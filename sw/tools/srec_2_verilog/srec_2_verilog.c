/* Verilog ROM Generator/Programer  Rev B March 12 1996  Bob Hayes            */
/* Started work on S-Record Writer Nov. 6, 1996 -- working except parity      */

/* Rev 1.1 Sept. 11, 2009 - Bob Hayes - Update to create output file name     */
/*   from input file name by changing extension to .v                         */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE * open_read_file (char *);
FILE * open_write_file (char *);
int Get_ROM_Byte (FILE *, int *);
void Make_Ref_Mem (FILE *, FILE *);


/* ************************************************************************** */

/* ************************************************************************** */
int main(int argc, char *argv[])
{
    int i, j, k = 0;
    char c;
    FILE *file1, *file2;
    file1 = NULL;
    file2 = NULL;

    printf("\nConvert S-record to Verilog memory file\n");
    
    if (argc != 2)
    {
      printf("Usage: %s filename\n", argv[0]);
      exit(1);
    }

    file1 = open_read_file(argv[1]);
    file2 = open_write_file(argv[1]); 
    Make_Ref_Mem(file1, file2);
    fclose(file1);
    fclose(file2);
    
    printf("\n All done now!\n");
    return 0;
}


/* ************************************************************************** */
/* 45678901234567890123456789012345678901234567890123456789012345678901234567 */
/* ************************************************************************** */

/* ************************************************************************** */
int Get_ROM_Byte (FILE *f1, int *S_Addr)
{
    static int Addr = 0, Count = 0, Sum = 0, Flag = 0;
    static int Max_Count = 0, Parity;
    static unsigned char c, *ch;
    static char EOL_str[80];
    static int i, j, k, OK, Byte;
    static long int Line_cnt = 0, Byte_cnt = 0;

    if (Flag == 0 )
    {
        Flag = 1;
        /* This code is to read first line of miscellaneous data */
        OK = fscanf(f1, "%c", &c);           /* Read the "S"         */
        OK = fscanf(f1, "%1x", &i);          /* Read the type number */
        OK = fscanf(f1, "%2x", &Max_Count);  /* Read the byte count  */
        if ( c != 'S' )
        {
            printf("Error in S-Records, No -S-, S = %c, i = %i, Max = %i\n", c, i, Max_Count);
            printf("Line Number = %i, Byte Number = %i\n", Line_cnt, Byte_cnt);
        }
        if ( i != 0 )
           rewind(f1);  /* Back-up if there is no comment line */
        else
        {
            printf("First S-Record info line is:\n");
            for (j = 1; j <= Max_Count-1; ++j)
              {
                 fscanf(f1, "%2x", &k);
                 if (( k >= ' ') && (k <= '~'))
                    printf("%c",k);
              }
            printf("\n\n");
            fgets(EOL_str, 10, f1); /* pick-up parity and other junk */
        }
    }

    if ( Count == 0 )
    {
        Sum = 0;
        OK = fscanf(f1, "%c", &c);           /* Read the "S"         */
        OK = fscanf(f1, "%1x", &i);          /* Read the type number */
        OK = fscanf(f1, "%2x", &Max_Count);  /* Read the byte count  */
        if ( c != 'S' )
        {
            printf("Error in S-Records, No -S-, S = %c, i = %i, Max = %i\n", c, i, Max_Count);
            printf("Line Number = %i, Byte Number = %i\n", Line_cnt, Byte_cnt);
        }
        switch (i)
        {
             case 1:
             case 9:
                 Max_Count = Max_Count - 2;
                 OK = fscanf(f1, "%4x", &Addr);
                 break;
             case 2:
             case 8:
                 Max_Count = Max_Count - 3;
                 OK = fscanf(f1, "%6x", &Addr);
                 break;
             case 3:
             case 7:
                 Max_Count = Max_Count - 4;
                 OK = fscanf(f1, "%8x", &Addr);
                 break;
             default :
                 printf("Error in S-Record file! Unrecognized TYPE Number\n");
                 break;
        }
    }

    if ( Max_Count > 1)               /* Make sure there is at least one byte of data */
      {
          OK = fscanf(f1, "%2x", &Byte); /* Read a Byte of Data        */
          Sum = Sum + Byte;              /* Increment the parity count */
          ++Count;
          ++Byte_cnt;
      }

    if ( Count == (Max_Count - 1))    /* Do the parity check        */
    {
        Count = 0;
        OK = fscanf(f1, "%2x", &Parity);  /* Read the parity from the S-Record File */
        Sum = 0xFF & ~Sum;
/*        printf("Line = %d, Sum = %2x, Parity = %2x\n", Line_cnt, Sum, Parity); */
        ++Line_cnt;

        c = ' ';
        while (( c != 'S') && ((k = feof(f1)) == 0))
          OK = fscanf(f1, "%c", &c);        /* Eat up end of line */

        if (( k = feof(f1)) != 0)
           printf("found EOF in S-Record file\n   %i Lines Processed\n", Line_cnt);
        else
           ungetc(c, f1);
    }

/*    printf("Read Byte = %x, Count = %i, Max_Count = %i \n", Byte, Count, Max_Count); */

    *S_Addr = Addr;
    return Byte;
}


/* *************************************************************************************** */
/* Convert S-record to Verilog memory file *********************************************** */

void Make_Ref_Mem (FILE *f1, FILE *f2)
{
 
    int Byte, S_Addr, S_Addr_Old;
    int i, j, k;

    i = 0;
    S_Addr_Old = 1;
    printf("// Making Verilog Reference Memory File \n");

            while (( i = feof(f1)) == 0)
            {
                Byte = Get_ROM_Byte(f1, &S_Addr);
                if ( S_Addr != S_Addr_Old )
                {
                    fprintf(f2, "\n@%4.4X", S_Addr );
                    S_Addr_Old = S_Addr;
                }
                fprintf(f2, " %2.2X", Byte);
            }

    printf("Conversion All Done Now\n");
    return;
}

/* ************************************************************************** */
FILE * open_read_file (char file_name[80])
{
    char c;
    FILE *file_num;

    file_num = NULL;
    printf("Input File Name => %s\n", file_name);
    file_num = fopen(file_name, "rb");
    if (file_num == NULL)
    {
       printf("\nError in opening read file!!\n");
    }
    return file_num;
}

/* ************************************************************************** */
FILE * open_write_file (char file_name[80])
{
    FILE *file_num;
    char c, out_file_name[80];
    int i, j, k;

    i = strlen(file_name);
    strcpy(out_file_name, file_name);
    while (out_file_name[i] != '.')
    {
      out_file_name[i] = 0;
      i--;
    }
    strcat(out_file_name, "v");
    
    file_num = NULL;
    printf("Output File Name => %s\n", out_file_name);
    file_num = fopen(out_file_name, "w");
    if (file_num == NULL)
      {
         printf("\nError in opening write file!!\n");
      }
    printf("\n");
    return file_num;
}

