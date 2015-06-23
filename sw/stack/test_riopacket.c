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
 * gcc -o testriopacket test_riopacket.c -fprofile-arcs -ftest-coverage
 * ./testriopacket
 * gcov test_riopacket.c
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
#include "riopacket.c"

#define PrintS(s)                               \
  {                                             \
    FILE *fd;                                   \
    fd=fopen("testspec.txt", "a");              \
    fputs(s "\n", fd);                          \
    fclose(fd);                                 \
  }

#define TESTSTART(s) printf(s)
#define TESTEND printf(" passed.\n");

#define TESTCOND(got)                           \
  if (!(got))                                   \
  {                                             \
    printf("\nERROR at line %u:%s=%u (0x%08x)\n", \
           __LINE__, #got, (got), (got));       \
    exit(1);                                    \
  }

#define TESTEXPR(got, expected)                                         \
  if ((got)!=(expected))                                                \
  {                                                                     \
    printf("\nERROR at line %u:%s=%u (0x%08x) expected=%u (0x%08x)\n",    \
           __LINE__, #got, (got), (got), (expected), (expected));       \
    exit(1);                                                            \
  }

#define TESTPACKET(got, expected) testSymbol(__LINE__, #got, (got), (expected))

void testPacket(uint32_t line, char *expression, RioPacket_t got, RioPacket_t expected)
{
  int i;


  if ((got).size==(expected).size)
  {
    for(i = 0; i < got.size; i++)
    {
      if(got.payload[i] != expected.payload[i])
      {
        printf("\nERROR at line %u:%s:payload[%u]:=%u (0x%08x) expected=%u (0x%08x)\n", 
               line, expression, i, (got).payload[i], (got).payload[i], (expected).payload[i], (expected).payload[i]); 
        exit(1);
      }
    }
  }
  else
  {
    printf("\nERROR at line %u:%s:size=%u (0x%08x) expected=%u (0x%08x)\n", 
           line, expression, (got).size, (got).size, (expected).size, (expected).size); 
    exit(1);
  }
}

void packetClear(RioPacket_t *packet)
{
  uint32_t i;

  for(i = 0; i < RIOPACKET_SIZE_MAX; i++)
  {
    packet->payload[i] = 0xdeadbeef;
  }
}

/*******************************************************************************
 * Module test for this file.
 *******************************************************************************/
int32_t main(void)
{
  RioPacket_t packet;
  int i, j, k;
  uint16_t length;
  uint16_t dstidExpected, dstid;
  uint16_t srcidExpected, srcid;
  uint8_t tidExpected, tid;
  uint8_t hopExpected, hop;
  uint8_t mailboxExpected, mailbox;
  uint16_t infoExpected, info;
  uint32_t addressExpected, address;
  uint32_t dataExpected, data;

  uint16_t payloadSizeExpected, payloadSize;
  uint8_t payloadExpected[256], payload[256];

  uint8_t buffer[512];
  uint16_t bufferSize;

  srand(0);

  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("TG_riopacket-TC1");
  PrintS("Description: Test packet initialization, validation and appending.");
  PrintS("Requirement: XXXXX");
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 1:");
  PrintS("Action: ");
  PrintS("Result: ");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC1-Step1");
  /******************************************************************************/

  RIOPACKET_init(&packet);

  TESTEXPR(RIOPACKET_size(&packet), 0);
  TESTCOND(!RIOPACKET_valid(&packet));

  RIOPACKET_append(&packet, 0x001a0001);

  TESTEXPR(RIOPACKET_size(&packet), 1);
  TESTCOND(!RIOPACKET_valid(&packet));

  RIOPACKET_append(&packet, 0xffff0000);

  TESTEXPR(RIOPACKET_size(&packet), 2);
  TESTCOND(!RIOPACKET_valid(&packet));

  RIOPACKET_append(&packet, 0xdeaf9903);

  TESTEXPR(RIOPACKET_size(&packet), 3);
  TESTCOND(RIOPACKET_valid(&packet));

  /* Check that altering the ackid does not affect the validity of the packet. */
  packet.payload[0] |= 0xfc000000;
  TESTCOND(RIOPACKET_valid(&packet));

  /* Access the packet and check its content. */
  TESTEXPR(RIOPACKET_getFtype(&packet), RIOPACKET_FTYPE_DOORBELL);
  TESTEXPR(RIOPACKET_getDestination(&packet), 0x0001);
  TESTEXPR(RIOPACKET_getSource(&packet), 0xffff);
  TESTEXPR(RIOPACKET_getTid(&packet), 0x00);
  RIOPACKET_getDoorbell(&packet, &dstid, &srcid, &tid, &info);
  TESTEXPR(dstid, 0x0001);
  TESTEXPR(srcid, 0xffff);
  TESTEXPR(tid, 0x00);
  TESTEXPR(info, 0xdeaf);

  bufferSize = RIOPACKET_serialize(&packet, sizeof(buffer), buffer);
  TESTEXPR(bufferSize, 13);
  TESTEXPR(buffer[0], 0x03);
  TESTEXPR(buffer[1], 0xfc);
  TESTEXPR(buffer[2], 0x1a);
  TESTEXPR(buffer[3], 0x00);
  TESTEXPR(buffer[4], 0x01);
  TESTEXPR(buffer[5], 0xff);
  TESTEXPR(buffer[6], 0xff);
  TESTEXPR(buffer[7], 0x00);
  TESTEXPR(buffer[8], 0x00);
  TESTEXPR(buffer[9], 0xde);
  TESTEXPR(buffer[10], 0xaf);
  TESTEXPR(buffer[11], 0x99);
  TESTEXPR(buffer[12], 0x03);

  RIOPACKET_init(&packet);
  RIOPACKET_deserialize(&packet, bufferSize, buffer);
  TESTCOND(RIOPACKET_valid(&packet));
  TESTEXPR(RIOPACKET_getFtype(&packet), RIOPACKET_FTYPE_DOORBELL);
  TESTEXPR(RIOPACKET_getDestination(&packet), 0x0001);
  TESTEXPR(RIOPACKET_getSource(&packet), 0xffff);
  TESTEXPR(RIOPACKET_getTid(&packet), 0x00);
  RIOPACKET_getDoorbell(&packet, &dstid, &srcid, &tid, &info);
  TESTEXPR(dstid, 0x0001);
  TESTEXPR(srcid, 0xffff);
  TESTEXPR(tid, 0x00);
  TESTEXPR(info, 0xdeaf);

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("TG_riopacket-TC2");
  PrintS("Description: Test maintenance packets.");
  PrintS("Requirement: XXXXX");
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 1:");
  PrintS("Action: ");
  PrintS("Result: ");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC2-Step1");
  /******************************************************************************/

  RIOPACKET_init(&packet);
  RIOPACKET_setMaintReadRequest(&packet, 0xc0de, 0xbabe, 0x13, 0x41, 0xffffffff);
  RIOPACKET_getMaintReadRequest(&packet, &dstid, &srcid, &hop, &tid, &address);

  TESTCOND(RIOPACKET_valid(&packet));
  TESTEXPR(dstid, 0xc0de);
  TESTEXPR(srcid, 0xbabe);
  TESTEXPR(hop, 0x13);
  TESTEXPR(tid, 0x41);
  TESTEXPR(address, 0x00fffffc);
  
  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("TG_riopacket-TC3");
  PrintS("Description: Test input/output packets.");
  PrintS("Requirement: XXXXX");
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 1:");
  PrintS("Action: ");
  PrintS("Result: ");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC3-Step1");
  /******************************************************************************/


  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("TG_riopacket-TC4");
  PrintS("Description: Test message passing packets.");
  PrintS("Requirement: XXXXX");
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 1:");
  PrintS("Action: Send a message with invalid payload length.");
  PrintS("Result: No packet should be generated.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC4-Step1");
  /******************************************************************************/

  RIOPACKET_setMessage(&packet, 0xdead, 0xbeef, 0xc0, 0, &payloadExpected[0]);

  TESTEXPR(packet.size, 0);
  TESTCOND(!RIOPACKET_valid(&packet));

  RIOPACKET_setMessage(&packet, 0xdead, 0xbeef, 0xc0, 257, &payloadExpected[0]);

  TESTEXPR(packet.size, 0);
  TESTCOND(!RIOPACKET_valid(&packet));

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/
  PrintS("----------------------------------------------------------------------");
  PrintS("Step 2:");
  PrintS("Action: Test sending all possible payload sizes on random deviceIds ");
  PrintS("        and mailboxes.");
  PrintS("Result: The content of the packet should be equal to what was entered.");
  PrintS("----------------------------------------------------------------------");
  /******************************************************************************/
  TESTSTART("TG_riostack-TC4-Step2");
  /******************************************************************************/

  for(i = 1; i <= 256; i++)
  {
    dstidExpected = rand();
    srcidExpected = rand();
    mailboxExpected = rand();

    if((i%8) == 0)
    {
      payloadSizeExpected = 8*(i/8);
    }
    else
    {
      payloadSizeExpected = 8*(i/8+1);
    }

    for(j = 0; j < i; j++)
    {
      payloadExpected[j] = rand();
    }
    
    RIOPACKET_setMessage(&packet, dstidExpected, srcidExpected, mailboxExpected, 
                         i, &payloadExpected[0]);
    TESTCOND(RIOPACKET_valid(&packet));

    RIOPACKET_getMessage(&packet, &dstid, &srcid, &mailbox, &payloadSize, &(payload[0]));
    TESTEXPR(dstid, dstidExpected);
    TESTEXPR(srcid, srcidExpected);
    TESTEXPR(mailbox, mailboxExpected);
    TESTEXPR(payloadSize, payloadSizeExpected);
    for(j = 0; j < i; j++)
    {
      TESTEXPR(payload[j], payloadExpected[j]);
    }
  }

  /******************************************************************************/
  TESTEND;
  /******************************************************************************/

  return 0;
}

/*************************** end of file **************************************/
