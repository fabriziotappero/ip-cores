/* 
 * Java libusb wrapper
 * Copyright (c) 2005-2006 Andreas Schläpfer <spandi at users.sourceforge.net>
 *
 * http://libusbjava.sourceforge.net
 * This library is covered by the LGPL, read LGPL.txt for details.
 */
package ch.ntb.usb;

/**
 * Represents the descriptor of a USB device.<br>
 * A USB device can only have one device descriptor. It specifies some basic,
 * yet important information about the device.<br>
 * <br>
 * The length of the device descriptor is
 * {@link ch.ntb.usb.Usb_Descriptor#USB_DT_DEVICE_SIZE} and the type is
 * {@link ch.ntb.usb.Usb_Descriptor#USB_DT_DEVICE}.
 * 
 */
public class Usb_Device_Descriptor extends Usb_Descriptor {
	/**
	 * Device and/or interface class codes.
	 */
	public static final int USB_CLASS_PER_INTERFACE = 0, USB_CLASS_AUDIO = 1,
			USB_CLASS_COMM = 2, USB_CLASS_HID = 3, USB_CLASS_PRINTER = 7,
			USB_CLASS_MASS_STORAGE = 8, USB_CLASS_HUB = 9, USB_CLASS_DATA = 10,
			USB_CLASS_VENDOR_SPEC = 0xff;

	private short bcdUSB;

	private byte bDeviceClass;

	private byte bDeviceSubClass;

	private byte bDeviceProtocol;

	private byte bMaxPacketSize0;

	private short idVendor;

	private short idProduct;

	private short bcdDevice;

	private byte iManufacturer;

	private byte iProduct;

	private byte iSerialNumber;

	private byte bNumConfigurations;

	/**
	 * Returns the device release number.<br>
	 * Assigned by the manufacturer of the device.
	 * 
	 * @return the device release number
	 */
	public short getBcdDevice() {
		return bcdDevice;
	}

	/**
	 * Returns the USB specification number to which the device complies to.<br>
	 * This field reports the highest version of USB the device supports. The
	 * value is in binary coded decimal with a format of 0xJJMN where JJ is the
	 * major version number, M is the minor version number and N is the sub
	 * minor version number.<br>
	 * Examples: USB 2.0 is reported as 0x0200, USB 1.1 as 0x0110 and USB 1.0 as
	 * 0x100
	 * 
	 * @return the USB specification number to which the device complies to
	 */
	public short getBcdUSB() {
		return bcdUSB;
	}

	/**
	 * Returns the class code (Assigned by <a
	 * href="http://www.usb.org">www.usb.org</a>)<br>
	 * If equal to zero, each interface specifies it's own class code. If equal
	 * to 0xFF, the class code is vendor specified. Otherwise the field is a
	 * valid class code.
	 * 
	 * @return the class code
	 */
	public byte getBDeviceClass() {
		return bDeviceClass;
	}

	/**
	 * Returns the protocol code (Assigned by <a
	 * href="http://www.usb.org">www.usb.org</a>)<br>
	 * 
	 * @return the protocol code
	 */
	public byte getBDeviceProtocol() {
		return bDeviceProtocol;
	}

	/**
	 * Returns the subclass code (Assigned by <a
	 * href="http://www.usb.org">www.usb.org</a>)<br>
	 * 
	 * @return the subclass code
	 */
	public byte getBDeviceSubClass() {
		return bDeviceSubClass;
	}

	/**
	 * Returns the maximum packet size for endpoint zero.<br>
	 * Valid sizes are 8, 16, 32, 64.
	 * 
	 * @return the maximum packet size for endpoint zero
	 */
	public byte getBMaxPacketSize0() {
		return bMaxPacketSize0;
	}

	/**
	 * Returns the number of possible configurations supported at its current
	 * speed.<br>
	 * 
	 * @return the number of possible configurations supported at its current
	 *         speed
	 */
	public byte getBNumConfigurations() {
		return bNumConfigurations;
	}

	/**
	 * Returns the product ID (Assigned by <a
	 * href="http://www.usb.org">www.usb.org</a>)<br>
	 * 
	 * @return the product ID
	 */
	public short getIdProduct() {
		return idProduct;
	}

	/**
	 * Returns the Vendor ID (Assigned by <a
	 * href="http://www.usb.org">www.usb.org</a>)<br>
	 * 
	 * @return the Vendor ID
	 */
	public short getIdVendor() {
		return idVendor;
	}

	/**
	 * Returns the index of the manufacturer string descriptor.<br>
	 * If this value is 0, no string descriptor is used.
	 * 
	 * @return the index of the manufacturer string descriptor
	 */
	public byte getIManufacturer() {
		return iManufacturer;
	}

	/**
	 * Returns the index of the product string descriptor.<br>
	 * If this value is 0, no string descriptor is used.
	 * 
	 * @return the index of the product string descriptor
	 */
	public byte getIProduct() {
		return iProduct;
	}

	/**
	 * Returns the index of serial number string descriptor.<br>
	 * If this value is 0, no string descriptor is used.
	 * 
	 * @return the index of serial number string descriptor
	 */
	public byte getISerialNumber() {
		return iSerialNumber;
	}

	@Override
	public String toString() {
		StringBuffer sb = new StringBuffer();
		sb.append("Usb_Device_Descriptor idVendor: 0x"
				+ Integer.toHexString(idVendor & 0xFFFF) + ", idProduct: 0x"
				+ Integer.toHexString(idProduct & 0xFFFF));
		return sb.toString();
	}
}