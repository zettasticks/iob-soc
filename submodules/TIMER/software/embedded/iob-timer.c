#include "iob-timer.h"
#include "sw_reg.h"
#include "interconnect.h"

static int s_base;

void InitTimer(int base)
{
  s_base = base;
}

void StartTimer()
{
  IO_SET(s_base,TIMER_RUN,1);
}

void StopTimer()
{
  IO_SET(s_base,TIMER_RUN,0);
}

int SampleTimer()
{
  return IO_GET(s_base,TIMER_DATA);
}

void ResetTimer()
{
  // Only reset time, does not stop timer
  IO_SET(s_base,TIMER_RESET,1);
  IO_SET(s_base,TIMER_RESET,0);
}
