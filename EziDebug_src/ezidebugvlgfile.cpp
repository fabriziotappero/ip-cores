#include "ezidebugfile.h"
#include "ezidebugvlgfile.h"
#include "ezidebugprj.h"
#include "ezidebugscanchain.h"
#include "ezidebugmodule.h"
#include "reg_scan.h"
#include "string.h"
#include <QDebug>
#include <QMessageBox>

extern unsigned int unModuCnt ;
extern unsigned int unMacroCnt ;

extern ModuleMem ModuleTab[MAX_T_LEN];
extern MacroMem MacroTab[MAX_T_LEN];

extern QMap<QString,QString> def_map ;  // 实体名.端口名，数值
extern QMap<QString ,QMap<QString,QString> >inst_map ;
extern QStringList iinstNameList ;

char buffer[200000];


const char *g_pscanRegModuleName =
"" ;
const char *g_pScanRegfileContentFirst =
"(\n"
"\tclock,\n"
"\tresetn,\n"
"\tTDI_reg,\n"
"\tTDO_reg,\n"
"\tTOUT_reg,\n"
"\tshift_reg\n"
"\t);\n"
"\tparameter shift_width = 100;\n"
"\n"
"\tinput   clock;\n"
"\tinput   resetn;\n"
"\tinput   TDI_reg;\n"
"\toutput  TDO_reg;\n"
"\tinput   TOUT_reg;\n"
"\tinput   [shift_width-1:0] shift_reg;\n"
"\n"
"\treg     [shift_width-1:0] shift_reg_r;\n" ;



const char *g_pScanRegfileContentSecond =
"\talways@(posedge clock or negedge resetn)\n"
"\t\tif(!resetn)\n"
"\t\t\tshift_reg_r <= ~shift_reg_r ;\n"
"\t\telse if(TOUT_reg)\n"
"\t\t\tshift_reg_r <=  shift_reg;\n"
"\t\telse\n"
"\t\t\tshift_reg_r <= {shift_reg_r[shift_width-2:0],TDI_reg};\n"
"\n"
"\tassign TDO_reg = shift_reg_r[shift_width-1] ;\n"
"\n"
"endmodule\n"
;



//  "\talways@(posedge clock or negedge resetn)\n"


const char *g_pscanIoModuleName =
"module _EziDebugScanChainIo(\n" ;
const char *g_pScanIofileContentFirst =
"\tclock,\n"
"\tresetn,\n"
"\tTDI_reg,\n"
"\tTDO_reg,\n"
"\tTOUT_reg,\n"
"\tshift_reg\n"
"\t);\n"
"\tparameter shift_width = 100;\n"
"\n"
"\tinput   clock;\n"
"\tinput   resetn;\n"
"\tinput   TDI_reg;\n"
"\toutput  TDO_reg;\n"
"\tinput   TOUT_reg;\n"
"\tinput   [shift_width-1:0] shift_io;\n"
"\n"
"\treg     [shift_width-1:0] shift_io_r;\n" ;




const char*g_pScanIoFileContentSecond =
"\talways@(posedge clock or negedge resetn)\n"
"\t\tif(!resetn)\n"
"\t\t\tshift_io_r <= 0;\n"
"\t\telse if(TOUT_reg)\n"
"\t\t\tshift_io_r <=  shift_io;\n"
"\t\telse\n"
"\t\t\tshift_io_r <= {shift_io_r[shift_width-2:0],TDI_reg};\n"
"\n"
"\tassign TDO_reg = shift_io_r[shift_width-1] ;\n"
"\n"
"endmodule\n"
;


const char* g_ptoutfileContentFirst =
"(\n"
"\t""clock ,\n"
"\t""reset ,\n"
"\t""rstn_out ,\n"
"\t""TOUT_reg \n"
"\t"") ;\n"
"\n"
"\t""input   clock ;\n"
"\t""input   reset ;\n"
"\t""output  rstn_out ;\n"
"\t""output  TOUT_reg ;\n"
"\t""reg[31:0] cnt ;\n"
"\t""reg[31:0] counter ;\n"
"\t""parameter CNT_MAX = 32'd";


const char* g_ptoutfileContentSecond =
"\n\n\t""always@(posedge clock or posedge reset)\n"
"\t\t""if(reset)\n"
"\t\t\t""cnt <= 32'h0 ;\n"
"\t\t""else if(cnt != CNT_MAX)\n"
"\t\t\t""cnt <= cnt + 32'h1 ;\n"
"\n\t""assign rstn_out = (cnt != CNT_MAX ) ? 1'b0 : 1'b1 ;"
"\n\n\t""always@(posedge clock or posedge reset)\n"
"\t\t""if(reset)\n"
"\t\t\t""counter <= 32'h0 ;\n"
"\t\t""else if(counter >= CNT_MAX)\n"
"\t\t\t""counter <= 32'h0 ;\n"
"\t\t""else\n"
"\t\t\t""counter <= counter + 32'h1 ;\n"
"\n"
"\t""assign TOUT_reg = (counter == 32'h0)? 1'b1 : 1'b0 ;\n"
"\n\t""endmodule\n";




EziDebugVlgFile::EziDebugVlgFile(const QString &filename):EziDebugFile(filename)
{

}

EziDebugVlgFile::EziDebugVlgFile(const QString &filename,const QDateTime &datetime,const QStringList &modulelist)\
    :EziDebugFile(filename,datetime,modulelist)
{

}


EziDebugVlgFile::~EziDebugVlgFile()
{

}

int EziDebugVlgFile::deleteScanChain(QStringList &ideletelinecodelist,const QStringList &ideleteblockcodelist,EziDebugScanChain *pchain,EziDebugPrj::OPERATE_TYPE type)
{
    int npos = 0 ;
    int ndeletePos = 0 ;
    int nresultPos = 0 ;
    QList<int> iposList ;
    QMap<int,int> ideleteCodePosMap ;
    QDateTime ilastModifedTime ;

    qDebug() << fileName() ;

    if(fileName().endsWith("SspApbifX.v"))
    {
        qDebug() << "SspApbifX.v";
    }

    // 打开
    // 读取 文件
    if(!open(QIODevice::ReadOnly | QIODevice::Text))
    {
        // 向用户输出  文件打不开
        qDebug() << errorString() << fileName() ;
        return 1 ;
    }

    QTextStream iin(this);
    QString ifileContent = iin.readAll();

    // 关闭
    close();
    // 打开 写 文件

    /*备份扫描过的文件*/
    QString ieziDebugFileSuffix ;
    if(type == EziDebugPrj::OperateTypeDelSingleScanChain)
    {
        ieziDebugFileSuffix.append(tr(".delete.%1").arg(pchain->getChainName()));
    }
    else if(type == EziDebugPrj::OperateTypeDelAllScanChain)
    {
        ieziDebugFileSuffix.append(tr(".deleteall"));
    }
    else
    {
        return 1 ;
    }

    EziDebugPrj *pprj = const_cast<EziDebugPrj *>(EziDebugInstanceTreeItem::getProject());
    QFileInfo ifileInfo(fileName());

    QString idir = EziDebugScanChain::getUserDir() ;
    QString ibackupFileName = pprj->getCurrentDir().absolutePath()\
            + idir + tr("/") + ifileInfo.fileName() \
            + ieziDebugFileSuffix ;
    copy(ibackupFileName);
    pchain->addToScanedFileList(fileName());


    // 将注释 替换成 空格
    QString iblankString = replaceCommentaryByBlank(ifileContent);

#if 0
    QFile itestfile("d:/test.txt");
    if(!itestfile.open(QIODevice::Text|QIODevice::WriteOnly))
    {
        qDebug()<<"aaaaaaaa";
    }
    QTextStream itestout(&itestfile);
    itestout << iblankString ;
    itestfile.close();
#endif

    //QString icaptureString ;
    // 删除行代码
    for(int i = 0 ; i < ideletelinecodelist.count() ; i++)
    {
        // 从 stringlist 提取 字符串 创建 QRegExp
        QRegExp ifindExp(ideletelinecodelist.at(i));
        ifindExp.setMinimal(true);
        QRegExp ifindExpOther(tr("\\s*") + ideletelinecodelist.at(i) );
        ifindExpOther.setMinimal(true);
        // 查找 待删除的字符串
        if((nresultPos = ifindExp.indexIn(iblankString,npos)) == -1)
        {
            // 向用户输出  查找不到 字符串
            qDebug() << "EziDebug info: Can't find the string:" <<ideletelinecodelist.at(i) ;
            continue ;
        }
        else
        {
            // 删除至 上一个非空白字符
            ndeletePos = nresultPos ;
            int nlastNoBlankChar = ifileContent.lastIndexOf(QRegExp("\\S"),ndeletePos-1) ;

            npos = ndeletePos + ifindExp.matchedLength() ;

            if(-1 == nlastNoBlankChar)
            {
                ndeletePos = ndeletePos ;
            }
            else
            {
                ndeletePos = nlastNoBlankChar + 1 ;
            }

            //QString icatchStr = ifindExp.capturedTexts().at(0) ;
            //QString itest = ifileContent.mid(ndeletePos,nresultPos - ndeletePos +ifindExp.matchedLength()) ;
            //qDebug() << itest << icatchStr ;
            iposList.append(ndeletePos);
            ideleteCodePosMap.insert(ndeletePos,(nresultPos - ndeletePos + ifindExp.matchedLength()));

            // 替换 带删除的字符串 为空字符串
            //ifileContent.replace(icaptureString,tr(""));
        }
    }

    // 删除块代码
    npos = 0 ;
    for(int i = 0 ; i < ideleteblockcodelist.count() ; i++)
    {
        // 从 stringlist 提取 字符串 创建 QRegExp
        QRegExp ifindExp(ideleteblockcodelist.at(i));


        // 查找 待删除的字符串
        if((npos = ifindExp.indexIn(iblankString,npos)) == -1)
        {
            // 向用户输出  查找不到 字符串
            qDebug() << ideletelinecodelist.at(i) ;
        }
        else
        {
            // always 和 ;

            // 寻找 always
            int nalwaysPos = iblankString.lastIndexOf(QRegExp(QObject::tr("\\balways\\b")),npos);
            // 最近的非空白字符, 从第一个空白字符开始 到 always 结束 替换为空
            if(-1 != ifileContent.lastIndexOf(QRegExp(QObject::tr("\\S")),nalwaysPos-1))
            {
                nalwaysPos = ifileContent.lastIndexOf(QRegExp(QObject::tr("\\S")),nalwaysPos-1) + 1;
            }

            int nfirstBeginPos = iblankString.indexOf(QRegExp(QObject::tr("\\bbegin\\b")),nalwaysPos);
            /*查找匹配的  end*/
            QRegExp iwordsExp(QObject::tr("\\b\\w+\\b"));
            iwordsExp.setMinimal(true);
            int nmatch = 1 ;
            int nendPos = 0 ;
            int nbeginPos = nfirstBeginPos + 5 ;

            while((nbeginPos = iwordsExp.indexIn(iblankString,nbeginPos)) != -1)
            {
                if(iwordsExp.capturedTexts().at(0) == "begin")
                {
                    nmatch++ ;

                }
                else if(iwordsExp.capturedTexts().at(0) == "end")
                {
                    nmatch-- ;
                    if(0 == nmatch)
                    {
                        nendPos = nbeginPos ;
                        break ;
                    }

                }
                else
                {
                    //
                }
                nbeginPos += iwordsExp.matchedLength();
            }

            if(nmatch != 0)
            {
                qDebug() << "no matching end string!";
                close();
                return 1 ;
            }

            if(nendPos != 0)
            {
                //qDebug() << ifileContent.mid(nalwaysPos,nendPos - nalwaysPos + 3);
                //ifileContent.replace(nalwaysPos , nendPos - nalwaysPos + 3 ,"");
                iposList.append(nalwaysPos);
                ideleteCodePosMap.insert(nalwaysPos , nendPos - nalwaysPos + 3);
                npos = nendPos + 3 ;
            }
            else
            {
                qDebug() << "no finding end string!";
            }
        }
    }

    qSort(iposList.begin(), iposList.end(), qGreater<int>());

    for(int j = 0 ; j < iposList.count() ; j++)
    {
        int nstartPos = iposList.at(j) ;
        int nlength = ideleteCodePosMap.value(nstartPos , -1) ;
        ifileContent.replace(nstartPos , nlength ,"");
    }


    if(!open(QIODevice::WriteOnly | QIODevice::Text | QIODevice::Truncate))
    {
        // 向用户输出  文件打不开
        qDebug() << errorString() << fileName() ;
        return 1 ;
    }

    QTextStream iout(this);
    iout << ifileContent ;

    //关闭
    close();

    ilastModifedTime = ifileInfo.lastModified() ;
    modifyStoredTime(ilastModifedTime);

    return 0 ;
}

int EziDebugVlgFile::addScanChain(INSERT_TYPE type,QMap<QString,EziDebugInstanceTreeItem::SCAN_CHAIN_STRUCTURE*> &chainStructuremap ,EziDebugScanChain* pchain, EziDebugInstanceTreeItem *pitem)
{

    QString ifileData ;
    QString ilastString ;
    QString ichainClock ;
    QString inoSynCode ;
    int noffSet = 0 ;
    EziDebugPrj * iprj = const_cast<EziDebugPrj *>(EziDebugInstanceTreeItem::getProject());
    EziDebugModule *pmodule =  iprj->getPrjModuleMap().value(pitem->getModuleName()) ;

    EziDebugModule *pparentMoudle = iprj->getPrjModuleMap().value(pitem->parent()->getModuleName()) ;
    QMap<QString,QString> iclockMap = pmodule->getClockSignal() ;
    //QMap<QString,QString> iresetMap = pmodule->getResetSignal() ;

    qDebug() << "Add chain in file:" << fileName();
    if(!open(QIODevice::ReadOnly|QIODevice::Text))
    {
        qDebug() << "Cannot Open file for reading:" << qPrintable(this->errorString());
        return 1 ;
    }

#if 0
    if(fileName().endsWith("ifft_airif_rdctrl.v"))
    {
        qDebug("add chain in iifft_airif_rdctrl.v");
    }
#endif

    /*遍历节点时生成 一个寄存器的 迭代关系 字符串  要传入 verilog 文件的 addScanChain 函数中 ，方便插完链之后  保存到相应的对象中*/
    /*读取文件所有字符  从上一个注释的结束端 到 下一个注释的开始端 之间 查找需要的字符串*/
    ifileData = this->readAll();
    close();



    /*记录到 扫描过的文件  并备份  */
    QFileInfo ifileInfo(fileName());
    pchain->addToScanedFileList(fileName());

    QString idir = EziDebugScanChain::getUserDir() ;
    QString ibackupFileName = iprj->getCurrentDir().absolutePath()\
            + idir + tr("/")+ ifileInfo.fileName() \
            + tr(".add") + tr(".%1").arg(pchain->getChainName());
    copy(ibackupFileName);

    QDateTime ilastModifedTime ;

    if(iprj->getToolType() == EziDebugPrj::ToolQuartus)
    {
        inoSynCode = "/*synthesis noprune*/" ;
    }
    else if(iprj->getToolType() == EziDebugPrj::ToolIse)
    {
        inoSynCode = "/* synthesis syn_keep = 1 xc_props = \"x\" */" ;
    }

    /*根据插入代码类型 分别加入代码 */
    // 加入函数 判断 新加入的 代码是否重复 ，如果重复 则在后面加入数字
    if(InsertTimer == type)
    {
        /*如果是定时器 相关代码  */
		
        struct SEARCH_STRING_STRUCTURE iModuleKeyWordSt ;
        iModuleKeyWordSt.m_etype = SearchModuleKeyWordPos ;
        iModuleKeyWordSt.m_icontent.m_imodulest.m_eportAnnounceFormat = NonAnsicFormat ;
        // 父节点的 的 module name
        
        strcpy(iModuleKeyWordSt.m_icontent.m_imodulest.m_amoduleName,pitem->parent()->getModuleName().toAscii().data());
        //  module 名
        int nmoduleKeyWordStartPos = 0 ;
        /*找到  右键加入扫描链的 module 对应例化 的 module */
        if(skipCommentaryFind(ifileData,0,iModuleKeyWordSt,nmoduleKeyWordStartPos))
        {
            close();
            return 1 ;
        }

        struct SEARCH_MODULE_POS_STRUCTURE imodulePos ;
        strcpy(imodulePos.m_amoduleName,iModuleKeyWordSt.m_icontent.m_imodulest.m_amoduleName);
        /*不用管 端口声明的  方式*/
        imodulePos.m_nendModuleKeyWordPos = -1 ;
        /*置为标准的，避免扫描 port */
        imodulePos.m_eportFormat = AnsicFormat ;
        imodulePos.m_nlastRegKeyWordPos = -1 ;
        imodulePos.m_nlastPortKeyWordPos = -1 ;
        imodulePos.m_nlastWireKeyWordPos = -1 ;
        imodulePos.m_nnextRightBracketPos = nmoduleKeyWordStartPos ;


        struct SEARCH_INSTANCE_POS_STRUCTURE *pinstanceSt = (struct SEARCH_INSTANCE_POS_STRUCTURE *)operator new(sizeof(struct SEARCH_INSTANCE_POS_STRUCTURE)) ;
        strcpy(pinstanceSt->m_amoduleName,pitem->getModuleName().toAscii().data());
        strcpy(pinstanceSt->m_ainstanceName,pitem->getInstanceName().toAscii().data());
        pinstanceSt->m_einstanceFormat = NonStardardFormat ;
        pinstanceSt->m_nnextRightBracketPos = -1 ;

        QMap<QString,SEARCH_INSTANCE_POS_STRUCTURE*> iinstancePosMap ;
        iinstancePosMap.insert(pitem->getInstanceName(),pinstanceSt);
        QString iinstanceCode ;
        QString iresetnWireName ;
        QString iresetnWireCode ;
        QString itoutWireName ;
        QString itoutRegName ;
        QString itdoWireCode ;
        QString itdoWireName ;
        QString itoutRegCode;
        QString itdoRegCode ;
        QString itdoRegName ;
        //QString itdoRegEvaluateCode ;
        QString itoutWireCode ;
        QString iblockCode ;
        QString ianncounceCode ;
        QString iaddedCode ;
        QStringList iaddedCodeList ;
        QStringList iaddedBlockCodeList ;
        // 找到 lastreg 、lastwire、右键节点的例化位置
        if(!matchingTargetString(ifileData,imodulePos,iinstancePosMap))
        {

            // 目前不 检查 端口名 是否 重复
            //5、查找 最后的寄存器代码 ，根据 端口 时钟个数 判断加入几个

            //怎么传入端口时钟

            // 加入 定义 线 tout_wire 的代码
            itoutWireName.append(tr("_EziDebug_%1_tout_w").arg(pchain->getChainName()));
            itoutWireCode.append(tr("\n\t""wire _EziDebug_%1_tout_w ;").arg(pchain->getChainName()));
            iaddedCodeList.append(tr("\\bwire\\s+_EziDebug_%1_tout_w\\s*;").arg(pchain->getChainName()));



            itoutRegName.append(tr("_EziDebug_%1_tout_r").arg(pchain->getChainName()));
            itoutRegCode.append(tr("\n\t""reg %1 %2 ;").arg(itoutRegName).arg(inoSynCode));
            iaddedCodeList.append(tr("\\breg\\s*%1\\s*.*;").arg(itoutRegName));

            // 加入用于控制翻转的 reset 信号
            iresetnWireName.append(tr("_EziDebug_%1_rstn_w").arg(pchain->getChainName()));
            iresetnWireCode.append(tr("\n\t""wire _EziDebug_%1_rstn_w ;").arg(pchain->getChainName()));
            iaddedCodeList.append(tr("\\bwire\\s+_EziDebug_%1_rstn_w\\s*;").arg(pchain->getChainName()));

            // iaddedCode.append(itoutWireCode) ;
            ianncounceCode.append(itoutWireCode);
            ianncounceCode.append(itoutRegCode);
            ianncounceCode.append(iresetnWireCode);

            SEARCH_INSTANCE_POS_STRUCTURE *pchainInstanceSt = iinstancePosMap.value(pitem->getInstanceName()) ;
            //clockname 为 module 里面的 clock 名字
            int num = 0 ;
            iinstanceCode.append("\n\t\t") ;
            QMap<QString,QString>::const_iterator i = iclockMap.constBegin();
            while(i != iclockMap.constEnd())
            {
                QString iparentClock ;
                QMap<QString,QString> iparentClockMap = pparentMoudle->getClockSignal();
                QMap<QString,QString>::const_iterator iparentClockIter = iparentClockMap.constBegin() ;
                while(iparentClockIter != iparentClockMap.constEnd())
                {
                    iparentClock = iparentClockIter.key();
                    ++iparentClockIter ;
                }
                /*根据当前节点的时钟 获得 扫描链个数  TDI 输入*/
                QString iconstBit(tr("%1'b").arg(chainStructuremap.value(i.key())->m_untotalChainNumber));
                for(int j = 0 ;j < chainStructuremap.value(i.key())->m_untotalChainNumber ; j++)
                {
                    iconstBit.append("1");
                }
                //6、查找 右键插入链的 instance 的代码 ，根据 时钟个数 ，插入多少个 2*TDI TDO ，位宽chainStructuremap 中有多少条链的变量
                // 根据 module 里面多少个 时钟, 创建 多少个 和
                //   _EziDebug_clockname_TDI_reg
                //   _EziDebug_clockname_TDO_reg
                //   _EziDebug_TOUT_reg
                //  1、 ,\n\t._EziDebug_clockname_TDI_reg(1),\n\t_EziDebug_clockname_TDO_reg(wire_tdo 名字),\n\t_EziDebug_TOUT_reg(wire_tout名字)\n
                //  2、 , 1 , wire_tdo 名字 , wire_tout名字

                //  加入定义 线  tdo_wire 的代码  // 位宽、多少个 wire(clock 个数)
                // wire [number:0] _EziDebug_chainName_tdo_wire序号 ;\n

                itdoWireName.append(tr("_EziDebug_%1_%2_tdo_w").arg(pchain->getChainName()).arg(i.key()));
                itdoRegName.append(tr("_EziDebug_%1_%2_tdo_r").arg(pchain->getChainName()).arg(i.key()));

                if((chainStructuremap.value(i.key())->m_untotalChainNumber) > 1)
                {

                    itdoWireCode.append(tr("\n\t""wire [%1:0] %2 ;").arg(chainStructuremap.value(i.key())->m_untotalChainNumber-1).arg(itdoWireName));
                    //wire [ %1 : 0 ] _EziDebug_%2_tdo_wire%3 ;
                    iaddedCodeList.append(tr("\\b")+tr("wire\\s+\\[")+tr("\\s*%1")\
                                          .arg(chainStructuremap.value(i.key())->m_untotalChainNumber - 1)\
                                          + tr("\\s*:\\s*0\\s*\\]\\s*") + tr("%1\\s*;")\
                                          .arg(itdoWireName));

                    itdoRegCode.append(tr("\n\t""reg [%1:0] %2 %3 ;").arg(chainStructuremap.value(i.key())->m_untotalChainNumber-1).arg(itdoRegName).arg(inoSynCode));
                    iaddedCodeList.append(tr("\\breg\\s*\\[\\s*%1\\s*:\\s*0\\s*\\]\\s*%2\\s*.*;").arg(chainStructuremap.value(i.key())->m_untotalChainNumber-1).arg(itdoRegName));
                }
                else
                {
                    itdoWireCode.append(tr("\n\t""wire %1 ;").arg(itdoWireName));
                    iaddedCodeList.append(tr("\\b")+tr("wire\\s+")+tr("%1\\s*;").arg(itdoWireName));

                    itdoRegCode.append(tr("\n\t""reg %1 %2 ;").arg(itdoRegName).arg(inoSynCode));
                    iaddedCodeList.append(tr("\\breg\\s*%1\\s*.*;").arg(itdoRegName));
                }

                //iaddedCode.append(itdoWireCode);
                //iaddedCode.append(itdoRegCode);

                ianncounceCode.append(itdoWireCode);
                ianncounceCode.append(itdoRegCode);


                // tdo always 赋值语句 无复位信号

                iblockCode.append(tr("\n\n\t""always@(posedge %1)").arg(iparentClock));
                iblockCode.append(tr("\n\t\tbegin"));
                iblockCode.append(tr("\n\t\t""%1 <= %2 ;").arg(itdoRegName).arg(itdoWireName));
                iblockCode.append(tr("\n\t\t""%1 <= %2 ;").arg(itoutRegName).arg(itoutWireName));
                iblockCode.append(tr("\n\t\tend"));



                iaddedBlockCodeList.append(tr("%1\\s*<=\\s*%2\\s*;").arg(itdoRegName).arg(itdoWireName));
                iaddedCode.append(iblockCode);

                /*
                    always@(posedge clk or negedge rstn)
                        if(!rstn)
                            TOut_reg <= 1'b0;
                        else if( addr[8:0] == 9'h0 )
                            TOut_reg <= 1'b1;
                        else
                            TOut_reg <= 1'b0;
                */
                if(StardardForamt == pchainInstanceSt->m_einstanceFormat)
                {
                    QString iportName = tr(",\n\t\t""._EziDebug_%1_%2_TDI_reg(%3),\n\t\t""._EziDebug_%4_%5_TDO_reg(%6)")\
                            .arg(pchain->getChainName()).arg(i.key()).arg(iconstBit).arg(pchain->getChainName()).arg(i.key()).arg(itdoWireName);
                    iinstanceCode.append(iportName);
                    //iportName.replace("\n\t","\\s*");
                    iaddedCodeList.append(tr(",\\s*\\._EziDebug_%1_%2_TDI_reg\\s*\\(\\s*%3\\s*\\)").arg(pchain->getChainName()).arg(i.key()).arg(iconstBit));
                    iaddedCodeList.append(tr(",\\s*\\._EziDebug_%1_%2_TDO_reg\\s*\\(\\s*%3\\s*\\)").arg(pchain->getChainName()).arg(i.key()).arg(itdoWireName));
                }
                else if(NonStardardFormat == pchainInstanceSt->m_einstanceFormat)
                {
                    QString iportName = tr(", %1 , %2 ,").arg(iconstBit).arg(itdoWireName) ;

                    iinstanceCode.append(iportName);
                    //iportName.replace(" ","\\s*");
                    iaddedCodeList.append(tr(",\\s*%1").arg(iconstBit));
                    iaddedCodeList.append(tr(",\\s*%1").arg(itdoWireName));
                }
                else
                {
                    // 释放内存
                    iinstancePosMap.remove(pitem->getInstanceName());
                    delete pinstanceSt ;
                    close();
                    return 1 ;
                }
                /*构造字符串*/

                ++i ;
                num++;
            }

            ifileData.insert(pinstanceSt->m_nstartPos,ianncounceCode);
            noffSet += ianncounceCode.size() ;
            // ._EziDebug_chn_rstn(_EziDebug_chn_rstn_w)
            if(StardardForamt == pchainInstanceSt->m_einstanceFormat)
            {
                iinstanceCode.append(tr(",\n\t\t""._EziDebug_%1_rstn(%2)"",\n\t\t""._EziDebug_%3_TOUT_reg(%4)").arg(pchain->getChainName()).arg(iresetnWireName).arg(pchain->getChainName()).arg(itoutWireName)) ;

                iaddedCodeList.append(tr(",\\s*\\._EziDebug_%1_rstn\\s*\\(\\s*%2\\s*\\)").arg(pchain->getChainName()).arg(iresetnWireName));
                iaddedCodeList.append(tr(",\\s*\\._EziDebug_%1_TOUT_reg\\s*\\(\\s*%2\\s*\\)").arg(pchain->getChainName()).arg(itoutWireName));
            }
            else
            {
                iinstanceCode.append(tr(", %1 , %2").arg(iresetnWireName).arg(itoutWireName)) ;
                iaddedCodeList.append(tr(",\\s*%1\\s*,\\s*%2").arg(iresetnWireName).arg(itoutWireName));
            }

            // 所有位置偏移 iinstanceCode.size()
            ifileData.insert(pinstanceSt->m_nnextRightBracketPos + noffSet , iinstanceCode);
            noffSet += iinstanceCode.size() ;

            // 端口对应 所有寄存器 定义
            iaddedCode.append(tr("\n"));
            QVector<EziDebugModule::PortStructure*> iportVec = pmodule->getPort(iprj,pitem->getInstanceName()) ;
            QString iportRegCode ;
            QString iportRegName ;
            QStringList iportRegEvaluationStrList ;
            QStringList iportRegRevereStrList ;
            QStringList iportRegResetStrList ;
            for(int i = 0 ; i < iportVec.count() ;i++)
            {
                QString iportWireName = pparentMoudle->getInstancePortMap(pitem->getInstanceName()).value(QString::fromAscii(iportVec.at(i)->m_pPortName));
                iportRegName.clear();
                iportRegCode.clear();
                iportRegName.append(tr("_EziDebug_%1_%2_r").arg(pchain->getChainName()).arg(QString::fromAscii(iportVec.at(i)->m_pPortName)));

                if(iportVec.at(i)->m_unBitwidth == 1)
                {
                    iportRegCode.append(tr("\n\t""reg %1 %2 ;").arg(iportRegName).arg(inoSynCode));
                    iaddedCodeList.append(tr("\\breg\\s+%1\\s*.*;").arg(iportRegName));
                }
                else
                {
                    iportRegCode.append(tr("\n\t""reg [%1:%2] %3 %4 ;").arg(iportVec.at(i)->m_unStartBit).arg(iportVec.at(i)->m_unEndBit).arg(iportRegName).arg(inoSynCode));
                    iaddedCodeList.append(tr("\\breg\\s*\\[\\s*%1\\s*:\\s*%2\\s*\\]\\s*%3\\s*.*;").arg(iportVec.at(i)->m_unStartBit).arg(iportVec.at(i)->m_unEndBit).arg(iportRegName));
                }
                iportRegEvaluationStrList.append(tr("%1 <= %2 ;").arg(iportRegName).arg(iportWireName));
                iportRegRevereStrList.append(tr("%1 <= ~%2 ;").arg(iportRegName).arg(iportRegName));
                iportRegResetStrList.append(tr("%1 <= 0 ;").arg(iportRegName));
                iaddedCode.append(iportRegCode);

                if(i == 0)
                {
                    iaddedBlockCodeList.append(tr("%1\\s*<=\\s*%2\\s*;").arg(iportRegName).arg(iportWireName));
                }
            }

            iblockCode.clear() ;
            if(pchain->getscaningPortClock().isEmpty())
            {
                if(pmodule->getClockSignal().count() > 1)
                {
                    qDebug() << "Error: There is two or more Clock Signal";
                    close();
                    return 1 ;
                }

                QString iscanningClock ;
                QMap<QString,QString> iparentClockMap = pparentMoudle->getClockSignal();
                QMap<QString,QString>::const_iterator iparentClockIter = iparentClockMap.constBegin() ;
                while(iparentClockIter != iparentClockMap.constEnd())
                {
                    iscanningClock = iparentClockIter.key();
                    ++iparentClockIter ;
                }

                iblockCode.append(tr("\n\n\t""always@(posedge %1 or negedge %2)").arg(iscanningClock).arg(iresetnWireName));
                iblockCode.append(tr("\n\tbegin"));
                iblockCode.append(tr("\n\t\t""if(!%1)").arg(iresetnWireName));
                iblockCode.append(tr("\n\t\t\t""begin"));
                iblockCode.append(tr("\n\t\t\t%1").arg(iportRegRevereStrList.join("\n\t\t\t"))) ;
                iblockCode.append(tr("\n\t\t\t""end"));
                iblockCode.append(tr("\n\t\t""else"));
                iblockCode.append(tr("\n\t\t\t""begin"));
                iblockCode.append(tr("\n\t\t\t%1").arg(iportRegEvaluationStrList.join("\n\t\t\t")));
                iblockCode.append(tr("\n\t\t\t""end"));
                iblockCode.append(tr("\n\tend"));

            }
            else
            {

                iblockCode.append(tr("\n\n\t""always@(posedge %1)").arg(pchain->getscaningPortClock()));
                iblockCode.append(tr("\n\t""begin"));
                iblockCode.append(tr("\n\t\t%1").arg(iportRegEvaluationStrList.join("\n\t\t")));
                iblockCode.append(tr("\n\t""end"));

            }

            iaddedCode.append(iblockCode);


            //7、加入 将 TDO 载入 reg 的代码
            // 找到时钟对应关系 , 定义有关 tdo 需要的 wire 和 生成 相关寄存器的语句
            // 并找到clock 和 reset 信号 的 时钟沿变化关系 定义相关的寄存器
            /*
              reg ......
              always@(posedge clock or negedge restn)
                if(!restn)
                    reg_n <= 0;
                else
                    reg_n <= wire tdo;

              always@(posedge clock or negedge restn)
                if(!restn)
                    reg_n <= 0;
                else
                    reg_n <= wire tdo;
            */

            //8、加入将端口保存的代码  在加入扫描链的界面 上 提供所有端口 和 clock 的对应关系
            // 根据 端口所在时钟个数 加入  并定义相关的寄存器  reg_n
            /*always@(posedge clock or negedge restn)
              if(!restn)
                  reg_n <= 0;
              else
                  reg_n <= wire tdo;
            */


            //9、在 endmodule 位置之前插入 timer 例化的代码 ;  不进行 例化名字 的重新改写，如果重复 直接报错 ，应该概率超级小
            // itoutCore
            /*
            itoutCore itoutCore_chainName_inst(
                    .clock(慢时钟名字),
                    .reset(module中复位信号名字),
                    .Tout_reg(wire_tout名)
                    );
            */

            QString itoutInstanceCode ;
            itoutInstanceCode.append("\n\n\t");

            itoutInstanceCode.append(EziDebugScanChain::getChainToutCore());
            QString itoutInstanceName(EziDebugScanChain::getChainToutCore() + tr("_%1_inst").arg(pchain->getChainName()));

            QString ireset = "1'b0";
            QString iclock ;

            QMap<QString,QString> iparentClockMap = pparentMoudle->getClockSignal();
            QMap<QString,QString>::const_iterator iparentClockIter = iparentClockMap.constBegin() ;
            while(iparentClockIter != iparentClockMap.constEnd())
            {
                iclock = iparentClockIter.key();
                ++iparentClockIter ;
            }


            if(pchain->getSlowClock().isEmpty())
            {
                if(iclockMap.count() > 1)
                {

                    qDebug() << "Error: There is two or more Clock Signal,Please Input the Tout Clock!";
                    close();
                    return 1 ;
                }
                else
                {
                    // .rstn_out (_EziDebug_chn_rstn_w ),
                    if(iclockMap.count() == 1)
                    {

                        itoutInstanceCode.append(tr(" ")+itoutInstanceName+tr("(\n\t\t"".clock(%1),\n\t\t"".reset(%2),\n\t\t"".rstn_out(%3),\n\t\t"".TOUT_reg(%4)\n\t);")\
                                             .arg(iclock).arg(ireset).arg(iresetnWireName).arg(itoutWireName));


                    }
                    else
                    {
                        qDebug() << "Error: There is no Clock Signal In moudle:" << pitem->getModuleName();
                        close();
                        return 1 ;
                    }
                }
            }
            else
            {
                itoutInstanceCode.append(tr(" ")+itoutInstanceName+tr("(\n\t\t"".clock(%1),\n\t\t"".reset(%2),\n\t\t"".rstn_out(%3),\n\t\t"".TOUT_reg(%4)\n\t);")\
                                         .arg(pchain->getSlowClock()).arg(ireset).arg(iresetnWireName).arg(itoutWireName));
            }

            iaddedCode.append(itoutInstanceCode) ;

            ifileData.insert(imodulePos.m_nendModuleKeyWordPos + noffSet ,iaddedCode);
            /*删除代码方法 itoutCore /s+ itoutInstanceName \s+ ( 任意字符 ) /s+ ;*/
            iaddedCodeList.append(EziDebugScanChain::getChainToutCore()+tr("\\s+")+itoutInstanceName+tr("\\(")+tr(".+")+tr("\\)")+tr("\\s*;"));

        }
        else
        {
            iinstancePosMap.remove(pitem->getInstanceName());
            delete pinstanceSt ;
            close();
            return 1 ;
        }

        //10、写入文件

        pchain->addToLineCodeMap(pitem->parent()->getModuleName(),iaddedCodeList);
        pchain->addToBlockCodeMap(pitem->parent()->getModuleName(),iaddedBlockCodeList);

        if(!open(QIODevice::WriteOnly|QIODevice::Text|QIODevice::Truncate))
        {
            qDebug() << "Cannot Open file for writing:" << qPrintable(this->errorString());
            return 1 ;
        }

        QTextStream iout(this);

        iout << ifileData  ;
        close();

        ilastModifedTime = ifileInfo.lastModified() ;
        modifyStoredTime(ilastModifedTime);
        // 释放内存
        iinstancePosMap.remove(pitem->getInstanceName());
        delete pinstanceSt ;
        return 0 ;

    }
    else if(InsertUserCore == type)
    {
        int nwireCount = pmodule->getEziDebugWireCounts(pchain->getChainName()) ;
        QStringList iaddedCodeList ;
        QStringList iaddedBlockCodeList ;
        QString iparentToutPort(tr("_EziDebug_%1_TOUT_reg").arg(pchain->getChainName())) ;

        struct SEARCH_STRING_STRUCTURE iModuleKeyWordSt ;
        iModuleKeyWordSt.m_etype = SearchModuleKeyWordPos ;
        iModuleKeyWordSt.m_icontent.m_imodulest.m_eportAnnounceFormat = NonAnsicFormat ;
        // 父节点的 的 module name
        strcpy(iModuleKeyWordSt.m_icontent.m_imodulest.m_amoduleName,pitem->getModuleName().toAscii().data());
        //  module 名
        int nmoduleKeyWordStartPos = 0 ;
        /*找到  定义本 module 的开始位置  */
        if(skipCommentaryFind(ifileData,0,iModuleKeyWordSt,nmoduleKeyWordStartPos))
        {
            close();
            return 1 ;
        }

        QString imodulePortCode ;
        // 判断这个  module 在本条扫描链 中 是否 被加入过了
        // 如果加过了，则直接跳到 加自定义 core 的地方 加代码
        if(!pmodule->getAddCodeFlag())
        {
            //  根据标准或者非标准 加入 本 moudle 的 新增端口  每个clock对应的(TDI TDO) 和 TOUT
            //clockname 为 module 里面的 clock 名字
            QMap<QString,QString>::const_iterator clockMapIterator = iclockMap.constBegin();
            imodulePortCode.append("\n\t\t") ;
            while(clockMapIterator != iclockMap.constEnd())
            {
                // 根据 module 里面多少个 时钟, 创建 多少个 和
                //  [bitwidth-1:0] _EziDebug_chainname_clockname_TDI_reg or _EziDebug_chainname_clockname_TDI_reg
                //  [bitwidth-1:0] _EziDebug_chainname_clockname_TDO_reg or _EziDebug_chainname_clockname_TDO_reg
                //  _EziDebug_chainname_TOUT_reg

                //  加入定义 线  tdo_wire 的代码  // 位宽、多少个 wire(clock 个数)
                // wire _EziDebug_chainName_tdo_wire序号[number:0] ;\n

                if(AnsicFormat == iModuleKeyWordSt.m_icontent.m_imodulest.m_eportAnnounceFormat)
                {
                    if((chainStructuremap.value(clockMapIterator.key())->m_untotalChainNumber) > 1)
                    {
                        QString iportName = tr(", input [%1:0] _EziDebug_%2_%3_TDI_reg ,\n\t""output [%4:0] _EziDebug_%5_%6_TDO_reg")\
                                .arg(chainStructuremap.value(clockMapIterator.key())->m_untotalChainNumber - 1).arg(pchain->getChainName()).arg(clockMapIterator.key())\
                                .arg(chainStructuremap.value(clockMapIterator.key())->m_untotalChainNumber - 1).arg(pchain->getChainName()).arg(clockMapIterator.key());

                        imodulePortCode.append(iportName);
                        //[ %1 : 0 ] _EziDebug_%2_%3_TDI_reg
                        iaddedCodeList.append(tr(",\\s*input\\s*\\[\\s*%1\\s*:\\s*0\\s*\\]\\s+_EziDebug_%2_%3_TDI_reg").arg(chainStructuremap.value(clockMapIterator.key())->m_untotalChainNumber - 1).arg(pchain->getChainName()).arg(clockMapIterator.key()));
                        //[ %1 : 0 ] _EziDebug_%2_%3_TDO_reg
                        iaddedCodeList.append(tr(",\\s*output\\s*\\[\\s*%1\\s*:\\s*0\\s*\\]\\s+_EziDebug_%2_%3_TDO_reg").arg(chainStructuremap.value(clockMapIterator.key())->m_untotalChainNumber - 1).arg(pchain->getChainName()).arg(clockMapIterator.key()));
                    }
                    else
                    {
                        imodulePortCode.append(tr(", input _EziDebug_%1_%2_TDI_reg ,\n\t""ouput_EziDebug_%3_%4_TDO_reg ,\n\t""input_EziDebug_%5_TOUT_reg")\
                                .arg(pchain->getChainName()).arg(clockMapIterator.key()).arg(pchain->getChainName()).arg(clockMapIterator.key()).arg(pchain->getChainName()));
                        iaddedCodeList.append(tr(",\\s*_EziDebug_%1_%2_TDI_reg\\s*").arg(pchain->getChainName()).arg(clockMapIterator.key()));
                        iaddedCodeList.append(tr(",\\s*_EziDebug_%1_%2_TDO_reg\\s*").arg(pchain->getChainName()).arg(clockMapIterator.key()));
                    }
                }
                else if(NonAnsicFormat == iModuleKeyWordSt.m_icontent.m_imodulest.m_eportAnnounceFormat)
                {
                    imodulePortCode.append(tr(",\n\t_EziDebug_%1_%2_TDI_reg ,\n\t""_EziDebug_%3_%4_TDO_reg")\
                            .arg(pchain->getChainName()).arg(clockMapIterator.key()).arg(pchain->getChainName()).arg(clockMapIterator.key()));
                    iaddedCodeList.append(tr(",\\s*_EziDebug_%1_%2_TDI_reg").arg(pchain->getChainName()).arg(clockMapIterator.key()));
                    iaddedCodeList.append(tr(",\\s*_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(clockMapIterator.key()));

                }
                else
                {
                    close();
                    return 1 ;
                }
                /*构造字符串*/
                ++clockMapIterator ;
            }

            if(AnsicFormat == iModuleKeyWordSt.m_icontent.m_imodulest.m_eportAnnounceFormat)
            {
                imodulePortCode.append(tr(",\n\t""input _EziDebug_%1_rstn"",\n\t""input _EziDebug_%2_TOUT_reg").arg(pchain->getChainName()).arg(pchain->getChainName())) ;
                iaddedCodeList.append(tr(",\\s*input\\s+_EziDebug_%1_rstn").arg(pchain->getChainName()));
                iaddedCodeList.append(tr(",\\s*input\\s+_EziDebug_%2_TOUT_reg").arg(pchain->getChainName()));
            }
            else
            {
                imodulePortCode.append(tr(",\n\t_EziDebug_%1_rstn,\n\t""_EziDebug_%2_TOUT_reg").arg(pchain->getChainName()).arg(pchain->getChainName())) ;
                iaddedCodeList.append(tr(",\\s*_EziDebug_%1_rstn").arg(pchain->getChainName()));
                iaddedCodeList.append(tr(",\\s*_EziDebug_%1_TOUT_reg").arg(pchain->getChainName()));
            }

            ifileData.insert(nmoduleKeyWordStartPos,imodulePortCode);
        }

        /*1、END 插入端口声明代码*/

        struct SEARCH_MODULE_POS_STRUCTURE imodulePos ;
        strcpy(imodulePos.m_amoduleName,iModuleKeyWordSt.m_icontent.m_imodulest.m_amoduleName);

        imodulePos.m_nendModuleKeyWordPos = -1 ;
        /*根据 端口声明的方式  决定是否搜索 端口*/
        imodulePos.m_eportFormat = iModuleKeyWordSt.m_icontent.m_imodulest.m_eportAnnounceFormat ;
        imodulePos.m_nlastRegKeyWordPos = -1 ;
        imodulePos.m_nlastPortKeyWordPos = -1 ;
        imodulePos.m_nlastWireKeyWordPos = -1 ;
        imodulePos.m_nnextRightBracketPos = nmoduleKeyWordStartPos ;

        QMap<QString,SEARCH_INSTANCE_POS_STRUCTURE*> iinstancePosMap ;
        int  nnumberOfNoLibCore = 0 ;

        // 遍历 本节点下面 的所有子节点
        for(int count = 0 ; count< pitem->childCount() ;count++ )
        {
            EziDebugInstanceTreeItem* pchildItem =  pitem->child(count) ;
            EziDebugPrj *prj = const_cast<EziDebugPrj*>(EziDebugInstanceTreeItem::getProject()) ;
            EziDebugModule *pchildModule = prj->getPrjModuleMap().value(pchildItem->getModuleName()) ;
            if(!pchildModule->isLibaryCore())
            {
                struct SEARCH_INSTANCE_POS_STRUCTURE *pinstanceSt = (struct SEARCH_INSTANCE_POS_STRUCTURE *)operator new(sizeof(struct SEARCH_INSTANCE_POS_STRUCTURE)) ;
                strcpy(pinstanceSt->m_amoduleName,pchildItem->getModuleName().toAscii().data());
                strcpy(pinstanceSt->m_ainstanceName,pchildItem->getInstanceName().toAscii().data());
                pinstanceSt->m_einstanceFormat = NonStardardFormat ;
                pinstanceSt->m_nnextRightBracketPos = -1 ;
                iinstancePosMap.insert(pchildItem->getInstanceName(),pinstanceSt);
                nnumberOfNoLibCore++ ;
            }
        }

        QString ilastTdoWire ; // 保存上一个 tdo 用于 连接 两个 instance 之间 的 端口
        QString itdoWire ;
        imodulePortCode.clear();

        // 找到 lastreg 、lastwire
        if(matchingTargetString(ifileData,imodulePos,iinstancePosMap))
        {
            // 释放内存
            QMap<QString,SEARCH_INSTANCE_POS_STRUCTURE*>::iterator i = iinstancePosMap.begin();
            while(i != iinstancePosMap.end())
            {
                struct SEARCH_INSTANCE_POS_STRUCTURE *pinstanceSt = i.value();
                delete pinstanceSt ;
                ++i ;
            }
            iinstancePosMap.clear();
            close();
            return 1 ;
        }


        if(!pmodule->getAddCodeFlag())
        {
            /*根据需要来 插入 TDI、TOUT、TDO 端口定义 */
            if(NonAnsicFormat == iModuleKeyWordSt.m_icontent.m_imodulest.m_eportAnnounceFormat)
            {
                /*定义端口*/
                QMap<QString,QString>::const_iterator i = iclockMap.constBegin();
                while(i != iclockMap.constEnd())
                {
                    // 根据 module 里面多少个 时钟, 创建 多少个 和
                    //  input  [bitwidth-1:0] _EziDebug_clockname_TDI_reg ; or input _EziDebug_clockname_TDI_reg ;
                    //  output [bitwidth-1:0] _EziDebug_clockname_TDO_reg ; or output _EziDebug_clockname_TDO_reg ;
                    //  input  _EziDebug_TOUT_reg ;

                    if((chainStructuremap.value(i.key())->m_untotalChainNumber) > 1)
                    {
                        QString iportName = tr("\n\t""input [%1:0] _EziDebug_%2_%3_TDI_reg ;\n\t""output [%4:0] _EziDebug_%5_%6_TDO_reg ;")\
                                .arg(chainStructuremap.value(i.key())->m_untotalChainNumber - 1).arg(pchain->getChainName()).arg(i.key())\
                                .arg(chainStructuremap.value(i.key())->m_untotalChainNumber - 1).arg(pchain->getChainName()).arg(i.key());

                        imodulePortCode.append(iportName);
                        //input [ %1 : 0 ] _EziDebug_%2_%3_TDI_reg
                        iaddedCodeList.append(tr("\\binput\\s*\\[\\s*%1\\s*:\\s*0\\s*\\]\\s+_EziDebug_%2_%3_TDI_reg\\s*;").arg(chainStructuremap.value(i.key())->m_untotalChainNumber - 1).arg(pchain->getChainName()).arg(i.key()));
                        //output [ %1 : 0 ] _EziDebug_%2_%3_TDO_reg
                        iaddedCodeList.append(tr("\\boutput\\s*\\[\\s*%1\\s*:\\s*0\\s*\\]\\s+_EziDebug_%2_%3_TDO_reg\\s*;").arg(chainStructuremap.value(i.key())->m_untotalChainNumber - 1).arg(pchain->getChainName()).arg(i.key()));
                    }
                    else
                    {
                        QString iportName = tr("\n\t""input _EziDebug_%1_%2_TDI_reg ;\n\t""output _EziDebug_%3_%4_TDO_reg ;")\
                                .arg(pchain->getChainName()).arg(i.key())\
                                .arg(pchain->getChainName()).arg(i.key());

                        imodulePortCode.append(iportName);
                        //input _EziDebug_%1_%2_TDI_reg
                        iaddedCodeList.append(tr("\\binput\\s+_EziDebug_%1_%2_TDI_reg\\s*;").arg(pchain->getChainName()).arg(i.key()));
                        //output _EziDebug_%1_%2_TDO_reg
                        iaddedCodeList.append(tr("\\boutput\\s+_EziDebug_%1_%2_TDO_reg\\s*;").arg(pchain->getChainName()).arg(i.key()));
                    }

                    /*构造字符串*/
                    ++i ;
                }
                imodulePortCode.append(tr("\n\t""input _EziDebug_%1_TOUT_reg ;").arg(pchain->getChainName())) ;
                iaddedCodeList.append(tr("\\binput\\s+_EziDebug_%1_TOUT_reg\\s*;").arg(pchain->getChainName()));

                // _EziDebug_%1_rstn
                imodulePortCode.append(tr("\n\t""input _EziDebug_%1_rstn ;").arg(pchain->getChainName())) ;
                iaddedCodeList.append(tr("\\binput\\s+_EziDebug_%1_rstn\\s*;").arg(pchain->getChainName()));

                // 在最后一个端口声明之前加入  EziDebug 端口 TDI TDO TOUT 的声明
                ifileData.insert(imodulePos.m_nlastPortKeyWordPos ,imodulePortCode);
                noffSet += imodulePortCode.size() ;
            }

            QString itdoWireDefinitionCode ;
            QString iinstanceCode ;

            QString iclockString ;
            QString iresetString ;
            QString iresetRegStr ;
            QString ievaluateRegStr ;
            QString isysCoreCode ;
            QString iregDefinitionCode ;
            QString iinstanceExp ;

            int nnonCoreNum = 0 ;
            int nFirstnonCoreNum = 0 ;

            // 遍历 本节点下面 的所有子节点
            for(int i = 0 ; i< pitem->childCount() ;i++ )
            {
                int m = 0 ;
                EziDebugInstanceTreeItem* pchildItem =  pitem->child(i) ;
                EziDebugPrj *prj = const_cast<EziDebugPrj *>(EziDebugInstanceTreeItem::getProject()) ;
                EziDebugModule *pchildModule = prj->getPrjModuleMap().value(pchildItem->getModuleName()) ;
                QMap<QString,QString> ichildModulePortMap = pmodule->getInstancePortMap(pchildItem->getInstanceName()) ;
                itdoWireDefinitionCode.clear();
                iinstanceCode.clear();
                itdoWire.clear();
                iinstanceExp.clear();
                if(!pchildModule->isLibaryCore())
                {
                    nnonCoreNum++ ;
                    iinstanceCode.append("\n\t\t") ;
                    /*在子模块例化中添加 新增的EziDebug端口代码 需要子节点与父模块的时钟相同*/
                    QMap<QString,QString> ichildClockMap = pchildModule->getClockSignal();
                    if(!ichildClockMap.count())
                    {
                        continue ;
                    }
                    nFirstnonCoreNum++ ;
                    nwireCount++ ;
                    /*根据 非系统core 子例化 加入代码：定义 wire 的代码  用于连接 各个例化 端口、例化模块代码的 端口插入代码*/
                    struct SEARCH_INSTANCE_POS_STRUCTURE *pinstSt = iinstancePosMap.value(pchildItem->getInstanceName());

                    QMap<QString,QString>::const_iterator p = ichildClockMap.constBegin();
                    while(p != ichildClockMap.constEnd())
                    {
                        QString iparentTdiPort ;
                        QString iparentTdoPort ;

                        QString iparentClock = pitem->getModuleClockMap(pchildItem->getInstanceName()).key(p.key(),QString()) ;
                        if(iparentClock.isEmpty())
                        {
                            // 释放内存
                            QMap<QString,SEARCH_INSTANCE_POS_STRUCTURE*>::iterator i = iinstancePosMap.begin();
                            while(i != iinstancePosMap.end())
                            {
                                struct SEARCH_INSTANCE_POS_STRUCTURE *pinstanceSt = i.value();
                                delete pinstanceSt ;
                                ++i ;
                            }
                            iinstancePosMap.clear();
                            close();
                            return 1 ;
                        }
                        else
                        {
                            iparentTdiPort.append(tr("_EziDebug_%1_%2_TDI_reg").arg(pchain->getChainName()).arg(iparentClock));
                            iparentTdoPort.append(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iparentClock));
                        }

                        // 定义用于连接  例化新增端口的 wire
                        if((chainStructuremap.value(iparentClock)->m_untotalChainNumber) > 1)
                        {
                            /*1、加入 定义 wire TDO 根据不同的 clock 定义的代码*/
                            itdoWireDefinitionCode.append(tr("\n\t""wire [%1:0] _EziDebug_%2_%3_tdo%4 ;").arg(chainStructuremap.value(iparentClock)->m_untotalChainNumber-1).arg(pchain->getChainName()).arg(iparentClock).arg(nwireCount));
                            itdoWire.append(tr("_EziDebug_%1_%2_tdo%3").arg(pchain->getChainName()).arg(iparentClock).arg(nwireCount));
                            iaddedCodeList.append(tr("\\bwire\\s*") + tr("\\[\\s*%1\\s*:\\s*0\\s*\\]\\s*").arg(chainStructuremap.value(iparentClock)->m_untotalChainNumber-1) +tr("_EziDebug_%1_%2_tdo%3\\s*;").arg(pchain->getChainName()).arg(iparentClock).arg(nwireCount));
                        }
                        else
                        {
                            /*1、加入 定义 wire TDO 根据不同的 clock 定义的代码*/
                            itdoWireDefinitionCode.append(tr("\n\t""wire _EziDebug_%1_%2_tdo%3 ;").arg(pchain->getChainName()).arg(iparentClock).arg(nwireCount));
                            itdoWire.append(tr("_EziDebug_%1_%2_tdo%3").arg(pchain->getChainName()).arg(iparentClock).arg(nwireCount));
                            iaddedCodeList.append(tr("\\bwire\\s+") +tr("_EziDebug_%1_%2_tdo%3\\s*;").arg(pchain->getChainName()).arg(iparentClock).arg(nwireCount));
                        }

                        // 根据例化 书写格式  填入新增端口以及端口连接代码
                        if(StardardForamt == pinstSt->m_einstanceFormat)
                        {

                            /*判断 时钟 是否  对应  找到 并将 module 的 clock 的那个 TDI 与 端口 相连 */
                            // 第一个 instance 的 tdi 与 module 对应 clock 的 tdi 相连 , tdo 与 下一个 instance 相连 或者  本module 自定义的  core 相连
                            if(1 == nFirstnonCoreNum)
                            {
                                /*非最后1个 no libcore instance*/
                                // 第一个 instance 的 tdi 与 module 对应 clock 的 tdi 相连 , tdo 与 下一个 instance
                                QString iportName = tr(" ,\n\t""._EziDebug_%1_%2_TDI_reg(%3) ,\n\t""._EziDebug_%4_%5_TDO_reg(%6)")\
                                        .arg(pchain->getChainName()).arg(p.key()).arg(iparentTdiPort).arg(pchain->getChainName()).arg(p.key()).arg(itdoWire);
                                iinstanceCode.append(iportName);


                                iinstanceExp.append(tr("\\s*,\\s*._EziDebug_%1_%2_TDI_reg\\s*\\(\\s*%3\\s*\\)").arg(pchain->getChainName()).arg(p.key()).arg(iparentTdiPort));
                                iinstanceExp.append(tr("\\s*,\\s*._EziDebug_%1_%2_TDO_reg\\s*\\(\\s*%3\\s*\\)").arg(pchain->getChainName()).arg(p.key()).arg(itdoWire));
                            }
                            else
                            {
                                //第一个 instance 的 tdi 与 module 对应 clock 的 tdi 相连,本module 自定义的  core 相连
                                // 其余的 instance 的 tdi 与 上一个 instance 的 tdo 相连 , tdo 与 下一个  instacne 相连 或者 本 module  自定义的 core 相连
                                QString iportName = tr(" ,\n\t""._EziDebug_%1_%2_TDI_reg(%3) ,\n\t""._EziDebug_%4_%5_TDO_reg(%6)")\
                                        .arg(pchain->getChainName()).arg(p.key()).arg(ilastTdoWire).arg(pchain->getChainName()).arg(p.key()).arg(itdoWire);
                                iinstanceCode.append(iportName);

                                // TDI 和  上一个  例化的
                                iinstanceExp.append(tr("\\s*,\\s*._EziDebug_%1_%2_TDI_reg\\s*\\(\\s*%3\\s*\\)").arg(pchain->getChainName()).arg(p.key()).arg(ilastTdoWire));
                                iinstanceExp.append(tr("\\s*,\\s*._EziDebug_%1_%2_TDO_reg\\s*\\(\\s*%3\\s*\\)").arg(pchain->getChainName()).arg(p.key()).arg(itdoWire));

                            }

                        }
                        else if(NonStardardFormat == pinstSt->m_einstanceFormat)
                        {

                            // 第一个 instance 的 tdi 与 module 对应 clock 的 tdi 相连 , tdo 与 下一个 instance 相连 或者  本module 自定义的  core 相连
                            // 其余的 instance 的 tdi 与 上一个 instance 的 tdo 相连 , tdo 与 下一个  instacne 相连 或者 本 module  自定义的 core 相连
                            if(1 == nFirstnonCoreNum) // 原来 为 i ,本意为 第一个 非系统例化 i = 0 只能保证是第一个 例化(有可能为 第一个 为 系统例化  第二个为  非系统例化 但 第二个 的 tdi 需要 与 端口 tdi 相连)
                            {
                                QString iportName = tr(" , %1 , %2 ").arg(iparentTdiPort).arg(itdoWire) ;
                                iinstanceCode.append(iportName);
                                iportName.replace(" ","\\s*");
                                iinstanceExp.append(iportName);
                            }
                            else
                            {
                                QString iportName = tr(" , %1 , %2 ").arg(ilastTdoWire).arg(itdoWire) ;
                                iinstanceCode.append(iportName);
                                iportName.replace(" ","\\s*");
                                iinstanceExp.append(iportName);
                            }
                        }
                        else
                        {
                            // 释放内存
                            QMap<QString,SEARCH_INSTANCE_POS_STRUCTURE*>::iterator i = iinstancePosMap.begin();
                            while(i != iinstancePosMap.end())
                            {
                                struct SEARCH_INSTANCE_POS_STRUCTURE *pinstanceSt = i.value();
                                iinstancePosMap.remove(i.key());
                                delete pinstanceSt ;
                            }
                            close();
                            return 1 ;
                        }

                        /*当到了最后1个非系统例化时  保存当前的的最后 1 根 tdo wire ,它需要与后面添加 EziDebug 自定义例化的 tdi相连 */
                        if(nnonCoreNum == nnumberOfNoLibCore)
                        {
                            /*保存最后的 clock 与 wire名称 的对应关系*/
                            pmodule->AddToClockWireNameMap(pchain->getChainName(),iparentClock,itdoWire);
                        }

                        ++p ;
                        //num++;
                    }

                    if(StardardForamt == pinstSt->m_einstanceFormat)
                    {
                        iinstanceCode.append(tr(",\n\t""._EziDebug_%1_rstn(_EziDebug_%2_rstn)").arg(pchain->getChainName()).arg(pchain->getChainName())) ;
                        iinstanceExp.append(tr("\\s*,\\s*._EziDebug_%1_rstn\\s*\\(\\s*_EziDebug_%2_rstn\\s*\\)").arg(pchain->getChainName()).arg(pchain->getChainName()));

                        iinstanceCode.append(tr(",\n\t""._EziDebug_%1_TOUT_reg(%2)").arg(pchain->getChainName()).arg(iparentToutPort)) ;
                        iinstanceExp.append(tr("\\s*,\\s*._EziDebug_%1_TOUT_reg\\s*\\(\\s*%2\\s*\\)").arg(pchain->getChainName()).arg(iparentToutPort));
                    }
                    else
                    {
                        QString iportName = tr(", _EziDebug_%1_rstn , %2").arg(pchain->getChainName()).arg(iparentToutPort) ;
                        iinstanceCode.append(iportName) ;
                        iinstanceExp.append(tr("\\s*,\\s*_EziDebug_%1_rstn\\s*,\\s*%2").arg(pchain->getChainName()).arg(iparentToutPort));
                    }


                    iaddedCodeList.append(iinstanceExp);

                    ifileData.insert(pinstSt->m_nstartPos + noffSet,itdoWireDefinitionCode);
                    noffSet += itdoWireDefinitionCode.size() ;
                    ifileData.insert(pinstSt->m_nnextRightBracketPos + noffSet,iinstanceCode);
                    noffSet += iinstanceCode.size() ;


                    /*保存最后一根 Tdo 的 线 名称 */


                    // 记录上一次的一根线的名字,用于下一次的连接
                    ilastTdoWire = itdoWire ;
                }
                else
                {
                    QMap<QString,QString> iinstancePortMap = pmodule->getInstancePortMap(pchildItem->getInstanceName());

                    /*根据 系统core 子例化  加入代码：定义 寄存器 reg_n 代码、将输出端口信号载入寄存器代码  */
                    /*从module 中 获得 所有的 输出端口(位宽、大小端) 及其 时钟名 、时钟跳变方向、*/
                    QVector<EziDebugModule::PortStructure*> iportVec =  pchildModule->getPort(iprj,pchildItem->getInstanceName());
                    int nportCount = 0 ;
                    for(; nportCount < iportVec.count() ; nportCount++)
                    {
                        if((EziDebugModule::directionTypeOutput == iportVec.at(nportCount)->eDirectionType)||(EziDebugModule::directionTypeInoutput == iportVec.at(nportCount)->eDirectionType))
                        {
#if 0
                            QString iportName = iinstancePortMap.value(QString::fromAscii(iportVec.at(nportCount)->m_pPortName),QString());
                            if(iportName.isEmpty())
                            {
                                // 释放内存
                                QMap<QString,SEARCH_INSTANCE_POS_STRUCTURE*>::iterator j = iinstancePosMap.begin();
                                while(j != iinstancePosMap.end())
                                {
                                    struct SEARCH_INSTANCE_POS_STRUCTURE *pinstanceSt = j.value();
                                    iinstancePosMap.remove(j.key());
                                    delete pinstanceSt ;
                                }
                                goto ErrorHandle ;
                            }
#else
                            QString iportName = QString::fromAscii(iportVec.at(nportCount)->m_pPortName)   ;
                            QString icomPortName = pchildItem->getItemHierarchyName() + iportName ;
#endif

                            if(iportVec.at(nportCount)->m_unBitwidth > 1)
                            {
                                iregDefinitionCode.append(tr("\n\t""reg [%1:%2] _EziDebug_%3_%4_r %5 ;").arg(iportVec.at(nportCount)->m_unStartBit).arg(iportVec.at(nportCount)->m_unEndBit).arg(pchain->getChainName()).arg(QString::fromAscii(iportVec.at(nportCount)->m_pPortName)).arg(inoSynCode));
                                //isysCoreCode.append(iregDefinitionCode);
                                iaddedCodeList.append(tr("\\breg\\s*\\[\\s*%1\\s*:\\s*%2\\s*\\]\\s*_EziDebug_%3_%4_r.+;").arg(iportVec.at(nportCount)->m_unStartBit).arg(iportVec.at(nportCount)->m_unEndBit).arg(pchain->getChainName()).arg(QString::fromAscii(iportVec.at(nportCount)->m_pPortName)));
                            }
                            else
                            {
                                iregDefinitionCode.append(tr("\n\t""reg _EziDebug_%1_%2_r %3 ;").arg(pchain->getChainName()).arg(QString::fromAscii(iportVec.at(nportCount)->m_pPortName)).arg(inoSynCode));
                                //isysCoreCode.append(iregDefinitionCode);
                                iaddedCodeList.append(tr("\\breg\\s+_EziDebug_%1_%2_r\\s*.+;").arg(pchain->getChainName()).arg(QString::fromAscii(iportVec.at(nportCount)->m_pPortName)));
                            }


                            QString iregName(tr("_EziDebug_%1_%2_r").arg(pchain->getChainName()).arg(QString::fromAscii(iportVec.at(nportCount)->m_pPortName))) ;


                            QString iregWireName = ichildModulePortMap.value(QString::fromAscii(iportVec.at(nportCount)->m_pPortName),QString());

                            //qDebug() << "EziDebug info:sys core wire name:" << iregWireName ;
                            if((iregWireName.isEmpty()|(QRegExp(tr("^\\d+$")).exactMatch(iregWireName.toLower()))\
                                |(QRegExp(tr("^\\d+'[bhd][\\da-f]+$")).exactMatch(iregWireName.toLower()))\
                                |(QRegExp(tr("^`[ho][\\da-f]+$")).exactMatch(iregWireName.toLower()))
                                |(iregWireName.toLower()== "null")))
                            {
                                continue ;
                            }

                            QStringList iportList ;
                            iportList << pitem->getItemHierarchyName() << icomPortName  << iregName << QString::number(iportVec.at(nportCount)->m_unBitwidth)  ;

                            pchain->addToSyscoreOutputPortList(iportList.join(tr("#")));


                            //iresetRegStr.append(tr("\n\t\t%1 <= 0 ;").arg(iregName));
                            iresetRegStr.clear();
                            ievaluateRegStr.append(tr("\n\t\t%1 <= %2 ;").arg(iregName).arg(iregWireName));


                            if(m == 0)
                            {
                                iaddedBlockCodeList.append(tr("%1\\s*<=\\s*%2\\s*;").arg(iregName).arg(iregWireName));
                            }
                            m++ ;

                        }
                    }
                }
            }

            if(!ievaluateRegStr.isEmpty())
            {
                isysCoreCode.append(iregDefinitionCode);
                /*统一加入 寄存器 载入 代码块*/

                /*根据 pchain 中保存的  clock list 找到 与扫描端口的时钟 对应的本模块的时钟 */
                if(iclockMap.count() == 1)
                {
                    QMap<QString,QString>::const_iterator iclockIterator = iclockMap.constBegin();
                    while(iclockIterator != iclockMap.constEnd())
                    {
                        iclockString.append(tr("%1 %2").arg(QObject::tr("posedge")).arg(iclockIterator.key()));
                        ++iclockIterator ;
                    }
                }
                else
                {
                    close();
                    return 1 ;
                }

                QString iprocessCode ;

                iprocessCode.append((tr("\n\n\t""always@(%1)").arg(iclockString)));
                iprocessCode.append(tr("\n\t""begin"));
                iprocessCode.append(tr("%1").arg(ievaluateRegStr));
                iprocessCode.append(tr("\n\t""end"));


                /*保存删除代码信息*/
                isysCoreCode.append(iprocessCode);
            }
            /*写入文件*/
            ifileData.insert(imodulePos.m_nendModuleKeyWordPos + noffSet ,isysCoreCode);
            noffSet += isysCoreCode.size() ;
        }


        // 释放内存
        QMap<QString,SEARCH_INSTANCE_POS_STRUCTURE*>::iterator iinstanceIter = iinstancePosMap.begin();
        while(iinstanceIter != iinstancePosMap.end())
        {
            struct SEARCH_INSTANCE_POS_STRUCTURE *pinstanceSt = iinstanceIter.value();
            delete pinstanceSt ;
            ++iinstanceIter;
        }
        iinstancePosMap.clear();

#if 0
        if(fileName().endsWith("ifft.v"))
        {
            qDebug("add chain in ifft.v");
        }
#endif
        int nwireShiftRegNum = 0 ;
        int nlastChainStartNum = 0 ;
        int nlastChainEndNum = 0 ;
        int nchainStartNum = 0 ;
        int nchainEndNum = 0 ;
        int nusedNum = 0  ;
        QVector<EziDebugModule::RegStructure*> sregVec ;
        QVector<EziDebugModule::RegStructure*> vregVec ;
        QString ilastInput ;

        QString iusrCoreCode ;

        // 遍历所有时钟 去添加相应时钟的扫描链
        QMap<QString,QString>::const_iterator iclockIterator = iclockMap.constBegin();
        while(iclockIterator != iclockMap.constEnd())
        {
            EziDebugInstanceTreeItem::SCAN_CHAIN_STRUCTURE* pchainSt = chainStructuremap.value(iclockIterator.key()) ;

            int nSregNum = 0 ;
            int nVregNum = 0 ;

            // 已经添加的 EziDebug core 的个数
            int ninstNum = pmodule->getEziDebugCoreCounts(pchain->getChainName()) ;
            int nleftRegNum = 0 ;
            int nregBitCount = 0 ;
            int nleftBit = -1 ;
            int nlastStopNum =  0 ;
            int nRegNum = 0 ;
            bool isNeedAdded = false ;
            ilastInput.clear();

            if(!pmodule->getAllRegMap(iclockIterator.key(),sregVec,vregVec))
            {
                qDebug() << "EeziDebug Error: Insert Chain Error!";
                return 1 ;
            }

            // 没有寄存器 直接看 next clock 是否有 reg
            if((!sregVec.count())&&(!vregVec.count()))
            {
                // 不用加任何代码 ，不用记录当前的 链号
                ++iclockIterator ;
                continue ;
            }

            // 计算固定位宽所有寄存器的bit总合
            int nregCount = 0 ;

            if(pchainSt->m_unleftRegNumber == 0)
            {
               pchainSt->m_unleftRegNumber =  iprj->getMaxRegNumPerChain() ;
               pchainSt->m_uncurrentChainNumber++ ;
            }

            // 起始bit位
            nchainStartNum = pchainSt->m_uncurrentChainNumber ;

            // 获取 module在 chainxxx 的 加链情况 占用了 从 nlastChainStartNum 到 nlastChainEndNum 的链
            pmodule->getBitRangeInChain(pchain->getChainName(),iclockIterator.key(),&nlastChainStartNum ,&nlastChainEndNum);


            /*
                 判断当前module是否单独例化（只有静态寄存器）
                 YES
                 {
                    判断剩余的扫描链个数 是否够用，够用则在旧的扫描链上继续添加，
                    不够则新创建一条扫描链继续添加
                   （不够再添加新的扫描链 ，至到结束为止）（计算最后剩余的寄存器个数）
                 }
                 NO (可能同时存在 静态与动态的寄存器 添加方法是 先添加静态的寄存器 再添加动态的寄存器)
                 {
                    原则：由于多次例化，寄存器不能因为链的变化 在不同的例化中 放在了不同的链里面
                        if(静态+动态 < 剩余寄存器链个数)
                        {
                            if(这次添加扫描链时和上一次的链相同 )
                            {
                               则只记录寄存器位置信息 不添加任何
                            }
                            // 所有的里面放  计算剩余的 扫描链寄存器个数
                        }
                        else
                        {
                            // 从新的扫描链 开始添加
                        }
                 }
                 // 最终目的是保证代码的唯一性
            */
            if(!pmodule->getConstInstacedTimesPerChain(pchain->getChainName()))
            {
                qDebug() << "EziDebug Error: the module instance times error!";
                return 1 ;
            }

            if(pmodule->getConstInstacedTimesPerChain(pchain->getChainName()) == 1)
            {
AddReg:
                // 只存在静态的寄存器
                /*移位寄存器 赋值 代码*/
                QStringList iregNameList ;
                QVector<EziDebugModule::RegStructure*> iregVec = sregVec ;
                QStringList iregCombinationCode ;


                if(nleftBit != -1)
                {
                    int nlastLeftRegNum = qAbs(iregVec.at(nleftRegNum)->m_unEndBit - nleftBit) + 1 ;

                    QVector<EziDebugModule::RegStructure*> iregVec =  sregVec ;
                    // 剩余的个数
                    if(nlastLeftRegNum >= iprj->getMaxRegNumPerChain())
                    {
                        while(nlastLeftRegNum >= iprj->getMaxRegNumPerChain())
                        {

                            ninstNum++ ;
                            nwireCount++ ;
                            iregCombinationCode.clear();
                            iregNameList.clear();

                            // 定义 wire 连接 tdo 代码
                            QString iwireTdoName(tr("_EziDebug_%1_%2_tdo%3").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireCount));
                            QString iwireTdoDefinitionCode(tr("\n\n\t""wire ")+ iwireTdoName + tr(" ;")) ;
                            iusrCoreCode.append(iwireTdoDefinitionCode);
                            iaddedCodeList.append(tr("\\bwire\\s+_EziDebug_%1_%2_tdo%3\\s*;")\
                                                  .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireCount));

                            // 定义 wire 连接 移位寄存器 代码
                            QString iwireShiftRegDefinitionCode(tr("\n\t""wire ") + tr("[%1:0]").arg(iprj->getMaxRegNumPerChain()-1)+ tr("_EziDebug_%1_%2_sr%3")\
                                                                .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(ninstNum) + tr(" ;"));
                            QString iwireSrName(tr("_EziDebug_%1_%2_sr%3").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(ninstNum)) ;

                            iaddedCodeList.append(tr("\\bwire\\s*\\[\\s*%1:\\s*0\\s*\\]\\s*").arg(iprj->getMaxRegNumPerChain()-1)+tr("_EziDebug_%1_%2_sr%3\\s*;")\
                                                  .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(ninstNum));

                            iusrCoreCode.append(iwireShiftRegDefinitionCode);
                            nwireShiftRegNum++ ;

                            /*移位寄存器 赋值 代码*/
                            // int nendBit = nleftBit + iprj->getMaxRegNumPerChain() -1;
                            int nendBit = 0 ;
                            if(iregVec.at(nleftRegNum)->m_unRegNum > 1)
                            {
                                if(iregVec.at(nleftRegNum)->m_eRegNumEndian == EziDebugModule::endianBig)
                                {
                                    /*高:低*/
                                    // iregVec.at(nleftRegNum)->m_unBitWidth-1
                                    nendBit = nleftBit + 1 - iprj->getMaxRegNumPerChain() ;
                                    iregNameList << constructChainRegString(iregVec.at(nleftRegNum) , nlastStopNum , nleftBit , nendBit , pitem);

                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum - nlastStopNum)+tr("[%1:%2]").arg(nleftBit).arg(nendBit));

                                    nleftBit = nendBit - 1 ;
                                }
                                else
                                {
                                    /*低:高*/
                                    nendBit = nleftBit -1 + iprj->getMaxRegNumPerChain() ;
                                    iregNameList << constructChainRegString(iregVec.at(nleftRegNum) , nlastStopNum , nleftBit , nendBit , pitem);

                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum + nlastStopNum)+tr("[%1:%2]").arg(nleftBit).arg(nendBit));

                                    nleftBit = nendBit + 1 ;
                                }
                            }
                            else
                            {
                                if(iregVec.at(nleftRegNum)->m_eRegNumEndian == EziDebugModule::endianBig)
                                {
                                    /*高:低*/
                                    nendBit = nleftBit + 1 - iprj->getMaxRegNumPerChain() ;
                                    iregNameList << constructChainRegString(iregVec.at(nleftRegNum) , nlastStopNum , nleftBit , nendBit , pitem);

                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1:%2]") \
                                                               .arg(nleftBit).arg(nendBit));
                                    nleftBit = nendBit - 1 ;
                                }
                                else
                                {
                                    /*低:高*/
                                    nendBit = nleftBit -1 + iprj->getMaxRegNumPerChain() ;
                                    iregNameList << constructChainRegString(iregVec.at(nleftRegNum) , nlastStopNum , nleftBit , nendBit , pitem);

                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1:%2]")\
                                                               .arg(nleftBit).arg(nendBit));

                                    nleftBit = nendBit + 1 ;
                                }
                            }


                            ichainClock = pchain->getChainClock(pitem->getInstanceName(),iclockIterator.key());
                            if(ichainClock.isEmpty())
                            {
                                qDebug() << "EziDebug Error: the top clock is not finded!" << __LINE__;
                                return 2 ;
                            }

                            pchain->addToRegChain(ichainClock ,pchainSt->m_uncurrentChainNumber ,iregNameList);

                            // 插入扫描链代码
                            QString iwireShiftRegEvaluateString ;
                            iwireShiftRegEvaluateString.append(tr("\n\t""assign %1 = {\n\t\t\t\t\t\t\t\t\t""%2""\n\t\t\t\t\t\t\t\t\t};").arg(iwireSrName).arg(iregCombinationCode.join(" ,\n\t\t\t\t\t\t\t\t\t")));
                            iaddedCodeList.append(tr("\\bassign\\s+%1.*;").arg(iwireSrName));
                            iusrCoreCode.append(iwireShiftRegEvaluateString);

                            /*自定义 core 例化代码 */
                            QString iusrCoreDefinitionCode ;
                            // QString iresetName = "1'b1";
                            // _EziDebug_chn_rstn
                            QString iresetName = tr("_EziDebug_%1_rstn").arg(pchain->getChainName());
                            QString iusrCoreTdi ;
                            if(nnumberOfNoLibCore != 0)
                            {
                                if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                                {
                                    iusrCoreTdi.append(tr("%1[%2]").arg(pmodule->getChainClockWireNameMap(pchain->getChainName(),iclockIterator.key())).arg(pchainSt->m_uncurrentChainNumber));
                                }
                                else
                                {
                                    iusrCoreTdi.append(tr("%1").arg(pmodule->getChainClockWireNameMap(pchain->getChainName(),iclockIterator.key())));
                                }
                            }
                            else
                            {
                                if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                                {
                                    iusrCoreTdi.append(tr("_EziDebug_%1_%2_TDI_reg[%3]").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(pchainSt->m_uncurrentChainNumber));
                                }
                                else
                                {
                                    iusrCoreTdi.append(tr("_EziDebug_%1_%2_TDI_reg").arg(pchain->getChainName()).arg(iclockIterator.key()));
                                }
                            }

                            iusrCoreDefinitionCode.append(tr("\n\t")+ EziDebugScanChain::getChainRegCore() + tr(" %1_%2_inst%3(\n").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));
                            iusrCoreDefinitionCode.append(  tr("\t"".clock""\t(%1) ,\n").arg(iclockIterator.key()) \
                                                            + tr("\t"".resetn""\t(%1) ,\n").arg(iresetName) \
                                                            + tr("\t"".TDI_reg""\t(%1) ,\n").arg(iusrCoreTdi) \
                                                            + tr("\t"".TDO_reg""\t(%1) ,\n").arg(iwireTdoName) \
                                                            + tr("\t"".TOUT_reg""\t(%1) ,\n").arg(iparentToutPort) \
                                                            + tr("\t"".shift_reg""\t(%1) \n\t) ;").arg(iwireSrName));

                            /*加入 定义 userCore regWidth 限定的 语句代码*/
                            QString iparameterDefCode ;
                            iparameterDefCode.append(tr("\n\t""defparam %1_%2_inst%3.shift_width = %4 ;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum).arg(iprj->getMaxRegNumPerChain()));
                            iaddedCodeList.append(tr("\\bdefparam\\s+%1_%2_inst%3\\.shift_width\\s*=.*;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));
                            iusrCoreCode.append(iparameterDefCode)  ;

                            iaddedCodeList.append(EziDebugScanChain::getChainRegCore() + tr("\\s+%1_%2_inst%3\\s*\\(.*\\)\\s*;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));

                            iusrCoreCode.append(iusrCoreDefinitionCode);


                            /*module 端口连接代码*/

                            QString iportConnectCode ;
                            // condition (chain number > 1) is true
                            iportConnectCode.append(tr("\n\t""assign %1[%2] = %3 ;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                    .arg(pchainSt->m_uncurrentChainNumber).arg(iwireTdoName));
                            iaddedCodeList.append(tr("\\bassign\\s+%1\\s*\\[\\s*%2\\s*\\].*;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                  .arg(pchainSt->m_uncurrentChainNumber));
                            iusrCoreCode.append(iportConnectCode);


                            nlastLeftRegNum = nlastLeftRegNum - iprj->getMaxRegNumPerChain();
                            pchainSt->m_uncurrentChainNumber++ ;
                            pchainSt->m_unleftRegNumber = iprj->getMaxRegNumPerChain() ;
                        }
                    } // REG n 大于 maxregnum 的部分 添加完毕

                    //  REG n 剩余 的部分
                    iregCombinationCode.clear();
                    iregNameList.clear();

                    if(iregVec.at(nleftRegNum)->m_eRegBitWidthEndian == EziDebugModule::endianBig)
                    {
                        if((nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) > 0)
                        {
                            pchainSt->m_unleftRegNumber -= (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                            nregBitCount = (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                            iregNameList << constructChainRegString(iregVec.at(nleftRegNum),nlastStopNum,nleftBit,iregVec.at(nleftRegNum)->m_unEndBit ,pitem);

                            iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName) + QObject::tr("[%1][%2:%3]").arg(iregVec.at(nleftRegNum)->m_unStartNum - nlastStopNum).arg(nleftBit).arg(iregVec.at(nleftRegNum)->m_unEndBit));
                        }
                        else if((nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) == 0)
                        {
                            pchainSt->m_unleftRegNumber -= (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                            nregBitCount = (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                            iregNameList << constructChainRegString(iregVec.at(nleftRegNum),nlastStopNum,nleftBit,iregVec.at(nleftRegNum)->m_unEndBit ,pitem);

                            iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+QObject::tr("[%1][0]").arg(iregVec.at(nleftRegNum)->m_unStartNum - nlastStopNum));
                        }
                        else
                        {
                            // 上面已经加完了
                        }

                    }
                    else
                    {
                        if((iregVec.at(nleftRegNum)->m_unEndBit - nleftBit) > 0) // 剩大于1bit
                        {
                            pchainSt->m_unleftRegNumber -= (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                            nregBitCount = (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                            iregNameList << constructChainRegString(iregVec.at(nleftRegNum),nlastStopNum,nleftBit,iregVec.at(nleftRegNum)->m_unEndBit ,pitem);

                            iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName) + QObject::tr("[%1][%2:%3]").arg(iregVec.at(nleftRegNum)->m_unStartNum + nlastStopNum).arg(nleftBit).arg(iregVec.at(nleftRegNum)->m_unEndBit));
                        }
                        else if((iregVec.at(nleftRegNum)->m_unEndBit - nleftBit) == 0) // 剩1bit
                        {
                            pchainSt->m_unleftRegNumber -= (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                            nregBitCount = (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                            iregNameList << constructChainRegString(iregVec.at(nleftRegNum),nlastStopNum,nleftBit,iregVec.at(nleftRegNum)->m_unEndBit ,pitem);

                            iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1][0]").arg(iregVec.at(nleftRegNum)->m_unStartNum + nlastStopNum));
                        }
                        else
                        {
                            // 已经加完
                        }
                    }



                    if(iregVec.at(nleftRegNum)->m_unRegNum > 1)
                    {
                        nlastStopNum++ ;
                    }
                    else
                    {
                        nleftRegNum++ ;
                        nlastStopNum = 0 ;
                    }

                    nleftBit = -1 ;
                }
                else
                {
                    nregBitCount = 0 ;
                }


                for(; nleftRegNum < iregVec.count() ; nleftRegNum++)
                {
                    for(int m = nlastStopNum ; m < iregVec.at(nleftRegNum)->m_unRegNum; m++)
                    {
                        nregBitCount += iregVec.at(nleftRegNum)->m_unRegBitWidth ;

                        if(nregBitCount < pchainSt->m_unleftRegNumber)
                        {
                            /*数组情况下*/
                            // 够用继续添加
                            if(iregVec.at(nleftRegNum)->m_unRegNum > 1)
                            {
                                if(iregVec.at(nleftRegNum)->m_eRegNumEndian == EziDebugModule::endianBig)
                                {
                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum - m));
                                }
                                else
                                {
                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum + m));
                                }
                            }
                            else
                            {
                                iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName));
                            }

                            iregNameList << constructChainRegString(iregVec.at(nleftRegNum),m,iregVec.at(nleftRegNum)->m_unStartBit,iregVec.at(nleftRegNum)->m_unEndBit ,pitem);
                        }
                        else if(nregBitCount == pchainSt->m_unleftRegNumber)
                        {
                            // 刚好满  跳出  下次新的扫描链继续 添加
                            if(iregVec.at(nleftRegNum)->m_unRegNum > 1)
                            {
                                if(iregVec.at(nleftRegNum)->m_eRegNumEndian == EziDebugModule::endianBig)
                                {
                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum - m));
                                }
                                else
                                {
                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum + m));
                                }
                            }
                            else
                            {
                                iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName));
                            }

                            iregNameList << constructChainRegString(iregVec.at(nleftRegNum),m,iregVec.at(nleftRegNum)->m_unStartBit,iregVec.at(nleftRegNum)->m_unEndBit,pitem);

                            nlastStopNum = m ;
                            // nleftBit = -1 ;
                            nleftRegNum++ ;
                            isNeedAdded = true ;


                            goto WireShiftRegEvaluate0 ;
                        }
                        else
                        {
                            if(iregVec.at(nleftRegNum)->m_unRegNum > 1)
                            {

                                if(iregVec.at(nleftRegNum)->m_eRegNumEndian == EziDebugModule::endianBig)
                                {
                                    int nstartBit = iregVec.at(nleftRegNum)->m_unStartBit ;
                                    int nendBit = nregBitCount- pchainSt->m_unleftRegNumber + iregVec.at(nleftRegNum)->m_unStartBit + 1 - iregVec.at(nleftRegNum)->m_unRegBitWidth ;
                                    nleftBit = nendBit - 1 ;
                                    iregNameList << constructChainRegString(iregVec.at(nleftRegNum),m,nstartBit,nendBit,pitem);

                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum - m)+tr("[%1:%2]").arg(nstartBit).arg(nendBit));
                                }
                                else
                                {
                                    int nstartBit = iregVec.at(nleftRegNum)->m_unStartBit ;
                                    int nendBit = iregVec.at(nleftRegNum)->m_unRegBitWidth + iregVec.at(nleftRegNum)->m_unStartBit - 1 - (nregBitCount- pchainSt->m_unleftRegNumber) ;
                                    nleftBit = nendBit + 1 ;
                                    iregNameList << constructChainRegString(iregVec.at(nleftRegNum),m,nstartBit,nendBit,pitem);

                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum + m)+tr("[%1:%2]").arg(nstartBit).arg(nendBit));
                                }
                            }
                            else
                            {
                                if(iregVec.at(nleftRegNum)->m_eRegNumEndian == EziDebugModule::endianBig)
                                {
                                    int nstartBit = iregVec.at(nleftRegNum)->m_unStartBit ;
                                    int nendBit = nregBitCount- pchainSt->m_unleftRegNumber + iregVec.at(nleftRegNum)->m_unStartBit + 1 - iregVec.at(nleftRegNum)->m_unRegBitWidth ;
                                    nleftBit = nendBit - 1 ;
                                    iregNameList << constructChainRegString(iregVec.at(nleftRegNum),m,nstartBit,nendBit,pitem);

                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1:%2]") \
                                                               .arg(nstartBit).arg(nendBit));
                                }
                                else
                                {
                                    int nstartBit = iregVec.at(nleftRegNum)->m_unStartBit ;
                                    int nendBit = iregVec.at(nleftRegNum)->m_unRegBitWidth + iregVec.at(nleftRegNum)->m_unStartBit - 1 - (nregBitCount- pchainSt->m_unleftRegNumber) ;
                                    nleftBit = nendBit + 1 ;
                                    iregNameList << constructChainRegString(iregVec.at(nleftRegNum),m,nstartBit,nendBit,pitem);

                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1:%2]")\
                                                               .arg(nstartBit).arg(nendBit));
                                }
                            }

                            nlastStopNum = m ;
                            isNeedAdded = true ;
                            goto WireShiftRegEvaluate0 ;
                        }
                    }
                    nlastStopNum = 0 ;
                }
WireShiftRegEvaluate0:



                if(iregNameList.count())
                {

                    ichainClock = pchain->getChainClock(pitem->getInstanceName(),iclockIterator.key());

                    if(ichainClock.isEmpty())
                    {
                        return 2 ;
                    }

                    if(isNeedAdded == true)
                    {
                        nusedNum =  pchainSt->m_unleftRegNumber ;
                    }
                    else
                    {
                        nusedNum = nregBitCount ;
                    }

                    pchain->addToRegChain(ichainClock,pchainSt->m_uncurrentChainNumber,iregNameList);

                    nwireCount++ ;
                    // 定义 wire 连接 tdo 代码
                    QString iwireTdoName(tr("_EziDebug_%1_%2_tdo%3").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireCount));
                    QString iwireTdoDefinitionCode(tr("\n\n\t""wire ")+ iwireTdoName + tr(" ;")) ;
                    iusrCoreCode.append(iwireTdoDefinitionCode);
                    iaddedCodeList.append(tr("\\bwire\\s+_EziDebug_%1_%2_tdo%3\\s*;")\
                                          .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireCount));

                    // 定义 wire 连接 移位寄存器 代码
                    QString iwireShiftRegDefinitionCode(tr("\n\t""wire ") + tr("[%1:0] ").arg(nusedNum-1) + tr("_EziDebug_%1_%2_sr%3")\
                                                        .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireShiftRegNum) + tr(" ;"));
                    QString iwireSrName(tr("_EziDebug_%1_%2_sr%3").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireShiftRegNum)) ;

                    iaddedCodeList.append(tr("\\bwire\\s*\\[\\s*%1\\s*:\\s*0\\s*\\]\\s*").arg(nusedNum-1) + tr("_EziDebug_%1_%2_sr%3\\s*;")\
                                          .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireShiftRegNum));

                    iusrCoreCode.append(iwireShiftRegDefinitionCode);
                    nwireShiftRegNum++ ;

                    //pchain->addToRegChain(ichainClock,pchainSt->m_uncurrentChainNumber,iregNameList);

                    QString iwireShiftRegEvaluateString ;
                    iwireShiftRegEvaluateString.append(tr("\n\t""assign %1 = {\n\t\t\t\t\t\t\t\t\t""%2""\n\t\t\t\t\t\t\t\t\t};").arg(iwireSrName).arg(iregCombinationCode.join(" ,\n\t\t\t\t\t\t\t\t\t")));
                    iaddedCodeList.append(tr("\\bassign\\s+%1.*;").arg(iwireSrName));
                    iusrCoreCode.append(iwireShiftRegEvaluateString);


                    /*自定义 core 例化代码 */
                    QString iusrCoreDefinitionCode ;
                    //QString iresetName = "1'b1";
                    QString iresetName = tr("_EziDebug_%1_rstn").arg(pchain->getChainName());


                    QString iusrCoreTdi ;
                    if(nnumberOfNoLibCore != 0)
                    {
                        if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                        {
                            iusrCoreTdi.append(tr("%1[%2]").arg(pmodule->getChainClockWireNameMap(pchain->getChainName(),iclockIterator.key())).arg(pchainSt->m_uncurrentChainNumber));
                        }
                        else
                        {
                            iusrCoreTdi.append(tr("%1").arg(pmodule->getChainClockWireNameMap(pchain->getChainName(),iclockIterator.key())));
                        }
                    }
                    else
                    {
                        if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                        {
                            iusrCoreTdi.append(tr("_EziDebug_%1_%2_TDI_reg[%3]").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(pchainSt->m_uncurrentChainNumber));
                        }
                        else
                        {
                            iusrCoreTdi.append(tr("_EziDebug_%1_%2_TDI_reg").arg(pchain->getChainName()).arg(iclockIterator.key()));
                        }
                    }

                    iusrCoreDefinitionCode.append(tr("\n\t")+ EziDebugScanChain::getChainRegCore() + tr(" %1_%2_inst%3(\n").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));
                    iusrCoreDefinitionCode.append(  tr("\t"".clock""\t(%1) ,\n").arg(iclockIterator.key()) \
                                                    + tr("\t"".resetn""\t(%1) ,\n").arg(iresetName) \
                                                    + tr("\t"".TDI_reg""\t(%1) ,\n").arg(iusrCoreTdi) \
                                                    + tr("\t"".TDO_reg""\t(%1) ,\n").arg(iwireTdoName) \
                                                    + tr("\t"".TOUT_reg""\t(%1) ,\n").arg(iparentToutPort) \
                                                    + tr("\t"".shift_reg""\t(%1) \n\t) ;").arg(iwireSrName));


                    /*加入 定义 userCore regWidth 限定的 语句代码*/
                    QString iparameterDefCode ;
                    iparameterDefCode.append(tr("\n\n\t""defparam %1_%2_inst%3.shift_width = %4 ;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum).arg(nusedNum));
                    iaddedCodeList.append(tr("\\bdefparam\\s+%1_%2_inst%3\\.shift_width\\s*=.*;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));

                    iusrCoreCode.append(iparameterDefCode)  ;
                    iaddedCodeList.append(EziDebugScanChain::getChainRegCore() + tr("\\s+%1_%2_inst%3\\s*(.*)\\s*;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));

                    iusrCoreCode.append(iusrCoreDefinitionCode);

                    /*module 端口连接代码*/
                    QString iportConnectCode ;
                    if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                    {
                        iportConnectCode.append(tr("\n\t""assign %1[%2] = %3 ;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                .arg(pchainSt->m_uncurrentChainNumber).arg(iwireTdoName));
                        iaddedCodeList.append(tr("\\bassign\\s+%1\\s*\\[\\s*%2\\s*\\].*;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                              .arg(pchainSt->m_uncurrentChainNumber));
                    }
                    else
                    {
                        iportConnectCode.append(tr("\n\t""assign %1 = %2 ;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                .arg(iwireTdoName));
                        iaddedCodeList.append(tr("\\bassign\\s+%1\\s*=\\s*%2\\s*;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                              .arg(iwireTdoName));
                    }
                    iusrCoreCode.append(iportConnectCode);
                }


                if(isNeedAdded == true)
                {
                    pchainSt->m_uncurrentChainNumber++ ;
                    pchainSt->m_unleftRegNumber = iprj->getMaxRegNumPerChain() ;
                    isNeedAdded = false ;
                }
                else
                {
                    pchainSt->m_unleftRegNumber -= nregBitCount ;
                }

                if(nleftRegNum != iregVec.count())
                {
                    goto AddReg ;
                }

            }
            else
            {
                // 肯定为多次例化的 模块
                for(;nregCount < sregVec.count(); nregCount++)
                {
                    EziDebugModule::RegStructure* preg =  sregVec.at(nregCount) ;
                    nSregNum += preg->m_unMaxBitWidth ;
                }

                nregCount = 0 ;

                for(;nregCount < vregVec.count();nregCount++)
                {
                    EziDebugModule::RegStructure* preg = vregVec.at(nregCount) ;
                    nVregNum += preg->m_unMaxBitWidth ;
                }


                //
                if((nSregNum + nVregNum) < pchainSt->m_unleftRegNumber)
                {
                    QStringList iregNameList ;
                    QStringList iregCombinationCode ;


                    QVector<EziDebugModule::RegStructure*> iregVec = sregVec ;
                    nleftRegNum = 0 ;
                    int nstaticRegBitSum = 0 ;
                    for(; nleftRegNum < iregVec.count() ; nleftRegNum++)
                    {
                        for(int m = 0 ; m < iregVec.at(nleftRegNum)->m_unRegNum ; m++)
                        {
                            EziDebugModule::RegStructure* preg = sregVec.at(nleftRegNum)  ;                    

                            nstaticRegBitSum += preg->m_unRegBitWidth ;
                            nRegNum += preg->m_unRegBitWidth ;

                            // reg pointer regnum  startbit  endbit  hiberarchyname
                            if(preg->m_eRegNumEndian)
                            {
                                iregNameList << constructChainRegString(preg,iregVec.at(nleftRegNum)->m_unStartNum - m , preg->m_unStartBit , preg->m_unEndBit ,pitem);
                                if(preg->m_unRegNum != 1)
                                {
                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName) + tr("[%1]")\
                                                               .arg(iregVec.at(nleftRegNum)->m_unStartNum - m));
                                }
                                else
                                {
                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName));
                                }
                            }
                            else
                            {
                                iregNameList << constructChainRegString(preg,iregVec.at(nleftRegNum)->m_unStartNum + m , preg->m_unStartBit , preg->m_unEndBit ,pitem);
                                if(preg->m_unRegNum != 1)
                                {
                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]")\
                                                               .arg(iregVec.at(nleftRegNum)->m_unStartNum + m));
                                }
                                else
                                {
                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName));
                                }
                            }                    

                        }
                    }

                    QString ivarRegBitSum ;
                    if(nstaticRegBitSum)
                    {
                        ivarRegBitSum =  QString::number(nstaticRegBitSum) ;
                    }
                    nleftRegNum = 0 ;

                    iregVec = vregVec ;

                    for(; nleftRegNum < iregVec.count() ; nleftRegNum++)
                    {
                        EziDebugModule::RegStructure* pvarReg = iregVec.at(nleftRegNum) ;
                        // 确切地定值 有 instancereg 提供
                        EziDebugModule::RegStructure* pinstanceReg = pmodule->getInstanceReg(pitem->getInstanceName(),iclockIterator.key(),QString::fromAscii(pvarReg->m_pRegName));
                        nRegNum += pvarReg->m_unMaxBitWidth ;
                        // construct the bitwidth string
                        if(pinstanceReg->m_unRegNum == 1)
                        {
                            ivarRegBitSum.append(QObject::tr("+") + QString::fromAscii(pvarReg->m_pExpString));
                        }
                        else
                        {
                            ivarRegBitSum.append(QObject::tr("+") + QObject::tr("(%1)*%2").arg(QString::fromAscii(pvarReg->m_pExpString)).arg(pinstanceReg->m_unRegNum));
                        }
                         // iprefixStr
                        for(int m = 0 ; m < pinstanceReg->m_unRegNum ; m++)
                        {

                            if(pinstanceReg->m_eRegNumEndian == EziDebugModule::endianBig)
                            {
                                iregNameList << constructChainRegString(pinstanceReg,pinstanceReg->m_unStartNum - m , pinstanceReg->m_unStartBit , pinstanceReg->m_unEndBit ,pitem);
                                if(pinstanceReg->m_unRegNum != 1)
                                {
                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName) + tr("[%1]")\
                                                               .arg(iregVec.at(nleftRegNum)->m_unStartNum - m));
                                }
                                else
                                {
                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName));
                                }
                            }
                            else
                            {
                                iregNameList << constructChainRegString(pinstanceReg,pinstanceReg->m_unStartNum + m , pinstanceReg->m_unStartBit , pinstanceReg->m_unEndBit ,pitem);
                                if(pinstanceReg->m_unRegNum != 1)
                                {
                                    iregCombinationCode.append( QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName) + tr("[%1]")\
                                                               .arg(iregVec.at(nleftRegNum)->m_unStartNum - m));
                                }
                                else
                                {
                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName));
                                }
                            }
                        }

                    }

                    ichainClock = pchain->getChainClock(pitem->getInstanceName(),iclockIterator.key());

                    if(ichainClock.isEmpty())
                    {
                        return 2 ;
                    }

                    pchain->addToRegChain(ichainClock,pchainSt->m_uncurrentChainNumber,iregNameList);


                    // 不用添加 新的代码
                    pchainSt->m_unleftRegNumber = pchainSt->m_unleftRegNumber - nRegNum ;

                    if(nchainStartNum == nlastChainEndNum) // 不用添加 新的代码,都在同一条扫描链中　且　剩余链寄存器够用
                    {
                        ++iclockIterator ;
                        continue ;
                    }

                    // defparameter 和　定义移位寄存器宽度　都为　字符串类型　非完全数字(如果存在变化位宽的寄存器的话)
                    // 加入的　ezidebug core 的　tdi 根据　前面是否存在　非系统core 连接　模块端口的　tdi 或者　定义的
                    // 非系统core 的　最后一根tdo_wire
                    // ezidebug core 的tdo 根据是否为最后１次添加代码　与　lastwire 相连　或者　端口的　tdo 相连
                    // 连接　这次添加链的　起始bit 与　上一次最后bit 之间的　连接　　assign

                    nwireCount++ ;
                    // 定义 wire 连接 tdo 代码
                    QString iwireTdoName(tr("_EziDebug_%1_%2_tdo%3").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireCount));
                    QString iwireTdoDefinitionCode(tr("\n\n\t""wire ")+ iwireTdoName + tr(" ;")) ;
                    iusrCoreCode.append(iwireTdoDefinitionCode);
                    iaddedCodeList.append(tr("\\bwire\\s+_EziDebug_%1_%2_tdo%3\\s*;")\
                                          .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireCount));


                    // 定义 wire 连接 移位寄存器 代码
                    QString iwireShiftRegDefinitionCode(tr("\n\t""wire ") + tr("[%1:0] ").arg(ivarRegBitSum + tr(" - 1")) + tr("_EziDebug_%1_%2_sr%3")\
                                                        .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireShiftRegNum) + tr(" ;"));
                    QString iwireSrName(tr("_EziDebug_%1_%2_sr%3").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireShiftRegNum)) ;

                    iaddedCodeList.append(tr("\\bwire\\s*\\[\\s*%1\\s*:\\s*0\\s*\\]\\s*").arg(ivarRegBitSum + tr(" - 1")) + tr("_EziDebug_%1_%2_sr%3\\s*;")\
                                          .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireShiftRegNum));

                    iusrCoreCode.append(iwireShiftRegDefinitionCode);
                    nwireShiftRegNum++ ;

                    //pchain->addToRegChain(ichainClock,pchainSt->m_uncurrentChainNumber,iregNameList);

                    QString iwireShiftRegEvaluateString ;
                    iwireShiftRegEvaluateString.append(tr("\n\t""assign %1 = {\n\t\t\t\t\t\t\t\t\t""%2""\n\t\t\t\t\t\t\t\t\t};").arg(iwireSrName).arg(iregCombinationCode.join(" ,\n\t\t\t\t\t\t\t\t\t")));
                    iaddedCodeList.append(tr("\\bassign\\s+%1.*;").arg(iwireSrName));
                    iusrCoreCode.append(iwireShiftRegEvaluateString);


                    /*自定义 core 例化代码 */
                    QString iusrCoreDefinitionCode ;
                    //QString iresetName = "1'b1";
                    QString iresetName = tr("_EziDebug_%1_rstn").arg(pchain->getChainName());


                    QString iusrCoreTdi ;
                    if(nnumberOfNoLibCore != 0)
                    {
                        if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                        {
                            iusrCoreTdi.append(tr("%1[%2]").arg(pmodule->getChainClockWireNameMap(pchain->getChainName(),iclockIterator.key())).arg(pchainSt->m_uncurrentChainNumber));
                        }
                        else
                        {
                            iusrCoreTdi.append(tr("%1").arg(pmodule->getChainClockWireNameMap(pchain->getChainName(),iclockIterator.key())));
                        }
                    }
                    else
                    {
                        if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                        {
                            iusrCoreTdi.append(tr("_EziDebug_%1_%2_TDI_reg[%3]").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(pchainSt->m_uncurrentChainNumber));
                        }
                        else
                        {
                            iusrCoreTdi.append(tr("_EziDebug_%1_%2_TDI_reg").arg(pchain->getChainName()).arg(iclockIterator.key()));
                        }
                    }

                    iusrCoreDefinitionCode.append(tr("\n\t")+ EziDebugScanChain::getChainRegCore() + tr(" %1_%2_inst%3(\n").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));
                    iusrCoreDefinitionCode.append(  tr("\t"".clock""\t(%1) ,\n").arg(iclockIterator.key()) \
                                                    + tr("\t"".resetn""\t(%1) ,\n").arg(iresetName) \
                                                    + tr("\t"".TDI_reg""\t(%1) ,\n").arg(iusrCoreTdi) \
                                                    + tr("\t"".TDO_reg""\t(%1) ,\n").arg(iwireTdoName) \
                                                    + tr("\t"".TOUT_reg""\t(%1) ,\n").arg(iparentToutPort) \
                                                    + tr("\t"".shift_reg""\t(%1) \n\t) ;").arg(iwireSrName));


                    /*加入 定义 userCore regWidth 限定的 语句代码*/
                    QString iparameterDefCode ;
                    iparameterDefCode.append(tr("\n\n\t""defparam %1_%2_inst%3.shift_width = %4 ;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum).arg(ivarRegBitSum));
                    iaddedCodeList.append(tr("\\bdefparam\\s+%1_%2_inst%3\\.shift_width\\s*=.*;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));

                    iusrCoreCode.append(iparameterDefCode)  ;
                    iaddedCodeList.append(EziDebugScanChain::getChainRegCore() + tr("\\s+%1_%2_inst%3\\s*(.*)\\s*;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));

                    iusrCoreCode.append(iusrCoreDefinitionCode);

                    /*module 端口连接代码*/
                    QString iportConnectCode ;
                    if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                    {
                        iportConnectCode.append(tr("\n\t""assign %1[%2] = %3 ;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                .arg(pchainSt->m_uncurrentChainNumber).arg(iwireTdoName));
                        iaddedCodeList.append(tr("\\bassign\\s+%1\\s*\\[\\s*%2\\s*\\].*;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                              .arg(pchainSt->m_uncurrentChainNumber));
                    }
                    else
                    {
                        iportConnectCode.append(tr("\n\t""assign %1 = %2 ;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                .arg(iwireTdoName));
                        iaddedCodeList.append(tr("\\bassign\\s+%1\\s*=\\s*%2\\s*;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                              .arg(iwireTdoName));
                    }
                    iusrCoreCode.append(iportConnectCode);
                }
                else
                {
                    // 从新的扫描链 开始添加
                    pchainSt->m_uncurrentChainNumber++ ;
                    pchainSt->m_unleftRegNumber = iprj->getMaxRegNumPerChain() ;

AddReg1:
                    // 只存在静态的寄存器
                    /*移位寄存器 赋值 代码*/
                    QStringList iregNameList ;
                    QVector<EziDebugModule::RegStructure*> iregVec = sregVec ;
                    QStringList iregCombinationCode ;


                    if(nleftBit != -1)
                    {
                        int nlastLeftRegNum = qAbs(iregVec.at(nleftRegNum)->m_unEndBit - nleftBit) + 1 ;

                        QVector<EziDebugModule::RegStructure*> iregVec =  sregVec ;
                        // 剩余的个数
                        if(nlastLeftRegNum >= iprj->getMaxRegNumPerChain())
                        {
                            while(nlastLeftRegNum >= iprj->getMaxRegNumPerChain())
                            {
                                ninstNum++ ;
                                nwireCount++ ;
                                iregCombinationCode.clear();
                                iregNameList.clear();
                                // 定义 wire 连接 tdo 代码
                                QString iwireTdoName(tr("_EziDebug_%1_%2_tdo%3").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireCount));
                                QString iwireTdoDefinitionCode(tr("\n\n\t""wire ")+ iwireTdoName + tr(" ;")) ;
                                iusrCoreCode.append(iwireTdoDefinitionCode);
                                iaddedCodeList.append(tr("\\bwire\\s+_EziDebug_%1_%2_tdo%3\\s*;")\
                                                      .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireCount));

                                // 定义 wire 连接 移位寄存器 代码
                                QString iwireShiftRegDefinitionCode(tr("\n\t""wire ") + tr("[%1:0]").arg(iprj->getMaxRegNumPerChain()-1)+ tr("_EziDebug_%1_%2_sr%3")\
                                                                    .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(ninstNum) + tr(" ;"));
                                QString iwireSrName(tr("_EziDebug_%1_%2_sr%3").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(ninstNum)) ;

                                iaddedCodeList.append(tr("\\bwire\\s*\\[\\s*%1:\\s*0\\s*\\]\\s*").arg(iprj->getMaxRegNumPerChain()-1)+tr("_EziDebug_%1_%2_sr%3\\s*;")\
                                                      .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(ninstNum));

                                iusrCoreCode.append(iwireShiftRegDefinitionCode);
                                nwireShiftRegNum++ ;

                                /*移位寄存器 赋值 代码*/
                                // int nendBit = nleftBit + iprj->getMaxRegNumPerChain() -1;
                                int nendBit = 0 ;
                                if(iregVec.at(nleftRegNum)->m_unRegNum > 1)
                                {
                                    if(iregVec.at(nleftRegNum)->m_eRegNumEndian == EziDebugModule::endianBig)
                                    {
                                        /*高:低*/
                                        // iregVec.at(nleftRegNum)->m_unBitWidth-1
                                        nendBit = nleftBit + 1 - iprj->getMaxRegNumPerChain() ;
                                        iregNameList << constructChainRegString(iregVec.at(nleftRegNum) , nlastStopNum , nleftBit , nendBit , pitem);

                                        iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum - nlastStopNum)+tr("[%1:%2]").arg(nleftBit).arg(nendBit));

                                        nleftBit = nendBit - 1 ;
                                    }
                                    else
                                    {
                                        /*低:高*/
                                        nendBit = nleftBit -1 + iprj->getMaxRegNumPerChain() ;
                                        iregNameList << constructChainRegString(iregVec.at(nleftRegNum) , nlastStopNum , nleftBit , nendBit , pitem);

                                        iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum + nlastStopNum)+tr("[%1:%2]").arg(nleftBit).arg(nendBit));

                                        nleftBit = nendBit + 1 ;
                                    }
                                }
                                else
                                {
                                    if(iregVec.at(nleftRegNum)->m_eRegNumEndian == EziDebugModule::endianBig)
                                    {
                                        /*高:低*/
                                        nendBit = nleftBit + 1 - iprj->getMaxRegNumPerChain() ;
                                        iregNameList << constructChainRegString(iregVec.at(nleftRegNum) , nlastStopNum , nleftBit , nendBit , pitem);

                                        iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1:%2]") \
                                                                   .arg(nleftBit).arg(nendBit));
                                        nleftBit = nendBit - 1 ;
                                    }
                                    else
                                    {
                                        /*低:高*/
                                        nendBit = nleftBit -1 + iprj->getMaxRegNumPerChain() ;
                                        iregNameList << constructChainRegString(iregVec.at(nleftRegNum) , nlastStopNum , nleftBit , nendBit , pitem);

                                        iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1:%2]")\
                                                                   .arg(nleftBit).arg(nendBit));

                                        nleftBit = nendBit + 1 ;
                                    }
                                }

                                ichainClock = pchain->getChainClock(pitem->getInstanceName(),iclockIterator.key());
                                if(ichainClock.isEmpty())
                                {
                                     // ichainClock = iclockIterator.key() ;
                                    return 2 ;
                                }

                                pchain->addToRegChain(ichainClock ,pchainSt->m_uncurrentChainNumber ,iregNameList);

                                QString iwireShiftRegEvaluateString ;
                                iwireShiftRegEvaluateString.append(tr("\n\t""assign %1 = {\n\t\t\t\t\t\t\t\t\t""%2""\n\t\t\t\t\t\t\t\t\t};").arg(iwireSrName).arg(iregCombinationCode.join(" ,\n\t\t\t\t\t\t\t\t\t")));
                                iaddedCodeList.append(tr("\\bassign\\s+%1.*;").arg(iwireSrName));
                                iusrCoreCode.append(iwireShiftRegEvaluateString);

                                /*自定义 core 例化代码 */
                                QString iusrCoreDefinitionCode ;
                                //QString iresetName = "1'b1";
                                QString iresetName = tr("_EziDebug_%1_rstn").arg(pchain->getChainName());

                                QString iusrCoreTdi ;
                                if(nnumberOfNoLibCore != 0)
                                {
                                    if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                                    {
                                        iusrCoreTdi.append(tr("%1[%2]").arg(pmodule->getChainClockWireNameMap(pchain->getChainName(),iclockIterator.key())).arg(pchainSt->m_uncurrentChainNumber));
                                    }
                                    else
                                    {
                                        iusrCoreTdi.append(tr("%1").arg(pmodule->getChainClockWireNameMap(pchain->getChainName(),iclockIterator.key())));
                                    }
                                }
                                else
                                {
                                    if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                                    {
                                        iusrCoreTdi.append(tr("_EziDebug_%1_%2_TDI_reg[%3]").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(pchainSt->m_uncurrentChainNumber));
                                    }
                                    else
                                    {
                                        iusrCoreTdi.append(tr("_EziDebug_%1_%2_TDI_reg").arg(pchain->getChainName()).arg(iclockIterator.key()));
                                    }
                                }

                                iusrCoreDefinitionCode.append(tr("\n\t")+ EziDebugScanChain::getChainRegCore() + tr(" %1_%2_inst%3(\n").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));
                                iusrCoreDefinitionCode.append(  tr("\t"".clock""\t(%1) ,\n").arg(iclockIterator.key()) \
                                                                + tr("\t"".resetn""\t(%1) ,\n").arg(iresetName) \
                                                                + tr("\t"".TDI_reg""\t(%1) ,\n").arg(iusrCoreTdi) \
                                                                + tr("\t"".TDO_reg""\t(%1) ,\n").arg(iwireTdoName) \
                                                                + tr("\t"".TOUT_reg""\t(%1) ,\n").arg(iparentToutPort) \
                                                                + tr("\t"".shift_reg""\t(%1) \n\t) ;").arg(iwireSrName));

                                /*加入 定义 userCore regWidth 限定的 语句代码*/
                                QString iparameterDefCode ;
                                iparameterDefCode.append(tr("\n\n\t""defparam %1_%2_inst%3.shift_width = %4 ;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum).arg(iprj->getMaxRegNumPerChain()));
                                iaddedCodeList.append(tr("\\bdefparam\\s+%1_%2_inst%3\\.shift_width\\s*=.*;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));
                                iusrCoreCode.append(iparameterDefCode)  ;

                                iaddedCodeList.append(EziDebugScanChain::getChainRegCore() + tr("\\s+%1_%2_inst%3\\s*\\(.*\\)\\s*;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));

                                iusrCoreCode.append(iusrCoreDefinitionCode);


                                /*module 端口连接代码*/
                                QString iportConnectCode ;
                                iportConnectCode.append(tr("\n\t""assign %1[%2] = %3 ;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                        .arg(pchainSt->m_uncurrentChainNumber).arg(iwireTdoName));
                                iaddedCodeList.append(tr("\\bassign\\s+%1\\s*\\[\\s*%2\\s*\\].*;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                      .arg(pchainSt->m_uncurrentChainNumber));
                                iusrCoreCode.append(iportConnectCode);


                                nlastLeftRegNum = nlastLeftRegNum - iprj->getMaxRegNumPerChain();
                                pchainSt->m_uncurrentChainNumber++ ;
                                pchainSt->m_unleftRegNumber = iprj->getMaxRegNumPerChain() ;
                            }
                        }

                        // 将剩余的寄存器加入到链中
                        iregCombinationCode.clear();
                        iregNameList.clear();
#if 1
                        if(iregVec.at(nleftRegNum)->m_eRegBitWidthEndian == EziDebugModule::endianBig)
                        {
                            if((nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) > 0)
                            {
                                pchainSt->m_unleftRegNumber -= (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                                nregBitCount = (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                                iregNameList << constructChainRegString(iregVec.at(nleftRegNum),nlastStopNum,nleftBit,iregVec.at(nleftRegNum)->m_unEndBit ,pitem);

                                iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1][%2:%3]").arg(iregVec.at(nleftRegNum)->m_unStartNum - nlastStopNum).arg(nleftBit).arg(iregVec.at(nleftRegNum)->m_unEndBit));
                            }
                            else if((nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) == 0)
                            {
                                pchainSt->m_unleftRegNumber -= (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                                nregBitCount = (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                                iregNameList << constructChainRegString(iregVec.at(nleftRegNum),nlastStopNum,nleftBit,iregVec.at(nleftRegNum)->m_unEndBit ,pitem);

                                iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1][0]").arg(iregVec.at(nleftRegNum)->m_unStartNum - nlastStopNum));
                            }
                            else
                            {
                                // 上面已经加完了
                            }

                        }
                        else
                        {
                            if((iregVec.at(nleftRegNum)->m_unEndBit - nleftBit) > 0)
                            {
                                pchainSt->m_unleftRegNumber -= (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                                nregBitCount = (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                                iregNameList << constructChainRegString(iregVec.at(nleftRegNum),nlastStopNum,nleftBit,iregVec.at(nleftRegNum)->m_unEndBit ,pitem);

                                iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1][%2:%3]").arg(iregVec.at(nleftRegNum)->m_unStartNum + nlastStopNum).arg(nleftBit).arg(iregVec.at(nleftRegNum)->m_unEndBit));
                            }
                            else if((iregVec.at(nleftRegNum)->m_unEndBit - nleftBit) == 0)
                            {
                                pchainSt->m_unleftRegNumber -= (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                                nregBitCount = (qAbs(nleftBit - iregVec.at(nleftRegNum)->m_unEndBit) + 1) ;
                                iregNameList << constructChainRegString(iregVec.at(nleftRegNum),nlastStopNum,nleftBit,iregVec.at(nleftRegNum)->m_unEndBit ,pitem);

                                iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1][0]").arg(iregVec.at(nleftRegNum)->m_unStartNum + nlastStopNum));
                            }
                            else
                            {
                                // 已经加完
                            }
                        }
#endif


                        if(iregVec.at(nleftRegNum)->m_unRegNum > 1)
                        {
                            nlastStopNum++ ;
                        }
                        else
                        {
                            nleftRegNum++ ;
                            nlastStopNum = 0 ;
                        }

                        nleftBit = -1 ;
                    }
                    else
                    {
                        nregBitCount = 0 ;
                    }


                    for(; nleftRegNum < iregVec.count() ; nleftRegNum++)
                    {
                        for(int m = nlastStopNum ; m < iregVec.at(nleftRegNum)->m_unRegNum; m++)
                        {
                            nregBitCount += iregVec.at(nleftRegNum)->m_unRegBitWidth ;

                            if(nregBitCount < pchainSt->m_unleftRegNumber)
                            {
                                /*数组情况下*/
                                // 够用继续添加
                                if(iregVec.at(nleftRegNum)->m_unRegNum > 1)
                                {
                                    if(iregVec.at(nleftRegNum)->m_eRegNumEndian == EziDebugModule::endianBig)
                                    {
                                        iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum - m));
                                    }
                                    else
                                    {
                                        iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum + m));
                                    }
                                }
                                else
                                {
                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName));
                                }

                                iregNameList << constructChainRegString(iregVec.at(nleftRegNum),m,iregVec.at(nleftRegNum)->m_unStartBit,iregVec.at(nleftRegNum)->m_unEndBit,pitem);
                            }
                            else if(nregBitCount == pchainSt->m_unleftRegNumber)
                            {
                                // 刚好满  跳出  下次新的扫描链继续 添加
                                if(iregVec.at(nleftRegNum)->m_unRegNum > 1)
                                {
                                    if(iregVec.at(nleftRegNum)->m_eRegNumEndian == EziDebugModule::endianBig)
                                    {
                                        iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum - m));
                                    }
                                    else
                                    {
                                        iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum + m));
                                    }
                                }
                                else
                                {
                                    iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName));
                                }

                                iregNameList << constructChainRegString(iregVec.at(nleftRegNum),m,iregVec.at(nleftRegNum)->m_unStartBit,iregVec.at(nleftRegNum)->m_unEndBit,pitem);

                                nlastStopNum = m ;
                                // nleftBit = -1 ;
                                nleftRegNum++ ;
                                isNeedAdded = true ;

                                goto WireShiftRegEvaluate1 ;
                            }
                            else
                            {
                                if(iregVec.at(nleftRegNum)->m_unRegNum > 1)
                                {
                                    if(iregVec.at(nleftRegNum)->m_eRegNumEndian == EziDebugModule::endianBig)
                                    {
                                        int nstartBit = iregVec.at(nleftRegNum)->m_unStartBit ;
                                        int nendBit = nregBitCount- pchainSt->m_unleftRegNumber + iregVec.at(nleftRegNum)->m_unStartBit + 1 - iregVec.at(nleftRegNum)->m_unRegBitWidth ;
                                        nleftBit = nendBit - 1 ;
                                        iregNameList << constructChainRegString(iregVec.at(nleftRegNum),m,nstartBit,nendBit,pitem);

                                        iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum - m)+tr("[%1:%2]").arg(nstartBit).arg(nendBit));
                                    }
                                    else
                                    {
                                        int nstartBit = iregVec.at(nleftRegNum)->m_unStartBit ;
                                        int nendBit = iregVec.at(nleftRegNum)->m_unRegBitWidth + iregVec.at(nleftRegNum)->m_unStartBit - 1 - (nregBitCount- pchainSt->m_unleftRegNumber) ;
                                        nleftBit = nendBit + 1 ;
                                        iregNameList << constructChainRegString(iregVec.at(nleftRegNum),m,nstartBit,nendBit,pitem);

                                        iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1]").arg(iregVec.at(nleftRegNum)->m_unStartNum + m)+tr("[%1:%2]").arg(nstartBit).arg(nendBit));
                                    }
                                }
                                else
                                {
                                    if(iregVec.at(nleftRegNum)->m_eRegNumEndian == EziDebugModule::endianBig)
                                    {
                                        int nstartBit = iregVec.at(nleftRegNum)->m_unStartBit ;
                                        int nendBit = nregBitCount- pchainSt->m_unleftRegNumber + iregVec.at(nleftRegNum)->m_unStartBit + 1 - iregVec.at(nleftRegNum)->m_unRegBitWidth ;
                                        nleftBit = nendBit - 1 ;
                                        iregNameList << constructChainRegString(iregVec.at(nleftRegNum),m,nstartBit,nendBit,pitem);

                                        iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1:%2]") \
                                                                   .arg(nstartBit).arg(nendBit));
                                    }
                                    else
                                    {
                                        int nstartBit = iregVec.at(nleftRegNum)->m_unStartBit ;
                                        int nendBit = iregVec.at(nleftRegNum)->m_unRegBitWidth + iregVec.at(nleftRegNum)->m_unStartBit - 1 - (nregBitCount- pchainSt->m_unleftRegNumber) ;
                                        nleftBit = nendBit + 1 ;
                                        iregNameList << constructChainRegString(iregVec.at(nleftRegNum),m,nstartBit,nendBit,pitem);

                                        iregCombinationCode.append(QString::fromAscii(iregVec.at(nleftRegNum)->m_pRegName)+tr("[%1:%2]")\
                                                                   .arg(nstartBit).arg(nendBit));
                                    }
                                }

                                nlastStopNum = m ;
                                isNeedAdded = true ;
                                goto WireShiftRegEvaluate1 ;
                            }
                        }
                        nlastStopNum = 0 ;
                    }
WireShiftRegEvaluate1:

                    if(isNeedAdded == true)
                    {
                        nusedNum =  pchainSt->m_unleftRegNumber ;
                    }
                    else
                    {
                        nusedNum = nregBitCount ;
                    }

                    // 没加完继续加
                    if(nleftRegNum != iregVec.count())
                    {
                        // 有寄存器
                        if(iregNameList.count())
                        {

                            ichainClock = pchain->getChainClock(pitem->getInstanceName(),iclockIterator.key());

                            if(ichainClock.isEmpty())
                            {
                                return 2 ;
                            }

                            pchain->addToRegChain(ichainClock,pchainSt->m_uncurrentChainNumber,iregNameList);

                            nwireCount++ ;
                            // 定义 wire 连接 tdo 代码
                            QString iwireTdoName(tr("_EziDebug_%1_%2_tdo%3").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireCount));
                            QString iwireTdoDefinitionCode(tr("\n\n\t""wire ")+ iwireTdoName + tr(" ;")) ;
                            iusrCoreCode.append(iwireTdoDefinitionCode);
                            iaddedCodeList.append(tr("\\bwire\\s+_EziDebug_%1_%2_tdo%3\\s*;")\
                                                  .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireCount));


                            // 定义 wire 连接 移位寄存器 代码
                            QString iwireShiftRegDefinitionCode(tr("\n\t""wire ") + tr("[%1:0] ").arg(nusedNum - 1) + tr("_EziDebug_%1_%2_sr%3")\
                                                                .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireShiftRegNum) + tr(" ;"));
                            QString iwireSrName(tr("_EziDebug_%1_%2_sr%3").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireShiftRegNum)) ;

                            iaddedCodeList.append(tr("\\bwire\\s*\\[\\s*%1\\s*:\\s*0\\s*\\]\\s*").arg(nusedNum - 1) + tr("_EziDebug_%1_%2_sr%3\\s*;")\
                                                  .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireShiftRegNum));

                            iusrCoreCode.append(iwireShiftRegDefinitionCode);
                            nwireShiftRegNum++ ;

                            //pchain->addToRegChain(ichainClock,pchainSt->m_uncurrentChainNumber,iregNameList);

                            QString iwireShiftRegEvaluateString ;
                            iwireShiftRegEvaluateString.append(tr("\n\t""assign %1 = {\n\t\t\t\t\t\t\t\t\t""%2""\n\t\t\t\t\t\t\t\t\t};").arg(iwireSrName).arg(iregCombinationCode.join(" ,\n\t\t\t\t\t\t\t\t\t")));
                            iaddedCodeList.append(tr("\\bassign\\s+%1\\s*=.*;").arg(iwireSrName));
                            iusrCoreCode.append(iwireShiftRegEvaluateString);


                            /*自定义 core 例化代码 */
                            QString iusrCoreDefinitionCode ;
                            //QString iresetName = "1'b1";
                            QString iresetName = tr("_EziDebug_%1_rstn").arg(pchain->getChainName());


                            QString iusrCoreTdi ;
                            if(nnumberOfNoLibCore != 0)
                            {
                                if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                                {
                                    iusrCoreTdi.append(tr("%1[%2]").arg(pmodule->getChainClockWireNameMap(pchain->getChainName(),iclockIterator.key())).arg(pchainSt->m_uncurrentChainNumber));
                                }
                                else
                                {
                                    iusrCoreTdi.append(tr("%1").arg(pmodule->getChainClockWireNameMap(pchain->getChainName(),iclockIterator.key())));
                                }
                            }
                            else
                            {
                                if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                                {
                                    iusrCoreTdi.append(tr("_EziDebug_%1_%2_TDI_reg[%3]").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(pchainSt->m_uncurrentChainNumber));
                                }
                                else
                                {
                                    iusrCoreTdi.append(tr("_EziDebug_%1_%2_TDI_reg").arg(pchain->getChainName()).arg(iclockIterator.key()));
                                }
                            }

                            iusrCoreDefinitionCode.append(tr("\n\n\t")+EziDebugScanChain::getChainRegCore() + tr(" %1_%2_inst%3(\n").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));
                            iusrCoreDefinitionCode.append(  tr("\t\t"".clock""\t(%1) ,\n").arg(iclockIterator.key()) \
                                                            + tr("\t\t"".resetn""\t(%1) ,\n").arg(iresetName) \
                                                            + tr("\t\t"".TDI_reg""\t(%1) ,\n").arg(iusrCoreTdi) \
                                                            + tr("\t\t"".TDO_reg""\t(%1) ,\n").arg(iwireTdoName) \
                                                            + tr("\t\t"".TOUT_reg""\t(%1) ,\n").arg(iparentToutPort) \
                                                            + tr("\t\t"".shift_reg""\t(%1) \n\t) ;").arg(iwireSrName));


                            /*加入 定义 userCore regWidth 限定的 语句代码*/
                            QString iparameterDefCode ;
                            iparameterDefCode.append(tr("\n\n\t""defparam %1_%2_inst%3.shift_width = %4 ;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum).arg(nusedNum));
                            iaddedCodeList.append(tr("\\bdefparam\\s+%1_%2_inst%3\\.shift_width\\s*=.*;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));

                            iusrCoreCode.append(iparameterDefCode)  ;
                            iaddedCodeList.append(EziDebugScanChain::getChainRegCore() + tr("\\s+%1_%2_inst%3\\s*(.*)\\s*;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));

                            iusrCoreCode.append(iusrCoreDefinitionCode);

                            /*module 端口连接代码*/
                            QString iportConnectCode ;
                            if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                            {
                                iportConnectCode.append(tr("\n\n\t""assign %1[%2] = %3 ;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                        .arg(pchainSt->m_uncurrentChainNumber).arg(iwireTdoName));
                                iaddedCodeList.append(tr("\\bassign\\s+%1\\s*\\[\\s*%2\\s*\\].*;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                      .arg(pchainSt->m_uncurrentChainNumber));
                            }
                            else
                            {
                                iportConnectCode.append(tr("\n\n\t""assign %1 = %2 ;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                        .arg(iwireTdoName));
                                iaddedCodeList.append(tr("\\bassign\\s+%1\\s*=\\s*%2\\s*;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                      .arg(iwireTdoName));
                            }
                            iusrCoreCode.append(iportConnectCode);
                        }

                        pchainSt->m_uncurrentChainNumber++ ;
                        pchainSt->m_unleftRegNumber = iprj->getMaxRegNumPerChain() ;
                        isNeedAdded = false ;
                        goto AddReg ;
                    }
                    else
                    {
                        pchainSt->m_unleftRegNumber -= nregBitCount ;
                    }
#if 0
                    if(!sregVec.count())
                    {
                        pchainSt->m_uncurrentChainNumber++ ;
                        pchainSt->m_unleftRegNumber = iprj->getMaxRegNumPerChain() ;
                    }
#endif

                    // 添加动态寄存器
                    QString ivarRegSumStr ;
                    int nregNumCount = 0 ;
                    nleftRegNum = 0 ;

AddVReg:
                    if(nregBitCount != 0)
                    {
                        ivarRegSumStr = QString::number(nregBitCount) ;
                    }
                    else
                    {
                        ivarRegSumStr.clear();
                        iregCombinationCode.clear();
                    }

                    for(;nleftRegNum < vregVec.count();nleftRegNum++)
                    {
                        // 还要考虑 regnum  记录添加到了 哪个 寄存器
                        EziDebugModule::RegStructure* preg = vregVec.at(nleftRegNum) ;
                        EziDebugModule::RegStructure* pinstancereg = pmodule->getInstanceReg(pitem->getInstanceName(),iclockIterator.key(),QString::fromAscii(preg->m_pRegName));

                        if(preg->m_unMaxBitWidth < pchainSt->m_unleftRegNumber)
                        {
                            pchainSt->m_unleftRegNumber -= preg->m_unMaxBitWidth ;

                            if(pinstancereg->m_unRegNum == 1)
                            {
                                if(!ivarRegSumStr.isEmpty())
                                {
                                    ivarRegSumStr.append(QObject::tr("+") + QString::fromAscii(preg->m_pExpString));
                                }
                                else
                                {
                                    ivarRegSumStr.append(QString::fromAscii(preg->m_pExpString));
                                }

                                iregNameList << constructChainRegString(pinstancereg , 0 ,pinstancereg->m_unStartBit , pinstancereg->m_unEndBit , pitem);

                                iregCombinationCode.append(QString::fromAscii(preg->m_pRegName));
                            }
                            else if(pinstancereg->m_unRegNum > 1)
                            {
                                if(!ivarRegSumStr.isEmpty())
                                {
                                    ivarRegSumStr.append(QObject::tr("+") + QString::fromAscii(preg->m_pExpString) + QObject::tr("*") + QString::number(pinstancereg->m_unRegNum));
                                }
                                else
                                {
                                    ivarRegSumStr.append(QString::fromAscii(preg->m_pExpString) + QObject::tr("*") + QString::number(pinstancereg->m_unRegNum));
                                }

                                for( ; nregNumCount < pinstancereg->m_unRegNum ; nregNumCount++ )
                                {
                                    QString iregNumStr ;
                                    if(pinstancereg->m_eRegNumEndian == EziDebugModule::endianBig)
                                    {
                                        iregNumStr = QString::number(pinstancereg->m_unStartNum - nregNumCount) ;
                                    }
                                    else
                                    {
                                        iregNumStr = QString::number(pinstancereg->m_unStartNum + nregNumCount) ;
                                    }
                                    iregNameList << constructChainRegString(pinstancereg , nregNumCount ,pinstancereg->m_unStartBit , pinstancereg->m_unEndBit , pitem);

                                    iregCombinationCode.append(QObject::tr("%1[%2]").arg(QString::fromAscii(pinstancereg->m_pRegName)).arg(iregNumStr)) ;
                                }
                            }
                        }
                        else
                        {
                            // 跳出添加链
                            break ;
                        }
                    }

                    // 添加扫描链
                    ichainClock = pchain->getChainClock(pitem->getInstanceName(),iclockIterator.key());
                    if(ichainClock.isEmpty())
                    {
                        ichainClock = iclockIterator.key() ;
                    }

                    pchain->addToRegChain(ichainClock ,pchainSt->m_uncurrentChainNumber ,iregNameList);


                    nwireCount++ ;
                    // 定义 wire 连接 tdo 代码
                    QString iwireTdoName(tr("_EziDebug_%1_%2_tdo%3").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireCount));
                    QString iwireTdoDefinitionCode(tr("\n\n\t""wire ")+ iwireTdoName + tr(" ;")) ;
                    iusrCoreCode.append(iwireTdoDefinitionCode);
                    iaddedCodeList.append(tr("\\bwire\\s+_EziDebug_%1_%2_tdo%3\\s*;")\
                                          .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireCount));


                    // 定义 wire 连接 移位寄存器 代码
                    QString iwireShiftRegDefinitionCode(tr("\n\t""wire ") + tr("[%1:0] ").arg(ivarRegSumStr + tr(" - 1")) + tr("_EziDebug_%1_%2_sr%3")\
                                                        .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireShiftRegNum) + tr(" ;"));
                    QString iwireSrName(tr("_EziDebug_%1_%2_sr%3").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireShiftRegNum)) ;

                    iaddedCodeList.append(tr("\\bwire\\s*\\[\\s*%1\\s*:\\s*0\\s*\\]\\s*").arg(ivarRegSumStr + tr(" - 1")) + tr("_EziDebug_%1_%2_sr%3\\s*;")\
                                          .arg(pchain->getChainName()).arg(iclockIterator.key()).arg(nwireShiftRegNum));

                    iusrCoreCode.append(iwireShiftRegDefinitionCode);
                    nwireShiftRegNum++ ;

                    QString iwireShiftRegEvaluateString ;
                    iwireShiftRegEvaluateString.append(tr("\n\t""assign %1 = {\n\t\t\t\t\t\t\t\t\t""%2""\n\t\t\t\t\t\t\t\t\t};").arg(iwireSrName).arg(iregCombinationCode.join(" ,\n\t\t\t\t\t\t\t\t\t")));
                    iaddedCodeList.append(tr("\\bassign\\s+%1.*;").arg(iwireSrName));
                    iusrCoreCode.append(iwireShiftRegEvaluateString);

                    /*自定义 core 例化代码 */
                    QString iusrCoreDefinitionCode ;
                    //QString iresetName ;
                    QString iresetName = tr("_EziDebug_%1_rstn").arg(pchain->getChainName());

                    QString iusrCoreTdi ;
                    if(nnumberOfNoLibCore != 0)
                    {
                        if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                        {
                            iusrCoreTdi.append(tr("%1[%2]").arg(pmodule->getChainClockWireNameMap(pchain->getChainName(),iclockIterator.key())).arg(pchainSt->m_uncurrentChainNumber));
                        }
                        else
                        {
                            iusrCoreTdi.append(tr("%1").arg(pmodule->getChainClockWireNameMap(pchain->getChainName(),iclockIterator.key())));
                        }
                    }
                    else
                    {
                        if((chainStructuremap.value(iclockIterator.key())->m_untotalChainNumber) > 1)
                        {
                            iusrCoreTdi.append(tr("_EziDebug_%1_%2_TDI_reg[%3]").arg(pchain->getChainName()).arg(iclockIterator.key()).arg(pchainSt->m_uncurrentChainNumber));
                        }
                        else
                        {
                            iusrCoreTdi.append(tr("_EziDebug_%1_%2_TDI_reg").arg(pchain->getChainName()).arg(iclockIterator.key()));
                        }
                    }

                    iusrCoreDefinitionCode.append(tr("\n\t")+ EziDebugScanChain::getChainRegCore() + tr(" %1_%2_inst%3(\n").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));
                    iusrCoreDefinitionCode.append(  tr("\t"".clock""\t(%1) ,\n").arg(iclockIterator.key()) \
                                                    + tr("\t"".resetn""\t(%1) ,\n").arg(iresetName) \
                                                    + tr("\t"".TDI_reg""\t(%1) ,\n").arg(iusrCoreTdi) \
                                                    + tr("\t"".TDO_reg""\t(%1) ,\n").arg(iwireTdoName) \
                                                    + tr("\t"".TOUT_reg""\t(%1) ,\n").arg(iparentToutPort) \
                                                    + tr("\t"".shift_reg""\t(%1) \n\t) ;").arg(iwireSrName));

                    /*加入 定义 userCore regWidth 限定的 语句代码*/
                    QString iparameterDefCode ;
                    iparameterDefCode.append(tr("\n\n\t""defparam %1_%2_inst%3.shift_width = %4 ;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum).arg(ivarRegSumStr));
                    iaddedCodeList.append(tr("\\bdefparam\\s+%1_%2_inst%3\\.shift_width\\s*=.*;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));
                    iusrCoreCode.append(iparameterDefCode)  ;

                    iaddedCodeList.append(EziDebugScanChain::getChainRegCore() + tr("\\s+%1_%2_inst%3\\s*\\(.*\\)\\s*;").arg(EziDebugScanChain::getChainRegCore()).arg(pchain->getChainName()).arg(ninstNum));

                    iusrCoreCode.append(iusrCoreDefinitionCode);


                    /*module 端口连接代码*/
                    QString iportConnectCode ;
                    iportConnectCode.append(tr("\n\t""assign %1[%2] = %3 ;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                            .arg(pchainSt->m_uncurrentChainNumber).arg(iwireTdoName));
                    iaddedCodeList.append(tr("\\bassign\\s+%1\\s*\\[\\s*%2\\s*\\].*;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                          .arg(pchainSt->m_uncurrentChainNumber));
                    iusrCoreCode.append(iportConnectCode);

                    ivarRegSumStr.clear();

                    if(iregNameList.count())
                    {
                        // 将第一部分的寄存器 最后一次的 regbitcount 记录下来
                        // 转换为 QString 类型

                        if(nleftRegNum != vregVec.count())
                        {
                            // 还有寄存器
                            pchainSt->m_uncurrentChainNumber++ ;
                            pchainSt->m_unleftRegNumber = iprj->getMaxRegNumPerChain() ;
                            goto AddVReg ;
                        }
                    }
                }

            }
            // 根据 要例化 数目 创建 例化 ,并创建 wire_tdo 信号 、移位寄存器 、
            if(fileName().endsWith("fft_ram_256x17.v"))
            {
                qDebug("add chain in fft_ram_256x17.v");
            }
            QString ilastPortConnect ;
            nchainEndNum = pchainSt->m_uncurrentChainNumber ;

            // 上一次链结束 到 这一次链开始 的 端口连接
            ilastInput.clear();
            if(nnumberOfNoLibCore != 0)
            {
                // 用 lastwire
                ilastInput = pmodule->getChainClockWireNameMap(pchain->getChainName(),iclockIterator.key()) ;
            }
            else
            {
                // 用 tdi
                ilastInput = tr("_EziDebug_%1_%2_TDI_reg").arg(pchain->getChainName()).arg(iclockIterator.key()) ;
            }

            // 不在同一条链上，且不是从0条链开始加
            if((nlastChainEndNum != nchainStartNum)&&(nchainStartNum != 0))
            {
                int nstartBit = 0 ;

                nstartBit = nlastChainEndNum + 1;


                if((nchainStartNum - nlastChainEndNum) > 2)
                {
                    ilastPortConnect.append(tr("\n\t""assign %1[%2:%3] = %4[%5:%6] ;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                            .arg(nchainStartNum-1).arg(nstartBit).arg(ilastInput).arg(nchainStartNum-1).arg(nstartBit));
                    iusrCoreCode.append(ilastPortConnect);
                    iaddedCodeList.append(tr("\\bassign\\s+%1\\s*\\[\\s*%2\\s*:\\s*%3\\s*\\]\\s*=\\s*%4\\[\\s*%5\\s*:\\s*%6\\s*\\]\\s*;")
                                          .arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                                                      .arg(nchainStartNum-1).arg(nstartBit).arg(ilastInput).arg(nchainStartNum-1).arg(nstartBit));
                }
                else
                {
                    ilastPortConnect.append(tr("\n\t""assign %1[%2] = %3[%4] ;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                            .arg(nstartBit)\
                                            .arg(ilastInput)\
                                            .arg(nstartBit));
                    iusrCoreCode.append(ilastPortConnect);
                    iaddedCodeList.append(tr("\\bassign\\s+%1\\s*\\[\\s*%2\\s*\\]\\s*=\\s*%3\\s*\\[\\s*%4\\s*\\]\\s*;")\
                                          .arg(tr("_EziDebug_%1_%2_TDO_reg")\
                                          .arg(pchain->getChainName())\
                                          .arg(iclockIterator.key()))\
                                          .arg(nstartBit)\
                                          .arg(ilastInput)\
                                          .arg(nstartBit));
                }
            }

            pmodule->setBitRangeInChain(pchain->getChainName(),iclockIterator.key(),nchainStartNum ,nchainEndNum);
            pmodule->setEziDebugCoreCounts(pchain->getChainName(),ninstNum);
            ++iclockIterator ;
        }

            pmodule->setEziDebugWireCounts(pchain->getChainName(),nwireCount);

        /*
                自定义core 的例化代码
                1、  _EziDebugScanChainReg + 例化名(
                    .clock      (module中的各个clock)  ,
                    .resetn     (module中的复位信号)  ,
                    .TDI_reg    (非系统core 的 最后一个 wire_tdo)  ,
                    .TDO_reg    (自定义的 wire_tdo  )  ,
                    .TOUT_reg   (module端口的 tout  )  ,
                    .shift_reg  (自定义的 shift_reg )
                 );
            */
        int ntimesPerChain = pmodule->getInstancedTimesPerChain(pchain->getChainName()) ;
        if(1 == ntimesPerChain)
        {
            iclockIterator = iclockMap.constBegin();
            while(iclockIterator != iclockMap.constEnd())
            {
                EziDebugInstanceTreeItem::SCAN_CHAIN_STRUCTURE* pchainSt = chainStructuremap.value(iclockIterator.key()) ;
                QString ilastInput ;
                QString ilastPortConnect ;
                if(nnumberOfNoLibCore != 0)
                {
                    // 用 lastwire
                    ilastInput = pmodule->getChainClockWireNameMap(pchain->getChainName(),iclockIterator.key()) ;

                }
                else
                {
                    // 用 tdi
                    ilastInput = tr("_EziDebug_%1_%2_TDI_reg").arg(pchain->getChainName()).arg(iclockIterator.key()) ;
                }

                // 这次最后1bit wire
                pmodule->getBitRangeInChain(pchain->getChainName(),iclockIterator.key(),&nlastChainStartNum ,&nlastChainEndNum);

                int nbitNum = 0 ;

                // 端口连接不完全
                if(nlastChainEndNum != (pchainSt->m_untotalChainNumber-1))
                {
                    if((pchainSt->m_untotalChainNumber - nlastChainEndNum) > 2)
                    {
                        if( -1 == nlastChainEndNum)
                        {
                            // 没加过自定义core
                            nbitNum  = 0 ;
                        }
                        else
                        {
                            nbitNum = nlastChainEndNum + 1 ;
                        }

                        ilastPortConnect.append(tr("\n\t""assign %1[%2:%3] = %4[%5:%6] ;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                .arg(pchainSt->m_untotalChainNumber-1).arg(nbitNum).arg(ilastInput).arg(pchainSt->m_untotalChainNumber-1).arg(nbitNum));
                        iusrCoreCode.append(ilastPortConnect);
                        iaddedCodeList.append(tr("\\bassign\\s+")+tr("%1\\s*\\[\\s*%2\\s*:\\s*%3\\s*\\]\\s*=\\s*%4\\s*\\[\\s*%5\\s*:\\s*%6\\s*\\]\\s*;") \
                                              .arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                              .arg(pchainSt->m_untotalChainNumber-1)\
                                              .arg(nbitNum).arg(ilastInput).arg(pchainSt->m_untotalChainNumber-1).arg(nbitNum)
                                              );
                    }
                    else
                    {

                        if(nlastChainEndNum == -1) // module无寄存器 无插入链代码  直接透传
                        {
                            ilastPortConnect.append(tr("\n\t""assign %1 = %2 ;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                    .arg(ilastInput));
                            iusrCoreCode.append(ilastPortConnect);
                            iaddedCodeList.append(tr("\\bassign\\s+")+tr("%1\\s*=\\s*%2\\s*;") \
                                                  .arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                  .arg(ilastInput));
                        }
                        else
                        {
                            ilastPortConnect.append(tr("\n\t""assign %1[%2] = %3[%4] ;").arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key())).arg(pchainSt->m_untotalChainNumber-1)\
                                                    .arg(ilastInput).arg(pchainSt->m_untotalChainNumber-1));
                            iusrCoreCode.append(ilastPortConnect);
                            iaddedCodeList.append(tr("\\bassign\\s+")+tr("%1\\s*\\[\\s*%2\\s*\\]\\s*=\\s*%3\\s*\\[\\s*%4\\s*\\]\\s*;") \
                                                  .arg(tr("_EziDebug_%1_%2_TDO_reg").arg(pchain->getChainName()).arg(iclockIterator.key()))\
                                                  .arg(pchainSt->m_untotalChainNumber-1)\
                                                  .arg(ilastInput).arg(pchainSt->m_untotalChainNumber-1)
                                                  );
                        }
                    }
                }

                ++iclockIterator ;
            }
        }
        else
        {
            ntimesPerChain-- ;
            pmodule->setInstancedTimesPerChain(pchain->getChainName(),ntimesPerChain);
        }

        pchain->addToLineCodeMap(pmodule->getModuleName(),iaddedCodeList);
        pchain->addToBlockCodeMap(pmodule->getModuleName(),iaddedBlockCodeList);
        /*插入到字符串中*/

        ifileData.insert(imodulePos.m_nendModuleKeyWordPos + noffSet ,iusrCoreCode);

        if(!open(QIODevice::WriteOnly|QIODevice::Text|QIODevice::Truncate))
        {
            qDebug() << "Cannot Open file for writing:" << qPrintable(this->errorString());
            return 1 ;
        }

        QTextStream iout(this);
        /*写入文件 */
        iout <<  ifileData ;

        // 记录已经加入了 一系列 用户 core 代码
        pmodule->setAddCodeFlag(true);      

        close();
        ilastModifedTime = ifileInfo.lastModified() ;
        modifyStoredTime(ilastModifedTime);
        return 0 ;
    }
    else
    {
        goto ErrorHandle ;
    }


ErrorHandle:

    /*关闭文件*/
    close();
    return 1 ;

}

int  EziDebugVlgFile::skipCommentaryFind(const QString &rangestring,int startpos ,SEARCH_STRING_STRUCTURE &stringtype,int &targetpos)
{
    int ncommentaryEnd = startpos ;
    int isNoCommentary = 0 ;

    int  nfindPosOther = 0 ;
    int  nfindPos = 0 ;
    int  noffset = 0 ;
    int  nleftBracketPos = 0 ;
    int  nstartPos = 0 ;

    QString imoduleName(tr("No Name")) ;
    QString ikeyWord(tr("No Name"));
    QRegExp ifindExp(tr(" ")) ;
    QRegExp ifindExpOther(tr(" ")) ;


    QString ipartString ;

    if(stringtype.m_etype == SearchModuleKeyWordPos)
    {
        ikeyWord = tr("module");
        imoduleName = QString::fromAscii(stringtype.m_icontent.m_imodulest.m_amoduleName);
        ifindExpOther.setPattern(tr("\\b")+ikeyWord+tr("\\b"));
        ifindExp.setPattern(tr("\\b")+ikeyWord+(tr("\\s+"))+imoduleName);
    }
    else if(stringtype.m_etype == SearchLeftBracketPos)
    {
        ifindExp.setPattern(tr("\\("));
    }
    else if(stringtype.m_etype == SearchSemicolonPos)
    {
        ifindExp.setPattern(tr(";"));
    }
    else
    {
        return 1 ;
    }

    while(1)
    {
        nstartPos = ncommentaryEnd ;
        ipartString = getNoCommentaryString(rangestring,ncommentaryEnd,isNoCommentary) ;
        /*封装成1个函数 用于得到   输入为 上一个注释的结束、下一个注释的开始  输出为 一个无注释的字符串*/
        /* 先扫描 module + module 名 并获得相应位置 */
        /*1、如果没有扫到  直到字符串结束 ；如果最后也没有 就返回错误 ；如果成功就继续下一步 */
        // while 循环
        /*2、接着扫描所有 reg、port、wire、endmodule、instance*/

        /*3、遇到匹配的就 保存相应的字符串的位置 例如 遇到 "reg"  关键字时，从reg 下一个字符 获得 无注释字符串
          查找 紧接着的 ; ，查找直到  最后1段无注释代码 也没有则 退出并返回错误，
         并且重新 从匹配到的字符串后面 重新得到 下一个无注释字符串
        然后继续扫描下个可能匹配的字符，直到遇到endmode 关键字 就退出 或者 最后1段无注释代码 匹配完成之后退出
        当进行匹配 instance 时 分别构造正则表达式，进行匹配，如果匹配到 instance ， 退出条件为最后1段无注释代码
        */

FindString:

        if(SearchModuleKeyWordPos == stringtype.m_etype)
        {
            nfindPosOther = ipartString.indexOf(ifindExpOther) ;
            nfindPos = ipartString.indexOf(ifindExp) ;
            noffset = nstartPos + nfindPos + ifindExp.capturedTexts().at(0).count() ;


            if(NO_STRING_FINDED == nfindPos)
            {
                if(NO_STRING_FINDED == nfindPosOther)
                {
                    /*在无注释情况下查找的*/
                    if(NO_COMMENTARY == isNoCommentary)
                    {
                        return 1 ;
                    }
//                    isNeededFindFlag = true ;
                    /*继续下一轮查找*/
                    continue ;
                }
                else
                {
                    noffset = nstartPos + nfindPosOther + ifindExpOther.capturedTexts().count();

                    struct SEARCH_STRING_STRUCTURE inextFindSemicolon ;
                    inextFindSemicolon.m_etype =  SearchSemicolonPos ;
                    inextFindSemicolon.m_icontent.m_nreserved = 0 ;
                    int nSemicolonPos = 0 ;
                    /*查找 下一个有效的 ";" 字符 */
                    if(!skipCommentaryFind(rangestring,noffset,inextFindSemicolon,nSemicolonPos))
                    {
                        /*截取从 module 名字出现的位置  到 ;所有的字符*/
                        QString itruncateString  = rangestring.mid(nfindPosOther,nSemicolonPos-nfindPosOther-1);
                        PORT_ANNOUNCE_FORMAT iportAnnounceformat = NonAnsicFormat ;
                        int  nrelativeRightBracketPos = 0 ;
                        int  nresult = 0 ;
                        /*判断这段字符是否 匹配 module + module名  并判断是否为规范的port声明*/
                        nresult =isModuleDefinition(itruncateString,imoduleName,iportAnnounceformat,nrelativeRightBracketPos) ;
                        if(!nresult)
                        {
                            // 保存相应的位置  以及  类型信息
                            /*找到 module */
                            stringtype.m_icontent.m_imodulest.m_eportAnnounceFormat = iportAnnounceformat ;
                            /*计算 ")" 绝对位置*/
                            targetpos = nrelativeRightBracketPos + nfindPosOther ;
                            int nlastNoblankChar = rangestring.lastIndexOf(QRegExp("\\S"),(targetpos-1));
                            targetpos = nlastNoblankChar +1 ;
                            return 0 ;
                        }
                        else if(1 == nresult)
                        {
//                          isNeededFindFlag = true ;
                            /*继续下一轮查找*/
                            continue;
                        }
                        else
                        {
                           return 1 ;
                        }

                    }
                    else
                    {
                        return 1 ;
                    }
                }
            }// if(NO_STRING_FINDED == nfindPos)

            SEARCH_STRING_STRUCTURE inextFind ;
            inextFind.m_etype = SearchLeftBracketPos ;
            inextFind.m_icontent.m_nreserved = 0 ;

            int nleftBracketPos = 0 ;
            if(!skipCommentaryFind(rangestring,noffset,inextFind,nleftBracketPos))
            {
                /*查找 与之对应的 下一个 ")"*/
                struct  SEARCH_MODULE_STRUCTURE imoduleSt ;
                imoduleSt.m_eportAnnounceFormat = NonAnsicFormat ;
                strcpy(imoduleSt.m_amoduleName,imoduleName.toAscii().data());
                struct  SEARCH_STRING_STRUCTURE inextFindRightBracket ;
                inextFindRightBracket.m_etype = SearchModuleKeyWordPos ;
                inextFindRightBracket.m_icontent.m_imodulest = imoduleSt ;
                int nrightBracketPos = noffset ;
                qDebug() << rangestring.mid(nleftBracketPos+1,100);
                if(!findOppositeBracket(rangestring,nleftBracketPos+1,inextFindRightBracket,nrightBracketPos))
                {
                    targetpos = nrightBracketPos ;
                    int nlastNoblankChar = rangestring.lastIndexOf(QRegExp("\\S"),(targetpos-1));
                    targetpos = nlastNoblankChar + 1 ;
                    /*接着返回 module 端口的书写类型 是否为标准 */
                    stringtype.m_icontent.m_imodulest.m_eportAnnounceFormat =  \
                            inextFindRightBracket.m_icontent.m_imodulest.m_eportAnnounceFormat ;
                    // 保存相应的位置  以及  类型信息
                   return 0 ;
                }
                else
                {
                    return 1 ;
                }
            }
            else
            {
                return 1 ;
            }
        } //if(SearchModuleKeyWordPos == stringtype.m_etype)
        else if(stringtype.m_etype == SearchLeftBracketPos)
        {
            nleftBracketPos = ipartString.indexOf(ifindExp) ;

            if(NO_STRING_FINDED == nleftBracketPos)
            {
                /*在字符串无注释情况下查找的*/
                if(NO_COMMENTARY == isNoCommentary)
                {
                    return 1 ;
                }
                continue ;
            }
            else
            {
                nleftBracketPos += nstartPos ;
                targetpos = nleftBracketPos ;
                return 0 ;
            }
        }
        else if(stringtype.m_etype == SearchSemicolonPos)
        {
            int nBackToBackSemicolonPos = 0 ;
            nBackToBackSemicolonPos = ipartString.indexOf(ifindExp) ;
            if(NO_STRING_FINDED == nBackToBackSemicolonPos)
            {
                /*在字符串无注释情况下查找的*/
                if(NO_COMMENTARY == isNoCommentary)
                {
                    return 1 ;
                }
                continue ;
            }
            else
            {
                nBackToBackSemicolonPos += nstartPos ;
                targetpos = nBackToBackSemicolonPos ;
                return 0 ;
            }
        }
        else if(stringtype.m_etype == SearchRightBracketPos)
        {
            // do nothing
        }
        else
        {
            return 1 ;
        }

        if(1 == isNoCommentary)
        {
            goto FindString ;
        }

      } // while(1)


      return 0 ;
    }

int EziDebugVlgFile::matchingTargetString(const QString &rangestring ,SEARCH_MODULE_POS_STRUCTURE &modulepos ,QMap<QString,SEARCH_INSTANCE_POS_STRUCTURE*> &instanceposmap)
{
    // 传入的是 无注释的字符串
    /*port(output input)*/
    QString ipartString ;
    QString imoduleName ;
    QString iinstanceName ;

    int ncommentaryEnd = modulepos.m_nnextRightBracketPos + 1;
    int isNoCommentary = 0 ;
    int nlastRegtKeyWordPos = -1 ;
    int nlastWireKeyWordPos = -1 ;
    int nendmoduleKeyWordPos = -1 ;

    int  nfindPosOther = 0 ;
    int  nfindPos = 0 ;
    int  noffset = 0 ;
    int  nsaveStartPos = 0 ;
    int  nendInsertPos = 0 ;
    int  nendLastChar = 0 ;
    int  nannounceInsertPos  = 0 ;

    bool ismoduleEnd = false ;
    QRegExp ifindOutputPortExp(tr("\\b") + tr("output") +tr("\\b")) ;
    QRegExp ifindInputPortPortExpOther(tr("\\b") + tr("input") +tr("\\b")) ;
    /*reg*/
    QRegExp ifindRegExp(tr("\\b") + tr("reg") +tr("\\b"));
    /*wire*/
    QRegExp ifindWireExp(tr("\\b") + tr("wire") +tr("\\b"));
    /*endmodule*/
    QRegExp ifindEndmoduleExp(tr("\\b") + tr("endmodule") +tr("\\b"));

    QRegExp ifindInstanceExp(tr(" "));
    QRegExp ifindInstanceExpOther(tr(" "));


    while(1)
    {
        nsaveStartPos = ncommentaryEnd ;
        ipartString = getNoCommentaryString(rangestring,ncommentaryEnd,isNoCommentary) ;

        nendmoduleKeyWordPos = ipartString.indexOf(ifindEndmoduleExp);
        if(nendmoduleKeyWordPos != -1)
        {
            /*保存相应位置*/
            // endmodule 关键字不能为 顶头字符串,否则从 最后查找
            if(nendmoduleKeyWordPos)
            {
                if(ipartString.lastIndexOf(QRegExp(tr("\\S")),nendmoduleKeyWordPos -1) != -1)
                {
                    nendInsertPos = nsaveStartPos + ipartString.lastIndexOf(QRegExp(tr("\\S")),nendmoduleKeyWordPos -1) ;
                }
            }

            modulepos.m_nendModuleKeyWordPos = nendInsertPos + 1;

            ismoduleEnd = true ;
        }
        else
        {
            if(-1 != ipartString.lastIndexOf(QRegExp(tr("\\S"))))
            {
                qDebug() << ipartString ;
                nendInsertPos = nsaveStartPos + ipartString.lastIndexOf(QRegExp(tr("\\S"))) ;
            }
        }

        // 非标准则进行扫描 最后个端口位置
        if(NonAnsicFormat == modulepos.m_eportFormat)
        {
            if(ipartString.contains(ifindOutputPortExp)||ipartString.contains(ifindInputPortPortExpOther))
            {
                int nlastPortKeyWordPos = 0 ;
                int noutputKeyWordPos = ipartString.lastIndexOf(ifindOutputPortExp,nendmoduleKeyWordPos) ;
                int ninputKeyWordPos = ipartString.lastIndexOf(ifindInputPortPortExpOther,nendmoduleKeyWordPos) ;


                if(-1 == ninputKeyWordPos)
                {
                    nlastPortKeyWordPos = nsaveStartPos + noutputKeyWordPos ;
                }
                else if(-1 == noutputKeyWordPos)
                {
                    nlastPortKeyWordPos = nsaveStartPos + ninputKeyWordPos ;
                }
                else
                {
                    if(noutputKeyWordPos > ninputKeyWordPos)
                    {
                        nlastPortKeyWordPos = nsaveStartPos + noutputKeyWordPos ;
                    }
                    else
                    {
                        nlastPortKeyWordPos = nsaveStartPos + ninputKeyWordPos ;
                    }
                }

                /*保存相应位置*/
                /*找到 紧接着的 ";" */
                struct SEARCH_STRING_STRUCTURE inextFind ;
                inextFind.m_etype = SearchSemicolonPos ;
                inextFind.m_icontent.m_nreserved = 0 ;
                int  nsemicolonPos = 0 ;
                if(!skipCommentaryFind(rangestring , nlastPortKeyWordPos , inextFind , nsemicolonPos))
                {
                    // 然后保存 继续下一个判断
                    modulepos.m_nlastPortKeyWordPos = nsemicolonPos + 1;
                }
                else
                {
                    return 1 ;
                }
            }
        }


        QMap<QString,SEARCH_INSTANCE_POS_STRUCTURE*>::iterator i = instanceposmap.begin();
        while (i != instanceposmap.end())
        {
            struct SEARCH_INSTANCE_POS_STRUCTURE *pinstance = i.value() ;
            imoduleName = QString::fromAscii(pinstance->m_amoduleName);
            iinstanceName = QString::fromAscii(pinstance->m_ainstanceName) ;
            ifindInstanceExp.setPattern(tr("\\b")+ imoduleName + tr("\\s+") + iinstanceName +tr("\\b"));
            ifindInstanceExpOther.setPattern(tr("\\b")+imoduleName+tr("\\b"));

            /*搜索 例化模块 出现的位置*/
            /*判断例化的类型 并返回紧接着的与第一次出现 "(" 相对应的 ")" 的位置 */
            nfindPosOther = ipartString.indexOf(ifindInstanceExpOther) ;
            nfindPos = ipartString.indexOf(ifindInstanceExp) ;
            noffset = nsaveStartPos + nfindPos + ifindInstanceExp.capturedTexts().at(0).count() ;

            if(NO_STRING_FINDED == nfindPos)
            {
                if(NO_STRING_FINDED == nfindPosOther)
                {
                    /*在无注释情况下查找的*/
                    if(NO_COMMENTARY == isNoCommentary)
                    {
                        return 1 ;
                    }
                    /*继续下一轮查找 1 个 例化 */
                    i++ ;
                    continue ;
                }
                else
                {
                    noffset = nsaveStartPos + nfindPosOther + ifindInstanceExpOther.capturedTexts().count() ;
                    /*查找紧接着的左括号 */
                    /*查找与左括号对应的 右括号 */
                    /*返回找到的位置 如果错误则 返回*/
                    struct SEARCH_STRING_STRUCTURE inextFindSemicolon ;
                    inextFindSemicolon.m_etype = SearchSemicolonPos ;
                    inextFindSemicolon.m_icontent.m_nreserved = 0 ;

                    int nrightSemicolonPos = 0 ;
                    /*查找 下一个有效的 ";" 字符 */
                    if(!skipCommentaryFind(rangestring,noffset,inextFindSemicolon,nrightSemicolonPos))
                    {
                        /*截取从 module 名字出现的位置  到 ;所有的字符*/
                        QString itruncateString  = rangestring.mid(nfindPosOther,nrightSemicolonPos-nfindPosOther +1);
                        INSTANCE_FORMAT iinstance_format = NonStardardFormat ;
                        int nresult = 0 ;
                        int nrelativeRightBracketPos = 0 ;
                        nresult = isModuleInstance(itruncateString,imoduleName,iinstanceName,iinstance_format,nrelativeRightBracketPos) ;

                        if(rangestring.lastIndexOf(QRegExp(tr("\\S")),(nsaveStartPos + nfindPosOther -1)) != -1)
                        {
                            nannounceInsertPos = rangestring.lastIndexOf(QRegExp(tr("\\S")),(nsaveStartPos + nfindPosOther -1)) ;
                        }

                        /*判断这段字符是否 匹配 module名+例化名  并判断是否为规范的端口连接*/
                        if(!nresult)
                        {
                            /*找到 module 保存信息*/
                            pinstance->m_nnextRightBracketPos = nrelativeRightBracketPos +  nfindPosOther ;
                            pinstance->m_nstartPos  = nannounceInsertPos + 1 ;
                            pinstance->m_einstanceFormat = iinstance_format ;
                            i++ ;
                            continue ;
                        }
                        else if(1 == nresult)
                        {
//                          isNeededFindFlag = true ;
                            /*继续下一轮查找*/
                            i++ ;
                            continue ;
                        }
                        else
                        {
                            return 1 ;
                        }
                    }
                    else
                    {
                        return 1 ;
                    }
                }
            }

            struct SEARCH_STRING_STRUCTURE inextFind ;
            inextFind.m_etype = SearchLeftBracketPos ;
            inextFind.m_icontent.m_eInstanceFormat = NonStardardFormat ;

            if(rangestring.lastIndexOf(QRegExp(tr("\\S")),(nsaveStartPos + nfindPos -1)) != -1)
            {
                nannounceInsertPos = rangestring.lastIndexOf(QRegExp(tr("\\S")),(nsaveStartPos + nfindPos -1)) ;
            }

            int nleftBracketPos = 0 ;
//          QString itest1 = rangestring.mid(noffset);
//          qDebug() << itest1 ;
            if(!skipCommentaryFind(rangestring,noffset,inextFind,nleftBracketPos))
            {
                /*查找 与之对应的 下一个 ")"*/
                struct SEARCH_STRING_STRUCTURE inextFindRightBracket ;
                inextFindRightBracket.m_etype = SearchInstancePos ;
                inextFindRightBracket.m_icontent.m_eInstanceFormat = NonStardardFormat ;

                int nrightBracketPos = 0 ;
                if(!findOppositeBracket(rangestring,nleftBracketPos+1,inextFindRightBracket,nrightBracketPos))
                {
                      QString itest2 = rangestring.mid(noffset,nrightBracketPos - nleftBracketPos - 1);
                      QString itest3 = rangestring.mid(nannounceInsertPos , nrightBracketPos - nannounceInsertPos - 1);
                      pinstance->m_nnextRightBracketPos = nrightBracketPos ;
                      pinstance->m_nstartPos  = nannounceInsertPos + 1 ;
                      pinstance->m_einstanceFormat = inextFindRightBracket.m_icontent.m_eInstanceFormat ;

                      /*接着返回 module 端口的书写类型 是否为标准 */
//                    stringtype.m_isearchContent.m_iinstanceStructure.m_einstanceFormat =  \
//                            inextFindRightBracket.m_isearchContent.m_iinstanceStructure.m_einstanceFormat ;
                      ++i ;
                      continue ;
                }
                else
                {
                    return 1 ;
                }
            }
            else
            {
                return 1 ;
            }

            ++i;
        }

        if(ismoduleEnd)
        {
            return 0 ;
        }

        // 正常时扫描到 endmodule 关键字 再退出 ，不应该在无注释下 没扫描到  endmodule 退出
        if(isNoCommentary)
        {
            return 1 ;
        }
    }
}



int EziDebugVlgFile::findOppositeBracket(const QString &rangestring,int startpos ,SEARCH_STRING_STRUCTURE &stringtype,int &targetpos)
{
    int ncommentaryBegin = 0 ;
    int ncommentaryEnd   = startpos ;
    QString ipartString ;
    QString inoCommentaryStr ;
    QString icheckString ;
    QString itestString ;

    int commentaryBegin_row  = 0 ; // 行注释开始
    int commentaryBegin_sec  = 0 ; // 段注释开始
    int scanPos = startpos ;
    int nsavePos = 0 ;
    int nstartBracketPos = 0 ;

    //bool isNeededFindFlag = 0 ;
    int  nappearanceCount = 1 ;
    int  nleftBracketPos = 0 ;
    int  nrightBracketPos = 0 ;
    //inoCommentaryStr = replaceCommentaryByBlank(rangestring) ;
//    QFile itest("d:/save.txt") ;
//    itest.open(QIODevice::WriteOnly|QIODevice::Truncate);

//    QTextStream iout(&itest) ;
//    iout << inoCommentaryStr ;
//    int Pos1 = rangestring.indexOf("ifft_airif_rdctrl");
//    int Pos2 = inoCommentaryStr.indexOf("ifft_airif_rdctrl");

    while(1)
    {
        // 查找下一个 注释的开始位置
        commentaryBegin_row = rangestring.indexOf(tr("//"),scanPos) ;
        commentaryBegin_sec = rangestring.indexOf(tr("/*"),scanPos) ;

        if((commentaryBegin_row == -1)&&(commentaryBegin_sec == -1))
        {
            /*没有注释了 从scanPos 截取剩余所有的字符串 */
            ipartString = rangestring.mid(ncommentaryEnd) ;
            nsavePos = ncommentaryEnd ;
            ncommentaryEnd = NO_COMMENTARY ;
        }
        else if(commentaryBegin_row == -1)
        {
            /*下一个注释开始位置为 */
            ncommentaryBegin = commentaryBegin_sec ;
            ipartString = rangestring.mid(ncommentaryEnd,ncommentaryBegin-ncommentaryEnd) ;
            nsavePos = ncommentaryEnd ;
            // 下一个注释结束位置 */
            ncommentaryEnd = rangestring.indexOf(tr("*/"),ncommentaryBegin) ;

            if(ncommentaryEnd == -1)
            {
                return 1;
            }
            scanPos = ncommentaryEnd + 2 ;
        }
        else if(commentaryBegin_sec == -1)
        {
            /*下一个注释开始位置为 */
            ncommentaryBegin = commentaryBegin_row ;
            ipartString = rangestring.mid(ncommentaryEnd,ncommentaryBegin-ncommentaryEnd) ;

            nsavePos = ncommentaryEnd ;
            ncommentaryEnd = rangestring.indexOf(tr("\n"),ncommentaryBegin) ;
            if(ncommentaryEnd == -1)
            {
                return 1;
            }
            scanPos = ncommentaryEnd + 1;
        }
        else
        {
            if(commentaryBegin_row < commentaryBegin_sec)
            {
                ncommentaryBegin = commentaryBegin_row ;
                ipartString = rangestring.mid(ncommentaryEnd,ncommentaryBegin-ncommentaryEnd) ;
                nsavePos = ncommentaryEnd ;
                ncommentaryEnd = rangestring.indexOf(tr("\n"),ncommentaryBegin) ;
                if(ncommentaryEnd == -1)
                {
                    return 1 ;
                }
                scanPos = ncommentaryEnd + 1;
            }
            else
            {
                ncommentaryBegin = commentaryBegin_sec ;
                ipartString = rangestring.mid(ncommentaryEnd,ncommentaryBegin-ncommentaryEnd) ;
                nsavePos = ncommentaryEnd ;
                ncommentaryEnd = rangestring.indexOf(tr("*/"),ncommentaryBegin) ;
                if(ncommentaryEnd == -1)
                {
                    return 1;
                }
                scanPos = ncommentaryEnd + 2 ;
            }
        }

        //int  nstartPos = startpos ;

        /*从这段无注释的代码中 找对应的括号的位置*/

        /*如果这段无注释 代码 包含 "output" 或者 "input "关键字，则为*/

        if(-1 == nsavePos)
        {
            return 1 ;
        }


        qDebug() << ipartString ;
        nstartBracketPos = 0 ;
        while(1)
        {
            /*是否存在 左括号 和 右括号*/
            nleftBracketPos = ipartString.indexOf("(",nstartBracketPos);
            nrightBracketPos = ipartString.indexOf(")",nstartBracketPos);

            if((NO_STRING_FINDED == nleftBracketPos)&&(NO_STRING_FINDED == nrightBracketPos))
            {
                break ;
            }
            else if(NO_STRING_FINDED == nleftBracketPos)
            {
                /*只有 ")"*/
                nappearanceCount-- ;
                if(0 == nappearanceCount)
                {
                    goto CheckType ;
                }
                nstartBracketPos = nrightBracketPos + 1 ;
            }
            else if(NO_STRING_FINDED == nrightBracketPos)
            {
                /*只有 "("*/
                nstartBracketPos = nleftBracketPos + 1 ;
                nappearanceCount++ ;
            }
            else
            {
                if(nleftBracketPos < nrightBracketPos)
                {
                    /*遇到 "("*/
                    nappearanceCount++ ;
                    nstartBracketPos = nleftBracketPos + 1 ;
                }
                else
                {
                    /*遇到 ")"*/
                    nappearanceCount-- ;

                    if(0 == nappearanceCount)
                    {

                        goto CheckType ;
                    }
                    nstartBracketPos = nrightBracketPos + 1 ;
                }
            }
        }
    }

CheckType:
        qDebug() << rangestring.mid(nsavePos,nrightBracketPos);
        targetpos = nsavePos + nrightBracketPos ;
        int n = targetpos - startpos + 1 ;
        icheckString = rangestring.mid(startpos , n );
        qDebug() << "origin string! "<<icheckString ;
        icheckString = replaceCommentaryByBlank(icheckString);
        qDebug() << "port string! "<<icheckString ;

        //itestString = rangestring.mid(scanPos ,targetpos - scanPos + 1 );
        if(SearchModuleKeyWordPos == stringtype.m_etype)
        {
            if(icheckString.contains("input",Qt::CaseInsensitive)||icheckString.contains("output",Qt::CaseInsensitive))
            {
                stringtype.m_icontent.m_imodulest.m_eportAnnounceFormat = AnsicFormat ;
            }
        }
        else if(SearchInstancePos == stringtype.m_etype)
        {
            // .mc_ul_start       ( mc_ul_start       ),
            // 标准的 查找 上一个 ")"
            if(icheckString.contains(QRegExp(tr(".")+ tr("\\s*\\w+") + tr("\\s*\\(")+ tr(".*") + tr("\\)"))))
            {
                stringtype.m_icontent.m_eInstanceFormat = StardardForamt ;
                targetpos = ipartString.lastIndexOf(')',nrightBracketPos-1);
                if(-1 == targetpos)
                {
                   return 1 ;
                }
                targetpos = nsavePos + targetpos + 1 ;
            }
            else
            {
                // 非标准的 查找 上一个 非空白字符
                targetpos = ipartString.lastIndexOf(QRegExp(tr("\\S")),nrightBracketPos-1);
                if(-1 == targetpos)
                {
                   return 1 ;
                }
                targetpos = nsavePos + targetpos + 1 ;
            }
        }
        else
        {
            return 1 ;
        }

    return 0 ;
}


QString EziDebugVlgFile::getNoCommentaryString(const QString &rangestring,int &lastcommentaryend ,int &nocommontaryflag)
{
    int commentaryBegin_row = 0 ;
    int commentaryBegin_sec = 0 ;
    int scanPos = lastcommentaryend ;
    int ncommentaryEnd = 0 ;
    int ncommentaryBegin = 0 ;
    QString ipartString ;
    // 查找下一个 注释的开始位置

    if(lastcommentaryend == -1)
    {
        /*全是注释  返回空字符串*/
        ipartString.clear();
        return ipartString ;
    }

    commentaryBegin_row = rangestring.indexOf(tr("//"),scanPos) ;
    commentaryBegin_sec = rangestring.indexOf(tr("/*"),scanPos) ;

    if((commentaryBegin_row == -1)&&(commentaryBegin_sec == -1))
    {
        ipartString = rangestring.mid(scanPos) ;
        /*没有注释了 从scanPos 截取剩余所有的字符串 */
        ncommentaryEnd = -1 ;
        // 最后一次扫描 的起始位置  就无注释
        lastcommentaryend =  scanPos ;
        nocommontaryflag = true ;
    }
    else if(commentaryBegin_row == -1)
    {
        /*下一个注释开始位置为 */
        ncommentaryBegin = commentaryBegin_sec ;
        ipartString = rangestring.mid(scanPos,ncommentaryBegin-scanPos) ;

        // 下一个注释结束位置 */
        ncommentaryEnd = rangestring.indexOf(tr("*/"),ncommentaryBegin) ;
        if(ncommentaryEnd == -1)
        {
            // 接下来都是注释
            lastcommentaryend = -1 ;
            return ipartString ;
        }
        lastcommentaryend = ncommentaryEnd  + 2;
    }
    else if(commentaryBegin_sec == -1)
    {
        /*下一个注释开始位置为 // */
        ncommentaryBegin = commentaryBegin_row ;
        ipartString = rangestring.mid(scanPos,ncommentaryBegin-scanPos) ;


        ncommentaryEnd = rangestring.indexOf(tr("\n"),ncommentaryBegin + 2);
        if(ncommentaryEnd == -1)
        {
            // 接下来都是注释
            lastcommentaryend = -1 ;
            return ipartString ;
        }
        lastcommentaryend =  ncommentaryEnd + 1;
    }
    else
    {
        if(commentaryBegin_row < commentaryBegin_sec)
        {
            ncommentaryBegin = commentaryBegin_row ;
            ipartString = rangestring.mid(scanPos,ncommentaryBegin-scanPos) ;

            ncommentaryEnd = rangestring.indexOf(tr("\n"),ncommentaryBegin) ;
            if(ncommentaryEnd == -1)
            {
                // 接下来都是注释
                lastcommentaryend = -1 ;
                return ipartString ;
            }
            lastcommentaryend =  ncommentaryEnd + 1 ;
        }
        else
        {
            ncommentaryBegin = commentaryBegin_sec ;
            ipartString = rangestring.mid(scanPos,ncommentaryBegin-scanPos) ;

            ncommentaryEnd = rangestring.indexOf(tr("*/"),ncommentaryBegin) ;
            if(ncommentaryEnd == -1)
            {
                // 接下来都是注释
                lastcommentaryend = -1 ;
                return ipartString ;

            }
            lastcommentaryend =  ncommentaryEnd + 2 ;
        }
    }
    return  ipartString ;
}



QString EziDebugVlgFile::replaceCommentaryByBlank(const QString &rangestring)
{
    QString data = rangestring ;
    int commentaryBegin_row = 0 ; // 行注释开始
    int commentaryBegin_sec = 0 ; // 段注释开始
    int commentaryEnd_row = 0 ;  // 行注释结束
    int commentaryEnd_sec = 0 ;  // 段注释结束
    int nstartPos = 0 ;

    commentaryBegin_row =  data.indexOf(tr("//"),nstartPos);
    commentaryBegin_sec =  data.indexOf(tr("/*"),nstartPos);
    while((commentaryBegin_row != -1)||(commentaryBegin_sec != -1))
    {
        if(commentaryBegin_row == -1)
        {
            commentaryEnd_sec = data.indexOf(tr("*/"), commentaryBegin_sec);
            data.replace(commentaryBegin_sec,commentaryEnd_sec - commentaryBegin_sec + 2,tr(" ").repeated(commentaryEnd_sec - commentaryBegin_sec + 2));
            commentaryBegin_sec =  data.indexOf(tr("/*"), commentaryBegin_sec);
        }
        else if(commentaryBegin_sec == -1)
        {
            commentaryEnd_row = data.indexOf(tr("\n"), commentaryBegin_row);
            if(commentaryEnd_row == -1)
            {
                int ncharPos = data.lastIndexOf(QRegExp(".*")) ;
                data.replace(commentaryBegin_row , ncharPos - commentaryBegin_row + 1,tr(" ").repeated(ncharPos - commentaryBegin_row + 1));
            }
            else
            {
                data.replace(commentaryBegin_row,commentaryEnd_row - commentaryBegin_row,tr(" ").repeated(commentaryEnd_row - commentaryBegin_row));
            }
            commentaryBegin_row =  data.indexOf(tr("//"), commentaryBegin_row);

        }
        else
        {
            /*行注释开始 在 段注释开始 之前*/
            if( commentaryBegin_row < commentaryBegin_sec )
            {
                /*删除行注释表示符开始后的一行字符*/
                commentaryEnd_row = data.indexOf(tr("\n"), commentaryBegin_row);
                if(commentaryEnd_row == -1)
                {
                    int ncharPos = data.lastIndexOf(QRegExp(".*")) ;
                    data.replace(commentaryBegin_row , ncharPos - commentaryBegin_row + 1,tr(" ").repeated(ncharPos - commentaryBegin_row + 1));
                }
                else
                {
                    data.replace(commentaryBegin_row,commentaryEnd_row - commentaryBegin_row,tr(" ").repeated(commentaryEnd_row - commentaryBegin_row));
                }
                commentaryBegin_sec =  data.indexOf(tr("/*"), commentaryBegin_row);
                commentaryBegin_row =  data.indexOf(tr("//"), commentaryBegin_row);
            }
            /*段注释开始 在 行注释开始 之前*/
            else
            {
                commentaryEnd_sec = data.indexOf(tr("*/"), commentaryBegin_sec);
                data.replace(commentaryBegin_sec,commentaryEnd_sec - commentaryBegin_sec + 2,tr(" ").repeated(commentaryEnd_sec - commentaryBegin_sec + 2));
                commentaryBegin_row =  data.indexOf(tr("//"), commentaryBegin_sec);
                commentaryBegin_sec =  data.indexOf(tr("/*"), commentaryBegin_sec);
            }
        }

    }
    return data ;
}

int EziDebugVlgFile::isModuleInstance(const QString &rangestring,const QString &modulename , const QString& instancename,INSTANCE_FORMAT &type ,int &targetpos)
{
    QString data = replaceCommentaryByBlank(rangestring);

    QRegExp ifindExp(tr("\\b")+ modulename + tr("\\s+") + instancename +tr("\\b")) ;

    if(NO_STRING_FINDED == data.indexOf(ifindExp))
    {
        return 1 ;
    }

    /*找到接着的 "("*/
    struct SEARCH_STRING_STRUCTURE ifindLeftBracket ;
    ifindLeftBracket.m_etype = SearchLeftBracketPos ;
    ifindLeftBracket.m_icontent.m_nreserved = 0  ;

    int nleftBracketPos = 0 ;
    if(!skipCommentaryFind(rangestring,0,ifindLeftBracket,nleftBracketPos))
    {
        struct SEARCH_STRING_STRUCTURE ifindRightBracket ;
        ifindRightBracket.m_etype = SearchInstancePos ;
        ifindRightBracket.m_icontent.m_eInstanceFormat = NonStardardFormat ;

        int nrightBracketPos = 0 ;
        if(!findOppositeBracket(rangestring,nleftBracketPos+1,ifindRightBracket,nrightBracketPos))
        {
            targetpos = nrightBracketPos ;
            type = ifindRightBracket.m_icontent.m_eInstanceFormat ;
            return 0 ;
        }
        else
        {
            return 2 ;
        }
    }
    else
    {
        return 2 ;
    }
}


int EziDebugVlgFile::isModuleDefinition(const QString &rangestring,const QString &modulename ,PORT_ANNOUNCE_FORMAT &type,int &targetpos)
{
    QString data = replaceCommentaryByBlank(rangestring);

    QRegExp ifindExp(tr("\\b")+ modulename + tr("\\b")) ;

    if(NO_STRING_FINDED == data.indexOf(ifindExp))
    {
        return 1 ;
    }

    /*找到接着的 "("*/
    struct SEARCH_STRING_STRUCTURE ifindLeftBracket ;
    ifindLeftBracket.m_etype = SearchLeftBracketPos ;
    ifindLeftBracket.m_icontent.m_nreserved = 0 ;

    int nleftBracketPos = 0 ;
    if(!skipCommentaryFind(rangestring,0,ifindLeftBracket,nleftBracketPos))
    {
        struct  SEARCH_MODULE_STRUCTURE imoduleSt ;
        struct SEARCH_STRING_STRUCTURE ifindRightBracket ;
        ifindRightBracket.m_etype = SearchRightBracketPos ;
        imoduleSt.m_eportAnnounceFormat = NonAnsicFormat ;
        strcpy(imoduleSt.m_amoduleName,modulename.toAscii().data());
        ifindRightBracket.m_icontent.m_imodulest = imoduleSt ;


        int nrightBracketPos = 0 ;
        if(!findOppositeBracket(rangestring,nleftBracketPos+1,ifindRightBracket,nrightBracketPos))
        {
            targetpos = nrightBracketPos ;
            type = ifindRightBracket.m_icontent.m_imodulest.m_eportAnnounceFormat ;
            return 0 ;
        }
        else
        {
            return 2 ;
        }
    }
    else
    {
        return 2 ;
    }

//    // 存在 output 或者 input 关键字
//    ifindExp.setPattern(tr("\\b") + tr("output") + tr("\\b"));
//    QRegExp ifindExpOther(tr("\\b") + tr("input") + tr("\\b"));

//    if(data.contains(ifindExp)||data.contains(ifindExpOther))
//    {
//        type = AnsicFormat ;
//    }
//    else
//    {
//        type = NonAnsicFormat ;
//    }

}

int EziDebugVlgFile::isStringReiteration(const QString &poolstring ,const QString& string)
{
    if(poolstring.contains(QRegExp(tr("\b")+string + tr("\b"))))
    {
        return 0 ;
    }
    return 1 ;
}

QString  EziDebugVlgFile::constructChainRegString(EziDebugModule::RegStructure* reg, int regnum , int startbit ,int endbit ,EziDebugInstanceTreeItem *item)
{
    QString iregName ;
    QString istartBit ;
    QString iendBit ;
    QString imoduleName = QString::fromAscii(reg->m_pMouduleName);
    QStringList ifullNameList ;
    QString ibitWitdth = QString::fromAscii(reg->m_pExpString);

    QString istartRegNum = QString::number(reg->m_unStartNum);
    QString iendRegNum = QString::number(reg->m_unEndNum);

    QString ihiberarchyname = item->getItemHierarchyName() ;
    QString iinstanceName = item->getInstanceName() ;

    QString iregNum = QString::fromAscii(reg->m_pregNum);
    QString iclockName = QString::fromAscii(reg->m_pclockName);

    QString iresult ;
    if(!reg)
    {
        return QString();
    }
    else
    {
        // 寄存器名 包括数组时 使用  aaa[m]
        if(reg->m_unRegNum != 1)
        {
            iregName.append(tr("%1[%2]").arg(QString::fromAscii(reg->m_pRegName)).arg(regnum));
        }
        else
        {
            iregName.append(tr("%1").arg(QString::fromAscii(reg->m_pRegName)));
        }

        // 开始位
        istartBit.append(QString::number(startbit));
        // 结束位
        iendBit.append(QString::number(endbit));

    }

    ifullNameList << imoduleName << iinstanceName << iclockName << ihiberarchyname << iregName << istartBit << iendBit << ibitWitdth << istartRegNum  << iendRegNum << iregNum   ;
    iresult = ifullNameList.join(tr("#")) ;
    return (iresult) ;
}


int EziDebugVlgFile::scanFile(EziDebugPrj* prj,EziDebugPrj::SCAN_TYPE type,QList<EziDebugPrj::LOG_FILE_INFO*> &addedinfolist,QList<EziDebugPrj::LOG_FILE_INFO*> &deletedinfolist)
{
    qDebug() << "verilog file scanfile!" << fileName();
    bool echainExistFlag = false ;
    int i = 0 ;
    QString ifileName = fileName() ;
    EziDebugModule *poldModule  = NULL ;
    EziDebugVlgFile *poldFile = NULL ;
    QDir icurrentDir = prj->getCurrentDir() ;
    QString irelativeFileName = icurrentDir.relativeFilePath(this->fileName()) ;
    QStringList ieziPort ;
    QFileInfo ifileInfo(this->fileName()) ;
    QStringList ichangedchainList ;
    QStringList icheckChainList ;
    int nresult = 0 ;

    QDateTime ilastModifedTime = ifileInfo.lastModified() ;


    QMap<QString,QString> iclockMap ;
    QMap<QString,QString> iresetMap ;


    poldFile = prj->getPrjVlgFileMap().value(irelativeFileName ,NULL);

    if(poldFile)
    {
        for( ; i < poldFile->getModuleList().count();i++)
        {
            EziDebugModule *pmodule = prj->getPrjModuleMap().value(poldFile->getModuleList().at(i),NULL) ;
            if(pmodule)
            {
                QString imoduleName = pmodule->getModuleName() ;
                struct EziDebugPrj::LOG_FILE_INFO* pdelmoduleInfo = new EziDebugPrj::LOG_FILE_INFO ;
                pdelmoduleInfo->etype = EziDebugPrj::infoTypeModuleStructure ;
                pdelmoduleInfo->pinfo = NULL ;
                qstrcpy(pdelmoduleInfo->ainfoName,imoduleName.toAscii().data());
                deletedinfolist.append(pdelmoduleInfo);
            }
        }
    }

#if 1
    if(fileName().endsWith("SspTxFIFO.v"))
    {
        qDebug() << "SspTxFIFO.v";
    }
#endif

    // 清空原文件的  modulelist
    clearModuleList();

    unModuCnt = 0  ;
    unMacroCnt = 0 ;

    //  memset((void*)module_tab,0,MAX_T_LEN*sizeof(struct Module_Mem)) ;
    //  memset((void*)macro_table,0,MAX_T_LEN*sizeof(struct macro_Mem)) ;

    inst_map.clear();
    iinstNameList.clear();

    reg_scan reg_search ;

    memset((void*)buffer,0,sizeof(buffer)) ;

    //qDebug()  <<  ifileName.toAscii().data() ;
    if(reg_search.LoadVeriFile(buffer,ifileName.toAscii().data()))
    {
        reg_search.prog = buffer ;
        try
        {
            reg_search.ScanPre();
            reg_search.Interp();
        }
        catch (InterpExc &except)
        {
            qDebug() << "EziDebug file parse Error!" ;
            return 1 ;
        }
    }
    else
    {
        qDebug() << "EziDebug Error: read file error!" ;
        return 1 ;
    }


    //qDebug() << "Find Module Number:"  << mod_count;

    for(i = 0 ; i < unModuCnt ;i++)
    {    	
        QString imoduleName = QString::fromAscii(ModuleTab[i].cModuleName) ;
        EziDebugModule *pmodule = new EziDebugModule(imoduleName) ;
        if(!pmodule)
        {
            qDebug() << "There is not memory left!"  ;
            return 1 ;
        }

        //qDebug() << "GET A Module!"  << module_tab[i].inst_map.count() ;

        QMap<QString,QMap<QString,QString> > iinstMap = inst_map ;
        int ninstanceCount = 0 ;
        for( ; ninstanceCount < iinstNameList.count() ;ninstanceCount++)
        {
            QString iinst = iinstNameList.at(ninstanceCount) ;
            QString iinstanceName = iinst.split('#').at(1) ;

            qDebug() << __LINE__  << "EziDebug instance:" << iinst;

            if(QRegExp(QObject::tr("_EziDebug_\\w+")).exactMatch(iinstanceName))
            {
                //ieziInstList.append(iinst.split('#').at(1));

                //echainExistFlag = true ;
                continue ;
            }

            pmodule->m_iinstanceNameList << iinst.replace("#",":");
            pmodule->m_iinstancePortMap.insert(iinstanceName,iinstMap.value(iinstNameList.at(ninstanceCount)));
        }


        for(int m = 0 ; m< ModuleTab[i].unParaCnt ;m++)
        {
            pmodule->addToParameterMap(QString::fromAscii(ModuleTab[i].ParaTab[m].cParaName),\
                                       ModuleTab[i].ParaTab[m].iParaVal);

        }

        // 向文件中添加 defparameter 信息
        QMap<QString,QString>::const_iterator idefParamIter = def_map.constBegin() ;
        while(idefParamIter != def_map.constEnd())
        {
             // <inst_name.para_name,para_value>
            QString icombName = idefParamIter.key() ;
            if(!icombName.contains("."))
            {
                qDebug() << "EziDebug Error: scan file Error , parameter pattern error!"  ;
                return 1 ;
            }
            QString iinstanceName = icombName.split(".").at(0) ;

            if(QRegExp(QObject::tr("_EziDebug_\\w+")).exactMatch(iinstanceName))
            {
                ++idefParamIter ;
                continue ;
            }

            QString iparamterStr = icombName.split(".").at(1) ;
            QString iparamterVal = idefParamIter.value() ;

            addToDefParameterMap(iinstanceName,iparamterStr,iparamterVal);
            ++idefParamIter ;
        }

        int j = 0 ;
        // 向文件中添加 define  信息
        for(; j < unMacroCnt ; j++)
        {
           addToMacroMap(QString::fromAscii(MacroTab[j].cMacroName),MacroTab[j].iMacroVal);
        }

        for(j = 0 ;j < ModuleTab[i].unRegCnt ; j++)
        {
            QString iedge ;

            if(QRegExp(QObject::tr("_EziDebug_\\w+")).exactMatch(QString::fromAscii(ModuleTab[i].RegTab[j].cRegName)))
            {
                // 提示 文件中包含有EziDebug添加的代码  是否进行删除

                // 删除指针
                //echainExistFlag = true ;
                continue ;
            }

            if(QString::fromAscii(ModuleTab[i].RegTab[j].ClkAttri.cClkName).isEmpty())
            {
                continue ;
            }

            if(ModuleTab[i].RegTab[j].IsFlag == 0)
            {
                continue ;
            }

            struct EziDebugModule::RegStructure * preg = new EziDebugModule::RegStructure ;


            memset((char*)preg,0,sizeof(struct EziDebugModule::RegStructure));


            qstrcpy(preg->m_pRegName,ModuleTab[i].RegTab[j].cRegName) ;

            if(ModuleTab[i].RegTab[j].iRegWidth.size() >= 64)
            {
                qDebug() << "EziDebug Error: the reg number string is too long!";
                continue ;
            }

            if(ModuleTab[i].RegTab[j].iRegCnt.isEmpty())
            {
                qstrcpy(preg->m_pregNum,"1") ;
            }
            else
            {
                qstrcpy(preg->m_pregNum,ModuleTab[i].RegTab[j].iRegCnt.toAscii().constData());
            }


            if(ModuleTab[i].RegTab[j].iRegWidth.count() >= 64 )
            {
                qDebug() << "EziDebug Error: the reg width string is too long!";
                continue ;
            }

            qstrcpy(preg->m_pExpString , ModuleTab[i].RegTab[j].iRegWidth.toAscii().constData());


            //  初始化寄存器数据
            preg->m_unStartNum = 0 ;
            preg->m_unEndNum = 0 ;
            preg->m_unRegNum = 0 ;

            preg->m_unStartBit = 0 ;
            preg->m_unEndBit = 0 ;
            preg->m_unRegBitWidth = 0 ;


            preg->m_unMaxRegNum = 0 ;
            preg->m_eRegNumEndian = EziDebugModule::endianOther ;
            preg->m_eRegNumType = EziDebugModule::attributeOther ;
            preg->m_unMaxBitWidth = 0 ;
            preg->m_eRegBitWidthEndian = EziDebugModule::endianOther ;
            preg->m_eRegBitWidthType = EziDebugModule::attributeOther ;


            qstrcpy(preg->m_pclockName,ModuleTab[i].RegTab[j].ClkAttri.cClkName);


            if(ModuleTab[i].RegTab[j].ClkAttri.eClkEdge == POSE)
            {
                iedge = QObject::tr("posedge");
                preg->m_eedge =  EziDebugModule::signalPosEdge ;
            }
            else if(ModuleTab[i].RegTab[j].ClkAttri.eClkEdge == NEGE)
            {
                iedge = QObject::tr("negedge");
                preg->m_eedge =  EziDebugModule::signalNegEdge ;
            }
            else if(ModuleTab[i].RegTab[j].ClkAttri.eClkEdge == LOW)
            {
                iedge = QObject::tr("low");
                preg->m_eedge =  EziDebugModule::signalLow ;
            }
            else if(ModuleTab[i].RegTab[j].ClkAttri.eClkEdge == HIGH)
            {
                iedge = QObject::tr("high");
                preg->m_eedge =  EziDebugModule::signalHigh ;
            }
            else
            {
                iedge = QObject::tr("posedge");
                preg->m_eedge =  EziDebugModule::signalPosEdge ;
            }

            if(QString::fromAscii(ModuleTab[i].RegTab[j].ClkAttri.cClkName).isEmpty())
            {
                qDebug() << "no clock " << preg->m_pRegName;
            }

            iclockMap.insert(QString::fromAscii(ModuleTab[i].RegTab[j].ClkAttri.cClkName),\
                             iedge);

            if(ModuleTab[i].RegTab[j].RstAttri.eRstEdge == POSE)
            {
                iedge = QObject::tr("posedge");
            }
            else if(ModuleTab[i].RegTab[j].RstAttri.eRstEdge == NEGE)
            {
                iedge = QObject::tr("negedge");
            }
            else
            {
                iedge = QObject::tr("posedge");
            }


            qstrcpy(preg->m_pMouduleName,ModuleTab[i].cModuleName) ;

            preg->m_unStartNum = 0 ;

            if(!QString::fromAscii(ModuleTab[i].RegTab[j].RstAttri.cRstName).isEmpty())
            {
                iresetMap.insert(QString::fromAscii(ModuleTab[i].RegTab[j].RstAttri.cRstName),\
                                 iedge);
            }

            QString iclockName = QString::fromAscii(preg->m_pclockName);

            // 全部加入 到固定位宽 , 待生成树状节点时,划分出来 非固定位宽
            pmodule->AddToRegMap(iclockName ,preg);

        }

        pmodule->m_iclockMap = iclockMap ;

        pmodule->m_iresetMap = iresetMap ;

        QVector<EziDebugModule::PortStructure*> iportVec ;

        //qDebug() << "scan port !"  ;
        int k = 0 ;
        for(; k < ModuleTab[i].unIOCnt ; k++)
        {
            // 暂时修改
            if(QRegExp(QObject::tr("_EziDebug_\\w+")).exactMatch(QString::fromAscii(ModuleTab[i].IOTab[k].cIOName)))
            {
                QString ieziPortName = QString::fromAscii(ModuleTab[i].IOTab[k].cIOName) ;
                ieziPort <<  ieziPortName ;

                echainExistFlag = true ;
                // 提示 文件中包含有EziDebug添加的代码  是否进行删除
                continue ;

            }

            struct EziDebugModule::PortStructure * pport = new EziDebugModule::PortStructure ;

            memset((char*)pport,0,sizeof(struct EziDebugModule::PortStructure)) ;

            qstrcpy(pport->m_pPortName,ModuleTab[i].IOTab[k].cIOName);

            pport->m_unStartBit = 0 ;
            pport->m_unBitwidth = 0 ;
            pport->m_unEndBit = 0 ;
            pport->m_eEndian  = EziDebugModule::endianOther ;

            if(ModuleTab[i].IOTab[k].iIOWidth.size() >= 64)
            {
                qDebug() << "EziDebug Error: the reg width string is too long!";
                continue ;
            }

            qstrcpy(pport->m_pBitWidth,ModuleTab[i].IOTab[k].iIOWidth.toAscii().constData()) ;

            if(ModuleTab[i].IOTab[k].eIOAttri == IO_INPUT)
            {
                pport->eDirectionType = EziDebugModule::directionTypeInput ;
            }
            else if(ModuleTab[i].IOTab[k].eIOAttri == IO_OUTPUT)
            {
                pport->eDirectionType = EziDebugModule::directionTypeOutput ;
            }
            else if(ModuleTab[i].IOTab[k].eIOAttri == IO_INOUT)
            {
                pport->eDirectionType = EziDebugModule::directionTypeInoutput ;
            }
            else
            {
                pport->eDirectionType = EziDebugModule::directionTypeInoutput ;
            }

            qstrcpy(pport->m_pModuleName,ModuleTab[i].cModuleName);

            iportVec.append(pport);

        }

        pmodule->m_iportVec = iportVec ;

        // QDir(工程路径). relativeFilePath(完整的文件路径) 得到文件相对路径
        pmodule->m_ilocatedFile = prj->getCurrentDir().relativeFilePath(fileName());

        // bool m_isLibaryCore ;
        pmodule->m_isLibaryCore |= ModuleTab[i].nIPCore ;

        if(this->isLibaryFile())
        {
            pmodule->m_isLibaryCore = true ;
        }

        qDebug() << "add to moudle list" << imoduleName << __FILE__ << __LINE__;

        // 加入 module map
        qDebug() << "Add to moudle map" << imoduleName << pmodule << __FILE__ << __LINE__;


        poldModule = prj->getPrjModuleMap().value(imoduleName,NULL) ;

        // 扫描完成后再 提示 信息 扫描链被破坏  是否重新添加链
#if 0
        if(pmodule->getModuleName() == "ifft")
        {
            qDebug() << "ifft" ;
        }
#endif
        addToModuleList(imoduleName);
        prj->addToModuleMap(imoduleName,pmodule);

        if(echainExistFlag)
        {
            /*
                1、无log文件，打开工程进行更新扫描
                  无对比对象，不进行对比
                2、有log文件，打开工程进行更新扫描
                  更扫描链进行对比，来判断是否　链被破坏
                3、在已打开工程进行更新
                  直接跟　已经记录的　module 进行对比
                  注:2013.3.26  由于parameter存在 可能 跟原module相比  会出错,以后均采用根据
                  扫描链的信息进行比较
            */
            // 根据log文件　进行对比
            if(true == prj->getLogFileExistFlag())
            {
                for(int i = 0 ; i < ieziPort.count() ; i++)
                {
                    QString iportName = ieziPort.at(i) ;
                    if(iportName.split('_',QString::SkipEmptyParts).count() >= 4)
                    {
                        QString ichainName = iportName.split('_',QString::SkipEmptyParts).at(1) ;
                        // prj->addToCheckedChainList(ichainName);
                        if(!icheckChainList.contains(ichainName))
                        {
                            icheckChainList.append(ichainName);
                            EziDebugScanChain* pchain = prj->getScanChainInfo().value(ichainName ,NULL) ;
                            if(pchain)
                            {
                                if(!pmodule->isChainCompleted(pchain))
                                {
                                    ichangedchainList.append(ichainName);                                    
                                    prj->addToDestroyedChainList(ichainName);
                                }
                            }
                            else
                            {
                                // log 文件被破坏(并非log文件本身格式问题,而是代码中的链 log文件中不存在)
                                prj->setLogfileDestroyedFlag(true);
                            }
                        }
                    }
                }

            }

        }
    }

    // 有哪些module、
    // 遍历扫描链代码 如果扫描链包括这个module 然后检测  line_code block_code 是否存在
    // All code in this file
    // QStringList icodeList ;
    QStringList ichainNameList ;
    for(int nmoduleNum = 0 ; nmoduleNum < this->getModuleList().count() ;nmoduleNum++)
    {
        QString imoduleName = this->getModuleList().at(nmoduleNum) ;
        QMap<QString,EziDebugScanChain*> iscanChainMap = prj->getScanChainInfo() ;
        QMap<QString,EziDebugScanChain*>::const_iterator iscanchainIter = iscanChainMap.constBegin() ;
        while(iscanchainIter != iscanChainMap.constEnd())
        {
            EziDebugScanChain* pchain = iscanchainIter.value() ;
            QString ichainName = iscanchainIter.key() ;
            if(pchain->getLineCode().contains(imoduleName))
            {
                if(!ichainNameList.contains(ichainName))
                {
                    ichainNameList.append(ichainName);
                }
            }

            if(pchain->getBlockCode().contains(imoduleName))
            {
                if(!ichainNameList.contains(ichainName))
                {
                    ichainNameList.append(ichainName);
                }
            }
            ++iscanchainIter ;
        }

        if((nresult = checkedEziDebugCodeExist(prj,imoduleName,ichainNameList)) != 0)
        {
            return nresult ;
        }
    }


//    // 如果在扫描被修改的文件， 则更新 相关的 module 对象
//    if(!(this->getLastStoredTime().isNull()))
//    {
//        // 更改的文件
//        if(isModifedRecently())
//        {
//            // 文件被改动 更新 相关的 module 对象

//            // 将文件 与 module 挂在 删除的链表上
////            struct EziDebugPrj::LOG_FILE_INFO* pdelFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
////            pdelFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
////            pdelFileInfo->pinfo = NULL ;
////            memcpy(pdelFileInfo->ainfoName,this->fileName().toAscii(),this->fileName().size()+1);
////            deletedinfolist.append(pdelFileInfo);

////            for(int i = 0 ; i < getModuleList().count();i++)
////            {
////                EziDebugModule *pmodule = prj->getPrjModuleMap().value(getModuleList().at(i),NULL) ;
////                if(!pmodule)
////                {
////                    struct EziDebugPrj::LOG_FILE_INFO* pdelmoduleInfo = new EziDebugPrj::LOG_FILE_INFO ;

////                    pdelmoduleInfo->etype = EziDebugPrj::infoTypeModuleStructure ;
////                    pdelmoduleInfo->pinfo = NULL ;
////                    memcpy(pdelmoduleInfo->ainfoName,pmodule->getModuleName().toAscii(),pmodule->getModuleName().size()+1);
////                    deletedinfolist.append(pdelmoduleInfo);
////                }
////            }

//            // 将更改后的文件 与 新的module 挂在 添加的链表上 需要重新添加
//            struct EziDebugPrj::LOG_FILE_INFO* paddFileInfo = new EziDebugPrj::LOG_FILE_INFO ;
//            paddFileInfo->etype = EziDebugPrj::infoTypeFileInfo ;
//            paddFileInfo->pinfo = this ;
//            memcpy(paddFileInfo->ainfoName,this->fileName().toAscii(),this->fileName().size()+1);
//            addedinfolist.append(paddFileInfo);

//            for(int i = 0 ; i < getModuleList().count();i++)
//            {
//                EziDebugModule *pmodule = prj->getPrjModuleMap().value(getModuleList().at(i),NULL) ;
//                if(pmodule)
//                {
//                    struct EziDebugPrj::LOG_FILE_INFO* paddModuleInfo = new EziDebugPrj::LOG_FILE_INFO ;
//                    paddModuleInfo->etype = EziDebugPrj::infoTypeModuleStructure ;
//                    paddModuleInfo->pinfo = pmodule ;
//                    memcpy(paddModuleInfo->ainfoName,pmodule->getModuleName().toAscii(),pmodule->getModuleName().size()+1);
//                    addedinfolist.append(paddModuleInfo);
//                }
//                else
//                {
//                    return 1 ;
//                }
//            }
//        }
//    }
//    else
//    {
        // 将最新扫描过的 信息 保存


        qDebug() << " !!module count !!"<< getModuleList().count();
        for(i = 0 ; i < getModuleList().count();i++)
        {
            EziDebugModule *pmodule = prj->getPrjModuleMap().value(getModuleList().at(i),NULL) ;
            if(pmodule)
            {   
                qDebug() << " add module info " ;
                struct EziDebugPrj::LOG_FILE_INFO* paddModuleInfo = new EziDebugPrj::LOG_FILE_INFO ;
                paddModuleInfo->etype = EziDebugPrj::infoTypeModuleStructure ;
                paddModuleInfo->pinfo = pmodule ;
                memcpy(paddModuleInfo->ainfoName,pmodule->getModuleName().toAscii().data(),pmodule->getModuleName().size()+1);
                addedinfolist.append(paddModuleInfo);
            }
            else
            {
                return 1 ;
            }
        }
//    }
    //qDebug() << addedinfolist.count() <<  deletedinfolist.count();
    // 更改文件扫描时间
    modifyStoredTime(ilastModifedTime);

    return 0 ;
}

int EziDebugVlgFile::checkedEziDebugCodeExist(EziDebugPrj* prj ,QString imoduleName ,QStringList &chainnamelist)
{
    QMap<QString,EziDebugScanChain*> ichainMap = prj->getScanChainInfo() ;
    QMap<QString,int> ilinesearchposMap ;
    QMap<QString,int> iblocksearchposMap ;
    QMap<QString,QStringList> ichainLineCodeMap ;
    QMap<QString,QStringList> ichainBlockCodeMap ;
    QStringList idestroyChainList ;
    QStringList icheckChainList ;
    QList<int>  iposList ;

    if(!open(QIODevice::ReadOnly | QIODevice::Text))
    {
        // 向用户输出  文件打不开
        qDebug() << errorString() << fileName() ;
        return 1 ;
    }

    QTextStream iin(this);
    QString ifileContent = iin.readAll();
    QString inoCommentaryStr = replaceCommentaryByBlank(ifileContent) ;
    QRegExp imoduleStartExp(tr("module\\s+%1").arg(imoduleName)) ;
    int nstartPos = inoCommentaryStr.indexOf(imoduleStartExp);
    if(-1 == nstartPos)
    {
        qDebug() << "EziDebug Error: parse file error ,please check the file!";
        return -2 ;
    }
    int nendPos = inoCommentaryStr.indexOf("endmodule",nstartPos);
    if(-1 == nendPos)
    {
        qDebug() << "EziDebug Error: parse file error ,please check the file!";
        return -2 ;
    }
    QString icheckStr = inoCommentaryStr.mid(nstartPos,nendPos-1);
    // 关闭
    close();

    for(int nchainNum = 0 ; nchainNum < chainnamelist.count() ; nchainNum++)
    {
        QString ichainName = chainnamelist.at(nchainNum) ;
        EziDebugScanChain * pchain = ichainMap.value(ichainName,NULL);
        if(pchain)
        {
            QMap<QString,QStringList> icodeListMap = pchain->getLineCode() ;
            QStringList icodeList ;
            icodeList = icodeListMap.value(imoduleName,icodeList) ;
            if(icodeList.count())
            {
                ichainLineCodeMap.insert(ichainName,icodeList);
            }

            icodeList.clear();
            icodeListMap = pchain->getBlockCode();
            icodeList = icodeListMap.value(imoduleName,icodeList);
            if(icodeList.count())
            {
                ichainBlockCodeMap.insert(ichainName,icodeList) ;
            }
        }
        else
        {
            qDebug() << "NULL Pointer!" << ichainName << "is not exist!";
            return -1 ;
        }
    }

    // linecode
    QMap<QString ,QStringList>::const_iterator icodeIter = ichainLineCodeMap.constBegin() ;
    while(icodeIter != ichainLineCodeMap.constEnd())
    {
        int ncodeNum = 0 ;
        QString chainname = icodeIter.key() ;
        QStringList icode = icodeIter.value() ;
        iposList.clear();
        EziDebugScanChain * pchain = ichainMap.value(chainname);
        int nsearchPos = 0 ;
        for(;ncodeNum < icode.count();ncodeNum++)
        {
            QString isearchLineStr = icode.at(ncodeNum) ;
            if(-1 != (nsearchPos = icheckStr.indexOf(QRegExp(isearchLineStr))))
            {
                ilinesearchposMap.insert(isearchLineStr ,nsearchPos);
                iposList.append(nsearchPos);
            }
            else
            {
                qDebug() <<"EziDebug Warning:"<< isearchLineStr << "is not finded!";
                if(!idestroyChainList.contains(chainname))
                {
                    idestroyChainList.append(chainname);
                }
                break ;
            }
        }

        // check code sequence
        if(ncodeNum == icode.count())
        {
            QSet<int> isimplifiedSet = iposList.toSet();
            if(isimplifiedSet.count() == iposList.count())
            {
                 QStringList inewCodeList ;
                 qSort(iposList.begin(), iposList.end(), qLess<int>());
                 for(int ncodeNum = 0 ; ncodeNum < iposList.count() ; ncodeNum++)
                 {
                    int npos = iposList.at(ncodeNum) ;
                    QString icodeStr = ilinesearchposMap.key(npos) ;
                    inewCodeList.append(icodeStr);
                 }

                 if(inewCodeList != icode)
                 {
                    pchain->replaceLineCodeMap(imoduleName,inewCodeList);
                    prj->addToCheckedChainList(chainname);
                 }
            }
            else
            {
                qDebug() << "Please remove the repeated code !";
                for(int i = 0 ; i < icode.count() ; i++)
                {
                    qDebug() << icode.at(i) << endl ;
                }
                return -2 ;
            }

        }
        ilinesearchposMap.clear();
        ++icodeIter ;
    }


    // blockcode
    icodeIter = ichainBlockCodeMap.constBegin() ;
    while(icodeIter != ichainBlockCodeMap.constEnd())
    {
        int ncodeNum = 0 ;
        iposList.clear();
        QString chainname = icodeIter.key() ;
        QStringList icode = icodeIter.value() ;
        EziDebugScanChain * pchain = ichainMap.value(chainname);
        // the code in icode is from little to big
        int nsearchPos = 0 ;
        for(;ncodeNum < icode.count();ncodeNum++)
        {
            QString isearchLineStr = icode.at(ncodeNum) ;
            if(-1 != (nsearchPos = icheckStr.indexOf(QRegExp(isearchLineStr))))
            {
                iblocksearchposMap.insert(isearchLineStr ,nsearchPos);
                iposList.append(nsearchPos);
            }
            else
            {
                qDebug() <<"EziDebug Warning:"<< isearchLineStr << "is not finded!";
                if(!idestroyChainList.contains(chainname))
                {
                    idestroyChainList.append(chainname);
                }
                break ;
            }
        }

        // check code sequence
        if(ncodeNum == icode.count())
        {
            QSet<int> isimplifiedSet = iposList.toSet();
            if(isimplifiedSet.count() == iposList.count())
            {
                 QStringList inewCodeList ;
                 qSort(iposList.begin(), iposList.end(), qLess<int>());
                 for(int ncodeNum = 0 ; ncodeNum < iposList.count() ; ncodeNum++)
                 {
                    int npos = iposList.at(ncodeNum) ;
                    QString icodeStr = iblocksearchposMap.key(npos) ;
                    inewCodeList.append(icodeStr);
                 }

                 if(inewCodeList != icode)
                 {
                    pchain->replaceBlockCodeMap(imoduleName,inewCodeList);

                    prj->addToCheckedChainList(chainname);
                 }
            }
            else
            {
                qDebug() << "Please remove the repeated code !\n";
                for(int i = 0 ; i < icode.count() ; i++)
                {
                    qDebug() << icode.at(i) << endl ;
                }
                return -2 ;
            }
        }
        iblocksearchposMap.clear();
        ++icodeIter ;
    }

    // check the destroyed chain!
    for(int nchaincount = 0 ; nchaincount < idestroyChainList.count() ;nchaincount++)
    {
        QString ichainName = idestroyChainList.at(nchaincount) ;
        qDebug()  << "EziDebug Error:" << ichainName << "is destroyed!" << "checkedEziDebugCodeExist !";
        prj->addToDestroyedChainList(ichainName);
    }

    return 0 ;
}

int EziDebugVlgFile::createUserCoreFile(EziDebugPrj* prj)
{
    if(!prj)
        return 1 ;
    QString iregModuleName(tr("_EziDebug_ScnReg")) ;
    QString itimerName(tr("_EziDebug_TOUT_m"));


    QFileInfo iPrjFileInfo(prj->getPrjName());
    /*创建新的文件夹  并 创建自己的core文件*/
    QDir idirPrj(iPrjFileInfo.absolutePath());
    QString inewDirName = iPrjFileInfo.absolutePath() + tr("/") + tr("EziDebug_1.0") ;
    QDir idir(inewDirName);
    QTime icurrentTime = QTime::currentTime() ;

    if(idir.exists())
    {
        qDebug() <<  "There is already exist folder!" << inewDirName ;
        // 检测 文件是否存在
        if(idir.exists("_EziDebug_ScanChainReg.v"))
        {
            if(idir.exists("_EziDebug_TOUT_m.v"))
            {
               EziDebugScanChain::saveEziDebugAddedInfo(iregModuleName,itimerName,QObject::tr("/EziDebug_1.0"));
               // 重新创建 tout 文件
               QString ifileToutName(tr("_EziDebug_TOUT_m.v"));
               QFile itoutfile(inewDirName + tr("/") + ifileToutName);
               if(!itoutfile.open(QIODevice::WriteOnly|QIODevice::Text|QIODevice::Truncate))
               {
                    /*在文本栏 提示插入链错误 无法创建文件 文件无法打开*/
                    return 1 ;
               }


               /*写入 tout 文件*/
               QTextStream itoutStream(&itoutfile);

               itoutStream <<"module ";

               /*写入module名字*/
               itoutStream << itimerName;
               itoutStream << g_ptoutfileContentFirst ;
               itoutStream << prj->getMaxRegNumPerChain() << ";" ;
               itoutStream << g_ptoutfileContentSecond ;

               itoutfile.close();
               return 0 ;
            }
        }
        // 重新创建 文件
        idir.remove("_EziDebug_ScanChainReg.v") ;
        idir.remove("_EziDebug_TOUT_m.v");
    }
    else
    {
        idirPrj.mkdir(tr("EziDebug_1.0"));
    }

    QString ifileRegName(tr("_EziDebug_ScanChainReg.v")) ;
    QString ifileToutName(tr("_EziDebug_TOUT_m.v"));
    QStringList ifileList = prj->getFileNameList();

    for (int i = 0; i < ifileList.size(); ++i)
    {
       QFileInfo ifileInfo(prj->getCurrentDir(),ifileList.at(i));
       if(ifileInfo.fileName() == ifileRegName)
       {
           ifileRegName = tr("_EziDebug_ScanChainReg")+tr("_")+ icurrentTime.toString("hh_mm_ss") + tr(".v") ;
           if(ifileInfo.fileName() == ifileRegName)
           {
                /*在文本栏 提示插入链错误  无法创建文件  文件名重复*/
               qDebug() << "EziDebug encounter error,Please ensure your fileName is right" << ifileRegName ;
               return 1 ;
           }
       }


       if(ifileInfo.fileName() == ifileToutName)
       {
           ifileToutName = tr("_EziDebug_TOUT_m")+tr("_")+ icurrentTime.toString("hh_mm_ss") + tr(".v") ;
           if(ifileInfo.fileName() == ifileToutName)
           {
                /*在文本栏 提示插入链错误  无法创建文件  文件名重复*/
               qDebug() << "EziDebug encounter error,Please ensure your fileName is right" << ifileToutName ;
               return 1 ;
           }
       }
    }

#if 0
    /*检查module名字是否存在重复*/
    QMap<QString,EziDebugModule*>::const_iterator i = prj->getPrjModuleMap().constBegin();
    while (i != prj->getPrjModuleMap().constEnd())
    {

    }
 #endif

    QFile itoutfile(inewDirName + tr("/") + ifileToutName);
    if(!itoutfile.open(QIODevice::WriteOnly|QIODevice::Text|QIODevice::Truncate))
    {
         /*在文本栏 提示插入链错误 无法创建文件 文件无法打开*/
         return 1 ;
    }


    /*写入 tout 文件*/
    QTextStream itoutStream(&itoutfile);

    itoutStream <<"module ";

    /*写入module名字*/
    itoutStream << itimerName;
    itoutStream << g_ptoutfileContentFirst ;
    itoutStream << prj->getMaxRegNumPerChain() << ";" ;
    itoutStream << g_ptoutfileContentSecond ;

    itoutfile.close();


    QFile iscanRegfile(inewDirName + tr("/") + ifileRegName);
    if(!iscanRegfile.open(QIODevice::WriteOnly|QIODevice::Text|QIODevice::Append))
    {
         /*在文本栏 提示插入链错误 无法创建文件 文件无法打开*/
         return 1 ;
    }
    /*写入 ScanReg 文件*/
    QTextStream iscanRegout(&iscanRegfile);

    iscanRegout <<"module ";

    /*写入module名字*/
    iscanRegout << iregModuleName ;
    iscanRegout << g_pScanRegfileContentFirst ;
    iscanRegout << g_pScanRegfileContentSecond ;

    iscanRegfile.close();

    EziDebugScanChain::saveEziDebugAddedInfo(iregModuleName,itimerName,QObject::tr("/EziDebug_1.0"));

    return 0 ;
}

int EziDebugVlgFile::caculateExpression(QString string)
{
    return 0 ;
}

void EziDebugVlgFile::addToMacroMap(const QString &macrostring , const QString &macrovalue)
{
    m_imacro.insert(macrostring,macrovalue) ;
}

void EziDebugVlgFile::addToDefParameterMap(const QString &instancename ,const QString &parameter ,const QString &value)
{
    QMap<QString,QString> iparameterMap ;
    iparameterMap = m_idefparameter.value(instancename ,iparameterMap) ;
    iparameterMap.insert(parameter,value);
    m_idefparameter.insert(instancename,iparameterMap) ;
}

const QMap<QString,QString> & EziDebugVlgFile::getMacroMap(void) const
{
    return m_imacro ;
}

const QMap<QString,QMap<QString,QString> > & EziDebugVlgFile::getDefParamMap(void) const
{
    return m_idefparameter ;
}


#if 0
bool EziDebugVlgFile::isLibaryFile()
{
    return 0 ;
}
#endif


int  EziDebugVlgFile::deleteEziDebugCode(void)
{
    // 只读方式 打开文件
    QString ifileContent ;
    QString inewContent ;
    //QString ikeyWords ;
    int nkeyWordsPos = 0 ;
    QList<int> iposList ;
    QMap<int,int> ideleteCodePosMap ;

    //QRegExp ieziDebugFlagExp(QObject::tr("\\b_EziDebug_\\w+\\b"));
    QRegExp ieziDebugFlagWithEnterExp(QObject::tr("\\s*\\b_EziDebug_\\w+\\b"));
    QRegExp ikeyWordsExp(QObject::tr("\\s*\\b[a-z]+\\b"));
    //QRegExp ikeyWordsWithEnterExp(QObject::tr("\\s*\\b\\w+\\b"));



    /*
        _EziDebug_ScnReg _EziDebug_ScnReg_chn_inst0(
        .clock	(HCLK) ,
        .resetn	(_EziDebug_chn_rstn) ,
        .TDI_reg	(_EziDebug_chn_HCLK_TDI_reg) ,
        .TDO_reg	(_EziDebug_chn_HCLK_tdo1) ,
        .TOUT_reg	(_EziDebug_chn_TOUT_reg) ,
        .shift_reg	(_EziDebug_chn_HCLK_sr0)
        )
    */
    QRegExp ieziDebugScnInstExp(QObject::tr("\\s*_EziDebug_ScnReg\\s+_EziDebug_ScnReg_chn\\d*_inst\\d*\\s*\\(.+\\)\\s*"));


    QRegExp ieziDebugToutInstExp(QObject::tr("\\s*_EziDebug_TOUT_m\\s+_EziDebug_TOUT_m_chn\\d*_inst\\d*\\s*\\(.+\\)\\s*"));
    //_EziDebug_TOUT_m _EziDebug_TOUT_m_chn_inst

    int npostion = 0 ;
    if(!open(QIODevice::ReadOnly | QIODevice::Text))
    {
        // 向用户输出  文件打不开
        qDebug() << errorString() << fileName() ;
        return 1 ;
    }
    // 全部读出
    QTextStream iin(this);
    ifileContent = iin.readAll();
    // 关闭
    close();

    // 替换所有注释为  空格
    inewContent = replaceCommentaryByBlank(ifileContent);
    qDebug() << "EziDebug info: start file---" << fileName();
    if(fileName().endsWith("fft_ram_256x17.v"))
    {
        qDebug() << "EziDebug Info : halt Point!";
    }

     qDebug() << fileName() ;

    // 查找 以 "_EziDebug" 开头的字符串
    while((npostion = ieziDebugFlagWithEnterExp.indexIn(inewContent,npostion)) != -1)
    {
        // EziDebug 自定义 core 的例化
        int nnextSemicolonPos = inewContent.indexOf(';',npostion + ieziDebugFlagWithEnterExp.matchedLength()) ;
        QString itruncateStr = inewContent.mid(npostion , (nnextSemicolonPos - npostion));
        qDebug() << "test string!" << itruncateStr  << ieziDebugScnInstExp.exactMatch(itruncateStr) << ieziDebugToutInstExp.exactMatch(itruncateStr) ;

        int nin = ieziDebugScnInstExp.indexIn(itruncateStr) ;
        qDebug() << nin <<  ieziDebugScnInstExp.matchedLength() << ieziDebugScnInstExp.capturedTexts().at(0);

        if(ieziDebugScnInstExp.exactMatch(itruncateStr)||ieziDebugToutInstExp.exactMatch(itruncateStr))
        {
            iposList.append(npostion);
            ideleteCodePosMap.insert(npostion,(nnextSemicolonPos - npostion + 1));
            qDebug() << " instance match!" <<  ifileContent.mid(npostion ,(nnextSemicolonPos - npostion + 1)) ;

            npostion = nnextSemicolonPos + 1 ;
        }
        else
        {
            if(QRegExp(QObject::tr("\\s*\\b_EziDebug\\w+\\s*<=.*")).exactMatch(itruncateStr))
            {
                // 寻找 always
                int nalwaysPos = inewContent.lastIndexOf(QRegExp(QObject::tr("\\balways\\b")),npostion);
                int nlastNoneblankCharPos = inewContent.lastIndexOf(QRegExp(QObject::tr("\\S")),nalwaysPos);
                if(nlastNoneblankCharPos != -1)
                {
                    // nalwaysPos   =  nlastNoneblankCharPos + 1 ;
                    nalwaysPos   =  nlastNoneblankCharPos ;
                }
                int nfirstBeginPos = inewContent.indexOf(QRegExp(QObject::tr("\\bbegin\\b")),nalwaysPos);
                /*查找匹配的  end*/
                QRegExp iwordsExp(QObject::tr("\\b\\w+\\b"));
                int nmatch = 1 ;
                int nendPos = 0 ;
                int nbeginPos = nfirstBeginPos + 5 ;

                while((nbeginPos = iwordsExp.indexIn(ifileContent,nbeginPos)) != -1)
                {
                    if(iwordsExp.capturedTexts().at(0) == "begin")
                    {
                        nmatch++ ;
                    }
                    else if(iwordsExp.capturedTexts().at(0) == "end")
                    {
                        nmatch-- ;
                        if(0 == nmatch)
                        {
                            nendPos = nbeginPos ;
                            break ;
                        }
                    }
                    else
                    {
                        // do nothing
                    }
                    nbeginPos = nbeginPos + iwordsExp.matchedLength();
                }

                if(nmatch != 0)
                {
                    return 1 ;
                }

                iposList.append(nalwaysPos);
                ideleteCodePosMap.insert(nalwaysPos,(nendPos - nalwaysPos + 3));

                qDebug()<< "1" << ifileContent.mid(nalwaysPos ,(nendPos - nalwaysPos + 3)) ;

                npostion = nendPos + 3 ;
            }
            else
            {
                // 查找最近的单词
                nkeyWordsPos = ikeyWordsExp.lastIndexIn(inewContent,npostion) ;
                QString ikeyWord = ikeyWordsExp.capturedTexts().at(0) ;
                // 最近的 ','
                int nlastCommaPos = inewContent.lastIndexOf(',',npostion);

                if(nlastCommaPos > nkeyWordsPos)
                {
                    // 是否包含 '.'
                    /*只能是 例化 中加入 的端口连接 */
                    // 标准的 ,.(),.(),.()
                    // 截取 上一个 逗号 之间的 字符 看是否包含 ".( 字符"
                    QString ipartStr = inewContent.mid((nlastCommaPos+1) , (npostion - nlastCommaPos -1));
                    if(QRegExp(QObject::tr("\\s*\\.")).exactMatch(ipartStr))
                    {
                        // 删除上一个逗号 到 下一个 ) 之间字符串
                        int nnextRightBracketPos = inewContent.indexOf(')',npostion);
                        iposList.append(nlastCommaPos);
                        ideleteCodePosMap.insert(nlastCommaPos,(nnextRightBracketPos - nlastCommaPos + 1));
                        qDebug()<< "2" << ifileContent.mid(nlastCommaPos ,(nnextRightBracketPos - nlastCommaPos + 1)) ;

                        npostion = nnextRightBracketPos + 1 ;
                    }
                    else
                    {
                        // 删除上一个逗号 到 本字符串结束
                        iposList.append(nlastCommaPos);
                        ideleteCodePosMap.insert(nlastCommaPos,(npostion + ieziDebugFlagWithEnterExp.matchedLength()- nlastCommaPos));
                        qDebug()<< "3" << ifileContent.mid(nlastCommaPos ,(npostion + ieziDebugFlagWithEnterExp.matchedLength()- nlastCommaPos)) ;

                        npostion =  npostion + ieziDebugFlagWithEnterExp.matchedLength() ;
                    }
                }
                else
                {
                    if(ikeyWordsExp.capturedTexts().at(0).contains(QRegExp(QObject::tr("\\binput\\b"))))
                    {
                        int nlastCommaPos = inewContent.lastIndexOf(',',npostion);
                        int nlastSemicolon = inewContent.lastIndexOf(';',npostion);
                        int nnextSemicolon = inewContent.indexOf(';',npostion);

                        if(nlastCommaPos > nlastSemicolon)
                        {
                            // 端口声明
                            iposList.append(nlastCommaPos);
                            ideleteCodePosMap.insert(nlastCommaPos,(npostion + ieziDebugFlagWithEnterExp.matchedLength() - nlastCommaPos));
                            qDebug() << "4" << ifileContent.mid(nlastCommaPos ,(npostion + ieziDebugFlagWithEnterExp.matchedLength() - nlastCommaPos)) ;

                            npostion = npostion + ieziDebugFlagWithEnterExp.matchedLength() ;
                        }
                        else
                        {
                            nkeyWordsPos = inewContent.lastIndexOf(QRegExp(QObject::tr("\\S")),nkeyWordsPos-1) + 1 ;
                            iposList.append(nkeyWordsPos);
                            ideleteCodePosMap.insert(nkeyWordsPos,(nnextSemicolon - nkeyWordsPos + 1));
                            qDebug() << "5" << ifileContent.mid(nkeyWordsPos ,(nnextSemicolon - nkeyWordsPos + 1)) ;

                            npostion = nnextSemicolon + 1 ;
                        }
                    }
                    else if(ikeyWordsExp.capturedTexts().at(0).contains(QRegExp(QObject::tr("\\boutput\\b"))))
                    {
                        int nlastCommaPos = inewContent.lastIndexOf(',',npostion);
                        int nlastSemicolon = inewContent.lastIndexOf(';',npostion);
                        int nnextSemicolon = inewContent.indexOf(';',npostion);

                        if(nlastCommaPos > nlastSemicolon)
                        {
                            iposList.append(nlastCommaPos);
                            ideleteCodePosMap.insert(nlastCommaPos,(npostion + ieziDebugFlagWithEnterExp.matchedLength() - nlastCommaPos));
                            qDebug() << "6" << ifileContent.mid(nlastCommaPos ,(npostion + ieziDebugFlagWithEnterExp.matchedLength() - nlastCommaPos)) ;

                            npostion = npostion + ieziDebugFlagWithEnterExp.matchedLength() ;
                        }
                        else
                        {
                            nkeyWordsPos = inewContent.lastIndexOf(QRegExp(QObject::tr("\\S")),nkeyWordsPos-1) + 1 ;
                            iposList.append(nkeyWordsPos);
                            ideleteCodePosMap.insert(nkeyWordsPos,(nnextSemicolon - nkeyWordsPos + 1));
                            qDebug() << "7" << ifileContent.mid(nkeyWordsPos ,(nnextSemicolon - nkeyWordsPos + 1)) ;
                            npostion = nnextSemicolon + 1 ;
                        }
                    }
                    else if(ikeyWordsExp.capturedTexts().at(0).contains(QRegExp(QObject::tr("\\breg\\b"))))
                    {
                        int nnextSemicolon = inewContent.indexOf(';',npostion);
                        nkeyWordsPos = inewContent.lastIndexOf(QRegExp(QObject::tr("\\S")),nkeyWordsPos-1) + 1 ;
                        iposList.append(nkeyWordsPos);
                        ideleteCodePosMap.insert(nkeyWordsPos,(nnextSemicolon - nkeyWordsPos + 1));
                        qDebug() << "8" << ifileContent.mid(nkeyWordsPos ,(nnextSemicolon - nkeyWordsPos + 1)) ;
                        npostion = nnextSemicolon + 1;
                    }
                    else if(ikeyWordsExp.capturedTexts().at(0).contains(QRegExp(QObject::tr("\\bwire\\b"))))
                    {
                        int nnextSemicolon = inewContent.indexOf(';',npostion);
                        nkeyWordsPos = inewContent.lastIndexOf(QRegExp(QObject::tr("\\S")),nkeyWordsPos-1) + 1 ;
                        iposList.append(nkeyWordsPos);
                        ideleteCodePosMap.insert(nkeyWordsPos,(nnextSemicolon - nkeyWordsPos + 1));
                        qDebug() << "9" << ifileContent.mid(nkeyWordsPos ,(nnextSemicolon - nkeyWordsPos + 1)) ;
                        npostion = nnextSemicolon + 1;
                    }
                    else if(ikeyWordsExp.capturedTexts().at(0).contains(QRegExp(QObject::tr("\\bdefparam\\b"))))
                    {
                        int nnextSemicolon = inewContent.indexOf(';',npostion);
                        nkeyWordsPos = inewContent.lastIndexOf(QRegExp(QObject::tr("\\S")),nkeyWordsPos-1) + 1 ;
                        iposList.append(nkeyWordsPos);
                        ideleteCodePosMap.insert(nkeyWordsPos,(nnextSemicolon - nkeyWordsPos + 1));
                        qDebug() << "10" << ifileContent.mid(nkeyWordsPos ,(nnextSemicolon - nkeyWordsPos + 1)) ;
                        npostion = nnextSemicolon + 1;
                    }
                    else if(ikeyWordsExp.capturedTexts().at(0).contains(QRegExp(QObject::tr("\\bassign\\b"))))
                    {
                        int nnextSemicolon = inewContent.indexOf(';',npostion);
                        nkeyWordsPos = inewContent.lastIndexOf(QRegExp(QObject::tr("\\S")),nkeyWordsPos-1) + 1 ;
                        iposList.append(nkeyWordsPos);
                        ideleteCodePosMap.insert(nkeyWordsPos,(nnextSemicolon - nkeyWordsPos + 1));
                        qDebug() << "11" << ifileContent.mid(nkeyWordsPos ,(nnextSemicolon - nkeyWordsPos + 1)) ;
                        npostion = nnextSemicolon + 1;
                    }
                    else
                    {
                        // do nothing
                        npostion = npostion + ikeyWordsExp.matchedLength();
                    }
                }
            }
        }
    }

    // from big to small
    qSort(iposList.begin(), iposList.end(), qGreater<int>());

    // j < iposList.count()
    for(int j = 0 ; j < iposList.count() ; j++)
    {
        int nstartPos = iposList.at(j) ;
        int nlength = ideleteCodePosMap.value(nstartPos , 0) ;
        ifileContent.replace(nstartPos , nlength ,"");
    }


    if(!open(QIODevice::WriteOnly | QIODevice::Truncate))
    {
        // 向用户输出  文件打不开
        qDebug() << "EziDebug Error:" << errorString() << ":" << fileName() ;
        return 1 ;
    }

    qDebug() << "EziDebug info: finish file---" << fileName();
    // 全部写入
    QTextStream iout(this);
    iout << ifileContent ;
    close() ;

    QFileInfo ifileInfo(fileName()) ;
    this->modifyStoredTime(ifileInfo.lastModified()) ;

    return 0 ;
}
