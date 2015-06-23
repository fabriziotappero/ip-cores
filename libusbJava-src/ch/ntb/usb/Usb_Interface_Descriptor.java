/* 
 * Java libusb wrapper
 * Copyright (c) 2005-2006 Andreas Schläpfer <spandi at users.sourceforge.net>
 *
 * http://libusbjava.sourceforge.net
 * This library is covered by the LGPL, read LGPL.txt for details.
 */
package ch.ntb.usb;

/**
 * Represents the descriptor of a USB interface.<br>
 * The interface descriptor could be seen as a header or grouping of the
 * endpoints into a functional group performing a single feature of the device.<br>
 * <br>
 * The length of the interface descriptor is
 * {@link ch.ntb.usb.Usb_Descriptor#USB_DT_INTERFACE_SIZE} and the type is
 * {@link ch.ntb.usb.Usb_Descriptor#USB_DT_INTERFACE}.
 * 
 */
public class Usb_Interface_Descriptor extends Usb_Descriptor {

	/**
	 * Maximum number of interfaces
	 */
	public static final int USB_MAXINTERFACES = 32;

	private byte bInterfaceNumber;

	private byte bAlternateSetting;

	private byte bNumEndpoints;

	private byte bInterfaceClass;

	private byte bInterfaceSubClass;

	private byte bInterfaceProtocol;

	private byte iInterface;

	private Usb_Endpoint_Descriptor[] endpoint;

	private byte[] extra; /* Extra descriptors */

	private int extralen;

	@Override
	public String toString() {
		return "Usb_Interface_Descriptor bNumEndpoints: 0x"
				+ Integer.toHexString(bNumEndpoints);
	}

	/**
	 * Returns the value used to select the alternate setting ({@link LibusbJava#usb_set_altinterface(long, int)}).<br>
	 * 
	 * @return the alternate setting
	 */
	public byte getBAlternateSetting() {
		return bAlternateSetting;
	}

	/**
	 * Returns the class code (Assigned by <a
	 * href="http://www.usb.org">www.usb.org</a>).<br>
	 * 
	 * @return the class code
	 */
	public byte getBInterfaceClass() {
		return bInterfaceClass;
	}

	/**
	 * Returns the number (identifier) of this interface.<br>
	 * 
	 * @return the number (identifier) of this interface
	 */
	public byte getBInterfaceNumber() {
		return bInterfaceNumber;
	}

	/**
	 * Returns the protocol code (Assigned by <a
	 * href="http://www.usb.org">www.usb.org</a>).<br>
	 * 
	 * @return the protocol code
	 */
	public byte getBInterfaceProtocol() {
		return bInterfaceProtocol;
	}

	/**
	 * Returns the subclass code (Assigned by <a
	 * href="http://www.usb.org">www.usb.org</a>).<br>
	 * 
	 * @return the subclass code
	 */
	public byte getBInterfaceSubClass() {
		return bInterfaceSubClass;
	}

	/**
	 * Returns the number of endpoints used for this interface.<br>
	 * 
	 * @return the number of endpoints used for this interface
	 */
	public byte getBNumEndpoints() {
		return bNumEndpoints;
	}

	/**
	 * Returns an array of endpoint descriptors.<br>
	 * 
	 * @return an array of endpoint descriptors
	 */
	public Usb_Endpoint_Descriptor[] getEndpoint() {
		return endpoint;
	}

	/**
	 * Returns the data of extra descriptor(s) if available.<br>
	 * 
	 * @return null or a byte array with the extra descriptor data
	 */
	public byte[] getExtra() {
		return extra;
	}

	/**
	 * Returns the number of bytes of the extra descriptor.<br>
	 * 
	 * @return the number of bytes of the extra descriptor
	 */
	public int getExtralen() {
		return extralen;
	}

	/**
	 * Returns the index of the String descriptor describing this interface.<br>
	 * 
	 * @return the index of the String descriptor
	 */
	public byte getIInterface() {
		return iInterface;
	}
}
