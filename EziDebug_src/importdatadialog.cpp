#include "importdatadialog.h"
#include <QDialog>
#include <QPushButton>
#include <QLabel>
#include <QLineEdit>
#include <QGridLayout>
#include <QListWidget>
#include <QFileDialog>
#include <QDebug>
#include <QGroupBox>
#include <QComboBox>
#include "ezidebuginstancetreeitem.h"
#include "toolwindow.h"
#include "ezidebugmodule.h"
#include "ezidebugscanchain.h"


ImportDataDialog::ImportDataDialog(const QMap<QString,EziDebugInstanceTreeItem*> &itemmap,QWidget *parent):QDialog(parent)
{   
    int ncount = 0 ;
    int nmaxSize = 0 ;
    EziDebugPrj::TOOL itool ;
    ToolWindow* iparentWidget = dynamic_cast<ToolWindow*>(parent) ;
    EziDebugPrj * pprj = const_cast<EziDebugPrj *>(iparentWidget->getCurrentProject()) ;
    itool = pprj->getToolType() ;
    m_pgroupBox = new QGroupBox("Input item setting",this) ;

    //m_pselectedLabel = new QLabel(this) ;
    //m_pselectedItemLineEdit = new QLineEdit(this) ;

    m_ptbFilePathLabel = new  QLabel(tr("Output directory:"),this) ;
    m_ptbFilePathButton = new QPushButton(tr(". . ."),this) ;
    m_ptbFilePathLineEdit = new QLineEdit(this) ;

    m_pnodeLabel = new QLabel(tr("The Scanchain Node List:"),this) ;
    m_pokButton = new QPushButton(tr("Gnerate TestBench"),this) ;
    m_pcancelButton = new QPushButton(tr("Cancel"),this) ;


    m_pnodeList = new QListWidget(this) ;

    QGridLayout *pLayout = new QGridLayout ;
    pLayout->addWidget(m_pnodeLabel, 0, 0);
    pLayout->addWidget(m_pnodeList, 1, 0,1,6);

    QHBoxLayout *pbuttonLayout = new QHBoxLayout ;
    pbuttonLayout->addWidget(m_pokButton) ;
    pbuttonLayout->addWidget(m_pcancelButton) ;

    QHBoxLayout *ptbLayout = new QHBoxLayout ;


    QGridLayout *pchildLayout = new QGridLayout ;

    //pchildLayout->addWidget(m_pselectedLabel , 0 ,0 ,1,2);
    //pchildLayout->addWidget(m_pselectedItemLineEdit,0,0,1,2);


    m_presetPortCombo = new QComboBox(this) ;
    m_presetPortEdgeCombo = new QComboBox(this) ;

    m_pportLabel = new QLabel("reset port:",this);
    m_pportEdgeLabel =new QLabel("reset edge:",this);
    m_pportOtherLabel = new QLabel("other:",this); ;
    m_pportOtherLineEdit = new QLineEdit(this) ;
    m_pportOtherLineEdit->setDisabled(true);
    m_ptbFilePathLineEdit->setDisabled(true);

    pchildLayout->addWidget(m_pportLabel,0,0,1,1,Qt::AlignLeft);
    pchildLayout->addWidget(m_pportEdgeLabel,1,0,1,1,Qt::AlignLeft);

    // ,Qt::AlignRight
    pchildLayout->addWidget(m_presetPortCombo,0,1,1,2);
    pchildLayout->addWidget(m_presetPortEdgeCombo,1,1,1,2);

    pchildLayout->addWidget(m_pportOtherLabel,2,0,1,2,Qt::AlignLeft);
    pchildLayout->addWidget(m_pportOtherLineEdit,2,1,1,2,Qt::AlignRight);


    m_pgroupBox1 = new QGroupBox("Input data file",this) ;
    QGridLayout *pchildLayout1 = new QGridLayout ;

    //m_pilaCombo = new QComboBox(this) ;
    m_pfindFileButton = new  QPushButton(tr("..."),this) ;
    m_pilaLine = new QLineEdit(this) ;
    m_pilaLine->setDisabled(true);
    //pchildLayout1->addWidget(m_pilaCombo,0,3,1,2);
    pchildLayout1->addWidget(m_pilaLine,0,0,1,2,Qt::AlignLeft);
    pchildLayout1->addWidget(m_pfindFileButton,0,2);

    m_pgroupBox1->setLayout(pchildLayout1);
    //
    pLayout->addWidget(m_pgroupBox1,3,3,1,3,Qt::AlignLeft);


    if(itool == EziDebugPrj::ToolQuartus)
    {

        connect(m_pfindFileButton, SIGNAL(clicked()),
                this, SLOT(findDataFileClicked()));
    }
    else
    {

        connect(m_pfindFileButton, SIGNAL(clicked()),
                this, SLOT(findDataFile()));
    }

    ptbLayout->addWidget(m_ptbFilePathLabel);
    ptbLayout->addWidget(m_ptbFilePathLineEdit);
    ptbLayout->addWidget(m_ptbFilePathButton);

    m_pgroupBox->setLayout(pchildLayout);

    //
    pLayout->addWidget(m_pgroupBox,3,0,1,3,Qt::AlignLeft);
    pLayout->addLayout(ptbLayout,4,0,1,6);


    pLayout->addLayout(pbuttonLayout,5,5,1,1, Qt::AlignRight);
    //

    QVBoxLayout *pmainLayout = new QVBoxLayout;

    pmainLayout->addLayout(pLayout);

    setLayout(pmainLayout);

    connect(m_pokButton, SIGNAL(clicked()),
            this, SLOT(accept()));

    connect(m_pcancelButton, SIGNAL(clicked()),
            this, SLOT(reject()));



    connect(m_ptbFilePathButton, SIGNAL(clicked()),
            this, SLOT(findSavePathClicked()));

    connect(m_pnodeList,SIGNAL(currentItemChanged(QListWidgetItem*,QListWidgetItem*)),this,SLOT(showCurrentItem(QListWidgetItem*,QListWidgetItem*)));

    connect(m_presetPortCombo,SIGNAL(currentIndexChanged(int)),this,SLOT(portSignalChange(int))) ;

    connect(m_presetPortEdgeCombo,SIGNAL(currentIndexChanged(int)),this,SLOT(portOtherEdge(int))) ;

    m_pnodeList->setFont(QFont("Times", 10 , QFont::DemiBold));
    QMap<QString,EziDebugInstanceTreeItem*>::const_iterator i = itemmap.constBegin();
    while(i != itemmap.constEnd())
    {
        QString ichainName = i.key();
        EziDebugInstanceTreeItem* pitem = i.value();
        QString ichainItem = tr("chain: %1     Node: %2").arg(ichainName).arg(pitem->getNameData());
        int nsize = m_pnodeList->fontMetrics().width(ichainItem);
        m_pnodeList->insertItem(ncount,ichainItem);
        //m_pnodeList->item(ncount)->setForeground(QBrush(QColor(90,90,252)));
        //m_pnodeList->item(ncount)->setFont(QFont("Times", 10 , QFont::DemiBold));
        m_pnodeList->item(ncount)->setIcon(QIcon(":/images/ok_1.png"));

        if(nsize > nmaxSize)
        {
            nmaxSize = nsize ;
        }
        ncount++;
        ++i;
    }

    m_ptbFilePathButton->setFont(QFont("Times",10,QFont::Bold)) ;
    m_ptbFilePathButton->setAutoDefault(false) ;
    //m_pselectedItemLineEdit->setReadOnly(true) ;

    m_ptbFilePathButton->setEnabled(false) ;
    m_pokButton->setEnabled(false );

    setWindowTitle(tr("Chose The ScanChain and corresponding Data File")) ;
    m_pnodeList->setMinimumHeight(100) ;
    m_pnodeList->setMinimumWidth(nmaxSize + 32) ;

    //this->setUpdatesEnabled();
    this->setMaximumSize(sizeHint()) ;
    this->setMinimumSize(sizeHint());

#if 0
         //QGridLayout *pchildLayout2 = new QGridLayout ;
         //pchildLayout2->addWidget(m_presetPortCombo,0,0,1,1);
         //pchildLayout2->addWidget(m_presetPortEdgeCombo,0,1,1,1);
         //m_pgroupBox2->setLayout(pchildLayout2);
         //pLayout->addWidget(m_pgroupBox2,3,1,1,2,Qt::AlignRight);

       //m_pfile = new QLineEdit(this) ;
        // pLayout->addWidget(m_pilaCombo,3,1,1,1,Qt::AlignLeft);
        // pLayout->addWidget(m_pilaLine,3,2,1,1,Qt::AlignLeft);
       //QHBoxLayout *pfindFileLayout = new QHBoxLayout ;
       //pfindFileLayout->addWidget(m_pilaCombo);
       //pfindFileLayout->addWidget(m_pfindFileButton);
       //pfindFileLayout->addWidget(m_pilaLine);
       //pfindFileLayout->addWidget(m_pfile);
      // pLayout->addWidget(m_pilaCombo,2,1);
      // pLayout->addWidget(m_pilaLine,2,2);

       //pchildLayout->addLayout(pfindFileLayout);
#endif
}

const QString &ImportDataDialog::getDataFileName(void) const
{
    return m_idataFileName ;
}
const QString &ImportDataDialog::getChainName(void) const
{
    return m_ichainName ;
}

const QString &ImportDataDialog::getOutputDirectory(void) const
{
    return m_isavePath ;
}
const QMap<int,QString> &ImportDataDialog::getFileIndexMap(void) const
{
    return iindexFileMap ;
}

void  ImportDataDialog::getResetSig(QString &resetsig,EDGE_TYPE &resetedgetype,QString &otherresetedge)
{
    resetsig = m_iresetSig ;
    resetedgetype = m_eresetEdge ;
    otherresetedge = m_iresetEdge ;
}

void ImportDataDialog::accept()
{
    if(m_presetPortCombo->currentText() != "No Reset")
    {
        m_iresetSig = m_presetPortCombo->currentText() ;
    }

    if(m_presetPortEdgeCombo->currentText() == "posedge")
    {
        m_eresetEdge = edgeTypePosEdge ;
    }
    else if(m_presetPortEdgeCombo->currentText() == "negedge")
    {
        m_eresetEdge = edgeTypeNegEdge ;
    }
    else if(m_presetPortEdgeCombo->currentText() == "other")
    {
        m_eresetEdge = edgeTypeOtherEdge ;
        m_iresetEdge = m_pportOtherLineEdit->text();
    }

    QDialog::accept();
}


void ImportDataDialog::findDataFileClicked()
{
    QString ifileType ;
    ToolWindow *parent = dynamic_cast<ToolWindow *>(this->parentWidget()) ;
    if(parent)
    {
        const EziDebugPrj *prj = parent->getCurrentProject();
        if(prj)
        {
            ifileType = "*.txt" ;
        }
    }

    m_idataFileName   = QFileDialog::getOpenFileName(this,tr("Chose Data file"),QString(),ifileType);
    m_idataFileName   = QDir::fromNativeSeparators(m_idataFileName);

    if (!m_idataFileName.isEmpty())
    {
       QString file = m_idataFileName.split("/").last();
       m_pfileLineEdit->setText(file);
       m_ptbFilePathButton->setEnabled(true);
    }
}

void ImportDataDialog::findDataFile()
{
    int nindex =  iindexFileMap.count() ;
    QString ifileType ;
    ToolWindow *parent = dynamic_cast<ToolWindow *>(this->parentWidget()) ;
    if(parent)
    {
        const EziDebugPrj *prj = parent->getCurrentProject();
        if(prj)
        {
            ifileType = "*.prn" ;
        }
    }

    m_idataFileName   = QFileDialog::getOpenFileName(this,tr("Chose Data file"),QString(),ifileType);
    m_idataFileName   = QDir::fromNativeSeparators(m_idataFileName);

    if (!m_idataFileName.isEmpty())
    {
       QString file = m_idataFileName.split("/").last();
       iindexFileMap.insert(nindex ,m_idataFileName) ;
       m_pilaLine->setText(file);
       m_ptbFilePathButton->setEnabled(true);
       m_ptbFilePathLineEdit->setEnabled(true);
    }

#if 0
    if(iindexFileMap.count() == m_pilaCombo->count())
    {
        m_ptbFilePathButton->setEnabled(true);
    }
#endif
}

void ImportDataDialog::findSavePathClicked()
{
    m_isavePath = QFileDialog::getExistingDirectory(this,tr("Choose TestBench file output directory"));
    if (!m_isavePath.isEmpty())
    {
       m_ptbFilePathLineEdit->setText(m_isavePath);
       m_pokButton->setEnabled(true);
    }
}

void ImportDataDialog::showCurrentItem(QListWidgetItem* currentitem,QListWidgetItem* previousitem)
{
    EziDebugInstanceTreeItem *pitem = NULL ;
    EziDebugModule *pmodule = NULL ;
    EziDebugScanChain *pchain = NULL ;
    //int nunitCount = 0 ;
    int nportCount = 0 ;
    //int nbitCount = 0 ;
    QString imoduleName ;
    previousitem = previousitem ;
    if(currentitem)
    {
        QString inode = currentitem->text() ;
        //QString inodeName = inode.split(QRegExp(tr("\\s+"))).at(3);
        //m_pselectedItemLineEdit->setText(inodeName);
        m_ichainName = inode.split(QRegExp(tr("\\s+"))).at(1);


        // 根据节点 以及 扫描链 统计 创建 cdc 文件 的 信号个数
        ToolWindow* iparentWidget = dynamic_cast<ToolWindow*>(this->parentWidget()) ;
        EziDebugPrj * pprj = const_cast<EziDebugPrj *>(iparentWidget->getCurrentProject()) ;
        //if(pprj->getToolType() == EziDebugPrj::ToolIse)
        //{
            pitem = pprj->getChainTreeItemMap().value(m_ichainName,pitem);
            imoduleName = pitem->getModuleName() ;
            pmodule = pprj->getPrjModuleMap().value(imoduleName,pmodule) ;
            QVector<EziDebugModule::PortStructure*> iportVec = pmodule->getPort(pprj,pitem->getInstanceName()) ;
            nportCount = 0 ;

            m_presetPortCombo->clear();

            for(;nportCount < iportVec.count() ; nportCount++)
            {
                EziDebugModule::PortStructure* pport = iportVec.at(nportCount) ;
                QString iportName = QString::fromAscii(pport->m_pPortName) ;
                m_presetPortCombo->addItem(iportName);
            }
            m_presetPortCombo->addItem(tr("No Reset"));


        //}


        if(m_pfindFileButton)
        {
            m_pfindFileButton->setEnabled(true);
            m_pilaLine->setEnabled(true);
        }
    }
}

void ImportDataDialog::portSignalChange(int index)
{
    if(m_presetPortCombo->itemText(index) == "No Reset")
    {
        m_presetPortEdgeCombo->clear();
        m_pportOtherLineEdit->setDisabled(true);
    }
    else
    {
        if(!m_presetPortCombo->itemText(index).isEmpty())
        {
            m_presetPortEdgeCombo->clear();
            m_presetPortEdgeCombo->addItem("posedge");
            m_presetPortEdgeCombo->addItem("negedge");
            m_presetPortEdgeCombo->addItem("other");
        }
    }
}

void ImportDataDialog::portOtherEdge(int index)
{
    if(m_presetPortEdgeCombo->itemText(index) == "other")
    {
        m_pportOtherLineEdit->setEnabled(true);
    }
    else
    {
        m_pportOtherLineEdit->setDisabled(true);
    }
}

