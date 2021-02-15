`timescale 1ns/1ps
`include "iob_lib.vh"

// An individual knn unit
// 
module knn_unit #(parameter
	COORD_W = 16,
	CLASS_W = 3,
	K_W = 3,
	K = 8,
	N_COORDS = 2
	)(
		`INPUT(valid,1),
		`INPUT(dataPointCoord,COORD_W),
		`INPUT(dataSetCoord,COORD_W),

		`INPUT(classIn,CLASS_W),
		`OUTPUT(classOut,CLASS_W),

		// Class calculation control variables
		`INPUT(incrementClass,1),
		`INPUT(classIndex,K_W),

		`INPUT(clk,1),
		`INPUT(rst,1)
	);

wire [COORD_W * 2:0] calculatedDistance;
wire outputValid;

squared_magnitude_calc #(
		.DATA_W(COORD_W),
		.COORDINATES(N_COORDS)
	    ) calc (
		.valid(valid),
		.p1(dataPointCoord), 
		.p2(dataSetCoord),

		.out(calculatedDistance),
		.outputValid(outputValid),
		
		.clk(clk),
		.rst(rst)
	);

reg [((COORD_W * 2 + 1) * K)-1:0] compOut;
reg [(CLASS_W * K)-1:0] bagOut;

`DEFLATE(bagOut,CLASS_W,K,classArray,temp1)

ordered_list #(
		.COMP_W(COORD_W * 2 + 1),  // Store distance
		.BAG_W(CLASS_W),    // Store class
		.LIST_SIZE(K) // Up to K neighbors
	) distanceList(
		.valid(outputValid),
		.compIn(calculatedDistance),
		.bagIn(classIn),

		.compOut(compOut),
		.bagOut(bagOut),

		.clk(clk),
		.rst(rst)
	);

integer i;
reg [CLASS_W-1:0] count[(2**CLASS_W)-1:0];
reg [K_W-1:0] maxCount,maxCountIndex;
wire [CLASS_W-1:0] currentClass = classArray[classIndex];
wire [CLASS_W-1:0] newCount = count[currentClass] + 1;

wire [CLASS_W-1:0] debugCount = count[3'b011];

always @(posedge clk)
begin
	if(incrementClass)
	begin
		count[currentClass] <= newCount;
		
		if(newCount > maxCount)
		begin
			maxCount <= newCount;
			maxCountIndex <= currentClass;
		end
	end

	if(rst)
	begin
		for(i = 0; i < (2**CLASS_W); i = i + 1)
		begin
			count[i] <= 0;
 		end
 		maxCount <= 0;
 		maxCountIndex <= 0;
	end
end

`SIGNAL2OUT(classOut,maxCountIndex)

endmodule