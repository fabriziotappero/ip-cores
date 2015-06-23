// Xilinx Verilog produced by program ngd2ver F.28
// Command: -quiet -gp GSR -tp GTS -w -log __projnav/ngd2ver.log tdm_switch_top.nga tdm_switch_top_timesim.v 
// Input file: tdm_switch_top.nga
// Output file: tdm_switch_top_timesim.v
// Design name: tdm_switch_top
// Xilinx: E:/Xilinx
// # of Entities: 1
// Device: 2s50tq144-6 (PRODUCTION 1.27 2002-12-13)

// The output of ngd2ver is a simulation model. This netlist uses simulation
// primitives which may not represent the true implementation of the device,
// however the netlist is functionally correct and should not be modified.
// This file cannot be synthesized and should only be used with supported
// simulation, static timing analysis and formal verification software tools.
// Please refer to the documentation on using third party static timing analysis
// and formal verification software to use the netlist for that purpose.

`timescale 1 ns/1 ps

module tdm_switch_top (
  frame_sync, clk_out, mpi_rw, mpi_cs, reset, clk_in, mpi_clk, GSR, GTS, tx_stream, mpi_data_out, rx_stream, mpi_data_in, mpi_addr
);
  output frame_sync;
  output clk_out;
  input mpi_rw;
  input mpi_cs;
  input reset;
  input clk_in;
  input mpi_clk;
  input GSR;
  input GTS;
  output [7 : 0] tx_stream;
  output [8 : 0] mpi_data_out;
  input [7 : 0] rx_stream;
  input [8 : 0] mpi_data_in;
  input [8 : 0] mpi_addr;
  wire frame_sync_OBUF;
  wire mpi_clk_BUFGP;
  wire _n0045;
  wire mpi_data_in_0_IBUF;
  wire mpi_data_in_1_IBUF;
  wire mpi_data_in_2_IBUF;
  wire mpi_data_in_3_IBUF;
  wire mpi_data_in_4_IBUF;
  wire mpi_data_in_5_IBUF;
  wire mpi_data_in_6_IBUF;
  wire mpi_data_in_7_IBUF;
  wire mpi_data_in_8_IBUF;
  wire mpi_addr_0_IBUF;
  wire mpi_addr_1_IBUF;
  wire mpi_addr_2_IBUF;
  wire mpi_addr_3_IBUF;
  wire mpi_addr_4_IBUF;
  wire mpi_addr_5_IBUF;
  wire mpi_addr_6_IBUF;
  wire mpi_addr_7_IBUF;
  wire mpi_addr_8_IBUF;
  wire reset_IBUF;
  wire \clk_in_BUFGP/IBUFG ;
  wire mpi_cs_IBUF;
  wire div_reg_2;
  wire div_reg_1;
  wire \mpi_clk_BUFGP/IBUFG ;
  wire mpi_rw_IBUF;
  wire div_reg;
  wire clk_in_BUFGP;
  wire ram_en;
  wire frame_cnt_1_1;
  wire GLOBAL_LOGIC0;
  wire _n0054;
  wire mem_page_sel;
  wire Mmux__n0074__net2;
  wire Mmux__n0074__net9;
  wire N8791;
  wire GLOBAL_LOGIC1;
  wire \_n00631/O ;
  wire frame_delay_cnt_0_1_0;
  wire frame_delay_cnt_0_0_0;
  wire \_n00621/O ;
  wire frame_delay_cnt_1_1_0;
  wire frame_delay_cnt_1_0_0;
  wire \_n00611/O ;
  wire frame_delay_cnt_2_1_0;
  wire frame_delay_cnt_2_0_0;
  wire \_n00601/O ;
  wire frame_delay_cnt_3_1_0;
  wire frame_delay_cnt_3_0_0;
  wire \_n00591/O ;
  wire frame_delay_cnt_4_1_0;
  wire frame_delay_cnt_4_0_0;
  wire \_n00581/O ;
  wire frame_delay_cnt_5_1_0;
  wire frame_delay_cnt_5_0_0;
  wire \_n00571/O ;
  wire frame_delay_cnt_6_1_0;
  wire frame_delay_cnt_6_0_0;
  wire \_n00561/O ;
  wire frame_delay_cnt_7_1_0;
  wire frame_delay_cnt_7_0_0;
  wire \_n00311/O ;
  wire \_n00321/O ;
  wire Ker87891_1;
  wire N8682;
  wire _n0225;
  wire frame_delay_cnt_0_0_0__n0000;
  wire N8676;
  wire frame_delay_cnt_0_0_1__n0000;
  wire _n0227;
  wire frame_delay_cnt_1_0_0__n0000;
  wire N8670;
  wire frame_delay_cnt_1_0_1__n0000;
  wire _n0228;
  wire frame_delay_cnt_2_0_0__n0000;
  wire N8664;
  wire frame_delay_cnt_2_0_1__n0000;
  wire _n0229;
  wire frame_delay_cnt_3_0_0__n0000;
  wire N8658;
  wire frame_delay_cnt_3_0_1__n0000;
  wire _n0230;
  wire frame_delay_cnt_4_0_0__n0000;
  wire N8652;
  wire frame_delay_cnt_4_0_1__n0000;
  wire _n0231;
  wire frame_delay_cnt_5_0_0__n0000;
  wire N8646;
  wire frame_delay_cnt_5_0_1__n0000;
  wire _n0232;
  wire frame_delay_cnt_6_0_0__n0000;
  wire N8640;
  wire frame_delay_cnt_6_0_1__n0000;
  wire _n0233;
  wire frame_delay_cnt_7_0_0__n0000;
  wire N8634;
  wire frame_delay_cnt_7_0_1__n0000;
  wire N8954;
  wire N8728;
  wire _n0038;
  wire _n0028;
  wire _n0030;
  wire _n0039;
  wire _n0040;
  wire _n0029;
  wire _n0033;
  wire _n0042;
  wire _n0041;
  wire _n0027;
  wire _n0034;
  wire _n0044;
  wire _n0043;
  wire GLOBAL_LOGIC1_0;
  wire GLOBAL_LOGIC1_1;
  wire GLOBAL_LOGIC0_0;
  wire GLOBAL_LOGIC0_1;
  wire GLOBAL_LOGIC0_2;
  wire GLOBAL_LOGIC0_3;
  wire GLOBAL_LOGIC0_4;
  wire GLOBAL_LOGIC0_5;
  wire GLOBAL_LOGIC0_6;
  wire GTS_0;
  wire \mpi_data_in<1>/IBUF ;
  wire \mpi_data_in<1>/IDELAY ;
  wire \mpi_data_in<0>/IBUF ;
  wire \mpi_data_in<0>/IDELAY ;
  wire \frame_sync/OUTMUX ;
  wire \frame_sync/TORGTS ;
  wire \frame_sync/ENABLE ;
  wire \mpi_data_in<1>/IFF/RST ;
  wire \mpi_data_in<0>/IFF/RST ;
  wire \mpi_data_out<0>/TDATANOT ;
  wire \mpi_data_out<0>/OUTMUX ;
  wire \mpi_data_out<0>/TORGTS ;
  wire \mpi_data_out<0>/ENABLE ;
  wire \mpi_data_out<1>/TDATANOT ;
  wire \mpi_data_out<1>/OUTMUX ;
  wire \mpi_data_out<1>/TORGTS ;
  wire \mpi_data_out<1>/ENABLE ;
  wire \mpi_data_out<2>/TDATANOT ;
  wire \mpi_data_out<2>/OUTMUX ;
  wire \mpi_data_out<2>/TORGTS ;
  wire \mpi_data_out<2>/ENABLE ;
  wire \mpi_data_out<3>/TDATANOT ;
  wire \mpi_data_out<3>/OUTMUX ;
  wire \mpi_data_out<3>/TORGTS ;
  wire \mpi_data_out<3>/ENABLE ;
  wire \mpi_data_out<4>/TDATANOT ;
  wire \mpi_data_out<4>/OUTMUX ;
  wire \mpi_data_out<4>/TORGTS ;
  wire \mpi_data_out<4>/ENABLE ;
  wire \mpi_data_out<5>/TDATANOT ;
  wire \mpi_data_out<5>/OUTMUX ;
  wire \mpi_data_out<5>/TORGTS ;
  wire \mpi_data_out<5>/ENABLE ;
  wire \mpi_data_out<6>/TDATANOT ;
  wire \mpi_data_out<6>/OUTMUX ;
  wire \mpi_data_out<6>/TORGTS ;
  wire \mpi_data_out<6>/ENABLE ;
  wire \mpi_data_out<7>/TDATANOT ;
  wire \mpi_data_out<7>/OUTMUX ;
  wire \mpi_data_out<7>/TORGTS ;
  wire \mpi_data_out<7>/ENABLE ;
  wire \mpi_data_out<8>/TDATANOT ;
  wire \mpi_data_out<8>/OUTMUX ;
  wire \mpi_data_out<8>/TORGTS ;
  wire \mpi_data_out<8>/ENABLE ;
  wire rx_stream_0_IBUF;
  wire \rx_stream<0>/IDELAY ;
  wire \rx_stream<0>/ICLKNOT ;
  wire \rx_stream<0>/IFF/RST ;
  wire rx_stream_1_IBUF;
  wire \rx_stream<1>/IDELAY ;
  wire \rx_stream<1>/ICLKNOT ;
  wire \rx_stream<1>/IFF/RST ;
  wire rx_stream_2_IBUF;
  wire \rx_stream<2>/IDELAY ;
  wire \rx_stream<2>/ICLKNOT ;
  wire \rx_stream<2>/IFF/RST ;
  wire rx_stream_3_IBUF;
  wire \rx_stream<3>/IDELAY ;
  wire \rx_stream<3>/ICLKNOT ;
  wire \rx_stream<3>/IFF/RST ;
  wire rx_stream_4_IBUF;
  wire \rx_stream<4>/IDELAY ;
  wire \rx_stream<4>/ICLKNOT ;
  wire \rx_stream<4>/IFF/RST ;
  wire rx_stream_5_IBUF;
  wire \rx_stream<5>/IDELAY ;
  wire \rx_stream<5>/ICLKNOT ;
  wire \rx_stream<5>/IFF/RST ;
  wire rx_stream_6_IBUF;
  wire \rx_stream<6>/IDELAY ;
  wire \rx_stream<6>/ICLKNOT ;
  wire \rx_stream<6>/IFF/RST ;
  wire rx_stream_7_IBUF;
  wire \rx_stream<7>/IDELAY ;
  wire \rx_stream<7>/ICLKNOT ;
  wire \rx_stream<7>/IFF/RST ;
  wire \tx_stream<0>/OD ;
  wire \tx_stream<0>/OUTMUX ;
  wire \tx_stream<0>/TORGTS ;
  wire \tx_stream<0>/ENABLE ;
  wire \tx_stream<0>/OFF/RST ;
  wire \tx_stream<1>/OD ;
  wire \tx_stream<1>/OUTMUX ;
  wire \tx_stream<1>/TORGTS ;
  wire \tx_stream<1>/ENABLE ;
  wire \tx_stream<1>/OFF/RST ;
  wire \tx_stream<2>/OD ;
  wire \tx_stream<2>/OUTMUX ;
  wire \tx_stream<2>/TORGTS ;
  wire \tx_stream<2>/ENABLE ;
  wire \tx_stream<2>/OFF/RST ;
  wire \tx_stream<3>/OD ;
  wire \tx_stream<3>/OUTMUX ;
  wire \tx_stream<3>/TORGTS ;
  wire \tx_stream<3>/ENABLE ;
  wire \tx_stream<3>/OFF/RST ;
  wire \tx_stream<4>/OD ;
  wire \tx_stream<4>/OUTMUX ;
  wire \tx_stream<4>/TORGTS ;
  wire \tx_stream<4>/ENABLE ;
  wire \tx_stream<4>/OFF/RST ;
  wire \tx_stream<5>/OD ;
  wire \tx_stream<5>/OUTMUX ;
  wire \tx_stream<5>/TORGTS ;
  wire \tx_stream<5>/ENABLE ;
  wire \tx_stream<5>/OFF/RST ;
  wire \tx_stream<6>/OD ;
  wire \tx_stream<6>/OUTMUX ;
  wire \tx_stream<6>/TORGTS ;
  wire \tx_stream<6>/ENABLE ;
  wire \tx_stream<6>/OFF/RST ;
  wire \tx_stream<7>/OD ;
  wire \tx_stream<7>/OUTMUX ;
  wire \tx_stream<7>/TORGTS ;
  wire \tx_stream<7>/ENABLE ;
  wire \tx_stream<7>/OFF/RST ;
  wire \clk_out/OUTMUX ;
  wire \clk_out/TORGTS ;
  wire \clk_out/ENABLE ;
  wire \c_mem/ENA_INTNOT ;
  wire \c_mem/RSTA_INTNOT ;
  wire \c_mem/RSTB_INTNOT ;
  wire \c_mem/LOGIC_ZERO ;
  wire \c_mem/WEB_INTNOT ;
  wire \c_mem/ADDRA0 ;
  wire \c_mem/ADDRA1 ;
  wire \c_mem/ADDRA2 ;
  wire \c_mem/ADDRA3 ;
  wire \c_mem/ADDRB0 ;
  wire \c_mem/ADDRB1 ;
  wire \c_mem/ADDRB2 ;
  wire \c_mem/ADDRB3 ;
  wire \c_mem/DOA8 ;
  wire \c_mem/DOA9 ;
  wire \c_mem/DOA10 ;
  wire \c_mem/DOA11 ;
  wire \c_mem/DOA12 ;
  wire \c_mem/DOA13 ;
  wire \c_mem/DOA14 ;
  wire \c_mem/DOA15 ;
  wire \c_mem/DOB9 ;
  wire \c_mem/DOB10 ;
  wire \c_mem/DOB11 ;
  wire \c_mem/DOB12 ;
  wire \c_mem/DOB13 ;
  wire \c_mem/DOB14 ;
  wire \c_mem/DOB15 ;
  wire \d_mem/LOGIC_ONE ;
  wire \d_mem/RSTA_INTNOT ;
  wire \d_mem/RSTB_INTNOT ;
  wire \d_mem/LOGIC_ZERO ;
  wire \d_mem/ADDRA0 ;
  wire \d_mem/ADDRA1 ;
  wire \d_mem/ADDRA2 ;
  wire \d_mem/ADDRB0 ;
  wire \d_mem/ADDRB1 ;
  wire \d_mem/ADDRB2 ;
  wire \d_mem/ADDRB3 ;
  wire \d_mem/DIA8 ;
  wire \d_mem/DIA9 ;
  wire \d_mem/DIA10 ;
  wire \d_mem/DIA11 ;
  wire \d_mem/DIA12 ;
  wire \d_mem/DIA13 ;
  wire \d_mem/DIA14 ;
  wire \d_mem/DIA15 ;
  wire \d_mem/DOA8 ;
  wire \d_mem/DOA9 ;
  wire \d_mem/DOA10 ;
  wire \d_mem/DOA11 ;
  wire \d_mem/DOA12 ;
  wire \d_mem/DOA13 ;
  wire \d_mem/DOA14 ;
  wire \d_mem/DOA15 ;
  wire \d_mem/DOB0 ;
  wire \d_mem/DOB1 ;
  wire \d_mem/DOB2 ;
  wire \d_mem/DOB3 ;
  wire \d_mem/DOB4 ;
  wire \d_mem/DOB5 ;
  wire \d_mem/DOB6 ;
  wire \d_mem/DOB7 ;
  wire \d_mem/DOB8 ;
  wire \d_mem/DOB9 ;
  wire \d_mem/DOB10 ;
  wire \d_mem/DOB11 ;
  wire \d_mem/DOB12 ;
  wire \d_mem/DOB13 ;
  wire \d_mem/DOB14 ;
  wire \d_mem/DOB15 ;
  wire \data_in_bus<12>/F5MUX ;
  wire N9669;
  wire N9671;
  wire \data_in_bus<3>/F5MUX ;
  wire N9619;
  wire N9621;
  wire \data_in_bus<13>/F5MUX ;
  wire N9659;
  wire N9661;
  wire \data_in_bus<4>/F5MUX ;
  wire N9614;
  wire N9616;
  wire \data_in_bus<14>/F5MUX ;
  wire N9649;
  wire N9651;
  wire \data_in_bus<5>/F5MUX ;
  wire N9664;
  wire N9666;
  wire \data_in_bus<15>/F5MUX ;
  wire N9674;
  wire N9676;
  wire \Mmux__n0074__net2/F5MUX ;
  wire Mmux__n0074__net0;
  wire Mmux__n0074__net1;
  wire Mmux__n0074__net5;
  wire \_n0246<2>/F6MUX ;
  wire Mmux__n0074__net3;
  wire Mmux__n0074__net4;
  wire \Mmux__n0074__net9/F5MUX ;
  wire Mmux__n0074__net7;
  wire Mmux__n0074__net8;
  wire Mmux__n0074__net12;
  wire \_n0246<3>/F6MUX ;
  wire Mmux__n0074__net10;
  wire Mmux__n0074__net11;
  wire \data_in_bus<6>/F5MUX ;
  wire N9654;
  wire N9656;
  wire \data_in_bus<7>/F5MUX ;
  wire N9644;
  wire N9646;
  wire \data_in_bus<8>/F5MUX ;
  wire N9634;
  wire N9636;
  wire \data_in_bus<9>/F5MUX ;
  wire N9629;
  wire N9631;
  wire \data_in_bus<0>/F5MUX ;
  wire N9679;
  wire N9681;
  wire \data_in_bus<10>/F5MUX ;
  wire N9624;
  wire N9626;
  wire \data_in_bus<1>/F5MUX ;
  wire N9609;
  wire N9611;
  wire \data_in_bus<11>/F5MUX ;
  wire N9639;
  wire N9641;
  wire \data_in_bus<2>/F5MUX ;
  wire N9604;
  wire N9606;
  wire \d_mem_addr_cnt<0>/LOGIC_ZERO ;
  wire d_mem_addr_cnt_Madd__n0000_inst_cy_0;
  wire \d_mem_addr_cnt<0>/GROM ;
  wire \d_mem_addr_cnt<0>/CYMUXG ;
  wire d_mem_addr_cnt_Madd__n0000_inst_lut2_0;
  wire \d_mem_addr_cnt<2>/CYINIT ;
  wire d_mem_addr_cnt_Madd__n0000_inst_cy_2;
  wire \d_mem_addr_cnt<2>/GROM ;
  wire \d_mem_addr_cnt<2>/LOGIC_ZERO ;
  wire \d_mem_addr_cnt<2>/CYMUXG ;
  wire \d_mem_addr_cnt<2>/FROM ;
  wire \d_mem_addr_cnt<4>/CYINIT ;
  wire \d_mem_addr_cnt<4>_rt ;
  wire \c_mem_addr_cnt<0>/LOGIC_ZERO ;
  wire c_mem_addr_cnt_Madd__n0000_inst_cy_0;
  wire \c_mem_addr_cnt<0>/GROM ;
  wire \c_mem_addr_cnt<0>/CYMUXG ;
  wire c_mem_addr_cnt_Madd__n0000_inst_lut2_0;
  wire \c_mem_addr_cnt<2>/CYINIT ;
  wire c_mem_addr_cnt_Madd__n0000_inst_cy_2;
  wire \c_mem_addr_cnt<2>/GROM ;
  wire \c_mem_addr_cnt<2>/LOGIC_ZERO ;
  wire \c_mem_addr_cnt<2>/CYMUXG ;
  wire \c_mem_addr_cnt<2>/FROM ;
  wire \c_mem_addr_cnt<4>/CYINIT ;
  wire \c_mem_addr_cnt<4>_rt ;
  wire \frame_cnt<0>/CKMUXNOT ;
  wire \frame_cnt<0>/XORG ;
  wire \frame_cnt<0>/SRMUX_OUTPUTNOT ;
  wire \frame_cnt<0>/LOGIC_ZERO ;
  wire frame_cnt_Madd__n0000_inst_cy_5;
  wire \frame_cnt<0>/GROM ;
  wire \frame_cnt<0>/CYMUXG ;
  wire frame_cnt_Madd__n0000_inst_lut2_5;
  wire \frame_cnt<0>/FFX/RST ;
  wire \frame_cnt<0>/FFY/RST ;
  wire \frame_cnt<2>/CKMUXNOT ;
  wire \frame_cnt<2>/SRMUX_OUTPUTNOT ;
  wire \frame_cnt<2>/CYINIT ;
  wire frame_cnt_Madd__n0000_inst_cy_7;
  wire \frame_cnt<2>/GROM ;
  wire \frame_cnt<2>/LOGIC_ZERO ;
  wire \frame_cnt<2>/CYMUXG ;
  wire \frame_cnt<2>/FROM ;
  wire \frame_cnt<2>/FFX/RST ;
  wire \frame_cnt<4>/CKMUXNOT ;
  wire \frame_cnt<4>/SRMUX_OUTPUTNOT ;
  wire \frame_cnt<4>/CYINIT ;
  wire frame_cnt_Madd__n0000_inst_cy_9;
  wire \frame_cnt<4>/GROM ;
  wire \frame_cnt<4>/LOGIC_ZERO ;
  wire \frame_cnt<4>/CYMUXG ;
  wire \frame_cnt<4>/FROM ;
  wire \frame_cnt<4>/FFX/RST ;
  wire \frame_cnt<4>/FFY/RST ;
  wire \frame_cnt<6>/CKMUXNOT ;
  wire \frame_cnt<6>/SRMUX_OUTPUTNOT ;
  wire \frame_cnt<6>/CYINIT ;
  wire frame_cnt_Madd__n0000_inst_cy_11;
  wire \frame_cnt<6>/GROM ;
  wire \frame_cnt<6>/LOGIC_ZERO ;
  wire \frame_cnt<6>/CYMUXG ;
  wire \frame_cnt<6>/FROM ;
  wire \frame_cnt<6>/FFX/RST ;
  wire \frame_cnt<6>/FFY/RST ;
  wire \frame_cnt<8>/CYINIT ;
  wire \frame_cnt<8>/SRMUX_OUTPUTNOT ;
  wire \frame_cnt<8>/CKMUXNOT ;
  wire \frame_cnt<8>_rt ;
  wire \frame_cnt<8>/FFX/RST ;
  wire \rx_buf_reg_0<1>/GROM ;
  wire \rx_buf_reg_0<1>/FFY/RST ;
  wire \rx_buf_reg_0<1>/FFX/RST ;
  wire \rx_buf_reg_1<1>/GROM ;
  wire \rx_buf_reg_1<1>/FFY/RST ;
  wire \rx_buf_reg_1<1>/FFX/RST ;
  wire \rx_buf_reg_2<1>/GROM ;
  wire \rx_buf_reg_2<1>/FFX/RST ;
  wire \rx_buf_reg_2<1>/FFY/RST ;
  wire \rx_buf_reg_3<1>/GROM ;
  wire \rx_buf_reg_3<1>/FFX/RST ;
  wire \rx_buf_reg_3<1>/FFY/RST ;
  wire \rx_buf_reg_4<1>/GROM ;
  wire \rx_buf_reg_4<1>/FFX/RST ;
  wire \rx_buf_reg_4<1>/FFY/RST ;
  wire \rx_buf_reg_5<1>/GROM ;
  wire \rx_buf_reg_5<1>/FFY/RST ;
  wire \rx_buf_reg_5<1>/FFX/RST ;
  wire \rx_buf_reg_6<1>/GROM ;
  wire \rx_buf_reg_6<1>/FFY/RST ;
  wire \rx_buf_reg_6<1>/FFX/RST ;
  wire \rx_buf_reg_7<1>/GROM ;
  wire \rx_buf_reg_7<1>/FFY/RST ;
  wire \rx_buf_reg_7<1>/FFX/RST ;
  wire \tx_buf_reg_4<1>/GROM ;
  wire \tx_buf_reg_4<1>/FFY/RST ;
  wire \tx_buf_reg_4<1>/FFX/RST ;
  wire \tx_buf_reg_5<1>/GROM ;
  wire \tx_buf_reg_5<1>/FFY/RST ;
  wire \tx_buf_reg_5<1>/FFX/RST ;
  wire \tx_shift_reg_0<2>/FFY/RST ;
  wire \tx_shift_reg_0<2>/FFX/RST ;
  wire \tx_shift_reg_0<4>/FFY/RST ;
  wire \tx_shift_reg_0<4>/FFX/RST ;
  wire \tx_shift_reg_1<2>/FFY/RST ;
  wire \tx_shift_reg_1<2>/FFX/RST ;
  wire \tx_shift_reg_0<6>/FFY/RST ;
  wire \tx_shift_reg_0<6>/FFX/RST ;
  wire \tx_shift_reg_0<7>/FROM ;
  wire \tx_shift_reg_0<7>/FFY/RST ;
  wire \tx_shift_reg_1<4>/FFX/RST ;
  wire \tx_shift_reg_1<4>/FFY/RST ;
  wire \tx_shift_reg_6<4>/FFX/RST ;
  wire \tx_shift_reg_6<4>/FFY/RST ;
  wire \tx_shift_reg_6<6>/FFY/RST ;
  wire \tx_shift_reg_6<6>/FFX/RST ;
  wire \tx_shift_reg_7<4>/FFY/RST ;
  wire \tx_shift_reg_7<4>/FFX/RST ;
  wire \tx_shift_reg_7<7>/FROM ;
  wire \ctrl_out_reg<0>/FROM ;
  wire \ctrl_out_reg<1>/FROM ;
  wire \frame_delay_cnt_0_0_0/CKMUXNOT ;
  wire \frame_delay_cnt_0_0_0/FROM ;
  wire \frame_delay_cnt_0_1_0/CKMUXNOT ;
  wire \frame_delay_cnt_0_1_0/FROM ;
  wire \frame_delay_cnt_1_0_0/CKMUXNOT ;
  wire \frame_delay_cnt_1_0_0/FROM ;
  wire \frame_delay_cnt_1_1_0/CKMUXNOT ;
  wire \frame_delay_cnt_1_1_0/FROM ;
  wire \frame_delay_cnt_2_0_0/CKMUXNOT ;
  wire \frame_delay_cnt_2_0_0/FROM ;
  wire \frame_delay_cnt_2_1_0/CKMUXNOT ;
  wire \frame_delay_cnt_2_1_0/FROM ;
  wire \frame_delay_cnt_3_0_0/CKMUXNOT ;
  wire \frame_delay_cnt_3_0_0/FROM ;
  wire \frame_delay_cnt_3_1_0/CKMUXNOT ;
  wire \frame_delay_cnt_3_1_0/FROM ;
  wire \frame_delay_cnt_4_0_0/CKMUXNOT ;
  wire \frame_delay_cnt_4_0_0/FROM ;
  wire \frame_delay_cnt_4_1_0/CKMUXNOT ;
  wire \frame_delay_cnt_4_1_0/FROM ;
  wire \frame_delay_cnt_5_0_0/CKMUXNOT ;
  wire \frame_delay_cnt_5_0_0/FROM ;
  wire \frame_delay_cnt_5_1_0/CKMUXNOT ;
  wire \frame_delay_cnt_5_1_0/FROM ;
  wire \frame_delay_cnt_5_1_0/FFY/RST ;
  wire \frame_delay_cnt_5_1_0/FFY/SET ;
  wire \mem_page_sel/GROM ;
  wire \mem_page_sel/SRMUX_OUTPUTNOT ;
  wire \mem_page_sel/FROM ;
  wire \frame_delay_cnt_6_0_0/CKMUXNOT ;
  wire \frame_delay_cnt_6_0_0/FROM ;
  wire \frame_delay_cnt_6_1_0/CKMUXNOT ;
  wire \frame_delay_cnt_6_1_0/FROM ;
  wire \frame_delay_cnt_6_1_0/FFY/RST ;
  wire \frame_delay_cnt_6_1_0/FFY/SET ;
  wire \frame_delay_cnt_7_0_0/CKMUXNOT ;
  wire \frame_delay_cnt_7_0_0/FROM ;
  wire \frame_delay_cnt_7_1_0/CKMUXNOT ;
  wire \frame_delay_cnt_7_1_0/FROM ;
  wire \N8954/GROM ;
  wire \N8954/FROM ;
  wire \N8728/GROM ;
  wire \N8728/FROM ;
  wire \_n0028/GROM ;
  wire \_n0028/FROM ;
  wire \_n0039/GROM ;
  wire \_n0039/FROM ;
  wire \_n0029/GROM ;
  wire \_n0029/FROM ;
  wire \_n0042/GROM ;
  wire \_n0042/FROM ;
  wire \_n0027/GROM ;
  wire \_n0027/FROM ;
  wire \_n0044/GROM ;
  wire \_n0044/FROM ;
  wire \_n0045/GROM ;
  wire \_COND_1<2>/GROM ;
  wire \_COND_1<2>/FROM ;
  wire \_n0230/GROM ;
  wire \_n0231/GROM ;
  wire \_n0232/GROM ;
  wire \_n0225/GROM ;
  wire \_n0233/GROM ;
  wire \_n0227/GROM ;
  wire \_n0228/GROM ;
  wire \_n0229/GROM ;
  wire \div_reg/BYMUXNOT ;
  wire \div_reg/SRMUX_OUTPUTNOT ;
  wire \rx_shift_reg_0<1>/CKMUXNOT ;
  wire \rx_shift_reg_0<3>/CKMUXNOT ;
  wire \rx_shift_reg_0<5>/CKMUXNOT ;
  wire \rx_shift_reg_1<1>/CKMUXNOT ;
  wire \rx_shift_reg_1<3>/CKMUXNOT ;
  wire \rx_shift_reg_0<6>/CKMUXNOT ;
  wire \rx_shift_reg_1<5>/CKMUXNOT ;
  wire \rx_shift_reg_2<1>/CKMUXNOT ;
  wire \rx_shift_reg_1<6>/CKMUXNOT ;
  wire \rx_shift_reg_2<3>/CKMUXNOT ;
  wire \rx_shift_reg_2<5>/CKMUXNOT ;
  wire \rx_shift_reg_3<1>/CKMUXNOT ;
  wire \rx_shift_reg_2<6>/CKMUXNOT ;
  wire \rx_shift_reg_3<3>/CKMUXNOT ;
  wire \rx_shift_reg_3<3>/FFY/RST ;
  wire \rx_shift_reg_3<3>/FFX/RST ;
  wire \rx_shift_reg_3<5>/CKMUXNOT ;
  wire \rx_shift_reg_4<1>/CKMUXNOT ;
  wire \rx_shift_reg_3<6>/CKMUXNOT ;
  wire \rx_shift_reg_3<6>/FFY/RST ;
  wire \rx_shift_reg_4<3>/CKMUXNOT ;
  wire \rx_shift_reg_4<5>/CKMUXNOT ;
  wire \rx_shift_reg_4<5>/FFX/RST ;
  wire \rx_shift_reg_4<5>/FFY/RST ;
  wire \rx_shift_reg_5<1>/CKMUXNOT ;
  wire \rx_shift_reg_4<6>/CKMUXNOT ;
  wire \rx_shift_reg_5<3>/CKMUXNOT ;
  wire \rx_shift_reg_5<5>/CKMUXNOT ;
  wire \rx_shift_reg_6<1>/CKMUXNOT ;
  wire \rx_shift_reg_5<6>/CKMUXNOT ;
  wire \rx_shift_reg_6<3>/CKMUXNOT ;
  wire \rx_shift_reg_7<1>/CKMUXNOT ;
  wire \rx_shift_reg_6<5>/CKMUXNOT ;
  wire \rx_shift_reg_6<6>/CKMUXNOT ;
  wire \rx_shift_reg_7<3>/CKMUXNOT ;
  wire \rx_shift_reg_7<5>/CKMUXNOT ;
  wire \rx_shift_reg_7<6>/CKMUXNOT ;
  wire \ram_en/GROM ;
  wire \ram_en/FROM ;
  wire \mpi_data_out_5_OBUFT/GROM ;
  wire \mpi_data_out_5_OBUFT/FROM ;
  wire \_n0019<0>/GROM ;
  wire \_n0019<0>/FROM ;
  wire \_n0022<0>/GROM ;
  wire \_n0022<0>/FROM ;
  wire \_n0024<0>/GROM ;
  wire \_n0024<0>/FROM ;
  wire \_n0026<0>/GROM ;
  wire \_n0026<0>/FROM ;
  wire \mpi_data_out_4_OBUFT/GROM ;
  wire \mpi_data_out_4_OBUFT/FROM ;
  wire \div_reg_2/BYMUXNOT ;
  wire \div_reg_2/SRMUX_OUTPUTNOT ;
  wire \div_reg_2/BXMUXNOT ;
  wire \frame_delay_cnt_0_0_1__n0000/GROM ;
  wire \frame_delay_cnt_0_0_1__n0000/FROM ;
  wire \frame_delay_cnt_1_0_1__n0000/GROM ;
  wire \frame_delay_cnt_1_0_1__n0000/FROM ;
  wire \d_mem_addr<0>/GROM ;
  wire \frame_delay_cnt_2_0_1__n0000/GROM ;
  wire \frame_delay_cnt_2_0_1__n0000/FROM ;
  wire \rx_buf_reg_2<5>/FFY/RST ;
  wire \rx_buf_reg_2<5>/FFX/RST ;
  wire \rx_buf_reg_3<3>/FFY/RST ;
  wire \rx_buf_reg_3<3>/FFX/RST ;
  wire \rx_buf_reg_3<7>/FFX/RST ;
  wire \rx_buf_reg_4<5>/FFX/RST ;
  wire \frame_delay_cnt_3_0_1__n0000/GROM ;
  wire \frame_delay_cnt_3_0_1__n0000/FROM ;
  wire \frame_delay_cnt_4_0_1__n0000/GROM ;
  wire \frame_delay_cnt_4_0_1__n0000/FROM ;
  wire \frame_delay_cnt_5_0_1__n0000/GROM ;
  wire \frame_delay_cnt_5_0_1__n0000/FROM ;
  wire \frame_delay_cnt_6_0_1__n0000/GROM ;
  wire \frame_delay_cnt_6_0_1__n0000/FROM ;
  wire \frame_delay_cnt_7_0_1__n0000/GROM ;
  wire \frame_delay_cnt_7_0_1__n0000/FROM ;
  wire \mpi_data_out_3_OBUFT/GROM ;
  wire \mpi_data_out_3_OBUFT/FROM ;
  wire \frame_cnt_1_1/CKMUXNOT ;
  wire \frame_cnt_1_1/SRMUX_OUTPUTNOT ;
  wire \frame_cnt_1_1/FROM ;
  wire \frame_delay_cnt_1_0_1__n0001/GROM ;
  wire \frame_delay_cnt_1_0_1__n0001/FROM ;
  wire \tx_buf_reg_2<7>/FFY/RST ;
  wire \tx_buf_reg_3<5>/FFY/RST ;
  wire \frame_delay_cnt_3_0_1__n0001/GROM ;
  wire \frame_delay_cnt_3_0_1__n0001/FROM ;
  wire \frame_delay_cnt_5_0_1__n0001/GROM ;
  wire \frame_delay_cnt_5_0_1__n0001/FROM ;
  wire \frame_cnt<2>/FFY/RST ;
  wire \frame_delay_cnt_7_0_1__n0001/GROM ;
  wire \frame_delay_cnt_7_0_1__n0001/FROM ;
  wire \mpi_data_out_7_OBUFT/GROM ;
  wire \tx_shift_reg_1<6>/FFY/RST ;
  wire \tx_shift_reg_2<4>/FFX/RST ;
  wire \tx_shift_reg_2<7>/FFX/RST ;
  wire \tx_shift_reg_2<2>/FFY/RST ;
  wire \tx_shift_reg_2<2>/FFX/RST ;
  wire \tx_shift_reg_1<6>/FFX/RST ;
  wire \tx_shift_reg_3<6>/FFY/RST ;
  wire \tx_shift_reg_2<4>/FFY/RST ;
  wire \tx_shift_reg_2<7>/FFY/RST ;
  wire \tx_shift_reg_2<6>/FFY/RST ;
  wire \tx_shift_reg_2<6>/FFX/RST ;
  wire \tx_shift_reg_3<2>/FFY/RST ;
  wire \tx_shift_reg_3<2>/FFX/RST ;
  wire \tx_shift_reg_4<7>/FFY/RST ;
  wire \tx_shift_reg_5<2>/FFY/RST ;
  wire \tx_shift_reg_3<4>/FFX/RST ;
  wire \tx_shift_reg_3<4>/FFY/RST ;
  wire \tx_shift_reg_4<2>/FFY/RST ;
  wire \rx_buf_reg_3<7>/FFY/RST ;
  wire \tx_shift_reg_3<6>/FFX/RST ;
  wire \tx_shift_reg_4<6>/FFY/RST ;
  wire \tx_shift_reg_4<2>/FFX/RST ;
  wire \tx_shift_reg_4<4>/FFY/RST ;
  wire \tx_shift_reg_4<4>/FFX/RST ;
  wire \tx_shift_reg_5<6>/FFY/RST ;
  wire \tx_shift_reg_4<7>/FFX/RST ;
  wire \tx_shift_reg_4<6>/FFX/RST ;
  wire \tx_shift_reg_5<2>/FFX/RST ;
  wire \tx_shift_reg_7<2>/FFY/RST ;
  wire \tx_shift_reg_7<6>/FFY/RST ;
  wire \tx_shift_reg_5<4>/FFX/RST ;
  wire \tx_shift_reg_5<4>/FFY/RST ;
  wire \tx_shift_reg_6<2>/FFY/RST ;
  wire \tx_shift_reg_5<6>/FFX/RST ;
  wire \tx_shift_reg_6<7>/FFY/RST ;
  wire \tx_buf_reg_4<3>/FFX/RST ;
  wire \tx_shift_reg_6<2>/FFX/RST ;
  wire \tx_shift_reg_6<7>/FFX/RST ;
  wire \frame_delay_cnt_7_1_0/FFY/RST ;
  wire \frame_delay_cnt_7_1_0/FFY/SET ;
  wire \tx_shift_reg_7<6>/FFX/RST ;
  wire \tx_shift_reg_7<2>/FFX/RST ;
  wire \mem_page_sel/FFY/RST ;
  wire \tx_buf_reg_2<7>/FFX/RST ;
  wire \rx_shift_reg_4<6>/FFY/RST ;
  wire \ctrl_out_reg<1>/FFY/RST ;
  wire \rx_shift_reg_5<5>/FFX/RST ;
  wire \tx_shift_reg_7<7>/FFY/RST ;
  wire \ctrl_out_reg<0>/FFY/RST ;
  wire \frame_delay_cnt_0_0_0/FFY/RST ;
  wire \frame_delay_cnt_0_0_0/FFY/SET ;
  wire \frame_delay_cnt_0_1_0/FFY/RST ;
  wire \frame_delay_cnt_0_1_0/FFY/SET ;
  wire \frame_delay_cnt_1_0_0/FFY/RST ;
  wire \frame_delay_cnt_1_0_0/FFY/SET ;
  wire \rx_buf_reg_4<5>/FFY/RST ;
  wire \frame_delay_cnt_6_0_0/FFY/RST ;
  wire \frame_delay_cnt_6_0_0/FFY/SET ;
  wire \frame_delay_cnt_1_1_0/FFY/RST ;
  wire \frame_delay_cnt_1_1_0/FFY/SET ;
  wire \frame_delay_cnt_2_0_0/FFY/RST ;
  wire \frame_delay_cnt_2_0_0/FFY/SET ;
  wire \frame_delay_cnt_2_1_0/FFY/RST ;
  wire \frame_delay_cnt_2_1_0/FFY/SET ;
  wire \frame_delay_cnt_3_0_0/FFY/RST ;
  wire \frame_delay_cnt_3_0_0/FFY/SET ;
  wire \frame_delay_cnt_3_1_0/FFY/RST ;
  wire \frame_delay_cnt_3_1_0/FFY/SET ;
  wire \frame_delay_cnt_4_0_0/FFY/RST ;
  wire \frame_delay_cnt_4_0_0/FFY/SET ;
  wire \frame_delay_cnt_4_1_0/FFY/RST ;
  wire \frame_delay_cnt_4_1_0/FFY/SET ;
  wire \rx_shift_reg_3<5>/FFX/RST ;
  wire \rx_shift_reg_5<5>/FFY/RST ;
  wire \frame_delay_cnt_5_0_0/FFY/RST ;
  wire \frame_delay_cnt_5_0_0/FFY/SET ;
  wire \tx_buf_reg_3<5>/FFX/RST ;
  wire \rx_shift_reg_3<5>/FFY/RST ;
  wire \frame_delay_cnt_7_0_0/FFY/RST ;
  wire \frame_delay_cnt_7_0_0/FFY/SET ;
  wire \rx_shift_reg_4<3>/FFY/RST ;
  wire \rx_shift_reg_0<1>/FFX/RST ;
  wire \rx_shift_reg_5<1>/FFY/RST ;
  wire \rx_shift_reg_1<5>/FFX/RST ;
  wire \div_reg/FFY/RST ;
  wire \rx_shift_reg_0<1>/FFY/RST ;
  wire \rx_shift_reg_1<1>/FFX/RST ;
  wire \rx_shift_reg_2<3>/FFX/RST ;
  wire \rx_shift_reg_2<3>/FFY/RST ;
  wire \rx_shift_reg_0<5>/FFX/RST ;
  wire \rx_shift_reg_1<3>/FFX/RST ;
  wire \rx_shift_reg_0<3>/FFY/RST ;
  wire \rx_shift_reg_0<3>/FFX/RST ;
  wire \rx_shift_reg_0<5>/FFY/RST ;
  wire \rx_shift_reg_2<1>/FFY/RST ;
  wire \rx_shift_reg_4<3>/FFX/RST ;
  wire \rx_buf_reg_5<3>/FFY/RST ;
  wire \rx_shift_reg_1<1>/FFY/RST ;
  wire \rx_shift_reg_1<5>/FFY/RST ;
  wire \rx_shift_reg_2<1>/FFX/RST ;
  wire \rx_shift_reg_0<6>/FFY/RST ;
  wire \rx_shift_reg_1<3>/FFY/RST ;
  wire \rx_shift_reg_6<1>/FFY/RST ;
  wire \rx_shift_reg_4<1>/FFY/RST ;
  wire \rx_shift_reg_1<6>/FFY/RST ;
  wire \rx_shift_reg_4<1>/FFX/RST ;
  wire \rx_shift_reg_2<5>/FFX/RST ;
  wire \rx_shift_reg_6<1>/FFX/RST ;
  wire \rx_shift_reg_3<1>/FFX/RST ;
  wire \rx_shift_reg_2<5>/FFY/RST ;
  wire \rx_shift_reg_3<1>/FFY/RST ;
  wire \rx_shift_reg_2<6>/FFY/RST ;
  wire \rx_buf_reg_5<3>/FFX/RST ;
  wire \tx_buf_reg_4<3>/FFY/RST ;
  wire \rx_shift_reg_5<3>/FFY/RST ;
  wire \rx_shift_reg_5<3>/FFX/RST ;
  wire \rx_shift_reg_5<1>/FFX/RST ;
  wire \rx_shift_reg_7<1>/FFX/RST ;
  wire \rx_shift_reg_5<6>/FFY/RST ;
  wire \rx_shift_reg_6<3>/FFX/RST ;
  wire \rx_shift_reg_7<3>/FFX/RST ;
  wire \rx_shift_reg_7<5>/FFY/RST ;
  wire \rx_shift_reg_6<3>/FFY/RST ;
  wire \rx_shift_reg_6<5>/FFX/RST ;
  wire \rx_shift_reg_7<3>/FFY/RST ;
  wire \rx_shift_reg_7<1>/FFY/RST ;
  wire \rx_shift_reg_7<5>/FFX/RST ;
  wire \rx_shift_reg_6<6>/FFY/RST ;
  wire \rx_shift_reg_6<5>/FFY/RST ;
  wire \rx_buf_reg_1<5>/FFY/RST ;
  wire \div_reg_2/FFY/RST ;
  wire \div_reg_2/FFX/RST ;
  wire \rx_shift_reg_7<6>/FFY/RST ;
  wire \tx_buf_reg_5<7>/FFX/RST ;
  wire \rx_buf_reg_0<3>/FFY/RST ;
  wire \rx_buf_reg_1<3>/FFX/RST ;
  wire \rx_buf_reg_2<3>/FFY/RST ;
  wire \rx_buf_reg_2<3>/FFX/RST ;
  wire \rx_buf_reg_0<5>/FFY/RST ;
  wire \rx_buf_reg_5<5>/FFY/RST ;
  wire \rx_buf_reg_1<7>/FFX/RST ;
  wire \rx_buf_reg_4<7>/FFX/RST ;
  wire \rx_buf_reg_1<7>/FFY/RST ;
  wire \rx_buf_reg_4<7>/FFY/RST ;
  wire \rx_buf_reg_1<5>/FFX/RST ;
  wire \rx_buf_reg_0<3>/FFX/RST ;
  wire \tx_buf_reg_5<5>/FFX/RST ;
  wire \rx_buf_reg_0<5>/FFX/RST ;
  wire \rx_buf_reg_0<7>/FFX/RST ;
  wire \rx_buf_reg_0<7>/FFY/RST ;
  wire \rx_buf_reg_3<5>/FFX/RST ;
  wire \rx_buf_reg_1<3>/FFY/RST ;
  wire \rx_buf_reg_2<7>/FFY/RST ;
  wire \tx_buf_reg_4<7>/FFX/RST ;
  wire \tx_buf_reg_5<7>/FFY/RST ;
  wire \rx_buf_reg_2<7>/FFX/RST ;
  wire \rx_buf_reg_3<5>/FFY/RST ;
  wire \tx_buf_reg_5<5>/FFY/RST ;
  wire \rx_buf_reg_4<3>/FFY/RST ;
  wire \rx_buf_reg_4<3>/FFX/RST ;
  wire \tx_buf_reg_4<7>/FFY/RST ;
  wire \rx_buf_reg_5<5>/FFX/RST ;
  wire \rx_buf_reg_7<7>/FFX/RST ;
  wire \tx_buf_reg_1<7>/FFX/RST ;
  wire \rx_buf_reg_5<7>/FFY/RST ;
  wire \frame_cnt_1_1/FFY/RST ;
  wire \rx_buf_reg_5<7>/FFX/RST ;
  wire \rx_buf_reg_6<3>/FFX/RST ;
  wire \rx_buf_reg_6<7>/FFY/RST ;
  wire \rx_buf_reg_7<3>/FFX/RST ;
  wire \rx_buf_reg_6<3>/FFY/RST ;
  wire \rx_buf_reg_6<5>/FFX/RST ;
  wire \tx_buf_reg_0<5>/FFY/RST ;
  wire \rx_buf_reg_7<3>/FFY/RST ;
  wire \rx_buf_reg_7<7>/FFY/RST ;
  wire \rx_buf_reg_7<5>/FFY/RST ;
  wire \rx_buf_reg_7<5>/FFX/RST ;
  wire \rx_buf_reg_6<5>/FFY/RST ;
  wire \rx_buf_reg_6<6>/FFY/RST ;
  wire \tx_buf_reg_0<1>/FFY/RST ;
  wire \tx_buf_reg_4<5>/FFY/RST ;
  wire \tx_buf_reg_5<3>/FFX/RST ;
  wire \tx_buf_reg_0<5>/FFX/RST ;
  wire \tx_buf_reg_1<5>/FFX/RST ;
  wire \tx_buf_reg_0<3>/FFY/RST ;
  wire \tx_buf_reg_0<1>/FFX/RST ;
  wire \tx_buf_reg_6<1>/FFY/RST ;
  wire \tx_buf_reg_0<3>/FFX/RST ;
  wire \tx_buf_reg_1<3>/FFX/RST ;
  wire \tx_buf_reg_1<1>/FFX/RST ;
  wire \tx_buf_reg_2<5>/FFX/RST ;
  wire \tx_buf_reg_2<1>/FFY/RST ;
  wire \tx_buf_reg_0<7>/FFX/RST ;
  wire \tx_buf_reg_1<1>/FFY/RST ;
  wire \tx_buf_reg_1<3>/FFY/RST ;
  wire \tx_buf_reg_0<7>/FFY/RST ;
  wire \tx_buf_reg_6<1>/FFX/RST ;
  wire \tx_buf_reg_2<1>/FFX/RST ;
  wire \tx_buf_reg_1<5>/FFY/RST ;
  wire \tx_buf_reg_2<3>/FFX/RST ;
  wire \tx_buf_reg_3<3>/FFY/RST ;
  wire \tx_buf_reg_3<1>/FFY/RST ;
  wire \tx_buf_reg_2<3>/FFY/RST ;
  wire \tx_buf_reg_1<7>/FFY/RST ;
  wire \tx_buf_reg_3<7>/FFX/RST ;
  wire \tx_buf_reg_3<1>/FFX/RST ;
  wire \tx_buf_reg_2<5>/FFY/RST ;
  wire \tx_buf_reg_4<5>/FFX/RST ;
  wire \tx_buf_reg_5<3>/FFY/RST ;
  wire \tx_buf_reg_3<7>/FFY/RST ;
  wire \tx_buf_reg_3<3>/FFX/RST ;
  wire \tx_buf_reg_6<5>/FFX/RST ;
  wire \tx_buf_reg_6<3>/FFY/RST ;
  wire \tx_buf_reg_6<3>/FFX/RST ;
  wire \tx_buf_reg_7<7>/FFY/RST ;
  wire \tx_buf_reg_7<3>/FFX/RST ;
  wire \tx_buf_reg_6<7>/FFX/RST ;
  wire \frame_delay_buf_4<1>/FFY/RST ;
  wire \tx_buf_reg_6<5>/FFY/RST ;
  wire \tx_buf_reg_7<1>/FFY/RST ;
  wire \tx_buf_reg_7<5>/FFX/RST ;
  wire \tx_buf_reg_7<1>/FFX/RST ;
  wire \frame_delay_buf_0<1>/FFY/RST ;
  wire \tx_buf_reg_7<3>/FFY/RST ;
  wire \tx_buf_reg_6<7>/FFY/RST ;
  wire \frame_delay_buf_1<1>/FFY/RST ;
  wire \frame_delay_buf_6<1>/FFY/RST ;
  wire \tx_buf_reg_7<7>/FFX/RST ;
  wire \tx_buf_reg_7<5>/FFY/RST ;
  wire \frame_delay_buf_4<1>/FFX/RST ;
  wire \frame_delay_buf_3<1>/FFY/RST ;
  wire \frame_delay_buf_0<1>/FFX/RST ;
  wire \frame_delay_buf_2<1>/FFX/RST ;
  wire \frame_delay_buf_2<1>/FFY/RST ;
  wire \frame_delay_buf_1<1>/FFX/RST ;
  wire \frame_delay_buf_3<1>/FFX/RST ;
  wire \frame_delay_buf_5<1>/FFX/RST ;
  wire \frame_delay_buf_5<1>/FFY/RST ;
  wire \frame_delay_buf_6<1>/FFX/RST ;
  wire \clk_in_BUFGP/BUFG/CE ;
  wire \mpi_clk_BUFGP/BUFG/CE ;
  wire \PWR_VCC_0/GROM ;
  wire \PWR_VCC_0/FROM ;
  wire \PWR_VCC_1/FROM ;
  wire \PWR_VCC_2/FROM ;
  wire \PWR_GND_0/GROM ;
  wire \PWR_GND_1/GROM ;
  wire \PWR_GND_2/GROM ;
  wire \PWR_GND_3/GROM ;
  wire \PWR_GND_4/GROM ;
  wire GND;
  wire VCC;
  wire [1 : 0] frame_delay_buf_7;
  wire [7 : 0] rx_shift_reg_0;
  wire [7 : 0] rx_shift_reg_1;
  wire [7 : 0] rx_shift_reg_2;
  wire [7 : 0] rx_shift_reg_3;
  wire [7 : 0] rx_shift_reg_4;
  wire [7 : 0] rx_shift_reg_5;
  wire [7 : 0] rx_shift_reg_6;
  wire [7 : 0] rx_shift_reg_7;
  wire [8 : 0] frame_cnt;
  wire [4 : 0] c_mem_addr_cnt;
  wire [7 : 0] cd_data;
  wire [8 : 0] mpi_mem_bus_out;
  wire [8 : 8] cd_mem_addr;
  wire [4 : 0] d_mem_addr_cnt;
  wire [2 : 2] _COND_1;
  wire [0 : 0] d_mem_addr;
  wire [15 : 0] data_in_bus;
  wire [7 : 0] data_out_bus;
  wire [7 : 0] rx_buf_reg_1;
  wire [7 : 0] rx_buf_reg_5;
  wire [7 : 0] rx_buf_reg_3;
  wire [7 : 0] rx_buf_reg_7;
  wire [7 : 0] rx_buf_reg_0;
  wire [7 : 0] rx_buf_reg_4;
  wire [7 : 0] rx_buf_reg_2;
  wire [7 : 0] rx_buf_reg_6;
  wire [1 : 0] frame_delay_buf_2;
  wire [1 : 0] frame_delay_buf_3;
  wire [1 : 0] frame_delay_buf_0;
  wire [1 : 0] frame_delay_buf_1;
  wire [1 : 0] frame_delay_buf_6;
  wire [1 : 0] frame_delay_buf_4;
  wire [1 : 0] frame_delay_buf_5;
  wire [3 : 2] _n0246;
  wire [8 : 1] frame_cnt__n0000;
  wire [7 : 0] tx_buf_reg_4;
  wire [7 : 0] tx_buf_reg_5;
  wire [7 : 0] tx_shift_reg_0;
  wire [7 : 0] tx_buf_reg_0;
  wire [7 : 0] tx_shift_reg_1;
  wire [7 : 0] tx_buf_reg_1;
  wire [7 : 0] tx_shift_reg_2;
  wire [7 : 0] tx_buf_reg_2;
  wire [7 : 0] tx_shift_reg_3;
  wire [7 : 0] tx_buf_reg_3;
  wire [7 : 0] tx_shift_reg_4;
  wire [7 : 0] tx_shift_reg_5;
  wire [7 : 0] tx_shift_reg_6;
  wire [7 : 0] tx_buf_reg_6;
  wire [7 : 0] tx_shift_reg_7;
  wire [7 : 0] tx_buf_reg_7;
  wire [1 : 0] ctrl_out_reg;
  wire [4 : 1] d_mem_addr_cnt__n0000;
  wire [4 : 1] c_mem_addr_cnt__n0000;
  wire [7 : 1] _n0019;
  wire [7 : 1] _n0020;
  wire [7 : 1] _n0021;
  wire [7 : 1] _n0022;
  wire [7 : 1] _n0023;
  wire [7 : 1] _n0024;
  wire [7 : 1] _n0025;
  wire [7 : 1] _n0026;
  wire [1 : 0] _n0046;
  wire [1 : 0] frame_delay_cnt_0__n0001;
  wire [1 : 0] frame_delay_cnt_1__n0001;
  wire [1 : 0] frame_delay_cnt_2__n0001;
  wire [1 : 0] frame_delay_cnt_3__n0001;
  wire [1 : 0] frame_delay_cnt_4__n0001;
  wire [1 : 0] frame_delay_cnt_5__n0001;
  wire [1 : 0] frame_delay_cnt_6__n0001;
  wire [1 : 0] frame_delay_cnt_7__n0001;
  assign
    GTS_0 = GTS;
  initial $sdf_annotate("tdm_switch_top_timesim.sdf");
  X_BUF mpi_addr_1_IBUF_1 (
    .I(mpi_addr[1]),
    .O(mpi_addr_1_IBUF)
  );
  X_IPAD \mpi_addr<1>/PAD  (
    .PAD(mpi_addr[1])
  );
  X_BUF mpi_addr_0_IBUF_2 (
    .I(mpi_addr[0]),
    .O(mpi_addr_0_IBUF)
  );
  X_IPAD \mpi_addr<0>/PAD  (
    .PAD(mpi_addr[0])
  );
  X_BUF mpi_data_in_8_IBUF_3 (
    .I(mpi_data_in[8]),
    .O(mpi_data_in_8_IBUF)
  );
  X_IPAD \mpi_data_in<8>/PAD  (
    .PAD(mpi_data_in[8])
  );
  X_BUF mpi_data_in_7_IBUF_4 (
    .I(mpi_data_in[7]),
    .O(mpi_data_in_7_IBUF)
  );
  X_IPAD \mpi_data_in<7>/PAD  (
    .PAD(mpi_data_in[7])
  );
  X_BUF mpi_data_in_6_IBUF_5 (
    .I(mpi_data_in[6]),
    .O(mpi_data_in_6_IBUF)
  );
  X_IPAD \mpi_data_in<6>/PAD  (
    .PAD(mpi_data_in[6])
  );
  X_BUF mpi_data_in_5_IBUF_6 (
    .I(mpi_data_in[5]),
    .O(mpi_data_in_5_IBUF)
  );
  X_IPAD \mpi_data_in<5>/PAD  (
    .PAD(mpi_data_in[5])
  );
  X_BUF mpi_data_in_4_IBUF_7 (
    .I(mpi_data_in[4]),
    .O(mpi_data_in_4_IBUF)
  );
  X_IPAD \mpi_data_in<4>/PAD  (
    .PAD(mpi_data_in[4])
  );
  X_BUF mpi_data_in_3_IBUF_8 (
    .I(mpi_data_in[3]),
    .O(mpi_data_in_3_IBUF)
  );
  X_IPAD \mpi_data_in<3>/PAD  (
    .PAD(mpi_data_in[3])
  );
  X_BUF mpi_data_in_2_IBUF_9 (
    .I(mpi_data_in[2]),
    .O(mpi_data_in_2_IBUF)
  );
  X_IPAD \mpi_data_in<2>/PAD  (
    .PAD(mpi_data_in[2])
  );
  X_BUF \mpi_data_in<1>/DELAY  (
    .I(\mpi_data_in<1>/IBUF ),
    .O(\mpi_data_in<1>/IDELAY )
  );
  X_BUF mpi_data_in_1_IBUF_10 (
    .I(mpi_data_in[1]),
    .O(\mpi_data_in<1>/IBUF )
  );
  X_BUF \mpi_data_in<1>/IMUX  (
    .I(\mpi_data_in<1>/IBUF ),
    .O(mpi_data_in_1_IBUF)
  );
  X_IPAD \mpi_data_in<1>/PAD  (
    .PAD(mpi_data_in[1])
  );
  X_BUF \mpi_data_in<0>/DELAY  (
    .I(\mpi_data_in<0>/IBUF ),
    .O(\mpi_data_in<0>/IDELAY )
  );
  X_BUF mpi_data_in_0_IBUF_11 (
    .I(mpi_data_in[0]),
    .O(\mpi_data_in<0>/IBUF )
  );
  X_BUF \mpi_data_in<0>/IMUX  (
    .I(\mpi_data_in<0>/IBUF ),
    .O(mpi_data_in_0_IBUF)
  );
  X_IPAD \mpi_data_in<0>/PAD  (
    .PAD(mpi_data_in[0])
  );
  X_BUF \frame_sync/OUTMUX_12  (
    .I(frame_sync_OBUF),
    .O(\frame_sync/OUTMUX )
  );
  X_BUF \frame_sync/GTS_OR  (
    .I(GTS_0),
    .O(\frame_sync/TORGTS )
  );
  X_INV \frame_sync/ENABLEINV  (
    .I(\frame_sync/TORGTS ),
    .O(\frame_sync/ENABLE )
  );
  X_TRI frame_sync_OBUF_13 (
    .I(\frame_sync/OUTMUX ),
    .CTL(\frame_sync/ENABLE ),
    .O(frame_sync)
  );
  X_OPAD \frame_sync/PAD  (
    .PAD(frame_sync)
  );
  X_BUF \mpi_data_in<1>/IFF/RSTOR  (
    .I(GSR),
    .O(\mpi_data_in<1>/IFF/RST )
  );
  X_FF frame_delay_buf_7_1 (
    .I(\mpi_data_in<1>/IDELAY ),
    .CE(_n0045),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\mpi_data_in<1>/IFF/RST ),
    .O(frame_delay_buf_7[1])
  );
  X_BUF \mpi_data_in<0>/IFF/RSTOR  (
    .I(GSR),
    .O(\mpi_data_in<0>/IFF/RST )
  );
  X_FF frame_delay_buf_7_0 (
    .I(\mpi_data_in<0>/IDELAY ),
    .CE(_n0045),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\mpi_data_in<0>/IFF/RST ),
    .O(frame_delay_buf_7[0])
  );
  X_BUF mpi_addr_2_IBUF_14 (
    .I(mpi_addr[2]),
    .O(mpi_addr_2_IBUF)
  );
  X_IPAD \mpi_addr<2>/PAD  (
    .PAD(mpi_addr[2])
  );
  X_BUF mpi_addr_3_IBUF_15 (
    .I(mpi_addr[3]),
    .O(mpi_addr_3_IBUF)
  );
  X_IPAD \mpi_addr<3>/PAD  (
    .PAD(mpi_addr[3])
  );
  X_BUF mpi_addr_4_IBUF_16 (
    .I(mpi_addr[4]),
    .O(mpi_addr_4_IBUF)
  );
  X_IPAD \mpi_addr<4>/PAD  (
    .PAD(mpi_addr[4])
  );
  X_BUF mpi_addr_5_IBUF_17 (
    .I(mpi_addr[5]),
    .O(mpi_addr_5_IBUF)
  );
  X_IPAD \mpi_addr<5>/PAD  (
    .PAD(mpi_addr[5])
  );
  X_BUF mpi_addr_6_IBUF_18 (
    .I(mpi_addr[6]),
    .O(mpi_addr_6_IBUF)
  );
  X_IPAD \mpi_addr<6>/PAD  (
    .PAD(mpi_addr[6])
  );
  X_BUF mpi_addr_7_IBUF_19 (
    .I(mpi_addr[7]),
    .O(mpi_addr_7_IBUF)
  );
  X_IPAD \mpi_addr<7>/PAD  (
    .PAD(mpi_addr[7])
  );
  X_BUF mpi_addr_8_IBUF_20 (
    .I(mpi_addr[8]),
    .O(mpi_addr_8_IBUF)
  );
  X_IPAD \mpi_addr<8>/PAD  (
    .PAD(mpi_addr[8])
  );
  X_BUF reset_IBUF_21 (
    .I(reset),
    .O(reset_IBUF)
  );
  X_IPAD \reset/PAD  (
    .PAD(reset)
  );
  X_INV \mpi_data_out<0>/TRIMUX  (
    .I(mpi_cs_IBUF),
    .O(\mpi_data_out<0>/TDATANOT )
  );
  X_BUF \mpi_data_out<0>/OUTMUX_22  (
    .I(\ctrl_out_reg<0>/FROM ),
    .O(\mpi_data_out<0>/OUTMUX )
  );
  X_OR2 \mpi_data_out<0>/GTS_OR  (
    .I0(GTS_0),
    .I1(\mpi_data_out<0>/TDATANOT ),
    .O(\mpi_data_out<0>/TORGTS )
  );
  X_INV \mpi_data_out<0>/ENABLEINV  (
    .I(\mpi_data_out<0>/TORGTS ),
    .O(\mpi_data_out<0>/ENABLE )
  );
  X_TRI mpi_data_out_0_OBUFT (
    .I(\mpi_data_out<0>/OUTMUX ),
    .CTL(\mpi_data_out<0>/ENABLE ),
    .O(mpi_data_out[0])
  );
  X_OPAD \mpi_data_out<0>/PAD  (
    .PAD(mpi_data_out[0])
  );
  X_INV \mpi_data_out<1>/TRIMUX  (
    .I(mpi_cs_IBUF),
    .O(\mpi_data_out<1>/TDATANOT )
  );
  X_BUF \mpi_data_out<1>/OUTMUX_23  (
    .I(\mpi_data_out_4_OBUFT/GROM ),
    .O(\mpi_data_out<1>/OUTMUX )
  );
  X_OR2 \mpi_data_out<1>/GTS_OR  (
    .I0(GTS_0),
    .I1(\mpi_data_out<1>/TDATANOT ),
    .O(\mpi_data_out<1>/TORGTS )
  );
  X_INV \mpi_data_out<1>/ENABLEINV  (
    .I(\mpi_data_out<1>/TORGTS ),
    .O(\mpi_data_out<1>/ENABLE )
  );
  X_TRI mpi_data_out_1_OBUFT (
    .I(\mpi_data_out<1>/OUTMUX ),
    .CTL(\mpi_data_out<1>/ENABLE ),
    .O(mpi_data_out[1])
  );
  X_OPAD \mpi_data_out<1>/PAD  (
    .PAD(mpi_data_out[1])
  );
  X_INV \mpi_data_out<2>/TRIMUX  (
    .I(mpi_cs_IBUF),
    .O(\mpi_data_out<2>/TDATANOT )
  );
  X_BUF \mpi_data_out<2>/OUTMUX_24  (
    .I(\mpi_data_out_5_OBUFT/GROM ),
    .O(\mpi_data_out<2>/OUTMUX )
  );
  X_OR2 \mpi_data_out<2>/GTS_OR  (
    .I0(GTS_0),
    .I1(\mpi_data_out<2>/TDATANOT ),
    .O(\mpi_data_out<2>/TORGTS )
  );
  X_INV \mpi_data_out<2>/ENABLEINV  (
    .I(\mpi_data_out<2>/TORGTS ),
    .O(\mpi_data_out<2>/ENABLE )
  );
  X_TRI mpi_data_out_2_OBUFT (
    .I(\mpi_data_out<2>/OUTMUX ),
    .CTL(\mpi_data_out<2>/ENABLE ),
    .O(mpi_data_out[2])
  );
  X_OPAD \mpi_data_out<2>/PAD  (
    .PAD(mpi_data_out[2])
  );
  X_INV \mpi_data_out<3>/TRIMUX  (
    .I(mpi_cs_IBUF),
    .O(\mpi_data_out<3>/TDATANOT )
  );
  X_BUF \mpi_data_out<3>/OUTMUX_25  (
    .I(\mpi_data_out_3_OBUFT/FROM ),
    .O(\mpi_data_out<3>/OUTMUX )
  );
  X_OR2 \mpi_data_out<3>/GTS_OR  (
    .I0(GTS_0),
    .I1(\mpi_data_out<3>/TDATANOT ),
    .O(\mpi_data_out<3>/TORGTS )
  );
  X_INV \mpi_data_out<3>/ENABLEINV  (
    .I(\mpi_data_out<3>/TORGTS ),
    .O(\mpi_data_out<3>/ENABLE )
  );
  X_TRI mpi_data_out_3_OBUFT (
    .I(\mpi_data_out<3>/OUTMUX ),
    .CTL(\mpi_data_out<3>/ENABLE ),
    .O(mpi_data_out[3])
  );
  X_OPAD \mpi_data_out<3>/PAD  (
    .PAD(mpi_data_out[3])
  );
  X_INV \mpi_data_out<4>/TRIMUX  (
    .I(mpi_cs_IBUF),
    .O(\mpi_data_out<4>/TDATANOT )
  );
  X_BUF \mpi_data_out<4>/OUTMUX_26  (
    .I(\mpi_data_out_4_OBUFT/FROM ),
    .O(\mpi_data_out<4>/OUTMUX )
  );
  X_OR2 \mpi_data_out<4>/GTS_OR  (
    .I0(GTS_0),
    .I1(\mpi_data_out<4>/TDATANOT ),
    .O(\mpi_data_out<4>/TORGTS )
  );
  X_INV \mpi_data_out<4>/ENABLEINV  (
    .I(\mpi_data_out<4>/TORGTS ),
    .O(\mpi_data_out<4>/ENABLE )
  );
  X_TRI mpi_data_out_4_OBUFT (
    .I(\mpi_data_out<4>/OUTMUX ),
    .CTL(\mpi_data_out<4>/ENABLE ),
    .O(mpi_data_out[4])
  );
  X_OPAD \mpi_data_out<4>/PAD  (
    .PAD(mpi_data_out[4])
  );
  X_INV \mpi_data_out<5>/TRIMUX  (
    .I(mpi_cs_IBUF),
    .O(\mpi_data_out<5>/TDATANOT )
  );
  X_BUF \mpi_data_out<5>/OUTMUX_27  (
    .I(\mpi_data_out_5_OBUFT/FROM ),
    .O(\mpi_data_out<5>/OUTMUX )
  );
  X_OR2 \mpi_data_out<5>/GTS_OR  (
    .I0(GTS_0),
    .I1(\mpi_data_out<5>/TDATANOT ),
    .O(\mpi_data_out<5>/TORGTS )
  );
  X_INV \mpi_data_out<5>/ENABLEINV  (
    .I(\mpi_data_out<5>/TORGTS ),
    .O(\mpi_data_out<5>/ENABLE )
  );
  X_TRI mpi_data_out_5_OBUFT (
    .I(\mpi_data_out<5>/OUTMUX ),
    .CTL(\mpi_data_out<5>/ENABLE ),
    .O(mpi_data_out[5])
  );
  X_OPAD \mpi_data_out<5>/PAD  (
    .PAD(mpi_data_out[5])
  );
  X_INV \mpi_data_out<6>/TRIMUX  (
    .I(mpi_cs_IBUF),
    .O(\mpi_data_out<6>/TDATANOT )
  );
  X_BUF \mpi_data_out<6>/OUTMUX_28  (
    .I(\ram_en/GROM ),
    .O(\mpi_data_out<6>/OUTMUX )
  );
  X_OR2 \mpi_data_out<6>/GTS_OR  (
    .I0(GTS_0),
    .I1(\mpi_data_out<6>/TDATANOT ),
    .O(\mpi_data_out<6>/TORGTS )
  );
  X_INV \mpi_data_out<6>/ENABLEINV  (
    .I(\mpi_data_out<6>/TORGTS ),
    .O(\mpi_data_out<6>/ENABLE )
  );
  X_TRI mpi_data_out_6_OBUFT (
    .I(\mpi_data_out<6>/OUTMUX ),
    .CTL(\mpi_data_out<6>/ENABLE ),
    .O(mpi_data_out[6])
  );
  X_OPAD \mpi_data_out<6>/PAD  (
    .PAD(mpi_data_out[6])
  );
  X_INV \mpi_data_out<7>/TRIMUX  (
    .I(mpi_cs_IBUF),
    .O(\mpi_data_out<7>/TDATANOT )
  );
  X_BUF \mpi_data_out<7>/OUTMUX_29  (
    .I(\mpi_data_out_7_OBUFT/GROM ),
    .O(\mpi_data_out<7>/OUTMUX )
  );
  X_OR2 \mpi_data_out<7>/GTS_OR  (
    .I0(GTS_0),
    .I1(\mpi_data_out<7>/TDATANOT ),
    .O(\mpi_data_out<7>/TORGTS )
  );
  X_INV \mpi_data_out<7>/ENABLEINV  (
    .I(\mpi_data_out<7>/TORGTS ),
    .O(\mpi_data_out<7>/ENABLE )
  );
  X_TRI mpi_data_out_7_OBUFT (
    .I(\mpi_data_out<7>/OUTMUX ),
    .CTL(\mpi_data_out<7>/ENABLE ),
    .O(mpi_data_out[7])
  );
  X_OPAD \mpi_data_out<7>/PAD  (
    .PAD(mpi_data_out[7])
  );
  X_INV \mpi_data_out<8>/TRIMUX  (
    .I(mpi_cs_IBUF),
    .O(\mpi_data_out<8>/TDATANOT )
  );
  X_BUF \mpi_data_out<8>/OUTMUX_30  (
    .I(\mpi_data_out_3_OBUFT/GROM ),
    .O(\mpi_data_out<8>/OUTMUX )
  );
  X_OR2 \mpi_data_out<8>/GTS_OR  (
    .I0(GTS_0),
    .I1(\mpi_data_out<8>/TDATANOT ),
    .O(\mpi_data_out<8>/TORGTS )
  );
  X_INV \mpi_data_out<8>/ENABLEINV  (
    .I(\mpi_data_out<8>/TORGTS ),
    .O(\mpi_data_out<8>/ENABLE )
  );
  X_TRI mpi_data_out_8_OBUFT (
    .I(\mpi_data_out<8>/OUTMUX ),
    .CTL(\mpi_data_out<8>/ENABLE ),
    .O(mpi_data_out[8])
  );
  X_OPAD \mpi_data_out<8>/PAD  (
    .PAD(mpi_data_out[8])
  );
  X_BUF \rx_stream<0>/DELAY  (
    .I(rx_stream_0_IBUF),
    .O(\rx_stream<0>/IDELAY )
  );
  X_BUF rx_stream_0_IBUF_31 (
    .I(rx_stream[0]),
    .O(rx_stream_0_IBUF)
  );
  X_INV \rx_stream<0>/ICKINV  (
    .I(div_reg_2),
    .O(\rx_stream<0>/ICLKNOT )
  );
  X_IPAD \rx_stream<0>/PAD  (
    .PAD(rx_stream[0])
  );
  X_BUF \rx_stream<0>/IFF/RSTOR  (
    .I(GSR),
    .O(\rx_stream<0>/IFF/RST )
  );
  X_FF rx_shift_reg_0_7 (
    .I(\rx_stream<0>/IDELAY ),
    .CE(VCC),
    .CLK(\rx_stream<0>/ICLKNOT ),
    .SET(GND),
    .RST(\rx_stream<0>/IFF/RST ),
    .O(rx_shift_reg_0[7])
  );
  X_BUF \rx_stream<1>/DELAY  (
    .I(rx_stream_1_IBUF),
    .O(\rx_stream<1>/IDELAY )
  );
  X_BUF rx_stream_1_IBUF_32 (
    .I(rx_stream[1]),
    .O(rx_stream_1_IBUF)
  );
  X_INV \rx_stream<1>/ICKINV  (
    .I(div_reg_2),
    .O(\rx_stream<1>/ICLKNOT )
  );
  X_IPAD \rx_stream<1>/PAD  (
    .PAD(rx_stream[1])
  );
  X_BUF \rx_stream<1>/IFF/RSTOR  (
    .I(GSR),
    .O(\rx_stream<1>/IFF/RST )
  );
  X_FF rx_shift_reg_1_7 (
    .I(\rx_stream<1>/IDELAY ),
    .CE(VCC),
    .CLK(\rx_stream<1>/ICLKNOT ),
    .SET(GND),
    .RST(\rx_stream<1>/IFF/RST ),
    .O(rx_shift_reg_1[7])
  );
  X_BUF \rx_stream<2>/DELAY  (
    .I(rx_stream_2_IBUF),
    .O(\rx_stream<2>/IDELAY )
  );
  X_BUF rx_stream_2_IBUF_33 (
    .I(rx_stream[2]),
    .O(rx_stream_2_IBUF)
  );
  X_INV \rx_stream<2>/ICKINV  (
    .I(div_reg_2),
    .O(\rx_stream<2>/ICLKNOT )
  );
  X_IPAD \rx_stream<2>/PAD  (
    .PAD(rx_stream[2])
  );
  X_BUF \rx_stream<2>/IFF/RSTOR  (
    .I(GSR),
    .O(\rx_stream<2>/IFF/RST )
  );
  X_FF rx_shift_reg_2_7 (
    .I(\rx_stream<2>/IDELAY ),
    .CE(VCC),
    .CLK(\rx_stream<2>/ICLKNOT ),
    .SET(GND),
    .RST(\rx_stream<2>/IFF/RST ),
    .O(rx_shift_reg_2[7])
  );
  X_BUF \rx_stream<3>/DELAY  (
    .I(rx_stream_3_IBUF),
    .O(\rx_stream<3>/IDELAY )
  );
  X_BUF rx_stream_3_IBUF_34 (
    .I(rx_stream[3]),
    .O(rx_stream_3_IBUF)
  );
  X_INV \rx_stream<3>/ICKINV  (
    .I(div_reg_2),
    .O(\rx_stream<3>/ICLKNOT )
  );
  X_IPAD \rx_stream<3>/PAD  (
    .PAD(rx_stream[3])
  );
  X_BUF \rx_stream<3>/IFF/RSTOR  (
    .I(GSR),
    .O(\rx_stream<3>/IFF/RST )
  );
  X_FF rx_shift_reg_3_7 (
    .I(\rx_stream<3>/IDELAY ),
    .CE(VCC),
    .CLK(\rx_stream<3>/ICLKNOT ),
    .SET(GND),
    .RST(\rx_stream<3>/IFF/RST ),
    .O(rx_shift_reg_3[7])
  );
  X_BUF \rx_stream<4>/DELAY  (
    .I(rx_stream_4_IBUF),
    .O(\rx_stream<4>/IDELAY )
  );
  X_BUF rx_stream_4_IBUF_35 (
    .I(rx_stream[4]),
    .O(rx_stream_4_IBUF)
  );
  X_INV \rx_stream<4>/ICKINV  (
    .I(div_reg_2),
    .O(\rx_stream<4>/ICLKNOT )
  );
  X_IPAD \rx_stream<4>/PAD  (
    .PAD(rx_stream[4])
  );
  X_BUF \rx_stream<4>/IFF/RSTOR  (
    .I(GSR),
    .O(\rx_stream<4>/IFF/RST )
  );
  X_FF rx_shift_reg_4_7 (
    .I(\rx_stream<4>/IDELAY ),
    .CE(VCC),
    .CLK(\rx_stream<4>/ICLKNOT ),
    .SET(GND),
    .RST(\rx_stream<4>/IFF/RST ),
    .O(rx_shift_reg_4[7])
  );
  X_BUF \rx_stream<5>/DELAY  (
    .I(rx_stream_5_IBUF),
    .O(\rx_stream<5>/IDELAY )
  );
  X_BUF rx_stream_5_IBUF_36 (
    .I(rx_stream[5]),
    .O(rx_stream_5_IBUF)
  );
  X_INV \rx_stream<5>/ICKINV  (
    .I(div_reg_2),
    .O(\rx_stream<5>/ICLKNOT )
  );
  X_IPAD \rx_stream<5>/PAD  (
    .PAD(rx_stream[5])
  );
  X_BUF \rx_stream<5>/IFF/RSTOR  (
    .I(GSR),
    .O(\rx_stream<5>/IFF/RST )
  );
  X_FF rx_shift_reg_5_7 (
    .I(\rx_stream<5>/IDELAY ),
    .CE(VCC),
    .CLK(\rx_stream<5>/ICLKNOT ),
    .SET(GND),
    .RST(\rx_stream<5>/IFF/RST ),
    .O(rx_shift_reg_5[7])
  );
  X_BUF \rx_stream<6>/DELAY  (
    .I(rx_stream_6_IBUF),
    .O(\rx_stream<6>/IDELAY )
  );
  X_BUF rx_stream_6_IBUF_37 (
    .I(rx_stream[6]),
    .O(rx_stream_6_IBUF)
  );
  X_INV \rx_stream<6>/ICKINV  (
    .I(div_reg_2),
    .O(\rx_stream<6>/ICLKNOT )
  );
  X_IPAD \rx_stream<6>/PAD  (
    .PAD(rx_stream[6])
  );
  X_BUF \rx_stream<6>/IFF/RSTOR  (
    .I(GSR),
    .O(\rx_stream<6>/IFF/RST )
  );
  X_FF rx_shift_reg_6_7 (
    .I(\rx_stream<6>/IDELAY ),
    .CE(VCC),
    .CLK(\rx_stream<6>/ICLKNOT ),
    .SET(GND),
    .RST(\rx_stream<6>/IFF/RST ),
    .O(rx_shift_reg_6[7])
  );
  X_BUF \rx_stream<7>/DELAY  (
    .I(rx_stream_7_IBUF),
    .O(\rx_stream<7>/IDELAY )
  );
  X_BUF rx_stream_7_IBUF_38 (
    .I(rx_stream[7]),
    .O(rx_stream_7_IBUF)
  );
  X_INV \rx_stream<7>/ICKINV  (
    .I(div_reg_1),
    .O(\rx_stream<7>/ICLKNOT )
  );
  X_IPAD \rx_stream<7>/PAD  (
    .PAD(rx_stream[7])
  );
  X_BUF \rx_stream<7>/IFF/RSTOR  (
    .I(GSR),
    .O(\rx_stream<7>/IFF/RST )
  );
  X_FF rx_shift_reg_7_7 (
    .I(\rx_stream<7>/IDELAY ),
    .CE(VCC),
    .CLK(\rx_stream<7>/ICLKNOT ),
    .SET(GND),
    .RST(\rx_stream<7>/IFF/RST ),
    .O(rx_shift_reg_7[7])
  );
  X_BUF \tx_stream<0>/OMUX  (
    .I(\_n0019<0>/FROM ),
    .O(\tx_stream<0>/OD )
  );
  X_BUF \tx_stream<0>/OUTMUX_39  (
    .I(tx_shift_reg_0[0]),
    .O(\tx_stream<0>/OUTMUX )
  );
  X_BUF \tx_stream<0>/GTS_OR  (
    .I(GTS_0),
    .O(\tx_stream<0>/TORGTS )
  );
  X_INV \tx_stream<0>/ENABLEINV  (
    .I(\tx_stream<0>/TORGTS ),
    .O(\tx_stream<0>/ENABLE )
  );
  X_TRI tx_stream_0_OBUF (
    .I(\tx_stream<0>/OUTMUX ),
    .CTL(\tx_stream<0>/ENABLE ),
    .O(tx_stream[0])
  );
  X_OPAD \tx_stream<0>/PAD  (
    .PAD(tx_stream[0])
  );
  X_BUF \tx_stream<0>/OFF/RSTOR  (
    .I(GSR),
    .O(\tx_stream<0>/OFF/RST )
  );
  X_FF tx_shift_reg_0_0 (
    .I(\tx_stream<0>/OD ),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_stream<0>/OFF/RST ),
    .O(tx_shift_reg_0[0])
  );
  X_BUF \tx_stream<1>/OMUX  (
    .I(\_n0019<0>/GROM ),
    .O(\tx_stream<1>/OD )
  );
  X_BUF \tx_stream<1>/OUTMUX_40  (
    .I(tx_shift_reg_1[0]),
    .O(\tx_stream<1>/OUTMUX )
  );
  X_BUF \tx_stream<1>/GTS_OR  (
    .I(GTS_0),
    .O(\tx_stream<1>/TORGTS )
  );
  X_INV \tx_stream<1>/ENABLEINV  (
    .I(\tx_stream<1>/TORGTS ),
    .O(\tx_stream<1>/ENABLE )
  );
  X_TRI tx_stream_1_OBUF (
    .I(\tx_stream<1>/OUTMUX ),
    .CTL(\tx_stream<1>/ENABLE ),
    .O(tx_stream[1])
  );
  X_OPAD \tx_stream<1>/PAD  (
    .PAD(tx_stream[1])
  );
  X_BUF \tx_stream<1>/OFF/RSTOR  (
    .I(GSR),
    .O(\tx_stream<1>/OFF/RST )
  );
  X_FF tx_shift_reg_1_0 (
    .I(\tx_stream<1>/OD ),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_stream<1>/OFF/RST ),
    .O(tx_shift_reg_1[0])
  );
  X_BUF \tx_stream<2>/OMUX  (
    .I(\_n0022<0>/GROM ),
    .O(\tx_stream<2>/OD )
  );
  X_BUF \tx_stream<2>/OUTMUX_41  (
    .I(tx_shift_reg_2[0]),
    .O(\tx_stream<2>/OUTMUX )
  );
  X_BUF \tx_stream<2>/GTS_OR  (
    .I(GTS_0),
    .O(\tx_stream<2>/TORGTS )
  );
  X_INV \tx_stream<2>/ENABLEINV  (
    .I(\tx_stream<2>/TORGTS ),
    .O(\tx_stream<2>/ENABLE )
  );
  X_TRI tx_stream_2_OBUF (
    .I(\tx_stream<2>/OUTMUX ),
    .CTL(\tx_stream<2>/ENABLE ),
    .O(tx_stream[2])
  );
  X_OPAD \tx_stream<2>/PAD  (
    .PAD(tx_stream[2])
  );
  X_BUF \tx_stream<2>/OFF/RSTOR  (
    .I(GSR),
    .O(\tx_stream<2>/OFF/RST )
  );
  X_FF tx_shift_reg_2_0 (
    .I(\tx_stream<2>/OD ),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_stream<2>/OFF/RST ),
    .O(tx_shift_reg_2[0])
  );
  X_BUF \tx_stream<3>/OMUX  (
    .I(\_n0022<0>/FROM ),
    .O(\tx_stream<3>/OD )
  );
  X_BUF \tx_stream<3>/OUTMUX_42  (
    .I(tx_shift_reg_3[0]),
    .O(\tx_stream<3>/OUTMUX )
  );
  X_BUF \tx_stream<3>/GTS_OR  (
    .I(GTS_0),
    .O(\tx_stream<3>/TORGTS )
  );
  X_INV \tx_stream<3>/ENABLEINV  (
    .I(\tx_stream<3>/TORGTS ),
    .O(\tx_stream<3>/ENABLE )
  );
  X_TRI tx_stream_3_OBUF (
    .I(\tx_stream<3>/OUTMUX ),
    .CTL(\tx_stream<3>/ENABLE ),
    .O(tx_stream[3])
  );
  X_OPAD \tx_stream<3>/PAD  (
    .PAD(tx_stream[3])
  );
  X_BUF \tx_stream<3>/OFF/RSTOR  (
    .I(GSR),
    .O(\tx_stream<3>/OFF/RST )
  );
  X_FF tx_shift_reg_3_0 (
    .I(\tx_stream<3>/OD ),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_stream<3>/OFF/RST ),
    .O(tx_shift_reg_3[0])
  );
  X_BUF \tx_stream<4>/OMUX  (
    .I(\_n0024<0>/GROM ),
    .O(\tx_stream<4>/OD )
  );
  X_BUF \tx_stream<4>/OUTMUX_43  (
    .I(tx_shift_reg_4[0]),
    .O(\tx_stream<4>/OUTMUX )
  );
  X_BUF \tx_stream<4>/GTS_OR  (
    .I(GTS_0),
    .O(\tx_stream<4>/TORGTS )
  );
  X_INV \tx_stream<4>/ENABLEINV  (
    .I(\tx_stream<4>/TORGTS ),
    .O(\tx_stream<4>/ENABLE )
  );
  X_TRI tx_stream_4_OBUF (
    .I(\tx_stream<4>/OUTMUX ),
    .CTL(\tx_stream<4>/ENABLE ),
    .O(tx_stream[4])
  );
  X_OPAD \tx_stream<4>/PAD  (
    .PAD(tx_stream[4])
  );
  X_BUF \tx_stream<4>/OFF/RSTOR  (
    .I(GSR),
    .O(\tx_stream<4>/OFF/RST )
  );
  X_FF tx_shift_reg_4_0 (
    .I(\tx_stream<4>/OD ),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_stream<4>/OFF/RST ),
    .O(tx_shift_reg_4[0])
  );
  X_BUF \tx_stream<5>/OMUX  (
    .I(\_n0024<0>/FROM ),
    .O(\tx_stream<5>/OD )
  );
  X_BUF \tx_stream<5>/OUTMUX_44  (
    .I(tx_shift_reg_5[0]),
    .O(\tx_stream<5>/OUTMUX )
  );
  X_BUF \tx_stream<5>/GTS_OR  (
    .I(GTS_0),
    .O(\tx_stream<5>/TORGTS )
  );
  X_INV \tx_stream<5>/ENABLEINV  (
    .I(\tx_stream<5>/TORGTS ),
    .O(\tx_stream<5>/ENABLE )
  );
  X_TRI tx_stream_5_OBUF (
    .I(\tx_stream<5>/OUTMUX ),
    .CTL(\tx_stream<5>/ENABLE ),
    .O(tx_stream[5])
  );
  X_OPAD \tx_stream<5>/PAD  (
    .PAD(tx_stream[5])
  );
  X_BUF \tx_stream<5>/OFF/RSTOR  (
    .I(GSR),
    .O(\tx_stream<5>/OFF/RST )
  );
  X_FF tx_shift_reg_5_0 (
    .I(\tx_stream<5>/OD ),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_stream<5>/OFF/RST ),
    .O(tx_shift_reg_5[0])
  );
  X_BUF \tx_stream<6>/OMUX  (
    .I(\_n0026<0>/GROM ),
    .O(\tx_stream<6>/OD )
  );
  X_BUF \tx_stream<6>/OUTMUX_45  (
    .I(tx_shift_reg_6[0]),
    .O(\tx_stream<6>/OUTMUX )
  );
  X_BUF \tx_stream<6>/GTS_OR  (
    .I(GTS_0),
    .O(\tx_stream<6>/TORGTS )
  );
  X_INV \tx_stream<6>/ENABLEINV  (
    .I(\tx_stream<6>/TORGTS ),
    .O(\tx_stream<6>/ENABLE )
  );
  X_TRI tx_stream_6_OBUF (
    .I(\tx_stream<6>/OUTMUX ),
    .CTL(\tx_stream<6>/ENABLE ),
    .O(tx_stream[6])
  );
  X_OPAD \tx_stream<6>/PAD  (
    .PAD(tx_stream[6])
  );
  X_BUF \tx_stream<6>/OFF/RSTOR  (
    .I(GSR),
    .O(\tx_stream<6>/OFF/RST )
  );
  X_FF tx_shift_reg_6_0 (
    .I(\tx_stream<6>/OD ),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_stream<6>/OFF/RST ),
    .O(tx_shift_reg_6[0])
  );
  X_BUF \tx_stream<7>/OMUX  (
    .I(\_n0026<0>/FROM ),
    .O(\tx_stream<7>/OD )
  );
  X_BUF \tx_stream<7>/OUTMUX_46  (
    .I(tx_shift_reg_7[0]),
    .O(\tx_stream<7>/OUTMUX )
  );
  X_BUF \tx_stream<7>/GTS_OR  (
    .I(GTS_0),
    .O(\tx_stream<7>/TORGTS )
  );
  X_INV \tx_stream<7>/ENABLEINV  (
    .I(\tx_stream<7>/TORGTS ),
    .O(\tx_stream<7>/ENABLE )
  );
  X_TRI tx_stream_7_OBUF (
    .I(\tx_stream<7>/OUTMUX ),
    .CTL(\tx_stream<7>/ENABLE ),
    .O(tx_stream[7])
  );
  X_OPAD \tx_stream<7>/PAD  (
    .PAD(tx_stream[7])
  );
  X_BUF \tx_stream<7>/OFF/RSTOR  (
    .I(GSR),
    .O(\tx_stream<7>/OFF/RST )
  );
  X_FF tx_shift_reg_7_0 (
    .I(\tx_stream<7>/OD ),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_stream<7>/OFF/RST ),
    .O(tx_shift_reg_7[0])
  );
  X_BUF mpi_cs_IBUF_47 (
    .I(mpi_cs),
    .O(mpi_cs_IBUF)
  );
  X_IPAD \mpi_cs/PAD  (
    .PAD(mpi_cs)
  );
  X_BUF mpi_rw_IBUF_48 (
    .I(mpi_rw),
    .O(mpi_rw_IBUF)
  );
  X_IPAD \mpi_rw/PAD  (
    .PAD(mpi_rw)
  );
  X_BUF \clk_out/OUTMUX_49  (
    .I(div_reg),
    .O(\clk_out/OUTMUX )
  );
  X_BUF \clk_out/GTS_OR  (
    .I(GTS_0),
    .O(\clk_out/TORGTS )
  );
  X_INV \clk_out/ENABLEINV  (
    .I(\clk_out/TORGTS ),
    .O(\clk_out/ENABLE )
  );
  X_TRI clk_out_OBUF (
    .I(\clk_out/OUTMUX ),
    .CTL(\clk_out/ENABLE ),
    .O(clk_out)
  );
  X_OPAD \clk_out/PAD  (
    .PAD(clk_out)
  );
  defparam c_mem.INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam c_mem.SETUP_ALL = 3139;
  X_RAMB4_S16_S16 c_mem (
    .CLKA(clk_in_BUFGP),
    .CLKB(mpi_clk_BUFGP),
    .ENA(\c_mem/ENA_INTNOT ),
    .ENB(ram_en),
    .RSTA(\c_mem/RSTA_INTNOT ),
    .RSTB(\c_mem/RSTB_INTNOT ),
    .WEA(\c_mem/LOGIC_ZERO ),
    .WEB(\c_mem/WEB_INTNOT ),
    .GSR(GSR),
    .ADDRA({c_mem_addr_cnt[4], c_mem_addr_cnt[3], c_mem_addr_cnt[2], c_mem_addr_cnt[1], c_mem_addr_cnt[0], frame_cnt[2], frame_cnt_1_1, frame_cnt[0]})
,
    .ADDRB({mpi_addr_7_IBUF, mpi_addr_6_IBUF, mpi_addr_5_IBUF, mpi_addr_4_IBUF, mpi_addr_3_IBUF, mpi_addr_2_IBUF, mpi_addr_1_IBUF, mpi_addr_0_IBUF}),
    .DIA({GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_5, GLOBAL_LOGIC0_5, GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_6, 
GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_5, GLOBAL_LOGIC0_4, GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_6}),
    .DIB({GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_6, GLOBAL_LOGIC0_3, GLOBAL_LOGIC0_6, mpi_data_in_8_IBUF, 
mpi_data_in_7_IBUF, mpi_data_in_6_IBUF, mpi_data_in_5_IBUF, mpi_data_in_4_IBUF, mpi_data_in_3_IBUF, mpi_data_in_2_IBUF, mpi_data_in_1_IBUF, 
mpi_data_in_0_IBUF}),
    .DOA({\c_mem/DOA15 , \c_mem/DOA14 , \c_mem/DOA13 , \c_mem/DOA12 , \c_mem/DOA11 , \c_mem/DOA10 , \c_mem/DOA9 , \c_mem/DOA8 , cd_data[7], cd_data[6]
, cd_data[5], cd_data[4], cd_data[3], cd_data[2], cd_data[1], cd_data[0]}),
    .DOB({\c_mem/DOB15 , \c_mem/DOB14 , \c_mem/DOB13 , \c_mem/DOB12 , \c_mem/DOB11 , \c_mem/DOB10 , \c_mem/DOB9 , mpi_mem_bus_out[8], 
mpi_mem_bus_out[7], mpi_mem_bus_out[6], mpi_mem_bus_out[5], mpi_mem_bus_out[4], mpi_mem_bus_out[3], mpi_mem_bus_out[2], mpi_mem_bus_out[1], 
mpi_mem_bus_out[0]})
  );
  X_INV \c_mem/WEBMUX  (
    .I(mpi_rw_IBUF),
    .O(\c_mem/WEB_INTNOT )
  );
  X_INV \c_mem/ENAMUX  (
    .I(frame_cnt[3]),
    .O(\c_mem/ENA_INTNOT )
  );
  X_INV \c_mem/RSTAMUX  (
    .I(reset_IBUF),
    .O(\c_mem/RSTA_INTNOT )
  );
  X_INV \c_mem/RSTBMUX  (
    .I(reset_IBUF),
    .O(\c_mem/RSTB_INTNOT )
  );
  X_ZERO \c_mem/LOGIC_ZERO_50  (
    .O(\c_mem/LOGIC_ZERO )
  );
  defparam d_mem.INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
  defparam d_mem.SETUP_ALL = 3139;
  X_RAMB4_S8_S16 d_mem (
    .CLKA(clk_in_BUFGP),
    .CLKB(div_reg),
    .ENA(\d_mem/LOGIC_ONE ),
    .ENB(_n0054),
    .RSTA(\d_mem/RSTA_INTNOT ),
    .RSTB(\d_mem/RSTB_INTNOT ),
    .WEA(\d_mem/LOGIC_ZERO ),
    .WEB(\d_mem/LOGIC_ONE ),
    .GSR(GSR),
    .ADDRA({cd_mem_addr[8], cd_data[7], cd_data[6], cd_data[5], cd_data[4], cd_data[3], cd_data[2], cd_data[1], cd_data[0]}),
    .ADDRB({mem_page_sel, d_mem_addr_cnt[4], d_mem_addr_cnt[3], d_mem_addr_cnt[2], d_mem_addr_cnt[1], d_mem_addr_cnt[0], _COND_1[2], d_mem_addr[0]}),
    .DIA({GLOBAL_LOGIC0, GLOBAL_LOGIC0, GLOBAL_LOGIC0, GLOBAL_LOGIC0, GLOBAL_LOGIC0, GLOBAL_LOGIC0, GLOBAL_LOGIC0, GLOBAL_LOGIC0}),
    .DIB({data_in_bus[15], data_in_bus[14], data_in_bus[13], data_in_bus[12], data_in_bus[11], data_in_bus[10], data_in_bus[9], data_in_bus[8], 
data_in_bus[7], data_in_bus[6], data_in_bus[5], data_in_bus[4], data_in_bus[3], data_in_bus[2], data_in_bus[1], data_in_bus[0]}),
    .DOA({data_out_bus[7], data_out_bus[6], data_out_bus[5], data_out_bus[4], data_out_bus[3], data_out_bus[2], data_out_bus[1], data_out_bus[0]}),
    .DOB({\d_mem/DOB15 , \d_mem/DOB14 , \d_mem/DOB13 , \d_mem/DOB12 , \d_mem/DOB11 , \d_mem/DOB10 , \d_mem/DOB9 , \d_mem/DOB8 , \d_mem/DOB7 , 
\d_mem/DOB6 , \d_mem/DOB5 , \d_mem/DOB4 , \d_mem/DOB3 , \d_mem/DOB2 , \d_mem/DOB1 , \d_mem/DOB0 })
  );
  X_INV \d_mem/RSTAMUX  (
    .I(reset_IBUF),
    .O(\d_mem/RSTA_INTNOT )
  );
  X_INV \d_mem/RSTBMUX  (
    .I(reset_IBUF),
    .O(\d_mem/RSTB_INTNOT )
  );
  X_ONE \d_mem/LOGIC_ONE_51  (
    .O(\d_mem/LOGIC_ONE )
  );
  X_ZERO \d_mem/LOGIC_ZERO_52  (
    .O(\d_mem/LOGIC_ZERO )
  );
  X_BUF \data_in_bus<12>/XUSED  (
    .I(\data_in_bus<12>/F5MUX ),
    .O(data_in_bus[12])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_16111_F.INIT = 16'hAAF0;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_16111_F (
    .ADR0(rx_buf_reg_7[4]),
    .ADR1(VCC),
    .ADR2(rx_buf_reg_3[4]),
    .ADR3(_COND_1[2]),
    .O(N9669)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_16111_G.INIT = 16'hFC30;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_16111_G (
    .ADR0(VCC),
    .ADR1(_COND_1[2]),
    .ADR2(rx_buf_reg_1[4]),
    .ADR3(rx_buf_reg_5[4]),
    .O(N9671)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_16111 (
    .IA(N9669),
    .IB(N9671),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<12>/F5MUX )
  );
  X_BUF \data_in_bus<3>/XUSED  (
    .I(\data_in_bus<3>/F5MUX ),
    .O(data_in_bus[3])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_7111_F.INIT = 16'hACAC;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_7111_F (
    .ADR0(rx_buf_reg_6[3]),
    .ADR1(rx_buf_reg_2[3]),
    .ADR2(_COND_1[2]),
    .ADR3(VCC),
    .O(N9619)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_7111_G.INIT = 16'hFC0C;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_7111_G (
    .ADR0(VCC),
    .ADR1(rx_buf_reg_0[3]),
    .ADR2(_COND_1[2]),
    .ADR3(rx_buf_reg_4[3]),
    .O(N9621)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_7111 (
    .IA(N9619),
    .IB(N9621),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<3>/F5MUX )
  );
  X_BUF \data_in_bus<13>/XUSED  (
    .I(\data_in_bus<13>/F5MUX ),
    .O(data_in_bus[13])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_17111_F.INIT = 16'hE2E2;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_17111_F (
    .ADR0(rx_buf_reg_3[5]),
    .ADR1(_COND_1[2]),
    .ADR2(rx_buf_reg_7[5]),
    .ADR3(VCC),
    .O(N9659)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_17111_G.INIT = 16'hF3C0;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_17111_G (
    .ADR0(VCC),
    .ADR1(_COND_1[2]),
    .ADR2(rx_buf_reg_5[5]),
    .ADR3(rx_buf_reg_1[5]),
    .O(N9661)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_17111 (
    .IA(N9659),
    .IB(N9661),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<13>/F5MUX )
  );
  X_BUF \data_in_bus<4>/XUSED  (
    .I(\data_in_bus<4>/F5MUX ),
    .O(data_in_bus[4])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_8111_F.INIT = 16'hEE22;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_8111_F (
    .ADR0(rx_buf_reg_2[4]),
    .ADR1(_COND_1[2]),
    .ADR2(VCC),
    .ADR3(rx_buf_reg_6[4]),
    .O(N9614)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_8111_G.INIT = 16'hBB88;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_8111_G (
    .ADR0(rx_buf_reg_4[4]),
    .ADR1(_COND_1[2]),
    .ADR2(VCC),
    .ADR3(rx_buf_reg_0[4]),
    .O(N9616)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_8111 (
    .IA(N9614),
    .IB(N9616),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<4>/F5MUX )
  );
  X_BUF \data_in_bus<14>/XUSED  (
    .I(\data_in_bus<14>/F5MUX ),
    .O(data_in_bus[14])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_18111_F.INIT = 16'hAFA0;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_18111_F (
    .ADR0(rx_buf_reg_7[6]),
    .ADR1(VCC),
    .ADR2(_COND_1[2]),
    .ADR3(rx_buf_reg_3[6]),
    .O(N9649)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_18111_G.INIT = 16'hDD88;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_18111_G (
    .ADR0(_COND_1[2]),
    .ADR1(rx_buf_reg_5[6]),
    .ADR2(VCC),
    .ADR3(rx_buf_reg_1[6]),
    .O(N9651)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_18111 (
    .IA(N9649),
    .IB(N9651),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<14>/F5MUX )
  );
  X_BUF \data_in_bus<5>/XUSED  (
    .I(\data_in_bus<5>/F5MUX ),
    .O(data_in_bus[5])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_9111_F.INIT = 16'hAFA0;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_9111_F (
    .ADR0(rx_buf_reg_6[5]),
    .ADR1(VCC),
    .ADR2(_COND_1[2]),
    .ADR3(rx_buf_reg_2[5]),
    .O(N9664)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_9111_G.INIT = 16'hF0CC;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_9111_G (
    .ADR0(VCC),
    .ADR1(rx_buf_reg_0[5]),
    .ADR2(rx_buf_reg_4[5]),
    .ADR3(_COND_1[2]),
    .O(N9666)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_9111 (
    .IA(N9664),
    .IB(N9666),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<5>/F5MUX )
  );
  X_BUF \data_in_bus<15>/XUSED  (
    .I(\data_in_bus<15>/F5MUX ),
    .O(data_in_bus[15])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_19111_F.INIT = 16'hACAC;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_19111_F (
    .ADR0(rx_buf_reg_7[7]),
    .ADR1(rx_buf_reg_3[7]),
    .ADR2(_COND_1[2]),
    .ADR3(VCC),
    .O(N9674)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_19111_G.INIT = 16'hEE22;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_19111_G (
    .ADR0(rx_buf_reg_1[7]),
    .ADR1(_COND_1[2]),
    .ADR2(VCC),
    .ADR3(rx_buf_reg_5[7]),
    .O(N9676)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_19111 (
    .IA(N9674),
    .IB(N9676),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<15>/F5MUX )
  );
  X_BUF \Mmux__n0074__net2/F5USED  (
    .I(\Mmux__n0074__net2/F5MUX ),
    .O(Mmux__n0074__net2)
  );
  defparam Mmux__n0074_inst_lut3_01.INIT = 16'hCCF0;
  X_LUT4 Mmux__n0074_inst_lut3_01 (
    .ADR0(VCC),
    .ADR1(frame_delay_buf_1[0]),
    .ADR2(frame_delay_buf_0[0]),
    .ADR3(mpi_addr_0_IBUF),
    .O(Mmux__n0074__net0)
  );
  defparam Mmux__n0074_inst_lut3_11.INIT = 16'hAFA0;
  X_LUT4 Mmux__n0074_inst_lut3_11 (
    .ADR0(frame_delay_buf_3[0]),
    .ADR1(VCC),
    .ADR2(mpi_addr_0_IBUF),
    .ADR3(frame_delay_buf_2[0]),
    .O(Mmux__n0074__net1)
  );
  X_MUX2 Mmux__n0074_inst_mux_f5_0 (
    .IA(Mmux__n0074__net0),
    .IB(Mmux__n0074__net1),
    .SEL(mpi_addr_1_IBUF),
    .O(\Mmux__n0074__net2/F5MUX )
  );
  X_MUX2 Mmux__n0074_inst_mux_f6_0 (
    .IA(Mmux__n0074__net2),
    .IB(Mmux__n0074__net5),
    .SEL(mpi_addr_2_IBUF),
    .O(\_n0246<2>/F6MUX )
  );
  X_BUF \_n0246<2>/YUSED  (
    .I(\_n0246<2>/F6MUX ),
    .O(_n0246[2])
  );
  defparam Mmux__n0074_inst_lut3_21.INIT = 16'hF5A0;
  X_LUT4 Mmux__n0074_inst_lut3_21 (
    .ADR0(mpi_addr_0_IBUF),
    .ADR1(VCC),
    .ADR2(frame_delay_buf_5[0]),
    .ADR3(frame_delay_buf_4[0]),
    .O(Mmux__n0074__net3)
  );
  defparam Mmux__n0074_inst_lut3_31.INIT = 16'hE4E4;
  X_LUT4 Mmux__n0074_inst_lut3_31 (
    .ADR0(mpi_addr_0_IBUF),
    .ADR1(frame_delay_buf_6[0]),
    .ADR2(frame_delay_buf_7[0]),
    .ADR3(VCC),
    .O(Mmux__n0074__net4)
  );
  X_MUX2 Mmux__n0074_inst_mux_f5_1 (
    .IA(Mmux__n0074__net3),
    .IB(Mmux__n0074__net4),
    .SEL(mpi_addr_1_IBUF),
    .O(Mmux__n0074__net5)
  );
  X_BUF \Mmux__n0074__net9/F5USED  (
    .I(\Mmux__n0074__net9/F5MUX ),
    .O(Mmux__n0074__net9)
  );
  defparam Mmux__n0074_inst_lut3_41.INIT = 16'hCACA;
  X_LUT4 Mmux__n0074_inst_lut3_41 (
    .ADR0(frame_delay_buf_0[1]),
    .ADR1(frame_delay_buf_1[1]),
    .ADR2(mpi_addr_0_IBUF),
    .ADR3(VCC),
    .O(Mmux__n0074__net7)
  );
  defparam Mmux__n0074_inst_lut3_51.INIT = 16'hF0CC;
  X_LUT4 Mmux__n0074_inst_lut3_51 (
    .ADR0(VCC),
    .ADR1(frame_delay_buf_2[1]),
    .ADR2(frame_delay_buf_3[1]),
    .ADR3(mpi_addr_0_IBUF),
    .O(Mmux__n0074__net8)
  );
  X_MUX2 Mmux__n0074_inst_mux_f5_2 (
    .IA(Mmux__n0074__net7),
    .IB(Mmux__n0074__net8),
    .SEL(mpi_addr_1_IBUF),
    .O(\Mmux__n0074__net9/F5MUX )
  );
  X_MUX2 Mmux__n0074_inst_mux_f6_1 (
    .IA(Mmux__n0074__net9),
    .IB(Mmux__n0074__net12),
    .SEL(mpi_addr_2_IBUF),
    .O(\_n0246<3>/F6MUX )
  );
  X_BUF \_n0246<3>/YUSED  (
    .I(\_n0246<3>/F6MUX ),
    .O(_n0246[3])
  );
  defparam Mmux__n0074_inst_lut3_61.INIT = 16'hCFC0;
  X_LUT4 Mmux__n0074_inst_lut3_61 (
    .ADR0(VCC),
    .ADR1(frame_delay_buf_5[1]),
    .ADR2(mpi_addr_0_IBUF),
    .ADR3(frame_delay_buf_4[1]),
    .O(Mmux__n0074__net10)
  );
  defparam Mmux__n0074_inst_lut3_71.INIT = 16'hFC30;
  X_LUT4 Mmux__n0074_inst_lut3_71 (
    .ADR0(VCC),
    .ADR1(mpi_addr_0_IBUF),
    .ADR2(frame_delay_buf_6[1]),
    .ADR3(frame_delay_buf_7[1]),
    .O(Mmux__n0074__net11)
  );
  X_MUX2 Mmux__n0074_inst_mux_f5_3 (
    .IA(Mmux__n0074__net10),
    .IB(Mmux__n0074__net11),
    .SEL(mpi_addr_1_IBUF),
    .O(Mmux__n0074__net12)
  );
  X_BUF \data_in_bus<6>/XUSED  (
    .I(\data_in_bus<6>/F5MUX ),
    .O(data_in_bus[6])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_10111_F.INIT = 16'hFA0A;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_10111_F (
    .ADR0(rx_buf_reg_2[6]),
    .ADR1(VCC),
    .ADR2(_COND_1[2]),
    .ADR3(rx_buf_reg_6[6]),
    .O(N9654)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_10111_G.INIT = 16'hAFA0;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_10111_G (
    .ADR0(rx_buf_reg_4[6]),
    .ADR1(VCC),
    .ADR2(_COND_1[2]),
    .ADR3(rx_buf_reg_0[6]),
    .O(N9656)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_10111 (
    .IA(N9654),
    .IB(N9656),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<6>/F5MUX )
  );
  X_BUF \data_in_bus<7>/XUSED  (
    .I(\data_in_bus<7>/F5MUX ),
    .O(data_in_bus[7])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_11111_F.INIT = 16'hAFA0;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_11111_F (
    .ADR0(rx_buf_reg_6[7]),
    .ADR1(VCC),
    .ADR2(_COND_1[2]),
    .ADR3(rx_buf_reg_2[7]),
    .O(N9644)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_11111_G.INIT = 16'hEE44;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_11111_G (
    .ADR0(_COND_1[2]),
    .ADR1(rx_buf_reg_0[7]),
    .ADR2(VCC),
    .ADR3(rx_buf_reg_4[7]),
    .O(N9646)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_11111 (
    .IA(N9644),
    .IB(N9646),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<7>/F5MUX )
  );
  X_BUF \data_in_bus<8>/XUSED  (
    .I(\data_in_bus<8>/F5MUX ),
    .O(data_in_bus[8])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_12111_F.INIT = 16'hAFA0;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_12111_F (
    .ADR0(rx_buf_reg_7[0]),
    .ADR1(VCC),
    .ADR2(_COND_1[2]),
    .ADR3(rx_buf_reg_3[0]),
    .O(N9634)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_12111_G.INIT = 16'hACAC;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_12111_G (
    .ADR0(rx_buf_reg_5[0]),
    .ADR1(rx_buf_reg_1[0]),
    .ADR2(_COND_1[2]),
    .ADR3(VCC),
    .O(N9636)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_12111 (
    .IA(N9634),
    .IB(N9636),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<8>/F5MUX )
  );
  X_BUF \data_in_bus<9>/XUSED  (
    .I(\data_in_bus<9>/F5MUX ),
    .O(data_in_bus[9])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_13111_F.INIT = 16'hEE22;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_13111_F (
    .ADR0(rx_buf_reg_3[1]),
    .ADR1(_COND_1[2]),
    .ADR2(VCC),
    .ADR3(rx_buf_reg_7[1]),
    .O(N9629)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_13111_G.INIT = 16'hFC30;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_13111_G (
    .ADR0(VCC),
    .ADR1(_COND_1[2]),
    .ADR2(rx_buf_reg_1[1]),
    .ADR3(rx_buf_reg_5[1]),
    .O(N9631)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_13111 (
    .IA(N9629),
    .IB(N9631),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<9>/F5MUX )
  );
  X_BUF \data_in_bus<0>/XUSED  (
    .I(\data_in_bus<0>/F5MUX ),
    .O(data_in_bus[0])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_4111_F.INIT = 16'hCCAA;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_4111_F (
    .ADR0(rx_buf_reg_2[0]),
    .ADR1(rx_buf_reg_6[0]),
    .ADR2(VCC),
    .ADR3(_COND_1[2]),
    .O(N9679)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_4111_G.INIT = 16'hCCF0;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_4111_G (
    .ADR0(VCC),
    .ADR1(rx_buf_reg_4[0]),
    .ADR2(rx_buf_reg_0[0]),
    .ADR3(_COND_1[2]),
    .O(N9681)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_4111 (
    .IA(N9679),
    .IB(N9681),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<0>/F5MUX )
  );
  X_BUF \data_in_bus<10>/XUSED  (
    .I(\data_in_bus<10>/F5MUX ),
    .O(data_in_bus[10])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_14111_F.INIT = 16'hCFC0;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_14111_F (
    .ADR0(VCC),
    .ADR1(rx_buf_reg_7[2]),
    .ADR2(_COND_1[2]),
    .ADR3(rx_buf_reg_3[2]),
    .O(N9624)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_14111_G.INIT = 16'hDD88;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_14111_G (
    .ADR0(_COND_1[2]),
    .ADR1(rx_buf_reg_5[2]),
    .ADR2(VCC),
    .ADR3(rx_buf_reg_1[2]),
    .O(N9626)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_14111 (
    .IA(N9624),
    .IB(N9626),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<10>/F5MUX )
  );
  X_BUF \data_in_bus<1>/XUSED  (
    .I(\data_in_bus<1>/F5MUX ),
    .O(data_in_bus[1])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_5111_F.INIT = 16'hFC30;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_5111_F (
    .ADR0(VCC),
    .ADR1(_COND_1[2]),
    .ADR2(rx_buf_reg_2[1]),
    .ADR3(rx_buf_reg_6[1]),
    .O(N9609)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_5111_G.INIT = 16'hF3C0;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_5111_G (
    .ADR0(VCC),
    .ADR1(_COND_1[2]),
    .ADR2(rx_buf_reg_4[1]),
    .ADR3(rx_buf_reg_0[1]),
    .O(N9611)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_5111 (
    .IA(N9609),
    .IB(N9611),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<1>/F5MUX )
  );
  X_BUF \data_in_bus<11>/XUSED  (
    .I(\data_in_bus<11>/F5MUX ),
    .O(data_in_bus[11])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_15111_F.INIT = 16'hF3C0;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_15111_F (
    .ADR0(VCC),
    .ADR1(_COND_1[2]),
    .ADR2(rx_buf_reg_7[3]),
    .ADR3(rx_buf_reg_3[3]),
    .O(N9639)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_15111_G.INIT = 16'hEE22;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_15111_G (
    .ADR0(rx_buf_reg_1[3]),
    .ADR1(_COND_1[2]),
    .ADR2(VCC),
    .ADR3(rx_buf_reg_5[3]),
    .O(N9641)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_15111 (
    .IA(N9639),
    .IB(N9641),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<11>/F5MUX )
  );
  X_BUF \data_in_bus<2>/XUSED  (
    .I(\data_in_bus<2>/F5MUX ),
    .O(data_in_bus[2])
  );
  defparam Mmux_data_in_bus_inst_mux_f5_6111_F.INIT = 16'hAFA0;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_6111_F (
    .ADR0(rx_buf_reg_6[2]),
    .ADR1(VCC),
    .ADR2(_COND_1[2]),
    .ADR3(rx_buf_reg_2[2]),
    .O(N9604)
  );
  defparam Mmux_data_in_bus_inst_mux_f5_6111_G.INIT = 16'hEE44;
  X_LUT4 Mmux_data_in_bus_inst_mux_f5_6111_G (
    .ADR0(_COND_1[2]),
    .ADR1(rx_buf_reg_0[2]),
    .ADR2(VCC),
    .ADR3(rx_buf_reg_4[2]),
    .O(N9606)
  );
  X_MUX2 Mmux_data_in_bus_inst_mux_f5_6111 (
    .IA(N9604),
    .IB(N9606),
    .SEL(frame_cnt_1_1),
    .O(\data_in_bus<2>/F5MUX )
  );
  X_XOR2 d_mem_addr_cnt_Madd__n0000_inst_sum_1 (
    .I0(d_mem_addr_cnt_Madd__n0000_inst_cy_0),
    .I1(\d_mem_addr_cnt<0>/GROM ),
    .O(d_mem_addr_cnt__n0000[1])
  );
  X_MUX2 d_mem_addr_cnt_Madd__n0000_inst_cy_1 (
    .IA(GLOBAL_LOGIC0_0),
    .IB(d_mem_addr_cnt_Madd__n0000_inst_cy_0),
    .SEL(\d_mem_addr_cnt<0>/GROM ),
    .O(\d_mem_addr_cnt<0>/CYMUXG )
  );
  defparam \d_mem_addr_cnt<0>/G .INIT = 16'hF0F0;
  X_LUT4 \d_mem_addr_cnt<0>/G  (
    .ADR0(GLOBAL_LOGIC0_0),
    .ADR1(VCC),
    .ADR2(d_mem_addr_cnt[1]),
    .ADR3(VCC),
    .O(\d_mem_addr_cnt<0>/GROM )
  );
  defparam d_mem_addr_cnt_Madd__n0000_inst_lut2_01.INIT = 16'h3333;
  X_LUT4 d_mem_addr_cnt_Madd__n0000_inst_lut2_01 (
    .ADR0(GLOBAL_LOGIC1_1),
    .ADR1(d_mem_addr_cnt[0]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(d_mem_addr_cnt_Madd__n0000_inst_lut2_0)
  );
  X_MUX2 d_mem_addr_cnt_Madd__n0000_inst_cy_0_53 (
    .IA(GLOBAL_LOGIC1_1),
    .IB(\d_mem_addr_cnt<0>/LOGIC_ZERO ),
    .SEL(d_mem_addr_cnt_Madd__n0000_inst_lut2_0),
    .O(d_mem_addr_cnt_Madd__n0000_inst_cy_0)
  );
  X_ZERO \d_mem_addr_cnt<0>/LOGIC_ZERO_54  (
    .O(\d_mem_addr_cnt<0>/LOGIC_ZERO )
  );
  X_SFF d_mem_addr_cnt_0 (
    .I(d_mem_addr_cnt_Madd__n0000_inst_lut2_0),
    .CE(N8791),
    .CLK(div_reg),
    .SET(GSR),
    .RST(GND),
    .SSET(frame_sync_OBUF),
    .SRST(GND),
    .O(d_mem_addr_cnt[0])
  );
  X_SFF d_mem_addr_cnt_1 (
    .I(d_mem_addr_cnt__n0000[1]),
    .CE(N8791),
    .CLK(div_reg),
    .SET(GSR),
    .RST(GND),
    .SSET(frame_sync_OBUF),
    .SRST(GND),
    .O(d_mem_addr_cnt[1])
  );
  X_BUF \d_mem_addr_cnt<2>/CYINIT_55  (
    .I(\d_mem_addr_cnt<0>/CYMUXG ),
    .O(\d_mem_addr_cnt<2>/CYINIT )
  );
  X_XOR2 d_mem_addr_cnt_Madd__n0000_inst_sum_3 (
    .I0(d_mem_addr_cnt_Madd__n0000_inst_cy_2),
    .I1(\d_mem_addr_cnt<2>/GROM ),
    .O(d_mem_addr_cnt__n0000[3])
  );
  X_MUX2 d_mem_addr_cnt_Madd__n0000_inst_cy_3 (
    .IA(\d_mem_addr_cnt<2>/LOGIC_ZERO ),
    .IB(d_mem_addr_cnt_Madd__n0000_inst_cy_2),
    .SEL(\d_mem_addr_cnt<2>/GROM ),
    .O(\d_mem_addr_cnt<2>/CYMUXG )
  );
  defparam \d_mem_addr_cnt<2>/G .INIT = 16'hF0F0;
  X_LUT4 \d_mem_addr_cnt<2>/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(d_mem_addr_cnt[3]),
    .ADR3(VCC),
    .O(\d_mem_addr_cnt<2>/GROM )
  );
  defparam \d_mem_addr_cnt<2>/F .INIT = 16'hFF00;
  X_LUT4 \d_mem_addr_cnt<2>/F  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(d_mem_addr_cnt[2]),
    .O(\d_mem_addr_cnt<2>/FROM )
  );
  X_XOR2 d_mem_addr_cnt_Madd__n0000_inst_sum_2 (
    .I0(\d_mem_addr_cnt<2>/CYINIT ),
    .I1(\d_mem_addr_cnt<2>/FROM ),
    .O(d_mem_addr_cnt__n0000[2])
  );
  X_MUX2 d_mem_addr_cnt_Madd__n0000_inst_cy_2_56 (
    .IA(\d_mem_addr_cnt<2>/LOGIC_ZERO ),
    .IB(\d_mem_addr_cnt<2>/CYINIT ),
    .SEL(\d_mem_addr_cnt<2>/FROM ),
    .O(d_mem_addr_cnt_Madd__n0000_inst_cy_2)
  );
  X_ZERO \d_mem_addr_cnt<2>/LOGIC_ZERO_57  (
    .O(\d_mem_addr_cnt<2>/LOGIC_ZERO )
  );
  X_SFF d_mem_addr_cnt_2 (
    .I(d_mem_addr_cnt__n0000[2]),
    .CE(N8791),
    .CLK(div_reg),
    .SET(GSR),
    .RST(GND),
    .SSET(frame_sync_OBUF),
    .SRST(GND),
    .O(d_mem_addr_cnt[2])
  );
  X_SFF d_mem_addr_cnt_3 (
    .I(d_mem_addr_cnt__n0000[3]),
    .CE(N8791),
    .CLK(div_reg),
    .SET(GSR),
    .RST(GND),
    .SSET(frame_sync_OBUF),
    .SRST(GND),
    .O(d_mem_addr_cnt[3])
  );
  X_BUF \d_mem_addr_cnt<4>/CYINIT_58  (
    .I(\d_mem_addr_cnt<2>/CYMUXG ),
    .O(\d_mem_addr_cnt<4>/CYINIT )
  );
  defparam \d_mem_addr_cnt<4>_rt_59 .INIT = 16'hFF00;
  X_LUT4 \d_mem_addr_cnt<4>_rt_59  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(d_mem_addr_cnt[4]),
    .O(\d_mem_addr_cnt<4>_rt )
  );
  X_XOR2 d_mem_addr_cnt_Madd__n0000_inst_sum_4 (
    .I0(\d_mem_addr_cnt<4>/CYINIT ),
    .I1(\d_mem_addr_cnt<4>_rt ),
    .O(d_mem_addr_cnt__n0000[4])
  );
  X_SFF d_mem_addr_cnt_4 (
    .I(d_mem_addr_cnt__n0000[4]),
    .CE(N8791),
    .CLK(div_reg),
    .SET(GSR),
    .RST(GND),
    .SSET(frame_sync_OBUF),
    .SRST(GND),
    .O(d_mem_addr_cnt[4])
  );
  X_XOR2 c_mem_addr_cnt_Madd__n0000_inst_sum_1 (
    .I0(c_mem_addr_cnt_Madd__n0000_inst_cy_0),
    .I1(\c_mem_addr_cnt<0>/GROM ),
    .O(c_mem_addr_cnt__n0000[1])
  );
  X_MUX2 c_mem_addr_cnt_Madd__n0000_inst_cy_1 (
    .IA(GLOBAL_LOGIC0_2),
    .IB(c_mem_addr_cnt_Madd__n0000_inst_cy_0),
    .SEL(\c_mem_addr_cnt<0>/GROM ),
    .O(\c_mem_addr_cnt<0>/CYMUXG )
  );
  defparam \c_mem_addr_cnt<0>/G .INIT = 16'hCCCC;
  X_LUT4 \c_mem_addr_cnt<0>/G  (
    .ADR0(GLOBAL_LOGIC0_2),
    .ADR1(c_mem_addr_cnt[1]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\c_mem_addr_cnt<0>/GROM )
  );
  defparam c_mem_addr_cnt_Madd__n0000_inst_lut2_01.INIT = 16'h00FF;
  X_LUT4 c_mem_addr_cnt_Madd__n0000_inst_lut2_01 (
    .ADR0(GLOBAL_LOGIC1),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(c_mem_addr_cnt[0]),
    .O(c_mem_addr_cnt_Madd__n0000_inst_lut2_0)
  );
  X_MUX2 c_mem_addr_cnt_Madd__n0000_inst_cy_0_60 (
    .IA(GLOBAL_LOGIC1),
    .IB(\c_mem_addr_cnt<0>/LOGIC_ZERO ),
    .SEL(c_mem_addr_cnt_Madd__n0000_inst_lut2_0),
    .O(c_mem_addr_cnt_Madd__n0000_inst_cy_0)
  );
  X_ZERO \c_mem_addr_cnt<0>/LOGIC_ZERO_61  (
    .O(\c_mem_addr_cnt<0>/LOGIC_ZERO )
  );
  X_SFF c_mem_addr_cnt_0 (
    .I(c_mem_addr_cnt_Madd__n0000_inst_lut2_0),
    .CE(N8791),
    .CLK(div_reg),
    .SET(GSR),
    .RST(GND),
    .SSET(frame_sync_OBUF),
    .SRST(GND),
    .O(c_mem_addr_cnt[0])
  );
  X_SFF c_mem_addr_cnt_1 (
    .I(c_mem_addr_cnt__n0000[1]),
    .CE(N8791),
    .CLK(div_reg),
    .SET(GND),
    .RST(GSR),
    .SSET(GND),
    .SRST(frame_sync_OBUF),
    .O(c_mem_addr_cnt[1])
  );
  X_BUF \c_mem_addr_cnt<2>/CYINIT_62  (
    .I(\c_mem_addr_cnt<0>/CYMUXG ),
    .O(\c_mem_addr_cnt<2>/CYINIT )
  );
  X_XOR2 c_mem_addr_cnt_Madd__n0000_inst_sum_3 (
    .I0(c_mem_addr_cnt_Madd__n0000_inst_cy_2),
    .I1(\c_mem_addr_cnt<2>/GROM ),
    .O(c_mem_addr_cnt__n0000[3])
  );
  X_MUX2 c_mem_addr_cnt_Madd__n0000_inst_cy_3 (
    .IA(\c_mem_addr_cnt<2>/LOGIC_ZERO ),
    .IB(c_mem_addr_cnt_Madd__n0000_inst_cy_2),
    .SEL(\c_mem_addr_cnt<2>/GROM ),
    .O(\c_mem_addr_cnt<2>/CYMUXG )
  );
  defparam \c_mem_addr_cnt<2>/G .INIT = 16'hFF00;
  X_LUT4 \c_mem_addr_cnt<2>/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(c_mem_addr_cnt[3]),
    .O(\c_mem_addr_cnt<2>/GROM )
  );
  defparam \c_mem_addr_cnt<2>/F .INIT = 16'hCCCC;
  X_LUT4 \c_mem_addr_cnt<2>/F  (
    .ADR0(VCC),
    .ADR1(c_mem_addr_cnt[2]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\c_mem_addr_cnt<2>/FROM )
  );
  X_XOR2 c_mem_addr_cnt_Madd__n0000_inst_sum_2 (
    .I0(\c_mem_addr_cnt<2>/CYINIT ),
    .I1(\c_mem_addr_cnt<2>/FROM ),
    .O(c_mem_addr_cnt__n0000[2])
  );
  X_MUX2 c_mem_addr_cnt_Madd__n0000_inst_cy_2_63 (
    .IA(\c_mem_addr_cnt<2>/LOGIC_ZERO ),
    .IB(\c_mem_addr_cnt<2>/CYINIT ),
    .SEL(\c_mem_addr_cnt<2>/FROM ),
    .O(c_mem_addr_cnt_Madd__n0000_inst_cy_2)
  );
  X_ZERO \c_mem_addr_cnt<2>/LOGIC_ZERO_64  (
    .O(\c_mem_addr_cnt<2>/LOGIC_ZERO )
  );
  X_SFF c_mem_addr_cnt_3 (
    .I(c_mem_addr_cnt__n0000[3]),
    .CE(N8791),
    .CLK(div_reg),
    .SET(GND),
    .RST(GSR),
    .SSET(GND),
    .SRST(frame_sync_OBUF),
    .O(c_mem_addr_cnt[3])
  );
  X_BUF \c_mem_addr_cnt<4>/CYINIT_65  (
    .I(\c_mem_addr_cnt<2>/CYMUXG ),
    .O(\c_mem_addr_cnt<4>/CYINIT )
  );
  defparam \c_mem_addr_cnt<4>_rt_66 .INIT = 16'hCCCC;
  X_LUT4 \c_mem_addr_cnt<4>_rt_66  (
    .ADR0(VCC),
    .ADR1(c_mem_addr_cnt[4]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\c_mem_addr_cnt<4>_rt )
  );
  X_XOR2 c_mem_addr_cnt_Madd__n0000_inst_sum_4 (
    .I0(\c_mem_addr_cnt<4>/CYINIT ),
    .I1(\c_mem_addr_cnt<4>_rt ),
    .O(c_mem_addr_cnt__n0000[4])
  );
  X_SFF c_mem_addr_cnt_4 (
    .I(c_mem_addr_cnt__n0000[4]),
    .CE(N8791),
    .CLK(div_reg),
    .SET(GND),
    .RST(GSR),
    .SSET(GND),
    .SRST(frame_sync_OBUF),
    .O(c_mem_addr_cnt[4])
  );
  X_INV \frame_cnt<0>/SRMUX  (
    .I(reset_IBUF),
    .O(\frame_cnt<0>/SRMUX_OUTPUTNOT )
  );
  X_XOR2 frame_cnt_Madd__n0000_inst_sum_6 (
    .I0(frame_cnt_Madd__n0000_inst_cy_5),
    .I1(\frame_cnt<0>/GROM ),
    .O(\frame_cnt<0>/XORG )
  );
  X_MUX2 frame_cnt_Madd__n0000_inst_cy_6 (
    .IA(GLOBAL_LOGIC0_1),
    .IB(frame_cnt_Madd__n0000_inst_cy_5),
    .SEL(\frame_cnt<0>/GROM ),
    .O(\frame_cnt<0>/CYMUXG )
  );
  X_BUF \frame_cnt<0>/YUSED  (
    .I(\frame_cnt<0>/XORG ),
    .O(frame_cnt__n0000[1])
  );
  X_INV \frame_cnt<0>/CKINV  (
    .I(clk_in_BUFGP),
    .O(\frame_cnt<0>/CKMUXNOT )
  );
  defparam \frame_cnt<0>/G .INIT = 16'hFF00;
  X_LUT4 \frame_cnt<0>/G  (
    .ADR0(GLOBAL_LOGIC0_1),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(frame_cnt_1_1),
    .O(\frame_cnt<0>/GROM )
  );
  defparam frame_cnt_Madd__n0000_inst_lut2_51.INIT = 16'h3333;
  X_LUT4 frame_cnt_Madd__n0000_inst_lut2_51 (
    .ADR0(GLOBAL_LOGIC1_0),
    .ADR1(frame_cnt[0]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(frame_cnt_Madd__n0000_inst_lut2_5)
  );
  X_MUX2 frame_cnt_Madd__n0000_inst_cy_5_67 (
    .IA(GLOBAL_LOGIC1_0),
    .IB(\frame_cnt<0>/LOGIC_ZERO ),
    .SEL(frame_cnt_Madd__n0000_inst_lut2_5),
    .O(frame_cnt_Madd__n0000_inst_cy_5)
  );
  X_ZERO \frame_cnt<0>/LOGIC_ZERO_68  (
    .O(\frame_cnt<0>/LOGIC_ZERO )
  );
  X_OR2 \frame_cnt<0>/FFX/RSTOR  (
    .I0(\frame_cnt<0>/SRMUX_OUTPUTNOT ),
    .I1(GSR),
    .O(\frame_cnt<0>/FFX/RST )
  );
  X_FF frame_cnt_0 (
    .I(frame_cnt_Madd__n0000_inst_lut2_5),
    .CE(VCC),
    .CLK(\frame_cnt<0>/CKMUXNOT ),
    .SET(GND),
    .RST(\frame_cnt<0>/FFX/RST ),
    .O(frame_cnt[0])
  );
  X_OR2 \frame_cnt<0>/FFY/RSTOR  (
    .I0(\frame_cnt<0>/SRMUX_OUTPUTNOT ),
    .I1(GSR),
    .O(\frame_cnt<0>/FFY/RST )
  );
  X_FF frame_cnt_1 (
    .I(\frame_cnt<0>/XORG ),
    .CE(VCC),
    .CLK(\frame_cnt<0>/CKMUXNOT ),
    .SET(GND),
    .RST(\frame_cnt<0>/FFY/RST ),
    .O(frame_cnt[1])
  );
  X_BUF \frame_cnt<2>/CYINIT_69  (
    .I(\frame_cnt<0>/CYMUXG ),
    .O(\frame_cnt<2>/CYINIT )
  );
  X_INV \frame_cnt<2>/SRMUX  (
    .I(reset_IBUF),
    .O(\frame_cnt<2>/SRMUX_OUTPUTNOT )
  );
  X_XOR2 frame_cnt_Madd__n0000_inst_sum_8 (
    .I0(frame_cnt_Madd__n0000_inst_cy_7),
    .I1(\frame_cnt<2>/GROM ),
    .O(frame_cnt__n0000[3])
  );
  X_MUX2 frame_cnt_Madd__n0000_inst_cy_8 (
    .IA(\frame_cnt<2>/LOGIC_ZERO ),
    .IB(frame_cnt_Madd__n0000_inst_cy_7),
    .SEL(\frame_cnt<2>/GROM ),
    .O(\frame_cnt<2>/CYMUXG )
  );
  X_INV \frame_cnt<2>/CKINV  (
    .I(clk_in_BUFGP),
    .O(\frame_cnt<2>/CKMUXNOT )
  );
  defparam \frame_cnt<2>/G .INIT = 16'hF0F0;
  X_LUT4 \frame_cnt<2>/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(frame_cnt[3]),
    .ADR3(VCC),
    .O(\frame_cnt<2>/GROM )
  );
  defparam \frame_cnt<2>/F .INIT = 16'hAAAA;
  X_LUT4 \frame_cnt<2>/F  (
    .ADR0(frame_cnt[2]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\frame_cnt<2>/FROM )
  );
  X_XOR2 frame_cnt_Madd__n0000_inst_sum_7 (
    .I0(\frame_cnt<2>/CYINIT ),
    .I1(\frame_cnt<2>/FROM ),
    .O(frame_cnt__n0000[2])
  );
  X_MUX2 frame_cnt_Madd__n0000_inst_cy_7_70 (
    .IA(\frame_cnt<2>/LOGIC_ZERO ),
    .IB(\frame_cnt<2>/CYINIT ),
    .SEL(\frame_cnt<2>/FROM ),
    .O(frame_cnt_Madd__n0000_inst_cy_7)
  );
  X_ZERO \frame_cnt<2>/LOGIC_ZERO_71  (
    .O(\frame_cnt<2>/LOGIC_ZERO )
  );
  X_OR2 \frame_cnt<2>/FFX/RSTOR  (
    .I0(\frame_cnt<2>/SRMUX_OUTPUTNOT ),
    .I1(GSR),
    .O(\frame_cnt<2>/FFX/RST )
  );
  X_FF frame_cnt_2 (
    .I(frame_cnt__n0000[2]),
    .CE(VCC),
    .CLK(\frame_cnt<2>/CKMUXNOT ),
    .SET(GND),
    .RST(\frame_cnt<2>/FFX/RST ),
    .O(frame_cnt[2])
  );
  X_BUF \frame_cnt<4>/CYINIT_72  (
    .I(\frame_cnt<2>/CYMUXG ),
    .O(\frame_cnt<4>/CYINIT )
  );
  X_INV \frame_cnt<4>/SRMUX  (
    .I(reset_IBUF),
    .O(\frame_cnt<4>/SRMUX_OUTPUTNOT )
  );
  X_XOR2 frame_cnt_Madd__n0000_inst_sum_10 (
    .I0(frame_cnt_Madd__n0000_inst_cy_9),
    .I1(\frame_cnt<4>/GROM ),
    .O(frame_cnt__n0000[5])
  );
  X_MUX2 frame_cnt_Madd__n0000_inst_cy_10 (
    .IA(\frame_cnt<4>/LOGIC_ZERO ),
    .IB(frame_cnt_Madd__n0000_inst_cy_9),
    .SEL(\frame_cnt<4>/GROM ),
    .O(\frame_cnt<4>/CYMUXG )
  );
  X_INV \frame_cnt<4>/CKINV  (
    .I(clk_in_BUFGP),
    .O(\frame_cnt<4>/CKMUXNOT )
  );
  defparam \frame_cnt<4>/G .INIT = 16'hF0F0;
  X_LUT4 \frame_cnt<4>/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(frame_cnt[5]),
    .ADR3(VCC),
    .O(\frame_cnt<4>/GROM )
  );
  defparam \frame_cnt<4>/F .INIT = 16'hCCCC;
  X_LUT4 \frame_cnt<4>/F  (
    .ADR0(VCC),
    .ADR1(frame_cnt[4]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\frame_cnt<4>/FROM )
  );
  X_XOR2 frame_cnt_Madd__n0000_inst_sum_9 (
    .I0(\frame_cnt<4>/CYINIT ),
    .I1(\frame_cnt<4>/FROM ),
    .O(frame_cnt__n0000[4])
  );
  X_MUX2 frame_cnt_Madd__n0000_inst_cy_9_73 (
    .IA(\frame_cnt<4>/LOGIC_ZERO ),
    .IB(\frame_cnt<4>/CYINIT ),
    .SEL(\frame_cnt<4>/FROM ),
    .O(frame_cnt_Madd__n0000_inst_cy_9)
  );
  X_ZERO \frame_cnt<4>/LOGIC_ZERO_74  (
    .O(\frame_cnt<4>/LOGIC_ZERO )
  );
  X_OR2 \frame_cnt<4>/FFX/RSTOR  (
    .I0(\frame_cnt<4>/SRMUX_OUTPUTNOT ),
    .I1(GSR),
    .O(\frame_cnt<4>/FFX/RST )
  );
  X_FF frame_cnt_4 (
    .I(frame_cnt__n0000[4]),
    .CE(VCC),
    .CLK(\frame_cnt<4>/CKMUXNOT ),
    .SET(GND),
    .RST(\frame_cnt<4>/FFX/RST ),
    .O(frame_cnt[4])
  );
  X_OR2 \frame_cnt<4>/FFY/RSTOR  (
    .I0(\frame_cnt<4>/SRMUX_OUTPUTNOT ),
    .I1(GSR),
    .O(\frame_cnt<4>/FFY/RST )
  );
  X_FF frame_cnt_5 (
    .I(frame_cnt__n0000[5]),
    .CE(VCC),
    .CLK(\frame_cnt<4>/CKMUXNOT ),
    .SET(GND),
    .RST(\frame_cnt<4>/FFY/RST ),
    .O(frame_cnt[5])
  );
  X_BUF \frame_cnt<6>/CYINIT_75  (
    .I(\frame_cnt<4>/CYMUXG ),
    .O(\frame_cnt<6>/CYINIT )
  );
  X_INV \frame_cnt<6>/SRMUX  (
    .I(reset_IBUF),
    .O(\frame_cnt<6>/SRMUX_OUTPUTNOT )
  );
  X_XOR2 frame_cnt_Madd__n0000_inst_sum_12 (
    .I0(frame_cnt_Madd__n0000_inst_cy_11),
    .I1(\frame_cnt<6>/GROM ),
    .O(frame_cnt__n0000[7])
  );
  X_MUX2 frame_cnt_Madd__n0000_inst_cy_12 (
    .IA(\frame_cnt<6>/LOGIC_ZERO ),
    .IB(frame_cnt_Madd__n0000_inst_cy_11),
    .SEL(\frame_cnt<6>/GROM ),
    .O(\frame_cnt<6>/CYMUXG )
  );
  X_INV \frame_cnt<6>/CKINV  (
    .I(clk_in_BUFGP),
    .O(\frame_cnt<6>/CKMUXNOT )
  );
  defparam \frame_cnt<6>/G .INIT = 16'hF0F0;
  X_LUT4 \frame_cnt<6>/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(frame_cnt[7]),
    .ADR3(VCC),
    .O(\frame_cnt<6>/GROM )
  );
  defparam \frame_cnt<6>/F .INIT = 16'hCCCC;
  X_LUT4 \frame_cnt<6>/F  (
    .ADR0(VCC),
    .ADR1(frame_cnt[6]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\frame_cnt<6>/FROM )
  );
  X_XOR2 frame_cnt_Madd__n0000_inst_sum_11 (
    .I0(\frame_cnt<6>/CYINIT ),
    .I1(\frame_cnt<6>/FROM ),
    .O(frame_cnt__n0000[6])
  );
  X_MUX2 frame_cnt_Madd__n0000_inst_cy_11_76 (
    .IA(\frame_cnt<6>/LOGIC_ZERO ),
    .IB(\frame_cnt<6>/CYINIT ),
    .SEL(\frame_cnt<6>/FROM ),
    .O(frame_cnt_Madd__n0000_inst_cy_11)
  );
  X_ZERO \frame_cnt<6>/LOGIC_ZERO_77  (
    .O(\frame_cnt<6>/LOGIC_ZERO )
  );
  X_OR2 \frame_cnt<6>/FFX/RSTOR  (
    .I0(\frame_cnt<6>/SRMUX_OUTPUTNOT ),
    .I1(GSR),
    .O(\frame_cnt<6>/FFX/RST )
  );
  X_FF frame_cnt_6 (
    .I(frame_cnt__n0000[6]),
    .CE(VCC),
    .CLK(\frame_cnt<6>/CKMUXNOT ),
    .SET(GND),
    .RST(\frame_cnt<6>/FFX/RST ),
    .O(frame_cnt[6])
  );
  X_OR2 \frame_cnt<6>/FFY/RSTOR  (
    .I0(\frame_cnt<6>/SRMUX_OUTPUTNOT ),
    .I1(GSR),
    .O(\frame_cnt<6>/FFY/RST )
  );
  X_FF frame_cnt_7 (
    .I(frame_cnt__n0000[7]),
    .CE(VCC),
    .CLK(\frame_cnt<6>/CKMUXNOT ),
    .SET(GND),
    .RST(\frame_cnt<6>/FFY/RST ),
    .O(frame_cnt[7])
  );
  X_BUF \frame_cnt<8>/CYINIT_78  (
    .I(\frame_cnt<6>/CYMUXG ),
    .O(\frame_cnt<8>/CYINIT )
  );
  X_INV \frame_cnt<8>/SRMUX  (
    .I(reset_IBUF),
    .O(\frame_cnt<8>/SRMUX_OUTPUTNOT )
  );
  X_INV \frame_cnt<8>/CKINV  (
    .I(clk_in_BUFGP),
    .O(\frame_cnt<8>/CKMUXNOT )
  );
  defparam \frame_cnt<8>_rt_79 .INIT = 16'hAAAA;
  X_LUT4 \frame_cnt<8>_rt_79  (
    .ADR0(frame_cnt[8]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\frame_cnt<8>_rt )
  );
  X_XOR2 frame_cnt_Madd__n0000_inst_sum_13 (
    .I0(\frame_cnt<8>/CYINIT ),
    .I1(\frame_cnt<8>_rt ),
    .O(frame_cnt__n0000[8])
  );
  X_OR2 \frame_cnt<8>/FFX/RSTOR  (
    .I0(\frame_cnt<8>/SRMUX_OUTPUTNOT ),
    .I1(GSR),
    .O(\frame_cnt<8>/FFX/RST )
  );
  X_FF frame_cnt_8 (
    .I(frame_cnt__n0000[8]),
    .CE(VCC),
    .CLK(\frame_cnt<8>/CKMUXNOT ),
    .SET(GND),
    .RST(\frame_cnt<8>/FFX/RST ),
    .O(frame_cnt[8])
  );
  X_BUF \rx_buf_reg_0<1>/YUSED  (
    .I(\rx_buf_reg_0<1>/GROM ),
    .O(\_n00631/O )
  );
  defparam _n00631.INIT = 16'h0F00;
  X_LUT4 _n00631 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(frame_delay_cnt_0_1_0),
    .ADR3(frame_delay_cnt_0_0_0),
    .O(\rx_buf_reg_0<1>/GROM )
  );
  X_BUF \rx_buf_reg_0<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_0<1>/FFY/RST )
  );
  X_FF rx_buf_reg_0_0 (
    .I(rx_shift_reg_0[0]),
    .CE(\_n00631/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_0<1>/FFY/RST ),
    .O(rx_buf_reg_0[0])
  );
  X_BUF \rx_buf_reg_0<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_0<1>/FFX/RST )
  );
  X_FF rx_buf_reg_0_1 (
    .I(rx_shift_reg_0[1]),
    .CE(\_n00631/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_0<1>/FFX/RST ),
    .O(rx_buf_reg_0[1])
  );
  X_BUF \rx_buf_reg_1<1>/YUSED  (
    .I(\rx_buf_reg_1<1>/GROM ),
    .O(\_n00621/O )
  );
  defparam _n00621.INIT = 16'h5500;
  X_LUT4 _n00621 (
    .ADR0(frame_delay_cnt_1_1_0),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(frame_delay_cnt_1_0_0),
    .O(\rx_buf_reg_1<1>/GROM )
  );
  X_BUF \rx_buf_reg_1<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_1<1>/FFY/RST )
  );
  X_FF rx_buf_reg_1_0 (
    .I(rx_shift_reg_1[0]),
    .CE(\_n00621/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_1<1>/FFY/RST ),
    .O(rx_buf_reg_1[0])
  );
  X_BUF \rx_buf_reg_1<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_1<1>/FFX/RST )
  );
  X_FF rx_buf_reg_1_1 (
    .I(rx_shift_reg_1[1]),
    .CE(\_n00621/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_1<1>/FFX/RST ),
    .O(rx_buf_reg_1[1])
  );
  X_BUF \rx_buf_reg_2<1>/YUSED  (
    .I(\rx_buf_reg_2<1>/GROM ),
    .O(\_n00611/O )
  );
  defparam _n00611.INIT = 16'h0C0C;
  X_LUT4 _n00611 (
    .ADR0(VCC),
    .ADR1(frame_delay_cnt_2_0_0),
    .ADR2(frame_delay_cnt_2_1_0),
    .ADR3(VCC),
    .O(\rx_buf_reg_2<1>/GROM )
  );
  X_BUF \rx_buf_reg_2<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_2<1>/FFX/RST )
  );
  X_FF rx_buf_reg_2_1 (
    .I(rx_shift_reg_2[1]),
    .CE(\_n00611/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_2<1>/FFX/RST ),
    .O(rx_buf_reg_2[1])
  );
  X_BUF \rx_buf_reg_2<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_2<1>/FFY/RST )
  );
  X_FF rx_buf_reg_2_0 (
    .I(rx_shift_reg_2[0]),
    .CE(\_n00611/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_2<1>/FFY/RST ),
    .O(rx_buf_reg_2[0])
  );
  X_BUF \rx_buf_reg_3<1>/YUSED  (
    .I(\rx_buf_reg_3<1>/GROM ),
    .O(\_n00601/O )
  );
  defparam _n00601.INIT = 16'h4444;
  X_LUT4 _n00601 (
    .ADR0(frame_delay_cnt_3_1_0),
    .ADR1(frame_delay_cnt_3_0_0),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\rx_buf_reg_3<1>/GROM )
  );
  X_BUF \rx_buf_reg_3<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_3<1>/FFX/RST )
  );
  X_FF rx_buf_reg_3_1 (
    .I(rx_shift_reg_3[1]),
    .CE(\_n00601/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_3<1>/FFX/RST ),
    .O(rx_buf_reg_3[1])
  );
  X_BUF \rx_buf_reg_3<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_3<1>/FFY/RST )
  );
  X_FF rx_buf_reg_3_0 (
    .I(rx_shift_reg_3[0]),
    .CE(\_n00601/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_3<1>/FFY/RST ),
    .O(rx_buf_reg_3[0])
  );
  X_BUF \rx_buf_reg_4<1>/YUSED  (
    .I(\rx_buf_reg_4<1>/GROM ),
    .O(\_n00591/O )
  );
  defparam _n00591.INIT = 16'h0F00;
  X_LUT4 _n00591 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(frame_delay_cnt_4_1_0),
    .ADR3(frame_delay_cnt_4_0_0),
    .O(\rx_buf_reg_4<1>/GROM )
  );
  X_BUF \rx_buf_reg_4<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_4<1>/FFX/RST )
  );
  X_FF rx_buf_reg_4_1 (
    .I(rx_shift_reg_4[1]),
    .CE(\_n00591/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_4<1>/FFX/RST ),
    .O(rx_buf_reg_4[1])
  );
  X_BUF \rx_buf_reg_4<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_4<1>/FFY/RST )
  );
  X_FF rx_buf_reg_4_0 (
    .I(rx_shift_reg_4[0]),
    .CE(\_n00591/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_4<1>/FFY/RST ),
    .O(rx_buf_reg_4[0])
  );
  X_BUF \rx_buf_reg_5<1>/YUSED  (
    .I(\rx_buf_reg_5<1>/GROM ),
    .O(\_n00581/O )
  );
  defparam _n00581.INIT = 16'h0F00;
  X_LUT4 _n00581 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(frame_delay_cnt_5_1_0),
    .ADR3(frame_delay_cnt_5_0_0),
    .O(\rx_buf_reg_5<1>/GROM )
  );
  X_BUF \rx_buf_reg_5<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_5<1>/FFY/RST )
  );
  X_FF rx_buf_reg_5_0 (
    .I(rx_shift_reg_5[0]),
    .CE(\_n00581/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_5<1>/FFY/RST ),
    .O(rx_buf_reg_5[0])
  );
  X_BUF \rx_buf_reg_5<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_5<1>/FFX/RST )
  );
  X_FF rx_buf_reg_5_1 (
    .I(rx_shift_reg_5[1]),
    .CE(\_n00581/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_5<1>/FFX/RST ),
    .O(rx_buf_reg_5[1])
  );
  X_BUF \rx_buf_reg_6<1>/YUSED  (
    .I(\rx_buf_reg_6<1>/GROM ),
    .O(\_n00571/O )
  );
  defparam _n00571.INIT = 16'h00F0;
  X_LUT4 _n00571 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(frame_delay_cnt_6_0_0),
    .ADR3(frame_delay_cnt_6_1_0),
    .O(\rx_buf_reg_6<1>/GROM )
  );
  X_BUF \rx_buf_reg_6<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_6<1>/FFY/RST )
  );
  X_FF rx_buf_reg_6_0 (
    .I(rx_shift_reg_6[0]),
    .CE(\_n00571/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_6<1>/FFY/RST ),
    .O(rx_buf_reg_6[0])
  );
  X_BUF \rx_buf_reg_6<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_6<1>/FFX/RST )
  );
  X_FF rx_buf_reg_6_1 (
    .I(rx_shift_reg_6[1]),
    .CE(\_n00571/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_6<1>/FFX/RST ),
    .O(rx_buf_reg_6[1])
  );
  X_BUF \rx_buf_reg_7<1>/YUSED  (
    .I(\rx_buf_reg_7<1>/GROM ),
    .O(\_n00561/O )
  );
  defparam _n00561.INIT = 16'h0F00;
  X_LUT4 _n00561 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(frame_delay_cnt_7_1_0),
    .ADR3(frame_delay_cnt_7_0_0),
    .O(\rx_buf_reg_7<1>/GROM )
  );
  X_BUF \rx_buf_reg_7<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_7<1>/FFY/RST )
  );
  X_FF rx_buf_reg_7_0 (
    .I(rx_shift_reg_7[0]),
    .CE(\_n00561/O ),
    .CLK(div_reg_2),
    .SET(GND),
    .RST(\rx_buf_reg_7<1>/FFY/RST ),
    .O(rx_buf_reg_7[0])
  );
  X_BUF \rx_buf_reg_7<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_7<1>/FFX/RST )
  );
  X_FF rx_buf_reg_7_1 (
    .I(rx_shift_reg_7[1]),
    .CE(\_n00561/O ),
    .CLK(div_reg_2),
    .SET(GND),
    .RST(\rx_buf_reg_7<1>/FFX/RST ),
    .O(rx_buf_reg_7[1])
  );
  X_BUF \tx_buf_reg_4<1>/YUSED  (
    .I(\tx_buf_reg_4<1>/GROM ),
    .O(\_n00311/O )
  );
  defparam _n00311.INIT = 16'h0400;
  X_LUT4 _n00311 (
    .ADR0(frame_cnt[3]),
    .ADR1(frame_cnt[2]),
    .ADR2(frame_cnt[0]),
    .ADR3(frame_cnt[1]),
    .O(\tx_buf_reg_4<1>/GROM )
  );
  X_BUF \tx_buf_reg_4<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_4<1>/FFY/RST )
  );
  X_FF tx_buf_reg_4_0 (
    .I(data_out_bus[0]),
    .CE(\_n00311/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_4<1>/FFY/RST ),
    .O(tx_buf_reg_4[0])
  );
  X_BUF \tx_buf_reg_4<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_4<1>/FFX/RST )
  );
  X_FF tx_buf_reg_4_1 (
    .I(data_out_bus[1]),
    .CE(\_n00311/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_4<1>/FFX/RST ),
    .O(tx_buf_reg_4[1])
  );
  X_BUF \tx_buf_reg_5<1>/YUSED  (
    .I(\tx_buf_reg_5<1>/GROM ),
    .O(\_n00321/O )
  );
  defparam _n00321.INIT = 16'h0080;
  X_LUT4 _n00321 (
    .ADR0(frame_cnt[1]),
    .ADR1(frame_cnt[0]),
    .ADR2(frame_cnt[2]),
    .ADR3(frame_cnt[3]),
    .O(\tx_buf_reg_5<1>/GROM )
  );
  X_BUF \tx_buf_reg_5<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_5<1>/FFY/RST )
  );
  X_FF tx_buf_reg_5_0 (
    .I(data_out_bus[0]),
    .CE(\_n00321/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_5<1>/FFY/RST ),
    .O(tx_buf_reg_5[0])
  );
  X_BUF \tx_buf_reg_5<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_5<1>/FFX/RST )
  );
  X_FF tx_buf_reg_5_1 (
    .I(data_out_bus[1]),
    .CE(\_n00321/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_5<1>/FFX/RST ),
    .O(tx_buf_reg_5[1])
  );
  defparam Mmux__n0019_I6_Result1.INIT = 16'hD8D8;
  X_LUT4 Mmux__n0019_I6_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(tx_buf_reg_0[1]),
    .ADR2(tx_shift_reg_0[2]),
    .ADR3(VCC),
    .O(_n0019[1])
  );
  defparam Mmux__n0019_I5_Result1.INIT = 16'hAFA0;
  X_LUT4 Mmux__n0019_I5_Result1 (
    .ADR0(tx_buf_reg_0[2]),
    .ADR1(VCC),
    .ADR2(Ker87891_1),
    .ADR3(tx_shift_reg_0[3]),
    .O(_n0019[2])
  );
  X_BUF \tx_shift_reg_0<2>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_0<2>/FFY/RST )
  );
  X_FF tx_shift_reg_0_1 (
    .I(_n0019[1]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_0<2>/FFY/RST ),
    .O(tx_shift_reg_0[1])
  );
  X_BUF \tx_shift_reg_0<2>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_0<2>/FFX/RST )
  );
  X_FF tx_shift_reg_0_2 (
    .I(_n0019[2]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_0<2>/FFX/RST ),
    .O(tx_shift_reg_0[2])
  );
  defparam Mmux__n0019_I4_Result1.INIT = 16'hFA50;
  X_LUT4 Mmux__n0019_I4_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(VCC),
    .ADR2(tx_shift_reg_0[4]),
    .ADR3(tx_buf_reg_0[3]),
    .O(_n0019[3])
  );
  defparam Mmux__n0019_I3_Result1.INIT = 16'hCFC0;
  X_LUT4 Mmux__n0019_I3_Result1 (
    .ADR0(VCC),
    .ADR1(tx_buf_reg_0[4]),
    .ADR2(Ker87891_1),
    .ADR3(tx_shift_reg_0[5]),
    .O(_n0019[4])
  );
  X_BUF \tx_shift_reg_0<4>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_0<4>/FFY/RST )
  );
  X_FF tx_shift_reg_0_3 (
    .I(_n0019[3]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_0<4>/FFY/RST ),
    .O(tx_shift_reg_0[3])
  );
  X_BUF \tx_shift_reg_0<4>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_0<4>/FFX/RST )
  );
  X_FF tx_shift_reg_0_4 (
    .I(_n0019[4]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_0<4>/FFX/RST ),
    .O(tx_shift_reg_0[4])
  );
  defparam Mmux__n0020_I6_Result1.INIT = 16'hAFA0;
  X_LUT4 Mmux__n0020_I6_Result1 (
    .ADR0(tx_buf_reg_1[1]),
    .ADR1(VCC),
    .ADR2(Ker87891_1),
    .ADR3(tx_shift_reg_1[2]),
    .O(_n0020[1])
  );
  defparam Mmux__n0020_I5_Result1.INIT = 16'hF3C0;
  X_LUT4 Mmux__n0020_I5_Result1 (
    .ADR0(VCC),
    .ADR1(Ker87891_1),
    .ADR2(tx_buf_reg_1[2]),
    .ADR3(tx_shift_reg_1[3]),
    .O(_n0020[2])
  );
  X_BUF \tx_shift_reg_1<2>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_1<2>/FFY/RST )
  );
  X_FF tx_shift_reg_1_1 (
    .I(_n0020[1]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_1<2>/FFY/RST ),
    .O(tx_shift_reg_1[1])
  );
  X_BUF \tx_shift_reg_1<2>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_1<2>/FFX/RST )
  );
  X_FF tx_shift_reg_1_2 (
    .I(_n0020[2]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_1<2>/FFX/RST ),
    .O(tx_shift_reg_1[2])
  );
  defparam Mmux__n0019_I2_Result1.INIT = 16'hFA50;
  X_LUT4 Mmux__n0019_I2_Result1 (
    .ADR0(N8791),
    .ADR1(VCC),
    .ADR2(tx_shift_reg_0[6]),
    .ADR3(tx_buf_reg_0[5]),
    .O(_n0019[5])
  );
  defparam Mmux__n0019_I1_Result1.INIT = 16'hE4E4;
  X_LUT4 Mmux__n0019_I1_Result1 (
    .ADR0(N8791),
    .ADR1(tx_shift_reg_0[7]),
    .ADR2(tx_buf_reg_0[6]),
    .ADR3(VCC),
    .O(_n0019[6])
  );
  X_BUF \tx_shift_reg_0<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_0<6>/FFY/RST )
  );
  X_FF tx_shift_reg_0_5 (
    .I(_n0019[5]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_0<6>/FFY/RST ),
    .O(tx_shift_reg_0[5])
  );
  X_BUF \tx_shift_reg_0<6>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_0<6>/FFX/RST )
  );
  X_FF tx_shift_reg_0_6 (
    .I(_n0019[6]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_0<6>/FFX/RST ),
    .O(tx_shift_reg_0[6])
  );
  X_BUF \tx_shift_reg_0<7>/XUSED  (
    .I(\tx_shift_reg_0<7>/FROM ),
    .O(N8791)
  );
  defparam Mmux__n0019_I0_Result1.INIT = 16'hF000;
  X_LUT4 Mmux__n0019_I0_Result1 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(tx_buf_reg_0[7]),
    .ADR3(N8791),
    .O(_n0019[7])
  );
  defparam Ker87891.INIT = 16'h1000;
  X_LUT4 Ker87891 (
    .ADR0(frame_cnt[0]),
    .ADR1(frame_cnt[2]),
    .ADR2(frame_cnt[3]),
    .ADR3(frame_cnt_1_1),
    .O(\tx_shift_reg_0<7>/FROM )
  );
  X_BUF \tx_shift_reg_0<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_0<7>/FFY/RST )
  );
  X_FF tx_shift_reg_0_7 (
    .I(_n0019[7]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_0<7>/FFY/RST ),
    .O(tx_shift_reg_0[7])
  );
  defparam Mmux__n0020_I4_Result1.INIT = 16'hCCF0;
  X_LUT4 Mmux__n0020_I4_Result1 (
    .ADR0(VCC),
    .ADR1(tx_buf_reg_1[3]),
    .ADR2(tx_shift_reg_1[4]),
    .ADR3(Ker87891_1),
    .O(_n0020[3])
  );
  defparam Mmux__n0020_I3_Result1.INIT = 16'hAACC;
  X_LUT4 Mmux__n0020_I3_Result1 (
    .ADR0(tx_buf_reg_1[4]),
    .ADR1(tx_shift_reg_1[5]),
    .ADR2(VCC),
    .ADR3(Ker87891_1),
    .O(_n0020[4])
  );
  X_BUF \tx_shift_reg_1<4>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_1<4>/FFX/RST )
  );
  X_FF tx_shift_reg_1_4 (
    .I(_n0020[4]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_1<4>/FFX/RST ),
    .O(tx_shift_reg_1[4])
  );
  X_BUF \tx_shift_reg_1<4>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_1<4>/FFY/RST )
  );
  X_FF tx_shift_reg_1_3 (
    .I(_n0020[3]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_1<4>/FFY/RST ),
    .O(tx_shift_reg_1[3])
  );
  defparam Mmux__n0021_I6_Result1.INIT = 16'hFA50;
  X_LUT4 Mmux__n0021_I6_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(VCC),
    .ADR2(tx_shift_reg_2[2]),
    .ADR3(tx_buf_reg_2[1]),
    .O(_n0021[1])
  );
  defparam Mmux__n0021_I5_Result1.INIT = 16'hD8D8;
  X_LUT4 Mmux__n0021_I5_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(tx_buf_reg_2[2]),
    .ADR2(tx_shift_reg_2[3]),
    .ADR3(VCC),
    .O(_n0021[2])
  );
  defparam Mmux__n0020_I2_Result1.INIT = 16'hF5A0;
  X_LUT4 Mmux__n0020_I2_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(VCC),
    .ADR2(tx_buf_reg_1[5]),
    .ADR3(tx_shift_reg_1[6]),
    .O(_n0020[5])
  );
  defparam Mmux__n0020_I1_Result1.INIT = 16'hDD88;
  X_LUT4 Mmux__n0020_I1_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(tx_buf_reg_1[6]),
    .ADR2(VCC),
    .ADR3(tx_shift_reg_1[7]),
    .O(_n0020[6])
  );
  defparam Mmux__n0021_I4_Result1.INIT = 16'hFC0C;
  X_LUT4 Mmux__n0021_I4_Result1 (
    .ADR0(VCC),
    .ADR1(tx_shift_reg_2[4]),
    .ADR2(Ker87891_1),
    .ADR3(tx_buf_reg_2[3]),
    .O(_n0021[3])
  );
  defparam Mmux__n0021_I3_Result1.INIT = 16'hCFC0;
  X_LUT4 Mmux__n0021_I3_Result1 (
    .ADR0(VCC),
    .ADR1(tx_buf_reg_2[4]),
    .ADR2(Ker87891_1),
    .ADR3(tx_shift_reg_2[5]),
    .O(_n0021[4])
  );
  defparam Mmux__n0020_I0_Result1.INIT = 16'hAA00;
  X_LUT4 Mmux__n0020_I0_Result1 (
    .ADR0(tx_buf_reg_1[7]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(Ker87891_1),
    .O(_n0020[7])
  );
  defparam Mmux__n0021_I0_Result1.INIT = 16'hF000;
  X_LUT4 Mmux__n0021_I0_Result1 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(Ker87891_1),
    .ADR3(tx_buf_reg_2[7]),
    .O(_n0021[7])
  );
  defparam Mmux__n0021_I2_Result1.INIT = 16'hF0CC;
  X_LUT4 Mmux__n0021_I2_Result1 (
    .ADR0(VCC),
    .ADR1(tx_shift_reg_2[6]),
    .ADR2(tx_buf_reg_2[5]),
    .ADR3(Ker87891_1),
    .O(_n0021[5])
  );
  defparam Mmux__n0021_I1_Result1.INIT = 16'hEE44;
  X_LUT4 Mmux__n0021_I1_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(tx_shift_reg_2[7]),
    .ADR2(VCC),
    .ADR3(tx_buf_reg_2[6]),
    .O(_n0021[6])
  );
  defparam Mmux__n0022_I6_Result1.INIT = 16'hF3C0;
  X_LUT4 Mmux__n0022_I6_Result1 (
    .ADR0(VCC),
    .ADR1(Ker87891_1),
    .ADR2(tx_buf_reg_3[1]),
    .ADR3(tx_shift_reg_3[2]),
    .O(_n0022[1])
  );
  defparam Mmux__n0022_I5_Result1.INIT = 16'hE2E2;
  X_LUT4 Mmux__n0022_I5_Result1 (
    .ADR0(tx_shift_reg_3[3]),
    .ADR1(Ker87891_1),
    .ADR2(tx_buf_reg_3[2]),
    .ADR3(VCC),
    .O(_n0022[2])
  );
  defparam Mmux__n0022_I4_Result1.INIT = 16'hFC30;
  X_LUT4 Mmux__n0022_I4_Result1 (
    .ADR0(VCC),
    .ADR1(Ker87891_1),
    .ADR2(tx_shift_reg_3[4]),
    .ADR3(tx_buf_reg_3[3]),
    .O(_n0022[3])
  );
  defparam Mmux__n0022_I3_Result1.INIT = 16'hAFA0;
  X_LUT4 Mmux__n0022_I3_Result1 (
    .ADR0(tx_buf_reg_3[4]),
    .ADR1(VCC),
    .ADR2(Ker87891_1),
    .ADR3(tx_shift_reg_3[5]),
    .O(_n0022[4])
  );
  defparam Mmux__n0022_I2_Result1.INIT = 16'hFC0C;
  X_LUT4 Mmux__n0022_I2_Result1 (
    .ADR0(VCC),
    .ADR1(tx_shift_reg_3[6]),
    .ADR2(Ker87891_1),
    .ADR3(tx_buf_reg_3[5]),
    .O(_n0022[5])
  );
  defparam Mmux__n0022_I1_Result1.INIT = 16'hFA50;
  X_LUT4 Mmux__n0022_I1_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(VCC),
    .ADR2(tx_shift_reg_3[7]),
    .ADR3(tx_buf_reg_3[6]),
    .O(_n0022[6])
  );
  defparam Mmux__n0023_I6_Result1.INIT = 16'hDD88;
  X_LUT4 Mmux__n0023_I6_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(tx_buf_reg_4[1]),
    .ADR2(VCC),
    .ADR3(tx_shift_reg_4[2]),
    .O(_n0023[1])
  );
  defparam Mmux__n0023_I5_Result1.INIT = 16'hF0CC;
  X_LUT4 Mmux__n0023_I5_Result1 (
    .ADR0(VCC),
    .ADR1(tx_shift_reg_4[3]),
    .ADR2(tx_buf_reg_4[2]),
    .ADR3(Ker87891_1),
    .O(_n0023[2])
  );
  defparam Mmux__n0023_I4_Result1.INIT = 16'hF5A0;
  X_LUT4 Mmux__n0023_I4_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(VCC),
    .ADR2(tx_buf_reg_4[3]),
    .ADR3(tx_shift_reg_4[4]),
    .O(_n0023[3])
  );
  defparam Mmux__n0023_I3_Result1.INIT = 16'hCACA;
  X_LUT4 Mmux__n0023_I3_Result1 (
    .ADR0(tx_shift_reg_4[5]),
    .ADR1(tx_buf_reg_4[4]),
    .ADR2(Ker87891_1),
    .ADR3(VCC),
    .O(_n0023[4])
  );
  defparam Mmux__n0022_I0_Result1.INIT = 16'hC0C0;
  X_LUT4 Mmux__n0022_I0_Result1 (
    .ADR0(VCC),
    .ADR1(Ker87891_1),
    .ADR2(tx_buf_reg_3[7]),
    .ADR3(VCC),
    .O(_n0022[7])
  );
  defparam Mmux__n0023_I0_Result1.INIT = 16'hA0A0;
  X_LUT4 Mmux__n0023_I0_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(VCC),
    .ADR2(tx_buf_reg_4[7]),
    .ADR3(VCC),
    .O(_n0023[7])
  );
  defparam Mmux__n0023_I2_Result1.INIT = 16'hFC0C;
  X_LUT4 Mmux__n0023_I2_Result1 (
    .ADR0(VCC),
    .ADR1(tx_shift_reg_4[6]),
    .ADR2(Ker87891_1),
    .ADR3(tx_buf_reg_4[5]),
    .O(_n0023[5])
  );
  defparam Mmux__n0023_I1_Result1.INIT = 16'hCFC0;
  X_LUT4 Mmux__n0023_I1_Result1 (
    .ADR0(VCC),
    .ADR1(tx_buf_reg_4[6]),
    .ADR2(Ker87891_1),
    .ADR3(tx_shift_reg_4[7]),
    .O(_n0023[6])
  );
  defparam Mmux__n0024_I6_Result1.INIT = 16'hFA50;
  X_LUT4 Mmux__n0024_I6_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(VCC),
    .ADR2(tx_shift_reg_5[2]),
    .ADR3(tx_buf_reg_5[1]),
    .O(_n0024[1])
  );
  defparam Mmux__n0024_I5_Result1.INIT = 16'hBB88;
  X_LUT4 Mmux__n0024_I5_Result1 (
    .ADR0(tx_buf_reg_5[2]),
    .ADR1(Ker87891_1),
    .ADR2(VCC),
    .ADR3(tx_shift_reg_5[3]),
    .O(_n0024[2])
  );
  defparam Mmux__n0024_I4_Result1.INIT = 16'hCCF0;
  X_LUT4 Mmux__n0024_I4_Result1 (
    .ADR0(VCC),
    .ADR1(tx_buf_reg_5[3]),
    .ADR2(tx_shift_reg_5[4]),
    .ADR3(Ker87891_1),
    .O(_n0024[3])
  );
  defparam Mmux__n0024_I3_Result1.INIT = 16'hE4E4;
  X_LUT4 Mmux__n0024_I3_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(tx_shift_reg_5[5]),
    .ADR2(tx_buf_reg_5[4]),
    .ADR3(VCC),
    .O(_n0024[4])
  );
  defparam Mmux__n0024_I2_Result1.INIT = 16'hF5A0;
  X_LUT4 Mmux__n0024_I2_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(VCC),
    .ADR2(tx_buf_reg_5[5]),
    .ADR3(tx_shift_reg_5[6]),
    .O(_n0024[5])
  );
  defparam Mmux__n0024_I1_Result1.INIT = 16'hBB88;
  X_LUT4 Mmux__n0024_I1_Result1 (
    .ADR0(tx_buf_reg_5[6]),
    .ADR1(Ker87891_1),
    .ADR2(VCC),
    .ADR3(tx_shift_reg_5[7]),
    .O(_n0024[6])
  );
  defparam Mmux__n0025_I6_Result1.INIT = 16'hCCF0;
  X_LUT4 Mmux__n0025_I6_Result1 (
    .ADR0(VCC),
    .ADR1(tx_buf_reg_6[1]),
    .ADR2(tx_shift_reg_6[2]),
    .ADR3(Ker87891_1),
    .O(_n0025[1])
  );
  defparam Mmux__n0025_I5_Result1.INIT = 16'hF3C0;
  X_LUT4 Mmux__n0025_I5_Result1 (
    .ADR0(VCC),
    .ADR1(Ker87891_1),
    .ADR2(tx_buf_reg_6[2]),
    .ADR3(tx_shift_reg_6[3]),
    .O(_n0025[2])
  );
  defparam Mmux__n0025_I4_Result1.INIT = 16'hFA50;
  X_LUT4 Mmux__n0025_I4_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(VCC),
    .ADR2(tx_shift_reg_6[4]),
    .ADR3(tx_buf_reg_6[3]),
    .O(_n0025[3])
  );
  defparam Mmux__n0025_I3_Result1.INIT = 16'hF5A0;
  X_LUT4 Mmux__n0025_I3_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(VCC),
    .ADR2(tx_buf_reg_6[4]),
    .ADR3(tx_shift_reg_6[5]),
    .O(_n0025[4])
  );
  X_BUF \tx_shift_reg_6<4>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_6<4>/FFX/RST )
  );
  X_FF tx_shift_reg_6_4 (
    .I(_n0025[4]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_6<4>/FFX/RST ),
    .O(tx_shift_reg_6[4])
  );
  X_BUF \tx_shift_reg_6<4>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_6<4>/FFY/RST )
  );
  X_FF tx_shift_reg_6_3 (
    .I(_n0025[3]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_6<4>/FFY/RST ),
    .O(tx_shift_reg_6[3])
  );
  defparam Mmux__n0024_I0_Result1.INIT = 16'hC0C0;
  X_LUT4 Mmux__n0024_I0_Result1 (
    .ADR0(VCC),
    .ADR1(Ker87891_1),
    .ADR2(tx_buf_reg_5[7]),
    .ADR3(VCC),
    .O(_n0024[7])
  );
  defparam Mmux__n0025_I0_Result1.INIT = 16'hAA00;
  X_LUT4 Mmux__n0025_I0_Result1 (
    .ADR0(tx_buf_reg_6[7]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(Ker87891_1),
    .O(_n0025[7])
  );
  defparam Mmux__n0025_I2_Result1.INIT = 16'hFC30;
  X_LUT4 Mmux__n0025_I2_Result1 (
    .ADR0(VCC),
    .ADR1(Ker87891_1),
    .ADR2(tx_shift_reg_6[6]),
    .ADR3(tx_buf_reg_6[5]),
    .O(_n0025[5])
  );
  defparam Mmux__n0025_I1_Result1.INIT = 16'hAACC;
  X_LUT4 Mmux__n0025_I1_Result1 (
    .ADR0(tx_buf_reg_6[6]),
    .ADR1(tx_shift_reg_6[7]),
    .ADR2(VCC),
    .ADR3(Ker87891_1),
    .O(_n0025[6])
  );
  X_BUF \tx_shift_reg_6<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_6<6>/FFY/RST )
  );
  X_FF tx_shift_reg_6_5 (
    .I(_n0025[5]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_6<6>/FFY/RST ),
    .O(tx_shift_reg_6[5])
  );
  X_BUF \tx_shift_reg_6<6>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_6<6>/FFX/RST )
  );
  X_FF tx_shift_reg_6_6 (
    .I(_n0025[6]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_6<6>/FFX/RST ),
    .O(tx_shift_reg_6[6])
  );
  defparam Mmux__n0026_I6_Result1.INIT = 16'hACAC;
  X_LUT4 Mmux__n0026_I6_Result1 (
    .ADR0(tx_buf_reg_7[1]),
    .ADR1(tx_shift_reg_7[2]),
    .ADR2(Ker87891_1),
    .ADR3(VCC),
    .O(_n0026[1])
  );
  defparam Mmux__n0026_I5_Result1.INIT = 16'hFC0C;
  X_LUT4 Mmux__n0026_I5_Result1 (
    .ADR0(VCC),
    .ADR1(tx_shift_reg_7[3]),
    .ADR2(Ker87891_1),
    .ADR3(tx_buf_reg_7[2]),
    .O(_n0026[2])
  );
  defparam Mmux__n0026_I4_Result1.INIT = 16'hB8B8;
  X_LUT4 Mmux__n0026_I4_Result1 (
    .ADR0(tx_buf_reg_7[3]),
    .ADR1(Ker87891_1),
    .ADR2(tx_shift_reg_7[4]),
    .ADR3(VCC),
    .O(_n0026[3])
  );
  defparam Mmux__n0026_I3_Result1.INIT = 16'hFA50;
  X_LUT4 Mmux__n0026_I3_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(VCC),
    .ADR2(tx_shift_reg_7[5]),
    .ADR3(tx_buf_reg_7[4]),
    .O(_n0026[4])
  );
  X_BUF \tx_shift_reg_7<4>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_7<4>/FFY/RST )
  );
  X_FF tx_shift_reg_7_3 (
    .I(_n0026[3]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_7<4>/FFY/RST ),
    .O(tx_shift_reg_7[3])
  );
  X_BUF \tx_shift_reg_7<4>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_7<4>/FFX/RST )
  );
  X_FF tx_shift_reg_7_4 (
    .I(_n0026[4]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_7<4>/FFX/RST ),
    .O(tx_shift_reg_7[4])
  );
  defparam Mmux__n0026_I2_Result1.INIT = 16'hAAF0;
  X_LUT4 Mmux__n0026_I2_Result1 (
    .ADR0(tx_buf_reg_7[5]),
    .ADR1(VCC),
    .ADR2(tx_shift_reg_7[6]),
    .ADR3(Ker87891_1),
    .O(_n0026[5])
  );
  defparam Mmux__n0026_I1_Result1.INIT = 16'hBB88;
  X_LUT4 Mmux__n0026_I1_Result1 (
    .ADR0(tx_buf_reg_7[6]),
    .ADR1(Ker87891_1),
    .ADR2(VCC),
    .ADR3(tx_shift_reg_7[7]),
    .O(_n0026[6])
  );
  X_BUF \tx_shift_reg_7<7>/XUSED  (
    .I(\tx_shift_reg_7<7>/FROM ),
    .O(Ker87891_1)
  );
  defparam Mmux__n0026_I0_Result1.INIT = 16'hF000;
  X_LUT4 Mmux__n0026_I0_Result1 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(tx_buf_reg_7[7]),
    .ADR3(Ker87891_1),
    .O(_n0026[7])
  );
  defparam Ker87891_1_80.INIT = 16'h0008;
  X_LUT4 Ker87891_1_80 (
    .ADR0(frame_cnt_1_1),
    .ADR1(frame_cnt[3]),
    .ADR2(frame_cnt[2]),
    .ADR3(frame_cnt[0]),
    .O(\tx_shift_reg_7<7>/FROM )
  );
  defparam Mmux__n0046_I1_Result1.INIT = 16'hCCF0;
  X_LUT4 Mmux__n0046_I1_Result1 (
    .ADR0(VCC),
    .ADR1(ctrl_out_reg[0]),
    .ADR2(_n0246[2]),
    .ADR3(N8682),
    .O(_n0046[0])
  );
  defparam Mmux__n0051_I8_Result1.INIT = 16'hAEA2;
  X_LUT4 Mmux__n0051_I8_Result1 (
    .ADR0(ctrl_out_reg[0]),
    .ADR1(mpi_cs_IBUF),
    .ADR2(mpi_addr_8_IBUF),
    .ADR3(mpi_mem_bus_out[0]),
    .O(\ctrl_out_reg<0>/FROM )
  );
  X_BUF \ctrl_out_reg<1>/XUSED  (
    .I(\ctrl_out_reg<1>/FROM ),
    .O(N8682)
  );
  defparam Mmux__n0046_I0_Result1.INIT = 16'hF0AA;
  X_LUT4 Mmux__n0046_I0_Result1 (
    .ADR0(_n0246[3]),
    .ADR1(VCC),
    .ADR2(ctrl_out_reg[1]),
    .ADR3(N8682),
    .O(_n0046[1])
  );
  defparam Ker86801.INIT = 16'hCFFF;
  X_LUT4 Ker86801 (
    .ADR0(VCC),
    .ADR1(mpi_addr_3_IBUF),
    .ADR2(mpi_cs_IBUF),
    .ADR3(mpi_addr_8_IBUF),
    .O(\ctrl_out_reg<1>/FROM )
  );
  X_INV \frame_delay_cnt_0_0_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_0_0_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_0_0_0/XUSED  (
    .I(\frame_delay_cnt_0_0_0/FROM ),
    .O(frame_delay_cnt_0_0_0__n0000)
  );
  defparam frame_delay_cnt_0_Mmux__n0001_I1_Result1.INIT = 16'h03CF;
  X_LUT4 frame_delay_cnt_0_Mmux__n0001_I1_Result1 (
    .ADR0(VCC),
    .ADR1(N8791),
    .ADR2(frame_delay_cnt_0_0_0),
    .ADR3(frame_delay_buf_0[0]),
    .O(frame_delay_cnt_0__n0001[0])
  );
  defparam frame_delay_cnt_0_0__n00001.INIT = 16'hCC00;
  X_LUT4 frame_delay_cnt_0_0__n00001 (
    .ADR0(VCC),
    .ADR1(N8791),
    .ADR2(VCC),
    .ADR3(frame_delay_buf_0[0]),
    .O(\frame_delay_cnt_0_0_0/FROM )
  );
  X_INV \frame_delay_cnt_0_1_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_0_1_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_0_1_0/XUSED  (
    .I(\frame_delay_cnt_0_1_0/FROM ),
    .O(N8676)
  );
  defparam frame_delay_cnt_0_Mmux__n0001_I0_Result1.INIT = 16'hED21;
  X_LUT4 frame_delay_cnt_0_Mmux__n0001_I0_Result1 (
    .ADR0(frame_delay_cnt_0_1_0),
    .ADR1(N8791),
    .ADR2(frame_delay_cnt_0_0_0),
    .ADR3(N8676),
    .O(frame_delay_cnt_0__n0001[1])
  );
  defparam Ker86741.INIT = 16'h0FF0;
  X_LUT4 Ker86741 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(frame_delay_buf_0[1]),
    .ADR3(frame_delay_buf_0[0]),
    .O(\frame_delay_cnt_0_1_0/FROM )
  );
  X_INV \frame_delay_cnt_1_0_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_1_0_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_1_0_0/XUSED  (
    .I(\frame_delay_cnt_1_0_0/FROM ),
    .O(frame_delay_cnt_1_0_0__n0000)
  );
  defparam frame_delay_cnt_1_Mmux__n0001_I1_Result1.INIT = 16'h2277;
  X_LUT4 frame_delay_cnt_1_Mmux__n0001_I1_Result1 (
    .ADR0(N8791),
    .ADR1(frame_delay_buf_1[0]),
    .ADR2(VCC),
    .ADR3(frame_delay_cnt_1_0_0),
    .O(frame_delay_cnt_1__n0001[0])
  );
  defparam frame_delay_cnt_1_0__n00001.INIT = 16'h8888;
  X_LUT4 frame_delay_cnt_1_0__n00001 (
    .ADR0(N8791),
    .ADR1(frame_delay_buf_1[0]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\frame_delay_cnt_1_0_0/FROM )
  );
  X_INV \frame_delay_cnt_1_1_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_1_1_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_1_1_0/XUSED  (
    .I(\frame_delay_cnt_1_1_0/FROM ),
    .O(N8670)
  );
  defparam frame_delay_cnt_1_Mmux__n0001_I0_Result1.INIT = 16'hF909;
  X_LUT4 frame_delay_cnt_1_Mmux__n0001_I0_Result1 (
    .ADR0(frame_delay_cnt_1_1_0),
    .ADR1(frame_delay_cnt_1_0_0),
    .ADR2(N8791),
    .ADR3(N8670),
    .O(frame_delay_cnt_1__n0001[1])
  );
  defparam Ker86681.INIT = 16'h5A5A;
  X_LUT4 Ker86681 (
    .ADR0(frame_delay_buf_1[0]),
    .ADR1(VCC),
    .ADR2(frame_delay_buf_1[1]),
    .ADR3(VCC),
    .O(\frame_delay_cnt_1_1_0/FROM )
  );
  X_INV \frame_delay_cnt_2_0_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_2_0_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_2_0_0/XUSED  (
    .I(\frame_delay_cnt_2_0_0/FROM ),
    .O(frame_delay_cnt_2_0_0__n0000)
  );
  defparam frame_delay_cnt_2_Mmux__n0001_I1_Result1.INIT = 16'h0A5F;
  X_LUT4 frame_delay_cnt_2_Mmux__n0001_I1_Result1 (
    .ADR0(N8791),
    .ADR1(VCC),
    .ADR2(frame_delay_buf_2[0]),
    .ADR3(frame_delay_cnt_2_0_0),
    .O(frame_delay_cnt_2__n0001[0])
  );
  defparam frame_delay_cnt_2_0__n00001.INIT = 16'hA0A0;
  X_LUT4 frame_delay_cnt_2_0__n00001 (
    .ADR0(N8791),
    .ADR1(VCC),
    .ADR2(frame_delay_buf_2[0]),
    .ADR3(VCC),
    .O(\frame_delay_cnt_2_0_0/FROM )
  );
  X_INV \frame_delay_cnt_2_1_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_2_1_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_2_1_0/XUSED  (
    .I(\frame_delay_cnt_2_1_0/FROM ),
    .O(N8664)
  );
  defparam frame_delay_cnt_2_Mmux__n0001_I0_Result1.INIT = 16'hED21;
  X_LUT4 frame_delay_cnt_2_Mmux__n0001_I0_Result1 (
    .ADR0(frame_delay_cnt_2_1_0),
    .ADR1(N8791),
    .ADR2(frame_delay_cnt_2_0_0),
    .ADR3(N8664),
    .O(frame_delay_cnt_2__n0001[1])
  );
  defparam Ker86621.INIT = 16'h6666;
  X_LUT4 Ker86621 (
    .ADR0(frame_delay_buf_2[1]),
    .ADR1(frame_delay_buf_2[0]),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\frame_delay_cnt_2_1_0/FROM )
  );
  X_INV \frame_delay_cnt_3_0_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_3_0_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_3_0_0/XUSED  (
    .I(\frame_delay_cnt_3_0_0/FROM ),
    .O(frame_delay_cnt_3_0_0__n0000)
  );
  defparam frame_delay_cnt_3_Mmux__n0001_I1_Result1.INIT = 16'h303F;
  X_LUT4 frame_delay_cnt_3_Mmux__n0001_I1_Result1 (
    .ADR0(VCC),
    .ADR1(frame_delay_buf_3[0]),
    .ADR2(N8791),
    .ADR3(frame_delay_cnt_3_0_0),
    .O(frame_delay_cnt_3__n0001[0])
  );
  defparam frame_delay_cnt_3_0__n00001.INIT = 16'hC0C0;
  X_LUT4 frame_delay_cnt_3_0__n00001 (
    .ADR0(VCC),
    .ADR1(frame_delay_buf_3[0]),
    .ADR2(N8791),
    .ADR3(VCC),
    .O(\frame_delay_cnt_3_0_0/FROM )
  );
  X_INV \frame_delay_cnt_3_1_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_3_1_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_3_1_0/XUSED  (
    .I(\frame_delay_cnt_3_1_0/FROM ),
    .O(N8658)
  );
  defparam frame_delay_cnt_3_Mmux__n0001_I0_Result1.INIT = 16'hEB41;
  X_LUT4 frame_delay_cnt_3_Mmux__n0001_I0_Result1 (
    .ADR0(N8791),
    .ADR1(frame_delay_cnt_3_1_0),
    .ADR2(frame_delay_cnt_3_0_0),
    .ADR3(N8658),
    .O(frame_delay_cnt_3__n0001[1])
  );
  defparam Ker86561.INIT = 16'h0FF0;
  X_LUT4 Ker86561 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(frame_delay_buf_3[0]),
    .ADR3(frame_delay_buf_3[1]),
    .O(\frame_delay_cnt_3_1_0/FROM )
  );
  X_INV \frame_delay_cnt_4_0_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_4_0_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_4_0_0/XUSED  (
    .I(\frame_delay_cnt_4_0_0/FROM ),
    .O(frame_delay_cnt_4_0_0__n0000)
  );
  defparam frame_delay_cnt_4_Mmux__n0001_I1_Result1.INIT = 16'h5353;
  X_LUT4 frame_delay_cnt_4_Mmux__n0001_I1_Result1 (
    .ADR0(frame_delay_buf_4[0]),
    .ADR1(frame_delay_cnt_4_0_0),
    .ADR2(N8791),
    .ADR3(VCC),
    .O(frame_delay_cnt_4__n0001[0])
  );
  defparam frame_delay_cnt_4_0__n00001.INIT = 16'hF000;
  X_LUT4 frame_delay_cnt_4_0__n00001 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(N8791),
    .ADR3(frame_delay_buf_4[0]),
    .O(\frame_delay_cnt_4_0_0/FROM )
  );
  X_INV \frame_delay_cnt_4_1_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_4_1_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_4_1_0/XUSED  (
    .I(\frame_delay_cnt_4_1_0/FROM ),
    .O(N8652)
  );
  defparam frame_delay_cnt_4_Mmux__n0001_I0_Result1.INIT = 16'hEB41;
  X_LUT4 frame_delay_cnt_4_Mmux__n0001_I0_Result1 (
    .ADR0(N8791),
    .ADR1(frame_delay_cnt_4_1_0),
    .ADR2(frame_delay_cnt_4_0_0),
    .ADR3(N8652),
    .O(frame_delay_cnt_4__n0001[1])
  );
  defparam Ker86501.INIT = 16'h33CC;
  X_LUT4 Ker86501 (
    .ADR0(VCC),
    .ADR1(frame_delay_buf_4[0]),
    .ADR2(VCC),
    .ADR3(frame_delay_buf_4[1]),
    .O(\frame_delay_cnt_4_1_0/FROM )
  );
  X_INV \frame_delay_cnt_5_0_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_5_0_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_5_0_0/XUSED  (
    .I(\frame_delay_cnt_5_0_0/FROM ),
    .O(frame_delay_cnt_5_0_0__n0000)
  );
  defparam frame_delay_cnt_5_Mmux__n0001_I1_Result1.INIT = 16'h0C3F;
  X_LUT4 frame_delay_cnt_5_Mmux__n0001_I1_Result1 (
    .ADR0(VCC),
    .ADR1(N8791),
    .ADR2(frame_delay_buf_5[0]),
    .ADR3(frame_delay_cnt_5_0_0),
    .O(frame_delay_cnt_5__n0001[0])
  );
  defparam frame_delay_cnt_5_0__n00001.INIT = 16'hCC00;
  X_LUT4 frame_delay_cnt_5_0__n00001 (
    .ADR0(VCC),
    .ADR1(frame_delay_buf_5[0]),
    .ADR2(VCC),
    .ADR3(N8791),
    .O(\frame_delay_cnt_5_0_0/FROM )
  );
  X_INV \frame_delay_cnt_5_1_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_5_1_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_5_1_0/XUSED  (
    .I(\frame_delay_cnt_5_1_0/FROM ),
    .O(N8646)
  );
  defparam frame_delay_cnt_5_Mmux__n0001_I0_Result1.INIT = 16'hEB41;
  X_LUT4 frame_delay_cnt_5_Mmux__n0001_I0_Result1 (
    .ADR0(N8791),
    .ADR1(frame_delay_cnt_5_0_0),
    .ADR2(frame_delay_cnt_5_1_0),
    .ADR3(N8646),
    .O(frame_delay_cnt_5__n0001[1])
  );
  defparam Ker86441.INIT = 16'h0FF0;
  X_LUT4 Ker86441 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(frame_delay_buf_5[1]),
    .ADR3(frame_delay_buf_5[0]),
    .O(\frame_delay_cnt_5_1_0/FROM )
  );
  X_OR2 \frame_delay_cnt_5_1_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_5_0_1__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_5_1_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_5_1_0/FFY/SETOR  (
    .I(\frame_delay_cnt_5_0_1__n0001/FROM ),
    .O(\frame_delay_cnt_5_1_0/FFY/SET )
  );
  X_FF frame_delay_cnt_5_1_0_81 (
    .I(frame_delay_cnt_5__n0001[1]),
    .CE(_n0231),
    .CLK(\frame_delay_cnt_5_1_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_5_1_0/FFY/SET ),
    .RST(\frame_delay_cnt_5_1_0/FFY/RST ),
    .O(frame_delay_cnt_5_1_0)
  );
  X_INV \mem_page_sel/SRMUX  (
    .I(reset_IBUF),
    .O(\mem_page_sel/SRMUX_OUTPUTNOT )
  );
  X_BUF \mem_page_sel/YUSED  (
    .I(\mem_page_sel/GROM ),
    .O(cd_mem_addr[8])
  );
  X_BUF \mem_page_sel/XUSED  (
    .I(\mem_page_sel/FROM ),
    .O(GLOBAL_LOGIC0_0)
  );
  defparam _n02341.INIT = 16'h00FF;
  X_LUT4 _n02341 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(mem_page_sel),
    .O(\mem_page_sel/GROM )
  );
  defparam \mem_page_sel/F .INIT = 16'h0000;
  X_LUT4 \mem_page_sel/F  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\mem_page_sel/FROM )
  );
  X_INV \frame_delay_cnt_6_0_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_6_0_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_6_0_0/XUSED  (
    .I(\frame_delay_cnt_6_0_0/FROM ),
    .O(frame_delay_cnt_6_0_0__n0000)
  );
  defparam frame_delay_cnt_6_Mmux__n0001_I1_Result1.INIT = 16'h505F;
  X_LUT4 frame_delay_cnt_6_Mmux__n0001_I1_Result1 (
    .ADR0(frame_delay_buf_6[0]),
    .ADR1(VCC),
    .ADR2(N8791),
    .ADR3(frame_delay_cnt_6_0_0),
    .O(frame_delay_cnt_6__n0001[0])
  );
  defparam frame_delay_cnt_6_0__n00001.INIT = 16'hA0A0;
  X_LUT4 frame_delay_cnt_6_0__n00001 (
    .ADR0(frame_delay_buf_6[0]),
    .ADR1(VCC),
    .ADR2(N8791),
    .ADR3(VCC),
    .O(\frame_delay_cnt_6_0_0/FROM )
  );
  X_INV \frame_delay_cnt_6_1_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_6_1_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_6_1_0/XUSED  (
    .I(\frame_delay_cnt_6_1_0/FROM ),
    .O(N8640)
  );
  defparam frame_delay_cnt_6_Mmux__n0001_I0_Result1.INIT = 16'hF909;
  X_LUT4 frame_delay_cnt_6_Mmux__n0001_I0_Result1 (
    .ADR0(frame_delay_cnt_6_0_0),
    .ADR1(frame_delay_cnt_6_1_0),
    .ADR2(N8791),
    .ADR3(N8640),
    .O(frame_delay_cnt_6__n0001[1])
  );
  defparam Ker86381.INIT = 16'h55AA;
  X_LUT4 Ker86381 (
    .ADR0(frame_delay_buf_6[1]),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(frame_delay_buf_6[0]),
    .O(\frame_delay_cnt_6_1_0/FROM )
  );
  X_OR2 \frame_delay_cnt_6_1_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_6_0_1__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_6_1_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_6_1_0/FFY/SETOR  (
    .I(\frame_delay_cnt_7_0_1__n0001/GROM ),
    .O(\frame_delay_cnt_6_1_0/FFY/SET )
  );
  X_FF frame_delay_cnt_6_1_0_82 (
    .I(frame_delay_cnt_6__n0001[1]),
    .CE(_n0232),
    .CLK(\frame_delay_cnt_6_1_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_6_1_0/FFY/SET ),
    .RST(\frame_delay_cnt_6_1_0/FFY/RST ),
    .O(frame_delay_cnt_6_1_0)
  );
  X_INV \frame_delay_cnt_7_0_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_7_0_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_7_0_0/XUSED  (
    .I(\frame_delay_cnt_7_0_0/FROM ),
    .O(frame_delay_cnt_7_0_0__n0000)
  );
  defparam frame_delay_cnt_7_Mmux__n0001_I1_Result1.INIT = 16'h03CF;
  X_LUT4 frame_delay_cnt_7_Mmux__n0001_I1_Result1 (
    .ADR0(VCC),
    .ADR1(N8791),
    .ADR2(frame_delay_cnt_7_0_0),
    .ADR3(frame_delay_buf_7[0]),
    .O(frame_delay_cnt_7__n0001[0])
  );
  defparam frame_delay_cnt_7_0__n00001.INIT = 16'hCC00;
  X_LUT4 frame_delay_cnt_7_0__n00001 (
    .ADR0(VCC),
    .ADR1(N8791),
    .ADR2(VCC),
    .ADR3(frame_delay_buf_7[0]),
    .O(\frame_delay_cnt_7_0_0/FROM )
  );
  X_INV \frame_delay_cnt_7_1_0/CKINV  (
    .I(div_reg),
    .O(\frame_delay_cnt_7_1_0/CKMUXNOT )
  );
  X_BUF \frame_delay_cnt_7_1_0/XUSED  (
    .I(\frame_delay_cnt_7_1_0/FROM ),
    .O(N8634)
  );
  defparam frame_delay_cnt_7_Mmux__n0001_I0_Result1.INIT = 16'hEB41;
  X_LUT4 frame_delay_cnt_7_Mmux__n0001_I0_Result1 (
    .ADR0(N8791),
    .ADR1(frame_delay_cnt_7_0_0),
    .ADR2(frame_delay_cnt_7_1_0),
    .ADR3(N8634),
    .O(frame_delay_cnt_7__n0001[1])
  );
  defparam Ker86321.INIT = 16'h5A5A;
  X_LUT4 Ker86321 (
    .ADR0(frame_delay_buf_7[0]),
    .ADR1(VCC),
    .ADR2(frame_delay_buf_7[1]),
    .ADR3(VCC),
    .O(\frame_delay_cnt_7_1_0/FROM )
  );
  X_BUF \N8954/YUSED  (
    .I(\N8954/GROM ),
    .O(frame_sync_OBUF)
  );
  X_BUF \N8954/XUSED  (
    .I(\N8954/FROM ),
    .O(N8954)
  );
  defparam Ker8737.INIT = 16'h0100;
  X_LUT4 Ker8737 (
    .ADR0(frame_cnt[8]),
    .ADR1(frame_cnt[6]),
    .ADR2(frame_cnt[7]),
    .ADR3(N8954),
    .O(\N8954/GROM )
  );
  defparam Ker8737_SW0.INIT = 16'h1100;
  X_LUT4 Ker8737_SW0 (
    .ADR0(frame_cnt[4]),
    .ADR1(frame_cnt[5]),
    .ADR2(VCC),
    .ADR3(N8791),
    .O(\N8954/FROM )
  );
  X_BUF \N8728/YUSED  (
    .I(\N8728/GROM ),
    .O(_n0038)
  );
  X_BUF \N8728/XUSED  (
    .I(\N8728/FROM ),
    .O(N8728)
  );
  defparam _n00381.INIT = 16'h0100;
  X_LUT4 _n00381 (
    .ADR0(mpi_addr_2_IBUF),
    .ADR1(mpi_addr_1_IBUF),
    .ADR2(mpi_addr_0_IBUF),
    .ADR3(N8728),
    .O(\N8728/GROM )
  );
  defparam Ker87261.INIT = 16'h0400;
  X_LUT4 Ker87261 (
    .ADR0(mpi_rw_IBUF),
    .ADR1(mpi_cs_IBUF),
    .ADR2(mpi_addr_3_IBUF),
    .ADR3(mpi_addr_8_IBUF),
    .O(\N8728/FROM )
  );
  X_BUF \_n0028/YUSED  (
    .I(\_n0028/GROM ),
    .O(_n0030)
  );
  X_BUF \_n0028/XUSED  (
    .I(\_n0028/FROM ),
    .O(_n0028)
  );
  defparam _n00301.INIT = 16'h0020;
  X_LUT4 _n00301 (
    .ADR0(frame_cnt[2]),
    .ADR1(frame_cnt[3]),
    .ADR2(frame_cnt[0]),
    .ADR3(frame_cnt[1]),
    .O(\_n0028/GROM )
  );
  defparam _n00281.INIT = 16'h0400;
  X_LUT4 _n00281 (
    .ADR0(frame_cnt[2]),
    .ADR1(frame_cnt[0]),
    .ADR2(frame_cnt[3]),
    .ADR3(frame_cnt[1]),
    .O(\_n0028/FROM )
  );
  X_BUF \_n0039/YUSED  (
    .I(\_n0039/GROM ),
    .O(_n0040)
  );
  X_BUF \_n0039/XUSED  (
    .I(\_n0039/FROM ),
    .O(_n0039)
  );
  defparam _n00401.INIT = 16'h0008;
  X_LUT4 _n00401 (
    .ADR0(mpi_addr_1_IBUF),
    .ADR1(N8728),
    .ADR2(mpi_addr_0_IBUF),
    .ADR3(mpi_addr_2_IBUF),
    .O(\_n0039/GROM )
  );
  defparam _n00391.INIT = 16'h0200;
  X_LUT4 _n00391 (
    .ADR0(mpi_addr_0_IBUF),
    .ADR1(mpi_addr_1_IBUF),
    .ADR2(mpi_addr_2_IBUF),
    .ADR3(N8728),
    .O(\_n0039/FROM )
  );
  X_BUF \_n0029/YUSED  (
    .I(\_n0029/GROM ),
    .O(_n0033)
  );
  X_BUF \_n0029/XUSED  (
    .I(\_n0029/FROM ),
    .O(_n0029)
  );
  defparam _n00331.INIT = 16'h0010;
  X_LUT4 _n00331 (
    .ADR0(frame_cnt[1]),
    .ADR1(frame_cnt[0]),
    .ADR2(frame_cnt[3]),
    .ADR3(frame_cnt[2]),
    .O(\_n0029/GROM )
  );
  defparam _n00291.INIT = 16'h0100;
  X_LUT4 _n00291 (
    .ADR0(frame_cnt[1]),
    .ADR1(frame_cnt[0]),
    .ADR2(frame_cnt[3]),
    .ADR3(frame_cnt[2]),
    .O(\_n0029/FROM )
  );
  X_BUF \_n0042/YUSED  (
    .I(\_n0042/GROM ),
    .O(_n0041)
  );
  X_BUF \_n0042/XUSED  (
    .I(\_n0042/FROM ),
    .O(_n0042)
  );
  defparam _n00411.INIT = 16'h4000;
  X_LUT4 _n00411 (
    .ADR0(mpi_addr_2_IBUF),
    .ADR1(mpi_addr_1_IBUF),
    .ADR2(N8728),
    .ADR3(mpi_addr_0_IBUF),
    .O(\_n0042/GROM )
  );
  defparam _n00421.INIT = 16'h0008;
  X_LUT4 _n00421 (
    .ADR0(mpi_addr_2_IBUF),
    .ADR1(N8728),
    .ADR2(mpi_addr_0_IBUF),
    .ADR3(mpi_addr_1_IBUF),
    .O(\_n0042/FROM )
  );
  X_BUF \_n0027/YUSED  (
    .I(\_n0027/GROM ),
    .O(_n0034)
  );
  X_BUF \_n0027/XUSED  (
    .I(\_n0027/FROM ),
    .O(_n0027)
  );
  defparam _n00341.INIT = 16'h0200;
  X_LUT4 _n00341 (
    .ADR0(frame_cnt[0]),
    .ADR1(frame_cnt[1]),
    .ADR2(frame_cnt[2]),
    .ADR3(frame_cnt[3]),
    .O(\_n0027/GROM )
  );
  defparam _n00271.INIT = 16'h0002;
  X_LUT4 _n00271 (
    .ADR0(frame_cnt[1]),
    .ADR1(frame_cnt[0]),
    .ADR2(frame_cnt[2]),
    .ADR3(frame_cnt[3]),
    .O(\_n0027/FROM )
  );
  X_BUF \_n0044/YUSED  (
    .I(\_n0044/GROM ),
    .O(_n0043)
  );
  X_BUF \_n0044/XUSED  (
    .I(\_n0044/FROM ),
    .O(_n0044)
  );
  defparam _n00431.INIT = 16'h0800;
  X_LUT4 _n00431 (
    .ADR0(mpi_addr_2_IBUF),
    .ADR1(N8728),
    .ADR2(mpi_addr_1_IBUF),
    .ADR3(mpi_addr_0_IBUF),
    .O(\_n0044/GROM )
  );
  defparam _n00441.INIT = 16'h0080;
  X_LUT4 _n00441 (
    .ADR0(N8728),
    .ADR1(mpi_addr_2_IBUF),
    .ADR2(mpi_addr_1_IBUF),
    .ADR3(mpi_addr_0_IBUF),
    .O(\_n0044/FROM )
  );
  X_BUF \_n0045/YUSED  (
    .I(\_n0045/GROM ),
    .O(_n0045)
  );
  defparam _n00451.INIT = 16'h8000;
  X_LUT4 _n00451 (
    .ADR0(N8728),
    .ADR1(mpi_addr_0_IBUF),
    .ADR2(mpi_addr_1_IBUF),
    .ADR3(mpi_addr_2_IBUF),
    .O(\_n0045/GROM )
  );
  X_BUF \_COND_1<2>/YUSED  (
    .I(\_COND_1<2>/GROM ),
    .O(_n0054)
  );
  X_BUF \_COND_1<2>/XUSED  (
    .I(\_COND_1<2>/FROM ),
    .O(_COND_1[2])
  );
  defparam _n00541.INIT = 16'h11EE;
  X_LUT4 _n00541 (
    .ADR0(frame_cnt[2]),
    .ADR1(frame_cnt_1_1),
    .ADR2(VCC),
    .ADR3(frame_cnt[3]),
    .O(\_COND_1<2>/GROM )
  );
  defparam \Madd__n0076_Mxor_Result<1>_Result1 .INIT = 16'hC3C3;
  X_LUT4 \Madd__n0076_Mxor_Result<1>_Result1  (
    .ADR0(VCC),
    .ADR1(frame_cnt_1_1),
    .ADR2(frame_cnt[2]),
    .ADR3(VCC),
    .O(\_COND_1<2>/FROM )
  );
  X_BUF \_n0230/YUSED  (
    .I(\_n0230/GROM ),
    .O(_n0230)
  );
  defparam _n02301.INIT = 16'hEEEE;
  X_LUT4 _n02301 (
    .ADR0(frame_delay_cnt_4_1_0),
    .ADR1(frame_delay_cnt_4_0_0),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\_n0230/GROM )
  );
  X_BUF \_n0231/YUSED  (
    .I(\_n0231/GROM ),
    .O(_n0231)
  );
  defparam _n02311.INIT = 16'hFFF0;
  X_LUT4 _n02311 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(frame_delay_cnt_5_1_0),
    .ADR3(frame_delay_cnt_5_0_0),
    .O(\_n0231/GROM )
  );
  X_BUF \_n0232/YUSED  (
    .I(\_n0232/GROM ),
    .O(_n0232)
  );
  defparam _n02321.INIT = 16'hFFCC;
  X_LUT4 _n02321 (
    .ADR0(VCC),
    .ADR1(frame_delay_cnt_6_1_0),
    .ADR2(VCC),
    .ADR3(frame_delay_cnt_6_0_0),
    .O(\_n0232/GROM )
  );
  X_BUF \_n0225/YUSED  (
    .I(\_n0225/GROM ),
    .O(_n0225)
  );
  defparam _n02251.INIT = 16'hFAFA;
  X_LUT4 _n02251 (
    .ADR0(frame_delay_cnt_0_0_0),
    .ADR1(VCC),
    .ADR2(frame_delay_cnt_0_1_0),
    .ADR3(VCC),
    .O(\_n0225/GROM )
  );
  X_BUF \_n0233/YUSED  (
    .I(\_n0233/GROM ),
    .O(_n0233)
  );
  defparam _n02331.INIT = 16'hFFF0;
  X_LUT4 _n02331 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(frame_delay_cnt_7_1_0),
    .ADR3(frame_delay_cnt_7_0_0),
    .O(\_n0233/GROM )
  );
  X_BUF \_n0227/YUSED  (
    .I(\_n0227/GROM ),
    .O(_n0227)
  );
  defparam _n02271.INIT = 16'hFFCC;
  X_LUT4 _n02271 (
    .ADR0(VCC),
    .ADR1(frame_delay_cnt_1_1_0),
    .ADR2(VCC),
    .ADR3(frame_delay_cnt_1_0_0),
    .O(\_n0227/GROM )
  );
  X_BUF \_n0228/YUSED  (
    .I(\_n0228/GROM ),
    .O(_n0228)
  );
  defparam _n02281.INIT = 16'hEEEE;
  X_LUT4 _n02281 (
    .ADR0(frame_delay_cnt_2_0_0),
    .ADR1(frame_delay_cnt_2_1_0),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\_n0228/GROM )
  );
  X_BUF \_n0229/YUSED  (
    .I(\_n0229/GROM ),
    .O(_n0229)
  );
  defparam _n02291.INIT = 16'hFCFC;
  X_LUT4 _n02291 (
    .ADR0(VCC),
    .ADR1(frame_delay_cnt_3_0_0),
    .ADR2(frame_delay_cnt_3_1_0),
    .ADR3(VCC),
    .O(\_n0229/GROM )
  );
  X_INV \div_reg/SRMUX  (
    .I(reset_IBUF),
    .O(\div_reg/SRMUX_OUTPUTNOT )
  );
  X_INV \div_reg/BYMUX  (
    .I(div_reg),
    .O(\div_reg/BYMUXNOT )
  );
  X_INV \rx_shift_reg_0<1>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_0<1>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_0<3>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_0<3>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_0<5>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_0<5>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_1<1>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_1<1>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_1<3>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_1<3>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_0<6>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_0<6>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_1<5>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_1<5>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_2<1>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_2<1>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_1<6>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_1<6>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_2<3>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_2<3>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_2<5>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_2<5>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_3<1>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_3<1>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_2<6>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_2<6>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_3<3>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_3<3>/CKMUXNOT )
  );
  X_BUF \rx_shift_reg_3<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_3<3>/FFY/RST )
  );
  X_FF rx_shift_reg_3_2 (
    .I(rx_shift_reg_3[3]),
    .CE(VCC),
    .CLK(\rx_shift_reg_3<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_3<3>/FFY/RST ),
    .O(rx_shift_reg_3[2])
  );
  X_BUF \rx_shift_reg_3<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_3<3>/FFX/RST )
  );
  X_FF rx_shift_reg_3_3 (
    .I(rx_shift_reg_3[4]),
    .CE(VCC),
    .CLK(\rx_shift_reg_3<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_3<3>/FFX/RST ),
    .O(rx_shift_reg_3[3])
  );
  X_INV \rx_shift_reg_3<5>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_3<5>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_4<1>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_4<1>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_3<6>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_3<6>/CKMUXNOT )
  );
  X_BUF \rx_shift_reg_3<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_3<6>/FFY/RST )
  );
  X_FF rx_shift_reg_3_6 (
    .I(rx_shift_reg_3[7]),
    .CE(VCC),
    .CLK(\rx_shift_reg_3<6>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_3<6>/FFY/RST ),
    .O(rx_shift_reg_3[6])
  );
  X_INV \rx_shift_reg_4<3>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_4<3>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_4<5>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_4<5>/CKMUXNOT )
  );
  X_BUF \rx_shift_reg_4<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_4<5>/FFX/RST )
  );
  X_FF rx_shift_reg_4_5 (
    .I(rx_shift_reg_4[6]),
    .CE(VCC),
    .CLK(\rx_shift_reg_4<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_4<5>/FFX/RST ),
    .O(rx_shift_reg_4[5])
  );
  X_BUF \rx_shift_reg_4<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_4<5>/FFY/RST )
  );
  X_FF rx_shift_reg_4_4 (
    .I(rx_shift_reg_4[5]),
    .CE(VCC),
    .CLK(\rx_shift_reg_4<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_4<5>/FFY/RST ),
    .O(rx_shift_reg_4[4])
  );
  X_INV \rx_shift_reg_5<1>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_5<1>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_4<6>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_4<6>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_5<3>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_5<3>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_5<5>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_5<5>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_6<1>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_6<1>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_5<6>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_5<6>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_6<3>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_6<3>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_7<1>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_7<1>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_6<5>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_6<5>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_6<6>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_6<6>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_7<3>/CKINV  (
    .I(div_reg_2),
    .O(\rx_shift_reg_7<3>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_7<5>/CKINV  (
    .I(div_reg_1),
    .O(\rx_shift_reg_7<5>/CKMUXNOT )
  );
  X_INV \rx_shift_reg_7<6>/CKINV  (
    .I(div_reg_1),
    .O(\rx_shift_reg_7<6>/CKMUXNOT )
  );
  X_BUF \ram_en/XUSED  (
    .I(\ram_en/FROM ),
    .O(ram_en)
  );
  defparam Mmux__n0051_I2_Result1.INIT = 16'h4040;
  X_LUT4 Mmux__n0051_I2_Result1 (
    .ADR0(mpi_addr_8_IBUF),
    .ADR1(mpi_mem_bus_out[6]),
    .ADR2(mpi_cs_IBUF),
    .ADR3(VCC),
    .O(\ram_en/GROM )
  );
  defparam ram_en1.INIT = 16'h0C0C;
  X_LUT4 ram_en1 (
    .ADR0(VCC),
    .ADR1(mpi_cs_IBUF),
    .ADR2(mpi_addr_8_IBUF),
    .ADR3(VCC),
    .O(\ram_en/FROM )
  );
  defparam Mmux__n0051_I6_Result1.INIT = 16'h4040;
  X_LUT4 Mmux__n0051_I6_Result1 (
    .ADR0(mpi_addr_8_IBUF),
    .ADR1(mpi_mem_bus_out[2]),
    .ADR2(mpi_cs_IBUF),
    .ADR3(VCC),
    .O(\mpi_data_out_5_OBUFT/GROM )
  );
  defparam Mmux__n0051_I3_Result1.INIT = 16'h2020;
  X_LUT4 Mmux__n0051_I3_Result1 (
    .ADR0(mpi_mem_bus_out[5]),
    .ADR1(mpi_addr_8_IBUF),
    .ADR2(mpi_cs_IBUF),
    .ADR3(VCC),
    .O(\mpi_data_out_5_OBUFT/FROM )
  );
  defparam Mmux__n0020_I7_Result1.INIT = 16'hAFA0;
  X_LUT4 Mmux__n0020_I7_Result1 (
    .ADR0(tx_buf_reg_1[0]),
    .ADR1(VCC),
    .ADR2(Ker87891_1),
    .ADR3(tx_shift_reg_1[1]),
    .O(\_n0019<0>/GROM )
  );
  defparam Mmux__n0019_I7_Result1.INIT = 16'hFC0C;
  X_LUT4 Mmux__n0019_I7_Result1 (
    .ADR0(VCC),
    .ADR1(tx_shift_reg_0[1]),
    .ADR2(Ker87891_1),
    .ADR3(tx_buf_reg_0[0]),
    .O(\_n0019<0>/FROM )
  );
  defparam Mmux__n0021_I7_Result1.INIT = 16'hBB88;
  X_LUT4 Mmux__n0021_I7_Result1 (
    .ADR0(tx_buf_reg_2[0]),
    .ADR1(Ker87891_1),
    .ADR2(VCC),
    .ADR3(tx_shift_reg_2[1]),
    .O(\_n0022<0>/GROM )
  );
  defparam Mmux__n0022_I7_Result1.INIT = 16'hCCAA;
  X_LUT4 Mmux__n0022_I7_Result1 (
    .ADR0(tx_shift_reg_3[1]),
    .ADR1(tx_buf_reg_3[0]),
    .ADR2(VCC),
    .ADR3(Ker87891_1),
    .O(\_n0022<0>/FROM )
  );
  defparam Mmux__n0023_I7_Result1.INIT = 16'hFA50;
  X_LUT4 Mmux__n0023_I7_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(VCC),
    .ADR2(tx_shift_reg_4[1]),
    .ADR3(tx_buf_reg_4[0]),
    .O(\_n0024<0>/GROM )
  );
  defparam Mmux__n0024_I7_Result1.INIT = 16'hFA50;
  X_LUT4 Mmux__n0024_I7_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(VCC),
    .ADR2(tx_shift_reg_5[1]),
    .ADR3(tx_buf_reg_5[0]),
    .O(\_n0024<0>/FROM )
  );
  defparam Mmux__n0025_I7_Result1.INIT = 16'hAACC;
  X_LUT4 Mmux__n0025_I7_Result1 (
    .ADR0(tx_buf_reg_6[0]),
    .ADR1(tx_shift_reg_6[1]),
    .ADR2(VCC),
    .ADR3(Ker87891_1),
    .O(\_n0026<0>/GROM )
  );
  defparam Mmux__n0026_I7_Result1.INIT = 16'hF5A0;
  X_LUT4 Mmux__n0026_I7_Result1 (
    .ADR0(Ker87891_1),
    .ADR1(VCC),
    .ADR2(tx_buf_reg_7[0]),
    .ADR3(tx_shift_reg_7[1]),
    .O(\_n0026<0>/FROM )
  );
  defparam Mmux__n0051_I7_Result1.INIT = 16'hEF40;
  X_LUT4 Mmux__n0051_I7_Result1 (
    .ADR0(mpi_addr_8_IBUF),
    .ADR1(mpi_mem_bus_out[1]),
    .ADR2(mpi_cs_IBUF),
    .ADR3(ctrl_out_reg[1]),
    .O(\mpi_data_out_4_OBUFT/GROM )
  );
  defparam Mmux__n0051_I4_Result1.INIT = 16'h00C0;
  X_LUT4 Mmux__n0051_I4_Result1 (
    .ADR0(VCC),
    .ADR1(mpi_mem_bus_out[4]),
    .ADR2(mpi_cs_IBUF),
    .ADR3(mpi_addr_8_IBUF),
    .O(\mpi_data_out_4_OBUFT/FROM )
  );
  X_INV \div_reg_2/SRMUX  (
    .I(reset_IBUF),
    .O(\div_reg_2/SRMUX_OUTPUTNOT )
  );
  X_INV \div_reg_2/BYMUX  (
    .I(div_reg),
    .O(\div_reg_2/BYMUXNOT )
  );
  X_INV \div_reg_2/BXMUX  (
    .I(div_reg),
    .O(\div_reg_2/BXMUXNOT )
  );
  X_BUF \frame_delay_cnt_0_0_1__n0000/XUSED  (
    .I(\frame_delay_cnt_0_0_1__n0000/FROM ),
    .O(frame_delay_cnt_0_0_1__n0000)
  );
  defparam frame_delay_cnt_0_0__n00011.INIT = 16'h5050;
  X_LUT4 frame_delay_cnt_0_0__n00011 (
    .ADR0(frame_delay_buf_0[0]),
    .ADR1(VCC),
    .ADR2(N8791),
    .ADR3(VCC),
    .O(\frame_delay_cnt_0_0_1__n0000/GROM )
  );
  defparam frame_delay_cnt_0_1__n00001.INIT = 16'hA050;
  X_LUT4 frame_delay_cnt_0_1__n00001 (
    .ADR0(frame_delay_buf_0[0]),
    .ADR1(VCC),
    .ADR2(N8791),
    .ADR3(frame_delay_buf_0[1]),
    .O(\frame_delay_cnt_0_0_1__n0000/FROM )
  );
  X_BUF \frame_delay_cnt_1_0_1__n0000/XUSED  (
    .I(\frame_delay_cnt_1_0_1__n0000/FROM ),
    .O(frame_delay_cnt_1_0_1__n0000)
  );
  defparam frame_delay_cnt_1_0__n00011.INIT = 16'h3300;
  X_LUT4 frame_delay_cnt_1_0__n00011 (
    .ADR0(VCC),
    .ADR1(frame_delay_buf_1[0]),
    .ADR2(VCC),
    .ADR3(N8791),
    .O(\frame_delay_cnt_1_0_1__n0000/GROM )
  );
  defparam frame_delay_cnt_1_1__n00001.INIT = 16'h9900;
  X_LUT4 frame_delay_cnt_1_1__n00001 (
    .ADR0(frame_delay_buf_1[0]),
    .ADR1(frame_delay_buf_1[1]),
    .ADR2(VCC),
    .ADR3(N8791),
    .O(\frame_delay_cnt_1_0_1__n0000/FROM )
  );
  X_BUF \d_mem_addr<0>/YUSED  (
    .I(\d_mem_addr<0>/GROM ),
    .O(d_mem_addr[0])
  );
  defparam Madd_d_mem_low_addr__n00041.INIT = 16'h0F0F;
  X_LUT4 Madd_d_mem_low_addr__n00041 (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(frame_cnt_1_1),
    .ADR3(VCC),
    .O(\d_mem_addr<0>/GROM )
  );
  X_BUF \frame_delay_cnt_2_0_1__n0000/XUSED  (
    .I(\frame_delay_cnt_2_0_1__n0000/FROM ),
    .O(frame_delay_cnt_2_0_1__n0000)
  );
  defparam frame_delay_cnt_2_0__n00011.INIT = 16'h3030;
  X_LUT4 frame_delay_cnt_2_0__n00011 (
    .ADR0(VCC),
    .ADR1(frame_delay_buf_2[0]),
    .ADR2(N8791),
    .ADR3(VCC),
    .O(\frame_delay_cnt_2_0_1__n0000/GROM )
  );
  defparam frame_delay_cnt_2_1__n00001.INIT = 16'h8282;
  X_LUT4 frame_delay_cnt_2_1__n00001 (
    .ADR0(N8791),
    .ADR1(frame_delay_buf_2[1]),
    .ADR2(frame_delay_buf_2[0]),
    .ADR3(VCC),
    .O(\frame_delay_cnt_2_0_1__n0000/FROM )
  );
  X_BUF \rx_buf_reg_2<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_2<5>/FFY/RST )
  );
  X_FF rx_buf_reg_2_4 (
    .I(rx_shift_reg_2[4]),
    .CE(\_n00611/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_2<5>/FFY/RST ),
    .O(rx_buf_reg_2[4])
  );
  X_BUF \rx_buf_reg_2<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_2<5>/FFX/RST )
  );
  X_FF rx_buf_reg_2_5 (
    .I(rx_shift_reg_2[5]),
    .CE(\_n00611/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_2<5>/FFX/RST ),
    .O(rx_buf_reg_2[5])
  );
  X_BUF \rx_buf_reg_3<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_3<3>/FFY/RST )
  );
  X_FF rx_buf_reg_3_2 (
    .I(rx_shift_reg_3[2]),
    .CE(\_n00601/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_3<3>/FFY/RST ),
    .O(rx_buf_reg_3[2])
  );
  X_BUF \rx_buf_reg_3<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_3<3>/FFX/RST )
  );
  X_FF rx_buf_reg_3_3 (
    .I(rx_shift_reg_3[3]),
    .CE(\_n00601/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_3<3>/FFX/RST ),
    .O(rx_buf_reg_3[3])
  );
  X_BUF \rx_buf_reg_3<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_3<7>/FFX/RST )
  );
  X_FF rx_buf_reg_3_7 (
    .I(rx_shift_reg_3[7]),
    .CE(\_n00601/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_3<7>/FFX/RST ),
    .O(rx_buf_reg_3[7])
  );
  X_BUF \rx_buf_reg_4<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_4<5>/FFX/RST )
  );
  X_FF rx_buf_reg_4_5 (
    .I(rx_shift_reg_4[5]),
    .CE(\_n00591/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_4<5>/FFX/RST ),
    .O(rx_buf_reg_4[5])
  );
  X_BUF \frame_delay_cnt_3_0_1__n0000/XUSED  (
    .I(\frame_delay_cnt_3_0_1__n0000/FROM ),
    .O(frame_delay_cnt_3_0_1__n0000)
  );
  defparam frame_delay_cnt_3_0__n00011.INIT = 16'h3300;
  X_LUT4 frame_delay_cnt_3_0__n00011 (
    .ADR0(VCC),
    .ADR1(frame_delay_buf_3[0]),
    .ADR2(VCC),
    .ADR3(N8791),
    .O(\frame_delay_cnt_3_0_1__n0000/GROM )
  );
  defparam frame_delay_cnt_3_1__n00001.INIT = 16'hC300;
  X_LUT4 frame_delay_cnt_3_1__n00001 (
    .ADR0(VCC),
    .ADR1(frame_delay_buf_3[0]),
    .ADR2(frame_delay_buf_3[1]),
    .ADR3(N8791),
    .O(\frame_delay_cnt_3_0_1__n0000/FROM )
  );
  X_BUF \frame_delay_cnt_4_0_1__n0000/XUSED  (
    .I(\frame_delay_cnt_4_0_1__n0000/FROM ),
    .O(frame_delay_cnt_4_0_1__n0000)
  );
  defparam frame_delay_cnt_4_0__n00011.INIT = 16'h5050;
  X_LUT4 frame_delay_cnt_4_0__n00011 (
    .ADR0(frame_delay_buf_4[0]),
    .ADR1(VCC),
    .ADR2(N8791),
    .ADR3(VCC),
    .O(\frame_delay_cnt_4_0_1__n0000/GROM )
  );
  defparam frame_delay_cnt_4_1__n00001.INIT = 16'hA050;
  X_LUT4 frame_delay_cnt_4_1__n00001 (
    .ADR0(frame_delay_buf_4[1]),
    .ADR1(VCC),
    .ADR2(N8791),
    .ADR3(frame_delay_buf_4[0]),
    .O(\frame_delay_cnt_4_0_1__n0000/FROM )
  );
  X_BUF \frame_delay_cnt_5_0_1__n0000/XUSED  (
    .I(\frame_delay_cnt_5_0_1__n0000/FROM ),
    .O(frame_delay_cnt_5_0_1__n0000)
  );
  defparam frame_delay_cnt_5_0__n00011.INIT = 16'h3030;
  X_LUT4 frame_delay_cnt_5_0__n00011 (
    .ADR0(VCC),
    .ADR1(frame_delay_buf_5[0]),
    .ADR2(N8791),
    .ADR3(VCC),
    .O(\frame_delay_cnt_5_0_1__n0000/GROM )
  );
  defparam frame_delay_cnt_5_1__n00001.INIT = 16'h9090;
  X_LUT4 frame_delay_cnt_5_1__n00001 (
    .ADR0(frame_delay_buf_5[0]),
    .ADR1(frame_delay_buf_5[1]),
    .ADR2(N8791),
    .ADR3(VCC),
    .O(\frame_delay_cnt_5_0_1__n0000/FROM )
  );
  X_BUF \frame_delay_cnt_6_0_1__n0000/XUSED  (
    .I(\frame_delay_cnt_6_0_1__n0000/FROM ),
    .O(frame_delay_cnt_6_0_1__n0000)
  );
  defparam frame_delay_cnt_6_0__n00011.INIT = 16'h4444;
  X_LUT4 frame_delay_cnt_6_0__n00011 (
    .ADR0(frame_delay_buf_6[0]),
    .ADR1(N8791),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\frame_delay_cnt_6_0_1__n0000/GROM )
  );
  defparam frame_delay_cnt_6_1__n00001.INIT = 16'hA00A;
  X_LUT4 frame_delay_cnt_6_1__n00001 (
    .ADR0(N8791),
    .ADR1(VCC),
    .ADR2(frame_delay_buf_6[1]),
    .ADR3(frame_delay_buf_6[0]),
    .O(\frame_delay_cnt_6_0_1__n0000/FROM )
  );
  X_BUF \frame_delay_cnt_7_0_1__n0000/XUSED  (
    .I(\frame_delay_cnt_7_0_1__n0000/FROM ),
    .O(frame_delay_cnt_7_0_1__n0000)
  );
  defparam frame_delay_cnt_7_0__n00011.INIT = 16'h3030;
  X_LUT4 frame_delay_cnt_7_0__n00011 (
    .ADR0(VCC),
    .ADR1(frame_delay_buf_7[0]),
    .ADR2(N8791),
    .ADR3(VCC),
    .O(\frame_delay_cnt_7_0_1__n0000/GROM )
  );
  defparam frame_delay_cnt_7_1__n00001.INIT = 16'hA500;
  X_LUT4 frame_delay_cnt_7_1__n00001 (
    .ADR0(frame_delay_buf_7[0]),
    .ADR1(VCC),
    .ADR2(frame_delay_buf_7[1]),
    .ADR3(N8791),
    .O(\frame_delay_cnt_7_0_1__n0000/FROM )
  );
  defparam Mmux__n0051_I0_Result1.INIT = 16'h3000;
  X_LUT4 Mmux__n0051_I0_Result1 (
    .ADR0(VCC),
    .ADR1(mpi_addr_8_IBUF),
    .ADR2(mpi_mem_bus_out[8]),
    .ADR3(mpi_cs_IBUF),
    .O(\mpi_data_out_3_OBUFT/GROM )
  );
  defparam Mmux__n0051_I5_Result1.INIT = 16'h3000;
  X_LUT4 Mmux__n0051_I5_Result1 (
    .ADR0(VCC),
    .ADR1(mpi_addr_8_IBUF),
    .ADR2(mpi_cs_IBUF),
    .ADR3(mpi_mem_bus_out[3]),
    .O(\mpi_data_out_3_OBUFT/FROM )
  );
  X_INV \frame_cnt_1_1/SRMUX  (
    .I(reset_IBUF),
    .O(\frame_cnt_1_1/SRMUX_OUTPUTNOT )
  );
  X_INV \frame_cnt_1_1/CKINV  (
    .I(clk_in_BUFGP),
    .O(\frame_cnt_1_1/CKMUXNOT )
  );
  X_BUF \frame_cnt_1_1/XUSED  (
    .I(\frame_cnt_1_1/FROM ),
    .O(GLOBAL_LOGIC0_1)
  );
  defparam \frame_cnt_1_1/F .INIT = 16'h0000;
  X_LUT4 \frame_cnt_1_1/F  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\frame_cnt_1_1/FROM )
  );
  defparam frame_delay_cnt_0_1__n00011.INIT = 16'h4848;
  X_LUT4 frame_delay_cnt_0_1__n00011 (
    .ADR0(frame_delay_buf_0[0]),
    .ADR1(N8791),
    .ADR2(frame_delay_buf_0[1]),
    .ADR3(VCC),
    .O(\frame_delay_cnt_1_0_1__n0001/GROM )
  );
  defparam frame_delay_cnt_1_1__n00011.INIT = 16'h4488;
  X_LUT4 frame_delay_cnt_1_1__n00011 (
    .ADR0(frame_delay_buf_1[1]),
    .ADR1(N8791),
    .ADR2(VCC),
    .ADR3(frame_delay_buf_1[0]),
    .O(\frame_delay_cnt_1_0_1__n0001/FROM )
  );
  X_BUF \tx_buf_reg_2<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_2<7>/FFY/RST )
  );
  X_FF tx_buf_reg_2_6 (
    .I(data_out_bus[6]),
    .CE(_n0029),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_2<7>/FFY/RST ),
    .O(tx_buf_reg_2[6])
  );
  X_BUF \tx_buf_reg_3<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_3<5>/FFY/RST )
  );
  X_FF tx_buf_reg_3_4 (
    .I(data_out_bus[4]),
    .CE(_n0030),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_3<5>/FFY/RST ),
    .O(tx_buf_reg_3[4])
  );
  defparam frame_delay_cnt_2_1__n00011.INIT = 16'h0CC0;
  X_LUT4 frame_delay_cnt_2_1__n00011 (
    .ADR0(VCC),
    .ADR1(N8791),
    .ADR2(frame_delay_buf_2[0]),
    .ADR3(frame_delay_buf_2[1]),
    .O(\frame_delay_cnt_3_0_1__n0001/GROM )
  );
  defparam frame_delay_cnt_3_1__n00011.INIT = 16'h50A0;
  X_LUT4 frame_delay_cnt_3_1__n00011 (
    .ADR0(frame_delay_buf_3[0]),
    .ADR1(VCC),
    .ADR2(N8791),
    .ADR3(frame_delay_buf_3[1]),
    .O(\frame_delay_cnt_3_0_1__n0001/FROM )
  );
  X_SFF c_mem_addr_cnt_2 (
    .I(c_mem_addr_cnt__n0000[2]),
    .CE(N8791),
    .CLK(div_reg),
    .SET(GND),
    .RST(GSR),
    .SSET(GND),
    .SRST(frame_sync_OBUF),
    .O(c_mem_addr_cnt[2])
  );
  defparam frame_delay_cnt_4_1__n00011.INIT = 16'h6600;
  X_LUT4 frame_delay_cnt_4_1__n00011 (
    .ADR0(frame_delay_buf_4[1]),
    .ADR1(frame_delay_buf_4[0]),
    .ADR2(VCC),
    .ADR3(N8791),
    .O(\frame_delay_cnt_5_0_1__n0001/GROM )
  );
  defparam frame_delay_cnt_5_1__n00011.INIT = 16'h5A00;
  X_LUT4 frame_delay_cnt_5_1__n00011 (
    .ADR0(frame_delay_buf_5[0]),
    .ADR1(VCC),
    .ADR2(frame_delay_buf_5[1]),
    .ADR3(N8791),
    .O(\frame_delay_cnt_5_0_1__n0001/FROM )
  );
  X_OR2 \frame_cnt<2>/FFY/RSTOR  (
    .I0(\frame_cnt<2>/SRMUX_OUTPUTNOT ),
    .I1(GSR),
    .O(\frame_cnt<2>/FFY/RST )
  );
  X_FF frame_cnt_3 (
    .I(frame_cnt__n0000[3]),
    .CE(VCC),
    .CLK(\frame_cnt<2>/CKMUXNOT ),
    .SET(GND),
    .RST(\frame_cnt<2>/FFY/RST ),
    .O(frame_cnt[3])
  );
  defparam frame_delay_cnt_6_1__n00011.INIT = 16'h2288;
  X_LUT4 frame_delay_cnt_6_1__n00011 (
    .ADR0(N8791),
    .ADR1(frame_delay_buf_6[0]),
    .ADR2(VCC),
    .ADR3(frame_delay_buf_6[1]),
    .O(\frame_delay_cnt_7_0_1__n0001/GROM )
  );
  defparam frame_delay_cnt_7_1__n00011.INIT = 16'h4488;
  X_LUT4 frame_delay_cnt_7_1__n00011 (
    .ADR0(frame_delay_buf_7[0]),
    .ADR1(N8791),
    .ADR2(VCC),
    .ADR3(frame_delay_buf_7[1]),
    .O(\frame_delay_cnt_7_0_1__n0001/FROM )
  );
  defparam Mmux__n0051_I1_Result1.INIT = 16'h0088;
  X_LUT4 Mmux__n0051_I1_Result1 (
    .ADR0(mpi_mem_bus_out[7]),
    .ADR1(mpi_cs_IBUF),
    .ADR2(VCC),
    .ADR3(mpi_addr_8_IBUF),
    .O(\mpi_data_out_7_OBUFT/GROM )
  );
  X_BUF \tx_shift_reg_1<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_1<6>/FFY/RST )
  );
  X_FF tx_shift_reg_1_5 (
    .I(_n0020[5]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_1<6>/FFY/RST ),
    .O(tx_shift_reg_1[5])
  );
  X_BUF \tx_shift_reg_2<4>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_2<4>/FFX/RST )
  );
  X_FF tx_shift_reg_2_4 (
    .I(_n0021[4]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_2<4>/FFX/RST ),
    .O(tx_shift_reg_2[4])
  );
  X_BUF \tx_shift_reg_2<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_2<7>/FFX/RST )
  );
  X_FF tx_shift_reg_2_7 (
    .I(_n0021[7]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_2<7>/FFX/RST ),
    .O(tx_shift_reg_2[7])
  );
  X_BUF \tx_shift_reg_2<2>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_2<2>/FFY/RST )
  );
  X_FF tx_shift_reg_2_1 (
    .I(_n0021[1]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_2<2>/FFY/RST ),
    .O(tx_shift_reg_2[1])
  );
  X_BUF \tx_shift_reg_2<2>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_2<2>/FFX/RST )
  );
  X_FF tx_shift_reg_2_2 (
    .I(_n0021[2]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_2<2>/FFX/RST ),
    .O(tx_shift_reg_2[2])
  );
  X_BUF \tx_shift_reg_1<6>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_1<6>/FFX/RST )
  );
  X_FF tx_shift_reg_1_6 (
    .I(_n0020[6]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_1<6>/FFX/RST ),
    .O(tx_shift_reg_1[6])
  );
  X_BUF \tx_shift_reg_3<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_3<6>/FFY/RST )
  );
  X_FF tx_shift_reg_3_5 (
    .I(_n0022[5]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_3<6>/FFY/RST ),
    .O(tx_shift_reg_3[5])
  );
  X_BUF \tx_shift_reg_2<4>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_2<4>/FFY/RST )
  );
  X_FF tx_shift_reg_2_3 (
    .I(_n0021[3]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_2<4>/FFY/RST ),
    .O(tx_shift_reg_2[3])
  );
  X_BUF \tx_shift_reg_2<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_2<7>/FFY/RST )
  );
  X_FF tx_shift_reg_1_7 (
    .I(_n0020[7]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_2<7>/FFY/RST ),
    .O(tx_shift_reg_1[7])
  );
  X_BUF \tx_shift_reg_2<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_2<6>/FFY/RST )
  );
  X_FF tx_shift_reg_2_5 (
    .I(_n0021[5]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_2<6>/FFY/RST ),
    .O(tx_shift_reg_2[5])
  );
  X_BUF \tx_shift_reg_2<6>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_2<6>/FFX/RST )
  );
  X_FF tx_shift_reg_2_6 (
    .I(_n0021[6]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_2<6>/FFX/RST ),
    .O(tx_shift_reg_2[6])
  );
  X_BUF \tx_shift_reg_3<2>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_3<2>/FFY/RST )
  );
  X_FF tx_shift_reg_3_1 (
    .I(_n0022[1]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_3<2>/FFY/RST ),
    .O(tx_shift_reg_3[1])
  );
  X_BUF \tx_shift_reg_3<2>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_3<2>/FFX/RST )
  );
  X_FF tx_shift_reg_3_2 (
    .I(_n0022[2]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_3<2>/FFX/RST ),
    .O(tx_shift_reg_3[2])
  );
  X_BUF \tx_shift_reg_4<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_4<7>/FFY/RST )
  );
  X_FF tx_shift_reg_3_7 (
    .I(_n0022[7]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_4<7>/FFY/RST ),
    .O(tx_shift_reg_3[7])
  );
  X_BUF \tx_shift_reg_5<2>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_5<2>/FFY/RST )
  );
  X_FF tx_shift_reg_5_1 (
    .I(_n0024[1]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_5<2>/FFY/RST ),
    .O(tx_shift_reg_5[1])
  );
  X_BUF \tx_shift_reg_3<4>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_3<4>/FFX/RST )
  );
  X_FF tx_shift_reg_3_4 (
    .I(_n0022[4]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_3<4>/FFX/RST ),
    .O(tx_shift_reg_3[4])
  );
  X_BUF \tx_shift_reg_3<4>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_3<4>/FFY/RST )
  );
  X_FF tx_shift_reg_3_3 (
    .I(_n0022[3]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_3<4>/FFY/RST ),
    .O(tx_shift_reg_3[3])
  );
  X_BUF \tx_shift_reg_4<2>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_4<2>/FFY/RST )
  );
  X_FF tx_shift_reg_4_1 (
    .I(_n0023[1]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_4<2>/FFY/RST ),
    .O(tx_shift_reg_4[1])
  );
  X_BUF \rx_buf_reg_3<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_3<7>/FFY/RST )
  );
  X_FF rx_buf_reg_3_6 (
    .I(rx_shift_reg_3[6]),
    .CE(\_n00601/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_3<7>/FFY/RST ),
    .O(rx_buf_reg_3[6])
  );
  X_BUF \tx_shift_reg_3<6>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_3<6>/FFX/RST )
  );
  X_FF tx_shift_reg_3_6 (
    .I(_n0022[6]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_3<6>/FFX/RST ),
    .O(tx_shift_reg_3[6])
  );
  X_BUF \tx_shift_reg_4<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_4<6>/FFY/RST )
  );
  X_FF tx_shift_reg_4_5 (
    .I(_n0023[5]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_4<6>/FFY/RST ),
    .O(tx_shift_reg_4[5])
  );
  X_BUF \tx_shift_reg_4<2>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_4<2>/FFX/RST )
  );
  X_FF tx_shift_reg_4_2 (
    .I(_n0023[2]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_4<2>/FFX/RST ),
    .O(tx_shift_reg_4[2])
  );
  X_BUF \tx_shift_reg_4<4>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_4<4>/FFY/RST )
  );
  X_FF tx_shift_reg_4_3 (
    .I(_n0023[3]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_4<4>/FFY/RST ),
    .O(tx_shift_reg_4[3])
  );
  X_BUF \tx_shift_reg_4<4>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_4<4>/FFX/RST )
  );
  X_FF tx_shift_reg_4_4 (
    .I(_n0023[4]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_4<4>/FFX/RST ),
    .O(tx_shift_reg_4[4])
  );
  X_BUF \tx_shift_reg_5<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_5<6>/FFY/RST )
  );
  X_FF tx_shift_reg_5_5 (
    .I(_n0024[5]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_5<6>/FFY/RST ),
    .O(tx_shift_reg_5[5])
  );
  X_BUF \tx_shift_reg_4<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_4<7>/FFX/RST )
  );
  X_FF tx_shift_reg_4_7 (
    .I(_n0023[7]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_4<7>/FFX/RST ),
    .O(tx_shift_reg_4[7])
  );
  X_BUF \tx_shift_reg_4<6>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_4<6>/FFX/RST )
  );
  X_FF tx_shift_reg_4_6 (
    .I(_n0023[6]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_4<6>/FFX/RST ),
    .O(tx_shift_reg_4[6])
  );
  X_BUF \tx_shift_reg_5<2>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_5<2>/FFX/RST )
  );
  X_FF tx_shift_reg_5_2 (
    .I(_n0024[2]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_5<2>/FFX/RST ),
    .O(tx_shift_reg_5[2])
  );
  X_BUF \tx_shift_reg_7<2>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_7<2>/FFY/RST )
  );
  X_FF tx_shift_reg_7_1 (
    .I(_n0026[1]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_7<2>/FFY/RST ),
    .O(tx_shift_reg_7[1])
  );
  X_BUF \tx_shift_reg_7<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_7<6>/FFY/RST )
  );
  X_FF tx_shift_reg_7_5 (
    .I(_n0026[5]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_7<6>/FFY/RST ),
    .O(tx_shift_reg_7[5])
  );
  X_BUF \tx_shift_reg_5<4>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_5<4>/FFX/RST )
  );
  X_FF tx_shift_reg_5_4 (
    .I(_n0024[4]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_5<4>/FFX/RST ),
    .O(tx_shift_reg_5[4])
  );
  X_BUF \tx_shift_reg_5<4>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_5<4>/FFY/RST )
  );
  X_FF tx_shift_reg_5_3 (
    .I(_n0024[3]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_5<4>/FFY/RST ),
    .O(tx_shift_reg_5[3])
  );
  X_BUF \tx_shift_reg_6<2>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_6<2>/FFY/RST )
  );
  X_FF tx_shift_reg_6_1 (
    .I(_n0025[1]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_6<2>/FFY/RST ),
    .O(tx_shift_reg_6[1])
  );
  X_BUF \tx_shift_reg_5<6>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_5<6>/FFX/RST )
  );
  X_FF tx_shift_reg_5_6 (
    .I(_n0024[6]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_5<6>/FFX/RST ),
    .O(tx_shift_reg_5[6])
  );
  X_BUF \tx_shift_reg_6<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_6<7>/FFY/RST )
  );
  X_FF tx_shift_reg_5_7 (
    .I(_n0024[7]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_6<7>/FFY/RST ),
    .O(tx_shift_reg_5[7])
  );
  X_BUF \tx_buf_reg_4<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_4<3>/FFX/RST )
  );
  X_FF tx_buf_reg_4_3 (
    .I(data_out_bus[3]),
    .CE(\_n00311/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_4<3>/FFX/RST ),
    .O(tx_buf_reg_4[3])
  );
  X_BUF \tx_shift_reg_6<2>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_6<2>/FFX/RST )
  );
  X_FF tx_shift_reg_6_2 (
    .I(_n0025[2]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_6<2>/FFX/RST ),
    .O(tx_shift_reg_6[2])
  );
  X_BUF \tx_shift_reg_6<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_6<7>/FFX/RST )
  );
  X_FF tx_shift_reg_6_7 (
    .I(_n0025[7]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_6<7>/FFX/RST ),
    .O(tx_shift_reg_6[7])
  );
  X_OR2 \frame_delay_cnt_7_1_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_7_0_1__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_7_1_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_7_1_0/FFY/SETOR  (
    .I(\frame_delay_cnt_7_0_1__n0001/FROM ),
    .O(\frame_delay_cnt_7_1_0/FFY/SET )
  );
  X_FF frame_delay_cnt_7_1_0_83 (
    .I(frame_delay_cnt_7__n0001[1]),
    .CE(_n0233),
    .CLK(\frame_delay_cnt_7_1_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_7_1_0/FFY/SET ),
    .RST(\frame_delay_cnt_7_1_0/FFY/RST ),
    .O(frame_delay_cnt_7_1_0)
  );
  X_BUF \tx_shift_reg_7<6>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_7<6>/FFX/RST )
  );
  X_FF tx_shift_reg_7_6 (
    .I(_n0026[6]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_7<6>/FFX/RST ),
    .O(tx_shift_reg_7[6])
  );
  X_BUF \tx_shift_reg_7<2>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_7<2>/FFX/RST )
  );
  X_FF tx_shift_reg_7_2 (
    .I(_n0026[2]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_7<2>/FFX/RST ),
    .O(tx_shift_reg_7[2])
  );
  X_OR2 \mem_page_sel/FFY/RSTOR  (
    .I0(\mem_page_sel/SRMUX_OUTPUTNOT ),
    .I1(GSR),
    .O(\mem_page_sel/FFY/RST )
  );
  X_FF mem_page_sel_84 (
    .I(\mem_page_sel/GROM ),
    .CE(frame_sync_OBUF),
    .CLK(div_reg),
    .SET(GND),
    .RST(\mem_page_sel/FFY/RST ),
    .O(mem_page_sel)
  );
  X_BUF \tx_buf_reg_2<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_2<7>/FFX/RST )
  );
  X_FF tx_buf_reg_2_7 (
    .I(data_out_bus[7]),
    .CE(_n0029),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_2<7>/FFX/RST ),
    .O(tx_buf_reg_2[7])
  );
  X_BUF \rx_shift_reg_4<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_4<6>/FFY/RST )
  );
  X_FF rx_shift_reg_4_6 (
    .I(rx_shift_reg_4[7]),
    .CE(VCC),
    .CLK(\rx_shift_reg_4<6>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_4<6>/FFY/RST ),
    .O(rx_shift_reg_4[6])
  );
  X_BUF \ctrl_out_reg<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\ctrl_out_reg<1>/FFY/RST )
  );
  X_FF ctrl_out_reg_1 (
    .I(_n0046[1]),
    .CE(VCC),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\ctrl_out_reg<1>/FFY/RST ),
    .O(ctrl_out_reg[1])
  );
  X_BUF \rx_shift_reg_5<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_5<5>/FFX/RST )
  );
  X_FF rx_shift_reg_5_5 (
    .I(rx_shift_reg_5[6]),
    .CE(VCC),
    .CLK(\rx_shift_reg_5<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_5<5>/FFX/RST ),
    .O(rx_shift_reg_5[5])
  );
  X_BUF \tx_shift_reg_7<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_shift_reg_7<7>/FFY/RST )
  );
  X_FF tx_shift_reg_7_7 (
    .I(_n0026[7]),
    .CE(VCC),
    .CLK(div_reg_1),
    .SET(GND),
    .RST(\tx_shift_reg_7<7>/FFY/RST ),
    .O(tx_shift_reg_7[7])
  );
  X_BUF \ctrl_out_reg<0>/FFY/RSTOR  (
    .I(GSR),
    .O(\ctrl_out_reg<0>/FFY/RST )
  );
  X_FF ctrl_out_reg_0 (
    .I(_n0046[0]),
    .CE(VCC),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\ctrl_out_reg<0>/FFY/RST ),
    .O(ctrl_out_reg[0])
  );
  X_OR2 \frame_delay_cnt_0_0_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_0_0_0__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_0_0_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_0_0_0/FFY/SETOR  (
    .I(\frame_delay_cnt_0_0_1__n0000/GROM ),
    .O(\frame_delay_cnt_0_0_0/FFY/SET )
  );
  X_FF frame_delay_cnt_0_0_0_85 (
    .I(frame_delay_cnt_0__n0001[0]),
    .CE(_n0225),
    .CLK(\frame_delay_cnt_0_0_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_0_0_0/FFY/SET ),
    .RST(\frame_delay_cnt_0_0_0/FFY/RST ),
    .O(frame_delay_cnt_0_0_0)
  );
  X_OR2 \frame_delay_cnt_0_1_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_0_0_1__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_0_1_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_0_1_0/FFY/SETOR  (
    .I(\frame_delay_cnt_1_0_1__n0001/GROM ),
    .O(\frame_delay_cnt_0_1_0/FFY/SET )
  );
  X_FF frame_delay_cnt_0_1_0_86 (
    .I(frame_delay_cnt_0__n0001[1]),
    .CE(_n0225),
    .CLK(\frame_delay_cnt_0_1_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_0_1_0/FFY/SET ),
    .RST(\frame_delay_cnt_0_1_0/FFY/RST ),
    .O(frame_delay_cnt_0_1_0)
  );
  X_OR2 \frame_delay_cnt_1_0_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_1_0_0__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_1_0_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_1_0_0/FFY/SETOR  (
    .I(\frame_delay_cnt_1_0_1__n0000/GROM ),
    .O(\frame_delay_cnt_1_0_0/FFY/SET )
  );
  X_FF frame_delay_cnt_1_0_0_87 (
    .I(frame_delay_cnt_1__n0001[0]),
    .CE(_n0227),
    .CLK(\frame_delay_cnt_1_0_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_1_0_0/FFY/SET ),
    .RST(\frame_delay_cnt_1_0_0/FFY/RST ),
    .O(frame_delay_cnt_1_0_0)
  );
  X_BUF \rx_buf_reg_4<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_4<5>/FFY/RST )
  );
  X_FF rx_buf_reg_4_4 (
    .I(rx_shift_reg_4[4]),
    .CE(\_n00591/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_4<5>/FFY/RST ),
    .O(rx_buf_reg_4[4])
  );
  X_OR2 \frame_delay_cnt_6_0_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_6_0_0__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_6_0_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_6_0_0/FFY/SETOR  (
    .I(\frame_delay_cnt_6_0_1__n0000/GROM ),
    .O(\frame_delay_cnt_6_0_0/FFY/SET )
  );
  X_FF frame_delay_cnt_6_0_0_88 (
    .I(frame_delay_cnt_6__n0001[0]),
    .CE(_n0232),
    .CLK(\frame_delay_cnt_6_0_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_6_0_0/FFY/SET ),
    .RST(\frame_delay_cnt_6_0_0/FFY/RST ),
    .O(frame_delay_cnt_6_0_0)
  );
  X_OR2 \frame_delay_cnt_1_1_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_1_0_1__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_1_1_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_1_1_0/FFY/SETOR  (
    .I(\frame_delay_cnt_1_0_1__n0001/FROM ),
    .O(\frame_delay_cnt_1_1_0/FFY/SET )
  );
  X_FF frame_delay_cnt_1_1_0_89 (
    .I(frame_delay_cnt_1__n0001[1]),
    .CE(_n0227),
    .CLK(\frame_delay_cnt_1_1_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_1_1_0/FFY/SET ),
    .RST(\frame_delay_cnt_1_1_0/FFY/RST ),
    .O(frame_delay_cnt_1_1_0)
  );
  X_OR2 \frame_delay_cnt_2_0_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_2_0_0__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_2_0_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_2_0_0/FFY/SETOR  (
    .I(\frame_delay_cnt_2_0_1__n0000/GROM ),
    .O(\frame_delay_cnt_2_0_0/FFY/SET )
  );
  X_FF frame_delay_cnt_2_0_0_90 (
    .I(frame_delay_cnt_2__n0001[0]),
    .CE(_n0228),
    .CLK(\frame_delay_cnt_2_0_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_2_0_0/FFY/SET ),
    .RST(\frame_delay_cnt_2_0_0/FFY/RST ),
    .O(frame_delay_cnt_2_0_0)
  );
  X_OR2 \frame_delay_cnt_2_1_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_2_0_1__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_2_1_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_2_1_0/FFY/SETOR  (
    .I(\frame_delay_cnt_3_0_1__n0001/GROM ),
    .O(\frame_delay_cnt_2_1_0/FFY/SET )
  );
  X_FF frame_delay_cnt_2_1_0_91 (
    .I(frame_delay_cnt_2__n0001[1]),
    .CE(_n0228),
    .CLK(\frame_delay_cnt_2_1_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_2_1_0/FFY/SET ),
    .RST(\frame_delay_cnt_2_1_0/FFY/RST ),
    .O(frame_delay_cnt_2_1_0)
  );
  X_OR2 \frame_delay_cnt_3_0_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_3_0_0__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_3_0_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_3_0_0/FFY/SETOR  (
    .I(\frame_delay_cnt_3_0_1__n0000/GROM ),
    .O(\frame_delay_cnt_3_0_0/FFY/SET )
  );
  X_FF frame_delay_cnt_3_0_0_92 (
    .I(frame_delay_cnt_3__n0001[0]),
    .CE(_n0229),
    .CLK(\frame_delay_cnt_3_0_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_3_0_0/FFY/SET ),
    .RST(\frame_delay_cnt_3_0_0/FFY/RST ),
    .O(frame_delay_cnt_3_0_0)
  );
  X_OR2 \frame_delay_cnt_3_1_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_3_0_1__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_3_1_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_3_1_0/FFY/SETOR  (
    .I(\frame_delay_cnt_3_0_1__n0001/FROM ),
    .O(\frame_delay_cnt_3_1_0/FFY/SET )
  );
  X_FF frame_delay_cnt_3_1_0_93 (
    .I(frame_delay_cnt_3__n0001[1]),
    .CE(_n0229),
    .CLK(\frame_delay_cnt_3_1_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_3_1_0/FFY/SET ),
    .RST(\frame_delay_cnt_3_1_0/FFY/RST ),
    .O(frame_delay_cnt_3_1_0)
  );
  X_OR2 \frame_delay_cnt_4_0_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_4_0_0__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_4_0_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_4_0_0/FFY/SETOR  (
    .I(\frame_delay_cnt_4_0_1__n0000/GROM ),
    .O(\frame_delay_cnt_4_0_0/FFY/SET )
  );
  X_FF frame_delay_cnt_4_0_0_94 (
    .I(frame_delay_cnt_4__n0001[0]),
    .CE(_n0230),
    .CLK(\frame_delay_cnt_4_0_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_4_0_0/FFY/SET ),
    .RST(\frame_delay_cnt_4_0_0/FFY/RST ),
    .O(frame_delay_cnt_4_0_0)
  );
  X_OR2 \frame_delay_cnt_4_1_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_4_0_1__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_4_1_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_4_1_0/FFY/SETOR  (
    .I(\frame_delay_cnt_5_0_1__n0001/GROM ),
    .O(\frame_delay_cnt_4_1_0/FFY/SET )
  );
  X_FF frame_delay_cnt_4_1_0_95 (
    .I(frame_delay_cnt_4__n0001[1]),
    .CE(_n0230),
    .CLK(\frame_delay_cnt_4_1_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_4_1_0/FFY/SET ),
    .RST(\frame_delay_cnt_4_1_0/FFY/RST ),
    .O(frame_delay_cnt_4_1_0)
  );
  X_BUF \rx_shift_reg_3<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_3<5>/FFX/RST )
  );
  X_FF rx_shift_reg_3_5 (
    .I(rx_shift_reg_3[6]),
    .CE(VCC),
    .CLK(\rx_shift_reg_3<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_3<5>/FFX/RST ),
    .O(rx_shift_reg_3[5])
  );
  X_BUF \rx_shift_reg_5<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_5<5>/FFY/RST )
  );
  X_FF rx_shift_reg_5_4 (
    .I(rx_shift_reg_5[5]),
    .CE(VCC),
    .CLK(\rx_shift_reg_5<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_5<5>/FFY/RST ),
    .O(rx_shift_reg_5[4])
  );
  X_OR2 \frame_delay_cnt_5_0_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_5_0_0__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_5_0_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_5_0_0/FFY/SETOR  (
    .I(\frame_delay_cnt_5_0_1__n0000/GROM ),
    .O(\frame_delay_cnt_5_0_0/FFY/SET )
  );
  X_FF frame_delay_cnt_5_0_0_96 (
    .I(frame_delay_cnt_5__n0001[0]),
    .CE(_n0231),
    .CLK(\frame_delay_cnt_5_0_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_5_0_0/FFY/SET ),
    .RST(\frame_delay_cnt_5_0_0/FFY/RST ),
    .O(frame_delay_cnt_5_0_0)
  );
  X_BUF \tx_buf_reg_3<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_3<5>/FFX/RST )
  );
  X_FF tx_buf_reg_3_5 (
    .I(data_out_bus[5]),
    .CE(_n0030),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_3<5>/FFX/RST ),
    .O(tx_buf_reg_3[5])
  );
  X_BUF \rx_shift_reg_3<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_3<5>/FFY/RST )
  );
  X_FF rx_shift_reg_3_4 (
    .I(rx_shift_reg_3[5]),
    .CE(VCC),
    .CLK(\rx_shift_reg_3<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_3<5>/FFY/RST ),
    .O(rx_shift_reg_3[4])
  );
  X_OR2 \frame_delay_cnt_7_0_0/FFY/RSTOR  (
    .I0(frame_delay_cnt_7_0_0__n0000),
    .I1(GSR),
    .O(\frame_delay_cnt_7_0_0/FFY/RST )
  );
  X_BUF \frame_delay_cnt_7_0_0/FFY/SETOR  (
    .I(\frame_delay_cnt_7_0_1__n0000/GROM ),
    .O(\frame_delay_cnt_7_0_0/FFY/SET )
  );
  X_FF frame_delay_cnt_7_0_0_97 (
    .I(frame_delay_cnt_7__n0001[0]),
    .CE(_n0233),
    .CLK(\frame_delay_cnt_7_0_0/CKMUXNOT ),
    .SET(\frame_delay_cnt_7_0_0/FFY/SET ),
    .RST(\frame_delay_cnt_7_0_0/FFY/RST ),
    .O(frame_delay_cnt_7_0_0)
  );
  X_BUF \rx_shift_reg_4<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_4<3>/FFY/RST )
  );
  X_FF rx_shift_reg_4_2 (
    .I(rx_shift_reg_4[3]),
    .CE(VCC),
    .CLK(\rx_shift_reg_4<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_4<3>/FFY/RST ),
    .O(rx_shift_reg_4[2])
  );
  X_BUF \rx_shift_reg_0<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_0<1>/FFX/RST )
  );
  X_FF rx_shift_reg_0_1 (
    .I(rx_shift_reg_0[2]),
    .CE(VCC),
    .CLK(\rx_shift_reg_0<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_0<1>/FFX/RST ),
    .O(rx_shift_reg_0[1])
  );
  X_BUF \rx_shift_reg_5<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_5<1>/FFY/RST )
  );
  X_FF rx_shift_reg_5_0 (
    .I(rx_shift_reg_5[1]),
    .CE(VCC),
    .CLK(\rx_shift_reg_5<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_5<1>/FFY/RST ),
    .O(rx_shift_reg_5[0])
  );
  X_BUF \rx_shift_reg_1<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_1<5>/FFX/RST )
  );
  X_FF rx_shift_reg_1_5 (
    .I(rx_shift_reg_1[6]),
    .CE(VCC),
    .CLK(\rx_shift_reg_1<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_1<5>/FFX/RST ),
    .O(rx_shift_reg_1[5])
  );
  X_OR2 \div_reg/FFY/RSTOR  (
    .I0(\div_reg/SRMUX_OUTPUTNOT ),
    .I1(GSR),
    .O(\div_reg/FFY/RST )
  );
  X_FF div_reg_98 (
    .I(\div_reg/BYMUXNOT ),
    .CE(VCC),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\div_reg/FFY/RST ),
    .O(div_reg)
  );
  X_BUF \rx_shift_reg_0<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_0<1>/FFY/RST )
  );
  X_FF rx_shift_reg_0_0 (
    .I(rx_shift_reg_0[1]),
    .CE(VCC),
    .CLK(\rx_shift_reg_0<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_0<1>/FFY/RST ),
    .O(rx_shift_reg_0[0])
  );
  X_BUF \rx_shift_reg_1<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_1<1>/FFX/RST )
  );
  X_FF rx_shift_reg_1_1 (
    .I(rx_shift_reg_1[2]),
    .CE(VCC),
    .CLK(\rx_shift_reg_1<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_1<1>/FFX/RST ),
    .O(rx_shift_reg_1[1])
  );
  X_BUF \rx_shift_reg_2<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_2<3>/FFX/RST )
  );
  X_FF rx_shift_reg_2_3 (
    .I(rx_shift_reg_2[4]),
    .CE(VCC),
    .CLK(\rx_shift_reg_2<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_2<3>/FFX/RST ),
    .O(rx_shift_reg_2[3])
  );
  X_BUF \rx_shift_reg_2<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_2<3>/FFY/RST )
  );
  X_FF rx_shift_reg_2_2 (
    .I(rx_shift_reg_2[3]),
    .CE(VCC),
    .CLK(\rx_shift_reg_2<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_2<3>/FFY/RST ),
    .O(rx_shift_reg_2[2])
  );
  X_BUF \rx_shift_reg_0<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_0<5>/FFX/RST )
  );
  X_FF rx_shift_reg_0_5 (
    .I(rx_shift_reg_0[6]),
    .CE(VCC),
    .CLK(\rx_shift_reg_0<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_0<5>/FFX/RST ),
    .O(rx_shift_reg_0[5])
  );
  X_BUF \rx_shift_reg_1<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_1<3>/FFX/RST )
  );
  X_FF rx_shift_reg_1_3 (
    .I(rx_shift_reg_1[4]),
    .CE(VCC),
    .CLK(\rx_shift_reg_1<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_1<3>/FFX/RST ),
    .O(rx_shift_reg_1[3])
  );
  X_BUF \rx_shift_reg_0<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_0<3>/FFY/RST )
  );
  X_FF rx_shift_reg_0_2 (
    .I(rx_shift_reg_0[3]),
    .CE(VCC),
    .CLK(\rx_shift_reg_0<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_0<3>/FFY/RST ),
    .O(rx_shift_reg_0[2])
  );
  X_BUF \rx_shift_reg_0<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_0<3>/FFX/RST )
  );
  X_FF rx_shift_reg_0_3 (
    .I(rx_shift_reg_0[4]),
    .CE(VCC),
    .CLK(\rx_shift_reg_0<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_0<3>/FFX/RST ),
    .O(rx_shift_reg_0[3])
  );
  X_BUF \rx_shift_reg_0<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_0<5>/FFY/RST )
  );
  X_FF rx_shift_reg_0_4 (
    .I(rx_shift_reg_0[5]),
    .CE(VCC),
    .CLK(\rx_shift_reg_0<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_0<5>/FFY/RST ),
    .O(rx_shift_reg_0[4])
  );
  X_BUF \rx_shift_reg_2<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_2<1>/FFY/RST )
  );
  X_FF rx_shift_reg_2_0 (
    .I(rx_shift_reg_2[1]),
    .CE(VCC),
    .CLK(\rx_shift_reg_2<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_2<1>/FFY/RST ),
    .O(rx_shift_reg_2[0])
  );
  X_BUF \rx_shift_reg_4<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_4<3>/FFX/RST )
  );
  X_FF rx_shift_reg_4_3 (
    .I(rx_shift_reg_4[4]),
    .CE(VCC),
    .CLK(\rx_shift_reg_4<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_4<3>/FFX/RST ),
    .O(rx_shift_reg_4[3])
  );
  X_BUF \rx_buf_reg_5<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_5<3>/FFY/RST )
  );
  X_FF rx_buf_reg_5_2 (
    .I(rx_shift_reg_5[2]),
    .CE(\_n00581/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_5<3>/FFY/RST ),
    .O(rx_buf_reg_5[2])
  );
  X_BUF \rx_shift_reg_1<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_1<1>/FFY/RST )
  );
  X_FF rx_shift_reg_1_0 (
    .I(rx_shift_reg_1[1]),
    .CE(VCC),
    .CLK(\rx_shift_reg_1<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_1<1>/FFY/RST ),
    .O(rx_shift_reg_1[0])
  );
  X_BUF \rx_shift_reg_1<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_1<5>/FFY/RST )
  );
  X_FF rx_shift_reg_1_4 (
    .I(rx_shift_reg_1[5]),
    .CE(VCC),
    .CLK(\rx_shift_reg_1<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_1<5>/FFY/RST ),
    .O(rx_shift_reg_1[4])
  );
  X_BUF \rx_shift_reg_2<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_2<1>/FFX/RST )
  );
  X_FF rx_shift_reg_2_1 (
    .I(rx_shift_reg_2[2]),
    .CE(VCC),
    .CLK(\rx_shift_reg_2<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_2<1>/FFX/RST ),
    .O(rx_shift_reg_2[1])
  );
  X_BUF \rx_shift_reg_0<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_0<6>/FFY/RST )
  );
  X_FF rx_shift_reg_0_6 (
    .I(rx_shift_reg_0[7]),
    .CE(VCC),
    .CLK(\rx_shift_reg_0<6>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_0<6>/FFY/RST ),
    .O(rx_shift_reg_0[6])
  );
  X_BUF \rx_shift_reg_1<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_1<3>/FFY/RST )
  );
  X_FF rx_shift_reg_1_2 (
    .I(rx_shift_reg_1[3]),
    .CE(VCC),
    .CLK(\rx_shift_reg_1<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_1<3>/FFY/RST ),
    .O(rx_shift_reg_1[2])
  );
  X_BUF \rx_shift_reg_6<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_6<1>/FFY/RST )
  );
  X_FF rx_shift_reg_6_0 (
    .I(rx_shift_reg_6[1]),
    .CE(VCC),
    .CLK(\rx_shift_reg_6<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_6<1>/FFY/RST ),
    .O(rx_shift_reg_6[0])
  );
  X_BUF \rx_shift_reg_4<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_4<1>/FFY/RST )
  );
  X_FF rx_shift_reg_4_0 (
    .I(rx_shift_reg_4[1]),
    .CE(VCC),
    .CLK(\rx_shift_reg_4<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_4<1>/FFY/RST ),
    .O(rx_shift_reg_4[0])
  );
  X_BUF \rx_shift_reg_1<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_1<6>/FFY/RST )
  );
  X_FF rx_shift_reg_1_6 (
    .I(rx_shift_reg_1[7]),
    .CE(VCC),
    .CLK(\rx_shift_reg_1<6>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_1<6>/FFY/RST ),
    .O(rx_shift_reg_1[6])
  );
  X_BUF \rx_shift_reg_4<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_4<1>/FFX/RST )
  );
  X_FF rx_shift_reg_4_1 (
    .I(rx_shift_reg_4[2]),
    .CE(VCC),
    .CLK(\rx_shift_reg_4<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_4<1>/FFX/RST ),
    .O(rx_shift_reg_4[1])
  );
  X_BUF \rx_shift_reg_2<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_2<5>/FFX/RST )
  );
  X_FF rx_shift_reg_2_5 (
    .I(rx_shift_reg_2[6]),
    .CE(VCC),
    .CLK(\rx_shift_reg_2<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_2<5>/FFX/RST ),
    .O(rx_shift_reg_2[5])
  );
  X_BUF \rx_shift_reg_6<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_6<1>/FFX/RST )
  );
  X_FF rx_shift_reg_6_1 (
    .I(rx_shift_reg_6[2]),
    .CE(VCC),
    .CLK(\rx_shift_reg_6<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_6<1>/FFX/RST ),
    .O(rx_shift_reg_6[1])
  );
  X_BUF \rx_shift_reg_3<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_3<1>/FFX/RST )
  );
  X_FF rx_shift_reg_3_1 (
    .I(rx_shift_reg_3[2]),
    .CE(VCC),
    .CLK(\rx_shift_reg_3<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_3<1>/FFX/RST ),
    .O(rx_shift_reg_3[1])
  );
  X_BUF \rx_shift_reg_2<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_2<5>/FFY/RST )
  );
  X_FF rx_shift_reg_2_4 (
    .I(rx_shift_reg_2[5]),
    .CE(VCC),
    .CLK(\rx_shift_reg_2<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_2<5>/FFY/RST ),
    .O(rx_shift_reg_2[4])
  );
  X_BUF \rx_shift_reg_3<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_3<1>/FFY/RST )
  );
  X_FF rx_shift_reg_3_0 (
    .I(rx_shift_reg_3[1]),
    .CE(VCC),
    .CLK(\rx_shift_reg_3<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_3<1>/FFY/RST ),
    .O(rx_shift_reg_3[0])
  );
  X_BUF \rx_shift_reg_2<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_2<6>/FFY/RST )
  );
  X_FF rx_shift_reg_2_6 (
    .I(rx_shift_reg_2[7]),
    .CE(VCC),
    .CLK(\rx_shift_reg_2<6>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_2<6>/FFY/RST ),
    .O(rx_shift_reg_2[6])
  );
  X_BUF \rx_buf_reg_5<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_5<3>/FFX/RST )
  );
  X_FF rx_buf_reg_5_3 (
    .I(rx_shift_reg_5[3]),
    .CE(\_n00581/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_5<3>/FFX/RST ),
    .O(rx_buf_reg_5[3])
  );
  X_BUF \tx_buf_reg_4<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_4<3>/FFY/RST )
  );
  X_FF tx_buf_reg_4_2 (
    .I(data_out_bus[2]),
    .CE(\_n00311/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_4<3>/FFY/RST ),
    .O(tx_buf_reg_4[2])
  );
  X_BUF \rx_shift_reg_5<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_5<3>/FFY/RST )
  );
  X_FF rx_shift_reg_5_2 (
    .I(rx_shift_reg_5[3]),
    .CE(VCC),
    .CLK(\rx_shift_reg_5<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_5<3>/FFY/RST ),
    .O(rx_shift_reg_5[2])
  );
  X_BUF \rx_shift_reg_5<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_5<3>/FFX/RST )
  );
  X_FF rx_shift_reg_5_3 (
    .I(rx_shift_reg_5[4]),
    .CE(VCC),
    .CLK(\rx_shift_reg_5<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_5<3>/FFX/RST ),
    .O(rx_shift_reg_5[3])
  );
  X_BUF \rx_shift_reg_5<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_5<1>/FFX/RST )
  );
  X_FF rx_shift_reg_5_1 (
    .I(rx_shift_reg_5[2]),
    .CE(VCC),
    .CLK(\rx_shift_reg_5<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_5<1>/FFX/RST ),
    .O(rx_shift_reg_5[1])
  );
  X_BUF \rx_shift_reg_7<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_7<1>/FFX/RST )
  );
  X_FF rx_shift_reg_7_1 (
    .I(rx_shift_reg_7[2]),
    .CE(VCC),
    .CLK(\rx_shift_reg_7<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_7<1>/FFX/RST ),
    .O(rx_shift_reg_7[1])
  );
  X_BUF \rx_shift_reg_5<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_5<6>/FFY/RST )
  );
  X_FF rx_shift_reg_5_6 (
    .I(rx_shift_reg_5[7]),
    .CE(VCC),
    .CLK(\rx_shift_reg_5<6>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_5<6>/FFY/RST ),
    .O(rx_shift_reg_5[6])
  );
  X_BUF \rx_shift_reg_6<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_6<3>/FFX/RST )
  );
  X_FF rx_shift_reg_6_3 (
    .I(rx_shift_reg_6[4]),
    .CE(VCC),
    .CLK(\rx_shift_reg_6<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_6<3>/FFX/RST ),
    .O(rx_shift_reg_6[3])
  );
  X_BUF \rx_shift_reg_7<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_7<3>/FFX/RST )
  );
  X_FF rx_shift_reg_7_3 (
    .I(rx_shift_reg_7[4]),
    .CE(VCC),
    .CLK(\rx_shift_reg_7<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_7<3>/FFX/RST ),
    .O(rx_shift_reg_7[3])
  );
  X_BUF \rx_shift_reg_7<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_7<5>/FFY/RST )
  );
  X_FF rx_shift_reg_7_4 (
    .I(rx_shift_reg_7[5]),
    .CE(VCC),
    .CLK(\rx_shift_reg_7<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_7<5>/FFY/RST ),
    .O(rx_shift_reg_7[4])
  );
  X_BUF \rx_shift_reg_6<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_6<3>/FFY/RST )
  );
  X_FF rx_shift_reg_6_2 (
    .I(rx_shift_reg_6[3]),
    .CE(VCC),
    .CLK(\rx_shift_reg_6<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_6<3>/FFY/RST ),
    .O(rx_shift_reg_6[2])
  );
  X_BUF \rx_shift_reg_6<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_6<5>/FFX/RST )
  );
  X_FF rx_shift_reg_6_5 (
    .I(rx_shift_reg_6[6]),
    .CE(VCC),
    .CLK(\rx_shift_reg_6<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_6<5>/FFX/RST ),
    .O(rx_shift_reg_6[5])
  );
  X_BUF \rx_shift_reg_7<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_7<3>/FFY/RST )
  );
  X_FF rx_shift_reg_7_2 (
    .I(rx_shift_reg_7[3]),
    .CE(VCC),
    .CLK(\rx_shift_reg_7<3>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_7<3>/FFY/RST ),
    .O(rx_shift_reg_7[2])
  );
  X_BUF \rx_shift_reg_7<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_7<1>/FFY/RST )
  );
  X_FF rx_shift_reg_7_0 (
    .I(rx_shift_reg_7[1]),
    .CE(VCC),
    .CLK(\rx_shift_reg_7<1>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_7<1>/FFY/RST ),
    .O(rx_shift_reg_7[0])
  );
  X_BUF \rx_shift_reg_7<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_7<5>/FFX/RST )
  );
  X_FF rx_shift_reg_7_5 (
    .I(rx_shift_reg_7[6]),
    .CE(VCC),
    .CLK(\rx_shift_reg_7<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_7<5>/FFX/RST ),
    .O(rx_shift_reg_7[5])
  );
  X_BUF \rx_shift_reg_6<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_6<6>/FFY/RST )
  );
  X_FF rx_shift_reg_6_6 (
    .I(rx_shift_reg_6[7]),
    .CE(VCC),
    .CLK(\rx_shift_reg_6<6>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_6<6>/FFY/RST ),
    .O(rx_shift_reg_6[6])
  );
  X_BUF \rx_shift_reg_6<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_6<5>/FFY/RST )
  );
  X_FF rx_shift_reg_6_4 (
    .I(rx_shift_reg_6[5]),
    .CE(VCC),
    .CLK(\rx_shift_reg_6<5>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_6<5>/FFY/RST ),
    .O(rx_shift_reg_6[4])
  );
  X_BUF \rx_buf_reg_1<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_1<5>/FFY/RST )
  );
  X_FF rx_buf_reg_1_4 (
    .I(rx_shift_reg_1[4]),
    .CE(\_n00621/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_1<5>/FFY/RST ),
    .O(rx_buf_reg_1[4])
  );
  X_OR2 \div_reg_2/FFY/RSTOR  (
    .I0(\div_reg_2/SRMUX_OUTPUTNOT ),
    .I1(GSR),
    .O(\div_reg_2/FFY/RST )
  );
  X_FF div_reg_1_99 (
    .I(\div_reg_2/BYMUXNOT ),
    .CE(VCC),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\div_reg_2/FFY/RST ),
    .O(div_reg_1)
  );
  X_OR2 \div_reg_2/FFX/RSTOR  (
    .I0(\div_reg_2/SRMUX_OUTPUTNOT ),
    .I1(GSR),
    .O(\div_reg_2/FFX/RST )
  );
  X_FF div_reg_2_100 (
    .I(\div_reg_2/BXMUXNOT ),
    .CE(VCC),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\div_reg_2/FFX/RST ),
    .O(div_reg_2)
  );
  X_BUF \rx_shift_reg_7<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_shift_reg_7<6>/FFY/RST )
  );
  X_FF rx_shift_reg_7_6 (
    .I(rx_shift_reg_7[7]),
    .CE(VCC),
    .CLK(\rx_shift_reg_7<6>/CKMUXNOT ),
    .SET(GND),
    .RST(\rx_shift_reg_7<6>/FFY/RST ),
    .O(rx_shift_reg_7[6])
  );
  X_BUF \tx_buf_reg_5<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_5<7>/FFX/RST )
  );
  X_FF tx_buf_reg_5_7 (
    .I(data_out_bus[7]),
    .CE(\_n00321/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_5<7>/FFX/RST ),
    .O(tx_buf_reg_5[7])
  );
  X_BUF \rx_buf_reg_0<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_0<3>/FFY/RST )
  );
  X_FF rx_buf_reg_0_2 (
    .I(rx_shift_reg_0[2]),
    .CE(\_n00631/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_0<3>/FFY/RST ),
    .O(rx_buf_reg_0[2])
  );
  X_BUF \rx_buf_reg_1<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_1<3>/FFX/RST )
  );
  X_FF rx_buf_reg_1_3 (
    .I(rx_shift_reg_1[3]),
    .CE(\_n00621/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_1<3>/FFX/RST ),
    .O(rx_buf_reg_1[3])
  );
  X_BUF \rx_buf_reg_2<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_2<3>/FFY/RST )
  );
  X_FF rx_buf_reg_2_2 (
    .I(rx_shift_reg_2[2]),
    .CE(\_n00611/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_2<3>/FFY/RST ),
    .O(rx_buf_reg_2[2])
  );
  X_BUF \rx_buf_reg_2<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_2<3>/FFX/RST )
  );
  X_FF rx_buf_reg_2_3 (
    .I(rx_shift_reg_2[3]),
    .CE(\_n00611/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_2<3>/FFX/RST ),
    .O(rx_buf_reg_2[3])
  );
  X_BUF \rx_buf_reg_0<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_0<5>/FFY/RST )
  );
  X_FF rx_buf_reg_0_4 (
    .I(rx_shift_reg_0[4]),
    .CE(\_n00631/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_0<5>/FFY/RST ),
    .O(rx_buf_reg_0[4])
  );
  X_BUF \rx_buf_reg_5<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_5<5>/FFY/RST )
  );
  X_FF rx_buf_reg_5_4 (
    .I(rx_shift_reg_5[4]),
    .CE(\_n00581/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_5<5>/FFY/RST ),
    .O(rx_buf_reg_5[4])
  );
  X_BUF \rx_buf_reg_1<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_1<7>/FFX/RST )
  );
  X_FF rx_buf_reg_1_7 (
    .I(rx_shift_reg_1[7]),
    .CE(\_n00621/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_1<7>/FFX/RST ),
    .O(rx_buf_reg_1[7])
  );
  X_BUF \rx_buf_reg_4<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_4<7>/FFX/RST )
  );
  X_FF rx_buf_reg_4_7 (
    .I(rx_shift_reg_4[7]),
    .CE(\_n00591/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_4<7>/FFX/RST ),
    .O(rx_buf_reg_4[7])
  );
  X_BUF \rx_buf_reg_1<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_1<7>/FFY/RST )
  );
  X_FF rx_buf_reg_1_6 (
    .I(rx_shift_reg_1[6]),
    .CE(\_n00621/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_1<7>/FFY/RST ),
    .O(rx_buf_reg_1[6])
  );
  X_BUF \rx_buf_reg_4<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_4<7>/FFY/RST )
  );
  X_FF rx_buf_reg_4_6 (
    .I(rx_shift_reg_4[6]),
    .CE(\_n00591/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_4<7>/FFY/RST ),
    .O(rx_buf_reg_4[6])
  );
  X_BUF \rx_buf_reg_1<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_1<5>/FFX/RST )
  );
  X_FF rx_buf_reg_1_5 (
    .I(rx_shift_reg_1[5]),
    .CE(\_n00621/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_1<5>/FFX/RST ),
    .O(rx_buf_reg_1[5])
  );
  X_BUF \rx_buf_reg_0<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_0<3>/FFX/RST )
  );
  X_FF rx_buf_reg_0_3 (
    .I(rx_shift_reg_0[3]),
    .CE(\_n00631/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_0<3>/FFX/RST ),
    .O(rx_buf_reg_0[3])
  );
  X_BUF \tx_buf_reg_5<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_5<5>/FFX/RST )
  );
  X_FF tx_buf_reg_5_5 (
    .I(data_out_bus[5]),
    .CE(\_n00321/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_5<5>/FFX/RST ),
    .O(tx_buf_reg_5[5])
  );
  X_BUF \rx_buf_reg_0<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_0<5>/FFX/RST )
  );
  X_FF rx_buf_reg_0_5 (
    .I(rx_shift_reg_0[5]),
    .CE(\_n00631/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_0<5>/FFX/RST ),
    .O(rx_buf_reg_0[5])
  );
  X_BUF \rx_buf_reg_0<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_0<7>/FFX/RST )
  );
  X_FF rx_buf_reg_0_7 (
    .I(rx_shift_reg_0[7]),
    .CE(\_n00631/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_0<7>/FFX/RST ),
    .O(rx_buf_reg_0[7])
  );
  X_BUF \rx_buf_reg_0<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_0<7>/FFY/RST )
  );
  X_FF rx_buf_reg_0_6 (
    .I(rx_shift_reg_0[6]),
    .CE(\_n00631/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_0<7>/FFY/RST ),
    .O(rx_buf_reg_0[6])
  );
  X_BUF \rx_buf_reg_3<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_3<5>/FFX/RST )
  );
  X_FF rx_buf_reg_3_5 (
    .I(rx_shift_reg_3[5]),
    .CE(\_n00601/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_3<5>/FFX/RST ),
    .O(rx_buf_reg_3[5])
  );
  X_BUF \rx_buf_reg_1<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_1<3>/FFY/RST )
  );
  X_FF rx_buf_reg_1_2 (
    .I(rx_shift_reg_1[2]),
    .CE(\_n00621/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_1<3>/FFY/RST ),
    .O(rx_buf_reg_1[2])
  );
  X_BUF \rx_buf_reg_2<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_2<7>/FFY/RST )
  );
  X_FF rx_buf_reg_2_6 (
    .I(rx_shift_reg_2[6]),
    .CE(\_n00611/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_2<7>/FFY/RST ),
    .O(rx_buf_reg_2[6])
  );
  X_BUF \tx_buf_reg_4<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_4<7>/FFX/RST )
  );
  X_FF tx_buf_reg_4_7 (
    .I(data_out_bus[7]),
    .CE(\_n00311/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_4<7>/FFX/RST ),
    .O(tx_buf_reg_4[7])
  );
  X_BUF \tx_buf_reg_5<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_5<7>/FFY/RST )
  );
  X_FF tx_buf_reg_5_6 (
    .I(data_out_bus[6]),
    .CE(\_n00321/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_5<7>/FFY/RST ),
    .O(tx_buf_reg_5[6])
  );
  X_BUF \rx_buf_reg_2<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_2<7>/FFX/RST )
  );
  X_FF rx_buf_reg_2_7 (
    .I(rx_shift_reg_2[7]),
    .CE(\_n00611/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_2<7>/FFX/RST ),
    .O(rx_buf_reg_2[7])
  );
  X_BUF \rx_buf_reg_3<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_3<5>/FFY/RST )
  );
  X_FF rx_buf_reg_3_4 (
    .I(rx_shift_reg_3[4]),
    .CE(\_n00601/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_3<5>/FFY/RST ),
    .O(rx_buf_reg_3[4])
  );
  X_BUF \tx_buf_reg_5<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_5<5>/FFY/RST )
  );
  X_FF tx_buf_reg_5_4 (
    .I(data_out_bus[4]),
    .CE(\_n00321/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_5<5>/FFY/RST ),
    .O(tx_buf_reg_5[4])
  );
  X_BUF \rx_buf_reg_4<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_4<3>/FFY/RST )
  );
  X_FF rx_buf_reg_4_2 (
    .I(rx_shift_reg_4[2]),
    .CE(\_n00591/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_4<3>/FFY/RST ),
    .O(rx_buf_reg_4[2])
  );
  X_BUF \rx_buf_reg_4<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_4<3>/FFX/RST )
  );
  X_FF rx_buf_reg_4_3 (
    .I(rx_shift_reg_4[3]),
    .CE(\_n00591/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_4<3>/FFX/RST ),
    .O(rx_buf_reg_4[3])
  );
  X_BUF \tx_buf_reg_4<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_4<7>/FFY/RST )
  );
  X_FF tx_buf_reg_4_6 (
    .I(data_out_bus[6]),
    .CE(\_n00311/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_4<7>/FFY/RST ),
    .O(tx_buf_reg_4[6])
  );
  X_BUF \rx_buf_reg_5<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_5<5>/FFX/RST )
  );
  X_FF rx_buf_reg_5_5 (
    .I(rx_shift_reg_5[5]),
    .CE(\_n00581/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_5<5>/FFX/RST ),
    .O(rx_buf_reg_5[5])
  );
  X_BUF \rx_buf_reg_7<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_7<7>/FFX/RST )
  );
  X_FF rx_buf_reg_7_7 (
    .I(rx_shift_reg_7[7]),
    .CE(\_n00561/O ),
    .CLK(div_reg_2),
    .SET(GND),
    .RST(\rx_buf_reg_7<7>/FFX/RST ),
    .O(rx_buf_reg_7[7])
  );
  X_BUF \tx_buf_reg_1<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_1<7>/FFX/RST )
  );
  X_FF tx_buf_reg_1_7 (
    .I(data_out_bus[7]),
    .CE(_n0028),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_1<7>/FFX/RST ),
    .O(tx_buf_reg_1[7])
  );
  X_BUF \rx_buf_reg_5<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_5<7>/FFY/RST )
  );
  X_FF rx_buf_reg_5_6 (
    .I(rx_shift_reg_5[6]),
    .CE(\_n00581/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_5<7>/FFY/RST ),
    .O(rx_buf_reg_5[6])
  );
  X_OR2 \frame_cnt_1_1/FFY/RSTOR  (
    .I0(\frame_cnt_1_1/SRMUX_OUTPUTNOT ),
    .I1(GSR),
    .O(\frame_cnt_1_1/FFY/RST )
  );
  X_FF frame_cnt_1_1_101 (
    .I(frame_cnt__n0000[1]),
    .CE(VCC),
    .CLK(\frame_cnt_1_1/CKMUXNOT ),
    .SET(GND),
    .RST(\frame_cnt_1_1/FFY/RST ),
    .O(frame_cnt_1_1)
  );
  X_BUF \rx_buf_reg_5<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_5<7>/FFX/RST )
  );
  X_FF rx_buf_reg_5_7 (
    .I(rx_shift_reg_5[7]),
    .CE(\_n00581/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_5<7>/FFX/RST ),
    .O(rx_buf_reg_5[7])
  );
  X_BUF \rx_buf_reg_6<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_6<3>/FFX/RST )
  );
  X_FF rx_buf_reg_6_3 (
    .I(rx_shift_reg_6[3]),
    .CE(\_n00571/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_6<3>/FFX/RST ),
    .O(rx_buf_reg_6[3])
  );
  X_BUF \rx_buf_reg_6<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_6<7>/FFY/RST )
  );
  X_FF rx_buf_reg_6_7 (
    .I(rx_shift_reg_6[7]),
    .CE(\_n00571/O ),
    .CLK(div_reg_2),
    .SET(GND),
    .RST(\rx_buf_reg_6<7>/FFY/RST ),
    .O(rx_buf_reg_6[7])
  );
  X_BUF \rx_buf_reg_7<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_7<3>/FFX/RST )
  );
  X_FF rx_buf_reg_7_3 (
    .I(rx_shift_reg_7[3]),
    .CE(\_n00561/O ),
    .CLK(div_reg_2),
    .SET(GND),
    .RST(\rx_buf_reg_7<3>/FFX/RST ),
    .O(rx_buf_reg_7[3])
  );
  X_BUF \rx_buf_reg_6<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_6<3>/FFY/RST )
  );
  X_FF rx_buf_reg_6_2 (
    .I(rx_shift_reg_6[2]),
    .CE(\_n00571/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_6<3>/FFY/RST ),
    .O(rx_buf_reg_6[2])
  );
  X_BUF \rx_buf_reg_6<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_6<5>/FFX/RST )
  );
  X_FF rx_buf_reg_6_5 (
    .I(rx_shift_reg_6[5]),
    .CE(\_n00571/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_6<5>/FFX/RST ),
    .O(rx_buf_reg_6[5])
  );
  X_BUF \tx_buf_reg_0<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_0<5>/FFY/RST )
  );
  X_FF tx_buf_reg_0_4 (
    .I(data_out_bus[4]),
    .CE(_n0027),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_0<5>/FFY/RST ),
    .O(tx_buf_reg_0[4])
  );
  X_BUF \rx_buf_reg_7<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_7<3>/FFY/RST )
  );
  X_FF rx_buf_reg_7_2 (
    .I(rx_shift_reg_7[2]),
    .CE(\_n00561/O ),
    .CLK(div_reg_2),
    .SET(GND),
    .RST(\rx_buf_reg_7<3>/FFY/RST ),
    .O(rx_buf_reg_7[2])
  );
  X_BUF \rx_buf_reg_7<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_7<7>/FFY/RST )
  );
  X_FF rx_buf_reg_7_6 (
    .I(rx_shift_reg_7[6]),
    .CE(\_n00561/O ),
    .CLK(div_reg_2),
    .SET(GND),
    .RST(\rx_buf_reg_7<7>/FFY/RST ),
    .O(rx_buf_reg_7[6])
  );
  X_BUF \rx_buf_reg_7<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_7<5>/FFY/RST )
  );
  X_FF rx_buf_reg_7_4 (
    .I(rx_shift_reg_7[4]),
    .CE(\_n00561/O ),
    .CLK(div_reg_2),
    .SET(GND),
    .RST(\rx_buf_reg_7<5>/FFY/RST ),
    .O(rx_buf_reg_7[4])
  );
  X_BUF \rx_buf_reg_7<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_7<5>/FFX/RST )
  );
  X_FF rx_buf_reg_7_5 (
    .I(rx_shift_reg_7[5]),
    .CE(\_n00561/O ),
    .CLK(div_reg_2),
    .SET(GND),
    .RST(\rx_buf_reg_7<5>/FFX/RST ),
    .O(rx_buf_reg_7[5])
  );
  X_BUF \rx_buf_reg_6<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_6<5>/FFY/RST )
  );
  X_FF rx_buf_reg_6_4 (
    .I(rx_shift_reg_6[4]),
    .CE(\_n00571/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_6<5>/FFY/RST ),
    .O(rx_buf_reg_6[4])
  );
  X_BUF \rx_buf_reg_6<6>/FFY/RSTOR  (
    .I(GSR),
    .O(\rx_buf_reg_6<6>/FFY/RST )
  );
  X_FF rx_buf_reg_6_6 (
    .I(rx_shift_reg_6[6]),
    .CE(\_n00571/O ),
    .CLK(div_reg),
    .SET(GND),
    .RST(\rx_buf_reg_6<6>/FFY/RST ),
    .O(rx_buf_reg_6[6])
  );
  X_BUF \tx_buf_reg_0<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_0<1>/FFY/RST )
  );
  X_FF tx_buf_reg_0_0 (
    .I(data_out_bus[0]),
    .CE(_n0027),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_0<1>/FFY/RST ),
    .O(tx_buf_reg_0[0])
  );
  X_BUF \tx_buf_reg_4<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_4<5>/FFY/RST )
  );
  X_FF tx_buf_reg_4_4 (
    .I(data_out_bus[4]),
    .CE(\_n00311/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_4<5>/FFY/RST ),
    .O(tx_buf_reg_4[4])
  );
  X_BUF \tx_buf_reg_5<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_5<3>/FFX/RST )
  );
  X_FF tx_buf_reg_5_3 (
    .I(data_out_bus[3]),
    .CE(\_n00321/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_5<3>/FFX/RST ),
    .O(tx_buf_reg_5[3])
  );
  X_BUF \tx_buf_reg_0<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_0<5>/FFX/RST )
  );
  X_FF tx_buf_reg_0_5 (
    .I(data_out_bus[5]),
    .CE(_n0027),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_0<5>/FFX/RST ),
    .O(tx_buf_reg_0[5])
  );
  X_BUF \tx_buf_reg_1<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_1<5>/FFX/RST )
  );
  X_FF tx_buf_reg_1_5 (
    .I(data_out_bus[5]),
    .CE(_n0028),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_1<5>/FFX/RST ),
    .O(tx_buf_reg_1[5])
  );
  X_BUF \tx_buf_reg_0<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_0<3>/FFY/RST )
  );
  X_FF tx_buf_reg_0_2 (
    .I(data_out_bus[2]),
    .CE(_n0027),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_0<3>/FFY/RST ),
    .O(tx_buf_reg_0[2])
  );
  X_BUF \tx_buf_reg_0<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_0<1>/FFX/RST )
  );
  X_FF tx_buf_reg_0_1 (
    .I(data_out_bus[1]),
    .CE(_n0027),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_0<1>/FFX/RST ),
    .O(tx_buf_reg_0[1])
  );
  X_BUF \tx_buf_reg_6<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_6<1>/FFY/RST )
  );
  X_FF tx_buf_reg_6_0 (
    .I(data_out_bus[0]),
    .CE(_n0033),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_6<1>/FFY/RST ),
    .O(tx_buf_reg_6[0])
  );
  X_BUF \tx_buf_reg_0<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_0<3>/FFX/RST )
  );
  X_FF tx_buf_reg_0_3 (
    .I(data_out_bus[3]),
    .CE(_n0027),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_0<3>/FFX/RST ),
    .O(tx_buf_reg_0[3])
  );
  X_BUF \tx_buf_reg_1<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_1<3>/FFX/RST )
  );
  X_FF tx_buf_reg_1_3 (
    .I(data_out_bus[3]),
    .CE(_n0028),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_1<3>/FFX/RST ),
    .O(tx_buf_reg_1[3])
  );
  X_BUF \tx_buf_reg_1<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_1<1>/FFX/RST )
  );
  X_FF tx_buf_reg_1_1 (
    .I(data_out_bus[1]),
    .CE(_n0028),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_1<1>/FFX/RST ),
    .O(tx_buf_reg_1[1])
  );
  X_BUF \tx_buf_reg_2<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_2<5>/FFX/RST )
  );
  X_FF tx_buf_reg_2_5 (
    .I(data_out_bus[5]),
    .CE(_n0029),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_2<5>/FFX/RST ),
    .O(tx_buf_reg_2[5])
  );
  X_BUF \tx_buf_reg_2<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_2<1>/FFY/RST )
  );
  X_FF tx_buf_reg_2_0 (
    .I(data_out_bus[0]),
    .CE(_n0029),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_2<1>/FFY/RST ),
    .O(tx_buf_reg_2[0])
  );
  X_BUF \tx_buf_reg_0<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_0<7>/FFX/RST )
  );
  X_FF tx_buf_reg_0_7 (
    .I(data_out_bus[7]),
    .CE(_n0027),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_0<7>/FFX/RST ),
    .O(tx_buf_reg_0[7])
  );
  X_BUF \tx_buf_reg_1<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_1<1>/FFY/RST )
  );
  X_FF tx_buf_reg_1_0 (
    .I(data_out_bus[0]),
    .CE(_n0028),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_1<1>/FFY/RST ),
    .O(tx_buf_reg_1[0])
  );
  X_BUF \tx_buf_reg_1<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_1<3>/FFY/RST )
  );
  X_FF tx_buf_reg_1_2 (
    .I(data_out_bus[2]),
    .CE(_n0028),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_1<3>/FFY/RST ),
    .O(tx_buf_reg_1[2])
  );
  X_BUF \tx_buf_reg_0<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_0<7>/FFY/RST )
  );
  X_FF tx_buf_reg_0_6 (
    .I(data_out_bus[6]),
    .CE(_n0027),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_0<7>/FFY/RST ),
    .O(tx_buf_reg_0[6])
  );
  X_BUF \tx_buf_reg_6<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_6<1>/FFX/RST )
  );
  X_FF tx_buf_reg_6_1 (
    .I(data_out_bus[1]),
    .CE(_n0033),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_6<1>/FFX/RST ),
    .O(tx_buf_reg_6[1])
  );
  X_BUF \tx_buf_reg_2<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_2<1>/FFX/RST )
  );
  X_FF tx_buf_reg_2_1 (
    .I(data_out_bus[1]),
    .CE(_n0029),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_2<1>/FFX/RST ),
    .O(tx_buf_reg_2[1])
  );
  X_BUF \tx_buf_reg_1<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_1<5>/FFY/RST )
  );
  X_FF tx_buf_reg_1_4 (
    .I(data_out_bus[4]),
    .CE(_n0028),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_1<5>/FFY/RST ),
    .O(tx_buf_reg_1[4])
  );
  X_BUF \tx_buf_reg_2<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_2<3>/FFX/RST )
  );
  X_FF tx_buf_reg_2_3 (
    .I(data_out_bus[3]),
    .CE(_n0029),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_2<3>/FFX/RST ),
    .O(tx_buf_reg_2[3])
  );
  X_BUF \tx_buf_reg_3<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_3<3>/FFY/RST )
  );
  X_FF tx_buf_reg_3_2 (
    .I(data_out_bus[2]),
    .CE(_n0030),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_3<3>/FFY/RST ),
    .O(tx_buf_reg_3[2])
  );
  X_BUF \tx_buf_reg_3<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_3<1>/FFY/RST )
  );
  X_FF tx_buf_reg_3_0 (
    .I(data_out_bus[0]),
    .CE(_n0030),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_3<1>/FFY/RST ),
    .O(tx_buf_reg_3[0])
  );
  X_BUF \tx_buf_reg_2<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_2<3>/FFY/RST )
  );
  X_FF tx_buf_reg_2_2 (
    .I(data_out_bus[2]),
    .CE(_n0029),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_2<3>/FFY/RST ),
    .O(tx_buf_reg_2[2])
  );
  X_BUF \tx_buf_reg_1<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_1<7>/FFY/RST )
  );
  X_FF tx_buf_reg_1_6 (
    .I(data_out_bus[6]),
    .CE(_n0028),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_1<7>/FFY/RST ),
    .O(tx_buf_reg_1[6])
  );
  X_BUF \tx_buf_reg_3<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_3<7>/FFX/RST )
  );
  X_FF tx_buf_reg_3_7 (
    .I(data_out_bus[7]),
    .CE(_n0030),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_3<7>/FFX/RST ),
    .O(tx_buf_reg_3[7])
  );
  X_BUF \tx_buf_reg_3<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_3<1>/FFX/RST )
  );
  X_FF tx_buf_reg_3_1 (
    .I(data_out_bus[1]),
    .CE(_n0030),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_3<1>/FFX/RST ),
    .O(tx_buf_reg_3[1])
  );
  X_BUF \tx_buf_reg_2<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_2<5>/FFY/RST )
  );
  X_FF tx_buf_reg_2_4 (
    .I(data_out_bus[4]),
    .CE(_n0029),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_2<5>/FFY/RST ),
    .O(tx_buf_reg_2[4])
  );
  X_BUF \tx_buf_reg_4<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_4<5>/FFX/RST )
  );
  X_FF tx_buf_reg_4_5 (
    .I(data_out_bus[5]),
    .CE(\_n00311/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_4<5>/FFX/RST ),
    .O(tx_buf_reg_4[5])
  );
  X_BUF \tx_buf_reg_5<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_5<3>/FFY/RST )
  );
  X_FF tx_buf_reg_5_2 (
    .I(data_out_bus[2]),
    .CE(\_n00321/O ),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_5<3>/FFY/RST ),
    .O(tx_buf_reg_5[2])
  );
  X_BUF \tx_buf_reg_3<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_3<7>/FFY/RST )
  );
  X_FF tx_buf_reg_3_6 (
    .I(data_out_bus[6]),
    .CE(_n0030),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_3<7>/FFY/RST ),
    .O(tx_buf_reg_3[6])
  );
  X_BUF \tx_buf_reg_3<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_3<3>/FFX/RST )
  );
  X_FF tx_buf_reg_3_3 (
    .I(data_out_bus[3]),
    .CE(_n0030),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_3<3>/FFX/RST ),
    .O(tx_buf_reg_3[3])
  );
  X_BUF \tx_buf_reg_6<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_6<5>/FFX/RST )
  );
  X_FF tx_buf_reg_6_5 (
    .I(data_out_bus[5]),
    .CE(_n0033),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_6<5>/FFX/RST ),
    .O(tx_buf_reg_6[5])
  );
  X_BUF \tx_buf_reg_6<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_6<3>/FFY/RST )
  );
  X_FF tx_buf_reg_6_2 (
    .I(data_out_bus[2]),
    .CE(_n0033),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_6<3>/FFY/RST ),
    .O(tx_buf_reg_6[2])
  );
  X_BUF \tx_buf_reg_6<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_6<3>/FFX/RST )
  );
  X_FF tx_buf_reg_6_3 (
    .I(data_out_bus[3]),
    .CE(_n0033),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_6<3>/FFX/RST ),
    .O(tx_buf_reg_6[3])
  );
  X_BUF \tx_buf_reg_7<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_7<7>/FFY/RST )
  );
  X_FF tx_buf_reg_7_6 (
    .I(data_out_bus[6]),
    .CE(_n0034),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_7<7>/FFY/RST ),
    .O(tx_buf_reg_7[6])
  );
  X_BUF \tx_buf_reg_7<3>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_7<3>/FFX/RST )
  );
  X_FF tx_buf_reg_7_3 (
    .I(data_out_bus[3]),
    .CE(_n0034),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_7<3>/FFX/RST ),
    .O(tx_buf_reg_7[3])
  );
  X_BUF \tx_buf_reg_6<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_6<7>/FFX/RST )
  );
  X_FF tx_buf_reg_6_7 (
    .I(data_out_bus[7]),
    .CE(_n0033),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_6<7>/FFX/RST ),
    .O(tx_buf_reg_6[7])
  );
  X_BUF \frame_delay_buf_4<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\frame_delay_buf_4<1>/FFY/RST )
  );
  X_FF frame_delay_buf_4_0 (
    .I(mpi_data_in_0_IBUF),
    .CE(_n0042),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\frame_delay_buf_4<1>/FFY/RST ),
    .O(frame_delay_buf_4[0])
  );
  X_BUF \tx_buf_reg_6<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_6<5>/FFY/RST )
  );
  X_FF tx_buf_reg_6_4 (
    .I(data_out_bus[4]),
    .CE(_n0033),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_6<5>/FFY/RST ),
    .O(tx_buf_reg_6[4])
  );
  X_BUF \tx_buf_reg_7<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_7<1>/FFY/RST )
  );
  X_FF tx_buf_reg_7_0 (
    .I(data_out_bus[0]),
    .CE(_n0034),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_7<1>/FFY/RST ),
    .O(tx_buf_reg_7[0])
  );
  X_BUF \tx_buf_reg_7<5>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_7<5>/FFX/RST )
  );
  X_FF tx_buf_reg_7_5 (
    .I(data_out_bus[5]),
    .CE(_n0034),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_7<5>/FFX/RST ),
    .O(tx_buf_reg_7[5])
  );
  X_BUF \tx_buf_reg_7<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_7<1>/FFX/RST )
  );
  X_FF tx_buf_reg_7_1 (
    .I(data_out_bus[1]),
    .CE(_n0034),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_7<1>/FFX/RST ),
    .O(tx_buf_reg_7[1])
  );
  X_BUF \frame_delay_buf_0<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\frame_delay_buf_0<1>/FFY/RST )
  );
  X_FF frame_delay_buf_0_0 (
    .I(mpi_data_in_0_IBUF),
    .CE(_n0038),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\frame_delay_buf_0<1>/FFY/RST ),
    .O(frame_delay_buf_0[0])
  );
  X_BUF \tx_buf_reg_7<3>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_7<3>/FFY/RST )
  );
  X_FF tx_buf_reg_7_2 (
    .I(data_out_bus[2]),
    .CE(_n0034),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_7<3>/FFY/RST ),
    .O(tx_buf_reg_7[2])
  );
  X_BUF \tx_buf_reg_6<7>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_6<7>/FFY/RST )
  );
  X_FF tx_buf_reg_6_6 (
    .I(data_out_bus[6]),
    .CE(_n0033),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_6<7>/FFY/RST ),
    .O(tx_buf_reg_6[6])
  );
  X_BUF \frame_delay_buf_1<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\frame_delay_buf_1<1>/FFY/RST )
  );
  X_FF frame_delay_buf_1_0 (
    .I(mpi_data_in_0_IBUF),
    .CE(_n0039),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\frame_delay_buf_1<1>/FFY/RST ),
    .O(frame_delay_buf_1[0])
  );
  X_BUF \frame_delay_buf_6<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\frame_delay_buf_6<1>/FFY/RST )
  );
  X_FF frame_delay_buf_6_0 (
    .I(mpi_data_in_0_IBUF),
    .CE(_n0044),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\frame_delay_buf_6<1>/FFY/RST ),
    .O(frame_delay_buf_6[0])
  );
  X_BUF \tx_buf_reg_7<7>/FFX/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_7<7>/FFX/RST )
  );
  X_FF tx_buf_reg_7_7 (
    .I(data_out_bus[7]),
    .CE(_n0034),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_7<7>/FFX/RST ),
    .O(tx_buf_reg_7[7])
  );
  X_BUF \tx_buf_reg_7<5>/FFY/RSTOR  (
    .I(GSR),
    .O(\tx_buf_reg_7<5>/FFY/RST )
  );
  X_FF tx_buf_reg_7_4 (
    .I(data_out_bus[4]),
    .CE(_n0034),
    .CLK(clk_in_BUFGP),
    .SET(GND),
    .RST(\tx_buf_reg_7<5>/FFY/RST ),
    .O(tx_buf_reg_7[4])
  );
  X_BUF \frame_delay_buf_4<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\frame_delay_buf_4<1>/FFX/RST )
  );
  X_FF frame_delay_buf_4_1 (
    .I(mpi_data_in_1_IBUF),
    .CE(_n0042),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\frame_delay_buf_4<1>/FFX/RST ),
    .O(frame_delay_buf_4[1])
  );
  X_BUF \frame_delay_buf_3<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\frame_delay_buf_3<1>/FFY/RST )
  );
  X_FF frame_delay_buf_3_0 (
    .I(mpi_data_in_0_IBUF),
    .CE(_n0041),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\frame_delay_buf_3<1>/FFY/RST ),
    .O(frame_delay_buf_3[0])
  );
  X_BUF \frame_delay_buf_0<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\frame_delay_buf_0<1>/FFX/RST )
  );
  X_FF frame_delay_buf_0_1 (
    .I(mpi_data_in_1_IBUF),
    .CE(_n0038),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\frame_delay_buf_0<1>/FFX/RST ),
    .O(frame_delay_buf_0[1])
  );
  X_BUF \frame_delay_buf_2<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\frame_delay_buf_2<1>/FFX/RST )
  );
  X_FF frame_delay_buf_2_1 (
    .I(mpi_data_in_1_IBUF),
    .CE(_n0040),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\frame_delay_buf_2<1>/FFX/RST ),
    .O(frame_delay_buf_2[1])
  );
  X_BUF \frame_delay_buf_2<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\frame_delay_buf_2<1>/FFY/RST )
  );
  X_FF frame_delay_buf_2_0 (
    .I(mpi_data_in_0_IBUF),
    .CE(_n0040),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\frame_delay_buf_2<1>/FFY/RST ),
    .O(frame_delay_buf_2[0])
  );
  X_BUF \frame_delay_buf_1<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\frame_delay_buf_1<1>/FFX/RST )
  );
  X_FF frame_delay_buf_1_1 (
    .I(mpi_data_in_1_IBUF),
    .CE(_n0039),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\frame_delay_buf_1<1>/FFX/RST ),
    .O(frame_delay_buf_1[1])
  );
  X_BUF \frame_delay_buf_3<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\frame_delay_buf_3<1>/FFX/RST )
  );
  X_FF frame_delay_buf_3_1 (
    .I(mpi_data_in_1_IBUF),
    .CE(_n0041),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\frame_delay_buf_3<1>/FFX/RST ),
    .O(frame_delay_buf_3[1])
  );
  X_BUF \frame_delay_buf_5<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\frame_delay_buf_5<1>/FFX/RST )
  );
  X_FF frame_delay_buf_5_1 (
    .I(mpi_data_in_1_IBUF),
    .CE(_n0043),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\frame_delay_buf_5<1>/FFX/RST ),
    .O(frame_delay_buf_5[1])
  );
  X_BUF \frame_delay_buf_5<1>/FFY/RSTOR  (
    .I(GSR),
    .O(\frame_delay_buf_5<1>/FFY/RST )
  );
  X_FF frame_delay_buf_5_0 (
    .I(mpi_data_in_0_IBUF),
    .CE(_n0043),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\frame_delay_buf_5<1>/FFY/RST ),
    .O(frame_delay_buf_5[0])
  );
  X_BUF \frame_delay_buf_6<1>/FFX/RSTOR  (
    .I(GSR),
    .O(\frame_delay_buf_6<1>/FFX/RST )
  );
  X_FF frame_delay_buf_6_1 (
    .I(mpi_data_in_1_IBUF),
    .CE(_n0044),
    .CLK(mpi_clk_BUFGP),
    .SET(GND),
    .RST(\frame_delay_buf_6<1>/FFX/RST ),
    .O(frame_delay_buf_6[1])
  );
  X_CKBUF \clk_in/BUF  (
    .I(clk_in),
    .O(\clk_in_BUFGP/IBUFG )
  );
  X_IPAD \clk_in/PAD  (
    .PAD(clk_in)
  );
  X_CKBUF \mpi_clk/BUF  (
    .I(mpi_clk),
    .O(\mpi_clk_BUFGP/IBUFG )
  );
  X_IPAD \mpi_clk/PAD  (
    .PAD(mpi_clk)
  );
  X_CKBUF \clk_in_BUFGP/BUFG/BUF  (
    .I(\clk_in_BUFGP/IBUFG ),
    .O(clk_in_BUFGP)
  );
  X_CKBUF \mpi_clk_BUFGP/BUFG/BUF  (
    .I(\mpi_clk_BUFGP/IBUFG ),
    .O(mpi_clk_BUFGP)
  );
  X_BUF \PWR_VCC_0/YUSED  (
    .I(\PWR_VCC_0/GROM ),
    .O(GLOBAL_LOGIC0_2)
  );
  X_BUF \PWR_VCC_0/XUSED  (
    .I(\PWR_VCC_0/FROM ),
    .O(GLOBAL_LOGIC1)
  );
  defparam \PWR_VCC_0/G .INIT = 16'h0000;
  X_LUT4 \PWR_VCC_0/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\PWR_VCC_0/GROM )
  );
  defparam \PWR_VCC_0/F .INIT = 16'hFFFF;
  X_LUT4 \PWR_VCC_0/F  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\PWR_VCC_0/FROM )
  );
  X_BUF \PWR_VCC_1/XUSED  (
    .I(\PWR_VCC_1/FROM ),
    .O(GLOBAL_LOGIC1_0)
  );
  defparam \PWR_VCC_1/F .INIT = 16'hFFFF;
  X_LUT4 \PWR_VCC_1/F  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\PWR_VCC_1/FROM )
  );
  X_BUF \PWR_VCC_2/XUSED  (
    .I(\PWR_VCC_2/FROM ),
    .O(GLOBAL_LOGIC1_1)
  );
  defparam \PWR_VCC_2/F .INIT = 16'hFFFF;
  X_LUT4 \PWR_VCC_2/F  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\PWR_VCC_2/FROM )
  );
  X_BUF \PWR_GND_0/YUSED  (
    .I(\PWR_GND_0/GROM ),
    .O(GLOBAL_LOGIC0)
  );
  defparam \PWR_GND_0/G .INIT = 16'h0000;
  X_LUT4 \PWR_GND_0/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\PWR_GND_0/GROM )
  );
  X_BUF \PWR_GND_1/YUSED  (
    .I(\PWR_GND_1/GROM ),
    .O(GLOBAL_LOGIC0_3)
  );
  defparam \PWR_GND_1/G .INIT = 16'h0000;
  X_LUT4 \PWR_GND_1/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\PWR_GND_1/GROM )
  );
  X_BUF \PWR_GND_2/YUSED  (
    .I(\PWR_GND_2/GROM ),
    .O(GLOBAL_LOGIC0_4)
  );
  defparam \PWR_GND_2/G .INIT = 16'h0000;
  X_LUT4 \PWR_GND_2/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\PWR_GND_2/GROM )
  );
  X_BUF \PWR_GND_3/YUSED  (
    .I(\PWR_GND_3/GROM ),
    .O(GLOBAL_LOGIC0_5)
  );
  defparam \PWR_GND_3/G .INIT = 16'h0000;
  X_LUT4 \PWR_GND_3/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\PWR_GND_3/GROM )
  );
  X_BUF \PWR_GND_4/YUSED  (
    .I(\PWR_GND_4/GROM ),
    .O(GLOBAL_LOGIC0_6)
  );
  defparam \PWR_GND_4/G .INIT = 16'h0000;
  X_LUT4 \PWR_GND_4/G  (
    .ADR0(VCC),
    .ADR1(VCC),
    .ADR2(VCC),
    .ADR3(VCC),
    .O(\PWR_GND_4/GROM )
  );
  X_ZERO NlwBlock_tdm_switch_top_GND (
    .O(GND)
  );
  X_ONE NlwBlock_tdm_switch_top_VCC (
    .O(VCC)
  );
endmodule

