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
define waveform window listpane 7.94
define waveform window namepane 13.47
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
    bench_top \
      can_testbench.ale_i \
      can_testbench.bus_off_on \
      can_testbench.clk \
      can_testbench.clkout \
      can_testbench.cs_can \
      can_testbench.delayed_tx \
      can_testbench.extended_mode \
      can_testbench.irq \
      can_testbench.port_0[7:0]'h \
      can_testbench.port_0_en \
      can_testbench.port_0_i[7:0]'h \
      can_testbench.port_0_o[7:0]'h \
      can_testbench.port_free \
      can_testbench.rd_i \
      can_testbench.rst_i \
      can_testbench.rx \
      can_testbench.rx_and_tx \
      can_testbench.start_tb's \
      can_testbench.tmp_data[7:0]'h \
      can_testbench.tx \
      can_testbench.tx_bypassed \
      can_testbench.tx_i \
      can_testbench.wr_i \
      can_testbench.ale_i \
      can_testbench.bus_off_on \
      can_testbench.clk \
      can_testbench.clkout \
      can_testbench.cs_can \
      can_testbench.delayed_tx \
      can_testbench.extended_mode \
      can_testbench.irq \
      can_testbench.port_0[7:0]'h \
      can_testbench.port_0_en \
      can_testbench.port_0_i[7:0]'h \
      can_testbench.port_0_o[7:0]'h \
      can_testbench.port_free \
      can_testbench.rd_i \
      can_testbench.rst_i \
      can_testbench.rx \
      can_testbench.rx_and_tx \
      can_testbench.start_tb's \
      can_testbench.tmp_data[7:0]'h \
      can_testbench.tx \
      can_testbench.tx_bypassed \
      can_testbench.tx_i \
      can_testbench.wr_i \

add group \
    can_registers \
      can_testbench.irq \
      can_testbench.i_can_top.i_can_registers.irq \
      can_testbench.i_can_top.i_can_registers.irq_en_ext[7:0]'h \
      can_testbench.i_can_top.i_can_registers.irq_reg[7:0]'h \

add group \
    can_bsp \
      can_testbench.i_can_top.tx_o \
      can_testbench.i_can_top.rx_i \
      can_testbench.i_can_top.i_can_bsp.rx_idle \
      can_testbench.i_can_top.i_can_bsp.rx_id1 \
      can_testbench.i_can_top.i_can_bsp.rx_id2 \
      can_testbench.i_can_top.i_can_bsp.rx_ide \
      can_testbench.i_can_top.i_can_bsp.rx_r0 \
      can_testbench.i_can_top.i_can_bsp.rx_r1 \
      can_testbench.i_can_top.i_can_bsp.rx_rtr1 \
      can_testbench.i_can_top.i_can_bsp.rx_rtr2 \
      can_testbench.i_can_top.i_can_bsp.rx_dlc \
      can_testbench.i_can_top.i_can_bsp.rx_data \
      can_testbench.i_can_top.i_can_bsp.rx_crc \
      can_testbench.i_can_top.i_can_bsp.rx_crc_lim \
      can_testbench.i_can_top.i_can_bsp.rx_ack \
      can_testbench.i_can_top.i_can_bsp.rx_ack_lim \
      can_testbench.i_can_top.i_can_bsp.rx_eof \
      can_testbench.i_can_top.i_can_bsp.go_error_frame \
      can_testbench.i_can_top.i_can_bsp.ack_err \
      can_testbench.i_can_top.i_can_bsp.bit_err \
      can_testbench.i_can_top.i_can_bsp.crc_err \
      can_testbench.i_can_top.i_can_bsp.form_err \
      can_testbench.i_can_top.i_can_bsp.stuff_err \
      can_testbench.i_can_top.tx_o \
      can_testbench.i_can_top.rx_i \
      can_testbench.i_can_top.i_can_bsp.rx_idle \
      can_testbench.i_can_top.i_can_bsp.rx_id1 \
      can_testbench.i_can_top.i_can_bsp.rx_id2 \
      can_testbench.i_can_top.i_can_bsp.rx_ide \
      can_testbench.i_can_top.i_can_bsp.rx_r0 \
      can_testbench.i_can_top.i_can_bsp.rx_r1 \
      can_testbench.i_can_top.i_can_bsp.rx_rtr1 \
      can_testbench.i_can_top.i_can_bsp.rx_rtr2 \
      can_testbench.i_can_top.i_can_bsp.rx_dlc \
      can_testbench.i_can_top.i_can_bsp.rx_data \
      can_testbench.i_can_top.i_can_bsp.rx_crc \
      can_testbench.i_can_top.i_can_bsp.rx_crc_lim \
      can_testbench.i_can_top.i_can_bsp.rx_ack \
      can_testbench.i_can_top.i_can_bsp.rx_ack_lim \
      can_testbench.i_can_top.i_can_bsp.rx_eof \
      can_testbench.i_can_top.i_can_bsp.rx_inter \
      can_testbench.i_can_top.i_can_bsp.sample_point \
      can_testbench.i_can_top.i_can_bsp.tx_point \
      can_testbench.i_can_top.i_can_bsp.go_error_frame \
      can_testbench.i_can_top.i_can_bsp.ack_err \
      can_testbench.i_can_top.i_can_bsp.bit_err \
      can_testbench.i_can_top.i_can_bsp.crc_err \
      can_testbench.i_can_top.i_can_bsp.form_err \
      can_testbench.i_can_top.i_can_bsp.stuff_err \
      can_testbench.i_can_top.i_can_bsp.rx_err_cnt[8:0]'h \
      can_testbench.i_can_top.i_can_bsp.tx_err_cnt[8:0]'h \
      can_testbench.i_can_top.i_can_bsp.crc_in[14:0]'h \
      can_testbench.i_can_top.i_can_bsp.calculated_crc[14:0]'h \
      can_testbench.i_can_top.i_can_bsp.bit_de_stuff \
      can_testbench.i_can_top.i_can_bsp.arbitration_blocked \
      can_testbench.i_can_top.i_can_bsp.arbitration_field \
      can_testbench.i_can_top.i_can_bsp.arbitration_lost \
      can_testbench.i_can_top.i_can_bsp.arbitration_lost_capture[4:0]'h \
      can_testbench.i_can_top.i_can_bsp.crc_in[14:0]'h \
      can_testbench.i_can_top.i_can_bsp.calculated_crc[14:0]'h \
      can_testbench.i_can_top.i_can_bsp.bit_de_stuff \
      can_testbench.i_can_top.i_can_bsp.arbitration_blocked \
      can_testbench.i_can_top.i_can_bsp.arbitration_field \
      can_testbench.i_can_top.i_can_bsp.arbitration_lost \
      can_testbench.i_can_top.i_can_bsp.arbitration_cnt[4:0]'h \
      can_testbench.i_can_top.i_can_bsp.arbitration_lost_capture[4:0]'h \

add group \
    can_fifo \
      can_testbench.i_can_top.i_can_bsp.i_can_fifo.reset_mode \
      can_testbench.i_can_top.i_can_bsp.i_can_fifo.data_in[7:0]'h \
      can_testbench.i_can_top.i_can_bsp.i_can_fifo.wr \
      can_testbench.i_can_top.i_can_bsp.i_can_fifo.wr_info_pointer[5:0]'h \
      can_testbench.i_can_top.i_can_bsp.i_can_fifo.wr_pointer[5:0]'h \
      can_testbench.i_can_top.i_can_bsp.i_can_fifo.wr_q \
      can_testbench.i_can_top.i_can_bsp.i_can_fifo.write_length_info \
      can_testbench.i_can_top.i_can_bsp.i_can_fifo.fifo_cnt[6:0]'h \
      can_testbench.i_can_top.i_can_bsp.i_can_fifo.fifo_empty \
      can_testbench.i_can_top.i_can_bsp.i_can_fifo.fifo_full \
      can_testbench.i_can_top.i_can_bsp.i_can_fifo.info_cnt[6:0]'h \
      can_testbench.i_can_top.i_can_bsp.i_can_fifo.info_empty \
      can_testbench.i_can_top.i_can_bsp.i_can_fifo.info_full \
      can_testbench.i_can_top.i_can_bsp.receive_status \
      can_testbench.i_can_top.i_can_bsp.transmit_status \

add group \
    state \
      can_testbench.i_can_top.i_can_bsp.sample_point \
      can_testbench.i_can_top.i_can_bsp.tx_point \
      can_testbench.i_can_top.tx_o \
      can_testbench.i_can_top.rx_i \
      can_testbench.i_can_top.i_can_bsp.rx_idle \
      can_testbench.i_can_top.i_can_bsp.rx_id1 \
      can_testbench.i_can_top.i_can_bsp.rx_rtr1 \
      can_testbench.i_can_top.i_can_bsp.rx_ide \
      can_testbench.i_can_top.i_can_bsp.rx_id2 \
      can_testbench.i_can_top.i_can_bsp.rx_rtr2 \
      can_testbench.i_can_top.i_can_bsp.rx_r1 \
      can_testbench.i_can_top.i_can_bsp.rx_r0 \
      can_testbench.i_can_top.i_can_bsp.rx_dlc \
      can_testbench.i_can_top.i_can_bsp.rx_data \
      can_testbench.i_can_top.i_can_bsp.rx_crc \
      can_testbench.i_can_top.i_can_bsp.rx_crc_lim \
      can_testbench.i_can_top.i_can_bsp.rx_ack \
      can_testbench.i_can_top.i_can_bsp.rx_ack_lim \
      can_testbench.i_can_top.i_can_bsp.rx_eof \
      can_testbench.i_can_top.i_can_bsp.rx_inter \
      can_testbench.i_can_top.i_can_bsp.go_error_frame \
      can_testbench.i_can_top.i_can_bsp.error_frame \
      can_testbench.i_can_top.i_can_bsp.ack_err \
      can_testbench.i_can_top.i_can_bsp.bit_err \
      can_testbench.i_can_top.i_can_bsp.crc_err \
      can_testbench.i_can_top.i_can_bsp.err \
      can_testbench.i_can_top.i_can_bsp.form_err \
      can_testbench.i_can_top.i_can_bsp.stuff_err \
      can_testbench.i_can_top.i_can_bsp.tx \
      can_testbench.i_can_top.i_can_bsp.sampled_bit \
      can_testbench.i_can_top.i_can_bsp.error_cnt1[2:0]'h \
      can_testbench.i_can_top.i_can_bsp.error_cnt2[2:0]'h \
      can_testbench.i_can_top.i_can_bsp.error_frame_ended \

add group \
    can_2 \
      can_testbench.i_can_top2.i_can_bsp.sample_point \
      can_testbench.i_can_top2.i_can_bsp.sampled_bit \
      can_testbench.i_can_top2.i_can_bsp.error_cnt1[2:0]'h \
      can_testbench.i_can_top2.i_can_bsp.error_cnt2[2:0]'h \
      can_testbench.i_can_top2.i_can_bsp.error_frame_ended \
      can_testbench.i_can_top2.cs_can_i \
      can_testbench.i_can_top2.ale_i \
      can_testbench.i_can_top2.rd_i \
      can_testbench.i_can_top2.wr_i \
      can_testbench.i_can_top2.port_0_io[7:0]'h \
      can_testbench.i_can_top2.reset_mode \
      can_testbench.i_can_top2.tx_o \
      can_testbench.i_can_top2.rx_i \
      can_testbench.i_can_top2.i_can_bsp.rx_idle \
      can_testbench.i_can_top2.i_can_bsp.rx_id1 \
      can_testbench.i_can_top2.i_can_bsp.rx_rtr1 \
      can_testbench.i_can_top2.i_can_bsp.rx_ide \
      can_testbench.i_can_top2.i_can_bsp.rx_id2 \
      can_testbench.i_can_top2.i_can_bsp.rx_rtr2 \
      can_testbench.i_can_top2.i_can_bsp.rx_r1 \
      can_testbench.i_can_top2.i_can_bsp.rx_r0 \
      can_testbench.i_can_top2.i_can_bsp.rx_dlc \
      can_testbench.i_can_top2.i_can_bsp.rx_data \
      can_testbench.i_can_top2.i_can_bsp.rx_crc \
      can_testbench.i_can_top2.i_can_bsp.rx_crc_lim \
      can_testbench.i_can_top2.i_can_bsp.rx_ack \
      can_testbench.i_can_top2.i_can_bsp.rx_ack_lim \
      can_testbench.i_can_top2.i_can_bsp.rx_eof \
      can_testbench.i_can_top2.i_can_bsp.rx_inter \
      can_testbench.i_can_top2.i_can_bsp.go_error_frame \
      can_testbench.i_can_top2.i_can_bsp.error_frame \
      can_testbench.i_can_top2.i_can_bsp.ack_err \
      can_testbench.i_can_top2.i_can_bsp.bit_err \
      can_testbench.i_can_top2.i_can_bsp.crc_err \
      can_testbench.i_can_top2.i_can_bsp.err \
      can_testbench.i_can_top2.i_can_bsp.form_err \
      can_testbench.i_can_top2.i_can_bsp.stuff_err \


deselect all
open window waveform 1 geometry 10 60 1592 1139
zoom at 0(0)ns 0.00000773 0.00000000
