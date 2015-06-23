;;; -*- asm -*-
;;; $Id: dscr_gen.A51 605 2014-11-18 22:34:44Z mueller $ 
;;;
;;; Copyright 2011-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
;;; Code was forked from ixo-jtag.svn.sourceforge.net on 2011-07-17
;;;
;;;- original copyright and licence disclaimer ---------------------------------
;;;- Copyright 2005..2007 Kolja Waschk, ixo.de
;;;- Code based on USRP2 firmware (GNU Radio Project), version 3.0.2,
;;;- Copyright 2003 Free Software Foundation, Inc.
;;;- This code is part of usbjtag. usbjtag is free software;
;;;- ---------------------------------------------------------------------------
;;;
;;; This program is free software; you may redistribute and/or modify it under
;;; the terms of the GNU General Public License as published by the Free
;;; Software Foundation, either version 2, or at your option any later version.
;;;
;;; This program is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
;;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;;; for complete details.
;;; 
;;;-----------------------------------------------------------------------------
;;; USB Descriptor, common source for jtag + 0, 2, or 3 hardware fifo interface
;;; 
;;; Use C preprocessor to create an assembler source for the configurations:
;;;
;;;   Endpoint   Usage   Comment    
;;;   EP1 IN     jtag    always defined
;;;   EP2 OUT    jtag    always defined
;;;   EP4 OUT    data    defined if USE_2FIFO or USE_3FIFO
;;;   EP6 IN     data    defined if USE_2FIFO or USE_3FIFO
;;;   EP8 IN     data    defined if USE_3FIFO
;;; 
;;; Available preprocessor options
;;; 
;;;   USE_VID            USB Vendor ID
;;;   USE_PID            USB Product ID
;;; 
;;;   USE_2FIFO          if given EP4 OUT and EP6 IN created
;;;   USE_3FIFO          if given EP4 OUT, EP6 IN and EP8 IN created
;;;   USE_DID=0xhhhh     for product version (default 0x0004)
;;;   USE_MAXPOWER=nnn   for USB max current (in units of 2 mA; default 250)
;;; 
;;;   USE_NEXYS2         prefix 'nexys2_' in iProduct string
;;;   USE_NEXYS3         prefix 'nexys3_' in iProduct string
;;;   USE_AS             suffix '_as' in iProduct string
;;;   USE_IC             suffix '_ic' in iProduct string
;;; 
;;; Usage
;;;   cpp -P -x assembler-with-cpp dscr_gen.A51             > ... 
;;;   cpp -P -x assembler-with-cpp dscr_gen.A51 -DUSE_2FIFO > ...
;;;   cpp -P -x assembler-with-cpp dscr_gen.A51 -DUSE_3FIFO > ...
;;; 
;;; 
;;; Revision History:
;;;
;;; Date         Rev Version  Comment
;;; 2014-11-18   605   2.2    BUGFIX: correct string 0 descriptor
;;; 2012-02-11   457   2.1    iVendor string now reflects firmware file name;
;;;                           iSerial string now 00000000;
;;;                           VID/PID now via USE_VID/USE_PID defines
;;; 2011-07-24   398   2.0    Convert all *.a51 to one common source
;;; 2011-07-17   395   1.1    Use USB 2.0; New string values; use 512 byte for
;;;                           all high speed endpoints
;;; 2011-07-17   395   1.0    Initial version (derived from dscr_jtag.a51)
;;;-----------------------------------------------------------------------------

#ifndef USE_DID
#define USE_DID  0x0004
#endif

#ifndef USE_MAXPOWER
#define USE_MAXPOWER  250
#endif

#ifdef  USE_3FIFO
#define NUM_EPS 5
#elif   USE_2FIFO
#define NUM_EPS 4
#else
#define NUM_EPS 2
#endif

        .module usb_descriptors

        VID              = USE_VID    ; Vendor ID  
        PID              = USE_PID    ; Product ID 
        VERSION          = USE_DID    ; Version  
        
        USB_VER          = 0x0200     ; Support USB version 2.00
        USB_ATTR         = 0x80       ; Bus powered, no remote wakeup
        FTD_ATTR         = 0x001C     ; Set USB version, use version string, enable suspend PD
        MAX_POWER        = USE_MAXPOWER

        DSCR_DEVICE      =   1        ; Descriptor type: Device
        DSCR_CONFIG      =   2        ; Descriptor type: Configuration
        DSCR_STRING      =   3        ; Descriptor type: String
        DSCR_INTRFC      =   4        ; Descriptor type: Interface
        DSCR_ENDPNT      =   5        ; Descriptor type: Endpoint
        DSCR_DEVQUAL     =   6        ; Descriptor type: Device Qualifier
        
        DSCR_DEVICE_LEN  =  18
        DSCR_CONFIG_LEN  =   9
        DSCR_INTRFC_LEN  =   9
        DSCR_ENDPNT_LEN  =   7
        DSCR_DEVQUAL_LEN =  10
        
        ET_CONTROL       =   0        ; Endpoint type: Control
        ET_ISO           =   1        ; Endpoint type: Isochronous
        ET_BULK          =   2        ; Endpoint type: Bulk
        ET_INT           =   3        ; Endpoint type: Interrupt
        
;;; --------------------------------------------------------
;;;        external ram data
;;;--------------------------------------------------------
        
        .area USBDESCSEG    (XDATA)
       
        .even      ; descriptors must be 2-byte aligned for SUDPTR{H,L} to work

        ;; The .even directive isn't really honored by the linker.  Bummer!
        ;; (There's no way to specify an alignment requirement for a given area,
        ;; hence when they're concatenated together, even doesn't work.)
        ;; 
        ;; We work around this by telling the linker to put USBDESCSEG
        ;; at absolute address 0xE100 (see LDFLAGS in Makefile).

;;; ----------------------------------------------------------------
;;; descriptors used when operating at high speed (480Mbps)
;;; ----------------------------------------------------------------
         
_high_speed_device_descr::
        .db        DSCR_DEVICE_LEN
        .db        DSCR_DEVICE
_dscr_usbver::
        .db        <USB_VER         ; Specification version (LSB)
        .db        >USB_VER         ; Specification version (MSB)
        .db        0x00             ; device class (vendor specific)
        .db        0x00             ; device subclass (vendor specific)
        .db        0x00             ; device protocol (vendor specific)
        .db        64               ; bMaxPacketSize0 for endpoint 0
_dscr_vidpidver::
        .db        <VID             ; idVendor
        .db        >VID             ; idVendor
        .db        <PID             ; idProduct
        .db        >PID             ; idProduct
        .db        <VERSION         ; bcdDevice
        .db        >VERSION         ; bcdDevice
_dscr_strorder::
        .db        SI_VENDOR        ; iManufacturer (string index)
        .db        SI_PRODUCT       ; iProduct (string index)
        .db        SI_SERIAL        ; iSerial number (string index)
        .db        1                ; bNumConfigurations
        
        .even
_high_speed_devqual_descr::
        .db        DSCR_DEVQUAL_LEN
        .db        DSCR_DEVQUAL
        .db        <USB_VER         ; bcdUSB (LSB)
        .db        >USB_VER         ; bcdUSB (MSB)
        .db        0xFF             ; bDeviceClass
        .db        0xFF             ; bDeviceSubClass
        .db        0xFF             ; bDeviceProtocol
        .db        64               ; bMaxPacketSize0
        .db        1                ; bNumConfigurations (one config at 12Mbps)
        .db        0                ; bReserved
        
        .even
_high_speed_config_descr::        
        .db        DSCR_CONFIG_LEN
        .db        DSCR_CONFIG
        .db        <(_high_speed_config_descr_end - _high_speed_config_descr)
        .db        >(_high_speed_config_descr_end - _high_speed_config_descr)
        .db        1                ; bNumInterfaces
        .db        1                ; bConfigurationValue
        .db        0                ; iConfiguration
_dscr_attrpow::
        .db        USB_ATTR         ; bmAttributes
        .db        MAX_POWER        ; bMaxPower [Unit: 2 mA]

        ;; interface descriptor
        
        .db        DSCR_INTRFC_LEN
        .db        DSCR_INTRFC
        .db        0                ; bInterfaceNumber (zero based)
        .db        0                ; bAlternateSetting
        .db        NUM_EPS          ; bNumEndpoints
        .db        0xFF             ; bInterfaceClass (vendor specific)
        .db        0xFF             ; bInterfaceSubClass (vendor specific)
        .db        0xFF             ; bInterfaceProtocol (vendor specific)
        .db        SI_PRODUCT       ; iInterface (description)

        ;; endpoint descriptor (jtag response)

        .db        DSCR_ENDPNT_LEN
        .db        DSCR_ENDPNT
        .db        0x81             ; bEndpointAddress (EP 1 IN)
        .db        ET_BULK          ; bmAttributes
        .db        <512             ; wMaxPacketSize (LSB) !! use only 64 byte
        .db        >512             ; wMaxPacketSize (MSB) !! use only 64 byte
        .db        0                ; bInterval (iso only)

        ;; endpoint descriptor (jtag request)

        .db        DSCR_ENDPNT_LEN
        .db        DSCR_ENDPNT
        .db        0x02             ; bEndpointAddress (EP 2 OUT)
        .db        ET_BULK          ; bmAttributes
        .db        <512             ; wMaxPacketSize (LSB) !! use only 64 byte
        .db        >512             ; wMaxPacketSize (MSB) !! use only 64 byte
        .db        0                ; bInterval (iso only)

#if defined(USE_2FIFO) || defined(USE_3FIFO)
        
        ;; endpoint descriptor (RXFIFO HOST->FPGA)

        .db        DSCR_ENDPNT_LEN
        .db        DSCR_ENDPNT
        .db        0x04             ; bEndpointAddress (EP 4 OUT)
        .db        ET_BULK          ; bmAttributes
        .db        <512             ; wMaxPacketSize (LSB)
        .db        >512             ; wMaxPacketSize (MSB)
        .db        0                ; bInterval (iso only)

        ;; endpoint descriptor (TXFIFO FPGA->HOST)

        .db        DSCR_ENDPNT_LEN
        .db        DSCR_ENDPNT
        .db        0x86             ; bEndpointAddress (EP 6 IN)
        .db        ET_BULK          ; bmAttributes
        .db        <512             ; wMaxPacketSize (LSB)
        .db        >512             ; wMaxPacketSize (MSB)
        .db        0                ; bInterval (iso only)

#endif

#if defined(USE_3FIFO)
        
        ;; endpoint descriptor (extra FIFO FPGA->HOST)

        .db        DSCR_ENDPNT_LEN
        .db        DSCR_ENDPNT
        .db        0x88             ; bEndpointAddress (EP 8 IN)
        .db        ET_BULK          ; bmAttributes
        .db        <512             ; wMaxPacketSize (LSB)
        .db        >512             ; wMaxPacketSize (MSB)
        .db        0                ; bInterval (iso only)

#endif

_high_speed_config_descr_end:                

;;; ----------------------------------------------------------------
;;; descriptors used when operating at full speed (12Mbps)
;;; no data fifo endpoints defined, if we are in full speed mode this will be no
;;; fun anyway. Shouldn't happen anyway, unless stone age USB hubs interfere...
;;; ----------------------------------------------------------------

        .even
_full_speed_device_descr::        
        .db        DSCR_DEVICE_LEN
        .db        DSCR_DEVICE
        .db        <USB_VER         ; Specification version (LSB)
        .db        >USB_VER         ; Specification version (MSB)
        .db        0x00             ; device class (vendor specific)
        .db        0x00             ; device subclass (vendor specific)
        .db        0x00             ; device protocol (vendor specific)
        .db        64               ; bMaxPacketSize0 for endpoint 0
        .db        <VID             ; idVendor
        .db        >VID             ; idVendor
        .db        <PID             ; idProduct
        .db        >PID             ; idProduct
        .db        <VERSION         ; bcdDevice
        .db        >VERSION         ; bcdDevice
        .db        SI_VENDOR        ; iManufacturer (string index)
        .db        SI_PRODUCT       ; iProduct (string index)
        .db        SI_SERIAL        ; iSerial number (string index)
        .db        1                ; bNumConfigurations
        
;;; describes the other speed (480Mbps)
        .even
_full_speed_devqual_descr::
        .db        DSCR_DEVQUAL_LEN
        .db        DSCR_DEVQUAL
        .db        <USB_VER         ; bcdUSB
        .db        >USB_VER         ; bcdUSB
        .db        0xFF             ; bDeviceClass
        .db        0xFF             ; bDeviceSubClass
        .db        0xFF             ; bDeviceProtocol
        .db        64               ; bMaxPacketSize0
        .db        1                ; bNumConfigurations (one config at 480Mbps)
        .db        0                ; bReserved
        
        .even
_full_speed_config_descr::        
        .db        DSCR_CONFIG_LEN
        .db        DSCR_CONFIG
        .db        <(_full_speed_config_descr_end - _full_speed_config_descr)
        .db        >(_full_speed_config_descr_end - _full_speed_config_descr)
        .db        1                ; bNumInterfaces
        .db        1                ; bConfigurationValue
        .db        0                ; iConfiguration
        .db        USB_ATTR         ; bmAttributes
        .db        MAX_POWER        ; bMaxPower [Unit: 2 mA]

        ;; interface descriptor
        
        .db        DSCR_INTRFC_LEN
        .db        DSCR_INTRFC
        .db        0                ; bInterfaceNumber (zero based)
        .db        0                ; bAlternateSetting
        .db        2                ; bNumEndpoints
        .db        0xFF             ; bInterfaceClass (vendor specific)
        .db        0xFF             ; bInterfaceSubClass (vendor specific)
        .db        0xFF             ; bInterfaceProtocol (vendor specific)
        .db        SI_PRODUCT       ; iInterface (description)

        ;; endpoint descriptor

        .db        DSCR_ENDPNT_LEN
        .db        DSCR_ENDPNT
        .db        0x81             ; bEndpointAddress (EP 1 IN)
        .db        ET_BULK          ; bmAttributes
        .db        <64              ; wMaxPacketSize (LSB)
        .db        >64              ; wMaxPacketSize (MSB)
        .db        0                ; bInterval (iso only)

        ;; endpoint descriptor

        .db        DSCR_ENDPNT_LEN
        .db        DSCR_ENDPNT
        .db        0x02             ; bEndpointAddress (EP 2 OUT)
        .db        ET_BULK          ; bmAttributes
        .db        <64              ; wMaxPacketSize (LSB)
        .db        >64              ; wMaxPacketSize (MSB)
        .db        0                ; bInterval (iso only)
        
_full_speed_config_descr_end:        
        
;;; ----------------------------------------------------------------
;;;                        string descriptors
;;; ----------------------------------------------------------------

_nstring_descriptors::
        .db        (_string_descriptors_end - _string_descriptors) / 2

_string_descriptors::
        .db        <str0, >str0
        .db        <str1, >str1
        .db        <str2, >str2
        .db        <str3, >str3
_string_descriptors_end:

        SI_NONE = 0
        ;; str0 contains the language ID's.
        .even
_str0::
str0:   .db        str0_end - str0
        .db        DSCR_STRING
        .db        <0x0409          ; magic code for US English (LSB)
        .db        >0x0409          ; magic code for US English (MSB)
str0_end:

        SI_VENDOR = 1
        .even
_str1::
str1:   .db        str1_end - str1
        .db        DSCR_STRING
        .db        'w, 0            ; 16-bit unicode
        .db        'w, 0
        .db        'w, 0
        .db        '., 0
        .db        'r, 0
        .db        'e, 0
        .db        't, 0
        .db        'r, 0
        .db        'o, 0
        .db        '1, 0
        .db        '1, 0
        .db        '., 0
        .db        'd, 0
        .db        'e, 0
str1_end:

        SI_PRODUCT = 2
        .even
_str2::
str2:   .db        str2_end - str2
        .db        DSCR_STRING
#if defined(USE_NEXYS2)
        .db        'n, 0
        .db        'e, 0
        .db        'x, 0
        .db        'y, 0
        .db        's, 0
        .db        '2, 0
        .db        '_, 0
#endif
#if defined(USE_NEXYS3)
        .db        'n, 0
        .db        'e, 0
        .db        'x, 0
        .db        'y, 0
        .db        's, 0
        .db        '3, 0
        .db        '_, 0
#endif
        .db        'j, 0
        .db        't, 0
        .db        'a, 0
        .db        'g, 0
#if defined(USE_2FIFO)
        .db        '_, 0
        .db        '2, 0
        .db        'f, 0
        .db        'i, 0
        .db        'f, 0
        .db        'o, 0
#endif
#if defined(USE_3FIFO)
        .db        '_, 0
        .db        '3, 0
        .db        'f, 0
        .db        'i, 0
        .db        'f, 0
        .db        'o, 0
#endif
#if defined(USE_AS)
        .db        '_, 0
        .db        'a, 0
        .db        's, 0
#endif
#if defined(USE_IC)
        .db        '_, 0
        .db        'i, 0
        .db        'c, 0
#endif
str2_end:

        SI_SERIAL = 3
        .even
_str3::
str3:   .db        str3_end - str3
        .db        DSCR_STRING
        .db        '0, 0
        .db        '0, 0
        .db        '0, 0
        .db        '0, 0
        .db        '0, 0
        .db        '0, 0
        .db        '0, 0
        .db        '0, 0
str3_end:
