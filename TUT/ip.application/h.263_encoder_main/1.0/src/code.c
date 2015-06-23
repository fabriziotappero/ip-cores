/*---------------------------------------------------------------------------
*
*  Course:   System Design II
*
*  Module:   code.c
*
*  Purpose:  Run-Length Encoding functions for H.263 encoder 
*
*  Notes:    Only INTRA MB:s supported
*            
*  Author:   Tero Kangas and Olli Lehtoranta
*
*  History:  31/10/2002: + Original version ready
*
**---------------------------------------------------------------------------
*/
#include "headers.h"


const uint16 zigzagScan[64] = 
{
  0,1,8,16,9,2,3,10,17,24,32,25,18,11,4,5,
  12,19,26,33,40,48,41,34,27,20,13,6,7,14,21,28,
  35,42,49,56,57,50,43,36,29,22,15,23,30,37,44,51,
  58,59,52,45,38,31,39,46,53,60,61,54,47,55,62,63
};


/*---------------------------------------------------------------------------
*
*  Function: codePictureHeader
*
*  Input:    pic = pointer to picture information structure
*
*  Return:   none
*
*  Purpose:  To encode H.263 picture header
*
**---------------------------------------------------------------------------
*/
void codePictureHeader( const PictureType * const pic, BitStreamType * const stream ){

  /* Picture start code */
  bitstreamPut(22,0x20,stream);
   
  /* Temporal reference */
  bitstreamPut(8,pic->TR,stream);
  
  /* PTYPE */
  /* bit 1 always 1 to avoid start code emulation:              1 */
  /* bit 2 always zero for distinction with H.261:              0 */
  /* bit 3 no support for split-screen in this software:        0 */
  /* bit 4 document_camera indicator:                           0 */
  /* bit 5 freeze_picture_release:                              0 */
  /* bit 6-8 QCIF source format:                            0b010 */ 
  /* bit 9 Picture coding type is INTRA always:                 0 */
  /* bit 10 no support for Unrestricted Motion Vector mode:     0 */
  /* bit 11 no support for Syntax-based Arithmetic Coding mode: 0 */
  /* bit 12 no support for Advanced Prediction mode:            0 */
  /* bit 13 no support for PB-mode:                             0 */
  bitstreamPut(13,0x1040,stream);   

  /* PQUANT */
  bitstreamPut(5,pic->QUANT,stream);

  /* Continuous Presence Multipoint (CPM) */
  bitstreamPut(1,0,stream);  /* CPM is not supported  */

  /* Picture Sub Bitstream Indicator (PSBI) */
  /* not needed */

  /* TRB and DBQUANT: extra information for PB-frames */
  /* PB not needed */
  
  /* PEI (extra information) */
  /* "Encoders shall not insert PSPARE until specified by the ITU" */
  bitstreamPut(1,0,stream); 

  /* PSPARE */
  /* not supported */

}


/*---------------------------------------------------------------------------
*
*  Function: codeLastRunLevel
*
*  Input:    last = indication, if this is the last coefficient to be coded
*            run = number of zeros after previously coded coefficient
*            level = absolute value of coefficient to be coded
*
*  Return:   none
*
*  Purpose:  Uses H.263 escape coding or standard given codes to encode
*            given data
*
**---------------------------------------------------------------------------
*/
static void codeLastRunLevel( const sint32 last,
                              const sint32 run,
                              const sint32 level,
                              BitStreamType * const stream ) {
 
  sint32 sign = 0;
  
  if( level < 0 ){
    sign = 1;
  }
  /* Is escape coding necessary?   */
  if( vlcCodeCoefficient(last,run,abs(level),sign,stream) == V_FALSE ) {
    /* 7-bit H.263 escape code */
    bitstreamPut(7,3,stream);
    /* 1-bit last coefficient indication  */
    bitstreamPut(1,last,stream);
    /* 6-bit run count */
    bitstreamPut(6,run,stream);
    /* 8-bit level */
    bitstreamPut(8,(level & 0xff),stream);
    /* printf("Last %4i Run %4i Level %4i\n",last,run,level); */
  }
}


/*---------------------------------------------------------------------------
*
*  Function: codeIntraBlocks
*
*  Input:    MB = pointer to macroblock data
*            stream = encoding parameters and buffers
*
*  Return:   none
*
*  Purpose:  Encodes all six 8 x 8 blocks belonging to the macroblock
*            with last, run, level coding. Intra macroblocks will
*            always include the DC coefficient.
*
**---------------------------------------------------------------------------
*/
void codeIntraBlocks(const MBType * const MB, 
		    BitStreamType * const stream){

  sint16 value;
  sint32 index;
  sint32 run;
  sint32 block;
  sint32 previous_run;
  sint32 level;
  sint32 mask = 32;
  const sint16 * coeffs;
  
  /* Loop through all 8 x 8 blocks  */
  for( block = 0; block < 6; block++ ) {

    coeffs = MB->data + block*64;

    /* DC coefficient */
    if( coeffs[0] == 128 ) 
      bitstreamPut(8,255,stream);
    else 
      bitstreamPut(8,coeffs[0],stream);
    
    /* AC coefficients */
    /* Last, run, level scanning part  */
    if( ( MB->cbp & mask ) != 0 ) {
      
      /* Init the scanning system  */
      index = 1;
      run = 0;
      previous_run = 0;
      level = 0;
      
      /* Pre-scan because of LAST must be known  */
      while( index < 64 ) {
	
	/* Notice how zigzag scan is taken in the account */
	value = coeffs[ zigzagScan[index++] ];
	if( value != 0 ) {
	  level = value;
	  previous_run = run;
	  run = 0;
	  break;
	}
	run++;
      }
      /* Scan possible remaining coefficients  */
      while( index < 64 ) {
	value = coeffs[ zigzagScan[index++] ];
	if( value != 0 ) {
	  codeLastRunLevel(0,previous_run,level,stream);
	  level = value;
	  previous_run = run;
	  run = 0;
	}
	else {
	  run++;
	}
      }
      /* Put the last coefficient into the bitstream  */
      codeLastRunLevel(1,previous_run,level,stream);
    }

     /* Move to next block */
      mask = mask >> 1;
  }
}


/*---------------------------------------------------------------------------
*
*  Function: codeIntraMB
*
*  Input:    MB = pointer to macroblock data
*            stream = encoding parameters and buffers
*
*  Return:   none
*
*  Purpose:  To manage VLC encoding of Intra macroblocks (headers + blocks)
*
**---------------------------------------------------------------------------
*/
void codeIntraMB(const MBType * const MB, BitStreamType * const stream){

  sint32 bitCount;
  sint32 bitPattern;
  sint32 chromaCbp;
  sint32 lumaCbp;

  /* COD, MODB, CBPB, DQUANT, MVD, MVD(2-4) and MVDB not needed */

  /* CBPCM */
  chromaCbp = MB->cbp & 3;
  bitCount = mcbpcIntraTable[0][chromaCbp].bitCount;
  bitPattern = mcbpcIntraTable[0][chromaCbp].bitPattern;
  bitstreamPut(bitCount,bitPattern,stream);

  /* CBPY */
  lumaCbp = MB->cbp >> 2;
  bitCount = cbpyTable[lumaCbp].bitCount;
  bitPattern = cbpyTable[lumaCbp].bitPattern;
  bitstreamPut(bitCount,bitPattern,stream);
  
  /* Block layer encoding */
  codeIntraBlocks(MB,stream);
  
}

