`define FLATTEN(BEFORE,WIDTH,SIZE,AFTER,GENVAR_NAME) \
	wire [WIDTH*SIZE-1:0] AFTER; \
	generate \
		genvar GENVAR_NAME; \
		for(GENVAR_NAME = 0; GENVAR_NAME < SIZE; GENVAR_NAME = GENVAR_NAME + 1) begin \
			assign AFTER[WIDTH*GENVAR_NAME +: WIDTH] = BEFORE[GENVAR_NAME]; \
		end \
	endgenerate

`define DEFLATE(BEFORE,WIDTH,SIZE,AFTER,GENVAR_NAME) \
	wire [WIDTH-1:0] AFTER[SIZE-1:0]; \
	generate \
		genvar GENVAR_NAME; \
		for(GENVAR_NAME = 0; GENVAR_NAME < SIZE; GENVAR_NAME = GENVAR_NAME + 1) begin \
			assign AFTER[GENVAR_NAME] = BEFORE[WIDTH*GENVAR_NAME +: WIDTH]; \
		end \
	endgenerate