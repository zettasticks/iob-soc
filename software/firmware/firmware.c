#include "stdlib.h"
#include "system.h"
#include "periphs.h"
#include "iob-uart.h"
#include "printf.h"
#include "iob-timer.h"
#include "iob-knn.h"
#include "string.h"

#define MAX_ARGS 4
#define INITIAL_SEED 123
#define DATASET_SIZE 10
#define NUMBER_POINTS 30

// Simple random function
static uint seed = INITIAL_SEED;
uint SimpleRand(){
	seed = (1664525 * seed + 1013904223);
	return seed;
}

// Sets the arguments for a LinearTestset function
void SetLinearArgs(int* args,int x1,int y1,int x2,int y2){
	int vecX,vecY,crossX,crossY;

    vecX = x2 - x1;
    vecY = y2 - y1;

    crossX = -vecY;
    crossY = vecX;

    args[0] = crossX;
    args[1] = crossY;
}

// Testset for a line that separates point into two classes
// Points on one side are set to class 0 while the points on the other side are set to 1
u8 LinearTestset(u16 x,u16 y,int* args){
	// Basically computes dot product and checks if positive or not
	int normalX,normalY;

	normalX = args[0];
	normalY = args[1];

	return (normalX * x + normalY * y >= 0) ? 1 : 0;
}

// Sets the arguments for a GridTestset function
void SetGridArgs(int* args,int cellStride,int powerTwoClasses){
	args[0] = cellStride;
	args[1] = powerTwoClasses;
}

// Testset that separates points in a grid
u8 GridTestset(u16 x,u16 y,int* args){
	int cellStride,powerTwoClasses;

	cellStride = args[0];
	powerTwoClasses = args[1];

	// Multiplication probably slowing this too much
	x >>= cellStride;
	y >>= cellStride;

	return ((x+y) & (powerTwoClasses-1));
}

// Prints a grid of 8x8 with the classification
// The point used corresponds to the middle point of each cell
// Does not work to well for > 10 classes, since it prints the number
void PrintClassificationGrid(TestsetFunction func,int* args){
	int x,y;
	char buffer[1024];
	char* ptr;

	const u16 GRID_LENGTH = ~0;
	const u16 CELL_LENGTH = (GRID_LENGTH / 8);
	const u16 HALF_CELL = (CELL_LENGTH / 2);

	ptr = buffer;
	for(y = GRID_LENGTH - HALF_CELL; y > 0; y -= CELL_LENGTH){
		for(x = HALF_CELL; x < GRID_LENGTH; x += CELL_LENGTH){
			u8 class = func(x,y,args);
			ptr += sprintf(ptr,"%d",class);
		}
		ptr += sprintf(ptr,"\n");
	}
	ptr += sprintf(ptr,"\n");

	uart_printf("%s",buffer);
}

int main()
{
  Point dataset[DATASET_SIZE];
  DataPoint dataPoints[NUMBER_POINTS];

  //Initialize pheripherals
  uart_init(UART_BASE,FREQ/BAUD);   
  uart_printf("\n KNN \n\n");
 
  InitTimer(TIMER_BASE);
  InitKNN(KNN_BASE);

  // Initialize data points
  // Assume that at the start the distance is infinite
  // Needed to make the ordered insert function work
  for(int i = 0; i < NUMBER_POINTS; i++){
  	for(int ii = 0; ii < K; ii++){
  		dataPoints[i].neighbors[ii].distance = ~0;
  		dataPoints[i].neighbors[ii].class = ~0;
  	}
  }

  // Set the arguments for the dataset creation
  TestsetFunction testSet = GridTestset;
  int testSetArgs[MAX_ARGS];
  SetGridArgs(testSetArgs,13,4);

  // Print the classification grid for 8 x 8 evenly distributed points
#if 0
  uart_printf("Classification grid:\n\n");
  PrintClassificationGrid(testSet,testSetArgs);
#endif

  ResetTimer();
  StartTimer();
  uart_printf("Generating dataset\n\n");

  for(int i = 0; i < DATASET_SIZE; i++){
    u16 x = (u16) SimpleRand();
    u16 y = (u16) SimpleRand();

    dataset[i].x = x;
    dataset[i].y = y;
    dataset[i].class = testSet(x,y,testSetArgs);
  }

  uart_printf("Finished generating %d samples, cycles taken: %d\n\n",DATASET_SIZE,SampleTimer());

  ResetTimer();
  uart_printf("Generating and classifying\n");

  for(int i = 0; i < NUMBER_POINTS; i++){
    DataPoint* dataPoint = &dataPoints[i];

    u16 x = (u16) SimpleRand();
    u16 y = (u16) SimpleRand();

    dataPoint->point.x = x;
    dataPoint->point.y = y;
    dataPoint->point.class = testSet(x,y,testSetArgs); // Store the true value it is supposed to have
  }

  int accurancy = Classify(dataPoints,NUMBER_POINTS,dataset,DATASET_SIZE);

  uart_printf("Finished classification. Correctly classified: %d/%d. Took %d cycles\n",accurancy,NUMBER_POINTS,SampleTimer());

  uart_finish();
}
