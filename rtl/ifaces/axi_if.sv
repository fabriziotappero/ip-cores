interface axi_if
  #(AXI_ID_W               = 8,   
    AXI_ADDR_W             = 32,  
    AXI_DATA_W             = 32,  
    AXI_PROT_W             = 3,   
    AXI_STB_W              = 4,   
    AXI_LEN_W              = 4,
    AXI_SIZE_W             = 3,
    AXI_BURST_W            = 2,
    AXI_LOCK_W             = 2,
    AXI_CACHE_W            = 4,
    AXI_RESP_W             = 2
  )
  ();

  //Write control channel signals
  logic [AXI_ID_W       - 1:0]  AWID    ;
  logic [AXI_ADDR_W     - 1:0]  AWADDR  ;
  logic [AXI_LEN_W      - 1:0]  AWLEN   ;
  logic [AXI_SIZE_W     - 1:0]  AWSIZE  ;
  logic [AXI_BURST_W    - 1:0]  AWBURST ;
  logic [AXI_LOCK_W     - 1:0]  AWLOCK  ;
  logic [AXI_CACHE_W    - 1:0]  AWCACHE ;
  logic [AXI_PROT_W     - 1:0]  AWPROT  ;
  logic                         AWVALID ;
  logic                         AWREADY ;
  //write data channel signals
  logic [AXI_ID_W      - 1:0 ]  WID     ;
  logic [AXI_DATA_W    - 1:0]   WDATA   ;
  logic [AXI_STB_W     - 1:0]   WSTRB   ;
  logic                         WLAST   ;
  logic                         WVALID  ;
  logic                         WREADY  ;
  //write response channel
  logic [AXI_ID_W       - 1:0]  BID     ;
  logic [AXI_RESP_W     - 1:0]  BRESP   ;
  logic                         BVALID  ;
  logic                         BREADY  ;
  //Read control channel signals
  logic [AXI_ID_W        - 1:0] ARID    ;
  logic [AXI_ADDR_W      - 1:0] ARADDR  ;
  logic [AXI_LEN_W       - 1:0] ARLEN   ;
  logic [AXI_SIZE_W      - 1:0] ARSIZE  ;
  logic [AXI_BURST_W     - 1:0] ARBURST ;
  logic [AXI_LOCK_W      - 1:0] ARLOCK  ;
  logic [AXI_CACHE_W     - 1:0] ARCACHE ;
  logic [AXI_PROT_W      - 1:0] ARPROT  ;
  logic                         ARVALID ;
  logic                         ARREADY ;
  //Read data channel signals
  logic [AXI_ID_W       - 1:0]  RID     ;
  logic [AXI_DATA_W     - 1:0]  RDATA   ;
  logic [AXI_RESP_W     - 1:0]  RRESP   ;
  logic                         RLAST   ;
  logic                         RVALID  ;
  logic                         RREADY  ;

modport initiator (
  //Write control channel signals
  output AWID    ,
  output AWADDR  ,
  output AWLEN   ,
  output AWSIZE  ,
  output AWBURST ,
  output AWLOCK  ,
  output AWCACHE ,
  output AWPROT  ,
  output AWVALID ,
  input  AWREADY ,
  //write data channel signals
  output WID     ,
  output WDATA   ,
  output WSTRB   ,
  output WLAST   ,
  output WVALID  ,
  input  WREADY  ,
  //write response channel
  input  BID     ,
  input  BRESP   ,
  input  BVALID  ,
  output BREADY  ,
  //Read control channel signals
  output ARID    ,
  output ARADDR  ,
  output ARLEN   ,
  output ARSIZE  ,
  output ARBURST ,
  output ARLOCK  ,
  output ARCACHE ,
  output ARPROT  ,
  output ARVALID ,
  input  ARREADY ,
  //Read data channel signals
  input  RID     ,
  input  RDATA   ,
  input  RRESP   ,
  input  RLAST   ,
  input  RVALID  ,
  output RREADY
);

modport target (
  //Write control channel signals
  input  AWID    ,
  input  AWADDR  ,
  input  AWLEN   ,
  input  AWSIZE  ,
  input  AWBURST ,
  input  AWLOCK  ,
  input  AWCACHE ,
  input  AWPROT  ,
  input  AWVALID ,
  output AWREADY ,
  //write data channel signals
  input  WID     ,
  input  WDATA   ,
  input  WSTRB   ,
  input  WLAST   ,
  input  WVALID  ,
  output WREADY  ,
  //write response channel
  output BID     ,
  output BRESP   ,
  output BVALID  ,
  input  BREADY  ,
  //Read control channel signals
  input  ARID    ,
  input  ARADDR  ,
  input  ARLEN   ,
  input  ARSIZE  ,
  input  ARBURST ,
  input  ARLOCK  ,
  input  ARCACHE ,
  input  ARPROT  ,
  input  ARVALID ,
  output ARREADY ,
  //Read data channel signals
  output RID     ,
  output RDATA   ,
  output RRESP   ,
  output RLAST   ,
  output RVALID  ,
  input  RREADY
);

endinterface

