`timescale 1ns/1ps
`include "iob_lib.vh"

// A unit designed to implement a ordered list
// Each unit stores a comparison value, called comp, and bagage data, called bag

// Each unit is supposed to be connected to a next unit
// Each unit works out individually if it should store the outside value or the previous unit value
// This simplifies the critical path to just be from one unit to the next, instead of accumulating for every unit in the "list"
// The only downside is the extra comparison unit
module ordered_list_unit #(parameter
	COMP_W = 32, // Size of data that is compared
	BAG_W = 32  // Size of bagage data  
	)(
		`INPUT(valid,1), 					// Indicates that the outside data is valid
		`INPUT(compIn,COMP_W), 				// Value used for comparison from outside
		`INPUT(bagIn,BAG_W),				// Bagage from outside

		`INPUT(previousUnitComp,COMP_W),	// Previous unit values
		`INPUT(previousUnitBag,BAG_W),		

		`OUTPUT(compOut,COMP_W), // Output, should be connected to the next unit (first unit should have ~0 to work)
		`OUTPUT(bagOut,BAG_W),

		`INPUT(clk,1),
		`INPUT(rst,1)
	);

// State
`SIGNAL(storedComp,COMP_W)
`SIGNAL(storedBag,BAG_W)

`SIGNAL2OUT(compOut,storedComp)
`SIGNAL2OUT(bagOut,storedBag)

wire insertNewValue = valid & (compIn < storedComp); // 1 if need to insert new value
wire insertFromPreviousUnit = (compIn < previousUnitComp); // 1 if new value comes from previous unit, 0 if from outside

// New values to insert
wire [COMP_W-1:0] newComp = (insertFromPreviousUnit ? previousUnitComp : compIn);
wire [BAG_W-1:0] newBag = (insertFromPreviousUnit ? previousUnitBag : bagIn);

always @(posedge clk)
begin
	if(insertNewValue)
	begin
		storedComp <= newComp;
		storedBag <= newBag;
	end

	if(rst)
	begin
		storedComp <= ~0;
		storedBag <= 0;
	end
end

endmodule