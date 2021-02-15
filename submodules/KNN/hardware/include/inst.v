//instantiate core in system

   //
   // KNN
   //

   iob_knn #(
         .DATA_W(`KNN_DATA_W),
         .ADDR_W(`KNN_ADDR_W),
         .UNITS(`KNN_UNITS)
      ) knn (      
      //CPU interface
      .clk       (clk),
      .rst       (reset),
      .valid(slaves_req[`valid(`KNN)]),
      .address(slaves_req[`address(`KNN,`KNN_ADDR_W+2)-2]),
      .wdata(slaves_req[`wdata(`KNN)-(`DATA_W-`KNN_WDATA_W)]),
      .wstrb(|slaves_req[`wstrb(`KNN)]),
      .rdata(slaves_resp[`rdata(`KNN)]),
      .ready(slaves_resp[`ready(`KNN)])
      );
