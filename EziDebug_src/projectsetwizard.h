#ifndef PROJECTSETWIZARD_H
#define PROJECTSETWIZARD_H

#include <QWizard>
#include "ezidebugprj.h"

QT_BEGIN_NAMESPACE
class QComboBox;
class QLabel;
class QPushButton;
class QWizardPage;
class QTableWidgetItem;
class QLineEdit;
class QString;
class QSpinBox ;
class QRadioButton ;
class QCheckBox ;
QT_END_NAMESPACE

class ProjectSetWizard : public QWizard
{
    Q_OBJECT

public:
    ProjectSetWizard(QWidget *parent = 0);
    ~ProjectSetWizard();
    QString getProPath();
    void done (int result) ;

    QString m_icurrentDir ;
    unsigned int m_uncurrentRegNum ;
    EziDebugPrj::TOOL m_ecurrentTool ;
    bool m_isXilinxErrChecked ;

    //int chainNum;

private slots:
    void browse();
    void saveModifiedPage(int m);
    void cc();
    void changeXilinxCompileOption(bool checked) ;

private:
    void createPage1();
    void createPage2();
    void createConclusionPage();

    QPushButton *createButton(const QString &text, const char *member);
    QComboBox *createComboBox(const QString &text = QString(), const QStringList &items =  QStringList());

    QWizardPage* m_iprjSetPage ;
    QWizardPage* m_iregSetPage ;
    QWizardPage* m_itoolSetPage ;

    QWizardPage* m_currentPage ;

    QLabel * m_imaxregNumLabel ;
    QPushButton *browseButton;
    QComboBox *proPathComboBox;
    QComboBox *slotComboBox;
    QSpinBox *spinBox ;
    QComboBox * m_nregNumComBox ;
    QRadioButton *alteraCheckBox ;
    QRadioButton *xilinxCheckBox ;
    QCheckBox *m_ixilinxComplieOption ;

};



#endif // PROJECTSETWIZARD_H
