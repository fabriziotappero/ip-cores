
#include <stdio.h>
#include <assert.h>
#include "Node.hh"
#include "Name.hh"
#include "Backend.hh"

int Node::indent = 0;
int Node::semantic_errors = 0;

int Enumerator::current = 0;
int TypeSpecifier::anonymous_number = 1;

extern FILE * out;

//-----------------------------------------------------------------------------
void NumericConstant::EmitValue_RR(FILE * out)
{
   Backend::load_rr_constant(value);
}
//-----------------------------------------------------------------------------
void NumericConstant::EmitValue_LL(FILE * out)
{
   Backend::load_ll_constant(value);
}
//-----------------------------------------------------------------------------
void StringConstant::EmitValue_RR(FILE * out)
{
   Backend::load_rr_string(string_number, 0);
}
//-----------------------------------------------------------------------------
void StringConstant::EmitValue_LL(FILE * out)
{
   Backend::load_ll_string(string_number, 0);
}
//-----------------------------------------------------------------------------
Node::Node(const char * ntype)
   : node_type(ntype)
{
   // printf("Creating %s\n", node_type);
}
//-----------------------------------------------------------------------------
void Node::Emit(FILE * out)
{
   EmitIndent(out);
   fprintf(out, "MISSING : %s\n", node_type);
   fprintf(stderr, "\n\nMISSING : %s::Emit()\n\n", node_type);
}
//-----------------------------------------------------------------------------
void Node::EmitIndent(FILE * out)
{
   fprintf(out, ";;; ");
   for (int i = 0; i < indent; i++)   fprintf(out, "  ");
}
//-----------------------------------------------------------------------------
void Node::EmitStart(FILE * out)
{
   EmitIndent(out);
   fprintf(out, "{ %d %s\n", indent, node_type);
   indent++;
}
//-----------------------------------------------------------------------------
void Node::EmitEnd(FILE * out)
{
   indent--;
   EmitIndent(out);
   fprintf(out, "} %d %s\n", indent, node_type);
}
//-----------------------------------------------------------------------------
template<> void StatementList           ::Emit(FILE * out)   { EmitList(out); }
template<> void DeclarationList         ::Emit(FILE * out)   { EmitList(out); }
template<> void InitializerList         ::Emit(FILE * out)   { EmitList(out); }
template<> void ParameterDeclarationList::Emit(FILE * out)   { EmitList(out); }
template<> void IdentifierList          ::Emit(FILE * out)   { EmitList(out); }
template<> void StructDeclaratorList    ::Emit(FILE * out)   { assert(0);     }
template<> void StructDeclarationList   ::Emit(FILE * out)   { assert(0); }
template<> void InitDeclaratorList      ::Emit(FILE * out)   { EmitList(out); }
template<> void TypeSpecifierList       ::Emit(FILE * out)   { EmitList(out); }
template<> void Declarator              ::Emit(FILE * out)   { EmitList(out); }
template<> void Pointer                 ::Emit(FILE * out)   { EmitList(out); }
//-----------------------------------------------------------------------------
void StructDeclarator::Emit(FILE * out)
{
   assert(declarator);
   EmitStart(out);
   declarator->Emit(out);
   if (expression)
      {
        EmitIndent(out);
        fprintf(out, " : bitfield\n");
      }

   EmitIndent(out);
   fprintf(out, " at position %d\n", position);
   EmitEnd(out);
}
//-----------------------------------------------------------------------------
int StructDeclarator::EmitMember(FILE * out, const char * struct_name,
                            TypeSpecifier * tspec, int pos, bool is_union)
{
   position = pos;
   if (is_union)   assert(position == 0);

   if (0)
      {
        const char * member_name = GetDeclaredName(declarator);

        assert(struct_name);
        if (member_name == 0)   member_name = "anonymous member";

        fprintf(stderr, "%s->%s at position %d\n",
                struct_name, member_name, position);
      }

   return tspec->GetSize(declarator);
}
//-----------------------------------------------------------------------------
template<>
void EnumeratorList::Emit(FILE * out)
{
   Enumerator::current = 0;

   for (EnumeratorList * el = this; el; el = el->tail)
       el->head->Emit(out);
}
//-----------------------------------------------------------------------------
void Enumerator::Emit(FILE * out)
{
   assert(name);

int val = current++;
   if (value)   
      {
        if (!value->IsNumericConstant())
           {
             fprintf(stderr, "enum value for %s is not constant\n", name);
             semantic_errors++;
           }
        else
           {
             val = value->GetConstantNumericValue();
             current = val + 1;
           }
      }
   Name::AddEnum(name, val);
}
//-----------------------------------------------------------------------------
ParameterDeclaration::ParameterDeclaration(TypeSpecifier * ds,
                                           Declarator * decl)
   : Node("ParameterDeclaration"),
     isEllipsis(false)
{
   type = new TypeName(ds, decl);

const char * pname = type->GetDeclaredName();

   if (pname)   Name::AddAuto(pname, type);
}
//-----------------------------------------------------------------------------
void ParameterDeclaration::Emit(FILE * out)
{
   EmitStart(out);
   EmitIndent(out);
   fprintf(out, "isEllipsis = ");
   if (isEllipsis)   fprintf(out, "true\r\n");
   else              fprintf(out, "false\r\n");
   type->Emit(out);
   EmitEnd(out);
}
//-----------------------------------------------------------------------------
int ParameterDeclaration::AllocateParameters(int offset)
{
const int size = type->GetSize();
const char * pname = GetDeclaredName(0);

   if (pname)   Name::SetAutoPos(pname, offset);

   return size;
}
//-----------------------------------------------------------------------------
const char * ParameterDeclaration::GetDeclaredName(int skip)
{
   for (Declarator * d = type->GetDeclarator(); d; d = d->Tail())
       {
         const char * n = d->Head()->GetName();
         if (n == 0)      continue;
         if (skip == 0)   return n;
         skip--;
       }
   return 0;
}
//-----------------------------------------------------------------------------
FunctionDefinition::FunctionDefinition(TypeSpecifier * ds,
                                       Declarator * decl,
                                       DeclarationList * dl)
   : Node("FunctionDefinition"),
     fun_declarator(decl),
     decl_list(dl),
     body(0)
{
   // these are always present...
   //
   assert(decl);

   // no type means int
   //
   if (ds == 0)   ds = new TypeSpecifier(TS_INT);

Declarator * ret_decl = 0;

   // copy decl to ret_decl up to FUN_DECL
   //
   for (Declarator * d = decl; d; d = d->Tail())
            {
              DeclItem * di = d->Head();
              assert(di);
              if (di->GetWhat() == DECL_FUN)   break;
              ret_decl = new Declarator(di, ret_decl);
            }

const char * fun_name = ::GetDeclaredName(fun_declarator);
   assert(fun_name);

   ret_type = new TypeName(ds, ret_decl);

TypeName * fun_type = new TypeName(ds, fun_declarator);
   Name::AddLocal(fun_name, fun_type);
}
//-----------------------------------------------------------------------------
void FunctionDefinition::Emit(FILE * out)
{
   EmitStart(out);

   assert(ret_type);
   ret_type->Emit(out);

   assert(fun_declarator);
   fun_declarator->Emit(out);

   if (decl_list)        decl_list->Emit(out);

   assert(body);

const char * funname = GetDeclaredName(fun_declarator);
   assert(funname);
   Backend::new_function(funname);

int ret_size = ret_type->GetSize();
   if (ret_size <= 4)   ret_size = 0;   // return value in register
   ret_size += 2;                       // return address

ParameterDeclarationList * pdl = ::GetParameters(fun_declarator);

int offset = ret_size;
   for (ParameterDeclarationList * p = pdl; p; p = p->Tail())
       {
         ParameterDeclaration * pd = p->Head();
	 assert(pd);
         offset += pd->AllocateParameters(offset);
       }

   body->Emit(out);

   Backend::ret();
   Name::RemoveAuto();
}
//-----------------------------------------------------------------------------
void InitDeclarator::Emit(FILE * out)
{
   EmitStart(out);
   if (declarator)    declarator->Emit(out);
   // don't emit initializer
   EmitEnd(out);
}
//-----------------------------------------------------------------------------
const char * InitDeclarator::GetDeclaredName(int skip)
{
const char * ret = ::GetDeclaredName(declarator);

   assert(ret);
   return ret;
}
//-----------------------------------------------------------------------------
int InitDeclarator::EmitAutovars(FILE * out, TypeSpecifier * typespec)
{
   EmitStart(out);
   assert(declarator);
   declarator->Emit(out);

   assert(typespec);
TypeName type(typespec, declarator);
const Specifier spec = typespec->GetType();

   assert(!(spec & SC_TYPEDEF));
   assert(!(spec & SC_EXTERN));

const char * name = ::GetDeclaredName(declarator);
   assert(name);

int size = type.GetSize();
   if (size < 0)   // a[]
      {
        if (initializer == 0)
           {
              fprintf(stderr, "Can't use [] without initializer\n");
              semantic_errors++;
              size = 2;
           }
        else
           {
             TypeName * etype = type.GetElementType();
             assert(etype);
             size = initializer->ElementCount() * etype->GetSize();
             assert(size > 0);
           }
      }
   Name::SetAutoPos(name, Backend::GetSP() - size);

   if (initializer)   initializer->InitAutovar(out, &type);
   else               Backend::push_zero(size);

   EmitEnd(out);
   return size;
}
//-----------------------------------------------------------------------------
void InitDeclarator::Allocate(FILE * out, TypeSpecifier * typespec)
{
const Specifier spec = typespec->GetType();

   if (spec & SC_TYPEDEF)   return;

const char * name = ::GetDeclaredName(declarator);
   assert(name);

   if (spec & SC_EXTERN)
      {
        fprintf(out, "\t.EXTERN\tC%s\n", name);
      }
   else if (spec & SC_STATIC)
      {
        // forward declaration
        fprintf(out, "\t.STATIC\tC%s\n", name);
      }
   else if (!IsFunction(declarator))
      {
        fprintf(out, "C%s:\t\t\t; \n", name);
        if (initializer)
           {
             TypeName tn(typespec, declarator);
             initializer->EmitValue(out, &tn);
           }
        else
           {
             const int size = typespec->GetSize(declarator);
             for (int b = 0; b < size; b++)
                 fprintf(out, "\t.BYTE\t0\t\t\t; VOID [%d]\r\n", b);
           }
      }
}
//-----------------------------------------------------------------------------
Declaration::Declaration(TypeSpecifier * ds, InitDeclaratorList * il)
   : Node("Declaration"),
     base_type(ds),
     init_list(il)
{
   assert(ds);

   for (InitDeclaratorList * i = init_list; i; i = i->Tail())
       {
         InitDeclarator * id = i->Head();
         assert(id);
         Declarator * decl = id->GetDeclarator();

         const char * dn = ::GetDeclaredName(decl);
         assert(dn);

        assert(base_type);
        const Specifier spec = base_type->GetType();

        if (spec & SC_TYPEDEF)
           {
             const Specifier real_spec = (Specifier)(spec & ~SC_TYPEDEF);
             TypeSpecifier * real_type = new TypeSpecifier(real_spec,
                                                base_type->GetName(),
                                                base_type->GetStructDecl());
             Declarator * ret = 0;
             for (Declarator * d = decl; d; d = d->Tail())
                 {
                   DeclItem * di = d->Head();
                   assert(di);
                   if (di->GetWhat() != DECL_NAME)
                      ret = new Declarator(di, ret);
                 }

             TypeName * tn = new TypeName(real_type, ret);
             TypedefName::Add(dn, tn);
           }
        else
           {
             TypeName * tn = new TypeName(base_type, decl);

             if (spec & SC_EXTERN)  Name::AddExtern(dn, tn);
             else if (spec & SC_STATIC)  Name::AddStatic(dn, tn);
             else                        Name::AddAuto(dn, tn);
           }
       }
}
//-----------------------------------------------------------------------------
void Declaration::Emit(FILE * out)
{
   EmitStart(out);
   if (base_type)   base_type->Emit(out);
   // if (init_list)   init_list->Emit(out);

   Allocate(out);

   EmitEnd(out);
   Name::AutoToLocal();
}
//-----------------------------------------------------------------------------
void Declaration::Allocate(FILE * out)
{
   for (InitDeclaratorList * il = init_list; il; il = il->Tail())
       {
         InitDeclarator * id = il->Head();
         assert(id);
         id->Allocate(out, base_type);
       }
}
//-----------------------------------------------------------------------------
int Declaration::EmitAutovars(FILE * out)
{
int ret = 0;

   for (InitDeclaratorList * il = init_list; il; il = il->Tail())
       {
         InitDeclarator * id = il->Head();
         assert(id);
         ret += id->EmitAutovars(out, base_type);
       }

   return ret;
}
//-----------------------------------------------------------------------------
void Ptr::Emit(FILE * out)
{
   EmitStart(out);
   if (decl_specs)   decl_specs->Emit(out);
   EmitEnd(out);
}
//-----------------------------------------------------------------------------
int Initializer::ElementCount() const
{
   if (skalar_value)   return 1;
   return InitializerList::Length(array_value);
}
//-----------------------------------------------------------------------------
void Initializer::Emit(FILE * out)
{
   // debug only: must call EmitValue() or EmitAutovars()
   EmitStart(out);
   if (skalar_value)   skalar_value->Emit(out);
   if (array_value)    array_value ->Emit(out);
   EmitEnd(out);
}
//-----------------------------------------------------------------------------
void Initializer::EmitValue(FILE * out, TypeName * tn)
{
   while (tn->IsUnion())
      {
        int union_size = tn->GetSize();
        TypeName * first = tn->FirstUnionMember(union_size);
        assert(first);
        tn = first;
      }

   if (skalar_value)
      {
        if (tn->IsArray())   // char x[] = "abc" ?
           {
             if (tn->GetElementType()->GetSize() != 1)
                {
                  fprintf(stderr,
                          "Initialization of array with skalar or string\n");
                  semantic_errors++;
                  return;
                }

           if (!skalar_value->IsStringConstant())
                {
                  fprintf(stderr,
                          "Initialization of char array with non-string\n");
                  semantic_errors++;
                  return;
                }

           int len = tn->GetSize();
           if (len == -1)
              {
                len = skalar_value->GetSize();   // x[] = "..."
                tn->SetArrayLength(len);
              }

           StringConstant * sc = skalar_value->GetStringConstant();
           assert(sc);
           sc->EmitAndRemove(out, len);
           return;
           }

        skalar_value->EmitInitialization(out, tn->GetSize());
        return;
      }

   assert(array_value);

   // array or struct...
   // check for array
   //
   if (tn->IsArray())
      {
        int elements;
        Expression * alen = tn->ArrayLength();
        if (alen)    // a[len]
           {
             elements = alen->GetConstantNumericValue();
           }
        else         // a[]
           {
             elements = List<Initializer>::Length(array_value);
             tn->SetArrayLength(elements);
           }

        TypeName * etype = tn->GetElementType();
        assert(etype);
        const int size = etype->GetSize();
        int done = 0;

        for (InitializerList * il = array_value; il; il = il->Tail())
            {
              if (done == elements)
                 {
                   fprintf(stderr, "Too many array initializers\n");
                   semantic_errors++;
                   return;
                 }

              Initializer * in = il->Head();
              assert(in);
              in->EmitValue(out, etype);
              done++;
            }

        // init unspecified array elements to 0
	//
        for (int b = done; b < elements; b++)
            {
              if (size == 1)
                 fprintf(out, "\t.BYTE\t0\t\t\t; VOID[%d]\r\n", b);
              else if (size == 2)
                 fprintf(out, "\t.WORD\t0\t\t\t; VOID[%d]\r\n", b);
              else
                 {
                   for (int i = 0; i < size; i++)
                   fprintf(out, "\t.BYTE\t0\t\t\t; VOID[%d]\r\n", b);
                 }
            }

        return;
      }

   // struct...
   //
   if (!tn->IsStruct())
      {
        fprintf(stderr, "Initialization of skalar type with array\n");
        semantic_errors++;
        return;
      }

TypeSpecifier * ts = tn->GetTypeSpecifier();
   assert(ts);

const char * sname = ts->GetName();
   if (sname == 0)
      {
        fprintf(stderr, "No struct name in struct initializer\n");
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

InitializerList * il = array_value;

   for (; sdl; sdl = sdl->Tail())
       {
         StructDeclaration * sd = sdl->Head();
         assert(sd);
         TypeSpecifier * ts = sd->GetSpecifier();
         assert(ts);

         for (StructDeclaratorList * sr = sd->GetDeclarators(); sr;
              sr = sr->Tail())
            {
              StructDeclarator * sor = sr->Head();
              assert(sor);

              Declarator * decl = sor->GetDeclarator();
              assert(decl);

              const char * membname = sor->GetMemberName();
              if (membname == 0)   membname = "anonymous";

              TypeName type(ts, decl);
              if (il == 0)
                 {
                   const int size = type.GetSize();
                   if (size == 1)
                      fprintf(out, "\t.BYTE\t0\t\t\t; VOID %s\r\n", membname);
                   else if (size == 2)
                      fprintf(out, "\t.WORD\t0\t\t\t; VOID %s\r\n", membname);
                   else
                      {
                        for (int i = 0; i < size; i++)
                        fprintf(out, "\t.BYTE\t0\t\t\t; VOID %s\r\n", membname);
                      }
                 }
              else
                 {
                   Initializer * ini = il->Head();
                   assert(ini);
                   il = il->Tail();
                   ini->EmitValue(out, &type);
                 }
            }
       }
}
//-----------------------------------------------------------------------------
int Initializer::InitAutovar(FILE * out, TypeName * type)
{
int ret = 0;

   EmitStart(out);

   while (type->IsUnion())
      {
        int union_size = type->GetSize();
        TypeName * first = type->FirstUnionMember(union_size);
        assert(first);
        type = first;
      }

   if (skalar_value)
      {
        assert(!array_value);

        if (type->GetSize() > 2)   // fixme: check for valid size
           {
             fprintf(stderr, "Initialization of compound type with skalar\n");
             semantic_errors++;
             return 2;
           }

        SUW suw = type->GetSUW();
        ret = 1;   if (suw == WO)   ret = 2;

        if (skalar_value->IsNumericConstant())
           {
             int value = skalar_value->GetConstantNumericValue();
             if (value == 0)
                {
                  Backend::push_zero(ret);
                }
            else
                {
                  skalar_value->Emit(out);
                  Backend::push_rr(suw);
                }
           }
        else
           {
             skalar_value->Emit(out);
             Backend::push_rr(suw);
           }
        EmitEnd(out);
        return ret;
      }


   assert(array_value);

   // array or struct...
   // check for array
   //
   //
   ret = type->GetSize();
InitializerList * arev = array_value->Reverse();
int alen = InitializerList::Length(arev);

   if (type->IsArray())
      {
        TypeName * etype = type->GetElementType();
        int esize = etype->GetSize();
        Expression * lenexpr = type->ArrayLength();
        int len = alen;
        if (lenexpr)   len = lenexpr->GetConstantNumericValue();

        if (alen > len)
           {
             fprintf(stderr, "Too many array initializer\n");
             semantic_errors++;
             return ret;
           }

        for (; alen < len; len--)
            {
              Backend::push_zero(esize);
            }

        for (; arev; arev = arev->Tail())
            {
              Initializer * ini = arev->Head();
              assert(ini);
              ini->InitAutovar(out, etype);
            }
        return ret;
      }

   // struct...
   //
   if (!type->IsStruct())
      {
        fprintf(stderr, "Initialization of skalar type with array\n");
        semantic_errors++;
        return ret;
      }

TypeSpecifier * ts = type->GetTypeSpecifier();
   assert(ts);

const char * sname = ts->GetName();
   if (sname == 0)
      {
        fprintf(stderr, "No struct name in struct initializer\n");
        semantic_errors++;
        return 2;
      }

StructDeclarationList * sdl = StructName::Find(sname);
   if (sdl == 0)
      {
        fprintf(stderr, "No struct %s defined\n", sname);
        semantic_errors++;
        return 2;
      }

   // compute member count...
   // 
int len = 0;
   for (StructDeclarationList * s = sdl; s; s = s->Tail())
       {
         StructDeclaration * sd = s->Head();
         assert(sd);
         len += sd->GetDeclaratorCount();
       }

   if (alen > len)
      {
        fprintf(stderr, "Too many struct initializer\n");
        semantic_errors++;
        return ret;
      }

   while (alen < len)   // uninitialized members
      {
        TypeName * tn = GetMemberType(sdl, --len);
        assert(tn);
        Backend::push_zero(tn->GetSize());
      }

   while (len)   // uninitialized members
      {
        TypeName * tn = GetMemberType(sdl, --len);
        assert(tn);

        assert(arev);
        Initializer * ini = arev->Head();
        assert(ini);
        arev = arev->Tail();
        ini->InitAutovar(out, tn);
      }

   EmitEnd(out);
   return ret;
}
//-----------------------------------------------------------------------------
TypeName * TypeSpecifier::GetMemberType(const char * member)
{
const int is_union  = spec & TS_UNION;
const int is_struct = spec & TS_STRUCT;

   if (!is_union && !is_struct)
      {
        fprintf(stderr, "access member %s of non-aggregate\n", member);
        semantic_errors++;
        return 0;
      }

StructDeclarationList * sdl = StructName::Find(name);
        if (sdl == 0)
            {
              fprintf(stderr, "No struct %s defined\n", name);
              semantic_errors++;
              return 0;
            }

   for (; sdl ; sdl = sdl->Tail())
       {
         StructDeclaration * sd = sdl->Head();
         assert(sd);
         TypeName * st = sd->GetMemberType(name, member);
         if (st)   return st;
       }

   fprintf(stderr, "aggregate %s has no member %s\n", name, member);
   semantic_errors++;
   return 0;
}
//-----------------------------------------------------------------------------
int StructDeclaration::Emit(FILE * out, const char * struct_name, int pos,
                            bool is_union)
{
   size = 0;
   for (StructDeclaratorList * sl = struct_decl_list; sl ; sl = sl->Tail())
       {
         StructDeclarator * sd = sl->Head();
         assert(sd);

         if (is_union)
            {
              int tsize = sd->EmitMember(out, struct_name,
                                         decl_specifiers, 0, true);
              if (size < tsize)   size = tsize;
            }
         else
            {
              size += sd->EmitMember(out, struct_name,
                                     decl_specifiers, pos + size, false);
            }
       }

   return size;
}
//-----------------------------------------------------------------------------
TypeName * StructDeclaration::GetMemberType(const char * struct_name,
                                                 const char * member)
{
   for (StructDeclaratorList * sl = struct_decl_list; sl ; sl = sl->Tail())
       {
         StructDeclarator * sd = sl->Head();
         assert(sd);
         TypeName * st = sd->GetMemberType(decl_specifiers, member);
         if (st)   return st;
       }

   return 0;
}
//-----------------------------------------------------------------------------
TypeName * StructDeclaration::GetMemberType(int pos)
{
   for (StructDeclaratorList * sl = struct_decl_list; sl ; sl = sl->Tail())
       {
         StructDeclarator * sd = sl->Head();
         assert(sd);

         if (pos == 0)   return new TypeName(decl_specifiers,
			                     sd->GetDeclarator());
         --pos;
       }

   return 0;
}
//-----------------------------------------------------------------------------
TypeName * StructDeclaration::FirstUnionMember(int union_size) const
{
   for (StructDeclaratorList * sl = struct_decl_list; sl ; sl = sl->Tail())
       {
         StructDeclarator * sd = sl->Head();
         assert(sd);
         TypeName * st = sd->FirstUnionMember(decl_specifiers, union_size);
         if (st)   return st;
       }

   return 0;
}
//-----------------------------------------------------------------------------
int StructDeclaration::GetMemberPosition(const char * struct_name,
                                         const char * member,
                                         bool is_union) const
{
   if (is_union)   return 0;

   for (StructDeclaratorList * sl = struct_decl_list; sl ; sl = sl->Tail())
       {
         StructDeclarator * sd = sl->Head();
         assert(sd);
         int position = sd->GetMemberPosition(member);
         if (position >= 0)   return position;
       }

   return -1;
}
//-----------------------------------------------------------------------------
TypeName * StructDeclarator::GetMemberType(TypeSpecifier * tspec,
                                           const char * member)
{
   for (Declarator * decl = declarator; decl; decl = decl->Tail())
       {
         DeclItem * di = decl->Head();
         assert(di);
         if (di->GetWhat() != DECL_NAME)      continue;
         assert(di->GetName());
         if (strcmp(member, di->GetName()))   continue;
         return new TypeName(tspec, declarator);
       }

   return 0;
}
//-----------------------------------------------------------------------------
TypeName * StructDeclarator::FirstUnionMember(TypeSpecifier * tspec,
                                              int union_size) const
{
   for (Declarator * decl = declarator; decl; decl = decl->Tail())
       {
         TypeName tn(tspec, declarator);
         if (tn.GetSize() != union_size)   continue;

         return new TypeName(tspec, declarator);
       }

   return 0;
}
//-----------------------------------------------------------------------------
const char * StructDeclarator::GetMemberName() const
{
   for (Declarator * decl = declarator; decl; decl = decl->Tail())
       {
         DeclItem * di = decl->Head();
         assert(di);
         if (di->GetWhat() != DECL_NAME)      continue;
         assert(di->GetName());
         return di->GetName();
       }

   return 0;
}
//-----------------------------------------------------------------------------
int StructDeclarator::GetMemberPosition(const char * member) const
{
   for (Declarator * decl = declarator; decl; decl = decl->Tail())
       {
         DeclItem * di = decl->Head();
         assert(di);
         if (di->GetWhat() != DECL_NAME)      continue;
         assert(di->GetName());
         if (strcmp(member, di->GetName()))   continue;
         return position;
       }

   return -1;
}
//-----------------------------------------------------------------------------
bool TypeSpecifier::IsNumericType() const
{
   if (spec & TS_NUMERIC)      return true;
   if (spec != TS_TYPE_NAME)   return false;

   assert(name);
TypeName * tname = TypedefName::Find(name);
   assert(tname);
   return tname->IsNumericType();
}
//-----------------------------------------------------------------------------
int TypeSpecifier::GetBaseSize() const
{
   if (spec & TS_VOID)      return 0;
   if (spec & TS_CHAR)      return 1;
   if (spec & TS_SHORT)     return 2;
   if (spec & TS_INT)       return 2;
   if (spec & TS_LONG)      return 4;
   if (spec & TS_FLOAT)     return 4;
   if (spec & TS_DOUBLE)    return 8;
   if (spec & TS_ENUM)      return 2;
   if (spec & (TS_STRUCT | TS_UNION))
      {
        assert(name);
        StructDeclarationList * sdl = StructName::Find(name);
        if (sdl == 0)
            {
              fprintf(stderr, "No struct %s defined\n", name);
              semantic_errors++;
              return 0;
            }

        int size = 0;
        for (; sdl; sdl = sdl->Tail())
            {
               assert(sdl->Head());
               int tsize = sdl->Head()->GetSize();
               if (spec & TS_UNION)
                  {
                    if (size < tsize)   size = tsize;
                  }
               else
                  {
                    size += tsize;
                  }
            }
         return size;
      }

   if (spec & TS_TYPE_NAME)
      {
        assert(name);
        TypeName * tname = TypedefName::Find(name);
        assert(tname);
        return tname->GetTypeSpecifier()->GetBaseSize();
      }

   return 2;	// no type -> int
}
//-----------------------------------------------------------------------------
int TypeSpecifier::GetSize(Declarator * decl) const
{
int size = -2;

   for (; decl; decl = decl->Tail())
       {
         const DeclItem * ditem = decl->Head();
         assert(ditem);

         switch(ditem->GetWhat())
            {
              case DECL_FUNPTR:
                   size = 2;
                   continue;

              case DECL_POINTER:
                   size = 2;
                   continue;

              case DECL_FUN:
                   size = 2;
                   continue;

              case DECL_ARRAY:
                   if (ditem->GetArraySize())     // type[num]
                      {
                        if (size == -2)   size = GetBaseSize();
                        size *= ditem->GetArraySize()
                                     ->GetConstantNumericValue();
                      }
                   else                           // type[]
                      {
                        size = -1;
                      }
                   continue;

              case DECL_NAME:
                   continue;   // varname

              default: assert(0 && "BAD what");
            }
       }

   if (size == -2)   return GetBaseSize();
   return size;
}
//-----------------------------------------------------------------------------
int TypeSpecifier::GetFunReturnSize(Declarator * decl) const
{
   assert(this);
   if (decl == 0)
      {
        fprintf(stderr, "Can't get parameters of (undeclared ?) function\n");
        semantic_errors++;
        return 0;
      }

int base_size = GetBaseSize();

   for (; decl; decl = decl->Tail())
       {
         DeclItem * di = decl->Head();
         assert(di);
         const Expression * asize = di->GetArraySize();

         switch(di->GetWhat())
            {
              case DECL_NAME:
                   continue;

              case DECL_FUNPTR:
                   base_size = 2;
                   continue;

              case DECL_ARRAY:
                   if (asize == 0)   // []
                      base_size = 2;
                   else                      // [const expr]
                      base_size *= asize->GetConstantNumericValue();
                   continue;

              case DECL_FUN:
                   continue;

              case DECL_POINTER:
                   base_size = 2;
                   continue;

              default: assert(0 && "Bad InitDeclarator::what");
            }
       }

   return base_size;
}
//-----------------------------------------------------------------------------
TypeSpecifier * TypeSpecifier::operator +(TypeSpecifier & other)
{
int sc_cnt = 0;
int tq_cnt = 0;
int si_cnt = 0;
int ty_cnt = 0;

   if (spec & SC_MASK)              sc_cnt++;
   if (spec & TQ_MASK)              tq_cnt++;
   if (spec & TS_SIGN_MASK)         si_cnt++;
   if (spec & TS_MASK)              ty_cnt++;

   if (other.spec & SC_MASK)        sc_cnt++;
   if (other.spec & TQ_MASK)        tq_cnt++;
   if (other.spec & TS_SIGN_MASK)   si_cnt++;
   if (other.spec & TS_MASK)        ty_cnt++;

   if (sc_cnt > 1)
      {
         fprintf(stderr, "Multiple or contradicting storage class (ignored)\n");
         semantic_errors++;
	 delete other.self();
	 return this;
      }

   if (tq_cnt > 1)
      {
         fprintf(stderr, "Multiple or contradicting qualifiers (ignored)\n");
         semantic_errors++;
	 delete other.self();
	 return this;
      }

   if (si_cnt > 1)
      {
         fprintf(stderr,
                 "Multiple or Contradicting signed/unsigned (ignored)\n");
         semantic_errors++;
	 delete other.self();
	 return this;
      }

   if (ty_cnt > 1)
      {
         fprintf(stderr, "Multiple or Contradicting types (ignored)\n");
         semantic_errors++;
	 delete other.self();
	 return this;
      }

   if (other.enum_list)          enum_list        = other.enum_list;
   if (other.name)               name             = other.name;
   if (other.struct_decl_list)   struct_decl_list = other.struct_decl_list;

   spec = (Specifier)(spec | other.spec);
   delete other.self();
   return this;
}
//-----------------------------------------------------------------------------
int TypeSpecifier::Print(FILE * out) const
{
int len = 0;

   if (spec & SC_TYPEDEF)   len += fprintf(out, "typedef ");
   if (spec & SC_EXTERN)    len += fprintf(out, "extern ");
   if (spec & SC_STATIC)    len += fprintf(out, "static ");
   if (spec & SC_AUTO)      len += fprintf(out, "auto ");
   if (spec & SC_REGISTER)  len += fprintf(out, "register ");

   if (spec & TQ_CONST)     len += fprintf(out, "const ");
   if (spec & TQ_VOLATILE)  len += fprintf(out, "volatile ");

   if (spec & TS_SIGNED)    len += fprintf(out, "signed ");
   if (spec & TS_UNSIGNED)  len += fprintf(out, "unsigned ");

   if (spec & TS_VOID)      len += fprintf(out, "void ");
   if (spec & TS_CHAR)      len += fprintf(out, "char ");
   if (spec & TS_SHORT)     len += fprintf(out, "short ");
   if (spec & TS_INT)       len += fprintf(out, "int ");
   if (spec & TS_LONG)      len += fprintf(out, "long ");
   if (spec & TS_FLOAT)     len += fprintf(out, "float ");
   if (spec & TS_DOUBLE)    len += fprintf(out, "double ");

   if (spec & TS_STRUCT)
      {
        assert(name);
        len += fprintf(out, "struct '%s' ", name);
      }

   if (spec & TS_UNION)
      {
        assert(name);
        len += fprintf(out, "union '%s' ", name);
      }

   if (spec & TS_ENUM)
      {
        if (name)   len += fprintf(out, "enum '%s' ", name);
        else        len += fprintf(out, "anonymous enum ");
      }

   if (spec & TS_TYPE_NAME)
      {
        if (name)   len += fprintf(out, "'%s' ", name);
        else        len += fprintf(out, "<user type> ");
      }

   return len;
}
//-----------------------------------------------------------------------------
// struct, union, or typedef
//
TypeSpecifier::TypeSpecifier(Specifier sp, const char * n,
                             StructDeclarationList * sdl)
   : Node("TypeSpecifier (struct/union)"),
     spec(sp),
     name(n),
     struct_decl_list(sdl),
     enum_list(0)
{
   if (name == 0)   // anonymous struct or union
      {
        char * cp = new char[20];
        sprintf(cp, "anonymous-%d", anonymous_number++);
        name = cp;
      }

   if (struct_decl_list)   StructName::Add(name, struct_decl_list);
}
//-----------------------------------------------------------------------------
void TypeSpecifier::Emit(FILE * out)
{
   EmitStart(out);
   EmitIndent(out);
   fprintf(out, "spec = ");

   Print(out);

   fprintf(out, "(%X)\n", spec);

   if (name)
      {
        EmitIndent(out);
        fprintf(out, "name = %s\n", name);
      }

   if (struct_decl_list)
      {
        int pos = 0;
        for (StructDeclarationList * sl = struct_decl_list; sl; sl = sl->Tail())
            {
              assert(sl->Head());
              pos += sl->Head()->Emit(out, name, pos, IsUnion());
            }
      }

   if (enum_list)
      {
        if (name)   TypedefName::Add(name, new TypeName(TS_INT));
        enum_list->Emit(out);
      }
   EmitEnd(out);
}
//-----------------------------------------------------------------------------
int Ptr::Print(FILE * out) const
{
   return fprintf(out, "* ");
}
//-----------------------------------------------------------------------------
void DeclItem::SetArraySize(int len)
{
   assert(!array_size);
   assert(len >= 0);
   array_size = new NumericExpression(len);
}
//-----------------------------------------------------------------------------
int DeclItem::Print(FILE * out) const
{
   switch(what)
      {
        case DECL_FUNPTR:    return fprintf(out, "*() ");
        case DECL_ARRAY:     if (!array_size) return fprintf(out, "[] ");
                             return fprintf(out, "[%d] ",
                                    array_size->GetConstantNumericValue());
        case DECL_FUN:       return fprintf(out, "() ");
        case DECL_POINTER:   {
                               assert(pointer);
                               int len = 0;
                               for (Pointer * p = pointer; p; p = p->Tail())
                                   len += p->Head()->Print(out);
                               return len;
                             }
        case DECL_NAME:      assert(name);
                             return fprintf(out, "%s ", name);
      }

   assert(0 ** "Bad what");
}
//-----------------------------------------------------------------------------
void DeclItem::Emit(FILE * out)
{
const char * s = "BAD DECL";

   EmitStart(out);
   switch(what)
      {
        case DECL_NAME:      s = "DECL_NAME";       break;
        case DECL_FUNPTR:    s = "DECL_FUNPTR";     break;
        case DECL_ARRAY:     s = "DECL_ARRAY";      break;
        case DECL_FUN:       s = "DECL_FUN";        break;
        case DECL_POINTER:   s = "DECL_POINTER";    break;
      }
   EmitIndent(out);
   fprintf(out, "what = %s\r\n", s);

   if (name)
      {
        EmitIndent(out);
        fprintf(out, "name = %s\r\n", name);
      }

   if (funptr)            funptr->Emit(out);
   // don't emit array_size
   if (fun_params)        fun_params->Emit(out);
   if (fun_identifiers)   fun_identifiers->Emit(out);
   if (pointer)           pointer->Emit(out);
   EmitEnd(out);
}
//-----------------------------------------------------------------------------
TypeName::TypeName(TypeSpecifier * ds, Declarator * ad)
   : Node("TypeName"),
     decl_spec(ds),
     abs_declarator(ad)
{
   assert(ds);
   if (ds->GetType() & TS_TYPE_NAME)
      {
        const char * name = decl_spec->GetName();
        assert(name);

        TypeName * def = TypedefName::Find(name);
        assert(def);

        // copy type specifier from definition...
        // 
        decl_spec = def->GetTypeSpecifier();
        assert(decl_spec);

        // prepend declarator from definition
        //
        for (Declarator * decl = def->abs_declarator->Reverse();
             decl; decl = decl->Tail())
            abs_declarator = new Declarator(decl->Head(), abs_declarator);
      }
}
//-----------------------------------------------------------------------------
TypeName::TypeName(Specifier sp)
   : Node("TypeName (internal)"),
     decl_spec(new TypeSpecifier(sp)),
     abs_declarator(0)
{
   assert((sp & TS_TYPE_NAME) == 0);
}
//-----------------------------------------------------------------------------
void TypeName::Emit(FILE * out)
{
   EmitStart(out);
   if (decl_spec)        decl_spec->Emit(out);
   if (abs_declarator)   abs_declarator->Emit(out);
   EmitEnd(out);
}
//-----------------------------------------------------------------------------
SUW TypeName::GetSUW()
{
   if (IsPointer())   return WO;

const int size = GetSize();

   if (size == 2)   return WO;
if (size != 1)
{
fprintf(stderr, "---- Size not 1 or 2:\n");
Emit(stderr);
fprintf(stderr, "\n====\n");
 *(char*)0 = 0;
// for (;;)   fprintf(stderr, "?");
fprintf(stderr, "\n====\n");
}
   assert(size == 1);
   if (IsUnsigned())   return UB;
   return SB;
}
//-----------------------------------------------------------------------------
bool TypeName::IsUnsigned() const
{
   if (IsPointer())   return true;
   return decl_spec->IsUnsigned();
}
//-----------------------------------------------------------------------------
bool TypeName::IsNumericType() const
{
   if (!decl_spec->IsNumericType())   return false;

   for (Declarator * d = abs_declarator; d; d = d->Tail())
       {
         DeclItem * di = d->Head();
         assert(di);
         switch(di->GetWhat())
            {
              case DECL_NAME:    continue;
              case DECL_FUNPTR:  return false;
              case DECL_ARRAY:   return false;
              case DECL_FUN:     return true;
              case DECL_POINTER: return false;
              default:           assert(0 && "Bad what");
            }
       }
   return true;
}
//-----------------------------------------------------------------------------
TypeName * TypeName::GetFunReturnType()
{
   assert(this);

   if (abs_declarator)
      {
        Declarator * ret = 0;
        for (Declarator * decl = abs_declarator; decl; decl = decl->Tail())
            {
              DECL_WHAT what = decl->Head()->GetWhat();
              if (what == DECL_FUNPTR || what == DECL_FUN)
                 return new TypeName(decl_spec, ret->Reverse());

              ret = new Declarator(decl->Head(), ret);
            }
      }

   Print(stderr);
   fprintf(stderr, " is not a function\n");
   semantic_errors++;
   return new TypeName(TS_INT);
}
//-----------------------------------------------------------------------------
TypeName * TypeName::GetMemberType(const char * member)
{
TypeName * tn = decl_spec->GetMemberType(member);
   if (tn)   return tn;

const char * sname = decl_spec->GetName();
   assert(sname);

   fprintf(stderr, "aggregate %s has no member %s\n", sname, member);
   semantic_errors++;
   return this;
}
//-----------------------------------------------------------------------------
TypeName * TypeName::FirstUnionMember(int union_size) const
{
   assert(IsUnion());
   assert(decl_spec);

const char * uname = decl_spec->GetName();
   assert(uname);

StructDeclarationList * sdl = StructName::Find(uname);
   if (sdl == 0)
      {
        fprintf(stderr, "No struct %s defined\n", uname);
        semantic_errors++;
        return 0;
      }

   for (; sdl; sdl = sdl->Tail())
       {
         StructDeclaration * sd = sdl->Head();
         assert(sd);

         TypeName * ret = sd->FirstUnionMember(union_size);
         if (ret)   return ret;
       }

   assert(0);
}
//-----------------------------------------------------------------------------
TypeName * TypeName::AddressOf() const
{
   assert(this);
   assert(decl_spec);

Ptr * newptr = new Ptr(0);

   if (abs_declarator == 0 || abs_declarator->Head()->GetWhat() != DECL_POINTER)
      {
        Pointer * pointer = new Pointer(newptr, 0);
        DeclItem * di     = new DeclItem(pointer);
        Declarator * decl = new Declarator(di, abs_declarator);
        return new TypeName(decl_spec, decl);
      }

DeclItem * hd = abs_declarator->Head();
   assert(hd);
   assert(hd->GetWhat() == DECL_POINTER);

Pointer * pointer  = new Pointer(newptr, hd->GetPointer());
DeclItem * di      = new DeclItem(pointer);
Declarator * decl  = new Declarator(di, abs_declarator->Tail());
   return new TypeName(decl_spec, decl);
}
//-----------------------------------------------------------------------------
TypeName * TypeName::ContentOf() const
{
   assert(this);
   assert(decl_spec);

   if (!abs_declarator)
      {
	semantic_errors++;
        Print(stderr);
        fprintf(stderr, " is not a pointer\n");
        return new TypeName(new TypeSpecifier(TS_INT), 0);
      }

DeclItem * hd = abs_declarator->Head();
   assert(hd);

   if (hd->GetWhat() != DECL_POINTER)
      {
        if (IsArray())
           {
             Declarator * ret = 0;
             Declarator * last = 0;
             for (Declarator * d = abs_declarator; d; d = d->Tail())
                 {
                   DeclItem * di = d->Head();
                   assert(di);
                   if (di->GetWhat() == DECL_ARRAY)  last = d;
                 }

             assert(last);
             for (Declarator * d = abs_declarator; d; d = d->Tail())
                 {
                   if (d != last)   ret = new Declarator(d->Head(), ret);
                 }
             ret = ret->Reverse();
             return new TypeName(decl_spec, ret);
           }
	semantic_errors++;
        Print(stderr);
        fprintf(stderr, " is not a pointer\n");
        return new TypeName(new TypeSpecifier(TS_INT), 0);
      }

Pointer * pointer = hd->GetPointer();
   assert(pointer);
   pointer = pointer->Tail();
   if (!pointer)   return new TypeName(decl_spec, abs_declarator->Tail());

DeclItem * new_hd = new DeclItem(pointer);
Declarator * decl = new Declarator(new_hd, abs_declarator->Tail());
   return new TypeName(decl_spec, decl);
}
//-----------------------------------------------------------------------------
int TypeName::Print(FILE * out) const
{
   assert(this);

int len = 0;
   if (decl_spec)   len += decl_spec->Print(out);

   for (Declarator * dl = abs_declarator; dl; dl = dl->Tail())
       {
         DeclItem * di = dl->Head();
         assert(di);
         len += fprintf(out, " ");
         len += di->Print(out);
      }

   return len;
}
//-----------------------------------------------------------------------------
const char * TypeName::GetDeclaredName()
{
const char * ret = 0;

   for (Declarator * d = abs_declarator; d; d = d->Tail())
       {
         DeclItem * di = d->Head();
         assert(di);
         const char * n = di->GetName();
         if (n == 0)      continue;
         assert (ret == 0);
         ret = n;
       }

   return ret;
}
//-----------------------------------------------------------------------------
const char * GetDeclaredName(Declarator * decl)
{
const char * ret = 0;
int count = 0;

   for (; decl; decl = decl->Tail())
       {
         DeclItem * di = decl->Head();
         assert(di);

         switch(di->GetWhat())
            {
              case DECL_NAME:    ret = di->GetName();
                                 assert(ret);
                                 count++;
                                 continue;

              case DECL_FUNPTR:  assert(!di->GetName());
                                 assert(di->GetFunptr());
                                 ret = GetDeclaredName(di->GetFunptr());
                                 assert(ret);
                                 count++;
                                 continue;

              case DECL_ARRAY:
              case DECL_FUN:
              case DECL_POINTER: assert(!di->GetName());
                                 continue;

              default:           assert("Bad What");

            }
       }

   assert(count <= 1);
   return ret;
}
//-----------------------------------------------------------------------------
int TypeName::GetPointeeSize() const
{
   assert(abs_declarator);
   assert(IsPointer() || IsArray());

   return ContentOf()->GetSize();
}
//-----------------------------------------------------------------------------
bool TypeName::IsPointer() const
{
   if (abs_declarator)   return ::IsPointer(abs_declarator);
   return false;
}
//-----------------------------------------------------------------------------
bool TypeName::IsArray() const
{
   if (abs_declarator)   return ::IsArray(abs_declarator);
   return false;
}
//-----------------------------------------------------------------------------
TypeName * TypeName::GetElementType() const
{
DeclItem * last = 0;

   assert(abs_declarator);
   for (Declarator * decl = abs_declarator; decl; decl = decl->Tail())
       {
         DeclItem * di = decl->Head();
         assert(di);

         if (di->GetWhat() == DECL_ARRAY)   last = di;
       }

   assert(last);

   // copy decl items except name and last...
   //
Declarator * ret = 0;
   for (Declarator * decl = abs_declarator; decl; decl = decl->Tail())
       {
         DeclItem * di = decl->Head();
         if (di == last)   continue;
         if (di->GetWhat() == DECL_NAME)   continue;

         ret = new Declarator(di, ret);
       }


   return new TypeName(decl_spec, ret);
}
//-----------------------------------------------------------------------------
void TypeName::SetArrayLength(int len)
{
   assert(abs_declarator);
   ::SetArrayLength(abs_declarator, len);
}
//-----------------------------------------------------------------------------
Expression * TypeName::ArrayLength() const
{
   if (abs_declarator)   return ::ArrayLength(abs_declarator);
   return 0;
}
//-----------------------------------------------------------------------------
bool TypeName::IsStruct() const
{
   assert(decl_spec);
   if (decl_spec->GetType() & TS_STRUCT)   return true;
   return false;
}
//-----------------------------------------------------------------------------
bool TypeName::IsUnion() const
{
   assert(decl_spec);
   if (decl_spec->GetType() & TS_UNION)   return true;
   return false;
}
//-----------------------------------------------------------------------------
bool IsPointer(Declarator * decl)
{
   assert(decl);

DeclItem * di = decl->Head();
   assert(di);

   if (di->GetWhat() == DECL_POINTER)   return true;
   return false;
}
//-----------------------------------------------------------------------------
bool IsArray(Declarator * decl)
{
   for (; decl; decl = decl->Tail())
       {
         DeclItem * di = decl->Head();
         assert(di);

         if (di->GetWhat() == DECL_ARRAY)   return true;
       }

   return false;
}
//-----------------------------------------------------------------------------
Expression * ArrayLength(Declarator * decl)
{
DeclItem * last = 0;

   for (; decl; decl = decl->Tail())
       {
         DeclItem * di = decl->Head();
         assert(di);

         if (di->GetWhat() == DECL_ARRAY)   last = di;
       }

   if (last)   return last->GetArraySize();
   return 0;
}
//-----------------------------------------------------------------------------
void SetArrayLength(Declarator * decl, int len)
{
DeclItem * last = 0;

   for (; decl; decl = decl->Tail())
       {
         DeclItem * di = decl->Head();
         assert(di);

         if (di->GetWhat() == DECL_ARRAY)   last = di;
       }

   assert(last);
   last->SetArraySize(len);
}
//-----------------------------------------------------------------------------
bool IsFunPtr(Declarator * decl)
{
   for (; decl; decl = decl->Tail())
       {
         DeclItem * di = decl->Head();
         assert(di);

         if (di->GetWhat() == DECL_FUNPTR)   return true;
       }

   return false;
}
//-----------------------------------------------------------------------------
bool IsFunction(Declarator * decl)
{
   for (; decl; decl = decl->Tail())
       {
         DeclItem * di = decl->Head();
         assert(di);

         if (di->GetWhat() == DECL_FUN)   return true;
       }

   return false;
}
//-----------------------------------------------------------------------------
ParameterDeclarationList * GetParameters(Declarator * decl)
{
   for (; decl; decl = decl->Tail())
       {
         DeclItem * di = decl->Head();
         assert(di);

         if (di->GetWhat() == DECL_FUN)      return di->GetParameters();
         if (di->GetWhat() == DECL_FUNPTR)   return di->GetParameters();
       }

   fprintf(stderr, "Can't get parameters of undeclared function\n");
   return 0;
}
//-----------------------------------------------------------------------------
TypeName * GetMemberType(StructDeclarationList * sdl, int pos)
{
   for (; sdl; sdl = sdl->Tail())
       {
         StructDeclaration * sd = sdl->Head();
         int count = sd->GetDeclaratorCount();
         if (pos < count)   return sd->GetMemberType(pos);

         pos -= count;
       }
}
//-----------------------------------------------------------------------------
