;; -*- Mode: Scheme -*-
;;   Machine description for GNU compiler,
;;   for SCARTS32 micro controllers.
;;   Copyright (C) 1998, 1999, 2000, 2001, 2002, 2004, 2005 Free Software Foundation, Inc.
;;   Contributed by Wolfgang Puffitsch <hausen@gmx.at>

;;   This file is part of the SCARTS32 port of GCC

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
  [(parallel [(call (match_operand:SI 0 "call_insn_operand" "")
		    (match_operand:SI 1 "general_operand" ""))
	      (clobber (reg:SI RA_REGNO))])]
  ""
  "{
     if (GET_CODE (operands[0]) == MEM
         && !register_operand (XEXP (operands[0], 0), SImode))
       operands[0] = gen_rtx_MEM (GET_MODE (operands[0]),
	                	  force_reg (SImode, XEXP (operands[0], 0)));
}")

(define_expand "call_value"
  [(parallel [(set (match_operand 0 "register_operand" "")
		   (call (match_operand:SI 1 "call_insn_operand" "")
			 (match_operand:SI 2 "general_operand" "")))
	      (clobber (reg:SI RA_REGNO))])]
  ""
  "{
     if (GET_CODE (operands[1]) == MEM
         && !register_operand (XEXP (operands[1], 0), SImode))
       operands[1] = gen_rtx_MEM (GET_MODE (operands[1]),
	                	  force_reg (SImode, XEXP (operands[1], 0)));
}")

(define_insn "call_insn"
   [(call (mem:SI (match_operand:SI 0 "register_operand" "r"))
	  (match_operand:SI 1 "general_operand" "X"))
    (clobber (reg:SI RA_REGNO))]
  ""
  "jsr %0"
  [(set_attr "length" "1")])

(define_insn "call_insn<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (parallel [(call (mem:SI (match_operand:SI 0 "register_operand" "r"))
		     (match_operand:SI 1 "general_operand" "X"))
	       (clobber (reg:SI RA_REGNO))]))]
  ""
  "jsr_ct %0"
  [(set_attr "length" "1")])

(define_insn "call_insn<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (parallel [(call (mem:SI (match_operand:SI 0 "register_operand" "r"))
		     (match_operand:SI 1 "general_operand" "X"))
	       (clobber (reg:SI RA_REGNO))]))]
  ""
  "jsr_cf %0"
  [(set_attr "length" "1")])

(define_insn "call_value_insn"
  [(set (match_operand 0 "register_operand" "=r")
        (call (mem:SI (match_operand:SI 1 "register_operand" "r"))
              (match_operand:SI 2 "general_operand" "X")))
   (clobber (reg:SI RA_REGNO))]
  ""
  "jsr %1"
  [(set_attr "length" "1")])

(define_insn "call_value_insn<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (parallel [(set (match_operand 0 "register_operand" "=r")
		    (call (mem:SI (match_operand:SI 1 "register_operand" "r"))
			  (match_operand:SI 2 "general_operand" "X")))
	       (clobber (reg:SI RA_REGNO))]))]
  ""
  "jsr_ct %1"
  [(set_attr "length" "1")])

(define_insn "call_value_insn<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (parallel [(set (match_operand 0 "register_operand" "=r")
		    (call (mem:SI (match_operand:SI 1 "register_operand" "r"))
			  (match_operand:SI 2 "general_operand" "X")))
	       (clobber (reg:SI RA_REGNO))]))]
  ""
  "jsr_cf %1"
  [(set_attr "length" "1")])

;; return

(define_insn "return"
  [(return)]
  "reload_completed && scarts32_simple_epilogue ()"
  "rts"
  [(set_attr "length" "1")])

;;==========================================================================
;; push

(define_insn "pushqi2"
  [(set (mem:QI (pre_modify:SI (match_operand:SI 0 "register_operand" "+q")
			       (plus:SI (match_dup 0) (const_int -4))))
	(match_operand:QI 1 "register_operand" "r"))]
  ""
  "st%0_dec %1,-1"
  [(set_attr "length" "1")])

(define_insn "pushhi2"
  [(set (mem:HI (pre_modify:SI (match_operand:SI 0 "register_operand" "+q")
			       (plus:SI (match_dup 0) (const_int -4))))
	(match_operand:HI 1 "register_operand" "r"))]
  ""
  "st%0_dec %1,-1"
  [(set_attr "length" "1")])

(define_insn "pushsi2"
  [(set (mem:SI (pre_dec:SI (match_operand:SI 0 "register_operand" "+q")))
	(match_operand:SI 1 "register_operand" "r"))]
  ""
  "st%0_dec %1,-1"
  [(set_attr "length" "1")])

(define_insn "pushdi2"
  [(set (mem:DI (pre_dec:SI (match_operand:SI 0 "register_operand" "+q")))
	(match_operand:DI 1 "register_operand" "r"))]
  ""
  "st%0_dec %B1,-1\;st%0_dec %A1,-1"
  [(set_attr "length" "2")])

;; =========================================================================
;; postdec

(define_insn "st_postdecsi2"
  [(set (mem:SI (post_dec:SI (match_operand:SI 0 "register_operand" "+q")))
	(match_operand:SI 1 "register_operand" "r"))]
   ""
   "st%0_dec %1,0"
   [(set_attr "length" "1")])

(define_insn "st_postdecdi2"
  [(set (mem:DI (post_dec:SI (match_operand:SI 0 "register_operand" "+q")))
	(match_operand:DI 1 "register_operand" "r"))]
   ""
   "st%0_dec %B1,1\;st%0_dec %A1,1"
   [(set_attr "length" "2")])

(define_insn "ld_postdecsi2"
  [(set (match_operand:SI 1 "register_operand" "=r")
	(mem:SI (post_dec:SI (match_operand:SI 0 "register_operand" "+q"))))]
   ""
   "ld%0_dec %1,0"
   [(set_attr "length" "1")])

(define_insn "ld_postdecdi2"
  [(set (match_operand:DI 1 "register_operand" "=r")
	(mem:DI (post_dec:SI (match_operand:SI 0 "register_operand" "+q"))))]
   ""
   "ld%0_dec %B1,1\;ld%0_dec %A1,1"
   [(set_attr "length" "2")])

;; =========================================================================
;; postinc

(define_insn "st_postincsi2"
  [(set (mem:SI (post_inc:SI (match_operand:SI 0 "register_operand" "+q")))
	(match_operand:SI 1 "register_operand" "r"))]
   ""
   "st%0_inc %1,0"
   [(set_attr "length" "1")])

(define_insn "st_postincdi2"
  [(set (mem:DI (post_inc:SI (match_operand:SI 0 "register_operand" "+q")))
	(match_operand:DI 1 "register_operand" "r"))]
   ""
   "st%0_inc %A1,0\;st%0_inc %B1,0"
   [(set_attr "length" "2")])

(define_insn "ld_postincsi2"
  [(set (match_operand:SI 1 "register_operand" "=r")
	(mem:SI (post_inc:SI (match_operand:SI 0 "register_operand" "+q"))))]
   ""
   "ld%0_inc %1,0"
   [(set_attr "length" "1")])

(define_insn "ld_postincdi2"
  [(set (match_operand:DI 1 "register_operand" "=r")
	(mem:DI (post_inc:SI (match_operand:SI 0 "register_operand" "+q"))))]
   ""
   "ld%0_inc %A1,0\;ld%0_inc %B1,0"
   [(set_attr "length" "2")])

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
  "* return scarts32_out_movqi (insn, operands, which_alternative);"
  [(set_attr "length" "1,1,1,1")])

;;==========================================================================
;; move half-word (16 bit)

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
  [(set (match_operand:HI 0 "nonimmediate_operand"   "=r,r,r,m,r")
        (match_operand:HI 1 "general_operand"         "r,L,n,r,m"))]
  ""
  "* return scarts32_out_movhi (insn, operands, which_alternative);"
  [(set_attr "length" "1,1,2,1,1")])

;;==========================================================================
;; move word (32 bit)

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

(define_insn "*ld_hisi2"
  [(set (match_operand:SI 0 "register_operand" "=r")
	(sign_extend:SI
	 (mem:HI (match_operand:SI 1 "register_operand" "r"))))]
  ""
  "ldh %0,%1"
  [(set_attr "length" "1")])

(define_insn "*ldu_hisi2"
  [(set (match_operand:SI 0 "register_operand" "=r")
	(zero_extend:SI
	 (mem:HI (match_operand:SI 1 "register_operand" "r"))))]
  ""
  "ldhu %0,%1"
  [(set_attr "length" "1")])

(define_insn "*ld_qisi2"
  [(set (match_operand:SI 0 "register_operand" "=r")
	(sign_extend:SI
	 (mem:QI (match_operand:SI 1 "register_operand" "r"))))]
  ""
  "ldb %0,%1"
  [(set_attr "length" "1")])

(define_insn "*ldu_qisi2"
  [(set (match_operand:SI 0 "register_operand" "=r")
	(zero_extend:SI
	 (mem:QI (match_operand:SI 1 "register_operand" "r"))))]
  ""
  "ldbu %0,%1"
  [(set_attr "length" "1")])

(define_insn "*movsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"    "=r")
	 (match_operand:SI 1 "register_operand"     "r")))]
  ""
  "mov_ct %0,%1"
  [(set_attr "length" "1")])

(define_insn "*movsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"    "=r")
	 (match_operand:SI 1 "register_operand"     "r")))]
  ""
  "mov_cf %0,%1"
  [(set_attr "length" "1")])

(define_insn "*movsi"
  [(set (match_operand:SI 0 "nonimmediate_operand"   "=r,r,r,r,r, m,rq,rq")
        (match_operand:SI 1 "general_operand"         "r,L,M,n,s,rq, m,rq"))]
  ""
  "* return scarts32_out_movsi (insn, operands, which_alternative);"
  [(set_attr "length" "1,1,2,6,6,5,5,6")])

;;==========================================================================
;; move double-word (64 bit)

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
	}
      else
	{
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

(define_insn "*movdi"
  [(set (match_operand:DI 0 "nonimmediate_operand"    "=r,r,r,m,r")
        (match_operand:DI 1 "general_operand"          "r,L,n,r,m"))]
  ""
  "* return scarts32_out_movdi (insn, operands, which_alternative);"
  [(set_attr "length" "2,2,12,4,4")])

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; add bytes

(define_insn "addsi3"
  [(set (match_operand:SI 0 "register_operand"            "=r,r")
        (plus:SI (match_operand:SI 1 "register_operand"   "%0,0")
                 (match_operand:SI 2 "nonmemory_operand"  "rq,O")))]
  ""
  "* return scarts32_out_addsi (insn, operands, which_alternative);"
  [(set_attr "length" "3,1")])

(define_insn "addsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"          "=r,r")
	 (plus:SI (match_operand:SI 1 "register_operand" "%0,0")
		  (match_operand:SI 2 "nonmemory_operand" "r,O"))))]
  ""
  "@
     add_ct %0,%2
     addi_ct %0,%2"
  [(set_attr "length" "1,1")])

(define_insn "addsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"          "=r,r")
	 (plus:SI (match_operand:SI 1 "register_operand" "%0,0")
		  (match_operand:SI 2 "nonmemory_operand" "r,O"))))]
  ""
  "@
     add_cf %0,%2
     addi_cf %0,%2"
  [(set_attr "length" "1,1")])

(define_insn "adddi3"
  [(set (match_operand:DI 0 "register_operand"          "=&r")
        (plus:DI (match_operand:DI 1 "register_operand"  "%0")
                 (match_operand:DI 2 "register_operand"   "r")))]
  ""
  "add %A0,%A2\;addc %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "adddi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (plus:DI (match_operand:DI 1 "register_operand" "%0")
		  (match_operand:DI 2 "register_operand"  "r"))))]
  ""
  "add_ct %A0,%A2\;addc_ct %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "adddi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (plus:DI (match_operand:DI 1 "register_operand" "%0")
		  (match_operand:DI 2 "register_operand"  "r"))))]
  ""
  "add_cf %A0,%A2\;addc_cf %B0,%B2"
  [(set_attr "length" "2")])

;-----------------------------------------------------------------------------
; sub bytes

(define_insn "subsi3"
  [(set (match_operand:SI 0 "register_operand"           "=r")
        (minus:SI (match_operand:SI 1 "register_operand"  "0")
		  (match_operand:SI 2 "register_operand"  "r")))]
  ""
  "sub %0,%2"
  [(set_attr "length" "1")])

(define_insn "subsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"           "=r")
	 (minus:SI (match_operand:SI 1 "register_operand"  "0")
		   (match_operand:SI 2 "register_operand"  "r"))))]
  ""
  "sub_ct %0,%2"
  [(set_attr "length" "1")])

(define_insn "subsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"           "=r")
	 (minus:SI (match_operand:SI 1 "register_operand"  "0")
		   (match_operand:SI 2 "register_operand"  "r"))))]
  ""
  "sub_cf %0,%2"
  [(set_attr "length" "1")])

(define_insn "subdi3"
  [(set (match_operand:DI 0 "register_operand"           "=&r")
        (minus:DI (match_operand:DI 1 "register_operand"   "0")
		  (match_operand:DI 2 "register_operand"   "r")))]
  ""
  "sub %A0,%A2\;subc %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "subdi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"          "=&r")
	 (minus:DI (match_operand:DI 1 "register_operand"  "0")
		   (match_operand:DI 2 "register_operand"  "r"))))]
  ""
  "sub_ct %A0,%A2\;subc_ct %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "subdi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"          "=&r")
	 (minus:DI (match_operand:DI 1 "register_operand"  "0")
		   (match_operand:DI 2 "register_operand"  "r"))))]
  ""
  "sub_cf %A0,%A2\;subc_cf %B0,%B2"
  [(set_attr "length" "2")])

;******************************************************************************
; mul

(define_expand "mulsi3"
  [(set (match_operand:SI 0 "register_operand" "")
	(mult:SI (match_operand:SI 1 "register_operand" "")
		 (match_operand:SI 2 "register_operand" "")))]
  ""
  "{
     operands[3] = force_reg (SImode, gen_rtx_SYMBOL_REF (SImode, \"__mulsi3\"));
     emit_insn (gen_mulsi3_call (operands[0], operands[1], operands[2], operands[3]));
     DONE;
}")

(define_expand "mulsi3_call"
  [(set (reg:SI ARG0_REGNO) (match_operand:SI 1 "register_operand" ""))
   (set (reg:SI ARG1_REGNO) (match_operand:SI 2 "register_operand" ""))
   (parallel [(set (reg:SI RET_REGNO)
		   (mult:SI (reg:SI ARG0_REGNO) (reg:SI ARG1_REGNO)))
	      (use (match_operand:SI 3 "register_operand" ""))
	      (use (reg:SI ARG0_REGNO))
	      (use (reg:SI ARG1_REGNO))
	      (clobber (reg:SI ARG0_REGNO))
	      (clobber (reg:SI ARG1_REGNO))
	      (clobber (reg:SI RA_REGNO))])
   (set (match_operand:SI 0 "register_operand" "") (reg:SI RET_REGNO))]
  ""
  "")

(define_insn "*mulsi3_call"
  [(set (reg:SI RET_REGNO)
	(mult:SI (reg:SI ARG0_REGNO) (reg:SI ARG1_REGNO)))
   (use (match_operand:SI 0 "register_operand" "r"))
   (use (reg:SI ARG0_REGNO))
   (use (reg:SI ARG1_REGNO))
   (clobber (reg:SI ARG0_REGNO))
   (clobber (reg:SI ARG1_REGNO))
   (clobber (reg:SI RA_REGNO))]
  ""
  "jsr %0"
  [(set_attr "length" "1")])

;//////////////////////////////////////////////////////////////////////////////
; div

(define_expand "divsi3"
  [(set (match_operand:SI 0 "register_operand" "")
	(div:SI (match_operand:SI 1 "register_operand" "")
		 (match_operand:SI 2 "register_operand" "")))]
  ""
  "{
     operands[3] = force_reg (SImode, gen_rtx_SYMBOL_REF (SImode, \"__divsi3\"));
     emit_insn (gen_divsi3_call (operands[0], operands[1], operands[2], operands[3]));
     DONE;
}")

(define_expand "divsi3_call"
  [(set (reg:SI ARG0_REGNO) (match_operand:SI 1 "register_operand" ""))
   (set (reg:SI ARG1_REGNO) (match_operand:SI 2 "register_operand" ""))
   (parallel [(set (reg:SI RET_REGNO)
		   (div:SI (reg:SI ARG0_REGNO) (reg:SI ARG1_REGNO)))
	      (use (match_operand:SI 3 "register_operand" ""))
	      (use (reg:SI ARG0_REGNO))
	      (use (reg:SI ARG1_REGNO))
	      (clobber (reg:SI ARG0_REGNO))
	      (clobber (reg:SI ARG1_REGNO))
	      (clobber (reg:SI ARG2_REGNO))
	      (clobber (reg:SI RA_REGNO))])
   (set (match_operand:SI 0 "register_operand" "") (reg:SI RET_REGNO))]
  ""
  "")

(define_insn "*divsi3_call"
  [(set (reg:SI RET_REGNO)
	(div:SI (reg:SI ARG0_REGNO) (reg:SI ARG1_REGNO)))
   (use (match_operand:SI 0 "register_operand" "r"))
   (use (reg:SI ARG0_REGNO))
   (use (reg:SI ARG1_REGNO))
   (clobber (reg:SI ARG0_REGNO))
   (clobber (reg:SI ARG1_REGNO))
   (clobber (reg:SI ARG2_REGNO))
   (clobber (reg:SI RA_REGNO))]
  ""
  "jsr %0"
  [(set_attr "length" "1")])

;//////////////////////////////////////////////////////////////////////////////
; udiv

(define_expand "udivsi3"
  [(set (match_operand:SI 0 "register_operand" "")
	(udiv:SI (match_operand:SI 1 "register_operand" "")
		 (match_operand:SI 2 "register_operand" "")))]
  ""
  "{
     operands[3] = force_reg (SImode, gen_rtx_SYMBOL_REF (SImode, \"__udivsi3\"));
     emit_insn (gen_udivsi3_call (operands[0], operands[1], operands[2], operands[3]));
     DONE;
}")

(define_expand "udivsi3_call"
  [(set (reg:SI ARG0_REGNO) (match_operand:SI 1 "register_operand" ""))
   (set (reg:SI ARG1_REGNO) (match_operand:SI 2 "register_operand" ""))
   (parallel [(set (reg:SI RET_REGNO)
		   (udiv:SI (reg:SI ARG0_REGNO) (reg:SI ARG1_REGNO)))
	      (use (match_operand:SI 3 "register_operand" ""))
	      (use (reg:SI ARG0_REGNO))
	      (use (reg:SI ARG1_REGNO))
	      (clobber (reg:SI ARG0_REGNO))
	      (clobber (reg:SI ARG1_REGNO))
	      (clobber (reg:SI RA_REGNO))])
   (set (match_operand:SI 0 "register_operand" "") (reg:SI RET_REGNO))]
  ""
  "")

(define_insn "*udivsi3_call"
  [(set (reg:SI RET_REGNO)
	(udiv:SI (reg:SI ARG0_REGNO) (reg:SI ARG1_REGNO)))
   (use (match_operand:SI 0 "register_operand" "r"))
   (use (reg:SI ARG0_REGNO))
   (use (reg:SI ARG1_REGNO))
   (clobber (reg:SI ARG0_REGNO))
   (clobber (reg:SI ARG1_REGNO))
   (clobber (reg:SI RA_REGNO))]
  ""
  "jsr %0"
  [(set_attr "length" "1")])

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; mod

(define_expand "modsi3"
  [(set (match_operand:SI 0 "register_operand" "")
	(mod:SI (match_operand:SI 1 "register_operand" "")
		 (match_operand:SI 2 "register_operand" "")))]
  ""
  "{
     operands[3] = force_reg (SImode, gen_rtx_SYMBOL_REF (SImode, \"__modsi3\"));
     emit_insn (gen_modsi3_call (operands[0], operands[1], operands[2], operands[3]));
     DONE;
}")

(define_expand "modsi3_call"
  [(set (reg:SI ARG0_REGNO) (match_operand:SI 1 "register_operand" ""))
   (set (reg:SI ARG1_REGNO) (match_operand:SI 2 "register_operand" ""))
   (parallel [(set (reg:SI RET_REGNO)
		   (mod:SI (reg:SI ARG0_REGNO) (reg:SI ARG1_REGNO)))
	      (use (match_operand:SI 3 "register_operand" ""))
	      (use (reg:SI ARG0_REGNO))
	      (use (reg:SI ARG1_REGNO))
	      (clobber (reg:SI ARG0_REGNO))
	      (clobber (reg:SI ARG1_REGNO))
	      (clobber (reg:SI ARG2_REGNO))
	      (clobber (reg:SI RA_REGNO))])
   (set (match_operand:SI 0 "register_operand" "") (reg:SI RET_REGNO))]
  ""
  "")

(define_insn "*modsi3_call"
  [(set (reg:SI RET_REGNO)
	(mod:SI (reg:SI ARG0_REGNO) (reg:SI ARG1_REGNO)))
   (use (match_operand:SI 0 "register_operand" "r"))
   (use (reg:SI ARG0_REGNO))
   (use (reg:SI ARG1_REGNO))
   (clobber (reg:SI ARG0_REGNO))
   (clobber (reg:SI ARG1_REGNO))
   (clobber (reg:SI ARG2_REGNO))
   (clobber (reg:SI RA_REGNO))]
  ""
  "jsr %0"
  [(set_attr "length" "1")])

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
; umod

(define_expand "umodsi3"
  [(set (match_operand:SI 0 "register_operand" "")
	(umod:SI (match_operand:SI 1 "register_operand" "")
		 (match_operand:SI 2 "register_operand" "")))]
  ""
  "{
     operands[3] = force_reg (SImode, gen_rtx_SYMBOL_REF (SImode, \"__umodsi3\"));
     emit_insn (gen_umodsi3_call (operands[0], operands[1], operands[2], operands[3]));
     DONE;
}")

(define_expand "umodsi3_call"
  [(set (reg:SI ARG0_REGNO) (match_operand:SI 1 "register_operand" ""))
   (set (reg:SI ARG1_REGNO) (match_operand:SI 2 "register_operand" ""))
   (parallel [(set (reg:SI RET_REGNO)
		   (umod:SI (reg:SI ARG0_REGNO) (reg:SI ARG1_REGNO)))
	      (use (match_operand:SI 3 "register_operand" ""))
	      (use (reg:SI ARG0_REGNO))
	      (use (reg:SI ARG1_REGNO))
	      (clobber (reg:SI ARG0_REGNO))
	      (clobber (reg:SI ARG1_REGNO))
	      (clobber (reg:SI RA_REGNO))])
   (set (match_operand:SI 0 "register_operand" "") (reg:SI RET_REGNO))]
  ""
  "")

(define_insn "*umodsi3_call"
  [(set (reg:SI RET_REGNO)
	(umod:SI (reg:SI ARG0_REGNO) (reg:SI ARG1_REGNO)))
   (use (match_operand:SI 0 "register_operand" "r"))
   (use (reg:SI ARG0_REGNO))
   (use (reg:SI ARG1_REGNO))
   (clobber (reg:SI ARG0_REGNO))
   (clobber (reg:SI ARG1_REGNO))
   (clobber (reg:SI RA_REGNO))]
  ""
  "jsr %0"
  [(set_attr "length" "1")])

;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
; and

(define_insn "andsi3"
  [(set (match_operand:SI 0 "register_operand"          "=r,r")
        (and:SI (match_operand:SI 1 "register_operand"  "%0,0")
                (match_operand:SI 2 "nonmemory_operand"  "r,I")))]
  ""
  "*{
      switch (which_alternative)
        {
          case 0: output_asm_insn (\"and %0, %2\", operands);
            break;
          case 1: operands[2] = gen_rtx_CONST_INT (SImode, exact_log2(~INTVAL(operands[2])));
                  output_asm_insn (\"bclr %0, %2\", operands);
            break;
          default: gcc_unreachable();
        }
      return \"\";
}"
  [(set_attr "length" "1,1")])

(define_insn "andsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"           "=r,r")
	 (and:SI (match_operand:SI 1 "register_operand"   "%0,0")
		  (match_operand:SI 2 "nonmemory_operand"  "r,I"))))]
  ""
  "*{
      switch (which_alternative)
        {
          case 0: output_asm_insn (\"and_ct %0, %2\", operands);
            break;
          case 1: operands[2] = gen_rtx_CONST_INT (SImode, exact_log2(~INTVAL(operands[2])));
                  output_asm_insn (\"bclr_ct %0, %2\", operands);
            break;
          default: gcc_unreachable();
        }
      return \"\";
}"
  [(set_attr "length" "1,1")])

(define_insn "andsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"           "=r,r")
	 (and:SI (match_operand:SI 1 "register_operand"   "%0,0")
		  (match_operand:SI 2 "nonmemory_operand"  "r,I"))))]
  ""
  "*{
      switch (which_alternative)
        {
          case 0: output_asm_insn (\"and_cf %0, %2\", operands);
            break;
          case 1: operands[2] = gen_rtx_CONST_INT (SImode, exact_log2(~INTVAL(operands[2])));
                  output_asm_insn (\"bclr_cf %0, %2\", operands);
            break;
          default: gcc_unreachable();
        }
      return \"\";
}"
  [(set_attr "length" "1,1")])

(define_insn "anddi3"
  [(set (match_operand:DI 0 "register_operand"         "=&r")
        (and:DI (match_operand:DI 1 "register_operand"  "%0")
		(match_operand:DI 2 "register_operand"   "r")))]
  ""
  "and %A0,%A2\;and %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "anddi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (and:DI (match_operand:DI 1 "register_operand"  "%0")
		  (match_operand:DI 2 "register_operand"  "r"))))]
  ""
  "and_ct %A0,%A2\;and_ct %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "anddi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (and:DI (match_operand:DI 1 "register_operand"  "%0")
		  (match_operand:DI 2 "register_operand"  "r"))))]
  ""
  "and_cf %A0,%A2\;and_cf %B0,%B2"
  [(set_attr "length" "2")])

;;|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
;; ior

(define_insn "iorsi3"
  [(set (match_operand:SI 0 "register_operand"          "=r,r")
        (ior:SI (match_operand:SI 1 "register_operand"  "%0,0")
                (match_operand:SI 2 "nonmemory_operand"  "r,J")))]
  ""
  "*{
      switch (which_alternative)
        {
          case 0: output_asm_insn (\"or %0, %2\", operands);
            break;
          case 1: operands[2] = gen_rtx_CONST_INT (SImode, exact_log2(INTVAL(operands[2])));
                  output_asm_insn (\"bset %0, %2\", operands);
            break;
          default: gcc_unreachable();
        }
      return \"\";
}"
  [(set_attr "length" "1,1")])

(define_insn "iorsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"          "=r,r")
	 (ior:SI (match_operand:SI 1 "register_operand"  "%0,0")
		  (match_operand:SI 2 "nonmemory_operand" "r,J"))))]
  ""
  "*{
      switch (which_alternative)
        {
          case 0: output_asm_insn (\"or_ct %0, %2\", operands);
            break;
          case 1: operands[2] = gen_rtx_CONST_INT (SImode, exact_log2(INTVAL(operands[2])));
                  output_asm_insn (\"bset_ct %0, %2\", operands);
            break;
          default: gcc_unreachable();
        }
      return \"\";
}"
  [(set_attr "length" "1,1")])

(define_insn "iorsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"          "=r,r")
	 (ior:SI (match_operand:SI 1 "register_operand"  "%0,0")
		  (match_operand:SI 2 "nonmemory_operand" "r,J"))))]
  ""
  "*{
      switch (which_alternative)
        {
          case 0: output_asm_insn (\"or_cf %0, %2\", operands);
            break;
          case 1: operands[2] = gen_rtx_CONST_INT (SImode, exact_log2(INTVAL(operands[2])));
                  output_asm_insn (\"bset_cf %0, %2\", operands);
            break;
          default: gcc_unreachable();
        }
      return \"\";
}"
  [(set_attr "length" "1,1")])

(define_insn "iordi3"
  [(set (match_operand:DI 0 "register_operand"         "=&r")
        (ior:DI (match_operand:DI 1 "register_operand"  "%0")
		(match_operand:DI 2 "register_operand"   "r")))]
  ""
  "or %A0,%A2\;or %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "iordi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (ior:DI (match_operand:DI 1 "register_operand"  "%0")
		 (match_operand:DI 2 "register_operand"   "r"))))]
  ""
  "or_ct %A0,%A2\;or_ct %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "iordi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (ior:DI (match_operand:DI 1 "register_operand"  "%0")
		 (match_operand:DI 2 "register_operand"   "r"))))]
  ""
  "or_cf %A0,%A2\;or_cf %B0,%B2"
  [(set_attr "length" "2")])

;;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;; xor

(define_insn "xorsi3"
  [(set (match_operand:SI 0 "register_operand"         "=r")
        (xor:SI (match_operand:SI 1 "register_operand" "%0")
                (match_operand:SI 2 "register_operand"  "r")))]
  ""
  "eor %0,%2"
  [(set_attr "length" "1")])

(define_insn "xorsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"          "=r")
	 (xor:SI (match_operand:SI 1 "register_operand"  "%0")
		 (match_operand:SI 2 "register_operand"   "r"))))]
  ""
  "eor_ct %0,%2"
  [(set_attr "length" "1")])

(define_insn "xorsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"          "=r")
	 (xor:SI (match_operand:SI 1 "register_operand"  "%0")
		 (match_operand:SI 2 "register_operand"   "r"))))]
  ""
  "eor_cf %0,%2"
  [(set_attr "length" "1")])

(define_insn "xordi3"
  [(set (match_operand:DI 0 "register_operand"        "=&r")
        (xor:DI (match_operand:DI 1 "register_operand" "%0")
                (match_operand:DI 2 "register_operand"  "r")))]
  ""
  "eor %A0,%A2\;eor %B0,%B2"
  [(set_attr "length" "1")])

(define_insn "xordi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (xor:DI (match_operand:DI 1 "register_operand"  "%0")
		  (match_operand:DI 2 "register_operand"  "r"))))]
  ""
  "eor_ct %A0,%A2\;eor_ct %B0,%B2"
  [(set_attr "length" "2")])

(define_insn "xordi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"         "=&r")
	 (xor:DI (match_operand:DI 1 "register_operand"  "%0")
		  (match_operand:DI 2 "register_operand"  "r"))))]
  ""
  "eor_cf %A0,%A2\;eor_cf %B0,%B2"
  [(set_attr "length" "2")])

;;>>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>> >>>
;; lshr

(define_insn "lshrsi3"
  [(set (match_operand:SI 0 "register_operand"              "=r,r")
	(lshiftrt:SI (match_operand:SI 1 "register_operand"  "0,0")
		     (match_operand:SI 2 "nonmemory_operand" "r,P")))]
  ""
  "@
      sr %0, %2
      sri %0, %2"
  [(set_attr "length" "1,1")])

(define_insn "lshrsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"              "=r,r")
	 (lshiftrt:SI (match_operand:SI 1 "register_operand"  "0,0")
		      (match_operand:SI 2 "nonmemory_operand" "r,P"))))]
  ""
  "@
      sr_ct %0,%2
      sri_ct %0,%2"
  [(set_attr "length" "1,1")])

(define_insn "lshrsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"              "=r,r")
	 (lshiftrt:SI (match_operand:SI 1 "register_operand"  "0,0")
		      (match_operand:SI 2 "nonmemory_operand" "r,P"))))]
  ""
  "@
      sr_cf %0,%2
      sri_cf %0,%2"
  [(set_attr "length" "1,1")])

(define_expand "lshrdi3"
  [(set (match_operand:DI 0 "register_operand" "")
	(lshiftrt:DI (match_operand:DI 1 "register_operand" "")
		     (match_operand:SI 2 "nonmemory_operand" "")))]
  ""
  "{
     if ((GET_CODE (operand2) == CONST_INT) && (INTVAL (operand2) <= 3))
       {
         int i;
         int k = INTVAL (operand2);
         emit_move_insn (operands[0], operands[1]);
         for (i = 0; i < k; i++)
           {
             emit_insn (gen_lshrdi1 (operands[0], operands[0]));
           }
         DONE;
       }
     else
       {
         FAIL;
       }
}")

(define_insn "lshrdi1"
  [(set (match_operand:DI 0 "register_operand"              "=r,r")
	(lshiftrt:DI (match_operand:DI 1 "register_operand"  "0,0")
		     (const_int 1)))]
  ""
  "sri %B0, 1\;rrc %A0"
  [(set_attr "length" "2")])

(define_insn "lshrdi1<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"              "=r,r")
	 (lshiftrt:DI (match_operand:DI 1 "register_operand"  "0,0")
		      (const_int 1))))]
  ""
  "sri_ct %B0, 1\;rrc_ct %A0"
  [(set_attr "length" "2")])

(define_insn "lshrdi1<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"              "=r,r")
	 (lshiftrt:DI (match_operand:DI 1 "register_operand"  "0,0")
		      (const_int 1))))]
  ""
  "sri_cf %B0, 1\;rrc_cf %A0"
  [(set_attr "length" "2")])

;;>> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >>
;; ashr

(define_insn "ashrsi3"
  [(set (match_operand:SI 0 "register_operand"              "=r,r")
	(ashiftrt:SI (match_operand:SI 1 "register_operand"  "0,0")
		     (match_operand:SI 2 "nonmemory_operand" "r,P")))]
  ""
  "@
      sra %0, %2
      srai %0, %2"
  [(set_attr "length" "1,1")])

(define_insn "ashrsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"              "=r,r")
	 (ashiftrt:SI (match_operand:SI 1 "register_operand"  "0,0")
		      (match_operand:SI 2 "nonmemory_operand" "r,P"))))]
  ""
  "@
      sra_ct %0,%2
      srai_ct %0,%2"
  [(set_attr "length" "1,1")])

(define_insn "ashrsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"              "=r,r")
	 (ashiftrt:SI (match_operand:SI 1 "register_operand"  "0,0")
		      (match_operand:SI 2 "nonmemory_operand" "r,P"))))]
  ""
  "@
      sra_cf %0,%2
      srai_cf %0,%2"
  [(set_attr "length" "1,1")])

(define_expand "ashrdi3"
  [(set (match_operand:DI 0 "register_operand" "")
	(ashiftrt:DI (match_operand:DI 1 "register_operand" "")
		     (match_operand:SI 2 "nonmemory_operand" "")))]
  ""
  "{
     if ((GET_CODE (operand2) == CONST_INT) && (INTVAL (operand2) <= 3))
       {
         int i;
         int k = INTVAL (operand2);
         emit_move_insn (operands[0], operands[1]);
         for (i = 0; i < k; i++)
           {
             emit_insn (gen_ashrdi1 (operands[0], operands[0]));
           }
         DONE;
       }
     else
       {
         FAIL;
       }
}")

(define_insn "ashrdi1"
  [(set (match_operand:DI 0 "register_operand"              "=r,r")
	(ashiftrt:DI (match_operand:DI 1 "register_operand"  "0,0")
		     (const_int 1)))]
  ""
  "srai %B0, 1\;rrc %A0"
  [(set_attr "length" "2")])

(define_insn "ashrdi1<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"              "=r,r")
	 (ashiftrt:DI (match_operand:DI 1 "register_operand"  "0,0")
		      (const_int 1))))]
  ""
  "srai_ct %B0, 1\;rrc_ct %A0"
  [(set_attr "length" "2")])

(define_insn "ashrdi1<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"              "=r,r")
	 (ashiftrt:DI (match_operand:DI 1 "register_operand"  "0,0")
		      (const_int 1))))]
  ""
  "srai_cf %B0, 1\;rrc_cf %A0"
  [(set_attr "length" "2")])

;;<< << << << << << << << << << << << << << << << << << << << << << << <<
;; ashl

(define_insn "ashlsi3"
  [(set (match_operand:SI 0 "register_operand"            "=r,r")
	(ashift:SI (match_operand:SI 1 "register_operand"  "0,0")
		   (match_operand:SI 2 "nonmemory_operand" "r,P")))]
  ""
  "@
      sl %0, %2
      sli %0, %2"
  [(set_attr "length" "1,1")])

(define_insn "ashlsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"            "=r,r")
	 (ashift:SI (match_operand:SI 1 "register_operand"  "0,0")
		    (match_operand:SI 2 "nonmemory_operand" "r,P"))))]
  ""
  "@
      sl_ct %0,%2
      sli_ct %0,%2"
  [(set_attr "length" "1,1")])

(define_insn "ashlsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"            "=r,r")
	 (ashift:SI (match_operand:SI 1 "register_operand"  "0,0")
		    (match_operand:SI 2 "nonmemory_operand" "r,P"))))]
  ""
  "@
      sl_cf %0,%2
      sli_cf %0,%2"
  [(set_attr "length" "1,1")])

(define_expand "ashldi3"
  [(set (match_operand:DI 0 "register_operand" "")
	(ashift:DI (match_operand:DI 1 "register_operand" "")
		   (match_operand:SI 2 "nonmemory_operand" "")))]
  ""
  "{
     if ((GET_CODE (operand2) == CONST_INT) && (INTVAL (operand2) <= 3))
       {
         int i;
         int k = INTVAL (operand2);
         emit_move_insn (operands[0], operands[1]);
         for (i = 0; i < k; i++)
           {
             emit_insn (gen_ashldi1 (operands[0], operands[0]));
           }
         DONE;
       }
     else
       {
         FAIL;
       }
}")

(define_insn "ashldi1"
  [(set (match_operand:DI 0 "register_operand"            "=r,r")
	(ashift:DI (match_operand:DI 1 "register_operand"  "0,0")
		   (const_int 1)))]
  ""
  "sli %A0, 1\;addc %B0, %B0"
  [(set_attr "length" "2")])

(define_insn "ashldi1<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"            "=r,r")
	 (ashift:DI (match_operand:DI 1 "register_operand"  "0,0")
		    (const_int 1))))]
  ""
  "sli_ct %A0, 1\;addc_ct %B0, %B0"
  [(set_attr "length" "2")])

(define_insn "ashldi1<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"            "=r,r")
	 (ashift:DI (match_operand:DI 1 "register_operand"  "0,0")
		    (const_int 1))))]
  ""
  "sli_cf %A0, 1\;addc_cf %B0, %B0"
  [(set_attr "length" "2")])

;; 0 - x  0 - x  0 - x  0 - x  0 - x  0 - x  0 - x  0 - x  0 - x  0 - x  0 - x
;; neg

(define_insn "negsi2"
  [(set (match_operand:SI 0 "register_operand"         "=r")
        (neg:SI (match_operand:SI 1 "register_operand"  "0")))]
  ""
  "neg %0"
  [(set_attr "length" "1")])

(define_insn "negsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"          "=r")
	 (neg:SI (match_operand:SI 1 "register_operand"   "0"))))]
  ""
  "neg_ct %0"
  [(set_attr "length" "1")])

(define_insn "negsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"          "=r")
	 (neg:SI (match_operand:SI 1 "register_operand"   "0"))))]
  ""
  "neg_cf %0"
  [(set_attr "length" "1")])

;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; not

(define_insn "one_cmplsi2"
  [(set (match_operand:SI 0 "register_operand"         "=r")
        (not:SI (match_operand:SI 1 "register_operand"  "0")))]
  ""
  "not %0"
  [(set_attr "length" "1")])

(define_insn "one_cmplsi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"          "=r")
	 (not:SI (match_operand:SI 1 "register_operand"   "0"))))]
  ""
  "not_ct %0"
  [(set_attr "length" "1")])

(define_insn "one_cmplsi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:SI 0 "register_operand"          "=r")
	 (not:SI (match_operand:SI 1 "register_operand"   "0"))))]
  ""
  "not_cf %0"
  [(set_attr "length" "1")])

(define_insn "one_cmpldi2"
  [(set (match_operand:DI 0 "register_operand"         "=r")
        (not:DI (match_operand:DI 1 "register_operand"  "0")))]
  ""
  "not %A0\;not %B0"
  [(set_attr "length" "2")])

(define_insn "one_cmpldi3<straight_cond:code>"
  [(cond_exec
    (straight_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"          "=r")
	 (not:DI (match_operand:DI 1 "register_operand"   "0"))))]
  ""
  "not_ct %A0\;not_ct %B0"
  [(set_attr "length" "2")])

(define_insn "one_cmpldi3<inverted_cond:code>"
  [(cond_exec
    (inverted_cond:CC (reg:CC CC_REGNO)
		      (const_int 0))
    (set (match_operand:DI 0 "register_operand"          "=r")
	 (not:DI (match_operand:DI 1 "register_operand"   "0"))))]
  ""
  "not_cf %A0\;not_cf %B0"
  [(set_attr "length" "2")])

;;<=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=><=>
;; compare

(define_insn "cmpsi"
  [(set (reg:CC CC_REGNO)
	(compare:CC (match_operand:SI 0 "register_operand" "r,r")
		    (match_operand:SI 1 "nonmemory_operand" "r,K")))]
  ""
  "* return scarts32_out_compare(insn, operands);"
  [(set_attr "length" "1,2")])


(define_insn "cmpdi"
  [(set (reg:CC CC_REGNO)
	(compare:CC (match_operand:DI 0 "register_operand" "r")
		    (match_operand:DI 1 "register_operand" "r")))]
  ""
  "* return scarts32_out_compare(insn, operands);"
  [(set_attr "length" "7")])

(define_insn "btstsi"
  [(set (reg:CC CC_REGNO)
	(compare:CC (zero_extract:SI (match_operand:SI 0 "register_operand"  "r")
				     (const_int 1)
				     (match_operand:SI 1 "immediate_operand" "N"))
		    (const_int 0)))]
  ""
  "* return scarts32_out_bittest(insn, operands);"
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
  "* return scarts32_out_branch(insn, operands, <CODE>);"
  [(set (attr "length")
	(if_then_else (and (ge (minus (match_dup 0) (pc)) (const_int -512))
			   (lt (minus (match_dup 0) (pc)) (const_int 511)))
		      (const_int 1)
		      (const_int 7)))])

;; ----------------------------------------------------------------------
;; Unconditional jump instructions

;; jump

(define_insn "jump"
  [(set (pc)
        (label_ref (match_operand 0 "" "")))]
  ""
  "* return scarts32_out_jump(insn, operands);"
  [(set (attr "length")
	(if_then_else (and (ge (minus (match_dup 0) (pc)) (const_int -512))
			   (lt (minus (match_dup 0) (pc)) (const_int 511)))
		      (const_int 1)
		      (const_int 7)))])

; indirect jump
(define_insn "indirect_jump"
  [(set (pc) (match_operand:SI 0 "register_operand" "r"))]
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
