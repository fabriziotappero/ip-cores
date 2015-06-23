#ifndef ENCODE_BITS_H
#define ENCODE_BITS_H

// The bluespec has a hardcoded maximum value...
#define MAX_SIZE (1<<(20+4))


// reads the first bits bits out of the file
void md6_file(char *filename,
              char *outinput,
              char *outresult,
              char *outsize,
              long long bits);

#endif
