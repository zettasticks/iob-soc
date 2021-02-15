`timescale 1ns/1ps
`include "iob_lib.vh"
`include "iob_knn.vh"

module iob_knn #(parameter
	DATA_W = 32,
	ADDR_W = 6,
	UNITS = 16
	)
	(
		`INPUT(valid,1),
		`INPUT(address,ADDR_W),
		`INPUT(wdata,DATA_W),
		`INPUT(wstrb,1),
		`OUTPUT(rdata,DATA_W),
		`OUTPUT(ready,1),
	
		`INPUT(clk,1),
		`INPUT(rst,1)
	);

`include "KNN_sw_reg.v"
`include "KNN_sw_reg_gen.v"
`include "KNN_sw_reg_w.vh"

// Reset if signal high or reset reg asserted
`SIGNAL(reset,1)
`COMB reset = rst | KNN_RESET;

// Assert ready one cycle after receiving valid data 
`SIGNAL(readyOut,1)
`REG_AR(clk,rst,0,readyOut,valid)
`SIGNAL2OUT(ready,readyOut)

`SIGNAL(sendData,1)
`SIGNAL(useY,1)

wire [2:0] outClass[UNITS-1:0];
wire running[UNITS-1:0];
wire [15:0] datapointCoord[UNITS-1:0];

wire [15:0] datasetCoord = (useY ? KNN_DATASET_XY[31:16] : KNN_DATASET_XY[15:0]);

// Delays the class value until needed by the knn_units
wire [2:0] delayedDatasetClass;
delayedValue #(
	.DATA_W(`KNN_CLASS_W),
	.CYCLE_DELAY(5 + (`KNN_NUMBER_COORDS-1)) // Number of cycles it takes for squared_magnitude_calc to output valid data. Kinda janky, I know
	) delayedClass(
		.dataIn(KNN_DATASET_CLASS),
		.dataOut(delayedDatasetClass),
		.clk(clk),
		.rst(reset)
	);

reg incrementClass;
reg [`KNN_CLASS_W-1:0] classIndex;

`SIGNAL2OUT(KNN_CALCULATING_CLASS,incrementClass) // while incrementClass is asserted, software cannot access the KNN_CLASS registers

generate
	genvar i;

	for(i = 0; i < UNITS; i = i + 1) begin

		assign datapointCoord[i] = (useY ? KNN_DATAPOINT[i][31:16] : KNN_DATAPOINT[i][15:0]);

		knn_unit #(
			.COORD_W(`KNN_COORD_W),
			.CLASS_W(`KNN_CLASS_W),
			.K_W(`KNN_K_W),
			.K(`KNN_K),
			.N_COORDS(`KNN_NUMBER_COORDS)
			) unit (	.dataPointCoord(datapointCoord[i]),
						.dataSetCoord(datasetCoord),

						.valid(sendData),

						.classIn(delayedDatasetClass),
						.classOut(outClass[i]),

						.incrementClass(incrementClass),
						.classIndex(classIndex),

						.clk(clk),
						.rst(reset));		
	
		`REG_AR(clk,reset,0,KNN_CLASS[i],outClass[i])
	end
endgenerate

// Keep track of how many dataset points are sent
// Needed in the class calculation, to terminate early
// Optimization plus simplification of class calculation
wire datasetOverflow;
wire [`KNN_CLASS_W - 1:0] newDatasetCount;
reg datasetMaximum; // After the first overflow, stop counting
reg [`KNN_CLASS_W - 1:0] datasetCount;

assign {datasetOverflow,newDatasetCount} = datasetCount + 1;

// Control signal generation to dataset insertion
// Basically, one cycle after the CPU writes the dataset Class
// Starts the KNN units, with useY == 0 first and then useY == 1
// SendData is asserted for both times and then it is deasserted
always @(posedge clk)
begin
	if(valid & wstrb & (address == `KNN_DATASET_CLASS_ADDR)) // Writing to the class register starts the FSM
	begin
		sendData <= 1'b1;
		useY <= 1'b0;

		if(!datasetMaximum)
		begin
			datasetCount <= newDatasetCount;
		end

		if(datasetOverflow)
		begin
			datasetMaximum <= 1'b1;
		end
	end

	// First send Data with useY == 0 (send X coord)
	if(sendData & !useY)
	begin
		sendData <= 1'b1;
		useY <= 1'b1;
	end

	// Then send Data with useY == 1 (send Y coord) and finish 
	if(sendData & useY)
	begin
		sendData <= 1'b0;
	end

	if(reset)
	begin
		sendData <= 0;
		useY <= 0;
		datasetMaximum <= 0;
		datasetCount <= 0;
	end
end

// Calculates the increment of the class index
// The overflow indicates the end of the "loop"
wire overflow;
wire [`KNN_CLASS_W - 1:0] newClassIndex;

assign {overflow,newClassIndex} = classIndex + 1;

// Class calculation control signals
// Simple iterate over every class
// Increment the count in the count array
// And keep track of the biggest count (the class to output)
always @(posedge clk)
begin
	if(incrementClass)
	begin
		classIndex <= newClassIndex;
	end

	// Important for this if to be before the if(valid ...
	// For the odd case where we only have one dataset value
	if(overflow | (!datasetMaximum & newClassIndex == datasetCount))
	begin
		incrementClass <= 1'b0;
	end

	if(valid & wstrb & (address == `KNN_FINISHED_DATASET_ADDR))
	begin
		incrementClass <= 1'b1;
		classIndex <= 0;
	end

	if(reset)
	begin
		incrementClass <= 0;
		classIndex <= 0;
	end
end

endmodule

