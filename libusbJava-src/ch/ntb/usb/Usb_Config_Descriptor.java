/* 
 * Java libusb wrapper
 * Copyright (c) 2005-2006 Andreas Schläpfer <spandi at users.sourceforge.net>
 *
 * http://libusbjava.sourceforge.net
 * This library is covered by the LGPL, read LGPL.txt for details.
 */
package ch.ntb.usb;

/**
 * Represents the descriptor of a USB configuration.<br>
 * A USB device can have several different configuration.<br>
 * <br>
 * The length of the configuration descriptor is
 * {@link ch.ntb.usb.Usb_Descriptor#USB_DT_CONFIG_SIZE} and the type is
 * {@link ch.ntb.usb.Usb_Descriptor#USB_DT_CONFIG}.
 * 
 */
public class Usb_Config_Descriptor extends Usb_Descriptor {

	/**
	 * Maximum number of configurations per device
	 */
	public static final int USB_MAXCONFIG = 8;

	private short wTotalLength;

	private byte bNumInterfaces;

	private byte bConfigurationValue;

	private byte iConfiguration;

	private byte bmAttributes;

	private byte MaxPower;

	private Usb_Interface[] interface_;

	private byte[] extra; /* Extra descriptors */

	private int extralen;

	/**
	 * Returns the value to use as an argument to select this configuration ({@link LibusbJava#usb_set_configuration(long, int)}).
	 * 
	 * @return the value to use as an argument to select this configuration
	 */
	public byte getBConfigurationValue() {
		return bConfigurationValue;
	}

	/**
	 * Returns the power parameters for this configuration.<br>
	 * <br>
	 * Bit 7: Reserved, set to 1 (USB 1.0 Bus Powered)<br>
	 * Bit 6: Self Powered<br>
	 * Bit 5: Remote Wakeup<br>
	 * Bit 4..0: Reserved, set to 0
	 * 
	 * @return the power parameters for this configuration
	 */
	public byte getBmAttributes() {
		return bmAttributes;
	}

	/**
	 * Returns the number of interfaces.<br>
	 * 
	 * @return the number of interfaces
	 */
	public byte getBNumInterfaces() {
		return bNumInterfaces;
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
	 * Returns the index of the String descriptor describing this configuration.<br>
	 * 
	 * @return the index of the String descriptor
	 */
	public byte getIConfiguration() {
		return iConfiguration;
	}

	/**
	 * Returns the USB interface descriptors.<br>
	 * 
	 * @return the USB interface descriptors
	 */
	public Usb_Interface[] getInterface() {
		return interface_;
	}

	/**
	 * Returns the maximum power consumption in 2mA units.<br>
	 * 
	 * @return the maximum power consumption in 2mA units
	 */
	public byte getMaxPower() {
		return MaxPower;
	}

	/**
	 * Returns the total length in bytes of all descriptors.<br>
	 * When the configuration descriptor is read, it returns the entire
	 * configuration hierarchy which includes all related interface and endpoint
	 * descriptors. The <code>wTotalLength</code> field reflects the number of
	 * bytes in the hierarchy.
	 * 
	 * @return the total length in bytes of all descriptors
	 */
	public short getWTotalLength() {
		return wTotalLength;
	}

	@Override
	public String toString() {
		return "Usb_Config_Descriptor bNumInterfaces: 0x"
				+ Integer.toHexString(bNumInterfaces);
	}
}