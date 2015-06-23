/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.debug;

import edu.byu.cc.plieber.fpgaenet.debug.llparse.LatchRBEntry;
import edu.byu.cc.plieber.fpgaenet.fcp.FCPException;
import edu.byu.cc.plieber.fpgaenet.icapif.IcapTools;
import edu.byu.ece.bitstreamTools.configuration.Frame;

/**
 * @author Peter Lieber
 *
 */
public class IcapReadback {
	
	IcapTools icapTools;
	
	public IcapReadback(IcapTools icapTools) {
		this.icapTools = icapTools;
	}
	
	public boolean readState(LatchRBEntry netEntry) throws FCPException {
		Frame frame = icapTools.readFrame(netEntry.getFrame());
		int bit = frame.getData().getBitReverse(netEntry.getFrameOffset());
		return (bit > 0);
	}
}
