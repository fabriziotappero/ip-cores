#ifndef EZIDEBUGINSTANCETREEITEM_H
#define EZIDEBUGINSTANCETREEITEM_H
#include <QMap>
#include "ezidebugprj.h"

class QString ;
template <typename T> class QList ;
class EziDebugScanChain ;



class EziDebugInstanceTreeItem
{
public:
    struct SCAN_CHAIN_STRUCTURE
    {
        unsigned int m_untotalChainNumber ;
        unsigned int m_unleftRegNumber ;
        unsigned int m_uncurrentChainNumber;
    };

    EziDebugInstanceTreeItem(const QString instance, const QString module);
    ~EziDebugInstanceTreeItem();
    EziDebugInstanceTreeItem* parent(void) const ;
    EziDebugInstanceTreeItem* child(int num) const ;
    void appendChild(EziDebugInstanceTreeItem *child);
    void removeChild(EziDebugInstanceTreeItem *child);

    void  setScanChainInfo(EziDebugScanChain * chaininfo);
    EziDebugScanChain* getScanChainInfo();

    QString getNameData() const;
    const QString &getModuleName() const;
    const QString &getInstanceName() const ;
    QMap<QString,QString> getInstancePortMapTbl(const QString &instancename) const ;
    //void  traverseChainTreeItem(void) ;
    int   getAllRegNum(const QString &clock ,QString chainname ,int &regbitcount ,int &bitwidth ,const QStringList &instancelist);    // 从本节点开始遍历所有子节点
    int   insertScanChain(QMap<QString,SCAN_CHAIN_STRUCTURE*> &chainStructuremap ,EziDebugScanChain* pchain ,QString topmodule);
    int   deleteScanChain(EziDebugPrj::OPERATE_TYPE type) ;
    QString findCorrespondClock(QString name, QString clock ,EziDebugInstanceTreeItem * headitem) ;
    void  setModuleClockMap(const QString &instancename,const QMap<QString,QString> &clockmap);
    QMap<QString,QString> getModuleClockMap(const QString& instancename) const ;
    const QString & getItemHierarchyName(void) const ;
    void setItemParent(EziDebugInstanceTreeItem* parentitem) ;
    void settItemHierarchyName(const QString& name);
    static void setProject(EziDebugPrj*prj) ;
    static const EziDebugPrj* getProject(void) ;
    int childCount() const ;
    int row() const ;




private:
    QString m_iinstanceName ;
    QString m_imoduleName ;
    QString m_ihierarchyName ;
    EziDebugInstanceTreeItem* m_pparentInstance ;
    QList<EziDebugInstanceTreeItem*> m_ichildModules ;
    QMap<QString,QMap<QString,QString> > m_imoduleClockMap ; // 每个例化的时钟 名字 对应关系
    QMap<QString,QMap<QString,QString> > m_iinstancePortMap ;
    EziDebugScanChain* m_pChainInfo ;
    static EziDebugPrj* sm_pprj ;
};

#endif // EZIDEBUGINSTANCETREEITEM_H
