/*---------------------------------------------------------------------------
 *
 *  Course:   Systems Design II
  *
 *  Module:   vlc.c
 *
 *  Purpose:  To encapsulate VLC coding tables for H.263 encoder
 *
 *  Notes:    Module required for slave CPUs. Codewords are taken from
 *            Telenor's H.263 encoder implementation.
 *
 *  Author:   Olli Lehtoranta and Tero Kangas
 *
 *  History:  23/09/2002: + Original version commented and ready
 *            31/10/2002: + TK: modified for Digital Systems Design II course
 **---------------------------------------------------------------------------
 */

#include "headers.h"


/*
* Intra picture coded block pattern for chrominance and macroblock mode
*
* Table element format = { Bit pattern value, codeword length }
*
* indexing with [mode][chroma block pattern]
*  mode 0 = INTRA
*  mode 1 = INTRA_Q
*
*/
const structVLC mcbpcIntraTable[2][4] =
{
   { {1,1},{1,3},{2,3},{3,3} },
   { {1,4},{1,6},{2,6},{6,6} }
};


/*
*
* Luminance block pattern table for Intra/Inter pictures
*
*/
const structVLC cbpyTable[16] =
{
   {3,4}, {5,5}, {4,5}, {9,4}, {3,5}, {7,4}, {2,6}, {11,4},
   {2,5}, {3,6}, {5,4}, {10,4}, {4,4}, {8,4}, {6,4}, {3,2}
};


/*
*
* H.263 DCT encoding tables (Taken from Telenor's implementation)
*/
static const structVLC coeffTab0[24] =
{
   /* run = 0 */
   {0x02, 2}, {0x0f, 4}, {0x15, 6}, {0x17, 7},
   {0x1f, 8}, {0x25, 9}, {0x24, 9}, {0x21,10},
   {0x20,10}, {0x07,11}, {0x06,11}, {0x20,11},
   /* run = 1 */
   {0x06, 3}, {0x14, 6}, {0x1e, 8}, {0x0f,10},
   {0x21,11}, {0x50,12}, {0x00, 0}, {0x00, 0},
   {0x00, 0}, {0x00, 0}, {0x00, 0}, {0x00, 0}
};

static const structVLC coeffTab1[100] =
{
   /* run = 2 */
   {0x0e, 4}, {0x1d, 8}, {0x0e,10}, {0x51,12},
   /* run = 3 */
   {0x0d, 5}, {0x23, 9}, {0x0d,10}, {0x00, 0},
   /* run = 4-26 */
   {0x0c, 5}, {0x22, 9}, {0x52,12}, {0x00, 0},
   {0x0b, 5}, {0x0c,10}, {0x53,12}, {0x00, 0},
   {0x13, 6}, {0x0b,10}, {0x54,12}, {0x00, 0},
   {0x12, 6}, {0x0a,10}, {0x00, 0}, {0x00, 0},
   {0x11, 6}, {0x09,10}, {0x00, 0}, {0x00, 0},
   {0x10, 6}, {0x08,10}, {0x00, 0}, {0x00, 0},
   {0x16, 7}, {0x55,12}, {0x00, 0}, {0x00, 0},
   {0x15, 7}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x14, 7}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x1c, 8}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x1b, 8}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x21, 9}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x20, 9}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x1f, 9}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x1e, 9}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x1d, 9}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x1c, 9}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x1b, 9}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x1a, 9}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x22,11}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x23,11}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x56,12}, {0x00, 0}, {0x00, 0}, {0x00, 0},
   {0x57,12}, {0x00, 0}, {0x00, 0}, {0x00, 0}
};
/*
* Auxilary table to store limit information for coeffTab1
*/
static const uint16 coeffTab1Limits[25] =
{
   4,3,3,3,3,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
};

static const structVLC coeffTab2[6] =
{
   /* run = 0 */
   {0x07, 4}, {0x19, 9}, {0x05,11},
   /* run = 1 */
   {0x0f, 6}, {0x04,11}, {0x00, 0}
};

static const structVLC coeffTab3[40] =
{
   {0x0e, 6}, {0x0d, 6}, {0x0c, 6},
   {0x13, 7}, {0x12, 7}, {0x11, 7}, {0x10, 7},
   {0x1a, 8}, {0x19, 8}, {0x18, 8}, {0x17, 8},
   {0x16, 8}, {0x15, 8}, {0x14, 8}, {0x13, 8},
   {0x18, 9}, {0x17, 9}, {0x16, 9}, {0x15, 9},
   {0x14, 9}, {0x13, 9}, {0x12, 9}, {0x11, 9},
   {0x07,10}, {0x06,10}, {0x05,10}, {0x04,10},
   {0x24,11}, {0x25,11}, {0x26,11}, {0x27,11},
   {0x58,12}, {0x59,12}, {0x5a,12}, {0x5b,12},
   {0x5c,12}, {0x5d,12}, {0x5e,12}, {0x5f,12},
   {0x00, 0}
};

/*---------------------------------------------------------------------------
*
*  Function: vlcCodeCoefficient
*
*  Input:    last = indication, if this is the last coefficient to be coded
*            run = number of zeros after previously coded coefficient
*            level = absolute value of coefficient to be coded
*            sign = positive / negative indication
*            stream = target bit buffer
*
*  Return:   V_TRUE if LAST,RUN,LEVEL combination can be encoded with
*            help of standard specified codes (optimal)
*
*  Purpose:  To provide look-up table based encoding for LAST,RUN,LEVEL
*            information
*
**---------------------------------------------------------------------------
*/
vbool vlcCodeCoefficient( const sint32 last,
                          const sint32 run,
                          const sint32 level,
                          const sint32 sign,
                          BitStreamType * const stream )
{
   sint32 index = 0;
   sint32 value;
   sint32 bitCount;

   if( !last && ( run < 2 ) && ( level < 13 ) )
   {
      if( run == 0 )
      {
         index = level - 1;
      }
      else if( run == 1 )
      {
         if( level > 6 )
         {
            return V_FALSE;
         }
         index = 12 + level - 1;
      }
      bitCount = coeffTab0[index].bitCount + 1;
      value = ( ( coeffTab0[index].bitPattern << 1 ) | sign);
      bitstreamPut(bitCount,value,stream);
      return V_TRUE;
   }
   else if( !last && ( run >= 2 ) && ( run < 27 ) )
   {
      if( level > coeffTab1Limits[ run - 2 ] )
      {
         return V_FALSE;
      }
      index = ( ( run - 2 ) * 4 ) + level - 1;
      bitCount = coeffTab1[index].bitCount + 1;
      value = ( (coeffTab1[index].bitPattern << 1 ) | sign);
      bitstreamPut(bitCount,value,stream);
      return V_TRUE;
   }
   else if( last && ( run < 2 ) && ( level < 4 ) )
   {
      if( run == 0 )
      {
         index = level - 1;
      }
      else if( run == 1 )
      {
         if( level > 2 )
         {
            return V_FALSE;
         }
         index = 3 + level - 1;
      }
      bitCount = coeffTab2[index].bitCount + 1;
      value = ( ( coeffTab2[index].bitPattern << 1 ) | sign );
      bitstreamPut(bitCount,value,stream);
      return V_TRUE;
   }
   else if( last && ( run >= 2 ) && ( run < 41 ) && ( level == 1 ) )
   {
      bitCount = coeffTab3[run-2].bitCount + 1;
      value = ( ( coeffTab3[run-2].bitPattern << 1 ) | sign);
      bitstreamPut(bitCount,value,stream);
      return V_TRUE;
   }

   return V_FALSE;
}

