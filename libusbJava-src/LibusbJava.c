/*
 * Java libusb wrapper
 * Copyright (c) 2005-2006 Andreas Schläpfer <spandi at users.sourceforge.net>
 *
 * http://libusbjava.sourceforge.net
 * This library is covered by the LGPL, read LGPL.txt for details.
 */

#include <jni.h>
#include <stddef.h>
#include <string.h>
#include <locale.h>
#include <errno.h>
#include <usb.h>
#include "LibusbJava.h"

// Windows specific stuff
#ifdef WIN32
#include <error.h>
#endif

//#define DEBUGON

// global bus (updated when usb_get_busses() is called)
struct usb_bus *busses;

// global flag for loading all class, method and field ID references
int java_references_loaded = 0;

// if > 0 an LibusbJava specific error string is set
char *libusbJavaError = NULL;

// macros to set and clear LibusbJava specific errors
#define setLibusbJavaError(error) libusbJavaError = error
#define clearLibusbJavaError() libusbJavaError = NULL

// class references
jclass usb_busClazz, usb_devClazz, usb_devDescClazz, usb_confDescClazz, \
	   usb_intClazz, usb_intDescClazz, usb_epDescClazz;

// method ID references
jmethodID usb_busMid, usb_devMid, usb_devDescMid, usb_confDescMid, \
	      usb_intMid, usb_intDescMid, usb_epDescMid;

// field ID references
// usb_bus
jfieldID usb_busFID_next, usb_busFID_prev, usb_busFID_dirname, \
		 usb_busFID_devices, usb_busFID_location, usb_busFID_root_dev;
// usb_device
jfieldID usb_devFID_next, usb_devFID_prev, usb_devFID_filename, \
		 usb_devFID_bus, usb_devFID_descriptor, usb_devFID_config, \
		 usb_devFID_devnum, usb_devFID_num_children, usb_devFID_children, \
		 usb_devFID_devStructAddr;
// usb_deviceDescriptor
jfieldID usb_devDescFID_bLength, usb_devDescFID_bDescriptorType, \
		 usb_devDescFID_bcdUSB, usb_devDescFID_bDeviceClass, \
		 usb_devDescFID_bDeviceSubClass, usb_devDescFID_bDeviceProtocol, \
		 usb_devDescFID_bMaxPacketSize0, usb_devDescFID_idVendor, \
		 usb_devDescFID_idProduct, usb_devDescFID_bcdDevice, \
		 usb_devDescFID_iManufacturer, usb_devDescFID_iProduct, \
		 usb_devDescFID_iSerialNumber, usb_devDescFID_bNumConfigurations;
// usb_configurationDescriptor
jfieldID usb_confDescFID_bLength, usb_confDescFID_bDescriptorType, usb_confDescFID_wTotalLength, \
		 usb_confDescFID_bNumInterfaces, usb_confDescFID_bConfigurationValue, \
		 usb_confDescFID_iConfiguration, usb_confDescFID_bmAttributes, usb_confDescFID_MaxPower, \
		 usb_confDescFID_interface_, usb_confDescFID_extra, usb_confDescFID_extralen;
// usb_interface
jfieldID usb_intFID_altsetting, usb_intFID_num_altsetting;
// usb_intDesc
jfieldID usb_intDescFID_bLength, usb_intDescFID_bDescriptorType, \
         usb_intDescFID_bInterfaceNumber, usb_intDescFID_bAlternateSetting, \
         usb_intDescFID_bNumEndpoints, usb_intDescFID_bInterfaceClass, \
         usb_intDescFID_bInterfaceSubClass, usb_intDescFID_bInterfaceProtocol, \
         usb_intDescFID_iInterface, usb_intDescFID_endpoint, usb_intDescFID_extra, \
         usb_intDescFID_extralen;
// usb_endpointDescriptor
jfieldID usb_epDescFID_bLength, usb_epDescFID_bDescriptorType, \
		 usb_epDescFID_bEndpointAddress, usb_epDescFID_bmAttributes, \
		 usb_epDescFID_wMaxPacketSize, usb_epDescFID_bInterval, \
		 usb_epDescFID_bRefresh, usb_epDescFID_bSynchAddress, usb_epDescFID_extra, \
		 usb_epDescFID_extralen;

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_set_debug
 * Signature: (B)V
 */
JNIEXPORT void JNICALL Java_ch_ntb_usb_LibusbJava_usb_1set_1debug
  (JNIEnv *env, jclass obj, jint level)
  {
  	clearLibusbJavaError();
  	usb_set_debug(level);
  }
/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_init
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_ch_ntb_usb_LibusbJava_usb_1init
  (JNIEnv *env, jclass obj)
  {
  	clearLibusbJavaError();
  	usb_init();
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_find_busses
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1find_1busses
  (JNIEnv *env, jclass obj)
  {
  	clearLibusbJavaError();
  	return usb_find_busses();
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_find_devices
 * Signature: ()I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1find_1devices
  (JNIEnv *env, jclass obj)
  {
  	clearLibusbJavaError();
  	return usb_find_devices();
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_get_busses
 * Signature: ()Lch/ntb/usb/Usb_Bus;
 */
JNIEXPORT jobject JNICALL Java_ch_ntb_usb_LibusbJava_usb_1get_1busses
  (JNIEnv *env, jclass obj)
  {

	clearLibusbJavaError();

	// only load class, method and field ID references once
	if (!java_references_loaded) {
	    // find classes and field ids
	    // usb_bus
	    usb_busClazz = (*env)->FindClass(env, "ch/ntb/usb/Usb_Bus");
	    if (usb_busClazz == NULL) { return NULL; /* exception thrown */ }
	  	usb_busMid = (*env)->GetMethodID(env, usb_busClazz, "<init>","()V");
	    if (usb_busMid == NULL) { return NULL; }

	    usb_busFID_next = (*env)->GetFieldID(env, usb_busClazz, "next", "Lch/ntb/usb/Usb_Bus;");
	    usb_busFID_prev = (*env)->GetFieldID(env, usb_busClazz, "prev", "Lch/ntb/usb/Usb_Bus;");
	    usb_busFID_dirname = (*env)->GetFieldID(env, usb_busClazz, "dirname", "Ljava/lang/String;");
	    usb_busFID_devices = (*env)->GetFieldID(env, usb_busClazz, "devices", "Lch/ntb/usb/Usb_Device;");
	    usb_busFID_location = (*env)->GetFieldID(env, usb_busClazz, "location", "J");
	    usb_busFID_root_dev = (*env)->GetFieldID(env, usb_busClazz, "root_dev", "Lch/ntb/usb/Usb_Device;");

	    // usb_device
	    usb_devClazz = (*env)->FindClass(env, "ch/ntb/usb/Usb_Device");
	    if (usb_devClazz == NULL) { return NULL; /* exception thrown */ }
	  	usb_devMid = (*env)->GetMethodID(env, usb_devClazz, "<init>","()V");
	    if (usb_devMid == NULL) { return NULL; }

	    usb_devFID_next = (*env)->GetFieldID(env, usb_devClazz, "next", "Lch/ntb/usb/Usb_Device;");
	    usb_devFID_prev = (*env)->GetFieldID(env, usb_devClazz, "prev", "Lch/ntb/usb/Usb_Device;");
	    usb_devFID_filename = (*env)->GetFieldID(env, usb_devClazz, "filename", "Ljava/lang/String;");
	    usb_devFID_bus = (*env)->GetFieldID(env, usb_devClazz, "bus", "Lch/ntb/usb/Usb_Bus;");
	    usb_devFID_descriptor = (*env)->GetFieldID(env, usb_devClazz, "descriptor", "Lch/ntb/usb/Usb_Device_Descriptor;");
	    usb_devFID_config = (*env)->GetFieldID(env, usb_devClazz, "config", "[Lch/ntb/usb/Usb_Config_Descriptor;");
	    usb_devFID_devnum = (*env)->GetFieldID(env, usb_devClazz, "devnum", "B");
	    usb_devFID_num_children = (*env)->GetFieldID(env, usb_devClazz, "num_children", "B");
	    usb_devFID_children = (*env)->GetFieldID(env, usb_devClazz, "children", "Lch/ntb/usb/Usb_Device;");
	    usb_devFID_devStructAddr = (*env)->GetFieldID(env, usb_devClazz, "devStructAddr", "J");


	    // usb_device_descriptor
	    usb_devDescClazz = (*env)->FindClass(env, "ch/ntb/usb/Usb_Device_Descriptor");
	    if (usb_devDescClazz == NULL) { return NULL; /* exception thrown */ }
	  	usb_devDescMid = (*env)->GetMethodID(env, usb_devDescClazz, "<init>","()V");
	    if (usb_devDescMid == NULL) { return NULL; }

	    usb_devDescFID_bLength = (*env)->GetFieldID(env, usb_devDescClazz, "bLength", "B");
	    usb_devDescFID_bDescriptorType = (*env)->GetFieldID(env, usb_devDescClazz, "bDescriptorType", "B");
	    usb_devDescFID_bcdUSB = (*env)->GetFieldID(env, usb_devDescClazz, "bcdUSB", "S");
	    usb_devDescFID_bDeviceClass = (*env)->GetFieldID(env, usb_devDescClazz, "bDeviceClass", "B");
	    usb_devDescFID_bDeviceSubClass = (*env)->GetFieldID(env, usb_devDescClazz, "bDeviceSubClass", "B");
	    usb_devDescFID_bDeviceProtocol = (*env)->GetFieldID(env, usb_devDescClazz, "bDeviceProtocol", "B");
	    usb_devDescFID_bMaxPacketSize0 = (*env)->GetFieldID(env, usb_devDescClazz, "bMaxPacketSize0", "B");
	    usb_devDescFID_idVendor = (*env)->GetFieldID(env, usb_devDescClazz, "idVendor", "S");
	    usb_devDescFID_idProduct = (*env)->GetFieldID(env, usb_devDescClazz, "idProduct", "S");
	    usb_devDescFID_bcdDevice = (*env)->GetFieldID(env, usb_devDescClazz, "bcdDevice", "S");
	    usb_devDescFID_iManufacturer = (*env)->GetFieldID(env, usb_devDescClazz, "iManufacturer", "B");
	    usb_devDescFID_iProduct = (*env)->GetFieldID(env, usb_devDescClazz, "iProduct", "B");
	    usb_devDescFID_iSerialNumber = (*env)->GetFieldID(env, usb_devDescClazz, "iSerialNumber", "B");
	    usb_devDescFID_bNumConfigurations = (*env)->GetFieldID(env, usb_devDescClazz, "bNumConfigurations", "B");

	    // usb_configuration_descriptor
	    usb_confDescClazz = (*env)->FindClass(env, "ch/ntb/usb/Usb_Config_Descriptor");
	    if (usb_confDescClazz == NULL) { return NULL; /* exception thrown */ }
	  	usb_confDescMid = (*env)->GetMethodID(env, usb_confDescClazz, "<init>","()V");
	    if (usb_confDescMid == NULL) { return NULL; }

	    usb_confDescFID_bLength = (*env)->GetFieldID(env, usb_confDescClazz, "bLength", "B");
	    usb_confDescFID_bDescriptorType = (*env)->GetFieldID(env, usb_confDescClazz, "bDescriptorType", "B");
	    usb_confDescFID_wTotalLength = (*env)->GetFieldID(env, usb_confDescClazz, "wTotalLength", "S");
	    usb_confDescFID_bNumInterfaces = (*env)->GetFieldID(env, usb_confDescClazz, "bNumInterfaces", "B");
	    usb_confDescFID_bConfigurationValue = (*env)->GetFieldID(env, usb_confDescClazz, "bConfigurationValue", "B");
	    usb_confDescFID_iConfiguration = (*env)->GetFieldID(env, usb_confDescClazz, "iConfiguration", "B");
	    usb_confDescFID_bmAttributes = (*env)->GetFieldID(env, usb_confDescClazz, "bmAttributes", "B");
	    usb_confDescFID_MaxPower = (*env)->GetFieldID(env, usb_confDescClazz, "MaxPower", "B");
	    usb_confDescFID_interface_ = (*env)->GetFieldID(env, usb_confDescClazz, "interface_", "[Lch/ntb/usb/Usb_Interface;");
	    usb_confDescFID_extra = (*env)->GetFieldID(env, usb_confDescClazz, "extra", "[B");
	    usb_confDescFID_extralen = (*env)->GetFieldID(env, usb_confDescClazz, "extralen", "I");

		// usb_interface
	    usb_intClazz = (*env)->FindClass(env, "ch/ntb/usb/Usb_Interface");
	    if (usb_intClazz == NULL) { return NULL; /* exception thrown */ }
	  	usb_intMid = (*env)->GetMethodID(env, usb_intClazz, "<init>","()V");
	    if (usb_intMid == NULL) { return NULL; }

	    usb_intFID_altsetting = (*env)->GetFieldID(env, usb_intClazz, "altsetting", "[Lch/ntb/usb/Usb_Interface_Descriptor;");
	    usb_intFID_num_altsetting = (*env)->GetFieldID(env, usb_intClazz, "num_altsetting", "I");

		// usb_interface_descriptor
	    usb_intDescClazz = (*env)->FindClass(env, "ch/ntb/usb/Usb_Interface_Descriptor");
	    if (usb_intDescClazz == NULL) { return NULL; /* exception thrown */ }
	  	usb_intDescMid = (*env)->GetMethodID(env, usb_intDescClazz, "<init>","()V");
	    if (usb_intDescMid == NULL) { return NULL; }

	    usb_intDescFID_bLength = (*env)->GetFieldID(env, usb_intDescClazz, "bLength", "B");
	    usb_intDescFID_bDescriptorType = (*env)->GetFieldID(env, usb_intDescClazz, "bDescriptorType", "B");
	    usb_intDescFID_bInterfaceNumber = (*env)->GetFieldID(env, usb_intDescClazz, "bInterfaceNumber", "B");
	    usb_intDescFID_bAlternateSetting = (*env)->GetFieldID(env, usb_intDescClazz, "bAlternateSetting", "B");
	    usb_intDescFID_bNumEndpoints = (*env)->GetFieldID(env, usb_intDescClazz, "bNumEndpoints", "B");
	    usb_intDescFID_bInterfaceClass = (*env)->GetFieldID(env, usb_intDescClazz, "bInterfaceClass", "B");
	    usb_intDescFID_bInterfaceSubClass = (*env)->GetFieldID(env, usb_intDescClazz, "bInterfaceSubClass", "B");
	    usb_intDescFID_bInterfaceProtocol = (*env)->GetFieldID(env, usb_intDescClazz, "bInterfaceProtocol", "B");
	    usb_intDescFID_iInterface = (*env)->GetFieldID(env, usb_intDescClazz, "iInterface", "B");
	    usb_intDescFID_endpoint = (*env)->GetFieldID(env, usb_intDescClazz, "endpoint", "[Lch/ntb/usb/Usb_Endpoint_Descriptor;");
	    usb_intDescFID_extra = (*env)->GetFieldID(env, usb_intDescClazz, "extra", "[B");
	    usb_intDescFID_extralen = (*env)->GetFieldID(env, usb_intDescClazz, "extralen", "I");

		// usb_endpoint_descriptor
	    usb_epDescClazz = (*env)->FindClass(env, "ch/ntb/usb/Usb_Endpoint_Descriptor");
	    if (usb_epDescClazz == NULL) { return NULL; /* exception thrown */ }
	  	usb_epDescMid = (*env)->GetMethodID(env, usb_epDescClazz, "<init>","()V");
	    if (usb_epDescMid == NULL) { return NULL; }

	    usb_epDescFID_bLength = (*env)->GetFieldID(env, usb_epDescClazz, "bLength", "B");
	    usb_epDescFID_bDescriptorType = (*env)->GetFieldID(env, usb_epDescClazz, "bDescriptorType", "B");
	    usb_epDescFID_bEndpointAddress = (*env)->GetFieldID(env, usb_epDescClazz, "bEndpointAddress", "B");
	    usb_epDescFID_bmAttributes = (*env)->GetFieldID(env, usb_epDescClazz, "bmAttributes", "B");
	    usb_epDescFID_wMaxPacketSize = (*env)->GetFieldID(env, usb_epDescClazz, "wMaxPacketSize", "S");
	    usb_epDescFID_bInterval = (*env)->GetFieldID(env, usb_epDescClazz, "bInterval", "B");
	    usb_epDescFID_bRefresh = (*env)->GetFieldID(env, usb_epDescClazz, "bRefresh", "B");
	    usb_epDescFID_bSynchAddress = (*env)->GetFieldID(env, usb_epDescClazz, "bSynchAddress", "B");
	    usb_epDescFID_extra = (*env)->GetFieldID(env, usb_epDescClazz, "extra", "[B");
	    usb_epDescFID_extralen = (*env)->GetFieldID(env, usb_epDescClazz, "extralen", "I");
#ifdef DEBUGON
		printf("usb_get_busses: Field initialization done (1)\n");
#endif
	}

	//************************************************************************//

  	struct usb_device *dev;
  	struct usb_bus *bus;

  	busses = usb_get_busses();
  	bus = busses;
  	if (!bus){
  		return NULL;
  	}

	// objects
    jobject main_usb_busObj, usb_busObj, usb_busObj_next, usb_busObj_prev, \
    		main_usb_devObj, usb_devObj, usb_devObj_next, usb_devObj_prev, \
    		usb_devDescObj, usb_confDescObj, usb_intObj, usb_intDescObj, \
    		usb_epDescObj;

    jobjectArray usb_confDescObjArray, usb_intObjArray, usb_intDescObjArray, usb_epDescObjArray;

 	usb_busObj = NULL;
	usb_busObj_prev = NULL;
	main_usb_busObj = NULL;

#ifdef DEBUGON
	printf("usb_get_busses: usb_get_busses done (2)\n");
#endif

    while (bus){
#ifdef DEBUGON
		printf("\tusb_get_busses: bus %x (3)\n", bus);
#endif

    	// create a new object for every bus
    	if (!usb_busObj) {
    		usb_busObj = (*env)->NewObject(env, usb_busClazz, usb_busMid);
			if (!usb_busObj) {
				setLibusbJavaError("shared library error: Error NewObject (usb_busObj)");
				return NULL;
			}
    		main_usb_busObj = usb_busObj;
    	}

		// fill the fields of the object
		usb_busObj_next = NULL;
		if (bus->next){
			usb_busObj_next = (*env)->NewObject(env, usb_busClazz, usb_busMid);
			if (!usb_busObj_next) {
				setLibusbJavaError("shared library error: Error NewObject (usb_busObj_next)");
				return NULL;
			}
		}
		(*env)->SetObjectField(env, usb_busObj, usb_busFID_next, usb_busObj_next);
		(*env)->SetObjectField(env, usb_busObj, usb_busFID_prev, usb_busObj_prev);
		(*env)->SetObjectField(env, usb_busObj, usb_busFID_dirname, (*env)->NewStringUTF(env, bus->dirname));
		(*env)->SetLongField(env, usb_busObj, usb_busFID_location, bus->location);

		dev = bus->devices;
		usb_devObj = NULL;
		usb_devObj_prev = NULL;
		main_usb_devObj = NULL;

		while (dev){
#ifdef DEBUGON
			printf("\tusb_get_busses: dev %x (4)\n", dev);
#endif
			// create a new object for every device
			if (!usb_devObj){
				usb_devObj = (*env)->NewObject(env, usb_devClazz, usb_devMid);
				if (!usb_devObj) {
					setLibusbJavaError("shared library error: Error NewObject (usb_devObj)");
					return NULL;
				}
				main_usb_devObj = usb_devObj;
			}
			// fill the fields of the object
			usb_devObj_next = NULL;
			if (dev->next){
				usb_devObj_next = (*env)->NewObject(env, usb_devClazz, usb_devMid);
				if (!usb_devObj_next) {
					setLibusbJavaError("shared library error: Error NewObject (usb_devObj_next)");
					return NULL;
				}
			}
			(*env)->SetObjectField(env, usb_devObj, usb_devFID_next, usb_devObj_next);
			(*env)->SetObjectField(env, usb_devObj, usb_devFID_prev, usb_devObj_prev);
			(*env)->SetObjectField(env, usb_devObj, usb_devFID_bus, usb_busObj);
			(*env)->SetObjectField(env, usb_devObj, usb_devFID_filename, (*env)->NewStringUTF(env, dev->filename));
			(*env)->SetByteField(env, usb_devObj, usb_devFID_devnum, dev->devnum);
			(*env)->SetByteField(env, usb_devObj, usb_devFID_num_children, dev->num_children);
			(*env)->SetLongField(env, usb_devObj, usb_devFID_devStructAddr, (jlong) dev);

			// device descriptor
			usb_devDescObj = (*env)->NewObject(env, usb_devDescClazz, usb_devDescMid);
			if (!usb_devDescObj) {
				setLibusbJavaError("shared library error: Error NewObject (usb_devDescObj)");
				return NULL;
			}
			(*env)->SetByteField(env, usb_devDescObj, usb_devDescFID_bLength, dev->descriptor.bLength);
			(*env)->SetByteField(env, usb_devDescObj, usb_devDescFID_bDescriptorType, dev->descriptor.bDescriptorType);
			(*env)->SetShortField(env, usb_devDescObj, usb_devDescFID_bcdUSB, dev->descriptor.bcdUSB);
			(*env)->SetByteField(env, usb_devDescObj, usb_devDescFID_bDeviceClass, dev->descriptor.bDeviceClass);
			(*env)->SetByteField(env, usb_devDescObj, usb_devDescFID_bDeviceSubClass, dev->descriptor.bDeviceSubClass);
			(*env)->SetByteField(env, usb_devDescObj, usb_devDescFID_bDeviceProtocol, dev->descriptor.bDeviceProtocol);
			(*env)->SetByteField(env, usb_devDescObj, usb_devDescFID_bMaxPacketSize0, dev->descriptor.bMaxPacketSize0);
			(*env)->SetShortField(env, usb_devDescObj, usb_devDescFID_idVendor, dev->descriptor.idVendor);
			(*env)->SetShortField(env, usb_devDescObj, usb_devDescFID_idProduct, dev->descriptor.idProduct);
			(*env)->SetShortField(env, usb_devDescObj, usb_devDescFID_bcdDevice, dev->descriptor.bcdDevice);
			(*env)->SetByteField(env, usb_devDescObj, usb_devDescFID_iManufacturer, dev->descriptor.iManufacturer);
			(*env)->SetByteField(env, usb_devDescObj, usb_devDescFID_iProduct, dev->descriptor.iProduct);
			(*env)->SetByteField(env, usb_devDescObj, usb_devDescFID_iSerialNumber, dev->descriptor.iSerialNumber);
			(*env)->SetByteField(env, usb_devDescObj, usb_devDescFID_bNumConfigurations, dev->descriptor.bNumConfigurations);

			(*env)->SetObjectField(env, usb_devObj, usb_devFID_descriptor, usb_devDescObj);
			// configuration descriptor
			// Loop through all of the configurations
			usb_confDescObjArray = (jobjectArray) (*env)->NewObjectArray(env, dev->descriptor.bNumConfigurations, usb_confDescClazz, NULL);
			if (!usb_confDescObjArray) {
				setLibusbJavaError("shared library error: Error NewObject 6");
				return NULL;
			}
			for (int c = 0; c < dev->descriptor.bNumConfigurations; c++){
#ifdef DEBUGON
				printf("\t\tusb_get_busses: configuration %x (5)\n", c);
#endif
				if (dev->config == NULL) {
					// this shouldn't happen, but it did occasionally (maybe this is (or probably was) a libusb bug)
					setLibusbJavaError("shared library error: dev->config == NULL");
					return main_usb_busObj;
				}

				usb_confDescObj = (*env)->NewObject(env, usb_confDescClazz, usb_confDescMid);
				if (!usb_confDescObj) {
					setLibusbJavaError("shared library error: Error NewObject (usb_confDescObj)");
					return NULL;
				}
				(*env)->SetObjectArrayElement(env, usb_confDescObjArray, c, usb_confDescObj);
				(*env)->SetByteField(env, usb_confDescObj, usb_confDescFID_bLength, dev->config[c].bLength);
				(*env)->SetByteField(env, usb_confDescObj, usb_confDescFID_bDescriptorType, dev->config[c].bDescriptorType);
				(*env)->SetShortField(env, usb_confDescObj, usb_confDescFID_wTotalLength, dev->config[c].wTotalLength);
				(*env)->SetByteField(env, usb_confDescObj, usb_confDescFID_bNumInterfaces, dev->config[c].bNumInterfaces);
				(*env)->SetByteField(env, usb_confDescObj, usb_confDescFID_bConfigurationValue, dev->config[c].bConfigurationValue);
				(*env)->SetByteField(env, usb_confDescObj, usb_confDescFID_iConfiguration, dev->config[c].iConfiguration);
				(*env)->SetByteField(env, usb_confDescObj, usb_confDescFID_bmAttributes, dev->config[c].bmAttributes);
				(*env)->SetByteField(env, usb_confDescObj, usb_confDescFID_MaxPower, dev->config[c].MaxPower);
				(*env)->SetIntField(env, usb_confDescObj, usb_confDescFID_extralen, dev->config[c].extralen);
				if (dev->config[c].extra){
					jbyteArray jbExtraDesc = (*env)->NewByteArray(env, dev->config[c].extralen);
					(*env)->SetByteArrayRegion(env, jbExtraDesc, 0, dev->config[c].extralen, (jbyte *) dev->config[c].extra);
					(*env)->SetObjectField(env, usb_confDescObj, usb_confDescFID_extra, jbExtraDesc);
				} else {
					(*env)->SetObjectField(env, usb_confDescObj, usb_confDescFID_extra, NULL);
				}
				// interface
				usb_intObjArray = (jobjectArray) (*env)->NewObjectArray(env, dev->config[c].bNumInterfaces, usb_intClazz, NULL);
				if (!usb_intObjArray) {
					setLibusbJavaError("shared library error: Error NewObject (usb_intObjArray)");
					return NULL;
				}
				for (int i = 0; i < dev->config[c].bNumInterfaces; i++){
#ifdef DEBUGON
					printf("\t\t\tusb_get_busses: interface %x (6)\n", i);
#endif
					if (dev->config[c].interface == NULL) {
						// this shouldn't happen
						printf("dev->config[c].interface == NULL");
						return main_usb_busObj;
					}

					usb_intObj = (*env)->NewObject(env, usb_intClazz, usb_intMid);
					if (!usb_intObj) {
						setLibusbJavaError("shared library error: Error NewObject (usb_intObj)");
						return NULL;
					}
					(*env)->SetObjectArrayElement(env, usb_intObjArray, i, usb_intObj);
					(*env)->SetIntField(env, usb_intObj, usb_intFID_num_altsetting, dev->config[c].interface[i].num_altsetting);
					// interface descriptor
					usb_intDescObjArray = (jobjectArray) (*env)->NewObjectArray(env, dev->config[c].interface[i].num_altsetting, usb_intDescClazz, NULL);
					if (!usb_intDescObjArray) {
						setLibusbJavaError("shared library error: Error NewObject (usb_intDescObjArray)");
						return NULL;
					}
					for (int a = 0; a < dev->config[c].interface[i].num_altsetting; a++){
#ifdef DEBUGON
						printf("\t\t\t\tusb_get_busses: interface descriptor %x (7)\n", a);
#endif
						if (dev->config[c].interface[i].altsetting == NULL) {
							// this shouldn't happen
							printf("LibusbJava: usb_get_busses: dev->config[c].interface[i].altsetting == NULL\n");
							return main_usb_busObj;
						}

						usb_intDescObj = (*env)->NewObject(env, usb_intDescClazz, usb_intDescMid);
						if (!usb_intDescObj) {
							setLibusbJavaError("shared library error: Error NewObject (usb_intDescObj)");
							return NULL;
						}
						(*env)->SetObjectArrayElement(env, usb_intDescObjArray, a, usb_intDescObj);
						(*env)->SetByteField(env, usb_intDescObj, usb_intDescFID_bLength, dev->config[c].interface[i].altsetting[a].bLength);
						(*env)->SetByteField(env, usb_intDescObj, usb_intDescFID_bDescriptorType, dev->config[c].interface[i].altsetting[a].bDescriptorType);
						(*env)->SetByteField(env, usb_intDescObj, usb_intDescFID_bInterfaceNumber, dev->config[c].interface[i].altsetting[a].bInterfaceNumber);
						(*env)->SetByteField(env, usb_intDescObj, usb_intDescFID_bAlternateSetting, dev->config[c].interface[i].altsetting[a].bAlternateSetting);
						(*env)->SetByteField(env, usb_intDescObj, usb_intDescFID_bNumEndpoints, dev->config[c].interface[i].altsetting[a].bNumEndpoints);
						(*env)->SetByteField(env, usb_intDescObj, usb_intDescFID_bInterfaceClass, dev->config[c].interface[i].altsetting[a].bInterfaceClass);
						(*env)->SetByteField(env, usb_intDescObj, usb_intDescFID_bInterfaceSubClass, dev->config[c].interface[i].altsetting[a].bInterfaceSubClass);
						(*env)->SetByteField(env, usb_intDescObj, usb_intDescFID_bInterfaceProtocol, dev->config[c].interface[i].altsetting[a].bInterfaceProtocol);
						(*env)->SetByteField(env, usb_intDescObj, usb_intDescFID_iInterface, dev->config[c].interface[i].altsetting[a].iInterface);
						(*env)->SetIntField(env, usb_intDescObj, usb_intDescFID_extralen, dev->config[c].interface[i].altsetting[a].extralen);
						if (dev->config[c].interface[i].altsetting[a].extra){
							jbyteArray jbExtraDesc = (*env)->NewByteArray(env, dev->config[c].interface[i].altsetting[a].extralen);
							(*env)->SetByteArrayRegion(env, jbExtraDesc, 0, dev->config[c].interface[i].altsetting[a].extralen, (jbyte *) dev->config[c].interface[i].altsetting[a].extra);
							(*env)->SetObjectField(env, usb_intDescObj, usb_intDescFID_extra, jbExtraDesc);
						} else {
							(*env)->SetObjectField(env, usb_intDescObj, usb_intDescFID_extra, NULL);
						}
						// endpoint descriptor
						usb_epDescObjArray = (jobjectArray) (*env)->NewObjectArray(env, dev->config[c].interface[i].altsetting[a].bNumEndpoints, usb_epDescClazz, NULL);
						if (!usb_epDescObjArray) {
							setLibusbJavaError("shared library error: Error NewObject (usb_epDescObjArray)");
							return NULL;
						}
						for (int e = 0; e < dev->config[c].interface[i].altsetting[a].bNumEndpoints; e++){
#ifdef DEBUGON
							printf("\t\t\t\t\tusb_get_busses: endpoint descriptor %x (8)\n", e);
#endif
							if (dev->config[c].interface[i].altsetting[a].endpoint == NULL) {
								printf("LibusbJava: usb_get_busses: dev->config[c].interface[i].altsetting[a].endpoint == NULL\n");
								return main_usb_busObj;
							}

							usb_epDescObj = (*env)->NewObject(env, usb_epDescClazz, usb_epDescMid);
							if (!usb_epDescObj)	{
								setLibusbJavaError("shared library error: Error NewObject (usb_epDescObj)");
								return NULL;
							}
							(*env)->SetObjectArrayElement(env, usb_epDescObjArray, e, usb_epDescObj);
							(*env)->SetByteField(env, usb_epDescObj, usb_epDescFID_bLength, dev->config[c].interface[i].altsetting[a].endpoint[e].bLength);
							(*env)->SetByteField(env, usb_epDescObj, usb_epDescFID_bDescriptorType, dev->config[c].interface[i].altsetting[a].endpoint[e].bDescriptorType);
							(*env)->SetByteField(env, usb_epDescObj, usb_epDescFID_bEndpointAddress, dev->config[c].interface[i].altsetting[a].endpoint[e].bEndpointAddress);
							(*env)->SetByteField(env, usb_epDescObj, usb_epDescFID_bmAttributes, dev->config[c].interface[i].altsetting[a].endpoint[e].bmAttributes);
							(*env)->SetShortField(env, usb_epDescObj, usb_epDescFID_wMaxPacketSize, dev->config[c].interface[i].altsetting[a].endpoint[e].wMaxPacketSize);
							(*env)->SetByteField(env, usb_epDescObj, usb_epDescFID_bInterval, dev->config[c].interface[i].altsetting[a].endpoint[e].bInterval);
							(*env)->SetByteField(env, usb_epDescObj, usb_epDescFID_bRefresh, dev->config[c].interface[i].altsetting[a].endpoint[e].bRefresh);
							(*env)->SetByteField(env, usb_epDescObj, usb_epDescFID_bSynchAddress, dev->config[c].interface[i].altsetting[a].endpoint[e].bSynchAddress);
							(*env)->SetIntField(env, usb_epDescObj, usb_epDescFID_extralen, dev->config[c].interface[i].altsetting[a].endpoint[e].extralen);
							if (dev->config[c].interface[i].altsetting[a].endpoint[e].extra){
								jbyteArray jbExtraDesc = (*env)->NewByteArray(env, dev->config[c].interface[i].altsetting[a].endpoint[e].extralen);
								(*env)->SetByteArrayRegion(env, jbExtraDesc, 0, dev->config[c].interface[i].altsetting[a].endpoint[e].extralen, (jbyte *) dev->config[c].interface[i].altsetting[a].endpoint[e].extra);
								(*env)->SetObjectField(env, usb_epDescObj, usb_epDescFID_extra, jbExtraDesc);
							} else {
								(*env)->SetObjectField(env, usb_epDescObj, usb_epDescFID_extra, NULL);
							}
						}
						(*env)->SetObjectField(env, usb_intDescObj, usb_intDescFID_endpoint, usb_epDescObjArray);
					}
					(*env)->SetObjectField(env, usb_intObj, usb_intFID_altsetting, usb_intDescObjArray);
				}
				(*env)->SetObjectField(env, usb_confDescObj, usb_confDescFID_interface_, usb_intObjArray);
			}


			(*env)->SetObjectField(env, usb_devObj, usb_devFID_config, usb_confDescObjArray);

			usb_devObj_prev = usb_devObj;
			usb_devObj = usb_devObj_next;
			dev = dev->next;
		}
		(*env)->SetObjectField(env, usb_busObj, usb_busFID_devices, main_usb_devObj);
		(*env)->SetObjectField(env, usb_busObj, usb_busFID_root_dev, main_usb_devObj);

		usb_busObj_prev = usb_busObj;
		usb_busObj = usb_busObj_next;
    	bus = bus->next;
    }

#ifdef DEBUGON
	printf("usb_get_busses: done\n");
#endif
  	return main_usb_busObj;
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_open
 * Signature: (Lch/ntb/usb/Usb_Device;)I
 */
JNIEXPORT jlong JNICALL Java_ch_ntb_usb_LibusbJava_usb_1open
  (JNIEnv *env, jclass obj, jobject dev)
  {
  	clearLibusbJavaError();
  	if (busses == NULL) {
  		setLibusbJavaError("shared library error: busses is null");
  		return 0;
	}

  	jlong usb_device_cmp_addr = (*env)->GetLongField(env, dev, usb_devFID_devStructAddr);
  	struct usb_bus *tmpBus;

  	for (tmpBus = busses; tmpBus; tmpBus = tmpBus->next) {
  		struct usb_device *device;
		for (device = tmpBus->devices; device; device = device->next) {
	  		if ((jlong) device == usb_device_cmp_addr){
	  			return (jlong) usb_open(device);
	  		}
		}
  	}
  	setLibusbJavaError("shared library error: no device with dev.devnum found on busses");
  	return 0;
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_close
 * Signature: (J)I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1close
  (JNIEnv *env, jclass obj, jlong dev_handle)
  {
  	clearLibusbJavaError();
	return (jint) usb_close((usb_dev_handle *) dev_handle);
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_set_configuration
 * Signature: (JI)I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1set_1configuration
  (JNIEnv *env, jclass obj, jlong dev_handle, jint configuration)
  {
  	clearLibusbJavaError();
 	return usb_set_configuration((usb_dev_handle *) dev_handle, configuration);
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_set_altinterface
 * Signature: (JI)I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1set_1altinterface
  (JNIEnv *env, jclass obj, jlong dev_handle, jint alternate)
  {
  	clearLibusbJavaError();
 	return usb_set_altinterface((usb_dev_handle *) dev_handle, alternate);
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_clear_halt
 * Signature: (JI)I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1clear_1halt
  (JNIEnv *env, jclass obj, jlong dev_handle, jint ep)
  {
  	clearLibusbJavaError();
 	return usb_clear_halt((usb_dev_handle *) dev_handle, (unsigned) ep);
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_reset
 * Signature: (J)I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1reset
  (JNIEnv *env, jclass obj, jlong dev_handle)
  {
  	clearLibusbJavaError();
 	return usb_reset((usb_dev_handle *) dev_handle);
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_claim_interface
 * Signature: (JI)I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1claim_1interface
  (JNIEnv *env, jclass obj, jlong dev_handle, jint interface)
  {
  	clearLibusbJavaError();
 	return usb_claim_interface((usb_dev_handle *) dev_handle, interface);
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_release_interface
 * Signature: (JI)I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1release_1interface
  (JNIEnv *env, jclass obj, jlong dev_handle, jint interface)
  {
  	clearLibusbJavaError();
 	return usb_release_interface((usb_dev_handle *) dev_handle, interface);
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_control_msg
 * Signature: (JIIII[BII)I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1control_1msg
  (JNIEnv *env, jclass obj, jlong dev_handle, jint requesttype, jint request, jint value, jint index, jbyteArray jbytes, jint size, jint timeout)
  {
  	clearLibusbJavaError();
  	jbyte *bytes = (*env)->GetByteArrayElements(env, jbytes, NULL);
  	int num_bytes = usb_control_msg((usb_dev_handle *) dev_handle, requesttype, request, value, index, (char *) bytes, size, timeout);
  	(*env)->SetByteArrayRegion(env, jbytes, 0, size, bytes);
  	(*env)->ReleaseByteArrayElements(env, jbytes, bytes, 0);
  	return num_bytes;
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_get_string
 * Signature: (JII)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_ch_ntb_usb_LibusbJava_usb_1get_1string
  (JNIEnv *env, jclass obj, jlong dev_handle, jint index, jint langid)
  {
  	clearLibusbJavaError();
	char string[256];
 	int retVal = usb_get_string((usb_dev_handle *) dev_handle, index, langid, string, 256);
 	if (retVal > 0)
 		return (*env)->NewStringUTF(env, string);
 	return 0;
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_get_string_simple
 * Signature: (JI)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_ch_ntb_usb_LibusbJava_usb_1get_1string_1simple
  (JNIEnv *env, jclass obj, jlong dev_handle, jint index)
  {
  	clearLibusbJavaError();
	char string[256];
 	int retVal = usb_get_string_simple((usb_dev_handle *) dev_handle, index, string, 256);
 	if (retVal > 0)
 		return (*env)->NewStringUTF(env, string);
 	return 0;
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_get_descriptor
 * Signature: (JBBI)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_ch_ntb_usb_LibusbJava_usb_1get_1descriptor
  (JNIEnv *env, jclass obj, jlong dev_handle, jbyte type, jbyte index, jint size)
  {
  	clearLibusbJavaError();
	char *string = (char *) malloc(size * sizeof(char));
 	int retVal = usb_get_descriptor((usb_dev_handle *) dev_handle, (unsigned) type,
 										(unsigned) index, string, size);
 	if (retVal > 0)
 		return (*env)->NewStringUTF(env, string);
 	return 0;
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_get_descriptor_by_endpoint
 * Signature: (JIBBI)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_ch_ntb_usb_LibusbJava_usb_1get_1descriptor_1by_1endpoint
  (JNIEnv *env, jclass obj, jlong dev_handle, jint ep, jbyte type, jbyte index, jint size)
  {
  	clearLibusbJavaError();
	char *string = (char *) malloc(size * sizeof(char));
 	int retVal = usb_get_descriptor_by_endpoint((usb_dev_handle *) dev_handle, ep, (unsigned) type,
 												(unsigned) index, string, size);
 	if (retVal > 0)
 		return (*env)->NewStringUTF(env, string);
 	return 0;
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_bulk_write
 * Signature: (JI[BII)I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1bulk_1write
  (JNIEnv *env, jclass obj, jlong dev_handle, jint ep, jbyteArray jbytes, jint size, jint timeout)
  {
  	clearLibusbJavaError();
  	jbyte *bytes = (*env)->GetByteArrayElements(env, jbytes, NULL);
 	int num_bytes = usb_bulk_write((usb_dev_handle *) dev_handle, ep, (char *) bytes, size, timeout);
 	(*env)->ReleaseByteArrayElements(env, jbytes, bytes, 0);
 	return num_bytes;
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_bulk_read
 * Signature: (JI[BII)I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1bulk_1read
  (JNIEnv *env, jclass obj, jlong dev_handle, jint ep, jbyteArray jbytes, jint size, jint timeout)
  {
  	clearLibusbJavaError();
  	char *bytes = (char *) malloc(size * sizeof(char));
 	int num_bytes = usb_bulk_read((usb_dev_handle *) dev_handle, ep, bytes, size, timeout);
  	if (!bytes) { return num_bytes; }
  	(*env)->SetByteArrayRegion(env, jbytes, 0, size, (jbyte *) bytes);
  	free(bytes);
 	return num_bytes;
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_interrupt_write
 * Signature: (JI[BII)I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1interrupt_1write
  (JNIEnv *env, jclass obj, jlong dev_handle, jint ep, jbyteArray jbytes, jint size, jint timeout)
  {
  	clearLibusbJavaError();
  	jbyte *bytes = (*env)->GetByteArrayElements(env, jbytes, NULL);
  	int num_bytes = usb_interrupt_write( (usb_dev_handle *) dev_handle, ep, (char *) bytes, size, timeout);
 	(*env)->ReleaseByteArrayElements(env, jbytes, bytes, 0);
 	return num_bytes;
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_interrupt_read
 * Signature: (JI[BII)I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1interrupt_1read
  (JNIEnv *env, jclass obj, jlong dev_handle, jint ep, jbyteArray jbytes, jint size, jint timeout)
  {
  	clearLibusbJavaError();
  	char *bytes = (char *) malloc(size * sizeof(char));
 	int num_bytes = usb_interrupt_read((usb_dev_handle *) dev_handle, ep, bytes, size, timeout);
  	if (!bytes) { return num_bytes; }
  	(*env)->SetByteArrayRegion(env, jbytes, 0, size, (jbyte *) bytes);
  	free(bytes);
 	return num_bytes;
  }

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_strerror
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_ch_ntb_usb_LibusbJava_usb_1strerror
  (JNIEnv *env, jclass obj){

  	char *str;
  	// check for LibusbJava specific errors first
  	if (libusbJavaError != NULL) {
  		str = libusbJavaError;
  		clearLibusbJavaError();
  	} else {
	  	str = usb_strerror();
  	}

  	return (*env)->NewStringUTF(env, str);
}

/*
 * Class:     ch_ntb_usb_LibusbJava
 * Method:    usb_error_no
 * Signature: (I)I
 */
JNIEXPORT jint JNICALL Java_ch_ntb_usb_LibusbJava_usb_1error_1no
  (JNIEnv *env, jclass obj, jint java_error_no){

	switch (java_error_no) {
	case 0:
		return 0;
	case 1:
		return EBADF;
	case 2:
		return ENXIO;
	case 3:
		return EBUSY;
	case 4:
		return EINVAL;
	case 5:
		return ETIMEDOUT;
	case 6:
		return EIO;
	case 7:
		return ENOMEM;
	default:
		return 100000;
	}
}
