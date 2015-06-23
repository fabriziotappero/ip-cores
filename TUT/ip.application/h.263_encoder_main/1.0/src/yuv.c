/*---------------------------------------------------------------------------
*
*  Course:   System Design II
*
*  Module:   yuv.c
*
*  Purpose:  YUV raw-file handling functions  for H.263 encoder 
*
*  Notes:    
*            
*  Author:   Tero Kangas and Olli Lehtoranta
*
*  History:  31/10/2002: + Original version ready
*
**---------------------------------------------------------------------------
*/
#include "headers.h"



/*---------------------------------------------------------------------------
*
*  Function: yuvOpenInputFile
*
*  Input:    file_name = name of file to be opened
*            frame_count = frame counter (to be initialized)
*
*  Return:   Pointer to file opened 
*
*  Purpose:  To open a raw YUV file and compute its frame count
*
**---------------------------------------------------------------------------
*/
FILE* yuvOpenInputFile( const vchar *file_name, sint32 *frame_count) {

  FILE *file;
  vlong  file_size;
  
  file = fopen(file_name,"rb");
  if( file == NULL ){
    printf("yuvOpenInputFile: Could not open the file %s\n", file_name);
    return NULL;
  }

  /* Check the file size */
  fseek(file,0,SEEK_END);
  file_size = ftell(file);
  *frame_count = ( file_size / 38016 );

  /* Set the file position back to the beginning of the file */
  fseek(file,0,SEEK_SET);
  return file;
}


/*---------------------------------------------------------------------------
*
*  Function: yuvReadFrame
*
*  Input:    file = data structure modeling YUV-file
*            target_buffer = target memory buffer where to the image is read
*
*  Return:   V_TRUE, if a frame read operation does not fail
*
*  Purpose:  Can be used to read frames from raw YUV-file
*
**---------------------------------------------------------------------------
*/
vbool yuvReadFrame( FILE * const file,
		    uint8 * const target_buffer ){

  if( fread(target_buffer,38016,1,file) != 1 ){
    printf("yuvReadFrame: The read was failed!\n");
    return V_FALSE;
  }
  
  return V_TRUE;
}

/*---------------------------------------------------------------------------
*
*  Function: yuvWriteFrame
*
*  Input:    file = data structure modeling YUV-file
*            source_buffer = source memory buffer from where image data
*                            is stored to file
*
*  Return:   V_FALSE, if the write operation fails
*
*  Purpose:  To write singe YUV-frame to the disk. Concatenated after
*            existing file.
*
**---------------------------------------------------------------------------
*/
vbool yuvWriteFrame( FILE * const file, const uint8 * const source_buffer ) {

  if( file != NULL ){
    if( fwrite(source_buffer,38016,1,file) != 1 ){
      return V_FALSE;
    }
  }
  return V_TRUE;
}


