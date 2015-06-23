
#include <stdio.h>
#include <assert.h>

#include "Node.hh"

enum Size
{
   SIZE_CHAR     = 1,
   SIZE_SHORT    = 2,
   SIZE_LONG     = 4,

   SIZE_INT      = SIZE_SHORT,
   SIZE_POINTER  = SIZE_INT
};

extern FILE * out;

class Backend
{
public:
   static int  check_size(int size, const char * function);
   static int  check_size(SUW suw,  const char * function);
   static void file_header();
   static void file_footer();

   static void load_rr_string(int snum, int offset);
   static void load_ll_string(int snum, int offset);
   static void load_rr_constant(int constant);
   static void load_ll_constant(int constant);

   static void load_rr_var(const char * name, SUW suw);
   static void load_ll_var(const char * name, SUW suw);
   static void load_rr_var(const char * name, int sp_offset, SUW suw);
   static void load_ll_var(const char * name, int sp_offset, SUW suw);

   static void store_rr_var(const char * name, SUW suw);
   static void store_rr_var(const char * name, int sp_offset, SUW suw);

   static void load_address(const char * name);
   static void add_address(const char * name);
   static void load_address(const char * name, int sp_offset);
   static void assign(int size);

   static void call(const char * name);
   static void call_ptr();
   static void ret();

   static void push_rr(SUW suw);
   static void pop_rr (SUW suw);
   static void pop_ll (SUW suw);
   static void pop(int pushed);
   static void pop_jump(int diff);
   static void pop_return(int ret_bytes);
   static int  push_return(int ret_bytes);
   static void push_zero(int bytes);

   static void move_rr_to_ll();

   static void compute_unary(int what, const char * pretty);
   static void compute_binary(int what, bool uns, const char * pretty);
   static void compute_binary(int what, bool uns, const char * pretty,
		              int value);
   static void mult_shift(int value, bool negative);
   static void div_shift(int value, bool negative, bool uns);
   static void mod_and(int value, bool negative, bool uns);

   static void compute_binary(int what, bool uns, int value,
		              const char * pretty);
   static void content(SUW suw);
   static void scale_rr(int size);
   static void unscale_rr(int size, bool uns);

   static void asmbl(const char * asm_string);
   static void asm_adjust(const char * asm_line);
   static void label(int lab);
   static void label(const char * name);
   static void label(const char * name, int loop);
   static void label(const char * name, int loop, int value);
   static void branch(int lab);
   static void branch(const char * name, int loop);
   static void branch(const char * name);
   static void branch_true(const char * name, int loop, int size);
   static void branch_false(const char * name, int lab, int size);
   static void branch_case(const char * name, int loop, int size, int value);
   static int  GetSP()       { return stack_pointer; };
   static int  get_label()   { return label_num++; };
   static int  new_function(const char * fname);

private:
   static int stack_pointer;
   static int label_num;
   static int function_num;
};
