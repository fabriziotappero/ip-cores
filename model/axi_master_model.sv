module axi_master_model (
axi_clk,
axi_resetn,
AWID    ,
AWADDR  ,
AWLEN   ,
AWSIZE  ,
AWBURST ,
AWLOCK  ,
AWCACHE ,
AWPROT  ,
AWVALID ,
AWREADY ,
//write data channel signals
WID     ,
WDATA   ,
WSTRB   ,
WLAST   ,
WVALID  ,
WREADY  ,
//write response channel
BID     ,
BRESP   ,
BVALID  ,
BREADY  ,
//Read control channel signals
ARID    ,
ARADDR  ,
ARLEN   ,
ARSIZE  ,
ARBURST ,
ARLOCK  ,
ARCACHE ,
ARPROT  ,
ARVALID ,
ARREADY ,
//Read data channel signals
RID     ,
RDATA   ,
RRESP   ,
RLAST   ,
RVALID  ,
RREADY
);
parameter AXI_ID_W          = 4;
parameter AXI_ADDR_W        = 32;
parameter AXI_DATA_W        = 32;
parameter AXI_PROT_W        = 3;
parameter AXI_STB_W         = 4;
parameter AXI_LEN_W         = 4;
parameter AXI_SIZE_W        = 3;
parameter AXI_BURST_W       = 2;
parameter AXI_LOCK_W        = 2;
parameter AXI_CACHE_W       = 4;
parameter AXI_RESP_W        = 2;

input  axi_clk;
input  axi_resetn;
output [AXI_ID_W       - 1:0]  AWID    ;
output [AXI_ADDR_W     - 1:0]  AWADDR  ;
output [AXI_LEN_W      - 1:0]  AWLEN   ;
output [AXI_SIZE_W     - 1:0]  AWSIZE  ;
output [AXI_BURST_W    - 1:0]  AWBURST ;
output [AXI_LOCK_W     - 1:0]  AWLOCK  ;
output [AXI_CACHE_W    - 1:0]  AWCACHE ;
output [AXI_PROT_W     - 1:0]  AWPROT  ;
output                         AWVALID ;
input                          AWREADY ;
  //write data channel signals
output [AXI_ID_W       - 1:0]  WID     ;
output [AXI_DATA_W     - 1:0]  WDATA   ;
output [AXI_STB_W      - 1:0]  WSTRB   ;
output                         WLAST   ;
output                         WVALID  ;
input                          WREADY  ;
  //write response channel
input  [AXI_ID_W       - 1:0]  BID     ;
input  [AXI_RESP_W     - 1:0]  BRESP   ;
input                          BVALID  ;
output                         BREADY  ;
  //Read control channel signals
output [AXI_ID_W        - 1:0] ARID    ;
output [AXI_ADDR_W      - 1:0] ARADDR  ;
output [AXI_LEN_W       - 1:0] ARLEN   ;
output [AXI_SIZE_W      - 1:0] ARSIZE  ;
output [AXI_BURST_W     - 1:0] ARBURST ;
output [AXI_LOCK_W      - 1:0] ARLOCK  ;
output [AXI_CACHE_W     - 1:0] ARCACHE ;
output [AXI_PROT_W      - 1:0] ARPROT  ;
output                         ARVALID ;
input                          ARREADY ;
  //Read data channel signals
input [AXI_ID_W   - 1:0]  RID     ;
input [AXI_DATA_W - 1:0]  RDATA   ;
input [AXI_RESP_W     - 1:0]  RRESP   ;
input                         RLAST   ;
input                         RVALID  ;
output                        RREADY  ;


reg  [AXI_ID_W   -1:0] axi_id    ;
reg  [AXI_ADDR_W -1:0] axi_addr  ;
reg  [AXI_LEN_W  -1:0] axi_len   ;
reg  [AXI_SIZE_W -1:0] axi_size  ;
reg  [AXI_BURST_W-1:0] axi_burst ;
reg  [AXI_LOCK_W -1:0] axi_lock  ;
reg  [AXI_CACHE_W-1:0] axi_cache ;
reg  [AXI_PROT_W -1:0] axi_prot  ;
reg                    axi_valid ;
reg                    wr_req    ;
reg  [AXI_ID_W   -1:0] axi_wid   ;
reg  [AXI_DATA_W -1:0] axi_wdata ;
reg  [AXI_STB_W  -1:0] axi_wstrb ;
reg                    axi_wlast ;
reg                    axi_wvalid;

reg  [AXI_ADDR_W-1:0] start_addr;
reg  [AXI_ADDR_W-1:0] end_addr;
reg  [7:0]            num_pkt;

initial begin 
  if ($value$plusargs("start_addr=%d", start_addr ))
    $display("****** start_addr=0x%0x", start_addr);
  else 
    start_addr = 32'h10_0000;
  if ($value$plusargs("end_addr=%d", end_addr ))
    $display("****** end_addr=0x%0x", end_addr);
  else 
    end_addr = 32'h1F_0000;
  if ($value$plusargs("num_pkt=%d", num_pkt))
    $display("****** num_pkt=%0d", num_pkt);
  else 
    num_pkt = 3;
end 
parameter AXI_IDLE = 3'b000;
parameter AXI_ADDR = 3'b001;
parameter AXI_DATA = 3'b010;
parameter AXI_WAIT_DATA = 3'b111;
parameter AXI_CFG  = 3'b011;
parameter AXI_UPD  = 3'b100;
reg [7:0]  pkt_count;
reg [4:0]  txn_count;
reg [1:0] axi_cs;
reg [1:0] axi_ns;

always @(posedge axi_clk or negedge axi_resetn)
  if (~axi_resetn) begin 
    axi_cs <= AXI_IDLE;
  end else begin 
    axi_cs <= axi_ns;
  end 

always @(posedge axi_clk or negedge axi_resetn)
  if (~axi_resetn) begin 
    pkt_count <= 0;
    txn_count <= 0;
  end else begin 
    case (axi_cs) 
      AXI_IDLE  : begin
        axi_id     <= 0;
        axi_addr   <= 0;
        axi_len    <= 0;
        axi_size   <= 0;
        axi_burst  <= 0;
        axi_lock   <= 0;
        axi_cache  <= 0;
        axi_prot   <= 0;
        axi_valid  <= 0;
        wr_req     <= 0;
        axi_wid    <= 0;
        axi_wdata  <= 0;
        axi_wstrb  <= 0;
        axi_wlast  <= 0;
        axi_wvalid <= 0;
        
      end 
      AXI_CFG : begin 
        pkt_count <= num_pkt;
      end 
      AXI_ADDR : begin 
        axi_id     <= 1;
        axi_addr   <= start_addr + 32'h20;
        axi_len    <= 4'hF;
        axi_size   <= 3'b010;
        axi_burst  <= 0;
        axi_lock   <= 0;
        axi_cache  <= 0;
        axi_prot   <= 0;
        axi_valid  <= 1;
        wr_req     <= 1;
        txn_count  <= 5'b10000;
      end 
      AXI_DATA: begin 
        txn_count <= txn_count >0 ? txn_count - 1 : txn_count;
        axi_valid <= 0;
        axi_wid   <= 2;
        axi_wdata <= $random; 
        axi_wstrb <= 4'hF;
        axi_wlast <= txn_count==0 ? 1 : 0;
        axi_wvalid<= 1'b1;
      end 
      AXI_WAIT_DATA : begin 
        axi_wvalid<= 1'b0;
      end 
      AXI_UPD : begin 
        pkt_count <= pkt_count >0 ? pkt_count -1 : pkt_count;
        axi_wvalid<= 1'b0;
      end 
    endcase
  end 

always @(*) begin 
  axi_ns = axi_cs;

  case (axi_cs)
    AXI_IDLE : begin 
      axi_ns = AXI_CFG;
    end
    AXI_CFG : begin 
      if (pkt_count >0 & AWREADY) 
         axi_ns = AXI_ADDR;
      else 
         axi_ns = AXI_CFG;
    end 
    AXI_ADDR : begin 
      axi_ns = AXI_DATA; 
    end 
    AXI_DATA: begin 
      if (WREADY & txn_count>0)
        axi_ns = AXI_DATA;
      else if (txn_count==0)
        axi_ns = AXI_UPD;
      else
        axi_ns = AXI_WAIT_DATA;
    end 
    AXI_WAIT_DATA: begin
      if (WREADY) 
        axi_ns = AXI_DATA;
      else 
        axi_ns = AXI_WAIT_DATA;
    end 
    AXI_UPD: begin 
      if (pkt_count >0)
        axi_ns = AXI_ADDR;
      else
        axi_ns = AXI_UPD;
    end 
  endcase 
end 

assign AWID    = wr_req ?axi_id     : 'hx;
assign AWADDR  = wr_req ?axi_addr   : 'hx;
assign AWLEN   = wr_req ?axi_len    : 'hx;
assign AWSIZE  = wr_req ?axi_size   : 'hx;
assign AWBURST = wr_req ?axi_burst  : 'hx;
assign AWLOCK  = wr_req ?axi_lock   : 'hx;
assign AWCACHE = wr_req ?axi_cache  : 'hx;
assign AWPROT  = wr_req ?axi_prot   : 'hx;
assign AWVALID = wr_req ?axi_valid  : 1'b0;
assign WID     = wr_req ?axi_wid    : 'hx;
assign WDATA   = wr_req ?axi_wdata  : 'hx;
assign WSTRB   = wr_req ?axi_wstrb  : 'hx;
assign WLAST   = wr_req ?axi_wlast  : 'hx;
assign WVALID  = wr_req ?axi_valid  : 1'b0;

assign BREADY  = 1'b1;
  //Read control channel signals
assign ARID    = wr_req ? 'hx : axi_id   ;
assign ARADDR  = wr_req ? 'hx : axi_addr ;
assign ARLEN   = wr_req ? 'hx : axi_len  ;
assign ARSIZE  = wr_req ? 'hx : axi_size ;
assign ARBURST = wr_req ? 'hx : axi_burst;
assign ARLOCK  = wr_req ? 'hx : axi_lock ;
assign ARCACHE = wr_req ? 'hx : axi_cache;
assign ARPROT  = wr_req ? 'hx : axi_prot ;
assign ARVALID = wr_req ? 1'b0: axi_valid;
  //Read data channel signals
assign RREADY = 1'b1;


endmodule 
