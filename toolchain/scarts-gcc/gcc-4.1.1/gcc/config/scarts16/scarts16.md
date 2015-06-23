;; -*- Mode: Scheme -*-
;;   Machine description for GNU compiler,
;;   for SCARTS16 micro controllers.
;;   Copyright (C) 1998, 1999, 2000, 2001, 2002, 2004, 2005 Free Software Foundation, Inc.
;;   Contributed by Wolfgang Puffitsch <hausen@gmx.at>

;;   This file is part of the SCARTS16 port of GCC

;; GNU CC is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU CC is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU CC; see the file COPYING.  If not, write to
;; the Free Software Foundation, 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;; Special characters after '%':
;;  A  No effect (add 0).
;;  B  Add 1 to REG number, MEM address or CONST_INT.
;;  C  Add 2.
;;  D  Add 3.

;; The size of instructions in bytes.
(define_attr "length" "" (const_int 1))

;; Register numbers.
(define_constants
  [(RET_REGNO 0)
   (ARG0_REGNO 1)
   (ARG1_REGNO 2)
   (ARG2_REGNO 3)
   (ARG3_REGNO 4)
   (TMP_REGNO 13)
   (RA_REGNO 14)
   (CC_REGNO 20)])

;; Possible conditions
(define_code_macro any_cond [eq ne gt gtu lt ltu ge geu le leu])
(define_code_macro straight_cond [eq gt gtu lt ltu])
(define_code_macro inverted_cond [ne le leu ge geu])

;; **************************************************************************
;; calls

(define_expand "call"
  [(parallel [(call (match_operand:HI 0 "call_insn_operand" "")
		    (match_operand:HI 1 "general_operand" ""))
	      (clobber (reg:HI RA_REGNO))])]
  ""
  "{
     if (GET_CODE (operands[0]) == MEM
         && !register_operand (XEXP (operands[0], 0), HImode))
       operands[0] = gen_rtx_MEM (GET_MODE (operands[0]),
	                	  force_reg (HImode, XEXP (operands[0], 0)));
}")

(define_expand "call_value"
  [(parallel [(set (match_operand 0 "register_operand" "")
		   (call (match_operand:HI 1 "call_insn_operand" "")
			 (match_operand:HI 2 "general_operand" "")))
	      (clobber (reg:HI RA_REGNO))])]
  ""
  "{
     if (GET_CODE (operands[1]) == MEM
         && !register_operand (XEXP (operands[1], 0), HImode))
       operands[1] = gen_rtx_MEM (GET_MODE (operands[1]),
	                	  force_reg (HImode, XEXP (operands[1], 0)));
}")

(define_insn "call_insn"
   [(call (mem:HI (match_operand:HI 0 "register_operand" "r"))
	  (match_operand:HI 1 "general_operand" "X"))
    (clobber (reg:HI RA_REGNO))]
  ""
  "jsr %0"
  [(set_attr "length" "1")])

(define_insn "call_insn<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (parallel [(call (mem:HI (match_operand:HI 0 "register_operand" "r"))
		     (match_operand:HI 1 "general_operand" "X"))
	       (clobber (reg:HI RA_REGNO))]))]
  ""
  "jsr_ct %0"
  [(set_attr "length" "1")])

(define_insn "call_insn<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (parallel [(call (mem:HI (match_operand:HI 0 "register_operand" "r"))
		     (match_operand:HI 1 "general_operand" "X"))
	       (clobber (reg:HI RA_REGNO))]))]
  ""
  "jsr_cf %0"
  [(set_attr "length" "1")])

(define_insn "call_value_insn"
  [(set (match_operand 0 "register_operand" "=r")
        (call (mem:HI (match_operand:HI 1 "register_operand" "r"))
              (match_operand:HI 2 "general_operand" "X")))
   (clobber (reg:HI RA_REGNO))]
  ""
  "jsr %1"
  [(set_attr "length" "1")])

(define_insn "call_value_insn<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (parallel [(set (match_operand 0 "register_operand" "=r")
		    (call (mem:HI (match_operand:HI 1 "register_operand" "r"))
			  (match_operand:HI 2 "general_operand" "X")))
	       (clobber (reg:HI RA_REGNO))]))]
  ""
  "jsr_ct %1"
  [(set_attr "length" "1")])

(define_insn "call_value_insn<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (parallel [(set (match_operand 0 "register_operand" "=r")
		    (call (mem:HI (match_operand:HI 1 "register_operand" "r"))
			  (match_operand:HI 2 "general_operand" "X")))
	       (clobber (reg:HI RA_REGNO))]))]
  ""
  "jsr_cf %1"
  [(set_attr "length" "1")])

;; return

(define_insn "return"
  [(return)]
  "reload_completed && scarts16_simple_epilogue ()"
  "rts"
  [(set_attr "length" "1")])

;;==========================================================================
;; push

(define_insn "pushqi2"
  [(set (mem:QI (pre_modify:HI (match_operand:HI 0 "register_operand" "+q")
			       (plus:HI (match_dup 0) (const_int -2))))
	(match_operand:QI 1 "register_operand" "r"))]
  ""
  "st%0_dec %1,-1"
  [(set_attr "length" "1")])

(define_insn "pushhi2"
  [(set (mem:HI (pre_dec:HI (match_operand:HI 0 "register_operand" "+q")))
	(match_operand:HI 1 "register_operand" "r"))]
  ""
  "st%0_dec %1,-1"
  [(set_attr "length" "1")])

(define_insn "pushsi2"
  [(set (mem:SI (pre_dec:HI (match_operand:HI 0 "register_operand" "+q")))
	(match_operand:SI 1 "register_operand" "r"))]
  ""
  "st%0_dec %B1,-1\;st%0_dec %A1,-1"
  [(set_attr "length" "2")])

(define_insn "pushdi2"
  [(set (mem:DI (pre_dec:HI (match_operand:HI 0 "register_operand" "+q")))
	(match_operand:DI 1 "register_operand" "r"))]
  ""
  "st%0_dec %D1,-1\;st%0_dec %C1,-1\;st%0_dec %B1,-1\;st%0_dec %A1,-1"
  [(set_attr "length" "4")])

;; =========================================================================
;; postdec

(define_insn "st_postdechi2"
  [(set (mem:HI (post_dec:HI (match_operand:HI 0 "register_operand" "+q")))
	(match_operand:HI 1 "register_operand" "r"))]
   ""
   "st%0_dec %1,0"
   [(set_attr "length" "1")])

(define_insn "st_postdecsi2"
  [(set (mem:SI (post_dec:HI (match_operand:HI 0 "register_operand" "+q")))
	(match_operand:SI 1 "register_operand" "r"))]
   ""
   "st%0_dec %B1,1\;st%0_dec %A1,1"
   [(set_attr "length" "2")])

(define_insn "st_postdecdi2"
  [(set (mem:DI (post_dec:HI (match_operand:HI 0 "register_operand" "+q")))
	(match_operand:DI 1 "register_operand" "r"))]
   ""
   "st%0_dec %D1,3\;st%0_dec %C1,3\;st%0_dec %B1,3\;st%0_dec %A1,3"
   [(set_attr "length" "4")])

(define_insn "ld_postdechi2"
  [(set (match_operand:HI 1 "register_operand" "=r")
	(mem:HI (post_dec:HI (match_operand:HI 0 "register_operand" "+q"))))]
   ""
   "ld%0_dec %1,0"
   [(set_attr "length" "1")])

(define_insn "ld_postdecsi2"
  [(set (match_operand:SI 1 "register_operand" "=r")
	(mem:SI (post_dec:HI (match_operand:HI 0 "register_operand" "+q"))))]
   ""
   "ld%0_dec %B1,1\;ld%0_dec %A1,1"
   [(set_attr "length" "2")])

(define_insn "ld_postdecdi2"
  [(set (match_operand:DI 1 "register_operand" "=r")
	(mem:DI (post_dec:HI (match_operand:HI 0 "register_operand" "+q"))))]
   ""
   "ld%0_dec %D1,3\;ld%0_dec %C1,3\;ld%0_dec %B1,3\;ld%0_dec %A1,3"
   [(set_attr "length" "4")])

;; =========================================================================
;; postinc

(define_insn "st_postinchi2"
  [(set (mem:HI (post_inc:HI (match_operand:HI 0 "register_operand" "+q")))
	(match_operand:HI 1 "register_operand" "r"))]
   ""
   "st%0_inc %1,0"
   [(set_attr "length" "1")])

(define_insn "st_postincsi2"
  [(set (mem:SI (post_inc:HI (match_operand:HI 0 "register_operand" "+q")))
	(match_operand:SI 1 "register_operand" "r"))]
   ""
   "st%0_inc %A1,0\;st%0_inc %B1,0"
   [(set_attr "length" "2")])

(define_insn "st_postincdi2"
  [(set (mem:DI (post_inc:HI (match_operand:HI 0 "register_operand" "+q")))
	(match_operand:DI 1 "register_operand" "r"))]
   ""
   "st%0_inc %A1,0\;st%0_inc %B1,0\;st%0_inc %C1,0\;st%0_inc %D1,0"
   [(set_attr "length" "4")])

(define_insn "ld_postinchi2"
  [(set (match_operand:HI 1 "register_operand" "=r")
	(mem:HI (post_inc:HI (match_operand:HI 0 "register_operand" "+q"))))]
   ""
   "ld%0_inc %1,0"
   [(set_attr "length" "1")])

(define_insn "ld_postincsi2"
  [(set (match_operand:SI 1 "register_operand" "=r")
	(mem:SI (post_inc:HI (match_operand:HI 0 "register_operand" "+q"))))]
   ""
   "ld%0_inc %A1,0\;ld%0_inc %B1,0"
   [(set_attr "length" "2")])

(define_insn "ld_postincdi2"
  [(set (match_operand:DI 1 "register_operand" "=r")
	(mem:DI (post_inc:HI (match_operand:HI 0 "register_operand" "+q"))))]
   ""
   "ld%0_inc %A1,0\;ld%0_inc %B1,0\;ld%0_inc %C1,0\;ld%0_inc %D1,0"
   [(set_attr "length" "4")])

;;==========================================================================
;; move byte (8 bit)

(define_expand "movqi"
  [(set (match_operand:QI 0 "nonimmediate_operand" "")
        (match_operand:QI 1 "general_operand"  ""))]
  ""
  "{
 /* One of the ops has to be in a register.  */
 if (!register_operand (operand0, QImode)
     && !(register_operand (operand1, QImode)))
   {
     operands[1] = copy_to_mode_reg (QImode, operand1);
   }
}
  ")

(define_insn "*movqi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:QI 0 "register_operand"    "=r")
	 (match_operand:QI 1 "register_operand"     "r")))]
  ""
  "mov_ct %0,%1"
  [(set_attr "length" "1")])

(define_insn "*movqi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:QI 0 "register_operand"    "=r")
	 (match_operand:QI 1 "register_operand"     "r")))]
  ""
  "mov_cf %0,%1"
  [(set_attr "length" "1")])

(define_insn "*movqi"
  [(set (match_operand:QI 0 "nonimmediate_operand"   "=r,r,m,r")
        (match_operand:QI 1 "general_operand"         "r,L,r,m"))]
  ""
  "* return scarts16_out_movqi (insn, operands, which_alternative);"
  [(set_attr "length" "1,1,3,3")])

;;==========================================================================
;; move word (16 bit)

(define_expand "movhi"
  [(set (match_operand:HI 0 "nonimmediate_operand" "")
        (match_operand:HI 1 "general_operand"  ""))]
  ""
  "{
 /* One of the ops has to be in a register.  */
 if (!register_operand (operand0, HImode)
     && !(register_operand (operand1, HImode)))
   {
     operands[1] = copy_to_mode_reg (HImode, operand1);
   }
}
  ")

(define_insn "*ld_qihi2"
  [(set (match_operand:HI 0 "register_operand" "=r")
	(sign_extend:HI
	 (mem:QI (match_operand:HI 1 "register_operand" "r"))))]
  ""
  "ldb %0,%1"
  [(set_attr "length" "1")])

(define_insn "*ldu_qihi2"
  [(set (match_operand:HI 0 "register_operand" "=r")
	(zero_extend:HI
	 (mem:QI (match_operand:HI 1 "register_operand" "r"))))]
  ""
  "ldbu %0,%1"
  [(set_attr "length" "1")])

(define_insn "*movhi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"    "=r")
	 (match_operand:HI 1 "register_operand"     "r")))]
  ""
  "mov_ct %0,%1"
  [(set_attr "length" "1")])

(define_insn "*movhi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"    "=r")
	 (match_operand:HI 1 "register_operand"     "r")))]
  ""
  "mov_cf %0,%1"
  [(set_attr "length" "1")])

(define_insn "*movhi"
  [(set (match_operand:HI 0 "nonimmediate_operand"   "=r,r,r,r, m,rq,rq")
        (match_operand:HI 1 "general_operand"         "r,L,n,s,rq, m,rq"))]
  ""
  "* return scarts16_out_movhi (insn, operands, which_alternative);"
  [(set_attr "length" "1,1,2,2,5,5,6")])

;;==========================================================================
;; move double-word (32 bit)

(define_expand "movsi"
  [(set (match_operand:SI 0 "nonimmediate_operand" "")
        (match_operand:SI 1 "general_operand"  ""))]
  ""
  "{
 /* One of the ops has to be in a register.  */
 if (!register_operand (operand0, SImode)
     && !register_operand (operand1, SImode))
   {
     operands[1] = copy_to_mode_reg (SImode, operand1);
   }
}
  ")

(define_insn "*movsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"    "=r")
	 (match_operand:SI 1 "register_operand"     "r")))]
  ""
  "* {
      if (true_regnum(operands[0]) < true_regnum(operands[1]))
	{  
	  output_asm_insn (\"mov_ct %A0,%A1\", operands);
	  output_asm_insn (\"mov_ct %B0,%B1\", operands);
	}
      else
	{
	  output_asm_insn (\"mov_ct %B0,%B1\", operands);
	  output_asm_insn (\"mov_ct %A0,%A1\", operands);
	}
     return \"\";
}"
  [(set_attr "length" "2")])

(define_insn "*movsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"    "=r")
	 (match_operand:SI 1 "register_operand"     "r")))]
  ""
  "* {
      if (true_regnum(operands[0]) < true_regnum(operands[1]))
	{  
	  output_asm_insn (\"mov_cf %A0,%A1\", operands);
	  output_asm_insn (\"mov_cf %B0,%B1\", operands);
	}
      else
	{
	  output_asm_insn (\"mov_cf %B0,%B1\", operands);
	  output_asm_insn (\"mov_cf %A0,%A1\", operands);
	}
     return \"\";
}"
  [(set_attr "length" "2")])

(define_insn "*movsi"
  [(set (match_operand:SI 0 "nonimmediate_operand"    "=r,r,r,m,r")
        (match_operand:SI 1 "general_operand"          "r,L,n,r,m"))]
  ""
  "* return scarts16_out_movsi (insn, operands, which_alternative);"
  [(set_attr "length" "2,2,4,4,4")])

;;==========================================================================
;; move quad-word (64 bit)

(define_expand "movdi"
  [(set (match_operand:DI 0 "nonimmediate_operand" "")
        (match_operand:DI 1 "general_operand"  ""))]
  ""
  "{
 /* One of the ops has to be in a register.  */
 if (!register_operand (operand0, DImode)
     && !(register_operand (operand1, DImode)))
   {
     operands[1] = copy_to_mode_reg (DImode, operand1);
   }
}
  ")

(define_insn "*movdi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"    "=r")
	 (match_operand:DI 1 "register_operand"     "r")))]
  ""
  "* {
      if (true_regnum(operands[0]) < true_regnum(operands[1]))
	{  
	  output_asm_insn (\"mov_ct %A0,%A1\", operands);
	  output_asm_insn (\"mov_ct %B0,%B1\", operands);
	  output_asm_insn (\"mov_ct %C0,%C1\", operands);
	  output_asm_insn (\"mov_ct %D0,%D1\", operands);
	}
      else
	{
	  output_asm_insn (\"mov_ct %D0,%D1\", operands);
	  output_asm_insn (\"mov_ct %C0,%C1\", operands);
	  output_asm_insn (\"mov_ct %B0,%B1\", operands);
	  output_asm_insn (\"mov_ct %A0,%A1\", operands);
	}
     return \"\";
}"
  [(set_attr "length" "2")])

(define_insn "*movdi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"    "=r")
	 (match_operand:DI 1 "register_operand"     "r")))]
  ""
  "* {
      if (true_regnum(operands[0]) < true_regnum(operands[1]))
	{  
	  output_asm_insn (\"mov_ct %A0,%A1\", operands);
	  output_asm_insn (\"mov_ct %B0,%B1\", operands);
	  output_asm_insn (\"mov_cf %C0,%C1\", operands);
	  output_asm_insn (\"mov_cf %D0,%D1\", operands);
	}
      else
	{
	  output_asm_insn (\"mov_cf %D0,%D1\", operands);
	  output_asm_insn (\"mov_cf %C0,%C1\", operands);
	  output_asm_insn (\"mov_ct %B0,%B1\", operands);
	  output_asm_insn (\"mov_ct %A0,%A1\", operands);
	}
     return \"\";
}"
  [(set_attr "length" "2")])

(define_insn "*movdi"
  [(set (match_operand:DI 0 "nonimmediate_operand"    "=r,r,r,m,r")
        (match_operand:DI 1 "general_operand"          "r,L,n,r,m"))]
  ""
  "* return scarts16_out_movdi (insn, operands, which_alternative);"
  [(set_attr "length" "4,4,8,5,5")])

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; add bytes

(define_insn "addhi3"
  [(set (match_operand:HI 0 "register_operand"            "=r,r")
        (plus:HI (match_operand:HI 1 "register_operand"   "%0,0")
                 (match_operand:HI 2 "nonmemory_operand"  "rq,O")))]
  ""
  "* return scarts16_out_addhi (insn, operands, which_alternative);"
  [(set_attr "length" "3,1")])

(define_insn "addhi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"          "=r,r")
	 (plus:HI (match_operand:HI 1 "register_operand" "%0,0")
		  (match_operand:HI 2 "nonmemory_operand" "r,O"))))]
  ""
  "@
     add_ct %0,%2
     addi_ct %0,%2"
  [(set_attr "length" "1,1")])

(define_insn "addhi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"          "=r,r")
	 (plus:HI (match_operand:HI 1 "register_operand" "%0,0")
		  (match_operand:HI 2 "nonmemory_operand" "r,O"))))]
  ""
  "@
     add_cf %0,%2
     addi_cf %0,%2"
  [(set_attr "length" "1,1")])

(define_insn "addsi3"
  [(set (match_operand:SI 0 "register_operand"          "=&r")
        (plus:SI (match_operand:SI 1 "register_operand"  "%0")
                 (match_operand:SI 2 "register_operand"   "r")))]
  ""
  "add %A0,%A2\;addc %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "addsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"         "=&r")
	 (plus:SI (match_operand:SI 1 "register_operand" "%0")
		  (match_operand:SI 2 "register_operand"  "r"))))]
  ""
  "add_ct %A0,%A2\;addc_ct %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "addsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"         "=&r")
	 (plus:SI (match_operand:SI 1 "register_operand" "%0")
		  (match_operand:SI 2 "register_operand"  "r"))))]
  ""
  "add_cf %A0,%A2\;addc_cf %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "adddi3"
  [(set (match_operand:DI 0 "register_operand"          "=&r")
        (plus:DI (match_operand:DI 1 "register_operand"  "%0")
                 (match_operand:DI 2 "register_operand"   "r")))]
  ""
  "add %A0,%A2\;addc %B0,%B2\;addc %C0,%C2\;addc %D0,%D2"
  [(set_attr "length" "4")])

(define_insn "adddi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (plus:DI (match_operand:DI 1 "register_operand" "%0")
		  (match_operand:DI 2 "register_operand"  "r"))))]
  ""
  "add_ct %A0,%A2\;addc_ct %B0,%B2\;addc_ct %C0,%C2\;addc_ct %D0,%D2"
  [(set_attr "length" "4")])

(define_insn "adddi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (plus:DI (match_operand:DI 1 "register_operand" "%0")
		  (match_operand:DI 2 "register_operand"  "r"))))]
  ""
  "add_cf %A0,%A2\;addc_cf %B0,%B2\;addc_cf %C0,%C2\;addc_cf %D0,%D2"
  [(set_attr "length" "4")])

;-----------------------------------------------------------------------------
; sub bytes

(define_insn "subhi3"
  [(set (match_operand:HI 0 "register_operand"           "=r")
        (minus:HI (match_operand:HI 1 "register_operand"  "0")
		  (match_operand:HI 2 "register_operand"  "r")))]
  ""
  "sub %0,%2"
  [(set_attr "length" "1")])

(define_insn "subhi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"           "=r")
	 (minus:HI (match_operand:HI 1 "register_operand"  "0")
		   (match_operand:HI 2 "register_operand"  "r"))))]
  ""
  "sub_ct %0,%2"
  [(set_attr "length" "1")])

(define_insn "subhi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"           "=r")
	 (minus:HI (match_operand:HI 1 "register_operand"  "0")
		   (match_operand:HI 2 "register_operand"  "r"))))]
  ""
  "sub_cf %0,%2"
  [(set_attr "length" "1")])

(define_insn "subsi3"
  [(set (match_operand:SI 0 "register_operand"           "=&r")
        (minus:SI (match_operand:SI 1 "register_operand"   "0")
		  (match_operand:SI 2 "register_operand"   "r")))]
  ""
  "sub %A0,%A2\;subc %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "subsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"          "=&r")
	 (minus:SI (match_operand:SI 1 "register_operand"  "0")
		   (match_operand:SI 2 "register_operand"  "r"))))]
  ""
  "sub_ct %A0,%A2\;subc_ct %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "subsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"          "=&r")
	 (minus:SI (match_operand:SI 1 "register_operand"  "0")
		   (match_operand:SI 2 "register_operand"  "r"))))]
  ""
  "sub_cf %A0,%A2\;subc_cf %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "subdi3"
  [(set (match_operand:DI 0 "register_operand"          "=&r")
        (minus:DI (match_operand:DI 1 "register_operand"  "0")
		  (match_operand:DI 2 "register_operand"  "r")))]
  ""
  "sub %A0,%A2\;subc %B0,%B2\;subc %C0,%C2\;subc %D0,%D2"
  [(set_attr "length" "4")])

(define_insn "subdi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (minus:DI (match_operand:DI 1 "register_operand" "0")
		   (match_operand:DI 2 "register_operand" "r"))))]
  ""
  "sub_ct %A0,%A2\;subc_ct %B0,%B2\;subc_ct %C0,%C2\;subc_ct %D0,%D2"
  [(set_attr "length" "4")])

(define_insn "subdi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (minus:DI (match_operand:DI 1 "register_operand" "0")
		   (match_operand:DI 2 "register_operand" "r"))))]
  ""
  "sub_cf %A0,%A2\;subc_cf %B0,%B2\;subc_cf %C0,%C2\;subc_cf %D0,%D2"
  [(set_attr "length" "4")])

;******************************************************************************
; mul

(define_expand "mulhi3"
  [(set (match_operand:HI 0 "register_operand" "")
	(mult:HI (match_operand:HI 1 "register_operand" "")
		 (match_operand:HI 2 "register_operand" "")))]
  ""
  "{
     operands[3] = force_reg (HImode, gen_rtx_SYMBOL_REF (HImode, \"__mulhi3\"));
     emit_insn (gen_mulhi3_call (operands[0], operands[1], operands[2], operands[3]));
     DONE;
}")

(define_expand "mulhi3_call"
  [(set (reg:HI ARG0_REGNO) (match_operand:HI 1 "register_operand" ""))
   (set (reg:HI ARG1_REGNO) (match_operand:HI 2 "register_operand" ""))
   (parallel [(set (reg:HI RET_REGNO)
		   (mult:HI (reg:HI ARG0_REGNO) (reg:HI ARG1_REGNO)))
	      (use (match_operand:HI 3 "register_operand" ""))
	      (use (reg:HI ARG0_REGNO))
	      (use (reg:HI ARG1_REGNO))
	      (clobber (reg:HI ARG0_REGNO))
	      (clobber (reg:HI ARG1_REGNO))
	      (clobber (reg:HI RA_REGNO))])
   (set (match_operand:HI 0 "register_operand" "") (reg:HI RET_REGNO))]
  ""
  "")

(define_insn "*mulhi3_call"
  [(set (reg:HI RET_REGNO)
	(mult:HI (reg:HI ARG0_REGNO) (reg:HI ARG1_REGNO)))
   (use (match_operand:HI 0 "register_operand" "r"))
   (use (reg:HI ARG0_REGNO))
   (use (reg:HI ARG1_REGNO))
   (clobber (reg:HI ARG0_REGNO))
   (clobber (reg:HI ARG1_REGNO))
   (clobber (reg:HI RA_REGNO))]
  ""
  "jsr %0"
  [(set_attr "length" "1")])

;//////////////////////////////////////////////////////////////////////////////
; div

(define_expand "divhi3"
  [(set (match_operand:HI 0 "register_operand" "")
	(div:HI (match_operand:HI 1 "register_operand" "")
		 (match_operand:HI 2 "register_operand" "")))]
  ""
  "{
     operands[3] = force_reg (HImode, gen_rtx_SYMBOL_REF (HImode, \"__divhi3\"));
     emit_insn (gen_divhi3_call (operands[0], operands[1], operands[2], operands[3]));
     DONE;
}")

(define_expand "divhi3_call"
  [(set (reg:HI ARG0_REGNO) (match_operand:HI 1 "register_operand" ""))
   (set (reg:HI ARG1_REGNO) (match_operand:HI 2 "register_operand" ""))
   (parallel [(set (reg:HI RET_REGNO)
		   (div:HI (reg:HI ARG0_REGNO) (reg:HI ARG1_REGNO)))
	      (use (match_operand:HI 3 "register_operand" ""))
	      (use (reg:HI ARG0_REGNO))
	      (use (reg:HI ARG1_REGNO))
	      (clobber (reg:HI ARG0_REGNO))
	      (clobber (reg:HI ARG1_REGNO))
	      (clobber (reg:HI ARG2_REGNO))
	      (clobber (reg:HI RA_REGNO))])
   (set (match_operand:HI 0 "register_operand" "") (reg:HI RET_REGNO))]
  ""
  "")

(define_insn "*divhi3_call"
  [(set (reg:HI RET_REGNO)
	(div:HI (reg:HI ARG0_REGNO) (reg:HI ARG1_REGNO)))
   (use (match_operand:HI 0 "register_operand" "r"))
   (use (reg:HI ARG0_REGNO))
   (use (reg:HI ARG1_REGNO))
   (clobber (reg:HI ARG0_REGNO))
   (clobber (reg:HI ARG1_REGNO))
   (clobber (reg:HI ARG2_REGNO))
   (clobber (reg:HI RA_REGNO))]
  ""
  "jsr %0"
  [(set_attr "length" "1")])

;//////////////////////////////////////////////////////////////////////////////
; udiv

(define_expand "udivhi3"
  [(set (match_operand:HI 0 "register_operand" "")
	(udiv:HI (match_operand:HI 1 "register_operand" "")
		 (match_operand:HI 2 "register_operand" "")))]
  ""
  "{
     operands[3] = force_reg (HImode, gen_rtx_SYMBOL_REF (HImode, \"__udivhi3\"));
     emit_insn (gen_udivhi3_call (operands[0], operands[1], operands[2], operands[3]));
     DONE;
}")

(define_expand "udivhi3_call"
  [(set (reg:HI ARG0_REGNO) (match_operand:HI 1 "register_operand" ""))
   (set (reg:HI ARG1_REGNO) (match_operand:HI 2 "register_operand" ""))
   (parallel [(set (reg:HI RET_REGNO)
		   (udiv:HI (reg:HI ARG0_REGNO) (reg:HI ARG1_REGNO)))
	      (use (match_operand:HI 3 "register_operand" ""))
	      (use (reg:HI ARG0_REGNO))
	      (use (reg:HI ARG1_REGNO))
	      (clobber (reg:HI ARG0_REGNO))
	      (clobber (reg:HI ARG1_REGNO))
	      (clobber (reg:HI RA_REGNO))])
   (set (match_operand:HI 0 "register_operand" "") (reg:HI RET_REGNO))]
  ""
  "")

(define_insn "*udivhi3_call"
  [(set (reg:HI RET_REGNO)
	(udiv:HI (reg:HI ARG0_REGNO) (reg:HI ARG1_REGNO)))
   (use (match_operand:HI 0 "register_operand" "r"))
   (use (reg:HI ARG0_REGNO))
   (use (reg:HI ARG1_REGNO))
   (clobber (reg:HI ARG0_REGNO))
   (clobber (reg:HI ARG1_REGNO))
   (clobber (reg:HI RA_REGNO))]
  ""
  "jsr %0"
  [(set_attr "length" "1")])

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; mod

(define_expand "modhi3"
  [(set (match_operand:HI 0 "register_operand" "")
	(mod:HI (match_operand:HI 1 "register_operand" "")
		 (match_operand:HI 2 "register_operand" "")))]
  ""
  "{
     operands[3] = force_reg (HImode, gen_rtx_SYMBOL_REF (HImode, \"__modhi3\"));
     emit_insn (gen_modhi3_call (operands[0], operands[1], operands[2], operands[3]));
     DONE;
}")

(define_expand "modhi3_call"
  [(set (reg:HI ARG0_REGNO) (match_operand:HI 1 "register_operand" ""))
   (set (reg:HI ARG1_REGNO) (match_operand:HI 2 "register_operand" ""))
   (parallel [(set (reg:HI RET_REGNO)
		   (mod:HI (reg:HI ARG0_REGNO) (reg:HI ARG1_REGNO)))
	      (use (match_operand:HI 3 "register_operand" ""))
	      (use (reg:HI ARG0_REGNO))
	      (use (reg:HI ARG1_REGNO))
	      (clobber (reg:HI ARG0_REGNO))
	      (clobber (reg:HI ARG1_REGNO))
	      (clobber (reg:HI ARG2_REGNO))
	      (clobber (reg:HI RA_REGNO))])
   (set (match_operand:HI 0 "register_operand" "") (reg:HI RET_REGNO))]
  ""
  "")

(define_insn "*modhi3_call"
  [(set (reg:HI RET_REGNO)
	(mod:HI (reg:HI ARG0_REGNO) (reg:HI ARG1_REGNO)))
   (use (match_operand:HI 0 "register_operand" "r"))
   (use (reg:HI ARG0_REGNO))
   (use (reg:HI ARG1_REGNO))
   (clobber (reg:HI ARG0_REGNO))
   (clobber (reg:HI ARG1_REGNO))
   (clobber (reg:HI ARG2_REGNO))
   (clobber (reg:HI RA_REGNO))]
  ""
  "jsr %0"
  [(set_attr "length" "1")])

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; umod

(define_expand "umodhi3"
  [(set (match_operand:HI 0 "register_operand" "")
	(umod:HI (match_operand:HI 1 "register_operand" "")
		 (match_operand:HI 2 "register_operand" "")))]
  ""
  "{
     operands[3] = force_reg (HImode, gen_rtx_SYMBOL_REF (HImode, \"__umodhi3\"));
     emit_insn (gen_umodhi3_call (operands[0], operands[1], operands[2], operands[3]));
     DONE;
}")

(define_expand "umodhi3_call"
  [(set (reg:HI ARG0_REGNO) (match_operand:HI 1 "register_operand" ""))
   (set (reg:HI ARG1_REGNO) (match_operand:HI 2 "register_operand" ""))
   (parallel [(set (reg:HI RET_REGNO)
		   (umod:HI (reg:HI ARG0_REGNO) (reg:HI ARG1_REGNO)))
	      (use (match_operand:HI 3 "register_operand" ""))
	      (use (reg:HI ARG0_REGNO))
	      (use (reg:HI ARG1_REGNO))
	      (clobber (reg:HI ARG0_REGNO))
	      (clobber (reg:HI ARG1_REGNO))
	      (clobber (reg:HI RA_REGNO))])
   (set (match_operand:HI 0 "register_operand" "") (reg:HI RET_REGNO))]
  ""
  "")

(define_insn "*umodhi3_call"
  [(set (reg:HI RET_REGNO)
	(umod:HI (reg:HI ARG0_REGNO) (reg:HI ARG1_REGNO)))
   (use (match_operand:HI 0 "register_operand" "r"))
   (use (reg:HI ARG0_REGNO))
   (use (reg:HI ARG1_REGNO))
   (clobber (reg:HI ARG0_REGNO))
   (clobber (reg:HI ARG1_REGNO))
   (clobber (reg:HI RA_REGNO))]
  ""
  "jsr %0"
  [(set_attr "length" "1")])

;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
; and

(define_insn "andhi3"
  [(set (match_operand:HI 0 "register_operand"          "=r,r")
        (and:HI (match_operand:HI 1 "register_operand"  "%0,0")
                (match_operand:HI 2 "nonmemory_operand"  "r,I")))]
  ""
  "*{
      switch (which_alternative)
        {
          case 0: output_asm_insn (\"and %0, %2\", operands);
            break;
          case 1: operands[2] = gen_rtx_CONST_INT (HImode, exact_log2(~INTVAL(operands[2])));
                  output_asm_insn (\"bclr %0, %2\", operands);
            break;
          default: gcc_unreachable();
        }
      return \"\";
}"
  [(set_attr "length" "1,1")])

(define_insn "andhi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"           "=r,r")
	 (and:HI (match_operand:HI 1 "register_operand"   "%0,0")
		  (match_operand:HI 2 "nonmemory_operand"  "r,I"))))]
  ""
  "*{
      switch (which_alternative)
        {
          case 0: output_asm_insn (\"and_ct %0, %2\", operands);
            break;
          case 1: operands[2] = gen_rtx_CONST_INT (HImode, exact_log2(~INTVAL(operands[2])));
                  output_asm_insn (\"bclr_ct %0, %2\", operands);
            break;
          default: gcc_unreachable();
        }
      return \"\";
}"
  [(set_attr "length" "1,1")])

(define_insn "andhi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"           "=r,r")
	 (and:HI (match_operand:HI 1 "register_operand"   "%0,0")
		  (match_operand:HI 2 "nonmemory_operand"  "r,I"))))]
  ""
  "*{
      switch (which_alternative)
        {
          case 0: output_asm_insn (\"and_cf %0, %2\", operands);
            break;
          case 1: operands[2] = gen_rtx_CONST_INT (HImode, exact_log2(~INTVAL(operands[2])));
                  output_asm_insn (\"bclr_cf %0, %2\", operands);
            break;
          default: gcc_unreachable();
        }
      return \"\";
}"
  [(set_attr "length" "1,1")])

(define_insn "andsi3"
  [(set (match_operand:SI 0 "register_operand"         "=&r")
        (and:SI (match_operand:SI 1 "register_operand"  "%0")
		(match_operand:SI 2 "register_operand"   "r")))]
  ""
  "and %A0,%A2\;and %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "andsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"         "=&r")
	 (and:SI (match_operand:SI 1 "register_operand"  "%0")
		  (match_operand:SI 2 "register_operand"  "r"))))]
  ""
  "and_ct %A0,%A2\;and_ct %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "andsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"         "=&r")
	 (and:SI (match_operand:SI 1 "register_operand"  "%0")
		  (match_operand:SI 2 "register_operand"  "r"))))]
  ""
  "and_cf %A0,%A2\;and_cf %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "anddi3"
  [(set (match_operand:DI 0 "register_operand"         "=&r")
        (and:DI (match_operand:DI 1 "register_operand"  "%0")
		(match_operand:DI 2 "register_operand"   "r")))]
  ""
  "and %A0,%A2\;and %B0,%B2\;and %C0,%C2\;and %D0,%D2"
  [(set_attr "length" "4")])

(define_insn "anddi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (and:DI (match_operand:DI 1 "register_operand"  "%0")
		  (match_operand:DI 2 "register_operand"  "r"))))]
  ""
  "and_ct %A0,%A2\;and_ct %B0,%B2\;and_ct %C0,%C2\;and_ct %D0,%D2"
  [(set_attr "length" "4")])

(define_insn "anddi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (and:DI (match_operand:DI 1 "register_operand"  "%0")
		  (match_operand:DI 2 "register_operand"  "r"))))]
  ""
  "and_cf %A0,%A2\;and_cf %B0,%B2\;and_cf %C0,%C2\;and_cf %D0,%D2"
  [(set_attr "length" "4")])

;;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;; ior

(define_insn "iorhi3"
  [(set (match_operand:HI 0 "register_operand"          "=r,r")
        (ior:HI (match_operand:HI 1 "register_operand"  "%0,0")
                (match_operand:HI 2 "nonmemory_operand"  "r,J")))]
  ""
  "*{
      switch (which_alternative)
        {
          case 0: output_asm_insn (\"or %0, %2\", operands);
            break;
          case 1: operands[2] = gen_rtx_CONST_INT (HImode, exact_log2(INTVAL(operands[2])));
                  output_asm_insn (\"bset %0, %2\", operands);
            break;
          default: gcc_unreachable();
        }
      return \"\";
}"
  [(set_attr "length" "1,1")])

(define_insn "iorhi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"          "=r,r")
	 (ior:HI (match_operand:HI 1 "register_operand"  "%0,0")
		  (match_operand:HI 2 "nonmemory_operand" "r,J"))))]
  ""
  "*{
      switch (which_alternative)
        {
          case 0: output_asm_insn (\"or_ct %0, %2\", operands);
            break;
          case 1: operands[2] = gen_rtx_CONST_INT (HImode, exact_log2(INTVAL(operands[2])));
                  output_asm_insn (\"bset_ct %0, %2\", operands);
            break;
          default: gcc_unreachable();
        }
      return \"\";
}"
  [(set_attr "length" "1,1")])

(define_insn "iorhi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"          "=r,r")
	 (ior:HI (match_operand:HI 1 "register_operand"  "%0,0")
		  (match_operand:HI 2 "nonmemory_operand" "r,J"))))]
  ""
  "*{
      switch (which_alternative)
        {
          case 0: output_asm_insn (\"or_cf %0, %2\", operands);
            break;
          case 1: operands[2] = gen_rtx_CONST_INT (HImode, exact_log2(INTVAL(operands[2])));
                  output_asm_insn (\"bset_cf %0, %2\", operands);
            break;
          default: gcc_unreachable();
        }
      return \"\";
}"
  [(set_attr "length" "1,1")])

(define_insn "iorsi3"
  [(set (match_operand:SI 0 "register_operand"         "=&r")
        (ior:SI (match_operand:SI 1 "register_operand"  "%0")
		(match_operand:SI 2 "register_operand"   "r")))]
  ""
  "or %A0,%A2\;or %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "iorsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"         "=&r")
	 (ior:SI (match_operand:SI 1 "register_operand"  "%0")
		 (match_operand:SI 2 "register_operand"   "r"))))]
  ""
  "or_ct %A0,%A2\;or_ct %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "iorsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"         "=&r")
	 (ior:SI (match_operand:SI 1 "register_operand"  "%0")
		 (match_operand:SI 2 "register_operand"   "r"))))]
  ""
  "or_cf %A0,%A2\;or_cf %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "iordi3"
  [(set (match_operand:DI 0 "register_operand"         "=&r")
        (ior:DI (match_operand:DI 1 "register_operand"  "%0")
		(match_operand:DI 2 "register_operand"   "r")))]
  ""
  "or %A0,%A2\;or %B0,%B2\;or %C0,%C2\;or %D0,%D2"
  [(set_attr "length" "4")])

(define_insn "iordi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (ior:DI (match_operand:DI 1 "register_operand"  "%0")
		 (match_operand:DI 2 "register_operand"   "r"))))]
  ""
  "or_ct %A0,%A2\;or_ct %B0,%B2\;or_ct %C0,%C2\;or_ct %D0,%D2"
  [(set_attr "length" "4")])

(define_insn "iordi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (ior:DI (match_operand:DI 1 "register_operand"  "%0")
		 (match_operand:DI 2 "register_operand"   "r"))))]
  ""
  "or_cf %A0,%A2\;or_cf %B0,%B2\;or_cf %C0,%C2\;or_cf %D0,%D2"
  [(set_attr "length" "4")])

;;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;; xor

(define_insn "xorhi3"
  [(set (match_operand:HI 0 "register_operand"         "=r")
        (xor:HI (match_operand:HI 1 "register_operand" "%0")
                (match_operand:HI 2 "register_operand"  "r")))]
  ""
  "eor %0,%2"
  [(set_attr "length" "1")])

(define_insn "xorhi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"          "=r")
	 (xor:HI (match_operand:HI 1 "register_operand"  "%0")
		 (match_operand:HI 2 "register_operand"   "r"))))]
  ""
  "eor_ct %0,%2"
  [(set_attr "length" "1")])

(define_insn "xorhi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"          "=r")
	 (xor:HI (match_operand:HI 1 "register_operand"  "%0")
		 (match_operand:HI 2 "register_operand"   "r"))))]
  ""
  "eor_cf %0,%2"
  [(set_attr "length" "1")])

(define_insn "xorsi3"
  [(set (match_operand:SI 0 "register_operand"        "=&r")
        (xor:SI (match_operand:SI 1 "register_operand" "%0")
                (match_operand:SI 2 "register_operand"  "r")))]
  ""
  "eor %A0,%A2\;eor %B0,%B2"
  [(set_attr "length" "1")])

(define_insn "xorsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"         "=&r")
	 (xor:SI (match_operand:SI 1 "register_operand"  "%0")
		  (match_operand:SI 2 "register_operand"  "r"))))]
  ""
  "eor_ct %A0,%A2\;eor_ct %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "xorsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"         "=&r")
	 (xor:SI (match_operand:SI 1 "register_operand"  "%0")
		  (match_operand:SI 2 "register_operand"  "r"))))]
  ""
  "eor_cf %A0,%A2\;eor_cf %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "xordi3"
  [(set (match_operand:DI 0 "register_operand"        "=&r")
        (xor:DI (match_operand:DI 1 "register_operand" "%0")
                (match_operand:DI 2 "register_operand"  "r")))]
  ""
  "eor %A0,%A2\;eor %B0,%B2\;eor %C0,%C2\;eor %D0,%D2"
  [(set_attr "length" "4")])

(define_insn "xordi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (xor:DI (match_operand:DI 1 "register_operand"  "%0")
		  (match_operand:DI 2 "register_operand"  "r"))))]
  ""
  "eor_ct %A0,%A2\;eor_ct %B0,%B2\;eor_ct %C0,%C2\;eor_ct %D0,%D2"
  [(set_attr "length" "4")])

(define_insn "xordi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (xor:DI (match_operand:DI 1 "register_operand"  "%0")
		  (match_operand:DI 2 "register_operand"  "r"))))]
  ""
  "eor_cf %A0,%A2\;eor_cf %B0,%B2\;eor_cf %C0,%C2\;eor_cf %D0,%D2"
  [(set_attr "length" "4")])

;;>>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>>
;; lshr

(define_insn "lshrhi3"
  [(set (match_operand:HI 0 "register_operand"              "=r,r")
	(lshiftrt:HI (match_operand:HI 1 "register_operand"  "0,0")
		     (match_operand:HI 2 "nonmemory_operand" "r,P")))]
  ""
  "@
      sr %0, %2
      sri %0, %2"
  [(set_attr "length" "1,1")])

(define_insn "lshrhi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"              "=r,r")
	 (lshiftrt:HI (match_operand:HI 1 "register_operand"  "0,0")
		      (match_operand:HI 2 "nonmemory_operand" "r,P"))))]
  ""
  "@
      sr_ct %0,%2
      sri_ct %0,%2"
  [(set_attr "length" "1,1")])

(define_insn "lshrhi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"              "=r,r")
	 (lshiftrt:HI (match_operand:HI 1 "register_operand"  "0,0")
		      (match_operand:HI 2 "nonmemory_operand" "r,P"))))]
  ""
  "@
      sr_cf %0,%2
      sri_cf %0,%2"
  [(set_attr "length" "1,1")])

(define_expand "lshrsi3"
  [(set (match_operand:SI 0 "register_operand" "")
	(lshiftrt:SI (match_operand:SI 1 "register_operand" "")
		     (match_operand:HI 2 "nonmemory_operand" "")))]
  ""
  "{
     if ((GET_CODE (operand2) == CONST_INT) && (INTVAL (operand2) <= 3))
       {
         int i;
         int k = INTVAL (operand2);
         emit_move_insn (operands[0], operands[1]);
         for (i = 0; i < k; i++)
           {
             emit_insn (gen_lshrsi1 (operands[0], operands[0]));
           }
         DONE;
       }
     else
       {
         FAIL;
       }
}")

(define_insn "lshrsi1"
  [(set (match_operand:SI 0 "register_operand"              "=r,r")
	(lshiftrt:SI (match_operand:SI 1 "register_operand"  "0,0")
		     (const_int 1)))]
  ""
  "sri %B0, 1\;rrc %A0"
  [(set_attr "length" "2")])

(define_insn "lshrsi1<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"              "=r,r")
	 (lshiftrt:SI (match_operand:SI 1 "register_operand"  "0,0")
		      (const_int 1))))]
  ""
  "sri_ct %B0, 1\;rrc_ct %A0"
  [(set_attr "length" "2")])

(define_insn "lshrsi1<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"              "=r,r")
	 (lshiftrt:SI (match_operand:SI 1 "register_operand"  "0,0")
		      (const_int 1))))]
  ""
  "sri_cf %B0, 1\;rrc_cf %A0"
  [(set_attr "length" "2")])

(define_insn "lshrdi1"
  [(set (match_operand:DI 0 "register_operand"              "=r,r")
	(lshiftrt:DI (match_operand:DI 1 "register_operand"  "0,0")
		   (const_int 1)))]
  ""
  "sri %D0, 1\;rrc %C0\;rrc %B0\;rrc %A0"
  [(set_attr "length" "4")])

(define_insn "lshrdi1<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"              "=r,r")
	 (lshiftrt:DI (match_operand:DI 1 "register_operand"  "0,0")
		    (const_int 1))))]
  ""
  "sri_ct %D0, 1\;rrc_ct %C0\;rrc_ct %B0\;rrc_ct %A0"
  [(set_attr "length" "4")])

(define_insn "lshrdi1<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"              "=r,r")
	 (lshiftrt:DI (match_operand:DI 1 "register_operand"  "0,0")
		    (const_int 1))))]
  ""
  "sri_cf %D0, 1\;rrc_cf %C0\;rrc_cf %B0\;rrc_cf %A0"
  [(set_attr "length" "4")])

;;>> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >>
;; ashr

(define_insn "ashrhi3"
  [(set (match_operand:HI 0 "register_operand"              "=r,r")
	(ashiftrt:HI (match_operand:HI 1 "register_operand"  "0,0")
		     (match_operand:HI 2 "nonmemory_operand" "r,P")))]
  ""
  "@
      sra %0, %2
      srai %0, %2"
  [(set_attr "length" "1,1")])

(define_insn "ashrhi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"              "=r,r")
	 (ashiftrt:HI (match_operand:HI 1 "register_operand"  "0,0")
		      (match_operand:HI 2 "nonmemory_operand" "r,P"))))]
  ""
  "@
      sra_ct %0,%2
      srai_ct %0,%2"
  [(set_attr "length" "1,1")])

(define_insn "ashrhi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"              "=r,r")
	 (ashiftrt:HI (match_operand:HI 1 "register_operand"  "0,0")
		      (match_operand:HI 2 "nonmemory_operand" "r,P"))))]
  ""
  "@
      sra_cf %0,%2
      srai_cf %0,%2"
  [(set_attr "length" "1,1")])

(define_expand "ashrsi3"
  [(set (match_operand:SI 0 "register_operand" "")
	(ashiftrt:SI (match_operand:SI 1 "register_operand" "")
		     (match_operand:HI 2 "nonmemory_operand" "")))]
  ""
  "{
     if ((GET_CODE (operand2) == CONST_INT) && (INTVAL (operand2) <= 3))
       {
         int i;
         int k = INTVAL (operand2);
         emit_move_insn (operands[0], operands[1]);
         for (i = 0; i < k; i++)
           {
             emit_insn (gen_ashrsi1 (operands[0], operands[0]));
           }
         DONE;
       }
     else
       {
         FAIL;
       }
}")

(define_insn "ashrsi1"
  [(set (match_operand:SI 0 "register_operand"              "=r,r")
	(ashiftrt:SI (match_operand:SI 1 "register_operand"  "0,0")
		     (const_int 1)))]
  ""
  "srai %B0, 1\;rrc %A0"
  [(set_attr "length" "2")])

(define_insn "ashrsi1<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"              "=r,r")
	 (ashiftrt:SI (match_operand:SI 1 "register_operand"  "0,0")
		      (const_int 1))))]
  ""
  "srai_ct %B0, 1\;rrc_ct %A0"
  [(set_attr "length" "2")])

(define_insn "ashrsi1<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"              "=r,r")
	 (ashiftrt:SI (match_operand:SI 1 "register_operand"  "0,0")
		      (const_int 1))))]
  ""
  "srai_cf %B0, 1\;rrc_cf %A0"
  [(set_attr "length" "2")])

(define_insn "ashrdi1"
  [(set (match_operand:DI 0 "register_operand"              "=r,r")
	(ashiftrt:DI (match_operand:DI 1 "register_operand"  "0,0")
		   (const_int 1)))]
  ""
  "srai %D0, 1\;rrc %C0\;rrc %B0\;rrc %A0"
  [(set_attr "length" "4")])
(define_insn "ashrdi1<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"              "=r,r")
	 (ashiftrt:DI (match_operand:DI 1 "register_operand"  "0,0")
		    (const_int 1))))]
  ""
  "srai_ct %D0, 1\;rrc_ct %C0\;rrc_ct %B0\;rrc_ct %A0"
  [(set_attr "length" "4")])

(define_insn "ashrdi1<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"              "=r,r")
	 (ashiftrt:DI (match_operand:DI 1 "register_operand"  "0,0")
		    (const_int 1))))]
  ""
  "srai_cf %D0, 1\;rrc_cf %C0\;rrc_cf %B0\;rrc_cf %A0"
  [(set_attr "length" "4")])

;;<< << << << << << << << << << << << << << << << << << << << << << << <<
;; ashl

(define_insn "ashlhi3"
  [(set (match_operand:HI 0 "register_operand"            "=r,r")
	(ashift:HI (match_operand:HI 1 "register_operand"  "0,0")
		   (match_operand:HI 2 "nonmemory_operand" "r,P")))]
  ""
  "@
      sl %0, %2
      sli %0, %2"
  [(set_attr "length" "1,1")])

(define_insn "ashlhi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"            "=r,r")
	 (ashift:HI (match_operand:HI 1 "register_operand"  "0,0")
		    (match_operand:HI 2 "nonmemory_operand" "r,P"))))]
  ""
  "@
      sl_ct %0,%2
      sli_ct %0,%2"
  [(set_attr "length" "1,1")])

(define_insn "ashlhi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"            "=r,r")
	 (ashift:HI (match_operand:HI 1 "register_operand"  "0,0")
		    (match_operand:HI 2 "nonmemory_operand" "r,P"))))]
  ""
  "@
      sl_cf %0,%2
      sli_cf %0,%2"
  [(set_attr "length" "1,1")])

(define_expand "ashlsi3"
  [(set (match_operand:SI 0 "register_operand" "")
	(ashift:SI (match_operand:SI 1 "register_operand" "")
		   (match_operand:HI 2 "nonmemory_operand" "")))]
  ""
  "{
     if ((GET_CODE (operand2) == CONST_INT) && (INTVAL (operand2) <= 3))
       {
         int i;
         int k = INTVAL (operand2);
         emit_move_insn (operands[0], operands[1]);
         for (i = 0; i < k; i++)
           {
             emit_insn (gen_ashlsi1 (operands[0], operands[0]));
           }
         DONE;
       }
     else
       {
         FAIL;
       }
}")

(define_insn "ashlsi1"
  [(set (match_operand:SI 0 "register_operand"            "=r,r")
	(ashift:SI (match_operand:SI 1 "register_operand"  "0,0")
		   (const_int 1)))]
  ""
  "sli %A0, 1\;addc %B0, %B0"
  [(set_attr "length" "2")])

(define_insn "ashlsi1<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"            "=r,r")
	 (ashift:SI (match_operand:SI 1 "register_operand"  "0,0")
		    (const_int 1))))]
  ""
  "sli_ct %A0, 1\;addc_ct %B0, %B0"
  [(set_attr "length" "2")])

(define_insn "ashlsi1<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"            "=r,r")
	 (ashift:SI (match_operand:SI 1 "register_operand"  "0,0")
		    (const_int 1))))]
  ""
  "sli_cf %A0, 1\;addc_cf %B0, %B0"
  [(set_attr "length" "4")])

(define_insn "ashldi1"
  [(set (match_operand:DI 0 "register_operand"            "=r,r")
	(ashift:DI (match_operand:DI 1 "register_operand"  "0,0")
		   (const_int 1)))]
  ""
  "sli %A0, 1\;addc %B0, %B0\;addc %C0, %C0\;addc %D0, %D0"
  [(set_attr "length" "4")])

(define_insn "ashldi1<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"            "=r,r")
	 (ashift:DI (match_operand:DI 1 "register_operand"  "0,0")
		    (const_int 1))))]
  ""
  "sli_ct %A0, 1\;addc_ct %B0, %B0\;addc_ct %C0, %C0\;addc_ct %D0, %D0"
  [(set_attr "length" "4")])

(define_insn "ashldi1<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"            "=r,r")
	 (ashift:DI (match_operand:DI 1 "register_operand"  "0,0")
		    (const_int 1))))]
  ""
  "sli_cf %A0, 1\;addc_cf %B0, %B0\;addc_cf %C0, %C0\;addc_cf %D0, %D0"
  [(set_attr "length" "4")])

;; 0 - x  0 - x  0 - x  0 - x  0 - x  0 - x  0 - x  0 - x  0 - x  0 - x  0 - x
;; neg

(define_insn "neghi2"
  [(set (match_operand:HI 0 "register_operand"         "=r")
        (neg:HI (match_operand:HI 1 "register_operand"  "0")))]
  ""
  "neg %0"
  [(set_attr "length" "1")])

(define_insn "neghi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"          "=r")
	 (neg:HI (match_operand:HI 1 "register_operand"   "0"))))]
  ""
  "neg_ct %0"
  [(set_attr "length" "1")])

(define_insn "neghi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"          "=r")
	 (neg:HI (match_operand:HI 1 "register_operand"   "0"))))]
  ""
  "neg_cf %0"
  [(set_attr "length" "1")])

;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; not

(define_insn "one_cmplhi2"
  [(set (match_operand:HI 0 "register_operand"         "=r")
        (not:HI (match_operand:HI 1 "register_operand"  "0")))]
  ""
  "not %0"
  [(set_attr "length" "1")])

(define_insn "one_cmplhi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"          "=r")
	 (not:HI (match_operand:HI 1 "register_operand"   "0"))))]
  ""
  "not_ct %0"
  [(set_attr "length" "1")])

(define_insn "one_cmplhi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:HI 0 "register_operand"          "=r")
	 (not:HI (match_operand:HI 1 "register_operand"   "0"))))]
  ""
  "not_cf %0"
  [(set_attr "length" "1")])

(define_insn "one_cmplsi2"
  [(set (match_operand:SI 0 "register_operand"         "=r")
        (not:SI (match_operand:SI 1 "register_operand"  "0")))]
  ""
  "not %A0\;not %B0"
  [(set_attr "length" "2")])

(define_insn "one_cmplsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"          "=r")
	 (not:SI (match_operand:SI 1 "register_operand"   "0"))))]
  ""
  "not_ct %A0\;not_ct %B0"
  [(set_attr "length" "2")])

(define_insn "one_cmplsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"          "=r")
	 (not:SI (match_operand:SI 1 "register_operand"   "0"))))]
  ""
  "not_cf %A0\;not_cf %B0"
  [(set_attr "length" "2")])

(define_insn "one_cmpldi2"
  [(set (match_operand:DI 0 "register_operand"         "=r")
        (not:DI (match_operand:DI 1 "register_operand"  "0")))]
  ""
  "not %A0\;not %B0\;not %C0\;not %D0"
  [(set_attr "length" "4")])

(define_insn "one_cmpldi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"          "=r")
	 (not:DI (match_operand:DI 1 "register_operand"   "0"))))]
  ""
  "not_ct %A0\;not_ct %B0\;not_ct %C0\;not_ct %D0"
  [(set_attr "length" "4")])

(define_insn "one_cmpldi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"          "=r")
	 (not:DI (match_operand:DI 1 "register_operand"   "0"))))]
  ""
  "not_cf %A0\;not_cf %B0\;not_cf %C0\;not_cf %D0"
  [(set_attr "length" "4")])

;;<=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=>
;; compare

(define_insn "cmphi"
  [(set (reg:CC CC_REGNO)
	(compare:CC (match_operand:HI 0 "register_operand" "r,r")
		    (match_operand:HI 1 "nonmemory_operand" "r,K")))]
  ""
  "* return scarts16_out_compare(insn, operands);"
  [(set_attr "length" "1,2")])


(define_insn "cmpsi"
  [(set (reg:CC CC_REGNO)
	(compare:CC (match_operand:SI 0 "register_operand" "r")
		    (match_operand:SI 1 "register_operand" "r")))]
  ""
  "* return scarts16_out_compare(insn, operands);"
  [(set_attr "length" "7")])

(define_insn "cmpdi"
  [(set (reg:CC CC_REGNO)
	(compare:CC (match_operand:DI 0 "register_operand" "r")
		    (match_operand:DI 1 "register_operand" "r")))]
  ""
  "* return scarts16_out_compare(insn, operands);"
  [(set_attr "length" "15")])

(define_insn "btsthi"
  [(set (reg:CC CC_REGNO)
	(compare:CC (zero_extract:HI (match_operand:HI 0 "register_operand"  "r")
				     (const_int 1)
				     (match_operand:HI 1 "immediate_operand" "N"))
		    (const_int 0)))]
  ""
  "* return scarts16_out_bittest(insn, operands);"
  [(set_attr "length" "1")])

;; ----------------------------------------------------------------------
;; CONDITIONAL INSTRUCTIONS
;; ----------------------------------------------------------------------

;; ----------------------------------------------------------------------
;; Conditional jump instructions

(define_insn "b<code>"
  [(set (pc)
        (if_then_else (any_cond:CC (reg:CC CC_REGNO)
				   (const_int 0))
                      (label_ref (match_operand 0 "" ""))
                      (pc)))]
  ""
  "* return scarts16_out_branch(insn, operands, <CODE>);"
  [(set (attr "length")
	(if_then_else (and (ge (minus (match_dup 0) (pc)) (const_int -512))
			   (lt (minus (match_dup 0) (pc)) (const_int 511)))
		      (const_int 1)
		      (const_int 3)))])

;; ----------------------------------------------------------------------
;; Unconditional jump instructions

;; jump

(define_insn "jump"
  [(set (pc)
        (label_ref (match_operand 0 "" "")))]
  ""
  "* return scarts16_out_jump(insn, operands);"
  [(set (attr "length")
	(if_then_else (and (ge (minus (match_dup 0) (pc)) (const_int -512))
			   (lt (minus (match_dup 0) (pc)) (const_int 511)))
		      (const_int 1)
		      (const_int 3)))])

; indirect jump
(define_insn "indirect_jump"
  [(set (pc) (match_operand:HI 0 "register_operand" "r"))]
  ""
  "jmp %0"
  [(set_attr "length" "1")])

;; **************************************************************************
;; NOP

(define_insn "nop"
  [(const_int 0)]
  ""
  "nop"
  [(set_attr "length" "1")])
