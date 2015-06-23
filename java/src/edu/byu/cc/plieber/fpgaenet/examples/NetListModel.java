/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.examples;

import java.util.ArrayList;
import java.util.Map;

import com.trolltech.qt.core.QModelIndex;
import com.trolltech.qt.core.Qt.ItemDataRole;
import com.trolltech.qt.core.Qt.Orientation;
import com.trolltech.qt.gui.QAbstractTableModel;

import edu.byu.cc.plieber.fpgaenet.debug.LogicalMapping;
import edu.byu.cc.plieber.fpgaenet.debug.llparse.LatchRBEntry;

/**
 * @author Peter Lieber
 *
 */
public class NetListModel extends QAbstractTableModel {

	LogicalMapping mapping;
	ArrayList<LatchRBEntry> netList;
	ArrayList<String> netTileList;
	
	public NetListModel(LogicalMapping mapping) {
		this.mapping = mapping;
		netList = new ArrayList<LatchRBEntry>();
		netTileList = new ArrayList<String>();
		for ( Map.Entry<String, LatchRBEntry> entry: mapping.getAllNetMapEntries()) {
			netList.add(entry.getValue());
			netTileList.add(entry.getKey());
		}
	}
	
	/* (non-Javadoc)
	 * @see com.trolltech.qt.core.QAbstractItemModel#columnCount(com.trolltech.qt.core.QModelIndex)
	 */
	@Override
	public int columnCount(QModelIndex parent) {
		return 5;
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
			return String.format("%8h", netList.get(index.row()).getFrame());
		case 2:
			return netList.get(index.row()).getFrameOffset();
		case 3:
			return netList.get(index.row()).getType();
		case 4:
			return netTileList.get(index.row());
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
			return "FAR";
		case 2:
			return "Offset";
		case 3:
			return "Type";
		case 4:
			return "Tile";
		default:
			break;
		}
		return null;
	}
	
	public LatchRBEntry getEntry(QModelIndex index) {
		return netList.get(index.row());
	}

}
