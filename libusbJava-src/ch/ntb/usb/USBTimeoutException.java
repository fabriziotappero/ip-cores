/* 
 * Java libusb wrapper
 * Copyright (c) 2005-2006 Andreas Schläpfer <spandi at users.sourceforge.net>
 *
 * http://libusbjava.sourceforge.net
 * This library is covered by the LGPL, read LGPL.txt for details.
 */
package ch.ntb.usb;

public class USBTimeoutException extends USBException {

	public USBTimeoutException(String string) {
		super(string);
	}

	/**
	 * 
	 */
	private static final long serialVersionUID = -1065328371159778249L;

}
