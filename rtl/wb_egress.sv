//Author     : Alex Zhang (cgzhangwei@gmail.com)
//Date       : 03-11-2015
//Description: Now support the classic WB protocol. 
//             Change the ACK_I meaing to improve the efficiency.
//TODO       : 4 beat wrapper or 8 beat wrapper is not supported yet.

module wb_egress(
wb_clk,
wb_resetn,
ENABLE,
WB_TX_IF,
fifo_adr_rdata,
fifo_adr_rd,
fifo_adr_empty,
fifo_dat_rdata,
fifo_dat_rd,
fifo_dat_empty
);

parameter  WB_ADR_W      = 32;
parameter  WB_DAT_W      = 32;
parameter  WB_TGA_W      = 8;
parameter  WB_TGD_W      = 8;
parameter  WB_TGC_W      = 4;
parameter  WB_SEL_W      = 4;
parameter  WB_CTI_W      = 3;
parameter  WB_BTE_W      = 2; 
parameter  AXI_ID_W      = 3;
parameter  AXI_ADDR_W    = 32;
parameter  AXI_LEN_W     = 4;
parameter  AXI_SIZE_W    = 3;
parameter  AXI_BURST_W   = 2;
parameter  AXI_LOCK_W    = 2;
parameter  AXI_CACHE_W   = 4;
parameter  AXI_PROT_W    = 3;
parameter  AXI_DATA_W    = 32;
parameter  AXI_STB_W     = 4;
parameter  FIFO_ADR_W    = AXI_ID_W + AXI_ADDR_W + AXI_LEN_W + AXI_SIZE_W + AXI_BURST_W + AXI_LOCK_W + AXI_CACHE_W + AXI_PROT_W +1 ;
parameter  FIFO_DAT_W    = AXI_ID_W + AXI_DATA_W + AXI_STB_W + 2;
parameter  ST_W          = 2 ;
parameter  ST_IDLE       = 2'b00,
           ST_READ_ADDR  = 2'b01,
           ST_WAIT_DATA  = 2'b10,
           ST_READ_DATA  = 2'b11;
parameter  WB_W          = 2;
parameter  WB_IDLE       = 2'b00,
           WB_FIRST_DATA = 2'b01,
           WB_NEXT_DATA  = 2'b10;


input  wire                          wb_clk;
input  wire                          wb_resetn;
input  wire                          ENABLE;
wishbone_if.master                   WB_TX_IF;
input  wire [FIFO_ADR_W-1:0]         fifo_adr_rdata;
output wire                          fifo_adr_rd;
input  wire                          fifo_adr_empty;
input  wire [FIFO_DAT_W-1:0]         fifo_dat_rdata;
output wire                          fifo_dat_rd;
input  wire                          fifo_dat_empty;


reg  [ST_W-1:0]        state;
reg  [ST_W-1:0]        next_state;
reg                    inc_dat_ptr;
reg  [4:0]             data_count;
wire                   allow_adr_rd;
wire                   fifo_adr_rd_q;
reg  [AXI_ID_W   -1:0] axi_id    ;
reg  [AXI_ADDR_W -1:0] axi_addr  ;
reg  [AXI_LEN_W  -1:0] axi_len   ;
reg  [AXI_SIZE_W -1:0] axi_size  ;
reg  [AXI_BURST_W-1:0] axi_burst ;
reg  [AXI_LOCK_W -1:0] axi_lock  ;
reg  [AXI_CACHE_W-1:0] axi_cache ;
reg  [AXI_PROT_W -1:0] axi_prot  ;
reg                    wr_req    ;
reg  [AXI_ID_W   -1:0] axi_wid   ;
reg  [AXI_DATA_W -1:0] axi_wdata ;
reg  [AXI_STB_W  -1:0] axi_wstrb ;
reg                    axi_wlast ;
reg                    axi_wvalid;
reg                    wb_we_o ;
reg  [WB_ADR_W-1:0]    wb_adr_o;
reg  [WB_TGA_W-1:0]    wb_tga_o;
reg  [WB_ADR_W-1:0]    wb_adr_tmp;
reg  [AXI_LEN_W-1:0]   wb_len_tmp;
reg  [WB_BTE_W-1:0]    wb_bte_o;
reg                    wb_cyc_o;
reg  [WB_TGC_W-1:0]    wb_tgc_o;
reg  [WB_CTI_W-1:0]    wb_cti_o;
reg                    wb_stb_o;
reg  [WB_DAT_W-1:0]    wb_dat_o;
reg  [WB_TGD_W-1:0]    wb_tgd_o;
reg  [WB_SEL_W-1:0]    wb_sel_o;

reg  [WB_W-1:0]  wb_cs;
reg  [WB_W-1:0]  wb_ns;



assign allow_adr_rd = wb_cs == WB_IDLE;
always_comb begin  
  next_state = state;
  inc_dat_ptr  = 0; //int- internal
  case (state)
    ST_IDLE : begin 
      if (!fifo_adr_empty&allow_adr_rd) begin 
        next_state = ST_READ_ADDR;
      end else begin 
        next_state = ST_IDLE;
      end 
    end 
    ST_READ_ADDR : begin 
      next_state = ST_WAIT_DATA;
    end 
    ST_WAIT_DATA : begin 
      if (WB_TX_IF.ACK & !fifo_dat_empty) begin
        next_state = ST_READ_DATA;
      end else begin 
        next_state = ST_WAIT_DATA;
      end 
    end 
    ST_READ_DATA : begin 
      if (data_count>0 & WB_TX_IF.ACK) begin 
        next_state = ST_READ_DATA;
        inc_dat_ptr = 1;
      end else if (data_count>0) begin 
        next_state = ST_WAIT_DATA;
        inc_dat_ptr = 0;
      end else begin
        next_state = ST_IDLE;
        inc_dat_ptr = 0;
      end 
    end 
  endcase
end 

assign fifo_adr_rd = state == ST_READ_ADDR;
assign fifo_dat_rd = inc_dat_ptr;

sync_single_ff #(.DATA_W(1)) adr_rd_ff (
  .DIN    ( fifo_adr_rd   ),
  .DOUT   ( fifo_adr_rd_q ),
  .CLK    ( wb_clk        ),
  .RESET_N( wb_resetn     )
);

always @(posedge wb_clk or negedge wb_resetn) 
  if (~wb_resetn) begin 
    state <= ST_IDLE;
    data_count <= 0 ;
  end else begin 
    state <= next_state;
    data_count <= state==ST_READ_ADDR ? axi_len   + 1 :
                  state==ST_READ_DATA ? data_count -1 : data_count ;
  end 

//AXI3 only accept the alignment input of 4Byte-aligned data.i.e. awaddr[1:0]==0


always @(posedge wb_clk or negedge wb_resetn)
  if (~wb_resetn) begin 
    axi_id     <= 0;
    axi_addr   <= 0;
    axi_len    <= 0;
    axi_size   <= 0;
    axi_burst  <= 0;
    axi_lock   <= 0;
    axi_cache  <= 0;
    axi_prot   <= 0;
    wr_req     <= 0;
    axi_wid    <= 0;
    axi_wdata  <= 0;
    axi_wstrb  <= 0;
    axi_wlast  <= 0;
    axi_wvalid <= 0;
  end else begin 
    if ( fifo_adr_rd ) 
      {axi_id, axi_addr, axi_len, axi_size, axi_burst, axi_lock, axi_cache, axi_prot, wr_req}<= fifo_adr_rdata;
    if ( fifo_dat_rd )
      {axi_wid, axi_wdata, axi_wstrb, axi_wlast, axi_wvalid}<= fifo_dat_rdata;
  end

always @(posedge wb_clk or negedge wb_resetn) begin 
  if (~wb_resetn) begin 
    wb_cs <= WB_IDLE;
  end else begin 
    wb_cs <= wb_ns;
  end 
end 
///Wishbone master output
always @(*) begin 
  wb_ns = wb_cs;
  case (wb_cs) 
    WB_IDLE : begin 
      if (fifo_dat_rd) begin 
        wb_ns = WB_FIRST_DATA;
      end  else begin 
        wb_ns = WB_IDLE;
      end 
    end 
    WB_FIRST_DATA : begin 
      if (axi_wlast & WB_TX_IF.ACK)
        wb_ns = WB_IDLE;
      else if (~axi_wlast & WB_TX_IF.ACK)
        wb_ns = WB_NEXT_DATA;
      else
        wb_ns = WB_FIRST_DATA;
    end 
    
    WB_NEXT_DATA : begin 
      if (axi_wlast & WB_TX_IF.ACK)
        wb_ns = WB_IDLE;
      else 
        wb_ns = WB_NEXT_DATA;
    end 
  endcase  
end 


always @(posedge wb_clk or negedge wb_resetn) begin 
  if (~wb_resetn) begin 
        wb_we_o  <= 0;
        wb_adr_o <= 0;
        wb_tga_o <= 0;   

        wb_adr_tmp <= 0;
        wb_bte_o <= 0;
        wb_cyc_o <= 0;
        wb_tgc_o <= 0;
        wb_cti_o <= 0;
        wb_stb_o <= 0;

        wb_dat_o <= 0;
        wb_tgd_o <= 0;
        wb_sel_o <= 0;
  end else begin 
    case (wb_cs)
      WB_IDLE : begin 
        wb_we_o  <= 0;
        wb_adr_o <= 0;
        wb_tga_o <= 0;   

        wb_bte_o <= 0;
        wb_cyc_o <= 0;
        wb_tgc_o <= 0;
        wb_cti_o <= 0;
        wb_stb_o <= 0;

        wb_dat_o <= 0;
        wb_tgd_o <= 0;
        wb_sel_o <= 0;
      end 
      WB_FIRST_DATA : begin 
        wb_we_o  <= wr_req;
        wb_adr_o <= axi_addr;
        wb_adr_tmp <= axi_addr;
        wb_len_tmp <= axi_len-1;
        wb_tga_o <= axi_id;
        
        wb_bte_o <= 2'b00; //burst
        wb_cyc_o <= 1;
        wb_tgc_o <= {axi_prot, axi_cache, axi_lock, axi_len};
        wb_cti_o <= axi_wlast ? 3'b111 : 3'b000;
        wb_stb_o <= 1;        

        wb_dat_o <= axi_wdata;
        wb_tgd_o <= axi_wid;
        wb_sel_o <= axi_wstrb;
      end 
      WB_NEXT_DATA : begin 
        wb_we_o  <= wr_req;
        wb_adr_o <= wb_adr_tmp + 4'b100;
        wb_adr_tmp <= wb_adr_tmp +4'b100;
        wb_len_tmp <= wb_len_tmp -1 ;
        wb_tga_o <= axi_id;
        
        wb_bte_o <= 2'b00; //burst
        wb_cyc_o <= 1;
        wb_tgc_o <= {axi_prot, axi_cache, axi_lock, wb_len_tmp };
        wb_cti_o <= axi_wlast ? 3'b111 : 3'b000;
        wb_stb_o <= 1;        

        wb_dat_o <= axi_wdata;
        wb_tgd_o <= axi_wid;
        wb_sel_o <= axi_wstrb;
      end 
    endcase
  end 
end 

assign WB_TX_IF.ADR   = wb_adr_o;
assign WB_TX_IF.WE    = wb_we_o;
assign WB_TX_IF.TGA   = wb_tga_o;
assign WB_TX_IF.BTE   = wb_bte_o;
assign WB_TX_IF.CYC   = wb_cyc_o;
assign WB_TX_IF.TGC   = wb_tgc_o;
assign WB_TX_IF.CTI   = wb_cti_o;
assign WB_TX_IF.STB   = wb_stb_o;
assign WB_TX_IF.DAT_O = wb_dat_o;
assign WB_TX_IF.TGD_O = wb_tgd_o;
assign WB_TX_IF.SEL   = wb_sel_o;

endmodule
