
#include <mcapi.h>
#include "headers.h"

#define MAIN_NODE_NUM 0
#define DCT_NODE_NUM 1

#define WAIT_TIMEOUT 0xFFFFFFFF

#define mcapi_assert_success(s) \
        if (s != MCAPI_SUCCESS) { printf("%s:%d status %d\n", __FILE__, __LINE__, s); abort(); }


extern void fdct_8x8(uint8 *input_data, sint16 *output_data, sint32 num_fdcts);

int main_dct(){
  
  //printf("DCT starts MCAPI initialization\r\n");
  
  mcapi_status_t status;
  mcapi_request_t request, recv_request, send_request;
  size_t size;
  mcapi_version_t version;
  mcapi_endpoint_t  block_count_in, dct_data_out, dct_data_in , ext_dct_data_in;  

  mcapi_pktchan_send_hndl_t       send_handle;
  mcapi_pktchan_recv_hndl_t       recv_handle;
  
  unsigned int my_node_id = DCT_NODE_NUM;

  mcapi_initialize(my_node_id,&version,&status);
  mcapi_assert_success(status);

  /* create endpoints */
  block_count_in = mcapi_create_endpoint ( 0 ,&status);
  dct_data_in = mcapi_create_endpoint ( 1 ,&status);
  dct_data_out =mcapi_create_endpoint ( 2 ,&status);
  
  //printf("Endpoints created succesfully\r\n");
  
  
  /* get main endpoint from database */ 
  ext_dct_data_in = mcapi_get_endpoint (MAIN_NODE_NUM, 1 , &status);
  
  //printf("Remote endpoint obtained succesfully\r\n");

 
  /* open pktchan for sending macroblocks */
  mcapi_open_pktchan_recv_i(&recv_handle, dct_data_in, &recv_request, &status);
  //mcapi_assert_success(status);
  
  /* open pktchan for receiving macroblocks from DCT */
  mcapi_open_pktchan_send_i(&send_handle, dct_data_out, &send_request, &status);
  //mcapi_assert_success(status);
  
  mcapi_wait(&send_request, &size, &status, WAIT_TIMEOUT);	
  mcapi_assert_success(status);
  
  //printf("First wait!\r\n");

  mcapi_wait(&recv_request, &size, &status, WAIT_TIMEOUT);	
  mcapi_assert_success(status);


  //printf("Packet channels opened successfully\r\n");

  // MCAPI INITIALIZATION DONE!

  /* Receive block count configuration from main node */
  size = 1;
  uint8 block_count;
  
  //printf("Waiting for config message..");
  mcapi_msg_recv(block_count_in, &block_count, 1 , &size ,&status);
  //printf("received %X\r\n", block_count);
  uint8 i = 0;
  uint8 ii = 0;
  uint8 *mb_data;
  sint16 *dct_data;
  dct_data=(sint16*)malloc(2*6*8*8);
  
  while(1) {
    
    /* receive data from main */
    //printf("Receiving macroblock packet from the main.\r\n");
    mcapi_pktchan_recv(recv_handle,(void *)&mb_data,&size,&status);
    mcapi_assert_success(status);
    mcapi_pktchan_free((void *)mb_data, &status);
    //printf("Transforming macroblocks\n");
    
    
    for(ii = 0; ii < 10; ii++)
    fdct_8x8(mb_data, dct_data, block_count);
 
    /* send transformed six macro blocks to main via mcapi */
    size =2*6*8*8;
    //printf("Sending transformed macroblocks to main\r\n");
    mcapi_pktchan_send(send_handle,dct_data,size,&status);     
    mcapi_assert_success(status);
    //printf("Counter %u\n", i);
      i++;
    }
  free(dct_data);
  return 1;
    
}
