`define KNN_CLASS 	8 // Maximum of 8 classes
`define KNN_CLASS_W     3
`define KNN_K   	8 // Maximum of 8 neighbors
`define KNN_K_W 	3
`define KNN_COORD_W     16
`define KNN_NUMBER_COORDS 2

`define KNN_UNITS   16 // Number of paralel units, changing this also requires changing the values in KNN_sw_reg

`define KNN_ADDR_W 6   //address width
`define KNN_RDATA_W 3  //read data width
`define KNN_WDATA_W 32  //write data width
`ifndef DATA_W
 `define DATA_W 32      //cpu data width
`endif
