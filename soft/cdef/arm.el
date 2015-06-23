(progn
  (load "cdef_lib_b1")
  (load "cdef_lib_c1")
  (load "cdef_lib_g1")
  (load "cdef_lib_l1")
  (load "cdef_lib_m1")
  (load "cdef_lib_i1")
  (load "cdef_lib_h1")
  (load "cdef_lib_pc")
  (load "cdef_lib_pv")
)

(progn
  (if (load "cdef_lib_b1") ()(message "You have to set your elisp load-path variable, i.e: (setq load-path
      (append (list nil \"/home/eiselekd/vhdl_0.8/soft/cdef\") load-path)))"))
  (load "cdef_lib_c1")
  (load "cdef_lib_g1")
  (load "cdef_lib_l1")
  (load "cdef_lib_m1")
  (load "cdef_lib_i1")
  (load "cdef_lib_h1")
  (load "cdef_lib_pc")
  (load "cdef_lib_pv")

(setq insn-help '(
		  (c "Condition code")
		  (op1 "Data processing opcode")
		  (rn "Register rn")
		  (rm "Register rm")
		  (rs "Register rs")
		  (rdl "Destination register long")
		  (rd "Destination register rd")
		  (sha "Shieft amount")
		  (sh "Shieft direction")
		  (dps "Update cpsr") 
		  (imm "Breakpoint imm part1")
		  (imm2 "Breakpoint imm part2")

		  (dsop "Dsp operand")
		  (MS "Set cpsr")
		  (MA "Multiply accumulate")
		  (MU "Multiply unsigned")
		  
		  (SB "Swap byte")
		  (LSP "pre-indexed")
		  (LSU "add/sub base '1'=add")
		  (LSW "writeback")
		  (LSL "Load|Store '1'=Load")
		  (S "Signed|Unsigned '1'=signed")
		  (H "halfword|signedbyte '1'=halfword")
		  (i81 "Immidiate8 part1")
		  (i82 "Immidiate8 part2")
		  (dpi "Immidiate8")
		  (rot "Immidiate8 rotate")
		  (rgl "register list")
		  (R "Cpsr|Spsr '1'=Spsr")		       	   	      	       	    	       	    	      	   	     	       	    	      	   	     	       	    	      	   	     						    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    					    						    					    						    					    					    
		  (MSK "move immidiate to status register mask")		       	   	      	       	    	       	    	      	   
		  (LSB "Byte|word '1'=byte")
		  (LMS "Set cpsr fro spsr")
		  (BLL "Link")
		  (BLH "Exchange")
		  (Cp_N "Coprocessor n bit")
		  (cpn "Coprocessor number")
		  (crn "Coprocessor register rn")
		  (crm "Coprocessor register rm")
		  (of8 "offset8")
		  (crd "Coprocessor destination register")
		  (co1 "Coprocessor op1")
		  
		  (insn_dp_i_s "Data Processing immidiate shieft")
		  
		  (insn_msr  "Move status register to register" )
		  (insn_mrs  "Move register to status register" )
		  (insn_bex  "Branch / exchange")
		  (insn_clz  "Count leading zero")
		  (insn_blx  "Branch and link /exchange")
		  (insn_dsa  "Dsp add|sub")
		  (insn_brk  "Breakpoint" )
		  (insn_dsm  "DSP multiply")
		  
		  (insn_dp_r_s "Data processing register shieft")
		  
		  (insn_mula "Multiply and accumulate")
		  (insn_mull "Multiply long")
		  
		  (insn_swp "Swap|swap byte")
		  
		  (insn_ld1 "Load|Store halfword")
		  (insn_ld2 "Load|Store halfword immidiate offset")
		  (insn_ld3 "Load|Store two words register offset")
		  (insn_ld4 "Load|Store signed halfword/byte register offset")
		  (insn_ld5 "Load|Store two words register offset")
		  (insn_ld6 "Load|Store signed halfword/byte immidiate offset")
		  
		  (insn_dp_i "Data processing immidiate")
		  (insn_undef1 "Undefined instruction")
		  (insn_misr "Move immidiate to status register")
		  (insn_lsio "Load|Store imidiate offset")
		  (insn_lsro "Load|Store register offset")
		  (insn_undef2 "Undefined instruction2")
		  (insn_undef3 "Undefined instruction3")
		  (insn_lsm "Load|Store multiple")
		  (insn_undef4  "Undefined instruction4")
		  (insn_bwl "Branch with link")
		  (insn_bwlth "Branch with link and change to thumb")
		  
		  (insn_cpldst "Coprocessor Load Store")
		  
		  (insn_cpdp "Coprocessor data processing")
		  (insn_cpr "Coprocessor register transfer")
		  
		  (insn_swi "Software interrupt")
		  (insn_undef "Undef")
		  
))


;;      list order   0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16   17   18   19   20   21   22   23   24   25   26   27   28   29   30   31
;;                  31   30   29   28   27   26   25   24   23   22   21   20   19   18   17   16   15   14   13   12   11   10   09   08   07   06   05   04   03   02   01   00
(setq insn_dp_i_s '( c    c    c    c    0    0    0   op1  op1  op1  op1  dps  rn   rn   rn   rn   rd   rd   rd   rd   sha  sha  sha  sha  sha  sh   sh    0   rm   rm   rm   rm  ))
		       	   	      	       	    	       	    	      	   	     	       	    	      	   	     	       	    	      	   	     						    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    					    						    					    						    					    					    
(setq insn_msr    '( c    c    c    c    0    0    0    1    0    R    0    0   SBO  SBO  SBO  SBO   rd   rd   rd   rd  SBZ  SBZ  SBZ  SBZ   0    0    0    0  SBZ2 SBZ2 SBZ2 SBZ2  ))
(setq insn_mrs    '( c    c    c    c    0    0    0    1    0    R    1    0   msk  msk  msk  msk  SBO  SBO  SBO  SBO  SBZ  SBZ  SBZ  SBZ   0    0    0    0   rm   rm   rm   rm  ))
(setq insn_bex    '( c    c    c    c    0    0    0    1    0    0    1    0   SBO  SBO  SBO  SBO  SBO  SBO  SBO  SBO  SBO  SBO  SBO  SBO   0    0    0    1   rm   rm   rm   rm  ))
(setq insn_clz    '( c    c    c    c    0    0    0    1    0    1    1    0   SBO  SBO  SBO  SBO   rd   rd   rd   rd  SBO2 SBO2 SBO2 SBO2   0    0    0    1   rm   rm   rm   rm  ))
(setq insn_blx    '( c    c    c    c    0    0    0    1    0    0    1    0   SBO  SBO  SBO  SBO  SBO  SBO  SBO  SBO  SBO  SBO  SBO  SBO   0    0    1    1   rm   rm   rm   rm  ))
(setq insn_dsa    '( c    c    c    c    0    0    0    1    0  dsop dsop   0   rn   rn   rn   rn    rd   rd   rd   rd  SBZ  SBZ  SBZ  SBZ   0    1    0    1   rm   rm   rm   rm  ))
(setq insn_brk    '( c    c    c    c    0    0    0    1    0    0    1    0   imm  imm  imm  imm  imm  imm  imm  imm  imm  imm  imm  imm   0    1    1    1  imm2 imm2 imm2 imm2  ))
(setq insn_dsm    '( c    c    c    c    0    0    0    1    0  dsop dsop   0   RD   RD   RD   RD    rn   rn   rn   rn  rs   rs   rs   rs    1    y    x    0   rm   rm   rm   rm  ))
		       	   	      	       	    	       	    	      	   	     	       	    	      	   	     	       	    	      	   	     						    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    					    						    					    						    					    					    
(setq insn_dp_r_s '( c    c    c    c    0    0    0   op1  op1  op1  op1  dps  rn   rn   rn   rn   rd   rd   rd   rd   rs   rs   rs   rs    0    sh   sh   1   rm   rm   rm   rm  ))
		       	   	      	       	    	       	    	      	   	     	       	    	      	   	     	       	    	      	   	     						    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    					    						    					    						    					    					    
(setq insn_mula   '( c    c    c    c    0    0    0    0    0    0   MA   MS    rd   rd   rd   rd  rn   rn   rn   rn   rs   rs   rs   rs    1    0    0    1   rm   rm   rm   rm  ))
(setq insn_mull   '( c    c    c    c    0    0    0    0    1   MU   MA   MS    rd   rd   rd   rd  rdl  rdl  rdl  rdl  rs   rs   rs   rs    1    0    0    1   rm   rm   rm   rm  ))
		       	   	      	       	    	       	    	      	   	     	       	    	      	   	     	       	    	      	   	     						    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    					    						    					    						    					    					    
(setq insn_swp    '( c    c    c    c    0    0    0    1    0   SB    0    0    rn   rn   rn   rn  rd   rd   rd   rd   sbz  sbz  sbz  sbz   1    0    0    1   rm   rm   rm   rm  ))
		       	   	      	       	    	       	    	      	   	     	       	    	      	   	     	       	    	      	   	     						    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    					    						    					    						    					    					    
(setq insn_ld1    '( c    c    c    c    0    0    0  LSP  LSU    0  LSW  LSL    rn   rn   rn   rn  rd   rd   rd   rd   sbz  sbz  sbz  sbz   1    0    1    1   rm   rm   rm   rm  ))
(setq insn_ld2    '( c    c    c    c    0    0    0  LSP  LSU    1  LSW  LSL    rn   rn   rn   rn  rd   rd   rd   rd   i81  i81  i81  i81   1    0    1    1   i82  i82  i82  i82  ))
(setq insn_ld3    '( c    c    c    c    0    0    0  LSP  LSU    0  LSW    0    rn   rn   rn   rn  rd   rd   rd   rd   i81  i81  i81  i81   1    1    S    1   i82  i82  i82  i82  ))
(setq insn_ld4    '( c    c    c    c    0    0    0  LSP  LSU    0  LSW    1    rn   rn   rn   rn  rd   rd   rd   rd   i81  i81  i81  i81   1    1    H    1   i82  i82  i82  i82  ))
(setq insn_ld5    '( c    c    c    c    0    0    0  LSP  LSU    1  LSW    0    rn   rn   rn   rn  rd   rd   rd   rd   i81  i81  i81  i81   1    1    S    1   i82  i82  i82  i82  ))
(setq insn_ld6    '( c    c    c    c    0    0    0  LSP  LSU    1  LSW    1    rn   rn   rn   rn  rd   rd   rd   rd   i81  i81  i81  i81   1    1    H    1   i82  i82  i82  i82  ))
	     	       	    	      	   	     	       	    	      	   	     						    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    					    						    					    						    					    					    
(setq insn_dp_i   '( c    c    c    c    0    0    1   op1  op1  op1  op1  dps  rn   rn   rn   rn   rd   rd   rd   rd   rot  rot  rot  rot  dpi  dpi  dpi  dpi  dpi  dpi  dpi  dpi ))
(setq insn_undef1 '( c    c    c    c    0    0    1    1    0   X2    0    0    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X  ))
(setq insn_misr   '( c    c    c    c    0    0    1    1    0    R    1    0   MSK  MSK  MSK  MSK  SBQ  SBQ  SBQ  SBQ  rot  rot  rot  rot  dpi  dpi  dpi  dpi  dpi  dpi  dpi  dpi ))
(setq insn_lsio   '( c    c    c    c    0    1    0   LSP  LSU  LSB  LSW  LSL  rn   rn   rn   rn   rd   rd   rd   rd   LSI  LSI  LSI  LSI  LSI  LSI  LSI  LSI  LSI  LSI  LSI  LSI ))
(setq insn_lsro   '( c    c    c    c    0    1    1   LSP  LSU  LSB  LSW  LSL  rn   rn   rn   rn   rd   rd   rd   rd   sha  sha  sha  sha  sha  sh   sh    0   rm   rm   rm   rm  ))
(setq insn_undef2 '( c    c    c    c    0    1    1    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    1    X2   X2   X2   X2  ))
(setq insn_undef3 '( 1    1    1    1    0    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X  ))
(setq insn_lsm    '( c    c    c    c    0    1    1   LSP  LSU  LMS  LSW  LSL  rn   rn   rn   rn   rgl  rgl  rgl  rgl  rgl  rgl  rgl  rgl  rgl  rgl  rgl  rgl  rgl  rgl  rgl  rgl ))
(setq insn_undef4 '( 1    1    1    1    1    0    0    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X  ))
(setq insn_bwl    '( c    c    c    c    1    0    1   BLL  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo))
(setq insn_bwlth  '( 1    1    1    1    1    0    1   BLH  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo  blo))
		       	   	      	       	    	       	    	      	   	     	       	    	      	   	     	       	    	      	   	     						    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    					    						    					    						    					    					    
(setq insn_cpldst '( c    c    c    c    1    1    0   LSP  LSU  Cp_N  LSW LSL rn   rn   rn   rn   crd  crd  crd  crd  cpn  cpn  cpn  cpn  of8  of8  of8  of8  of8  of8  of8  of8 ))
(setq insn_cpdp   '( c    c    c    c    1    1    0    0   co1  co1  co1  co1  crn  crn  crn  crn   rd   rd   rd   rd  cpn  cpn  cpn  cpn  cp1  cp1  cp1   0   crm  crm  crm  crm ))
(setq insn_cpr    '( c    c    c    c    1    1    0    0   co1  co1  co1  LSL  crn  crn  crn  crn   rd   rd   rd   rd  cpn  cpn  cpn  cpn  cp1  cp1  cp1   1   crm  crm  crm  crm ))
		       	   	      	       	    	       	    	      	   	     	       	    	      	   	     	       	    	      	   	     						    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    						    					    					    						    					    					    						    					    					    						    					    						    					    					    
(setq insn_swi    '( c    c    c    c    1    1    1    1    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X ))
(setq insn_undef  '( 1    1    1    1    1    1    1    1    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X    X ))


(setq insn '(
  insn_dp_i_s insn_msr insn_mrs insn_bex insn_clz insn_blx insn_dsa 
  insn_brk insn_dsm insn_dp_r_s insn_mula insn_mull insn_swp insn_ld1
  insn_ld2 insn_ld3 insn_ld4 insn_ld5 insn_ld6 insn_dp_i insn_undef1 
  insn_misr insn_lsio insn_lsro insn_undef2 insn_undef3 insn_lsm insn_undef4 
  insn_bwl insn_bwlth insn_cpldst insn_cpdp insn_cpr insn_swi insn_undef
 ))

(setq h (create-decoder-setenc (or-insn-set insn) insn 0))
;(insert (print-decoder h 0))
(insert (print-decoder-c-pre h))
(insert (print-decoder-c-structs insn insn-help))
;(insert (print-decoder-vhd-pre h))

)





