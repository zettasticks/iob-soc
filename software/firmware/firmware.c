#include "stdlib.h"
#include "system.h"
#include "periphs.h"
#include "iob-uart.h"
#include "printf.h"
#include "iob-timer.h"

int main()
{
  int i;

  //init uart 
  uart_init(UART_BASE,FREQ/BAUD);   
  uart_printf("\n\n\nHello world number %d!\n\n\n", 1);
 
  InitTimer(TIMER_BASE);

  ResetTimer();
  StartTimer();
  uart_printf("Started timer\n");

  for(i = 0; i < 3; i++){
    uart_printf("Waiting %d\n",SampleTimer());
  }

  StopTimer();
  uart_printf("Ended timer at:%d\n",SampleTimer());

  printf_("Value of Pi = %f\n\n", 3.1415);
  
  uart_finish();
}
