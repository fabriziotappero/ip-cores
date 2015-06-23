// Node.hh
#ifndef __NODE_HH_DEFINED__
#define __NODE_HH_DEFINED__

#include <assert.h>
#include "List.hh"

//-----------------------------------------------------------------------------

class TypeSpecifier;
class DeclItem;
class Initializer;
class TypeName;
class Expression;

const char * GetDeclaredName(Declarator * decl);
ParameterDeclarationList * GetParameters(Declarator * decl);
bool         IsFunPtr(Declarator * decl);
bool         IsPointer(Declarator * decl);
Expression * ArrayLength(Declarator * decl);
void         SetArrayLength(Declarator * decl, int len);
bool         IsFunction(Declarator * decl);
bool         IsArray(Declarator * decl);

enum SUW { SB, UB, WO };

//-----------------------------------------------------------------------------
class Constant : public Node
{
public:
   Constant(const char * name)
   : Node(name)
   {};

   virtual void EmitValue_RR(FILE * out) = 0;
   virtual void EmitValue_LL(FILE * out) = 0;
};
//-----------------------------------------------------------------------------
class NumericConstant : public Constant
{
public:
   NumericConstant(const char * txt);
   NumericConstant(int val, int siz = 0)
   : Constant("NumericConstant"),
     value(val),
     size(siz)
     {};

   virtual void EmitValue_RR(FILE * out);
   virtual void EmitValue_LL(FILE * out);
   int GetValue() const   { return value; };
   int GetSize()  const   { return size;  };

   void Negate()       { value = -value; };
   void Complement()   { value = ~value; };
   void LogNot()       { if (value)   value = 0;   else value = -1; };

private:
   int value;
   int size;
};
//-----------------------------------------------------------------------------
class StringConstant : public Constant
{
public:
   StringConstant();
   ~StringConstant();

   virtual void EmitValue_RR(FILE * out);
   virtual void EmitValue_LL(FILE * out);
   void operator += (char txt);
   StringConstant * operator & (StringConstant * other);
   void operator += (const char * txt)
      { while (*txt)   *this += *txt++; };

   int GetStringNumber() const   { return string_number; };
   int GetLength()       const   { return value_len;     };
   char * Kill()
      { char * ret = buffer;   buffer = 0;   delete this;   return ret; };

   void  EmitAndRemove(FILE * out, int length);

   static void  EmitAll(FILE * out);

private:
   char       * buffer;
   int          buffer_len;
   int          value_len;
   int          string_number;

   static int str_count;
   enum { MAX_STRINGS = 5000 };
   static StringConstant * all_strings[MAX_STRINGS];
};
//-----------------------------------------------------------------------------
// how an expression is created...
// //
enum BinExprType
{
   // binary
   ET_LIST,             // expr  ,  expr
   ET_ARGLIST,          // expr  ,  expr in function argument
   ET_ASSIGN,           // expr  =  expr
   ET_MULT_ASSIGN,      // expr *=  expr
   ET_DIV_ASSIGN,       // expr /=  expr
   ET_MOD_ASSIGN,       // expr %=  expr
   ET_ADD_ASSIGN,       // expr +=  expr
   ET_SUB_ASSIGN,       // expr -=  expr
   ET_LEFT_ASSIGN,      // expr <<= expr
   ET_RIGHT_ASSIGN,     // expr >>= expr
   ET_AND_ASSIGN,       // expr &=  expr
   ET_XOR_ASSIGN,       // expr ^=  expr
   ET_OR_ASSIGN,        // expr |=  expr
   ET_BIT_OR,           // expr |   expr
   ET_BIT_AND,          // expr &   expr
   ET_BIT_XOR,          // expr ^   expr
   ET_LOG_OR,           // expr ||  expr
   ET_LOG_AND,          // expr &&  expr
   ET_EQUAL,            // expr ==  expr
   ET_NOT_EQUAL,        // expr !=  expr
   ET_LESS_EQUAL,       // expr <=  expr
   ET_LESS,             // expr <   expr
   ET_GREATER_EQUAL,    // expr >=  expr
   ET_GREATER,          // expr >   expr
   ET_LEFT,             // expr <<  expr
   ET_RIGHT,            // expr >>  expr
   ET_ADD,              // expr +   expr
   ET_SUB,              // expr -   expr
   ET_MULT,             // expr *   expr
   ET_DIV,              // expr /   expr
   ET_MOD,              // expr %   expr
   ET_ELEMENT,          // expr [   expr ]
   ET_FUNCALL           // expr (   ... )
};

enum UnaExprType
{
   ET_CAST,             // (type)   expr
   ET_ADDRESS,          //      &   expr
   ET_CONTENT,          //      *   expr
   ET_CONJUGATE,        //      +   expr
   ET_NEGATE,           //      -   expr
   ET_COMPLEMENT,       //      ~   expr
   ET_LOG_NOT,          //      !   expr
   ET_POSTINC,          //      ++  expr
   ET_POSTDEC,          //      --  expr
   ET_PREINC,           //      ++  expr
   ET_PREDEC            //      --  expr
};

class Expression : public Node
{
public:
   Expression(const char * nodename)
   : Node(nodename),
     type_name(0)
   {};

   virtual void Emit(FILE * out) = 0;
   virtual void Emit_to_ll(FILE * out)   { assert(0); };
           void EmitCall(FILE * out, Expression * right);
   virtual void EmitInitialization(FILE * out, int size);
   virtual void EmitAddress(FILE * out);
   virtual void AddAddress(FILE * out);
   virtual int  EmitPush(FILE * out, ParameterDeclarationList * params);
   virtual void EmitAssign(FILE * out)   { assert(0); };
   virtual int  GetParaLength() const    { return 1; };

   virtual bool IsConstant() const          { return false; };
   virtual bool IsNumericConstant() const   { return false; };
   virtual bool IsStringConstant() const    { return false; };
   virtual bool IsVariable() const          { return false; };
   virtual const char * GetVarname() const  { return 0;     };
   virtual int  GetConstantNumericValue() const;
   virtual StringConstant * GetStringConstant() const;
   virtual      TypeName * FunReturnType();
   virtual      TypeName * SetType() = 0;
   virtual SUW  GetSUW();
   void SetType(TypeName * t);

   bool       IsPointer();
   bool       IsArray();
   int        PointeeSize();
   int        GetSize();
   TypeName * GetType();
   bool       IsUnsigned();
   int        FunReturnSize();

   static const char * GetPrettyName(const char * pretty);

   virtual Expression * OptNegate()        { assert(0); };
   virtual Expression * OptComplement()    { assert(0); };
   virtual Expression * OptLogNot()        { assert(0); };

private:
   TypeName *  type_name;
};
//-----------------------------------------------------------------------------
class IdentifierExpression : public Expression
{
public:
   static Expression * New(const char * s);

   virtual void  Emit(FILE * out);
   virtual void  EmitAssign(FILE * out);
   virtual void  Emit_to_ll(FILE * out);
   virtual       TypeName * SetType();

   virtual bool             IsVariable() const   { return true;    };
   virtual const char *     GetVarname() const   { return varname; };
   virtual void             EmitAddress(FILE * out);
   virtual void             EmitInitialization(FILE * out, int size);
   virtual void             AddAddress(FILE * out);
   virtual TypeName *       FunReturnType();

private:
   IdentifierExpression(const char * s)
   : Expression("Expression (variable name)"),
     varname(s)
   {};

   const char * varname;
};
//-----------------------------------------------------------------------------
class MemberExpression : public Expression
{
public:
   MemberExpression(bool is_pointer, Expression * r, const char * s);

   virtual void  Emit(FILE * out);
   virtual void EmitAddress(FILE * out);
   void EmitAddress(FILE * out, bool content);
   virtual       TypeName * SetType();

private:
   Expression * left;
   const char * membername;
};
//-----------------------------------------------------------------------------
class StringExpression : public Expression
{
public:
   StringExpression(StringConstant * s);

   virtual void  Emit(FILE * out);
   virtual void EmitAddress(FILE * out);
   virtual void  Emit_to_ll(FILE * out);
   virtual       TypeName * SetType();
   virtual void  EmitInitialization(FILE * out, int size);

   virtual bool  IsConstant()       const   { return true; };
   virtual bool  IsStringConstant() const   { return true; };
   virtual StringConstant * GetStringConstant() const
      { return string_constant; }

private:
   StringConstant * string_constant;
};
//-----------------------------------------------------------------------------
class NumericExpression : public Expression
{
public:
   NumericExpression(NumericConstant * n);
   NumericExpression(TypeName * t);
   NumericExpression(Expression * r);
   NumericExpression(int value);

   virtual void Emit(FILE * out);
   virtual void Emit_to_ll(FILE * out);
   virtual bool IsConstant()        const   { return true; };
   virtual bool IsNumericConstant() const   { return true; };
   virtual int  GetConstantNumericValue() const;
   virtual       TypeName * SetType();
   virtual void EmitInitialization(FILE * out, int size);
   static const char * GetPretty(int value);

   virtual Expression * OptNegate();
   virtual Expression * OptComplement();
   virtual Expression * OptLogNot();

private:
   NumericConstant * int_value;
};
//-----------------------------------------------------------------------------
class CondExpression : public Expression
{
public:
   CondExpression(Expression * l, Expression * m, Expression * r)
   : Expression("Expression (l ? m : r)"),
     left(l),
     middle(m),
     right(r)
   {};

   virtual void Emit(FILE * out);
   virtual       TypeName * SetType();

private:
   Expression      * left;
   Expression      * middle;
   Expression      * right;
};
//-----------------------------------------------------------------------------
class BinaryExpression : public Expression
{
public:
   static Expression * New(BinExprType et, Expression * l, Expression * r);

   virtual void Emit(FILE * out);
   virtual       TypeName * SetType();
   virtual void EmitAddress(FILE * out);

   TypeName * MaxType(Expression * l, Expression * r);

   static const char * GetPretty(BinExprType expr_type);
   static BinExprType  MapAssign(BinExprType et);

protected:
   BinaryExpression(BinExprType et, Expression * l, Expression * r);
   BinExprType       expr_type;
   Expression      * left;
   Expression      * right;
};
//-----------------------------------------------------------------------------
class ArgListExpression : public BinaryExpression
{
public:
   ArgListExpression(Expression * l, Expression * r)
   : BinaryExpression(ET_ARGLIST, l, r)
   {};

   virtual void Emit(FILE * out)  {};   // done vy EmitPush()
   virtual int  EmitPush(FILE * out, ParameterDeclarationList * params);
   virtual int  GetParaLength() const;
   virtual       TypeName * SetType();
};
//-----------------------------------------------------------------------------
class AdditionExpression : public BinaryExpression
{
public:
   static Expression * New(Expression * l, Expression * r);

   virtual void Emit(FILE * out);
   virtual       TypeName * SetType();

private:
   AdditionExpression(Expression * l, Expression * r)
   : BinaryExpression(ET_ADD, l, r)
   {};
};
//-----------------------------------------------------------------------------
class SubtractionExpression : public BinaryExpression
{
public:
   static Expression * New(Expression * l, Expression * r);

   virtual void Emit(FILE * out);
   virtual       TypeName * SetType();

private:
   SubtractionExpression(Expression * l, Expression * r)
   : BinaryExpression(ET_SUB, l, r)
   {};
};
//-----------------------------------------------------------------------------
class UnaryExpression : public Expression
{
public:
   UnaryExpression(TypeName * t, Expression * r);

   virtual void Emit(FILE * out);
   virtual void EmitAddress(FILE * out);
   virtual void EmitInitialization(FILE * out, int size);
   virtual       TypeName * SetType();

   static const char * GetPretty(UnaExprType expr_type);
   static Expression * New(UnaExprType et, Expression * r);

private:
   UnaryExpression(UnaExprType et, Expression * r)
   : Expression(GetPrettyName(GetPretty(et))),
     expr_type(et),
     right(r)
   {};

   UnaExprType   expr_type;
   Expression  * right;
};
//-----------------------------------------------------------------------------
class AsmExpression : public Expression
{
public:
   AsmExpression(StringConstant * string);

   virtual void Emit(FILE * out);
   virtual       TypeName * SetType();

private:
     char * asm_string;
};
//-----------------------------------------------------------------------------
enum Specifier
{
   // storage class
   SC_TYPEDEF   = 0x00000001,
   SC_EXTERN    = 0x00000002,
   SC_STATIC    = 0x00000004,
   SC_AUTO      = 0x00000008,
   SC_REGISTER  = 0x00000010,
   SC_MASK      = SC_TYPEDEF | SC_EXTERN | SC_STATIC  | SC_AUTO  | SC_REGISTER,

   // type qualifiers
   TQ_CONST     = 0x00000100,
   TQ_VOLATILE  = 0x00000200,
   TQ_MASK      = TQ_CONST | TQ_VOLATILE,

   // type specifiers
   TS_SIGNED    = 0x00001000,
   TS_UNSIGNED  = 0x00002000,
   TS_SIGN_MASK = TS_SIGNED | TS_UNSIGNED,

   TS_VOID      = 0x00010000,
   TS_CHAR      = 0x00020000,
   TS_SHORT     = 0x00040000,
   TS_INT       = 0x00080000,
   TS_LONG      = 0x00100000,
   TS_FLOAT     = 0x00200000,
   TS_DOUBLE    = 0x00400000,
   TS_STRUCT    = 0x00800000,
   TS_UNION     = 0x01000000,
   TS_ENUM      = 0x02000000,
   TS_TYPE_NAME = 0x04000000,
   TS_MASK      = TS_VOID  | TS_CHAR   | TS_SHORT  | TS_INT | TS_LONG |
                  TS_FLOAT | TS_DOUBLE | TS_STRUCT |
                  TS_UNION | TS_ENUM   | TS_TYPE_NAME,
   TS_NUMERIC   = TS_CHAR  | TS_SHORT  | TS_INT    | TS_LONG |
                  TS_FLOAT | TS_DOUBLE | TS_ENUM,
};
//-----------------------------------------------------------------------------
class Ptr : public Node
{
public:
   Ptr(TypeSpecifier * ds)
   : Node("Ptr"),
     decl_specs(ds)
     {};

   virtual void Emit(FILE * out);
   int Print(FILE * out) const;
      
private:
   TypeSpecifier * decl_specs;
};
//-----------------------------------------------------------------------------
class Identifier : public Node
{
public:
   Identifier(const char * n)
   : Node("Identifier"),
     name(n)
     {};

private:
   const char * name;
};
//-----------------------------------------------------------------------------
class Initializer : public Node
{
public:
   Initializer(Expression * expr)
   : Node("Initializer (skalar)"),
     skalar_value(expr),
     array_value(0)
     {};

   Initializer(InitializerList * list)
   : Node("Initializer (vector)"),
     skalar_value(0),
     array_value(list)
     {};

   virtual void Emit(FILE * out);
   virtual void EmitValue(FILE * out, TypeName * tn);

   int  InitAutovar(FILE * out, TypeName * type);
   int  ElementCount() const;
      
private:
   Expression      * skalar_value;
   InitializerList * array_value;
};
//-----------------------------------------------------------------------------
class ParameterDeclaration : public Node
{
public:
   ParameterDeclaration(TypeSpecifier * ds, Declarator * dec);

   virtual void Emit(FILE * out);

   int AllocateParameters(int position);
   const char * GetDeclaredName(int skip);
   TypeName * GetTypeName() const   { return type; };
   bool       IsEllipsis() const    { return isEllipsis; };
   ParameterDeclaration * SetEllipsis() { isEllipsis = true; return this; };
      
private:
   TypeName * type;
   bool       isEllipsis;
};
//-----------------------------------------------------------------------------
enum DECL_WHAT
{
   DECL_NAME    = 1,
   DECL_FUNPTR  = 2,
   DECL_ARRAY   = 3,
   DECL_FUN     = 4,
   DECL_POINTER = 5
};

class DeclItem : public Node
{
public:
   DeclItem(DECL_WHAT w)
   : Node("DeclItem"),
     what(w),
     name(0),
     funptr(0),
     array_size(0),
     fun_params(0),
     fun_identifiers(0),
     pointer(0)
     {};

   DeclItem(const char * n)
   : Node("DeclItem"),
     what(DECL_NAME),
     name(n),
     funptr(0),
     array_size(0),
     fun_params(0),
     fun_identifiers(0),
     pointer(0)
     {};

   DeclItem(Declarator * fp)
   : Node("DeclItem"),
     what(DECL_FUNPTR),
     name(0),
     funptr(fp),
     array_size(0),
     fun_params(0),
     fun_identifiers(0),
     pointer(0)
     {};

   DeclItem(Expression * ep)
   : Node("DeclItem"),
     what(DECL_ARRAY),
     name(0),
     funptr(0),
     array_size(ep),
     fun_params(0),
     fun_identifiers(0),
     pointer(0)
     {};

   DeclItem(ParameterDeclarationList * pl)
   : Node("DeclItem"),
     what(DECL_FUN),
     name(0),
     funptr(0),
     array_size(0),
     fun_params(pl),
     fun_identifiers(0),
     pointer(0)
     {};

   DeclItem(IdentifierList * il)
   : Node("DeclItem"),
     what(DECL_FUN),
     name(0),
     funptr(0),
     array_size(0),
     fun_params(0),
     fun_identifiers(il),
     pointer(0)
     {};

   DeclItem(Pointer * p)
   : Node("DeclItem"),
     what(DECL_POINTER),
     name(0),
     funptr(0),
     array_size(0),
     fun_params(0),
     fun_identifiers(0),
     pointer(p)
     {};

   virtual void Emit(FILE * out);
   int Print(FILE * out) const;
      
   const char * GetName()      const   { return name;       };
   DECL_WHAT    GetWhat()      const   { return what;       };
   Declarator * GetFunptr()    const   { return funptr;     };
   Pointer    * GetPointer()   const   { return pointer;    };
   Expression * GetArraySize() const   { return array_size; };
   void         SetArraySize(int n);
   ParameterDeclarationList * GetParameters() const   { return fun_params; };

private:
   const DECL_WHAT            what;
   const char               * name;
   Declarator               * funptr;
   Expression               * array_size;
   ParameterDeclarationList * fun_params;
   IdentifierList           * fun_identifiers;
   Pointer                  * pointer;
};
//-----------------------------------------------------------------------------
class Enumerator : public Node
{
public:
   Enumerator(const char * n, Expression * v)
   : Node("Enumerator"),
     name(n),
     value(v)
   {};

   virtual void Emit(FILE * out);
   static int current;

private:
   const char * name;
   Expression * value;
};
//-----------------------------------------------------------------------------
class StructDeclarator : public Node
{
public:
   StructDeclarator(Declarator * dcl, Expression * exp)
   : Node("StructDeclarator"),
     declarator(dcl),
     expression(exp),
     position(-1)
     {};

   virtual void Emit(FILE * out);
   int EmitMember(FILE * out, const char * struct_name,
        TypeSpecifier * tspec, int pos, bool is_union);
   TypeName * GetMemberType(TypeSpecifier * tspec, const char * member);
   int GetMemberPosition(const char * member) const;
   Declarator * GetDeclarator() const   { return declarator; };
   TypeName * FirstUnionMember(TypeSpecifier * tspec, int union_size) const;
   const char * GetMemberName() const;

private:
   Declarator * declarator;
   Expression * expression;   // : bitfield
   int          position;
};
//-----------------------------------------------------------------------------
class StructDeclaration : public Node
{
public:
   StructDeclaration(TypeSpecifier * ds, StructDeclaratorList * sdl)
   : Node("StructDeclaration"),
     decl_specifiers(ds),
     struct_decl_list(sdl),
     size(-1)
     { };

   int Emit(FILE * out, const char * struct_name, int pos, bool is_union);
   TypeName * GetMemberType(const char * struct_name, const char * member);
   TypeName * GetMemberType(int pos);
   int GetMemberPosition(const char * struct_name,
		         const char * member, bool is_union) const;
   int GetSize() const   { assert(size != -1);   return size; };

   TypeSpecifier        * GetSpecifier()   const { return decl_specifiers; };
   StructDeclaratorList * GetDeclarators() const { return struct_decl_list; };
   TypeName * FirstUnionMember(int size) const;
   int GetDeclaratorCount() const
      { return StructDeclaratorList::Length(struct_decl_list); };

private:
   TypeSpecifier        * decl_specifiers;
   StructDeclaratorList * struct_decl_list;
   int size;
};
TypeName * GetMemberType(StructDeclarationList * sdl, int pos);
//-----------------------------------------------------------------------------
class TypeSpecifier : public Node
{
public:
   // all types
   TypeSpecifier(Specifier sp)
   : Node("TypeSpecifier (all)"),
     spec(sp),
     name(0),
     struct_decl_list(0),
     enum_list(0)
     {};

   // structs, unions, typedef(name)
   TypeSpecifier(Specifier sp, const char * n, StructDeclarationList * sdl);

   // enums
   TypeSpecifier(const char * n, EnumeratorList * el)
   : Node("TypeSpecifier (enum)"),
     spec(TS_ENUM),
     name(n),
     struct_decl_list(0),
     enum_list(el)
     {};

   virtual void Emit(FILE * out);
   int Print(FILE * out) const;

   TypeSpecifier * operator +(TypeSpecifier & other);
   TypeSpecifier * self()   { return this; };

   Specifier    GetType()    const   { return spec; };
   const char * GetName()    const   { return name; };
   StructDeclarationList * GetStructDecl() const
                                     { return struct_decl_list; };
   bool         IsUnsigned() const   { return spec & TS_UNSIGNED; };

   int          GetFunReturnSize(Declarator * decl) const;
   int          GetSize(Declarator * decl) const;
   int          GetBaseSize()              const;
   TypeName *   GetMemberType(const char * member);
   bool         IsNumericType() const;  // char, short, or int
   bool         IsUnion() const
      { if (spec & TS_UNION)    return true; return false; };
   bool             IsStruct() const
      { if (spec & TS_STRUCT)   return true; return false; };

private:
   Specifier               spec;		// all types
   const char            * name;		// enums, structs and unions
   StructDeclarationList * struct_decl_list;	// structs and unions
   EnumeratorList        * enum_list;		// enums

   static int anonymous_number;
};
//-----------------------------------------------------------------------------
class InitDeclarator : public Node
{
public:
   InitDeclarator(Declarator * decl, Initializer * init)
   : Node("InitDeclarator"),
     declarator(decl),
     initializer(init)
     {};

   virtual void Emit(FILE * out);

   Declarator * GetDeclarator() const   { return declarator; };

   const char * GetDeclaredName(int skip);
   void Allocate(FILE * out, TypeSpecifier * spec);
   int  EmitAutovars(FILE * out, TypeSpecifier * spec);
      
private:
   Declarator  * declarator;
   Initializer * initializer;
};
//-----------------------------------------------------------------------------
class Declaration : public Node
{
public:
   Declaration(TypeSpecifier * ds, InitDeclaratorList * il);

   virtual void Emit(FILE * out);

   void Allocate(FILE * out);
   int  EmitAutovars(FILE * out);

private:
   TypeSpecifier      * base_type;
   InitDeclaratorList * init_list;
};
//-----------------------------------------------------------------------------
class TypeName : public Node
{
public:
   TypeName(TypeSpecifier * ds, Declarator * ad);
   TypeName(Specifier sp);

   virtual void Emit(FILE * out);
   int Print(FILE * out) const;

   Declarator     * GetDeclarator()    const   { return abs_declarator; };
   TypeSpecifier  * GetTypeSpecifier() const   { return decl_spec;  };
   const char     * GetDeclaredName();
   TypeName       * GetFunReturnType();

   TypeName *       AddressOf() const;
   TypeName *       ContentOf() const;
   TypeName *       GetElementType() const;
   bool             IsNumericType() const;  // char, short, or int
   bool             IsPointer() const;
   Expression *     ArrayLength() const;
   void             SetArrayLength(int len);
   bool             IsStruct()    const;
   bool             IsUnion()     const;
   bool             IsArray()     const;
   int              GetPointeeSize() const;
   TypeName *       GetMemberType(const char * member);
   TypeName *       FirstUnionMember(int size) const;

   int GetFunReturnSize()
       { return decl_spec->GetFunReturnSize(abs_declarator); };
   int GetSize() const
       { return decl_spec->GetSize(abs_declarator); };
   SUW GetSUW();
   bool IsUnsigned() const;
   bool IsFunPtr() const
       { return ::IsFunPtr(abs_declarator); };
   ParameterDeclarationList * GetParameters() const
       { return ::GetParameters(abs_declarator); };

private:
   TypeSpecifier * decl_spec;
   Declarator    * abs_declarator;
};
//-----------------------------------------------------------------------------
class Statement : public Node
{
public:
   Statement(const char * ntype)
   : Node(ntype)
   {};

   virtual void Emit(FILE * out) = 0;
   virtual bool NotEmpty() const   { return true; };
   virtual bool EmitCaseJump(FILE * out, bool def, int loop, int size)
      { return false; };
};
//-----------------------------------------------------------------------------
class LabelStatement : public Statement
{
public:
   LabelStatement(const char * n, Statement * stat)
   : Statement("Label Statement"),
     label_name(n),
     statement(stat)
     {};

   virtual void Emit(FILE * out);

private:
   const char * label_name;
   Statement  * statement;
};
//-----------------------------------------------------------------------------
class CaseStatement : public Statement
{
public:
   CaseStatement(Expression * exp, Statement * stat)
   : Statement("case Statement"),
     case_value(exp),
     statement(stat)
     {};

   virtual void Emit(FILE * out);
   virtual bool EmitCaseJump(FILE * out, bool def, int loop, int size);

private:
   Expression * case_value;		// case, or 0 for default
   Statement  * statement;
};
//-----------------------------------------------------------------------------
class CompoundStatement : public Statement
{
public:
   CompoundStatement(DeclarationList * dl, StatementList * sl)
   : Statement("CompoundStatement"),
     decl_list(dl),
     stat_list(sl)
     {};

   virtual void Emit(FILE * out);
   virtual bool NotEmpty() const   { return decl_list || stat_list; };
   void EmitCaseJumps(FILE * out, int size);

   int  EmitAutovars(FILE * out);
      
private:
   DeclarationList * decl_list;
   StatementList   * stat_list;
};
//-----------------------------------------------------------------------------
class ExpressionStatement : public Statement
{
public:
   ExpressionStatement(Expression * expr)
   : Statement("ExpressionStatement"),
     expression(expr)
   {};
   
   virtual void Emit(FILE * out);
   virtual bool NotEmpty() const   { return expression; };

   Expression * GetExpression() const   { return expression; };
      
private:
   Expression * expression;
};
//-----------------------------------------------------------------------------
class SwitchStatement : public Statement
{
public:
   SwitchStatement(Expression * cond, CompoundStatement * cas)
   : Statement("SwitchStatement"),
     condition(cond),
     case_stat(cas)
   {};

   virtual void Emit(FILE * out);
      
private:
   Expression         * condition;
   CompoundStatement  * case_stat;
};
//-----------------------------------------------------------------------------
class IfElseStatement : public Statement
{
public:
   IfElseStatement(Expression * cond, Statement * ifs, Statement * els)
   : Statement("IfElseStatement"),
     condition(cond),
     if_stat(ifs),
     else_stat(els)
   {};

   virtual void Emit(FILE * out);
      
private:
   Expression * condition;
   Statement  * if_stat;
   Statement  * else_stat;
};
//-----------------------------------------------------------------------------
class DoWhileStatement : public Statement
{
public:
   DoWhileStatement(Statement * bdy, Expression * cond)
   : Statement("do while Statement"),
     condition(cond),
     body(bdy)
     {};

   virtual void Emit(FILE * out);
      
private:
   Expression           * condition;
   Statement            * body;
};
//-----------------------------------------------------------------------------
class WhileStatement : public Statement
{
public:
   WhileStatement(Expression * cond, Statement * bdy)
   : Statement("while Statement"),
     condition(cond),
     body(bdy)
     {};

   virtual void Emit(FILE * out);
      
private:
   Expression           * condition;
   Statement            * body;
};
//-----------------------------------------------------------------------------
class ForStatement : public Statement
{
public:

   ForStatement(ExpressionStatement * f1, ExpressionStatement * f2,
                      Expression * f3, Statement * bdy)
   : Statement("for Statement"),
     for_1(f1),
     for_2(f2),
     for_3(f3),
     body(bdy)
     {};

   virtual void Emit(FILE * out);
      
private:
   ExpressionStatement  * for_1;
   ExpressionStatement  * for_2;
   Expression           * for_3;
   Statement            * body;
};
//-----------------------------------------------------------------------------
class GotoStatement : public Statement
{
public:
   GotoStatement(const char * lab)
   : Statement("goto Statement"),
     label_name(lab)
     {};

   virtual void Emit(FILE * out);
      
private:
   const char * label_name;
};
//-----------------------------------------------------------------------------
class ReturnStatement : public Statement
{
public:
   ReturnStatement(Expression * expr)
   : Statement("return Statement"),
     retval(expr)
     {};

   virtual void Emit(FILE * out);
      
private:
   Expression * retval;
};
//-----------------------------------------------------------------------------
class ContStatement : public Statement
{
public:
   ContStatement(bool do_brk)
   : Statement("break/continue Statement"),
     do_break(do_brk)
     {};

   virtual void Emit(FILE * out);
      
private:
   bool	do_break;   // true for break, false for continue
};
//-----------------------------------------------------------------------------
class FunctionDefinition : public Node
{
public:
   FunctionDefinition(TypeSpecifier * ds, Declarator * decl,
                      DeclarationList * dl);

   virtual void Emit(FILE * out);

   FunctionDefinition * SetBody(CompoundStatement * bdy)
      { body = bdy;  return this; };
      
private:
   TypeName          * ret_type;
   Declarator        * fun_declarator;
   DeclarationList   * decl_list;
   CompoundStatement * body;
};
//-----------------------------------------------------------------------------

#endif
