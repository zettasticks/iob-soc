#include "stdint.h"

#define K 8
#define MAX_CLASS 8

#define max(x,y) ((x > y) ? x : y)
#define min(x,y) ((x > y) ? y : x)

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef unsigned int uint;
typedef int8_t i8;
typedef int16_t i16;
typedef int32_t i32;

typedef struct{
	u16 x,y;
	u8 class;
} Point;

typedef struct{
	u8 class;
	u32 distance;
} Neighbor;

typedef struct{
	Point point;
	Neighbor neighbors[K];
} DataPoint;

typedef u8 (*TestsetFunction)(u16 x,u16 y,int* args);

void InitKNN(int base);

int Classify(DataPoint* data,int dataSize,Point* dataset,int datasetSize);
