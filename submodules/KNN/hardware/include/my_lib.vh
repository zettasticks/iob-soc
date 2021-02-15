`define FLATTEN(EXIST,WIDTH,SIZE,NEW,GENVAR_NAME) \
	wire [WIDTH-1:0] NEW[SIZE-1:0]; \
	generate \
		genvar GENVAR_NAME; \
		for(GENVAR_NAME = 0; GENVAR_NAME < SIZE; GENVAR_NAME = GENVAR_NAME + 1) begin \
			assign EXIST[WIDTH*GENVAR_NAME +: WIDTH] = NEW[GENVAR_NAME]; \
		end \
	endgenerate

`define DEFLATE(EXIST,WIDTH,SIZE,NEW,GENVAR_NAME) \
	wire [WIDTH-1:0] NEW[SIZE-1:0]; \
	generate \
		genvar GENVAR_NAME; \
		for(GENVAR_NAME = 0; GENVAR_NAME < SIZE; GENVAR_NAME = GENVAR_NAME + 1) begin \
			assign NEW[GENVAR_NAME] = EXIST[WIDTH*GENVAR_NAME +: WIDTH]; \
		end \
	endgenerate