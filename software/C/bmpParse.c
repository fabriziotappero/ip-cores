//----------------------------------------------------------------------------
// Copyright (C) 2007 Jonathon W. Donaldson
//                    jwdonal a t opencores DOT org
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//
//----------------------------------------------------------------------------
//
//  $Id: bmpParse.c,v 1.1 2007-05-25 11:20:18 jwdonal Exp $
//
//  Description: This program parses a BMP file and writes the
//  necessary image data to a Xilinx COE file.  The COE file
//  can be used to initialize any instantiated BRAM memory!
//
//  There is a significant difference between using binary vs hex COE files.
//  Be sure that you use the radix that will allow you to match the exact data
//  width (i.e. bits/color) of the LCD being used.
//
//  For instance using hex radix in the COE files for the lq057q3dc02 (6
//  bits/color) will result in 38 BRAMs being used to store the data since
//  the hex radix would result in 8 bits of data output to the COE file instead
//  of 6 bits.  There would be 2 extra unused bits of data storage required in
//  the BRAMs.
//
//  If we use binary radix instead we can match the data width of the LCD
//  exactly.  Using binary radix we use only 29 BRAMs.  For the Virtex-II Pro
//  this is a difference of 29*3/136 vs. 38*3/136.  Resulting in a 64% vs. 84%
//  BRAM usage.
//
//  The time required to generate the BRAM source files is also much less when
//  using binary instead of hex for the lq057q3dc02.  Generating the source files
//  with binary radix COE files only takes 5min 45sec per color while a hex
//  radix COE file requires approx 7 minutes.  This is mainly due to Java's
//  ridiculously slow I/O operations.
//
//
//---------------------------------------------------------------------
#include <stdio.h>
#include <stdlib.h>

#define NUM_COE_FILES 3
#define R_FILE_LOC 0
#define G_FILE_LOC 1
#define B_FILE_LOC 2
#define ARGV_BMP_NUM 1
#define ARGV_COE_R_NUM 2
#define ARGV_COE_G_NUM 3
#define ARGV_COE_B_NUM 4
#define ARGV_HDR_NUM 5
#define ARGV_DBG_NUM 6
#define ARGV_RAD_NUM 7
#define R_BYTE_LOC 2
#define G_BYTE_LOC 1
#define B_BYTE_LOC 0
#define BMP_REQUIRED_WIDTH_MULTIPLE 4
#define BMP_BYTES_PER_PIXEL 3
#define LCD_BIT_DEPTH 18
#define LCD_NUM_COLORS 3
#define RADIX_BIN 2
#define RADIX_HEX 16

//Type definitions
typedef unsigned char BYTE;   /* 8 Bit Value      ( 0x00 - 0xFF )  */
typedef unsigned short WORD;  /* 16 Bit Value   ( 0x0000 - 0xFFFF )  */
typedef unsigned long DWORD;  /* 32 Bit Value ( 0x00000000 - 0xFFFFFFFF ) */

//File Header (bf = "bitmap file")
//Information about the file itself, not the image
typedef struct tagBITMAPFILEHDR {

  WORD  bfType;  //specifies the file type
  DWORD bfSize;  //specifies the size in bytes of the bitmap file
  WORD  bfRes1;  //reserved; must be 0
  WORD  bfRes2;  //reserved; must be 0
  DWORD bfOffset;  //offset (in bytes) from the bitmapfileheader to image data

} BITMAPFILEHDR;

//Info Header (bi = "bitmap info")
//Information about the actual image
typedef struct tagBITMAPINFOHDR {

  DWORD biSize;            //specifies the number of bytes required by the struct
  DWORD biWidth;           //specifies width in pixels
  DWORD biHeight;          //species height in pixels
  WORD  biPlanes;          //specifies the number of color planes, must be 1
  WORD  biBitCnt;          //specifies the number of bit per pixel
  DWORD biComp;            //specifies the type of compression
  DWORD biImgSizeWithPad;  //stored image size in bytes (including row 'pad' bytes)
  DWORD biXPelsPerMtr;     //number of pixels per meter in x axis
  DWORD biYPelsPerMtr;     //number of pixels per meter in y axis
  DWORD biClrUsed;         //number of colors used by the bitmap.  If zero, 2^biBitCount
  DWORD biClrImp;          //number of colors that are important. If zero, all are important

} BITMAPINFOHDR;

//This struct simply contains values that
//were calculated based on the information
//provided in the info header.  NOTE! None
//of these values are actually in the image file!
typedef struct tagBITMAPINFOHDR_CALC {

  DWORD biWidthInBytes;
  DWORD biWidthInBytesMod4;
  DWORD biWidthInBytesPadded;

} BITMAPINFOHDR_CALC;

//OutBinary
//Want to make equal to size of data of LCD.  Do you have a way of knowing this?
void OutBinary( FILE *file, BYTE *bitmapImageData ) {

  BYTE mask = 0x80;
  char bin_str[LCD_BIT_DEPTH/LCD_NUM_COLORS + 1]; // +1 for NULL byte! Compiler will add a null byte for us
  int i;

  for( i = 0; i < LCD_BIT_DEPTH/LCD_NUM_COLORS; i++ ) {

    bin_str[i] = ((*bitmapImageData & mask) == 0) ? '0' : '1';
    mask >>= 1;

  }

  bin_str[6] = '\0';  //can't forgot to null-terminate our string!

  //printf( "\nFinal hex to binary conversion for the given byte was: 0x%x", bin_str[6] );
  //printf( "\nFinal hex to binary conversion for the given byte was: %s", bin_str );
  fprintf( file, "\n%s,", bin_str );

  return;

}//end OutBinary

// The Parser
BYTE* ParseBitmapFile( char* filename, BITMAPFILEHDR *bitmapFileHdr, BITMAPINFOHDR *bitmapInfoHdr, BITMAPINFOHDR_CALC *bitmapInfoHdr_Calc ) {

  //CREATE necessary variables
  FILE *filePtr; //file pointer
  BYTE *bitmapImageData;  //pointer to stored image data


  //OPEN bitmap image file and VERIFY
  //Note that the `b' option for fopen has no effect on POSIX compliant systems
  //and the `b' option may cause non-POSIX systems to read the file in different
  //manners - RTFM!
  if ( !(filePtr = fopen( filename, "r" )) ) {
    
    fprintf( stderr, "File Not Found!\n" ); //print exception to error
    return NULL;

  }


  //PARSE the bitmap fileHeader - must be done this way instead of with one fread
  //operation because a single fread will skip the 3rd and 4th bytes for some reason ???
  fread( &(*bitmapFileHdr).bfType,   sizeof((*bitmapFileHdr).bfType),   1, filePtr );
  fread( &(*bitmapFileHdr).bfSize,   sizeof((*bitmapFileHdr).bfSize),   1, filePtr );
  fread( &(*bitmapFileHdr).bfRes1,   sizeof((*bitmapFileHdr).bfRes1),   1, filePtr );	  
  fread( &(*bitmapFileHdr).bfRes2,   sizeof((*bitmapFileHdr).bfRes2),   1, filePtr );
  fread( &(*bitmapFileHdr).bfOffset, sizeof((*bitmapFileHdr).bfOffset), 1, filePtr );

  //VERIFY that this is a bmp file by checking bitmap id
  if( ((*bitmapFileHdr).bfType != 0x4D42) && 
      ((*bitmapFileHdr).bfRes1 != 0x0000) &&
      ((*bitmapFileHdr).bfRes2 != 0x0000) ) {
    
    fprintf( stderr, "INVALID File Type or Reserved Values!\n" );    //print exception to error
    fclose( filePtr ); //close file
    return NULL;

  }
  

  // PARSE the InfoHeader
  if ( fread( bitmapInfoHdr, sizeof( BITMAPINFOHDR ), 1, filePtr ) != 1 ) {

    fclose( filePtr ); 
    printf( "\nRead bitmap info header failed\n" );
    return NULL;
  }
  

  //VERIFY bitmap has not already undergone some type of compression
  if( (*bitmapInfoHdr).biComp != 0x00000000 ) {

    fprintf( stderr, "File is compressed!\n" ); //print exception to error
    fclose( filePtr ); //close file
    return NULL;

  }

  
  //Get width of image (in bytes)
  (*bitmapInfoHdr_Calc).biWidthInBytes = (*bitmapInfoHdr).biWidth * BMP_BYTES_PER_PIXEL;

  //Get width of image (in bytes) with padding bytes
  (*bitmapInfoHdr_Calc).biWidthInBytesMod4 = (*bitmapInfoHdr_Calc).biWidthInBytes % BMP_REQUIRED_WIDTH_MULTIPLE;

  //If the width of the image is already a multiple of 4 then no pad bytes would have been added by the program that created the bitmap image and we simply set the pad value equal to the non-pad value.
  if( !(*bitmapInfoHdr_Calc).biWidthInBytesMod4 ) {

    (*bitmapInfoHdr_Calc).biWidthInBytesPadded = (*bitmapInfoHdr_Calc).biWidthInBytes;

  } else { //if the image width is not a multiple of 4, then calculate the number of pad bytes that were added

    (*bitmapInfoHdr_Calc).biWidthInBytesPadded = (*bitmapInfoHdr_Calc).biWidthInBytes + (BMP_REQUIRED_WIDTH_MULTIPLE - (*bitmapInfoHdr_Calc).biWidthInBytesMod4 );

  }


  //If the bitmap's info header states that the image has 0 size then we need to calculate the size manually so we know how much to allocate in memory for the image data!  This phenomena is likely due to the image being originally created as some other image file format and then later converted to BMP.  The parser will now calculate the expected value below.
  if( (*bitmapInfoHdr).biImgSizeWithPad == 0 ) {

    (*bitmapInfoHdr).biImgSizeWithPad = (*bitmapInfoHdr_Calc).biWidthInBytesPadded * (*bitmapInfoHdr).biHeight;

  }


  //MOVE file point to the begging of bitmap data
  //SEEK_SET = 0 (default) - seek from beginning of file
  fseek( filePtr, (*bitmapFileHdr).bfOffset, SEEK_SET );


  //ALLOCATE enough memory for the bitmap image data
  //"malloc" returns pointer to the space requested
  bitmapImageData = (BYTE*)malloc( (*bitmapInfoHdr).biImgSizeWithPad );
  //Could also use:
  //bitmapImageData = (BYTE*)malloc( bitmapInfoHdr -> biImgSizeWithPad );
  

  //VERIFY memory allocation
  if( !bitmapImageData ) { //(if NULL)

    fprintf( stderr, "Bitmap Image Data Memory Allocation Failed!\n" ); //print exception to std error
    free( bitmapImageData );
    fclose( filePtr );
    return NULL;

  }


  //PARSE the bitmap image data
  fread( bitmapImageData, bitmapInfoHdr -> biImgSizeWithPad, 1, filePtr );
  

  //VERIFY bitmap image data was read
  if( bitmapImageData == NULL ) {
    
    fprintf( stderr, "Bitmap image data was not read!\n" ); //print exception to std error
    fclose(filePtr);
    return NULL;

  }


  //CLOSE file and return bitmap image reference
  fclose( filePtr );
  return bitmapImageData; //return the starting address of the bitmap image data

} //end ParseBitmapFile


//Used to display the bitmap header info
void DispBitmapHdrs( BITMAPFILEHDR *bitmapFileHdr, BITMAPINFOHDR *bitmapInfoHdr, BITMAPINFOHDR_CALC *bitmapInfoHdr_Calc ) {

    //DISPLAY file header values in each variable
  printf( "\n-- Bitmap File Header --\n%xh type\tFile Type\n%xh bytes\tFile Size\n%xh resrvd\tReserved1\n%xh resrvd\tReserved2\n%xh bytes\tImage Offset\n",
    (*bitmapFileHdr).bfType,
    (*bitmapFileHdr).bfSize,
    (*bitmapFileHdr).bfRes1,
    (*bitmapFileHdr).bfRes2,
    (*bitmapFileHdr).bfOffset );


  //DISPLAY info header values in each variable
  //Each "bitmapInfoHdr" must be dereferenced b/c it was passed through to the function as a pointer
  //and not as a local variable like "bitmapFileHdr".
  printf( "\n-- Bitmap Info Header --\n%xh bytes\tInfo Size\n%xh pixels\tImage Width\n%xh pixels\tImage Height\n%xh planes\tColor Planes\n%xh bits\tBits/Pixel\n%xh method\tCompression\n%xh bytes\tImgSizeWithPad\n%xh pixels\tXPelsPerMtr\n%xh pixels\tYPelsPerMtr\n%xh colors\tColors Used\n%xh colors\tColrsImportant\n",
    (*bitmapInfoHdr).biSize,
    (*bitmapInfoHdr).biWidth,
    (*bitmapInfoHdr).biHeight,
    (*bitmapInfoHdr).biPlanes,
    (*bitmapInfoHdr).biBitCnt,
    (*bitmapInfoHdr).biComp,
    (*bitmapInfoHdr).biImgSizeWithPad,
    (*bitmapInfoHdr).biXPelsPerMtr,
    (*bitmapInfoHdr).biYPelsPerMtr,
    (*bitmapInfoHdr).biClrUsed,
    (*bitmapInfoHdr).biClrImp );


  //DISPLAY the calculated header values derived from the info header values
  printf( "\n-- Bitmap Info Header (Calculated) --\n%xh bytes\tImage Width\n%xh bytes\tImage Width Mod 4\n%xh bytes\tImage Width with Padding\n",
  (*bitmapInfoHdr_Calc).biWidthInBytes,
  (*bitmapInfoHdr_Calc).biWidthInBytesMod4,
  (*bitmapInfoHdr_Calc).biWidthInBytesPadded );

  return;

} // end DispBitmapHdrs


//Used to write the bitmap header data to a file
void WriteBitmapHdrFile( char *filename, BITMAPFILEHDR *bitmapFileHdr, BITMAPINFOHDR *bitmapInfoHdr, BITMAPINFOHDR_CALC *bitmapInfoHdr_Calc, int *radix ) {

  FILE* hdr_file;

  //OPEN and VERIFY
  if( !(hdr_file = fopen( filename, "w" )) ) {

    fprintf( stderr, "Error Opening/Creating File!\n" ); //print exception to error
    exit( 1 );

  }

  //WRITE file header values in each variable
  fprintf( hdr_file, "-- Bitmap File Header --\n%xh type\tFile Type\n%xh bytes\tFile Size\n%xh resrvd\tReserved1\n%xh resrvd\tReserved2\n%xh bytes\tImage Offset\n",
    (*bitmapFileHdr).bfType,
    (*bitmapFileHdr).bfSize,
    (*bitmapFileHdr).bfRes1,
    (*bitmapFileHdr).bfRes2,
    (*bitmapFileHdr).bfOffset );


  //WRITE info header values in each variable
  //Each "bitmapInfoHdr" must be dereferenced b/c it was passed through to the function as a pointer
  //and not as a local variable like "bitmapFileHdr".
  fprintf( hdr_file, "\n-- Bitmap Info Header --\n%xh bytes\tInfo Size\n%xh pixels\tImage Width\n%xh pixels\tImage Height\n%xh planes\tColor Planes\n%xh bits\tBits/Pixel\n%xh method\tCompression\n%xh bytes\tImgSizeWithPad\n%xh pixels\tXPelsPerMtr\n%xh pixels\tYPelsPerMtr\n%xh colors\tColors Used\n%xh colors\tColrsImportant\n",
    (*bitmapInfoHdr).biSize,
    (*bitmapInfoHdr).biWidth,
    (*bitmapInfoHdr).biHeight,
    (*bitmapInfoHdr).biPlanes,
    (*bitmapInfoHdr).biBitCnt,
    (*bitmapInfoHdr).biComp,
    (*bitmapInfoHdr).biImgSizeWithPad,
    (*bitmapInfoHdr).biXPelsPerMtr,
    (*bitmapInfoHdr).biYPelsPerMtr,
    (*bitmapInfoHdr).biClrUsed,
    (*bitmapInfoHdr).biClrImp );


  //WRITE the calculated header values derived from the info header values
  fprintf( hdr_file, "\n-- Bitmap Info Header (Calculated) --\n%xh bytes\tImage Width\n%xh bytes\tImage Width Mod 4\n%xh bytes\tImage Width with Padding\n",
  (*bitmapInfoHdr_Calc).biWidthInBytes,
  (*bitmapInfoHdr_Calc).biWidthInBytesMod4,
  (*bitmapInfoHdr_Calc).biWidthInBytesPadded );

  //WRITE the required BRAM options
  if( *radix == RADIX_BIN ) {

      fprintf( hdr_file, "\n-- BRAM Instance Parameters --\nWidth = %d\nDepth = %d\n", LCD_BIT_DEPTH/LCD_NUM_COLORS, (*bitmapInfoHdr).biWidth * (*bitmapInfoHdr).biHeight );

    } else { //if RADIX_HEX

      fprintf( hdr_file, "\n-- BRAM Instance Parameters --\nWidth = 8\nDepth = %d\n", (*bitmapInfoHdr).biWidth * (*bitmapInfoHdr).biHeight );

    }

  //CLOSE the header output file
  fclose( hdr_file );

  return;

} // end WriteBitmapHdrFile


//This function writes out the COE byte data for each colors
void WriteCoeFiles( char *filenames[], BYTE *bitmapImageData, BITMAPFILEHDR *bitmapFileHdr, BITMAPINFOHDR *bitmapInfoHdr, BITMAPINFOHDR_CALC *bitmapInfoHdr_Calc, int *debug, int *radix ) {

  FILE* coeFile[3];
  int coeFileNum;
  int byteNum;
  int rowNum;
  int numOfFirstByteInRow;

  //OPEN and VERIFY each COE file
  for( coeFileNum = 0; coeFileNum < NUM_COE_FILES; coeFileNum++ ) {

    coeFile[coeFileNum] = fopen( filenames[coeFileNum + 2], "w" ); //open for writing

    if( coeFile[coeFileNum] == NULL ) { // check if file opening was successful

      fprintf( stderr, "Error Opening/Creating File!\n" ); //print exception to error
      exit( 1 );

    } // end NULL pointer check

  } //end file open check

  //Add COE file color specifier
  fprintf( coeFile[R_FILE_LOC], "; RED Image Data\n" );
  fprintf( coeFile[G_FILE_LOC], "; GREEN Image Data\n" );
  fprintf( coeFile[B_FILE_LOC], "; BLUE Image Data\n" );

  //Add initial COE file info
  for( coeFileNum = 0; coeFileNum < NUM_COE_FILES; coeFileNum++ ) {

    fprintf( coeFile[coeFileNum], "\nMEMORY_INITIALIZATION_RADIX =\n%d;\n", *radix );
    fprintf( coeFile[coeFileNum], "\nMEMORY_INITIALIZATION_VECTOR = " );

  }

  //It is important to note that bitmap image data is stored upside down
  //with the last row of the image first and the first row of the image last.
  //So, for example, if you were to number each pixel in a 3pixelx2row image with
  //memory address numbers starting @ address 0, it would look like this:
  //
  //[B  G  R ][B  G  R ][B  G  R ][P  P  P ]
  // |  |  |   |  |  |   |  |  |   |  |  |
  //[12,13,14][15,16,17][18,19,20][21,22,23] (Actual top of image if you were looking at it)
  //[00,01,02][03,04,05][06,07,08][09,10,11] (Actual bottom of image if you were looking at it)
  // |  |  |   |  |  |   |  |  |   |  |  |
  //[B  G  R ][B  G  R ][B  G  R ][P  P  P ]
  //
  //The above is how the image data is stored in memory with 'bitmapImageData' referencing address
  //'00'. Each set of brackets represents one pixel.  But then why are there 4 sets of brackets?
  //I said that the image was 3 pixels wide didn't I?  Well, that's true, but the BMP
  //file format pads out all rows to be a multiple of 4 bytes wide.  3pixels x 3bytes/pixel = 9
  //Because 9 bytes is not a multiple of 4 we have to pad out 3 bytes of '0' (blank) data to get
  //to 12!
  //Likewise, if the image were only 2 pixels wide = 6 bytes across, we would have to pad out
  //2 blank bytes of '0' data to get to 8.  Yes, I know, it's retarded.  But like they say,
  //don't shoot the messenger. :-)
  //For my byte reader algorithm the blue element of the bottom left pixel of the image is
  //coordinate: (row0, byte0).  The very upper right byte is (HeightInPixels-1,
  //biWidthInBytesPadded-1), which may be a red element (if the original image width in bytes was
  //already a multiple of 4) or a pad byte (if the original image width in byte was not a multiple
  //of 4).
  for( rowNum = (*bitmapInfoHdr).biHeight-1; rowNum >= 0; rowNum-- ) {

    numOfFirstByteInRow = rowNum * (*bitmapInfoHdr_Calc).biWidthInBytesPadded;

    //This loop reads 3 bytes (R,G,B) at a time
    for( byteNum = numOfFirstByteInRow; byteNum <= numOfFirstByteInRow + (*bitmapInfoHdr_Calc).biWidthInBytes - 1; byteNum = byteNum + LCD_NUM_COLORS ) {

      if( !(*debug) ) { //if the user does NOT want debug output

        if( *radix == RADIX_BIN ) {

          OutBinary( coeFile[R_FILE_LOC], bitmapImageData + byteNum + R_BYTE_LOC );
          OutBinary( coeFile[G_FILE_LOC], bitmapImageData + byteNum + G_BYTE_LOC );
          OutBinary( coeFile[B_FILE_LOC], bitmapImageData + byteNum + B_BYTE_LOC );

        } else { //RADIX_HEX

          fprintf( coeFile[R_FILE_LOC], "\n%x,", *(bitmapImageData + byteNum + R_BYTE_LOC) );
          fprintf( coeFile[G_FILE_LOC], "\n%x,", *(bitmapImageData + byteNum + G_BYTE_LOC) );
          fprintf( coeFile[B_FILE_LOC], "\n%x,", *(bitmapImageData + byteNum + B_BYTE_LOC) );

        }

      } else { // if the user DOES want debug output (debug output disregards the user's RADIX value since the COREGEN tool cannot parse COE file with debug information.  We simply force HEX_RADIX.

        fprintf( coeFile[R_FILE_LOC], "\n%x\t-\t(Row %d, Byte %d)", *(bitmapImageData + byteNum + R_BYTE_LOC), rowNum, byteNum );
        fprintf( coeFile[G_FILE_LOC], "\n%x\t-\t(Row %d, Byte %d)", *(bitmapImageData + byteNum + G_BYTE_LOC), rowNum, byteNum );
        fprintf( coeFile[B_FILE_LOC], "\n%x\t-\t(Row %d, Byte %d)", *(bitmapImageData + byteNum + B_BYTE_LOC), rowNum, byteNum );

      } // end debug output check

    } // end if inner loop (byte navigation)

  } // end of outer loop (row navigation)


  //Need to replace the last character in all three files with a semi-colon instead of a comma
  for( coeFileNum = 0; coeFileNum < NUM_COE_FILES; coeFileNum++ ) {
    fseek( coeFile[coeFileNum], -1, SEEK_CUR ); // go back one character from the current
    fprintf( coeFile[coeFileNum], ";" ); //replace the last character with a semi-colon
    fclose( coeFile[coeFileNum] ); //CLOSE the output file because we're done
  }


  return;

} //end WriteCoeFiles


/****MAIN FUNCTION****/
int main( int argc, char* argv[] ) {
  
  BITMAPFILEHDR bitmapFileHdr;
  BITMAPINFOHDR bitmapInfoHdr;
  BITMAPINFOHDR_CALC bitmapInfoHdr_Calc;
  BYTE *bitmapImageData;
  int debug;
  int radix;


  //CHECK for proper number of arguments
  if( argc != 8 ) {
    
    //Print exception to error (argv[0] is the program name itself)
    fprintf( stderr, "Usage: %s <24bpp_bitmap> <R_coe_output> <G_coe_output> <B_coe_output> <bitmap_hdr_output> <debug> <radix>\n", argv[0] );
    exit(1);

  } //end argument check

  //Check for proper radix values
  radix = atoi( argv[ARGV_RAD_NUM] );
  if( radix != RADIX_BIN &&
      radix != RADIX_HEX ) {

    fprintf( stderr, "Invalid value for <radix>.  Choose either 2 or 16." );
    exit(1);

  }

  //get debug value
  debug = atoi( argv[ARGV_DBG_NUM] );
  if( debug ) {
    fprintf( stderr, "Debug output has been requested.  RADIX value will be ignored!" );
  }

  //PARSE the bitmap file
  bitmapImageData = ParseBitmapFile( argv[ARGV_BMP_NUM], &bitmapFileHdr, &bitmapInfoHdr, &bitmapInfoHdr_Calc );

  //make sure we got a good reference address from our parser
  if( bitmapImageData == NULL ) {
    fprintf( stderr, "The parser did not return a valid reference address for the bitmap data!\nExiting..." );
    exit(1);
  }

  if( debug ) {
    DispBitmapHdrs( &bitmapFileHdr, &bitmapInfoHdr, &bitmapInfoHdr_Calc );
  }


  //WRITE out bitmap header info to specified file
  WriteBitmapHdrFile( argv[ARGV_HDR_NUM], &bitmapFileHdr, &bitmapInfoHdr, &bitmapInfoHdr_Calc, &radix );


  //WRITE out COE file color data for BRAMs
  WriteCoeFiles( argv, bitmapImageData, &bitmapFileHdr, &bitmapInfoHdr, &bitmapInfoHdr_Calc, &debug, &radix );

  printf( "\nImage Parsing and COE Data Collection Successful!\n" );

  return 0;

} //end main function
