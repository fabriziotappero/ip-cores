// Signalscan Version 6.7p1


define noactivityindicator
define analog waveform lines
define add variable default overlay off
define waveform window analogheight 1
define terminal automatic
define buttons control \
  1 opensimmulationfile \
  2 executedofile \
  3 designbrowser \
  4 waveform \
  5 source \
  6 breakpoints \
  7 definesourcessearchpath \
  8 exit \
  9 createbreakpoint \
  10 creategroup \
  11 createmarker \
  12 closesimmulationfile \
  13 renamesimmulationfile \
  14 replacesimulationfiledata \
  15 listopensimmulationfiles \
  16 savedofile
define buttons waveform \
  1 undo \
  2 cut \
  3 copy \
  4 paste \
  5 delete \
  6 zoomin \
  7 zoomout \
  8 zoomoutfull \
  9 expand \
  10 createmarker \
  11 designbrowser:1 \
  12 variableradixbinary \
  13 variableradixoctal \
  14 variableradixdecimal \
  15 variableradixhexadecimal \
  16 variableradixascii
define buttons designbrowser \
  1 undo \
  2 cut \
  3 copy \
  4 paste \
  5 delete \
  6 cdupscope \
  7 getallvariables \
  8 getdeepallvariables \
  9 addvariables \
  10 addvarsandclosewindow \
  11 closewindow \
  12 scopefiltermodule \
  13 scopefiltertask \
  14 scopefilterfunction \
  15 scopefilterblock \
  16 scopefilterprimitive
define buttons event \
  1 undo \
  2 cut \
  3 copy \
  4 paste \
  5 delete \
  6 move \
  7 closewindow \
  8 duplicate \
  9 defineasrisingedge \
  10 defineasfallingedge \
  11 defineasanyedge \
  12 variableradixbinary \
  13 variableradixoctal \
  14 variableradixdecimal \
  15 variableradixhexadecimal \
  16 variableradixascii
define buttons source \
  1 undo \
  2 cut \
  3 copy \
  4 paste \
  5 delete \
  6 createbreakpoint \
  7 creategroup \
  8 createmarker \
  9 createevent \
  10 createregisterpage \
  11 closewindow \
  12 opensimmulationfile \
  13 closesimmulationfile \
  14 renamesimmulationfile \
  15 replacesimulationfiledata \
  16 listopensimmulationfiles
define buttons register \
  1 undo \
  2 cut \
  3 copy \
  4 paste \
  5 delete \
  6 createregisterpage \
  7 closewindow \
  8 continuefor \
  9 continueuntil \
  10 continueforever \
  11 stop \
  12 previous \
  13 next \
  14 variableradixbinary \
  15 variableradixhexadecimal \
  16 variableradixascii
define show related transactions  
define exit prompt
define event search direction forward
define variable nofullhierarchy
define variable nofilenames
define variable nofullpathfilenames
include bookmark with filenames
include scope history without filenames
define waveform window listpane 10.99
define waveform window namepane 12.96
define multivalueindication
define pattern curpos dot
define pattern cursor1 dot
define pattern cursor2 dot
define pattern marker dot
define print designer "Simon Teran"
define print border
define print color blackonwhite
define print command "/usr/ucb/lpr -P%P"
define print printer  lp
define print range visible
define print variable visible
define rise fall time low threshold percentage 10
define rise fall time high threshold percentage 90
define rise fall time low value 0
define rise fall time high value 3.3
define sendmail command "/usr/lib/sendmail"
define sequence time width 30.00
define snap

define source noprompt
define time units default
define userdefinedbussymbol
define user guide directory "/usr/local/designacc/signalscan-6.7p1/doc/html"
define waveform window grid off
define waveform window waveheight 14
define waveform window wavespace 6
define web browser command netscape
define zoom outfull on initial add off
add group \
    oc8051_tb \
      oc8051_tb.rst \
      oc8051_tb.clk \

add group \
    oc8051_top \
      oc8051_tb.oc8051_top_1.op1_n[7:0]'h \
      oc8051_tb.oc8051_top_1.op2_n[7:0]'h \
      oc8051_tb.oc8051_top_1.op3_n[7:0]'h \

add group \
    "cpu to cache" \
      oc8051_tb.oc8051_top_1.iack_i \
      oc8051_tb.oc8051_top_1.iadr_o[15:0]'h \
      oc8051_tb.oc8051_top_1.icyc_o \
      oc8051_tb.oc8051_top_1.idat_i[31:0]'h \
      oc8051_tb.oc8051_top_1.istb_o \

add group \
    xrom \
      oc8051_tb.oc8051_top_1.wbi_adr_o[15:0]'h \
      oc8051_tb.oc8051_top_1.wbi_ack_i \
      oc8051_tb.oc8051_top_1.wbi_cyc_o \
      oc8051_tb.oc8051_top_1.wbi_dat_i[31:0]'h \
      oc8051_tb.oc8051_top_1.wbi_err_i \
      oc8051_tb.oc8051_top_1.wbi_stb_o \

add group \
    rom \
      oc8051_tb.oc8051_top_1.oc8051_rom1.addr[15:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_rom1.data1[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_rom1.data2[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_rom1.data3[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_rom1.ea_int \

add group \
    decoder \
      oc8051_tb.oc8051_top_1.oc8051_decoder1.op_cur[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_decoder1.state[1:0]'h \

add group \
    "sfr's" \
      oc8051_tb.oc8051_top_1.wait_data \
      oc8051_tb.oc8051_top_1.wr_sfr[1:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.sp[7:0]'h \
      oc8051_tb.oc8051_top_1.acc[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.psw[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.b_reg[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.p0_out[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.p1_out[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.p2_out[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.p3_out[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.dptr_hi[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.dptr_lo[7:0]'h \

add group \
    pc \
      oc8051_tb.oc8051_top_1.pc_wr \
      oc8051_tb.oc8051_top_1.wr_sfr[1:0]'h \
      oc8051_tb.oc8051_top_1.comp_wait \

add group \
    ram \
      oc8051_tb.oc8051_top_1.ram_rd_sel[2:0]'h \
      oc8051_tb.oc8051_top_1.ram_wr_sel[2:0]'h \
      oc8051_tb.oc8051_top_1.ram_out[7:0]'h \
      oc8051_tb.oc8051_top_1.rd_addr[7:0]'h \
      oc8051_tb.oc8051_top_1.wr_o \
      oc8051_tb.oc8051_top_1.wr_addr[7:0]'h \
      oc8051_tb.oc8051_top_1.wr_dat[7:0]'h \

add group \
    comp \
      oc8051_tb.oc8051_top_1.oc8051_comp1.acc[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_comp1.b_in \
      oc8051_tb.oc8051_top_1.oc8051_comp1.cy \
      oc8051_tb.oc8051_top_1.oc8051_comp1.des[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_comp1.eq \
      oc8051_tb.oc8051_top_1.oc8051_comp1.eq_r \
      oc8051_tb.oc8051_top_1.oc8051_comp1.sel[1:0]'h \

add group \
    xram \
      oc8051_tb.oc8051_top_1.wbd_ack_i \
      oc8051_tb.oc8051_top_1.wbd_adr_o[15:0]'h \
      oc8051_tb.oc8051_top_1.wbd_cyc_o \
      oc8051_tb.oc8051_top_1.wbd_dat_i[7:0]'h \
      oc8051_tb.oc8051_top_1.wbd_dat_o[7:0]'h \
      oc8051_tb.oc8051_top_1.wbd_err_i \
      oc8051_tb.oc8051_top_1.wbd_stb_o \
      oc8051_tb.oc8051_top_1.wbd_we_o \

add group \
    alu \
      oc8051_tb.oc8051_top_1.oc8051_alu1.src1[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_alu1.src2[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_alu1.src3[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_alu1.des1[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_alu1.des2[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_alu1.op_code[3:0]'h \

add group \
    "t/c 0,1" \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc1.tmod[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc1.tr0 \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc1.th0[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc1.tl0[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc1.tf0 \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc1.tr1 \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc1.th1[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc1.tl1[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc1.tf1 \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc1.pres_ow \

add group \
    "t/c 2" \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc21.t2con[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc21.rcap2h[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc21.rcap2l[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc21.th2[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc21.tl2[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc21.tr2 \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc21.tf2 \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc21.run \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc21.t2 \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc21.ct2 \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc21.exf2 \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc21.exen2 \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_tc21.t2ex \

add group \
    uart \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_uatr1.scon[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_uatr1.pcon[7:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_uatr1.pres_ow \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_uatr1.brate2 \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_uatr1.t1_ow \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_uatr1.receive \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_uatr1.rxd \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_uatr1.sbuf_rxd_tmp[11:0]'h \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_uatr1.shift_re \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_uatr1.rx_done \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_uatr1.trans \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_uatr1.txd \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_uatr1.sc_clk_tr \
      oc8051_tb.oc8051_top_1.oc8051_sfr1.oc8051_uatr1.tx_done \

add group \
    "uart test" \
      oc8051_tb.oc8051_uart_test1.oc8051_uart_test.pres_ow \
      oc8051_tb.oc8051_uart_test1.oc8051_uart_test.brate2 \
      oc8051_tb.oc8051_uart_test1.oc8051_uart_test.t1_ow \
      oc8051_tb.oc8051_uart_test1.oc8051_uart_test.receive \
      oc8051_tb.oc8051_uart_test1.oc8051_uart_test.sbuf_rxd_tmp[11:0]'h \
      oc8051_tb.oc8051_uart_test1.oc8051_uart_test.rx_done \
      oc8051_tb.oc8051_uart_test1.oc8051_uart_test.trans \
      oc8051_tb.oc8051_uart_test1.oc8051_uart_test.tx_done \


deselect all
create event   iadr \
  oc8051_tb.oc8051_top_1.iadr_o[15:0]'h \
  "0414" \


open window designbrowser 1 geometry 284 163 972 884
open window waveform 1 geometry 10 59 1592 1094
zoom at 826129.62(0)ns 0.00861944 0.00000000
open window event 1 geometry 1056 469 546 335
