##################################################################
### Functions declaration
## -- start

proc write_reg32 { addr val } {
  puts "Write 32 $addr $val"
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tvalid 1 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tlast 1 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tkeep 8'h1F 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(63 downto 0) $addr 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(74 downto 64) 11'h1 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(78 downto 75) 4'h1 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(95 downto 79) 16'h0 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(102 downto 96) 8'h6 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(127 downto 103) 24'h0 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(255 downto 128) $val
  run 4ns
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tvalid 0 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tlast 0 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tkeep 8'h00 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(255 downto 0) 256'h0 0
  run 8ns
  set tready [examine -value sim:/virtex7_dma_top/u1/dma0/s_axis_r_cq.tready]
  while {$tready < 1} {
    set tready [examine -value sim:/virtex7_dma_top/u1/dma0/s_axis_r_cq.tready]
    run 8ns
  }
  
}
proc write_reg128 { addr val } {
  puts "Write 128 $addr $val"
  
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tvalid 1 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tlast 1 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tkeep 8'hFF 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(63 downto 0) $addr 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(74 downto 64) 11'h4 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(78 downto 75) 4'h1 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(95 downto 79) 16'h0 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(102 downto 96) 8'h6 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(127 downto 103) 24'h0 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(255 downto 128) $val
  run 4ns
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tvalid 0 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tlast 0 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tkeep 8'h00 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_cq.tdata(255 downto 0) 256'h0 0
  run 8ns
  set tready [examine -value sim:/virtex7_dma_top/u1/dma0/s_axis_r_cq.tready]
  while {$tready < 1} {
    set tready [examine -value sim:/virtex7_dma_top/u1/dma0/s_axis_r_cq.tready]
    run 8ns
  }
}

proc write_dma { addr dataL dataH tag size} {
  upvar $dataL dL
  upvar $dataH dH
  
  set wordcount [format "%X" [expr $size * 8]]
  # address                                
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(11 downto 0) $addr 0
  #Error code, no error                    
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(15 downto 12) 4'h0 0
  #byte count                              
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(28 downto 16) 13'h0 0
  #locked read completion                  
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(29) 1'h0 0
  #request completed                       
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(30) 1'h0 0
  #unimplemented                           
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(31) 1'h0 0
  #Dword count                             
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(42 downto 32) $wordcount 0
  #Completion status                       
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(45 downto 43) 3'h0 0
  #Poinsoned Completion                    
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(46) 1'h0 0
  #Reserved                                
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(47) 1'h0 0
  #Req ID                                  
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(63 downto 48) 16'hDEAD 0
  #Tag                                     
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(71 downto 64) $tag 0
  #Com ID                                  
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(87 downto 72) 16'hBEEF 0
  #Reserved                                
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(88) 1'h0 0
  #TC                                      
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(91 downto 89) 3'h0 0
  #Attr                                    
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(94 downto 92) 3'h0 0
  #Reserved                                
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(95) 1'h0 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(255 downto  96) $dL(0) 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tkeep 8'hFF 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tlast 0 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tvalid 1 0
  run 4ns
  
  for {set i 0} {$i < [expr $size - 1]} {incr i} {
    force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(95 downto 0) $dH($i) 0
    force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(255 downto  96) $dL([expr $i + 1]) 0
    force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tkeep 8'hFF 0
    force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tlast 0 0
    force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tvalid 1 0
    run 4ns
  }
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(95 downto 0) $dH($i) 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata(255 downto  96) 16'h0 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tkeep 8'h07 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tlast 1 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tvalid 1 0
  run 4ns
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tdata 256'h0  0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tkeep 8'h00 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tlast 0 0
  force -freeze sim:/virtex7_dma_top/u1/dma0/s_axis_rc.tvalid 0 0
  run 4ns      
}
## -- end 

##################################################################
### Beginning of simulation

restart -force
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
force -freeze sim:/virtex7_dma_top/u1/dma0/u1/bar0 fbb00000 0
force -freeze sim:/virtex7_dma_top/u1/dma0/u1/bar1 fba00000 0
force -freeze sim:/virtex7_dma_top/u1/dma0/u1/bar2 fb900000 0

force -freeze sim:/virtex7_dma_top/sys_reset_n 0 0
force -freeze sim:/virtex7_dma_top/sys_clk_p 1 0, 0 {5 ns} -r 10 ns
force -freeze sim:/virtex7_dma_top/sys_clk_n 0 0, 1 {5 ns} -r 10 ns

#force -freeze sim:/virtex7_dma_top/clk_200_in_n 1 0, 0 {2.5 ns} -r 5 ns
#force -freeze sim:/virtex7_dma_top/clk_200_in_p 0 0, 1 {2.5 ns} -r 5 ns
# forced signals 
force -freeze sim:/virtex7_dma_top/u1/dma0/m_axis_r_rq.tready 1 0
force -freeze sim:/virtex7_dma_top/u1/dma0/m_axis_r_cc.tready 1 0
force -freeze sim:/virtex7_dma_top/u1/u2/cfg_interrupt_msix_enable 1 0
force -freeze sim:/virtex7_dma_top/u1/u2/interrupt_vector_s(0).int_vec_add 16'h00000000000000AA 0
force -freeze sim:/virtex7_dma_top/u1/u2/interrupt_vector_s(0).int_vec_data 16'h0000C1A0 0
force -freeze sim:/virtex7_dma_top/u1/u2/interrupt_vector_s(0).int_vec_ctrl 16'h00000000 0
force -freeze sim:/virtex7_dma_top/u1/u2/interrupt_vector_s(1).int_vec_add 16'h00000000000000BB 0
force -freeze sim:/virtex7_dma_top/u1/u2/interrupt_vector_s(1).int_vec_data 16'h0000CA70 0
force -freeze sim:/virtex7_dma_top/u1/u2/interrupt_vector_s(1).int_vec_ctrl 16'h00000000 0
run 100 ns
force -freeze sim:/virtex7_dma_top/sys_reset_n 1 0
force -freeze sim:/virtex7_dma_top/u1/reset 0 0
run 102ns                            
run 800ns
## emulated register writes
write_reg128 64'hfbb00000 128'h0000_0004_5600_0400_0000_0004_5600_0000
write_reg128 64'hfbb00010 128'h0000_0004_5600_0000_0000_0000_0000_1040
write_reg128 64'hfbb00020 128'h0000_0004_5600_0800_0000_0004_5600_0000
write_reg128 64'hfbb00030 128'h0000_0004_5600_0700_0000_0000_0000_1840
#do it another time to see if read works.
#write_reg128 64'hfbb00030 128'h00000000000000000000000000000840
# issue a soft reset
#write_reg32 64'hfbb00430 128'h1
#enable descriptor 0 and 1
write_reg32 64'hfbb00400 128'h3
#enable interrupt table 
run 15ns
force -freeze sim:/virtex7_dma_top/u1/dma0/m_axis_r_rq.tready 0 0
run 12ns
force -freeze sim:/virtex7_dma_top/u1/dma0/m_axis_r_rq.tready 1 0
#write_reg32 64'hfba0100 32'h1

run 100ns

#### emulated PCIe read to drive the AXI interface from the Core side
##
#set dmadataL(0) 160'h131211100f0e0d0c0b0a09080706050403020100
#set dmadataH(0)  96'h1f1e1d1c1b1a191817161514
#set dmadataL(1) 160'h333231302f2e2d2c2b2a29282726252423222120
#set dmadataH(1)  96'h3f3e3d3c3b3a393837363534
#set dmadataL(2) 160'h535251504f4e4d4c4b4a49484746454443424140
#set dmadataH(2)  96'h5f5e5d5c5b5a595857565554
#set dmadataL(3) 160'h737271706f6e6d6c6b6a69686766656463626160
#set dmadataH(3)  96'h7f7e7d7c7b7a797877767574
#set dmadataL(4) 160'h939291908f8e8d8c8b8a89888786858483828180
#set dmadataH(4)  96'h9f9e9d9c9b9a999897969594
#set dmadataL(5) 160'hB3B2B1B0AfAeAdAcAbAaA9A8A7A6A5A4A3A2A1A0
#set dmadataH(5)  96'hBfBeBdBcBbBaB9B8B7B6B5B4
#set dmadataL(6) 160'hD3D2D1D0CfCeCdCcCbCaC9C8C7C6C5C4C3C2C1C0
#set dmadataH(6)  96'hDfDeDdDcDbDaD9D8D7D6D5D4
#set dmadataL(7) 160'hF3F2F1F0EfEeEdEcEbEaE9E8E7E6E5E4E3E2E1E0
#set dmadataH(7)  96'hFfFeFdFcFbFaF9F8F7F6F5F4
#
#write_dma 12'hABC dmadataL dmadataH 8'h10 8



#run 100ns
#write_dma 12'hABC dmadataL dmadataH 8'h11 8
#run 100ns
#write_dma 12'hABC dmadataL dmadataH 8'h12 8
#run 100ns
#write_dma 12'hABC dmadataL dmadataH 8'h13 8
#run 100ns
#write_dma 12'hABC dmadataL dmadataH 8'h14 8
#run 100ns
#write_dma 12'hABC dmadataL dmadataH 8'h15 8
#run 100ns
#write_dma 12'hABC dmadataL dmadataH 8'h15 8
#run 100ns
#write_dma 12'hABC dmadataL dmadataH 8'h16 8
#run 100ns
#write_dma 12'hABC dmadataL dmadataH 8'h17 8
#run 100ns
#write_dma 12'hABC dmadataL dmadataH 8'h18 8
#run 100ns
#write_dma 12'hABC dmadataL dmadataH 8'h19 8
#run 100ns
#write_dma 12'hABC dmadataL dmadataH 8'h1A 8
#run 100ns

#write_reg32 64'hfbb00400 128'h1
run 100ns
force -freeze sim:/virtex7_dma_top/u1/dma0/u2/m_axis_r_rq.tready 0 0
run 80ns
force -freeze sim:/virtex7_dma_top/u1/dma0/u2/m_axis_r_rq.tready 1 0
run 100ns
#run 12us
write_reg128 64'hfbb00010 128'h0000_0004_5600_0400_0000_0000_0000_1040
run 100ns
write_reg128 64'hfbb00010 128'h0000_0004_5600_0000_0000_0000_0000_1040
run 200ns
write_reg128 64'hfbb00010 128'h0000_0004_5600_0200_0000_0000_0000_1040
run 200ns
write_reg128 64'hfbb00010 128'h0000_0004_5600_0300_0000_0000_0000_1040
run 200ns
write_reg128 64'hfbb00010 128'h0000_0004_5600_0400_0000_0000_0000_1040

