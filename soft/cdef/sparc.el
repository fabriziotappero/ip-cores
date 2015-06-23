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

(setq insn-help '((rd "Destination register")
		  (rs1 "Source register 1")
		  (a  "Alternate space '1'=alternate space")
		  (ls "Load/Store '1'=Store")
		  (cc "Modify icc '1'=modify")
		  (xx "Use carry '1'=use")
		  (sa "Sub/Add '1'=Sub")
		  (n "Not '1'=not")
		  (sig "Signed '1'=Signed")
		  (d30 "Offset 30bit")
		  (i22 "Immidiate 22")
		  (c "Condition code")
		  (i "Select s2i '1'=sim13")
		  (s2i "op2: simm13 or rs2")

		  (insn_ldsb "Load|Store signed byte")
		  (insn_ldsh "Load|Store signed halfword")
		  (insn_ldst_ub "Load|Store unsigned byte")
		  (insn_ldst_uh "Load|Store unsigned halfword")
		  (insn_ldst "Load|Store word")
		  (insn_ldst_d "Load|Store doubleword")

		  (insn_ldst_f "Load|Sore floating point register")
		  (insn_ldst_df "Load|Sore double floating point register")
		  (insn_ldst_fsr "Load|Sore floating point state register")
		  (insn_stdfq "Store floating point deferred trap queue")    

		  (insn_ldst_c "Load|Sore coprocessor register")
		  (insn_ldst_dc "Load|Sore double coprocessor register")
		  (insn_ldst_csr "Load|Sore double coprocessor state register")
		  (insn_stdcq "Store coprocessor deferred trap queue")    

		  (insn_ldstb "Atomic Load-Store unsigned byte")
		  (insn_swp "Swap register into memory")

		  (insn_sethi "Set upper 22 bits")
		  (insn_nop "No op")

		  (insn_and "logical and")
		  (insn_or "logical or")
		  (insn_xor "logical xor")

		  (insn_sll "shieft left logical")
		  (insn_srl "shieft right logical")      
		  (insn_sra "shieft right arith")

		  (insn_sadd "Sub|Add")
		  (insn_tsadd "Tagged Sub|Add")
		  (insn_tsaddtv "Tagged Sub|Add with trap on overflow") 

		  (insn_mulscc "Multiply")
		  (insn_divscc "Divide")

		  (insn_sv "Save")
		  (insn_rest "Restore")
		  
		  (insn_bra "Branch on condition")
		  (insn_fbra "Branch on floating point condition")
		  (insn_cbra "Branch on coprocessor condition")    

		  (insn_jmp "Call and link offset")
		  (insn_jml "Jump and link")
		  (insn_ret "Return from trap")     
		  (insn_trap "Trap on condition code")    

		  (insn_rd "Read state registers")
		  (insn_rdp "Read processor state register (rdpsr)")     
		  (insn_rdw "Read windows invalid mask")      
		  (insn_rdt "Read trap base register")      

		  (insn_wd "Write state registers")
		  (insn_wdp "Write processor state register (rdpsr)")
		  (insn_wdw "Write windows invalid mask")
		  (insn_wdt "Write trap base register")

		  (insn_stbar "Store barrier")

		  (insn_unimp "Unimplemented")

		 )
)







;;      list order     0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31
;;                    31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  09  08  07  06  05  04  03  02  01  00
(setq insn_ldsb     '( 1   1  rd  rd  rd  rd  rd   0   a   1   0   0   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))
(setq insn_ldsh     '( 1   1  rd  rd  rd  rd  rd   0   a   1   0   1   0  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))
(setq insn_ldst_ub  '( 1   1  rd  rd  rd  rd  rd   0   a   0   ls  0   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))
(setq insn_ldst_uh  '( 1   1  rd  rd  rd  rd  rd   0   a   0   ls  1   0  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))
(setq insn_ldst     '( 1   1  rd  rd  rd  rd  rd   0   a   0   ls  0   0  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))
(setq insn_ldst_d   '( 1   1  rd  rd  rd  rd  rd   0   a   0   ls  1   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))

(setq insn_ldst_f   '( 1   1  rd  rd  rd  rd  rd   1   0   0   ls  0   0  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))
(setq insn_ldst_df  '( 1   1  rd  rd  rd  rd  rd   1   0   0   ls  1   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))
(setq insn_ldst_fsr '( 1   1  rd  rd  rd  rd  rd   1   0   0   ls  0   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))
(setq insn_stdfq    '( 1   1  rd  rd  rd  rd  rd   1   0   0   1   1   0  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))

(setq insn_ldst_c   '( 1   1  rd  rd  rd  rd  rd   1   1   0   ls  0   0  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))
(setq insn_ldst_dc  '( 1   1  rd  rd  rd  rd  rd   1   1   0   ls  1   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))
(setq insn_ldst_csr '( 1   1  rd  rd  rd  rd  rd   1   1   0   ls  0   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))
(setq insn_stdcq    '( 1   1  rd  rd  rd  rd  rd   1   1   0   1   1   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))

(setq insn_ldstb    '( 1   1  rd  rd  rd  rd  rd   0   a   1   1   0   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))
(setq insn_swp      '( 1   1  rd  rd  rd  rd  rd   0   a   1   1   1   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i ))

(setq insn_sethi    '( 0   0  rd  rd  rd  rd  rd   1   0   0  i22 i22 i22 i22 i22 i22 i22 i22 i22 i22 i22 i22 i22 i22 i22 i22 i22 i22 i22 i22 i22 i22  ))
(setq insn_nop      '( 0   0  0   0   0   0   0    1   0   0   x   x   x   x   x   x   x   x   x   x   x   x   x   x   x   x   x   x   x   x   x   x    ))

(setq insn_and      '( 1   0  rd  rd  rd  rd  rd   0  cc   0   n   0   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))
(setq insn_or       '( 1   0  rd  rd  rd  rd  rd   0  cc   0   n   1   0  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))
(setq insn_xor      '( 1   0  rd  rd  rd  rd  rd   0  cc   0   n   1   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))

(setq insn_sll      '( 1   0  rd  rd  rd  rd  rd   1   0   0   1   0   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))
(setq insn_srl      '( 1   0  rd  rd  rd  rd  rd   1   0   0   1   1   0  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))
(setq insn_sra      '( 1   0  rd  rd  rd  rd  rd   1   0   0   1   1   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))

(setq insn_sadd     '( 1   0  rd  rd  rd  rd  rd   0  cc  xx  sa   0   0  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))
(setq insn_tsadd    '( 1   0  rd  rd  rd  rd  rd   1   0   0   0   0  sa  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))
(setq insn_tsaddtv  '( 1   0  rd  rd  rd  rd  rd   1   0   0   0   1  sa  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))

(setq insn_mulscc   '( 1   0  rd  rd  rd  rd  rd   0  cc   1   0   1  sig  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))
(setq insn_divscc   '( 1   0  rd  rd  rd  rd  rd   0  cc   1   1   1  sig  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))

(setq insn_sv       '( 1   0  rd  rd  rd  rd  rd   1   1   1   1   0   0  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))
(setq insn_rest     '( 1   0  rd  rd  rd  rd  rd   1   1   1   1   0   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))

(setq insn_bra      '( 0   0   a   c   c   c   c   0   1   0  d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22  ))
(setq insn_fbra     '( 0   0   a   c   c   c   c   1   1   0  d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22  ))
(setq insn_cbra     '( 0   0   a   c   c   c   c   1   1   1  d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22 d22  ))

(setq insn_jmp      '( 0   1  d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 d30 ))
(setq insn_jml      '( 1   0  rd  rd  rd  rd  rd   1   1   1   0   0   0  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))
(setq insn_ret      '( 1   0  rd  rd  rd  rd  rd   1   1   1   0   0   1  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))
(setq insn_trap     '( 1   0  rvd  c   c   c   c   1   1   1   0   1   0  rs1 rs1 rs1 rs1 rs1  i  s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i s2i  ))

(setq insn_rd       '( 1   0  rd  rd  rd  rd  rd   1   0   1   0   0   0  rs1 rs1 rs1 rs1 rs1  x   x   x   x   x   x   x   x   x   x   x   x   x   x   ))
(setq insn_rdp      '( 1   0  rd  rd  rd  rd  rd   1   0   1   0   0   1  rs1 rs1 rs1 rs1 rs1  x   x   x   x   x   x   x   x   x   x   x   x   x   x   ))
(setq insn_rdw      '( 1   0  rd  rd  rd  rd  rd   1   0   1   0   1   0  rs1 rs1 rs1 rs1 rs1  x   x   x   x   x   x   x   x   x   x   x   x   x   x   ))
(setq insn_rdt      '( 1   0  rd  rd  rd  rd  rd   1   0   1   0   1   1  rs1 rs1 rs1 rs1 rs1  x   x   x   x   x   x   x   x   x   x   x   x   x   x   ))

(setq insn_wd       '( 1   0  rd  rd  rd  rd  rd   1   1   0   0   0   0  rs1 rs1 rs1 rs1 rs1  x   x   x   x   x   x   x   x   x   x   x   x   x   x   ))
(setq insn_wdp      '( 1   0  rd  rd  rd  rd  rd   1   1   0   0   0   1  rs1 rs1 rs1 rs1 rs1  x   x   x   x   x   x   x   x   x   x   x   x   x   x   ))
(setq insn_wdw      '( 1   0  rd  rd  rd  rd  rd   1   1   0   0   1   0  rs1 rs1 rs1 rs1 rs1  x   x   x   x   x   x   x   x   x   x   x   x   x   x   ))
(setq insn_wdt      '( 1   0  rd  rd  rd  rd  rd   1   1   0   0   1   1  rs1 rs1 rs1 rs1 rs1  x   x   x   x   x   x   x   x   x   x   x   x   x   x   ))

(setq insn_stbar    '( 1   0   0   0   0   0   0   1   0   1   0   0   0   0   1   1   1   1   0   x   x   x   x   x   x   x   x   x   x   x   x   x   ))

(setq insn_unimp    '( 0   0  rvd rvd rvd rvd rvd  0   0   0  cst cst cst cst cst cst cst cst cst cst cst cst cst cst cst cst cst cst cst cst cst cst  ))

(setq insn '(
  insn_ldsb  insn_ldsh  insn_ldst_ub  insn_ldst_uh 
  insn_ldst  insn_ldst_d  insn_ldst_f  insn_ldst_df   
  insn_ldst_fsr  insn_stdfq  insn_ldst_c  insn_ldst_dc  
  insn_ldst_csr  insn_stdcq  insn_ldstb  insn_swp       
  insn_sethi  insn_nop  insn_and  insn_or  insn_xor       
  insn_sll  insn_srl  insn_sra  insn_sadd  insn_tsadd     
  insn_tsaddtv insn_mulscc insn_divscc insn_sv
  insn_rest insn_bra insn_fbra insn_cbra insn_jmp
  insn_jml insn_ret insn_trap
  insn_rd insn_rdp insn_rdw insn_rdt insn_wd insn_wdp   
  insn_wdw insn_wdt insn_stbar insn_unimp
 ))

(setq h (create-decoder-setenc (or-insn-set insn) insn 0))
;(insert (print-decoder h 0))
;(insert (print-decoder-c-pre h))
;(insert (print-decoder-c-structs insn insn-help))
(insert (print-decoder-vhd-pre h))

)

