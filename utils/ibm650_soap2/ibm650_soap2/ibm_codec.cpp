//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: An implementation of SOAP 2 for the IBM 650.
// 
// Additional Comments: .
//
// Copyright (c) 2015 Robert Abeles
//
// This source file is free software; you can redistribute it
// and/or modify it under the terms of the GNU Lesser General
// Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any
// later version.
//
// This source is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE.  See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General
// Public License along with this source; if not, download it
// from http://www.opencores.org/lgpl.shtml
//////////////////////////////////////////////////////////////////////////////////

#include "ibm_codec.h"
#include <iostream>
#include <iomanip>

using namespace std;

// -------------------------------------------------------------------------
// Hollerith zone and digit punches.
// -------------------------------------------------------------------------
enum holl_zn {
  holl_znone,
  holl_z0,
  holl_z11,     // aka X punch
  holl_z12      // aka Y punch
};
enum holl_dig {
  holl_dnone,
  holl_d0,
  holl_d1,
  holl_d2,
  holl_d3,
  holl_d4,
  holl_d5,
  holl_d6,
  holl_d7,
  holl_d8,
  holl_d9,
  holl_d8_2,
  holl_d8_3,
  holl_d8_4,
  holl_d8_5,
  holl_d8_6,
  holl_d8_7
};

// -------------------------------------------------------------------------
// Glyph specification.
// -------------------------------------------------------------------------
struct glyph_spec {
    holl_zn  zone;
    holl_dig digit;
    int      unicode;
    int      ascii;
    int      keycode; // Qt keycode
    int      code650;
    int      bcd704;
    int      bcd705;
    int      codeset;
};

// -------------------------------------------------------------------------
// Not all BCD characters have readily available keyboard equivalents.
// To these characters, we assign a modifier plus an alphabetic key.
// When the keycode field is not negative, it contains the unmodified
// keycode of the alphabetic key that when entered with a platform-
// pecific modifier key will enter the unavailable code. For example,
// pressing alt-R on a Mac will enter the unicode 'square root' character.
// Pressing the modifier key with a digit, '-', or '=' key will act
// as a multipunch, where '-' is an 11 punch and '=' is a 12 punch.
//
// The special characters in the final group, shown below, have
// several alternate encodings, designated by IBM as special character
// arrangements A through K. Encodings A, F and H are implemented above.
//
// A - &.^-$*,%/#@
// B - /.^-$*,%&#@
// C - &.^-$*,%0#@
// D - -.^-$*,%/#@
// E - -.<./*,%&#>
// F - +.)-$*,(/=-
// G - +.^-$*,%/+-
// H - +.)-$*,(/='
// J - +.^-$*,%/#@
// K - +.)-$*,(/=@
//
// In addition to the standard 48 BCD encodings shown above, the 705
// uses 6 additional encodings, 4 for marks (tape mark, record mark,
// group mark, storage and drum mark), and 2 encodings for signed zeroes
// (plus zero, minus zero).
//
// A word about marks. Some of the BCD character codes have special meaning to
// early IBM business computers. The 702 and its successor machines (705, 7070)
// were 'character oriented', i.e., they operated on variable length BCD character
// strings. Mark characters ('tape mark', 'record mark', 'group mark',
// 'segment mark', and 'word separator') served to delineate variable length
// objects on tape and in memory.
//
// In fact, a six bit character can have 64 unique values. The remaining
// unused BCD character codes were assigned by subsequent machines until
// all possible codes were accounted for. Mappings between BCD and Hollerith
// remain stable across the IBM product line, but glyph assignment differs
// between systems, options, and RPQs.
// -------------------------------------------------------------------------
#define A48 cs_bcd48_a
#define F48 cs_bcd48_f
#define H48 cs_bcd48_h
#define BCD48 cs_bcd48
#define BCD64 cs_bcd64

static glyph_spec glyph_codes[] = {
//   zone        digit      unicode ascii keycd 650 704  14xx codeset(s)
//                                              BCD BCD  BCD
    {holl_znone, holl_dnone, ' ',    ' ',  -1,  00, 060, 000, BCD48},
    {holl_znone, holl_d0,    '0',    '0',  -1,  90, 000, 012, BCD48},
    {holl_znone, holl_d1,    '1',    '1',  -1,  91, 001, 001, BCD48},
    {holl_znone, holl_d2,    '2',    '2',  -1,  92, 002, 002, BCD48},
    {holl_znone, holl_d3,    '3',    '3',  -1,  93, 003, 003, BCD48},
    {holl_znone, holl_d4,    '4',    '4',  -1,  94, 004, 004, BCD48},
    {holl_znone, holl_d5,    '5',    '5',  -1,  95, 005, 005, BCD48},
    {holl_znone, holl_d6,    '6',    '6',  -1,  96, 006, 006, BCD48},
    {holl_znone, holl_d7,    '7',    '7',  -1,  97, 007, 007, BCD48},
    {holl_znone, holl_d8,    '8',    '8',  -1,  98, 010, 010, BCD48},
    {holl_znone, holl_d9,    '9',    '9',  -1,  99, 011, 011, BCD48},

    {holl_z12,   holl_d0,    '?',    '?',  -1,  -1, 032, 072, BCD64},  // plus zero
    {holl_z12,   holl_d1,    'A',    'A',  -1,  61, 021, 061, BCD48},
    {holl_z12,   holl_d2,    'B',    'B',  -1,  62, 022, 062, BCD48},
    {holl_z12,   holl_d3,    'C',    'C',  -1,  63, 023, 063, BCD48},
    {holl_z12,   holl_d4,    'D',    'D',  -1,  64, 024, 064, BCD48},
    {holl_z12,   holl_d5,    'E',    'E',  -1,  65, 025, 065, BCD48},
    {holl_z12,   holl_d6,    'F',    'F',  -1,  66, 026, 066, BCD48},
    {holl_z12,   holl_d7,    'G',    'G',  -1,  67, 027, 067, BCD48},
    {holl_z12,   holl_d8,    'H',    'H',  -1,  68, 030, 070, BCD48},
    {holl_z12,   holl_d9,    'I',    'I',  -1,  69, 031, 071, BCD48},

    {holl_z11,   holl_d0,    '!',    '!',  -1,  -1, 052, 052, BCD64},  // minus zero
    {holl_z11,   holl_d1,    'J',    'J',  -1,  71, 041, 041, BCD48},
    {holl_z11,   holl_d2,    'K',    'K',  -1,  72, 042, 042, BCD48},
    {holl_z11,   holl_d3,    'L',    'L',  -1,  73, 043, 043, BCD48},
    {holl_z11,   holl_d4,    'M',    'M',  -1,  74, 044, 044, BCD48},
    {holl_z11,   holl_d5,    'N',    'N',  -1,  75, 045, 045, BCD48},
    {holl_z11,   holl_d6,    'O',    'O',  -1,  76, 046, 046, BCD48},
    {holl_z11,   holl_d7,    'P',    'P',  -1,  77, 047, 047, BCD48},
    {holl_z11,   holl_d8,    'Q',    'Q',  -1,  78, 050, 050, BCD48},
    {holl_z11,   holl_d9,    'R',    'R',  -1,  79, 051, 051, BCD48},

    {holl_z0,    holl_d1,    '/',    '/',  -1,  31, 061, 021, A48+F48+H48},
    {holl_z0,    holl_d2,    'S',    'S',  -1,  82, 062, 022, BCD48},
    {holl_z0,    holl_d3,    'T',    'T',  -1,  83, 063, 023, BCD48},
    {holl_z0,    holl_d4,    'U',    'U',  -1,  84, 064, 024, BCD48},
    {holl_z0,    holl_d5,    'V',    'V',  -1,  85, 065, 025, BCD48},
    {holl_z0,    holl_d6,    'W',    'W',  -1,  86, 066, 026, BCD48},
    {holl_z0,    holl_d7,    'X',    'X',  -1,  87, 067, 027, BCD48},
    {holl_z0,    holl_d8,    'Y',    'Y',  -1,  88, 070, 030, BCD48},
    {holl_z0,    holl_d9,    'Z',    'Z',  -1,  89, 071, 031, BCD48},

    {holl_z12,   holl_dnone, '&',    '&',  -1,  20, 020, 060, A48},
    {holl_z12,   holl_dnone, '+',    '+',  -1,  20, 020, 060, F48+H48},
    {holl_z12,   holl_d8_3,  '.',    '.',  -1,  18, 033, 073, A48+F48+H48},
    {holl_z12,   holl_d8_4, L'⌑',    '^', 'L',  19, 034, 074, A48},    // unicode 'square lozenge'
    {holl_z12,   holl_d8_4,  ')',    ')',  -1,  19, 034, 074, F48+H48},
    {holl_z12,   holl_d8_5,  '[',    '[',  -1,  -1, 035, 075, BCD64},
    {holl_z12,   holl_d8_6,  '<',    '<',  -1,  -1, 036, 076, BCD64},
    {holl_z12,   holl_d8_7,L'\uF000', -1, 'G',  -1, 037, 077, BCD64},  // group mark, use uF000 for triple dagger

    {holl_z11,   holl_dnone, '-',    '-',  -1,  30, 040, 040, A48+F48+H48},
    {holl_z11,   holl_d8_3,  '$',    '$',  -1,  28, 053, 053, A48+F48+H48},
    {holl_z11,   holl_d8_4,  '*',    '*',  -1,  29, 054, 054, A48+F48+H48},
    {holl_z11,   holl_d8_5,  ']',    ']',  -1,  29, 055, 055, BCD64},
    {holl_z11,   holl_d8_6,  ';',    ';',  -1,  29, 056, 056, BCD64},
    {holl_z11,   holl_d8_7,L'\uF004', -1, 'D',  29, 057, 057, BCD64},  // delta -> unicode uppercase delta

    {holl_z0,    holl_d8_2, L'‡',     -1, 'R',  -1, 073, 033, BCD64},  // record mark -> double dagger
    {holl_z0,    holl_d8_3,  ',',    ',',  -1,  38, 073, 033, A48+F48+H48},
    {holl_z0,    holl_d8_4,  '%',    '%',  -1,  39, 074, 034, A48},
    {holl_z0,    holl_d8_4,  '(',    '(',  -1,  39, 074, 034, F48+H48},
    {holl_z0,    holl_d8_5,L'\u2423', -1, 'W',  -1, 075, 035, BCD64},  // word separator -> open box
    {holl_z0,    holl_d8_6, '\\',    '\\', -1,  -1, 076, 036, BCD64},  // left oblique
    {holl_z0,    holl_d8_7,L'\u29FB', -1, 'S',  -1, 077, 037, BCD64},  // segment mark -> triple plus

    {holl_znone, holl_d8_2,L'\u2422',' ', ' ',  -1, 060, 020, BCD64},  // alternate blank
    {holl_znone, holl_d8_3,  '#',    '#',  -1,  48, 013, 013, A48},
    {holl_znone, holl_d8_3,  '=',    '=',  -1,  48, 013, 013, F48+H48},
    {holl_znone, holl_d8_4,  '@',    '@',  -1,  49, 014, 014, A48},
    {holl_znone, holl_d8_4,  '-',    '-',  -1,  49, 014, 014, F48},    // FORTRAN's other minus
    {holl_znone, holl_d8_4,  '\'',   '\'', -1,  49, 014, 014, H48},
    {holl_znone, holl_d8_5,  ':',    ':',  -1,  -1, 015, 015, BCD64},  // colon
    {holl_znone, holl_d8_6,  '>',    '>',  -1,  -1, 016, 016, BCD64},  // greater than
    {holl_znone, holl_d8_7, L'√',     -1, 'T',  -1, 017, 017, BCD64}   // radical
};

static uint16_t make_holl(int z, int d)
{
    uint16_t h = 0;
    switch (z) {
        case holl_znone:
            break;
        case holl_z0:
            h += (1 << 9);
            break;
        case holl_z11:
            h += (1 << 10);
            break;
        case holl_z12:
            h += (1 << 11);
            break;
        default:
            break;
    }
    switch (d) {
        case holl_dnone:
            break;
        case holl_d0:
            h += (1 << 9);
            break;
        case holl_d1:
            h += (1 << 8);
            break;
        case holl_d2:
            h += (1 << 7);
            break;
        case holl_d3:
            h += (1 << 6);
            break;
        case holl_d4:
            h += (1 << 5);
            break;
        case holl_d5:
            h += (1 << 4);
            break;
        case holl_d6:
            h += (1 << 3);
            break;
        case holl_d7:
            h += (1 << 2);
            break;
        case holl_d8:
            h += (1 << 1);
            break;
        case holl_d9:
            h += (1 << 0);
            break;
        case holl_d8_2:
            h += (1 << 1) + (1 << 7);
            break;
        case holl_d8_3:
            h += (1 << 1) + (1 << 6);
            break;
        case holl_d8_4:
            h += (1 << 1) + (1 << 5);
            break;
        case holl_d8_5:
            h += (1 << 1) + (1 << 4);
            break;
        case holl_d8_6:
            h += (1 << 1) + (1 << 3);
            break;
        case holl_d8_7:
            h += (1 << 1) + (1 << 2);
            break;
        default:
            break;
    }
    return h;
}

void ibm_codec::setup_tables(int c) {
    hollerith_to_code650_.resize(4096);
    code650_to_hollerith_.resize(100);
    hollerith_to_unicode_.resize(4096);
    unicode_to_hollerith_.resize(65536);
    hollerith_to_ascii_  .resize(4096);
    ascii_to_hollerith_  .resize(256);
    ascii_to_code650_    .resize(256);
    code650_to_ascii_    .resize(100);
    keycode_to_unicode_  .resize(256);

    // mark all translations invalid (-1)
    for (int i = 0; i < 65536; i++) {
        unicode_to_hollerith_[i] = -1;
        if (i < 4096) {
            hollerith_to_code650_[i] = -1;
            hollerith_to_unicode_[i] = -1;
            hollerith_to_ascii_[i]   = -1;
        }
        if (i < 256) {
            ascii_to_code650_[i]     = -1;
            ascii_to_hollerith_[i]   = -1;
            keycode_to_unicode_[i]   = -1;
        }
        if (i < 100) {
            code650_to_hollerith_[i] = -1;
            code650_to_ascii_[i]     = -1;
        }
    }

    // Fill in glyphs from table that are in the specified codeset(s).
    // When multiple glyphs map to the same codepoint, the first
    // glyph encoutered in the table occupying a codepoint takes
    // precedence.
    for (auto glyph : glyph_codes) {
        if (!(glyph.codeset & c)) continue;
        uint16_t hcode = make_holl(glyph.zone, glyph.digit);
        if (hollerith_to_code650_[hcode] < 0)
            hollerith_to_code650_[hcode] = glyph.code650;
        if (code650_to_hollerith_[glyph.code650] < 0)
            code650_to_hollerith_[glyph.code650] = hcode;
        if (hollerith_to_unicode_[hcode] < 0)
            hollerith_to_unicode_[hcode] = glyph.unicode;
        if (unicode_to_hollerith_[glyph.unicode] < 0)
            unicode_to_hollerith_[glyph.unicode] = hcode;
        if (keycode_to_unicode_[glyph.keycode] < 0)
            keycode_to_unicode_[glyph.keycode] = glyph.unicode;
        if (hollerith_to_ascii_[hcode] < 0)
            hollerith_to_ascii_[hcode] = glyph.ascii;
        if (ascii_to_hollerith_[glyph.ascii] < 0)
            ascii_to_hollerith_[glyph.ascii] = hcode;
        if (ascii_to_code650_[glyph.ascii] < 0)
            ascii_to_code650_[glyph.ascii] = glyph.code650;
        if (code650_to_ascii_[glyph.code650] < 0)
            code650_to_ascii_[glyph.code650] = glyph.ascii;
    }
}
