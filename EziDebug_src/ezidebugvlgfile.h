#ifndef EZIDEBUGVLGFILE_H
#define EZIDEBUGVLGFILE_H
#include "ezidebugfile.h"
#include "ezidebuginstancetreeitem.h"
#include "ezidebugmodule.h"


#define NO_STRING_FINDED   -1
#define NO_COMMENTARY      -1
#define EZI_MAX_INSTANCE_NUM  256

//class EziDebugFile ;
class QString ;
class EziDebugModule ;
class EziDebugInstanceTreeItem ;
class EziDebugFile ;
class EziDebugPrj ;

class EziDebugVlgFile:public EziDebugFile
{
    //Q_OBJECT
public:
    enum INSERT_TYPE
    {
        InsertTimer = 0 ,
        InsertUserCore ,
        InsertOther
    };

    enum SEARCH_TYPE
    {
        SearchModuleKeyWordPos = 1 ,
        SearchPortKeyWord ,
        SearchLastPortPos ,
        SearchLastRegPos ,
        SearchLastWirePos,
        SearchModuleEndPos ,
        SearchInstancePos ,
        SearchLeftBracketPos ,
        SearchRightBracketPos,
        SearchSemicolonPos,
        SearchOther
    };



    enum PORT_ANNOUNCE_FORMAT
    {
        AnsicFormat = 1,
        NonAnsicFormat ,
        PortOtherFormat
    };

    enum INSTANCE_FORMAT
    {
        StardardForamt = 1,
        NonStardardFormat,
        InstanceOtherFormat
    };

    struct SEARCH_MODULE_STRUCTURE
    {
        char m_amoduleName[128] ;
        PORT_ANNOUNCE_FORMAT m_eportAnnounceFormat ;
    };

    struct SEARCH_STRING_STRUCTURE
    {
        SEARCH_TYPE m_etype ;
//      char m_akeyWord[12] ;
        union SEARCH_CONTENT
        {
            int m_nreserved ;
            struct SEARCH_MODULE_STRUCTURE  m_imodulest ;
            INSTANCE_FORMAT      m_eInstanceFormat ;
        }m_icontent;
    };



    struct SEARCH_INSTANCE_POS_STRUCTURE
    {
        char m_amoduleName[128] ;
        char m_ainstanceName[128] ;
        INSTANCE_FORMAT  m_einstanceFormat ;
        int  m_nnextRightBracketPos ;
        int  m_nstartPos ;
    };

    struct SEARCH_MODULE_POS_STRUCTURE
    {
        char m_amoduleName[128] ;
        PORT_ANNOUNCE_FORMAT  m_eportFormat ;
        int m_nnextRightBracketPos ;
        int m_nlastPortKeyWordPos ;
        int m_nlastRegKeyWordPos ;
        int m_nlastWireKeyWordPos ;
        int m_nendModuleKeyWordPos ;
    };



    EziDebugVlgFile(const QString &filename);
    EziDebugVlgFile(const QString &filename,const QDateTime &datetime,const QStringList &modulelist);
    ~EziDebugVlgFile();

    int  deleteScanChain(QStringList &ideletelinecodelist,const QStringList &ideleteblockcodelist,EziDebugScanChain *pchain,EziDebugPrj::OPERATE_TYPE type);
    int  addScanChain(INSERT_TYPE type,QMap<QString,EziDebugInstanceTreeItem::SCAN_CHAIN_STRUCTURE*> &chainStructuremap ,EziDebugScanChain* pchain, EziDebugInstanceTreeItem *pitem);
    int  skipCommentaryFind(const QString &rangestring,int startpos ,SEARCH_STRING_STRUCTURE &stringtype,int &targetpos);
    int  matchingTargetString(const QString &rangestring ,SEARCH_MODULE_POS_STRUCTURE &modulepos ,QMap<QString,SEARCH_INSTANCE_POS_STRUCTURE*> &instancepos) ;
    int  findOppositeBracket(const QString &rangestring,int startpos ,SEARCH_STRING_STRUCTURE &stringtype,int &targetpos);
    QString  getNoCommentaryString(const QString &rangestring,int &lastcommentaryend,int &nocommontaryflag) ;
    QString  replaceCommentaryByBlank(const QString &rangestring);
    int  isModuleInstance(const QString &rangestring,const QString &modulename , const QString& instancename ,INSTANCE_FORMAT &type,int &targetpos);
    int  isModuleDefinition(const QString &rangestring,const QString &modulename ,PORT_ANNOUNCE_FORMAT &type,int &targetpos);
    int  isStringReiteration(const QString &poolstring ,const QString& string);
    QString  constructChainRegString(EziDebugModule::RegStructure* reg,int regnum ,int startbit ,int endbit,EziDebugInstanceTreeItem *item);


    int  deleteEziDebugCode(void);
    friend int EziDebugPrj::saveInfoToLogFile(QDomDocument &idoc, EziDebugPrj::LOG_FILE_INFO* loginfo) ;


    int scanFile(EziDebugPrj* prj,EziDebugPrj::SCAN_TYPE type,QList<EziDebugPrj::LOG_FILE_INFO*> &infolist,QList<EziDebugPrj::LOG_FILE_INFO*> &deletedinfolist);
    int checkedEziDebugCodeExist(EziDebugPrj* prj ,QString imoduleName  ,QStringList &chainnamelist) ;
    int  createUserCoreFile(EziDebugPrj* prj);
    int  caculateExpression(QString string) ;
    void addToMacroMap(const QString &macrostring , const QString &macrovalue);
    void addToDefParameterMap(const QString &instancename ,const QString &parameter ,const QString &value);
    const QMap<QString,QString> & getMacroMap(void) const;
    const QMap<QString,QMap<QString,QString> > & getDefParamMap(void) const ;
private:

    QMap<QString,QString>  m_imacro ; // 保存 defparameter 方便文件 更改时 同时更新 以及 保存到 ezi 文件中
    QMap<QString,QMap<QString,QString> > m_idefparameter ;  // 保存 define 方便文件 更改时 同时更新 以及 保存到 ezi 文件中

};

#endif // EZIDEBUGVLGFILE_H
