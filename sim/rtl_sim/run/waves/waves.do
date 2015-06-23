// Signalscan Version 6.8b1


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
define waveform window listpane 11
define waveform window namepane 21
define multivalueindication
define pattern curpos dot
define pattern cursor1 dot
define pattern cursor2 dot
define pattern marker dot
define print designer "Richard Herveille"
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
define user guide directory "/usr/local/designacc/signalscan-6.8b1/doc/html"
define waveform window grid off
define waveform window waveheight 14
define waveform window wavespace 6
define web browser command netscape
define zoom outfull on initial add off
add group \
    Wishbone \
      tst_bench_top.i2c_top.byte_controller.bit_controller.clk \
      tst_bench_top.i2c_top.wb_cyc_i \
      tst_bench_top.i2c_top.wb_stb_i \
      tst_bench_top.i2c_top.wb_we_i \
      tst_bench_top.i2c_top.wb_adr_i[2:0]'h \
      tst_bench_top.i2c_top.wb_ack_o \
      tst_bench_top.i2c_top.prer[15:0]'h \
      tst_bench_top.i2c_top.ctr[7:0]'h \
      tst_bench_top.i2c_top.cr[7:0]'h \
      tst_bench_top.i2c_top.rd \
      tst_bench_top.i2c_top.wr \
      tst_bench_top.i2c_top.sta \
      tst_bench_top.i2c_top.sto \
      tst_bench_top.i2c_top.sr[7:0]'h \
      tst_bench_top.i2c_top.tip \
      tst_bench_top.i2c_top.txr[7:0]'h \
      tst_bench_top.i2c_top.rxr[7:0]'h \

add group \
    "byte controller" \
      tst_bench_top.i2c_top.byte_controller.start \
      tst_bench_top.i2c_top.byte_controller.stop \
      tst_bench_top.i2c_top.byte_controller.read \
      tst_bench_top.i2c_top.byte_controller.write \
      tst_bench_top.i2c_top.byte_controller.c_state[4:0]'b \
      tst_bench_top.i2c_top.byte_controller.cmd_ack \

add group \
    I2C \
      tst_bench_top.scl \
      tst_bench_top.sda \
      tst_bench_top.i2c_top.byte_controller.bit_controller.clk_en \
      tst_bench_top.i2c_top.byte_controller.bit_controller.cmd[3:0]'h \
      tst_bench_top.i2c_top.byte_controller.bit_controller.c_state[16:0]'b \
      tst_bench_top.i2c_top.byte_controller.bit_controller.sto_condition \
      tst_bench_top.i2c_top.byte_controller.bit_controller.sta_condition \
      tst_bench_top.i2c_top.byte_controller.bit_controller.al \
      tst_bench_top.i2c_top.byte_controller.bit_controller.cmd_stop \


deselect all
open window designbrowser 1 geometry 56 117 855 550
