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
#include <stdio.h>
#include <string.h>

#define SCARTS_INSN_SIZE 2

#define NUM_HEX_CHARS_PER_BYTE         2
#define IHEX_MAX_LINE_LEN             50
#define IHEX_FIELD_BYTE_COUNT_OFFSET   1
#define IHEX_FIELD_BYTE_COUNT_LEN      2
#define IHEX_FIELD_ADDRESS_OFFSET      3
#define IHEX_FIELD_ADDRESS_LEN         4
#define IHEX_FIELD_RECORD_TYPE_OFFSET  7
#define IHEX_FIELD_RECORD_TYPE_LEN     2
#define IHEX_FIELD_PAYLOAD_OFFSET      9
#define IHEX_FIELD_CHECKSUM_LEN        2
#define IHEX_REC_TYPE_DATA             0
#define IHEX_REC_TYPE_EOF              1
#define IHEX_REC_TYPE_EXT_SEG_ADDR     2
#define IHEX_REC_TYPE_EXT_LIN_ADDR     4


typedef struct
{
  uint8_t  byte_count;
  uint16_t address;  
  uint8_t  type;
  uint8_t  checksum_offset;
  uint8_t  checksum;
} ihex16_t;

static uint8_t compute_checksum (char *);
static uint8_t char_to_int (char);
static char    int_to_char (uint8_t);

static uint8_t
compute_checksum (char *buffer)
{
  uint8_t checksum, i, j;
  checksum = 0;

  for (i = 1; i < (strlen(buffer) - IHEX_FIELD_CHECKSUM_LEN) / NUM_HEX_CHARS_PER_BYTE; ++i)
  {
    j = NUM_HEX_CHARS_PER_BYTE * i - 1;
    checksum += (char_to_int (buffer[j]) << 4) + char_to_int (buffer[j + 1]);
  }

  checksum ^= 0xFF;
  checksum += 1;

  return (uint8_t) checksum;
}

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

static char
int_to_char (uint8_t i)
{
  if (i >= 0 && i <= 9)
    return i + 48;
  else if (i >= 10 && i <= 15)
    return i + 55;
  else
    return '0';
}

int main (int argc, char *argv[])
{
  char buffer[IHEX_MAX_LINE_LEN + 1];
  uint8_t i;
  ihex16_t ihex;

  while (1)
  {
    if (fgets (buffer, IHEX_MAX_LINE_LEN, stdin) == NULL)
      break;

    /* Check if the line starts with a ':'. */
    if (buffer[0] != ':')
      continue;

    /* Extract the byte count.*/
    ihex.byte_count = 0;
    for (i = 0; i < IHEX_FIELD_BYTE_COUNT_LEN; ++i)
      ihex.byte_count += char_to_int (buffer[IHEX_FIELD_BYTE_COUNT_OFFSET + i]) << 4 * (IHEX_FIELD_BYTE_COUNT_LEN - i - 1);

    /* Extract the address. */
    ihex.address = 0;
    for (i = 0; i < IHEX_FIELD_ADDRESS_LEN; ++i)
      ihex.address += char_to_int (buffer[IHEX_FIELD_ADDRESS_OFFSET + i]) << 4 * (IHEX_FIELD_ADDRESS_LEN - i - 1);
    
    /* Extract the record type. */
    ihex.type = 0;
    for (i = 0; i < IHEX_FIELD_RECORD_TYPE_LEN; ++i)
      ihex.type += char_to_int (buffer[IHEX_FIELD_RECORD_TYPE_OFFSET + i]) << 4 * (IHEX_FIELD_RECORD_TYPE_LEN - i - 1);

    /* Calculate the checksum offset. */
    ihex.checksum_offset = IHEX_FIELD_PAYLOAD_OFFSET + ihex.byte_count * 2;

    /* Only process data and eof records */    
    if (ihex.type != IHEX_REC_TYPE_DATA &&
	ihex.type != IHEX_REC_TYPE_EOF) 
    {
      continue;
    }
	

    /* Process the current record. */
    if (ihex.type == IHEX_REC_TYPE_DATA
	|| ihex.type == IHEX_REC_TYPE_EXT_SEG_ADDR
	|| ihex.type == IHEX_REC_TYPE_EXT_LIN_ADDR)
    {
      switch (ihex.type)
      {
        case IHEX_REC_TYPE_EXT_SEG_ADDR:
        case IHEX_REC_TYPE_EXT_LIN_ADDR:
        {
          /* Divide the data by SCARTS_INSN_SIZE and write back. */
          uint16_t temp = 0;
          for (i = 0; i < (ihex.byte_count * 2); ++i)
            temp += char_to_int (buffer[IHEX_FIELD_PAYLOAD_OFFSET + i]) << 4 * (ihex.byte_count * 2 - i - 1);

          temp /= SCARTS_INSN_SIZE;

          for (i = 0; i < ihex.byte_count * 2; ++i)
          {
            char nibble = int_to_char ((temp >> 4 * (ihex.byte_count * 2 - i - 1)) & 0xF);
            buffer[IHEX_FIELD_PAYLOAD_OFFSET + i] = nibble;
          }

          break;
        }
        default:
          break;
      }

      /* Divide the byte count by SCARTS_INSN_SIZE and write back. */
      //ihex.byte_count /= SCARTS_INSN_SIZE;
      for (i = 0; i < IHEX_FIELD_BYTE_COUNT_LEN; ++i)
      {
        char nibble = int_to_char ((ihex.byte_count >> 4 * (IHEX_FIELD_BYTE_COUNT_LEN - i - 1)) & 0xF);
        buffer[IHEX_FIELD_BYTE_COUNT_OFFSET + i] = nibble;
      }

      /* Divide the address by SCARTS_INSN_SIZE and write back. */
      ihex.address /= SCARTS_INSN_SIZE;
      for (i = 0; i < IHEX_FIELD_ADDRESS_LEN; ++i)
      {
        char nibble = int_to_char ((ihex.address >> 4 * (IHEX_FIELD_ADDRESS_LEN - i - 1)) & 0xF);
        buffer[IHEX_FIELD_ADDRESS_OFFSET + i] = nibble;
      }

      /* Compute the checksum and write back. */
      ihex.checksum = compute_checksum (buffer);
      for (i = 0; i < IHEX_FIELD_CHECKSUM_LEN; ++i)
      {
        char nibble = int_to_char ((ihex.checksum >> 4 * (IHEX_FIELD_CHECKSUM_LEN - i - 1)) & 0xF);
        buffer[ihex.checksum_offset + i] = nibble;
      }
    }

    printf ("%s", buffer);
  }

  return 0;
}

