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
define waveform window listpane 7.36
define waveform window namepane 9.36
define multivalueindication
define pattern curpos dot
define pattern cursor1 dot
define pattern cursor2 dot
define pattern marker dot
define print designer "Miha Dolenc"
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
    A \

add group \
    "PCI signals" \
      SYSTEM.pci_clock \
      SYSTEM.MAS0_REQ \
      SYSTEM.MAS0_GNT \
      SYSTEM.MAS1_REQ \
      SYSTEM.MAS1_GNT \
      SYSTEM.MAS2_REQ \
      SYSTEM.MAS2_GNT \
      SYSTEM.FRAME \
      SYSTEM.IRDY \
      SYSTEM.DEVSEL \
      SYSTEM.TRDY \
      SYSTEM.STOP \
      SYSTEM.AD[31:0]'h \
      SYSTEM.CBE[3:0]'h \
      SYSTEM.PAR \
      SYSTEM.INTA \
      SYSTEM.PERR \
      SYSTEM.SERR \

add group \
    "WISHBONE slave signals" \
      SYSTEM.wb_clock \
      SYSTEM.CYC_I \
      SYSTEM.STB_I \
      SYSTEM.CAB_I \
      SYSTEM.WE_I \
      SYSTEM.ACK_O \
      SYSTEM.RTY_O \
      SYSTEM.ERR_O \
      SYSTEM.ADR_I[31:0]'h \
      SYSTEM.SDAT_I[31:0]'h \
      SYSTEM.SDAT_O[31:0]'h \
      SYSTEM.SEL_I[3:0]'h \
      SYSTEM.INT_O \

add group \
    "WISHBONE master signals" \
      SYSTEM.wb_clock \
      SYSTEM.CYC_O \
      SYSTEM.STB_O \
      SYSTEM.CAB_O \
      SYSTEM.WE_O \
      SYSTEM.ACK_I \
      SYSTEM.RTY_I \
      SYSTEM.ERR_I \
      SYSTEM.ADR_O[31:0]'h \
      SYSTEM.MDAT_I[31:0]'h \
      SYSTEM.MDAT_O[31:0]'h \
      SYSTEM.SEL_O[3:0]'h \
      SYSTEM.INT_I \

add group \
    "Clocks, resets" \
      SYSTEM.wb_clock \
      SYSTEM.pci_clock \
      SYSTEM.RST \
      SYSTEM.RST_O \
      SYSTEM.RTY_I \
      SYSTEM.test_name[799:0]'a \

add group \
    CPCI \
      SYSTEM.LED \
      SYSTEM.ENUM \
      SYSTEM.ES \

add group \
    SPOCI \
      SYSTEM.SCL \
      SYSTEM.SDA \


deselect all
open window designbrowser 1 geometry 62 124 855 550
open window waveform 1 geometry 14 61 1268 912
zoom at 214.947(0)ns 0.00237500 0.00000000
