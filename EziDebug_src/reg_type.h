#ifndef REG_TYPE_H
#define REG_TYPE_H

const int MAX_T_LEN= 128 ;
const int MAX_ID_LEN= 64 ;
const int MAX_NAME_LEN = 64 ;

/*enumeration of internal represention of tokens*/
enum TOKEN_IREPS
{UNDEFTOK,IFDEF,IFNDEF,ENDIF,MODULE,BEGIN,END,ENDMODULE,DEFPARAM,POSEDGE,NEGEDGE,IF,ELSE,REG,WIRE,CASE,CASEX,ENDCASE,PARAMETER,DEFINE,INCLUDE,ENDLINE,INPUT,OUTPUT,INOUT,ALWAYS,ASSIGN,SIGNED};

/*  enumeration of token types*/
enum TOK_TYPES
        {UNDEFTT,DELIMITER,IDENTFIER,NUMBER,KEYWORD,TEMP,STRING,BLOCK};
enum DOUBLE_OPS
        {LT=1,LE,GT,GE,EQ,NE,LS,RS,INC,DEC,POW,OR};

enum ERROR_MSG
{SYNTAX,NO_EXP,NOT_VAR,PAREN_EXPECTED,QUOTE_EXPECTED,UNBAL_BRACES,SEMI_EXPECTED,MODULE_UNDEF};

enum IO_ATTRI{IO_INPUT,IO_OUTPUT,IO_INOUT,IO_INVALID};
enum EDGE_ATTRI{INVALID,LOW,HIGH,POSE,NEGE};


//错误消息执行
class InterpExc
{
    ERROR_MSG eErr;
public:
    InterpExc(ERROR_MSG eErrMsg){eErr=eErrMsg;}
    ERROR_MSG eGetErr(){return eErr;}
};


//临时存储空间
struct TempBuf
{
    char cNameBuf[MAX_T_LEN];
    EDGE_ATTRI  eEdge;   //1: posedge,0: negedge
};

#endif // REG_TYPE_H
