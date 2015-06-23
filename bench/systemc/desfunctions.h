//////////////////////////////////////////////////////////////////////
////                                                              ////
////  DES C encrypt and decrypt functions for C golden model      ////
////                                                              ////
////  This file is part of the SystemC DES                        ////
////                                                              ////
////  Description:                                                ////
////  DES C encrypt and decrypt functions for C golden model      ////
////                                                              ////
////  To Do:                                                      ////
////   - done                                                     ////
////                                                              ////
////  Author(s):                                                  ////
////      - Javier Castillo, jcastilo@opencores.org               ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
// Revision 1.2  2004/08/30 16:55:54  jcastillo
// Used indent command on C code
//
// Revision 1.1.1.1  2004/07/05 17:31:18  jcastillo
// First import
//



unsigned int P[] = { 16, 7, 20, 21,
  29, 12, 28, 17,
  1, 15, 23, 26,
  5, 18, 31, 10,
  2, 8, 24, 14,
  32, 27, 3, 9,
  19, 13, 30, 6,
  22, 11, 4, 25
};

unsigned int IP[] = { 58, 50, 42, 34, 26, 18, 10, 2,
  60, 52, 44, 36, 28, 20, 12, 4,
  62, 54, 46, 38, 30, 22, 14, 6,
  64, 56, 48, 40, 32, 24, 16, 8,
  57, 49, 41, 33, 25, 17, 9, 1,
  59, 51, 43, 35, 27, 19, 11, 3,
  61, 53, 45, 37, 29, 21, 13, 5,
  63, 55, 47, 39, 31, 23, 15, 7
};

unsigned int IP_1[] = { 40, 8, 48, 16, 56, 24, 64, 32,
  39, 7, 47, 15, 55, 23, 63, 31,
  38, 6, 46, 14, 54, 22, 62, 30,
  37, 5, 45, 13, 53, 21, 61, 29,
  36, 4, 44, 12, 52, 20, 60, 28,
  35, 3, 43, 11, 51, 19, 59, 27,
  34, 2, 42, 10, 50, 18, 58, 26,
  33, 1, 41, 9, 49, 17, 57, 25
};

unsigned int PC_1[] = { 57, 49, 41, 33, 25, 17, 9,
  1, 58, 50, 42, 34, 26, 18,
  10, 2, 59, 51, 43, 35, 27,
  19, 11, 3, 60, 52, 44, 36,
  63, 55, 47, 39, 31, 23, 15,
  7, 62, 54, 46, 38, 30, 22,
  14, 6, 61, 53, 45, 37, 29,
  21, 13, 5, 28, 20, 12, 4
};

unsigned int PC_2[] = { 14, 17, 11, 24, 1, 5,
  3, 28, 15, 6, 21, 10,
  23, 19, 12, 4, 26, 8,
  16, 7, 27, 20, 13, 2,
  41, 52, 31, 37, 47, 55,
  30, 40, 51, 45, 33, 48,
  44, 49, 39, 56, 34, 53,
  46, 42, 50, 36, 29, 32
};

unsigned int E[] = { 32, 1, 2, 3, 4, 5,
  4, 5, 6, 7, 8, 9,
  8, 9, 10, 11, 12, 13,
  12, 13, 14, 15, 16, 17,
  16, 17, 18, 19, 20, 21,
  20, 21, 22, 23, 24, 25,
  24, 25, 26, 27, 28, 29,
  28, 29, 30, 31, 32, 1
};

unsigned int key_shifts[] =
  { 1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1 };

unsigned int rotate_C_1[] = { 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 1, 29, 30, 31, 32
};

unsigned int rotate_C_2[] = { 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 1, 2, 29, 30, 31, 32
};

unsigned int rotate_D_1[] =
  { 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 5
};

unsigned int rotate_D_2[] =
  { 1, 2, 3, 4, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
  22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 5, 6
};

unsigned int S1[] = { 14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7,
  0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8,
  4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0,
  15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13
};

unsigned int S2[] = { 15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10,
  3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5,
  0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15,
  13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9
};

unsigned int S3[] = { 10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8,
  13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1,
  13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7,
  1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12
};

unsigned int S4[] = { 7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15,
  13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9,
  10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4,
  3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14
};

unsigned int S5[] = { 2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9,
  14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6,
  4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14,
  11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3
};

unsigned int S6[] = { 12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11,
  10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8,
  9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6,
  4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13
};

unsigned int S7[] = { 4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1,
  13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6,
  1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2,
  6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12
};

unsigned int S8[] = { 13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7,
  1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2,
  7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8,
  2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11
};


void
apply_table (unsigned char *block, unsigned char *block_t, unsigned int *perm,
	     int outlength)
{
  unsigned int i, byte, bit;

  for (i = 0; i < outlength >> 3; i++)
    block_t[i] = 0;

  for (i = 0; i < outlength; i++)
    {
      byte = ((perm[i] - 1) >> 3);	/*In which byte of the original block is the bit to permute */
      bit = ((perm[i] - 1) & 7);	/*In which pos of the byte is the bit to permute */
      if ((block[byte] >> (7 - bit)) & 1 == 1)
	block_t[i >> 3] += (0x80 >> (i & 7));
    }
}

void
generate_key (unsigned char *previous_key, unsigned char *new_key,
	      int iteration)
{
  /*Generates the next iteration non permuted key from the previous non-permuted key */

  unsigned char Cx_rotated[4], Dx_rotated[4];
  unsigned char Cx[4], Dx[4];
  unsigned int i;

  for (i = 0; i < 7; i++)
    new_key[i] = 0;


  /*We split the 56 bit key in two parts */
  Cx[0] = previous_key[0];
  Cx[1] = previous_key[1];
  Cx[2] = previous_key[2];
  Cx[3] = previous_key[3];
  Dx[0] = previous_key[3];
  Dx[1] = previous_key[4];
  Dx[2] = previous_key[5];
  Dx[3] = previous_key[6];

  /*Rotate Cx and Dx */
  if (key_shifts[iteration - 1] == 1)
    {
      apply_table (Cx, Cx_rotated, rotate_C_1, 32);
      apply_table (Dx, Dx_rotated, rotate_D_1, 32);
    }
  else if (key_shifts[iteration - 1] == 2)
    {
      apply_table (Cx, Cx_rotated, rotate_C_2, 32);
      apply_table (Dx, Dx_rotated, rotate_D_2, 32);
    }

  //binary_print(previous_key,7);
  //binary_print(Cx_rotated,4);
  //binary_print(Dx_rotated,4);

  /*Recompose key */
  new_key[0] = Cx_rotated[0];
  new_key[1] = Cx_rotated[1];
  new_key[2] = Cx_rotated[2];
  new_key[3] = (Cx_rotated[3] & 0xF0);

  new_key[3] += Dx_rotated[0] & 0xF;
  new_key[4] = Dx_rotated[1];
  new_key[5] = Dx_rotated[2];
  new_key[6] = Dx_rotated[3];

  //binary_print(new_key,7);   
}

void
applyS (unsigned char *KER, unsigned char *KERS)
{

  unsigned char aux;
  int i;
  unsigned short int row, col;

  for (i = 0; i < 4; i++)
    KERS[i] = 0;

  /*Transform KER with S matrix */
  row = ((KER[0] >> 2) & 1) + ((KER[0] & 0x80) >> 6);
  aux = KER[0] << 1;
  col = aux >> 4;
  KERS[0] = S1[16 * row + col];

  row = (KER[0] & 2) + ((KER[1] >> 4) & 1);
  col = ((KER[0] & 1) << 3) + (KER[1] >> 5);
  KERS[0] = (KERS[0] << 4) + S2[16 * row + col];

  row = ((KER[1] >> 2) & 2) + ((KER[2] >> 6) & 1);
  col = ((KER[1] & 7) << 1) + ((KER[2] & 0x80) >> 7);
  KERS[1] = S3[16 * row + col];

  row = ((KER[2] >> 4) & 2) + (KER[2] & 1);
  col = (KER[2] >> 1) & 0xF;
  KERS[1] = (KERS[1] << 4) + S4[16 * row + col];

  row = ((KER[3] >> 2) & 1) + ((KER[3] & 0x80) >> 6);
  aux = KER[3] << 1;
  col = aux >> 4;
  KERS[2] = S5[16 * row + col];

  row = (KER[3] & 2) + ((KER[4] >> 4) & 1);
  col = ((KER[3] & 1) << 3) + (KER[4] >> 5);
  KERS[2] = (KERS[2] << 4) + S6[16 * row + col];

  row = ((KER[4] >> 2) & 2) + ((KER[5] >> 6) & 1);
  col = ((KER[4] & 7) << 1) + ((KER[5] & 0x80) >> 7);
  KERS[3] = S7[16 * row + col];

  row = ((KER[5] >> 4) & 2) + (KER[5] & 1);
  col = (KER[5] >> 1) & 0xF;
  KERS[3] = (KERS[3] << 4) + S8[16 * row + col];

}

void
encrypt_des (unsigned char *block, unsigned char *block_o, unsigned char *key)
{

  unsigned char block_t[8];
  unsigned char new_key[7], permuted_key[6], ER[6], last_key[7];
  unsigned char KER[6];
  unsigned char KERS[4];	/*32 bits after apply the S matrix */
  unsigned char fKERS[4];	/*32 bits after apply the P matrix */

  int i, j;
  unsigned char b0_t, b1_t, b2_t, b3_t;

  /*This is the main DES encrypt function
     encrypt one block of 64 bits with a key of 64 bits */

  /*First we generate the permuted key of 56 bits from the 64 bits one */
  apply_table (key, last_key, PC_1, 7 * 8);
  /*Now we have the K+ key of 56 bits */

  /*We generate the first permuted block */
  apply_table (block, block_t, IP, 8 * 8);


  /*16 iterations */
  for (i = 1; i < 17; i++)
    {
      generate_key (last_key, new_key, i);
      for (j = 0; j < 7; j++)
	last_key[j] = new_key[j];
      apply_table (new_key, permuted_key, PC_2, 6 * 8);

      /*We now calculate f(R,K) */
      /*Compute E(R0) */
      apply_table (block_t + 4, ER, E, 6 * 8);
      /*Key XOR ER */
      for (j = 0; j < 6; j++)
	KER[j] = ER[j] ^ permuted_key[j];

      applyS (KER, KERS);
      apply_table (KERS, fKERS, P, 4 * 8);

      /*Make the aditions */
      /*Li=Ri-1 */
      b0_t = block_t[0];
      b1_t = block_t[1];
      b2_t = block_t[2];
      b3_t = block_t[3];
      block_t[0] = block_t[4];
      block_t[1] = block_t[5];
      block_t[2] = block_t[6];
      block_t[3] = block_t[7];
      /*Ri=Li-1+fKERS */
      block_t[4] = b0_t ^ fKERS[0];
      block_t[5] = b1_t ^ fKERS[1];
      block_t[6] = b2_t ^ fKERS[2];
      block_t[7] = b3_t ^ fKERS[3];
    }
  /*Recolocate L and R */
  b0_t = block_t[0];
  b1_t = block_t[1];
  b2_t = block_t[2];
  b3_t = block_t[3];
  block_t[0] = block_t[4];
  block_t[1] = block_t[5];
  block_t[2] = block_t[6];
  block_t[3] = block_t[7];
  block_t[4] = b0_t;
  block_t[5] = b1_t;
  block_t[6] = b2_t;
  block_t[7] = b3_t;

  /*Final permutation */
  apply_table (block_t, block_o, IP_1, 8 * 8);

}

void
decrypt_des (unsigned char *block, unsigned char *block_o, unsigned char *key)
{
  unsigned char block_t[8];
  unsigned char new_key[7], permuted_key[6], ER[6], last_key[7];
  unsigned char KER[6];
  unsigned char KERS[4];	/*32 bits after apply the S matrix */
  unsigned char fKERS[4];	/*32 bits after apply the P matrix */
  unsigned char keys[16][6];

  int i, j;
  unsigned char b0_t, b1_t, b2_t, b3_t;

  /*This is the main DES decrypt function
     encrypt one block of 64 bits with a key of 64 bits */

  /*First we generate the permuted key of 56 bits from the 64 bits one */
  apply_table (key, last_key, PC_1, 7 * 8);
  /*Now we have the K+ key of 56 bits */

  /*We generate the first permuted block */
  apply_table (block, block_t, IP, 8 * 8);

  for (i = 1; i < 17; i++)
    {
      generate_key (last_key, new_key, i);
      for (j = 0; j < 7; j++)
	last_key[j] = new_key[j];
      apply_table (new_key, permuted_key, PC_2, 6 * 8);
      for (j = 0; j < 6; j++)
	keys[i - 1][j] = permuted_key[j];
    }

  /*16 iterations */
  for (i = 1; i < 17; i++)
    {
      /*We now calculate f(R,K) */
      /*Compute E(R0) */
      apply_table (block_t + 4, ER, E, 6 * 8);
      /*Key XOR ER */
      for (j = 0; j < 6; j++)
	KER[j] = ER[j] ^ keys[15 - (i - 1)][j];

      applyS (KER, KERS);
      apply_table (KERS, fKERS, P, 4 * 8);

      /*Make the aditions */
      /*Li=Ri-1 */
      b0_t = block_t[0];
      b1_t = block_t[1];
      b2_t = block_t[2];
      b3_t = block_t[3];
      block_t[0] = block_t[4];
      block_t[1] = block_t[5];
      block_t[2] = block_t[6];
      block_t[3] = block_t[7];
      /*Ri=Li-1+fKERS */
      block_t[4] = b0_t ^ fKERS[0];
      block_t[5] = b1_t ^ fKERS[1];
      block_t[6] = b2_t ^ fKERS[2];
      block_t[7] = b3_t ^ fKERS[3];
    }
  /*Recolocate L and R */
  b0_t = block_t[0];
  b1_t = block_t[1];
  b2_t = block_t[2];
  b3_t = block_t[3];
  block_t[0] = block_t[4];
  block_t[1] = block_t[5];
  block_t[2] = block_t[6];
  block_t[3] = block_t[7];
  block_t[4] = b0_t;
  block_t[5] = b1_t;
  block_t[6] = b2_t;
  block_t[7] = b3_t;

  /*Final permutation */
  apply_table (block_t, block_o, IP_1, 8 * 8);

}
