module simple_gmii_regs (
clk,reset,addr,wr_data,rd_data,doe,rd_n,wr_n,iorq_n,status_set,status_msk,control,control_clr,rx_len0,rx_len1,rx_data,rx_data_stb,tx_data,tx_data_stb,cfg,int_n);
input clk;
input reset;
input [15:0] addr;
input [7:0] wr_data;
output [7:0] rd_data;
output doe;
input rd_n;
input wr_n;
input iorq_n;
input [1:0] status_set;
output [1:0] status_msk;
output control;
input control_clr;
input [7:0] rx_len0;
input [7:0] rx_len1;
input [7:0] rx_data;
output rx_data_stb;
output [7:0] tx_data;
output tx_data_stb;
output cfg;
output int_n;
reg [7:0] rd_data;
reg block_select;
reg doe;
reg status_rd_sel;
reg [1:0] status;
reg status_wr_sel;
reg status_int;
reg [1:0] status_msk;
reg status_msk_rd_sel;
reg status_msk_wr_sel;
reg control;
reg control_rd_sel;
reg control_wr_sel;
reg rx_len0_rd_sel;
reg rx_len1_rd_sel;
reg rx_data_rd_sel;
reg rx_data_stb;
reg [7:0] tx_data;
reg tx_data_rd_sel;
reg tx_data_wr_sel;
reg tx_data_stb;
reg cfg;
reg cfg_rd_sel;
reg cfg_wr_sel;
reg int_n;
reg [7:0] int_vec;
always @*
  begin
    block_select = (addr[7:3] == 1) & !iorq_n;
    status_rd_sel = block_select & (addr[2:0] == 0) & !rd_n;
    status_wr_sel = block_select & (addr[2:0] == 0) & !wr_n;
    status_msk_rd_sel = block_select & (addr[2:0] == 1) & !rd_n;
    status_msk_wr_sel = block_select & (addr[2:0] == 1) & !wr_n;
    control_rd_sel = block_select & (addr[2:0] == 2) & !rd_n;
    control_wr_sel = block_select & (addr[2:0] == 2) & !wr_n;
    rx_len0_rd_sel = block_select & (addr[2:0] == 3) & !rd_n;
    rx_len1_rd_sel = block_select & (addr[2:0] == 4) & !rd_n;
    rx_data_rd_sel = block_select & (addr[2:0] == 5) & !rd_n;
    tx_data_rd_sel = block_select & (addr[2:0] == 6) & !rd_n;
    tx_data_wr_sel = block_select & (addr[2:0] == 6) & !wr_n;
    cfg_rd_sel = block_select & (addr[2:0] == 7) & !rd_n;
    cfg_wr_sel = block_select & (addr[2:0] == 7) & !wr_n;
  end
always @*
  begin
    case (1'b1)
      status_int : int_vec = 207;
      default : int_vec = 8'bx;
    endcase
    case (1'b1)
      status_rd_sel : rd_data = status;
      status_msk_rd_sel : rd_data = status_msk;
      control_rd_sel : rd_data = control;
      rx_len0_rd_sel : rd_data = rx_len0;
      rx_len1_rd_sel : rd_data = rx_len1;
      rx_data_rd_sel : rd_data = rx_data;
      tx_data_rd_sel : rd_data = tx_data;
      cfg_rd_sel : rd_data = cfg;
      default : rd_data = int_vec;
    endcase
    doe = status_rd_sel | status_msk_rd_sel | control_rd_sel | rx_len0_rd_sel | rx_len1_rd_sel | rx_data_rd_sel | tx_data_rd_sel | cfg_rd_sel;
  end
always @*
  begin
    int_n = ~(status_int);
  end
// register: status
always @(posedge clk)
  begin
    if (reset) status <= 0;
    else status <= (status_set | status) & ~( {2{status_wr_sel}} & wr_data);
    if (reset) status_int <= 0;
    else status_int <= |(status & ~status_msk);
  end
// register: status_msk
always @(posedge clk)
  begin
    if (reset) status_msk <= 0;
    else if (status_msk_wr_sel) status_msk <= wr_data;
  end
// register: control
always @(posedge clk)
  begin
    if (reset) control <= 0;
    else control <= ( ({1{control_wr_sel}} & wr_data) | control) & ~(control_clr);
  end
// register: rx_data
always @(posedge clk)
  begin
    if (reset) rx_data_stb <= 0;
    else if (rx_data_rd_sel) rx_data_stb <= 1;
    else rx_data_stb <= 0;
  end
always @(posedge clk)
  begin
    if (reset) tx_data <= 0;
    else if (tx_data_wr_sel) tx_data <= wr_data;
    if (reset) tx_data_stb <= 0;
    else if (tx_data_wr_sel) tx_data_stb <= 1;
    else tx_data_stb <= 0;
  end
// register: cfg
always @(posedge clk)
  begin
    if (reset) cfg <= 0;
    else if (cfg_wr_sel) cfg <= wr_data;
  end
endmodule
