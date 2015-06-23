/*
 *  Copyright (c) 2008  Zeus Gomez Marmolejo <zeus@opencores.org>
 *
 *  This file is part of the Zet processor. This processor is free
 *  hardware; you can redistribute it and/or modify it under the terms of
 *  the GNU General Public License as published by the Free Software
 *  Foundation; either version 3, or (at your option) any later version.
 *
 *  Zet is distrubuted in the hope that it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
 *  License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Zet; see the file COPYING. If not, see
 *  <http://www.gnu.org/licenses/>.
 */

`timescale 1ns/10ps
`include "defines.v"

module kotku_ml403 (
`ifdef DEBUG
  (* LOC="B6"  *) input butc_,
  (* LOC="F10" *) input bute_,
  (* LOC="E9"  *) input butw_,
  (* LOC="E7"  *) input butn_,
  (* LOC="A6"  *) input buts_,
`endif
    output        rs_,
    output        rw_,
    output        e_,
    output [ 7:4] db_,

    output        trx_,

    output        tft_lcd_clk_,
    output [ 1:0] tft_lcd_r_,
    output [ 1:0] tft_lcd_g_,
    output [ 1:0] tft_lcd_b_,
    output        tft_lcd_hsync_,
    output        tft_lcd_vsync_,

    input         sys_clk_in_,

    output        sram_clk_,
    output [20:0] sram_flash_addr_,
    inout  [31:0] sram_flash_data_,
    output        sram_flash_oe_n_,
    output        sram_flash_we_n_,
    output [ 3:0] sram_bw_,
    output        sram_cen_,
    output        sram_adv_ld_n_,
    output        flash_ce2_,

    inout         ps2_clk_,
    inout         ps2_data_,

    output [ 6:1] aceusb_a_,
    inout  [15:0] aceusb_d_,
    output        aceusb_oe_n_,
    output        aceusb_we_n_,

    input         ace_clkin_,
    output        ace_mpce_n_,

    output        usb_cs_n_,
    output        usb_hpi_reset_n_
  );

  // Net declarations
  wire        clk;
  wire        sys_clk;
  wire        rst2;
  wire        rst_lck;
  wire [15:0] dat_i;
  wire [15:0] dat_o;
  wire [19:1] adr;
  wire        we;
  wire        tga;
  wire        stb;
  wire        ack;
  wire [15:0] io_dat_i;
  wire [ 1:0] sel;
  wire        cyc;
  wire [ 7:0] keyb_dat_o;
  wire        keyb_io_arena;
  wire        keyb_io_status;
  wire        keyb_arena;

  wire [15:0] vdu_dat_o;
  wire        vdu_ack_o;
  wire        vdu_mem_arena;
  wire        vdu_io_arena;
  wire        vdu_arena;
  wire [15:0] flash_dat_o;
  wire        flash_stb;
  wire        flash_ack;
  wire        flash_mem_arena;
  wire        flash_io_arena;
  wire        flash_arena;
  wire [15:0] zbt_dat_o;
  wire        zbt_stb;
  wire        zbt_ack;
  wire [20:0] flash_addr_;
  wire [20:0] sram_addr_;
  wire        flash_we_n_;
  wire        sram_we_n_;
  wire        intr;
  wire        inta;
  wire        clk_100M;
  wire        rst;
  wire [15:0] vdu_dat_i;
  wire [11:1] vdu_adr_i;
  wire        vdu_we_i;
  wire [ 1:0] vdu_sel_i;
  wire        vdu_stb_i;
  wire        vdu_tga_i;

  wire [19:1] zbt_adr_i;
  wire        zbt_we_i;
  wire [ 1:0] zbt_sel_i;
  wire        zbt_stb_i;

  wire [15:0] ace_dat_o;
  wire        ace_ack;
  wire        ace_stb;
  wire        ace_io_arena;
  wire        ace_arena;

  wire [ 1:0] int;
  wire        iid;

`ifdef DEBUG
  reg  [31:0] cnt_time;
  wire [35:0] control0;
  wire [ 5:0] funct;
  wire [ 2:0] state, next_state;
  wire [15:0] x, y;
  wire [15:0] imm;
  wire [63:0] f1, f2;
  wire [15:0] m1, m2;
  wire [19:0] pc;
  wire [15:0] cs, ip;
  wire [15:0] aluo;
  wire [ 2:0] cnt;
  wire        op;
  wire        block;
  wire        cpu_block;
  wire        clk_921600;
  wire [15:0] ax, dx, bp, si, es;
  wire [15:0] c;
  wire [ 3:0] addr_c;
  wire [15:0] cpu_dat_o;
  wire [15:0] d;
  wire [ 3:0] addr_d;
  wire        byte_op;
  wire [ 8:0] flags;

  wire [15:0] dbg_vdu_dat_o;
  wire [11:1] dbg_vdu_adr_o;
  wire        dbg_vdu_we_o;
  wire        dbg_vdu_stb_o;
  wire [ 1:0] dbg_vdu_sel_o;
  wire        dbg_vdu_tga_o;

  wire [19:1] dbg_zbt_adr_o;
  wire        dbg_zbt_we_o;
  wire [ 1:0] dbg_zbt_sel_o;
  wire        dbg_zbt_stb_o;

  wire [ 2:0] old_zet_st;
  wire [ 4:0] pack;
  wire [19:0] tr_dat;
  wire        tr_new_pc;
  wire        tr_st;
  wire        tr_stb;
  wire        tr_ack;
  wire        addr_st;

  wire        end_seq;
  wire        ext_int;
  wire        cpu_block2;

  wire [ 1:0] irr;

  wire        rx_output_strobe;
  wire        rx_shifting_done;
  wire        released;
`endif

  // Register declarations
  reg  [15:0] io_reg;
  reg  [ 1:0] vdu_stb_sync;
  reg  [ 1:0] vdu_ack_sync;

  // Module instantiations
  clock #(
    .div (8)
    ) c0 (
    .clk_100M    (clk_100M),
    .sys_clk_in_ (sys_clk_in_),
    .clk         (sys_clk),
    .vdu_clk     (tft_lcd_clk_),
    .rst         (rst_lck)
  );

  vdu vdu0 (
    // Wishbone signals
    .wb_clk_i (tft_lcd_clk_), // 25 Mhz VDU clock
    .wb_rst_i (rst2),
    .wb_dat_i (vdu_dat_i),
    .wb_dat_o (vdu_dat_o),
    .wb_adr_i (vdu_adr_i),
    .wb_we_i  (vdu_we_i),
    .wb_tga_i (vdu_tga_i),
    .wb_sel_i (vdu_sel_i),
    .wb_stb_i (vdu_stb_i),
    .wb_cyc_i (vdu_stb_i),
    .wb_ack_o (vdu_ack_o),

    // VGA pad signals
    .vga_red_o   (tft_lcd_r_),
    .vga_green_o (tft_lcd_g_),
    .vga_blue_o  (tft_lcd_b_),
    .horiz_sync  (tft_lcd_hsync_),
    .vert_sync   (tft_lcd_vsync_)
  );

  flash_cntrl #(
    .timeout (4)
    ) fc0 (
     // Wishbone slave interface
    .wb_clk_i (clk),
    .wb_rst_i (rst),
    .wb_dat_i (dat_o),
    .wb_dat_o (flash_dat_o),
    .wb_adr_i (adr[16:1]),
    .wb_we_i  (we),
    .wb_tga_i (tga),
    .wb_stb_i (flash_stb),
    .wb_cyc_i (flash_stb),
    .wb_ack_o (flash_ack),

    // Pad signals
    .flash_addr_ (flash_addr_),
    .flash_data_ (sram_flash_data_[15:0]),
    .flash_we_n_ (flash_we_n_),
    .flash_ce2_  (flash_ce2_)
  );

  zbt_cntrl zbt0 (
`ifdef DEBUG
    .cnt    (cnt),
    .op     (op),
`endif
    .wb_clk_i (clk),
    .wb_rst_i (rst2),
    .wb_dat_i (dat_o),
    .wb_dat_o (zbt_dat_o),
    .wb_adr_i (zbt_adr_i),
    .wb_we_i  (zbt_we_i),
    .wb_sel_i (zbt_sel_i),
    .wb_stb_i (zbt_stb_i),
    .wb_cyc_i (zbt_stb_i),
    .wb_ack_o (zbt_ack),

    // Pad signals
    .sram_clk_      (sram_clk_),
    .sram_addr_     (sram_addr_),
    .sram_data_     (sram_flash_data_),
    .sram_we_n_     (sram_we_n_),
    .sram_bw_       (sram_bw_),
    .sram_cen_      (sram_cen_),
    .sram_adv_ld_n_ (sram_adv_ld_n_)
  );

  ps2_keyb #(1500, // number of clks for 60usec.
             11,   // number of bits needed for 60usec. timer
             120,  // number of clks for debounce
             7     // number of bits needed for debounce timer
            ) keyboard0 (      // Instance name
`ifdef DEBUG
    .rx_output_strobe (rx_output_strobe),
    .rx_shifting_done (rx_shifting_done),
    .released         (released),
`endif
    .wb_clk_i (clk),
    .wb_rst_i (rst),
    .wb_dat_o (keyb_dat_o),
    .wb_tgc_o (int[1]),

    .ps2_clk_  (ps2_clk_),
    .ps2_data_ (ps2_data_)
  );

  timer #(
    .res   (34),
    .phase (12507)
    ) timer0 (
    .wb_clk_i (clk),
    .wb_rst_i (rst),
    .wb_tgc_o (int[0])
  );

  simple_pic pic0 (
`ifdef DEBUG
    .irr  (irr),
`endif
    .clk  (clk),
    .rst  (rst),
    .int  (int),
    .inta (inta),
    .intr (intr),
    .iid  (iid)
  );

  aceusb ace_cf (
    .wb_clk_i (clk),
    .wb_rst_i (rst),
    .wb_adr_i (adr[6:1]),
    .wb_dat_i (dat_o),
    .wb_dat_o (ace_dat_o),
    .wb_cyc_i (ace_stb),
    .wb_stb_i (ace_stb),
    .wb_we_i  (we),
    .wb_ack_o (ace_ack),

    .aceusb_a_    (aceusb_a_),
    .aceusb_d_    (aceusb_d_),
    .aceusb_oe_n_ (aceusb_oe_n_),
    .aceusb_we_n_ (aceusb_we_n_),

    .ace_clkin_  (ace_clkin_),
    .ace_mpce_n_ (ace_mpce_n_),

    .usb_cs_n_        (usb_cs_n_),
    .usb_hpi_reset_n_ (usb_hpi_reset_n_)
  );

  cpu zet_proc (
`ifdef DEBUG
    .cs         (cs),
    .ip         (ip),
    .state      (state),
    .next_state (next_state),
    .iralu      (funct),
    .x          (x),
    .y          (y),
    .imm        (imm),
    .aluo       (aluo),
    .ax         (ax),
    .dx         (dx),
    .bp         (bp),
    .si         (si),
    .es         (es),
    .dbg_block  (cpu_block),
    .c          (c),
    .addr_c     (addr_c),
    .cpu_dat_o  (cpu_dat_o),
    .d          (d),
    .byte_exec  (byte_op),
    .addr_d     (addr_d),
    .flags      (flags),
    .end_seq    (end_seq),
    .ext_int    (ext_int),
    .cpu_block  (cpu_block2),
`endif

    // Wishbone master interface
    .wb_clk_i (clk),
    .wb_rst_i (rst),
    .wb_dat_i (dat_i),
    .wb_dat_o (dat_o),
    .wb_adr_o (adr),
    .wb_we_o  (we),
    .wb_tga_o (tga),
    .wb_sel_o (sel),
    .wb_stb_o (stb),
    .wb_cyc_o (cyc),
    .wb_ack_i (ack),
    .wb_tgc_i (intr),
    .wb_tgc_o (inta)
  );

`ifdef DEBUG
  // Module instantiations

  icon icon0 (
    .CONTROL0 (control0)
  );

  ila ila0 (
    .CONTROL (control0),
    .CLK     (clk),
    .TRIG0   (adr),
    .TRIG1   ({dat_o,dat_i}),
    .TRIG2   (pc),
    .TRIG3   ({clk,we,tga,cyc,stb,ack}),
    .TRIG4   (funct),
    .TRIG5   ({state,next_state}),
    .TRIG6   ({intr,inta,flags,byte_op,addr_d}),
    .TRIG7   (d),
    .TRIG8   ({x,y}),
    .TRIG9   (aluo),
    .TRIG10  ({ace_mpce_n_,aceusb_we_n_,aceusb_oe_n_,
               ace_ack,ace_stb,ace_dat_o}),
    .TRIG11  (aceusb_d_),
    .TRIG12  ({1'b0,rx_output_strobe,rx_shifting_done,released,int,irr,iid}),
    .TRIG13  (cnt),
    .TRIG14  ({vdu_mem_arena,flash_mem_arena,flash_stb,zbt_stb,op}),
    .TRIG15  (cnt_time)
  );

  lcd_display lcd0 (
    .f1 (f1),  // 1st row
    .f2 (f2),  // 2nd row
    .m1 (m1),  // 1st row mask
    .m2 (m2),  // 2nd row mask

    .clk (clk_100M),  // 100 Mhz clock
    .rst (rst_lck),

    // Pad signals
    .lcd_rs_  (rs_),
    .lcd_rw_  (rw_),
    .lcd_e_   (e_),
    .lcd_dat_ (db_)
  );

  hw_dbg dbg0 (
    .clk     (clk),
    .rst_lck (rst_lck),
    .rst     (rst),
    .butc_   (butc_),
    .bute_   (bute_),
    .butw_   (butw_),
    .butn_   (butn_),
    .buts_   (buts_),

    .vdu_dat_o (dbg_vdu_dat_o),
    .vdu_adr_o (dbg_vdu_adr_o),
    .vdu_we_o  (dbg_vdu_we_o),
    .vdu_stb_o (dbg_vdu_stb_o),
    .vdu_sel_o (dbg_vdu_sel_o),
    .vdu_tga_o (dbg_vdu_tga_o),
    .vdu_ack_i (vdu_ack_sync[1]),

    .zbt_dat_i (zbt_dat_o),
    .zbt_adr_o (dbg_zbt_adr_o),
    .zbt_we_o  (dbg_zbt_we_o),
    .zbt_sel_o (dbg_zbt_sel_o),
    .zbt_stb_o (dbg_zbt_stb_o),
    .zbt_ack_i (zbt_ack)
  );

  clk_uart clk0 (
    .clk_100M   (clk_100M),
    .rst        (rst_lck),
    .clk_921600 (clk_921600),
    .rst2       (rst2)
  );

  pc_trace pc0 (
    .old_zet_st (old_zet_st),

    .dat    (tr_dat),
    .new_pc (tr_new_pc),
    .st     (tr_st),
    .stb    (tr_stb),
    .ack    (tr_ack),
    .pack   (pack),
    .addr_st (addr_st),
    .trx_ (trx_),

    .clk      (clk),
    .rst      (rst2),
    .pc       (pc),
    .zet_st   (state),
    .block    (block)
  );

  // Continuous assignments
  assign f1 = { 3'b0, rst, 4'h0, io_reg, 4'h0, dat_o, 7'h0, tga, 7'h0, ack, 4'h0 };
  assign f2 = { adr, 7'h0, we, 3'h0, stb, 3'h0, cyc, 8'h0, pc };
  assign m1 = 16'b1011110111101010;
  assign m2 = 16'b1111101110011111;

  assign pc = (cs << 4) + ip;

  assign vdu_dat_i = rst ? dbg_vdu_dat_o : dat_o;
  assign vdu_adr_i = rst ? dbg_vdu_adr_o : adr[11:1];
  assign vdu_we_i  = rst ? dbg_vdu_we_o : we;
  assign vdu_sel_i = rst ? dbg_vdu_sel_o : sel;
  assign vdu_stb_i = rst ? dbg_vdu_stb_o : stb & cyc & vdu_arena;
  assign vdu_tga_i = rst ? dbg_vdu_tga_o : tga;
  assign zbt_adr_i = rst ? dbg_zbt_adr_o : adr;
  assign zbt_we_i  = rst ? dbg_zbt_we_o  : we;
  assign zbt_sel_i = rst ? dbg_zbt_sel_o : sel;
  assign zbt_stb_i = rst ? dbg_zbt_stb_o : zbt_stb;
`ifdef DEBUG_TRACE
   assign cpu_block = block;
`else
   assign cpu_block = 1'b0;
`endif
`else
  assign vdu_dat_i = dat_o;
  assign vdu_adr_i = adr[11:1];
  assign vdu_we_i  = we;
  assign vdu_sel_i = sel;
  assign vdu_stb_i = stb & cyc & vdu_arena;
  assign vdu_tga_i = tga;
  assign zbt_adr_i = adr;
  assign zbt_we_i  = we;
  assign zbt_sel_i = sel;
  assign zbt_stb_i = zbt_stb;
  assign rst2 = rst_lck;

  assign rs_  = 1'b1;
  assign e_   = 1'b0;
  assign rw_  = 1'b1;
  assign db_  = 4'h0;
  assign trx_ = 1'b1;
`endif

`ifdef DEBUG_TRACE
  assign clk = clk_921600;
`else
//  assign clk = sys_clk;
  assign clk = tft_lcd_clk_;
`endif

  assign io_dat_i = flash_io_arena ? flash_dat_o
                  : (vdu_io_arena ? vdu_dat_o
                  : (keyb_io_arena ? keyb_dat_o
                  : (keyb_io_status ? 16'h10
                  : (ace_io_arena ? ace_dat_o : 16'h0))));
  assign dat_i    = inta ? { 15'b0000_0000_0000_100, iid }
                  : (tga ? io_dat_i
                  : (vdu_mem_arena ? vdu_dat_o
                  : (flash_mem_arena ? flash_dat_o : zbt_dat_o)));

  assign flash_mem_arena = (adr[19:16]==4'hc || adr[19:16]==4'hf);
  assign vdu_mem_arena = (adr[19:12]==8'hb8);

  assign flash_io_arena  = (adr[15:9]==7'b1110_000);
  assign vdu_io_arena  = (adr[15:4]==12'h03d) &&
                         ((adr[3:1]==3'h2 && we)
                       || (adr[3:1]==3'h5 && !we));

  assign keyb_io_arena = (adr[15:1]==15'h0030 && !we);
  assign ace_io_arena = (adr[15:7]==9'b1110_0010_0);

  // MS-DOS is reading IO address 0x64 to check the inhibit bit
  assign keyb_io_status = (adr[15:1]==15'h0032 && !we);

  assign flash_arena = (!tga & flash_mem_arena)
                     | (tga & flash_io_arena);
  assign vdu_arena = (!tga & vdu_mem_arena)
                   | (tga & vdu_io_arena);
  assign keyb_arena = (tga & keyb_io_arena);
  assign ace_arena  = (tga & ace_io_arena);

  assign flash_stb = flash_arena & stb & cyc;
  assign zbt_stb   = !vdu_mem_arena & !flash_mem_arena
                   & !tga & stb & cyc;
  assign ace_stb   = ace_arena & stb & cyc;

  assign ack    = tga ? (flash_io_arena ? flash_ack
                      : (vdu_io_arena ? vdu_ack_o
                      : (ace_io_arena ? ace_ack : (stb & cyc))))
                : (vdu_mem_arena ? vdu_ack_o
                : (flash_mem_arena ? flash_ack : zbt_ack));

  assign sram_flash_oe_n_ = 1'b0;
  assign sram_flash_addr_ = flash_arena ? flash_addr_
                                        : sram_addr_;
  assign sram_flash_we_n_ = flash_arena ? flash_we_n_
                                        : sram_we_n_;

  // Behaviour
  // vdu_stb_sync[0]
  always @(posedge tft_lcd_clk_)
    vdu_stb_sync[0] <= vdu_stb_i;

  // vdu_stb_sync[1]
  always @(posedge clk)
    vdu_stb_sync[1] <= vdu_stb_sync[0];

  // vdu_ack_sync[0]
  always @(posedge clk) vdu_ack_sync[0] <= vdu_ack_o;

  // vdu_ack_sync[1]
  always @(posedge clk) vdu_ack_sync[1] <= vdu_ack_sync[0];

  // io_reg
  always @(posedge clk)
    io_reg <= rst ? 16'h0
	   : ((tga && stb && cyc && we && adr[15:8]==8'hf1) ?
		  dat_o : io_reg );

`ifdef DEBUG
  // cnt_time
  always @(posedge clk)
    cnt_time <= rst ? 32'h0 : (cnt_time + 32'h1);
`else
  assign rst = rst_lck;
`endif
endmodule
