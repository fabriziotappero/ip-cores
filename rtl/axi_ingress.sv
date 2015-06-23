//Author     : Alex Zhang (cgzhangwei@gmail.com)
//Date       : 03-11-2015
//Basic : How to storage the AXI info and data into sram or fifo.
`include "wb2axi_parameters.vh"

module axi_ingress (
axi_clk,
reset_n,
AXI_IF,
fifo_full,
fifo_addr_info,
fifo_data_info,
fifo_addr_wr,
fifo_data_wr
);
parameter  AXI_ID_W         = `WB2AXI_AXI_ID_W   ;
parameter  AXI_ADDR_W       = `WB2AXI_AXI_ADDR_W ;
parameter  AXI_DATA_W       = `WB2AXI_AXI_DATA_W ;
parameter  AXI_PROT_W       = `WB2AXI_AXI_PROT_W ;
parameter  AXI_STB_W        = `WB2AXI_AXI_STB_W  ;
parameter  AXI_LEN_W        = `WB2AXI_AXI_LEN_W  ;
parameter  AXI_SIZE_W       = `WB2AXI_AXI_SIZE_W ;
parameter  AXI_BURST_W      = `WB2AXI_AXI_BURST_W;
parameter  AXI_LOCK_W       = `WB2AXI_AXI_LOCK_W ;
parameter  AXI_CACHE_W      = `WB2AXI_AXI_CACHE_W;
parameter  AXI_RESP_W       = `WB2AXI_AXI_RESP_W ;
parameter  AXI_MAX_RESP_W   = 3; 
parameter  FIFO_ADR_W       = 10;
parameter  FIFO_DAT_W       = 10;

input                axi_clk;
input                reset_n;
axi_if.target        AXI_IF;
output               fifo_full;
output [FIFO_ADR_W-1:0] fifo_addr_info;
output [FIFO_DAT_W-1:0] fifo_data_info;
output reg           fifo_addr_wr;
output reg           fifo_data_wr;
localparam     ST_W = 2;
localparam  ST_IDLE = 2'b00;
localparam ST_WDATA = 2'b01;
localparam ST_BRESP = 2'b10;
localparam AXI_MAX_RESP_VAL = {AXI_MAX_RESP_W{1'b1}};

wire   input_addr_event;
wire   input_data_event;
wire   inc_bresp;
wire   dec_bresp;
wire   bresp_cnt_max;


reg [ST_W-1:0]            state;
reg [ST_W-1:0]            next_state;
reg [AXI_MAX_RESP_W-1:0]  bresp_pending_cnt;  //responses pending to generate
reg [AXI_ID_W-1:0]       last_wid;
reg [FIFO_ADR_W-1:0]         fifo_addr_in;
reg [FIFO_DAT_W-1:0]         fifo_data_in;

assign input_addr_event = AXI_IF.AWVALID & AXI_IF.AWREADY;
assign input_data_event = AXI_IF.WVALID  & AXI_IF.WREADY;
assign inc_bresp = AXI_IF.WLAST & input_data_event;
assign dec_bresp = AXI_IF.BREADY & AXI_IF.BVALID;
assign bresp_cnt_max = (bresp_pending_cnt == AXI_MAX_RESP_VAL);

always_comb begin 
  next_state   = state;
  fifo_addr_wr = 0;
  
  case (state)
    ST_IDLE : begin 
      if(input_addr_event) begin 
        fifo_addr_wr = 1;
        fifo_addr_in = {AXI_IF.AWID, AXI_IF.AWADDR, AXI_IF.AWLEN, AXI_IF.AWSIZE, AXI_IF.AWBURST, AXI_IF.AWLOCK, AXI_IF.AWCACHE, AXI_IF.AWPROT, 1'b1}; //Wr address info
        next_state = ST_WDATA;
      end else begin 
        fifo_addr_wr = 0;
        next_state = ST_IDLE;
      end 
    end 
    ST_WDATA: begin 
      if (input_data_event) begin 
        fifo_data_wr = 1;
        fifo_data_in = {AXI_IF.WID, AXI_IF.WDATA, AXI_IF.WSTRB, AXI_IF.WLAST, AXI_IF.WVALID};
        next_state = ST_BRESP;
      end else begin 
        fifo_data_wr = 0;
        next_state = ST_WDATA;
      end 
    end 
    ST_BRESP : begin 
      next_state = ST_IDLE;
    end 
   

  endcase 
end

always @(posedge axi_clk or negedge reset_n) begin 
  if (~reset_n) begin 
    state <= ST_IDLE;
    bresp_pending_cnt <= 0;
    last_wid   <= 0;
  end else begin 
    state <= next_state;
    bresp_pending_cnt <= ( inc_bresp & !dec_bresp) ? bresp_pending_cnt +1 :
                         (!inc_bresp &  dec_bresp) ? bresp_pending_cnt -1 : bresp_pending_cnt ;
    last_wid <= input_data_event ? AXI_IF.WID : last_wid; 

  end 
end 

assign AXI_IF.BRESP = 2'b00; //Response is always OK.
assign AXI_IF.BID   = last_wid; 
assign AXI_IF.BVALID= (state == ST_BRESP) && bresp_pending_cnt !=0;
assign AXI_IF.ARREADY = 0;
assign AXI_IF.RDATA   = 0;
assign AXI_IF.RRESP   = 0;
assign AXI_IF.RLAST   = 0;
assign AXI_IF.RVALID  = 0;
assign AXI_IF.AWREADY = (state ==ST_IDLE || state==ST_WDATA) & ~fifo_full & ~bresp_cnt_max;
assign AXI_IF.WREADY  = ~fifo_full & ~bresp_cnt_max;

assign fifo_addr_info = fifo_addr_in;
assign fifo_data_info = fifo_data_in;

endmodule 
