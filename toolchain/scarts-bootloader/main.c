/* Copyright (C) 2010, 2011 Embedded Computing Systems Group,
Department of Computer Engineering, Vienna University of Technology.
Contributed by Martin Walter <mwalter@opencores.org>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 2.1 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>. */


#include <inttypes.h>
#include <machine/UART.h>
#include <machine/modules.h>

#if defined __SCARTS_16__
  #include "gdb/sim-scarts_16.h"
  #define SCARTS_ADDR_CTYPE  uint16_t
#elif defined __SCARTS_32__
  #include "gdb/sim-scarts_32.h"
  #define SCARTS_ADDR_CTYPE  uint32_t
#else
  #error "Unsupported target machine type"
#endif

#define SCARTS_INSN_SIZE 2

#define NUM_HEX_CHARS_PER_BYTE     2
#define SREC_MAX_LINE_LEN         80
#define SREC_FIELD_TYPE_OFFSET     1
#define SREC_FIELD_LENGTH_LEN      2
#define SREC_FIELD_LENGTH_OFFSET   2
#define SREC_FIELD_ADDRESS_OFFSET  4
#define SREC_FIELD_CHECKSUM_LEN    2
#define SREC_TYPE_HEADER           0
#define SREC_TYPE_DATA2            1
#define SREC_TYPE_DATA2_TERM       9
#define SREC_TYPE_DATA4            3
#define SREC_TYPE_DATA4_TERM       7

typedef struct
{
  uint8_t           type;
  uint8_t           length;
  uint8_t           address_length;
  SCARTS_ADDR_CTYPE address;
  uint8_t           payload_num_bytes;
  uint8_t           payload_offset;
  uint8_t           size;
} srecord_t;

static uint8_t
char_to_int (char c)
{
  if (c >= '0' && c <= '9')
    return c - 48;
  else if (c >= 'A' && c <= 'F')
    return c - 55;
  else
    return 0;
}

static void
program_codemem (srecord_t *srec, char *buffer)
{
  int8_t i;

  srec->address -= SCARTS_CODEMEM_LMA;
  srec->address /= SCARTS_INSN_SIZE;

  /* Iterate over the number of codewords in the current srecord. */
  for (i = 0; i < srec->payload_num_bytes / SCARTS_INSN_SIZE; ++i)
  {
    /* Write the address of the current codeword to
     * the address register of the programmer module. */
    PROGRAMMER_ADDRESS = srec->address + i;

    /* Prepare the characters in the buffer to form a proper codeword
     * and write this to the data register of the programmer module. */
    PROGRAMMER_DATA = (char_to_int (buffer[srec->payload_offset + 2]) << 12)
                    + (char_to_int (buffer[srec->payload_offset + 3]) << 8)
                    + (char_to_int (buffer[srec->payload_offset + 0]) << 4)
                    + (char_to_int (buffer[srec->payload_offset + 1]));

    /* Advance the payload offset pointer to point to the next codeword. */
    srec->payload_offset += (SCARTS_INSN_SIZE * NUM_HEX_CHARS_PER_BYTE);

    /* Tell the programmer module to perform the download. */
    PROGRAMMER_CONFIG_C |= (1 << PROGRAMMER_CONFIG_C_PREXE);
  }
}

static void
program_datamem (srecord_t *srec, char *buffer)
{
  int8_t i;
  uint8_t data;
  volatile uint8_t *address;

  /* Iterate over the number of data bytes in the current srecord. */
  for (i = 0; i < srec->payload_num_bytes; ++i)
  {
    /* Write the address of the current data byte to
     * the address register of the programmer module. */
    address = (uint8_t *) srec->address + i;

    /* Prepare the characters in the buffer to form a proper data byte. */
    data = (char_to_int (buffer[srec->payload_offset + 0]) << 4)
         + (char_to_int (buffer[srec->payload_offset + 1]));

    /* Advance the payload offset pointer to point to the next datum. */
    srec->payload_offset += NUM_HEX_CHARS_PER_BYTE;

    *address = data;
  }
}

int main (int argc, char *argv[])
{
  char buffer[SREC_MAX_LINE_LEN+1];
  int8_t i, j;
  srecord_t srec;
  UART_Cfg cfg;

  /* Define the UART settings. */
  cfg.fclk = UART_CFG_FCLK_40MHZ;
  cfg.baud = UART_CFG_BAUD_57600;
  cfg.frame.msg_len = UART_CFG_MSG_LEN_8;
  cfg.frame.parity = UART_CFG_PARITY_EVEN;
  cfg.frame.stop_bits = UART_CFG_STOP_BITS_2;

  UART_init (cfg);
  while (1)
  {
    srec.size = UART_read_line (0, buffer, SREC_MAX_LINE_LEN);

    if (srec.size == 0)
      continue;

    /* Check if the line starts with an 'S'. */
    if (buffer[0] != 'S')
      continue;

    /* Extract the srecord type. */
    srec.type = char_to_int (buffer[SREC_FIELD_TYPE_OFFSET]);

    /* Extract the srecord length. */
    srec.length = (char_to_int (buffer[SREC_FIELD_LENGTH_OFFSET]) << 4)
                 + char_to_int (buffer[SREC_FIELD_LENGTH_OFFSET + 1]);

    /* Process the current srecord. */
    switch (srec.type)
    {
      case SREC_TYPE_DATA4:
      {
        /* Deduce the address field length from the srecord type. */
        srec.address_length = 8;

        /* Extract the address at which the payload is to be loaded. */
        srec.address = 0;
        for (i = 0; i < srec.address_length; ++i)
        {
          j = srec.address_length - 1 - i;
          srec.address += char_to_int (buffer[SREC_FIELD_ADDRESS_OFFSET + i]) << 4 * j;
        }

        /* Compute the offset and length (bytes) of the payload field. */
        srec.payload_offset = SREC_FIELD_ADDRESS_OFFSET + srec.address_length;
        srec.payload_num_bytes = (srec.size - srec.payload_offset - SREC_FIELD_CHECKSUM_LEN) / NUM_HEX_CHARS_PER_BYTE;

        if (srec.address >= SCARTS_CODEMEM_LMA)
          program_codemem (&srec, buffer);
        else
          program_datamem (&srec, buffer);

        break;
      }
      case SREC_TYPE_DATA4_TERM:
      {
        /* Set the program counter to SCARTS_CODEMEM_LMA. */
#if defined __SCARTS_16__
        asm ("ldhi r13, 0");
#elif defined __SCARTS_32__
        asm ("ldhi r13, 0");
        asm ("ldliu r13, 0");
        asm ("sli r13, 0x8");
        asm ("ldliu r13, 0");
        asm ("sli r13, 0x8");
#endif
        asm ("ldliu r13, 0");
        asm ("jmp r13");
      }
      default:
        continue;
    }
  }

  return 0;
}

