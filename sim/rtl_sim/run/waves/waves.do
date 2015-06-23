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
  1 replacesimulationfiledata \
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
define exit noprompt
define event search direction forward
define variable fullhierarchy
define variable nofilenames
define variable nofullpathfilenames
include bookmark with filenames
include scope history without filenames
define waveform window listpane 7.95
define waveform window namepane 33.97
define multivalueindication
define pattern curpos dot
define pattern cursor1 dot
define pattern cursor2 dot
define pattern marker dot
define print designer "Rudolf Usselmann"
define print border
define print color blackonwhite
define print command "/usr/bin/lpr -P%P"
define print printer  lp
define print size A4
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
    A \
      test.rst \
      test.clk \
      test.u0.ld \
      test.u0.ld_r \
      test.u0.key[127:0]'h \
      test.u0.text_in[127:0]'h \
      test.text_out[127:0]'h \
      test.u0.done \
      test.done2 \
      test.text_out2[127:0]'h \
      test.u0.w0[31:0]'h \
      test.u0.w1[31:0]'h \
      test.u0.w2[31:0]'h \
      test.u0.w3[31:0]'h \
      test.u0.sa00[7:0]'h \
      test.u0.sa01[7:0]'h \
      test.u0.sa02[7:0]'h \
      test.u0.sa03[7:0]'h \
      test.u0.sa10[7:0]'h \
      test.u0.sa11[7:0]'h \
      test.u0.sa12[7:0]'h \
      test.u0.sa13[7:0]'h \
      test.u0.sa20[7:0]'h \
      test.u0.sa21[7:0]'h \
      test.u0.sa22[7:0]'h \
      test.u0.sa23[7:0]'h \
      test.u0.sa30[7:0]'h \
      test.u0.sa31[7:0]'h \
      test.u0.sa32[7:0]'h \
      test.u0.sa33[7:0]'h \
      test.clk \
      test.u1.ld \
      test.u1.done \
      test.u1.w3[31:0]'h \
      test.u1.kdone \
      test.u1.kld \
      test.u1.text_in[127:0]'h \
      test.u1.text_in_r[127:0]'h \
      test.u1.text_out[127:0]'h \
      test.u1.kb_ld \
      test.u1.kcnt[3:0]'h \
      test.u1.dcnt[3:0]'h \
      test.u1.w0[31:0]'h \
      test.u1.w1[31:0]'h \
      test.u1.w2[31:0]'h \
      test.u1.w3[31:0]'h \
      test.u1.wk0[31:0]'h \
      test.u1.wk1[31:0]'h \
      test.u1.wk2[31:0]'h \
      test.u1.wk3[31:0]'h \


deselect all
create marker Marker1 0ns
open window designbrowser 1 geometry 450 269 1020 752
open window waveform 1 geometry 58 104 1540 838
zoom at 0(0)ns 0.00803721 0.00000000
