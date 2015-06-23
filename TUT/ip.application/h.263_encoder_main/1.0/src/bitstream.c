/*---------------------------------------------------------------------------
*
*  Course:   System-on-Chip Design
*
*  Module:   bitstream.c
*
*  Purpose:  bitstream handling functions for H.263 encoder 
*
*  Notes:    Modify bitstreaPut if you want to direct the bitstream
*            somewhere else than a file
*            
*  Author:   Tero Kangas
*
*  History:  31/10/2002: + Original version ready
*            31/12/2003: + Now this file can be used for both in Excalibur 
*                         and PC platforms. Selected by PRINT_TO_TERMINAL constant
*            29/08/2011: Get rid of the unnecessary PRINT_TO_TERMINAL hacks.
*                        Added DISABLE_OUTPUT ifdef to easily disable output
*                        printing for profiling purposes.
*
**---------------------------------------------------------------------------
*/
#include "headers.h"

const sint32 bitSetMask[] =
{
0x00000001,0x00000002,0x00000004,0x00000008,
0x00000010,0x00000020,0x00000040,0x00000080,
0x00000100,0x00000200,0x00000400,0x00000800,
0x00001000,0x00002000,0x00004000,0x00008000,
0x00010000,0x00020000,0x00040000,0x00080000,
0x00100000,0x00200000,0x00400000,0x00800000,
0x01000000,0x02000000,0x04000000,0x08000000,
0x10000000,0x20000000,0x40000000,0x80000000
};


/*---------------------------------------------------------------------------
 *
 *  Function: bitstreamInitBuffer
 *
 *  Input:    pointer to bitstream structure 
 *
 *  Return:   none
 *
 *  Purpose:  initialize bitstream structure
 *
 **---------------------------------------------------------------------------
 */
void bitstreamInitBuffer(BitStreamType * const stream){
  stream->bitcount = 0; 
  stream->file = NULL;
  stream->buffer = 0;
}


/*---------------------------------------------------------------------------
 *
 *  Function: bitstreamFlushBufferToFile
 *
 *  Input:    pointer to bitstream structure 
 *
 *  Return:   none
 *
 *  Purpose: Flush the remaining 0<n<32 bits from buffer to file 
 *
 **---------------------------------------------------------------------------
 */
void bitstreamFlushBufferToFile(BitStreamType * const stream){
  
  sint32 byteCount, i;

  /* Align the bitstream first */
  bitstreamAlign(stream);

  byteCount = stream->bitcount/8;

  for(i=byteCount-1; i>=0; i--){
#ifndef DISABLE_OUTPUT
      fprintf(stream->file, "%c", *((char *)(&stream->buffer)+i));
#endif
  }
  
}

/*---------------------------------------------------------------------------
 *
 *  Function: bitstreamPut
 *
 *  Input:   bitCount = number of bits to put ( 1 - 32 )
 *           bitPattern = binary representation of codeword to put
 *           stream = target bit buffer
 *
 *  Return:   none
 *
 *  Purpose: To insert bits in given bitbuffer. Writes also the buffer into
 *           a file when there are 32 bits in the buffer
 *
 **---------------------------------------------------------------------------
 */
void bitstreamPut(const uint32 number_of_bits, 
		  const sint32 val, 
		  BitStreamType * const stream){

  sint32 byte;
  sint32 n = number_of_bits;

  /*printf("Writing %#x (%i bits) to buffer\n", val, number_of_bits);*/
  while(n--) {
    stream->buffer <<= 1;

    if (val & bitSetMask[n])
      stream->buffer|= 1;
   
    stream->bitcount++;

    if (stream->bitcount==32){     /* buffer full */

      for(byte=3; byte>=0; byte--){
#ifndef DISABLE_OUTPUT
          fprintf(stream->file, "%c", *((char *)(&stream->buffer)+byte));
#endif
      }
      stream->bitcount = 0;
    }
  }
}



/*---------------------------------------------------------------------------
 *
 *  Function: bitstreamAlign
 *
 *  Input:    pointer to bitstream structure 
 *
 *  Return:   none
 *
 *  Purpose: Zero bit stuffing to next byte boundary
 *
 **---------------------------------------------------------------------------
 */
void bitstreamAlign( BitStreamType * const stream ){
  
  sint32 bits = stream->bitcount%8;

  if (bits != 0)
    bitstreamPut(8-bits, 0, stream);   

}
