// Name.cc

#include <stdio.h>
#include "Name.hh"
#include "Node.hh"

Name * Name::externs  = 0;
Name * Name::statics  = 0;
Name * Name::enums    = 0;
Name * Name::locals   = 0;
Name * Name::autos    = 0;

TypedefName * TypedefName::typedefs = 0;
StructName  * StructName::structs = 0;

const bool DEBUG = false;

//-----------------------------------------------------------------------------
TypeName * TypedefName::Find(const char * na)
{
   for (TypedefName * n = typedefs; n; n = n->tail)
       {
          if (!strcmp(na, n->name))   return n->decl;
       }
   return 0;
}
//-----------------------------------------------------------------------------
bool TypedefName::IsDefined(const char * na)
{
   for (TypedefName * n = typedefs; n; n = n->tail)
       {
          if (!strcmp(na, n->name))   return true;
       }
   return false;
}
//-----------------------------------------------------------------------------
void TypedefName::Add(const char * na, TypeName * decl)
{
   if (DEBUG)   fprintf(stderr, "Adding \"%s\" to typedefs\n", na);
   typedefs = new TypedefName(na, typedefs, decl);
}
//=============================================================================
StructDeclarationList * StructName::Find(const char * na)
{
   for (StructName * n = structs; n; n = n->tail)
       {
          if (!strcmp(na, n->name))   return n->sdlist;
       }
   return 0;
}
//-----------------------------------------------------------------------------
bool StructName::IsDefined(const char * na)
{
   for (StructName * n = structs; n; n = n->tail)
       {
          if (!strcmp(na, n->name))   return true;
       }
   return false;
}
//-----------------------------------------------------------------------------
void StructName::Add(const char * na, StructDeclarationList * sdl)
{
   if (DEBUG)   fprintf(stderr, "Adding \"%s\" to structs\n", na);
   structs = new StructName(na, structs, sdl);
}
//=============================================================================
void Name::PushContext()
{
   // use "}" as a marker for contexts
   autos = new Name("}", autos, 0, 0);
}
//-----------------------------------------------------------------------------
void Name::PopContext()
{
   while (autos)
       {
          Name * tl = autos->tail;
          const bool marker = !strcmp("}", autos->name);
          delete autos;
	  autos = tl;
          if (marker)   return;
       }

   assert(0 && "No context marker");
}
//-----------------------------------------------------------------------------
void Name::RemoveAuto()
{
   while (autos)
       {
          Name * tl = autos->tail;
          delete autos;
	  autos = tl;
       }
}
//-----------------------------------------------------------------------------
void Name::AutoToLocal()
{
   while (autos)
      {
        Name * n = autos;
        autos = autos->tail;
	AutoToLocal();
	n->tail = locals;
	locals = n;
      }
}
//-----------------------------------------------------------------------------
TypeName * Name::FindType(const char * na)
{
Name * np = FindDeclared(na);

   if (np == 0)   return 0;

   return np->decl;
}
//-----------------------------------------------------------------------------
int Name::FindPos(const char * na)
{
Name * np = FindDeclared(na);

   if (np == 0)   return 1;   // +1 indicates error !

   return np->stack_position;
}
//-----------------------------------------------------------------------------
bool Name::FindEnum(const char * na, int & value)
{
   for (Name * n = enums; n; n = n->tail)
       {
          if (strcmp(na, n->name))   continue;
          value = n->stack_position;
          return true;
       }

   return false;
}
//-----------------------------------------------------------------------------
Name * Name::FindDeclared(const char * na)
{
   for (Name * n = autos; n; n = n->tail)
       {
          if (!strcmp(na, n->name))   return n;
       }

   for (Name * n = locals; n; n = n->tail)
       {
          if (!strcmp(na, n->name))   return n;
       }

   for (Name * n = statics; n; n = n->tail)
       {
          if (!strcmp(na, n->name))   return n;
       }

   for (Name * n = externs; n; n = n->tail)
       {
          if (!strcmp(na, n->name))   return n;
       }

   return 0;
}
//-----------------------------------------------------------------------------
void Name::Print(FILE * out)
{
   fprintf(out, "'%s' %d\n", name, stack_position);
}
//-----------------------------------------------------------------------------
void Name::PrintAll(FILE * out)
{
   fprintf(out, "Auto:\n");
   for (Name * n = autos; n; n = n->tail)     n->Print(out);

   fprintf(out, "Local:\n");
   for (Name * n = locals; n; n = n->tail)    n->Print(out);

   fprintf(out, "Static:\n");
   for (Name * n = statics; n; n = n->tail)   n->Print(out);

   fprintf(out, "Extern:\n");
   for (Name * n = externs; n; n = n->tail)   n->Print(out);
}
//-----------------------------------------------------------------------------
void Name::AddExtern(const char * na, TypeName * decl)
{
   if (DEBUG)   fprintf(stderr, "Adding \"%s\" to externs\n", na);
   externs = new Name(na, externs, decl, 0);
}
//-----------------------------------------------------------------------------
void Name::AddStatic(const char * na, TypeName * decl)
{
   if (DEBUG)   fprintf(stderr, "Adding \"%s\" to statics\n", na);
   statics = new Name(na, statics, decl, 0);
}
//-----------------------------------------------------------------------------
void Name::AddLocal(const char * na, TypeName * decl)
{
   if (DEBUG)   fprintf(stderr, "Adding \"%s\" to locals\n", na);
   locals = new Name(na, locals, decl, 0);
}
//-----------------------------------------------------------------------------
void Name::AddEnum(const char * na, int spos)
{
   if (DEBUG)   fprintf(stderr, "Adding \"%s\" to enums\n", na);
   enums = new Name(na, enums, 0, spos);
}
//-----------------------------------------------------------------------------
void Name::AddAuto(const char * na, TypeName * decl, int spos)
{
   if (DEBUG)   fprintf(stderr, "Adding \"%s\" to autos\n", na);
   autos = new Name(na, autos, decl, spos);
}
//-----------------------------------------------------------------------------
void Name::SetAutoPos(const char * na, int spos)
{
   for (Name * n = autos; n; n = n->tail)
       {
          if (!strcmp(na, n->name))
             {

               if (DEBUG)   fprintf(stderr,
			            "Setting Stack Position of \"%s\" to %d\n",
				    na, spos);
               assert(n->stack_position == 0);
               assert(spos != 0);
               assert(spos != 1);
               n->stack_position = spos;
               return;
             }
       }
   assert(0);
}
//-----------------------------------------------------------------------------
