/*******************************************************************************
*
*   File:        bin2vhd_4x8b.c
*   Description: Converts a 32-bit big endian .bin file into a VHDL description
*                containing 4 initialized 8-bit RAM instances to be used with 
*                the mbLite (ram0 containing the msb's, ram3 the lsb's).
*   Syntax:      bin2vhd_4x8b INFILENAME OUTFILENAME ABITS
*                with ABITS representing the number of address bits 
*                ( equal to ceil(log2(MEMORY DEPTH)) ).
*
*   Author:      Rene van Leuken, edited and extended by Huib
*   Date:        this version, February 2010
*
*   Note:        No checks, e.g. on inputfile being a multiple of 4 bytes
*
********************************************************************************/

#include <stdio.h>
#include <string.h>


unsigned power (unsigned base, unsigned n) {
    unsigned p;

    for( p = 1; n > 0; --n)
        p = p*base;
    return p;
}

void print_help(char * name)
{
    fprintf(stderr, "%s converts a binary file into a VHDL ram file\n", name);
    fprintf(stderr, "Usage: %s INFILE OUTFILE ABITS\n", name);
    fprintf(stderr, "where ABITS (number of address bits) is log2(MEMORY DEPTH)\n");
}


int main(int argc, char *argv[]) {

    FILE *infile, *outfile;
    int c[4], insize;
    unsigned ram_size;
    unsigned i = 0;
    unsigned m = 0;

    if (argc != 4) {
        print_help(argv[0]);
        return(1);
    }

    infile = fopen(argv[1], "rb");
    if (!infile) {
        printf("Cannot open file %s\n", argv[1]);
        return(1);
    }

    outfile = fopen(argv[2], "w");
    if (!outfile) {
        printf("Cannot open file %s\n", argv[2]);
        return(1);
    }

    if (strlen(argv[3]) <= 0) {
        printf("Argument ABITS missing", argv[3]);
        return(1);
    }

    ram_size = power(2, atoi(argv[3])) * 1;
    // determine the size of the input file in bytes
    fseek(infile, 0, SEEK_END);
    insize = ftell(infile);
    rewind(infile);
    if (insize/4 > ram_size) {
        printf("RAM size (%d words) too small (at least %d words needed", 
                                                                ram_size, insize/4);
        return(1);
    }


    fprintf(outfile,"\
--------------------------------------------------------------------------------\n\
--\n\
--    Filename    : dmem4.vhd\n\
--    Entity      : dmem4\n\
--    Input from  : %s\n\
--    Description : Single Port Synchronous Random Access (Instruction) Memory\n\
--                  with 4 write enable ports.\n\
--    Author      : Rene van Leuken, modified by Huib\n\
--    Company     : Delft University of Technology\n\
--\n\
--------------------------------------------------------------------------------\n\
\n\
LIBRARY ieee;\n\
USE ieee.std_logic_1164.ALL;\n\
USE ieee.std_logic_unsigned.ALL;\n\
USE ieee.numeric_std.all;\n\
\n\n\
ENTITY dmem4 IS\n\
    GENERIC (\n\
        WIDTH_g : POSITIVE := 32;\n\
        ABITS_g : POSITIVE := %s\n\
        );\n\
    PORT (\n\
        dat_o : OUT STD_LOGIC_VECTOR (WIDTH_g -1 DOWNTO 0);\n\
        dat_i :  IN STD_LOGIC_VECTOR (WIDTH_g -1 DOWNTO 0);\n\
        adr_i :  IN STD_LOGIC_VECTOR (ABITS_g -1 DOWNTO 0);\n\
        wre_i :  IN STD_LOGIC_VECTOR (3 DOWNTO 0);\n\
        ena_i :  IN STD_LOGIC;\n\
        clk_i :  IN STD_LOGIC\n\
    );\n\
END dmem4;\n\
\n\n\
ARCHITECTURE arch OF dmem4 IS\n\
\n\
  SIGNAL di0, di1, di2, di3 : STD_LOGIC_VECTOR (WIDTH_g/4 -1 DOWNTO 0);\n\
  SIGNAL do0, do1, do2, do3 : STD_LOGIC_VECTOR (WIDTH_g/4 -1 DOWNTO 0);\n\
\n\
  TYPE ram_type IS ARRAY (0 TO 2**ABITS_g -1) OF STD_LOGIC_VECTOR (WIDTH_g/4 -1 DOWNTO 0);\n\
", argv[1], argv[3] );

    for ( m = 0; m < 4; m++ ) {
        infile = freopen(argv[1], "rb", infile);
        i = 0;

        fprintf(outfile,"\
\nSIGNAL ram%d : ram_type := (", m);

    while (i < insize) {
        c[0] = fgetc(infile);
        c[1] = fgetc(infile);
        c[2] = fgetc(infile);
        c[3] = fgetc(infile);
        if ((i % 32) == 0 ) { fprintf(outfile,"\n     "); }
        fprintf(outfile," X\"%.2X", (unsigned char) c[m] & 0x0ff);
        if (i < insize-4) { fprintf(outfile,"\","); }
            else { fprintf(outfile,"\""); }
        i += 4;
    }
        // Fill rest of ram if not full yet
        i = i/4;
        while (i < ram_size) {
            fprintf(outfile,","); 
            if ((i % 8) == 0 ) { fprintf(outfile,"\n     "); }
               fprintf(outfile," X\""); 
            fprintf(outfile,"00");
            fprintf(outfile,"\""); 
            i++;
        }

        fprintf(outfile," );\n");
    }

    fprintf(outfile,"\n\
\n\
    ATTRIBUTE syn_ramstyle : STRING;\n\
    ATTRIBUTE syn_ramstyle OF ram0,ram1,ram2,ram3 : SIGNAL IS \"block_ram\";\n\
\n\
BEGIN\n\
\n\
    dat_o <= do0 & do1 & do2 & do3;\n\
    \n\
    di3 <= dat_i(  WIDTH_g/4 -1 DOWNTO         0);\n\
    di2 <= dat_i(  WIDTH_g/2 -1 DOWNTO   WIDTH_g/4);\n\
    di1 <= dat_i(3*WIDTH_g/4 -1 DOWNTO   WIDTH_g/2);\n\
    di0 <= dat_i(  WIDTH_g   -1 DOWNTO 3*WIDTH_g/4);\n\
\n\
    PROCESS(clk_i)\n\
    BEGIN\n\
        -- wre: 3 downto 0, while di0..di3 in byte reversed format\n\
        IF RISING_EDGE(clk_i) THEN\n\
            IF  ena_i = '1' THEN\n\
                IF wre_i(0) = '1' THEN\n\
                    ram3(TO_INTEGER(UNSIGNED(adr_i))) <= di3;\n\
                END IF;\n\
                IF wre_i(1) = '1' THEN\n\
                    ram2(TO_INTEGER(UNSIGNED(adr_i))) <= di2;\n\
                END IF;\n\
                IF wre_i(2) = '1' THEN\n\
                    ram1(TO_INTEGER(UNSIGNED(adr_i))) <= di1;\n\
                END IF;\n\
                IF wre_i(3) = '1' THEN\n\
                    ram0(TO_INTEGER(UNSIGNED(adr_i))) <= di0;\n\
                END IF;\n\
                do3 <= ram3(TO_INTEGER(UNSIGNED(adr_i)));\n\
                do2 <= ram2(TO_INTEGER(UNSIGNED(adr_i)));\n\
                do1 <= ram1(TO_INTEGER(UNSIGNED(adr_i)));\n\
                do0 <= ram0(TO_INTEGER(UNSIGNED(adr_i)));\n\
            END IF;\n\
        END IF;\n\
    END PROCESS;\n\
\n\
END ARCHITECTURE arch;\n\
\n\
-- [EOF]\n\
");

  fclose(infile);
  fclose(outfile);

  return 0;

}
