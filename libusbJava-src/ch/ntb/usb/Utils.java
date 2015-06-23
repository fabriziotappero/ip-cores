/* 
 * Java libusb wrapper
 * Copyright (c) 2005-2006 Andreas Schläpfer <spandi at users.sourceforge.net>
 *
 * http://libusbjava.sourceforge.net
 * This library is covered by the LGPL, read LGPL.txt for details.
 */
package ch.ntb.usb;

import java.io.PrintStream;

public class Utils {

	public static void logBus(Usb_Bus bus) {
		logBus(bus, System.out);
	}

	public static void logBus(Usb_Bus bus, PrintStream out) {
		Usb_Bus usb_Bus = bus;
		while (usb_Bus != null) {
			out.println(usb_Bus.toString());
			Usb_Device dev = usb_Bus.getDevices();
			while (dev != null) {
				out.println("\t" + dev.toString());
				// Usb_Device_Descriptor
				Usb_Device_Descriptor defDesc = dev.getDescriptor();
				out.println("\t\t" + defDesc.toString());
				// Usb_Config_Descriptor
				Usb_Config_Descriptor[] confDesc = dev.getConfig();
				for (int i = 0; i < confDesc.length; i++) {
					out.println("\t\t" + confDesc[i].toString());
					Usb_Interface[] int_ = confDesc[i].getInterface();
					if (int_ != null) {
						for (int j = 0; j < int_.length; j++) {
							out.println("\t\t\t" + int_[j].toString());
							Usb_Interface_Descriptor[] intDesc = int_[j]
									.getAltsetting();
							if (intDesc != null) {
								for (int k = 0; k < intDesc.length; k++) {
									out.println("\t\t\t\t"
											+ intDesc[k].toString());
									Usb_Endpoint_Descriptor[] epDesc = intDesc[k]
											.getEndpoint();
									if (epDesc != null) {
										for (int e = 0; e < epDesc.length; e++) {
											out.println("\t\t\t\t\t"
													+ epDesc[e].toString());
										}
									}
								}
							}
						}
					}
				}
				dev = dev.getNext();
			}
			usb_Bus = usb_Bus.getNext();
		}
	}
}
