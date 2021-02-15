`timescale 1ns/1ps
`include "iob_lib.vh"

module iob_timer #(parameter
	DATA_W = 32,
	ADDR_W = 2
	)
	(
		`INPUT(valid,1),
		`INPUT(address,ADDR_W),
		`INPUT(wdata,1),
		`INPUT(wstrb,1),
		`OUTPUT(rdata,DATA_W),
		`OUTPUT(ready,1),
	
		`INPUT(clk,1),
		`INPUT(rst,1)
	);

`include "TIMER_sw_reg.v"
`include "TIMER_sw_reg_gen.v"
`include "TIMER_sw_reg_w.vh"

// Reset if signal high or reset reg asserted
`SIGNAL(reset,1)
`COMB reset = rst | TIMER_RESET;

// TIMER_DATA is a simple counter that runs while the TIMER_RUN register is asserted
`COUNTER_RE(clk,reset,TIMER_RUN,TIMER_DATA)

// Assert ready one cycle after receiving valid data 
`SIGNAL(readyOut,1)
`REG_AR(clk,rst,0,readyOut,valid)
`SIGNAL2OUT(ready,readyOut)

endmodule

