/*
 * @file     CCITT4Client.h
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

#ifndef CCITT4CLIENT_H
#define CCITT4CLIENT_H

#include <QMainWindow>
#include <QKeyEvent>
#include <QGraphicsView>
#include <QGraphicsScene>
#include <QFile>
#include <QTextStream>
#include <QDataStream>
#include <QTimer>
#include <QListWidgetItem>

#include "CSerialport.h"
#include "PortSelectionDialog.h"

namespace Ui {
class CCCITT4Client;
}

class CCCITT4Client : public QMainWindow
{
    Q_OBJECT

public:
    explicit CCCITT4Client(QWidget *parent = 0, QString sStoragePath = "");
    ~CCCITT4Client();
    void UpdateFileList();

protected:
    void showEvent (QShowEvent * event);
    
private:
    Ui::CCCITT4Client *ui;
    CSerialport* m_pSerialport;
    CPortSelectionDialog *m_pPortSelectionDialog;
    int m_nCursorPos;
    QTimer m_oScreenRefreshTimer;

    QString byteToHexString(quint8 nValue);
    void setVerticalSpitter(int nIndex, int nSizePercent);
    void setHorizontalSpitter(int nIndex, int nSizePercent, int nSizePixels = 0);

public slots:
    void Show();

private slots:
    void OnBtConnectClicked();
    void OnBtSingleShotClicked();
    void OnBtRepeatClicked();
    void OnBtPathClicked();
    void keyPressEvent(QKeyEvent *event);
    void keyReleaseEvent(QKeyEvent *event);
    void OnFilesListItemClicked(QListWidgetItem* pItem);
    void OnFilesListSelectionChanged();
    void OnLineEditPathChanged(QString sPath);
    void OnScreenRefreshTimer();
    void OnShowErrorMessage(QString sMessage, bool bEnableBtSingleShot, bool bCheckedBtRepeat);
    void OnFrameCompleted(QString sFilename);
};

#endif // CCITT4CLIENT_H
