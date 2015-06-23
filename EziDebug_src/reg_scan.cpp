#include "reg_scan.h"
//#include "ui_reg_scan.h"

#include <QtCore>
#include <QtGui/QtGui>
//#include <QWidget>
//#include <QtGui/QLabel>
#include <QDebug>
#include <QChar>
#include <QFile>
#include <QMap>
#include <qmath.h>
#include <QString>


#define PROG_SIZE 1024*200

commands ComTable[]={
{       "ifdef",   IFDEF},
{       "ifndef",   IFNDEF},
{       "endif",   ENDIF},
{       "module",   MODULE},
{       "begin",    BEGIN},
{       "end",      END},
{       "endmodule",ENDMODULE },
{       "defparam", DEFPARAM },
{       "posedge",  POSEDGE },
{       "negedge",  NEGEDGE },
{       "if",       IF},
{       "else",     ELSE},
{       "reg",      REG},
{       "wire",     WIRE},
{       "case",     CASE},
{       "casex",    CASEX},
{       "endcase",  ENDCASE},
{       "parameter",PARAMETER},
{       "define",   DEFINE},
{       "include",  INCLUDE},
{       "input",    INPUT},
{       "output",   OUTPUT},
{       "inout",    INOUT},
{       "always",   ALWAYS},
{       "assign",   ASSIGN},
{       "signed",   SIGNED}
 };

ModuleMem ModuleTab[MAX_T_LEN];

MacroMem MacroTab[MAX_T_LEN];

QMap<QString,QString> def_map ;
QMap<QString,QMap<QString,QString> > inst_map ;

QStringList iinstNameList ;

unsigned int unModuCnt=0;
unsigned int unMacroCnt=0;
int nIsComponent=0;

#if 0
#define DealError(a) { \
                       qDebug(a);\
                       return false ;}
#endif

reg_scan::reg_scan(QWidget *parent) :
    QWidget(parent) //,ui(new Ui::reg_scan)
{
    memset(cToken,0, 64 );
    //ui->setupUi(this);
}

reg_scan::~reg_scan()
{
    //delete ui;
}
//load the parse program
/******************************************************/
/*装载待分析Verilog文件，判断大小能否分析以及添加结束符号('\0') */
/******************************************************/
bool reg_scan::LoadVeriFile(char *p,char *fname)
{
    unsigned long i=0;
    QFile iFile(fname);
    ClearModule();
    if(iFile.open(QIODevice::ReadOnly))//WriteOnly | QFile::Truncate))
    {
        do
        {
            iFile.getChar(p);
            p++;i++;
        }while(!iFile.atEnd());
        if(i==PROG_SIZE)
        {
            qDebug("program too big\n");
            iFile.close();
            return FALSE;
        }
        if(*(p-1)==0x1a)  /*Null terminate the program. Skip any EOF mark if present in the file.*/
            *(p-1)='\0';
        else
            *p='\0';
        iFile.close();
        qDebug() << i ;
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}
//retrun true if c is a delimiter
bool reg_scan::IsDelim(char c)
{
//    if((*prog=='@'||*prog==' '||*prog=='='||*prog=='+'||*prog=='-' || *prog=='*'||*prog=='^'||*prog=='/'||*prog=='%'
//            ||*prog==';'||*prog==':'||*prog=='('||*prog==')'||*prog==','||*prog=='`'||*prog=='"'||*prog=='!'||*prog=='<'||*prog=='>')
//            ||c==9||c=='\r'||c==0)return true;
    if((c==':'||c=='@'||*prog==' '||c=='='||c=='+'||c=='-' || c=='*'||c=='^'||c=='/'||c=='%'
        ||c==';'||c=='('||c==')'||c==','||c=='`'||c=='"'||c=='!'||c=='<'||c=='>'||c=='['||c==']')
            ||c==9||c=='\r'||c==0||c=='\n')return true;
    else
        return false;
}

/******************************************************/
/*从数据流中提取下一个令牌以供分析                          */
/******************************************************/
TOK_TYPES reg_scan::GetToken()
{
  char *temp;
    eTokenType=UNDEFTT;
    eTok=UNDEFTOK;
  //memset(token,0,sizeof(token));
    temp=cToken;
  *temp='\0';
  while(*prog==' '&& *prog||*prog=='\t') ++prog;  //QChar::isSpace()
//skip over newline
  while(*prog=='\r'||*prog=='\n')
    {
      ++prog;
//   ++prog;
   while(*prog==' '&& *prog||*prog=='\t') ++prog;
  }

  //check for end of program
  if(*prog=='\0')
  {
        *cToken='\0';
        eTok=ENDLINE;
      //prog++;
        return(eTokenType=DELIMITER);
  }
  //look for comments
  if(*prog=='/')
      if(*(prog+1)=='*')
  {
          prog+=2;
          do
          {//find end of comment
              while(*prog!='*')prog++;
              prog++;

          }while(*prog!='/');
          prog++;
            return(eTokenType=DELIMITER);
  }
      else if(*(prog+1)=='/')
      {
        prog+=2;
        //find end of comment
        while(*prog!='\r' && *prog!='\n'&&*prog!='\0')      //'\n' substitute '\0'
            prog++;
        if(*prog=='\r')
            prog+=2;
            return(eTokenType=DELIMITER);
      }

  while(*prog==' '&& *prog||*prog=='\t') ++prog;  //QChar::isSpace()

  //skip over newline
    while(*prog=='\r'||*prog=='\n')
    {
     ++prog;
//     ++prog;
     while(*prog==' '&& *prog||*prog=='\t') ++prog;
    }

  //check for double-ops.
    if(*prog=='!'||*prog=='<'||*prog=='>'||*prog=='='||*prog=='+'||*prog=='-'||*prog=='*'||*prog=='|'){
  if(*prog=='=')
     { if(*(prog+1)=='=')
      {
        prog++;
        prog++;
        *temp=EQ;
        temp++;
        *temp=EQ;
        temp++;
        *temp='\0';
      }
     }
   else if(*prog=='!'){
      if(*(prog+1)=='=')
      {
        prog++;
        prog++;
        *temp=NE;
        temp++;
        *temp=NE;
        temp++;
        *temp='\0';
      }
  }else if(*prog=='<')
  {
      if(*(prog+1)=='=')
            {
              prog++;
              prog++;
              *temp=LE;
              temp++;
              *temp=LE;
            }else if(*(prog+1)=='<')
      {
        prog++;prog++;
        *temp=LS;
        temp++;
        *temp=LS;
      }else
      {
          prog++;
          *temp=LT;
      }
      temp++;
      *temp='\0';

  }
  else if(*prog=='>')
    {
        if(*(prog+1)=='=')
              {
                prog++;
                prog++;
                *temp=GE;
                temp++;
                *temp=GE;
              }else if(*(prog+1)=='>')
        {
          prog++;prog++;
          *temp=RS;
          temp++;
          *temp=RS;
        }else
        {
            prog++;
            *temp=GT;
        }
        temp++;
        *temp='\0';

    }
  else if(*prog=='+'){
      if(*(prog+1)=='+'){
       prog++;
       prog++;
       *temp=INC;
       temp++;
       *temp=INC;
       temp++;
       *temp='\0';
      }


  }else if(*prog=='-'){
      if(*(prog+1)=='-'){
       prog++;
       prog++;
       *temp=DEC;
       temp++;
       *temp=DEC;
       temp++;
       *temp='\0';
      }
  }
  ///////////////////////////为了处理**为幂的情况
  else if(*prog=='*'){
        if(*(prog+1)=='*'){
         prog++;
         prog++;
         *temp=POW;
         temp++;
         *temp=POW;
         temp++;
         *temp='\0';
        }

    }
  /////////////////////////////为了处理||的情况
  else if(*prog=='|'){
        if(*(prog+1)=='|'){
         prog++;
         prog++;
         *temp=OR;
         temp++;
         *temp=OR;
         temp++;
         *temp='\0';
        }

    }
        if(*cToken)return(eTokenType=DELIMITER);
 }

//check for other delimiters.
  if(*prog=='@'||*prog=='='||*prog=='+'||*prog=='-' || *prog=='*'||*prog=='^'||*prog=='/'||*prog=='%'
          ||*prog==';'||*prog==':'||*prog=='('||*prog==')'||*prog==','||*prog=='`'||*prog=='\''||*prog==']'
          ||*prog=='['||*prog=='\t'||*prog=='&'||*prog=='!'||*prog=='{'||*prog=='}'||*prog=='~'||*prog=='.'||*prog=='?')
  {
      *temp=*prog;
      prog++;
      temp++;
      *temp='\0';
        return(eTokenType=DELIMITER);

  }

//read a quoted string
  if(*prog=='"'){
  prog++;
  while(*prog!='"'&&*prog!='\r'&&*prog){
      if(*prog=='\\'){
          if(*(prog+1)=='n')
          {
            prog++;
            *temp='\n';

          }
      }
            else if((temp-cToken)<MAX_T_LEN)
          *temp++=*prog;
      prog++;
   }
  if(*prog=='\r'||*prog==0)
     throw InterpExc(SYNTAX);
            //DealError("Error: read a quoted string");

  prog++;
  *temp='\0';
        return(eTokenType=STRING);
  }
//read an integer number
  QChar qchr(*prog);
  if(qchr.isDigit())
  {
        while(!IsDelim(*prog))
      {
            if((temp-cToken)<MAX_ID_LEN)
              *temp++=*prog ;
          prog++;
      }
      *temp='\0';
        return(eTokenType=NUMBER);
  }

    //read identifier or keyword,开头为"_"的也要提取出来
    if(qchr.isLetter()||qchr=='_')
  {
        while(!IsDelim(*prog)){//&&*prog!=' ' for module name();
            if((temp-cToken)<MAX_ID_LEN)
              *temp++=*prog;
          prog++;

      }
        eTokenType=TEMP;
  }
  *temp='\0';

//   qDebug() << temp << token << __LINE__;
  
  //determine if token is a keyword or identifier.
    if(eTokenType==TEMP)
  {
        eTok=LookUp(cToken);
        if(eTok)
            eTokenType=KEYWORD;
      else
            eTokenType=IDENTFIER;
  }

  //check  for unidentified character in file.
    if(eTokenType==UNDEFTT)
//      throw InterpExc(SYNTAX);
    {
        qDebug()<<*(prog-6)<<*(prog-5)<<*(prog-4)<<*(prog-3)<<*(prog-2)<<*(prog-1)<<*(prog)<<*(prog+1)<<*(prog+2)<<*(prog+3)<<*(prog+4)<<*(prog+5)<<*(prog+6)<<*(prog+7);
        DealError("Error:undefine unidentified character");
        //throw InterpExc(SYNTAX);
        prog++;
    }
    return eTokenType;

}

/******************************************************/
/*在令牌表ComTable中查找令牌                              */
/******************************************************/
TOKEN_IREPS reg_scan::LookUp(char *s)
{
 int i;

    //convert to lowercase
    QString iStr=s;
    iStr=iStr.toLower();
    for(i=0;*ComTable[i].cCmd;i++)
    {   if(!iStr.compare(ComTable[i].cCmd))
            return ComTable[i].eTok;

    }
    return UNDEFTOK;
}

/******************************************************/
/*释放上一个令牌到数据流中                                 */
/******************************************************/
void reg_scan::PutBack()
{
    char *t;
    t=cToken;
    for(;*t;t++)
    {
        prog--;
        //qDebug()<<*prog;
    }

}



/**************************************************** */
/*Find the location of all macro ,deal with "include" */
/*file  in the program , store global variables       */
/******************************************************/
void reg_scan::ScanPre()
{
    char *p,*tp;
    TOKEN_IREPS DataType;
    QString iStrBegin="module";
    QString iStrEnd="endmodule";


    // qDebug()<<prog;
    int nBraceFlag=0;



    p=prog;
    do{
        while(nBraceFlag){
            GetToken();
            if(eTok==ENDLINE) //DealError("ScanPre error\n");
				throw InterpExc(UNBAL_BRACES);

            if(!iStrBegin.compare(cToken))nBraceFlag++;
            if(!iStrEnd.compare(cToken))
                nBraceFlag--;
        }
        tp=prog;
        GetToken();

        //See if global var type or function return type
        if(*cToken=='`'){
            GetToken();

            if(eTok==DEFINE)  //store macro value
            {
                //              qDebug("define");
                GetToken();
                StoreMacro();
            }
            else if(eTok==INCLUDE)// deal with include file
            {
                GetToken();
                ExecInclude();
            }


        }
        else{
            //          if(*cToken=='{')nBraceFlag++;
            //          if(*cToken=='}')nBraceFlag--;
            if(!iStrBegin.compare(cToken))nBraceFlag++;
            if(!iStrEnd.compare(cToken))nBraceFlag--;
        }
    }while(eTok!=ENDLINE);
    if(nBraceFlag)
        throw InterpExc(UNBAL_BRACES);
        //DealError("nBraceFlag is not equal 0\n");
    prog=p;
    //   qDebug()<<*(prog)<<*(prog+1)<<*(prog+2)<<*(prog+3)<<*(prog+4)<<*(prog+5)<<*(prog+6)<<*(prog+7)<<*(prog+8)<<*(prog+9)<<*(prog+10)<<*(prog+11);
}



//interpret a single statment or block of code.When interp() returns from its initial call,the final
//module(or a return) in module has been encounted.
void reg_scan::Interp()
{
    do{   //find all module

        if(FindModule("module"))
            do{
            //don't interpret until the keyword "endmodule"
            eTokenType= GetToken();
            if(eTokenType==IDENTFIER)
            {
                // qDebug()<<*(prog)<<*(prog+1)<<*(prog+2)<<*(prog+3)<<*(prog+4)<<*(prog+5)<<*(prog+6)<<*(prog+7)<<*(prog+8)<<*(prog+9)<<*(prog+10)<<*(prog+11);
                ExecInst();
                //return;
            }
            else if(eTokenType==DELIMITER)
            {
                if(*cToken=='`')
                    ExecDef();
            }
            else //is keyword

                switch(eTok) {
                case MODULE:
                    ExecModule();
                    break;

                case INPUT:
                case OUTPUT:
                case INOUT:
                    ExecIO();
                    break;

                case REG:
                    ExecReg();
                    break;

                case WIRE:
                    do{
                        prog++;
                    }while(*prog!=';');
                    prog++;
                    break;

                case PARAMETER:
                    ExecParam();
                    break;

                case DEFPARAM:
                    ExecDefparam();
                    break;

                case ALWAYS:
                    ExecAlways();
                    break;

                case ASSIGN:
                    ExecAssign();
                    break;

                case ENDMODULE:
                    break;

                case ENDLINE:
					throw InterpExc(SYNTAX);
                    //DealError("Error:innormal endline\n");
                    return;

                default:
                    qDebug()<<cToken;
                    break;
                }
        }while(eTok!=ENDMODULE);
    }while(eTok!=ENDLINE);
    //  return;
}

//return the entry point of the inst module
char *reg_scan::FindInstModu(char *name)
{
    unsigned i;
    for(i=0;i<ModuleTab[unModuCnt-1].InstModuTab[i].unSize;i++)
        if(!qstrcmp(name,ModuleTab[unModuCnt-1].InstModuTab[i].cInstName))
            return ModuleTab[unModuCnt-1].InstModuTab[i].cModuName;
    return NULL;
}




bool reg_scan::FindModule(char *name)
{
    // QString str=prog;
    //    qDebug()<<*(prog)<<*(prog+1)<<*(prog+2)<<*(prog+3)<<*(prog+4)<<*(prog+5)<<*(prog+6)<<*(prog+7)<<*(prog+8)<<*(prog+9)<<*(prog+10)<<*(prog+11);
    do
    {
        GetToken();
    }while(eTok!=ENDLINE&&eTok!=MODULE/*str.compare(name)*/);
    if(eTok==ENDLINE/*&&tok!=1*/)
    {
        return FALSE;
    }
    PutBack();
    // qDebug()<<"cToken is "<<*prog;
    return TRUE;
}



void reg_scan::ExecModule()
{
    eTokenType=GetToken();
    // qDebug()<<"ExecModule";
    if(eTokenType==IDENTFIER)
    {
        qstrcpy(ModuleTab[unModuCnt].cModuleName,cToken);
        unModuCnt++;
    }
    while(*cToken!=';')
    {
        GetToken();
    }
    // qDebug()<<eTokenType<<*cToken;
    ModuleTab[unModuCnt-1].nIPCore=0;

}

void reg_scan::ExecIO()
{
    QString iIOAttri=cToken;
    QString iWidthAttri="1";//存储位宽
    //  int value=1,partial_value;
    do{

        if(!iIOAttri.compare("input"))
            ModuleTab[unModuCnt-1].IOTab[ModuleTab[unModuCnt-1].unIOCnt].eIOAttri=IO_INPUT;
        else  if(!iIOAttri.compare("output"))
            ModuleTab[unModuCnt-1].IOTab[ModuleTab[unModuCnt-1].unIOCnt].eIOAttri=IO_OUTPUT;
        else  if(!iIOAttri.compare("inout"))
            ModuleTab[unModuCnt-1].IOTab[ModuleTab[unModuCnt-1].unIOCnt].eIOAttri=IO_INOUT;
        else
			throw InterpExc(SYNTAX);
            //DealError("Error:Not a io port\n");

        eTokenType= GetToken();
        if(eTokenType==KEYWORD)
        {eTokenType= GetToken();}
        if(eTokenType==DELIMITER&&*cToken!=',')
        {
            /*/////////////////////////////////////////
            //以下情况是将位宽计算按照表达式处理，直接计算出结果
            if(*cToken=='[')
            {//
                EvalExp(value);    //caculate the width and store to the value
                //               qDebug()<<"eval_deal"<<value<<cToken;
                GetToken();

                if(*cToken==':'||*cToken==']')
                {
                    if(*cToken==':')
                    {
                        EvalExp(partial_value);
                        //                       qDebug(": is coming");
                        if(*cToken==']')
                        {

                            value=value-partial_value+1;
                            GetToken();
                        }
                        //                       qDebug()<<cToken<<value;
                    }
                }
            }
            ////////////////////////////////////////////////*/
            //以下是针对将位宽表达式存储为字符串的处理过程
            if(*cToken=='[')
            {
                iWidthAttri.clear();
                GetToken();
                do
                {
                    iWidthAttri.append(cToken);
                    GetToken();

                }while(*cToken!=']');
            }
        }
        else if(eTokenType==IDENTFIER)
        {
            qstrcpy(ModuleTab[unModuCnt-1].IOTab[ModuleTab[unModuCnt-1].unIOCnt].cIOName,cToken);//store the io name
            ModuleTab[unModuCnt-1].IOTab[ModuleTab[unModuCnt-1].unIOCnt++].iIOWidth=iWidthAttri;
            // qDebug()<<"name is"<<IOTab[ModuleTab[unModuCnt-1].unIOCnt-1].cIOName;
            // qDebug()<<"width is"<<IOTab[ModuleTab[unModuCnt-1].unIOCnt-1].iIOWidth;
        }
    }while(*cToken!=';');
}

void reg_scan::ExecReg()
{
    QString iWidthAttri="1";//存储位宽
    QString iRegWidth;
    do{
        eTokenType= GetToken();
        if(eTokenType==DELIMITER&&*cToken!=',')
        {
            /*////////////////////////////////////
            //以下情况是将位宽计算按照表达式处理，直接计算出结果
            if(*cToken=='[')
            {
                EvalExp(value);    //caculate the width and store to the value

                GetToken();

                if(*cToken==':'||*cToken==']')
                {
                    if(*cToken==':')
                    {
                        EvalExp(partial_value);
                        //                       qDebug(": is coming");
                        if(*cToken==']')
                        {

                            value=value-partial_value+1;
                            GetToken();
                        }
                        //                       qDebug()<<cToken<<value;
                    }
                }

            }
            //////////////////////////////////////*/
            //以下是针对将位宽表达式存储为字符串的处理过程
            if(*cToken=='[')
            {
                iWidthAttri.clear();
                GetToken();
                do
                {
                    iWidthAttri.append(cToken);
                    GetToken();

                }while(*cToken!=']');
                qDebug() << "EziDebug the BitWidth:"<< iWidthAttri ;
            }
        }
        else if(eTokenType==IDENTFIER)
        {
            qstrcpy(ModuleTab[unModuCnt-1].RegTab[ModuleTab[unModuCnt-1].unRegCnt].cRegName,cToken);//store the reg name
            ModuleTab[unModuCnt-1].RegTab[ModuleTab[unModuCnt-1].unRegCnt++].iRegWidth=iWidthAttri;
            // qDebug() << "name  is" << unModuCnt-1 << ModuleTab[unModuCnt-1].unRegCnt-1<< ModuleTab[unModuCnt-1].RegTab[ModuleTab[unModuCnt-1].unRegCnt-1].cRegName;
            // qDebug() << "width is" << unModuCnt-1 << ModuleTab[unModuCnt-1].unRegCnt-1 << ModuleTab[unModuCnt-1].RegTab[ModuleTab[unModuCnt-1].unRegCnt-1].iRegWidth;
            GetToken();
            /*/////////////////////////////
            //以下情况是将寄存器个数按照表达式处理，直接计算出结果
            if(*cToken=='[')
            {
                EvalExp(value);    //caculate the width and store to the value

                GetToken();

                if(*cToken==':'||*cToken==']')
                {
                    if(*cToken==':')
                    {
                        EvalExp(partial_value);
                        //                       qDebug(": is coming");
                        if(*cToken==']')
                        {

                            value=value-partial_value+1;
                            GetToken();
                        }
                        //                       qDebug()<<cToken<<value;
                    }
                }

                ModuleTab[unModuCnt-1].RegTab[ModuleTab[unModuCnt-1].unRegCnt-1].iRegCnt=value;
                qDebug()<<"width is"<<ModuleTab[unModuCnt-1].RegTab[ModuleTab[unModuCnt-1].unRegCnt-1].iRegCnt;
            }
            ///////////////////////////////////////////////*/
            //以下是针对将寄存器个数表达式存储为字符串的处理过程
            if(*cToken=='[')
            {
                iRegWidth.clear();
                GetToken();
                do
                {
                    iRegWidth.append(cToken);
                    GetToken();

                }while(*cToken!=']');
                ModuleTab[unModuCnt-1].RegTab[ModuleTab[unModuCnt-1].unRegCnt-1].iRegCnt=iRegWidth;
            }
            else
                PutBack();
        }
    }while(*cToken!=';');
}
//store the value of macro (`define)
void reg_scan::StoreMacro()
{
    QString iMacroVal;
    if(eTokenType==IDENTFIER)
    {
        MacroTab[unMacroCnt].nMacroFlag=1;
        qstrcpy(MacroTab[unMacroCnt].cMacroName,cToken);
        eTokenType=GetToken();
        if(*cToken==NULL||*cToken=='`'||eTokenType==KEYWORD||eTokenType==IDENTFIER)
        {
            unMacroCnt++;
            PutBack();
        }
        else
        {
            iMacroVal.clear();
            do{
                iMacroVal.append(cToken);
                eTokenType=GetToken();
            }while(*cToken!=NULL&&*cToken!='`'&&eTokenType!=KEYWORD&&eTokenType!=IDENTFIER);
            PutBack();
            MacroTab[unMacroCnt++].iMacroVal=iMacroVal;
        }
    }
}
void reg_scan::ExecParam()
{
    // int value=1;
    QString iParaVal;
    do{
        eTokenType=GetToken();
        if(eTokenType==IDENTFIER)
        {   qstrcpy(ModuleTab[unModuCnt-1].ParaTab[ModuleTab[unModuCnt-1].unParaCnt].cParaName,cToken);
            eTokenType=GetToken();
            if(eTokenType==DELIMITER&&*cToken=='=')
            {
                /////////////////////
                //处理parameter后面只是数字的情况
                //  EvalExp(value);    //caculate the width and store to the value
                //////////////////////
                //将后面的参数存储为字符串
                iParaVal.clear();
                GetToken();
                do
                {
                    iParaVal.append(cToken);
                    GetToken();

                }while(*cToken!=','&&*cToken!=';');
                PutBack();
                ModuleTab[unModuCnt-1].ParaTab[ModuleTab[unModuCnt-1].unParaCnt++].iParaVal=iParaVal;
                //qstrcpy(ModuleTab[unModuCnt-1].ParaTab[ModuleTab[unModuCnt-1].unParaCnt++].iParaVal,token);
            }
        }
    }while(*cToken!=';');
}
void reg_scan::ExecAlways()
{

    int i=0;
    char *p;  //record current location
    struct TempBuf iTmpTab[2];
    *iTmpTab[0].cNameBuf='\0';
    iTmpTab[0].eEdge=INVALID;
    *iTmpTab[1].cNameBuf='\0';
    iTmpTab[1].eEdge=INVALID;

    GetToken();
    if(*cToken=='@')
    {
        while(*cToken!=')')
        {
            GetToken();
            //qDebug()<<"token is"<<token<<"prog is"<<*prog;
            if(eTok==POSEDGE)
            {
                GetToken();
                qstrcpy(iTmpTab[i].cNameBuf,cToken);
                iTmpTab[i++].eEdge=POSE;

            }
            else if(eTok==NEGEDGE)
            {
                GetToken();
                strcpy( iTmpTab[i].cNameBuf,cToken);
                iTmpTab[i++].eEdge=NEGE;
            }

        }
    }
    else
		throw InterpExc(SYNTAX);
        //DealError("error: 'always' is error\n");
    // qDebug()<<"before is"<<token;
    if(i==0)
    {
        qDebug("current always is not logic curcuit");
        InterpAlways(NULL,NULL,0);
    }
    else
    {
        if(i==1)
        {
            qDebug("tmp2 is clk");
            InterpAlways(&iTmpTab[0],&iTmpTab[1],1);
        }
        else if(i==2)
        {
            //qDebug("tmp1 is clk");
            p=prog;
            do{
                GetToken();
                //qDebug()<<"prog is "<<*prog<<*p<<token;
                if(eTokenType==IDENTFIER)
                {
                    if(!qstrcmp(cToken,iTmpTab[0].cNameBuf)){
                        prog=p;  //return the prelocation
                        //qDebug()<<"prog is "<<*prog;
                        InterpAlways(&iTmpTab[1],&iTmpTab[0],1);

                    }
                    else  if(!qstrcmp(cToken,iTmpTab[1].cNameBuf)){
                        prog=p;  //return the prelocation
                        //qDebug()<<"prog is "<<*(prog-1)<<token;
                        InterpAlways(&iTmpTab[0],&iTmpTab[1],1);
                    }
                    //else
                    //DealError("ERROR: always programa error");
                    return;
                }
            }while(*cToken!=')');
            prog=p;  //return the prelocation
        }
        else
            qDebug("find reset");
    }
    //qDebug()<<"token is"<<token;
}

void reg_scan::ExecAssign()
{
    do{
        prog++;
    }while(*prog!=';');
    prog++;
    qDebug()<<"assign"<<*prog;
}

unsigned int reg_scan::VarToUint(char *str)
{
    uint32_t var;
    QString iStr=str;
    QString tmp;
    int position;
    bool ok;


    if((position=iStr.indexOf("b",0))!=-1)
    {
        tmp=iStr.remove(0,position+1);
        tmp=tmp.remove('_');
        var=tmp.toUInt(&ok,2);
    }
    else if((position=iStr.indexOf("o",0))!=-1)
    {
        tmp=iStr.remove(0,position+1);
        tmp=tmp.remove('_');
        var=tmp.toUInt(&ok,8);
    }
    else if((position=iStr.indexOf("h",0))!=-1)
    {
        tmp=iStr.remove(0,position+1);
        tmp=tmp.remove('_');
        var=tmp.toUInt(&ok,16);
    }
    else if((position=iStr.indexOf("d",0))!=-1)
    {
        tmp=iStr.remove(0,position+1);
        tmp=tmp.remove('_');
        var=tmp.toUInt(&ok,10);
    }
    else
    {

        tmp=iStr.remove('_');
        var=iStr.toUInt(&ok,10);
    }
    return var;
}


bool reg_scan::DealError(char *str)
{
    qDebug(str);
    return FALSE;
}


bool reg_scan::IsVar(char *vname)
{
    for(int i=0;i<ModuleTab[unModuCnt-1].unParaCnt;i++)
    {
        if(!qstrcmp(ModuleTab[unModuCnt-1].ParaTab[i].cParaName,vname))
            return TRUE;
    }
    return FALSE;
}

QString reg_scan::FindVar(char *vname)
{
    for(int i=0 ; i < ModuleTab[unModuCnt-1].unParaCnt ; i++)
    {
        if(!qstrcmp(ModuleTab[unModuCnt-1].ParaTab[i].cParaName,vname))
            return ModuleTab[unModuCnt-1].ParaTab[i].iParaVal ;
    }

    for(int i=0;i<unMacroCnt;i++)
    {
        if(!qstrcmp(MacroTab[i].cMacroName,vname))
            return MacroTab[i].iMacroVal;
    }
    return QString() ;
    // return FALSE;

}


/*void reg_scan::find_attr_reg()
{
  int flag=1;
  GetToken();
  if(tok==BEGIN)
  {
     do
      {
       GetToken();
       switch(tok){
           case BEGIN:
                flag++;
                break;
           case END:
                flag--;
                break;
           case LT:
           case GE:

                break;
        }
      }while(flag);
  }
  else if(tok==IF||tok==ELSE)
  {
      GetToken();
      if(tok==BEGIN)
      {
          do
           {
            GetToken();
            switch(tok){
                case BEGIN:
                     flag++;
                     break;
                case END:
                     flag--;
                     break;
                case LT:
                case GE:
                     return;
                     break;
             }
           }while(flag);
      }
     else
      {

       }


  }
}*/

/******************************************************/
/*处理always中的内容，之前已经解析出时钟信号和复位信号，如果没有 */
/*以上信号，则isRegValid为0,否则为1                       */
/******************************************************/
void reg_scan::InterpAlways(struct TempBuf* clk,struct TempBuf* rst,bool isRegValid)
{
    int flag=0;
    int brace_f=1;
    char tmp[MAX_T_LEN];

    //   qDebug()<<"start is"<<token;
    GetToken();
    //   qDebug()<<"end is "<<token;

    //解决tab键的问题
    while(eTokenType!=IDENTFIER&&eTokenType!=KEYWORD)
    {
        GetToken();
    }

    if(eTokenType==IDENTFIER&&flag==0)
    {
        //qDebug()<<" identifier is"<<token;
        qstrcpy(tmp,cToken);
        GetToken();
        //if(*cToken==LE||*cToken=='=')
        {
            qDebug("no begin &if");
            //set the tmp's clk and rst
            if(!SetRegAttr(tmp,clk,rst,isRegValid))
				throw InterpExc(SYNTAX);
                //DealError("ERROR: Reg is not exist");
            //           qDebug()<<"current token is"<<token<<*(prog-1);
            do{
                prog++;
            }while(*prog!=';');
            prog++;

            return;     //deal with the case that section have no begin/end
        }
    }
    else{
        PutBack();

        do{
            GetToken();
            if(eTokenType==IDENTFIER)
            {
                qstrcpy(tmp,cToken);
                GetToken();
                if(*cToken==LE)
                {
                    PutBack();
                    //set reg attribute
                    SetRegAttr(tmp,clk,rst,isRegValid);
                    do
                    {
                        prog++;
                    }while(*prog!=';');
                    prog++;
                }

            }else{
                switch(eTok){
                case BEGIN:
                    flag++;
                    //          qDebug()<<"flag is"<<flag;
                    break;
                case END:
                    flag--;
                    if(!flag)
                    {
                        GetToken();
                        if(eTok==ELSE/*||tok==IF*/)
                        {
                            PutBack();
                            InterpAlways(clk,rst,isRegValid);
                        }
                        else
                            PutBack();
                    }
                    qDebug()<<"flag end is"<<flag;
                    break;

                case IF:

                    do{
                        GetToken();
                        if(*cToken=='(')
                            brace_f++;
                        else if(*cToken==')')
                            brace_f--;
                    }while(brace_f!=1);
                    InterpAlways(clk,rst,isRegValid);

                    //for "if" without begin/end
                    if(!flag)
                    {
                        GetToken();
                        while(eTokenType==DELIMITER)
                            GetToken();
                        if(eTok==ELSE/*||tok==IF*/)
                        {
                            PutBack();
                            InterpAlways(clk,rst,isRegValid);
                        }
                        else
                            PutBack();
                    }
                    break;

                case ELSE:
                    qDebug()<<"else is"<<cToken;
                    InterpAlways(clk,rst,isRegValid);
                    break;

                case CASE:
                    flag++;
                    do{
                        GetToken();
                    }while(*cToken!=')');
                    break;

                case CASEX:
                    flag++;
                    do{
                        GetToken();
                    }while(*cToken!=')');
                    break;

                case ENDCASE:
                    flag--;
                    break;
                default:
                    break;
                }
            }
        }while(flag!=0);
    }
    qDebug("quit always");
}

/******************************************************/
/*存储reg的相关属性，包括时钟信号名称及属性，复位信号名称及属性   */
/******************************************************/
bool reg_scan::SetRegAttr(char *reg,struct TempBuf* clk,struct TempBuf* rst,bool isRegValid)
{
    int i;
    if(isRegValid){
        for(i=0;i<ModuleTab[unModuCnt-1].unRegCnt;i++)
        {
            if(!qstrcmp(reg,ModuleTab[unModuCnt-1].RegTab[i].cRegName))
            {
                qstrcpy( ModuleTab[unModuCnt-1].RegTab[i].RstAttri.cRstName,rst->cNameBuf);
                ModuleTab[unModuCnt-1].RegTab[i].RstAttri.eRstEdge=rst->eEdge;
                qstrcpy(ModuleTab[unModuCnt-1].RegTab[i].ClkAttri.cClkName,clk->cNameBuf);
                ModuleTab[unModuCnt-1].RegTab[i].ClkAttri.eClkEdge=clk->eEdge;
                ModuleTab[unModuCnt-1].RegTab[i].IsFlag=1;
                return TRUE;
            }

        }
    }
    else
    {
        for(i=0;i<ModuleTab[unModuCnt-1].unRegCnt;i++)
        {
            if(!qstrcmp(reg,ModuleTab[unModuCnt-1].RegTab[i].cRegName))
            {
                //qstrcpy( ModuleTab[unModuCnt-1].RegTab[i].RstAttri.cRstName,rst->cNameBuf);
                //ModuleTab[unModuCnt-1].RegTab[i].RstAttri.eRstEdge=rst->eEdge;
                //qstrcpy(ModuleTab[unModuCnt-1].RegTab[i].ClkAttri.cClkName,clk->cNameBuf);
                //ModuleTab[unModuCnt-1].RegTab[i].ClkAttri.eClkEdge=clk->eEdge;
                ModuleTab[unModuCnt-1].RegTab[i].IsFlag=0;
                return TRUE;
            }
        }
    }
    return FALSE;
}

/******************************************************/
/*将整个程序解析出来的内容打印在文本文件result.txt中，以供校验  */
/******************************************************/
void reg_scan::PrintFile()
{
    int i,j;
    ///////////////////////////////////////////////////以下为输出到文件中进行检测
    QFile resultFile("result.txt");
    if(!resultFile.open(QFile::Append|QIODevice::Text|QIODevice::WriteOnly))
    {
        qDebug() << resultFile.errorString();
    }
    QTextStream out(&resultFile);

    //输出define信息
    out<<"define macros:\n";
    for(i=0;i<unMacroCnt;i++)
    {
        out<<qSetFieldWidth(16)<<right<<MacroTab[i].cMacroName<<MacroTab[i].iMacroVal
          << "flag:" <<MacroTab[i].nMacroFlag << "\n";
    }

    for (j=0;j<unModuCnt;j++)
    {
        out<<"module:"<<"\n";
        out<<qSetFieldWidth(16)<<right<<ModuleTab[j].cModuleName<<"\n";
        for(i=0;i<ModuleTab[j].unInstCnt;i++)
        {
            out<<"instname:"<<ModuleTab[j].InstModuTab[i].cInstName<<"modulename:"<<ModuleTab[j].InstModuTab[i].cModuName<<"\n";
        }

        //输出input,output信息
        out<<"ports:\n";
        for (i=0;i<ModuleTab[j].unIOCnt;i++)
        {

            out<<qSetFieldWidth(10)<<right<<ModuleTab[j].IOTab[i].cIOName;//<<IOTab[i].eIOAttri<<IOTab[i].iIOWidth<<"\n";
            if(ModuleTab[j].IOTab[i].eIOAttri==0)
                out<<"input";
            else if(ModuleTab[j].IOTab[i].eIOAttri==1)
                out<<"output";
            else out<<"inout";
            out<<ModuleTab[j].IOTab[i].iIOWidth<<"\n";
        }

        //输出reg信息
        out<<"regs:\n";
        for(i=0;i<ModuleTab[j].unRegCnt;i++)
        {
            out<<ModuleTab[j].RegTab[i].cRegName;
            out<<"IsFlag:"<<ModuleTab[j].RegTab[i].IsFlag;
            out<<"width:"<<ModuleTab[j].RegTab[i].iRegWidth;
            out<<"count:"<<ModuleTab[j].RegTab[i].iRegCnt;
            out<<"reg_clk:"<<ModuleTab[j].RegTab[i].ClkAttri.cClkName;
            if(ModuleTab[j].RegTab[i].ClkAttri.eClkEdge==3)
                out<<"POSEDGE";
            else if(ModuleTab[j].RegTab[i].ClkAttri.eClkEdge==4)
                out<<"NEGEDGE";
            out<<"reg_rst:"<<ModuleTab[j].RegTab[i].RstAttri.cRstName;
            if(ModuleTab[j].RegTab[i].RstAttri.eRstEdge==3)
                out<<"POSEDGE";
            else if(ModuleTab[j].RegTab[i].RstAttri.eRstEdge==4)
                out<<"NEGEDGE";
            out<<"\n";
        }

        //输出parameter信息
        out<<"PARAMETERS:\n";
        for(i=0;i<ModuleTab[j].unParaCnt;i++)
        {
            out<<ModuleTab[j].ParaTab[i].cParaName<<ModuleTab[j].ParaTab[i].iParaVal<<"\n";
        }

        for(int k=0;k<10;k++)
            out<<"******************";
        out<<"\n";

    }
}

/******************************************************/
/*处理实体例化的情况，并将内容存储在全局变量InstMap中，存储格式为*/
/*<module_name#inst_name,<port_name,port_value> >     */
/******************************************************/
void reg_scan::ExecInst()
{
    char module_tmp[MAX_NAME_LEN];
    char inst_tmp[MAX_NAME_LEN];
    char port_module[MAX_NAME_LEN];
    char port_inst[MAX_NAME_LEN];
    int position;

    QMap<QString,QString> port_map;
    QString  name_map;
    QString  port_inst_tmp;

    qstrcpy(module_tmp,cToken); //module名称
    do
    {
        GetToken();
    }while(eTokenType!=IDENTFIER);
    qstrcpy(inst_tmp,cToken);


    name_map.append(module_tmp);
    name_map.append("#");
    name_map.append(inst_tmp);


    qDebug()<<"inst module is"<<name_map;
    qstrcpy(ModuleTab[unModuCnt-1].InstModuTab[ModuleTab[unModuCnt-1].unInstCnt].cModuName,cToken);
    do{
        GetToken();
		if(eTok == ENDLINE)
		{
			throw InterpExc(SYNTAX); 
		}
        switch(*cToken){
        case '.':
            while(eTokenType!=IDENTFIER)
            {
                GetToken();
            }
            qstrcpy(port_module,cToken);
            do{
                GetToken();
				if(eTok == ENDLINE)
				{
					throw InterpExc(SYNTAX); 
			    }
            }while(*cToken!='(');
            eTokenType=GetToken();
            if(*cToken==')')
            {
                qstrcpy(port_inst,"NULL");
                port_map.insert(port_module,port_inst);
                PutBack();
            }
            else if(*cToken=='{')
            {
                do{
                    port_inst_tmp.append(cToken);
                    GetToken();
					if(eTok == ENDLINE)
					{
				    	throw InterpExc(SYNTAX); 
			    	}
                }while(*cToken!=')');
                PutBack();
                port_map.insert(port_module,port_inst_tmp);
            }
            else
            {
                qstrcpy(port_inst,cToken);
                port_map.insert(port_module,port_inst);
            }

            do{
                GetToken();	
				if(eTok == ENDLINE)
				{
				    throw InterpExc(SYNTAX); 
			    }
            }while(*cToken!=')');
            break;
        default:
            break;
        }
    }while(*cToken!=';');
	
    inst_map.insert(name_map,port_map);
    iinstNameList.append(name_map);
    //判断是否为ipcore
    if((position=name_map.indexOf("_component",0))!=-1) //表示找到
        nIsComponent=1;
}

/******************************************************/
/*处理关键字DEFPARAM的情况，并将内容存储在全局变量DefMap中，存储*/
/*格式为<inst_name.para_name,para_value>               */
/******************************************************/
void reg_scan::ExecDefparam()
{
    QString inst_name;
    QString para_name;
    if(nIsComponent)
    {
        ModuleTab[unModuCnt-1].nIPCore=1;
        nIsComponent=0;
        do{
            GetToken();
        }while(*cToken!=';');
    }
    else
    {
        do{
            eTokenType=GetToken();
            if(eTokenType==IDENTFIER)
            {
                //存储格式为（实体名.端口名，数值）
                inst_name.clear();
                para_name.clear();
                inst_name.append(cToken);
                GetToken();
                if(*cToken=='=')
                {
                    GetToken();
                    do{
                        para_name.append(cToken);
                        GetToken();
                    }while(*cToken!=';'&&*cToken!=',');
                    PutBack();
                }
                else
					throw InterpExc(SYNTAX);
                    //DealError("Error in para value of defparam!\n");

                def_map.insert(inst_name,para_name);
            }

        }while(*cToken!=';');
    }
    qDebug()<<"defparam is" << def_map;
}

/******************************************************/
/*处理预处理指令(`),分为三种情况：DEFINE,IFDEF,IFNDEF       */
/******************************************************/
void reg_scan::ExecDef()
{
    int l_nMacroFlag=0;
    int l_nElseFlag=0;
    GetToken();
    if(eTok==IFDEF)
    {
        eTokenType=GetToken();
        if(eTokenType==IDENTFIER)
            if(FindMacro(cToken))
                l_nMacroFlag=1;
        if(l_nMacroFlag==1)//如果定义了就执行上面的
        {
            ExecIfels(l_nElseFlag);
            SkipElsend(l_nElseFlag);
        }
        else  //没有定义的情况处理
        {
            SkipIfels(l_nElseFlag);
            ExecElsend(l_nElseFlag);
        }
    }

    else if(eTok==IFNDEF)
    {
        eTokenType=GetToken();
        if(eTokenType==IDENTFIER)
            if(FindMacro(cToken))
                l_nMacroFlag=1;
        if(l_nMacroFlag==0)//如果未定义了就执行上面的
        {
            ExecIfels(l_nElseFlag);
            SkipElsend(l_nElseFlag);
        }
        else  //定义的情况处理
        {
            SkipIfels(l_nElseFlag);
            ExecElsend(l_nElseFlag);
        }
    }
    else if(eTok==DEFINE)//处理module内部有定义宏的情况
    {
        GetToken();
        StoreMacro();
    }

}

/**************************************************** */
/*在已存入的MacroTab中查找当前的宏是否存在，如果找到，返回真，否 */
/*则，返回假                                            */
/******************************************************/
bool reg_scan::FindMacro(char *vname)
{
    for(int i=0;i<unMacroCnt;i++)
    {
        if(!qstrcmp(MacroTab[i].cMacroName,vname))
        {
            if(MacroTab[i].nMacroFlag==1)
                return TRUE;
            else
                return FALSE;
        }
    }

    return FALSE;
}

/***************************************************************************/
/*处理预处理指令，执行`else之前的指令                                             */
/****************************************************************************/
void reg_scan::ExecIfels(int &nElseFlag) //nElseFlag为else的标志位，1表示发现else
{
    int l_nEndFlag=1;//标志位

    do{
        eTokenType= GetToken();
        switch(eTokenType)
        {
        case IDENTFIER:
            ExecInst();
            break;

        case DELIMITER:
            if(*cToken=='`')
            {
                GetToken();
                switch(eTok)
                {
                case IFDEF:
                case IFNDEF:
                    PutBack();
                    ExecDef();
                    break;

                case ELSE:
                    l_nEndFlag=0;
                    nElseFlag=1;
                    break;

                case ENDIF:
                    if(l_nEndFlag) //处理不存在else的情况，直接是endif时
                    {
                        l_nEndFlag=0;
                        nElseFlag=0;
                    }
                    break;
                default:
                    break;
                }
            }
        case KEYWORD:
        {
            switch(eTok)
            {
            case ALWAYS:
                ExecAlways();
                break;

            case INPUT:
            case OUTPUT:
            case INOUT:
                ExecIO();
                break;

            case REG:
                ExecReg();
                break;

            case WIRE:
                do{
                    prog++;
                }while(*prog!=';');
                prog++;
                break;

            case PARAMETER:
                ExecParam();
                break;


            case DEFPARAM://将参数存储，包括模块名，参数名，参数数值，以字符串形式存储
                ExecDefparam();
                break;

            case ASSIGN:
                do{
                    prog++;
                }while(*prog!=';');
                prog++;
                break;

            default:
                break;
            }
        }
        default:
            break;
        }
    }while(l_nEndFlag);
}

/***************************************************************************/
/*执行预处理命令，执行`else到`endif中间的指令                                     */
/****************************************************************************/
void reg_scan::ExecElsend(int &nElseFlag)
{
    if(nElseFlag)//表示存在else的情况
    {
        int l_nEndFlag=1;//标志位

        do{
            eTokenType= GetToken();
            switch(eTokenType)
            {
            case IDENTFIER:
                ExecInst();
                break;

            case DELIMITER:
                if(*cToken=='`')
                {
                    GetToken();
                    switch(eTok)
                    {
                    case IFDEF:
                    case IFNDEF:
                        PutBack();
                        ExecDef();
                        break;

                    case ENDIF:
                        l_nEndFlag=0;
                        break;

                    default:
                        break;
                    }
                }
            case KEYWORD:
            {
                switch(eTok)
                {
                case ALWAYS:
                    ExecAlways();
                    break;

                case INPUT:
                case OUTPUT:
                case INOUT:
                    ExecIO();
                    break;

                case REG:
                    ExecReg();
                    break;

                case WIRE:
                    do{
                        prog++;
                    }while(*prog!=';');
                    prog++;
                    break;

                case PARAMETER:
                    ExecParam();
                    break;

                case DEFPARAM://将参数存储，包括模块名，参数名，参数数值，以字符串形式存储
                    ExecDefparam();
                    break;

                case ASSIGN:
                    do{
                        prog++;
                    }while(*prog!=';');
                    prog++;
                    break;

                default:
                    break;
                }
            }
            default:
                break;
            }
        }while(l_nEndFlag);
    }
}

/***************************************************************************/
/*执行预处理命令，跳过`if和`else之间的指令                                        */
/****************************************************************************/
void reg_scan::SkipIfels(int &nElseFlag)
{
    int l_nEndFlag=1;

    do{
        GetToken();
        if(*cToken=='`')
        {
            GetToken();
            switch(eTok)
            {
            case IFDEF:
            case IFNDEF:
                l_nEndFlag++;
                break;

            case ENDIF:
                l_nEndFlag--;
                break;

            case ELSE:
                if(l_nEndFlag==1)
                { l_nEndFlag=0;
                    nElseFlag=1;
                }
                break;

            default:
                break;
            }

        }
    }while(l_nEndFlag);

}

/***************************************************************************/
/*执行预处理命令，跳过`else到`endif中间的指令                                    */
/****************************************************************************/
void reg_scan::SkipElsend(int &nElseFlag)
{
    int l_nEndFlag=1;
    if(nElseFlag)//表示发现else
    {
        do{
            GetToken();
            if(*cToken=='`')
            {
                GetToken();
                switch(eTok)
                {
                case IFDEF:
                case IFNDEF:
                    l_nEndFlag++;
                    break;
                case ENDIF:
                    l_nEndFlag--;
                    break;

                default:
                    break;
                }
            }
        }while(l_nEndFlag);
    }
}

/***************************************************************************/
/*为处理include指令预留接口                                                   */
/***************************************************************************/
void reg_scan::ExecInclude()
{

}

/***************************************************************************/
/*清空待存储的module结构体                                                     */
/***************************************************************************/
void reg_scan::ClearModule()
{
    inst_map.clear();
    def_map.clear();

    for(int i=0;i<MAX_T_LEN;i++)
    {

        qstrcpy(ModuleTab[i].cModuleName,NULL);
        ModuleTab[i].unInstCnt=0;
        ModuleTab[i].unIOCnt=0;
        ModuleTab[i].unParaCnt=0;
        ModuleTab[i].unRegCnt=0;
        ModuleTab[i].nIPCore=0;

        for(int j=0;j<MAX_T_LEN;j++)
        {
            qstrcpy(ModuleTab[i].InstModuTab[j].cInstName,NULL);
            qstrcpy(ModuleTab[i].InstModuTab[j].cModuName,NULL);
            ModuleTab[i].InstModuTab[j].unSize=0;
        }
        for(int j=0;j<MAX_T_LEN;j++)
        {
            qstrcpy(ModuleTab[i].IOTab[j].cIOName,NULL);
            ModuleTab[i].IOTab[j].eIOAttri=IO_INVALID;
            ModuleTab[i].IOTab[j].iIOWidth.clear();
        }
        for(int j=0;j<MAX_T_LEN;j++)
        {
            qstrcpy(ModuleTab[i].RegTab[j].cRegName,NULL);
            ModuleTab[i].RegTab[j].iRegWidth.clear();
            ModuleTab[i].RegTab[j].iRegCnt.clear();
            qstrcpy(ModuleTab[i].RegTab[j].ClkAttri.cClkName,NULL);
            ModuleTab[i].RegTab[j].ClkAttri.eClkEdge=INVALID;
            qstrcpy(ModuleTab[i].RegTab[j].RstAttri.cRstName,NULL);
            ModuleTab[i].RegTab[j].RstAttri.eRstEdge=INVALID;
            ModuleTab[i].RegTab[j].IsFlag=0;
        }
        for(int j=0;j<MAX_T_LEN;j++)
        {
            qstrcpy(ModuleTab[i].ParaTab[j].cParaName,NULL);
            ModuleTab[i].ParaTab[j].iParaVal.clear();
        }

    }

    for(int k=0;k<MAX_T_LEN;k++)
    {
        qstrcpy(MacroTab[k].cMacroName,NULL);
        MacroTab[k].iMacroVal.clear();
        MacroTab[k].nMacroFlag=0;
    }
}


//entry point into parser
void reg_scan::EvalExp(int &value)
{
    GetToken();
    //  qDebug()<<"EvalExp token is "<<cToken<<eTokenType;
    if(!*cToken)
        //    {throw InterpExc(NO_EXP);}
        //DealError("empty exp\n");
        throw InterpExc(NO_EXP);
    if(*cToken==';')//||*cToken==':'||*cToken==']'
    {
        value=0;
        return;
    }
    EvalExp0(value);
    PutBack();
}

//process an assignment expression
void reg_scan::EvalExp0(int &value)
{
    char temp[MAX_ID_LEN+1];
    TOK_TYPES temp_tok;

    if(eTokenType==IDENTFIER)
    {
        if(IsVar(cToken))              ////????????
        {
            qstrcpy(temp,cToken);
            temp_tok=eTokenType;
            GetToken();
            if(*cToken=='=')
            {// is an assignment
                GetToken();
                EvalExp0(value);
                //assign_var(temp,value);
                qDebug()<<"assign var";
                return;

            }
            else{

                PutBack();
                qstrcpy(cToken,temp);
                eTokenType=temp_tok;
            }
        }
    }
    EvalExp1(value);
}

//process relational operators
void reg_scan::EvalExp1(int &value)
{
    int partial_value;
    char op;
    char relops[]={LT,LE,GT,GE,EQ,NE,0};
    QString str=relops;


    EvalExp2(value);
    op=*cToken;
    if(str.indexOf(op)!=-1)
    {
        GetToken();
        EvalExp2(partial_value);
        switch(op){
        case LT:
            value=value<partial_value;
            break;
        case LE:
            value=value<=partial_value;
            break;
        case GT:
            value=value>partial_value;
            break;
        case GE:
            value=value>=partial_value;
            break;
        case EQ:
            value=value==partial_value;
            break;
        case NE:
            value=value!=partial_value;
            break;
        }

    }
}

//add or subtract two terms
void reg_scan::EvalExp2(int &value)
{
    char op;
    int partial_value;
    char okops[]={'(',INC,DEC,'-','+',0};
    QString str=okops;
    EvalExp3(value);
    while((op=*cToken)=='+'||op=='-')
    {
        GetToken();
        if(eTokenType==DELIMITER&&str.indexOf(*cToken)==-1)
            //          throw InterpExc(SYNTAX);
            // DealError("exp2\n");
            throw InterpExc(SYNTAX);
        EvalExp3(partial_value);
        switch(op)
        {
        case '-':
            value=value-partial_value;
            break;
        case '+':
            value=value+partial_value;
            break;

        }
    }
}
//multiply or divide two factors
void reg_scan::EvalExp3(int &value)
{
    char op;
    int partial_value,t;
    char okops[]={'(',INC,DEC,'-','+',0};
    QString str=okops;
    EvalExp4(value);
    while((op=*cToken)=='*'||op=='/'||op=='%'||op==POW)
    {
        GetToken();
        if(eTokenType==DELIMITER&&str.indexOf(*cToken)==-1)
                    throw InterpExc(SYNTAX);
            //DealError("exp4\n");
        EvalExp4(partial_value);
        switch(op)
        {
        case '*':
            value=value*partial_value;
            break;
        case '/':
            if(partial_value==0)
                //            throw InterpExc(SYNTAX);
                // DealError("divide 0\n");
                 throw InterpExc(SYNTAX);
            value=(value)/partial_value;
            break;
        case '%':
            t=(value)/partial_value;
            value=value-(t*partial_value);
            break;
        case POW:
            value=qPow(value,partial_value);
            break;
        }
    }

}

//is a unary +,-,++,or --.
void reg_scan::EvalExp4(int &value)
{
   EvalExp5(value);
}

//process parenthesized expression
void reg_scan::EvalExp5(int &value)
{
    if(*cToken=='(')
    {
      GetToken();
      EvalExp0(value);  //get subexpression
        if(*cToken!=')')
//          throw InterpExc(PAREN_EXPECTED);
         // DealError("EvalExp5 error\n");
         throw InterpExc(PAREN_EXPECTED);
      GetToken();
    }
    else
        Atom(value);
}


void reg_scan::Atom(int &value)
{
 int i;
 char temp[MAX_ID_LEN+1];
 QString str=cToken;
 bool ok;
 switch(eTokenType)
 {
   case IDENTFIER:
//     i=internal_func(cToken);
       // value = FindVar(cToken);  //get var's value
       value = 0 ;
//     strcpy(temp,cToken);
       GetToken() ;
       return ;
   case NUMBER:
     value=VarToUint(cToken);
     //value=str.toInt(&ok,10);  //   atoi(cToken);
     GetToken();
//     qDebug()<<cToken;
     return;
   case DELIMITER:
     if(*cToken=='\'')
     {
       value= *prog;
       prog++;
       if(*prog!='\'')
//          throw InterpExc(QUOTE_EXPECTED);
           //DealError("Atom error");
           throw InterpExc(QUOTE_EXPECTED);
       prog++;
       GetToken();
       return;
     }
     if(*cToken==')')return;  //process empty expression
     else if(*cToken==':'||*cToken==']'){
         qDebug("end character");
//         GetToken();
         return;
     }
     else
         throw InterpExc(SYNTAX);
//         DealError("process empty expression");
   default:
//     throw InterpExc(SYNTAX);
//     DealError("Atom default");
		throw InterpExc(SYNTAX);

 }
}

