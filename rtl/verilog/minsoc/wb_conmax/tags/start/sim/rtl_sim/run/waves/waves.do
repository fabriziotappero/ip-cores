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
  12 savedofile \
  13 replacesimulationfiledata \
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
define exit noprompt
define event search direction forward
define variable fullhierarchy
define variable nofilenames
define variable nofullpathfilenames
include bookmark with filenames
include scope history without filenames
define waveform window listpane 10.93
define waveform window namepane 18.98
define multivalueindication
define pattern curpos dot
define pattern cursor1 dot
define pattern cursor2 dot
define pattern marker dot
define print designer "Rudolf Usselmann"
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
define user guide directory "/usr/local/designacc/signalscan-6.5s2/doc/html"
define waveform window grid off
define waveform window waveheight 14
define waveform window wavespace 6
define web browser command netscape
define zoom outfull on initial add off
add group \
    "System" \
      test.clk \
      test.rst \

add group \
    "Master 0" \
      test.m0_cyc_i \
      test.m0_stb_i \
      test.m0_sel_i[3:0]'h \
      test.m0_addr_i[31:0]'h \
      test.m0_data_i[31:0]'h \
      test.m0_data_o[31:0]'h \
      test.m0_we_i \
      test.m0_ack_o \
      test.m0_err_o \
      test.m0_rty_o \

add group \
    "Master 1" \
      test.m1_cyc_i \
      test.m1_stb_i \
      test.m1_sel_i[3:0]'h \
      test.m1_addr_i[31:0]'h \
      test.m1_data_i[31:0]'h \
      test.m1_data_o[31:0]'h \
      test.m1_we_i \
      test.m1_ack_o \
      test.m1_err_o \
      test.m1_rty_o \

add group \
    "Master 2" \
      test.m2_cyc_i \
      test.m2_stb_i \
      test.m2_sel_i[3:0]'h \
      test.m2_addr_i[31:0]'h \
      test.m2_data_i[31:0]'h \
      test.m2_data_o[31:0]'h \
      test.m2_we_i \
      test.m2_ack_o \
      test.m2_err_o \
      test.m2_rty_o \

add group \
    "Master 3" \
      test.m3_cyc_i \
      test.m3_stb_i \
      test.m3_sel_i[3:0]'h \
      test.m3_addr_i[31:0]'h \
      test.m3_data_i[31:0]'h \
      test.m3_data_o[31:0]'h \
      test.m3_we_i \
      test.m3_ack_o \
      test.m3_err_o \
      test.m3_rty_o \

add group \
    "Master 4" \
      test.m4_cyc_i \
      test.m4_stb_i \
      test.m4_sel_i[3:0]'h \
      test.m4_addr_i[31:0]'h \
      test.m4_data_i[31:0]'h \
      test.m4_data_o[31:0]'h \
      test.m4_we_i \
      test.m4_ack_o \
      test.m4_err_o \
      test.m4_rty_o \

add group \
    "Master 5" \
      test.m5_cyc_i \
      test.m5_stb_i \
      test.m5_sel_i[3:0]'h \
      test.m5_addr_i[31:0]'h \
      test.m5_data_i[31:0]'h \
      test.m5_data_o[31:0]'h \
      test.m5_we_i \
      test.m5_ack_o \
      test.m5_err_o \
      test.m5_rty_o \

add group \
    "Master 6" \
      test.m6_cyc_i \
      test.m6_stb_i \
      test.m6_sel_i[3:0]'h \
      test.m6_addr_i[31:0]'h \
      test.m6_data_i[31:0]'h \
      test.m6_data_o[31:0]'h \
      test.m6_we_i \
      test.m6_ack_o \
      test.m6_err_o \
      test.m6_rty_o \

add group \
    "Master 7" \
      test.m7_cyc_i \
      test.m7_stb_i \
      test.m7_sel_i[3:0]'h \
      test.m7_addr_i[31:0]'h \
      test.m7_data_i[31:0]'h \
      test.m7_data_o[31:0]'h \
      test.m7_we_i \
      test.m7_ack_o \
      test.m7_err_o \
      test.m7_rty_o \

add group \
    "Slave 0" \
      test.s0_cyc_o \
      test.s0_stb_o \
      test.s0_sel_o[3:0]'h \
      test.s0_addr_o[31:0]'h \
      test.s0_data_i[31:0]'h \
      test.s0_data_o[31:0]'h \
      test.s0_we_o \
      test.s0_ack_i \
      test.s0_err_i \
      test.s0_rty_i \

add group \
    "Slave 1" \
      test.s1_cyc_o \
      test.s1_stb_o \
      test.s1_sel_o[3:0]'h \
      test.s1_addr_o[31:0]'h \
      test.s1_data_i[31:0]'h \
      test.s1_data_o[31:0]'h \
      test.s1_we_o \
      test.s1_ack_i \
      test.s1_err_i \
      test.s1_rty_i \

add group \
    "Slave 2" \
      test.s2_cyc_o \
      test.s2_stb_o \
      test.s2_sel_o[3:0]'h \
      test.s2_addr_o[31:0]'h \
      test.s2_data_i[31:0]'h \
      test.s2_data_o[31:0]'h \
      test.s2_we_o \
      test.s2_ack_i \
      test.s2_err_i \
      test.s2_rty_i \

add group \
    "Slave 3" \
      test.s3_cyc_o \
      test.s3_stb_o \
      test.s3_sel_o[3:0]'h \
      test.s3_addr_o[31:0]'h \
      test.s3_data_i[31:0]'h \
      test.s3_data_o[31:0]'h \
      test.s3_we_o \
      test.s3_ack_i \
      test.s3_err_i \
      test.s3_rty_i \

add group \
    "Slave 4" \
      test.s4_cyc_o \
      test.s4_stb_o \
      test.s4_sel_o[3:0]'h \
      test.s4_addr_o[31:0]'h \
      test.s4_data_i[31:0]'h \
      test.s4_data_o[31:0]'h \
      test.s4_we_o \
      test.s4_ack_i \
      test.s4_err_i \
      test.s4_rty_i \

add group \
    "Slave 5" \
      test.s5_cyc_o \
      test.s5_stb_o \
      test.s5_sel_o[3:0]'h \
      test.s5_addr_o[31:0]'h \
      test.s5_data_i[31:0]'h \
      test.s5_data_o[31:0]'h \
      test.s5_we_o \
      test.s5_ack_i \
      test.s5_err_i \
      test.s5_rty_i \

add group \
    "Slave 6" \
      test.s6_cyc_o \
      test.s6_stb_o \
      test.s6_sel_o[3:0]'h \
      test.s6_addr_o[31:0]'h \
      test.s6_data_i[31:0]'h \
      test.s6_data_o[31:0]'h \
      test.s6_we_o \
      test.s6_ack_i \
      test.s6_err_i \
      test.s6_rty_i \

add group \
    "Slave 7" \
      test.s7_cyc_o \
      test.s7_stb_o \
      test.s7_sel_o[3:0]'h \
      test.s7_addr_o[31:0]'h \
      test.s7_data_i[31:0]'h \
      test.s7_data_o[31:0]'h \
      test.s7_we_o \
      test.s7_ack_i \
      test.s7_err_i \
      test.s7_rty_i \

add group \
    "Slave 8" \
      test.s8_cyc_o \
      test.s8_stb_o \
      test.s8_sel_o[3:0]'h \
      test.s8_addr_o[31:0]'h \
      test.s8_data_i[31:0]'h \
      test.s8_data_o[31:0]'h \
      test.s8_we_o \
      test.s8_ack_i \
      test.s8_err_i \
      test.s8_rty_i \

add group \
    "Slave 9" \
      test.s9_cyc_o \
      test.s9_stb_o \
      test.s9_sel_o[3:0]'h \
      test.s9_addr_o[31:0]'h \
      test.s9_data_i[31:0]'h \
      test.s9_data_o[31:0]'h \
      test.s9_we_o \
      test.s9_ack_i \
      test.s9_err_i \
      test.s9_rty_i \

add group \
    "Slave 10" \
      test.s10_cyc_o \
      test.s10_stb_o \
      test.s10_sel_o[3:0]'h \
      test.s10_addr_o[31:0]'h \
      test.s10_data_i[31:0]'h \
      test.s10_data_o[31:0]'h \
      test.s10_we_o \
      test.s10_ack_i \
      test.s10_err_i \
      test.s10_rty_i \

add group \
    "Slave 11" \
      test.s11_cyc_o \
      test.s11_stb_o \
      test.s11_sel_o[3:0]'h \
      test.s11_addr_o[31:0]'h \
      test.s11_data_i[31:0]'h \
      test.s11_data_o[31:0]'h \
      test.s11_we_o \
      test.s11_ack_i \
      test.s11_err_i \
      test.s11_rty_i \

add group \
    "Slave 12" \
      test.s12_cyc_o \
      test.s12_stb_o \
      test.s12_sel_o[3:0]'h \
      test.s12_addr_o[31:0]'h \
      test.s12_data_i[31:0]'h \
      test.s12_data_o[31:0]'h \
      test.s12_we_o \
      test.s12_ack_i \
      test.s12_err_i \
      test.s12_rty_i \

add group \
    "Slave 13" \
      test.s13_cyc_o \
      test.s13_stb_o \
      test.s13_sel_o[3:0]'h \
      test.s13_addr_o[31:0]'h \
      test.s13_data_i[31:0]'h \
      test.s13_data_o[31:0]'h \
      test.s13_we_o \
      test.s13_ack_i \
      test.s13_err_i \
      test.s13_rty_i \

add group \
    "Slave 14" \
      test.s14_cyc_o \
      test.s14_stb_o \
      test.s14_sel_o[3:0]'h \
      test.s14_addr_o[31:0]'h \
      test.s14_data_i[31:0]'h \
      test.s14_data_o[31:0]'h \
      test.s14_we_o \
      test.s14_ack_i \
      test.s14_err_i \
      test.s14_rty_i \

add group \
    "Slave 15" \
      test.s15_cyc_o \
      test.s15_stb_o \
      test.s15_sel_o[3:0]'h \
      test.s15_addr_o[31:0]'h \
      test.s15_data_i[31:0]'h \
      test.s15_data_o[31:0]'h \
      test.s15_we_o \
      test.s15_ack_i \
      test.s15_err_i \
      test.s15_rty_i \


deselect all
open window designbrowser 1 geometry 56 118 1075 799
open window waveform 1 geometry 10 59 1272 919
zoom at 274.11(0)ns 0.07173877 0.00000000
