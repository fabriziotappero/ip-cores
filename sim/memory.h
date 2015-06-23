/*
 * memory.h -- physical memory simulation
 */


#ifndef _MEMORY_H_
#define _MEMORY_H_


Word memoryReadWord(Word pAddr);
Half memoryReadHalf(Word pAddr);
Byte memoryReadByte(Word pAddr);
void memoryWriteWord(Word pAddr, Word data);
void memoryWriteHalf(Word pAddr, Half data);
void memoryWriteByte(Word pAddr, Byte data);

void memoryReset(void);
void memoryInit(unsigned int memorySize,
                char *progImageName,
                unsigned int loadAddr,
                char *romImageName);
void memoryExit(void);


#endif /* _MEMORY_H_ */
