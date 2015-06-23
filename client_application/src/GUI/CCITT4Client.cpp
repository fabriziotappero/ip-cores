/*
 * @file     CCITT4Client.cpp
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

#include <QMessageBox>
#include <QImage>
#include <QGraphicsPixmapItem>
#include <QMessageBox>
#include <QDebug>
#include <QFileDialog>
#include <QDateTime>
#include <QListWidgetItem>
#include <QStringList>
#include <QIcon>
#include <QColor>
#include <QFile>

#include "CCITT4Client.h"
#include "ui_CCITT4Client.h"
#include "CPathLib.h"

CCCITT4Client::CCCITT4Client(QWidget *parent, QString sStoragePath) :
    QMainWindow(parent),
    ui(new Ui::CCCITT4Client)
{
    QString sTmp = sStoragePath;

    ui->setupUi(this);

    m_nCursorPos = 0;

    m_pSerialport = new CSerialport();
    m_pPortSelectionDialog = new CPortSelectionDialog();

    ui->BtSingleShot->setEnabled(false);
    ui->BtRepeat->setEnabled(false);

    if( (sStoragePath != "") && (QFile::exists(sStoragePath)) )
    {
        this->ui->lineEditPath->setText(sStoragePath);
    }
    else
    {
        this->ui->lineEditPath->setText(QDir::currentPath());
    }

    UpdateFileList();

    m_oScreenRefreshTimer.start(100);

    connect(ui->BtConnect, SIGNAL(clicked()), this, SLOT(OnBtConnectClicked()));
    connect(ui->BtSingleShot, SIGNAL(clicked()), this, SLOT(OnBtSingleShotClicked()));
    connect(ui->BtRepeat, SIGNAL(clicked()), this, SLOT(OnBtRepeatClicked()));
    connect(ui->BtPath, SIGNAL(clicked()), this, SLOT(OnBtPathClicked()));
    connect(ui->lineEditPath, SIGNAL(textChanged(QString)), this, SLOT(OnLineEditPathChanged(QString)));
    connect(ui->listWidgetFiles, SIGNAL(itemSelectionChanged()), this, SLOT(OnFilesListSelectionChanged()));
    connect(&m_oScreenRefreshTimer, SIGNAL(timeout()), this, SLOT(OnScreenRefreshTimer()));
    connect(m_pSerialport, SIGNAL(showErrorMessage(QString, bool, bool)), this, SLOT(OnShowErrorMessage(QString, bool, bool)));
    connect(m_pSerialport, SIGNAL(frameCompleted(QString)), this, SLOT(OnFrameCompleted(QString)));

}

CCCITT4Client::~CCCITT4Client()
{
    delete ui;
}

void CCCITT4Client::Show()
{
    QMainWindow::show();

    this->setHorizontalSpitter(1, -1, 140);
}

void CCCITT4Client::showEvent(QShowEvent *event)
{
    this->setHorizontalSpitter(1, -1, 240);
}

void CCCITT4Client::OnBtConnectClicked()
{
    QString sPortname = "";
    QList<QString> aPortNames;

    if(m_pSerialport == NULL)
        return;

    if(ui->BtConnect->isChecked())
    {
        ui->BtConnect->setChecked(false);

        /*
         * Show the port selection dialog to the user if there is more than
         * one port available. Show an error pop-up if no ports are available.
         */
        aPortNames = CSerialport::GetPortNames();
        if(aPortNames.size() <= 0)
        {
            QMessageBox::critical(this, "Error",
                    "No serial ports available");
            return;
        }

        m_pPortSelectionDialog->UpdateList(aPortNames);
        if(m_pPortSelectionDialog->exec() == QDialog::Accepted)
        {
            sPortname = m_pPortSelectionDialog->GetPortname();
        }
        else
        {
            ui->BtConnect->setChecked(false);
            return;
        }

#ifdef linux
        if(m_pSerialport->Connect((char*)sPortname.toStdString().c_str(), m_pPortSelectionDialog->GetBaudrate()))
#else
        if(m_pSerialport->Connect((char*)sPortname.toStdString().c_str(), m_pPortSelectionDialog->GetBaudrate()))
#endif
        {
            ui->BtSingleShot->setEnabled(true);
            ui->BtRepeat->setEnabled(true);
            ui->BtConnect->setChecked(true);
            ui->BtRepeat->setChecked(false);
        }
        else
        {
            ui->BtConnect->setChecked(false);
            QMessageBox::critical(this, "Error",
                    "Unable to connect to "+sPortname);
        }
    }
    else
    {
        m_pSerialport->Disconnect();

        ui->BtSingleShot->setEnabled(false);
        ui->BtRepeat->setEnabled(false);
        ui->BtRepeat->setChecked(false);
    }
}

void CCCITT4Client::OnBtSingleShotClicked()
{
    this->ui->statusBar->clearMessage();
    ui->textEditRxLog->insertPlainText("\n");
    m_nCursorPos = 0;

    ui->BtSingleShot->setEnabled(false);

    m_pSerialport->RequestNewFrame(QString(""), ui->lineEditPath->text());
}

void CCCITT4Client::OnBtRepeatClicked()
{
    if(ui->BtRepeat->isChecked())
    {
        if(m_pSerialport->IsStateStandby())
        {
            ui->BtSingleShot->setEnabled(false);
            OnBtSingleShotClicked();
        }
        else
        {
            ui->BtRepeat->setChecked(false);
        }
    }
    else
    {
        ui->BtSingleShot->setEnabled(true);
    }
}

void CCCITT4Client::OnBtPathClicked()
{
    QString sStorageDir = QFileDialog::getExistingDirectory(this, tr("Open Directory"),
                                                            ui->lineEditPath->text(),
                                                            QFileDialog::ShowDirsOnly
                                                            | QFileDialog::DontResolveSymlinks);
    this->ui->lineEditPath->setText(sStorageDir);
}

void CCCITT4Client::OnLineEditPathChanged(QString sPath)
{
    sPath.clear(); //To surpress the unused warning when building

    this->UpdateFileList();
}

void CCCITT4Client::OnFilesListItemClicked(QListWidgetItem *pItem)
{
    QImage *pImage;
    QString sFilename;
    QDir oDir;
    QMessageBox msgBox;

    oDir.setCurrent(ui->lineEditPath->text());

    sFilename = oDir.absoluteFilePath(pItem->text());

    this->ui->graphicsView->Scene->clear();

    pImage = new QImage(sFilename);
    if(pImage->isNull())
    {
        msgBox.setText(QString("Can't' open the file: %1").arg(sFilename));
        msgBox.exec();

        /* Update the file list because it seems to be corrupt */
        UpdateFileList();

        return;
    }

    this->ui->graphicsView->Scene->addItem(new QGraphicsPixmapItem(QPixmap::fromImage(*pImage)));
    this->show();

    /* Move the splitter to enhance the image viewer. */
    setVerticalSpitter(0, 80);
}

void CCCITT4Client::OnFilesListSelectionChanged()
{
    QListWidgetItem *pListItem = ui->listWidgetFiles->currentItem();

    OnFilesListItemClicked(pListItem);
}

void CCCITT4Client::UpdateFileList()
{
    QListWidgetItem *pListItem;
    QDir *pDir;
    QFileInfoList list;
    int i, j;
    bool bFileExists, bItemExists;

    /* Disconnect the list event while changing the contents */
    disconnect(ui->listWidgetFiles, SIGNAL(itemSelectionChanged()), this, SLOT(OnFilesListSelectionChanged()));

    /* Obtain a list of all the tif files in the selected directory */
    pDir = new QDir(ui->lineEditPath->text());
    list = pDir->entryInfoList(QStringList("*.tif"), QDir::Files | QDir::NoDotAndDotDot | QDir::NoSymLinks, QDir::Time);

    /* Remove list elements of which the corresponding file does not exist anymore */
    for(i = 0; i < ui->listWidgetFiles->count(); i++)
    {
        pListItem = ui->listWidgetFiles->item(i);

        /* Verify if the file exists */
        bFileExists = false;
        if(pListItem != NULL)
        {
            for(j = 0; (j < list.size()) && (bFileExists == false); j++)
            {
                if(list.at(j).fileName().compare(pListItem->text()) == 0)
                {
                    bFileExists = true;
                }
            }
        }

        /* Delete the list element if the file doesn't exists */
        if(bFileExists == false)
        {
            ui->listWidgetFiles->removeItemWidget(pListItem);
            delete pListItem;
            pListItem = NULL;
            i = 0;
        }
    }

    /* Iterate over all the files and add them to the list if they are not contained yet */
    for(i = 0; i < list.size(); ++i)
    {
        bItemExists = false;
        for(j = 0; j < ui->listWidgetFiles->count(); j++)
        {
            if(list.at(i).fileName().compare(ui->listWidgetFiles->item(j)->text()) == 0)
            {
                bItemExists = true;
            }
        }

        if(bItemExists == false)
        {
            pListItem = new QListWidgetItem(QIcon(list.at(i).absoluteFilePath()), list.at(i).fileName());

            ui->listWidgetFiles->addItem(pListItem);
        }
    }

    /* Alternate the backgroundcolor of the list elements */
    for(i = 0; i < ui->listWidgetFiles->count(); i++)
    {
        if(i & 0x1)
        {
            ui->listWidgetFiles->item(i)->setBackgroundColor(QColor::fromHsv(0,0,240));
        }
        else
        {
            ui->listWidgetFiles->item(i)->setBackgroundColor(QColor::fromHsv(0,0,255));
        }
    }

    delete pDir;

    /* reconnnect the list event */
    connect(ui->listWidgetFiles, SIGNAL(itemSelectionChanged()), this, SLOT(OnFilesListSelectionChanged()));
}

void CCCITT4Client::setHorizontalSpitter(int nIndex, int nSizePercent, int nSizePixels)
{
    QList<int> aSize;
    int nSizeTotal, nSizeTotalOthers, i;

    if(nSizePercent > 100)
        return;

    /* Obtain current sizes */
    aSize = ui->splitter->sizes();

    /* Verify that the splitter contains enough items */
    if( (nIndex >= aSize.count()) || (nIndex < 0) )
        return;

    /* Calculate the total size */
    nSizeTotal = this->ui->splitter->width()
            - (this->ui->splitter->handleWidth() * (this->ui->splitter->count()-1))
            - (this->ui->splitter->lineWidth() * (this->ui->splitter->count()-1) );

    /* Set the size for the other items */
    for(i = 0; i < aSize.count(); i++)
    {
        if(i != nIndex)
        {
            /* Special option: when nSizePercent < 0 then nSizePixels is used instead */
            if(nSizePercent >= 0)
            {
                aSize[i] = ((nSizeTotal * ((100 - nSizePercent) / aSize.count()-1)) / 100);
            }
            else
            {
                aSize[i] = (nSizeTotal - nSizePixels) / (aSize.count()-1);
            }
        }
    }

    /* Calcualte ocupied size of the other items */
    for(i = 0, nSizeTotalOthers = 0; i < aSize.count(); i++)
    {
        if(i != nIndex)
            nSizeTotalOthers += aSize.at(i);
    }

    /* Calculate and set the size of the requested item */
    aSize[nIndex] = nSizeTotal - nSizeTotalOthers;

    this->ui->splitter->setSizes(aSize);
}

void CCCITT4Client::setVerticalSpitter(int nIndex, int nSizePercent)
{
    QList<int> aSize;
    int nSizeTotal, nSizeTotalOthers, i;

    if( (nSizePercent < 0) || (nSizePercent > 100) )
        return;

    /* Obtain current sizes */
    aSize = ui->splitterWidgetViewer->sizes();

    /* Verify that the splitter contains 3 items(log, image and graph) */
    if( (nIndex >= aSize.count()) || (nIndex < 0) )
        return;

    /* Calculate the total size */
    nSizeTotal = this->ui->splitterWidgetViewer->height()
            - (this->ui->splitterWidgetViewer->handleWidth() * (this->ui->splitterWidgetViewer->count()-1))
            - (this->ui->splitterWidgetViewer->lineWidth() * (this->ui->splitterWidgetViewer->count()-1) );

    /* Set the size for the other items */
    for(i = 0; i < aSize.count(); i++)
    {
        if(i != nIndex)
            aSize[i] = ((nSizeTotal * ((100 - nSizePercent) / aSize.count()-1)) / 100);
    }

    /* Calcualte ocupied size of the other items */
    for(i = 0, nSizeTotalOthers = 0; i < aSize.count(); i++)
    {
        if(i != nIndex)
            nSizeTotalOthers += aSize.at(i);
    }

    /* Calculate and set the size of the requested item */
    aSize[nIndex] = nSizeTotal - nSizeTotalOthers;

    this->ui->splitterWidgetViewer->setSizes(aSize);
}

void CCCITT4Client::keyPressEvent(QKeyEvent *event)
{
    if(event->key() == Qt::Key_Escape)
    {

    }
}

void CCCITT4Client::keyReleaseEvent(QKeyEvent *event)
{
    /*
     * On the first escape event cancel any pending request.
     * On the second escape event clear the log window.
     */
    if(event->key() == Qt::Key_Escape)
    {
        if(this->m_pSerialport->IsStateWaitForData() || ui->BtRepeat->isChecked())
        {
            this->m_pSerialport->CancelRequest();

            ui->BtSingleShot->setEnabled(true);
            ui->BtRepeat->setChecked(false);
        }
        else
        {
            this->ui->textEditRxLog->clear();
        }
    }
}

QString CCCITT4Client::byteToHexString(quint8 nValue)
{
    QString sResult;

    sResult = QString("%1").arg((int)nValue, 2, 16, QChar('0'));

    return sResult;
}

void CCCITT4Client::OnScreenRefreshTimer()
{
    QByteArray aRxData;
    int i;
    char cData;

    aRxData.clear();
    m_pSerialport->GetNewBytes(&aRxData);

    for(i = 0; i < aRxData.size(); i++)
    {
        cData = aRxData.at(i);
        /*
         * Print the data on the receive log
         */
        if(m_nCursorPos == 8)
        {
            ui->textEditRxLog->insertPlainText("\t");
        }
        if(m_nCursorPos >= 16)
        {
            ui->textEditRxLog->insertPlainText("\n");
            m_nCursorPos = 0;
        }

        ui->textEditRxLog->insertPlainText(byteToHexString(cData) + " ");

        m_nCursorPos++;
    }

    this->ui->statusBar->showMessage(QString("Expected:%1, received:%2").arg(m_pSerialport->GetBytesExpected()).arg(m_pSerialport->GetBytesReceived()));
}

void CCCITT4Client::OnShowErrorMessage(QString sMessage, bool bEnableBtSingleShot, bool bCheckedBtRepeat)
{
    QMessageBox msgBox;

    msgBox.setText(sMessage);
    msgBox.exec();

    ui->BtSingleShot->setEnabled(bEnableBtSingleShot);
    ui->BtRepeat->setChecked(bCheckedBtRepeat);

    /* Update the file list */
    this->UpdateFileList();
}

void CCCITT4Client::OnFrameCompleted(QString sFilename)
{
    QImage *pImage;

    /*
     * Call this function to be sure that all the data is printed before
     * starting a new request.
     */
    OnScreenRefreshTimer();

    /* Update the file list */
    this->UpdateFileList();

    this->ui->graphicsView->Scene->clear();

    pImage = new QImage(sFilename);
    if(pImage->isNull())
    {
        return;
    }

    this->ui->graphicsView->Scene->addItem(new QGraphicsPixmapItem(QPixmap::fromImage(*pImage)));
    this->show();

    /* Move the splitter to enhance the image viewer. */
    setVerticalSpitter(0, 80);

    ui->BtSingleShot->setEnabled(true);

    /* Request for a new frame if the repeat mode is active */
    if(ui->BtRepeat->isChecked())
    {
        OnBtSingleShotClicked();
    }
}
