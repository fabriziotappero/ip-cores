#ifndef IMPORTDATADIALOG_H
#define IMPORTDATADIALOG_H
#include <QDialog>

//class QDialog ;
#include <QMap>
class QWidget ;
class QLabel  ;
class QLineEdit ;
class QButtonGroup ;
class QPushButton ;
class QListWidget ;
class EziDebugInstanceTreeItem ;
class QListWidgetItem ;
class QGroupBox ;
class QComboBox ;

class ImportDataDialog:public QDialog
{
    Q_OBJECT

public:
    enum EDGE_TYPE
    {
        edgeTypePosEdge = 0 ,
        edgeTypeNegEdge,
        edgeTypeOtherEdge
    };
    ImportDataDialog(const QMap<QString,EziDebugInstanceTreeItem*> &itemmap,QWidget *parent = 0);

//signals:
//    void findNext(const QString &str, Qt::CaseSensitivity cs);
//    void findPrevious(const QString &str, Qt::CaseSensitivity cs);
    const QString &getDataFileName(void) const;
    const QString &getChainName(void) const;
    const QString &getOutputDirectory(void) const ;
    const QMap<int,QString> &getFileIndexMap(void) const ;
    void  getResetSig(QString &resetsig,EDGE_TYPE &resetedgetype,QString &otherresetedge) ;
public slots:
    void accept();
private slots:
    void findDataFileClicked();
    void findDataFile() ;
    void findSavePathClicked();
    void showCurrentItem(QListWidgetItem* currentitem,QListWidgetItem* previousitem);
    void portSignalChange(int index) ;
    void portOtherEdge(int index) ;
//    void enableFindButton(const QString &text);

private:
    QGroupBox *m_pgroupBox ;
    QGroupBox *m_pgroupBox1 ;
    //QGroupBox *m_pgroupBox2 ;
    QLabel *m_pnodeLabel ;
    QLineEdit *m_pfileLineEdit ;

    QLabel *m_pselectedLabel ;
    QLineEdit *m_pselectedItemLineEdit ;

    QLabel * m_ptbFilePathLabel ;
    QPushButton *m_ptbFilePathButton ;
    QLineEdit *m_ptbFilePathLineEdit ;

    QListWidget * m_pnodeList ;
    QPushButton * m_pfindFileButton ;
    QPushButton *m_pokButton ;
    QPushButton *m_pcancelButton ;
    //QComboBox *m_pilaCombo ;
    QLineEdit *m_pilaLine ;
    QLineEdit *m_pfile ;

    QLabel *m_pportLabel ;
    QLabel *m_pportEdgeLabel ;
    QLabel *m_pportOtherLabel ;
    QLineEdit *m_pportOtherLineEdit ;
    QComboBox *m_presetPortCombo ;
    QComboBox *m_presetPortEdgeCombo ;


    QString  m_idataFileName ;
    QString  m_ichainName ;
    QString  m_isavePath ;

    QString   m_iresetSig ;
    EDGE_TYPE m_eresetEdge ;
    QString   m_iresetEdge ;

    QMap<int,QString> iindexFileMap ;

};

#endif // IMPORTDATADIALOG_H
