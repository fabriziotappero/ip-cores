/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.examples;

import java.util.ArrayList;

import com.trolltech.qt.core.QModelIndex;
import com.trolltech.qt.core.Qt.ItemDataRole;
import com.trolltech.qt.core.Qt.ItemFlag;
import com.trolltech.qt.core.Qt.ItemFlags;
import com.trolltech.qt.core.Qt.Orientation;
import com.trolltech.qt.gui.QAbstractTableModel;

import edu.byu.cc.plieber.fpgaenet.debug.IcapReadback;
import edu.byu.cc.plieber.fpgaenet.debug.llparse.LatchRBEntry;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;

/**
 * @author Peter Lieber
 *
 */
public class NetValueModel extends QAbstractTableModel {
	
	ArrayList<LatchRBEntry> netList;
	ArrayList<String> netValueList;
	private IcapReadback icapReadback;
	
	public NetValueModel(ArrayList<LatchRBEntry> entries, IcapReadback icapRB) {
		netList = entries;
		icapReadback = icapRB;
		netValueList = new ArrayList<String>();
		for (int i=0; i<netList.size(); i++) {
			netValueList.add("<invalid>");
		}
	}
	
	public void replaceContents(ArrayList<LatchRBEntry> entries) {
		beginRemoveRows(null, 0, netList.size()-1);
		netList.clear();
		endRemoveRows();
		beginInsertRows(null, 0, entries.size()-1);
		netList = entries;
		netValueList = new ArrayList<String>();
		for (int i=0; i<netList.size(); i++) {
			netValueList.add("<invalid>");
		}
		endInsertRows();
	}

	/* (non-Javadoc)
	 * @see com.trolltech.qt.core.QAbstractItemModel#columnCount(com.trolltech.qt.core.QModelIndex)
	 */
	@Override
	public int columnCount(QModelIndex arg0) {
		return 2;
	}

	/* (non-Javadoc)
	 * @see com.trolltech.qt.core.QAbstractItemModel#data(com.trolltech.qt.core.QModelIndex, int)
	 */
	@Override
	public Object data(QModelIndex index, int role) {
		if (role != ItemDataRole.DisplayRole)
			return null;
		switch (index.column()) {
		case 0:
			return netList.get(index.row()).getFullName();
		case 1:
			return netValueList.get(index.row());
		default:
			break;
		}
		return null;
	}

	/* (non-Javadoc)
	 * @see com.trolltech.qt.core.QAbstractItemModel#rowCount(com.trolltech.qt.core.QModelIndex)
	 */
	@Override
	public int rowCount(QModelIndex parent) {
		return netList.size();
	}
	
	@Override
	public Object headerData(int section, Orientation orientation, int role) {
		if (role != ItemDataRole.DisplayRole)
			return null;
		else if (orientation == Orientation.Vertical) return "";
		switch (section) {
		case 0:
			return "Name";
		case 1:
			return "Value";
		default:
			break;
		}
		return null;
	}
	
	public LatchRBEntry getEntry(QModelIndex index) {
		return netList.get(index.row());
	}

	public void updateValues() throws FCPException {
		for (int i=0; i<netList.size(); i++) {
			LatchRBEntry entry = netList.get(i);
			if ( entry != null) {
				 netValueList.set(i, String.valueOf(icapReadback.readState(entry)));
			}
		}
		dataChanged.emit(index(0, 0, null), index(netList.size(), 0, null));
	}
}
