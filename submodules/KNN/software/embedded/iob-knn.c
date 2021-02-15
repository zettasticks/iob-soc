#include "iob-knn.h"
#include "KNN_sw_reg.h"
#include "interconnect.h"
#include "iob-uart.h"
#include "string.h"

#define TEST_ONLY_SOFTWARE 0
#define UNITS 16

#define myAssert(expr) if(!(expr)){ uart_printf("Assert line:%d\n",__LINE__); uart_finish();}

static int s_base;

typedef union{
	struct{
		u16 x,y;
	};
	u32 val32;
} Coordinates;

void InitKNN(int base)
{
  s_base = base;
}

static int ClassifyHardware(DataPoint* dataPoints,int dataSize,Point* dataset,int datasetSize)
{
  	int correctCount = 0;
	int offset = 0;

	if(dataSize == 0 | datasetSize == 0)
	{
		return 0;
	}

	while(dataSize > 0)
	{
		IO_SET(s_base,KNN_RESET,1);
		IO_SET(s_base,KNN_RESET,0);

		uart_printf("Start of loop %d %d\n",dataSize,offset);
		for(int i = 0; i < min(dataSize,UNITS); i++){
	    	DataPoint* dataPoint = &dataPoints[i + offset];

	    	Coordinates coord = (Coordinates) {.x = dataPoint->point.x,.y = dataPoint->point.y};

	    	IO_SET(s_base,(KNN_DATAPOINT0 + i),coord.val32);
		}
		uart_printf("Finished setting dataPoints\n");

		for(int i = 0; i < datasetSize; i++){
			Point point = dataset[i];
			
			Coordinates coord = (Coordinates) {.x = point.x,.y = point.y};

			IO_SET(s_base,KNN_DATASET_XY,coord.val32);
			IO_SET(s_base,KNN_DATASET_CLASS,point.class);
		}
		uart_printf("Finished sending dataset\n");

		IO_SET(s_base,KNN_FINISHED_DATASET,0);
		uart_printf("Hardware finished processing\n");

		int waitClassCalculating = 1;
		while(waitClassCalculating = IO_GET(s_base,KNN_CALCULATING_CLASS)); 

		for(int i = 0; i < min(dataSize,UNITS); i++){
			DataPoint* dataPoint = &dataPoints[i + offset];

			int class = IO_GET(s_base,(KNN_CLASS0 + i));

			correctCount += (class == dataPoint->point.class);
		}

		dataSize -= 16;
		offset += 16;
	}

	return correctCount;
}

// Internal helper functions
static u32 SquaredMagnitude(u16 x1,u16 y1,u16 x2,u16 y2){
	u16 diffX,diffY;
	u32 squaredX,squaredY,squaredMag;

	// Since we are using unsigned, need to calculate difference between max with min
	// Otherwise their is a possibility of overflow
#if 0
	diffX = x1 - x2;
	diffY = y1 - y2;
#else
	diffX = max(x1,x2) - min(x1,x2);
	diffY = max(y1,y2) - min(y1,y2);
#endif

	squaredX = ((u32) diffX * (u32) diffX);
	squaredY = ((u32) diffY * (u32) diffY);

	squaredMag = squaredX + squaredY;

	// On the off chance we have overflow (33 bits are needed), simple store the maximum value
	if(squaredMag < squaredX | squaredMag < squaredY){
		squaredMag = (u32) ~0;
	}

	return squaredMag;
}

static void OrderedNeighborInsert(Neighbor neighbors[K],Neighbor new){
	int i,j;
	Neighbor n,temp;

	for(i = 0; i < K; i++){
		n = neighbors[i];

		if(new.distance <= n.distance){
			break;
		}
	}

	if(i == K){
		return; // Nothing to insert, return early
	}

	// Perform swaps to insert the new value
	for(j = K-1; j != i; j--){
		neighbors[j] = neighbors[j-1];
	}

	neighbors[i] = new;
}

// Use a full software implementation
// Usually to compare the cycle count to the hardware accelerated one
static int ClassifySoftware(DataPoint* dataPoints,int dataSize,Point* dataset,int datasetSize)
{
	int correctCount = 0;

	if(dataSize == 0 | datasetSize == 0)
	{
		return 0;
	}

	for(int i = 0; i < dataSize; i++){
    	DataPoint* dataPoint = &dataPoints[i];

    	u16 x = dataPoint->point.x;
    	u16 y = dataPoint->point.y;

	    // Calculate nearest neighbors
	  	for(int ii = 0; ii < datasetSize; ii++){
	  		Point point = dataset[ii];

	  		u32 distance = SquaredMagnitude(x,y,point.x,point.y);

	  		OrderedNeighborInsert(dataPoint->neighbors,(Neighbor) {.class = point.class,.distance = distance});
	  	}

	  	// Calculate the count of classes
	  	int maximum = 0,maximumClass = 0;
	    int count[MAX_CLASS];
	  	memset(count,0,sizeof(count));
	  	for(int ii = 0; ii < min(datasetSize,K); ii++){
	  		int class = dataPoint->neighbors[ii].class;
	  		myAssert(class < MAX_CLASS);
	  		count[class] += 1;

	  		if(count[class] > maximum){
	  			maximum = count[class];
	  			maximumClass = class;
	  		}
	  	}

	  	correctCount += (maximumClass == dataPoint->point.class);
	}

	return correctCount;
}

int Classify(DataPoint* dataPoints,int dataSize,Point* dataset,int datasetSize)
{
	#if TEST_ONLY_SOFTWARE != 0
		return ClassifySoftware(dataPoints,dataSize,dataset,datasetSize);
	#else
		return ClassifyHardware(dataPoints,dataSize,dataset,datasetSize);
	#endif
}