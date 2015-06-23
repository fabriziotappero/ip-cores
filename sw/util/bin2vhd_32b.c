/*******************************************************************************
*
*   File:        bin2vhd_32b.c
*   Description: Converts a 32-bit big endian .bin file into a VHDL description
*                containing an initialized 32-bit RAM instance to be used with 
*                the mbLite.
*   Syntax:      bin2vhd_32b INFILENAME OUTFILENAME ABITS
*                with ABITS representing the number of address bits 
*                ( equal to ceil(log2(MEMORY DEPTH)) ).
* 
*   Author:      Rene van Leuken, edited and extended by Huib
*   Date:        this version, February 2010
*   Modified:    Register after DOUT removed and inserted in 'decode.vhd' (Huib)
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
    fprintf(stderr, "%s converts a binary file into a VHDL rom file\n", name);
    fprintf(stderr, "Usage: %s INFILE OUTFILE ABITS\n", name);
    fprintf(stderr, "where ABITS (number of address bits) is log2(MEMORY DEPTH)\n");
}


int main (int argc, char *argv[]) {

    FILE *infile, *outfile;
    int      c, insize;
    unsigned ram_size;
    unsigned i = 0;

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

    ram_size = power(2, atoi(argv[3])) * 4;     // 32 bits data bus!

    // determine the size of the input file in bytes
    fseek(infile, 0, SEEK_END);
    insize = ftell(infile);
    rewind(infile);
    if (insize > ram_size) {
        printf("RAM size (%d words) too small (at least %d words needed", 
                                                            ram_size/4, insize/4);
        return(1);
    }

    fprintf(outfile,"\
--------------------------------------------------------------------------------\n\
--\n\
--    Filename    : imem.vhd\n\
--    Entity      : imem\n\
--    Input from  : %s\n\
--    Description : Single Port Synchronous Random Access (Instruction) Memory\n\
--                  for the mbLite processor.\n\
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
ENTITY imem IS\n\
    GENERIC (\n\
        WIDTH_g : POSITIVE := 32;\n\
        ABITS_g : POSITIVE := %s\n\
        );\n\
    PORT (\n\
        dat_o : OUT STD_LOGIC_VECTOR (WIDTH_g -1 DOWNTO 0);\n\
        dat_i :  IN STD_LOGIC_VECTOR (WIDTH_g -1 DOWNTO 0);\n\
        adr_i :  IN STD_LOGIC_VECTOR (ABITS_g -1 DOWNTO 0);\n\
        wre_i :  IN STD_LOGIC;\n\
        ena_i :  IN STD_LOGIC;\n\
        clk_i :  IN STD_LOGIC\n\
        );\n\
END imem;\n\
\n\n\
ARCHITECTURE arch OF imem IS\n\
    TYPE ram_type IS array (0 TO 2**ABITS_g -1) OF STD_LOGIC_VECTOR (WIDTH_g -1 DOWNTO 0);\n\
    SIGNAL ram : ram_type := (",     argv[1], argv[3] );

    while (i < insize) {
        c = fgetc(infile);
        if ((i % 32) == 0 ) { fprintf(outfile,"\n     "); }
        if ((i %  4) == 0 ) { fprintf(outfile," X\""); }
        fprintf(outfile,"%.2X", (unsigned char) c & 0x0ff);
        if ((i %  4) == 3) {
            if (i < insize-4) { fprintf(outfile,"\","); }
            else { fprintf(outfile,"\""); }
        }
        i++;
    }
    
    // Fill rest of ram if not full yet
    while (i < ram_size) {
        if ((i %  4) == 0 ) { fprintf(outfile,","); }
        if ((i % 32) == 0 ) { fprintf(outfile,"\n     "); }
        if ((i %  4) == 0 ) { fprintf(outfile," X\""); }
        fprintf(outfile,"00");
        if ((i % 4) == 3 ) { fprintf(outfile,"\""); }
        i++;
    }

    fprintf(outfile," );\n\
\n\
    ATTRIBUTE syn_ramstyle : STRING;\n\
    ATTRIBUTE syn_ramstyle OF ram : SIGNAL IS \"block_ram\";\n\
\n\
BEGIN\n\
\n\
    -- for future use (enable programming ...)\n\
    PROCESS(clk_i)\n\
    BEGIN\n\
        IF RISING_EDGE(clk_i) THEN\n\
            IF ena_i = '1' THEN\n\
                IF wre_i = '1' THEN\n\
                    ram(TO_INTEGER(UNSIGNED(adr_i))) <= dat_i;\n\
                END IF;\n\
                dat_o <= ram(TO_INTEGER(UNSIGNED(adr_i)));\n\
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

