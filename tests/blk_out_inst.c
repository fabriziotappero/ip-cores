/*
 * This test covers the four block OUT instructions OUTI, OUTD,
 * OTIR, and OTDR.  The test works by first creating a buffer
 * of data, then doing a block-out instruction from the buffer
 * to a special checksum output port.
 *
 * The test self-checks by performing a checksum of the buffer
 * and comparing it with the result read out of the checksum
 * port.
 */

#include "tv80_env.h"

#define BUF_SIZE 128

char buf[BUF_SIZE];

char cksum_up (char *buf, char len) {
  // pointer should be in 4(ix) and 5(ix), length in 6(ix)
  cksum_value = 0;
  _asm
    ld   l, 4(ix)
    ld   h, 5(ix)
    ld   b, 6(ix)
    ld   c, #_cksum_accum
    otir
    in   a, (_cksum_value)
    ld   l, a
  _endasm;
}

char cksum_dn (char *buf, char len) {
  // pointer should be in 4(ix) and 5(ix), length in 6(ix)
  cksum_value = 0;
  //buf += BUF_SIZE-1;
  _asm
    ld   de, #127
    ld   l, 4(ix)
    ld   h, 5(ix)
    add  hl, de
    ld   b, 6(ix)
    ld   c, #_cksum_accum
    otdr
    in   a, (_cksum_value)
    ld   l, a
  _endasm;
}

char cksum_up_sn (char *buf, char len) {
  // pointer should be in 4(ix) and 5(ix), length in 6(ix)
  cksum_value = 0;

  _asm
    ld   l, 4(ix)
    ld   h, 5(ix)
    ld   b, 6(ix)
    ld   c, #_cksum_accum
    ld   a, #0

cksum_up_sn_loop:
    outi
    cp   b
    jp   nz, cksum_up_sn_loop

    in   a, (_cksum_value)
    ld   l, a
  _endasm;
}

char cksum_dn_sn (char *buf, char len) {
  // pointer should be in 4(ix) and 5(ix), length in 6(ix)
  cksum_value = 0;

  _asm
    ld   de, #127
    ld   l, 4(ix)
    ld   h, 5(ix)
    add  hl, de
    ld   b, 6(ix)
    ld   c, #_cksum_accum
    ld   a, #0

cksum_dn_sn_loop:
    outd
    cp   b
    jp   nz, cksum_dn_sn_loop

    in   a, (_cksum_value)
    ld   l, a
  _endasm;
}

char cksum_asm (char *buf, char len) {
  _asm
    ld   l, 4(ix)
    ld   h, 5(ix)
    ld   b, 6(ix)
    ld   c, #0
    cksum_asm_loop:
    ld   a, c
    add  a, (hl)
    ld   c, a
    inc  hl
    djnz cksum_asm_loop
    ld   l, c
  _endasm;
}

char cksum_sw (char *buf, int len) {
  char rv; int i;

  rv = 0;
  for (i=0; i<len; i++) {
    rv += buf[i];
  }

  return rv;
}

int main ()
{
  unsigned char cs_a, cs_b;
  int  i;

  max_timeout_high = 0xff;

  for (i=0; i<BUF_SIZE; i++) {
    buf[i] = i+1;
    //timeout_port = 3;
  }

  print ("Checking OTIR\n");
  cs_a = cksum_sw (buf, BUF_SIZE);
  cs_b = cksum_up (buf, BUF_SIZE);

  if (cs_a != cs_b)
    sim_ctl (SC_TEST_FAILED);

  print ("Checking OTDR\n");
  cs_b = cksum_dn  (buf, BUF_SIZE);

  if (cs_a != cs_b)
    sim_ctl (SC_TEST_FAILED);

  print ("Checking OUTI\n");

  cs_b = cksum_up_sn (buf, BUF_SIZE);
  if (cs_a != cs_b)
    sim_ctl (SC_TEST_FAILED);

  print ("Checking OUTD\n");

  cs_b = cksum_dn_sn (buf, BUF_SIZE);
  if (cs_a == cs_b)
    sim_ctl (SC_TEST_PASSED);
  else
    sim_ctl (SC_TEST_FAILED);

  return 0;
}
