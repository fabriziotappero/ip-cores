// List.hh
#ifndef __LIST_HH_DEFINED__
#define __LIST_HH_DEFINED__

#include <string.h>

//-----------------------------------------------------------------------------
class Node
{
public:
   Node(const char * ntype);

   virtual void Emit(FILE * out);
   void EmitStart(FILE * out);
   void EmitEnd(FILE * out);

   static void EmitIndent(FILE * out);
   static int GetSemanticErrors()     { return semantic_errors; };
   static void Error()                { ++semantic_errors;      };
   const char * GetNodeType() const   { return node_type;       };

protected:
   const char * node_type;

   static int indent;
   static int semantic_errors;
};
//-----------------------------------------------------------------------------
template <class C>
class List : public Node
{
public:
   List(C * h, List<C> * t)
   : Node(list_name(h, t)),
     head(h), tail(t) {};

   virtual void Emit(FILE * out);

   C * Head()         { return head; };
   List<C> * Tail()   { return tail; };
   void ForceEnd()    { tail = 0;    };

   List<C> * Reverse()
      {
        List<C> * ret = 0;
	for (List<C> * l = this; l; l = l->tail)
	    {
	       ret = new List<C>(l->head, ret);
	    }
        return ret;
      };

   static int Length(const List<C> * l)
      {
        int ret = 0;
	for (; l; l = l->tail)   ret++;
        return ret;
      };

   void EmitList(FILE * out)
      {
        EmitStart(out);
	for (List<C> * l = this; l; l = l->tail)
            if (l->Head())   l->Head()->Emit(out);
        EmitEnd(out);
      };

   List<C> * SetHead(C * hd)
      {
        assert(head == 0);
        head = hd;
        return this;
      };

   static const char * list_name(C * h, List<C> * t)
      {
        if (h == 0)
           {
	     for (; t; t = t->tail)   if (h = t->head)   break;
           }

        if (h == 0)   return "List";
        char * cp = new char[strlen(h->GetNodeType()) + 10];
        sprintf(cp, "List<%s>", h->GetNodeType());
        return cp;
      };

private:
   C       * head;
   List<C> * tail;
};
//-----------------------------------------------------------------------------

class DeclItem;               typedef List<DeclItem>    Declarator;
class Initializer;            typedef List<Initializer> InitializerList;
class Enumerator;             typedef List<Enumerator> EnumeratorList;
class InitDeclarator;         typedef List<InitDeclarator> InitDeclaratorList;
class Ptr;                    typedef List<Ptr> Pointer;
class Identifier;             typedef List<Identifier> IdentifierList;
class Declaration;            typedef List<Declaration> DeclarationList;
class Statement;              typedef List<Statement> StatementList;
class TypeSpecifier;          typedef List<TypeSpecifier> TypeSpecifierList;
class ParameterDeclaration;   typedef List<ParameterDeclaration>
                                          ParameterDeclarationList;
class StructDeclarator;       typedef List<StructDeclarator>
                                           StructDeclaratorList;
class StructDeclaration;      typedef List<StructDeclaration>
                                           StructDeclarationList;
#endif
