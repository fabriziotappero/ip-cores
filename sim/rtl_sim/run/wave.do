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
define waveform window listpane 5.97
define waveform window namepane 14.99
define multivalueindication
define pattern curpos dot
define pattern cursor1 dot
define pattern cursor2 dot
define pattern marker dot
define print designer "Igor Mohor"
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
    tap_top \
      dbg_tb.i_tap_top.tck_pad_i \
      dbg_tb.i_tap_top.tms_pad_i \
      dbg_tb.i_tap_top.tdi_pad_i \
      dbg_tb.i_tap_top.tms_reset \
      dbg_tb.i_tap_top.tdo_pad_o \
      dbg_tb.i_tap_top.tdo_padoe_o \
      dbg_tb.i_tap_top.idcode_tdo \
      dbg_tb.i_tap_top.test_logic_reset \
      dbg_tb.i_tap_top.run_test_idle \
      dbg_tb.i_tap_top.select_dr_scan \
      dbg_tb.i_tap_top.capture_dr \
      dbg_tb.i_tap_top.tck_pad_i \
      dbg_tb.i_tap_top.tms_pad_i \
      dbg_tb.i_tap_top.tdi_pad_i \
      dbg_tb.i_tap_top.tms_reset \
      dbg_tb.i_tap_top.tdo_pad_o \
      dbg_tb.i_tap_top.tdo_padoe_o \
      dbg_tb.i_tap_top.idcode_tdo \
      dbg_tb.i_tap_top.test_logic_reset \
      dbg_tb.i_tap_top.run_test_idle \
      dbg_tb.i_tap_top.select_dr_scan \
      dbg_tb.i_tap_top.capture_dr \
      dbg_tb.i_tap_top.shift_dr \
      dbg_tb.i_tap_top.exit1_dr \
      dbg_tb.i_tap_top.pause_dr \
      dbg_tb.i_tap_top.exit2_dr \
      dbg_tb.i_tap_top.update_dr \
      dbg_tb.i_tap_top.select_ir_scan \
      dbg_tb.i_tap_top.capture_ir \
      dbg_tb.i_tap_top.shift_ir \
      dbg_tb.i_tap_top.exit1_ir \
      dbg_tb.i_tap_top.pause_ir \
      dbg_tb.i_tap_top.exit2_ir \
      dbg_tb.i_tap_top.update_ir \
      dbg_tb.i_tap_top.bypass_reg \
      dbg_tb.i_tap_top.bypass_select \
      dbg_tb.i_tap_top.bypassed_tdo \
      dbg_tb.i_tap_top.debug_select \
      dbg_tb.i_tap_top.extest_select \
      dbg_tb.i_tap_top.idcode_reg[31:0]'h \
      dbg_tb.i_tap_top.idcode_select \
      dbg_tb.i_tap_top.idcode_tdo \
      dbg_tb.i_tap_top.instruction_tdo \
      dbg_tb.i_tap_top.jtag_ir[3:0]'h \
      dbg_tb.i_tap_top.latched_jtag_ir[3:0]'h \
      dbg_tb.i_tap_top.mbist_select \
      dbg_tb.i_tap_top.sample_preload_select \
      dbg_tb.i_tap_top.trst_pad_i \
      dbg_tb.i_tap_top.tck_pad_i \
      dbg_tb.i_tap_top.shift_dr \
      dbg_tb.i_tap_top.exit1_dr \
      dbg_tb.i_tap_top.pause_dr \
      dbg_tb.i_tap_top.exit2_dr \
      dbg_tb.i_tap_top.update_dr \
      dbg_tb.i_tap_top.select_ir_scan \
      dbg_tb.i_tap_top.capture_ir \
      dbg_tb.i_tap_top.shift_ir \
      dbg_tb.i_tap_top.exit1_ir \
      dbg_tb.i_tap_top.pause_ir \
      dbg_tb.i_tap_top.exit2_ir \
      dbg_tb.i_tap_top.update_ir \
      dbg_tb.i_tap_top.bypass_reg \
      dbg_tb.i_tap_top.bypass_select \
      dbg_tb.i_tap_top.bypassed_tdo \
      dbg_tb.i_tap_top.debug_select \
      dbg_tb.i_tap_top.extest_select \
      dbg_tb.i_tap_top.idcode_reg[31:0]'h \
      dbg_tb.i_tap_top.idcode_select \
      dbg_tb.i_tap_top.idcode_tdo \
      dbg_tb.i_tap_top.instruction_tdo \
      dbg_tb.i_tap_top.jtag_ir[3:0]'h \
      dbg_tb.i_tap_top.latched_jtag_ir[3:0]'h \
      dbg_tb.i_tap_top.mbist_select \
      dbg_tb.i_tap_top.sample_preload_select \
      dbg_tb.i_tap_top.trst_pad_i \
      dbg_tb.i_tap_top.tck_pad_i \

add group \
    dbg_top \
      dbg_tb.test_text[199:0]'a \
      dbg_tb.i_dbg_top.crc_cnt_end \
      dbg_tb.i_dbg_top.crc_cnt_end_q \
      dbg_tb.i_dbg_top.data_cnt[2:0]'h \
      dbg_tb.i_dbg_top.data_cnt_end \
      dbg_tb.i_dbg_top.crc_cnt[5:0]'h \
      dbg_tb.i_dbg_top.crc_cnt_end \
      dbg_tb.i_dbg_top.crc_match \
      dbg_tb.i_dbg_top.debug_select_i \
      dbg_tb.i_dbg_top.module_select \
      dbg_tb.i_dbg_top.cpu_debug_module \
      dbg_tb.i_dbg_top.shift_dr_i \
      dbg_tb.i_dbg_top.status_cnt[2:0]'h \
      dbg_tb.i_dbg_top.status_cnt_end \
      dbg_tb.i_dbg_top.tck_i \
      dbg_tb.i_dbg_top.tdi_i \
      dbg_tb.i_dbg_top.tdo_o \
      dbg_tb.i_dbg_top.tdo_module_select \
      dbg_tb.i_dbg_top.update_dr_i \
      dbg_tb.i_dbg_top.crc_en \
      dbg_tb.i_dbg_top.crc_en_dbg \
      dbg_tb.i_dbg_top.crc_en_wb \
      dbg_tb.status[3:0]'h \
      dbg_tb.crc_match_in \
      dbg_tb.test_text[199:0]'a \
      dbg_tb.i_dbg_top.crc_cnt_end \
      dbg_tb.i_dbg_top.crc_cnt_end_q \
      dbg_tb.i_dbg_top.data_cnt[2:0]'h \
      dbg_tb.i_dbg_top.data_cnt_end \
      dbg_tb.i_dbg_top.crc_cnt[5:0]'h \
      dbg_tb.i_dbg_top.crc_cnt_end \
      dbg_tb.i_dbg_top.crc_match \
      dbg_tb.i_dbg_top.debug_select_i \
      dbg_tb.i_dbg_top.module_select \
      dbg_tb.i_dbg_top.cpu_debug_module \
      dbg_tb.i_dbg_top.shift_dr_i \
      dbg_tb.i_dbg_top.status_cnt[2:0]'h \
      dbg_tb.i_dbg_top.status_cnt_end \
      dbg_tb.i_dbg_top.tck_i \
      dbg_tb.i_dbg_top.tdi_i \
      dbg_tb.i_dbg_top.tdo_o \
      dbg_tb.i_dbg_top.tdo_module_select \
      dbg_tb.i_dbg_top.update_dr_i \
      dbg_tb.i_dbg_top.crc_en \
      dbg_tb.i_dbg_top.crc_en_dbg \
      dbg_tb.i_dbg_top.crc_en_wb \
      dbg_tb.status[3:0]'h \
      dbg_tb.crc_match_in \

add group \
    crc_out \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.clk \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.crc[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.crc_match \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.crc_out \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.data \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.enable \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.shift \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.new_crc[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.rst \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.sync_rst \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.clk \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.crc[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.crc_match \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.crc_out \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.data \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.enable \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.shift \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.new_crc[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.rst \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_out.sync_rst \

add group \
    crc_in \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.clk \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.crc_match \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.data \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.enable \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.new_crc[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.rst \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.shift \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.sync_rst \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.crc[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.clk \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.crc_match \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.data \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.enable \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.new_crc[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.rst \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.shift \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.sync_rst \
      dbg_tb.i_dbg_top.i_dbg_crc32_d1_in.crc[31:0]'h \

add group \
    cpu_module \
      dbg_tb.test_text[199:0]'a \
      dbg_tb.i_dbg_top.i_dbg_cpu.cpu_ce_i \
      dbg_tb.i_dbg_top.i_dbg_cpu.curr_cmd[3:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.curr_cmd_go \
      dbg_tb.i_dbg_top.i_dbg_cpu.cmd_cnt[2:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.addr_len_cnt[5:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.data_cnt_en \
      dbg_tb.i_dbg_top.i_dbg_cpu.data_cnt[19:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.crc_cnt[5:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.status_cnt[2:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.adr[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.acc_type[3:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.len[15:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.start_rd_tck \
      dbg_tb.i_dbg_top.i_dbg_cpu.start_wr_tck \
      dbg_tb.i_dbg_top.i_dbg_cpu.long_q \
      dbg_tb.i_dbg_top.i_dbg_cpu.acc_type[3:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.long \
      dbg_tb.i_dbg_top.i_dbg_cpu.data_cnt[19:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.cpu_stb_o \
      dbg_tb.i_dbg_top.i_dbg_cpu.i_dbg_cpu_registers.cpu_rst_o \
      dbg_tb.i_dbg_top.i_dbg_cpu.cpu_stall_o \
      dbg_tb.i_dbg_top.i_dbg_cpu.cpu_reg_stall \
      dbg_tb.i_dbg_top.i_dbg_cpu.fifo_full \
      dbg_tb.i_dbg_top.i_dbg_cpu.latch_data \
      dbg_tb.i_dbg_top.i_dbg_cpu.cpu_overrun \
      dbg_tb.i_dbg_top.i_dbg_cpu.cpu_overrun_tck \
      dbg_tb.i_dbg_top.i_dbg_cpu.underrun_tck \
      dbg_tb.i_dbg_top.i_dbg_cpu.cpu_reg_stall \
      dbg_tb.test_text[199:0]'a \
      dbg_tb.i_dbg_top.i_dbg_cpu.cpu_ce_i \
      dbg_tb.i_dbg_top.i_dbg_cpu.curr_cmd[3:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.curr_cmd_go \
      dbg_tb.i_dbg_top.i_dbg_cpu.cmd_cnt[2:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.addr_len_cnt[5:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.data_cnt[19:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.crc_cnt[5:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.status_cnt[2:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.adr[31:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.acc_type[3:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.len[15:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.start_wr_tck \
      dbg_tb.i_dbg_top.i_dbg_cpu.long_q \
      dbg_tb.i_dbg_top.i_dbg_cpu.acc_type[3:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.long \
      dbg_tb.i_dbg_top.i_dbg_cpu.data_cnt[19:0]'h \
      dbg_tb.i_dbg_top.i_dbg_cpu.cpu_stall_o \
      dbg_tb.i_dbg_top.i_dbg_cpu.cpu_stb_o \
      dbg_tb.i_dbg_top.i_dbg_cpu.i_dbg_cpu_registers.cpu_rst_o \
      dbg_tb.i_dbg_top.i_dbg_cpu.i_dbg_cpu_registers.cpu_stall_o \
      dbg_tb.i_dbg_top.i_dbg_cpu.cpu_overrun \
      dbg_tb.i_dbg_top.i_dbg_cpu.underrun_tck \

add group \
    cpu_behavioural \
      dbg_tb.i_cpu_behavioral.cpu_ack_o \
      dbg_tb.i_cpu_behavioral.cpu_addr_i[31:0]'h \
      dbg_tb.i_cpu_behavioral.cpu_bp_o \
      dbg_tb.i_cpu_behavioral.cpu_clk_o \
      dbg_tb.i_cpu_behavioral.cpu_data_i[31:0]'h \
      dbg_tb.i_cpu_behavioral.cpu_data_o[31:0]'h \
      dbg_tb.i_cpu_behavioral.cpu_rst_i \
      dbg_tb.i_cpu_behavioral.cpu_rst_o \
      dbg_tb.i_cpu_behavioral.cpu_stall_i \
      dbg_tb.i_cpu_behavioral.cpu_stb_i \
      dbg_tb.i_cpu_behavioral.cpu_we_i \


deselect all
open window waveform 1 geometry 10 60 1592 1139
zoom at 914057.1(0)ns 0.00038020 0.00000000
