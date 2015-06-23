/**
 * 
 */
package edu.byu.cc.plieber.fpgaenet.fcp;

/**
 * @author Peter Lieber
 *
 */
public class FCPException extends Exception {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = -4218060356196155780L;
	
	public FCPException() {
		super("FCP Exception");
	}
	public FCPException(String message) {
		super(message);
	}
}
