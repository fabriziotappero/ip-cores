/*---------------------------------------------------------------------------
*
*  Course:   System Design II
*
*  Module:   memory.c
*
*  Purpose:  Load/Storing MBs from/to raw-image 
*
*  Notes:    
*            
*  Author:   Tero Kangas
*
*  History:  31/10/2002: + Original version ready
*
**---------------------------------------------------------------------------
*/
#include "headers.h"


/*---------------------------------------------------------------------------
*
*  Function: memoryLoadMB
*
*  Input:    mb_data = pointer to macroblock data
*            image = source location in memory
*            xMB, yMB = coordinates in source image
*
*  Return:   none
*
*  Purpose:  Load one MB from source image in memory 
*
**---------------------------------------------------------------------------
*/
void memoryLoadMB(const sint32 yMB, 
		  const sint32 xMB, 
		  const uint8 * const image, 
		  uint8 *mb_data){
  
  sint32 block, j; 
  sint32 xMBstart, yMBstart;
  const uint8 *block_ptr = NULL;
  sint32 pixelsInRow = 0;
  uint8 *pData;

  uint32 fourpixels;

  pData = mb_data;
  xMBstart = xMB*16;
  yMBstart = yMB*16*176;

  for (block=0; block<6; block++){
    switch( block ){
    case 0: /* 1st luma  */
      block_ptr = image + yMBstart + xMBstart;
      pixelsInRow = 176;
      break;
    case 1: /* 2nd luma  */
      block_ptr = image + yMBstart + xMBstart+8;
      break;
    case 2: /* 3rd luma  */
      block_ptr = image + yMBstart+8*176 + xMBstart;
      break;
    case 3: /* 4th luma  */
      block_ptr = image + yMBstart+8*176 + xMBstart+8;
      break;
    case 4: /* chroma blue */
      block_ptr = image+176*144 + yMBstart/4 + xMBstart/2;
      pixelsInRow = 88;
      break;
    case 5: /* chroma red */
      block_ptr = image+176*144+88*72 + yMBstart/4 + xMBstart/2;
      break;
    }
    

    for (j=0; j<8; j++, block_ptr+=pixelsInRow ) {
      fourpixels = *((uint32*)block_ptr);
      *(pData++) = (uint8)(fourpixels >> 0);
      *(pData++) = (uint8)(fourpixels >> 8);
      *(pData++) = (uint8)(fourpixels >> 16);
      *(pData++) = (uint8)(fourpixels >> 24);
      fourpixels = *((uint32*)(block_ptr+4));
      *(pData++) = (uint8)(fourpixels >> 0);
      *(pData++) = (uint8)(fourpixels >> 8);
      *(pData++) = (uint8)(fourpixels >> 16);
      *(pData++) = (uint8)(fourpixels >> 24);
    }

/*
    for (j=0; j<8; j++, block_ptr+=(pixelsInRow-8)) {
      for (i=0; i<8; i++) {
	*(pData++) = *(block_ptr++);
      }
    }
*/
  }
}

/*---------------------------------------------------------------------------
*
*  Function: memoryStoreMB
*
*  Input:    MB = pointer to macroblock data
*            image = target location in memory
*            xMB, yMB = coordinates in target image
*
*  Return:   none
*
*  Purpose:  Stores one MB to target image in memory 
*
**---------------------------------------------------------------------------
*/
void memoryStoreMB(const sint32 yMB, 
		   const sint32 xMB, 
		   uint8 * const image, 
		   const MBType * const MB){

  sint32 block, i, j; 
  sint32 xMBstart, yMBstart;
  uint8 *block_ptr = NULL;
  sint32 pixelsInRow = 0;
  sint16 *pData;

  pData = MB->data;
  xMBstart = xMB*16;
  yMBstart = yMB*16*176;

  for (block=0; block<6; block++){
    switch( block ){
    case 0: /* 1st luma  */
      block_ptr = image + yMBstart + xMBstart;
      pixelsInRow = 176;
      break;
    case 1: /* 2nd luma  */
      block_ptr = image + yMBstart + xMBstart+8;
      break;
    case 2: /* 3rd luma  */
      block_ptr = image + yMBstart+8*176 + xMBstart;
      break;
    case 3: /* 4th luma  */
      block_ptr = image + yMBstart+8*176 + xMBstart+8;
      break;
    case 4: /* chroma blue */
      block_ptr = image+176*144 + yMBstart/4 + xMBstart/2;
      pixelsInRow = 88;
      break;
    case 5: /* chroma red */
      block_ptr = image+176*144+88*72 + yMBstart/4 + xMBstart/2;
      break;
    }
    
  
    for (j=0; j<8; j++, block_ptr+=(pixelsInRow-8))
      for (i=0; i<8; i++)
	*(block_ptr++) = (uint8)*(pData++);
    
  } 

}

