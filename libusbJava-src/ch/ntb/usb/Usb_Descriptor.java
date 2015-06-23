/* 
 * Java libusb wrapper
 * Copyright (c) 2005-2006 Andreas Schläpfer <spandi at users.sourceforge.net>
 *
 * http://libusbjava.sourceforge.net
 * This library is covered by the LGPL, read LGPL.txt for details.
 */
package ch.ntb.usb;

/**
 * Common USB descriptor values.<br>
 * 
 */
public class Usb_Descriptor {

	/**
	 * Descriptor types.
	 */
	public static final int USB_DT_DEVICE = 0x01, USB_DT_CONFIG = 0x02,
			USB_DT_STRING = 0x03, USB_DT_INTERFACE = 0x04,
			USB_DT_ENDPOINT = 0x05;

	/**
	 * Descriptor types.
	 */
	public static final int USB_DT_HID = 0x21, USB_DT_REPORT = 0x22,
			USB_DT_PHYSICAL = 0x23, USB_DT_HUB = 0x29;

	/**
	 * Descriptor sizes per descriptor type.
	 */
	public static final int USB_DT_DEVICE_SIZE = 18, USB_DT_CONFIG_SIZE = 9,
			USB_DT_INTERFACE_SIZE = 9, USB_DT_ENDPOINT_SIZE = 7,
			USB_DT_ENDPOINT_AUDIO_SIZE = 9 /* Audio extension */,
			USB_DT_HUB_NONVAR_SIZE = 7;

	private byte bLength;

	private byte bDescriptorType;

	/**
	 * Get the type of this descriptor.<br>
	 * 
	 * @return the type of this descriptor
	 */
	public byte getBDescriptorType() {
		return bDescriptorType;
	}

	/**
	 * Get the size of this descriptor in bytes.<br>
	 * 
	 * @return the size of this descriptor in bytes
	 */
	public byte getBLength() {
		return bLength;
	}

}
