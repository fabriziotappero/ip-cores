
#include <stdio.h>
#include <string.h>
#include <assert.h>

#include "Backend.hh"
#include "Node.hh"

extern bool is_loader;
extern int  memtop;

int Backend::stack_pointer = 0;
int Backend::label_num = 1;
int Backend::function_num = 1;

//-----------------------------------------------------------------------------
int Backend::check_size(int size, const char * function)
{
   if (size == 1)   return  8;
   if (size == 2)   return 16;
   fprintf(stderr, "Backend::%s does not support %d bits\n",
           function, size * 8);
   return 0;
}
//-----------------------------------------------------------------------------
int Backend::check_size(SUW suw, const char * function)
{
   if (suw == SB)        return  8;
   else if (suw == UB)   return  8;
   else if (suw == WO)   return 16;
   assert(0);
}
//-----------------------------------------------------------------------------
void Backend::file_header()
{
   if (is_loader)
      fprintf(out,
           "IN_RX_DATA\t= 0x00\t\t\t;\n"
           "IN_STATUS\t= 0x01\t\t\t;\n"
	   "\n"
	   "MEMTOP\t\t= 0x%4.4X\n"
	   "\n"
           "OUT_TX_DATA\t= 0x00\t\t\t;\n"
           ";---------------------------------------;\n"
           "RELOC_SRC\t= start+Cend_text-stack\t;\n"
           ";---------------------------------------;\n"
           "\t\t\t\t\t;\n"
           "\tMOVE\t#reloc_rr, RR\t\t;\n"
           "\tMOVE\tRR, SP\t\t\t;\n"
           "\tMOVE\t#MEMTOP, LL\t\t; destination\n"
           "reloc:\t\t\t\t\t;\n"
           "\tMOVE\t(SP)+, RR\t\t; restore source\n"
           "\tMOVE\t-(RR), -(LL)\t\t;\n"
           "\tMOVE\tRR, -(SP)\t\t; save source\n"
           "\tSHI\tRR, #start\t\t;\n"
           "\tJMP\tRRNZ, reloc\t\t;\n"
           "\tMOVE\t#stack, RR\t\t;\n"
           "\tMOVE\tRR, SP\t\t\t;\n"
           "\tCALL\tCmain\t\t\t;\n"
           "halt:\t\t\t\t\t;\n"
           "\tHALT\t\t\t\t;\n"
           "reloc_rr:\t\t\t\t; source\n"
           "\t.WORD\tRELOC_SRC\t\t;\n"
           ";---------------------------------------;\n"
           "start:\t\t\t\t\t;\n"
           "\t.OFFSET\tMEMTOP\t\t\t;\n"
           "stack:\t\t\t\t\t;\n"
           ";---------------------------------------;\n", memtop);
   else
      fprintf(out,
           "IN_RX_DATA\t\t= 0x00\t\t;\n"
           "IN_STATUS\t\t= 0x01\t\t;\n"
           "IN_TEMPERAT\t\t= 0x02\t\t;\n"
           "IN_DIP_SWITCH\t\t= 0x03\t\t;\n"
           "IN_CLK_CTR_LOW\t\t= 0x05\t\t;\n"
           "IN_CLK_CTR_HIGH\t\t= 0x06\t\t;\n"
	   "\n"
	   "MEMTOP\t=0x%4.4X\n"
	   "\n"
           "OUT_TX_DATA\t\t= 0x00\t\t;\n"
           "OUT_LEDS\t\t= 0x02\t\t;\n"
           "OUT_INT_MASK\t\t= 0x03\t\t;\n"
           "OUT_RESET_TIMER\t\t= 0x04\t\t;\n"
           "OUT_START_CLK_CTR\t= 0x05\t\t;\n"
           "OUT_STOP_CLK_CTR\t= 0x06\t\t;\n"
           ";---------------------------------------;\n"
           "\tMOVE\t#MEMTOP, RR\t\t;\n"
           "\tMOVE\tRR, SP\t\t\t;\n"
           "\tEI\t\t\t\t;\n"
           "\tJMP\tCmain\t\t\t;\n"
           "\tJMP\tCinterrupt\t\t;\n"
           ";---------------------------------------;\n"
           "mult_div:\t\t\t\t;\n"
           "\tMD_STP\t\t\t\t; 1\n"
           "\tMD_STP\t\t\t\t; 2\n"
           "\tMD_STP\t\t\t\t; 3\n"
           "\tMD_STP\t\t\t\t; 4\n"
           "\tMD_STP\t\t\t\t; 5\n"
           "\tMD_STP\t\t\t\t; 6\n"
           "\tMD_STP\t\t\t\t; 7\n"
           "\tMD_STP\t\t\t\t; 8\n"
           "\tMD_STP\t\t\t\t; 9\n"
           "\tMD_STP\t\t\t\t; 10\n"
           "\tMD_STP\t\t\t\t; 11\n"
           "\tMD_STP\t\t\t\t; 12\n"
           "\tMD_STP\t\t\t\t; 13\n"
           "\tMD_STP\t\t\t\t; 14\n"
           "\tMD_STP\t\t\t\t; 15\n"
           "\tMD_STP\t\t\t\t; 16\n"
           "\tRET\t\t\t\t;\n"
           ";---------------------------------------;\n", memtop);
}
//-----------------------------------------------------------------------------
void Backend::file_footer()
{
   fprintf(out, "Cend_text:\t\t\t\t;\n");
}
//-----------------------------------------------------------------------------
int Backend::new_function(const char * fname)
{
   fprintf(out, "C%s:\n", fname);
   fflush(out);
   assert(stack_pointer == 0);
   function_num++;
}
//-----------------------------------------------------------------------------
void Backend::asmbl(const char * asm_string)
{
   if (*asm_string == ' ')   fprintf(out, "\t%s\n", asm_string + 1);
   else                      fprintf(out, "%s\n", asm_string);

char buffer[256];
int bufidx = 0;
bool inside = true;

   for (;;)
      {
        char c = *asm_string++;
        switch(c)
           {
             case 0:
             case '\r':
             case '\n': buffer[bufidx] = 0;
                        asm_adjust(buffer);
                        bufidx = 0;
                        inside = true;
                        if (c == 0)   return;
                        break;

             case ';' : inside = false;
                        break;

             case ' ':  break;   // ignore spaces

             default:   assert(bufidx < (sizeof(buffer) - 3));
                        if (inside)   buffer[bufidx++] = c;
           }
      }
}
//-----------------------------------------------------------------------------
void Backend::asm_adjust(const char * asm_line)
{
int osp = stack_pointer;
bool need_adjust = false;

   if (strstr(asm_line, "-(SP)"))
      {
        need_adjust = true;
        if      (strstr(asm_line, "RR,"))     stack_pointer -= 2;
        else if (strstr(asm_line, "R,"))      stack_pointer -= 1;
        else if (strstr(asm_line, "CLRW"))   stack_pointer -= 2;
        else if (strstr(asm_line, "CLRB"))   stack_pointer -= 1;
      }

   if (strstr(asm_line, "(SP)+"))
      {
        need_adjust = true;
        if      (strstr(asm_line, ",RR"))    stack_pointer += 2;
        else if (strstr(asm_line, ",RS"))    stack_pointer += 1;
        else if (strstr(asm_line, ",RU"))    stack_pointer += 1;
        else if (strstr(asm_line, ",LL"))    stack_pointer += 2;
        else if (strstr(asm_line, ",LS"))    stack_pointer += 1;
        else if (strstr(asm_line, ",LU"))    stack_pointer += 1;
      }

   if (need_adjust && osp == stack_pointer)
      {
        fprintf(out, "Bad ASM()\n");
        Node::Error();
      }
}
//-----------------------------------------------------------------------------
void Backend::load_rr_string(int snum, int offset)
{
   fprintf(out, ";--\tload_rr_string\n");

   if (offset)   fprintf(out, "\tMOVE\t#Cstr_%d + %d, RR\n", snum, offset);
   else          fprintf(out, "\tMOVE\t#Cstr_%d, RR\n", snum);
}
//-----------------------------------------------------------------------------
void Backend::load_ll_string(int snum, int offset)
{
   fprintf(out, ";--\tload_ll_string\n");

   if (offset)   fprintf(out, "\tMOVE\t#Cstr_%d + %d, LL\n", snum, offset);
   else          fprintf(out, "\tMOVE\t#Cstr_%d, LL\n", snum);
}
//-----------------------------------------------------------------------------
void Backend::load_rr_constant(int constant)
{
   fprintf(out, ";--\tload_rr_constant\n");
   fprintf(out, "\tMOVE\t#0x%4.4X, RR\n", constant & 0xFFFF);
}
//-----------------------------------------------------------------------------
void Backend::load_ll_constant(int constant)
{
   fprintf(out, ";--\tload_ll_constant\n");
   fprintf(out, "\tMOVE\t#0x%4.4X, LL\n", constant & 0xFFFF);
}
//-----------------------------------------------------------------------------
void Backend::load_rr_var(const char * name, SUW suw)
{
   fprintf(out, ";--\tload_rr_var %s, (%d bit)\n",
                name, check_size(suw, "load_rr_var"));
   if      (suw == SB)   fprintf(out, "\tMOVE\t(C%s), RS\n", name);
   else if (suw == UB)   fprintf(out, "\tMOVE\t(C%s), RU\n", name);
   else                  fprintf(out, "\tMOVE\t(C%s), RR\n", name);
}
//-----------------------------------------------------------------------------
void Backend::load_ll_var(const char * name, SUW suw)
{
   fprintf(out, ";--\tload_ll_var %s, (%d bit)\n",
                name, check_size(suw, "load_ll_var"));
   if      (suw == SB)   fprintf(out, "\tMOVE\t(C%s), LS\n", name);
   else if (suw == UB)   fprintf(out, "\tMOVE\t(C%s), LU\n", name);
   else                  fprintf(out, "\tMOVE\t(C%s), LL\n", name);
}
//-----------------------------------------------------------------------------
void Backend::load_rr_var(const char * name, int sp_off, SUW suw)
{
   fprintf(out, ";--\tload_rr_var %s = %d(FP), SP at %d (%d bit)\n",
                name, sp_off, GetSP(), check_size(suw, "load_rr_var"));

   sp_off -= GetSP();
   if (suw == SB)        fprintf(out, "\tMOVE\t%d(SP), RS\n", sp_off);
   else if (suw == UB)   fprintf(out, "\tMOVE\t%d(SP), RU\n", sp_off);
   else                  fprintf(out, "\tMOVE\t%d(SP), RR\n", sp_off);
}
//-----------------------------------------------------------------------------
void Backend::load_ll_var(const char * name, int sp_off, SUW suw)
{
   fprintf(out, ";--\tload_ll_var %s = %d(FP), SP at %d (%d bit)\n",
                name, sp_off, GetSP(), check_size(suw, "load_ll_var"));

   sp_off -= GetSP();
   if      (suw == SB)   fprintf(out, "\tMOVE\t%d(SP), LS\n", sp_off);
   else if (suw == UB)   fprintf(out, "\tMOVE\t%d(SP), LU\n", sp_off);
   else                  fprintf(out, "\tMOVE\t%d(SP), LL\n", sp_off);
}
//-----------------------------------------------------------------------------
void Backend::store_rr_var(const char * name, SUW suw)
{
   fprintf(out, ";--\tstore_rr_var %s\n", name);
   if (suw == WO)   fprintf(out, "\tMOVE\tRR, (C%s)\n", name);
   else             fprintf(out, "\tMOVE\tR, (C%s)\n", name);
}
//-----------------------------------------------------------------------------
void Backend::store_rr_var(const char * name, int sp_off, SUW suw)
{
   fprintf(out, ";--\tstore_rr_var %s = %d(FP), SP at %d\n",
		name, sp_off, GetSP());

   sp_off -= GetSP();
   if (suw == WO)   fprintf(out, "\tMOVE\tRR, %d(SP)\n", sp_off);
   else             fprintf(out, "\tMOVE\tR, %d(SP)\n", sp_off);
}
//-----------------------------------------------------------------------------
void Backend::load_address(const char * name)
{
   fprintf(out, ";--\tload_address %s\n", name);
   fprintf(out, "\tMOVE\t#C%s, RR\n", name);
}
//-----------------------------------------------------------------------------
void Backend::load_address(const char * name, int sp_offset)
{
   fprintf(out, ";--\tload_address %s = %d(FP), SP at %d\n",
		name, sp_offset, GetSP());
   fprintf(out, "\tLEA\t%d(SP), RR\n", sp_offset - GetSP());
}
//-----------------------------------------------------------------------------
void Backend::add_address(const char * name)
{
   fprintf(out, ";--\tadd_address %s\n", name);
   fprintf(out, "\tADD\tRR, #C%s\n", name);
}
//-----------------------------------------------------------------------------
void Backend::assign(int size)
{
   fprintf(out, ";--\tassign (%d bit)\n", check_size(size, "assign"));
   if (size == 1)   fprintf(out, "\tMOVE\tR, (LL)\n");
   else             fprintf(out, "\tMOVE\tRR, (LL)\n");
}
//-----------------------------------------------------------------------------
void Backend::call(const char * name)
{
   fprintf(out, ";--\tcall\n");
   fprintf(out, "\tCALL\tC%s\n", name);
}
//-----------------------------------------------------------------------------
void Backend::call_ptr()
{
   fprintf(out, ";--\tcall_ptr\n");
   fprintf(out, "\tCALL\t(RR)\n");
}
//-----------------------------------------------------------------------------
void Backend::ret()
{
   fprintf(out, ";--\tret\n");

   assert(stack_pointer <= 0);
   // pop, but don't update stack_pointer

   if (stack_pointer)   fprintf(out, "\tADD\tSP, #%d\n", -stack_pointer);
   fprintf(out, "\tRET\n");
}
//-----------------------------------------------------------------------------
void Backend::push_rr(SUW suw)
{
   fprintf(out, ";--\tpush_rr (%d bit)\n", check_size(suw, "push_rr"));
   if (suw == WO)   fprintf(out, "\tMOVE\tRR, -(SP)\n");
   else             fprintf(out, "\tMOVE\tR, -(SP)\n");

   stack_pointer--;
   if (suw == WO)   stack_pointer--;
}
//-----------------------------------------------------------------------------
void Backend::pop_rr(SUW suw)
{
   fprintf(out, ";--\tpop_rr (%d bit)\n", check_size(suw, "pop_rr"));
   if      (suw == SB)   fprintf(out, "\tMOVE\t(SP)+, RS\n");
   else if (suw == UB)   fprintf(out, "\tMOVE\t(SP)+, RU\n");
   else                  fprintf(out, "\tMOVE\t(SP)+, RR\n");

   stack_pointer++;
   if (suw == WO)   stack_pointer++;
}
//-----------------------------------------------------------------------------
void Backend::pop_ll(SUW suw)
{
   fprintf(out, ";--\tpop_ll (%d bit)\n", check_size(suw, "pop_ll"));
   if      (suw == SB)   fprintf(out, "\tMOVE\t(SP)+, LS\n");
   else if (suw == UB)   fprintf(out, "\tMOVE\t(SP)+, LU\n");
   else                  fprintf(out, "\tMOVE\t(SP)+, LL\n");

   stack_pointer++;
   if (suw == WO)   stack_pointer++;
}
//-----------------------------------------------------------------------------
void Backend::pop(int pushed)
{
   fprintf(out, ";--\tpop %d bytes\n", pushed);
   assert(pushed >= 0);
   stack_pointer += pushed;

   if (pushed)   fprintf(out, "\tADD\tSP, #%d\n", pushed);
}
//-----------------------------------------------------------------------------
void Backend::pop_jump(int diff)
{
   fprintf(out, ";--\tpop (break/continue) %d bytes\n", diff);
   assert(diff >= 0);
   // don't update stack_pointer !

   if (diff)   fprintf(out, "\tADD\tSP, #%d\n", diff);
}
//-----------------------------------------------------------------------------
void Backend::pop_return(int ret_bytes)
{
   fprintf(out, ";--\tpop_return %d bytes\n", ret_bytes);
   if (ret_bytes > 4)   pop(ret_bytes);
}
//-----------------------------------------------------------------------------
int Backend::push_return(int ret_bytes)
{
   fprintf(out, ";--\tpush %d bytes\n", ret_bytes);
   if (ret_bytes <= 4)   return 0;
   push_zero(ret_bytes);
   return ret_bytes;
}
//-----------------------------------------------------------------------------
void Backend::push_zero(int bytes)
{
   fprintf(out, ";--\tpush_zero %d bytes\n", bytes);
   stack_pointer -= bytes;   // doesn't really matter

   for (; bytes > 1; bytes -= 2)   fprintf(out, "\tCLRW\t-(SP)\n");
   if (bytes)                      fprintf(out, "\tCLRB\t-(SP)\n");
}
//-----------------------------------------------------------------------------
void Backend::move_rr_to_ll()
{
   fprintf(out, ";--\tmove_rr_to_ll\n");
   fprintf(out, "\tMOVE\tRR, LL\n");
}
//-----------------------------------------------------------------------------
void Backend::label(int lab)
{
   fprintf(out, "L%d_%d:\n", function_num, lab);
}
//-----------------------------------------------------------------------------
void Backend::label(const char * name)
{
   fprintf(out, "L%d_%s:\n", function_num, name);
}
//-----------------------------------------------------------------------------
void Backend::label(const char * name, int loop)
{
   fprintf(out, "L%d_%s_%d:\n", function_num, name, loop);
}
//-----------------------------------------------------------------------------
void Backend::label(const char * name, int loop, int value)
{
   fprintf(out, "L%d_%s_%d_%4.4X:\n", function_num, name, loop, value & 0xFFFF);
}
//-----------------------------------------------------------------------------
void Backend::branch(int lab)
{
   fprintf(out, ";--\tbranch\n");
   fprintf(out, "\tJMP\tL%d_%d\n", function_num, lab);
}
//-----------------------------------------------------------------------------
void Backend::branch(const char * name)
{
   fprintf(out, ";--\tbranch\n");
   fprintf(out, "\tJMP\tL%d_%s\n", function_num, name);
}
//-----------------------------------------------------------------------------
void Backend::branch(const char * name, int loop)
{
   fprintf(out, ";--\tbranch\n");
   fprintf(out, "\tJMP\tL%d_%s_%d\n", function_num, name, loop);
}
//-----------------------------------------------------------------------------
void Backend::branch_true(const char * name, int loop, int size)
{
   fprintf(out, ";--\tbranch_true\n");
   fprintf(out, "\tJMP\tRRNZ, L%d_%s_%d\n", function_num, name, loop);
}
//-----------------------------------------------------------------------------
void Backend::branch_false(const char * name, int loop, int size)
{
   fprintf(out, ";--\tbranch_false\n");
   fprintf(out, "\tJMP\tRRZ, L%d_%s_%d\n", function_num, name, loop);
}
//-----------------------------------------------------------------------------
void Backend::branch_case(const char * name, int loop, int size, int value)
{
int bits = check_size(size, "branch_case");

   fprintf(out, ";--\tbranch_case (%d bit)\n", bits);
   fprintf(out, "\tSEQ\tLL, #0x%4.4X\n", value & 0xFFFF);
   fprintf(out, "\tJMP\tRRNZ, L%d_%s_%d_%4.4X\n",
		function_num, name, loop, value & 0xFFFF);
}
//-----------------------------------------------------------------------------
void Backend::compute_unary(int what, const char * pretty)
{
const char * opc = "???";

   fprintf(out, ";--\t16 bit %s\n", pretty);
   switch(what)
      {
         case ET_LOG_NOT:    opc = "LNOT";      break;
         case ET_NEGATE:     opc = "NEG";      break;
         case ET_COMPLEMENT: opc = "NOT";      break;

         default:
              assert(0 && "Bad unary what");
              break;
      }
   fprintf(out, "\t%s\tRR\n", opc);
}
//-----------------------------------------------------------------------------
//  constant right side (non-constant operand in RR !)
//
void Backend::compute_binary(int what, bool uns, const char * pretty, int value)
{
const char * opc = "???";

   fprintf(out, ";--\t%s\n", pretty);
   switch(what)
      {
         case ET_BIT_OR:        opc = "OR";                  break;
         case ET_BIT_AND:       opc = "AND";                 break;
         case ET_BIT_XOR:       opc = "XOR";                 break;
         case ET_LEFT:          opc = "LSL";                 break;
         case ET_EQUAL:         opc = "SEQ";                 break;
         case ET_NOT_EQUAL:     opc = "SNE";                 break;
	 case ET_LESS_EQUAL:    opc = uns ? "SLS" : "SLE";   break;
	 case ET_LESS:          opc = uns ? "SLO" : "SLT";   break;
	 case ET_GREATER_EQUAL: opc = uns ? "SHS" : "SGE";   break;
	 case ET_GREATER:       opc = uns ? "SHI" : "SGT";   break;
         case ET_RIGHT:         opc = uns ? "LSR" : "ASR";   break;

         case ET_ADD:           if (value == 0)              return;
                                opc = "ADD";
                                if (value > 0)               break;
                                opc = "SUB";
                                value = - value;             break;

         case ET_SUB:           if (value == 0)              return;
                                opc = "SUB";
                                if (value > 0)               break;
                                opc = "ADD";
                                value = - value;             break;


         case ET_MULT:             // expr * const
              switch(value & 0xFFFF)   // special cases
                 {
                   case 0x0000: fprintf(out, "\tMOVE\t#0, RR\n");
                        return;

                   case 0x0001: case 0x0002: case 0x0004: case 0x0008:
                   case 0x0010: case 0x0020: case 0x0040: case 0x0080:
                   case 0x0100: case 0x0200: case 0x0400: case 0x0800:
                   case 0x1000: case 0x2000: case 0x4000:
                        mult_shift(value, false);
                        return;

                   case 0xFFFF: case 0xFFFE: case 0xFFFC: case 0xFFF8:
                   case 0xFFF0: case 0xFFE0: case 0xFFC0: case 0xFF80:
                   case 0xFF00: case 0xFE00: case 0xFC00: case 0xF800:
                   case 0xF000: case 0xE000: case 0xC000: case 0x8000:
                        mult_shift(-value, true);
                        return;
                 }

              fprintf(out, "\tMOVE\tRR, LL\n");
              fprintf(out, "\tMOVE\t#0x%4.4X, RR\n", value & 0xFFFF);
              compute_binary(what, uns, pretty);
              return;

         case ET_DIV:              // expr / const
              switch(value & 0xFFFF)   // special cases
                 {
                   case 0x0000: assert(0 && "Division by 0");

                   case 0x0001: case 0x0002: case 0x0004: case 0x0008:
                   case 0x0010: case 0x0020: case 0x0040: case 0x0080:
                   case 0x0100: case 0x0200: case 0x0400: case 0x0800:
                   case 0x1000: case 0x2000: case 0x4000:
                        div_shift(value, false, uns);
                        return;

                   case 0xFFFF: case 0xFFFE: case 0xFFFC: case 0xFFF8:
                   case 0xFFF0: case 0xFFE0: case 0xFFC0: case 0xFF80:
                   case 0xFF00: case 0xFE00: case 0xFC00: case 0xF800:
                   case 0xF000: case 0xE000: case 0xC000: case 0x8000:
                        div_shift(-value, true, uns);
                        return;
                 }

              fprintf(out, "\tMOVE\tRR, LL\n");
              fprintf(out, "\tMOVE\t#0x%4.4X, RR\n", value & 0xFFFF);
              compute_binary(what, uns, pretty);
              return;

         case ET_MOD:              // expr % const
              switch(value & 0xFFFF)   // special cases
                 {
                   case 0x0000: assert(0 && "Division by 0");

                   case 0x0001: case 0x0002: case 0x0004: case 0x0008:
                   case 0x0010: case 0x0020: case 0x0040: case 0x0080:
                   case 0x0100: case 0x0200: case 0x0400: case 0x0800:
                   case 0x1000: case 0x2000: case 0x4000:
                        mod_and(value, false, uns);
                        return;

                   case 0xFFFF: case 0xFFFE: case 0xFFFC: case 0xFFF8:
                   case 0xFFF0: case 0xFFE0: case 0xFFC0: case 0xFF80:
                   case 0xFF00: case 0xFE00: case 0xFC00: case 0xF800:
                   case 0xF000: case 0xE000: case 0xC000: case 0x8000:
                        mod_and(-value, true, uns);
                        return;
                 }

              fprintf(out, "\tMOVE\tRR, LL\n");
              fprintf(out, "\tMOVE\t#0x%4.4X, RR\n", value & 0xFFFF);
              compute_binary(what, uns, pretty);
              return;

         default:
              assert(0 && "Bad what");
              return;
      }

   fprintf(out, "\t%s\tRR, #0x%4.4X\n", opc, value & 0xFFFF);
}
//-----------------------------------------------------------------------------
void Backend::mult_shift(int value, bool negative)
{
   assert(value >= 0);
   if (negative)   fprintf(out, "\tNEG\tRR\n");

   switch(value)   // special cases
      {
        case 0x0001:                                     return;
        case 0x0002:  fprintf(out, "\tLSL\tRR, #1\n");   return;
        case 0x0004:  fprintf(out, "\tLSL\tRR, #2\n");   return;
        case 0x0008:  fprintf(out, "\tLSL\tRR, #3\n");   return;
        case 0x0010:  fprintf(out, "\tLSL\tRR, #4\n");   return;
        case 0x0020:  fprintf(out, "\tLSL\tRR, #5\n");   return;
        case 0x0040:  fprintf(out, "\tLSL\tRR, #6\n");   return;
        case 0x0080:  fprintf(out, "\tLSL\tRR, #7\n");   return;
        case 0x0100:  fprintf(out, "\tLSL\tRR, #8\n");   return;
        case 0x0200:  fprintf(out, "\tLSL\tRR, #9\n");   return;
        case 0x0400:  fprintf(out, "\tLSL\tRR, #10\n");  return;
        case 0x0800:  fprintf(out, "\tLSL\tRR, #11\n");  return;
        case 0x1000:  fprintf(out, "\tLSL\tRR, #12\n");  return;
        case 0x2000:  fprintf(out, "\tLSL\tRR, #13\n");  return;
        case 0x4000:  fprintf(out, "\tLSL\tRR, #14\n");  return;
        case 0x8000:  fprintf(out, "\tLSL\tRR, #15\n");  return;
        default:      assert(0);
      }
}
//-----------------------------------------------------------------------------
void Backend::div_shift(int value, bool negative, bool uns)
{
   assert(value >= 0);
   if (negative)   fprintf(out, "\tNEG\tRR\n");

const char * op = "ASR";
   if (uns)  op = "LSR";

   switch(value)   // special cases
      {
        case 0x0001:                                         return;
        case 0x0002:  fprintf(out, "\t%s\tRR, #1\n",  op);   return;
        case 0x0004:  fprintf(out, "\t%s\tRR, #2\n",  op);   return;
        case 0x0008:  fprintf(out, "\t%s\tRR, #3\n",  op);   return;
        case 0x0010:  fprintf(out, "\t%s\tRR, #4\n",  op);   return;
        case 0x0020:  fprintf(out, "\t%s\tRR, #5\n",  op);   return;
        case 0x0040:  fprintf(out, "\t%s\tRR, #6\n",  op);   return;
        case 0x0080:  fprintf(out, "\t%s\tRR, #7\n",  op);   return;
        case 0x0100:  fprintf(out, "\t%s\tRR, #8\n",  op);   return;
        case 0x0200:  fprintf(out, "\t%s\tRR, #9\n",  op);   return;
        case 0x0400:  fprintf(out, "\t%s\tRR, #10\n", op);   return;
        case 0x0800:  fprintf(out, "\t%s\tRR, #11\n", op);   return;
        case 0x1000:  fprintf(out, "\t%s\tRR, #12\n", op);   return;
        case 0x2000:  fprintf(out, "\t%s\tRR, #13\n", op);   return;
        case 0x4000:  fprintf(out, "\t%s\tRR, #14\n", op);   return;
        case 0x8000:  fprintf(out, "\t%s\tRR, #15\n", op);   return;
        default:      assert(0);
      }
}
//-----------------------------------------------------------------------------
void Backend::mod_and(int value, bool negative, bool uns)
{
   assert(value >= 0);
   if (negative)   fprintf(out, "\tNEG\tRR\n");

   switch(value)   // special cases
      {
        case 0x0001:  fprintf(out, "\tMOVE\t#0,  RR\n");     return;
        case 0x0002:  fprintf(out, "\tAND\tRR, #0x0001\n");  return;
        case 0x0004:  fprintf(out, "\tAND\tRR, #0x0003\n");  return;
        case 0x0008:  fprintf(out, "\tAND\tRR, #0x0007\n");  return;
        case 0x0010:  fprintf(out, "\tAND\tRR, #0x000F\n");  return;
        case 0x0020:  fprintf(out, "\tAND\tRR, #0x001F\n");  return;
        case 0x0040:  fprintf(out, "\tAND\tRR, #0x003F\n");  return;
        case 0x0080:  fprintf(out, "\tAND\tRR, #0x007F\n");  return;
        case 0x0100:  fprintf(out, "\tAND\tRR, #0x00FF\n");  return;
        case 0x0200:  fprintf(out, "\tAND\tRR, #0x01FF\n");  return;
        case 0x0400:  fprintf(out, "\tAND\tRR, #0x03FF\n");  return;
        case 0x0800:  fprintf(out, "\tAND\tRR, #0x07FF\n");  return;
        case 0x1000:  fprintf(out, "\tAND\tRR, #0x0FFF\n");  return;
        case 0x2000:  fprintf(out, "\tAND\tRR, #0x1FFF\n");  return;
        case 0x4000:  fprintf(out, "\tAND\tRR, #0x3FFF\n");  return;
        case 0x8000:  fprintf(out, "\tAND\tRR, #0x7FFF\n");  return;
        default:      assert(0);
      }
}
//-----------------------------------------------------------------------------
//  constant left side (non-constant operand in RR !)
//
void Backend::compute_binary(int what, bool uns, int value, const char * pretty)
{
   // symmetric operators: exchange left and right...
   //
   switch(what)
      {
         case ET_BIT_OR:
         case ET_BIT_AND:
         case ET_BIT_XOR:
         case ET_ADD:
         case ET_MULT:
         case ET_EQUAL:
         case ET_NOT_EQUAL:
              compute_binary(what, uns, pretty, value);             return;

         case ET_LESS_EQUAL:
              compute_binary(ET_GREATER, uns, ">", value);          return;

         case ET_LESS:
              compute_binary(ET_GREATER_EQUAL, uns, ">=", value);   return;

         case ET_GREATER_EQUAL:
              compute_binary(ET_LESS, uns, "<", value);             return;

         case ET_GREATER:
              compute_binary(ET_LESS_EQUAL, uns, "<=", value);      return;
      }

   // assymmetric operators: load constant and call non-const operator
   //
   switch(what)
      {
         case ET_SUB:
         case ET_LEFT:
         case ET_RIGHT:
         case ET_DIV:
         case ET_MOD:
              fprintf(out, "\tMOVE\t#0x%4.4X, LL\n", value & 0xFFFF);
              compute_binary(what, uns, pretty);
              return;
      }

   assert(0 && "Bad what");
}
//-----------------------------------------------------------------------------
void Backend::compute_binary(int what, bool uns, const char * pretty)
{
const char * opc = "???";

   fprintf(out, ";--\t%s\n", pretty);
   switch(what)
      {
         case ET_BIT_OR:        opc = "OR";                   break;
         case ET_BIT_AND:       opc = "AND";                  break;
         case ET_BIT_XOR:       opc = "XOR";                  break;
         case ET_ADD:           opc = "ADD";                  break;
         case ET_SUB:           opc = "SUB";                  break;
         case ET_EQUAL:         opc = "SEQ";                  break;
         case ET_NOT_EQUAL:     opc = "SNE";                  break;
	 case ET_LESS_EQUAL:    opc = uns ? "SLS" : "SLE";   break;
	 case ET_LESS:          opc = uns ? "SLO" : "SLT";   break;
	 case ET_GREATER_EQUAL: opc = uns ? "SHS" : "SGE";   break;
	 case ET_GREATER:       opc = uns ? "SHI" : "SGT";   break;

         case ET_MULT:             // expr * expr
	      fprintf(out, "\tDI\n");
              if (uns)   fprintf(out, "\tMUL_IU\n");
	      else       fprintf(out, "\tMUL_IS\n");
	      fprintf(out, "\tCALL\tmult_div\n");
	      fprintf(out, "\tMD_FIN\n");
	      fprintf(out, "\tEI\n");
              return;

         case ET_DIV:              // expr / expr
	      fprintf(out, "\tDI\n");
              if (uns)   fprintf(out, "\tDIV_IU\n");
	      else       fprintf(out, "\tDIV_IS\n");
	      fprintf(out, "\tCALL\tmult_div\n");
	      fprintf(out, "\tMD_FIN\n");
	      fprintf(out, "\tEI\n");
              return;

         case ET_MOD:              // expr % expr
	      fprintf(out, "\tDI\n");
              if (uns)   fprintf(out, "\tDIV_IU\n");
	      else       fprintf(out, "\tDIV_IS\n");
	      fprintf(out, "\tCALL\tmult_div\n");
	      fprintf(out, "\tMOD_FIN\n");
	      fprintf(out, "\tEI\n");
              return;

         default:
              assert(0 && "Bad what");
              break;
      }

   fprintf(out, "\t%s\tLL, RR\n", opc);
}
//-----------------------------------------------------------------------------
void Backend::content(SUW suw)
{
   check_size(suw, "content");
   fprintf(out, ";--\tcontent\n");
   if      (suw == SB)   fprintf(out, "\tMOVE\t(RR), RS\n");
   else if (suw == UB)   fprintf(out, "\tMOVE\t(RR), RU\n");
   else                  fprintf(out, "\tMOVE\t(RR), RR\n");
}
//-----------------------------------------------------------------------------
void Backend::scale_rr(int size)
{
   assert(size > 0);
   fprintf(out, ";--\tscale_rr *%d\n", size);

   if (size == 1)   return;
   check_size(size, "scale_rr");

   compute_binary(ET_MULT, false, "*", size);
   // fprintf(out, "\tLSL\tRR, #%d\n", size);
}
//-----------------------------------------------------------------------------
void Backend::unscale_rr(int size, bool uns)
{
   assert(size > 0);
   fprintf(out, ";--\tscale *%d\n", size);

   if (size == 1)   return;
   check_size(size, "unscale_rr");

   compute_binary(ET_DIV, uns, "/", size);
   // if (uns)   fprintf(out, "\tLSR\tRR, #%d\n", size);
   // else       fprintf(out, "\tASR\tRR, #%d\n", size);
}
//-----------------------------------------------------------------------------
