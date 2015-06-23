/*
 * Driver functions for UDP2HIBI block.
 * 
 * These are more like examples, so modify if you see it necessary
 * 
 * Original author: Jussi Nieminen
 * Last update: 7.1.2010
 * History:
 *  7.1.2010: created
 */
 
#include "udp2hibi.h"
#include "system.h"


 
 
int udp2hibi_rx_conf( int ip_addr, int dest_port, int source_port, int receiving_haddr, int udp2hibi_haddr ) {
        
    // todo: check that ip and ports are valid
    
    // wait tx to finish
    while ( !HPD_TX_DONE( (int*)N2H_REGISTERS_BASE_ADDRESS )) {}
    
    // set up n2h2 to receive ack/nack sent to receiving_haddr
    N2H_CHAN_CONF( 0, N2H_REGISTERS_RX_BUFFER_START, receiving_haddr, 1, N2H_REGISTERS_BASE_ADDRESS);
    
    // set n2h2 to send udp2hibi's rx_conf command to addr 0x01000000, responding to 03000000
    *((int*)N2H_REGISTERS_TX_BUFFER_START + 0) = 0x30000000;
    *((int*)N2H_REGISTERS_TX_BUFFER_START + 1) = ip_addr;
    *((int*)N2H_REGISTERS_TX_BUFFER_START + 2) = (dest_port << 16) | source_port;
    *((int*)N2H_REGISTERS_TX_BUFFER_START + 3) = receiving_haddr;
    
    N2H_SEND( N2H_REGISTERS_TX_BUFFER_START, 4, udp2hibi_haddr, N2H_REGISTERS_BASE_ADDRESS );
    
    return 1;
}


int udp2hibi_tx_conf( unsigned int timeout, int ip_addr, int dest_port, int source_port, int receiving_haddr, int udp2hibi_haddr ) {
    
    // todo: other info
    
    // timeout must be under 2^28, so that 4 first bits of tx will be zeros (tx conf header)
    if ( timeout > 0x0FFFFFFF ) {
        return 0;
    }
    
    // wait tx to finish
    while ( !N2H_TX_DONE( (int*)N2H_REGISTERS_BASE_ADDRESS )) {}
    
    // set n2h2 to wait for an ack
    N2H_CHAN_CONF( 0, N2H_REGISTERS_RX_BUFFER_START, receiving_haddr, 1, N2H_REGISTERS_BASE_ADDRESS);
    
    // tx conf
    *((int*)N2H_REGISTERS_TX_BUFFER_START + 0) = timeout;
    *((int*)N2H_REGISTERS_TX_BUFFER_START + 1) = ip_addr;
    *((int*)N2H_REGISTERS_TX_BUFFER_START + 2) = (dest_port << 16) | source_port;
    *((int*)N2H_REGISTERS_TX_BUFFER_START + 3) = receiving_haddr;
    
    N2H_SEND( N2H_REGISTERS_TX_BUFFER_START, 4, udp2hibi_haddr, N2H_REGISTERS_BASE_ADDRESS );
    
    return 1;
}



int udp2hibi_check_tx_ack( unsigned int received_header ) {
    
    // an ack starts with 0x5, and if bit 27 is '1', it's a tx ack
    // so header >> 27 should be 0b01011 = 11 
    if ( (received_header >> 27) == 11 ) {
        // success
        return 1;
    }
    return 0;
}


int udp2hibi_check_rx_ack( unsigned int received_header ) {
    
    // an ack starts with 0x5, and if bit 27 is '0', it's a rx ack
    // so header >> 27 should be 0b01010 = 10 
    if ( (received_header >> 27) == 10 ) {
        // success
        return 1;
    }
    return 0;
}



void udp2hibi_write_data_header( int* mem_addr, int tx_length ) {
    
    // check that length is correct ( 0 < len <= ethernet packet size - headers )
    // (ethernet pkt - eth headers/checksum - ip headers - udp headers
    //  = 1518 - 18 - 20 - 8 = 1472) 
    if ( tx_length < 1 || tx_length > 1472 ) {
        return 0;
    }
    // if correct, write the header
    *mem_addr = (1 << 28) | (tx_length << 17);
    return 1;
}



void udp2hibi_release_lock( int udp2hibi_haddr ) {
    
    // wait tx to finish
    while (!N2H_TX_DONE( (int*)N2H_REGISTERS_BASE_ADDRESS ) ){}
    
    // write the release header to memory
    *(int*)N2H_REGISTERS_TX_BUFFER_START = 0x20000000;
    // send
    N2H_SEND( N2H_REGISTERS_TX_BUFFER_START, 1, udp2hibi_haddr, N2H_REGISTERS_BASE_ADDRESS );
}














