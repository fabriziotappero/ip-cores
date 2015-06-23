#ifndef EZIDEBUGMODULE_H
#define EZIDEBUGMODULE_H


#include "ezidebugprj.h"

class QString ;
class QStringList ;
template <class Key, class T> class QMap ;
template <typename T> class QVector;

class EziDebugModule
{
public:
    enum DIRECTION_TYPE
    {
        dirctionNone  = 0 ,
        directionTypeInput,
        directionTypeOutput,
        directionTypeInoutput
    };

    enum SIGNAL_EDGE
    {
        signalPosEdge = 0 ,
        signalNegEdge,
        signalLow,
        signalHigh,
        signalOtherEdge
    };

    enum ENDIAN_TYPE
    {
        endianLittle = 0 ,
        endianBig ,
        endianOther
    };

    enum ATTRIBUTE_TYPE
    {
        attributeStatic = 0 ,
        attributeDynamic ,
        attributeOther
    };



    struct RegStructure
    {
        // 静态属性
        char m_pMouduleName[128] ;
        char m_pRegName[128] ;
        char m_pclockName[128] ;
        SIGNAL_EDGE  m_eedge ;

        char m_pregNum[64] ;
        char m_pregNumNoMacroString[128] ;

        char m_pExpString[64] ;             // 用于根据参数 计算位数的表达式
        char m_pExpNoMacroString[128] ;     // 只是做 宏替换 并不能真正保证 parameter 引入 宏

        // 变化属性 (随扫描链不同可能变化)
        unsigned int m_unMaxRegNum ;        // 存在 defparameter 的最大寄存器个数
        ENDIAN_TYPE m_eRegNumEndian ;
        ATTRIBUTE_TYPE m_eRegNumType ;
        unsigned int m_unMaxBitWidth ;      // 位宽可能出现的最大宽度
        ENDIAN_TYPE m_eRegBitWidthEndian ;
        ATTRIBUTE_TYPE m_eRegBitWidthType ;


        // 用于静态寄存器使用(每个例化的寄存器是静态的)
        unsigned int m_unStartNum ;
        unsigned int m_unEndNum ;
        unsigned int m_unRegNum ;

        unsigned int m_unStartBit ;
        unsigned int m_unEndBit ;
        unsigned int m_unRegBitWidth ;
    };



    struct PortStructure
    {
        char m_pPortName[128] ;
        char m_pModuleName[128] ;
        DIRECTION_TYPE eDirectionType ;
        char m_pBitWidth[64] ;
        unsigned int m_unStartBit ;
        unsigned int m_unEndBit ;
        unsigned int m_unBitwidth ;
        ENDIAN_TYPE m_eEndian ;
    };

    EziDebugModule(const QString modulename);
    ~EziDebugModule();


    friend int EziDebugPrj::readModuleStructure(char readflag) ;
    friend int EziDebugPrj::readClockStructure(char readflag ,EziDebugModule* module) ;
    friend int EziDebugPrj::readRegStructure(char readflag ,EziDebugModule* module);
    friend int EziDebugPrj::readPortStructure(char readflag ,EziDebugModule* module);



    friend int EziDebugPrj::domParseModuleInfoElement(const QDomElement &element, char readflag);


    friend int EziDebugPrj::domParseClockDescriptionElement(const QDomElement &element, char readflag, EziDebugModule* module) ;
    friend int EziDebugPrj::domParseRegDescriptionElement(const QDomElement &element,char readflag, EziDebugModule* module) ;
    friend int EziDebugPrj::domParsePortDescriptionElement(const QDomElement &element,char readflag, EziDebugModule* module) ;


    friend int EziDebugPrj::domParsePortStructure(const QDomElement &element, char readflag, EziDebugModule *module);
    friend int EziDebugPrj::domParseRegStructure(const QDomElement &element, char readflag, EziDebugModule *module);
    friend int EziDebugPrj::domParseClockStructure(const QDomElement &element, char readflag, EziDebugModule *module);
    friend int EziDebugPrj::domParseInstancePortMapDescriptionElement(const QDomElement &element,char readflag, EziDebugModule* module);


    friend int EziDebugPrj::saveInfoToLogFile(QDomDocument &idoc , EziDebugPrj::LOG_FILE_INFO* loginfo);
    friend class EziDebugVlgFile ;
    //friend int EziDebugVlgFile::scanFile(EziDebugPrj* prj,EziDebugPrj::SCAN_TYPE type,QList<EziDebugPrj::LOG_FILE_INFO*> &addedinfolist,QList<EziDebugPrj::LOG_FILE_INFO*> &deletedinfolist) ;



    QString getModuleName(void) const ;
    const QStringList &getInstanceList(void) const;
    QVector<RegStructure*> getReg(const QString &clock)  ;
    const QMap<QString,QVector<EziDebugModule::RegStructure*> > getRegMap(void) const ;
    const QMap<QString,QString> & getClockSignal(void) const ;
    const QMap<QString,QString> & getResetSignal(void) const ;
    const QVector<PortStructure*> & getPort(EziDebugPrj *prj ,const QString &instancename)  ;
    void  addToClockMap(const QString &clock);
    void  addToResetSignalMap(const QString &reset,const QString &edge);


    const QMap<QString,QMap<QString,QString> > &getInstancePortMap(void) const ;
    QMap<QString,QString> getInstancePortMap(const QString &instanceName) ;

    const QString  &getLocatedFileName(void) const;
    bool  getAddCodeFlag(void) ;
    int   getInstancedTimesPerChain(const QString &chainName);
    int   getConstInstacedTimesPerChain(const QString &chainName);
    // int   getRegNumber(const QString &clock) ;


    void  getBitRangeInChain(const QString& chainname, const QString &clockname, int* startbit,int * endbit);
    void  setBitRangeInChain(const QString& chainname, const QString &clockname, int startbit,int endbit);

    void  AddToRegMap(const QString &clock,RegStructure*preg);
    // void  addToVaribleRegMap(const QString &clock,RegStructure*preg);
    void  addToDefParameterMap(const QString &instancename, const QString &parametername ,const QString &value);
    void  addToParameterMap(const QString &parametername,const QString &value);
    int   getInstanceTimes(void) ;
    QString getChainClockWireNameMap(const QString& chainname ,const QString& clockname) ;
    bool  isLibaryCore(void) ;
    void  setLibaryCoreFlag(bool flag) ;
    //void  setInstanceTimes(int count) ;
    void  setInstancedTimesPerChain(const QString &chainame,int count);
    void  setConstInstanceTimesPerChain(const QString &chainname,int count);
    void  setEziDebugCoreCounts(const QString &chainname,int count);
    int   getEziDebugCoreCounts(const QString &chainname);
    void  setEziDebugWireCounts(const QString &chainname,int count);
    int   getEziDebugWireCounts(const QString &chainname);
    void  AddToClockWireNameMap(const QString& chainname,const QString& clockname,const QString& lastwirename);
    void  setAddCodeFlag(bool flag) ;
    void  setRegInfoToInitalState(void) ;
    bool  isChainCompleted(EziDebugScanChain *pchain);
    bool  isChainCompleted(EziDebugModule *pmodue);
    void  clearChainInfo(const QString& chainname);

    int   getAllRegMap(QString clock ,QVector<EziDebugModule::RegStructure*> &sregVec,QVector<EziDebugModule::RegStructure*> &vregVec);
    void  calInstanceRegData(EziDebugPrj*prj,const QString &instancename);
    RegStructure* getInstanceReg(QString instancename , QString clock , QString regname) ;
    void  getBitRange(const QString &widthStr ,int *startbit ,int *endbit) ;
    int   constructChainRegMap(EziDebugPrj * prj ,const QStringList &cominstanceList,QString instancename) ;


private:
    QString m_imoduleName ;
    QStringList m_iinstanceNameList ;
    //QStringList m_iclockNameList ;
    QMap<QString,QString>  m_iclockMap ;
    QMap<QString,QString>  m_iresetMap ;
    // <clock,reg>
    QMap<QString,QVector<RegStructure*> > m_iregMap ;  // 所有寄存器

#if 0
    QMap<QString,QVector<RegStructure*> > m_ivregMap ; // 不可计算  变化位宽的寄存器组
    QMap<QString,QVector<RegStructure*> > m_isregMap ; // 可计算   固定位宽的寄存器组
#endif

    // 计算当前例化的寄存器的宽度需要  当前的例化名字、扫描链出现的module所有例化（例化次数可将一些变化位宽的寄存器固定化）、

    QMap<QString,QMap<QString ,QVector<RegStructure*> > > m_iinstanceRegMap ;  // module 的 每个例化 对应具体值的 寄存器组

    // 在扫描链中例化出现1次的都为 固定位宽的寄存器组

    QMap<QString,QMap<QString,QString> > m_iinstancePortMap   ;  //例化对应 各个例化上的对应的端口名字
    QMap<QString,QMap<QString,QString> > m_iclockWireNameMap ;  // 仅用于添加扫描链时使用，不保存在log文件里(避免函数参数过多)
                                                                // 保存每条链 最后一个非系统core 例化 创建的 wire_tdo

    QMap<QString,QMap<QString,int> > m_istartChainNum ;    // 本 module 在 每个 clock链 在 总链    开始 bit 位 用于连接 用户core 和 module tdo
    QMap<QString,QMap<QString,int> > m_iendChainNum ;  // 本 module 在每个 clock 链 在 总链  的  结束 bit 位 用于 连接 tdo
    QVector<PortStructure*> m_iportVec ;
    bool m_isSubstituted ;
    QString m_ilocatedFile ;
    int  m_ninstanceTimes ;
    int  m_nConstInstanceTimes ;
    bool m_isLibaryCore ;
    QMap<QString,int> m_iinstanceTimesPerChain ;
    QMap<QString,int> m_iconstInstanceTimesPerChain ;
    QMap<QString,int> m_ieziDebugCoreCounts ;
    QMap<QString,int> m_ieziDebugWireCounts ;
    QMap<QString,QString> m_iparameter ;  //  ( parameter : value )
    QMap<QString,QMap<QString,QString> > m_idefparameter ;  // instance (parameter: value)
    //QMap<QString,QMap<QString,QString> > m_ivarRegWidth ;
    // 寄存器名  不同的宽度字符串
    QMultiMap<QString,QString> m_ivarRegWidth ; // 保存 1个寄存器 1条扫描链 不同例化 对应 的宽度字符串

    // 固定位宽
    // 1、无parameter 只有数字与 define 宏来组成
    // 2、虽然有parameter 却无 defparameter
    // 3、有defparameter 却扫描链中只存在1次例化

    // 变化位宽
    // 1、有parameter 且 有 defparameter ，扫描链存在多次例化  ，正好都在defparameter 中
    // 计算位宽时   用例化对应的defparamete ；
    // 扫描整条链时 记录每个module具体例化了哪些
    // 在根据位宽字符串计算位宽时
    // 1、将define 的宏全部替换
    // 2、根据替换后的字符串 ，根据当前例化 把defparameter 放入到 parameter 中 ，并计算最大位宽
    // 3、最大位宽 与 当前位宽 不一样 则 为变化位宽
    bool m_isaddedCode ;
};

#endif // EZIDEBUGMODULE_H
