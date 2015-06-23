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
define waveform window listpane 4.96
define waveform window namepane 15.18
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
    "WISHBONE common" \
      tb_ethernet.ethmac.wb_clk_i \
      tb_ethernet.ethmac.wb_rst_i \
      tb_ethernet.ethmac.wb_dat_i[31:0]'h \
      tb_ethernet.ethmac.wb_dat_o[31:0]'h \
      tb_ethernet.ethmac.wb_err_o \

add group \
    "WISHBONE slave signals" \
      tb_ethernet.ethmac.wb_adr_i[11:2]'h \
      tb_ethernet.ethmac.wb_sel_i[3:0]'h \
      tb_ethernet.ethmac.wb_we_i \
      tb_ethernet.ethmac.wb_cyc_i \
      tb_ethernet.ethmac.wb_stb_i \
      tb_ethernet.ethmac.wb_ack_o \

add group \
    "WISHBONE master signals" \
      tb_ethernet.ethmac.m_wb_adr_o[31:0]'h \
      tb_ethernet.ethmac.m_wb_sel_o[3:0]'h \
      tb_ethernet.ethmac.m_wb_we_o \
      tb_ethernet.ethmac.m_wb_dat_i[31:0]'h \
      tb_ethernet.ethmac.m_wb_dat_o[31:0]'h \
      tb_ethernet.ethmac.m_wb_cyc_o \
      tb_ethernet.ethmac.m_wb_stb_o \
      tb_ethernet.ethmac.m_wb_ack_i \
      tb_ethernet.ethmac.m_wb_err_i \

add group \
    "MAC common" \
      tb_ethernet.ethmac.mcoll_pad_i \
      tb_ethernet.ethmac.mcrs_pad_i \

add group \
    "MAC TX" \
      tb_ethernet.ethmac.mtx_clk_pad_i \
      tb_ethernet.ethmac.mtxd_pad_o[3:0]'h \
      tb_ethernet.ethmac.mtxen_pad_o \
      tb_ethernet.ethmac.mtxerr_pad_o \

add group \
    "MAC RX" \
      tb_ethernet.ethmac.mrx_clk_pad_i \
      tb_ethernet.ethmac.mrxd_pad_i[3:0]'h \
      tb_ethernet.ethmac.mrxdv_pad_i \
      tb_ethernet.ethmac.mrxerr_pad_i \

add group \
    "MAC MIIM interface" \
      tb_ethernet.ethmac.mdc_pad_o \
      tb_ethernet.ethmac.md_padoe_o \
      tb_ethernet.ethmac.md_pad_o \
      tb_ethernet.ethmac.md_pad_i \
      tb_ethernet.ethmac.miim1.Busy \
      tb_ethernet.ethmac.miim1.LinkFail \
      tb_ethernet.ethmac.miim1.Nvalid \
      tb_ethernet.ethmac.miim1.CtrlData[15:0]'h \
      tb_ethernet.ethmac.miim1.UpdateMIIRX_DATAReg \
      tb_ethernet.ethmac.miim1.Prsd[15:0]'h \
      tb_ethernet.ethmac.miim1.Divider[7:0]'h \

add group \
    "Test signals" \
      tb_ethernet.test_name[799:0]'a \
      tb_ethernet.ethmac.ethreg1.MIISTATUSOut[31:0]'h \
      tb_ethernet.ethmac.miim1.InProgress \
      tb_ethernet.ethmac.miim1.InProgress_q1 \
      tb_ethernet.ethmac.miim1.InProgress_q2 \
      tb_ethernet.ethmac.miim1.InProgress_q3 \
      tb_ethernet.ethmac.miim1.shftrg.ShiftReg[7:0]'h \
      tb_ethernet.eth_phy.status_bit6_0[6:0]'h \
      tb_ethernet.eth_phy.control_bit8_0[8:0]'h \
      tb_ethernet.eth_phy.control_bit9 \
      tb_ethernet.eth_phy.control_bit14_10[14:10]'h \
      tb_ethernet.eth_phy.control_bit15 \
      tb_ethernet.eth_phy.eth_speed \
      tb_ethernet.eth_phy.m_rst_n_i \
      tb_ethernet.eth_phy.mcoll_o \
      tb_ethernet.eth_phy.mcrs_o \
      tb_ethernet.eth_phy.md_get_phy_address \
      tb_ethernet.eth_phy.md_get_reg_address \
      tb_ethernet.eth_phy.md_get_reg_data_in \
      tb_ethernet.eth_phy.md_put_reg_data_in \
      tb_ethernet.eth_phy.md_put_reg_data_out \
      tb_ethernet.eth_phy.reg_data_in[15:0]'h \
      tb_ethernet.eth_phy.reg_data_out[15:0]'h \
      tb_ethernet.eth_phy.register_bus_in[15:0]'h \
      tb_ethernet.eth_phy.register_bus_out[15:0]'h \
      tb_ethernet.eth_phy.reg_address[4:0]'h \
      tb_ethernet.eth_phy.md_io_output \
      tb_ethernet.eth_phy.md_io_enable \
      tb_ethernet.eth_phy.md_io \
      tb_ethernet.Mdc_O \
      tb_ethernet.Mdi_I \
      tb_ethernet.Mdio_IO \
      tb_ethernet.Mdo_O \
      tb_ethernet.Mdo_OE \
      tb_ethernet.eth_phy.md_io_enable \
      tb_ethernet.eth_phy.md_io_output \
      tb_ethernet.eth_phy.md_io_rd_wr \
      tb_ethernet.eth_phy.md_io_reg \
      tb_ethernet.eth_phy.m_rst_n_i \
      tb_ethernet.eth_phy.md_transfer_cnt'd \
      tb_ethernet.eth_phy.md_transfer_cnt_reset \
      tb_ethernet.eth_phy.mdc_i \
      tb_ethernet.eth_phy.mrx_clk_o \
      tb_ethernet.eth_phy.mrxd_o[3:0]'h \
      tb_ethernet.eth_phy.mrxdv_o \
      tb_ethernet.eth_phy.mrxerr_o \
      tb_ethernet.eth_phy.mtx_clk_o \
      tb_ethernet.eth_phy.mtxd_i[3:0]'h \
      tb_ethernet.eth_phy.mtxen_i \
      tb_ethernet.eth_phy.mtxerr_i \
      tb_ethernet.eth_phy.phy_address[4:0]'h \
      tb_ethernet.eth_phy.phy_id1[15:0]'h \
      tb_ethernet.eth_phy.phy_id2[15:0]'h \
      tb_ethernet.eth_phy.phy_log[31:0]'h \
      tb_ethernet.eth_phy.reg_address[4:0]'h \
      tb_ethernet.eth_phy.register_bus_in[15:0]'h \
      tb_ethernet.eth_phy.register_bus_out[15:0]'h \
      tb_ethernet.eth_phy.registers_addr_data_test_operation \
      tb_ethernet.eth_phy.rx_link_down_halfperiod \
        ( \
          minmax 0 93 \
        ) \
      tb_ethernet.eth_phy.self_clear_d0 \
      tb_ethernet.eth_phy.self_clear_d1 \
      tb_ethernet.eth_phy.self_clear_d2 \
      tb_ethernet.eth_phy.self_clear_d3 \
      tb_ethernet.eth_phy.status_bit6_0[6:0]'h \
      tb_ethernet.eth_phy.status_bit7 \
      tb_ethernet.eth_phy.status_bit8 \
      tb_ethernet.eth_phy.status_bit15_9[15:9]'h \


deselect all
open window designbrowser 1 geometry 56 117 855 550
open window waveform 1 geometry 10 59 1592 1094
zoom at 4981823.979(0)ns 0.00025639 0.00000000
