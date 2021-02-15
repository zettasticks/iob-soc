`timescale 1ns/1ps
`include "iob_knn.v"

module iob_knn_tb;

   parameter clk_frequency = 100e6; //100 MHz
   parameter baud_rate = 1e6; //high value to speed sim
   parameter clk_per = 1e9/clk_frequency;
   
   // CPU SIDE
   reg 			rst;
   reg 			clk;

   reg                  valid;
   reg [`UART_ADDR_W-1:0] addr;
   reg [`UART_WDATA_W-1:0] wdata;
   reg                     wstrb;
   wire [`UART_RDATA_W-1:0] rdata;
   wire                     ready;

   reg [`UART_RDATA_W-1:0]  cpu_readreg;

 
   //iterator
   integer               i;

   //serial data
   wire                  serial_data;

   // rts, cts handshaking
   wire                  rtscts;
   

   initial begin

`ifdef VCD
      $dumpfile("timer.vcd");
      $dumpvars;
`endif
      
      rst = 1;
      clk = 1;
      wstrb = 0;
      valid = 0;
      
      // deassert reset
      #100 @(posedge clk) rst = 0;
      #100 @(posedge clk);

      $display("Test completed successfully");
      $finish;

   end 

   //
   // CLOCKS
   //

   //system clock
   always #(clk_per/2) clk = ~clk;

   //
   // TASKS
   //

  // Instantiate the Unit Under Test (UUT)
  iob_knn knn(
      .valid(valid),
      .address(address),
      .wdata(wdata),
      .wstrb(wstrb),
      .rdata(rdata),
      .ready(ready),
   
      .clk(clk),
      .rst(rst)
   );

endmodule

