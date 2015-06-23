//////////////////////////////////////////////////////////////////////////////////
// IBM 650 Reconstruction in Verilog (i650)
// 
// This file is part of the IBM 650 Reconstruction in Verilog (i650) project
// http:////www.opencores.org/project,i650
//
// Description: An implementation of SOAP 2 for the IBM 650.
// 
// Additional Comments:
//
// Code translation tables for character codes used by early IBM data processing
// machines. An ibm_codec object translates codes for a specific codeset between
// Unicode or ASCII and a number of machine-specific codes.
//
// Hollerith code is a 12-bit code representing a column on an IBM punched card.
// The 12-bit column is split into zones and digits, a zero punch being both a
// zone and a digit. Zone punches are 12, 11, zero, and none, while digit
// punches are zero, 1, 2, ... 8, and 9. If all 12 rows of a card column are
// utilized, there are 1024 possible codes per column. In practice, codes
// were restricted to a single zone punch combined with one or two digit punches.
// For codes where two digit punches are used, one of those punches will be an 8.
// The zero punch may act as either a zone or digit: It is considered to be a
// digit when it appears alone or combined an 11 or 12 punch, otherwise it acts
// as a zone punch.
//
// Binary Coded Decimal (BCD) is a 6-bit code made up of a 2-bit zone code and a
// 4-bit digit code, providing up to 64 unique codes. Tape (the usual destination
// and source for BCD data) adds an additional parity bit. The bits comprising
// BCD characters were recorded on 1/2" magnetic tape in 7 parallel tracks.
//
// Due to its method of operation, a BCD character on tape may not consist of
// all zero bits. Automatic conversion is provided by the tape hardware between
// an even parity BCD zero (000) and a BCD 'substitute blank' (0020) character
// when writing to tape. Likewise, a substitute blank is converted to a BCD zero
// when reading a tape in even parity mode. Tapes written in odd parity mode
// suffer no such limitations because an odd parity BCD zero (0100) already has
// a bit set.
//
// Present in the BCD character set are codes that have special meaning to various
// hardware devices. Generally called marks, they serve to delineate character
// data in various ways. As used by IBM tape systems, the 'tape mark' character is
// used to delineate a file on tape. Tape hardware may search independently of the
// CPU for tape marks, accelerating certain types of tape processing.
//
// In even parity mode, the 704 tape hardware automatically modifies the BCD zone
// bits. This translation preserves the BCD collating sequence when character
// comparisons are performed by binary magnitude comparison.
//
// Collating sequence is an important property of any character set. An
// examination of BCD codes shows that simply sorting by the binary magnitude
// of the codes will not yield a useful collating sequence. Hardware or
// software methods are needed to sort this character set. The 701/704/709/709x
// family of machines translated BCD on its way to and from tape when operating
// in the even parity mode. Translation conisted of reassigning zones so that
// BCD alphabetic characters sorted naturally, but did not help with special
// characters. The 14xx machines incorporated complex hardware logic to compare
// BCD codes directly, resulting in what we consider to be the authoritative BCD
// collating sequence. See fig. 64 in A24-3116-0, "System Operation Reference
// Manual, IBM 1440 Data Processing System". The 1401 BCD compare logic can
// be found in system diagrams 44.30.11.2, 44.31.11.2, 44.32.11.2, 44.33.11.2,
// 44.34.11.2, 44.34.21.2, and 44.34.31.2.
//
// Early machines used modified card machines (ex. 407 for 704 printer) for unit
// record I/O, and so were limited to the 48 character BCD codeset supported by
// these machines.
//
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

#ifndef __ibm650_soap2__ibm_codec__
#define __ibm650_soap2__ibm_codec__

#include <stdint.h>
#include <vector>

// -------------------------------------------------------------------------------
// Selects the character code set. Selections may be combined, for example to
// select the FORTRAN 48 character BCD set, specify cs_bcd48+cs_bcd48_f.
// -------------------------------------------------------------------------------
enum ibm_codeset {
  cs_bcd48       = 0x00000001, // 36 letters and digits   BCD codeset
  cs_bcd48_a     = 0x00000002, // commercial 48 character BCD codeset
  cs_bcd48_f     = 0x00000004, // FORTRAN    48 character BCD codeset
  cs_bcd48_h     = 0x00000008, // scientific 48 character BCD codeset
  cs_bcd64       = 0x00000010  // 64 character            BCD codeset
};

// -------------------------------------------------------------------------------
// Binary Hollerith punch codes.
// -------------------------------------------------------------------------------
enum {
  holl_12_punch = (1 << 11),
  holl_11_punch = (1 << 10),
  holl_0_punch  = (1 << 9),
  holl_1_punch  = (1 << 8),
  holl_2_punch  = (1 << 7),
  holl_3_punch  = (1 << 6),
  holl_4_punch  = (1 << 5),
  holl_5_punch  = (1 << 4),
  holl_6_punch  = (1 << 3),
  holl_7_punch  = (1 << 2),
  holl_8_punch  = (1 << 1),
  holl_9_punch  = (1 << 0)
};

// -------------------------------------------------------------------------------
// Class ibm_codec.
// -------------------------------------------------------------------------------
class ibm_codec {
  std::vector<int8_t>  hollerith_to_code650_;
  std::vector<int16_t> code650_to_hollerith_;
  std::vector<int32_t> hollerith_to_unicode_;
  std::vector<int16_t> unicode_to_hollerith_;
  std::vector<int32_t> keycode_to_unicode_;
  std::vector<int16_t> hollerith_to_ascii_;
  std::vector<int16_t> ascii_to_hollerith_;
  std::vector<int8_t>  ascii_to_code650_;
  std::vector<int16_t> code650_to_ascii_;
  void setup_tables(int);

public:
  static inline int clamp_650(int v) {
    return (v < 0) ? 0 : (v > 99) ? 99 : v;
  }
  static inline int clamp_hollerith(int v) {
    return (v < 0) ? 0 : (v > 4095) ? 4095 : v;
  }
  static inline int clamp_unicode(int v) {
    return (v < 0) ? 0 : (v > 65535) ? 65535 : v;
  }
  static inline int clamp_keycode(int v) {
    return (v < 0) ? 0 : (v > 255) ? 0 : v;
  }
  static inline int clamp_ascii(int v) {
    return (v < 0) ? 0 : (v > 255) ? 0 : v;
  }
  ibm_codec(int c)           { setup_tables(c); }
  void change_codeset(int c) { setup_tables(c); }

  inline bool valid_hollerith_for_650(int c) const {
    return code650_to_hollerith_[clamp_650(c)] >= 0;
  }
  inline uint16_t hollerith_to_unicode(int c) const {
    return clamp_unicode(hollerith_to_unicode_[clamp_hollerith(c)]);
  }
  inline bool valid_unicode_for_hollerith(int c) const {
    return hollerith_to_unicode_[clamp_hollerith(c)] >= 0;
  }
  inline uint16_t unicode_to_hollerith(int c) const {
    return clamp_hollerith(unicode_to_hollerith_[clamp_unicode(c)]);
  }
  inline bool valid_hollerith_for_unicode(int c) const {
    return unicode_to_hollerith_[clamp_unicode(c)] >= 0;
  }
  inline uint16_t keycode_to_unicode(int c) const {
    return keycode_to_unicode_[clamp_keycode(c)];
  }
  inline bool valid_unicode_for_keycode(int c) const {
    return keycode_to_unicode_[clamp_keycode(c)] >= 0;
  }
  inline uint16_t hollerith_to_ascii(int c) const {
    return clamp_unicode(hollerith_to_ascii_[clamp_hollerith(c)]);
  }
  inline uint16_t ascii_to_hollerith(int c) const {
    return clamp_hollerith(ascii_to_hollerith_[clamp_ascii(c)]);
  }
  inline bool valid_hollerith_for_ascii(int c) const {
    return ascii_to_hollerith_[clamp_ascii(c)] >= 0;
  }
  inline uint8_t ascii_to_code650(int c) const {
    return clamp_650(ascii_to_code650_[clamp_ascii(c)]);
  }
  inline bool valid_code650_for_ascii(int c) const {
    return ascii_to_code650_[clamp_ascii(c)] >= 0;
  }
  inline uint16_t code650_to_ascii(int c) const {
    return clamp_ascii(code650_to_ascii_[clamp_650(c)]);
  }
  inline bool valid_ascii_for_code650(int c) const {
    return code650_to_ascii_[clamp_650(c)] >= 0;
  }
};

#endif /* defined(__ibm650_soap2__ibm_codec__) */
