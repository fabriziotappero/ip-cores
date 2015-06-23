//////////////////////////////////////////////////////////////////////////////////
// Company:  (C) Athree, 2009
// Engineer: Dmitry Rozhdestvenskiy 
// Email dmitry.rozhdestvenskiy@srisc.com dmitryr@a3.spb.ru divx4log@narod.ru
// 
// Design Name:    OpenCores 10/10 Ethernet combined with Altera MII->SGMII bridge
// Module Name:    eth_sgmii 
// Project Name:   SPARC SoC single-core
//
// LICENSE:
// This is a Free Hardware Design; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// version 2 as published by the Free Software Foundation.
// The above named program is distributed in the hope that it will
// be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
//////////////////////////////////////////////////////////////////////////////////
module eth_sgmii (
    input  wb_clk_i,
    input  wb_rst_i,
    input  sysclk,
    
    input  [63:0] wb_dat_i,
    output [63:0] wb_dat_o,
    input  [63:0] wb_adr_i,
    input  [ 7:0] wb_sel_i,
    input         wb_we_i,
    input         wb_cyc_i,
    input         wb_stb_i,
    output        wb_ack_o,
    output        wb_err_o,
    
    output [63:0] m_wb_adr_o,
    output [ 7:0] m_wb_sel_o,
    output        m_wb_we_o,
    output [63:0] m_wb_dat_o,
    input  [63:0] m_wb_dat_i,
    output        m_wb_cyc_o,
    output        m_wb_stb_o,
    input         m_wb_ack_i,
    input         m_wb_err_i,
    
    input         sgmii_rx,
    output        sgmii_tx,
    
    output        int_eth,
    
    output        led_10,
    output        led_100,
    output        led_1000,
    output        led_an,
    output        led_disp_err,
    output        led_char_err,
    output        led_link,
    
    inout         md,
    output        mdc
);

wire [ 3:0] mrxd;
wire [ 3:0] mtxd;
wire [31:0] dat_o;
wire [ 3:0] sel_o;
wire [31:0] mdat_o;

assign wb_dat_o={dat_o[7:0],dat_o[15:8],dat_o[23:16],dat_o[31:24],dat_o[7:0],dat_o[15:8],dat_o[23:16],dat_o[31:24]};
assign m_wb_adr_o[63:32]=0;
assign m_wb_sel_o=m_wb_adr_o[2] ? {4'b0000,sel_o[0],sel_o[1],sel_o[2],sel_o[3]}:{sel_o[0],sel_o[1],sel_o[2],sel_o[3],4'b0000};
assign m_wb_dat_o={mdat_o[7:0],mdat_o[15:8],mdat_o[23:16],mdat_o[31:24],mdat_o[7:0],mdat_o[15:8],mdat_o[23:16],mdat_o[31:24]};

// OpenCores 10/100 Ethernet MAC
eth_top eth_mac (
    .wb_clk_i(wb_clk_i), 
    .wb_rst_i(wb_rst_i), 
    
    .wb_dat_i(wb_sel_i[7:4]==4'b0 ? {wb_dat_i[7:0],wb_dat_i[15:8],wb_dat_i[23:16],wb_dat_i[31:24]}:{wb_dat_i[39:32],wb_dat_i[47:40],wb_dat_i[55:48],wb_dat_i[63:56]}), 
    .wb_dat_o(dat_o), 
    .wb_adr_i(wb_adr_i[31:0]), 
    .wb_sel_i(wb_sel_i[7:4]==4'b0 ? {wb_sel_i[0],wb_sel_i[1],wb_sel_i[2],wb_sel_i[3]}:{wb_sel_i[4],wb_sel_i[5],wb_sel_i[6],wb_sel_i[7]}), 
    .wb_we_i(wb_we_i), 
    .wb_cyc_i(wb_cyc_i), 
    .wb_stb_i(wb_stb_i), 
    .wb_ack_o(wb_ack_o), 
    .wb_err_o(wb_err_o), 
    .m_wb_adr_o(m_wb_adr_o[31:0]), 
    .m_wb_sel_o(sel_o), 
    .m_wb_we_o(m_wb_we_o), 
    .m_wb_dat_o(mdat_o), 
    .m_wb_dat_i(m_wb_adr_o[2] ? {m_wb_dat_i[7:0],m_wb_dat_i[15:8],m_wb_dat_i[23:16],m_wb_dat_i[31:24]}:{m_wb_dat_i[39:32],m_wb_dat_i[47:40],m_wb_dat_i[55:48],m_wb_dat_i[63:56]}), 
    .m_wb_cyc_o(m_wb_cyc_o), 
    .m_wb_stb_o(m_wb_stb_o), 
    .m_wb_ack_i(m_wb_ack_i), 
    .m_wb_err_i(m_wb_err_i), 
    
    .mtx_clk_pad_i(mtx_clk), 
    .mtxd_pad_o(mtxd), 
    .mtxen_pad_o(mtxen), 
    .mtxerr_pad_o(mtxerr), 
    .mrx_clk_pad_i(mrx_clk), 
    .mrxd_pad_i(mrxd), 
    .mrxdv_pad_i(mrxdv), 
    .mrxerr_pad_i(mrxerr), 
    .mcoll_pad_i(mcoll), 
    .mcrs_pad_i(mcrs), 
    .mdc_pad_o(mdc), 
    .md_pad_i(md_i), 
    .md_pad_o(md_o), 
    .md_padoe_o(md_oe), 
    .int_o(int_eth)
);

assign md_i=md;
assign md=md_oe ? md_o:1'bZ;

/*reg  [63:0] mdio_shift;
reg  [ 5:0] mdio_cnt;
wire [15:0] mdio_wrdata;
wire [15:0] mdio_rdata;
wire [ 4:0] mdio_addr;
reg mdio_wr;

assign mdio_rd=(mdio_cnt==6'd46) && mdio_shift[45:14]==32'hFFFFFFFF; // Address just latched, frame valid
assign mdio_wrdata=mdio_shift[15:0];
assign md_i=mdio_rdata[~mdio_cnt+1];
assign mdio_addr=(mdio_cnt<6'd48) ? mdio_shift[4:0]:mdio_shift[22:18];

always @(posedge mdc or posedge wb_rst_i)
   if(wb_rst_i)
      begin
         mdio_cnt<=0;
         mdio_shift<=64'b0;
      end
   else
      begin
          mdio_shift[0]<=md_o;
          mdio_shift[63:1]<=mdio_shift[62:0];
          mdio_cnt<=mdio_cnt+1;
          if(mdio_cnt==6'd63 && mdio_shift[62:27]==36'hFFFFFFFF5)
             mdio_wr<=1;
          else
             mdio_wr<=0;
      end*/
      
// Altera Ethernet controller in MII->SGMII bridge mode
// You may generate it with Quartus use it for free in test mode
// (either time-limited or connected to PC)
MII2SGMII eth_pcs(
	.ref_clk(sysclk),
	.reset(wb_rst_i),

	.gmii_rx_d(),
	.gmii_rx_dv(),
	.gmii_rx_err(),
	.gmii_tx_d(0),
	.gmii_tx_en(0),
	.gmii_tx_err(0),

	.tx_clk(mtx_clk),
	.reset_tx_clk(wb_rst_i),
	.tx_clkena(),
	.mii_tx_d(mtxd),
	.mii_tx_en(mtxen),
	.mii_tx_err(mtxerr),

	.rx_clk(mrx_clk),
	.reset_rx_clk(wb_rst_i),
	.rx_clkena(),
	.mii_rx_d(mrxd),
	.mii_rx_dv(mrxdv),
	.mii_rx_err(mrxerr),
	.mii_col(mcoll),
	.mii_crs(mcrs),

	.set_10(led_10),
	.set_100(led_100),
	.set_1000(led_1000),

	.hd_ena(),

	.txp(sgmii_tx),
	.rxp(sgmii_rx),

	.led_col(),
	.led_crs(),
	.led_an(led_an),
	.led_disp_err(led_disp_err),
	.led_char_err(led_char_err),
	.led_link(led_link),

	.clk(0),
	.readdata(),
	.waitrequest(),
	.address(),
	.read(0),
	.writedata(),
	.write(0)
);

endmodule 
