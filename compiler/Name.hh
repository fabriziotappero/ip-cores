// Name.hh

#include "List.hh"
class TypeName;
class Name;

//-----------------------------------------------------------------------------
class Name
{
public:
   Name(const char * n, Name * t, TypeName * d, int spos)
   : name(n),
     tail(t),
     decl(d),
     stack_position(spos)
     {}

   static TypeName  * FindType(const char * na);
   static int         FindPos(const char * na);
   static bool        FindEnum(const char * na, int & value);
   static void        AddExtern(const char * na, TypeName * decl);
   static void        AddStatic(const char * na, TypeName * decl);
   static void        AddEnum(const char * na, int value);
   static void        AddLocal(const char * na, TypeName * decl);
   static void        AddAuto(const char * na, TypeName * decl, int spos = 0);
   static void        SetAutoPos(const char * na, int spos);
   static void        AutoToLocal();
   static void        PrintAll(FILE * out);

   static void        RemoveAuto();
   static bool        ContextIsEmpty()   { return (autos == 0); };
   static void        PushContext();
   static void        PopContext();

   void               Print(FILE * out);

private:
   const char * name;
   Name       * tail;
   TypeName   * decl;
   int          stack_position;

   static Name * FindDeclared(const char * na);

   static Name * externs;
   static Name * statics;
   static Name * locals;
   static Name * enums;
   static Name * autos;
};
//-----------------------------------------------------------------------------
class TypedefName
{
public:
   TypedefName(const char * n, TypedefName * t, TypeName * d)
   : name(n),
     tail(t),
     decl(d)
     {}

   static bool       IsDefined(const char * na);
   static TypeName * Find(const char * na);
   static void       Add(const char * na, TypeName * decl);

private:
   const char  * name;
   TypedefName * tail;
   TypeName    * decl;

   static TypedefName * typedefs;
};
//-----------------------------------------------------------------------------
class StructName
{
public:
   StructName(const char * n, StructName * t, StructDeclarationList * sdl)
   : name(n),
     tail(t),
     sdlist(sdl)
     {}

   static bool IsDefined(const char * na);
   static StructDeclarationList * Find(const char * na);
   static void Add(const char * na, StructDeclarationList * sdl);

private:
   const char            * name;
   StructName            * tail;
   StructDeclarationList * sdlist;

   static StructName * structs;
};
//-----------------------------------------------------------------------------
