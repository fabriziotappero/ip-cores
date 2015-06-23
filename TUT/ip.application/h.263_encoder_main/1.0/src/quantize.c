/*---------------------------------------------------------------------------
*
*  Course:   System Design II
*
*  Module:   quantize.c
*
*  Purpose:  Quantization functions for H.263 encoder 
*
*  Notes:    Only INTRA MB:s supported
*            
*  Author:   Tero Kangas and Olli Lehtoranta
*
*  History:  28/10/2002: + Original version ready
*
**---------------------------------------------------------------------------
*/
#include "headers.h"

/*---------------------------------------------------------------------------
*
*  Function: quantizeIntraMB
*
*  Input:    QP = H.263 quantization parameter
*            MB = pointer to macroblock data
*
*  Return:   none
*
*  Purpose:  Correct quantization for Intra macroblock. The DC
*            coefficients are processed separately. Also sets the coded
*            block pattern for given macroblock.
*
**---------------------------------------------------------------------------
*/
void quantizeIntraMB( const sint32 QP, MBType * const MB ) {

  sint32 block, i;
  sint32 dc;
  sint32 cbp;
  sint32 qLevel;
  sint32 origCoeff;
  sint32 twiceTheQP = QP*2;
  sint32 zeroBlockIndication = 0;
  sint16 *pMB;

  cbp = 0;
  pMB = MB->data; 
  
  for( block=0; block<6; block++ ) {
  
    /* Special quantization for DC coefficient  */
    dc = *pMB;
    dc = dc / 8;
    CLIP(1,dc,254);
    *(pMB++) = (sint16)dc;
    
    #ifdef ENC_DEBUG
    printf("o: %x ", (uint16)dc);
    #endif
    

    for(i=1; i<64; i++ ) {
      origCoeff = *pMB;
      qLevel = abs(origCoeff) / twiceTheQP;
      if( qLevel > 127 )
          qLevel = 127;

      zeroBlockIndication = zeroBlockIndication | qLevel;

      if( origCoeff < 0 )
          qLevel = -qLevel;

      *(pMB++) = (sint16)qLevel;
      
      #ifdef ENC_DEBUG
      printf("%x ", (uint16)qLevel);
      #endif
    }
    
    #ifdef ENC_DEBUG
    printf("\r\n");
    #endif
    
    if( zeroBlockIndication != 0 ){
      /* Set block pattern accordingly */
      cbp = cbp | ( 1 << ( 5 - block ) );
      zeroBlockIndication = 0;
    }
  }

  MB->cbp = cbp;
}

/*---------------------------------------------------------------------------
*
*  Function: quantizeIntraMBInverse
*
*  Input:    QP = H.263 quantization parameter
*            MB = pointer to macroblock data
*
*  Return:   none
*
*  Purpose:  Inverse quantization of Intra macroblock. DC values are processed
*            separately. In addition, no inverse quantization is
*            performed if coded block pattern says that there are no
*            AC coefficients present. In this case the 8 x 8 matrix
*            is filled with zeros (Simplification of computations). 
*
**---------------------------------------------------------------------------
*/
void quantizeIntraMBInverse( const sint32 QP, MBType * const MB ){

  sint32 block, i;
  sint32 reconCoeff;
  sint32 origCoeff;
  sint32 bias;
  sint32 mask = 32;
  sint16 *pMB;

  /* Odd/even determination and inverse quantization formula bias  */
  bias = 0;
  if( ( QP & 1 ) == 0 )
      bias = 1;
  
  pMB = MB->data; 
  
  for( block = 0; block < 6; block++ ) {
    /* DC coeff */
    *(pMB++) = (sint16)(8 * MB->data[64*block]);

    /* The inverse quantization for AC coeffs is needed 
       on if there are nonzero coefficients in MB */
    if( ( MB->cbp & mask ) != 0 ){
      /* The were nonzero AC-coefficients */
      for( i=1; i<64; i++ ) {
          origCoeff = *pMB; 
          reconCoeff = QP * ( 2 * abs(origCoeff) + 1 ) - bias;
          if( origCoeff < 0 )
              reconCoeff = -reconCoeff;
          else if( origCoeff == 0 )
              reconCoeff = 0;
          *(pMB++) = (sint16)reconCoeff;
      }
    } else {
      /* All AC coeffs are zero -> nothing needs to be done */
    }
    mask = mask >> 1;
  }
}
