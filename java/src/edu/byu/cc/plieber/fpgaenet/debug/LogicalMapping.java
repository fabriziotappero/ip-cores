/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.debug;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.Collection;
import java.util.Hashtable;
import java.util.Map;
import java.util.Set;

import edu.byu.cc.plieber.fpgaenet.debug.llparse.*;

/**
 * @author plieber
 *
 */
public class LogicalMapping {
	LL_Virtex5 parser = null;
	Hashtable<String, RAMGroup> ramTable;
	Hashtable<String, LatchRBEntry> netTable;
	
	public LogicalMapping(String llFile) {
		try {
			parser = new LL_Virtex5(new FileInputStream(llFile));
			parser.initTables();
			parser.parseLL();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		if (parser != null) {
			ramTable = parser.getRAMGroupHash();
			netTable = parser.getNetHashBlock();
		}
	}
	
	public Set<String> getAllNets() {
		return this.netTable.keySet();
	}
	
	public LatchRBEntry getNetEntry(String netName) {
		return this.netTable.get(netName);
	}

	public Collection<LatchRBEntry> getAllNetEntries() {
		return this.netTable.values();
	}
	
	public Set<Map.Entry<String, LatchRBEntry>> getAllNetMapEntries() {
		return this.netTable.entrySet();
	}
}
