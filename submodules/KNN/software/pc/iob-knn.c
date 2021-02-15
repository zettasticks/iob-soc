#include "iob-knn.h"
#include "time.h"
#include "string.h"
#include "stdlib.h"
#include "stdio.h"

#define assert(expr) if(!(expr)){ printf("Assert line:%d\n",__LINE__); exit(0);}

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

// External functions
void InitKNN(int base)
{
}

int Classify(DataPoint* dataPoints,int dataSize,Point* dataset,int datasetSize)
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
	  		assert(class < MAX_CLASS);
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
