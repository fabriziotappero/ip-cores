// --------------------------------------------------------------------
//
// --------------------------------------------------------------------


`include "timescale.v"


module tb_top();

  parameter CLK_PERIOD = 100;
  parameter LOG_LEVEL = 3;

  reg tb_clk, tb_rst;

  initial 
    begin
      tb_clk <= 1'b1;      
      tb_rst <= 1'b1;
      
      #(CLK_PERIOD); #(CLK_PERIOD/3);
      tb_rst = 1'b0;
      
    end

  always
    #(CLK_PERIOD/2) tb_clk = ~tb_clk;
    
    
// --------------------------------------------------------------------
// tb_dut
  tb_dut i_tb_dut( tb_clk, tb_rst );
  
  
// --------------------------------------------------------------------
// debug wires
  wire  [31:0] r0 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*0+31:32*0];
  wire  [31:0] r1 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*1+31:32*1];
  wire  [31:0] r2 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*2+31:32*2];
  wire  [31:0] r3 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*3+31:32*3];
  wire  [31:0] r4 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*4+31:32*4];
  wire  [31:0] r5 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*5+31:32*5];
  wire  [31:0] r6 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*6+31:32*6];
  wire  [31:0] r7 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*7+31:32*7];
  wire  [31:0] r8 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*8+31:32*8];
  wire  [31:0] r9 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*9+31:32*9];
  wire  [31:0] r10 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*10+31:32*10];
  wire  [31:0] r11 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*11+31:32*11];
  wire  [31:0] r12 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*12+31:32*12];
  wire  [31:0] r13 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*13+31:32*13];
  wire  [31:0] r14 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*14+31:32*14];
  wire  [31:0] r15 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*15+31:32*15];
  wire  [31:0] r16 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*16+31:32*16];
  wire  [31:0] r17 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*17+31:32*17];
  wire  [31:0] r18 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*18+31:32*18];
  wire  [31:0] r19 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*19+31:32*19];
  wire  [31:0] r20 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*20+31:32*20];
  wire  [31:0] r21 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*21+31:32*21];
  wire  [31:0] r22 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*22+31:32*22];
  wire  [31:0] r23 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*23+31:32*23];
  wire  [31:0] r24 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*24+31:32*24];
  wire  [31:0] r25 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*25+31:32*25];
  wire  [31:0] r26 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*26+31:32*26];
  wire  [31:0] r27 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*27+31:32*27];
  wire  [31:0] r28 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*28+31:32*28];
  wire  [31:0] r29 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*29+31:32*29];
  wire  [31:0] r30 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*30+31:32*30];
  wire  [31:0] r31 = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_rf.rf_a.mem[32*31+31:32*31];
  
  
// --------------------------------------------------------------------
// logging stuff

  wire iwb_clk_i = tb_top.i_tb_dut.i_top.i_or1200_soc_top.iwb_clk_i;
  wire iwb_ack_i = tb_top.i_tb_dut.i_top.i_or1200_soc_top.iwb_ack_i;
  wire iwb_we_o = tb_top.i_tb_dut.i_top.i_or1200_soc_top.iwb_we_o;
  
  wire [31:0] iwb_adr_o = tb_top.i_tb_dut.i_top.i_or1200_soc_top.iwb_adr_o;
  wire [31:0] iwb_dat_i = tb_top.i_tb_dut.i_top.i_or1200_soc_top.iwb_dat_i;
  wire [31:0] iwb_dat_o = tb_top.i_tb_dut.i_top.i_or1200_soc_top.iwb_dat_o;
    
  always @( posedge iwb_clk_i )
    if( iwb_ack_i & (LOG_LEVEL > 3) )
      if( iwb_we_o )
        $display( "###- iwb write: 0x%h @ 0x%h at time %t. ", iwb_dat_o, iwb_adr_o, $time );
      else  
        $display( "###- iwb read: 0x%h @ 0x%h at time %t. ", iwb_dat_i, iwb_adr_o, $time );
        

  wire dwb_clk_i = tb_top.i_tb_dut.i_top.i_or1200_soc_top.dwb_clk_i;
  wire dwb_ack_i = tb_top.i_tb_dut.i_top.i_or1200_soc_top.dwb_ack_i;
  wire dwb_we_o = tb_top.i_tb_dut.i_top.i_or1200_soc_top.dwb_we_o;
  
  wire [31:0] dwb_adr_o = tb_top.i_tb_dut.i_top.i_or1200_soc_top.dwb_adr_o;
  wire [31:0] dwb_dat_i = tb_top.i_tb_dut.i_top.i_or1200_soc_top.dwb_dat_i;
  wire [31:0] dwb_dat_o = tb_top.i_tb_dut.i_top.i_or1200_soc_top.dwb_dat_o;
    
  always @( posedge dwb_clk_i )
    if( dwb_ack_i & (LOG_LEVEL > 2) )
      if( dwb_we_o )
        $display( "###- dwb write: 0x%h @ 0x%h at time %t. ", dwb_dat_o, dwb_adr_o, $time );
      else  
        $display( "###- dwb read: 0x%h @ 0x%h at time %t. ", dwb_dat_i, dwb_adr_o, $time );

  wire [31:0] pc = tb_top.i_tb_dut.i_top.i_or1200_soc_top.i_or1200_top.or1200_cpu.or1200_genpc.pc;

  always @(pc)
    if( LOG_LEVEL > 3 ) 
      $display( "###- PC: 0x%h at time %t. ", pc, $time );
      
  reg [31:0] pc_1, pc_2, pc_3, pc_at_wb;
  
  always @(pc)
    begin
      pc_1 <= pc;
      pc_2 <= pc_1;
      pc_3 <= pc_2;
      pc_at_wb <= pc_3;
    end
  

    
// --------------------------------------------------------------------
// break point

  always @( posedge dwb_clk_i )
    if( dwb_ack_i & dwb_we_o & (dwb_dat_o == 32'hcea5e_0ff) & (dwb_adr_o == 32'h5fff_fffc) )
      $stop;

                        
endmodule


