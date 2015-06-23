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

#include "soap2.h"

static addr_type get_addr_type(int32_t addr)
{
    if ((addr >= 0) && (addr <= 1999))
        return addr_gs;
    if ((addr >= 9000) && (addr <= 9059))
        return addr_ias;
    if ((addr >= 8000) && (addr <= 8003))
        return addr_800X;
    if ((addr >= 8005) && (addr <= 8007))
        return addr_800X;
    
    return addr_invalid;
}

static inline char zone_x(int c)
{
    c = (c < '0')? '0' : (c > '9')? '9' : c;
    c = (c == '0')? '!' : (c - '0' + 'J');
    return c;
}

static inline char zone_y(int c)
{
    c = (c < '0')? '0' : (c > '9')? '9' : c;
    c = (c == '0')? '?' : (c - '0' + 'A');
    return c;
}

asmfield::asmfield(const string &f, u_int8_t h) : src(f), type(field_error)
{
    if (src == "     ") {
        type = field_blank;
        return;
    }
    
    if (src[0] == ' ') {
        for (int i = 1; i < 5; i++)
            if (!isdigit(src[i])) return;
        type = field_numeric;
        nval = stoi(src.substr(1,4));
        return;
    }
    
    if (isalpha(src[0])) {
        bool numeric = true;
        for (int i = 1; i < 5; i++)
            if (!isdigit(src[i])) numeric = false;
        if (numeric) {
            type = field_region;
            nval = stoi(src.substr(1, 4));
            region = src[0];
            return;
        }
    }
    
    type = field_symbolic;
    symbol = src;
    if (symbol[4] == ' ')
        symbol[4] = h;
}

void memory::load_7wd_deck(istream &d7)
{
    bool ctl_word = true;
    bool op_fld   = true;
    bool op_d     = false;
    bool op_i     = false;
    string number = "";
    char ch;

    bool word_valid = false;
    u_int32_t addr = 0;
    bool sign = false; // true is minus
    u_int32_t op = 0;
    u_int32_t d  = 0;
    u_int32_t i  = 0;
    
    while (EOF != (ch = d7.get())) {
        if ('\n' == ch) {
            if (word_valid) {
                i = stoi(number);
                int64_t v = op * 100000000LL + d * 10000 + i;
                mem[addr].set_sign(sign);
                mem[addr].set_value(v);
                addr++;
                sign = false;
                op = d = i = 0;
                word_valid = false;
            }
            ctl_word = true;
            op_fld   = true;
            op_d     = false;
            op_i     = false;
            number   = "";
        } else if (isdigit(ch)) {
            word_valid = true;
            number += ch;
        } else if (' ' == ch) {
            if (number != "") {
                if (op_fld) {
                    op = stoi(number);
                    op_fld = false;
                    op_d = true;
                } else if (op_d) {
                    d = stoi(number);
                    op_d = false;
                    op_i = true;
                } else if (op_i) {
                    i = stoi(number);
                    op_i = false;
                    op_fld = true;
                    if (ctl_word) {
                        addr = d;
                        ctl_word = false;
                    } else {
                        int64_t v = op * 100000000LL + d * 10000 + i;
                        mem[addr].set_sign(sign);
                        mem[addr].set_value(v);
                        addr++;
                        sign = false;
                        op = d = i = 0;
                        word_valid = false;
                    }
                }
                number = "";
            }
        } else if ('-' == ch) {
            sign = true;
        }
    }
}

memmap::memmap(u_int32_t s, u_int32_t o)
    : size(s)
    , origin(o)
    , freectr(s)
{
    allocmap.resize(size, false);
}

void memmap::reserve(u_int32_t addr)
{
    if ((addr >= origin) && (addr < (origin + size))) {
        if (!allocmap[addr-origin]) {
            freectr--;
            allocmap[addr-origin] = true;
        }
    }
}

void memmap::reserve(u_int32_t fwa, u_int32_t sz)
{
    for (int i = 0; i < sz; i++)
        reserve(fwa+i);
}

void memmap::unreserve(u_int32_t addr)
{
    if ((addr >= origin) && (addr < (origin + size))) {
        if (allocmap[addr-origin]) {
            freectr--;
            allocmap[addr-origin] = false;
        }
    }
}

void memmap::unreserve(u_int32_t fwa, u_int32_t sz)
{
    for (int i= 0; i < sz; i++)
        unreserve(fwa+i);
}

void memmap::reset()
{
    for (int i = 0; i < size; i++)
        allocmap[i] = false;
    freectr = size;
}

int32_t memmap::optimum(u_int32_t rot)
{
    // 50 words per band
    // 40 bands per drum
    if (isfull())
        return -1;
    u_int32_t addr = rot;
    for (signed ctr = 0; ctr < size; ctr++) {
        if (!allocmap[addr]) {
            allocmap[addr] = true;
            freectr--;
            break;
        }
        addr += 50;
        if (addr >= size)
            addr = (addr % 50) + 1;
    }
    return addr;
}

static opcode optab[] = {
    // the flags field is encoded 8 for on, 9 for off
    // the digits in the flag field are, left to right,
    // A, B, and C.
    // A is on for index reg ops and for the SRD op
    // B is on for shift ops
    // C is on for index reg ops, shift ops, branch ops, HLT, NOP, etc.
    
    // SOAP2 decodes the flags with a nest of conditional branches.
    //
    //             |------------------------------- Decimal opcode
    //             |  |---------------------------- Idx reg ops and SRD
    //             |  ||--------------------------- Shift ops
    //             |  |||-------------------------- Idx reg, shift, branch, etc.
    //             |  |||  |----------------------- D even
    //             |  |||  |  |-------------------- D odd
    //             |  |||  |  |   |---------------- I even
    //             |  |||  |  |   |   |------------ I odd
    //             v  vvv  v  v   v   v
    opcode("ALO", 15, 999, 3, 3,  5,  4, real_op),
    opcode("AML", 17, 999, 3, 3,  5,  4, real_op),
    opcode("AUP", 10, 999, 3, 3,  5,  4, real_op),
    opcode("AXA", 50, 898, 0, 0,  0,  0, real_op),
    opcode("AXB", 52, 898, 0, 0,  0,  0, real_op),
    opcode("AXC", 58, 898, 0, 0,  0,  0, real_op),
    opcode("BDO", 90, 998, 4, 4,  5,  5, real_op),
    opcode("BD1", 91, 998, 3, 3,  5,  5, real_op),
    opcode("BD2", 92, 998, 3, 3,  5,  5, real_op),
    opcode("BD3", 93, 998, 3, 3,  5,  5, real_op),
    opcode("BD4", 94, 998, 3, 3,  5,  5, real_op),
    opcode("BD5", 95, 998, 3, 3,  5,  5, real_op),
    opcode("BD6", 96, 998, 3, 3,  5,  5, real_op),
    opcode("BD7", 97, 998, 3, 3,  5,  5, real_op),
    opcode("BD8", 98, 998, 3, 3,  5,  5, real_op),
    opcode("BD9", 99, 998, 4, 4,  5,  5, real_op),
    opcode("BIN", 26, 998, 0, 0,  5,  5, real_op),
    opcode("BMA", 41, 998, 3, 3,  4,  4, real_op),
    opcode("BMB", 43, 998, 3, 3,  4,  4, real_op),
    opcode("BMC", 49, 998, 3, 3,  4,  4, real_op),
    opcode("BMI", 46, 998, 3, 3,  4,  4, real_op),
    opcode("BOV", 47, 998, 3, 3,  5,  5, real_op),
    opcode("BST", 57, 998, 0, 0,  5,  5, real_op),
    opcode("DIV", 14, 999, 3, 3, 10, 11, real_op),  // modified from 11,10
    opcode("DVR", 64, 999, 3, 3, 11, 10, real_op),
    opcode("FAD", 32, 999, 3, 3, 27, 26, real_op),
    opcode("FAM", 37, 999, 3, 3, 27, 26, real_op),
    opcode("FDV", 34, 999, 3, 3,  0,  0, real_op),
    opcode("FMP", 39, 999, 3, 3,  0,  0, real_op),
    opcode("FSB", 33, 999, 3, 3, 27, 26, real_op),
    opcode("FSM", 38, 999, 3, 3, 27, 26, real_op),
    opcode("HLT",  1, 998, 0, 0,  4,  4, real_op),
    opcode("LDD", 69, 999, 3, 3,  3,  3, real_op),
    opcode("LDI",  9, 999, 3, 3,  2,  2, real_op),
    opcode("LIB",  8, 999, 3, 3, 12, 12, real_op),
    opcode("MPY", 19, 999, 3, 3, 20, 21, real_op),  // modified from 21,20
    opcode("NEF", 54, 998, 4, 4,  5,  5, real_op),
    opcode("NOP",  0, 998, 0, 0,  4,  4, real_op),
    opcode("NTS", 25, 998, 4, 4,  5,  5, real_op),
    opcode("NZA", 40, 998, 3, 3,  4,  4, real_op),
    opcode("NZB", 42, 998, 3, 3,  4,  4, real_op),
    opcode("NZC", 48, 998, 3, 3,  4,  4, real_op),
    opcode("NZE", 45, 998, 4, 3,  5,  4, real_op),
    opcode("NZU", 44, 998, 3, 4,  4,  5, real_op),
    opcode("RAA", 80, 898, 0, 0,  0,  0, real_op),
    opcode("RAB", 82, 898, 0, 0,  0,  0, real_op),
    opcode("RAC", 88, 898, 0, 0,  0,  0, real_op),
    opcode("RAL", 65, 999, 3, 3,  5,  4, real_op),
    opcode("RAM", 67, 999, 3, 3,  5,  4, real_op),
    opcode("RAU", 60, 999, 3, 3,  5,  4, real_op),
    opcode("RC1", 72, 999, 0, 0,  0,  0, real_op),
    opcode("RC2", 75, 999, 0, 0,  0,  0, real_op),
    opcode("RC3", 78, 999, 0, 0,  0,  0, real_op),
    opcode("RD1", 70, 999, 0, 0,  0,  0, real_op),
    opcode("RD2", 73, 999, 0, 0,  0,  0, real_op),
    opcode("RD3", 76, 999, 0, 0,  0,  0, real_op),
    opcode("RDS", 86, 998, 0, 0,  6,  6, real_op),
    opcode("RPY", 79, 999, 0, 0,  5,  5, real_op),
    opcode("RSA", 81, 898, 0, 0,  0,  0, real_op),
    opcode("RSB", 83, 898, 0, 0,  0,  0, real_op),
    opcode("RSC", 89, 898, 0, 0,  0,  0, real_op),
    opcode("RSL", 66, 999, 3, 3,  5,  4, real_op),
    opcode("RSM", 68, 999, 3, 3,  5,  4, real_op),
    opcode("RSU", 61, 999, 3, 3,  5,  4, real_op),
    opcode("RTA",  5, 998, 0, 0,  5,  5, real_op),
    opcode("RTC",  3, 998, 0, 0,  5,  5, real_op),
    opcode("RTN",  4, 998, 0, 0,  5,  5, real_op),
    opcode("RWD", 55, 998, 0, 0,  5,  5, real_op),
    opcode("SCT", 36, 988, 0, 0,  0,  0, real_op),
    opcode("SDA", 22, 999, 3, 4,  3,  3, real_op),
    opcode("SDS", 85, 998, 0, 0,  6,  6, real_op),
    opcode("SET", 27, 998, 0, 0,  5,  5, real_op),
    opcode("SIA", 23, 999, 3, 4,  3,  3, real_op),
    opcode("SIB", 28, 999, 3, 3, 12, 12, real_op),
    opcode("SLO", 16, 999, 3, 3,  5,  4, real_op),
    opcode("SLT", 35, 988, 0, 0,  0,  0, real_op),
    opcode("SML", 18, 999, 3, 3,  5,  4, real_op),
    opcode("SRD", 31, 888, 0, 0,  0,  0, real_op),
    opcode("SRT", 30, 988, 0, 0,  0,  0, real_op),
    opcode("STD", 24, 999, 3, 3,  3,  3, real_op),
    opcode("STI", 29, 999, 3, 3,  2,  2, real_op),
    opcode("STL", 20, 999, 5, 4,  3,  3, real_op),
    opcode("STU", 21, 999, 4, 5,  3,  3, real_op),
    opcode("SUP", 11, 999, 3, 3,  5,  4, real_op),
    opcode("SXA", 51, 898, 0, 0,  0,  0, real_op),
    opcode("SXB", 53, 898, 0, 0,  0,  0, real_op),
    opcode("SXC", 59, 898, 0, 0,  0,  0, real_op),
    opcode("TLU", 84, 999, 3, 3,  5,  6, real_op),
    opcode("UFA",  2, 999, 3, 3, 23, 22, real_op),
    opcode("WDS", 87, 998, 0, 0,  6,  6, real_op),
    opcode("WR1", 71, 999, 0, 0,  0,  0, real_op),
    opcode("WR2", 74, 999, 0, 0,  0,  0, real_op),
    opcode("WR3", 77, 999, 0, 0,  0,  0, real_op),
    opcode("WTA",  7, 998, 0, 0,  5,  5, real_op),
    opcode("WTM", 56, 998, 0, 0,  5,  5, real_op),
    opcode("WTN",  6, 998, 0, 0,  5,  5, real_op),
#if 0
    opcode("",12,Unused op,,,,,,,,
    opcode("",13,Unused op,,,,,,,,
    opcode("",62,Unused op,,,,,,,,
    opcode("",63,Unused op,,,,,,,,
#endif
    // symbolic op aliases
    opcode("RCD", "RD1"),
    opcode("PCH", "WR1"),
    opcode("BD0", "BDO"),
           
    // pseudo ops
    opcode("ALF", pseudo_alf,   0, 0, 0,  0,  0, pseudo_op),
    opcode("BLA", pseudo_bla,   0, 0, 0,  0,  0, pseudo_op),
    opcode("BLR", pseudo_blr,   0, 0, 0,  0,  0, pseudo_op),
    opcode("BOP", pseudo_bop,   0, 0, 0,  0,  0, pseudo_op),
    opcode("EQU", pseudo_equ,   0, 0, 0,  0,  0, pseudo_op),
    opcode("HED", pseudo_hed,   0, 0, 0,  0,  0, pseudo_op),
    opcode("PAT", pseudo_pat,   0, 0, 0,  0,  0, pseudo_op),
    opcode("RBR", pseudo_rbr,   0, 0, 0,  0,  0, pseudo_op),
    opcode("REG", pseudo_reg,   0, 0, 0,  0,  0, pseudo_op),
    opcode("REL", pseudo_rel,   0, 0, 0,  0,  0, pseudo_op),
    opcode("REQ", pseudo_req,   0, 0, 0,  0,  0, pseudo_op),
    opcode("SYN", pseudo_syn,   0, 0, 0,  0,  0, pseudo_op),
           
    opcode("FIN",  0,   0, 0, 0,  0,  0, final_op),
};

static opcode dummy_op("DUM", 0, 999, 5, 5, 5, 5, real_op);

void soap2::init_opcodetab()
{
    // initialize opcode lookup by-symbol and by-opcode tables
    opbycodetab.resize(100, &dummy_op);
    for (int i=0; optab[i].type != final_op; i++) {
        opcodetab[optab[i].op] = &optab[i];
        if (optab[i].type == real_op)
            opbycodetab[optab[i].code] = &optab[i];
    }
    
}

soap2::soap2(int c, int f, istream &cds_in, ostream &cds_out, ostream &listing, istream &ck_deck)
    : gsmap       (2000, 0)
    , input_deck  (cds_in)
    , output_deck (cds_out)
    , listing     (listing)
    , check_deck  (ck_deck)
    , ibm_obj     (2000)
    , codec       (c)
    , flags       (f)
{
    init_opcodetab();
    if (flags & asmflag_k)
        ibm_obj.load_7wd_deck(check_deck);
    assemble();
}

void soap2::error_message(const string &msg)
{
    errors << cardnumber << ": " << msg << endl;
}

void soap2::assemble()
{
    char inbuf[102];
    hed_char = ' ';
    opt_addr = -1;
    opt_gs   = -1;
    opt_ias  = -1;
    opt_800x = -1;
    cardnumber = 0;
    while (!input_deck.eof()) {
        ++cardnumber;
        input_deck.getline(&inbuf[0], 100);
        src = inbuf;
        src.resize(80, ' ');
        assemble_statement();
    }
    if (!errors.str().empty()) {
        cout << "Errors:" << endl;
        cout << errors.str();
        listing << endl << "Errors:" << endl;
        listing << errors.str();
    }
    print_symtab(listing);
    print_availtab(listing);
    print_regiontab(listing);
}

void soap2::assemble_statement()
{
    // resets for new statement
    asm_loc = 0;
    asm_op = 0;
    asm_d = 0;
    asm_i = 0;
    op = NULL;
    blank_loc = false;
    blank_op = false;
    blank_d = false;
    blank_i = false;
    punch_800x = false;
    bypass = false;
    
    // break statement into assembler fields
    src_type = src.substr(40,  1);
    src_sign = src.substr(41,  1);
    src_loc  = src.substr(42,  5);
    src_op   = src.substr(47,  3);
    src_d    = src.substr(50,  5);
    src_dtag = src.substr(55,  1);
    src_i    = src.substr(56,  5);
    src_itag = src.substr(61,  1);
    src_comm = src.substr(62, 10);
    src_fcom = src.substr(42, 30);
    
    // determine type and invoke processor
    switch (src_type[0]) {
        case ' ':
            assemble_command();
            punch_command(output_deck);
            print_command(listing);
            break;
        case '1':
            assemble_comment();
            if (flags & asmflag_c)
                punch_comment(output_deck);
            print_comment(listing);
            break;
        case '2':
            error_message("Relocatable statements no supported.");
            //assemble_relocate();
            break;
        default:
            error_message("Invalid statement type code");
            break;
    }
}

void soap2::assemble_command()
{
    process_op();
    if (op) {
        switch (op->type) {
            case real_op:
                assemble_realop();
                break;
            case pseudo_op:
                assemble_pseudo();
                break;
            default:
                error_message("Internal error, invalid op type");
                break;
        }
    } else {
        error_message("Invalid opcode");
    }
}

void soap2::punch_command(ostream &os)
{
    if (op) {
        if ((op->type == real_op) || (op->code == pseudo_alf)) {
            if (punch_800x && (flags & asmflag_e)) {
                os << zone_y('6') << "91954800" << zone_y('0')
                   << "      "
                   << setfill('0') << setw(4) << dec << (cardnumber % 10000)
                   << "24" << setfill('0') << setw(4) << dec << asm_loc
                   << "800" << zone_y('0')
                   << setfill('0') << setw(2) << dec << asm_op
                   << setfill('0') << setw(4) << dec << asm_d
                   << setfill('0') << setw(3) << dec << (asm_i / 10)
                   << ((src_sign == " ")? zone_y(asm_i % 10 + '0')
                                        : zone_x(asm_i % 10 + '0'))
                   << src_type
                   << ((src_sign == " ")? ' ' : '-')
                   << src_fcom
                   << " " << '-' << "     "
                   << endl;
            } else {
                os << zone_y('6') << "91954195" << zone_y('3')
                   << "      "
                   << setfill('0') << setw(4) << dec << (cardnumber % 10000)
                   << "24" << setfill('0') << setw(4) << dec << asm_loc
                   << "800" << zone_y('0')
                   << setfill('0') << setw(2) << dec << asm_op
                   << setfill('0') << setw(4) << dec << asm_d
                   << setfill('0') << setw(3) << dec << (asm_i / 10)
                   << ((src_sign == " ")? zone_y(asm_i % 10 + '0')
                                        : zone_x(asm_i % 10 + '0'))
                   << src_type
                   << ((src_sign == " ")? ' ' : '-')
                   << src_fcom
                   << "       "
                   << endl;
            }
        } else if ((op->type == pseudo_op) && (flags & asmflag_p)) {
                os << zone_y('0') << "00000800" << zone_y('0')
                   << "      "
                   << setfill('0') << setw(4) << dec << (cardnumber % 10000)
                   << "                    "
                   << src_type
                   << ((src_sign == " ")? ' ' : '-')
                   << src_fcom
                   << "9      "
                   << endl;
        }
    }
}

void soap2::print_command(ostream &os)
{
    if (op) {
        if ((op->type == real_op) || (op->code == pseudo_alf)) {
            os << dec << setfill(' ') << setw(4) << cardnumber << ": "
               << src_loc
               << ' ' << src_op
               << ' ' << src_d << src_dtag
               << ' ' << src_i << src_itag
               << ' ' << src_comm << "  "
               << dec << setfill(' ') << setw(4) << asm_loc << ": "
               << setfill('0') << setw(2) << asm_op
               << ' ' << setw(4) << asm_d
               << ' ' << setw(4) << asm_i;
            check_obj(os);
            os << endl;
        } else if (op->type == pseudo_op) {
            os << setfill(' ') << setw(4) << dec << cardnumber
               << ": "
               << src_loc
               << ' ' << src_op
               << ' ' << src_d << src_dtag
               << ' ' << src_i << src_itag
               << ' ' << src_comm
               << endl;
        }
    }
}

void soap2::assemble_comment()
{
}

void soap2::punch_comment(ostream &os)
{
    os << zone_y('0') << "00000800" << zone_y('0')
       << "      "
       << setfill('0') << setw(4) << dec << (cardnumber % 10000)
       << "                    "
       << src_type
       << ((src_sign == " ")? ' ' : '-')
       << src_fcom
       << "9" << "      "
       << endl;
}

void soap2::print_comment(ostream &os)
{
    os << setfill(' ') << setw(4) << dec << cardnumber
       << ":           "
       << src_fcom
       << endl;
}

void soap2::assemble_relocate()
{
}

void soap2::assemble_realop()
{
    process_loc();
    process_d();
    process_i();
}

void soap2::assemble_pseudo()
{
    asmfield d(src_d, ' ');
    asmfield i(src_i, ' ');
    switch (op->code) {
        case pseudo_alf:
            process_loc();
            asm_op = ascii_to_650(src_d[0]);
            asm_d =  ascii_to_650(src_d[1]) * 100 + ascii_to_650(src_d[2]);
            asm_i =  ascii_to_650(src_d[3]) * 100 + ascii_to_650(src_d[4]);
            if ((src_i) == "     ")
                src_i = "SOAP2";
            break;
            
        case pseudo_bla:
            if (d.type == field_numeric) {
                if (i.type == field_numeric) {
                    if (gsmap.isvalid(d.nval, i.nval - d.nval + 1))
                        gsmap.unreserve(d.nval, i.nval - d.nval + 1);
                    else
                        error_message("Invalid address range");
                } else {
                    error_message("Invalid I field");
                }
            } else {
                error_message("Invalid D field");
            }
            break;
            
        case pseudo_blr:
            if (d.type == field_numeric) {
                if (i.type == field_numeric) {
                    if (gsmap.isvalid(d.nval, i.nval - d.nval + 1))
                        gsmap.reserve(d.nval, i.nval - d.nval + 1);
                    else
                        error_message("Invalid address range");
                } else {
                    error_message("Invalid I field");
                }
            } else {
                error_message("Invalid D field");
            }
            break;
            
        case pseudo_bop:
            error_message("BOP not supported");
            break;
            
        case pseudo_syn:
        case pseudo_equ: {
            int32_t eaddr = -1;
            switch (i.type) {
                case field_numeric:
                    eaddr = i.nval;
                    break;
                    
                case field_region: {
                    regiter ri = regiontab.find(i.region);
                    if (ri == regiontab.end()) {
                        error_message("Region not defined");
                        bypass = true;
                    } else {
                        eaddr = ri->second->start + i.nval;
                    }
                }
                    break;
                    
                case field_symbolic: {
                    symiter si = symboltab.find(i.symbol);
                    if (si == symboltab.end()) {
                        error_message("Symbol not defined");
                        bypass = true;
                    } else {
                        eaddr = si->second->location;
                        si->second->add_ref(cardnumber);
                    }
                }
                    break;
                
                case field_blank:
                    error_message("I field may not be blank");
                    bypass = true;
                    break;
                    
                case field_error:
                    error_message("Invalid I field");
                    bypass = true;
                    break;
                    
                default:
                    error_message("Internal error: unknown field code");
                    bypass = true;
                    break;
            }
            if (!bypass) {
                if (d.type != field_symbolic) {
                    error_message("D field must be a symbol");
                    bypass = true;
                } else {
                    symboltab[d.symbol] = new symbol(d.symbol, eaddr, cardnumber);
                    if (op->code == pseudo_syn)
                        gsmap.reserve(eaddr);
                }
            }
        }
            break;
            
        case pseudo_hed:
            hed_char = src_d[0];
            break;
            
        case pseudo_pat:
            print_availtab(cout);
            //error_message("PAT not supported");
            break;
            
        case pseudo_rbr:
            error_message("RBR not supported");
            break;

        case pseudo_reg:
            switch (d.type) {
                case field_numeric:
                case field_region:
                    switch (i.type) {
                        case field_numeric:
                            if (d.type == field_region) {
                                regiter ri = regiontab.find(d.region);
                                if (ri == regiontab.end()) {
                                    regiontab[d.region] = new region(d.region, d.nval);
                                } else {
                                    ri->second->start = d.nval;
                                }
                            }
                            if (d.nval < i.nval)
                                gsmap.reserve(d.nval, i.nval - d.nval + 1);
                            break;
                        default:
                            error_message("Invalid I field");
                            break;
                    }
                    break;
                default:
                    error_message("Invalid D field");
                    break;
            }
            break;
            
        case pseudo_rel:
            error_message("REL not supported");
            break;
            
        case pseudo_req:
            error_message("REQ not supported");
            break;
            
        default:
            error_message("Internal error, invalid pseudo op");
            break;
    }
}

void soap2::check_obj(ostream &os)
{
    if (((op->type == real_op) && !punch_800x) || (op->code == pseudo_alf)) {
        int64_t v = asm_op * 100000000LL + asm_d * 10000 + asm_i;
        if ((v != ibm_obj[asm_loc].value()) || ((src_sign == " ") && ibm_obj[asm_loc].sign())) {
            int64_t ov = ibm_obj[asm_loc].value();
            os << " : " << setfill('0') << setw(2) << ov / 100000000LL
               << ' ' << setw(4) << ov / 10000 % 10000
               << ' ' << setw(4) << ov % 10000;
        }
    }
}

struct opt_deltas {
    int even;
    int odd;
    
    opt_deltas(int even, int odd) : even(even), odd(odd) {}
    opt_deltas() : even(0), odd(0) {}
};

static opt_deltas shift_deltas[] = {
    opt_deltas(23, 22),
    opt_deltas( 7,  6),
    opt_deltas( 7,  6),
    opt_deltas( 9,  8),
    opt_deltas(11, 10),
    opt_deltas(13, 12),
    opt_deltas(15, 14),
    opt_deltas(17, 16),
    opt_deltas(19, 18),
    opt_deltas(21, 20)
};

static opt_deltas srd_deltas[] = {
    opt_deltas(25, 24),
    opt_deltas( 7,  6),
    opt_deltas( 9,  8),
    opt_deltas(11, 10),
    opt_deltas(13, 12),
    opt_deltas(15, 14),
    opt_deltas(17, 16),
    opt_deltas(19, 18),
    opt_deltas(21, 20),
    opt_deltas(23, 22)
};

u_int32_t soap2::find_optimal_wt(opt_type ot)
{
    opt_deltas deltas;
    
    if (opt_addr < 0) {
        return 0;
    }
    if (opt_i == ot) {
        deltas = opt_deltas(op->i_even, op->i_odd);
        if (op->opt_B()) {
            int scount = asm_d % 10;
            deltas = (op->opt_A())? srd_deltas[scount] : shift_deltas[scount];
        } else if (op->opt_A()) {
            if (asm_d <= 1999)      deltas = opt_deltas( 6,  6);
            else if (asm_d <= 7999) deltas = opt_deltas( 6,  6);
            else if (asm_d == 8000) deltas = opt_deltas( 8,  8);
            else if (asm_d == 8001) deltas = opt_deltas( 6,  6);
            else if (asm_d == 8002) deltas = opt_deltas( 9,  8);
            else if (asm_d == 8003) deltas = opt_deltas( 8,  9);
            else if (asm_d <= 9059) deltas = opt_deltas( 8,  8);
            else                    deltas = opt_deltas( 9,  9);
                
        }
    } else {
        deltas = opt_deltas(op->d_even, op->d_odd);
    }
    int delta = (opt_addr & 1)? deltas.odd : deltas.even;
    return (opt_addr + delta) % 50;
}

u_int32_t soap2::find_optimal_800x(opt_type ot, u_int32_t opa)
{
    u_int32_t opta = find_optimal_wt(ot);
    if (8002 == opa) {
        if ((opta & 1)) opta++;
    } else if (8003 == opa) {
        if (!(opta & 1)) opta++;
    }
    return opta % 50;
}

void soap2::process_loc_addr()
{
    switch (get_addr_type(asm_loc)) {
        case addr_gs:
            opt_addr = asm_loc;
            break;
            
        case addr_800X:
            opt_addr = opt_800x;
            punch_800x = true;
            break;
            
        case addr_ias:
            opt_addr = opt_ias;
            break;
            
        case addr_invalid:
            error_message("Invalid location address");
            blank_loc = true;
            break;
        
        default:
            break;
    }
}

void soap2::process_loc()
{
    asmfield field(src_loc, hed_char);
    switch (field.type) {
        case field_blank:
            if (opt_addr < 0) {
                error_message("Cannot assign location, optimal address invalid");
                blank_loc = true;
            } else {
                asm_loc = opt_addr;
            }
            break;
            
        case field_symbolic: {
            symiter symi = symboltab.find(field.symbol);
            if (symi == symboltab.end()) {
                int32_t oaddr = gsmap.optimum(0);
                if (oaddr < 0) {
                    error_message("General storage packed");
                    blank_loc = true;
                } else {
                    symboltab[field.symbol] = new symbol(field.symbol, oaddr, cardnumber);
                    opt_addr = oaddr;
                    asm_loc = oaddr;
                }
            } else {
                asm_loc = symi->second->location;
                symi->second->add_ref(cardnumber);
                process_loc_addr();
            }
        }
            break;
        case field_numeric:
            asm_loc = field.nval;
            process_loc_addr();
            break;
            
        case field_region: {
            regiter regi = regiontab.find(field.region);
            if (regi == regiontab.end()) {
                error_message("Undefined region");
                blank_loc = true;
            } else {
                asm_loc = field.nval - 1 + regi->second->start;
                process_loc_addr();
            }
        }
            break;
            
        case field_error:
            error_message("Invalid location field");
            blank_loc = true;
            break;
            
        default:
            error_message("Internal error: processing location");
            blank_loc = true;
            break;
    }
}

void soap2::process_op()
{
    op = NULL;
    if (src_op[0] == ' ') {
        bool numeric = true;
        for (int i = 1; i < 3; i++)
            if (!isdigit(src_op[i]))
                numeric = false;
        if (numeric) {
            int opcode = stoi(src_op.substr(1, 2));
            op = opbycodetab[opcode];
            asm_op = opcode;
            return;
        } else {
            error_message("Malformed opcode");
            blank_op = true;
            return;
        }
    }
    opiter oi = opcodetab.find(src_op);
    if (oi != opcodetab.end()) {
        if (oi->second->type == alias_op) {
            oi = opcodetab.find(oi->second->alias);
            if (oi == opcodetab.end()) {
                error_message("Internal error: opcode alias not found");
                blank_op = true;
                return;
            }
        }
        op = oi->second;
        asm_op = op->code;
    } else {
        error_message("Invalid symbolic opcode");
        op = &dummy_op;
        blank_op = true;
    }
}

void soap2::process_d_addr()
{
    switch (get_addr_type(asm_d)) {
        case addr_gs:
            // todo: index
            if (!op->opt_C())
                opt_addr = asm_d;
            break;
            
        case addr_800X:
            opt_800x = find_optimal_800x(opt_d, asm_d);
            opt_addr = opt_800x;
            break;

        case addr_ias:
            // todo: index
            opt_ias = find_optimal_wt(opt_d);
            if (!op->opt_C())
                opt_addr = asm_d;
            break;
            
        case addr_invalid:
            if (!op->opt_C())
                opt_addr = asm_d;
            break;
        
        default:
            error_message("Internal error: processing D field");
            blank_d = true;
            break;
    }
}

void soap2::process_d()
{
    asmfield field(src_d, hed_char);
    switch (field.type) {
        case field_blank: {
            int32_t oaddr = gsmap.optimum(find_optimal_wt(opt_d));
            if (oaddr < 0) {
                error_message("General storage packed");
                blank_d = true;
            } else {
                opt_b = oaddr;
                asm_d = oaddr;
                if (!op->opt_C())
                    opt_addr = oaddr;
            }
        }
            break;
            
        case field_numeric:
            asm_d = field.nval;
            process_d_addr();
            break;
            
        case field_symbolic: {
            symiter symi = symboltab.find(field.symbol);
            if (symi == symboltab.end()) {
                int32_t oaddr = gsmap.optimum(find_optimal_wt(opt_d));
                if (oaddr < 0) {
                    error_message("General storage packed");
                    blank_d = true;
                } else {
                    symboltab[field.symbol] = new symbol(field.symbol, oaddr, cardnumber);
                    asm_d = oaddr;
                    if (!op->opt_C())
                        opt_addr = oaddr;
                }
            } else {
                asm_d = symi->second->location;
                symi->second->add_ref(cardnumber);
                process_d_addr();
            }
        }
            break;
            
        case field_region: {
            regiter regi = regiontab.find(field.region);
            if (regi == regiontab.end()) {
                error_message("Undefined region");
                blank_d = true;
            } else {
                asm_d = field.nval - 1 + regi->second->start;
                process_d_addr();
            }
        }
            break;

        case field_error:
            error_message("Invalid D field");
            blank_loc = true;
            break;
            
        default:
            error_message("Internal error: processing D field");
            blank_loc = true;
            break;
    }
}

void soap2::process_i_addr()
{
    switch (get_addr_type(asm_i)) {
        case addr_gs:
            // todo: index
            break;
            
        case addr_800X: {
            opt_800x = find_optimal_800x(opt_i, asm_i);
            break;
        }
        case addr_ias:
            // todo: index
            opt_ias = find_optimal_wt(opt_i);
            break;
            
        case addr_invalid:
            break;
        
        default:
            error_message("Internal error: processing I field");
            blank_i = true;
            break;
    }
    opt_addr = opt_b;
}

void soap2::process_i()
{
    asmfield field(src_i, hed_char);
    asmfield field_d(src_d, hed_char);
    switch (field.type) {
        case field_blank:
            if (field_blank == field_d.type) {
                if (gsmap.isfull()) {
                    blank_i = true;
                } else {
                    asm_i = opt_b;
                    opt_addr = opt_b;
                }
            } else {
                int32_t oaddr = gsmap.optimum(find_optimal_wt(opt_i));
                if (oaddr < 0) {
                    error_message("General storage packed");
                    blank_i = true;
                } else {
                    opt_b = oaddr;
                    asm_i = oaddr;
                    opt_addr = oaddr;
                }
            }
            break;
            
        case field_numeric:
            asm_i = field.nval;
            process_i_addr();
            break;
            
        case field_symbolic: {
            symiter symi = symboltab.find(field.symbol);
            if (symi == symboltab.end()) {
                int32_t oaddr = gsmap.optimum(find_optimal_wt(opt_i));
                if (oaddr < 0) {
                    error_message("General storage packed");
                    blank_i = true;
                } else {
                    symboltab[field.symbol] = new symbol(field.symbol, oaddr, cardnumber);
                    asm_i = oaddr;
                    opt_addr = opt_b;
                }
            } else {
                asm_i = symi->second->location;
                symi->second->add_ref(cardnumber);
                process_i_addr();
            }
        }
            break;
            
        case field_region: {
            regiter regi = regiontab.find(field.region);
            if (regi == regiontab.end()) {
                error_message("Undefined region");
                blank_i = true;
            } else {
                asm_i = field.nval - 1 + regi->second->start;
                process_i_addr();
            }
        }
            break;

        case field_error:
            error_message("Invalid I field");
            blank_loc = true;
            break;
            
        default:
            error_message("Internal error: processing I field");
            blank_loc = true;
            break;
    }
}

void soap2::print_symtab(ostream &sout)
{
    sout << endl << "Symbol Table:" << endl;
    symiter siter;
    for (siter = symboltab.begin(); siter != symboltab.end(); siter++) {
        sout << siter->first << ": " << setfill(' ') << setw(4) << dec << siter->second->location;
        int rctr = 0;
        for (int ref : siter->second->ref_line) {
            if (0 == (++rctr % 20)) sout << endl << "      ";
            sout << " " << setfill(' ') << setw(4) << dec << ref;
        }
        sout << endl;
    }
}

void memmap::print_availtab(ostream &sout)
{
    sout << endl << "Availability Table:" << endl;
    for (int i = 0; i < size; i++) {
        sout.width(4);
        if (0 == i % 50) sout << endl << i << ":";
        sout.width(1);
        if (0 == i % 10)  sout << " ";
        sout << ((allocmap[i])? '1' : '0');
    }
    sout << endl;
    for (int i = 0; i < 50; i++) {
        sout << setw(2) << i << ':';
        int addr = i;
        int ctr = 0;
        while (addr < size) {
            if (0 == allocmap[addr]) {
                if (ctr == 20) {
                    sout << endl << "   ";
                    ctr = 0;
                }   
                sout << ' ' << setw(4) << addr;
                ctr++;
            }
            addr += 50;
        }
        sout << endl;
    }
}

void soap2::print_availtab(ostream &sout)
{
    gsmap.print_availtab(sout);
}

void soap2::print_regiontab(ostream &sout)
{
    sout << endl << "Region Table:" << endl;
    for (regiter riter = regiontab.begin(); riter != regiontab.end(); riter++) {
        sout << riter->first << ": " << riter->second->start << endl;
    }
}
