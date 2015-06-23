
#
#  Display top-level ports
#
set binopt {-logic}
set hexopt {-literal -hex}

set tbpath {/system_tb/dut}

eval add wave -color DarkGreen -noupdate -divider {"top-level ports"}
eval add wave -color DarkGreen -noupdate $binopt /system_tb/sys_clk
eval add wave -color DarkGreen -noupdate $binopt /system_tb/sys_rst
eval add wave -color DarkGreen -noupdate $binopt /system_tb/wb_rst
eval add wave -color DarkGreen -noupdate $binopt /system_tb/dut/plb_bfm_slave/synch_in


# eval do ../../behavioral/mb_plb_wave.do
# eval do ../../behavioral/plb_bfm_monitor_wave.do


 # Master signals
 proc add_master { num color } {
      global binopt hexopt tbpath
      eval add wave -color ${color} -noupdate -group Master_${num}
      eval add wave -color ${color} -label ${num}_m_request      -group Master_${num} -noupdate $binopt $tbpath/plb_bfm_master_${num}/m_request     
      eval add wave -color ${color} -label ${num}_m_abus         -group Master_${num} -noupdate $hexopt $tbpath/plb_bfm_master_${num}/m_abus        
      eval add wave -color ${color} -label ${num}_m_be           -group Master_${num} -noupdate $hexopt $tbpath/plb_bfm_master_${num}/m_be          
      eval add wave -color ${color} -label ${num}_m_rnw          -group Master_${num} -noupdate $binopt $tbpath/plb_bfm_master_${num}/m_rnw         
      eval add wave -color ${color} -label ${num}_m_size         -group Master_${num} -noupdate $binopt $tbpath/plb_bfm_master_${num}/m_size        
      eval add wave -color ${color} -label ${num}_m_priority     -group Master_${num} -noupdate $hexopt $tbpath/plb_bfm_master_${num}/m_priority    
      eval add wave -color ${color} -label ${num}_plb_mrddbus    -group Master_${num} -noupdate $hexopt $tbpath/plb_bfm_master_${num}/plb_mrddbus   
      eval add wave -color ${color} -label ${num}_m_wrdbus       -group Master_${num} -noupdate $hexopt $tbpath/plb_bfm_master_${num}/m_wrdbus      
 }
 add_master 32  White 
 add_master 64  AliceBlue
 add_master 128 Seashell



-- do ../behavioral/mb_plb_wave.do

 proc add_ocram { num color } {
   global binopt hexopt tbpath
   eval add wave -color ${color} -noupdate -group ocram${num}
   eval add wave -color ${color} -label wb_stb_i         -group ocram${num} -noupdate  $tbpath/onchip_ram_${num}/onchip_ram_${num}/wb_stb_i
   eval add wave -color ${color} -label wb_stb_i         -group ocram${num} -noupdate  $tbpath/onchip_ram_${num}/onchip_ram_${num}/wb_stb_i
   eval add wave -color ${color} -label wb_ack_o         -group ocram${num} -noupdate  $tbpath/onchip_ram_${num}/onchip_ram_${num}/wb_ack_o
   eval add wave -color ${color} -label wb_err_o         -group ocram${num} -noupdate  $tbpath/onchip_ram_${num}/onchip_ram_${num}/wb_err_o
   eval add wave -color ${color} -label wb_rty_o         -group ocram${num} -noupdate  $tbpath/onchip_ram_${num}/onchip_ram_${num}/wb_rty_o
   eval add wave -color ${color} -label w_ack            -group ocram${num} -noupdate  $tbpath/onchip_ram_${num}/onchip_ram_${num}/w_ack
   eval add wave -color ${color} -label err_rty_count_r  -group ocram${num} -noupdate  $tbpath/onchip_ram_${num}/onchip_ram_${num}/err_rty_count_r
   eval add wave -color ${color} -label err_rty_count_w  -group ocram${num} -noupdate  $tbpath/onchip_ram_${num}/onchip_ram_${num}/err_rty_count_w
   eval add wave -color ${color} -label r_delay_count    -group ocram${num} -noupdate  $tbpath/onchip_ram_${num}/onchip_ram_${num}/r_delay_count
   eval add wave -color ${color} -label w_delay_count    -group ocram${num} -noupdate  $tbpath/onchip_ram_${num}/onchip_ram_${num}/w_delay_count

   eval add wave -color ${color} -label ram(0)   -group ocram${num} -noupdate  $hexopt     $tbpath/onchip_ram_${num}/onchip_ram_${num}/ram(0)
   eval add wave -color ${color} -label ram(1)   -group ocram${num} -noupdate  $hexopt     $tbpath/onchip_ram_${num}/onchip_ram_${num}/ram(1)
   eval add wave -color ${color} -label ram(2)   -group ocram${num} -noupdate  $hexopt     $tbpath/onchip_ram_${num}/onchip_ram_${num}/ram(2)
   eval add wave -color ${color} -label ram(3)   -group ocram${num} -noupdate  $hexopt     $tbpath/onchip_ram_${num}/onchip_ram_${num}/ram(3)
   eval add wave -color ${color} -label ram(4)   -group ocram${num} -noupdate  $hexopt     $tbpath/onchip_ram_${num}/onchip_ram_${num}/ram(4)
   eval add wave -color ${color} -label ram(5)   -group ocram${num} -noupdate  $hexopt     $tbpath/onchip_ram_${num}/onchip_ram_${num}/ram(5)
   eval add wave -color ${color} -label ram(6)   -group ocram${num} -noupdate  $hexopt     $tbpath/onchip_ram_${num}/onchip_ram_${num}/ram(6)
   eval add wave -color ${color} -label ram(7)   -group ocram${num} -noupdate  $hexopt     $tbpath/onchip_ram_${num}/onchip_ram_${num}/ram(7)
 }




 # 
 # General bridge signals
 #
 eval add wave -color purple -group bridge_general -noupdate 
 eval add wave -color purple -label sl_addrack     -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/sl_addrack
 eval add wave -color purple -label plb_abus       -group bridge_general -noupdate $hexopt   $tbpath/plb2wb_bridge_0/plb_abus      
 eval add wave -color purple -label plb_be         -group bridge_general -noupdate $hexopt   $tbpath/plb2wb_bridge_0/plb_be        
 eval add wave -color purple -label plb_pavalid    -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/plb_pavalid   
 eval add wave -color purple -label plb_savalid    -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/plb_savalid   
 eval add wave -color purple -label plb_rnw        -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/plb_rnw       
 eval add wave -color purple -label plb_msize      -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/plb_msize     
 eval add wave -color purple -label plb_type       -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/plb_type      
 eval add wave -color purple -label plb_wrdbus     -group bridge_general -noupdate $hexopt   $tbpath/plb2wb_bridge_0/plb_wrdbus    
 eval add wave -color purple -label sl_rddbus      -group bridge_general -noupdate $hexopt   $tbpath/plb2wb_bridge_0/sl_rddbus     
                                                  
 eval add wave -color purple -label sl_wrdack      -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/sl_wrdack
 eval add wave -color maroon -label sl_wrcomp      -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/sl_wrcomp
 eval add wave -color purple -label sl_rddack      -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/sl_rddack
 eval add wave -color maroon -label sl_rdcomp      -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/sl_rdcomp

 eval add wave -color maroon -label sl_rdprim      -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/plb_rdprim
 eval add wave -color maroon -label sl_wrprim      -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/plb_wrprim


 eval add wave -color maroon -label wb_adr_o       -group bridge_general -noupdate $hexopt   $tbpath/plb2wb_bridge_0/wb_adr_o      
 eval add wave -color maroon -label wb_cyc_o       -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/wb_cyc_o      
 eval add wave -color maroon -label wb_dat_i       -group bridge_general -noupdate $hexopt   $tbpath/plb2wb_bridge_0/wb_dat_i      
 eval add wave -color maroon -label wb_dat_o       -group bridge_general -noupdate $hexopt   $tbpath/plb2wb_bridge_0/wb_dat_o      
 eval add wave -color maroon -label wb_err_i       -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/wb_err_i      
 eval add wave -color maroon -label wb_rst_i       -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/wb_rst_i      
 eval add wave -color maroon -label wb_sel_o       -group bridge_general -noupdate $hexopt   $tbpath/plb2wb_bridge_0/wb_sel_o      
 eval add wave -color maroon -label wb_stb_o       -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/wb_stb_o      
 eval add wave -color maroon -label wb_we_o        -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/wb_we_o       
 eval add wave -color maroon -label sl_mbusy       -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/sl_mbusy
 eval add wave -color maroon -label sl_mwrerr      -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/sl_mwrerr
 eval add wave -color maroon -label sl_mrderr      -group bridge_general -noupdate           $tbpath/plb2wb_bridge_0/sl_mrderr

 eval add wave -color maroon -label sl_mirq      -group bridge_general -noupdate             $tbpath/plb2wb_bridge_0/sl_mirq
 #
 # Bridge - Transfer Control Unit
 # 
 eval add wave -color aquamarine -group bridge_TCU -noupdate  
 eval add wave -color aquamarine -label c_plb_wstate     -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/c_plb_wstate     
 eval add wave -color aquamarine -label c_plb_rstate     -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/c_plb_rstate     
 eval add wave -color aquamarine -label c_wb_state       -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/c_wb_state      
 eval add wave -color aquamarine -label wb_ack           -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/wb_ack
 eval add wave -color aquamarine -label wb_err           -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/wb_err
 eval add wave -color aquamarine -label wb_rty           -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/wb_rty

 eval add wave -color aquamarine -label tcu_addrack      -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_addrack    
 eval add wave -color aquamarine -label sl_rdwdaddr      -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/sl_rdwdaddr

 eval add wave -color aquamarine -label tcu_adr_offset   -group bridge_TCU -noupdate $hexopt $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_adr_offset  
 eval add wave -color aquamarine -label tcu_adrbufren    -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_adrbufren   
 eval add wave -color aquamarine -label tcu_adrbufwen    -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_adrbufwen   
 eval add wave -color aquamarine -label tcu_rpiperden   -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_rpiperden  
 eval add wave -color aquamarine -label tcu_wpiperden   -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_wpiperden

 eval add wave -color aquamarine -label tcu_enrddbus     -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_enrddbus    
 eval add wave -color aquamarine -label tcu_rbufren      -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_rbufren     
 eval add wave -color aquamarine -label tcu_rbufwen      -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_rbufwen     
 eval add wave -color aquamarine -label tcu_wbufren      -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_wbufren     
 eval add wave -color aquamarine -label tcu_wbufwen      -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_wbufwen     

 eval add wave -color aquamarine -label tcu_enStuRDDbus  -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_ensturddbus
 eval add wave -color aquamarine -label tcu_stuWritePA   -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_stuwritepa
 eval add wave -color aquamarine -label tcu_stuWriteSA   -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_stuwritesa
 eval add wave -color aquamarine -label tcu_stat2plb_en  -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_stat2plb_en
 eval add wave -color aquamarine -label tcu_wb_status_info -group bridge_TCU -noupdate       $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/tcu_wb_status_info

 eval add wave -color aquamarine -label tcu_mrbusy       -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/tcu_mrbusy      
 eval add wave -color aquamarine -label mbusy_read_out   -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/mbusy_read_out  
 eval add wave -color aquamarine -label mbusy_write_out  -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/mbusy_write_out  
 eval add wave -color aquamarine -label SL_MWrErr         -group bridge_TCU -noupdate        $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/SL_MWrErr
 eval add wave -color aquamarine -label SL_MRdErr         -group bridge_TCU -noupdate        $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/SL_MRdErr
 eval add wave -color aquamarine -label sl_wrbterm       -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/sl_wrbterm
 eval add wave -color aquamarine -label sl_rdbterm       -group bridge_TCU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/tcu/sl_rdbterm



 #
 # Bridge - Status Unit
 #
 eval add wave -color DarkSalmon -group bridge_STU -noupdate  
 eval add wave -color DarkSalmon -label STU_full          -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/STU_full
 eval add wave -color DarkSalmon -label STU_softReset     -group bridge_STU -noupdate $hexopt $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/STU_softReset
 eval add wave -color DarkSalmon -label STU_continue      -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/STU_continue
 eval add wave -color DarkSalmon -label STU_abort         -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/STU_abort
 eval add wave -color DarkSalmon -label amu_masterid      -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/amu_masterid   
 eval add wave -color DarkSalmon -label plb_masterid      -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/plb_masterid    

 eval add wave -color DarkSalmon -label stat2plb_empty    -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/stat2plb_empty
 eval add wave -color DarkSalmon -label stat2plb_rd_en    -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/stat2plb_rd_en
 eval add wave -color DarkSalmon -label stat2wb_rd_en     -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/stat2wb_rd_en
 eval add wave -color DarkSalmon -label stat2wb_wr_en     -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/stat2wb_wr_en
 eval add wave -color DarkSalmon -label stat2wb_full      -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/stat2wb_full
 eval add wave -color DarkSalmon -label stat2wb_empty     -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/stat2wb_empty
 eval add wave -color DarkSalmon -label stat2wb_dout      -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/stat2wb_dout
 eval add wave -color DarkSalmon -label stat2wb_din       -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/stat2wb_din

 eval add wave -color DarkSalmon -label tcu_stuLatchPA       -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/tcu_stulatchpa
 eval add wave -color DarkSalmon -label tcu_stuLatchSA       -group bridge_STU -noupdate  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/tcu_stulatchsa


 eval add wave -color DarkSalmon -label soft_reset_count  -group bridge_STU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/soft_reset_count
 eval add wave -color DarkSalmon -label address_reg       -group bridge_STU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/address_reg
 eval add wave -color DarkSalmon -label status_reg0       -group bridge_STU -noupdate $hexopt $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/status_regs(0)
 eval add wave -color DarkSalmon -label status_reg1       -group bridge_STU -noupdate $hexopt $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/status_regs(1)
 eval add wave -color DarkSalmon -label status_reg2       -group bridge_STU -noupdate $hexopt $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/status_regs(2)
 eval add wave -color DarkSalmon -label status_reg3       -group bridge_STU -noupdate $hexopt $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/status_regs(3)
 eval add wave -color DarkSalmon -label status_reg_out    -group bridge_STU -noupdate $hexopt $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/status_reg_out
 
 eval add wave -color DarkSalmon -label sl_mirq            -group bridge_STU -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/stu/sl_mirq


 #
 # Bridge - Adress Management Unit
 #
 eval add wave -color RosyBrown -group bridge_AMU -noupdate  
 eval add wave -color RosyBrown -label amu_addrack      -group bridge_AMU -noupdate          $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_addrack       
 eval add wave -color RosyBrown -label plb_savalid      -group bridge_AMU -noupdate          $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/plb_savalid
 eval add wave -color RosyBrown -label amu_buf_rnw      -group bridge_AMU -noupdate          $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_buf_rnw       
 eval add wave -color RosyBrown -label amu_bufempty     -group bridge_AMU -noupdate          $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_bufempty      
 eval add wave -color RosyBrown -label amu_buffull      -group bridge_AMU -noupdate          $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_buffull       
 eval add wave -color RosyBrown -label amu_deviceselect -group bridge_AMU -noupdate          $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_deviceselect  
 eval add wave -color RosyBrown -label amu_statusselect -group bridge_AMU -noupdate          $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_statusselect  
 eval add wave -color RosyBrown -label amu_pipe_rmID    -group bridge_AMU -noupdate $hexopt  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_pipe_rmID      
 eval add wave -color RosyBrown -label amu_pipe_wmID    -group bridge_AMU -noupdate $hexopt  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_pipe_wmID      
 eval add wave -color rosyBrown -label amu_buf_size     -group bridge_AMU -noupdate          $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_buf_size
 eval add wave -color rosyBrown -label amu_buf_BE       -group bridge_AMU -noupdate          $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_buf_BE
 eval add wave -color rosyBrown -label amu_pipe_size    -group bridge_AMU -noupdate          $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_pipe_size
 eval add wave -color rosyBrown -label amu_pipe_size    -group bridge_AMU -noupdate          $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_pipe_BE
 eval add wave -color RosyBrown -label amu_buf_adr        -group bridge_AMU -noupdate $hexopt  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_buf_adr
 eval add wave -color RosyBrown -label wb_sel_o         -group bridge_AMU -noupdate $hexopt  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/wb_sel_o          
 eval add wave -color RosyBrown -label rpipe_out        -group bridge_AMU -noupdate $hexopt  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/rpipe_out
 eval add wave -color RosyBrown -label wpipe_out        -group bridge_AMU -noupdate $hexopt  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/wpipe_out
 eval add wave -color RosyBrown -label pipeline_in      -group bridge_AMU -noupdate $hexopt  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/pipeline_in
 eval add wave -color RosyBrown -label AMU_pipe_adr     -group bridge_AMU -noupdate $hexopt  $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_pipe_adr
 eval add wave -color RosyBrown -label AMU_pipe_rStatusSelect -group bridge_AMU -noupdate    $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_pipe_rStatusSelect
 eval add wave -color RosyBrown -label AMU_pipe_wStatusSelect -group bridge_AMU -noupdate    $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/amu/amu_pipe_wStatusSelect


 #
 # Read buffer
 #
 eval add wave -color SpringGreen -group bridge_RBF -noupdate  
 eval add wave -color SpringGreen -label rbuf_din        -group bridge_RBF -noupdate $hexopt $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/rbuf/rbuf_din
 eval add wave -color SpringGreen -label rbuf_dout       -group bridge_RBF -noupdate $hexopt $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/rbuf/rbuf_dout
 eval add wave -color SpringGreen -label tcu_rbufren     -group bridge_RBF -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/rbuf/tcu_rbufren
 eval add wave -color SpringGreen -label tcu_rbufwen     -group bridge_RBF -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/rbuf/tcu_rbufwen
 eval add wave -color SpringGreen -label rbf_empty       -group bridge_RBF -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/rbuf/rbf_empty
 eval add wave -color SpringGreen -label rbf_full        -group bridge_RBF -noupdate         $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/rbuf/rbf_full


 #
 # Write buffer
 #
 eval add wave -color LimeGreen -group bridge_WBF -noupdate
 eval add wave -color LimeGreen -label plb_size       -group bridge_WBF -noupdate            $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/wbuf/plb_size        
 eval add wave -color LimeGreen -label wbf_empty      -group bridge_WBF -noupdate            $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/wbuf/wbf_empty       
 eval add wave -color LimeGreen -label wbf_full       -group bridge_WBF -noupdate            $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/wbuf/wbf_full        
 eval add wave -color LimeGreen -label wbf_wbus       -group bridge_WBF -noupdate            $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/wbuf/wbf_wbus        
 eval add wave -color LimeGreen -label tcu_wbufren    -group bridge_WBF -noupdate            $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/wbuf/tcu_wbufren     
 eval add wave -color LimeGreen -label tcu_wbufwen    -group bridge_WBF -noupdate            $tbpath/plb2wb_bridge_0/plb2wb_bridge_0/wbuf/tcu_wbufwen     



 #
 #  Whishbone signals
 # 
 eval add wave -color Orange -noupdate -group Wishbone

 eval add wave -color Orange -label wb_m_dat_o -group Wishbone -noupdate $hexopt $tbpath/wb_conbus_0/wb_m_dat_o
 eval add wave -color Orange -label wb_m_ack_o -group Wishbone -noupdate $hexopt $tbpath/wb_conbus_0/wb_m_ack_o
 eval add wave -color Orange -label wb_m_err_o -group Wishbone -noupdate $hexopt $tbpath/wb_conbus_0/wb_m_err_o
 eval add wave -color Orange -label wb_m_rty_o -group Wishbone -noupdate $hexopt $tbpath/wb_conbus_0/wb_m_rty_o
 eval add wave -color Orange -label wb_s_dat_o -group Wishbone -noupdate $hexopt $tbpath/wb_conbus_0/wb_s_dat_o
 eval add wave -color Orange -label wb_s_adr_o -group Wishbone -noupdate $hexopt $tbpath/wb_conbus_0/wb_s_adr_o
 eval add wave -color Orange -label wb_s_sel_o -group Wishbone -noupdate $hexopt $tbpath/wb_conbus_0/wb_s_sel_o
 eval add wave -color Orange -label wb_s_we_o  -group Wishbone -noupdate $binopt $tbpath/wb_conbus_0/wb_s_we_o
 eval add wave -color Orange -label wb_s_cyc_o -group Wishbone -noupdate $binopt $tbpath/wb_conbus_0/wb_s_cyc_o
 eval add wave -color Orange -label wb_s_stb_o -group Wishbone -noupdate $hexopt $tbpath/wb_conbus_0/wb_s_stb_o
 # eval add wave -color Orange -label wb_s_lock_o -group Wishbone -noupdate $hexopt $tbpath/wb_conbus_0/wb_s_lock_o
 eval add wave -color Orange -label wb_clk_i   -group Wishbone -noupdate $binopt $tbpath/wb_conbus_0/wb_clk_i


 add_ocram  0 OrangeRed
 add_ocram  1 OrangeRed
 add_ocram  2 OrangeRed
 add_ocram  3 OrangeRed
 add_ocram  4 OrangeRed
 add_ocram  5 OrangeRed

 configure wave -namecolwidth 347
 configure wave -valuecolwidth 252
 configure wave -timeline 0
 configure wave -timelineunits ns
