
#include <stdio.h>
#include <assert.h>

char data[0x10000];

//-----------------------------------------------------------------------------
void write_mem_1(FILE * out, FILE * ucf, int bank, int bit, const char * data)
{
   fprintf(out, "-- content of m_%d_%d\r\n", bank, bit);
   for (int col = 0; col < 16; col++)
       {
	fprintf(out, "constant m_%d_%d_%X : BIT_VECTOR := X\"", bank, bit, col);
	fprintf(ucf, "INST \"cp_eng_memo_m_%d_%d\" INIT_0%X = ",
		bank, bit, col);

        for (const char * end = data + 256*(col + 1); end > data + 256*col;)
	   {
             int b3 = *--end;   b3 >>= bit;   b3 &= 1;
             int b2 = *--end;   b2 >>= bit;   b2 &= 1;
             int b1 = *--end;   b1 >>= bit;   b1 &= 1;
             int b0 = *--end;   b0 >>= bit;   b0 &= 1;
	     fprintf(out, "%1.1X", (b3 << 3) | (b2 << 2) | (b1 << 1) | b0);
	     fprintf(ucf, "%1.1X", (b3 << 3) | (b2 << 2) | (b1 << 1) | b0);
	   }
		
         fprintf(out, "\";\r\n");
         fprintf(ucf, ";\r\n");

       }
   fprintf(out, "\r\n");
   fprintf(ucf, "\r\n");

/**********
   fprintf(out,
"\tm_%d_%d : RAMB4_S1_S1\r\n"
"\t-- synopsys translate_off\r\n"
"\tGENERIC MAP(\r\n", bank, bit);

   for (int col = 0; col < 4; col++)
       {
         fprintf(out, "\t");
         for (int row = 0; row < 4; row++)
             {
               const int pos = row + 4*col;
               fprintf(out, "INIT_0%X => m_%d_%d_%X", pos, bank, bit, pos);
               if (pos < 15)   fprintf(out, ", ");
	       else            fprintf(out, ")");
             }
         fprintf(out, "\r\n");
       }
   fprintf(out, "\t-- synopsys translate_on\r\n\r\n");
**********/
}
//-----------------------------------------------------------------------------
void write_bank_1(FILE * out, FILE * ucf, int bank, const char * data)
{
   for (int i = 0; i < 8; i++)   write_mem_1(out, ucf, bank, i, data);
}
//-----------------------------------------------------------------------------
void write_header(FILE * out, FILE * ucf)
{
   fprintf(out,
"library IEEE;\r\n"
"use IEEE.STD_LOGIC_1164.all;\r\n"
"\r\n"
"package mem_content is\r\n"
"\r\n"
	  );

   fprintf(ucf,
"NET \"clk40\" TNM_NET = \"clk40\";\r\n"
"TIMESPEC \"TS_clk40\" = PERIOD \"clk40\" 25 ns HIGH 50 %%;\r\n"
// "NET \"clk20\" TNM_NET = \"clk20\";\r\n"
// "TIMESPEC \"TS_clk20\" = PERIOD \"clk20\" \"TS_clk40\" * 2;\r\n"
"\r\n"
"NET \"clk40\"        LOC = P92;\r\n"
"NET \"clk_out\"      LOC = P84;\r\n"

"NET \"xm_adr<14>\"   LOC = P66;\r\n"
"NET \"xm_adr<12>\"   LOC = P64;\r\n"
"NET \"xm_we_n\"      LOC = P63;\r\n"
"NET \"xm_adr<7>\"    LOC = P99;\r\n"
"NET \"xm_adr<13>\"   LOC = P97;\r\n"
"NET \"xm_adr<6>\"    LOC = P96;\r\n"
"NET \"xm_adr<8>\"    LOC = P95;\r\n"
"NET \"xm_adr<5>\"    LOC = P94;\r\n"
"NET \"xm_adr<9>\"    LOC = P118;\r\n"
"NET \"xm_adr<4>\"    LOC = P117;\r\n"
"NET \"xm_adr<11>\"   LOC = P115;\r\n"
"NET \"xm_adr<3>\"    LOC = P114;\r\n"
"NET \"xm_oe_n\"      LOC = P113;\r\n"
"NET \"xm_adr<2>\"    LOC = P111;\r\n"
"NET \"xm_adr<10>\"   LOC = P110;\r\n"
"NET \"xm_adr<1>\"    LOC = P109;\r\n"
"NET \"xm_ce_n\"      LOC = P108;\r\n"
"NET \"xm_adr<0>\"    LOC = P149;\r\n"
"NET \"xm_dio<7>\"    LOC = P147;\r\n"
"NET \"xm_dio<0>\"    LOC = P144;\r\n"
"NET \"xm_dio<6>\"    LOC = P142;\r\n"
"NET \"xm_dio<1>\"    LOC = P141;\r\n"
"NET \"xm_dio<5>\"    LOC = P140;\r\n"
"NET \"xm_dio<2>\"    LOC = P139;\r\n"
"NET \"xm_dio<4>\"    LOC = P133;\r\n"
"NET \"xm_dio<3>\"    LOC = P131;\r\n"

"NET \"deactivate_n\" LOC = P220;\r\n"
"NET \"enable_n\"     LOC = P218;\r\n"
"NET \"led<0>\"       LOC = P27;\r\n"
"NET \"led<1>\"       LOC = P28;\r\n"
"NET \"led<2>\"       LOC = P3;\r\n"
"NET \"led<3>\"       LOC = P4;\r\n"
"NET \"led<4>\"       LOC = P5;\r\n"
"NET \"led<5>\"       LOC = P6;\r\n"
"NET \"led<6>\"       LOC = P7;\r\n"
"NET \"led<7>\"       LOC = P9;\r\n"
"NET \"ser_in\"       LOC = P216;\r\n"
"NET \"ser_out\"      LOC = P217;\r\n"
"NET \"switch<0>\"    LOC = P194;\r\n"
"NET \"switch<1>\"    LOC = P195;\r\n"
"NET \"switch<2>\"    LOC = P199;\r\n"
"NET \"switch<3>\"    LOC = P200;\r\n"
"NET \"switch<4>\"    LOC = P201;\r\n"
"NET \"switch<5>\"    LOC = P202;\r\n"
"NET \"switch<6>\"    LOC = P203;\r\n"
"NET \"switch<7>\"    LOC = P205;\r\n"
"NET \"switch<8>\"    LOC = P206;\r\n"
"NET \"switch<9>\"    LOC = P208;\r\n"
"NET \"temp_ce\"      LOC = P160;\r\n"
"NET \"temp_sclk\"    LOC = P159;\r\n"
"NET \"temp_spi\"     LOC = P161;\r\n"
"NET \"temp_spo\"     LOC = P162;\r\n"
"NET \"seg1<0>\"      LOC = P231; \r\n"
"NET \"seg1<1>\"      LOC = P230; \r\n"
"NET \"seg1<2>\"      LOC = P229; \r\n"
"NET \"seg1<3>\"      LOC = P228; \r\n"
"NET \"seg1<4>\"      LOC = P224; \r\n"
"NET \"seg1<5>\"      LOC = P223; \r\n"
"NET \"seg1<6>\"      LOC = P222; \r\n"
"NET \"seg1<7>\"      LOC = P221; \r\n"
"NET \"seg2<0>\"      LOC = P188; \r\n"
"NET \"seg2<1>\"      LOC = P187; \r\n"
"NET \"seg2<2>\"      LOC = P186; \r\n"
"NET \"seg2<3>\"      LOC = P238; \r\n"
"NET \"seg2<4>\"      LOC = P237; \r\n"
"NET \"seg2<5>\"      LOC = P236; \r\n"
"NET \"seg2<6>\"      LOC = P235; \r\n"
"NET \"seg2<7>\"      LOC = P234;\r\n"
"\r\n"
	  );
}
//-----------------------------------------------------------------------------
void write_tail(FILE * out)
{
   fprintf(out,
"\r\n"
"end mem_content;\r\n"
"\r\n"
"package body mem_content is\r\n"
"\r\n"
"end mem_content;\r\n"
"\r\n"
	  );
}
//-----------------------------------------------------------------------------
int main(int argc, char *argv[])
{
   assert(argc == 2 && "No (binary) input file specified");

   for (int i = 0; i < sizeof(data); i++)   data[i] = 0;

   FILE * in = fopen(argv[1], "rb");
   if (in == 0)
      {
        fprintf(stderr, "Can't open input file %s\n", argv[1]);
        return 1;
      }

int bytes = fread(data, 1, sizeof(data), in);
   fclose(in);
   
   printf("Read %d bytes\n", bytes);

   FILE * out = fopen("../vhdl/mem_content.vhd", "w");
   assert(out);

   FILE * ucf = fopen("../vhdl/board_cpu.ucf", "w");
   assert(ucf);

   write_header(out, ucf);
   write_bank_1(out, ucf, 0, data);
   write_bank_1(out, ucf, 1, data + 0x1000);
   write_tail(out);
   
   fclose(out);
   fclose(ucf);
   return 0;
}
//-----------------------------------------------------------------------------
