interface sram_if
  #(
    DATA_W                     = 64,
    ADDR_W                     = 13
  )
  ();

  logic                                   rd_l ;
  logic                                   wr_l ;
  logic  [ADDR_W-1:0]               rd_address ;
  logic  [ADDR_W-1:0]               wr_address ;
  logic  [DATA_W-1:0]                    rdata ;
  logic  [DATA_W-1:0]                    wdata ;

modport initiator (
  output                     rd_l ,
  output                     wr_l ,
  output               rd_address ,
  output               wr_address ,
  input                     rdata ,
  output                    wdata 
);

modport target (
  input                      rd_l ,
  input                      wr_l ,
  input                rd_address ,
  input                wr_address ,
  output                    rdata ,
  input                     wdata 
);

endinterface


