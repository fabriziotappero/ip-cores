// Expression.cc

#include <stdio.h>
#include <assert.h>
#include "Node.hh"
#include "Name.hh"
#include "Backend.hh"

//-----------------------------------------------------------------------------
Expression * NumericExpression::OptNegate()
{
   int_value->Negate();
   return this;
}
//-----------------------------------------------------------------------------
Expression * NumericExpression::OptComplement()
{
   int_value->Complement();
   return this;
}
//-----------------------------------------------------------------------------
Expression * NumericExpression::OptLogNot()
{
   int_value->LogNot();
   return this;
}
//-----------------------------------------------------------------------------
TypeName * NumericExpression::SetType()
{
   assert(int_value);
   return new TypeName(TS_INT);
}
//-----------------------------------------------------------------------------
void NumericExpression::EmitInitialization(FILE * out, int size)
{
const int value = int_value->GetValue();
   assert(int_value);
   if (size == 1)        fprintf(out, "\t.BYTE\t%d\n", value);
   else if (size == 2)   fprintf(out, "\t.WORD\t%d\n", value);
   else                  assert(0 && "Bad size");
}
//-----------------------------------------------------------------------------
NumericExpression::NumericExpression(TypeName * t)
   : Expression("NumericExpression (sizeof type)")
{
   assert(t);
   int_value = new NumericConstant(t->GetSize());
}
//-----------------------------------------------------------------------------
NumericExpression::NumericExpression(Expression * r)
   : Expression("NumericExpression (sizeof expr)"),
     int_value(0)
{
   assert(r);

   int_value = new NumericConstant(r->GetSize());
}
//-----------------------------------------------------------------------------
const char * NumericExpression::GetPretty(int val)
{
char * cp = new char[50];
   assert(cp);
   sprintf(cp, "NumericExpression (constant %d = 0x%X)", val, val);
   return cp;

}
//-----------------------------------------------------------------------------
NumericExpression::NumericExpression(NumericConstant * n)
   : Expression(GetPretty(n->GetValue())),
      int_value(n)
{
   assert(n);
}
//-----------------------------------------------------------------------------
NumericExpression::NumericExpression(int value)
   : Expression(GetPretty(value)),
     int_value(0)
{
   int_value = new NumericConstant(value);
}
//-----------------------------------------------------------------------------
StringExpression::StringExpression(StringConstant * s)
   : Expression("StringExpression"),
     string_constant(s)
{
}
//-----------------------------------------------------------------------------
TypeName * StringExpression::SetType()
{
/*
TypeSpecifier * con = new TypeSpecifier(TQ_CONST);
Ptr * ptr           = new Ptr(con);
Pointer * pointer   = new Pointer(ptr, 0);
DeclItem * di       = new DeclItem(pointer);
Declarator * decl   = new Declarator(di, 0);
TypeSpecifier * ts  = new TypeSpecifier(TS_CHAR);
*/

char * name = new char[10];
   assert(string_constant);
   sprintf(name, "Cstr_%d", string_constant->GetStringNumber());

const int len = string_constant->GetLength() + 1;   // 1 for terminatin 0
Expression * lex = new NumericExpression(len);

TypeSpecifier * ts  = new TypeSpecifier(TS_CHAR);

DeclItem * na_it = new DeclItem(name);
DeclItem * ar_it = new DeclItem(lex);

Declarator * ar_dcl = new Declarator(ar_it, 0);
Declarator * na_dcl = new Declarator(na_it, ar_dcl);
   return new TypeName(ts, na_dcl);
}
//-----------------------------------------------------------------------------
void StringExpression::EmitInitialization(FILE * out, int size)
{
   assert(string_constant);
   assert(size == 2);
   fprintf(out, "\t.WORD\tCstr_%d\n", string_constant->GetStringNumber());
}
//-----------------------------------------------------------------------------
TypeName * IdentifierExpression::SetType()
{
   assert(varname);
TypeName * ret = Name::FindType(varname);

   if (ret)   return ret;

   fprintf(stderr, "Symbol '%s' not declared\n", varname);
   semantic_errors++;
   return new TypeName(TS_INT);
}
//-----------------------------------------------------------------------------
MemberExpression::MemberExpression(bool is_pointer, Expression * l,
		                   const char * s)
   : Expression("Expression l.member"),
     membername(s),
     left(l)
{
   if (is_pointer)   // map l->s to (*l).s
      {
        left = UnaryExpression::New(ET_CONTENT, left);
      }
}
//-----------------------------------------------------------------------------
TypeName * MemberExpression::SetType()
{
   assert(left);
   return left->GetType()->GetMemberType(membername);
}
//-----------------------------------------------------------------------------
void MemberExpression::Emit(FILE * out)
{
   EmitAddress(out, true);
}
//-----------------------------------------------------------------------------
void MemberExpression::EmitAddress(FILE * out)
{
   EmitAddress(out, false);
}
//-----------------------------------------------------------------------------
void MemberExpression::EmitAddress(FILE * out, bool content)
{
   assert(membername);

TypeName * struct_type = left->GetType();
   assert(struct_type);

   if (!struct_type->IsStruct())
      {
        fprintf(stderr, "request for member %s of non-struct\n", membername);
        semantic_errors++;
      }

TypeSpecifier * ts = struct_type->GetTypeSpecifier();
   assert(ts);

const char * sname = ts->GetName();
   if (sname == 0)
      {
        fprintf(stderr, "No struct name in member expression\n");
        semantic_errors++;
        return;
      }

StructDeclarationList * sdl = StructName::Find(sname);
   if (sdl == 0)
      {
        fprintf(stderr, "No struct %s defined\n", sname);
        semantic_errors++;
        return;
      }

int position = -1;
TypeName * membtype = 0;

   for (; sdl; sdl = sdl->Tail())
       {
         StructDeclaration * sd = sdl->Head();
         assert(sd);
         position = sd->GetMemberPosition(sname, membername, ts->IsUnion());
         if (position == -1)   continue;

         membtype = sd->GetMemberType(sname, membername);
         assert(membtype);
         break;
       }

   if (!membtype) 
      {
        fprintf(stderr, "struct %s has no member %s\n", sname, membername);
        semantic_errors++;
        return;
      }

   left->EmitAddress(out);
   Backend::compute_binary(ET_ADD, true, position, "+ (member)");
   if (content)   Backend::content(membtype->GetSUW());
}
//-----------------------------------------------------------------------------
Expression * UnaryExpression::New(UnaExprType et, Expression * r)
{
   assert(r);

   if (r->IsConstant())
      {
        switch(et)
           {
             case ET_CONJUGATE:  return r;
             case ET_NEGATE:     return r->OptNegate();
             case ET_COMPLEMENT: return r->OptComplement();
             case ET_LOG_NOT:    return r->OptLogNot();
           }
      }

   switch(et)
      {
	case ET_POSTINC:   // x++ = ++x - 1
             {
               Expression * pre = UnaryExpression::New(ET_PREINC, r);
               NumericConstant   * num = new NumericConstant(1);
               NumericExpression * one = new NumericExpression(num);
               return SubtractionExpression::New(pre, one);
             }

	case ET_POSTDEC:   // x-- = --x + 1
             {
               Expression * pre = UnaryExpression::New(ET_PREDEC, r);
               NumericConstant   * num = new NumericConstant(1);
               NumericExpression * one = new NumericExpression(num);
               return AdditionExpression::New(pre, one);
             }
      }

   return new UnaryExpression(et, r);
}
//-----------------------------------------------------------------------------
TypeName * UnaryExpression::SetType()
{
   assert(right);
   switch(expr_type)
      {
        case ET_CONJUGATE:
        case ET_NEGATE:
        case ET_COMPLEMENT:
	case ET_PREINC:
	case ET_PREDEC:
	case ET_POSTINC:
	case ET_POSTDEC:
             return right->GetType();

        case ET_LOG_NOT:
             return new TypeName(TS_INT);

        case ET_ADDRESS:
             return right->GetType()->AddressOf();

        case ET_CONTENT:
             return right->GetType()->ContentOf();

        default: assert(0 && "Bad unary operator");
      }
}
//-----------------------------------------------------------------------------
UnaryExpression::UnaryExpression(TypeName * t, Expression * r)
   : Expression("Expression (cast)r"),
     expr_type(ET_CAST),
     right(r)
{
   assert(right);
   Expression::SetType(t);
}
//-----------------------------------------------------------------------------
Expression * AdditionExpression::New(Expression * l, Expression * r)
{
   if (l->IsVariable() && l->IsArray())
      {
         l = UnaryExpression::New(ET_ADDRESS, l);
      }

   if (r->IsVariable() && r->IsArray())
      {
         r = UnaryExpression::New(ET_ADDRESS, r);
      }

   if (l->IsNumericConstant() && r->IsNumericConstant())
      {
        const int lval = l->GetConstantNumericValue();
        const int rval = r->GetConstantNumericValue();
        delete l;
        delete r;
        return new NumericExpression(lval + rval);
      }

   return new AdditionExpression(l, r);
}
//-----------------------------------------------------------------------------
Expression * SubtractionExpression::New(Expression * l, Expression * r)
{
   if (l->IsNumericConstant() && r->IsNumericConstant())
      {
        const int lval = l->GetConstantNumericValue();
        const int rval = r->GetConstantNumericValue();
        delete l;
        delete r;
        return new NumericExpression(lval - rval);
      }

   return new SubtractionExpression(l, r);
}
//-----------------------------------------------------------------------------
Expression * BinaryExpression::New(BinExprType et, Expression * l,
                                   Expression * r)
{
   assert(l);
   if (!r)   return new BinaryExpression(et, l, r);   // function call

   if (l->IsNumericConstant() && r->IsNumericConstant())
      {
        const int lval = l->GetConstantNumericValue();
        const int rval = r->GetConstantNumericValue();
        switch(et)
           {
             case ET_LIST:
                  delete l;
                  return r;

             case ET_BIT_OR:
                  delete l;
                  delete r;
                  return new NumericExpression(lval | rval);

             case ET_BIT_AND:
                  delete l;
                  delete r;
                  return new NumericExpression(lval & rval);

             case ET_BIT_XOR:
                  delete l;
                  delete r;
                  return new NumericExpression(lval ^ rval);

             case ET_LOG_OR:
                  delete l;
                  delete r;
                  if (lval || rval)   return new NumericExpression(-1);
                  return new NumericExpression(0);

             case ET_LOG_AND:
                  delete l;
                  delete r;
                  if (lval || rval)   return new NumericExpression(-1);
                  return new NumericExpression(0);

             case ET_EQUAL:
                  delete l;
                  delete r;
                  if (lval == rval)   return new NumericExpression(-1);
                  return new NumericExpression(0);

             case ET_NOT_EQUAL:
                  delete l;
                  delete r;
                  if (lval != rval)   return new NumericExpression(-1);
                  return new NumericExpression(0);

             case ET_LESS_EQUAL:
                  delete l;
                  delete r;
                  if (lval <= rval)   return new NumericExpression(-1);
                  return new NumericExpression(0);

             case ET_LESS:
                  delete l;
                  delete r;
                  if (lval < rval)   return new NumericExpression(-1);
                  return new NumericExpression(0);

             case ET_GREATER_EQUAL:
                  delete l;
                  delete r;
                  if (lval >= rval)   return new NumericExpression(-1);
                  return new NumericExpression(0);

             case ET_GREATER:
                  delete l;
                  delete r;
                  if (lval > rval)   return new NumericExpression(-1);
                  return new NumericExpression(0);

             case ET_LEFT:
                  delete l;
                  delete r;
                  return new NumericExpression(lval << rval);

             case ET_RIGHT:
                  delete l;
                  delete r;
                  return new NumericExpression(lval >> rval);

             case ET_MULT:
                  delete l;
                  delete r;
                  return new NumericExpression(lval * rval);

             case ET_DIV:
                  delete l;
                  delete r;
                  assert(rval);
                  return new NumericExpression(lval / rval);

             case ET_MOD:
                  delete l;
                  delete r;
                  assert(rval);
                  return new NumericExpression(lval % rval);
           }
      }

   if (l->IsNumericConstant())
      {
        const int lval = l->GetConstantNumericValue();
        switch(et)
           {
             case ET_LIST:
                  delete l;
                  return r;

             case ET_LOG_OR:
                  delete l;
                  if (lval == 0)   return r;
                  delete r;
                  return  new NumericExpression(-1);

             case ET_LOG_AND:
                  delete l;
                  if (lval != 0)   return r;
                  delete r;
                  return  new NumericExpression(0);
           }
      }
   else if (l->IsConstant())   // otherwise string (pointer) : always nonzero
      {
        assert(l->IsStringConstant());
        switch(et)
           {
             case ET_LOG_OR:
                  delete l;
                  delete r;
                  return new NumericExpression(-1);

             case ET_LOG_AND:
                  delete l;
                  return r;

             case ET_LIST:
                  delete l;
                  return r;
           }
      }

   if (r->IsNumericConstant())
      {
        const int rval = r->GetConstantNumericValue();
        switch(et)
           {
             case ET_LOG_OR:
                  if (!rval)   return l;
                  break;

             case ET_LOG_AND:
                  if (rval)   return l;
                  break;

           }
      }
   else if (r->IsConstant())   // otherwise string (pointer) : always nonzero
      {
        assert(r->IsStringConstant());
        switch(et)
           {
             case ET_LOG_AND:   return r;
           }
      }

   return new BinaryExpression(et, l, r);
}
//-----------------------------------------------------------------------------
BinaryExpression::BinaryExpression(BinExprType et,
                                   Expression * l, Expression * r)
   : Expression(GetPrettyName(GetPretty(et))),
     expr_type(et),
     left(l),
     right(r)
{
   switch(expr_type)
      {
        case ET_ADD_ASSIGN:       // expr +=  expr
             right = AdditionExpression::New(l, right);
             expr_type = ET_ASSIGN;
             return;

        case ET_SUB_ASSIGN:       // expr -=  expr
             right = SubtractionExpression::New(l, right);
             expr_type = ET_ASSIGN;
             return;

        case ET_MULT_ASSIGN:      // expr *=  expr
        case ET_DIV_ASSIGN:       // expr /=  expr
        case ET_MOD_ASSIGN:       // expr %=  expr
        case ET_LEFT_ASSIGN:      // expr <<= expr
        case ET_RIGHT_ASSIGN:     // expr >>= expr
        case ET_AND_ASSIGN:       // expr &=  expr
        case ET_XOR_ASSIGN:       // expr ^=  expr
        case ET_OR_ASSIGN:        // expr |=  expr
             right = new BinaryExpression(MapAssign(expr_type), l, right);
             expr_type = ET_ASSIGN;
             return;
      }
}
//-----------------------------------------------------------------------------
TypeName * BinaryExpression::SetType()
{
   assert(left);
   assert(right || expr_type == ET_FUNCALL);   // zero if no args

   switch(expr_type)
      {
        case ET_LIST:             // expr  ,  expr
        case ET_LEFT:             // expr <<  expr
        case ET_RIGHT:            // expr >>  expr
             return right->GetType();

        case ET_ASSIGN:           // expr  =  expr
             return left->GetType();

        case ET_EQUAL:            // expr ==  expr
        case ET_NOT_EQUAL:        // expr !=  expr
        case ET_LESS_EQUAL:       // expr <=  expr
        case ET_LESS:             // expr <   expr
        case ET_GREATER_EQUAL:    // expr >=  expr
        case ET_GREATER:          // expr >   expr
        case ET_BIT_OR:           // expr |   expr
        case ET_BIT_AND:          // expr &   expr
        case ET_BIT_XOR:          // expr ^   expr
        case ET_MULT:             // expr *   expr
        case ET_DIV:              // expr /   expr
        case ET_MOD:              // expr %   expr
             return MaxType(left, right);

        case ET_LOG_OR:           // expr ||  expr
        case ET_LOG_AND:          // expr &&  expr
             return new TypeName(TS_INT);

        case ET_FUNCALL:          // expr (   ... )
             return left->FunReturnType();

        case ET_ELEMENT:          // expr [ expr ]
             return left->GetType()->ContentOf();
      }
   assert(0 && "Bad binary operator");
}
//-----------------------------------------------------------------------------
TypeName * AdditionExpression::SetType()
{
   assert(left);
   assert(right);

   if (left->GetType()->IsNumericType() && right->GetType()->IsNumericType())
      return MaxType(left, right);

   if (left ->GetType()->IsNumericType())   return right->GetType();
   if (right->GetType()->IsNumericType())   return left ->GetType();

   fprintf(stderr, "Illegal pointer arithmetic\n");
   semantic_errors++;
   return new TypeName(TS_INT);
}
//-----------------------------------------------------------------------------
TypeName * SubtractionExpression::SetType()
{
   assert(left);
   assert(right);

   if (left->GetType()->IsNumericType() && right->GetType()->IsNumericType())
      return MaxType(left, right);

   if (left ->GetType()->IsNumericType())   return right->GetType();
   if (right->GetType()->IsNumericType())   return left ->GetType();

   // TODO: check pointer compatibility
   return new TypeName(TS_INT);
}
//-----------------------------------------------------------------------------
TypeName * CondExpression::SetType()
{
   // TODO: check argument compatibility
   return right->GetType();
}
//-----------------------------------------------------------------------------
TypeName * ArgListExpression::SetType()
{
   assert(0);
   return 0;
}
//-----------------------------------------------------------------------------
void Expression::SetType(TypeName * t)
{
   assert(!type_name);
   type_name = t;
   assert(type_name);
}
//-----------------------------------------------------------------------------
TypeName * Expression::GetType()
{
   if (!type_name)   type_name = SetType();
	   
   assert(type_name);
   return type_name;
}
//-----------------------------------------------------------------------------
bool Expression::IsPointer()
{
   return GetType()->IsPointer();
}
//-----------------------------------------------------------------------------
bool Expression::IsArray()
{
   return GetType()->IsArray();
}
//-----------------------------------------------------------------------------
bool Expression::IsUnsigned()
{
   return GetType()->IsUnsigned();
}
//-----------------------------------------------------------------------------
int Expression::PointeeSize()
{
   return GetType()->GetPointeeSize();
}
//-----------------------------------------------------------------------------
int Expression::GetSize()
{
   return GetType()->GetSize();
}
//-----------------------------------------------------------------------------
SUW Expression::GetSUW()
{
   return GetType()->GetSUW();
}
//-----------------------------------------------------------------------------
void IdentifierExpression::Emit(FILE * out)
{
   assert(this);
   assert(varname);
   EmitStart(out);
   EmitIndent(out);
   fprintf(out, "expr_type = \"identifier\" (%s)\n", varname);

const int spos = Name::FindPos(varname);
   if (spos == 1)
      {
        fprintf(stderr, "Variable %s not declared\n", varname);
        semantic_errors++;
      }
   else
      {
        if (spos == 0)   Backend::load_rr_var(varname,       GetSUW());
        else             Backend::load_rr_var(varname, spos, GetSUW());
      }

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void IdentifierExpression::Emit_to_ll(FILE * out)
{
   assert(this);
   EmitStart(out);
   EmitIndent(out);
   fprintf(out, "expr_type = \"identifier\" (%s)\n", varname);

   assert(varname);
const int spos = Name::FindPos(varname);
   if (spos == 1)
      {
        fprintf(stderr, "Variable %s not declared\n", varname);
        semantic_errors++;
      }
   else
      {
        if (spos == 0)   Backend::load_ll_var(varname,       GetSUW());
        else             Backend::load_ll_var(varname, spos, GetSUW());
      }

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void StringExpression::Emit(FILE * out)
{
   assert(this);
   EmitStart(out);

   assert(string_constant);
   string_constant->EmitValue_RR(out);

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void StringExpression::EmitAddress(FILE * out)
{
   assert(this);
   EmitStart(out);

   assert(string_constant);
   string_constant->EmitValue_RR(out);

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void StringExpression::Emit_to_ll(FILE * out)
{
   assert(this);
   EmitStart(out);

   assert(string_constant);
   string_constant->EmitValue_LL(out);

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void NumericExpression::Emit(FILE * out)
{
   assert(this);
   assert(int_value);
   EmitStart(out);

   assert(int_value);
   int_value->EmitValue_RR(out);

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void NumericExpression::Emit_to_ll(FILE * out)
{
   assert(this);
   assert(int_value);
   EmitStart(out);

   assert(int_value);
   int_value->EmitValue_LL(out);

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void CondExpression::Emit(FILE * out)
{
   assert(this);
   EmitStart(out);

   assert(left);
   assert(middle);
   assert(right);
   ExpressionStatement sm(middle);
   ExpressionStatement sr(right);
   IfElseStatement     sel(left, &sm, &sr);
   sel.Emit(out);

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void BinaryExpression::EmitAddress(FILE * out)
{
   assert(this);
   assert(left);
   EmitStart(out);

   switch(expr_type)
      {
         case ET_ELEMENT:             // expr[expr]
              {
                if (left->IsPointer())
                   {
                     assert(right);
                     right->Emit(out);
                     Backend::scale_rr(left->GetType()->GetPointeeSize());
                     Backend::push_rr(WO);
                     left->Emit(out);
                     Backend::pop_ll(WO);
                     Backend::compute_binary(ET_ADD, true, "+ (element)");
                   }
                else if (left->IsArray())
                   {
                     assert(right);
                     right->Emit(out);
                     Backend::scale_rr(left->GetType()->GetPointeeSize());
                     left->AddAddress(out);
                   }
                else
                   {
                     left->GetType()->Print(out);
                     fprintf(stderr, " is not a pointer\n");
                     semantic_errors++;
                   }
              }
              break;

         default:
              fprintf(stderr, "'expr %s expr' is not an lvalue\n",
                      GetPretty(expr_type));
              semantic_errors++;
              break;
      }
   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void UnaryExpression::EmitAddress(FILE * out)
{
   assert(this);
   EmitStart(out);

   assert(right);
   switch(expr_type)
      {
         case ET_CAST:             // (type)   expr
         case ET_CONJUGATE:        //      +   expr
         case ET_LOG_NOT:          //      !   expr
         case ET_NEGATE:           //      -   expr
         case ET_COMPLEMENT:       //      ~   expr
              fprintf(stderr, "'%s expr' is not an lvalue\n",
		GetPretty(expr_type));
              semantic_errors++;
              break;

         case ET_CONTENT:          //      *   expr
              right->Emit(out);
              break;

         case ET_ADDRESS:          //      &   expr
              right->EmitAddress(out);
              break;

         default: assert(0 && "Bad expr_type");
      }

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void UnaryExpression::EmitInitialization(FILE * out, int size)
{
   assert(this);
   assert(right);
   switch(expr_type)
      {
         case ET_CAST: //      (type)expr
              right->EmitInitialization(out, size);
              return;

         case ET_ADDRESS: //      &   expr
             if (size != 2) right->Emit(stderr);
             assert(size == 2);
             if (right->IsVariable())
                {
                  const char * vname = right->GetVarname();
                  assert(vname);

                  // check that var is declared
                  const int spos = Name::FindPos(vname);
                     if (spos == 1)
                        {
                          fprintf(stderr, "Variable %s not declared\n", vname);
                          semantic_errors++;
                          return;
                        }

                  fprintf(out, "\t.WORD\tC%s\t\t\t; & %s\n", vname, vname);
                  return;
                }
      }

   fprintf(stderr, "Non-const initializer (not supported)\n");
   semantic_errors++;
}
//-----------------------------------------------------------------------------
void UnaryExpression::Emit(FILE * out)
{
   assert(this);
   EmitStart(out);

   assert(right);
   switch(expr_type)
      {
	case ET_PREINC:
	case ET_PREDEC:
             {
               BinExprType  op  = ET_ADD;
               const char * ops = "++";
               if (expr_type == ET_PREDEC)
                  {
                    op  = ET_SUB;
                    ops = "--";
                  }

               int amount = 1;
               if (right->IsPointer())
                  amount = right->GetType()->GetPointeeSize();

               if (right->IsVariable())
                  {
                    right->Emit(out);
                    Backend::compute_binary(op, true, ops, amount);
                    right->EmitAssign(out);
                    break;
                  }

               right->EmitAddress(out);
               Backend::move_rr_to_ll();
               Backend::content(right->GetSUW());
               Backend::compute_binary(op, true, ops, amount);
               Backend::assign(right->GetSUW());
             }
             break;

        case ET_LOG_NOT:          //      !   expr
        case ET_NEGATE:           //      -   expr
        case ET_COMPLEMENT:       //      ~   expr
             right->Emit(out);
             Backend::compute_unary(expr_type, GetPretty(expr_type));
             break;

        case ET_ADDRESS:          //      &   expr
             right->EmitAddress(out);
             break;

        case ET_CONTENT:          //      *   expr
             right->Emit(out);
             Backend::content(GetSUW());
             break;

        case ET_CONJUGATE:        //      +   expr
             right->Emit(out);
             break;

        case ET_CAST:             // (type)   expr
             right->Emit(out);
             break;

        default: assert(0 && "Bad expr_type");
      }

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void BinaryExpression::Emit(FILE * out)
{
   assert(this);
   EmitStart(out);
   ((TypeName *)GetType())->Emit(out);

   assert(left);
   assert(right || expr_type == ET_FUNCALL);   // zero if no args
   switch(expr_type)
      {
         case ET_FUNCALL:
	      left ->EmitCall(out, right);
              break;

         case ET_LIST:
              left ->Emit(out);
              right->Emit(out);
              break;

         case ET_ASSIGN:           // expr = expr
              right->Emit(out);
              if (left->IsVariable())
                 {
                   left->EmitAssign(out);
                   break;
                 }
              Backend::push_rr(left->GetSUW());
              left->EmitAddress(out);
              Backend::move_rr_to_ll();
              Backend::pop_rr(left->GetSUW());
              Backend::assign(GetSize());
              break;

         case ET_BIT_OR:           // expr |   expr
         case ET_BIT_AND:          // expr &   expr
         case ET_BIT_XOR:          // expr ^   expr
         case ET_MULT:             // expr *   expr
         case ET_DIV:              // expr /   expr
         case ET_MOD:              // expr %   expr
         case ET_LEFT:             // expr <<  expr
         case ET_RIGHT:            // expr >>  expr
         case ET_EQUAL:            // expr ==  expr
         case ET_NOT_EQUAL:        // expr !=  expr
         case ET_LESS_EQUAL:       // expr <=  expr
         case ET_LESS:             // expr <   expr
         case ET_GREATER_EQUAL:    // expr >=  expr
         case ET_GREATER:          // expr >   expr
               if (right->IsConstant())
                  {
                    left->Emit(out);
                    Backend::compute_binary(expr_type, IsUnsigned(),
                                            GetPretty(expr_type),
                                            right->GetConstantNumericValue());
                  }
               else if (left->IsConstant())
                  {
                    right->Emit(out);
                    Backend::compute_binary(expr_type, IsUnsigned(), 
                                            left->GetConstantNumericValue(),
                                            GetPretty(expr_type));
                  }
               else if (right->IsVariable())
                  {
                    left->Emit(out);
                    Backend::move_rr_to_ll();
                    right->Emit(out);
                    Backend::compute_binary(expr_type, IsUnsigned(),
                                            GetPretty(expr_type));
                  }
               else if (left->IsVariable())
                  {
                    right->Emit(out);
                    left->Emit_to_ll(out);
                    Backend::compute_binary(expr_type, IsUnsigned(),
                                            GetPretty(expr_type));
                  }
               else
                  {
                    left->Emit(out);
                    Backend::push_rr(WO);
                    right->Emit(out);
                    Backend::pop_ll(WO);
                    Backend::compute_binary(expr_type, IsUnsigned(),
                                            GetPretty(expr_type));
                  }
              break;

         case ET_LOG_AND:          // expr &&  expr
                                   // if (left) right;
              {
                ExpressionStatement r(right);
                IfElseStatement i(left, &r, 0);
                i.Emit(out);
              }
              break;

         case ET_LOG_OR:           // expr ||  expr
                                   // if (left) ; else right;
              {
                ExpressionStatement r(right);
                IfElseStatement i(left, 0, &r);
                i.Emit(out);
              }
              break;

         case ET_ELEMENT:           // expr [ expr ]
              EmitAddress(out);
              Backend::content(left->GetType()->ContentOf()->GetSUW());
              break;

         default: assert(0 && "Bad expr_type");
      }

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void AdditionExpression::Emit(FILE * out)
{
   assert(this);
   EmitStart(out);

   assert(left);
   assert(right);

Expression * lft = left;
Expression * rht = right;

   // move pointer to left side
   if (right->IsPointer() || right->IsArray())
      {
        lft = right;
        rht = left;
      }

   if (rht->IsPointer() || rht->IsArray())   // error: pinter + pointer
      {
        fprintf(stderr, "Bad pointer arithmetic\n");
        semantic_errors++;
        EmitEnd(out);
        return;
      }

int rscale = 1;
   if (lft ->IsPointer())   rscale = lft ->PointeeSize();

   if (rht->IsConstant())
      {
        lft->Emit(out);
        Backend::compute_binary(expr_type, IsUnsigned(), GetPretty(ET_ADD),
                                rscale * rht->GetConstantNumericValue());
        EmitEnd(out);
        return;
      }

   if (lft->IsConstant())
      {
        rht->Emit(out);
        Backend::compute_binary(expr_type, IsUnsigned(), 
                                lft->GetConstantNumericValue(),
                                GetPretty(ET_ADD));
        EmitEnd(out);
        return;
      }

   if (rht->IsVariable())
      {
        lft->Emit(out);
        Backend::move_rr_to_ll();
        rht->Emit(out);
      }
   else if (lft->IsVariable())
      {
        rht->Emit(out);
        lft->Emit_to_ll(out);
      }
   else
      {
        rht->Emit(out);
        Backend::push_rr(WO);
        lft->Emit(out);
        Backend::move_rr_to_ll();
        Backend::pop_rr(WO);
      }

   Backend::scale_rr(rscale);
   Backend::compute_binary(ET_ADD, IsUnsigned(), GetPretty(ET_ADD));
   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void SubtractionExpression::Emit(FILE * out)
{
   assert(this);
   EmitStart(out);

   assert(left);
   assert(right);

int rscale = 1;
int uscale = 1;
   if (left->IsPointer())
      {
        if (right->IsPointer())   uscale = left->PointeeSize();
        else                      rscale = left->PointeeSize();
      }
   else if (right->IsPointer())
      {
        fprintf(stderr, "Bad pointer arithmetic\n");
        semantic_errors++;
        EmitEnd(out);
        return;
      }

   if (left->IsConstant())
      {
        right->Emit(out);
        Backend::compute_binary(expr_type, IsUnsigned(), 
                                left->GetConstantNumericValue(),
                                GetPretty(ET_SUB));
        EmitEnd(out);
        return;
      }

   if (right->IsConstant())
      {
        left->Emit(out);
        Backend::compute_binary(expr_type, IsUnsigned(), GetPretty(ET_SUB),
                                rscale * right->GetConstantNumericValue());
        EmitEnd(out);
        return;
      }

   if (right->IsVariable())
      {
        left->Emit(out);
        Backend::move_rr_to_ll();
        right->Emit(out);
      }
   else if (left->IsVariable())
      {
        right->Emit(out);
        Backend::move_rr_to_ll();
        left->Emit_to_ll(out);
      }
   else
      {
        right->Emit(out);
        Backend::push_rr(WO);
        left->Emit(out);
        Backend::move_rr_to_ll();
        Backend::pop_rr(WO);
      }

   Backend::scale_rr(rscale);
   Backend::compute_binary(ET_SUB, IsUnsigned(), GetPretty(ET_SUB));
   Backend::unscale_rr(uscale, right->IsUnsigned());

   EmitEnd(out);
}
//-----------------------------------------------------------------------------
const char * Expression::GetPrettyName(const char * pretty)
{
   assert(pretty);
const int plen = strlen(pretty);
char * ret = new char[plen + 10];
   sprintf(ret, "Expr %s", pretty);
   return ret;
}
//-----------------------------------------------------------------------------
const char * UnaryExpression::GetPretty(UnaExprType expr_type)
{
   switch(expr_type)
      {
        case ET_ADDRESS:       return "& r";
        case ET_CAST:          return "()r";
        case ET_CONTENT:       return "* r";
        case ET_CONJUGATE:     return "+ r";
        case ET_NEGATE:        return "- r";
        case ET_COMPLEMENT:    return "~ r";
        case ET_LOG_NOT:       return "! r";
        case ET_POSTINC:       return "r++";
        case ET_POSTDEC:       return "r--";
        case ET_PREINC:        return "++r";
        case ET_PREDEC:        return "--r";

        default:               return "BAD UNARY EXPR_TYPE";
      }
}
//-----------------------------------------------------------------------------
const char * BinaryExpression::GetPretty(BinExprType expr_type)
{
   switch(expr_type)
      {
        case ET_LIST:          return "l , r";
        case ET_ARGLIST:       return "(l , r)";
        case ET_ASSIGN:        return "l = r";
        case ET_MULT_ASSIGN:   return "l *- r";
        case ET_DIV_ASSIGN:    return "l /= r";
        case ET_MOD_ASSIGN:    return "l %= r";
        case ET_ADD_ASSIGN:    return "l += r";
        case ET_SUB_ASSIGN:    return "l -= r";
        case ET_LEFT_ASSIGN:   return "l <<= r";
        case ET_RIGHT_ASSIGN:  return "l >>= r";
        case ET_AND_ASSIGN:    return "l & r";
        case ET_XOR_ASSIGN:    return "l ^ r";
        case ET_OR_ASSIGN:     return "l | r";
        case ET_LOG_OR:        return "l || r";
        case ET_LOG_AND:       return "l && r";
        case ET_BIT_OR:        return "l | r";
        case ET_BIT_AND:       return "l & r";
        case ET_BIT_XOR:       return "l ^ r";
        case ET_EQUAL:         return "l == r";
        case ET_NOT_EQUAL:     return "l != r";
        case ET_LESS_EQUAL:    return "l <= r";
        case ET_LESS:          return "l < r";
        case ET_GREATER_EQUAL: return "l >= r";
        case ET_GREATER:       return "l > r";
        case ET_LEFT:          return "l << r";
        case ET_RIGHT:         return "l >> r";
        case ET_ADD:           return "l + r";
        case ET_SUB:           return "l - r";
        case ET_MULT:          return "l * r";
        case ET_DIV:           return "l / r";
        case ET_MOD:           return "l % r";
        case ET_FUNCALL:       return "l(r)";
        case ET_ELEMENT:       return "l[r]";

        default:               return "BAD BINARY EXPR_TYPE";
      }
}
//-----------------------------------------------------------------------------
void IdentifierExpression::EmitAssign(FILE * out)
{
   assert(varname);
const int spos = Name::FindPos(varname);
   if (spos == 1)
      {
        fprintf(stderr, "Variable %s not declared\n", varname);
        semantic_errors++;
        return;
      }

   if (spos == 0)   Backend::store_rr_var(varname, GetSUW());
   else             Backend::store_rr_var(varname, spos, GetSUW());
}
//-----------------------------------------------------------------------------
void IdentifierExpression::AddAddress(FILE * out)
{
   assert(varname);
const int spos = Name::FindPos(varname);
   if (spos == 1)
      {
        fprintf(stderr, "Variable %s not declared\n", varname);
        semantic_errors++;
        return;
      }

   if (spos == 0)   Backend::add_address(varname);
   else             Expression::AddAddress(out);
}
//-----------------------------------------------------------------------------
void IdentifierExpression::EmitAddress(FILE * out)
{
   assert(varname);
const int spos = Name::FindPos(varname);
   if (spos == 1)
      {
        fprintf(stderr, "Variable %s not declared\n", varname);
        semantic_errors++;
        return;
      }

   if (spos == 0)   Backend::load_address(varname);
   else             Backend::load_address(varname, spos);
}
//-----------------------------------------------------------------------------
void IdentifierExpression::EmitInitialization(FILE * out, int size)
{
   assert(varname);
   fprintf(out, "\t.WORD\tC%s\n", varname);
}
//-----------------------------------------------------------------------------
void Expression::EmitInitialization(FILE * out, int size)
{
   fprintf(stderr, "TODO: EmitInitialization %s\n", GetNodeType());
   Emit(stderr);
   fprintf(stderr, "----: EmitInitialization %s\n", GetNodeType());
   assert(0);
}
//-----------------------------------------------------------------------------
void Expression::EmitAddress(FILE * out)
{
   fprintf(stderr, "TODO: Expression::EmitAddress() %s\n", GetNodeType());
   Emit(stderr);
   fprintf(stderr, "----: Expression::EmitAddress() %s\n", GetNodeType());
   assert(0);
}
//-----------------------------------------------------------------------------
void Expression::AddAddress(FILE * out)
{
   Backend::push_rr(WO);
   Emit(out);
   Backend::pop_ll(WO);
   Backend::compute_binary(ET_ADD, true, "&l[r]");
}
//-----------------------------------------------------------------------------
BinExprType BinaryExpression::MapAssign(BinExprType et)
{
   switch(et)
      {
         case ET_MULT_ASSIGN:  return ET_MULT;
         case ET_DIV_ASSIGN:   return ET_DIV;
         case ET_MOD_ASSIGN:   return ET_MOD;
         case ET_LEFT_ASSIGN:  return ET_LEFT;
         case ET_RIGHT_ASSIGN: return ET_RIGHT;
         case ET_AND_ASSIGN:   return ET_BIT_AND;
         case ET_XOR_ASSIGN:   return ET_BIT_XOR;
         case ET_OR_ASSIGN:    return ET_BIT_OR;
      }

   assert(0 && "Bad expr_type");
}
//-----------------------------------------------------------------------------
int Expression::FunReturnSize()
{
TypeName * funtn = FunReturnType();
   assert(funtn);

   return funtn->GetFunReturnSize();
}
//-----------------------------------------------------------------------------
TypeName * Expression::FunReturnType()
{
TypeName * tn = GetType();
   assert(tn);
   return tn->GetFunReturnType();
}
//-----------------------------------------------------------------------------
Expression * IdentifierExpression::New(const char * s)
{
int value;
bool is_enum = Name::FindEnum(s, value);

   if (!is_enum)   return new IdentifierExpression(s);

int spos = Name::FindPos(s);

   if (spos != 1)
      {
        fprintf(stderr, "Warning: variable %s shadows enum value\n", s);
        return new IdentifierExpression(s);
      }

   return new NumericExpression(value);
}
//-----------------------------------------------------------------------------
TypeName * IdentifierExpression::FunReturnType()
{
   assert(varname);

TypeName * funtn = Name::FindType(varname);
   if (funtn)   return funtn->GetFunReturnType();

   fprintf(stderr, "Function '%s' not declared\n", varname);
   semantic_errors++;
   return new TypeName(TS_INT);
}
//-----------------------------------------------------------------------------
TypeName * BinaryExpression::MaxType(Expression * left, Expression * right)
{
TypeName * ltype = left ->GetType();   assert(ltype);
TypeName * rtype = right->GetType();   assert(rtype);

   if (!ltype->IsNumericType())
      {
        if (  expr_type == ET_EQUAL         || expr_type == ET_NOT_EQUAL
           || expr_type == ET_LESS_EQUAL    || expr_type == ET_LESS
           || expr_type == ET_GREATER_EQUAL || expr_type == ET_GREATER)
           {
             if (ltype->IsPointer())   return ltype;
           }

        fprintf(stderr, "Left argument of %s is not numeric\n",
                        GetPretty(expr_type));
        semantic_errors++;
        return new TypeName(TS_INT);
      }

   if (!rtype->IsNumericType())
      {
        if (  expr_type == ET_EQUAL         || expr_type == ET_NOT_EQUAL
           || expr_type == ET_LESS_EQUAL    || expr_type == ET_LESS
           || expr_type == ET_GREATER_EQUAL || expr_type == ET_GREATER)
           {
             if (rtype->IsPointer())   return rtype;
           }

        fprintf(stderr, "Right argument of %s is not numeric\n",
                        GetPretty(expr_type));
        semantic_errors++;
        return new TypeName(TS_INT);
      }

Specifier spec = TS_INT;

   if (ltype->IsUnsigned())   spec = (Specifier)(TS_INT | TS_UNSIGNED);
   if (rtype->IsUnsigned())   spec = (Specifier)(TS_INT | TS_UNSIGNED);
   return new TypeName(spec);
}
//-----------------------------------------------------------------------------
int NumericExpression::GetConstantNumericValue() const
{
   assert(int_value);
   return int_value->GetValue();
}
//-----------------------------------------------------------------------------
int Expression::GetConstantNumericValue() const
{
   fprintf(stderr, "Non-constant value where numeric constant expected\n");
   semantic_errors++;
   return 0;
}
//-----------------------------------------------------------------------------
StringConstant * Expression::GetStringConstant() const
{
   fprintf(stderr, "Non-constant value where string constant expected\n");
   semantic_errors++;
   return 0;
}
//-----------------------------------------------------------------------------
void Expression::EmitCall(FILE * out, Expression * args)
{
TypeName * tname;

   tname = GetType();
   assert(tname);

ParameterDeclarationList * plist = tname->GetParameters();

int param_bytes_pushed = 0;
   if (args)
      {
        if (!plist)
           {
             const char * funname = GetVarname();
             if (funname == 0)   funname = "";
             fprintf(stderr,
                     "Arguments for function %s without parameters\n",
                     funname);
             semantic_errors++;
             return;
           }
	param_bytes_pushed += args->EmitPush(out, plist);
      }
   else
      {
        if (plist)
           {
             const char * funname = GetVarname();
             if (funname == 0)   funname = "";
             fprintf(stderr,
                     "No arguments for function %s with parameters\n",
                     funname);
             semantic_errors++;
             return;
           }
      }

   // compute return value size
const int ret_size = tname->GetFunReturnSize();
   param_bytes_pushed += Backend::push_return(ret_size);

   if (GetType()->IsFunPtr())
      {
        Emit(out);
        Backend::call_ptr();
      }
   else
      {
        assert(GetVarname());
        Backend::call(GetVarname());
      }

   Backend::pop(param_bytes_pushed);
}
//-----------------------------------------------------------------------------
int ArgListExpression::EmitPush(FILE * out, ParameterDeclarationList * args)
{
   EmitStart(out);

   assert(left);
   assert(right);

ParameterDeclarationList * a = args;
   for (int l = left->GetParaLength(); a && l; l--)
       {
         if (!a->Head()->IsEllipsis())   a = a->Tail();
       }

   if (a)
      {
        const int rpush = right->EmitPush(out, a);
        const int lpush = left ->EmitPush(out, args);

        EmitEnd(out);
        return rpush + lpush;
      }

   semantic_errors++;
   EmitEnd(out);
   return 0;
}
//-----------------------------------------------------------------------------
int Expression::EmitPush(FILE * out, ParameterDeclarationList * args)
{
   assert(args);

ParameterDeclaration * pd = args->Head();
   assert(pd);

TypeName * tname = pd->GetTypeName();
   assert(tname);

SUW suw;

   pd->Emit(out);   // just shows type
   if (tname->IsPointer() && GetType()->IsArray())
      {
        EmitAddress(out);
        suw = WO;
      }
   else
      {
        Emit(out);
        suw = tname->GetSUW();
      }

   Backend::push_rr(suw);

   if (suw == WO)   return 2;
   return 1;
}
//-----------------------------------------------------------------------------
int ArgListExpression::GetParaLength() const
{
   assert(left);
   assert(right);

   return left->GetParaLength() + right->GetParaLength();
}
//-----------------------------------------------------------------------------
AsmExpression::AsmExpression(StringConstant * string)
   : Expression("asm Expression")
{
   asm_string = string->Kill();
   assert(asm_string);
}
//-----------------------------------------------------------------------------
void AsmExpression::Emit(FILE * out)
{
   Backend::asmbl(asm_string);
}
//-----------------------------------------------------------------------------
TypeName * AsmExpression::SetType()
{
   return new TypeName(TS_INT);
}
//-----------------------------------------------------------------------------
