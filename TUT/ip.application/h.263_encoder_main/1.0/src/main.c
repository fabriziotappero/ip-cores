/*---------------------------------------------------------------------------
 *
 *  Course:   SoC design 
 *
 *  File:     main.c 
 *
 *  Purpose:  This is main code of H.263 video encoder 
 *
 *  Group:  
 *          
 *  Authors:
 *
 * 
 *  Notes:    This encoder code implements only a part of H.263 features.
 *            As you know, H.263 standard defines only the decoder - not 
 *            the encoder. Thus, this encoder code produces bitstream that
 *            any H.263 compliant decoder is able to decode. 
 *
 *            This implementation is an extremely simplified version 
 *            H.263 video encoder. For instance, parallel execution and 
 *            motion estimation is not applied at all in these codes.
 *            Limitations:
 *            - Only INTRA coding mode is supported
 *            - Only QCIF picture format supported
 *            - None of the optional coding modes supported
 *
 *---------------------------------------------------------------------------
 */

//#include <assert.h>
#include <mcapi.h>
#include <stdio.h>

#include "headers.h"
//#include "carphone_data.h"


FILE* OUTPUT_STREAM;

#define XMBS 11
#define YMBS 9

// MACRO BLOCK COUNT FOR DCT
#define MB_COUNT 6
#define MB_SIZE 64 

// MCAPI NODE NUMBER
#define MAIN_NODE_NUM 0
#define DCT_NODE_NUM 1

#define WAIT_TIMEOUT 0xFFFFFFFF

#define mcapi_assert_success(s) \
        if (s != MCAPI_SUCCESS) { printf("%s:%d status %d\n", __FILE__, __LINE__, s); abort(); }



int encoder(){

  //printf("Encoder starts MCAPI initialization\r\n");

  // mcapi initialization starts here
  mcapi_priority_t priority = 1;
  mcapi_status_t status;
  mcapi_request_t request, send_request, recv_request;
  size_t size, recv_size, send_size;
  mcapi_version_t version;
  mcapi_endpoint_t  block_count_out, dct_data_out, dct_data_in , 
    ext_dct_data_in, ext_dct_data_out, ext_dct_block_count_in;  

  mcapi_pktchan_send_hndl_t       send_handle;
  mcapi_pktchan_recv_hndl_t       recv_handle;

  unsigned int my_node_id = MAIN_NODE_NUM;

  mcapi_initialize(my_node_id,&version,&status);
  mcapi_assert_success(status);
  
  /* create endpoints */
  block_count_out = mcapi_create_endpoint ( 0 ,&status);
  mcapi_assert_success(status);

  dct_data_out = mcapi_create_endpoint ( 1 ,&status);
  mcapi_assert_success(status);

  dct_data_in = mcapi_create_endpoint ( 2 ,&status);
  mcapi_assert_success(status);

  //printf("Endpoints created succesfully\r\n");
  
  /* get DCT's endpoints from database */ 
  ext_dct_data_in = mcapi_get_endpoint (DCT_NODE_NUM, 1,&status);
  mcapi_assert_success(status);
  
  ext_dct_data_out = mcapi_get_endpoint (DCT_NODE_NUM, 2, &status);
  mcapi_assert_success(status);
  
  ext_dct_block_count_in = mcapi_get_endpoint (DCT_NODE_NUM, 0, &status);
  mcapi_assert_success(status);
  
  //printf("Remote endpoints obtained succesfully\r\n");
  
  /* connect packet channels */
  mcapi_connect_pktchan_i(dct_data_out , ext_dct_data_in,&request,&status);
  while (!mcapi_test(&request,&size,&status)) {}
  mcapi_assert_success(status);

  mcapi_connect_pktchan_i(ext_dct_data_out, dct_data_in,&request,&status);
  while (!mcapi_test(&request,&size,&status)) {}
  mcapi_assert_success(status);
   
  //printf("Packet channels connected succesfully\r\n");

  /* open pktchan for sending macroblocks */
  mcapi_open_pktchan_send_i(&send_handle, dct_data_out, &send_request, &status);
  //printf("First channel opened!\r\n");
  mcapi_assert_success(status);

  /* open pktchan for receiving macroblocks from DCT */
  mcapi_open_pktchan_recv_i(&recv_handle, dct_data_in, &recv_request, &status);
  mcapi_assert_success(status);
  //printf("Second channel opened!\r\n");

  mcapi_wait(&send_request, &size, &status, WAIT_TIMEOUT);	
  mcapi_assert_success(status);
  
  //printf("First wait!\r\n");

  mcapi_wait(&recv_request, &size, &status, WAIT_TIMEOUT);	
  mcapi_assert_success(status);
  
  //printf("MCAPI initialization done!\r\n");
  
  
  size = 1;
  uint8 msg = MB_COUNT;

  //printf("Sending configuration message to DCT!\r\n");
  mcapi_msg_send(block_count_out, ext_dct_block_count_in, &msg, size, priority,&status);

  sint32 lastFrame;
  uint8 currentImage[38016];

  vchar inputFileName[] = "carphone.qcif";
  vchar streamFileName[] = "carphone.263";

  unsigned int cur_frame;

  BitStreamType stream;

  FILE *inputfile;

  inputfile=yuvOpenInputFile(inputFileName, &lastFrame);
  
  
  //  assert(inputfile != NULL);


  bitstreamInitBuffer(&stream);
  stream.file=fopen(streamFileName, "wb");

  uint8 *mb_data;
  MBType dct_data;

  mb_data=(uint8*)malloc(MB_COUNT*MB_SIZE);
  dct_data.data=(sint16*)malloc(2*MB_COUNT*MB_SIZE);
//  char start;
//  getc(start);
  
  for(cur_frame=0;cur_frame<lastFrame;cur_frame++)
  {
    yuvReadFrame(inputfile,currentImage);
    //currentImage=&carphone_data[cur_frame*38016];
    
    PictureType ptype;
    ptype.TR=cur_frame;
    ptype.QUANT=QPI_DEF;
    codePictureHeader(&ptype,&stream);

    unsigned int xpos,ypos;
/*
    uint8 *mb_data;
    MBType dct_data;
    
  
    mb_data=(uint8*)malloc(MB_COUNT*MB_SIZE);
    dct_data.data=(sint16*)malloc(2*MB_COUNT*MB_SIZE);
  */  
    send_size = MB_COUNT*MB_SIZE;
    
    //sint16 *incoming;

    for(ypos=0;ypos<YMBS; ypos++)
    {
      for(xpos=0;xpos<XMBS; xpos++)
      {
	//printf("Blokin aloitus: f=%d: x=%d, y=%d\r\n", cur_frame, xpos, ypos);
       memoryLoadMB(ypos,xpos,(unsigned char*)currentImage, mb_data);
       //printf("Memory load ok.\r\n");
       
       /* send six macro blocks to dct via mcapi */
       //printf("Sending macroblock packets to DCT.\r\n");
       mcapi_pktchan_send(send_handle, mb_data, send_size, &status);
       mcapi_assert_success(status);
       //printf("Sent successfully!\r\n");
       
       /* receive data from dct */
       mcapi_pktchan_recv(recv_handle,(void *)&dct_data.data ,&recv_size,&status);
       mcapi_assert_success(status);
       
       
       //printf("Received transformed macroblocks from DCT.\r\n");
       fdct_8x8(mb_data, dct_data.data, 6);
       // printf("fdct ok.\r\n");
       quantizeIntraMB(QPI_DEF, &dct_data);
       //printf("quantize ok.\r\n");
       codeIntraMB(&dct_data, &stream);
       //printf("code ok.\r\n");

       mcapi_pktchan_free(dct_data.data, &status);
      }
    }
    

    bitstreamAlign(&stream);
     

  }
    free(mb_data);
    //free(dct_data.data);

  bitstreamFlushBufferToFile(&stream);

  fclose(stream.file);
  //printf("Job well done!\n");
  return 1;
}
  

