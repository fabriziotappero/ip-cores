#ifndef EZIDEBUGVHDLFILE_H
#define EZIDEBUGVHDLFILE_H
#include "ezidebugprj.h"

class EziDebugFile ;
class QFile ;
class QString ;
class EziDebugModule ;
class QDateTime ;
class EziDebugInstanceTreeItem ;


class EziDebugVhdlFile:public EziDebugFile
{
    //Q_OBJECT
public:

    EziDebugVhdlFile(const QString &filename);
    EziDebugVhdlFile(const QString &filename,const QDateTime &datetime,const QStringList &modulelist);
    ~EziDebugVhdlFile();

    void deleteScanChain(const QStringList &ideletecodelist);
    void addScanChain(EziDebugInstanceTreeItem* item);
    int scanFile(EziDebugPrj* prj,EziDebugPrj::SCAN_TYPE type);

    int  caculateExpression(QString string) ;
};

#endif // EZIDEBUGVHDLFILE_H
