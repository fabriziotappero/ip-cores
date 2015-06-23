#include "assert.h"
#include "stdio.h"
#include "stdint.h"
#include "string.h"

uint8_t buffer[0x10000];    // 64 k is max. for Intel hex.
uint8_t slice [0x10000];    // 16 k is max. for Xilinx bram

//-----------------------------------------------------------------------------
//
// get a byte (from cp pointing into Intel hex file).
//
uint32_t
get_byte(const char *  cp)
{
uint32_t value;
const char cc[3] = { cp[0], cp[1], 0 };
const int cnt = sscanf(cc, "%X", &value);
   assert(cnt == 1);
   return value;
}
//-----------------------------------------------------------------------------
//
// read an Intel hex file into buffer
void
read_file(FILE * in)
{
   memset(buffer, 0xFF, sizeof(buffer));
char line[200];
   for (;;)
       {
         const char * s = fgets(line, sizeof(line) - 2, in);
         if (s == 0)   return;
         assert(*s++ == ':');
         const uint32_t len     = get_byte(s);
         const uint32_t ah      = get_byte(s + 2);
         const uint32_t al      = get_byte(s + 4);
         const uint32_t rectype = get_byte(s + 6);
         const char * d = s + 8;
         const uint32_t addr = ah << 8 | al;

         uint32_t csum = len + ah + al + rectype;
         assert((addr + len) <= 0x10000);
         for (uint32_t l = 0; l < len; ++l)
             {
               const uint32_t byte = get_byte(d);
               d += 2;
               buffer[addr + l] = byte;
               csum += byte;
             }

         csum = 0xFF & -csum;
         const uint32_t sum = get_byte(d);
         assert(sum == csum);
       }
}
//-----------------------------------------------------------------------------
//
// copy a slice from buffer into slice.
// buffer is organized as 32-bit x items.
// slice is organized as bits x items.
//
void copy_slice(uint32_t slice_num, uint32_t port_bits, uint32_t mem_bits)
{
   assert(mem_bits == 0x1000 || mem_bits == 0x4000);

const uint32_t items = mem_bits/port_bits;
const uint32_t mask = (1 << port_bits) - 1;
const uint8_t * src = buffer;

    memset(slice, 0, sizeof(slice));

    for (uint32_t i = 0; i < items; ++i)
        {
          // read one 32-bit value;
          const uint32_t v0 = *src++;
          const uint32_t v1 = *src++;
          const uint32_t v2 = *src++;
          const uint32_t v3 = *src++;
          const uint32_t v = (v3 << 24 |
                              v2 << 16 |
                              v1 <<  8 |
                              v0       ) >> (slice_num*port_bits) & mask;

          if (port_bits == 16)
             {
               assert(v < 0x10000);
               slice[2*i]     = v;
               slice[2*i + 1] = v >> 8;
             }
          else if (port_bits == 8)
             {
               assert(v < 0x100);
               slice[i] = v;
             }
          else if (port_bits == 4)
             {
               assert(v < 0x10);
               slice[i >> 1] |= v << (4*(i & 1));
             }
          else if (port_bits == 2)
             {
               assert(v < 0x04);
               slice[i >> 2] |= v << (2*(i & 3));
             }
          else if (port_bits == 1)
             {
               assert(v < 0x02);
               slice[i >> 3] |= v << ((i & 7));
             }
          else assert(0 && "Bad aspect ratio.");
        }
}
//-----------------------------------------------------------------------------
//
// write one initialization vector
//
void
write_vector(FILE * out, uint32_t mem, uint32_t vec, const uint8_t * data)
{
   fprintf(out, "constant p%u_%2.2X : BIT_VECTOR := X\"", mem, vec);
   for (int32_t d = 31; d >= 0; --d)
       fprintf(out, "%2.2X", data[d]);

   fprintf(out, "\";\r\n");
}
//-----------------------------------------------------------------------------
//
// write one memory
//
void
write_mem(FILE * out, uint32_t mem, uint32_t bytes)
{
   fprintf(out, "-- content of p_%u --------------------------------------"
                "--------------------------------------------\r\n", mem);

const uint8_t * src = slice;
   for (uint32_t v = 0; v < bytes/32; ++v)
       write_vector(out, mem, v, src + 32*v);

   fprintf(out, "\r\n");
}
//-----------------------------------------------------------------------------
//
// write the entire memory_contents file.
//
void
write_file(FILE * out, uint32_t bits)
{
   fprintf(out,
"\r\n"
"library IEEE;\r\n"
"use IEEE.STD_LOGIC_1164.all;\r\n"
"\r\n"
"package prog_mem_content is\r\n"
"\r\n");

const uint32_t mems = 16/bits;

   for (uint32_t m = 0; m < 2*mems; ++m)
       {
         copy_slice(m, bits, 0x1000);
         write_mem(out, m, 0x200);
       }

   fprintf(out,
"end prog_mem_content;\r\n"
"\r\n");
}
//-----------------------------------------------------------------------------
int
main(int argc, char * argv[])
{
uint32_t bits = 4;
const char * prog = *argv++;   --argc;

   if      (argc && !strcmp(*argv, "-1"))    { bits =  1;   ++argv;   --argc; }
   else if (argc && !strcmp(*argv, "-2"))    { bits =  2;   ++argv;   --argc; }
   else if (argc && !strcmp(*argv, "-4"))    { bits =  4;   ++argv;   --argc; }
   else if (argc && !strcmp(*argv, "-8"))    { bits =  8;   ++argv;   --argc; }
   else if (argc && !strcmp(*argv, "-16"))   { bits = 16;   ++argv;   --argc; }

const char * hex_file = 0;
const char * vhdl_file = 0;

   if (argc)   { hex_file  = *argv++;   --argc; }
   if (argc)   { vhdl_file = *argv++;   --argc; }
   assert(argc == 0);

FILE * in = stdin;
   if (hex_file)   in = fopen(hex_file, "r");
   assert(in);
   read_file(in);
   fclose(in);

FILE * out = stdout;
   if (vhdl_file)   out = fopen(vhdl_file, "w");
   write_file(out, bits);
   assert(out);
}
//-----------------------------------------------------------------------------
