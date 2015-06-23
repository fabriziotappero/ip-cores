
D                       [0-9]
L                       [a-zA-Z_]
NQ			[\x20-\x21\x23-\x5B\x5D-\x7E]
H                       [a-fA-F0-9]
E                       [Ee][+-]?{D}+
FS                      (f|F|l|L)
IS                      (u|U|l|L)*

%x com
%x strg

%{
#include <stdio.h>
#include "Node.hh"
#include "Name.hh"
#include "ansic_bison.hh"

extern FILE * out;

void count();
int check_type();
int StringConstant::str_count = 0;
StringConstant * StringConstant::
                 all_strings[StringConstant::MAX_STRINGS] = { 0 };

%}

%%
"//".*                  { count(); }
"/*"                    { count(); BEGIN(com); }
<com>"*/"		{ count(); BEGIN(0);   }
<com>\r			{ count();    }
<com>\n			{ count();    }
<com>.			{ count();    }

"ASM"                   { count(); return(ASM); }
"auto"                  { count(); return(AUTO); }
"break"                 { count(); return(BREAK); }
"case"                  { count(); return(CASE); }
"char"                  { count(); return(CHAR); }
"const"                 { count(); return(CONST); }
"continue"              { count(); return(CONTINUE); }
"default"               { count(); return(DEFAULT); }
"do"                    { count(); return(DO); }
"double"                { count(); return(DOUBLE); }
"else"                  { count(); return(ELSE); }
"enum"                  { count(); return(ENUM); }
"extern"                { count(); return(EXTERN); }
"float"                 { count(); return(FLOAT); }
"for"                   { count(); return(FOR); }
"goto"                  { count(); return(GOTO); }
"if"                    { count(); return(IF); }
"int"                   { count(); return(INT); }
"long"                  { count(); return(LONG); }
"register"              { count(); return(REGISTER); }
"return"                { count(); return(RETURN); }
"short"                 { count(); return(SHORT); }
"signed"                { count(); return(SIGNED); }
"sizeof"                { count(); return(SIZEOF); }
"static"                { count(); return(STATIC); }
"struct"                { count(); return(STRUCT); }
"switch"                { count(); return(SWITCH); }
"typedef"               { count(); return(TYPEDEF); }
"union"                 { count(); return(UNION); }
"unsigned"              { count(); return(UNSIGNED); }
"void"                  { count(); return(VOID); }
"volatile"              { count(); return(VOLATILE); }
"while"                 { count(); return(WHILE); }

{L}({L}|{D})*           { count(); yylval._name = new char[strlen(yytext)+1];
                          strcpy((char *)(yylval._name), yytext);
                                   return(check_type()); }

0[xX]{H}+{IS}?          { count(); yylval._num = new NumericConstant(yytext);
                                   return(CONSTANT); }
0{D}+{IS}?              { count(); yylval._num = new NumericConstant(yytext);
                                   return(CONSTANT); }
{D}+{IS}?               { count(); yylval._num = new NumericConstant(yytext);
                                   return(CONSTANT); }
L?'(\\.|[^\\'])+'       { count(); yylval._num = new NumericConstant(yytext);
                                   return(CONSTANT); }
{D}+{E}{FS}?            { count(); yylval._num = 0;   /* TODO */
                                   return(CONSTANT); }
{D}*"."{D}+({E})?{FS}?  { count(); yylval._num = 0;   /* TODO */
                                   return(CONSTANT); }
{D}+"."{D}*({E})?{FS}?  { count(); yylval._num = 0;   /* TODO */
                                   return(CONSTANT); }

L?\"                    { count();   BEGIN(strg);
                          yylval._string_constant = new StringConstant(); }
<strg>\"                { count();   BEGIN(0);   return(STRING_LITERAL);  }
<strg>\\\"              { count();   *yylval._string_constant += '"';     }
<strg>\\a               { count();   *yylval._string_constant += '\a';    }
<strg>\\b               { count();   *yylval._string_constant += '\b';    }
<strg>\\f               { count();   *yylval._string_constant += '\f';    }
<strg>\\n               { count();   *yylval._string_constant += '\n';    }
<strg>\\r               { count();   *yylval._string_constant += '\r';    }
<strg>\\t               { count();   *yylval._string_constant += '\t';    }
<strg>{NQ}              { count();   *yylval._string_constant += *yytext; }
<strg>\t                { count();   *yylval._string_constant += '\t';    }
<strg>\r                { count();                                        }
<strg>\n                { count();   *yylval._string_constant += '\n';    }
<strg>.                 { count();   *yylval._string_constant += *yytext; }

"..."                   { count(); return(ELLIPSIS); }
">>="                   { count(); return(RIGHT_ASSIGN); }
"<<="                   { count(); return(LEFT_ASSIGN); }
"+="                    { count(); return(ADD_ASSIGN); }
"-="                    { count(); return(SUB_ASSIGN); }
"*="                    { count(); return(MUL_ASSIGN); }
"/="                    { count(); return(DIV_ASSIGN); }
"%="                    { count(); return(MOD_ASSIGN); }
"&="                    { count(); return(AND_ASSIGN); }
"^="                    { count(); return(XOR_ASSIGN); }
"|="                    { count(); return(OR_ASSIGN); }
">>"                    { count(); return(RIGHT_OP); }
"<<"                    { count(); return(LEFT_OP); }
"++"                    { count(); return(INC_OP); }
"--"                    { count(); return(DEC_OP); }
"->"                    { count(); return(PTR_OP); }
"&&"                    { count(); return(AND_OP); }
"||"                    { count(); return(OR_OP); }
"<="                    { count(); return(LE_OP); }
">="                    { count(); return(GE_OP); }
"=="                    { count(); return(EQ_OP); }
"!="                    { count(); return(NE_OP); }
";"                     { count(); return(';'); }
("{"|"<%")              { count(); return('{'); }
("}"|"%>")              { count(); return('}'); }
","                     { count(); return(','); }
":"                     { count(); return(':'); }
"="                     { count(); return('='); }
"("                     { count(); return('('); }
")"                     { count(); return(')'); }
("["|"<:")              { count(); return('['); }
("]"|":>")              { count(); return(']'); }
"."                     { count(); return('.'); }
"&"                     { count(); return('&'); }
"!"                     { count(); return('!'); }
"~"                     { count(); return('~'); }
"-"                     { count(); return('-'); }
"+"                     { count(); return('+'); }
"*"                     { count(); return('*'); }
"/"                     { count(); return('/'); }
"%"                     { count(); return('%'); }
"<"                     { count(); return('<'); }
">"                     { count(); return('>'); }
"^"                     { count(); return('^'); }
"|"                     { count(); return('|'); }
"?"                     { count(); return('?'); }

[ \t\v\n\f]             { count(); }

<<EOF>>			{ return EOFILE; };
.			{ return ERROR ; };
%%

int yywrap()
{
        return(1);
}

int column = 0;
int row    = 1;

//-----------------------------------------------------------------------------
enum { QUOTE = '\'', BACKSLASH = '\\' };

NumericConstant::NumericConstant(const char * txt)
   : Constant("NumericConstant"),
     size(0)
{
   if (*txt == 'L')    txt++;
   if (*txt == QUOTE)   // TODO: make it proper
      {
        value = 0;
        for (txt++; *txt != QUOTE; txt++)
            {
              value <<= 8;
              int next_val = *txt;
              if (*txt == BACKSLASH)
                 {
                   txt++;   // skip backslash
                   next_val = *txt;
                   switch(*txt)
                      {
                        case 'a': next_val = '\a';   break;
                        case 'b': next_val = '\b';   break;
                        case 'f': next_val = '\f';   break;
                        case 'n': next_val = '\n';   break;
                        case 'r': next_val = '\r';   break;
                        case 't': next_val = '\t';   break;

                        case '0': // octal
                             {
                               int len;
                               int s = sscanf(txt, "%i%n", &next_val, &len);
                               assert(s == 2);
                               txt += len;
                             }
			     break;

                        case 'x': // hex
                             {
                               int len;
                               txt++;   // skip 'x'
                               int s = sscanf(txt, "%x%n", &next_val, &len);
                               assert(s == 2);
                               txt += len;
                             }
			     break;
                      }
                 }
              value |= 0x00FF & next_val;
            }
        return;
      }

   if (txt[1] == 'x' || txt[1] == 'X')
      {
        assert(*txt == '0');
        int cnt = sscanf(txt + 2, "%X", &value);
        assert(cnt == 1);
        return;
      }

   if (*txt == '0')
      {
        int cnt = sscanf(txt, "%o", &value);
        assert(cnt == 1);
        return;
      }

int cnt = sscanf(txt, "%d", &value);
   assert(cnt == 1);
}
//-----------------------------------------------------------------------------
StringConstant::StringConstant()
   : Constant("StringConstant"),
     buffer(new char[80]),
     buffer_len(80),
     string_number(str_count++),
     value_len(0)
{
   assert(buffer);
   *buffer = 0;
   if (string_number == 0)   // first string
      {
         for (int i = 0; i < MAX_STRINGS; i++)   all_strings[i] = 0;
      }

   all_strings[string_number] = this;
}
//-----------------------------------------------------------------------------
void StringConstant::EmitAll(FILE * out)
{
   for (int i = 0; i < MAX_STRINGS; i++)
       {
         StringConstant * sc = all_strings[i];
         if (sc == NULL)   continue;

         fprintf(out, "Cstr_%d:\t\t\t\t;\n", sc->string_number);
         for (int i = 0; i < sc->value_len; i++)
             fprintf(out, "\t.BYTE\t0x%2.2X\t\t\t;\n", sc->buffer[i]);

         fprintf(out, "\t.BYTE\t0\t\t\t;\n");
       }
}
//-----------------------------------------------------------------------------
void StringConstant::EmitAndRemove(FILE * out, int length)
{
   if (length < (value_len + 1))
      {
        fprintf(stderr,
                "Initialization string too long (length %d, size %d)\n",
                value_len + 1, length);
        semantic_errors++;
      }

   for (int b = 0; b < length; b++)
       {
         if (b > value_len)
             fprintf(out, "\t.BYTE\t0\t\t\t; [%d]\n", b);
	 else
             fprintf(out, "\t.BYTE\t0x%2.2X\t\t\t; [%d]\n", buffer[b], b);
       }
   
   all_strings[string_number] = 0;
}
//-----------------------------------------------------------------------------
StringConstant::~StringConstant()
{
   delete buffer;

   assert(all_strings[string_number] == this);
   all_strings[string_number] = 0;
}
//-----------------------------------------------------------------------------
StringConstant * StringConstant::operator & (StringConstant * other)
{
   buffer_len = value_len + other->value_len;
char * cp = new char[buffer_len + 1];
   assert(cp);
   memcpy(cp, buffer, value_len);
   memcpy(cp + value_len, other->buffer, other->value_len);
   cp[buffer_len] = 0;
   value_len += other->value_len;

   delete buffer;
   buffer = cp;
   delete other;
   return this;
}
//-----------------------------------------------------------------------------
void StringConstant::operator += (char txt)
{
   if (value_len + 1 >= buffer_len)
      {
        assert(buffer);

        char * cp = new char[2*buffer_len];
	assert(cp);
	memcpy(cp, buffer, buffer_len);
	delete buffer;
	buffer = cp;
	buffer_len *= 2;
      }

   buffer[value_len++] = txt;
   buffer[value_len]   = 0;
}
//-----------------------------------------------------------------------------
void count()
{
   for (int i = 0; yytext[i]; i++)
       {
         if (yytext[i] == '\n')        { column = 0;   row++; }
         else if (yytext[i] == '\t')   column += 8 - (column % 8);
         else                          column++;
       }
}
//-----------------------------------------------------------------------------
int check_type()
{
   if (TypedefName::IsDefined(yytext))   return TYPE_NAME;
   return(IDENTIFIER);
}
//-----------------------------------------------------------------------------
int yyerror(const char *s)
{
   printf("\n%s Line %d Col %d\n", s, row, column);
   fflush(stdout);
}
//-----------------------------------------------------------------------------
