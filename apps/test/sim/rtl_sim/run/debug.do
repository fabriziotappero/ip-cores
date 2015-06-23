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
define waveform window namepane 23.00
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
      test_bench.wbs_ack_o \
      test_bench.wbs_adr_i[31:0]'h \
      test_bench.wbs_cab_i \
      test_bench.wbs_cyc_i \
      test_bench.wbs_dat_i[31:0]'h \
      test_bench.wbs_dat_o[31:0]'h \
      test_bench.wbs_err_o \
      test_bench.wbs_rty_o \
      test_bench.wbs_sel_i[3:0]'h \
      test_bench.wbs_stb_i \
      test_bench.wbs_we_i \
      test_bench.clk \

add group \
    wbm \
      test_bench.wbm_ack_i \
      test_bench.wbm_adr_o[31:0]'h \
      test_bench.wbm_cab_o \
      test_bench.wbm_cyc_o \
      test_bench.wbm_cyc_o_previous \
      test_bench.wbm_dat_i[31:0]'h \
      test_bench.wbm_dat_o[31:0]'h \
      test_bench.wbm_err_i \
      test_bench.wbm_mon_log_file_desc's \
      test_bench.wbm_rty_i \
      test_bench.wbm_sel_o[3:0]'h \
      test_bench.wbm_stb_o \
      test_bench.wbm_we_o \

add group \
    pci_dbg \
      test_bench.pci_clk \
      test_bench.pci_ad_reg[31:0]'h \
      test_bench.pci_irdy_en_reg \
      test_bench.pci_irdy_reg \
      test_bench.pci_trdy_reg \
      test_bench.i_test.master_num_of_pci_transfers[31:0]'h \
      test_bench.i_test.master_num_of_wb_transfers[31:0]'h \
      test_bench.i_test.clr_master_num_of_pci_transfers \
      test_bench.i_test.master_dat_err_detected \
      test_bench.i_test.pci_clk_master_test_expect_dat[31:0]'h \
      test_bench.i_test.pci_clk_master_test_start \
      test_bench.i_test.master_test_start_dat[31:0]'h \
      test_bench.pci_ad_reg[31:0]'h \
      test_bench.configure_master_registers.start_dat[31:0]'h \
      test_bench.test_master_data_errors.current_error_offset's \
      test_bench.test_master_data_errors.num_of_transfers's \
      test_bench.test_master_data_errors.tmp[31:0]'h \


deselect all
open window waveform 1 geometry 10 62 1592 1095
zoom at 4967.842(0)ns 0.00214844 0.00000000
