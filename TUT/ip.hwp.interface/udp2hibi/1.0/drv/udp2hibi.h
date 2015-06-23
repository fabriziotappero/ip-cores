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

#ifndef UDP2HIBI_H_
#define UDP2HIBI_H_


/* Reserve a slot from udp2hibi's rx configuration table. The udp2hibi
 * then relays matching transmissions to address receiving_haddr. An ack
 * is sent if reservation is succesful, and a nack comes if the table
 * is full. 1 is returned on success, 0 if the given rx info is somehow
 * invalid.
 */ 
int udp2hibi_rx_conf( int ip_addr, int dest_port, int source_port, int receiving_haddr, int udp2hibi_haddr );


/* Lock udp2hibi to listen data that is coming to address udp2hibi_haddr.
 * Also configure destination ip and ports for a following transfer.
 * An ack is sent to the receiving_haddr, if the udp2hibi is not already
 * reserved. If a nack is received, it means that someone else is using
 * udp2hibi right now and you should try again after a while. Returns 1
 * on success, 0 if there is something wrong with the given parameters.
 * Timeout has to be under 2^28.
 */
int udp2hibi_tx_conf( unsigned int timeout, int ip_addr, int dest_port, int source_port, int receiving_haddr, int udp2hibi_haddr );


/* Check if the tx/rx ack received is correct. Both functions return
 * 1 on success, and 0 if it's a nack or an invalid header.
 */
int udp2hibi_check_tx_ack( unsigned int received_header );
int udp2hibi_check_rx_ack( unsigned int received_header );


/* You are responsible of storing the data to be sent to correct addresses
 * in the shared memory between cpu and n2h2. This function only saves you
 * from generating and storing the udp2hibi data header.
 */
 void udp2hibi_write_data_header( int* mem_addr, int tx_length );
 
 
 /* This function makes udp2hibi again available for other agents.
  * Call this after you have finished sending. And don't you forget,
  * or the other agents will be very angry...
  */
  void udp2hibi_release_lock( int udp2hibi_haddr );

#endif /*UDP2HIBI_H_*/
