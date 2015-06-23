/* Global definitions for Reed-Solomon encoder/decoder
 * Phil Karn KA9Q, September 1996
 *
 * The parameters MM and KK specify the Reed-Solomon code parameters.
 *
 * Set MM to be the size of each code symbol in bits. The Reed-Solomon
 * block size will then be NN = 2**M - 1 symbols. Supported values are
 * defined in rs.c.
 *
 * Set KK to be the number of data symbols in each block, which must be
 * less than the block size. The code will then be able to correct up
 * to NN-KK erasures or (NN-KK)/2 errors, or combinations thereof with
 * each error counting as two erasures.
 */
#define MM  8		/* RS code over GF(2**MM) - change to suit */
#define KK  223		/* KK = number of information symbols */

#define	NN ((1 << MM) - 1)

#if (MM <= 8)
typedef unsigned char dtype;
#else
typedef unsigned int dtype;
#endif

/* Initialization function */
void init_rs(void);

/* These two functions *must* be called in this order (e.g.,
 * by init_rs()) before any encoding/decoding
 */

void generate_gf(void);	/* Generate Galois Field */
void gen_poly(void);	/* Generate generator polynomial */

/* Reed-Solomon encoding
 * data[] is the input block, parity symbols are placed in bb[]
 * bb[] may lie past the end of the data, e.g., for (255,223):
 *	encode_rs(&data[0],&data[223]);
 */
int encode_rs(dtype data[], dtype bb[]);

/* Reed-Solomon erasures-and-errors decoding
 * The received block goes into data[], and a list of zero-origin
 * erasure positions, if any, goes in eras_pos[] with a count in no_eras.
 *
 * The decoder corrects the symbols in place, if possible and returns
 * the number of corrected symbols. If the codeword is illegal or
 * uncorrectible, the data array is unchanged and -1 is returned
 */
int eras_dec_rs(dtype data[], int eras_pos[], int no_eras);
