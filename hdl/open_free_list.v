module open_free_list #(parameter RAM_W = 128, RAM_E = 0, RAM_S = 64, CNK_S = 128, RAM_TYPE = "MRAM", FL_AEMPTY_LVL=2) (
  input  wire                                 reset_n,
  input  wire                                 clk,
  // Write side
  output wire [clog2((RAM_S*1024)/CNK_S)-1:0] fl_q,
  output wire                                 fl_aempty,
  output wire                                 fl_empty,
  input  wire                                 wren,
  input  wire [RAM_W+RAM_E-1:0]               din,
  input  wire                                 eop,
  // Read side
  input  wire [clog2((RAM_S*1024)/CNK_S)-1:0] chunk_num,
  input  wire                                 load_req,
  input  wire                                 rel_req,
  output reg                                  load_rel_ack,
  input  wire                                 rden,
  output wire [RAM_W+RAM_E-1:0]               dout
);

localparam FL_S = (RAM_S*1024)/CNK_S;
localparam FL_W = clog2(FL_S);
localparam FL_ADDR_W = FL_W;
localparam LL_W = FL_W+1;
localparam RAM_ADDR_W = clog2((RAM_S*1024)/(RAM_W/8));
localparam LINES_IN_CNK = CNK_S/(RAM_W/8);
localparam IN_CNK_ADDR_W = clog2(LINES_IN_CNK);


wire [RAM_W+RAM_E-1:0]  ram_q;
reg  [RAM_ADDR_W-1:0]   ram_rd_addr;
wire [RAM_ADDR_W-1:0]   ram_wr_addr;
reg  [RAM_ADDR_W-1:0]   ram_wr_addr_lat;
reg                     wr_eop_while_ll;
reg  [FL_W-1:0]         fl_data;
wire [FL_ADDR_W-1:0]    fl_lvl;
reg                     fl_rden;
reg                     fl_wren;
wire [FL_W:0]           ll_data;
wire [FL_W:0]           ll_q;
reg  [FL_ADDR_W-1:0]    ll_rd_addr;
wire [FL_ADDR_W-1:0]    ll_wr_addr;
wire                    ll_wren;
wire                    ll_eop;

reg  [FL_ADDR_W-1:0]    fl_init_cnt;
reg                     fl_init;
reg                     fl_init_r1;
reg                     fl_init_r2;
reg                     fl_init_r3;
reg                     fl_init_wr;

reg                     int_sop;
reg                     rel_req_from_idle;

wire                    load_req_p;
wire [FL_ADDR_W-1:0]    nxt_chunk_ptr;

reg  [2:0]              ns_rd_sm;
reg  [2:0]              cs_rd_sm;
parameter               IDLE           = 3'd0,
                        PREFETCH       = 3'd1,
                        RD             = 3'd2,
                        WAIT_REL       = 3'd3,
                        REL_DELAY1     = 3'd4,
                        REL_DELAY2     = 3'd5,
                        REL_WR2FL      = 3'd6;

reg                     sm_rel_ctrl;
reg                     sm_rel_wren;
reg						sm_rel_ctrl_mask;
reg						sm_rel_ctrl_mask_clr;
reg						sm_rel_ctrl_mask_set;

reg                     int_rden;
reg                     load_req_r1;
reg  [RAM_ADDR_W-1:0]   usr_ram_rd_addr_r1;

altsyncram3 ram (
  .data       (din),
  .rd_aclr    (~reset_n),
  .rdaddress  (ram_rd_addr),
  .rdclock    (clk),
  .rdclocken  (int_rden | rden),
  .wraddress  (ram_wr_addr),
  .wrclock    (clk),
  .wrclocken  (1'b1),
  .wren       (wren),
  .q          (dout)
);
defparam
  ram.A_WIDTH   = RAM_W+RAM_E,
  ram.A_WIDTHAD = RAM_ADDR_W,
  ram.RAM_TYPE  = RAM_TYPE,
  ram.USE_RDEN  = 0;

alt_scfifo free_list(
  .aclr          (~reset_n),
  .clock         (clk),
  .data          (fl_init_wr ? fl_init_cnt : fl_data),
  .rdreq         (fl_rden),
  .sclr          (1'b0),
  .wrreq         (fl_init_wr | fl_wren),
  .almost_empty  (fl_aempty),
  .almost_full   (),
  .empty         (fl_empty),
  .full          (),
  .q             (fl_q),
  .usedw         (fl_lvl)
);
defparam
   free_list.FIFO_WIDTH    = FL_W,
   free_list.FIFO_DEPTH    = FL_ADDR_W,
   free_list.FIFO_TYPE     = "M4K",
   free_list.FIFO_SHOW     = "ON",
   free_list.FIFO_AEMPTY   = FL_AEMPTY_LVL;


altsyncram3 link_list(
  .data       (ll_data),
  .rd_aclr    (~reset_n),
  .rdaddress  (sm_rel_ctrl ? nxt_chunk_ptr : ll_rd_addr),
  .rdclock    (clk),
  .rdclocken  (1'b1),
  .wraddress  (ll_wr_addr),
  .wrclock    (clk),
  .wrclocken  (1'b1),
  .wren       (ll_wren),
  .q          (ll_q)
);
defparam
  link_list.A_WIDTH   = LL_W,
  link_list.A_WIDTHAD = FL_ADDR_W,
  link_list.RAM_TYPE  = "M4K",
  link_list.USE_RDEN  = 0;


// Free list init

always @ (posedge clk, negedge reset_n)
begin
  if (reset_n==1'b0)
  begin
    fl_init_cnt <= {FL_ADDR_W{1'b0}};
    fl_init     <= 1'b0;
    fl_init_r1  <= 1'b0;
    fl_init_r2  <= 1'b0;
    fl_init_r3  <= 1'b0;
    fl_init_wr  <= 1'b0;
  end
  else
  begin
    fl_init_cnt <= fl_init_wr ? fl_init_cnt + 1'b1 : {FL_ADDR_W{1'b0}};
    fl_init     <= 1'b1;
    fl_init_r1  <= fl_init;
    fl_init_r2  <= fl_init_r1;
    fl_init_r3  <= fl_init_r2;
    fl_init_wr  <= !fl_init_r3 && fl_init_r2 ? 1'b1 : fl_init_cnt=={FL_ADDR_W{1'b1}} ?  1'b0 : fl_init_wr;
  end
end


// Write side

assign ram_wr_addr = int_sop || (wren && ram_wr_addr_lat[IN_CNK_ADDR_W-1:0]==(LINES_IN_CNK-1)) ? {fl_q, {IN_CNK_ADDR_W{1'b0}}}
                                                                                               : wren ? ram_wr_addr_lat + 1'b1
                                                                                                      : ram_wr_addr_lat;
assign ll_eop      = wren && ram_wr_addr[IN_CNK_ADDR_W-1:0]==0 && eop ? 1'b0 : eop | wr_eop_while_ll;
assign ll_wr_addr  = ram_wr_addr_lat[RAM_ADDR_W-1:IN_CNK_ADDR_W];
assign ll_data     = {fl_q, ll_eop};
assign ll_wren     = (wren && ((ram_wr_addr[IN_CNK_ADDR_W-1:0]==0) || eop)) || wr_eop_while_ll ? 1'b1 : 1'b0;


always @ (posedge clk, negedge reset_n)
begin
  if (reset_n==1'b0)
  begin
    fl_rden         <= 1'b0;
    int_sop         <= 1'b1;
    ram_wr_addr_lat <= {RAM_ADDR_W{1'b0}};
    wr_eop_while_ll <= 1'b0;
  end
  else
  begin
    fl_rden         <= wren && (ram_wr_addr[IN_CNK_ADDR_W-1:0]==0) ? 1'b1 : 1'b0;
    int_sop         <= wren && eop ? 1'b1 :
                       wren        ? 1'b0 :
                                     int_sop;
    ram_wr_addr_lat <= ram_wr_addr;
    wr_eop_while_ll <= wren && ram_wr_addr[IN_CNK_ADDR_W-1:0]==0 && eop ? 1'b1 : 1'b0;
  end
end

// Read side
assign load_req_p    = ~load_req_r1 & load_req;
assign nxt_chunk_ptr = ll_q[FL_W:1]; //can be sampled

always @*
begin
  case(cs_rd_sm)
    IDLE:
      ns_rd_sm = fl_init_wr ? IDLE       :
                 rel_req    ? REL_DELAY1 :
                 load_req   ? PREFETCH   :
                              IDLE;
    PREFETCH:
      ns_rd_sm = RD;
    RD:
      ns_rd_sm = load_req                                                                     ? PREFETCH  :
                 rden && (usr_ram_rd_addr_r1[IN_CNK_ADDR_W-1:0]==(LINES_IN_CNK-1)) && ll_q[0] ? WAIT_REL  : // true if the current chunk is the last chunk and was reached to its end and is released now                                                                                           : REL_WR2FL // true if the current chunk was reached to its end and is released now and is the last one
                 rel_req                                                                      ? REL_WR2FL :
                 																				RD;
    WAIT_REL:
      ns_rd_sm = rel_req ? IDLE : WAIT_REL;
    REL_DELAY1:
      ns_rd_sm = REL_DELAY2;
    REL_DELAY2:
      ns_rd_sm = REL_WR2FL;
    REL_WR2FL:
      ns_rd_sm = ll_q[0] ? IDLE : REL_DELAY2;
  endcase
end

always @*
begin
  rel_req_from_idle    = 1'b0;
  int_rden             = 1'b0;
  load_rel_ack         = 1'b0;
  sm_rel_ctrl_mask_set = 1'b0;
  sm_rel_ctrl_mask_clr = 1'b0;
  sm_rel_ctrl          = 1'b1;
  sm_rel_wren          = 1'b0;
  case(cs_rd_sm)
    IDLE:
    begin
      rel_req_from_idle    = rel_req;
      sm_rel_ctrl_mask_set = rel_req;
      sm_rel_ctrl          = 1'b0;
    end
    PREFETCH:
    begin
      int_rden      = 1'b1;
      load_rel_ack  = 1'b1;
      sm_rel_ctrl   = 1'b0;
    end
    RD:
    begin
      sm_rel_ctrl   = 1'b0;
    end
    WAIT_REL:
    begin
      load_rel_ack = rel_req;
    end
    REL_DELAY1:
    begin
      sm_rel_ctrl = ~sm_rel_ctrl_mask;
    end
    REL_DELAY2:
    begin
      sm_rel_ctrl = ~sm_rel_ctrl_mask;
    end
    REL_WR2FL:
    begin
      sm_rel_wren  = 1'b1;
      load_rel_ack = ll_q[0];
      sm_rel_ctrl_mask_clr = 1'b1;
    end
  endcase
end

always @ (posedge clk, negedge reset_n)
begin
  if (reset_n==1'b0)
  begin
    cs_rd_sm           <= 3'd0;
    load_req_r1        <= 1'b0;
    sm_rel_ctrl_mask   <= 1'b0;
    ll_rd_addr         <= {FL_ADDR_W{1'b0}};
    ram_rd_addr        <= {RAM_ADDR_W{1'b0}};
    usr_ram_rd_addr_r1 <= {RAM_ADDR_W{1'b0}};
    fl_wren            <= 1'b0;
    fl_data            <= {FL_W{1'b0}};
  end
  else
  begin
    cs_rd_sm           <= ns_rd_sm;
    load_req_r1        <= load_req;
    sm_rel_ctrl_mask   <= sm_rel_ctrl_mask_set ? 1'b1 :
                          sm_rel_ctrl_mask_clr ? 1'b0 :
                                                 sm_rel_ctrl_mask;

    ll_rd_addr         <= load_req_p  || rel_req_from_idle                                                                     ? chunk_num     :
                          sm_rel_wren || ((!sm_rel_ctrl && rden && (usr_ram_rd_addr_r1[IN_CNK_ADDR_W-1:0]==(LINES_IN_CNK-1)))) ? nxt_chunk_ptr :
                                                                                                                                 ll_rd_addr;
    ram_rd_addr        <= load_req_p                                                 ? {chunk_num,  {IN_CNK_ADDR_W{1'b0}}}     :
                          rden && (ram_rd_addr[IN_CNK_ADDR_W-1:0]==(LINES_IN_CNK-1)) ? {nxt_chunk_ptr,  {IN_CNK_ADDR_W{1'b0}}} :
                          rden || int_rden                                           ? ram_rd_addr + 1'b1                      :
                                                                                       ram_rd_addr;
    usr_ram_rd_addr_r1 <= !sm_rel_ctrl && (rden || int_rden) ? ram_rd_addr : usr_ram_rd_addr_r1;
    fl_wren            <= (!sm_rel_ctrl && rden && (usr_ram_rd_addr_r1[IN_CNK_ADDR_W-1:0]==(LINES_IN_CNK-1))) || sm_rel_wren ? 1'b1 : 1'b0;
    fl_data            <= rel_req_from_idle ? chunk_num  :
                          sm_rel_wren       ? ll_rd_addr :
                                              usr_ram_rd_addr_r1[RAM_ADDR_W-1:IN_CNK_ADDR_W];

  end
end

/********************************************************
  clog2 - function that returns log2 of a value rounded up
        - min return value is 1 (in case of clog2(1)=1)
 ********************************************************/
function integer clog2(input integer value);
begin
  value = value-1;
  for (clog2=0; value>0; clog2=clog2+1)
    value = value>>1;
  if (clog2 == 0)
    clog2 = 1;
end
endfunction

endmodule
