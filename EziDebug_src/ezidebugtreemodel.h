#ifndef EZIDEBUGTREEMODEL_H
#define EZIDEBUGTREEMODEL_H
#include <QIcon>
#include <QAbstractItemModel>
class EziDebugInstanceTreeItem ;

class EziDebugTreeModel:public QAbstractItemModel
{
    //Q_OBJECT
public:
    EziDebugTreeModel(EziDebugInstanceTreeItem* item, QObject *parent);
    ~EziDebugTreeModel();

    QVariant data(const QModelIndex &index, int role) const;
    Qt::ItemFlags flags(const QModelIndex &index) const;
    QVariant headerData(int section, Qt::Orientation orientation,int role = Qt::DisplayRole) const;
    QModelIndex index(int row, int column,const QModelIndex &parent = QModelIndex()) const;
    QModelIndex parent(const QModelIndex &child) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;

    EziDebugInstanceTreeItem* getInstanceTreeRootItem(void) ;
    void  setInstanceTreeRootItem(EziDebugInstanceTreeItem* item);

private:
   EziDebugInstanceTreeItem* m_pheadItem ;
   EziDebugInstanceTreeItem* m_pinstanceTopItem ;
};

#endif // EZIDEBUGTREEMODEL_H
