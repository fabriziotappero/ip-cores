/******************************************************************************/
/*            _   _            __   ____                                      */
/*           / / | |          / _| |  __|                                     */
/*           | |_| |  _   _  / /   | |_                                       */
/*           |  _  | | | | | | |   |  _|                                      */
/*           | | | | | |_| | \ \_  | |__                                      */
/*           |_| |_| \_____|  \__| |____| microLab                            */
/*                                                                            */
/*           Bern University of Applied Sciences (BFH)                        */
/*           Quellgasse 21                                                    */
/*           Room HG 4.33                                                     */
/*           2501 Biel/Bienne                                                 */
/*           Switzerland                                                      */
/*                                                                            */
/*           http://www.microlab.ch                                           */
/******************************************************************************/
/* GECKO4COM
 *
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details. 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*********************************************************************/
/** \file     usb_descriptors.h
 *********************************************************************
 * \brief     header file for the USB descriptors. The descriptors are 
 *            defined outside in the usb_descriptor.a51 file.
 *
 * \author    GNUradio, Christoph Zimmermann bfh.ch
 *
*/

/** USB High speed device descriptor */
extern xdata const char high_speed_device_descr[];
/** USB High speed device qualifier descriptor */
extern xdata const char high_speed_devqual_descr[];
/** USB High speed configuration descriptor */
extern xdata const char high_speed_config_descr[];

/** USB Full speed device descriptor */
extern xdata const char full_speed_device_descr[];
/** USB Full speed device qualifier descriptor */
extern xdata const char full_speed_devqual_descr[];
/** USB Full speed configuration descriptor */
extern xdata const char full_speed_config_descr[];

#ifdef USB_DFU_SUPPORT
/** USB DFU mode device descriptor */
extern xdata const char dfu_mode_device_descr[];
/** USB DFU mode configuration descriptor */
extern xdata const char dfu_mode_config_descr[];
/** USB DFU mode functional descriptor */
extern xdata const char dfu_mode_functional_descr[];
#endif

/** Number of USB String descriptors available */
extern xdata unsigned char nstring_descriptors;

/** USB String descriptors */
extern xdata char * xdata string_descriptors[];

/** We patch these locations with info read from the config eeprom */
extern xdata char usb_desc_hw_rev_binary_patch_location_0[];
/** We patch these locations with info read from the config eeprom */
extern xdata char usb_desc_hw_rev_binary_patch_location_1[];
/** We patch these locations with info read from the config eeprom */
extern xdata char usb_desc_hw_rev_binary_patch_location_2[];
/** We patch these locations with info read from the config eeprom */
/*extern xdata char usb_desc_hw_rev_ascii_patch_location_0[];*/
/** We patch these locations with info read from the config eeprom */
extern xdata char usb_desc_serial_number_ascii[];

