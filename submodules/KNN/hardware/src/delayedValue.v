`timescale 1ns/1ps
`include "iob_lib.vh"

// Delays a value by CYCLE_DELAY cycles
// Implemented using chained registers
module delayedValue #(parameter
	DATA_W = 32,
	CYCLE_DELAY = 2
	)(
		`INPUT(dataIn,DATA_W),

		`OUTPUT(dataOut,DATA_W),

		`INPUT(clk,1),
		`INPUT(rst,1)
	);

reg [DATA_W-1:0] regs[CYCLE_DELAY-1:0];

`SIGNAL2OUT(dataOut,regs[CYCLE_DELAY-1])

integer i;
always @(posedge clk)
begin
	regs[0] <= dataIn;
	for(i = 1; i < CYCLE_DELAY; i = i + 1)
	begin
		regs[i] <= regs[i-1];
	end

	if(rst)
	begin
		for(i = 0; i < CYCLE_DELAY; i = i + 1)
		begin
			regs[i] <= 0;
		end
	end
end

endmodule