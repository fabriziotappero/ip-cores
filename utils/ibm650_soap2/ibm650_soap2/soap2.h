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

#ifndef ibm650_soap2_soap2_h
#define ibm650_soap2_soap2_h

#include <string>
#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>
#include <vector>
#include <map>
#include "ibm_codec.h"

using namespace std;

struct region {
    u_int8_t  code;
    u_int32_t start;
    
    region(u_int8_t c, u_int32_t s) : code(c), start(s) {}
};

struct symbol {
    string            name;
    u_int32_t         location;
    vector<u_int32_t> ref_line;
    
    symbol(string n, u_int32_t l, u_int32_t r) : name(n), location(l) {
        ref_line.push_back(r);
    }
    void add_ref(u_int32_t r) {ref_line.push_back(r);}
};

enum {
    real_op,
    alias_op,
    unused_op,
    pseudo_op,
    final_op
};

enum {
    pseudo_alf = 1000,
    pseudo_bla,
    pseudo_blr,
    pseudo_bop,
    pseudo_equ,
    pseudo_hed,
    pseudo_pat,
    pseudo_rbr,
    pseudo_reg,
    pseudo_rel,
    pseudo_req,
    pseudo_syn
};

enum {
    asmflag_c = 0x0001,
    asmflag_e = 0x0002,
    asmflag_p = 0x0004,
    asmflag_k = 0x0008
};

struct opcode {
    string    op;
    u_int32_t code;
    u_int32_t group;
    u_int32_t d_even;
    u_int32_t d_odd;
    u_int32_t i_even;
    u_int32_t i_odd;
    u_int32_t type;
    string    alias;
    
    opcode(const string& o, u_int32_t c, u_int32_t g,u_int32_t de, u_int32_t dodd, u_int32_t ie, u_int32_t io, u_int32_t t)
     : op(o)
     , code(c)
     , group(g)
     , d_even(de)
     , d_odd(dodd)
     , i_even(ie)
     , i_odd(io)
     , type(t)
    {}
    
    opcode(const string& o, const string& a) : op(o), alias(a), type(alias_op) {}
    
    inline bool opt_A() const {return (8 == (group / 100));}
    inline bool opt_B() const {return (8 == ((group / 10) % 10));}
    inline bool opt_C() const {return (8 == (group % 10));}
};

enum fieldtype {
    field_blank,
    field_symbolic,
    field_numeric,
    field_region,
    field_error
};

struct asmfield {
    string    src;
    fieldtype type;
    u_int32_t nval;
    string    symbol;
    u_int8_t  region;
    
    asmfield(const string&, u_int8_t);
};

class biq_number {
    u_int64_t val;
    
  public:
    biq_number(const biq_number &n) {val = n.val;}
    biq_number(bool s, u_int64_t v) {
        val = (((s)? 1LL : 0LL) << 63) | (v % 10000000000LL);
    }
    biq_number() : val(0) {}
    bool sign() const {return (val & 0x8000000000000000LL);}
    u_int64_t value() const {return (val & 0x7fffffffffffffffLL);}
    void set_sign(bool s) {
        val = (val & 0x7fffffffffffffffLL) | (((s)? 1LL : 0LL) << 63);
    }
    void set_value(u_int64_t v) {
        val = (val & 0x8000000000000000LL) | (v % 10000000000LL);
    }
};

class memory {
    vector<biq_number> mem;
    
public:
    memory(u_int32_t sz) : mem(sz) {}
    
    void load_7wd_deck(istream &);
    biq_number& operator[](unsigned ix) {ix %= mem.size(); return mem[ix];}
};

class memmap {
    u_int32_t size;
    u_int32_t origin;
    vector<int> allocmap;
    int32_t freectr;

public:
    memmap(u_int32_t s, u_int32_t o);
    void reserve(u_int32_t addr);
    void reserve(u_int32_t fwa, u_int32_t sz);
    void unreserve(u_int32_t addr);
    void unreserve(u_int32_t fwa, u_int32_t sz);
    void reset();
    int32_t optimum(u_int32_t rot);
    inline bool isfull() const {return (freectr <= 0);}
    inline bool isvalid(u_int32_t addr) const {return (addr >= origin) && (addr < (origin+size));}
    inline bool isvalid(u_int32_t fwa, u_int32_t sz) const { return (fwa >= origin) && ((fwa + sz - 1) < (origin+size));}
    void print_availtab(ostream &);
};

enum addr_type {
    addr_gs,
    addr_ias,
    addr_800X,
    addr_invalid
};

class soap2 {
    typedef map<string, symbol*>::iterator symiter;
    map<string, symbol*>   symboltab;   // symbol -> location
    typedef map<u_int8_t, region*>::iterator regiter;
    map<u_int8_t, region*> regiontab;   // character -> region
    memmap                 gsmap;       // general storage (drum) allocation map
    map<string, opcode*>   opcodetab;   // opcode lookup table
    typedef map<string, opcode*>::iterator opiter;
    vector<opcode*>        opbycodetab; // opcode indexed by opcode
    istream               &input_deck;
    istream               &check_deck;
    ostream               &output_deck;
    ostream               &listing;
    memory                 ibm_obj;
    ibm_codec              codec;
    int                    flags;
    
    void init_opcodetab();
    
    ostringstream    errors;
    u_int32_t cardnumber;
    u_int8_t  hed_char;

    int32_t   opt_addr;
    int32_t   opt_gs;
    int32_t   opt_ias;
    int32_t   opt_800x;
    int32_t   opt_b;

    // statement currently under assembly
    string    src;
    string    src_type;
    string    src_sign;
    string    src_loc;
    string    src_op;
    string    src_d;
    string    src_dtag;
    string    src_i;
    string    src_itag;
    string    src_comm;
    string    src_fcom;
    
    u_int32_t asm_loc;
    u_int32_t asm_op;
    u_int32_t asm_d;
    u_int32_t asm_i;
    
    opcode   *op;
    
    bool blank_loc;
    bool blank_op;
    bool blank_d;
    bool blank_i;
    bool punch_800x;
    bool bypass;

    enum opt_type {
        opt_d,
        opt_i,
    };
    u_int32_t find_optimal_wt(opt_type);
    u_int32_t find_optimal_800x(opt_type, u_int32_t);
    
    void process_loc();
    void process_loc_addr();
    void process_op();
    void process_d();
    void process_d_addr();
    void process_i();
    void process_i_addr();

    void assemble();
    void assemble_statement();
    void assemble_command();
    void assemble_comment();
    void assemble_relocate();
    void assemble_realop();
    void assemble_pseudo();
    void check_obj(ostream &);
    
    void punch_comment(ostream &);
    void punch_command(ostream &);
    void print_comment(ostream &);
    void print_command(ostream &);
    
    void print_symtab(ostream &);
    void print_availtab(ostream &);
    void print_regiontab(ostream &);
        
    void error_message(const string &);
    
public:
    soap2(int, int, istream &, ostream &, ostream &, istream &);
    inline u_int8_t ascii_to_650(int c) const {
      return codec.valid_code650_for_ascii(c)? codec.ascii_to_code650(c) : 0;
    }
};

#endif
