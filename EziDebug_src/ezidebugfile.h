#ifndef EZIDEBUGFILE_H
#define EZIDEBUGFILE_H
#include <QFile>
#include <QMap>
#include <QDateTime>
#include <QStringList>
#include "ezidebugprj.h"


#define estimation(x) (((x) < 0)?(0):(x))


class QString ;
class EziDebugModule ;
class EziDebugInstanceTreeItem ;
//class QFile ;
//class QDateTime ;
//template <class Key, class T> class QMap ;


class EziDebugFile:public QFile
{
    //Q_OBJECT
public:

    EziDebugFile(const QString &filename);
    EziDebugFile(const QString &filename,const QDateTime &datetime,const QStringList &modulelist);
    virtual ~EziDebugFile();
    void addToFileModuleMap(QString modulename , EziDebugModule* moduleobj);
    void addToPrjModuleMap(QString modulename , EziDebugModule* moduleobj);
    void deleteFromFileModuleMap(QString modulename , EziDebugModule* moduleobj);
    void deleteFromPrjModuleMap(QString modulename , EziDebugModule* moduleobj);

    bool isExistEziDebugCode() const;
    virtual int deleteEziDebugCode() ;
    const QDateTime& getLastStoredTime() const;
    void  modifyStoredTime(const QDateTime &datetime) ;
    bool  isModifedRecently(void) ;

    void  addToModuleList(const QString& modulename) ;
    void  clearModuleList(void) ;


    const QStringList &getModuleList() const ;
    virtual void deleteScanChain(EziDebugInstanceTreeItem* item);
    virtual void addScanChain(EziDebugInstanceTreeItem* item);
    virtual int scanFile(EziDebugPrj* prj,EziDebugPrj::SCAN_TYPE type);
    virtual int  caculateExpression(QString string) ;
    bool isLibaryFile() ;
    void setLibaryFlag(bool flag)  ;

    friend void UpdateDetectThread::update() ;
    //static const QString& getCreatedRelavieDir(void);
    //static const QString& (void);
    //static const QString& getCreatedRelavieDir(void);
    //static const setEziDebugCreatedFileInfo(const QString dir ,const QString iofilename ,const QString regfilename);
private:
    //static QString m_icreatedRelativeDir ;
    //static QString m_icreatedIoFileName  ;
    //static QString m_icreatedRegFileName ;
    //static QString m_iscanIoModuleName ;
    //static QString m_iscanRegModuleName ;

    QStringList m_iModuleList ;
    QDateTime m_iUpdateTime ;
    bool m_isLibrary ;
};

#endif // EZIDEBUGFILE_H
