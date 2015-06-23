/**
 * @file   hpd_functions.h
 * @author Lasse Lehtonen
 * @date   2012-02-14
 *
 * @brief  Platform independed C functions.
 *
 * @details This file introduces a set of functions for handling
 * HIBI_PE_DMA more easily. Functions are written in platform
 * independed C using macros defined in hdp_macros.h.
 *
 * @warning These functions store the HIBI_PE_DMA configuration
 * information in an internal structure to avoid unnessery
 * configuration. This implies that all communication with HIBI_PE_DMA
 * must be done with these functions or their behaviour may become
 * undefined.
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

#ifndef HPD_FUNCTIONS_H
#define HPD_FUNCTIONS_H


/**
 * @defgroup GEN_FUNCTIONS General Functions
 * @{
 */


/**
 * @brief Initializes HIBI_PE_DMA component according to
 * hpd_config.c. 
 *
 * @details Reads settings from the data structure defined in
 * hpd_config.c and configures memory address, buffer size and hibi
 * address registers on all HIBI_PE_DMA interfaces but doesn't start
 * RX channel receiving.
 */
void hpd_initialize();


/**
 * @}
 */

/**
 * @defgroup TX_FUNCTIONS TX Functions
 * @{
 */

/**
 * @brief Configures HIBI_PE_DMA's TX base settings for interface \e
 * iface.
 *
 * @param[in] base TX buffer's base address.
 * @param[in] words Size of the TX buffer in words.
 */
void hpd_tx_base_conf_gen(int base, int words, int iface);


/**
 * @brief Configures HIBI_PE_DMA's TX base settings for default interface.
 *
 * @param[in] base TX buffer's base address.
 * @param[in] words Size of the TX buffer in words.
 */
void hpd_tx_base_conf(int base, int words);


/**
 * @brief Send packet through HIBI_PE_DMA interface \e iface. Data
 * must be in a memory accessible by HIBI_PE_DMA.
 *
 * @param[in] daddr Beginning address for the data to be sent.
 * @param[in] words How many words to sent.
 * @param[in] haddr Where to send the packet on HIBI.
 * @param[in] iface Which interface to use.
 *
 * @details This function configures registers on HIBI_PE_DMA and
 * starts the transfer. It sends \e words amount of words starting
 * from \e daddr. Address \e daddr must be accessible by HIBI_PE_DMA.
 *
 */
void hpd_tx_send_gen(int daddr, int words, int haddr, int iface);


/**
 * @brief Send packet through HIBI_PE_DMA default interface. Data
 * must be in a memory accessible by HIBI_PE_DMA.
 *
 * @param[in] daddr Beginning address for the data to be sent.
 * @param[in] words How many words to sent.
 * @param[in] haddr Where to send the packet on HIBI.
 * 
 * @details This function configures registers on HIBI_PE_DMA and
 * starts the transfer. It sends \e words amount of words starting
 * from \e daddr. Address \e daddr must be accessible by HIBI_PE_DMA.
 *
 */
void hpd_tx_send(int daddr, int words, int haddr);


/**
 * @brief Send packet through HIBI_PE_DMA interface \e iface. Copies
 * the data first to the memory accessible by HIBI_PE_DMA.
 *
 * @param[in] daddr Beginning address for the data to be sent.
 * @param[in] words How many words to sent.
 * @param[in] haddr Where to send the packet on HIBI.
 * @param[in] iface Which interface to use.
 *
 * @details This function configures registers on HIBI_PE_DMA and
 * starts the transfer. It sends \e words amount of words starting
 * from \e daddr. This function copies the data from \e daddr to the
 * shared memory accessible by HIBI_PE_DMA before sending. If packet
 * is larger than TX buffer it's sent in pieces.
 *
 */
void hpd_tx_send_copy_gen(int daddr, int words, int haddr, int iface);


/**
 * @brief Send packet through HIBI_PE_DMA default interface. Copies
 * the data first to the memory accessible by HIBI_PE_DMA.
 *
 * @param[in] daddr Beginning address for the data to be sent.
 * @param[in] words How many words to sent.
 * @param[in] haddr Where to send the packet on HIBI.
 * 
 * @details This function configures registers on HIBI_PE_DMA and
 * starts the transfer. It sends \e words amount of words starting
 * from \e daddr. This function copies the data from \e daddr to the
 * shared memory accessible by HIBI_PE_DMA before sending. If packet
 * is larger than TX buffer it's sent in pieces.
 *
 */
void hpd_tx_send_copy(int daddr, int words, int haddr);


/**
 * @}
 */


/**
 * @defgroup RX_PACKET RX Packet Functions
 * @{
 */


/**
 * @brief Initialize packet channel for reception on interface \e iface.
 * @param[in] chan Which channel.
 * @param[in] daddr Where to store the packet.
 * @param[in] words How many to expect.
 * @param[in] haddr Hibi address to listen to.
 * @param[in] iface Which interface to use.
 *
 */
void hpd_rx_packet_init_gen(int chan, int daddr, 
			    int words, int haddr, int iface);

/**
 * @brief Initialize packet channel for reception on default interface.
 * @param[in] chan Which channel.
 * @param[in] daddr Where to store the packet.
 * @param[in] words How many to expect.
 * @param[in] haddr Hibi address to listen to.
 */
void hpd_rx_packet_init(int chan, int daddr, int words, int haddr);


/**
 * @brief Reinitializes packet channel with previous settings on
 * interface \e iface.
 *
 * @param[in] chan Which channel.
 * @param[in] iface Which interface to use.
 */
void hpd_rx_packet_reinit_gen(int chan, int iface);


/**
 * @brief Reinitializes packet channel with previous settings on
 * default interface.
 *
 * @warning Undefined bahaviour if used for stream channels.
 *
 * @param[in] chan Which channel.
 */
void hpd_rx_packet_reinit(int chan);


/**
 * @brief Read RX packet from channel \e chan to \e buffer without
 * checking the channel's status from interface \e iface.
 *
 * @param[in]  chan   Which channel to read.
 * @param[out] buffer Place to store the data. 
 * @param[in]  iface  Interface to use.
 *
 * @details This function copies channels RX buffer without checking
 * wether or not it has received anything. Used when it's already
 * known that there is whole packet available e.g. through interrupts
 * or polling.
 */
void hpd_rx_packet_read_gen(int chan, void* buffer, int iface);


/**
 * @brief Read RX packet from channel \e chan to \e buffer without
 * checking the channel's status from default interface.
 *
 * @param[in]  chan Which channel to read.
 * @param[out] buffer Place to store the data. 
 *
 * @details This function copies channels RX buffer without checking
 * wether or not it has received anything. Used when it's already
 * known that there is whole packet available e.g. through interrupts
 * or polling.
 */
void hpd_rx_packet_read(int chan, void* buffer);


/**
 * @brief Gets the configuration information of packet channel \e chan
 * from interface \e iface.
 *
 * @param[in]  chan     Which channel to read.
 * @param[out] rx_base  Base address where channel stores the data.
 * @param[out] rx_bytes Size of the RX buffer in bytes.
 * @param[out] rx_haddr HIBI address that this channel is listening to.
 * @param[in]  iface    Which inteface to read from.
 *
 * @details Gets configuration information from one RX packet
 * channel. Use NULL to disable returning particular parameter.
 */
void hpd_rx_packet_get_conf_gen(int chan, int* rx_base, int* rx_bytes,
				int* rx_haddr, int iface);


/**
 * @brief Gets the configuration information of packet channel \e chan
 * from default interface.
 *
 * @param[in]  chan     Which channel to read.
 * @param[out] rx_base  Base address where channel stores the data.
 * @param[out] rx_bytes Size of the RX buffer in bytes.
 * @param[out] rx_haddr HIBI address that this channel is listening to.
 *
 * @details Gets configuration information from one RX packet
 * channel. Use NULL to disable returning particular parameter.
 */
void hpd_rx_packet_get_conf(int chan, int* rx_base, int* rx_bytes,
			    int* rx_haddr);


/**
 * @brief Poll RX packet channel \e chan from interface \e iface to
 * check if it's received all data.
 *
 * @param[in] chan Which channel to check.  
 * @param[in] iface From which interface.  
 * @return One if packet channel has received a packet, zero otherwise.
 *
 * @warning Undefined behaviour if used for stream or unitialized channels.
 */
int hpd_rx_packet_poll_gen(int chan, int iface);


/**
 * @brief Poll RX packet channel \e chan from default interface to
 * check if it's received all data.
 *
 * @param[in] chan Which channel to check.  
 * @return One if packet channel has received a full packet, zero otherwise.
 *
 * @warning Undefined behavior if used for stream or unitialized channels.
 */
int hpd_rx_packet_poll(int chan);


/**
 * @}
 */

/**
 * @defgroup RX_STREAM RX Stream Functions
 * @{
 */


/**
 * @brief Initialize stream channel for reception on interface \e iface.
 * @param[in] chan Which channel.
 * @param[in] daddr Starting address of the buffer.
 * @param[in] words Size of the receive buffer.
 * @param[in] haddr Hibi address to listen to.
 * @param[in] iface Which interface to use.
 *
 */
void hpd_rx_stream_init_gen(int chan, int daddr, 
			    int words, int haddr, int iface);

/**
 * @brief Initialize stream channel for reception on default interface.
 * @param[in] chan Which channel.
 * @param[in] daddr Starting address of the buffer.
 * @param[in] words Size of the receive buffer.
 * @param[in] haddr Hibi address to listen to.
 */
void hpd_rx_stream_init(int chan, int daddr, int words, int haddr);


/**
 * @brief Reinitializes stream channel with previous settings on
 * interface \e iface.
 *
 * @param[in] chan Which channel.
 * @param[in] iface Which interface to use.
 */
void hpd_rx_stream_reinit_gen(int chan, int iface);


/**
 * @brief Reinitializes stream channel with previous settings on
 * default interface.
 *
 * @warning Undefined bahaviour if used for packet channels.
 *
 * @param[in] chan Which channel.
 */
void hpd_rx_stream_reinit(int chan);


/**
 * @brief Gets the configuration information of stream channel \e chan
 * from interface \e iface.
 *
 * @param[in]  chan     Which channel to read.
 * @param[out] rx_base  Base address where channel stores the data.
 * @param[out] rx_bytes Size of the RX buffer in bytes.
 * @param[out] rx_haddr HIBI address that this channel is listening to.
 * @param[in]  iface    Which inteface to read from.
 *
 * @details Gets configuration information from one RX stream
 * channel. Use NULL to disable returning particular parameter.
 */
void hpd_rx_stream_get_conf_gen(int chan, int* rx_base, int* rx_bytes,
				int* rx_haddr, int iface);


/**
 * @brief Gets the configuration information of stream channel \e chan
 * from default interface.
 *
 * @param[in]  chan     Which channel to read.
 * @param[out] rx_base  Base address where channel stores the data.
 * @param[out] rx_bytes Size of the RX buffer in bytes.
 * @param[out] rx_haddr HIBI address that this channel is listening to.
 *
 * @details Gets configuration information from one RX steram
 * channel. Use NULL to disable returning particular parameter.
 */
void hpd_rx_stream_get_conf(int chan, int* rx_base, int* rx_bytes,
			    int* rx_haddr);


/**
 * @brief Poll if RX stream channel \e chan on interface \e iface has
 * receivedy any words.
 *
 * @param[in] chan Which channel to check.  
 * @param[in] iface From which interface.  
 * @return Number of received words.
 *
 * @warning Undefined behavior if used on packet or unitialized channel.
 */
int hpd_rx_stream_poll_gen(int chan, int iface);


/**
 * @brief Poll if RX stream channel \e chan on default interface has
 * receivedy any words.
 *
 * @param[in] chan Which channel to check.  
 * @return Number of received words.
 *
 * @warning Undefined behavior if used on packet or unitialized channel.
 */
int hpd_rx_stream_poll(int chan);


/**
 * @brief Read \e words amount of words from channel \e chan on
 * interface \e iface and store them to \e buffer.
 * 
 * @param[in] chan   Which channel to check.
 * @param[in] words  How many words to read.
 * @param[in] buffer Where to store read words.
 * @param[in] iface  From which interface.  
 *
 * @details Reads from a stream channel and acknowledges the channel
 * about the amount read. This function should be used only when it's
 * known that the channel has received at least \e words words of
 * data.
 *
 * @warning Don't use ack function after this function because
 * acknowledging is handled in this function. Undefined behaviour if
 * used for packet channels.
 */
void hpd_rx_stream_read_gen(int chan, int words, int* buffer, int iface);


/**
 * @brief Read \e words amount of words from channel \e chan on
 * default interface store them to \e buffer.
 * 
 * @param[in] chan   Which channel to check.
 * @param[in] words  How many words to read.
 * @param[in] buffer Where to store read words.
 *
 * @details Reads from a stream channel and acknowledges the channel
 * about the amount read. This function should be used only when it's
 * known that the channel has received at least \e words words of
 * data.
 *
 * @warning No need to use ack function after this function because
 * acknowledging is handled in this function. Undefined behaviour if
 * used for packet channels.
 */
void hpd_rx_stream_read(int chan, int words, int* buffer);


/**
 * @brief Acknowledege to stream channel on interface \e iface that \e
 * words amount of words have been read from it.
 *
 * @param[in] chan  Which channel to check.  
 * @param[in] words How many words was read.
 * @param[in] iface From which interface.  
 *
 * @details This functions is used to tell HIBI_PE_DMA that some words
 * have been read from its RX stream channel so it can use that buffer
 * again for receiving data.
 *
 * @warning Undefined behaviour if used for packet channels.
 */
void hpd_rx_stream_ack_gen(int chan, int words, int iface);


/**
 * @brief Acknowledege to stream channel on default interface that \e
 * words amount of words have been read from it.
 *
 * @param[in] chan  Which channel to check.  
 * @param[in] words How many words was read.
 * @param[in] iface From which interface.  
 *
 * @details This functions is used to tell HIBI_PE_DMA that some words
 * have been read from its RX stream channel so it can use that buffer
 * again for receiving data.
 *
 * @warning Undefined behaviour if used for packet channels.
 */
void hpd_rx_stream_ack(int chan, int words);

/**
 * @}
 */

/**
 * @defgroup IRQ_FUNCS IRQ Functions
 * @{
 */


/**
 * @brief Enable HIBI_PE_DMA interrupts on interface \e iface.
 *
 * @param[in] iface Which interface.  
 */
void hpd_irq_enable_gen(int iface);


/**
 * @brief Enable HIBI_PE_DMA interrupts on default interface.
 * 
 * @details Enables interrupts.
 */
void hpd_irq_enable();


/**
 * @brief Disable HIBI_PE_DMA interrupts on interface \e iface.
 *
 * @param[in] iface Which interface.  
 */
void hpd_irq_disable_gen(int iface);


/**
 * @brief Disable HIBI_PE_DMA interrupts on default interface.
 *
 * @details Disables interrupts.
 */
void hpd_irq_disable();


/**
 * @brief Acknowledge IRQ for packet channel \e chan on interface \e
 * iface.
 *
 * @param[in] chan  Channel to acknowledge.
 * @param[in] iface Which interface.
 *
 */
void hpd_irq_packet_ack_gen(int chan, int iface);


/**
 * @brief Acknowledge IRQ for packet channel \e chan on default
 * interface. 
 *
 * @param[in] chan  Channel to acknowledge.
 *
 */
void hpd_irq_packet_ack(int chan);


/**
 * @brief Acknowledge IRQ for stream channel \e chan on interface \e
 * iface.
 *
 * @param[in] chan  Channel to acknowledge.
 * @param[in] iface Which interface.
 *
 */
void hpd_irq_stream_ack_gen(int chan, int iface);


/**
 * @brief Acknowledge IRQ for stream channel \e chan on default
 * interface. 
 *
 * @param[in] chan  Channel to acknowledge.
 *
 */
void hpd_irq_stream_ack(int chan);


/**
 * @brief Returns IRQ vector from HIBI_PE_DMA interface \e iface.
 *
 * @details Returns a vector in which a high bit indicates an active
 * interrupt source.
 *
 * @param[in] iface Which interface.
 * @return IRQ vector.
 */
int hpd_irq_get_vector_gen(int iface);


/**
 * @brief Returns IRQ vector from HIBI_PE_DMA default interface.
 *
 * @return IRQ vector.
 */
int hpd_irq_get_vector();


/**
 * @brief Clear interrupts by mask on interface \e iface.
 *
 * @details Every bit high in the mask will clear the corresponding
 * interrupt source.
 *
 * @param[in] mask Clear interrupt mask.
 * @param[in] iface Which interface.
 *
 */
void hpd_irq_clear_vector_gen(int mask, int iface);


/**
 * @brief Clear interrupts by mask on default interface.
 *
 * @details Every bit high in the mask will clear the corresponding
 * interrupt source.
 *
 * @param[in] mask Clear interrupt mask.
 * @param[in] iface Which interface.
 *
 */
void hpd_irq_clear_vector(int mask);




/**
 * @}
 */


#endif




