/**
 * @file   hpd_config.h
 * @author Lasse Lehtonen
 * @date   2012-02-16
 *
 * @brief HIBI_PE_DMA configuration file. 
 *
 * @detail This file along with its .c file is used to configure
 * HIBI_PE_DMA components for the functions to know where they
 * are. This file should be unique for each processor using
 * HIBI_PE_DMA components.
 *
 * @par Copyright
 * Funbase IP library Copyright (C) 2012 TUT Department of
 * Computer Systems
 * @par
 * This file is part of HIBI_PE_DMA
 * @par
 * This source file may be used and distributed without
 * restriction provided that this copyright statement is not
 * removed from the file and that any derivative work contains
 * the original copyright notice and the associated disclaimer.
 * This source file is free software; you can redistribute it
 * and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation;
 * either version 2.1 of the License, or (at your option) any
 * later version.
 * @par
 * This source is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 * @par
 * You should have received a copy of the GNU Lesser General
 * Public License along with this source; if not, download it
 * from http://www.opencores.org/lgpl.shtml
 *
 */

#ifndef HPD_CONFIG_HH
#define HPD_CONFIG_HH

/**
 * @def NUM_OF_HIBI_PE_DMAS 
 *
 * @brief Total number HIBI_PE_DMA components this processor uses and
 * sees on its memory mapped bus.
 *
 * @hideinitializer
 */
#define NUM_OF_HIBI_PE_DMAS 1


/**
 * @struct HPD_rx_stream
 * @brief Holds configuration information of one RX stream channel.
 */
typedef struct {
  int  rx_base_address;    /**< Address of this channnel's RX buffer.*/
  int  rx_buffer_bytes;    /**< Size of the RX buffer in bytes. */
  int  rx_hibi_address;    /**< HIBI address for receiving data. */
  int  rx_read_words;      /**< Current read pointer. */
} HPD_rx_stream;


/**
 * @struct HPD_rx_packet
 * @brief Holds configuration information of one RX packet channel.
 */
typedef struct {
  int  rx_base_address;    /**< Address of this channnel's RX buffer.*/
  int  rx_buffer_bytes;    /**< Size of the RX buffer in bytes. */
  int  rx_hibi_address;    /**< HIBI address for receiving data. */
} HPD_rx_packet;


/**
 * @struct HPD_iface
 * @brief  Struct holding information about HIBI_PE_DMA components.
 */
typedef struct {
  int  base_address;           /**< Base address for this HIBI_PE_DMA. */
  int  tx_base_address;        /**< TX buffer's start on shared mem. */
  int  tx_buffer_bytes;        /**< Size of the TX buffer in bytes. */
  int  tx_hibi_address;        /**< Target HIBI address for sending. */
  int  tx_hibi_command;        /**< HIBI command for sending. */
  int  n_stream_channels;      /**< Number of stream channels available. */
  int  n_packet_channels;      /**< Number of packet channels available. */
  HPD_rx_stream* rx_streams;   /**< Table of rx stream channels. */
  HPD_rx_packet* rx_packets;   /**< Table of rx packet channels. */
} HPD_iface;

/**
 * Actual interface information is located in the c file.
 */
extern HPD_iface hpd_ifaces[NUM_OF_HIBI_PE_DMAS];

#endif
