`timescale 1ns/1ps
`include "iob_lib.vh"

// A squared magnitude calculate module
// Fully pipelined, uses two comparators, one subtract, one adder and one unsigned multiplier

// This module expects to receive data over COORDINATE cycles
// Each cycle corresponds to a given coordinate
module squared_magnitude_calc #(parameter
	DATA_W = 16,
	COORDINATES = 2
	)(
		`INPUT(valid,1),
		`INPUT(p1,DATA_W), // Coordinate value of point 1 
		`INPUT(p2,DATA_W), // Coordinate value of point 2

		`OUTPUT(out,DATA_W * 2 + 1), // Need 2 * DATA_W + 1 bits to fully store the result
		`OUTPUT(outputValid,1),
		
		`INPUT(clk,1),
		`INPUT(rst,1)
	);

reg [$clog2(COORDINATES)-1:0] currentCoordinate;

wire [$clog2(COORDINATES):0] nextCoordinate = currentCoordinate + 1;
wire lastCoordinate = (nextCoordinate == COORDINATES);

always @(posedge clk)
begin
	if(valid)
	begin
		currentCoordinate <= nextCoordinate;
	end

	if(rst)
	begin
		currentCoordinate <= 0;
	end
end

// Start of pipelined stage
// Stage 1, save the values
reg [DATA_W-1:0] stage_1_p1,stage_1_p2;
reg stage_1_lastCoordinate;
reg stage_1_valid;

always @(posedge clk)
begin
	stage_1_p1 <= p1;
	stage_1_p2 <= p2;
	stage_1_lastCoordinate <= lastCoordinate;
	stage_1_valid <= valid;

	if(rst)
	begin
		stage_1_p1 <= 0;
		stage_1_p2 <= 0;
		stage_1_lastCoordinate <= 0;
		stage_1_valid <= 0;
	end
end

// Stage 2, save min and max
reg [DATA_W-1:0] stage_2_max,stage_2_min;
reg stage_2_lastCoordinate;
reg stage_2_valid;

always @(posedge clk)
begin
	stage_2_max <= (stage_1_p1 > stage_1_p2 ? stage_1_p1 : stage_1_p2); 
	stage_2_min <= (stage_1_p1 > stage_1_p2 ? stage_1_p2 : stage_1_p1);
	stage_2_lastCoordinate <= stage_1_lastCoordinate;
	stage_2_valid <= stage_1_valid;

	if(rst)
	begin
		stage_2_max <= 0;
		stage_2_min <= 0;
		stage_2_lastCoordinate <= 0;
		stage_2_valid <= 0;
	end
end

// Stage 3, compute diff
reg [DATA_W-1:0] stage_3_diff;
reg stage_3_lastCoordinate;
reg stage_3_valid;

always @(posedge clk)
begin
	stage_3_diff <= stage_2_max - stage_2_min;
	stage_3_lastCoordinate <= stage_2_lastCoordinate;
	stage_3_valid <= stage_2_valid;

	if(rst)
	begin
		stage_3_diff <= 0;
		stage_3_lastCoordinate <= 0;
		stage_3_valid <= 0;
	end
end

// Stage 4, compute multiplication
reg [DATA_W*2-1:0] stage_4_mult;
reg stage_4_lastCoordinate;
reg stage_4_valid;

always @(posedge clk)
begin
	stage_4_mult <= (stage_3_diff * stage_3_diff); // A direct multiplication is probably impossible to due in hardware, either way it is simple to add more stages
	stage_4_lastCoordinate <= stage_3_lastCoordinate;
	stage_4_valid <= stage_3_valid;

	if(rst)
	begin
		stage_4_mult <= 0;
		stage_4_lastCoordinate <= 0;
		stage_4_valid <= 0;
	end
end

// Stage 5, accumulate
reg [DATA_W*2:0] accumulator;
reg stage_5_valid;
wire [DATA_W*2:0] nextAccum = accumulator + stage_4_mult;

always @(posedge clk)
begin
	if(stage_4_valid)
	begin
		accumulator <= nextAccum;
	end
	stage_5_valid <= stage_4_valid;

	if(rst | stage_4_lastCoordinate)
	begin
		accumulator <= 0;
		stage_5_valid <= 0;
	end
end

// Stage 6, output
reg [DATA_W*2:0] out;
reg outputValid;

always @(posedge clk)
begin
	out <= nextAccum;
	outputValid <= stage_5_valid;

	if(rst)
	begin
		out <= 0;
		outputValid <= 0;
	end
end

endmodule