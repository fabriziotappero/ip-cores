/*
 * @file     PortSelectionDialog.h
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

#ifndef PORTSELECTIONDIALOG_H
#define PORTSELECTIONDIALOG_H

#include <QDialog>

namespace Ui {
    class CPortSelectionDialog;
}

class CPortSelectionDialog : public QDialog
{
    Q_OBJECT

public:
    explicit CPortSelectionDialog(QWidget *parent = 0);
    ~CPortSelectionDialog();
	void UpdateList(QList<QString> sPortNames);
	QString GetPortname();
    quint32 GetBaudrate();

private:
    Ui::CPortSelectionDialog *ui;
};

#endif // PORTSELECTIONDIALOG_H
