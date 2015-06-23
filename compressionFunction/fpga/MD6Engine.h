#ifndef MD6_ENGINE_H
#define MD6_ENGINE_H
#include"md6.h"


#define SHORT_WIDTH

//#if sizeof(short) != 2
//  #error "Miss-sized short"
//#endif

typedef enum {Read=0,Write=1,} Command;
typedef enum {RoundRegister = 0,
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
              TotalRegisters = DestinationRegisterBase + 2 }  RegisterAddr;
              
 
				  
/*int MD6Send(Command command, 
         RegisterAddr reg,
         short payload);

int MD6Receive(short * payload);*/

int MD6Write(RegisterAddr reg, short payload);

int MD6Read(RegisterAddr reg, short *payload);

#endif
