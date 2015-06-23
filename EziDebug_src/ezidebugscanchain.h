#ifndef EZIDEBUGSCANCHAIN_H
#define EZIDEBUGSCANCHAIN_H

#include <QMap>
#include <QStringList>
#include <ezidebugprj.h>
class QString ;
//class EziDebugTemplateFile ;
class EziDebugScanChain
{
public:
    struct RegListStructure
    {
        char* m_pnamehiberarchy ;
        char* m_pregName ;
        char* m_pclock ;
        unsigned int m_nbitwidth ;
        unsigned int m_nstartbit ;
        unsigned int m_nendbit   ;
    };

    EziDebugScanChain(const QString& chainname);
    ~EziDebugScanChain();

    const QString &getChainName(void) const;
    //QString getFirstInstanceItemName() const;

    const QMap<QString,QStringList> &getLineCode(void) const;
    const QMap<QString,QStringList> &getBlockCode(void) const;

    const QMap<QString,QVector<QStringList> >& getRegChain(void) const;
    int getChildChainNum(QString clock);
    const QStringList &getSyscoreOutputPortList(void);
    void  addToSyscoreOutputPortList(const QString& portlist);

    const QString &getscaningPortClock(void) const;
    const QString &getSlowClock(void) const;
    const QStringList &getInstanceItemList(void) const;
    int   traverseAllInstanceNode(EziDebugInstanceTreeItem *item);

    int   traverseChainAllReg(EziDebugInstanceTreeItem *item);
    int   compareCodeSequence(const QMap<QString,int> &ilinesearchposMap ,const QMap<QString,int> &iblocksearchposMap) ;


    void  setChainRegCount(const QString &clock ,int count);
    int   getChainRegCount(QString clock);

    const QString &getCfgFileName(void) const;
    //EziDebugTemplateFile * getTestBenchFile() const;


    void addToLineCodeMap(const QString &modulename, const QStringList &code);
    void addToBlockCodeMap(const QString &modulename, const QStringList &code);

    void replaceLineCodeMap(const QString &modulename, const QStringList &code);
    void replaceBlockCodeMap(const QString &modulename, const QStringList &code);

    void addToClockSetMap(EziDebugInstanceTreeItem *item);
    QString getChainClock(QString instancename,QString clock);


    void addToInstanceItemList(QString modulename ,QString instancename);
    void removeItemListDuplicates(void);
    void addToScanedFileList(const QString & filename);
    const QStringList& getScanedFileList(void) const ;
    void removeScanedFileListDuplicate(void) ;

    void setChildChainNum(QString clock ,int num);

    void setHeadTreeItem(EziDebugInstanceTreeItem *item) ;
    EziDebugInstanceTreeItem * getHeadTreeItem(void);

    void backupFileList(void) ;
    const QStringList &getBackupFileList(void) const;
    void clearupFileList(void) ;
    void resumeFileList(void) ;

    void addToRegChain(QString iclock ,int chainNum ,const QStringList& reglist);
    //int codeNum(QString modulename);

    //void createCfgFile(EziDebugPrj::TOOL tool);

    friend  int EziDebugPrj::domParseScanChainInfoElement(const QDomElement &element,char readflag) ;
    friend  int EziDebugPrj::domParseScanChainStructure(const QDomElement &element,char readflag, EziDebugScanChain *chain) ;
    friend  int EziDebugPrj::domParseReglistDescriptionElement(const QDomElement &element,char readflag, EziDebugScanChain *chain) ;
    friend  int EziDebugPrj::domParseCodeDescriptionElement(const QDomElement &element,char readflag, EziDebugScanChain *chain) ;

    friend  int EziDebugPrj::saveInfoToLogFile(QDomDocument &idoc, EziDebugPrj::LOG_FILE_INFO* loginfo) ;

    static const QString& getChainRegCore(void) ;
    static const QString& getChainToutCore(void) ;
    static const QString& getUserDir(void) ;
    static void  saveEziDebugAddedInfo(const QString &regcore,const QString &toutcore,const QString &dir) ;

    //friend  int EziDebugPrj::domParseReglistStructure(const QDomElement &element,char readflag, EziDebugScanChain *chain) ;
    //friend  int EziDebugPrj::domParseCodeStructure(const QDomElement &element,char readflag ,EziDebugScanChain * chain) ;
private:
    QMap<QString,int> m_nregCountMap ;
    QString m_iChainName ;
    QString m_iregCode ;
    QMultiMap<QString,QString> m_iuserDefineCoreMap ;
    QStringList m_iinstanceItemList ;
    QMap<QString,QStringList> m_icodeMap ;
    QMap<QString,QStringList> m_iblockCodeMap ;
    QMap<QString,QVector<QStringList> > m_iregChainStructure ;
    QString m_islowClock ;       // 用于产生  tout 信号的慢时钟
    QString m_iscaningPortClock ;   // 用于 扫描端口 的 时钟
    QString m_cfgFileName ;      // cdc or stp file

    QMap<QString,QStringList> m_iclockSetMap ;
    QStringList m_iscanedFileNameList ;        // 不用保存   用于 undo 操作
    QStringList m_isbackupscanedFileNameList ; // 备份扫描过的文件
    //EziDebugTemplateFile* m_ptestBechFile ;
    QMap<QString ,int>    m_nchildChainNumMap ;
    EziDebugInstanceTreeItem *m_pheadItem ;
    QStringList m_isysCoreOutputPortList ;

    static QString  m_iscanChainRegCore ;
    static QString  m_iscanChainIoCore ;
    static QString  m_iscanChainToutCore ;
    static QString  m_iuserDir ;
};
#endif // EZIDEBUGSCANCHAIN_H
