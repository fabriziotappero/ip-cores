// Statement.cc

#include <stdio.h>
#include <assert.h>
#include "Node.hh"
#include "Name.hh"
#include "Backend.hh"

class LoopStack
{
public:
   LoopStack(int num, LoopStack * prev)
   : number(num),
     stack_depth(Backend::GetSP()),
     previous(prev)
     {};

   static int Push(LoopStack * & stack);
   static void Pop(LoopStack * & stack, int val);
   static int GetNumber(LoopStack * stack)
      { assert(stack);   return stack->number; };
   static int GetStackDepth(LoopStack * stack)
      { assert(stack);   return stack->stack_depth; };

private:
   int number;
   int stack_depth;
   LoopStack * previous;

   static int next_number;
};

int LoopStack::next_number = 1;

LoopStack * loop_stack  = 0;
LoopStack * break_stack = 0;

//-----------------------------------------------------------------------------
int LoopStack::Push(LoopStack * & stack)
{
   stack = new LoopStack(next_number++, stack);
   return stack->number;
}
//-----------------------------------------------------------------------------
void LoopStack::Pop(LoopStack * & stack, int val)
{
   assert(stack);
   assert(val == stack->number);

LoopStack * del = stack;
   stack = stack->previous;
   delete del;
}
//=============================================================================
void ExpressionStatement::Emit(FILE * out)
{
   EmitStart(out);
   if (expression)   expression->Emit(out);
   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void SwitchStatement::Emit(FILE * out)
{
const int brk = LoopStack::Push(break_stack);

   EmitStart(out);

   assert(condition);
   condition->Emit(out);
   Backend::move_rr_to_ll();

   assert(case_stat);
   case_stat->EmitCaseJumps(out, condition->GetSize());

   EmitEnd(out);

   LoopStack::Pop(break_stack, brk);
}
//-----------------------------------------------------------------------------
void IfElseStatement::Emit(FILE * out)
{
const int loop = LoopStack::Push(loop_stack);   // just get a number
   LoopStack::Pop(loop_stack, loop);

   EmitStart(out);
   assert(condition);
   condition->Emit(out);

const int size = condition->GetSize();

   if (if_stat)
      {
        if (else_stat)   // if and else
           {
             Backend::branch_false("else", loop, size);
             if_stat->Emit(out);
             Backend::branch("endif", loop);
             Backend::label("else", loop);
             else_stat->Emit(out);
             Backend::label("endif", loop);
           }
        else             // if only
           {
             Backend::branch_false("endif", loop, size);
             if_stat->Emit(out);
             Backend::label("endif", loop);
           }
      }
   else
      {
        if (else_stat)   // else only
           {
             Backend::branch_true("endif", loop, size);
	     else_stat->Emit(out);
             Backend::label("endif", loop);
           }
        else             // nothing
           {
           }
      }

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void DoWhileStatement::Emit(FILE * out)
{
const int loop = LoopStack::Push(loop_stack);
const int brk  = LoopStack::Push(break_stack);

   EmitStart(out);

   assert(condition);
   assert(body);

const int size = condition->GetSize();

   Backend::label("loop", loop);
   body->Emit(out);

   Backend::label("cont", loop);
   condition->Emit(out);
   Backend::branch_true("loop", loop, size);

   Backend::label("brk", brk);

   EmitEnd(out);

   LoopStack::Pop(break_stack, brk);
   LoopStack::Pop(loop_stack, loop);
}
//-----------------------------------------------------------------------------
void WhileStatement::Emit(FILE * out)
{
const int loop = LoopStack::Push(loop_stack);
const int brk  = LoopStack::Push(break_stack);

   EmitStart(out);

   assert(condition);
   assert(body);

const int size = condition->GetSize();

   if (body->NotEmpty())   Backend::branch("cont", loop);

   Backend::label("loop", loop);
   body->Emit(out);

   Backend::label("cont", loop);
   condition->Emit(out);
   Backend::branch_true("loop", loop, size);

   Backend::label("brk", brk);

   EmitEnd(out);

   LoopStack::Pop(break_stack,  brk);
   LoopStack::Pop(loop_stack, loop);
}
//-----------------------------------------------------------------------------
void ForStatement::Emit(FILE * out)
{
const int loop = LoopStack::Push(loop_stack);
const int brk  = LoopStack::Push(break_stack);

   EmitStart(out);

   assert(for_1);
   assert(for_2);
   assert(body);

Expression * cond = for_2->GetExpression();

int size = 0;
   if (cond)   size = cond->GetSize();

   for_1->Emit(out);

   if (cond)   Backend::branch("tst", loop);

   Backend::label("loop", loop);
   body->Emit(out);

   Backend::label("cont", loop);
   if (for_3)   for_3->Emit(out);


   if (cond)
      {
        Backend::label("tst", loop);
        cond->Emit(out);
        Backend::branch_true("loop", loop, size);
      }
   else
      {
        Backend::branch("loop", loop);
      }

   Backend::label("brk", brk);

   EmitEnd(out);

   LoopStack::Pop(break_stack, brk);
   LoopStack::Pop(loop_stack, loop);
}
//-----------------------------------------------------------------------------
void LabelStatement::Emit(FILE * out)
{
   EmitStart(out);

   assert(label_name);
   assert(statement);

   Backend::label(label_name);
   statement->Emit(out);

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void GotoStatement::Emit(FILE * out)
{
   EmitStart(out);

   assert(label_name);

   Backend::branch(label_name);

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void ReturnStatement::Emit(FILE * out)
{
   EmitStart(out);

   if (retval)   retval->Emit(out);

   Backend::ret();

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void ContStatement::Emit(FILE * out)
{
   EmitStart(out);

LoopStack * ls;
const char * ln;

   if (do_break)   { ls = break_stack;   ln = "brk"; }
   else            { ls = loop_stack;    ln = "cont"; };

const int stack_diff = LoopStack::GetStackDepth(ls) - Backend::GetSP();

   if (stack_diff < 0)
      {
        fprintf(stderr, "Jump over initialization\n");
        semantic_errors++;
      }
   
   if (stack_diff > 0)   Backend::pop_jump(stack_diff);
   Backend::branch(ln, LoopStack::GetNumber(ls));

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void CompoundStatement::Emit(FILE * out)
{
   EmitStart(out);

   Name::PushContext();

const int autosize = EmitAutovars(out);

   if (stat_list)   stat_list->Emit(out);

   Backend::pop(autosize);

   Name::PopContext();
   EmitEnd(out);
}
//-----------------------------------------------------------------------------
int CompoundStatement::EmitAutovars(FILE * out)
{
int ret = 0;

   for (DeclarationList * d = decl_list; d; d = d->Tail())
       {
         Declaration * di = d->Head();
         assert(di);
	 int len = di->EmitAutovars(out);
	 assert(len > 0);
         ret += len;
       }

   return ret;
}
//-----------------------------------------------------------------------------
void CompoundStatement::EmitCaseJumps(FILE * out, int size)
{
const int brk = LoopStack::GetNumber(break_stack);

bool has_default = false;

   for (StatementList * sl = stat_list; sl; sl = sl->Tail())
       {
         Statement * s = sl->Head();
         assert(s);
         s->EmitCaseJump(out, false, brk, size);
       }

   for (StatementList * sl = stat_list; sl; sl = sl->Tail())
       {
         Statement * s = sl->Head();
         assert(s);
         if (s->EmitCaseJump(out, true, brk, size))   has_default = true;
       }

   if (!has_default)
      {
        Backend::branch("brk", brk);
      }

   Emit(out);

   Backend::label("brk", brk);
}
//-----------------------------------------------------------------------------
void CaseStatement::Emit(FILE * out)
{
const int brk = LoopStack::GetNumber(break_stack);

   EmitStart(out);
   if (case_value)
      {
        if (case_value->IsConstant())
           {
             const int value = case_value->GetConstantNumericValue();
             Backend::label("case", brk, value);
           }
	else
           {
             fprintf(stderr, "Case value not constant\r\n");
             semantic_errors++;
           }
      }
   else
      {
        Backend::label("deflt", brk);
      }

   if (statement)   statement->Emit(out);
   EmitEnd(out);
}
//-----------------------------------------------------------------------------
//
// return true iff this is a default clause
//
bool CaseStatement::EmitCaseJump(FILE * out, bool def, int loop, int size)
{
bool ret = false;

   if (def)   // default branch
      {
        if (!case_value)   { Backend::branch("deflt", loop);   ret = true; }
      }
   else       // case branch
      {
        if (case_value)
           {
             if (!case_value->IsConstant())
                {
                  fprintf(stderr, "case value not constant\r\n");
                  semantic_errors++;
                  return false;
                }

             const int value = case_value->GetConstantNumericValue();
             Backend::branch_case("case", loop, size, value);
           }
      }

   if (statement)   ret = ret || statement->EmitCaseJump(out, def, loop, size);
   return ret;
}
//-----------------------------------------------------------------------------
