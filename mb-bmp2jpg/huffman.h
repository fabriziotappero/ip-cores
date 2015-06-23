#ifndef _HUFFMAN_H
#define _HUFFMAN_H 1

int vlc_init();

char EncodeDataUnit(char dataunit[NUMBER_OF_PIXELS], unsigned int component);

void HuffmanEncodeFinishSend();

#else
#error "ERROR file huffman.h multiple times included"
#endif /* --- _HUFFMAN_H --- */

