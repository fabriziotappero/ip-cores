`include "wb2axi_parameters.vh"
module tb;

reg axi_clk;
reg wb_clk;
reg resetn;

axi_if #(
  .AXI_ID_W      (`WB2AXI_AXI_ID_W    ),          
  .AXI_ADDR_W    (`WB2AXI_AXI_ADDR_W  ),          
  .AXI_DATA_W    (`WB2AXI_AXI_DATA_W  ),          
  .AXI_PROT_W    (`WB2AXI_AXI_PROT_W  ),          
  .AXI_STB_W     (`WB2AXI_AXI_STB_W   ),          
  .AXI_LEN_W     (`WB2AXI_AXI_LEN_W   ),          
  .AXI_SIZE_W    (`WB2AXI_AXI_SIZE_W  ),          
  .AXI_BURST_W   (`WB2AXI_AXI_BURST_W ),          
  .AXI_LOCK_W    (`WB2AXI_AXI_LOCK_W  ),          
  .AXI_CACHE_W   (`WB2AXI_AXI_CACHE_W ),          
  .AXI_RESP_W    (`WB2AXI_AXI_RESP_W  )          
) axi_if_m();

wishbone_if #(
  .WB_ADR_WIDTH(`WB2AXI_WB_ADR_W) ,
  .WB_BTE_WIDTH(`WB2AXI_WB_BTE_W) , 
  .WB_CTI_WIDTH(`WB2AXI_WB_CTI_W) ,
  .WB_DAT_WIDTH(`WB2AXI_WB_DAT_W) ,
  .WB_TGA_WIDTH(`WB2AXI_WB_TGA_W) ,
  .WB_TGD_WIDTH(`WB2AXI_WB_TGD_W) ,
  .WB_TGC_WIDTH(`WB2AXI_WB_TGC_W) ,
  .WB_SEL_WIDTH(`WB2AXI_WB_SEL_W)  
) wb_if_s(); 

assign wb_if_s.ACK = 1'b1;

axi_master_model# (
  .AXI_ID_W      (`WB2AXI_AXI_ID_W    ),          
  .AXI_ADDR_W    (`WB2AXI_AXI_ADDR_W  ),          
  .AXI_DATA_W    (`WB2AXI_AXI_DATA_W  ),          
  .AXI_PROT_W    (`WB2AXI_AXI_PROT_W  ),          
  .AXI_STB_W     (`WB2AXI_AXI_STB_W   ),          
  .AXI_LEN_W     (`WB2AXI_AXI_LEN_W   ),          
  .AXI_SIZE_W    (`WB2AXI_AXI_SIZE_W  ),          
  .AXI_BURST_W   (`WB2AXI_AXI_BURST_W ),          
  .AXI_LOCK_W    (`WB2AXI_AXI_LOCK_W  ),          
  .AXI_CACHE_W   (`WB2AXI_AXI_CACHE_W ),          
  .AXI_RESP_W    (`WB2AXI_AXI_RESP_W  )  
)I_AXIM (
  .axi_clk       (axi_clk         ),
  .axi_resetn    (resetn          ),
  .AWID          (axi_if_m.AWID   ),
  .AWADDR        (axi_if_m.AWADDR ),
  .AWLEN         (axi_if_m.AWLEN  ),
  .AWSIZE        (axi_if_m.AWSIZE ),
  .AWBURST       (axi_if_m.AWBURST),
  .AWLOCK        (axi_if_m.AWLOCK ),
  .AWCACHE       (axi_if_m.AWCACHE),
  .AWPROT        (axi_if_m.AWPROT ),
  .AWVALID       (axi_if_m.AWVALID),
  .AWREADY       (axi_if_m.AWREADY),
  .WID           (axi_if_m.WID    ),
  .WDATA         (axi_if_m.WDATA  ),
  .WSTRB         (axi_if_m.WSTRB  ),
  .WLAST         (axi_if_m.WLAST  ),
  .WVALID        (axi_if_m.WVALID ),
  .WREADY        (axi_if_m.WREADY ),
  .BID           (axi_if_m.BID    ),
  .BRESP         (axi_if_m.BRESP  ),
  .BVALID        (axi_if_m.BVALID ),
  .BREADY        (axi_if_m.BREADY ),
  .ARID          (axi_if_m.ARID   ),
  .ARADDR        (axi_if_m.ARADDR ),
  .ARLEN         (axi_if_m.ARLEN  ),
  .ARSIZE        (axi_if_m.ARSIZE ),
  .ARBURST       (axi_if_m.ARBURST),
  .ARLOCK        (axi_if_m.ARLOCK ),
  .ARCACHE       (axi_if_m.ARCACHE),
  .ARPROT        (axi_if_m.ARPROT ),
  .ARVALID       (axi_if_m.ARVALID),
  .ARREADY       (axi_if_m.ARREADY),
  .RID           (axi_if_m.RID    ),
  .RDATA         (axi_if_m.RDATA  ),
  .RRESP         (axi_if_m.RRESP  ),
  .RLAST         (axi_if_m.RLAST  ),
  .RVALID        (axi_if_m.RVALID ),
  .RREADY        (axi_if_m.RREADY )
);


axi2wb #(
  .AXI_ID_W         (`WB2AXI_AXI_ID_W         ),
  .AXI_ADDR_W       (`WB2AXI_AXI_ADDR_W       ),
  .AXI_DATA_W       (`WB2AXI_AXI_DATA_W       ),
  .AXI_PROT_W       (`WB2AXI_AXI_PROT_W       ),
  .AXI_STB_W        (`WB2AXI_AXI_STB_W        ),
  .AXI_LEN_W        (`WB2AXI_AXI_LEN_W        ),
  .AXI_SIZE_W       (`WB2AXI_AXI_SIZE_W       ),
  .AXI_BURST_W      (`WB2AXI_AXI_BURST_W      ),
  .AXI_LOCK_W       (`WB2AXI_AXI_LOCK_W       ),
  .AXI_CACHE_W      (`WB2AXI_AXI_CACHE_W      ),
  .AXI_RESP_W       (`WB2AXI_AXI_RESP_W       ),
  .FIFO_ADDR_DEPTH_W(`WB2AXI_FIFO_ADDR_DEPTH_W),
  .FIFO_DATA_DEPTH_W(`WB2AXI_FIFO_DATA_DEPTH_W),
  .WB_ADR_W         (`WB2AXI_WB_ADR_W         ),
  .WB_DAT_W         (`WB2AXI_WB_DAT_W         ),
  .WB_TGA_W         (`WB2AXI_WB_TGA_W         ),
  .WB_TGD_W         (`WB2AXI_WB_TGD_W         ),
  .WB_TGC_W         (`WB2AXI_WB_TGC_W         ),
  .WB_SEL_W         (`WB2AXI_WB_SEL_W         ),
  .WB_CTI_W         (`WB2AXI_WB_CTI_W         ),
  .WB_BTE_W         (`WB2AXI_WB_BTE_W         )
) I_AXI2WB (
  .axi_clk   (axi_clk ),
  .wb_clk    (wb_clk  ),
  .axi_resetn(resetn  ),
  .wb_resetn (resetn  ),
  .ENABLE    (1'b1    ),
  .AXI_IF    (axi_if_m),
  .WB_TX_IF  (wb_if_s )
);

initial begin 
  wb_clk = 1'b1;
  axi_clk= 1'b1;
  resetn = 1'b1;
  #10;
  resetn = 1'b0;
  #100;
  $display ("Resetn is done");
  resetn = 1'b1;
  #20000;
  $display ("Simulation is done");
  $finish;
end 
always begin 
  #2;
  axi_clk = ~axi_clk;
end 

always begin 
  #5 wb_clk = ~wb_clk; 
end 

initial begin 
    $fsdbDumpfile("./test_wb2axi.fsdb");
    $fsdbDumpvars(0, tb);
end 

endmodule 
