module lcfg_cfgo_regs (
clk,reset_n,rf_irdy,rf_trdy,rf_write,rf_addr,rf_wr_data,rf_rd_data,cfg_addr0,cfg_addr1,cfg_data0_wr_stb,cfg_data0_rd_stb,cfg_data0_wr_data,cfg_data0_rd_data,cfg_data0_rd_ack,cfg_data0_wr_ack,cfg_data1_wr_stb,cfg_data1_rd_stb,cfg_data1_wr_data,cfg_data1_rd_data,cfg_data1_rd_ack,cfg_data1_wr_ack,cfg_data2_wr_stb,cfg_data2_rd_stb,cfg_data2_wr_data,cfg_data2_rd_data,cfg_data2_rd_ack,cfg_data2_wr_ack,cfg_data3_wr_stb,cfg_data3_rd_stb,cfg_data3_wr_data,cfg_data3_rd_data,cfg_data3_rd_ack,cfg_data3_wr_ack,cfg_status);
input clk;
input reset_n;
input rf_irdy;
output rf_trdy;
input rf_write;
input [3:0] rf_addr;
input [7:0] rf_wr_data;
output [7:0] rf_rd_data;
output [7:0] cfg_addr0;
output [7:0] cfg_addr1;
output cfg_data0_wr_stb;
output cfg_data0_rd_stb;
output [7:0] cfg_data0_wr_data;
input [7:0] cfg_data0_rd_data;
input cfg_data0_rd_ack;
input cfg_data0_wr_ack;
output cfg_data1_wr_stb;
output cfg_data1_rd_stb;
output [7:0] cfg_data1_wr_data;
input [7:0] cfg_data1_rd_data;
input cfg_data1_rd_ack;
input cfg_data1_wr_ack;
output cfg_data2_wr_stb;
output cfg_data2_rd_stb;
output [7:0] cfg_data2_wr_data;
input [7:0] cfg_data2_rd_data;
input cfg_data2_rd_ack;
input cfg_data2_wr_ack;
output cfg_data3_wr_stb;
output cfg_data3_rd_stb;
output [7:0] cfg_data3_wr_data;
input [7:0] cfg_data3_rd_data;
input cfg_data3_rd_ack;
input cfg_data3_wr_ack;
input [7:0] cfg_status;
reg [7:0] rf_rd_data;
reg nxt_rf_trdy;
reg rf_trdy;
reg [7:0] cfg_addr0;
reg [7:0] nxt_cfg_addr0;
reg cfg_addr0_rd_sel;
reg cfg_addr0_wr_sel;
reg [7:0] cfg_addr1;
reg [7:0] nxt_cfg_addr1;
reg cfg_addr1_rd_sel;
reg cfg_addr1_wr_sel;
reg cfg_data0_rd_sel;
reg cfg_data0_wr_sel;
reg cfg_data0_rd_stb;
reg cfg_data0_wr_stb;
reg cfg_data0_wait_n;
reg [7:0] cfg_data0;
reg [7:0] cfg_data0_wr_data;
reg [1:0] sm_cfg_data0_state;
reg [1:0] nxt_sm_cfg_data0_state;
reg cfg_data1_rd_sel;
reg cfg_data1_wr_sel;
reg cfg_data1_rd_stb;
reg cfg_data1_wr_stb;
reg cfg_data1_wait_n;
reg [7:0] cfg_data1;
reg [7:0] cfg_data1_wr_data;
reg [1:0] sm_cfg_data1_state;
reg [1:0] nxt_sm_cfg_data1_state;
reg cfg_data2_rd_sel;
reg cfg_data2_wr_sel;
reg cfg_data2_rd_stb;
reg cfg_data2_wr_stb;
reg cfg_data2_wait_n;
reg [7:0] cfg_data2;
reg [7:0] cfg_data2_wr_data;
reg [1:0] sm_cfg_data2_state;
reg [1:0] nxt_sm_cfg_data2_state;
reg cfg_data3_rd_sel;
reg cfg_data3_wr_sel;
reg cfg_data3_rd_stb;
reg cfg_data3_wr_stb;
reg cfg_data3_wait_n;
reg [7:0] cfg_data3;
reg [7:0] cfg_data3_wr_data;
reg [1:0] sm_cfg_data3_state;
reg [1:0] nxt_sm_cfg_data3_state;
reg cfg_status_rd_sel;
always @*
  begin
    cfg_addr0_rd_sel = (rf_addr[3:0] == 0) & rf_irdy & !rf_write;
    cfg_addr0_wr_sel = (rf_addr[3:0] == 0) & rf_irdy & rf_write;

    cfg_addr1_rd_sel = (rf_addr[3:0] == 1) & rf_irdy & !rf_write;
    cfg_addr1_wr_sel = (rf_addr[3:0] == 1) & rf_irdy & rf_write;

    cfg_data0_rd_sel = (rf_addr[3:0] == 2) & rf_irdy & !rf_write;
    cfg_data0_wr_sel = (rf_addr[3:0] == 2) & rf_irdy & rf_write;

    cfg_data1_rd_sel = (rf_addr[3:0] == 3) & rf_irdy & !rf_write;
    cfg_data1_wr_sel = (rf_addr[3:0] == 3) & rf_irdy & rf_write;

    cfg_data2_rd_sel = (rf_addr[3:0] == 4) & rf_irdy & !rf_write;
    cfg_data2_wr_sel = (rf_addr[3:0] == 4) & rf_irdy & rf_write;

    cfg_data3_rd_sel = (rf_addr[3:0] == 5) & rf_irdy & !rf_write;
    cfg_data3_wr_sel = (rf_addr[3:0] == 5) & rf_irdy & rf_write;

    cfg_status_rd_sel = (rf_addr[3:0] == 6) & rf_irdy & !rf_write;
  end
always @*
  begin
    case (1'b1)
      cfg_addr0_rd_sel : rf_rd_data = cfg_addr0;
      cfg_addr1_rd_sel : rf_rd_data = cfg_addr1;
      cfg_data0_rd_sel : rf_rd_data = cfg_data0;
      cfg_data1_rd_sel : rf_rd_data = cfg_data1;
      cfg_data2_rd_sel : rf_rd_data = cfg_data2;
      cfg_data3_rd_sel : rf_rd_data = cfg_data3;
      cfg_status_rd_sel : rf_rd_data = cfg_status;
      default : rf_rd_data = 8'b0;
    endcase
  end
always @*
  begin
    if (rf_trdy) nxt_rf_trdy = 0;
    else if (rf_irdy) nxt_rf_trdy = cfg_data0_wait_n & cfg_data1_wait_n & cfg_data2_wait_n & cfg_data3_wait_n;
    else nxt_rf_trdy = 0;
  end
always @(posedge clk or negedge reset_n)
  begin
    if (~reset_n) rf_trdy <= #1 0;
    else rf_trdy <= #1 nxt_rf_trdy;
  end
// config: cfg_addr0
always @*
  begin
    if (cfg_addr0_wr_sel) nxt_cfg_addr0 = rf_wr_data;
    else nxt_cfg_addr0 = cfg_addr0;
  end
always @(posedge clk or negedge reset_n)
  begin
    if (~reset_n) cfg_addr0 <= #1 8'h0;
    else cfg_addr0 <= #1 nxt_cfg_addr0;
  end
// config: cfg_addr1
always @*
  begin
    if (cfg_addr1_wr_sel) nxt_cfg_addr1 = rf_wr_data;
    else nxt_cfg_addr1 = cfg_addr1;
  end
always @(posedge clk or negedge reset_n)
  begin
    if (~reset_n) cfg_addr1 <= #1 8'h0;
    else cfg_addr1 <= #1 nxt_cfg_addr1;
  end
// state machine sm_cfg_data0
parameter st_sm_cfg_data0_w_clear = 0;
parameter st_sm_cfg_data0_idle = 1;
parameter st_sm_cfg_data0_wr_req = 2;
parameter st_sm_cfg_data0_rd_req = 3;
always @*
  begin
    cfg_data0_rd_stb = 0;
    cfg_data0_wr_stb = 0;
    cfg_data0_wait_n = 1;
    nxt_sm_cfg_data0_state = sm_cfg_data0_state;
    case (sm_cfg_data0_state)
    st_sm_cfg_data0_w_clear : 
      begin
        if (~(cfg_data0_rd_sel | cfg_data0_wr_sel))
        begin
        nxt_sm_cfg_data0_state = st_sm_cfg_data0_idle;
        end
      end
    st_sm_cfg_data0_idle : 
      begin
        if (cfg_data0_rd_sel)
        begin
        nxt_sm_cfg_data0_state = st_sm_cfg_data0_rd_req;
        cfg_data0_wait_n = 0;
        end
        else if (cfg_data0_wr_sel)
        begin
        nxt_sm_cfg_data0_state = st_sm_cfg_data0_wr_req;
        cfg_data0_wait_n = 0;
        end
      end
    st_sm_cfg_data0_wr_req : 
      begin
        if (cfg_data0_wr_ack)
        begin
        nxt_sm_cfg_data0_state = st_sm_cfg_data0_w_clear;
        end
        else if (!cfg_data0_wr_ack)
        begin
        cfg_data0_wait_n = 0;
        end
        cfg_data0_wr_stb = 1;
      end
    st_sm_cfg_data0_rd_req : 
      begin
        if (cfg_data0_rd_ack)
        begin
        nxt_sm_cfg_data0_state = st_sm_cfg_data0_w_clear;
        end
        else if (!cfg_data0_rd_ack)
        begin
        cfg_data0_wait_n = 0;
        end
        cfg_data0_rd_stb = 1;
      end
    endcase
  end
always @(posedge clk or negedge reset_n)
  begin
    if(~reset_n)
    sm_cfg_data0_state <= #1 st_sm_cfg_data0_idle;
    else
    sm_cfg_data0_state <= #1 nxt_sm_cfg_data0_state;
  end
always @*
  begin
    cfg_data0_wr_data = rf_wr_data;
    cfg_data0 = cfg_data0_rd_data;
  end
// state machine sm_cfg_data1
parameter st_sm_cfg_data1_w_clear = 0;
parameter st_sm_cfg_data1_idle = 1;
parameter st_sm_cfg_data1_wr_req = 2;
parameter st_sm_cfg_data1_rd_req = 3;
always @*
  begin
    cfg_data1_rd_stb = 0;
    cfg_data1_wr_stb = 0;
    cfg_data1_wait_n = 1;
    nxt_sm_cfg_data1_state = sm_cfg_data1_state;
    case (sm_cfg_data1_state)
    st_sm_cfg_data1_w_clear : 
      begin
        if (~(cfg_data1_rd_sel | cfg_data1_wr_sel))
        begin
        nxt_sm_cfg_data1_state = st_sm_cfg_data1_idle;
        end
      end
    st_sm_cfg_data1_idle : 
      begin
        if (cfg_data1_rd_sel)
        begin
        nxt_sm_cfg_data1_state = st_sm_cfg_data1_rd_req;
        cfg_data1_wait_n = 0;
        end
        else if (cfg_data1_wr_sel)
        begin
        nxt_sm_cfg_data1_state = st_sm_cfg_data1_wr_req;
        cfg_data1_wait_n = 0;
        end
      end
    st_sm_cfg_data1_wr_req : 
      begin
        if (cfg_data1_wr_ack)
        begin
        nxt_sm_cfg_data1_state = st_sm_cfg_data1_w_clear;
        end
        else if (!cfg_data1_wr_ack)
        begin
        cfg_data1_wait_n = 0;
        end
        cfg_data1_wr_stb = 1;
      end
    st_sm_cfg_data1_rd_req : 
      begin
        if (cfg_data1_rd_ack)
        begin
        nxt_sm_cfg_data1_state = st_sm_cfg_data1_w_clear;
        end
        else if (!cfg_data1_rd_ack)
        begin
        cfg_data1_wait_n = 0;
        end
        cfg_data1_rd_stb = 1;
      end
    endcase
  end
always @(posedge clk or negedge reset_n)
  begin
    if(~reset_n)
    sm_cfg_data1_state <= #1 st_sm_cfg_data1_idle;
    else
    sm_cfg_data1_state <= #1 nxt_sm_cfg_data1_state;
  end
always @*
  begin
    cfg_data1_wr_data = rf_wr_data;
    cfg_data1 = cfg_data1_rd_data;
  end
// state machine sm_cfg_data2
parameter st_sm_cfg_data2_w_clear = 0;
parameter st_sm_cfg_data2_idle = 1;
parameter st_sm_cfg_data2_wr_req = 2;
parameter st_sm_cfg_data2_rd_req = 3;
always @*
  begin
    cfg_data2_rd_stb = 0;
    cfg_data2_wr_stb = 0;
    cfg_data2_wait_n = 1;
    nxt_sm_cfg_data2_state = sm_cfg_data2_state;
    case (sm_cfg_data2_state)
    st_sm_cfg_data2_w_clear : 
      begin
        if (~(cfg_data2_rd_sel | cfg_data2_wr_sel))
        begin
        nxt_sm_cfg_data2_state = st_sm_cfg_data2_idle;
        end
      end
    st_sm_cfg_data2_idle : 
      begin
        if (cfg_data2_rd_sel)
        begin
        nxt_sm_cfg_data2_state = st_sm_cfg_data2_rd_req;
        cfg_data2_wait_n = 0;
        end
        else if (cfg_data2_wr_sel)
        begin
        nxt_sm_cfg_data2_state = st_sm_cfg_data2_wr_req;
        cfg_data2_wait_n = 0;
        end
      end
    st_sm_cfg_data2_wr_req : 
      begin
        if (cfg_data2_wr_ack)
        begin
        nxt_sm_cfg_data2_state = st_sm_cfg_data2_w_clear;
        end
        else if (!cfg_data2_wr_ack)
        begin
        cfg_data2_wait_n = 0;
        end
        cfg_data2_wr_stb = 1;
      end
    st_sm_cfg_data2_rd_req : 
      begin
        if (cfg_data2_rd_ack)
        begin
        nxt_sm_cfg_data2_state = st_sm_cfg_data2_w_clear;
        end
        else if (!cfg_data2_rd_ack)
        begin
        cfg_data2_wait_n = 0;
        end
        cfg_data2_rd_stb = 1;
      end
    endcase
  end
always @(posedge clk or negedge reset_n)
  begin
    if(~reset_n)
    sm_cfg_data2_state <= #1 st_sm_cfg_data2_idle;
    else
    sm_cfg_data2_state <= #1 nxt_sm_cfg_data2_state;
  end
always @*
  begin
    cfg_data2_wr_data = rf_wr_data;
    cfg_data2 = cfg_data2_rd_data;
  end
// state machine sm_cfg_data3
parameter st_sm_cfg_data3_w_clear = 0;
parameter st_sm_cfg_data3_idle = 1;
parameter st_sm_cfg_data3_wr_req = 2;
parameter st_sm_cfg_data3_rd_req = 3;
always @*
  begin
    cfg_data3_rd_stb = 0;
    cfg_data3_wr_stb = 0;
    cfg_data3_wait_n = 1;
    nxt_sm_cfg_data3_state = sm_cfg_data3_state;
    case (sm_cfg_data3_state)
    st_sm_cfg_data3_w_clear : 
      begin
        if (~(cfg_data3_rd_sel | cfg_data3_wr_sel))
        begin
        nxt_sm_cfg_data3_state = st_sm_cfg_data3_idle;
        end
      end
    st_sm_cfg_data3_idle : 
      begin
        if (cfg_data3_rd_sel)
        begin
        nxt_sm_cfg_data3_state = st_sm_cfg_data3_rd_req;
        cfg_data3_wait_n = 0;
        end
        else if (cfg_data3_wr_sel)
        begin
        nxt_sm_cfg_data3_state = st_sm_cfg_data3_wr_req;
        cfg_data3_wait_n = 0;
        end
      end
    st_sm_cfg_data3_wr_req : 
      begin
        if (cfg_data3_wr_ack)
        begin
        nxt_sm_cfg_data3_state = st_sm_cfg_data3_w_clear;
        end
        else if (!cfg_data3_wr_ack)
        begin
        cfg_data3_wait_n = 0;
        end
        cfg_data3_wr_stb = 1;
      end
    st_sm_cfg_data3_rd_req : 
      begin
        if (cfg_data3_rd_ack)
        begin
        nxt_sm_cfg_data3_state = st_sm_cfg_data3_w_clear;
        end
        else if (!cfg_data3_rd_ack)
        begin
        cfg_data3_wait_n = 0;
        end
        cfg_data3_rd_stb = 1;
      end
    endcase
  end
always @(posedge clk or negedge reset_n)
  begin
    if(~reset_n)
    sm_cfg_data3_state <= #1 st_sm_cfg_data3_idle;
    else
    sm_cfg_data3_state <= #1 nxt_sm_cfg_data3_state;
  end
always @*
  begin
    cfg_data3_wr_data = rf_wr_data;
    cfg_data3 = cfg_data3_rd_data;
  end
// status: cfg_status
endmodule
