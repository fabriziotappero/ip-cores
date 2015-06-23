
%{

#include <stdio.h>
#include "Node.hh"
#include "Name.hh"

extern int yylex();
extern int yyparse();
extern int yyerror(const char *);
extern FILE * out;

%}

%token EOFILE ERROR
%token IDENTIFIER CONSTANT STRING_LITERAL SIZEOF ASM
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%expect 1

%start all

%union	{	NumericConstant			* _num;
		const char			*_name;
		StringConstant			*_string_constant;
		BinExprType			 _bin_expr_type;
		UnaExprType			 _una_expr_type;
		Specifier			 _specifier;
		Expression			*_expr;
		Pointer				*_pointer;
		IdentifierList			*_identifier_list;
		Initializer			*_initializer;
		InitializerList			*_initializer_list;
		ParameterDeclaration   		*_parameter_declaration;
		ParameterDeclarationList	*_parameter_declaration_list;
		Declarator			*_declarator;
		Enumerator			*_enumerator;
		EnumeratorList			*_enumerator_list;
		StructDeclarator		*_struct_declarator;
		StructDeclaratorList		*_struct_declarator_list;
		StructDeclaration		*_struct_declaration;
		StructDeclarationList		*_struct_declaration_list;
		TypeSpecifier			*_type_specifier;
		InitDeclarator			*_init_declarator;
		InitDeclaratorList		*_init_declarator_list;
		Declaration			*_declaration;
		DeclarationList			*_declaration_list;
		TypeName			*_type_name;
		Statement			*_statement;
		ExpressionStatement		*_expression_statement;
		CompoundStatement		*_compound_statement;
		StatementList			*_statement_list;
		FunctionDefinition		*_function_definition;
	}

%type	<_function_definition>		function_definition
					function_head
%type	<_statement_list>		statement_list
%type	<_statement>			statement
					labeled_statement
					selection_statement
					iteration_statement
					jump_statement
%type	<_expression_statement>		expression_statement
%type	<_compound_statement>		compound_statement
%type	<_type_name>			type_name
%type	<_declaration_list>		declaration_list
%type	<_declaration>			declaration
%type	<_init_declarator>		init_declarator
%type	<_init_declarator_list>		init_declarator_list
%type	<_type_specifier>		struct_or_union_specifier
					type_specifier
					enum_specifier
					declaration_specifiers
					type_qualifier_list
					specifier_qualifier_list
					type_qualifier
%type	<_struct_declaration_list>	struct_declaration_list
%type	<_struct_declaration>		struct_declaration
%type	<_struct_declarator_list>	struct_declarator_list
%type	<_struct_declarator>		struct_declarator
%type	<_enumerator>			enumerator
%type	<_enumerator_list>		enumerator_list
%type	<_declarator>			declarator
					direct_declarator
					abstract_declarator
					direct_abstract_declarator
%type	<_parameter_declaration>	parameter_declaration
%type	<_parameter_declaration_list>	parameter_list
%type	<_initializer>			initializer
%type	<_initializer_list>		initializer_list
%type	<_identifier_list>		identifier_list
%type	<_pointer>			pointer
%type	<_specifier>			struct_or_union
%type	<_una_expr_type>		unary_operator
%type	<_bin_expr_type>		assignment_operator
%type	<_name>				IDENTIFIER TYPE_NAME
%type	<_string_constant>		STRING_LITERAL
					string_sequence
%type	<_num>				CONSTANT
%type	<_expr>				expression
					primary_expression
					postfix_expression
					argument_expression_list
					unary_expression
					cast_expression
					multiplicative_expression
					additive_expression
					shift_expression
					relational_expression
					equality_expression
					and_expression
					exclusive_or_expression
					inclusive_or_expression
					logical_and_expression
					logical_or_expression
					conditional_expression
					assignment_expression
					constant_expression

%%

all	: translation_unit EOFILE
	{ StringConstant::EmitAll(out);  return 0; }
	;

primary_expression
        : IDENTIFIER		{ $$ = IdentifierExpression::New($1);	}
        | CONSTANT		{ $$ = new NumericExpression($1);	}
        | string_sequence	{ $$ = new StringExpression($1);	}
        | '(' expression ')'	{ $$ = $2;				}
	| ASM  '(' string_sequence ')'	{ $$ = new AsmExpression($3);	}
	;

string_sequence
	: STRING_LITERAL			{ $$ = $1;		}
	| string_sequence STRING_LITERAL	{ $$ = *$1 & $2;	}
	;

postfix_expression
        : primary_expression
		{ $$ = $1;						}
        | postfix_expression '[' expression ']'
		{ $$ = BinaryExpression::New(ET_ELEMENT, $1, $3);	}
        | postfix_expression '(' ')'
		{ $$ = BinaryExpression::New(ET_FUNCALL, $1, 0);	}
        | postfix_expression '(' argument_expression_list ')'
		{ $$ = BinaryExpression::New(ET_FUNCALL, $1, $3);	}
        | postfix_expression '.' IDENTIFIER
		{ $$ = new MemberExpression(false, $1, $3);		}
        | postfix_expression PTR_OP IDENTIFIER
		{ $$ = new MemberExpression(true, $1, $3);		}
        | postfix_expression INC_OP
		{ $$ = UnaryExpression::New(ET_POSTINC, $1);		}
        | postfix_expression DEC_OP
		{ $$ = UnaryExpression::New(ET_POSTDEC, $1);		}
        ;

argument_expression_list
        : assignment_expression
		{ $$ = $1;						}
        | argument_expression_list ',' assignment_expression
		{ $$ = new ArgListExpression($1, $3);			}
        ;

unary_expression
        : postfix_expression
		{ $$ = $1;						}
        | INC_OP unary_expression
		{ $$ = UnaryExpression::New(ET_PREINC, $2);		}
        | DEC_OP unary_expression
		{ $$ = UnaryExpression::New(ET_PREDEC, $2);		}
        | unary_operator cast_expression
		{ $$ = UnaryExpression::New($1, $2);			}
        | SIZEOF unary_expression
		{ $$ = new NumericExpression($2);			}
        | SIZEOF '(' type_name ')'
		{ $$ = new NumericExpression($3);			}
        ;

unary_operator
        : '&'					{ $$ = ET_ADDRESS;	}
        | '*'					{ $$ = ET_CONTENT;	}
        | '+'					{ $$ = ET_CONJUGATE;	}
        | '-'					{ $$ = ET_NEGATE;	}
        | '~'					{ $$ = ET_COMPLEMENT;	}
        | '!'					{ $$ = ET_LOG_NOT;	}
        ;

cast_expression
        : unary_expression
		{ $$ = $1;						}
        | '(' type_name ')' cast_expression
		{ $$ = new UnaryExpression($2, $4);			}
        ;

multiplicative_expression
        : cast_expression
		{ $$ = $1;						}
        | multiplicative_expression '*' cast_expression
		{ $$ = BinaryExpression::New(ET_MULT, $1, $3);		}
        | multiplicative_expression '/' cast_expression
		{ $$ = BinaryExpression::New(ET_DIV, $1, $3);		}
        | multiplicative_expression '%' cast_expression
		{ $$ = BinaryExpression::New(ET_MOD, $1, $3);		}
        ;

additive_expression
        : multiplicative_expression
		{ $$ = $1;						}
        | additive_expression '+' multiplicative_expression
		{ $$ = AdditionExpression::New($1, $3);			}
        | additive_expression '-' multiplicative_expression
		{ $$ = SubtractionExpression::New($1, $3);		}
        ;

shift_expression
        : additive_expression
		{ $$ = $1;						}
        | shift_expression LEFT_OP additive_expression
		{ $$ = BinaryExpression::New(ET_LEFT, $1, $3);		}
        | shift_expression RIGHT_OP additive_expression
		{ $$ = BinaryExpression::New(ET_RIGHT, $1, $3);		}
        ;

relational_expression
        : shift_expression
		{ $$ = $1;						}
        | relational_expression '<' shift_expression
		{ $$ = BinaryExpression::New(ET_LESS, $1, $3);		}
        | relational_expression '>' shift_expression
		{ $$ = BinaryExpression::New(ET_GREATER, $1, $3);	}
        | relational_expression LE_OP shift_expression
		{ $$ = BinaryExpression::New(ET_LESS_EQUAL, $1, $3);	}
        | relational_expression GE_OP shift_expression
		{ $$ = BinaryExpression::New(ET_GREATER_EQUAL, $1, $3);	}
        ;

equality_expression
        : relational_expression
		{ $$ = $1;						}
        | equality_expression EQ_OP relational_expression
		{ $$ = BinaryExpression::New(ET_EQUAL, $1, $3);		}
        | equality_expression NE_OP relational_expression
		{ $$ = BinaryExpression::New(ET_NOT_EQUAL, $1, $3);	}
        ;

and_expression
        : equality_expression
		{ $$ = $1;						}
        | and_expression '&' equality_expression
		{ $$ = BinaryExpression::New(ET_BIT_AND, $1, $3);	}
        ;

exclusive_or_expression
        : and_expression
		{ $$ = $1;						}
        | exclusive_or_expression '^' and_expression
		{ $$ = BinaryExpression::New(ET_BIT_XOR, $1, $3);	}
        ;

inclusive_or_expression
        : exclusive_or_expression
		{ $$ = $1;						}
        | inclusive_or_expression '|' exclusive_or_expression
		{ $$ = BinaryExpression::New(ET_BIT_OR, $1, $3);	}
        ;

logical_and_expression
        : inclusive_or_expression
		{ $$ = $1;						}
        | logical_and_expression AND_OP inclusive_or_expression
		{ $$ = BinaryExpression::New(ET_LOG_AND, $1, $3);	}
        ;

logical_or_expression
        : logical_and_expression
		{ $$ = $1;						}
        | logical_or_expression OR_OP logical_and_expression
		{ $$ = BinaryExpression::New(ET_LOG_OR, $1, $3);	}
        ;

conditional_expression
        : logical_or_expression
		{ $$ = $1;						}
        | logical_or_expression '?' expression ':' conditional_expression
		{ $$ = new CondExpression($1, $3, $5);			}
        ;

assignment_expression
        : conditional_expression
		{ $$ = $1;						}
        | unary_expression assignment_operator assignment_expression
		{ $$ = BinaryExpression::New($2, $1, $3);		}
        ;

assignment_operator
        : '='					{ $$ = ET_ASSIGN;	}
        | MUL_ASSIGN				{ $$ = ET_MULT_ASSIGN;	}
        | DIV_ASSIGN				{ $$ = ET_DIV_ASSIGN;	}
        | MOD_ASSIGN				{ $$ = ET_MOD_ASSIGN;	}
        | ADD_ASSIGN				{ $$ = ET_ADD_ASSIGN;	}
        | SUB_ASSIGN				{ $$ = ET_SUB_ASSIGN;	}
        | LEFT_ASSIGN				{ $$ = ET_LEFT_ASSIGN;	}
        | RIGHT_ASSIGN				{ $$ = ET_RIGHT_ASSIGN;	}
        | AND_ASSIGN				{ $$ = ET_AND_ASSIGN;	}
        | XOR_ASSIGN				{ $$ = ET_XOR_ASSIGN;	}
        | OR_ASSIGN				{ $$ = ET_OR_ASSIGN;	}
        ;

expression
        : assignment_expression
		{ $$ = $1;						}
        | expression ',' assignment_expression
		{ $$ = BinaryExpression::New(ET_LIST, $1, $3);		}
        ;

constant_expression
        : conditional_expression
		{ $$ = $1;						}
        ;

declaration
        : declaration_specifiers ';'
		{ $$ = new Declaration($1,  0);				}
        | declaration_specifiers init_declarator_list ';'
		{ $$ = new Declaration($1, $2);				}
        ;

declaration_specifiers
        : type_specifier			{ $$ = $1;		}
        | type_qualifier			{ $$ = $1;		}
        | type_specifier declaration_specifiers	{ $$ = *$2 + *$1;	}
        | type_qualifier declaration_specifiers	{ $$ = *$2 + *$1;	}
        ;

init_declarator_list
        : init_declarator
		{ $$ = new InitDeclaratorList($1,  0);			}
        | init_declarator ',' init_declarator_list
		{ $$ = new InitDeclaratorList($1, $3);			}
        ;

init_declarator
        : declarator
		{ $$ = new InitDeclarator($1,  0);			}
        | declarator '=' initializer
		{ $$ = new InitDeclarator($1, $3);			}
        ;

type_specifier
	// storage class
        : TYPEDEF		{ $$ = new TypeSpecifier(SC_TYPEDEF);	}
        | EXTERN		{ $$ = new TypeSpecifier(SC_EXTERN);	}
        | STATIC		{ $$ = new TypeSpecifier(SC_STATIC);	}
        | AUTO			{ $$ = new TypeSpecifier(SC_AUTO);	}
        | REGISTER		{ $$ = new TypeSpecifier(SC_REGISTER);	}
	// type
        | VOID			{ $$ = new TypeSpecifier(TS_VOID);	}
        | CHAR			{ $$ = new TypeSpecifier(TS_CHAR);	}
        | SHORT			{ $$ = new TypeSpecifier(TS_SHORT);	}
        | INT			{ $$ = new TypeSpecifier(TS_INT);	}
        | LONG			{ $$ = new TypeSpecifier(TS_LONG);	}
        | FLOAT			{ $$ = new TypeSpecifier(TS_FLOAT);	}
        | DOUBLE		{ $$ = new TypeSpecifier(TS_DOUBLE);	}
        | SIGNED		{ $$ = new TypeSpecifier(TS_SIGNED);	}
        | UNSIGNED		{ $$ = new TypeSpecifier(TS_UNSIGNED);	}
        | struct_or_union_specifier	{ $$ = $1;			}
        | enum_specifier		{ $$ = $1;			}
        | TYPE_NAME	{ $$ = new TypeSpecifier(TS_TYPE_NAME, $1, 0);	}
        ;

struct_or_union_specifier
        : struct_or_union IDENTIFIER '{' struct_declaration_list '}'
		{ $$ = new TypeSpecifier($1, $2, $4);			}
        | struct_or_union '{' struct_declaration_list '}'
		{ $$ = new TypeSpecifier($1,  0, $3);			}
        | struct_or_union IDENTIFIER
		{ $$ = new TypeSpecifier($1, $2,  0);			}
        ;

struct_or_union
        : STRUCT				{ $$ = TS_STRUCT;	}
        | UNION					{ $$ = TS_UNION;	}
        ;

struct_declaration_list
        : struct_declaration
		{ $$ = new StructDeclarationList($1,  0);		}
        | struct_declaration struct_declaration_list
		{ $$ = new StructDeclarationList($1, $2);		}
        ;

struct_declaration
        : specifier_qualifier_list struct_declarator_list ';'
		{ $$ = new StructDeclaration($1, $2);			}
        ;

specifier_qualifier_list
        : type_specifier				{ $$ = $1;	}
        | type_qualifier				{ $$ = $1;	}
        | type_specifier specifier_qualifier_list	{ $$=*$1 + *$2;	}
        | type_qualifier specifier_qualifier_list	{ $$=*$1 + *$2;	}
        ;

struct_declarator_list
        : struct_declarator
		{ $$ = new StructDeclaratorList($1,  0);		}
        | struct_declarator ',' struct_declarator_list
		{ $$ = new StructDeclaratorList($1, $3);		}
        ;

struct_declarator
        : declarator
		{ $$ = new StructDeclarator($1,  0);			}
        | ':' constant_expression
		{ $$ = new StructDeclarator( 0, $2);			}
        | declarator ':' constant_expression
		{ $$ = new StructDeclarator($1, $3);			}
        ;

enum_specifier
        : ENUM '{' enumerator_list '}'
		{ $$ = new TypeSpecifier( 0, $3);			}
        | ENUM IDENTIFIER '{' enumerator_list '}'
		{ $$ = new TypeSpecifier($2, $4);			}
        | ENUM IDENTIFIER
		{ $$ = new TypeSpecifier(TS_ENUM);			}
        ;

enumerator_list
        : enumerator
				{ $$ = new EnumeratorList($1, 0);	}
        | enumerator ',' enumerator_list
				{ $$ = new EnumeratorList($1, $3);	}
        ;

enumerator
        : IDENTIFIER		{ $$ = new Enumerator($1, 0);		}
        | IDENTIFIER '=' constant_expression
				{ $$ = new Enumerator($1, $3);		}
        ;

type_qualifier
        : CONST			{ $$ = new TypeSpecifier(TQ_CONST);	}
        | VOLATILE		{ $$ = new TypeSpecifier(TQ_VOLATILE);	}
        ;

declarator
        : pointer direct_declarator
		{ $$ = new Declarator(new DeclItem($1), $2->Reverse());	}
        | direct_declarator
		{  $$ = $1->Reverse();					}
        ;

direct_declarator
        : IDENTIFIER
		{ $$ = new Declarator(new DeclItem($1), 0);		}
        | '(' declarator ')'
		{ $$ = new Declarator(new DeclItem($2), 0);		}
        | direct_declarator '[' constant_expression ']'
		{ $$ = new Declarator(new DeclItem($3), $1);		}
        | direct_declarator '[' ']'
		{ $$ = new Declarator(new DeclItem(DECL_ARRAY), $1);	}
        | direct_declarator '(' parameter_list ')'
		{ $$ = new Declarator(new DeclItem($3), $1);		}
        | direct_declarator '(' identifier_list ')'
		{ $$ = new Declarator(new DeclItem($3), $1);		}
        | direct_declarator '(' ')'
		{ $$ = new Declarator(new DeclItem(DECL_FUN), $1);	}
        ;

pointer
        : '*'
		{ $$ = new Pointer(new Ptr(0), 0);			}
        | '*' type_qualifier_list
		{ $$ = new Pointer(new Ptr($2), 0);			}
        | '*' pointer
		{ $$ = new Pointer(new Ptr(0), $2);			}
        | '*' type_qualifier_list pointer
		{ $$ = new Pointer(new Ptr($2), $3);			}
        ;

type_qualifier_list
        : type_qualifier			 { $$ = $1		}
        | type_qualifier type_qualifier_list	 { $$ = *$1 + *$2;	}
        ;

parameter_list
        : parameter_declaration
		{ $$ = new ParameterDeclarationList($1, 0);		}
        | ELLIPSIS
		{ $$ = new ParameterDeclarationList( 0, 0);		}
        | parameter_declaration ',' parameter_list
	  {
	    if ($3->Head())   $$ = new ParameterDeclarationList($1, $3);
	    else              $$ = $3->SetHead($1->SetEllipsis());
	  }
        ;

parameter_declaration
        : declaration_specifiers declarator
		{ $$ = new ParameterDeclaration($1, $2);		}
        | declaration_specifiers abstract_declarator
		{ $$ = new ParameterDeclaration($1, $2);		}
        | declaration_specifiers
		{ $$ = new ParameterDeclaration($1,  0);		}
        ;

identifier_list
        : IDENTIFIER
		{ $$ = new IdentifierList(new Identifier($1),  0);	}
        | IDENTIFIER ',' identifier_list
		{ $$ = new IdentifierList(new Identifier($1), $3);	}
        ;

type_name
        : specifier_qualifier_list
		{ assert($1);   $$ = new TypeName($1, 0);		}
        | specifier_qualifier_list abstract_declarator
		{ assert($1);   $$ = new TypeName($1, $2);		}
        ;

abstract_declarator
        : pointer
		{ $$ = new Declarator(new DeclItem($1), 0);		}
        | direct_abstract_declarator
		{ $$ = $1->Reverse();					}
        | pointer direct_abstract_declarator
		{ $$ = new Declarator(new DeclItem($1), $2->Reverse());	}
        ;

direct_abstract_declarator
        : '(' abstract_declarator ')'
	 { $$ = new Declarator(new DeclItem($2), 0);		}
        | '[' ']'
	 { $$ = new Declarator(new DeclItem(DECL_ARRAY), 0);	}
        | '[' constant_expression ']'
	 { $$ = new Declarator(new DeclItem($2), 0);		}
        | '(' ')'
	 { $$ = new Declarator(new DeclItem(DECL_FUN), 0);	}
        | '(' parameter_list ')'
	 { $$ = new Declarator(new DeclItem($2), 0);		}
        | direct_abstract_declarator '[' ']'
	 { $$ = new Declarator(new DeclItem(DECL_ARRAY), $1);	}
        | direct_abstract_declarator '[' constant_expression ']'
	 { $$ = new Declarator(new DeclItem($3), $1);		}
        | direct_abstract_declarator '(' ')'
	 { $$ = new Declarator(new DeclItem(DECL_FUN), $1);	}
        | direct_abstract_declarator '(' parameter_list ')'
	 { $$ = new Declarator(new DeclItem($3), $1);		}
        ;

initializer
        : assignment_expression	
		{ $$ = new Initializer($1);			}
        | '{' initializer_list '}'
		{ $$ = new Initializer($2->Reverse());		}
        | '{' initializer_list ',' '}'
		{ $$ = new Initializer($2->Reverse());		}
        ;

initializer_list
        : initializer
		{ $$ = new InitializerList($1, 0);			}
        | initializer_list ',' initializer
		{ $$ = new InitializerList($3, $1);			}
        ;

statement
        : labeled_statement				{ $$ = $1;	}
        | compound_statement				{ $$ = $1;	}
        | expression_statement				{ $$ = $1;	}
        | selection_statement				{ $$ = $1;	}
        | iteration_statement				{ $$ = $1;	}
        | jump_statement				{ $$ = $1;	}
        ;

labeled_statement
        : IDENTIFIER ':' statement
		{ $$ = new LabelStatement($1, $3);			}
        | CASE constant_expression ':' statement
		{ $$ = new CaseStatement($2, $4);			}
        | DEFAULT ':' statement
		{ $$ = new CaseStatement(0, $3);			}
        ;

compound_statement
        : '{' '}'
		{ $$ = new CompoundStatement( 0,  0);			}
        | '{' statement_list '}'
		{ $$ = new CompoundStatement( 0, $2);			}
        | '{' declaration_list '}'
		{ $$ = new CompoundStatement($2,  0);			}
        | '{' declaration_list statement_list '}'
		{ $$ = new CompoundStatement($2, $3);			}
        ;

declaration_list
        : declaration
		{ $$ = new DeclarationList($1,  0);			}
        | declaration declaration_list
		{ $$ = new DeclarationList($1, $2);			}
        ;

statement_list
        : statement
		{ $$ = new StatementList($1,  0);			}
        | statement statement_list
		{ $$ = new StatementList($1, $2);			}
        ;

expression_statement
        : ';'			{ $$ = new ExpressionStatement(0);	}
        | expression ';'	{ $$ = new ExpressionStatement($1);	}
        | error ';'		{ $$ = new ExpressionStatement(0);
				  Node::Error();			}
        ;

selection_statement
        : IF '(' expression ')' statement
		{ $$ = new IfElseStatement($3, $5,  0);			}
        | IF '(' expression ')' statement ELSE statement
		{ $$ = new IfElseStatement($3, $5, $7);			}
        | SWITCH '(' expression ')' compound_statement
		{ $$ = new SwitchStatement($3, $5);			}
        ;

iteration_statement
        : WHILE '(' expression ')' statement
		{ $$ = new WhileStatement($3, $5);			}
        | DO statement WHILE '(' expression ')' ';'
		{ $$ = new DoWhileStatement($2, $5);			}
        | FOR '(' expression_statement expression_statement ')' statement
		{ $$ = new ForStatement($3, $4,  0, $6);		}
        | FOR '(' expression_statement expression_statement
		  expression ')' statement
		{ $$ = new ForStatement($3, $4, $5, $7);		}
        ;

jump_statement
        : GOTO IDENTIFIER ';'	{ $$ = new GotoStatement($2);		}
        | CONTINUE ';'		{ $$ = new ContStatement(false);	}
        | BREAK ';'		{ $$ = new ContStatement(true);	}
        | RETURN ';'		{ $$ = new ReturnStatement(0);		}
        | RETURN expression ';'	{ $$ = new ReturnStatement($2);		}
        ;

translation_unit
        : external_declaration					{	}
        | external_declaration translation_unit			{	}
        ;

external_declaration
        : function_definition
	  { $1->Emit(out);
	    fprintf(out,
	    ";;; ------------------------------------;\n");		}
        | declaration
	  { if ($1)   $1->Emit(out);
	    fprintf(out,
	    ";;; ------------------------------------;\n");		}
        | error
	  { Node::Error();
	    fprintf(out,
	    ";;; SYNTAX ERROR\n"
	    ";;; ------------------------------------;\n");		}
        ;

function_head
        : declaration_specifiers declarator declaration_list
		{ $$ = new FunctionDefinition($1, $2, $3);		}
        | declaration_specifiers declarator
		{ $$ = new FunctionDefinition($1, $2,  0);		}
        | declarator declaration_list
		{ $$ = new FunctionDefinition( 0, $1, $2);		}
        | declarator
		{ $$ = new FunctionDefinition( 0, $1,  0);		}
        ;

function_definition
        : function_head compound_statement
		{ $$ = $1->SetBody($2);					}
        ;
%%
