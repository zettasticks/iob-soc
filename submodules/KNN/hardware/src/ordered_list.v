`timescale 1ns/1ps
`include "iob_lib.vh"
`include "my_lib.vh"

// A ordered list
// Comp is the value used for comparison, bagage is extra data associated to the comp value
module ordered_list #(parameter
	COMP_W = 32, // Size of data that is compared
	BAG_W = 32,  // Size of bagage data
	LIST_SIZE = 8
	)(
		`INPUT(valid,1), 					// Indicates that the outside data is valid
		`INPUT(compIn,COMP_W), 				// Value used for comparision from outside
		`INPUT(bagIn,BAG_W),				// Bagage from outside

		`OUTPUT(compOut,COMP_W * LIST_SIZE),
		`OUTPUT(bagOut,BAG_W * LIST_SIZE),

		`INPUT(clk,1),
		`INPUT(rst,1)
	);

`FLATTEN(compOut,COMP_W,LIST_SIZE,compOutDeflated,temp1)
`FLATTEN(bagOut,BAG_W,LIST_SIZE,bagOutDeflated,temp2)

ordered_list_unit #(
		.COMP_W(COMP_W),
		.BAG_W(BAG_W)
	) unit0 (
		.valid(valid),
		.compIn(compIn),
		.bagIn(bagIn),

		.previousUnitComp(33'b0),
		.previousUnitBag(3'b0),

		.compOut(compOutDeflated[0]),
		.bagOut(bagOutDeflated[0]),

		.clk(clk),
		.rst(rst)
		);

generate
	genvar i;
	
	for(i = 1; i < LIST_SIZE; i = i + 1) begin
		ordered_list_unit #(
			.COMP_W(COMP_W),
			.BAG_W(BAG_W)
		) unit (
			.valid(valid),
			.compIn(compIn),
			.bagIn(bagIn),

			.previousUnitComp(compOutDeflated[i-1]),
			.previousUnitBag(bagOutDeflated[i-1]),

			.compOut(compOutDeflated[i]),
			.bagOut(bagOutDeflated[i]),

			.clk(clk),
			.rst(rst)
			);
	end

endgenerate

endmodule