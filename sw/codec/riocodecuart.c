/*******************************************************************************
 * 
 * RapidIO IP Library Core
 * 
 * This file is part of the RapidIO IP library project
 * http://www.opencores.org/cores/rio/
 * 
 * Description:
 * This file contains code that can serialize and deserialize rio symbols onto 
 * and from an 8-bit UART transmission channel.
 *
 * To Do:
 * -
 * 
 * Author(s): 
 * - Magnus Rosenius, magro732@opencores.org 
 * 
 *******************************************************************************
 * 
 * Copyright (C) 2013 Authors and OPENCORES.ORG 
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

#include <stdint.h>

typedef enum 
{
  RIO_SYMBOL_TYPE_IDLE, RIO_SYMBOL_TYPE_CONTROL, 
  RIO_SYMBOL_TYPE_DATA, RIO_SYMBOL_TYPE_ERROR
} RioSymbolType;

typedef struct
{
  RioSymbolType type;
  uint32_t data;
} RioSymbol;

typedef struct
{
  
} RioStack_t;

void RIO_portAddSymbol( RioStack_t *stack, const RioSymbol s );
RioSymbol RIO_portGetSymbol( RioStack_t *stack );


void receiveByte(RioStack_t *stack, uint8_t incoming)
{
  static RioSymbol rxSymbol;
  static uint8_t flagFound = 0;
  static uint8_t symbolCounter = 0;


  if(incoming != 0x7e)
  {
    if(incoming != 0x7d)
    {
      if(flagFound)
      {
        incoming ^= 0x20;
      }
      else
      {
        /* Dont do anything. */
      }

      switch(symbolCounter)
      {
        case 0:
          rxSymbol.type = RIO_SYMBOL_TYPE_ERROR;
          rxSymbol.data = incoming;
          symbolCounter++;
          break;
        case 1:
          rxSymbol.type = RIO_SYMBOL_TYPE_ERROR;
          rxSymbol.data <<= 8;
          rxSymbol.data |= incoming;
          symbolCounter++;
          break;
        case 2:
          rxSymbol.type = RIO_SYMBOL_TYPE_CONTROL;
          rxSymbol.data <<= 8;
          rxSymbol.data |= incoming;
          symbolCounter++;
          break;
        case 3:
          rxSymbol.type = RIO_SYMBOL_TYPE_DATA;
          rxSymbol.data <<= 8;
          rxSymbol.data |= incoming;

          RIO_portAddSymbol(stack, rxSymbol);

          rxSymbol.data = 0x00000000;
          symbolCounter = 0;
          break;
      }

      flagFound = 0;
    }
    else
    {
      flagFound = 1;
    }
  }
  else
  {
    if(symbolCounter == 0)
    {
      rxSymbol.type = RIO_SYMBOL_TYPE_IDLE;
      RIO_portAddSymbol(stack, rxSymbol);
    }
    else
    {
      RIO_portAddSymbol(stack, rxSymbol);
    }

    symbolCounter = 0;
  }
}

uint8_t transmitByte(RioStack_t *stack)
{
  uint8_t returnValue;
  static uint8_t symbolCounter = 3;
  static uint8_t stuffing = 0;
  static RioSymbol txSymbol;
  uint8_t outbound;


  /* Check if the previous symbol has been sent. */
  if((symbolCounter == 3) && (stuffing == 0))
  {
    /* Symbol sent. */

    /* Get a new symbol. */
    txSymbol = RIO_portGetSymbol(stack);
    if(txSymbol.type == RIO_SYMBOL_TYPE_CONTROL)
    {
      txSymbol.data <<= 8;
    }
  }
  else
  {
    /* Symbol not sent. */
    /* Continue to send the old symbol. */
  }

  /* Check if a flag should be sent. */
  if ((txSymbol.type == RIO_SYMBOL_TYPE_IDLE) || 
      ((stuffing == 0) && (symbolCounter == 0) && (txSymbol.type == RIO_SYMBOL_TYPE_CONTROL)))
  {
    /* A flag needs to be sent. */
    /* An idle symbol should be sent as a flag and a control symbol should always be 
       terminated by a flag. */
    returnValue = 0x7e;
    symbolCounter = 3;
    stuffing = 0;
  }
  else
  {
    /* A flag does not need to be sent. */

    /* Get the current byte in the symbol. */
    outbound = txSymbol.data >> (8*symbolCounter);

    /* Check if stuffing is active. */
    if(!stuffing)
    {
      /* No stuffing active. */

      /* Check if the current byte needs to be stuffed. */
      if((outbound != 0x7e) && (outbound != 0x7d))
      {
        /* The current byte does not need to be stuffed. */
        returnValue = outbound;
        symbolCounter = (symbolCounter - 1) & 0x3;
      }
      else
      {
        /* The current byte needs to be stuffed. */
        returnValue = 0x7d;
        stuffing = 1;
      }
    }
    else
    {
      /* Stuffing is active. */
      /* An escape sequence has been sent, transmit the original data but change it to not being a flag. */
      returnValue = outbound ^ 0x20;
      stuffing = 0;
      symbolCounter = (symbolCounter - 1) & 0x3;
    }
  }

  return returnValue;
}



/*******************************************************************************
 * Module test code.
 *******************************************************************************/

#define TESTEXPR(got, expected)                                         \
  if ((got)!=(expected))                                                \
  {                                                                     \
    printf("ERROR at line %u:%s=%u (0x%08x) expected=%u (0x%08x)\n",    \
           __LINE__, #got, (got), (got), (expected), (expected));       \
    exit(1);                                                            \
  }
static RioSymbol txSymbol;
static uint8_t txNewSymbol;
static RioSymbol rxSymbol;
static uint8_t rxNewSymbol;
void RIO_portAddSymbol( RioStack_t *stack, const RioSymbol s )
{
  rxNewSymbol = 1;
  rxSymbol = s;
}
RioSymbol RIO_portGetSymbol( RioStack_t *stack )
{
  if(txNewSymbol)
  {
    txNewSymbol = 0;
    return txSymbol;
  }
  else
  {
    RioSymbol s;
    s.type = RIO_SYMBOL_TYPE_ERROR;
    return s;
  }
}
int main(int argc, char *argv[])
{
  RioStack_t *stack;

  /***************************************************************
   * Test receiver.
   ***************************************************************/

  /* Receive a flag. */
  rxNewSymbol = 0;
  receiveByte(stack, 0x7e);
  TESTEXPR(rxNewSymbol, 1);
  TESTEXPR(rxSymbol.type, RIO_SYMBOL_TYPE_IDLE);

  /* Receive not a flag followed by flag. */
  rxNewSymbol = 0;
  receiveByte(stack, 0xaa);
  receiveByte(stack, 0x7e);
  TESTEXPR(rxNewSymbol, 1);
  TESTEXPR(rxSymbol.type, RIO_SYMBOL_TYPE_ERROR);
  
  /* Receive not a flag twice followed by flag. */
  rxNewSymbol = 0;
  receiveByte(stack, 0xaa);
  receiveByte(stack, 0x55);
  receiveByte(stack, 0x7e);
  TESTEXPR(rxNewSymbol, 1);
  TESTEXPR(rxSymbol.type, RIO_SYMBOL_TYPE_ERROR);

  /* Receive a control symbol followed by flag. */
  rxNewSymbol = 0;
  receiveByte(stack, 0x11);
  receiveByte(stack, 0x22);
  receiveByte(stack, 0x33);
  receiveByte(stack, 0x7e);
  TESTEXPR(rxNewSymbol, 1);
  TESTEXPR(rxSymbol.type, RIO_SYMBOL_TYPE_CONTROL);
  TESTEXPR(rxSymbol.data, 0x00112233);

  /* Receive a data symbol. */
  rxNewSymbol = 0;
  receiveByte(stack, 0x44);
  receiveByte(stack, 0x55);
  receiveByte(stack, 0x66);
  receiveByte(stack, 0x77);
  TESTEXPR(rxNewSymbol, 1);
  TESTEXPR(rxSymbol.type, RIO_SYMBOL_TYPE_DATA);
  TESTEXPR(rxSymbol.data, 0x44556677);

  /* Receive a back-to-back data symbol. */
  rxNewSymbol = 0;
  receiveByte(stack, 0x88);
  receiveByte(stack, 0x99);
  receiveByte(stack, 0xaa);
  receiveByte(stack, 0xbb);
  TESTEXPR(rxNewSymbol, 1);
  TESTEXPR(rxSymbol.type, RIO_SYMBOL_TYPE_DATA);
  TESTEXPR(rxSymbol.data, 0x8899aabb);

  /* Receive a back-to-back control symbol. */
  rxNewSymbol = 0;
  receiveByte(stack, 0xcc);
  receiveByte(stack, 0xdd);
  receiveByte(stack, 0xee);
  receiveByte(stack, 0x7e);
  TESTEXPR(rxNewSymbol, 1);
  TESTEXPR(rxSymbol.type, RIO_SYMBOL_TYPE_CONTROL);
  TESTEXPR(rxSymbol.data, 0x00ccddee);

  /* Test control symbol with one stuffed byte. */
  rxNewSymbol = 0;
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5e);
  receiveByte(stack, 0xff);
  receiveByte(stack, 0x01);
  receiveByte(stack, 0x7e);
  TESTEXPR(rxNewSymbol, 1);
  TESTEXPR(rxSymbol.type, RIO_SYMBOL_TYPE_CONTROL);
  TESTEXPR(rxSymbol.data, 0x007eff01);

  /* Test control symbol with two stuffed bytes. */
  rxNewSymbol = 0;
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5e);
  receiveByte(stack, 0xff);
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5d);
  receiveByte(stack, 0x7e);
  TESTEXPR(rxNewSymbol, 1);
  TESTEXPR(rxSymbol.type, RIO_SYMBOL_TYPE_CONTROL);
  TESTEXPR(rxSymbol.data, 0x007eff7d);

  /* Test control symbol with three stuffed bytes. */
  rxNewSymbol = 0;
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5d);
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5e);
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5d);
  receiveByte(stack, 0x7e);
  TESTEXPR(rxNewSymbol, 1);
  TESTEXPR(rxSymbol.type, RIO_SYMBOL_TYPE_CONTROL);
  TESTEXPR(rxSymbol.data, 0x007d7e7d);

  /* Test data symbol with one stuffed byte. */
  rxNewSymbol = 0;
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5e);
  receiveByte(stack, 0x00);
  receiveByte(stack, 0x01);
  receiveByte(stack, 0x02);
  TESTEXPR(rxNewSymbol, 1);
  TESTEXPR(rxSymbol.type, RIO_SYMBOL_TYPE_DATA);
  TESTEXPR(rxSymbol.data, 0x7e000102);

  /* Test data symbol with two stuffed bytes. */
  rxNewSymbol = 0;
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5e);
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5d);
  receiveByte(stack, 0x03);
  receiveByte(stack, 0x04);
  TESTEXPR(rxNewSymbol, 1);
  TESTEXPR(rxSymbol.type, RIO_SYMBOL_TYPE_DATA);
  TESTEXPR(rxSymbol.data, 0x7e7d0304);

  /* Test data symbol with three stuffed bytes. */
  rxNewSymbol = 0;
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5e);
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5d);
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5e);
  receiveByte(stack, 0x05);
  TESTEXPR(rxNewSymbol, 1);
  TESTEXPR(rxSymbol.type, RIO_SYMBOL_TYPE_DATA);
  TESTEXPR(rxSymbol.data, 0x7e7d7e05);

  /* Test data symbol with four stuffed bytes. */
  rxNewSymbol = 0;
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5e);
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5d);
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5e);
  receiveByte(stack, 0x7d);
  receiveByte(stack, 0x5d);
  TESTEXPR(rxNewSymbol, 1);
  TESTEXPR(rxSymbol.type, RIO_SYMBOL_TYPE_DATA);
  TESTEXPR(rxSymbol.data, 0x7e7d7e7d);

  /***************************************************************
   * Test transmitter.
   ***************************************************************/

  /* Test transmission of idle symbol. */
  txNewSymbol = 1;
  txSymbol.type = RIO_SYMBOL_TYPE_IDLE;
  TESTEXPR(transmitByte(stack), 0x7e);

  /* Test transmission of control symbol. */
  txNewSymbol = 1;
  txSymbol.type = RIO_SYMBOL_TYPE_CONTROL;
  txSymbol.data = 0x00112233;
  TESTEXPR(transmitByte(stack), 0x11);
  TESTEXPR(transmitByte(stack), 0x22);
  TESTEXPR(transmitByte(stack), 0x33);
  TESTEXPR(transmitByte(stack), 0x7e);

  /* Test transmission of data symbol. */
  txNewSymbol = 1;
  txSymbol.type = RIO_SYMBOL_TYPE_DATA;
  txSymbol.data = 0x44556677;
  TESTEXPR(transmitByte(stack), 0x44);
  TESTEXPR(transmitByte(stack), 0x55);
  TESTEXPR(transmitByte(stack), 0x66);
  TESTEXPR(transmitByte(stack), 0x77);

  /* Test transmission of back-to-back data symbol. */
  txNewSymbol = 1;
  txSymbol.type = RIO_SYMBOL_TYPE_DATA;
  txSymbol.data = 0x8899aabb;
  TESTEXPR(transmitByte(stack), 0x88);
  TESTEXPR(transmitByte(stack), 0x99);
  TESTEXPR(transmitByte(stack), 0xaa);
  TESTEXPR(transmitByte(stack), 0xbb);

  /* Test transmission of back-to-back control symbol. */
  txNewSymbol = 1;
  txSymbol.type = RIO_SYMBOL_TYPE_CONTROL;
  txSymbol.data = 0xffccddee;
  TESTEXPR(transmitByte(stack), 0xcc);
  TESTEXPR(transmitByte(stack), 0xdd);
  TESTEXPR(transmitByte(stack), 0xee);
  TESTEXPR(transmitByte(stack), 0x7e);

  /* Test transmission of back-to-back control symbol. */
  txNewSymbol = 1;
  txSymbol.type = RIO_SYMBOL_TYPE_CONTROL;
  txSymbol.data = 0xff010203;
  TESTEXPR(transmitByte(stack), 0x01);
  TESTEXPR(transmitByte(stack), 0x02);
  TESTEXPR(transmitByte(stack), 0x03);
  TESTEXPR(transmitByte(stack), 0x7e);

  /* Test transmission of control symbol with one stuffed byte. */
  txNewSymbol = 1;
  txSymbol.type = RIO_SYMBOL_TYPE_CONTROL;
  txSymbol.data = 0xff7e0102;
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5e);
  TESTEXPR(transmitByte(stack), 0x01);
  TESTEXPR(transmitByte(stack), 0x02);
  TESTEXPR(transmitByte(stack), 0x7e);

  /* Test transmission of stuffed control symbol with two stuffed bytes. */
  txNewSymbol = 1;
  txSymbol.type = RIO_SYMBOL_TYPE_CONTROL;
  txSymbol.data = 0xff7e7d01;
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5e);
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5d);
  TESTEXPR(transmitByte(stack), 0x01);
  TESTEXPR(transmitByte(stack), 0x7e);

  /* Test transmission of stuffed control symbol with three stuffed bytes. */
  txNewSymbol = 1;
  txSymbol.type = RIO_SYMBOL_TYPE_CONTROL;
  txSymbol.data = 0xff7e7d7e;
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5e);
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5d);
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5e);
  TESTEXPR(transmitByte(stack), 0x7e);

  /* Test transmission of data symbol with one stuffed byte. */
  txNewSymbol = 1;
  txSymbol.type = RIO_SYMBOL_TYPE_DATA;
  txSymbol.data = 0x7e010203;
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5e);
  TESTEXPR(transmitByte(stack), 0x01);
  TESTEXPR(transmitByte(stack), 0x02);
  TESTEXPR(transmitByte(stack), 0x03);

  /* Test transmission of data symbol with two stuffed byte. */
  txNewSymbol = 1;
  txSymbol.type = RIO_SYMBOL_TYPE_DATA;
  txSymbol.data = 0x7e7d0102;
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5e);
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5d);
  TESTEXPR(transmitByte(stack), 0x01);
  TESTEXPR(transmitByte(stack), 0x02);

  /* Test transmission of data symbol with three stuffed byte. */
  txNewSymbol = 1;
  txSymbol.type = RIO_SYMBOL_TYPE_DATA;
  txSymbol.data = 0x7e7d7e01;
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5e);
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5d);
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5e);
  TESTEXPR(transmitByte(stack), 0x01);

  /* Test transmission of data symbol with four stuffed byte. */
  txNewSymbol = 1;
  txSymbol.type = RIO_SYMBOL_TYPE_DATA;
  txSymbol.data = 0x7e7d7e7d;
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5e);
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5d);
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5e);
  TESTEXPR(transmitByte(stack), 0x7d);
  TESTEXPR(transmitByte(stack), 0x5d);

  /***************************************************************
   * Test complete.
   ***************************************************************/

  printf("Test complete.\n");
}
