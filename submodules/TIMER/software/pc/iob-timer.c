#include "iob-timer.h"
#include "time.h"

static clock_t startTime,endTime;
static int running;

#define FALSE 0
#define TRUE 1

void InitTimer(int base)
{
    running = FALSE;
    startTime = clock(); // Start at zero, time is given by difference between endTime and startTime
    endTime = startTime;
}

void StartTimer()
{
    startTime = clock();
    running = TRUE;
}

void StopTimer()
{
	endTime = clock();
	running = FALSE;
}

void ResetTimer()
{
	startTime = endTime;
}

int SampleTimer()
{
	clock_t timeToCompare = 0;

    if(!running){ // The hardware timer gives the same sample time when not running
		timeToCompare = endTime;
    } else {
    	timeToCompare = clock();
    }

    return (timeToCompare - startTime); // divide by CLOCKS_PER_SEC to get timer in seconds, for now only returns time in cycles
}
