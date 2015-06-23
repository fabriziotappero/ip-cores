;;; -*- asm -*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;            _   _            __   ____                                      ;;
;;           / / | |          / _| |  __|                                     ;;
;;           | |_| |  _   _  / /   | |_                                       ;;
;;           |  _  | | | | | | |   |  _|                                      ;;
;;           | | | | | |_| | \ \_  | |__                                      ;;
;;           |_| |_| \_____|  \__| |____| microLab                            ;;
;;                                                                            ;;
;;           Bern University of Applied Sciences (BFH)                        ;;
;;           Quellgasse 21                                                    ;;
;;           Room HG 4.33                                                     ;;
;;           2501 Biel/Bienne                                                 ;;
;;           Switzerland                                                      ;;
;;                                                                            ;;
;;           http://www.microlab.ch                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; GECKO4COM
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details. 
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;;
;;;********************************************************************
;;;
;;; Endpoint configuration is according to USB TMC specification 1.0
;;;

   .module  usb_descriptors

   VID_BFH        = 0xBFF1    ; Just stole a non defined VID, not registered
   PID_GECKO      = 0x0004    ; GECKO4 PID
   DID_GECKO      = 0x0100    ; Device ID in BCD
   
   DSCR_DEVICE_LENGTH      = 18
   DSCR_DQUAL_LENGTH       = 10
   DSCR_CONFIG_LENGTH      = 9
   DSCR_IF_LENGTH          = 9
   DSCR_EP_LENGTH          = 7
   DSCR_DEVICE             = 1
   DSCR_CONFIG             = 2
   DSCR_STRING             = 3
   DSCR_INTERFACE          = 4
   DSCR_END_POINT          = 5
   DSCR_DEVICE_QUAL        = 6
   DSCR_USB_VER            = 0x0200
   DSCR_US_ENGLISH         = 0x0409
   DSCR_DEVICE_CLASS       = 0x00
   DSCR_DEVICE_SUBCLASS    = 0x00
   DSCR_DEVICE_PROTOCOL    = 0x00
   DSCR_MAX_PACKET_SIZE    = 64
   DSCR_NUMBER_CONFIGS     = 1
   DSCR_RESERVED           = 0
   DSCR_BUS_POWERED        = 0x80
   DSCR_BUS_POWER_100mA    = 50
   DSCR_BUS_POWER_500mA    = 250
   
   DSCR_EP2_OUT            = 0x02
   DSCR_EP2_IN             = 0x82
   DSCR_EP4_OUT            = 0x04
   DSCR_EP4_IN             = 0x84
   DSCR_EP6_OUT            = 0x06
   DSCR_EP6_IN             = 0x86
   DSCR_EP8_OUT            = 0x08
   DSCR_EP8_IN             = 0x88
   
   NUM_INTERFACES          = 1
   CONFIG_VALUE            = 1
   INTERFACE_0             = 0
   ALT_SETTING_0           = 0
   NR_ENDPOINTS_ONE        = 1
   NR_ENDPOINTS_TWO        = 2
   
   ET_BULK                 = 0x02
   FS_MAX_PACK_SIZE        = 64
   HS_MAX_PACK_SIZE        = 512
   
   USBTMC_IF_CLASS         = 0xFE
   USBTMC_IF_SUBCLASS      = 0x03
   USBTMC_PROTO            = 0x01
   
   INTERVAL_0              = 0
;;;-----------------------------------------------------------------------------
;;;   external ram data
;;;-----------------------------------------------------------------------------
	
   .area USBDESCSEG    (XDATA)

;;;-----------------------------------------------------------------------------
;;;   Default descriptors at initial enumeration (full speed mode)
;;;-----------------------------------------------------------------------------
_high_speed_device_descr::
_full_speed_device_descr::
   .db   DSCR_DEVICE_LENGTH
   .db   DSCR_DEVICE
   .db   <DSCR_USB_VER
   .db   >DSCR_USB_VER
   .db   DSCR_DEVICE_CLASS
   .db   DSCR_DEVICE_SUBCLASS
   .db   DSCR_DEVICE_PROTOCOL
   .db   DSCR_MAX_PACKET_SIZE
   .db   <VID_BFH
   .db   >VID_BFH
   .db   <PID_GECKO
   .db   >PID_GECKO
   .db   <DID_GECKO
   .db   >DID_GECKO
   .db   ID_MANUFACTURER
   .db   ID_PRODUCT
   .db   ID_SERIAL
   .db   DSCR_NUMBER_CONFIGS           ; 18 bytes
_high_speed_devqual_descr::
_full_speed_devqual_descr::
   .db   DSCR_DQUAL_LENGTH
   .db   DSCR_DEVICE_QUAL
   .db   <DSCR_USB_VER
   .db   >DSCR_USB_VER
   .db   DSCR_DEVICE_CLASS
   .db   DSCR_DEVICE_SUBCLASS
   .db   DSCR_DEVICE_PROTOCOL
   .db   DSCR_MAX_PACKET_SIZE
   .db   DSCR_NUMBER_CONFIGS
   .db   DSCR_RESERVED                 ; 28 bytes

_full_speed_config_descr::
   .db   DSCR_CONFIG_LENGTH
   .db   DSCR_CONFIG
   .db   <(_full_speed_config_descr_end-_full_speed_config_descr)
   .db   >(_full_speed_config_descr_end-_full_speed_config_descr)
   .db   NUM_INTERFACES
   .db   CONFIG_VALUE
   .db   ID_FULL_SPEED
_device_bus_attributes_fs::
   .db   DSCR_BUS_POWERED
   .db   DSCR_BUS_POWER_500mA          ; 37 bytes

;;; Interface 0 descriptor (USB TMC, ep8 OUT BULK, ep6 IN BULK)
   .db   DSCR_IF_LENGTH
   .db   DSCR_INTERFACE
   .db   INTERFACE_0
   .db   ALT_SETTING_0
   .db   NR_ENDPOINTS_TWO
   .db   USBTMC_IF_CLASS
   .db   USBTMC_IF_SUBCLASS
   .db   USBTMC_PROTO
   .db   ID_USBTMC                     ; 46 bytes
;;; Interface 0 OUT endpoint
   .db   DSCR_EP_LENGTH
   .db   DSCR_END_POINT
   .db   DSCR_EP8_OUT
   .db   ET_BULK
   .db   <FS_MAX_PACK_SIZE
   .db   >FS_MAX_PACK_SIZE
   .db   INTERVAL_0                    ; 53 bytes
;;; Interface 0 IN endpoint
   .db   DSCR_EP_LENGTH
   .db   DSCR_END_POINT
   .db   DSCR_EP6_IN
   .db   ET_BULK
   .db   <FS_MAX_PACK_SIZE
   .db   >FS_MAX_PACK_SIZE
   .db   INTERVAL_0                    ; 60 bytes
_full_speed_config_descr_end:

;;;-----------------------------------------------------------------------------
;;;   High Speed descriptors
;;;-----------------------------------------------------------------------------
_high_speed_config_descr::
   .db   DSCR_CONFIG_LENGTH
   .db   DSCR_CONFIG
   .db   <(_high_speed_config_descr_end-_high_speed_config_descr)
   .db   >(_high_speed_config_descr_end-_high_speed_config_descr)
   .db   NUM_INTERFACES
   .db   CONFIG_VALUE
   .db   ID_HI_SPEED
_device_bus_attributes_hs::
   .db   DSCR_BUS_POWERED
   .db   DSCR_BUS_POWER_500mA          

;;; Interface 0 descriptor (USB TMC, ep8 OUT BULK, ep6 IN BULK)
   .db   DSCR_IF_LENGTH
   .db   DSCR_INTERFACE
   .db   INTERFACE_0
   .db   ALT_SETTING_0
   .db   NR_ENDPOINTS_TWO
   .db   USBTMC_IF_CLASS
   .db   USBTMC_IF_SUBCLASS
   .db   USBTMC_PROTO
   .db   ID_USBTMC                     ; 46 bytes
;;; Interface 0 OUT endpoint
   .db   DSCR_EP_LENGTH
   .db   DSCR_END_POINT
   .db   DSCR_EP8_OUT
   .db   ET_BULK
   .db   <HS_MAX_PACK_SIZE
   .db   >HS_MAX_PACK_SIZE
   .db   INTERVAL_0                    ; 53 bytes
;;; Interface 0 IN endpoint
   .db   DSCR_EP_LENGTH
   .db   DSCR_END_POINT
   .db   DSCR_EP6_IN
   .db   ET_BULK
   .db   <HS_MAX_PACK_SIZE
   .db   >HS_MAX_PACK_SIZE
   .db   INTERVAL_0                    ; 60 bytes
_high_speed_config_descr_end:

;;;-----------------------------------------------------------------------------
;;; String index table
;;;-----------------------------------------------------------------------------
_nstring_descriptors::
   .db   (_string_index_table_end - _string_descriptors) / 2
_string_descriptors::
   .db   <_str_language , >_str_language
   .db   <_manufacturer , >_manufacturer
   .db   <_product , >_product
   .db   <_serial , >_serial
   .db   <_full_speed , >_full_speed
   .db   <_usbtmc , >_usbtmc
   .db   <_hi_speed , >_hi_speed
_string_index_table_end::
   .db   0         ;; make even address, as the table is by definition odd
                                       ; +16 => 76 bytes
;;;-----------------------------------------------------------------------------
;;; String descriptors
;;;-----------------------------------------------------------------------------

   ID_LANGUAGE = 0
_str_language:
   .db   _str_language_end - _str_language
   .db   DSCR_STRING
   .db   0
   .db   0
   .db   <DSCR_US_ENGLISH
   .db   >DSCR_US_ENGLISH
_str_language_end:                      ; +6 => 82 bytes

   ID_MANUFACTURER = 1
_manufacturer:
   .db   _manufacturer_end - _manufacturer
   .db   DSCR_STRING
   .db   'B , 0
   .db   'e , 0
   .db   'r , 0
   .db   'n , 0
   .db   '  , 0
   .db   'U , 0
   .db   'n , 0
   .db   'i , 0
   .db   'v , 0
   .db   'e , 0
   .db   'r , 0
   .db   's , 0
   .db   'i , 0
   .db   't , 0
   .db   'y , 0
   .db   '  , 0
   .db   'o , 0
   .db   'f , 0
   .db   '  , 0
   .db   'A , 0
   .db   'p , 0
   .db   'p , 0
   .db   'l , 0
   .db   'i , 0
   .db   'e , 0
   .db   'd , 0
   .db   '  , 0
   .db   'S , 0
   .db   'c , 0
   .db   'i , 0
   .db   'e , 0
   .db   'n , 0
   .db   'c , 0
   .db   'e , 0
   .db   's , 0
   .db   ': , 0
   .db   '  , 0
   .db   'H , 0
   .db   'U , 0
   .db   'C , 0
   .db   'E , 0
   .db   '- , 0
   .db   'm , 0
   .db   'i , 0
   .db   'c , 0
   .db   'r , 0
   .db   'o , 0
   .db   'l , 0
   .db   'a , 0
   .db   'b , 0
_manufacturer_end:

   ID_PRODUCT = 2
_product:
   .db   _product_end - _product
   .db   DSCR_STRING
   .db   'G , 0
   .db   'E , 0
   .db   'C , 0
   .db   'K , 0
   .db   'O , 0
   .db   '4 , 0
   .db   'C , 0
   .db   'O , 0
   .db   'M , 0                        ; +20 => 134 bytes
_product_end:

   ID_SERIAL = 3
_serial:
   .db   _serial_end - _serial
   .db   DSCR_STRING
   .db   'V , 0
   .db   '1 , 0
   .db   '. , 0
   .db   '0 , 0                        ; +10 => 144 bytes
_serial_end:

   ID_FULL_SPEED = 4
_full_speed:
   .db   _full_speed_end - _full_speed
   .db   DSCR_STRING
   .db   'F , 0
   .db   'u , 0
   .db   'l , 0
   .db   'l , 0
   .db   '  , 0
   .db   'S , 0
   .db   'p , 0
   .db   'e , 0
   .db   'e , 0
   .db   'd , 0                        ; +22 => 166 bytes
_full_speed_end:

   ID_USBTMC = 5
_usbtmc:
   .db   _usbtmc_end - _usbtmc
   .db   DSCR_STRING
   .db   'U , 0
   .db   'S , 0
   .db   'B , 0
   .db   'T , 0
   .db   'M , 0
   .db   'C , 0
   .db   '  , 0
   .db   'U , 0
   .db   'S , 0
   .db   'B , 0
   .db   '4 , 0
   .db   '8 , 0
   .db   '8 , 0                        ; +28 => 194 bytes
_usbtmc_end:

   ID_HI_SPEED = 6
_hi_speed:
   .db   _hi_speed_end - _hi_speed
   .db   DSCR_STRING
   .db   'H , 0
   .db   'i , 0
   .db   'g , 0
   .db   'h , 0
   .db   '  , 0
   .db   'S , 0
   .db   'p , 0
   .db   'e , 0
   .db   'e , 0
   .db   'd , 0                        ; +22 => 216 bytes
_hi_speed_end:

