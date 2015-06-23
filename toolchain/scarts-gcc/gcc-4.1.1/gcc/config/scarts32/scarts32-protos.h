/* Prototypes for exported functions defined in scarts32.c
   Copyright (C) 2000, 2001, 2002, 2004, 2005 Free Software Foundation, Inc.
   Contributed by Wolfgang Puffitsch <hausen@gmx.at>

   This file is part of the SCARTS32 port of GCC

   GNU CC is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   GNU CC is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with GNU CC; see the file COPYING.  If not, write to
   the Free Software Foundation, 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.  */


extern int    function_arg_regno_p              (int r);
extern void   scarts32_override_options          (void);
extern void   scarts32_optimization_options	(int level, int size);
extern enum reg_class scarts32_regno_reg_class   (int r);
extern enum reg_class scarts32_reg_class_from_letter (int c);
extern int    scarts32_const_ok_for_letter       (HOST_WIDE_INT value, char c);
extern int    frame_pointer_required_p          (void);
extern int    scarts32_simple_epilogue           (void);
extern void   scarts32_output_ascii              (FILE *, const char *, size_t);
extern void   scarts32_output_aligned_common     (FILE *, const char *, int, int);
extern void   scarts32_output_aligned_local      (FILE *, const char *, int, int);
extern void   rodata_section                    (void);

#ifdef TREE_CODE
extern int    scarts32_progmem_p                 (tree decl);
extern void   scarts32_output_aligned_bss        (FILE *, tree, const char *, int, int);

#ifdef RTX_CODE /* inside TREE_CODE */
extern rtx    scarts32_function_value            (tree type, tree func);
extern void   init_cumulative_args              (CUMULATIVE_ARGS *cum, tree fntype, rtx libname, tree indirect);
extern rtx    function_arg                      (CUMULATIVE_ARGS *cum, enum machine_mode mode, tree type, int named);


#endif /* RTX_CODE inside TREE_CODE */

#ifdef HAVE_MACHINE_MODES /* inside TREE_CODE */
extern void   function_arg_advance              (CUMULATIVE_ARGS *cum, enum machine_mode mode, tree type, int named);
#endif /* HAVE_MACHINE_MODES inside TREE_CODE*/
#endif /* TREE_CODE */

#ifdef RTX_CODE
extern int    legitimate_address_p              (enum machine_mode mode, rtx x, int strict);

extern const char * scarts32_out_movqi           (rtx insn, rtx operands[], int alternative);
extern const char * scarts32_out_movhi           (rtx insn, rtx operands[], int alternative);
extern const char * scarts32_out_movsi           (rtx insn, rtx operands[], int alternative);
extern const char * scarts32_out_movdi           (rtx insn, rtx operands[], int alternative);

extern const char * scarts32_out_addsi           (rtx insn, rtx operands[], int alternative);

extern const char * scarts32_out_compare         (rtx insn, rtx operands[]);
extern const char * scarts32_out_bittest         (rtx insn, rtx operands[]);
extern const char * scarts32_out_branch          (rtx insn, rtx operands[], enum rtx_code code);
extern const char * scarts32_out_jump            (rtx insn, rtx operands[]);

extern int    extra_constraint                  (rtx x, int c);
extern rtx    legitimize_address                (rtx x, rtx oldx, enum machine_mode mode);
extern int    adjust_insn_length                (rtx insn, int len);
extern rtx    scarts32_libcall_value             (enum machine_mode mode);
extern rtx    scarts32_return_addr               (int, rtx);
extern int    initial_elimination_offset        (int, int);

extern void   print_operand                     (FILE *file, rtx x, int code);
extern int    scarts32_jump_mode                 (rtx x, rtx insn);
extern int    test_hard_reg_class               (enum reg_class class, rtx x);

extern int    call_insn_operand                 (rtx op, enum machine_mode mode);
extern void   final_prescan_insn                (rtx insn, rtx *operand, int num_operands);

#endif /* RTX_CODE */
