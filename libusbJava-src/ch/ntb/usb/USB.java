/* 
 * Java libusb wrapper
 * Copyright (c) 2005-2006 Andreas Schläpfer <spandi at users.sourceforge.net>
 *
 * http://libusbjava.sourceforge.net
 * This library is covered by the LGPL, read LGPL.txt for details.
 */
package ch.ntb.usb;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.logging.Logger;

import ch.ntb.usb.logger.LogUtil;

/**
 * This class manages all USB devices and defines some USB specific constants.<br>
 * 
 */
public class USB {

	// Standard requests (USB spec 9.4)
	/**
	 * This request returns status for the specified recipient (USB spec 9.4.5).
	 * 
	 * @see ch.ntb.usb.Device#controlMsg(int, int, int, int, byte[], int, int,
	 *      boolean)
	 */
	public static final int REQ_GET_STATUS = 0x00;
	/**
	 * This request is used to clear or disable a specific feature (USB spec
	 * 9.4.1).
	 * 
	 * @see ch.ntb.usb.Device#controlMsg(int, int, int, int, byte[], int, int,
	 *      boolean)
	 */
	public static final int REQ_CLEAR_FEATURE = 0x01;
	// 0x02 is reserved
	/**
	 * This request is used to set or enable a specific feature (USB spec
	 * 9.4.9).
	 * 
	 * @see ch.ntb.usb.Device#controlMsg(int, int, int, int, byte[], int, int,
	 *      boolean)
	 */
	public static final int REQ_SET_FEATURE = 0x03;
	// 0x04 is reserved
	/**
	 * This request sets the device address for all future device accesses (USB
	 * spec 9.4.6).
	 * 
	 * @see ch.ntb.usb.Device#controlMsg(int, int, int, int, byte[], int, int,
	 *      boolean)
	 */
	public static final int REQ_SET_ADDRESS = 0x05;
	/**
	 * This request returns the specified descriptor if the descriptor exists
	 * (USB spec 9.4.3).
	 * 
	 * @see ch.ntb.usb.Device#controlMsg(int, int, int, int, byte[], int, int,
	 *      boolean)
	 */
	public static final int REQ_GET_DESCRIPTOR = 0x06;
	/**
	 * This request is optional and may be used to update existing descriptors
	 * or new descriptors may be added (USB spec 9.4.8).
	 * 
	 * @see ch.ntb.usb.Device#controlMsg(int, int, int, int, byte[], int, int,
	 *      boolean)
	 */
	public static final int REQ_SET_DESCRIPTOR = 0x07;
	/**
	 * This request returns the current device configuration value (USB spec
	 * 9.4.2).
	 * 
	 * @see ch.ntb.usb.Device#controlMsg(int, int, int, int, byte[], int, int,
	 *      boolean)
	 */
	public static final int REQ_GET_CONFIGURATION = 0x08;
	/**
	 * This request sets the device configuration (USB spec 9.4.7).
	 * 
	 * @see ch.ntb.usb.Device#controlMsg(int, int, int, int, byte[], int, int,
	 *      boolean)
	 */
	public static final int REQ_SET_CONFIGURATION = 0x09;
	/**
	 * This request returns the selected alternate setting for the specified
	 * interface (USB spec 9.4.4).
	 * 
	 * @see ch.ntb.usb.Device#controlMsg(int, int, int, int, byte[], int, int,
	 *      boolean)
	 */
	public static final int REQ_GET_INTERFACE = 0x0A;
	/**
	 * This request allows the host to select an alternate setting for the
	 * specified interface (USB spec 9.4.10).
	 * 
	 * @see ch.ntb.usb.Device#controlMsg(int, int, int, int, byte[], int, int,
	 *      boolean)
	 */
	public static final int REQ_SET_INTERFACE = 0x0B;
	/**
	 * This request is used to set and then report an endpoint’s synchronization
	 * frame (USB spec 9.4.11).
	 * 
	 * @see ch.ntb.usb.Device#controlMsg(int, int, int, int, byte[], int, int,
	 *      boolean)
	 */
	public static final int REQ_SYNCH_FRAME = 0x0C;

	// data transfer direction (USB spec 9.3)
	/**
	 * Identifies the direction of data transfer in the second phase of the
	 * control transfer.<br>
	 * The state of the Direction bit is ignored if the wLength field is zero,
	 * signifying there is no Data stage.<br>
	 * Specifies bit 7 of bmRequestType.
	 * 
	 * @see ch.ntb.usb.Device#controlMsg(int, int, int, int, byte[], int, int,
	 *      boolean)
	 */
	public static final int REQ_TYPE_DIR_HOST_TO_DEVICE = (0x00 << 7),
			REQ_TYPE_DIR_DEVICE_TO_HOST = (0x01 << 7);

	// request types (USB spec 9.3)
	/**
	 * Specifies the type of the request.<br>
	 * Specifies bits 6..5 of bmRequestType.
	 * 
	 * @see ch.ntb.usb.Device#controlMsg(int, int, int, int, byte[], int, int,
	 *      boolean)
	 */
	public static final int REQ_TYPE_TYPE_STANDARD = (0x00 << 5),
			REQ_TYPE_TYPE_CLASS = (0x01 << 5),
			REQ_TYPE_TYPE_VENDOR = (0x02 << 5),
			REQ_TYPE_TYPE_RESERVED = (0x03 << 5);

	// request recipient (USB spec 9.3)
	/**
	 * Specifies the intended recipient of the request.<br>
	 * Requests may be directed to the device, an interface on the device, or a
	 * specific endpoint on a device. When an interface or endpoint is
	 * specified, the wIndex field identifies the interface or endpoint.<br>
	 * Specifies bits 4..0 of bmRequestType.
	 * 
	 * @see ch.ntb.usb.Device#controlMsg(int, int, int, int, byte[], int, int,
	 *      boolean)
	 */
	public static final int REQ_TYPE_RECIP_DEVICE = 0x00,
			REQ_TYPE_RECIP_INTERFACE = 0x01, REQ_TYPE_RECIP_ENDPOINT = 0x02,
			REQ_TYPE_RECIP_OTHER = 0x03;

	/**
	 * The maximum packet size of a bulk transfer when operating in highspeed
	 * (480 MB/s) mode.
	 */
	public static int HIGHSPEED_MAX_BULK_PACKET_SIZE = 512;

	/**
	 * The maximum packet size of a bulk transfer when operating in fullspeed
	 * (12 MB/s) mode.
	 */
	public static int FULLSPEED_MAX_BULK_PACKET_SIZE = 64;

	private static final Logger logger = LogUtil.getLogger("ch.ntb.usb");

	private static LinkedList<Device> devices = new LinkedList<Device>();

	private static boolean initUSBDone = false;

	/**
	 * Create a new device an register it in a device queue. If the device is
	 * already registered, a reference to it will be returned.<br>
	 * 
	 * @param idVendor
	 *            the vendor id of the USB device
	 * @param idProduct
	 *            the product id of the USB device
	 * @param filename
	 *            an optional filename which can be used to distinguish multiple
	 *            devices with the same vendor and product id.
	 * @return a newly created device or an already registered device
	 */
	public static Device getDevice(short idVendor, short idProduct,
			String filename) {

		// check if this device is already registered
		Device dev = getRegisteredDevice(idVendor, idProduct, filename);
		if (dev != null) {
			logger.info("return already registered device");
			return dev;
		}
		dev = new Device(idVendor, idProduct, filename);
		logger.info("create new device");
		devices.add(dev);
		return dev;
	}

	/**
	 * See {@link #getDevice(short, short, String)}. The parameter
	 * <code>filename</code> is set to null.
	 * 
	 * @param idVendor
	 * @param idProduct
	 * @return a newly created device or an already registered device
	 */
	public static Device getDevice(short idVendor, short idProduct) {
		return getDevice(idVendor, idProduct, null);
	}

	/**
	 * Get an already registered device or null if the device does not exist.<br>
	 * 
	 * @param idVendor
	 *            the vendor id of the USB device
	 * @param idProduct
	 *            the product id of the USB device
	 * @param filename
	 *            an optional filename which can be used to distinguish multiple
	 *            devices with the same vendor and product id.
	 * @return the device or null
	 */
	private static Device getRegisteredDevice(short idVendor, short idProduct,
			String filename) {
		for (Iterator<Device> iter = devices.iterator(); iter.hasNext();) {
			Device dev = iter.next();
			if (filename != null && dev.getFilename() != null
					&& filename.compareTo(dev.getFilename()) == 0
					&& dev.getIdVendor() == idVendor
					&& dev.getIdProduct() == idProduct) {
				return dev;
			} else if (dev.getIdVendor() == idVendor
					&& dev.getIdProduct() == idProduct) {
				return dev;
			}
		}
		return null;
	}

	/**
	 * Returns the root {@link Usb_Bus} element.
	 * 
	 * @return the root {@link Usb_Bus} element
	 * @throws USBException
	 */
	public static Usb_Bus getBus() throws USBException {
		if (!initUSBDone) {
			init();
		}
		LibusbJava.usb_find_busses();
		LibusbJava.usb_find_devices();

		Usb_Bus bus = LibusbJava.usb_get_busses();
		if (bus == null) {
			throw new USBException("LibusbJava.usb_get_busses(): "
					+ LibusbJava.usb_strerror());
		}
		return bus;
	}

	/**
	 * Explicitly calls {@link LibusbJava#usb_init()}. Note that you don't need
	 * to call this procedure as it is called implicitly when creating a new
	 * device with {@link USB#getDevice(short, short, String)}.
	 */
	public static void init() {
		LibusbJava.usb_init();
		initUSBDone = true;
	}
}
