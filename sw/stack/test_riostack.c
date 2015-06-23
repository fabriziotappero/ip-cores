/*******************************************************************************
 * 
 * RapidIO IP Library Core
 * 
 * This file is part of the RapidIO IP library project
 * http://www.opencores.org/cores/rio/
 * 
 * Description:
 * This file contains automatic regression tests for riopacket. Compile and 
 * run it by using:
 * gcc -o testriostack test_riostack.c riopacket.c -fprofile-arcs -ftest-coverage
 * ./testriostack
 * gcov test_riostack.c
 *
 * To Do:
 * -
 * 
 * Author(s): 
 * - Magnus Rosenius, magro732@opencores.org 
 * 
 *******************************************************************************
 * 
 * Copyright (C) 2015 Authors and OPENCORES.ORG 
 * 
 * This source file may be used and distributed without 
 * restriction provided that this copyright statement is not 
 * removed from the file and that any derivative work contains 
 * the original copyright notice and the associated disclaimer. 
 * 
 * This source file is free software; you can redistribute it 
 * and/or modify it under the terms of the GNU Lesser General 
 * Public License as published by the Free Software Foundation; 
 * either version 2.1 of the License, or (at your option) any 
 * later version. 
 * 
 * This source is distributed in the hope that it will be 
 * useful, but WITHOUT ANY WARRANTY; without even the implied 
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR 
 * PURPOSE. See the GNU Lesser General Public License for more 
 * details. 
 * 
 * You should have received a copy of the GNU Lesser General 
 * Public License along with this source; if not, download it 
 * from http://www.opencores.org/lgpl.shtml 
 * 
 *******************************************************************************/
 
#include <stdio.h>
#include <stdlib.h>

#define MODULE_TEST
#include "riostack.c"

#define PrintS(s)                               \
  {                                             \
    FILE *fd;                                   \
    fd=fopen("testspec.txt", "a");              \
    fputs(s "\n", fd);                          \
    fclose(fd);                                 \
  }

#define TESTSTART(s) printf(s)
#define TESTEND printf(" passed.\n");

#define TESTCOND(got)                                   \
  if (!(got))                                           \
  {                                                     \
    printf("\nERROR at line %u:%s=%u (0x%08x)\n",       \
           __LINE__, #got, (got), (got));               \
    exit(1);                                            \
  }

#define TESTEXPR(got, expected)                                         \
  if ((got)!=(expected))                                                \
  {                                                                     \
    printf("\nERROR at line %u:%s=%u (0x%08x) expected=%u (0x%08x)\n",  \
           __LINE__, #got, (got), (got), (expected), (expected));       \
    exit(1);                                                            \
  }

#define TESTSYMBOL(got, expected) testSymbol(__LINE__, #got, (got), (expected))

void testSymbol(uint32_t line, char *expression, RioSymbol_t got, RioSymbol_t expected)
{
  if ((got).type==(expected).type)                                      
  {                                                                     
    switch ((got).type)                                                 
    {                                                                   
      case RIOSTACK_SYMBOL_TYPE_ERROR:
      case RIOSTACK_SYMBOL_TYPE_IDLE:                                        
        break;                                                          
      case RIOSTACK_SYMBOL_TYPE_CONTROL:                                     
        if((got).data != (expected).data)                               
        {                                                               
          if(STYPE0_GET((got).data) != STYPE0_GET((expected).data))     
          {                                                             
            printf("\nERROR at line %u:STYPE0=0x%02x expected=0x%02x\n",  
                   line, STYPE0_GET((got).data), STYPE0_GET((expected).data)); 
          }                                                             
          if(PARAMETER0_GET((got).data) != PARAMETER0_GET((expected).data)) 
          {                                                             
            printf("\nERROR at line %u:PARAMETER0=0x%02x expected=0x%02x\n", 
                   line, PARAMETER0_GET((got).data), PARAMETER0_GET((expected).data)); 
          }                                                             
          if(PARAMETER1_GET((got).data) != PARAMETER1_GET((expected).data)) 
          {                                                             
            printf("\nERROR at line %u:PARAMETER1=0x%02x expected=0x%02x\n", 
                   line, PARAMETER1_GET((got).data), PARAMETER1_GET((expected).data)); 
          }                                                             
          if(STYPE1_GET((got).data) != STYPE1_GET((expected).data))     
          {                                                             
            printf("\nERROR at line %u:STYPE1=0x%02x expected=0x%02x\n",  
                   line, STYPE1_GET((got).data), STYPE1_GET((expected).data)); 
          }                                                             
          if(CMD_GET((got).data) != CMD_GET((expected).data))           
          {                                                             
            printf("\nERROR at line %u:CMD=0x%02x expected=0x%02x\n",     
                   line, CMD_GET((got).data), CMD_GET((expected).data)); 
          }                                                             
          if(CRC5_GET((got).data) != CRC5_GET((expected).data))         
          {                                                             
            printf("\nERROR at line %u:CRC5=0x%02x expected=0x%02x\n",    
                   line, CRC5_GET((got).data), CRC5_GET((expected).data)); 
          }                                                             
          exit(1);
        }                                                               
        break;                                                          
      case RIOSTACK_SYMBOL_TYPE_DATA:                                        
        if((got).data != (expected).data)                               
        {                                                               
          printf("\nERROR at line %u:%s=%u (0x%08x) expected=%u (0x%08x)\n", 
                 line, expression, (got).data, (got).data, (expected).data, (expected).data); 
          exit(1);
        }                                                               
        break;                                                          
    }    
  }
  else
  {
    printf("\nERROR at line %u:%s=%u (0x%08x) expected=%u (0x%08x)\n", 
           line, expression, (got).type, (got).type, (expected).type, (expected).type); 
    exit(1);
  }
}



uint8_t createDoorbell(uint32_t *doorbell, uint8_t ackId, uint16_t destid, uint16_t srcId, uint8_t tid, uint16_t info)
{
  uint16_t crc;
  uint32_t content;

  /* ackId(4:0)|0|vc|crf|prio(1:0)|tt(1:0)|ftype(3:0)|destinationId(15:0) */
  /* ackId is set when the packet is transmitted. */
  content = 0x001aul << 16;
  content |= (uint32_t) destid;
  crc = RIOPACKET_Crc32(content, 0xffffu);
  doorbell[0] = (((uint32_t) ackId) << 27) | content;

  /* sourceId(15:0)|rsrv(7:0)|srcTID(7:0) */
  content = ((uint32_t) srcId) << 16;
  content |= (uint32_t) tid;
  crc = RIOPACKET_Crc32(content, crc);
  doorbell[1] = content;

  /* infoMSB(7:0)|infoLSB(7:0)|crc(15:0) */
  content = ((uint32_t) info) << 16;
  crc = RIOPACKET_Crc16(info, crc);
  content |= ((uint32_t) crc);
  doorbell[2] = content;

  return 3;

}

/*******************************************************************************
 * Module test for this file.
 *******************************************************************************/
int32_t main(void)
{
  RioStack_t stack;
  uint32_t rxPacketBuffer[RIOSTACK_BUFFER_SIZE*8], txPacketBuffer[RIOSTACK_BUFFER_SIZE*8];
  RioPacket_t rioPacket;
  uint32_t packet[69];
  RioSymbol_t s, c, d;
  int i, j, k;
  uint16_t length;
  uint16_t dstid;
  uint16_t srcid;
  uint8_t tid;
  uint8_t hop;
  uint8_t mailbox;
  uint16_t info;
  uint32_t address;
  uint32_t data;
  uint8_t payload8[256];
  uint8_t payload8Expected[256];
  uint32_t packetLength;


  /*************************************************************************
   * Test prelude.
   * Setup the RIO stack for operation.
   *************************************************************************/

  /* Open the stack and set the port status to initialized. */
  RIOSTACK_open(&stack, NULL,
                RIOSTACK_BUFFER_SIZE*8, &rxPacketBuffer[0],
                RIOSTACK_BUFFER_SIZE*8, &txPacketBuffer[0]);

  /* Set the port timeout. */
  RIOSTACK_portSetTimeout(&stack, 1);

  /* Set the current port time. */
  RIOSTACK_portSetTime(&stack, 0);

  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("TG_riostack");
  PrintS("----------------------------------------------------------------------");
  PrintS("TG_riostack-TC1");
  PrintS("Description: Test link initialization and normal packet exchange.");
  PrintS("Requirement: XXXXX");
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 1:");
  PrintS("Action: Send packets when port is uninitialized.");
  PrintS("Result: All packets should be ignored during initialization.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC1-Step1");
  /******************************************************************************/

  /* Place a packet in the outbound queue to check that it is received once 
     the transmitter is placed in the correct state. */
  RIOPACKET_setDoorbell(&rioPacket, 1, 0xffff, 0, 0xdeaf);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);
  
  /* Check that only idle symbols are transmitted when the port has not been
     initialied even if statuses are received. */
  for(i = 0; i < 1024; i++)
  {
    RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 0, 1, STYPE1_NOP, 0));
    s = RIOSTACK_portGetSymbol(&stack);
    TESTEXPR(s.type, RIOSTACK_SYMBOL_TYPE_IDLE);
  }
  
  /******************************************************************************/
  TESTEND;
  /*****************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 2:");
  PrintS("Action: Set port initialized and get symbols from the stack.");
  PrintS("Result: Status-control-symbols should be generated each 256 symbol.");
  PrintS("----------------------------------------------------------------------");
  /*****************************************************************************/
  TESTSTART("TG_riostack-TC1-Step2");
  /*****************************************************************************/
   
  /* Set the port status to intialized. */
  RIOSTACK_portSetStatus(&stack, 1);

  /* Set port time. */
  RIOSTACK_portSetTime(&stack, 1);

  /* Check that status-control-symbols are transmitted once every 256 symbol. */
  for(j = 0; j < 15; j++)
  {
    for(i = 0; i < 255; i++)
    {
      s = RIOSTACK_portGetSymbol(&stack);
      TESTEXPR(s.type, RIOSTACK_SYMBOL_TYPE_IDLE);
    }
    s = RIOSTACK_portGetSymbol(&stack);
    c = CreateControlSymbol(STYPE0_STATUS, 0, 8, STYPE1_NOP, 0);
    TESTEXPR(s.type, c.type);
    TESTEXPR(s.data, c.data);
  }

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 3:");
  PrintS("Action: Add a status-control-symbol to the receiver.");
  PrintS("Result: Status-control-symbols should be generated each 15 symbol.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC1-Step3");
  /*****************************************************************************/

  /* Insert a status-control-symbol in the receive. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 0, 1, STYPE1_NOP, 0));
  
  /* Check that status-control-symbols are transmitted once every 16 symbol. */
  for(i = 0; i < 15; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    TESTEXPR(s.type, RIOSTACK_SYMBOL_TYPE_IDLE);
  }
  s = RIOSTACK_portGetSymbol(&stack);
  c = CreateControlSymbol(STYPE0_STATUS, 0, 8, STYPE1_NOP, 0);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 4:");
  PrintS("Action: Add a packet to the receiver.");
  PrintS("Result: Packet should be ignored until the link is initialized.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC1-Step4");
  /*****************************************************************************/

  /* Send a packet. Note that the start and end of the packet contains a status. */
  packetLength = createDoorbell(packet, 0, 0, 0, 0, 0);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 0, 8, STYPE1_START_OF_PACKET, 0));
  for(i = 0; i < packetLength; i++)
  {
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    RIOSTACK_portAddSymbol(&stack, d);
  }
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 0, 8, STYPE1_END_OF_PACKET, 0));

  /* Check that packet was not received. */
  TESTEXPR(RIOSTACK_getInboundQueueLength(&stack), 0);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 5:");
  PrintS("Action: Add four more status-control-symbols followed by one with error in ");
  PrintS("        CRC5. Then send a packet.");
  PrintS("Result: The receiver should remain in port initialized and packet should ");
  PrintS("        still be ignored.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC1-Step5");
  /*****************************************************************************/

  /* Send 4 more status-control-symbols followed by one erronous. */
  for(i = 0; i < 4; i++)
  {
    RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 0, 1, STYPE1_NOP, 0));
  }
  c = CreateControlSymbol(STYPE0_STATUS, 0, 1, STYPE1_NOP, 0);
  c.data ^= 1;
  RIOSTACK_portAddSymbol(&stack, c);

  /* Send a packet. Note that the start and end of the packet contains status. */
  packetLength = createDoorbell(packet, 0, 0, 0, 0, 0);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 0, 8, STYPE1_START_OF_PACKET, 0));
  for(i = 0; i < packetLength; i++)
  {
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    RIOSTACK_portAddSymbol(&stack, d);
  }
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 0, 8, STYPE1_END_OF_PACKET, 0));

  /* Check that the packet was ignored. */
  TESTEXPR(RIOSTACK_getInboundQueueLength(&stack), 0);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 6:");
  PrintS("Action: Add six more status-control-symbols. Then send a packet.");
  PrintS("Result: The receiver should enter link initialized and the packet should ");
  PrintS("        be received.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC1-Step6");
  /*****************************************************************************/

  /* Send 6 more status-control-symbols. */
  for(i = 0; i < 6; i++)
  {
    RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 0, 1, STYPE1_NOP, 0));
  }

  /* Send a packet and check that it is accepted. */
  /* The ackId on receiver in testobject is updated when this has been transmitted. */
  packetLength = createDoorbell(packet, 0, 0, 0, 0, 0);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 0, 8, STYPE1_START_OF_PACKET, 0));
  for(i = 0; i < packetLength; i++)
  {
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    RIOSTACK_portAddSymbol(&stack, d);
  }
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 0, 8, STYPE1_END_OF_PACKET, 0));

  /* Check that the packet is received. */
  TESTEXPR(RIOSTACK_getInboundQueueLength(&stack), 1);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 7:");
  PrintS("Action: Get symbols from transmitter.");
  PrintS("Result: Status-control-symbols should still be generated each 15 symbol ");
  PrintS("until a total of 15 status-control-symbols has been transmitted. Once these ");
  PrintS("has been transmitted, the transmitter will be link initialized.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC1-Step7");
  /*****************************************************************************/

  /* Note that the available buffers in the receiver should have decremented once 
     since the previously received packet has not been read from the application 
     side of the stack yet. */
  for(j = 0; j < 14; j++)
  {
    for(i = 0; i < 15; i++)
    {
      s = RIOSTACK_portGetSymbol(&stack);
      TESTEXPR(s.type, RIOSTACK_SYMBOL_TYPE_IDLE);
    }
    s = RIOSTACK_portGetSymbol(&stack);
    c = CreateControlSymbol(STYPE0_STATUS, 1, 7, STYPE1_NOP, 0);
    TESTEXPR(s.type, c.type);
    TESTEXPR(s.data, c.data);
  }

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 8:");
  PrintS("Action: Get the first symbol from the transmitter once the link-intialized ");
  PrintS("        state has been entered.");
  PrintS("Result: A packet-accepted-symbol should be received for the newly received ");
  PrintS("        packet.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC1-Step8");
  /*****************************************************************************/

  c = CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 0, 7, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 9:");
  PrintS("Action: Get the next symbols from the transmitter.");
  PrintS("Result: The packet placed in the outbound queue at startup should be ");
  PrintS("        received. Dont acknowledge the packet yet.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC1-Step9");
  /*****************************************************************************/

  /* Create a packet. */
  packetLength = createDoorbell(packet, 0, 1, 0xffff, 0, 0xdeaf);

  /* Receive the start of the frame. */
  c = CreateControlSymbol(STYPE0_STATUS, 1, 7, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Receive the data of the frame. */
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }

  /* Receive the end of the frame. */
  c = CreateControlSymbol(STYPE0_STATUS, 1, 7, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTSYMBOL(s, c);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 10:");
  PrintS("Action: Remove the packet from the inbound queue. Dont acknowledge the");
  PrintS("        transmitted packet yet.");
  PrintS("Result: Check that status-control-symbols are sent each 256 symbol and that ");
  PrintS("        the buffer count is updated when the inbound packet has been read.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC1-Step10");
  /*****************************************************************************/

  /* Simulate the application reading the received packet to free one reception 
     buffer. */
  RIOSTACK_getInboundPacket(&stack, &rioPacket);

  /* Check that the status-control-symbols are generated each 256 symbol. */
  for(i = 0; i < 255; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    TESTEXPR(s.type, RIOSTACK_SYMBOL_TYPE_IDLE);
  }

  /* Check that the buffer status has been updated. */
  s = RIOSTACK_portGetSymbol(&stack);
  c = CreateControlSymbol(STYPE0_STATUS, 1, 8, STYPE1_NOP, 0);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 11:");
  PrintS("Action: Send a packet when an acknowledge has not been received.");
  PrintS("Result: Only idle and status control symbols should be transmitted until ");
  PrintS("        the packet-accepted symbol has been received.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC1-Step11");
  /*****************************************************************************/

  /* Place a packet in the outbound queue. */
  RIOPACKET_setDoorbell(&rioPacket, 2, 0xffff, 1, 0xc0de);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);

  packetLength = createDoorbell(packet, 1, 2, 0xffff, 1, 0xc0de);

  /* Receive the start of the frame. */
  c = CreateControlSymbol(STYPE0_STATUS, 1, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Receive the data of the frame. */
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }

  /* Receive the end of the frame. */
  c = CreateControlSymbol(STYPE0_STATUS, 1, 8, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTSYMBOL(s, c);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 12:");
  PrintS("Action: Send a packet-accepted symbol.");
  PrintS("Result: Check that the new packet is transmitted.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC1-Step12");
  /*****************************************************************************/

  /* Send acknowledge for the first frame. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 0, 1, STYPE1_NOP, 0));

  /* Check that status-control-symbols are transmitted once every 256 symbol with 
     updated ackId. */
  for(i = 0; i < 255; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    TESTEXPR(s.type, RIOSTACK_SYMBOL_TYPE_IDLE);
  }
  s = RIOSTACK_portGetSymbol(&stack);
  c = CreateControlSymbol(STYPE0_STATUS, 1, 8, STYPE1_NOP, 0);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 13:");
  PrintS("Action: Send a packet-accepted symbol.");
  PrintS("Result: Check that only idle and status-control-symbols are transmitted ");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC1-Step13");
  /*****************************************************************************/

  /* Acknowledge the second frame. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 1, 1, STYPE1_NOP, 0));

  /* Check that status-control-symbols are transmitted once every 256 symbol with 
     updated ackId. */
  for(i = 0; i < 255; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    TESTEXPR(s.type, RIOSTACK_SYMBOL_TYPE_IDLE);
  }
  s = RIOSTACK_portGetSymbol(&stack);
  c = CreateControlSymbol(STYPE0_STATUS, 1, 8, STYPE1_NOP, 0);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("TG_riostack-TC2");
  PrintS("Description: Test flow control.");
  PrintS("Requirement: XXXXX");
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 1:");
  PrintS("Action: Send packets to receiver but don't acknowledge them.");
  PrintS("Result: The reception queue of the stack is full.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC2-Step1");
  /******************************************************************************/

  /* Fill input queue in receiver. */
  for(j = 0; j < 8; j++)
  {
    packetLength = createDoorbell(packet, 1+j, 0, 0, 1+j, 0);

    RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 2, 1, STYPE1_START_OF_PACKET, 0));
    for(i = 0; i < packetLength; i++)
    {
      d.type = RIOSTACK_SYMBOL_TYPE_DATA;
      d.data = packet[i];
      RIOSTACK_portAddSymbol(&stack, d);
    }
    RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 2, 1, STYPE1_END_OF_PACKET, 0));

    c = CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 1+j, 7-j, STYPE1_NOP, 0);
    s = RIOSTACK_portGetSymbol(&stack);
    TESTEXPR(s.type, c.type);
    TESTEXPR(s.data, c.data);
  }
  
  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 2:");
  PrintS("Action: Send a packet when the inbound queue of the stack is full.");
  PrintS("Result: The stack sends a packet-retry symbol. The receiver will end up in ");
  PrintS("input-retry-stopped state.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC2-Step2");
  /******************************************************************************/

  /* Send another packet. */
  packetLength = createDoorbell(packet, 9, 0, 0, 9, 0);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 2, 1, STYPE1_START_OF_PACKET, 0));
  for(i = 0; i < packetLength; i++)
  {
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    RIOSTACK_portAddSymbol(&stack, d);
  }
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 2, 1, STYPE1_END_OF_PACKET, 0));

  /* Receive indication from stack that the packet must be retried. */
  c = CreateControlSymbol(STYPE0_PACKET_RETRY, 9, 0, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 3:");
  PrintS("Action: Send a packet when the receiver is in input-retry-stopped.");
  PrintS("Result: The receiver should ignore the new packet.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC2-Step3");
  /******************************************************************************/

  /* Resend the packet. */
  packetLength = createDoorbell(packet, 9, 0, 0, 9, 0);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 2, 1, STYPE1_START_OF_PACKET, 0));
  for(i = 0; i < packetLength; i++)
  {
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    RIOSTACK_portAddSymbol(&stack, d);
  }
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 2, 1, STYPE1_END_OF_PACKET, 0));
  s = RIOSTACK_portGetSymbol(&stack);

  /* Check that nothing is transmitted. */
  TESTEXPR(s.type, RIOSTACK_SYMBOL_TYPE_IDLE);

  /* REMARK: Send other symbols here to check that they are handled as expected... */

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 4:");
  PrintS("Action: Send restart-from-retry and resend the previous packet.");
  PrintS("Result: The receiver should leave the input-retry-stopped state and receive ");
  PrintS("        the new frame.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC2-Step4");
  /******************************************************************************/

  /* Send restart-from-retry. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 2, 1, STYPE1_RESTART_FROM_RETRY, 0));

  /* Check that the transaction id is correct and remove a packet from the inbound 
     queue. One entry in the inbound queue will be empty. */
  RIOSTACK_getInboundPacket(&stack, &rioPacket);
  RIOPACKET_getDoorbell(&rioPacket, &dstid, &srcid, &tid, &info);
  TESTEXPR(tid, 1);

  /* Check that the buffer status has changed to show that a buffer is available. */
  s = RIOSTACK_portGetSymbol(&stack);  
  while(s.type == RIOSTACK_SYMBOL_TYPE_IDLE)
  {
    s = RIOSTACK_portGetSymbol(&stack);  
  }
  c = CreateControlSymbol(STYPE0_STATUS, 9, 1, STYPE1_NOP, 0);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Resend the packet and check that it is received. */
  packetLength = createDoorbell(packet, 9, 0, 0, 9, 0);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 2, 1, STYPE1_START_OF_PACKET, 0));
  for(i = 0; i < packetLength; i++)
  {
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    RIOSTACK_portAddSymbol(&stack, d);
  }
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 2, 1, STYPE1_END_OF_PACKET, 0));
  c = CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 9, 0, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  
  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 5:");
  PrintS("Action: Place receiver in input-retry-stopped state.");
  PrintS("Result: Check that packets may be transmitted normally.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC2-Step5");
  /******************************************************************************/

  /* Send another packet and check that the receiver indicates that it should be retried. */
  packetLength = createDoorbell(packet, 10, 0, 0, 10, 0);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 2, 1, STYPE1_START_OF_PACKET, 0));
  for(i = 0; i < packetLength; i++)
  {
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    RIOSTACK_portAddSymbol(&stack, d);
  }
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 2, 1, STYPE1_END_OF_PACKET, 0));
  c = CreateControlSymbol(STYPE0_PACKET_RETRY, 10, 0, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send two packets to see that the first acknowledge has been processed. */
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 2, 0xfeed);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 3, 0xdeed);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);

  /* Get the first packet. */
  packetLength = createDoorbell(packet, 2, 0, 0xffff, 2, 0xfeed);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 0, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }

  /* Get the second packet. */
  packetLength = createDoorbell(packet, 3, 0, 0xffff, 3, 0xdeed);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 0, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTSYMBOL(s, c);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  c = CreateControlSymbol(STYPE0_STATUS, 10, 0, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Indicate the packets must be retransmitted. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_RETRY, 2, 1, STYPE1_NOP, 0));

  /* Receive confirmation that the packet will be retransmitted. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 0, STYPE1_RESTART_FROM_RETRY, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTSYMBOL(s, c);

  /* Get the retransmission of the first packet. */
  packetLength = createDoorbell(packet, 2, 0, 0xffff, 2, 0xfeed);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 0, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }

  /* Get the retransmission of the second packet. */
  packetLength = createDoorbell(packet, 3, 0, 0xffff, 3, 0xdeed);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 0, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTSYMBOL(s, c);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  c = CreateControlSymbol(STYPE0_STATUS, 10, 0, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Confirm the reception of the packets. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 2, 1, STYPE1_NOP, 0));
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 3, 1, STYPE1_NOP, 0));

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 6:");
  PrintS("Action: Send status-control-symbol to show that no packets can be ");
  PrintS("        transmitted.");
  PrintS("Result: No packets should be transmitted.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC2-Step6");
  /******************************************************************************/

  /* Send status with bufferStatus set to zero. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 4, 0, STYPE1_NOP, 0));

  /* Send a packet. */
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 4, 0xf00d);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);

  /* Check that nothing is transmitted but status-control-symbols. */  
  for(i = 0; i < 255; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    TESTEXPR(s.type, RIOSTACK_SYMBOL_TYPE_IDLE);
  }
  s = RIOSTACK_portGetSymbol(&stack);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 0, STYPE1_NOP, 0);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 7:");
  PrintS("Action: Indicate free buffers and receive a frame, then request it to be ");
  PrintS("retried.");
  PrintS("Result: The packet should be retransmitted.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC2-Step7");
  /******************************************************************************/

  /* Send status with bufferStatus set to available. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 4, 1, STYPE1_NOP, 0));

  /* Get the packet but request it to be retried. */
  packetLength = createDoorbell(packet, 4, 0, 0xffff, 4, 0xf00d);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 0, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  c = CreateControlSymbol(STYPE0_STATUS, 10, 0, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_RETRY, 4, 1, STYPE1_NOP, 0));

  /* Check the acknowledge of the retransmission. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 0, STYPE1_RESTART_FROM_RETRY, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Get the packet and acknowledge it. */
  packetLength = createDoorbell(packet, 4, 0, 0xffff, 4, 0xf00d);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 0, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  c = CreateControlSymbol(STYPE0_STATUS, 10, 0, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 4, 1, STYPE1_NOP, 0));

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 8:");
  PrintS("Action: Read all inbound packets from the reception queue.");
  PrintS("Result: The buffer status should be updated.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC2-Step8");
  /******************************************************************************/

  for(j = 0; j < 8; j++)
  {
    RIOSTACK_getInboundPacket(&stack, &rioPacket);
    RIOPACKET_getDoorbell(&rioPacket, &dstid, &srcid, &tid, &info);
    TESTEXPR(tid, j+2);
    
    for(i = 0; i < 255; i++)
    {
      s = RIOSTACK_portGetSymbol(&stack);
      TESTEXPR(s.type, RIOSTACK_SYMBOL_TYPE_IDLE);
    }
    s = RIOSTACK_portGetSymbol(&stack);
    c = CreateControlSymbol(STYPE0_STATUS, 10, j+1, STYPE1_NOP, 0);
    TESTEXPR(s.type, c.type);
    TESTEXPR(s.data, c.data);
  }
  
  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 9:");
  PrintS("Action: Send a restart-from-retry to make the receiver leave the ");
  PrintS("        input-retry-stopped state.");
  PrintS("Result: New packets should be received again.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC2-Step9");
  /******************************************************************************/

  /* Send restart-from-retry. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, STYPE1_RESTART_FROM_RETRY, 0));


  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("TG_riostack-TC3");
  PrintS("Description: Test receiver error handling.");
  PrintS("Requirement: XXXXX");
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 1:");
  PrintS("Action: Send invalid ack id in packet.");
  PrintS("Result: Input-error-stopped state should be entered and link-response ");
  PrintS("        should indicate an ackId error.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC3-Step1");
  /******************************************************************************/

  /* Send packet with invalid ackId, same as sent previously. */
  packetLength = createDoorbell(packet, 9, 0, 0, 10, 0);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, STYPE1_START_OF_PACKET, 0));
  for(i = 0; i < packetLength; i++)
  {
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    RIOSTACK_portAddSymbol(&stack, d);
  }
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, STYPE1_END_OF_PACKET, 0));

  /* Check that the packet is not accepted with cause error in ackId. */  
  c = CreateControlSymbol(STYPE0_PACKET_NOT_ACCEPTED, 0, 1, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send a link-request. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, 
                                                     STYPE1_LINK_REQUEST, LINK_REQUEST_INPUT_STATUS));

  /* Check that a link-response is returned. */
  /* Note that the status of the input-port will be reported as ok since a 
     link-request has been received. */
  c = CreateControlSymbol(STYPE0_LINK_RESPONSE, 10, 16, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Check that a status is transmitted directly after the link-response. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 2:");
  PrintS("Action: Send packet with invalid CRC.");
  PrintS("Result: Input-error-stopped state should be entered and link-response ");
  PrintS("        should indicate a CRC error.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC3-Step2");
  /******************************************************************************/

  /* Send packet with invalid crc. */
  packetLength = createDoorbell(packet, 10, 0, 0, 10, 0);
  packet[0] ^= 0x00000001;
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, STYPE1_START_OF_PACKET, 0));
  for(i = 0; i < packetLength; i++)
  {
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    RIOSTACK_portAddSymbol(&stack, d);
  }
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, STYPE1_END_OF_PACKET, 0));

  /* Check that the packet is not accepted with cause error in ackId. */  
  c = CreateControlSymbol(STYPE0_PACKET_NOT_ACCEPTED, 0, 4, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send a link-request. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, 
                                                     STYPE1_LINK_REQUEST, LINK_REQUEST_INPUT_STATUS));

  /* Check that a link-response is returned. */
  /* Note that the status of the input-port will be reported as ok since a 
     link-request has been received. */
  c = CreateControlSymbol(STYPE0_LINK_RESPONSE, 10, 16, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Check that a status is transmitted directly after the link-response. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 3:");
  PrintS("Action: Send a packet that is too short.");
  PrintS("Result: Input-error-stopped state should be entered and link-response ");
  PrintS("        should indicate a packet error.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC3-Step3");
  /******************************************************************************/

  /* Send packet with valid ackid and crc but too short. */
  packetLength = createDoorbell(packet, 10, 0, 0, 10, 0);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, STYPE1_START_OF_PACKET, 0));
  d.type = RIOSTACK_SYMBOL_TYPE_DATA;
  d.data = packet[0];
  RIOSTACK_portAddSymbol(&stack, d);
  d.type = RIOSTACK_SYMBOL_TYPE_DATA;
  d.data = ((uint32_t) RIOPACKET_Crc32(packet[0] & 0x07ffffff, 0xffff)) << 16;
  RIOSTACK_portAddSymbol(&stack, d);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, STYPE1_END_OF_PACKET, 0));

  /* Check that the packet is not accepted with cause error in ackId. */  
  c = CreateControlSymbol(STYPE0_PACKET_NOT_ACCEPTED, 0, 31, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send a link-request. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, 
                                                     STYPE1_LINK_REQUEST, LINK_REQUEST_INPUT_STATUS));

  /* Check that a link-response is returned. */
  /* Note that the status of the input-port will be reported as ok since a 
     link-request has been received. */
  c = CreateControlSymbol(STYPE0_LINK_RESPONSE, 10, 16, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Check that a status is transmitted directly after the link-response. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 4:");
  PrintS("Action: Send a packet that is too long.");
  PrintS("Result: Input-error-stopped state should be entered and link-response ");
  PrintS("        should indicate a packet error.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC3-Step4");
  /******************************************************************************/

  /* Send packet with too many data symbols and without a end-of-packet. */
  packetLength = createDoorbell(packet, 10, 0, 0, 10, 0);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, STYPE1_START_OF_PACKET, 0));
  for(i = 0; i < packetLength; i++)
  {
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    RIOSTACK_portAddSymbol(&stack, d);
  }
  for(; i < 70; i++)
  {
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = i;
    RIOSTACK_portAddSymbol(&stack, d);
  }

  /* Check that the packet is not accepted with cause error in ackId. */  
  c = CreateControlSymbol(STYPE0_PACKET_NOT_ACCEPTED, 0, 31, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send a link-request. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, 
                                                     STYPE1_LINK_REQUEST, LINK_REQUEST_INPUT_STATUS));

  /* Check that a link-response is returned. */
  /* Note that the status of the input-port will be reported as ok since a 
     link-request has been received. */
  c = CreateControlSymbol(STYPE0_LINK_RESPONSE, 10, 16, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Check that a status is transmitted directly after the link-response. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 5:");
  PrintS("Action: Send a data symbol without starting a packet.");
  PrintS("Result: Input-error-stopped state should be entered and link-response ");
  PrintS("        should indicate a packet error.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC3-Step5");
  /******************************************************************************/

  /* Send a data symbol. */
  packetLength = createDoorbell(packet, 10, 0, 0, 10, 0);
  d.type = RIOSTACK_SYMBOL_TYPE_DATA;
  d.data = packet[0];
  RIOSTACK_portAddSymbol(&stack, d);

  /* Check that the packet is not accepted with cause error in ackId. */  
  c = CreateControlSymbol(STYPE0_PACKET_NOT_ACCEPTED, 0, 31, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send a link-request. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, 
                                                     STYPE1_LINK_REQUEST, LINK_REQUEST_INPUT_STATUS));

  /* Check that a link-response is returned. */
  /* Note that the status of the input-port will be reported as ok since a 
     link-request has been received. */
  c = CreateControlSymbol(STYPE0_LINK_RESPONSE, 10, 16, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Check that a status is transmitted directly after the link-response. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  
  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 6:");
  PrintS("Action: Send end-of-packet without matching start.");
  PrintS("Result: Input-error-stopped state should be entered and link-response ");
  PrintS("        should indicate a packet error.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC3-Step6");
  /******************************************************************************/

  /* Send end-of-packet. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, STYPE1_END_OF_PACKET, 0));

  /* Check that the packet is not accepted with cause error in ackId. */
  c = CreateControlSymbol(STYPE0_PACKET_NOT_ACCEPTED, 0, 4, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTSYMBOL(s, c);

  /* Send a link-request. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, 
                                                     STYPE1_LINK_REQUEST, LINK_REQUEST_INPUT_STATUS));

  /* Check that a link-response is returned. */
  /* Note that the status of the input-port will be reported as ok since a 
     link-request has been received. */
  c = CreateControlSymbol(STYPE0_LINK_RESPONSE, 10, 16, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Check that a status is transmitted directly after the link-response. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 7:");
  PrintS("Action: Send a symbol indicating a codec error.");
  PrintS("Result: Input-error-stopped state should be entered and link-response ");
  PrintS("        should indicate a symbol error.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC3-Step7");
  /******************************************************************************/

  /* Send error-symbol. */
  s.type = RIOSTACK_SYMBOL_TYPE_ERROR;
  RIOSTACK_portAddSymbol(&stack, s);

  /* Check that the packet is not accepted with cause error in ackId. */  
  c = CreateControlSymbol(STYPE0_PACKET_NOT_ACCEPTED, 0, 5, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send a link-request. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, 
                                                     STYPE1_LINK_REQUEST, LINK_REQUEST_INPUT_STATUS));

  /* Check that a link-response is returned. */
  /* Note that the status of the input-port will be reported as ok since a 
     link-request has been received. */
  c = CreateControlSymbol(STYPE0_LINK_RESPONSE, 10, 16, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Check that a status is transmitted directly after the link-response. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_NOP, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("TG_riostack-TC4");
  PrintS("Description: Test transmitter error handling.");
  PrintS("Requirement: XXXXX");
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 1:");
  PrintS("Action: Send acknowledge for a frame that has not been transmitted and ");
  PrintS("        without any frame being expected.");
  PrintS("Result: The transmitter should enter output-error-stopped and send ");
  PrintS("        link-request.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC4-Step1");
  /******************************************************************************/

  /* Packet acknowledge for unsent frame. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 5, 1, STYPE1_NOP, 0));

  /* Check that a link-request is received as the transmitter enters 
     output-error-stopped state. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, 
                          STYPE1_LINK_REQUEST, LINK_REQUEST_INPUT_STATUS);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send link-response with expected ackId. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_LINK_RESPONSE, 5, 16, STYPE1_NOP, 0));
  
  /* Send a status directly afterwards. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 5, 1, STYPE1_NOP, 0));

  /* Check that packets are relayed after this. */
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 5, 2);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);
  packetLength = createDoorbell(packet, 5, 0, 0xffff, 5, 2);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 5, 1, STYPE1_NOP, 0));

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 2:");
  PrintS("Action: Send a packet and send acknowledge for a previous frame. Then send ");
  PrintS("        a link-response indicating that the packet was received (accepted ");
  PrintS("        but reply corrupted).");
  PrintS("Result: The transmitter should enter output-error-stopped state and send ");
  PrintS("        link-request and proceed with the next packet.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC4-Step2");
  /******************************************************************************/

  /* Send a packet. */
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 6, 2);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);
  packetLength = createDoorbell(packet, 6, 0, 0xffff, 6, 2);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send acknowledge for another packet. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 5, 1, STYPE1_NOP, 0));

  /* Check that a link-request is received as the transmitter enters 
     output-error-stopped state. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, 
                          STYPE1_LINK_REQUEST, LINK_REQUEST_INPUT_STATUS);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send link-response with expected ackId. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_LINK_RESPONSE, 7, 16, STYPE1_NOP, 0));
  
  /* Send a status directly afterwards. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 7, 1, STYPE1_NOP, 0));

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 3:");
  PrintS("Action: Send a packet and let the packet-accepted time out. Then send a ");
  PrintS("        link-response indicating that the packet was not received.");
  PrintS("Result: The transmitter should enter output-error-stopped state, send a");
  PrintS("        link-request and then resend the packet.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC4-Step3");
  /******************************************************************************/

  /* Set the time at frame transmission. */
  RIOSTACK_portSetTime(&stack, 2);

  /* Send an output packet. */
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 7, 2);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);

  /* Receive the transmitted packet. */
  packetLength = createDoorbell(packet, 7, 0, 0xffff, 7, 2);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Indicate that time has passed to trigger a timeout. */
  RIOSTACK_portSetTime(&stack, 3);

  /* Check that a link-request is received as the transmitter enters 
     output-error-stopped state. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, 
                          STYPE1_LINK_REQUEST, LINK_REQUEST_INPUT_STATUS);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send link-response with expected ackId. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_LINK_RESPONSE, 7, 16, STYPE1_NOP, 0));
  
  /* Send a status directly afterwards. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 7, 1, STYPE1_NOP, 0));

  /* Receive retransmitted packet. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send acknowledge for the retransmitted packet. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 7, 1, STYPE1_NOP, 0));

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 4:");
  PrintS("Action: Send a packet and then indicate that the packet was not accepted. ");
  PrintS("        Then send a link-response indicating that the packet was not received.");
  PrintS("Result: The transmitter should enter output-error-stopped state, send a");
  PrintS("        link-request and then resend the packet.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC4-Step4");
  /******************************************************************************/

  /* Send an output packet. */
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 8, 3);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);

  /* Receive the transmitted packet. */
  packetLength = createDoorbell(packet, 8, 0, 0xffff, 8, 3);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send packet-not-accepted indicating CRC error. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_NOT_ACCEPTED, 0, 4, STYPE1_NOP, 0));

  /* Check that a link-request is received as the transmitter enters 
     output-error-stopped state. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, 
                          STYPE1_LINK_REQUEST, LINK_REQUEST_INPUT_STATUS);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send link-response with expected ackId. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_LINK_RESPONSE, 8, 16, STYPE1_NOP, 0));
  
  /* Send a status directly afterwards. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 8, 1, STYPE1_NOP, 0));

  /* Receive retransmitted packet. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send acknowledge for the retransmitted packet. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 8, 1, STYPE1_NOP, 0));

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 5:");
  PrintS("Action: Send a packet-retry for an unexpected packet. Then send a");
  PrintS("        link-response indicating the expected ackId and a normal packet.");
  PrintS("Result: The transmitter should enter output-error-stopped state, send a");
  PrintS("        link-request and then the normal packet.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC4-Step5");
  /******************************************************************************/

  /* Send packet-retry indicating that a packet should be retransmitted. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_RETRY, 8, 1, STYPE1_NOP, 0));

  /* Check that a link-request is received as the transmitter enters 
     output-error-stopped state. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, 
                          STYPE1_LINK_REQUEST, LINK_REQUEST_INPUT_STATUS);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send link-response with expected ackId. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_LINK_RESPONSE, 9, 16, STYPE1_NOP, 0));
  
  /* Send a status directly afterwards. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_STATUS, 9, 1, STYPE1_NOP, 0));

  /* Send an output packet. */
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 9, 4);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);

  /* Receive retransmitted packet. */
  packetLength = createDoorbell(packet, 9, 0, 0xffff, 9, 4);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Send acknowledge for the retransmitted packet. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 9, 1, STYPE1_NOP, 0));

  /******************************************************************************/
  TESTEND; 
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 6:");
  PrintS("Action: Fill outbound queue with packets, then check retransmission when ");
  PrintS("        packet-retry is encountered. ");
  PrintS("Result: Packets should be retried until packet-accepted is received.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC4-Step6");
  /******************************************************************************/

  TESTCOND(RIOSTACK_getOutboundQueueAvailable(&stack) > 0);
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 20, 0xbabe);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);

  TESTCOND(RIOSTACK_getOutboundQueueAvailable(&stack) > 0);
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 21, 0xbabe);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);

  TESTCOND(RIOSTACK_getOutboundQueueAvailable(&stack) > 0);
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 22, 0xbabe);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);

  TESTCOND(RIOSTACK_getOutboundQueueAvailable(&stack) > 0);
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 23, 0xbabe);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);

  TESTCOND(RIOSTACK_getOutboundQueueAvailable(&stack) > 0);
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 24, 0xbabe);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);

  TESTCOND(RIOSTACK_getOutboundQueueAvailable(&stack) > 0);
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 25, 0xbabe);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);

  TESTCOND(RIOSTACK_getOutboundQueueAvailable(&stack) > 0);
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 26, 0xbabe);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);

  TESTCOND(RIOSTACK_getOutboundQueueAvailable(&stack) > 0);
  RIOPACKET_setDoorbell(&rioPacket, 0, 0xffff, 27, 0xbabe);
  RIOSTACK_setOutboundPacket(&stack, &rioPacket);

  TESTCOND(RIOSTACK_getOutboundQueueAvailable(&stack) == 0);

  /* Receive transmitted packet. */
  packetLength = createDoorbell(packet, 10, 0, 0xffff, 20, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  packetLength = createDoorbell(packet, 11, 0, 0xffff, 21, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  packetLength = createDoorbell(packet, 12, 0, 0xffff, 22, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  packetLength = createDoorbell(packet, 13, 0, 0xffff, 23, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  packetLength = createDoorbell(packet, 14, 0, 0xffff, 24, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  packetLength = createDoorbell(packet, 15, 0, 0xffff, 25, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  packetLength = createDoorbell(packet, 16, 0, 0xffff, 26, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  packetLength = createDoorbell(packet, 17, 0, 0xffff, 27, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  for(i = 0; i < 10; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    TESTEXPR(s.type, RIOSTACK_SYMBOL_TYPE_IDLE);
  }

  /* Request retransmission. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_RETRY, 10, 1, STYPE1_NOP, 0));

  /* Acknowledge retransmission. */
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_RESTART_FROM_RETRY, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  /* Check retransmitted packets. */
  packetLength = createDoorbell(packet, 10, 0, 0xffff, 20, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  packetLength = createDoorbell(packet, 11, 0, 0xffff, 21, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  packetLength = createDoorbell(packet, 12, 0, 0xffff, 22, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }

  /* Acknowledge. */
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 10, 1, STYPE1_NOP, 0));
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 11, 1, STYPE1_NOP, 0));

  packetLength = createDoorbell(packet, 13, 0, 0xffff, 23, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  packetLength = createDoorbell(packet, 14, 0, 0xffff, 24, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }

  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 12, 1, STYPE1_NOP, 0));

  packetLength = createDoorbell(packet, 15, 0, 0xffff, 25, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }

  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 13, 1, STYPE1_NOP, 0));

  packetLength = createDoorbell(packet, 16, 0, 0xffff, 26, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 14, 1, STYPE1_NOP, 0));
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  packetLength = createDoorbell(packet, 17, 0, 0xffff, 27, 0xbabe);
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_START_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);
  for(i = 0; i < packetLength; i++)
  {
    s = RIOSTACK_portGetSymbol(&stack);
    d.type = RIOSTACK_SYMBOL_TYPE_DATA;
    d.data = packet[i];
    TESTEXPR(s.type, d.type);
    TESTEXPR(s.data, d.data);
  }
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 15, 1, STYPE1_NOP, 0));
  c = CreateControlSymbol(STYPE0_STATUS, 10, 8, STYPE1_END_OF_PACKET, 0);
  s = RIOSTACK_portGetSymbol(&stack);
  TESTEXPR(s.type, c.type);
  TESTEXPR(s.data, c.data);

  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 16, 1, STYPE1_NOP, 0));
  RIOSTACK_portAddSymbol(&stack, CreateControlSymbol(STYPE0_PACKET_ACCEPTED, 17, 1, STYPE1_NOP, 0));

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/

  return 0;
}

/*************************** end of file **************************************/
