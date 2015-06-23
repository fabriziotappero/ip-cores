#include "md6.h"
#include "MD6Engine.h"
#include "cLib.h"

#define MD6CommunicationConstant 0xC0000

inline int MD6Send(Command command, RegisterAddr reg, short payload) {
  int command_bits =(int)(((command & 0x1) << 31) | ((reg & 0x3fff) << 16) | ((payload & 0xffff) << 0)); 
  return putValue(command_bits);
}

inline int MD6Receive(short *payload) {
  int resp;
  int value = getResponse(&resp);
  if(MD6CommunicationConstant ^ (resp & 0xFFFF0000)) {
    xil_printf("Communication may be corrupt\r\n");
  }
  *payload = (short) resp;
  return value;
}

inline int MD6Write(RegisterAddr reg, short payload) {
  return MD6Send(Write, reg, payload);
}

inline int MD6Read(RegisterAddr reg, short *payload) {
  if(MD6Send(Read, reg, 0) < 0) {
     return -1;
  }
  return MD6Receive(payload);
}

/*typedef enum {RoundRegister = 0,
              TreeHeightRegister = 1,
              LastCompressionRegister = 2,
              PaddingBitsRegister = 3,
              KeyLengthRegister = 4,
              DigestLengthRegister = 5,
              CompressionFunctionStatus = 6,
              KeyRegisterBase = 7, 
              IdentifierRegisterBase = KeyRegisterBase + md6_k*(md6_w/16),
              SourceRegisterBase = IdentifierRegisterBase + md6_u*(md6_w/16), 
              DestinationRegisterBase = SourceRegisterBase + 2, 
              TotalRegisters = DestinationRegisterBase + 2 }  RegisterAddr;*/

char *registerAddrToString(RegisterAddr reg) {
    switch(reg) {
      case RoundRegister: return "RoundRegister";
      case TreeHeightRegister: return "TreeHeightRegister";
      case PaddingBitsRegister: return "PaddingBitsRegister";
      case KeyLengthRegister: return "KeyLengthRegister";
		case DigestLengthRegister: return "DigestLengthRegister";
      case KeyRegisterBase: return "KeyRegisterBase";
	   case IdentifierRegisterBase: return "IdentifierRegisterBase";
	   case IdentifierRegisterBase + 1: return "IdentifierRegisterBase+1";
	   case IdentifierRegisterBase + 2: return "IdentifierRegisterBase+2";
	   case IdentifierRegisterBase + 3: return "IdentifierRegisterBase+3";
	   case CompressionFunctionStatus: return "CompressionFunctionStatus";
	   case SourceRegisterBase: return "SourceRegisterBase";
	   case SourceRegisterBase + 1: return "SourceRegisterBase + 1";
      case DestinationRegisterBase: return "DestinationRegisterBase";
      case DestinationRegisterBase + 1: return "DestinationRegisterBase + 1";		
		default: return "Uknown Register";
	 }
}	 