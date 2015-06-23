#ifndef MD6_ENGINE_H

#include "md6.h"
#include "MD6Engine.h"

int checkHash(md6_word *src, md6_word *dest, md6_word *uniqueID, 
              md6_word *key, md6_word *tree_height, md6_word *last_op, 
              md6_word *padding_bits,  md6_word *digest_length);

// this function expects src to be laid out 63:0 and writes dest 15:0
// These will be word reversed.
int startHash(md6_word *src, md6_word *dest, md6_word *uniqueID, 
              md6_word *key, md6_word *tree_height, md6_word *last_op, 
              md6_word *padding_bits, md6_word *digest_length);

#endif
