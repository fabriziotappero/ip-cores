/*
 * @file     PortSelectionDialog.cpp
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

#include "PortSelectionDialog.h"
#include "ui_PortSelectionDialog.h"

CPortSelectionDialog::CPortSelectionDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::CPortSelectionDialog)
{
    ui->setupUi(this);

    ui->BaudrateComboBox->addItem("9600", QVariant(9600));
    ui->BaudrateComboBox->addItem("19200", QVariant(19200));
    ui->BaudrateComboBox->addItem("38400", QVariant(38400));
    ui->BaudrateComboBox->addItem("57600", QVariant(57600));
    ui->BaudrateComboBox->addItem("115200", QVariant(115200));
    ui->BaudrateComboBox->addItem("230400", QVariant(230400));
    ui->BaudrateComboBox->setCurrentIndex(0);
}

CPortSelectionDialog::~CPortSelectionDialog()
{
    delete ui;
}

void CPortSelectionDialog::UpdateList(QList<QString> sPortNames)
{
	ui->PortsComboBox->clear();
	ui->PortsComboBox->addItems(QStringList(sPortNames));
	if(ui->PortsComboBox->count() > 0)
		ui->PortsComboBox->setCurrentIndex(0);
}

QString CPortSelectionDialog::GetPortname()
{
	return this->ui->PortsComboBox->currentText();
}

quint32 CPortSelectionDialog::GetBaudrate()
{
    return (quint32)ui->BaudrateComboBox->itemData(ui->BaudrateComboBox->currentIndex()).toInt();
}
