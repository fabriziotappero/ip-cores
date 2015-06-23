
#include <QtAlgorithms>
#include <QString>
#include <QStringList>
#include <QFile>
#include <QFileInfo>
#include <QVector>
#include <QDir>
#include <QPair>
#include <QTextStream>
#include <QDebug>
#include <memory.h>
#include "textquery.h"

#define OUT(n)  "OUT" #n ".txt"
#define OUTT(n)  OUT##n
#define OUTFILE(n) outfile##n


//int main()
//{
//    TextQuery tq;
//    tq.doit();
//}

void TextQuery::constructDataFile(const QString &filename ,const QStringList &datalist)
{
    QStringList list(datalist);
    QFile ifile(filename) ;

    qDebug() <<  filename ;

    if(!list.size())
    {
        return ;
    }
    // generate the datafile which needed by Testbench

    qDebug() << "retrieve_text" << __LINE__ ;

    QString Data ;

    if(!ifile.open(QIODevice::WriteOnly))
    {
        qDebug() << "Something wrong happen in open Outfile" << "!" << endl;
    }

    qDebug() << "retrieve_text" << __LINE__ ;

    QTextStream Out1(&ifile);

    qDebug() << list.size() << __LINE__  ;

    for(short k = list.size()-1 ; k >= 0 ; k--)
    {
        Data.append(list.at(k) + QObject::tr("\n")) ;
    }

    Out1 << Data ;

    qDebug() << "retrieve_text" << __LINE__ ;

    ifile.close();
}
void TextQuery::retrieve_text()
{
    short open = 0;
    int   nsignalNum = 0 ;
    int nfileCount = 0 ;

    QVector<QString> lines_of_text;
    QMultiMap<QString, QString>    Key_value;
//    QString filename;

    qDebug() << "retrieve_text" << __LINE__ ;

    QFile Outfile(m_ioutputDirectory + QObject::tr("/""tb.v"));

    if(!Outfile.open(QIODevice::WriteOnly))
    {
        qDebug() << "EziDebug Error: Something wrong happen in open Outfile!" << endl;
        return ;
    }
    QTextStream Out(&Outfile);

    // parse data File
    QStringList list;
    for(;nfileCount < m_idataFileNameList.count(); nfileCount++)
    {
        QString idataFileName = m_idataFileNameList.at(nfileCount) ;
        QFile file(idataFileName);
        if(!file.open( QIODevice::ReadOnly | QIODevice::Text))
        {
            qDebug() << "EziDebug Error: Something wrong happen in open file!" << endl;
            return ;
        }
        QTextStream in(&file);
        while(!in.atEnd())
        {
            QString line = in.readLine();
            lines_of_text.append(line);
        }
        file.close();

        QString     wordsline, single_word,single_word1,single_word2, string_num;

        short j = 0, word_num = 0;


        for(short line_pos = 0; line_pos < lines_of_text.size(); line_pos++)
        {
            wordsline = lines_of_text[line_pos];
            list = wordsline.split(QRegExp("\\s+"));
            word_num++;
            if(list.filter(QRegExp("^\\d+$")).count())
            {
                nsignalNum = list.at(0).toInt() + 1 ;
            }
            short i = 0;

            if(Fpga == Altera){
                do{
                    single_word = list.at(i).toLocal8Bit().constData();
                    //             Out << "list.size() is"<< list.size() << "\tline_pos is:" <<line_pos << "  list i is:"<< i <<"  word content is:"<< single_word << endl;

                    if((single_word == string_num.setNum(j)) && open == 0)
                    {
                        j++;
                        break;
                    }else if(single_word.toLower() == "sample")
                    {
                        open = 1;
                    }

                    if(open == 1 && list.size() >= j && i>=1)
                    {
                        Key_value.insertMulti( string_num.setNum(i-1),list.at(i).toLocal8Bit().constData());
                    }

                    i++;
                }while(i < list.size()-1);
            }
            else
            {
                short sampleNum = 0;
                short sample_WidthCount = 0;
                QString word;

                do{
       //             single_word = list.at(i);
                    //               Out << " line_pos is:" <<line_pos << "  list i is:"<<i<<"  word content is:"<< single_word << endl;

                    if(list.at(i) == "Sample" && open == 0)
                    {
                        single_word1 = list.at(i+1) ;
                        single_word2 = list.at(i+2) ;
                        if(single_word1 == "in" && single_word2 == "Buffer")
                        {
                            open = 1;
     //                       j = list.size() - 5;    // 得到采样点数
                            //                      Out << "j = " << j << endl;
                            break ;
                        }
                    }

                    // 从第二列开始 是数据
                    if(open == 1 && list.size()>=2 && i > 1)
                    {
                        if(sampleNum >= sample_table.count() )
                        {
                            break ;
                        }
                        int nwidth = qAbs(sample_table[sampleNum]->width_first - sample_table[sampleNum]->width_second) + 1;

                        qDebug() << __LINE__ << nwidth << sampleNum << sample_table[sampleNum]->sample_name;
                        do
                        {
                            word.append(list.at(i));
                            i++;
                            nwidth-- ;
                        }
                        while((nwidth > 0)&& ( i<list.size()-1 ));

                        Key_value.insertMulti(string_num.setNum(sampleNum),word);
                        word.clear();

                        sampleNum++ ;

                    }
                    else
                    {
                        i++;
                    }

                }while (i < list.size()-1 );

            }
        }

    }

    qDebug() << "retrieve_text" << __LINE__ ;


    short filecount = 0 ;
    for(;filecount < sample_table.count() ; filecount++)
    {
        qDebug() << "retrieve_text" << filecount  <<  __LINE__ ;

        // string_num =  QObject::tr("%1").arg(filecount);
        QString ifileName = m_ioutputDirectory + QObject::tr("%1Out%2").arg(QDir::separator()).arg(filecount) + QObject::tr(".txt") ;
        list= Key_value.values(QString::number(filecount));
        constructDataFile(ifileName,list);
    }


    qDebug() << "retrieve_text" << __LINE__ ;

    Out << endl << endl ;

    qDebug() << "retrieve_text" << __LINE__ ;

    Out << "`timescale 1ns/1ps" << endl;
    Out << "module tb();" << endl;
    Out << QObject::tr("parameter DATA_WIDTH = %1; ").arg(nsignalNum) << endl;

    Out.setFieldAlignment(QTextStream::AlignLeft);

#if 1
    for(short i = 0; i < sample_table.count(); i++)
    {
        if(sample_table[i]->width_first == 0)
        {
            //           Out.setFieldAlignment(QTextStream::AlignLeft);
            Out << "\t" << qSetFieldWidth(30)<< "reg" << qSetFieldWidth(0)<< sample_table[i]->sample_name  << "_buf[1:DATA_WIDTH];" << endl;
        }
        else
        {
            //             Out.setFieldAlignment(QTextStream::AlignLeft);
            Out << "\treg  [";

            Out << qSetFieldWidth(0) << sample_table[i]->width_first << ":" << sample_table[i]->width_second << qSetFieldWidth(20)<< "]";

            Out << qSetFieldWidth(0) << sample_table[i]->sample_name << qSetFieldWidth(0)<<"_buf[1:" << "DATA_WIDTH" << "];" << endl;
        }
    }

    qDebug() << "retrieve_text" << __LINE__ ;

    Out << endl << endl;
    Out << "//{Buffer initialization" << endl;
    Out << "\tinitial" << endl;
    Out << "\tbegin"  << endl;

#if 0
     for (short i = 0 ; i < sample_table.count() ; i++)
    {
        Out << "\t\t$readmemh(" << "Out"+string_num.setNum(i)+".txt" <<",       "<< sample_table[i]->sample_name << "_buf);"   << endl;
    }
#endif

     QString string_num ;
     QString idirctoryStr = m_ioutputDirectory ;
     idirctoryStr.replace(QDir::separator(),"/") ;
     idirctoryStr.append(QObject::tr("/"));
#if 1
     if(Fpga==Altera)
         {
            for (short i = 0; i<sample_table.count(); i++)
            {
                Out << "\t\t$readmemh(" << "Out"+string_num.setNum(i)+".txt" <<",       "<< sample_table[i]->sample_name << "_buf);"   << endl;
            }
         }
         else if(Fpga == Xilinx)
         {
             unsigned int j=0;

             for (short i = 0; i < sample_table.count(); i++)
             {
                 // short sample_width = sample_table[i]->width_first;
                 // Out << "\t\t$readmemb(" << "Out"+string_num.setNum(i)+".txt" <<",       "<< sample_table[i]->sample_name <<"_buf"<< "[" << sample_table[i]->width_first << ":" << sample_table[i]->width_second <<"] );" << endl;
                 Out << "\t\t$readmemb(" << "\"" <<idirctoryStr <<"Out"+string_num.setNum(i)+".txt" << "\"" <<",       "<< sample_table[i]->sample_name <<"_buf"<< " );" << endl;

             }
          }
#endif
    // 添加 end 结尾
    Out << "\tend"  << endl;

    Out << endl;
#if 0
    Out << "\t reg [31:0]  cnt_Pos       ;" << endl;
    Out << "\t reg [31:0]  cnt_Neg       ;" << endl << endl;

    Out << "\t reg [31:0]  sample_0_     ;" << endl;
    Out << "\t reg [31:0]  sample_1_     ;" << endl << endl;
#else
    Out  << "\t reg         check_en     ;" << endl ;
    Out  << "\t reg [31:0]  cnt          ;" << endl ;
    Out  << "\t reg         _EziDebug_clk          ;" << endl ;
    Out  << "\t reg         _EziDebug_rst          ;" << endl ;
    Out  << "\t reg         _EziDebug_TOUT_reg     ;" << endl ;

#endif
    for(short i = 0; i < inout_table.count(); i++)    // 生成输入输出端口
    {
        if((QString::fromAscii(inout_table[i]->port_name) == m_iclockSigName)\
                ||(QString::fromAscii(inout_table[i]->port_name) == m_iresetSigName))
        {
            continue ;
        }

        if(inout_table[i]->inout)
        {
            if(inout_table[i]->width_first == 0)
            {
                Out << "     reg          "<< qSetFieldWidth(0) << inout_table[i]->port_name << "    ;"<< endl;
            }else
            {
                Out << "     reg " <<" ["<< inout_table[i]->width_first << ":" << inout_table[i]->width_second << "]  ";
                Out <<  inout_table[i]->port_name << ";" << endl;
            }
        }else
        {
            if(inout_table[i]->width_first == 0)
            {
                Out << endl;
                Out << "     reg          " <<  inout_table[i]->port_name << "_hw" << "    ;" <<endl;
                Out << "     wire         " << inout_table[i]->port_name << "    ;" << endl ;

            }else
            {
                Out << endl;
                Out  << "     reg " << qSetFieldWidth(0) <<"["<< inout_table[i]->width_first << ":" << inout_table[i]->width_second << "]  ";
                Out  << inout_table[i]->port_name  << "_hw" << "    ;"<< endl;
                Out  << "     wire " << qSetFieldWidth(0) <<"["<< inout_table[i]->width_first << ":" << inout_table[i]->width_second << "]  ";
                Out  << inout_table[i]->port_name << "    ;"<< endl;
            }
        }
    }

    Out << "\t\t ///////////////////////////////////////////////////////////////////////////////////" << endl;
    Out << "\t\t // Inner signal initializing" << endl;
    Out << "\t\t ////////////////////////////////////////////////////////////////////////////////////" << endl << endl << endl;

    Out << "\t\t initial" << endl;
    Out << "\t\t begin" << endl;


    Out << "\t\t\t " << "cnt    =0 ;" << endl;
    Out << "\t\t\t " << "check_en    =0 ;" << endl;
    Out << "\t\t\t " << "_EziDebug_clk    =0 ;" << endl;
    Out << "\t\t\t " << "_EziDebug_rst    =0 ;" << endl;
    Out << "\t\t\t " << "_EziDebug_TOUT_reg    =0 ;" << endl;
    for(short i = 0; i < inout_table.count(); i++)
    {
        if((QString::fromAscii(inout_table[i]->port_name) == m_iclockSigName)\
                ||(QString::fromAscii(inout_table[i]->port_name) == m_iresetSigName))
        {
            continue ;
        }
        if(inout_table[i]->inout)
        {
            Out << "\t\t\t "<< inout_table[i]->port_name << "    =0 ;"<< endl;
        }else
        {
            Out << "\t\t\t "<< inout_table[i]->port_name << "_hw" << "    =0 ;" <<endl;
        }
    }

    Out << "\t\t\t repeat(3) @(posedge _EziDebug_clk);" << endl;
    Out << "\t\t\t      _EziDebug_rst           = 1; " << endl;
    Out << "\t\t\t repeat(3) @(posedge _EziDebug_clk);" << endl;
    Out << "\t\t\t      _EziDebug_rst           = 0; " << endl;
    Out << "\t\t end" << endl << endl;

    Out << "\t\t always #10 _EziDebug_clk = ~_EziDebug_clk ;" << endl << endl;

    Out << "\t\t///////////////////////////////////////////////////////////////////////////" << endl;
    Out << "\t\t// Register Initializing" << endl;
    Out << "\t\t////////////////////////////////////////////////////////////////////////// " << endl;

    Out << "\t\treg  [7:0]  k;" << endl;
    Out << "\t\t initial" << endl;
    Out << "\t\t begin" << endl;
    Out << "\t\t\t k = 0;" << endl;
    Out << "\t\t\t @(posedge _EziDebug_clk);" << endl;
    Out << "\t\t\t\t wait (_EziDebug_TOUT_reg == 1'b1);" << endl;
    Out << "\t\t\t @(negedge _EziDebug_clk);" << endl;
    Out << "\t\t\t @(posedge _EziDebug_clk);" << endl;
    Out << "\t\t\t\t wait (_EziDebug_TOUT_reg == 1'b0);" << endl;
    Out << "\t\t\t @(negedge _EziDebug_clk);" << endl;
    Out << "\t\t\t @(posedge _EziDebug_clk);" << endl;
    Out << "\t\t\t\t begin" << endl;
    Out << "\t\t\t\t $stop;" << endl ;
    Out << "\t\t\t\t     #1" << endl;
    Out << "\t\t\t\t check_en = 1'b1;" << endl ;

    short i1 = 1;
    short format_open = 0;

#if 1
    //QVector<QList<regchain *> > regchain_table ;
    sample * ptdoSample = sample_table.at(0) ;
    QString  itdoPort = QString::fromAscii(ptdoSample->sample_name);
    for(short i = 0; i < regchain_table.count() ; i++)
    {
        QString itdoTemp ;
        QList<regchain *> iregChainList =  regchain_table.at(i) ;
        if(regchain_table.count() > 1)
        {
            itdoTemp = QObject::tr("    = %1_buf[%2][cnt -1 +").arg(itdoPort).arg(i);
        }
        else
        {
            itdoTemp = QObject::tr("    = %1_buf[cnt -1 +").arg(itdoPort);
        }

        for(short j = 0 ; j < iregChainList.count() ; j++)
        {
            if(iregChainList[j]->width_first == 0)
            {
                if(format_open == 1)
                {
                    Out << endl;
                    format_open = 0;
                }
                Out << "\t\t\t\t    dut." << iregChainList[j]->reg_name << itdoTemp << i1 << "];" << endl;
                i1++;
            }
            else
            {
                Out << endl;
                Out << "\t\t\t\t for( k=0; k<" << (iregChainList[j]->width_first + 1) << ";k=k+1)  begin" << endl;
                Out << "\t\t\t\t    dut." << iregChainList[j]->reg_name << "[" << iregChainList[j]->width_first << "-k]" << itdoTemp << i1 << "+k];"  << endl;
                Out << "\t\t\t\t end " << endl;
                i1 += iregChainList[j]->width_first +1;
                format_open = 1;
            }
        }
    }
    // 添加 end 结尾
    Out << "\t\t\t\t end" << endl ;

    // 添加 end 结尾
    Out << "\t\t end" << endl ;
#endif

    Out << endl << endl ;
    Out << "\t\t///////////////////////////////////////////////////////////////////////////" << endl;
    Out << "\t\t// Input Signals " << endl;
    Out << "\t\t////////////////////////////////////////////////////////////////////////// " << endl;
    Out << endl;
    Out << "\t\t\t always@(posedge _EziDebug_clk)" << endl;
    Out << "\t\t\t\t  begin" << endl;

    QString itout = QString::fromAscii(sample_table[1]->sample_name);
    QString ichainName = itout.split("_").at(2) ;
    QString itoutPortName = QObject::tr("_EziDebug_%1_TOUT_reg").arg(ichainName) ;
    // EziDebug_TOUT_reg
    Out << "\t\t\t\t      force " << "_EziDebug_TOUT_reg" << "       =" << itout << "_buf[cnt+1];" << endl;

    for(short i = 0 ; i < inout_table.count() ; i++)
    {
        if((QString::fromAscii(inout_table[i]->port_name) == m_iclockSigName)\
                ||(QString::fromAscii(inout_table[i]->port_name) == m_iresetSigName))
        {
            continue ;
        }
        if(inout_table[i]->inout == 1)
        {
            Out << "\t\t\t\t      force " << inout_table[i]->port_name << "       =" << inout_table[i]->port_name << "_buf[cnt];" << endl;

        }else
        {
            Out << "\t\t\t\t      force " << inout_table[i]->port_name << "_hw       =" << inout_table[i]->port_name << "_buf[cnt];" << endl;

        }
    }

    for(short i = 0 ; i < systeminout_table.count() ; i++)
    {
        QString isysPort = QString::fromAscii(systeminout_table[i]->port_name) ;
        // QString isysTempPort = isysPort.split(".").last();
        QString isysReg = QString::fromAscii(systeminout_table[i]->reg_name) ;
        Out << "\t\t\t\t      force " << isysPort << "       =" << isysReg << "_buf" << "[cnt];" << endl;
    }

    Out << "\t\t\t\t  #1" << endl;
    Out << "\t\t\t\t cnt     = cnt + 32'h1;" << endl;
    Out << "\t\t\t     if(cnt == DATA_WIDTH)  $stop;" << endl;
    Out << "\t\t\t    end" << endl << endl << endl;

    Out << "\t\t///////////////////////////////////////////////////////////////////////////" << endl;
    Out << "\t\t// Outputs checks " << endl;
    Out << "\t\t////////////////////////////////////////////////////////////////////////// " << endl << endl;

    Out << "\t\t  always@ (posedge _EziDebug_clk)" << endl;
    Out << "\t\t\t if(check_en == 1'b1)" << endl;
    Out << "\t\t\t begin" << endl;
    Out << "\t\t\t if("   << endl;

    qDebug() << "retrieve_text" << __LINE__ ;

    for(short i = 0 ; i < inout_table.count() ; i++)
    {
        if((QString::fromAscii(inout_table[i]->port_name) == m_iclockSigName)\
                ||(QString::fromAscii(inout_table[i]->port_name) == m_iresetSigName))
        {
            continue ;
        }
        // 只比较输出
        if(inout_table[i]->inout == 0)
    {
        if( i != (inout_table.count() - 1))
        {
            Out << "\t\t\t   ( "   << inout_table[i]->port_name << "_hw     != " << inout_table[i]->port_name << "      )|" << endl;
        }else
        {
            Out << "\t\t\t   ( "   << inout_table[i]->port_name << "_hw     != " << inout_table[i]->port_name << "      )" << endl;
            }
        }
    }
    Out << "\t\t\t   )"   << endl;
    Out << "\t\t $stop;" << endl;
    Out << "\t\t end" << endl << endl << endl;

    Out << "\t\t///////////////////////////////////////////////////////////////////////////" << endl;
    Out << "\t\t// top  module " << endl;
    Out << "\t\t////////////////////////////////////////////////////////////////////////// " << endl << endl;

    Out << "\t\t   "<< module_name << "  dut(" << endl;
    QString iresetName ;
    for(short i = 0; i < inout_table.count(); i++ )
    {
        if(i != (inout_table.count() -1))
        {
            if(m_iclockSigName == QString::fromAscii(inout_table[i]->port_name))
            {
                Out << "\t\t  ." << qSetFieldWidth(40) << inout_table[i]->port_name << qSetFieldWidth(0) << "( " << "_EziDebug_clk"   << " )," << endl;
            }
            else if(m_iresetSigName == QString::fromAscii(inout_table[i]->port_name))
            {
                if(m_eresetEdge == posedge)
                {
                    iresetName = "_EziDebug_rst";
                }
                else if(m_eresetEdge == nededge )
                {
                    iresetName = "!_EziDebug_rst" ;
                }
                else
                {
                    iresetName = m_iresetSigVal ;
                }

                Out << "\t\t  ." << qSetFieldWidth(40) << inout_table[i]->port_name << qSetFieldWidth(0) << "( " << iresetName  << " )," << endl;
            }
            else
            {
                Out << "\t\t  ." << qSetFieldWidth(40) << inout_table[i]->port_name << qSetFieldWidth(0) << "( " << inout_table[i]->port_name    << " )," << endl;
            }
        }else
        {
            if(m_iclockSigName == QString::fromAscii(inout_table[i]->port_name))
            {
                Out << "\t\t  ." << qSetFieldWidth(40) << inout_table[i]->port_name << qSetFieldWidth(0) << "( " << "_EziDebug_clk" << " )" << endl;
            }
            else if(m_iresetSigName == QString::fromAscii(inout_table[i]->port_name))
            {
                if(m_eresetEdge == posedge)
                {
                    iresetName = "_EziDebug_rst";
                }
                else if(m_eresetEdge == nededge )
                {
                    iresetName = "!_EziDebug_rst" ;
                }
                else
                {
                    iresetName = m_iresetSigVal ;
                }

                Out << "\t\t  ." << qSetFieldWidth(40) << inout_table[i]->port_name << qSetFieldWidth(0) << "( " << iresetName << " )" << endl;
            }
            else
            {
                Out << "\t\t  ." << qSetFieldWidth(40) << inout_table[i]->port_name << qSetFieldWidth(0) << "( " << inout_table[i]->port_name << " )" << endl;
            }
        }
    }

    Out << "\t\t  );  "<< endl << endl ;
    Out << "\t endmodule  "<< endl ;
#endif

    Outfile.close();

    qDebug() << "retrieve_text" << __LINE__ ;
}

void TextQuery::setNoNeedSig(QString clockport, QString resetport ,EDGE_TYPE resetedge,QString resetval)
{
    m_iclockSigName = clockport ;
    m_iresetSigName = resetport ;
    m_eresetEdge = resetedge ;
    m_iresetSigVal = resetval ;
}

