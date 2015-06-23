// **************************************************************************
// File             : mapping.h
// Author           : Lauri Matilainen
// Date             : 17.09.2010
// Decription       : Header-file for funcapi communication in hibi network.
//                   
//                    
// Version history  : 17.09.2005    Lauri Matilainen   1st mod version  
//
//
//
//
// **************************************************************************



#ifndef MAPPING_H
#define MAPPING_H


#define NIOS_0_NODE_ID 0
#define NIOS_1_NODE_ID 1
#define DCT_NODE_ID 2


#define NUM_OF_NODES 3
#define RX_DATA_CH 0

#define MSG_SIZE 32
#define PKT_SIZE 32
#define PKT_HEADER 0x1



// Hibi addresses for corresponding funcapi nodes ie. table_index  = node_num
unsigned int hibi_address_table[NUM_OF_NODES] = {0x01000000, 0x03000000};

#endif // MAPPING_H



