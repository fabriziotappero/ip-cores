/* 
 * Java libusb wrapper
 * Copyright (c) 2005-2006 Andreas Schläpfer <spandi at users.sourceforge.net>
 *
 * http://libusbjava.sourceforge.net
 * This library is covered by the LGPL, read LGPL.txt for details.
 */
package ch.ntb.usb;

/**
 * Represents an USB device.<br>
 * An USB device has one device descriptor and it may have multiple
 * configuration descriptors.
 * 
 */
public class Usb_Device {

	private Usb_Device next, prev;

	private String filename;

	private Usb_Bus bus;

	private Usb_Device_Descriptor descriptor;

	private Usb_Config_Descriptor[] config;

	private byte devnum;

	private byte num_children;

	private Usb_Device children;

	/**
	 * The address of the device structure to be passed to usb_open. This value
	 * is used only internally so we don't use getter or setter methods.
	 */
	@SuppressWarnings("unused")
	private long devStructAddr;

	/**
	 * Returns the reference to the bus to which this device is connected.<br>
	 * 
	 * @return the reference to the bus to which this device is connected
	 */
	public Usb_Bus getBus() {
		return bus;
	}

	/**
	 * Returns a reference to the first child.<br>
	 * 
	 * @return a reference to the first child
	 */
	public Usb_Device getChildren() {
		return children;
	}

	/**
	 * Returns the USB config descriptors.<br>
	 * 
	 * @return the USB config descriptors
	 */
	public Usb_Config_Descriptor[] getConfig() {
		return config;
	}

	/**
	 * Returns the USB device descriptor.<br>
	 * 
	 * @return the USB device descriptor
	 */
	public Usb_Device_Descriptor getDescriptor() {
		return descriptor;
	}

	/**
	 * Returns the number assigned to this device.<br>
	 * 
	 * @return the number assigned to this device
	 */
	public byte getDevnum() {
		return devnum;
	}

	/**
	 * Returns the systems String representation.<br>
	 * 
	 * @return the systems String representation
	 */
	public String getFilename() {
		return filename;
	}

	/**
	 * Returns the pointer to the next device.<br>
	 * 
	 * @return the pointer to the next device or null
	 */
	public Usb_Device getNext() {
		return next;
	}

	/**
	 * Returns the number of children of this device.<br>
	 * 
	 * @return the number of children of this device
	 */
	public byte getNumChildren() {
		return num_children;
	}

	/**
	 * Returns the pointer to the previous device.<br>
	 * 
	 * @return the pointer to the previous device or null
	 */
	public Usb_Device getPrev() {
		return prev;
	}

	@Override
	public String toString() {
		return "Usb_Device " + filename;
	}
}