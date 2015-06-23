#include "md6.h"
#include "MD6Engine.h"
#include "timer.h"

#ifdef DEBUG
  int writeCheck(RegisterAddr reg, short data);
  int readCheck(RegisterAddr reg, short data);
#endif

#undef DEBUG

#define EVER ;;

//int checkHash(md6_word *src, md6_word *dest, md6_word *uniqueID, 
//              md6_word *tree_height, md6_word *last_op, 
//              md6_word *padding_bits);
#ifdef DEBUG
inline int writeCheck(RegisterAddr reg, short data) {
  short temp;
  if(MD6Write(reg, data) < 0) {
    xil_printf("Failed to write %s\r\n", registerAddrToString(reg));					 
	 return -1;
  }
  
    return readCheck(reg,data);
}
#else
  int (*writeCheck) (RegisterAddr,short) = MD6Write;
#endif

inline int readCheck(RegisterAddr reg, short data) {
  short temp;
  if(MD6Read(reg, &temp) < 0) {
    xil_printf("Failed to read %s\r\n",registerAddrToString(reg));					
    return -1;	 
  } else if(temp != data) {
    xil_printf("%s == %x, expect %x\r\n",registerAddrToString(reg),temp,data);  
	 return -1;
  } 
  return 0;
}

int startHash(md6_word *src, md6_word *dest, md6_word *uniqueID, 
              md6_word *key, md6_word *tree_height, md6_word *last_op, 
              md6_word *padding_bits,  md6_word *digest_length) {
  short sent_value;
  int spins = 0;
  long long start, finish;
  int i;
  #ifdef DEBUG
    xil_printf("src: %x dest: %x \r\n", src, dest);
  #endif
  sent_value = ((int)src) & 0xffff;
  //Check that the compressor is turned off 
 // if(readChseck(CompressionFunctionStatus,0)){
 //   return 0;
 // }
  
  if(writeCheck(SourceRegisterBase, sent_value) < 0) {
    return -1;
  }

  sent_value = ((int)src >>16) & 0xffff;
  if(writeCheck(SourceRegisterBase + 1, sent_value) < 0) {
    return -1;
  }

  sent_value = ((int)dest) & 0xffff;
  if(writeCheck(DestinationRegisterBase, sent_value) < 0) {
    return -1;
  }

  sent_value = ((int)dest >>16) & 0xffff;
  if(writeCheck(DestinationRegisterBase + 1, sent_value) < 0) {
    return -1;
  }
  
  // write out uniqueID
  for(i = 0; i < md6_u*md6_w/16; i++) {       
	  sent_value = ( (uniqueID[i>>2]) >> ((i&0x3)*16) ) & 0xffff; 
	  writeCheck(IdentifierRegisterBase+i,sent_value);
  }  

  // write out key
  for(i = 0; i < md6_k*md6_w/16; i++) {       
	  sent_value = ( (key[i>>2]) >> ((i&0x3)*16) ) & 0xffff; 
	  writeCheck(KeyRegisterBase+i,sent_value);
  } 
  
  sent_value = *tree_height & 0xffff;
  if(writeCheck(TreeHeightRegister, sent_value) < 0) {
    return -1;
  }
  
  sent_value = *last_op & 0xffff;
  if(writeCheck(LastCompressionRegister, sent_value) < 0) {
    return -1;
  }
  
  sent_value = *padding_bits & 0xffff;
  if(writeCheck(PaddingBitsRegister, sent_value) < 0) {
    return -1;
  }
  //XXXX this must be fixed at some point.
  sent_value = md6_k;
  if(writeCheck(KeyLengthRegister, sent_value) < 0) {
    return -1;
  }
  
  sent_value = 0;
  if(writeCheck(RoundRegister, sent_value) < 0) {
    return -1;
  }
  
  sent_value = (short)*digest_length & 0xffff;
  if(writeCheck(DigestLengthRegister, sent_value) < 0) {
    return -1;
  }

  #ifdef DEBUG
    for(i = 0; i < TotalRegisters; i++) {
      MD6Read(i,&sent_value);
	   xil_printf("Reg[%d]: %4x  ", i, sent_value);
	   if(i%4==3) {
	     printf("\r\n");
	   }
    }
    printf("\r\n");
  #endif
//  md6_word *src, md6_word *dest, md6_word *uniqueID, 
//              md6_word *tree_height, md6_word *last_op, 
//              md6_word *padding_bits
  // this check could possibly fail
  start = ts_get_ll();
  if(MD6Write(CompressionFunctionStatus,1)<0) {
    xil_printf("Failed to start Compression Function\r\n");
    return -1; 
  }
  

  
  
  for(EVER) {
    if(MD6Read(CompressionFunctionStatus, &sent_value) < 0) {
	   xil_printf("Failed to read Compression Function Status spins: %d, %d\r\n",spins,CompressionFunctionStatus);
		return -1;
	 }
	 
	 if(sent_value == 0) {
	   finish = ts_get_ll();
	xil_printf("Time kernel: %d %d\r\n", (int)(finish-start),ts_elapse_ns(start,finish)); 
      break;
	 }

	 spins++;	 
	 if(spins%1000000 == 0) {
	   xil_printf("Compression Function Timeout, status: %d", sent_value);
		break;
	 }
  }   
  
}


