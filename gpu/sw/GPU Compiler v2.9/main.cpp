// Diego Andrés González Idárraga

#include <iostream>
#include <vector>
#include <bitset>
#include <cstdint>
#include <map>
#include <fstream>
#include <stdexcept>
#include <iomanip>

const std::string space = "\t\n\v\f\r ",
                  digit = "0123456789",
                  alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

const std::array<std::string, 8> ks = {"-inf", "-1.f", "0.f", "1.f", "e", "pi", "inf", "nan"};

const std::array<std::string, 32> rs = { "r0",  "r1",  "r2",  "r3",  "r4",  "r5",  "r6",  "r7",
                                        "r8" , "r9" , "r10", "r11", "r12", "r13", "r14", "r15",
                                        "r16", "r17", "r18", "r19", "r20", "r21", "r22", "r23",
                                        "r24", "r25", "r26", "r27", "r28", "r29", "r30", "r31"};

const std::array<std::string, 8> crs = {"cr0", "cr1", "cr2", "cr3", "cr4", "cr5", "cr6", "cr7"};

enum INSTRUCTION_FORMAT {
    OP1_CONDITION_0_OP2_0,
    OP1_CONDITION_OP2_0,
    OP1_CONDITION_OP2_RC,
    OP1_CONDITION_KRA_RA_OP2_0_RC,
    OP1_CONDITION_KRA_RA_OP2_RC,
    OP1_CONDITION_KRA_RA_OP2_RB_RC,
    OP1_CONDITION_0_OP2_RB_RC,
    OP1_CONDITION_KRA_RA_OP2_RB_CR,
    OP1_CONDITION_1_RA_OP2_RB_RC,
    OP1_CONDITION_0_OP2_0_RC,
    OP1_CONDITION_0_OP2_RB_0,
    OP1_CONDITION_KRA_RA_OP2_0,
    OP1_CONDITION_KRA_RA_OP2_RB_0
};

enum COMPILER_EXCEPTIONS {
    SYNTAX_ERROR,
    INVALID_INSTRUCTION,
    LABEL_REDEFINED,
    JUMP_OR_RCALL_OUT_OF_RANGE,
    LABEL_UNDEFINED
};

struct STR_INST {
    bool addr;
    std::string label2;
    std::bitset<32> instruction;
};

union FTOU {
    float f;
    std::uint_least32_t u;

    FTOU() {}
    FTOU(const float &x) : f(x) {}
};

class DEF {
    std::map<std::string, std::string> def_map;

public:
    void operator()(const std::string &);
    std::string operator[](const std::string &);
} def;

std::string find_label(std::string &, const char &);
STR_INST instruction(std::string);
std::string find_number(std::string &, const char &, const bool &);
std::string rx(std::string &, const char &);
std::string find_op2(std::string &);
std::string crx(std::string &, const char &);
void save_vhd(const std::vector<STR_INST> &);
void save_h(const std::vector<STR_INST> &);

int main() {
    std::ifstream rfile;
    std::string line, str;
    bool comment, use_inst_line, format_loop;
    std::size_t i, j, k;
    std::vector<std::string> labels1;
    std::vector<STR_INST> code;
    std::map<std::size_t, std::size_t> inst_line;
    std::map<std::string, std::size_t> labels;
    std::map<std::string, std::size_t>::iterator l;
    std::bitset<18> label;

    do {
        std::cout<<"File: ";
        std::getline(std::cin, line);
        if (line == "exit") return 0;
        rfile.open(line);
        if (!rfile.is_open()) std::cout<<"Error opening file.\n\n";
    } while(!rfile.is_open());

    try {
        for (comment = false, i = 1, use_inst_line = false; !rfile.eof(); i++) {
            std::getline(rfile, line);
            if (!comment && ((j = line.find("//")) != std::string::npos)) line.erase(j);
            if (!comment && ((j = line.find("/*")) != std::string::npos)) {
                if ((k = line.find("*/", j+2)) != std::string::npos) line.erase(j, k+2-j);
                else comment = true;
            }
            else if (comment && ((j = line.find("*/")) != std::string::npos)) {
                line.erase(0, j+2);
                comment = false;
            }
            if (!comment) {
                if (line.find('#') != std::string::npos) def(line);
                else {
                    while (line.find(':') != std::string::npos) labels1.push_back(find_label(line, ':'));
                    if (line.find_first_not_of(space) != std::string::npos) {
                        for (j = 0; j < labels1.size(); j++) {
                            if (labels.find(str = labels1[j]) == labels.end()) labels[str] = code.size();
                            else throw LABEL_REDEFINED;
                        }
                        labels1.clear();
                        inst_line[code.size()] = i;
                        code.push_back(instruction(line));
                    }
                }
            }
        }

        rfile.close();

        for (i = 0, use_inst_line = true; i < code.size(); i++) {
            if (!(line = code[i].label2).empty()) {
                if ((l = labels.find(line)) != labels.end()) {
                    k = (j = l->second)-i;
                    if (j >= i) {
                        if (k > 131071) throw JUMP_OR_RCALL_OUT_OF_RANGE;
                    }
                    else if (i-j > 131072) throw JUMP_OR_RCALL_OUT_OF_RANGE;
                    label = std::bitset<18>(k);
                    for (j = 0; j < 10; j++) code[i].instruction[j] = label[j];
                    for (j = 10; j < 18; j++) code[i].instruction[j+4] = label[j];
                }
                else throw LABEL_UNDEFINED;
            }
        }

        do {
            std::cout<<"Format: ";
            std::getline(std::cin, line);
            format_loop = false;
            if (line == "vhdl") save_vhd(code);
            else if (line == "c") save_h(code);
            else {
                std::cout<<"Invalid format.\n\n";
                format_loop = true;
            }
        } while(format_loop);
    }

    catch(const COMPILER_EXCEPTIONS &ce) {
        if (use_inst_line) i = inst_line[i];
        switch (ce) {
        case SYNTAX_ERROR:
            str = "syntax error.";
            break;
        case LABEL_REDEFINED:
            str = "label redefined.";
            break;
        case INVALID_INSTRUCTION:
            str = "invalid instruction.";
            break;
        case JUMP_OR_RCALL_OUT_OF_RANGE:
            str = "jump or rcall out of range";
            break;
        case LABEL_UNDEFINED:
            str = "label undefined.";
            break;
        }
        std::cout<<"\nError line "<<i<<": "<<str<<'\n';
    }

    std::cout<<"Press enter to continue . . . ";
    std::cin.sync();
    std::cin.get();
    return 0;
}

void DEF::operator()(const std::string &line) {
    std::size_t i, j, k, l, m;
    std::string str1, str2, str3;
    bool define_undef;
    std::map<std::string, std::string>::iterator n;

    if (((i = line.find_first_not_of(space)) != std::string::npos) &&
        ((j = line.find_first_of(space, i)) != std::string::npos) &&
        ((k = line.find_first_not_of(space, j)) != std::string::npos)) {
        str1 = line.substr(i, j-i);
        if (str1 == "#def") {
            if (((isalpha(line[k]) != 0) || (line[k] == '_')) &&
                ((l = line.find_first_not_of(digit+alpha+'_', k)) != std::string::npos) && (std::isspace(line[l]) != 0) &&
                ((m = line.find_first_not_of(space, l)) != std::string::npos)) {
                str2 = line.substr(k, l-k);
                str3 = line.substr(m);
                define_undef = false;
            }
            else throw SYNTAX_ERROR;
        }
        else if (str1 == "#undef") {
            if ((l = line.find_first_of(space, k)) != std::string::npos) {
                if (line.find_first_not_of(space, l) == std::string::npos) str2 = line.substr(k, l-k);
                else throw SYNTAX_ERROR;
            }
            else str2 = line.substr(k);
            define_undef = true;
        }
        else throw SYNTAX_ERROR;
    }
    else throw SYNTAX_ERROR;

    for (i = 0; i < ks.size(); i++) {
        if (str2 == ks[i]) throw SYNTAX_ERROR;
    }
    for (i = 0; i < rs.size(); i++) {
        if (str2 == rs[i]) throw SYNTAX_ERROR;
    }

    if (!define_undef) {
        if (def_map.find(str2) == def_map.end()) def_map[str2] = def[str3];
        else throw LABEL_REDEFINED;
    }
    else {
        if ((n = def_map.find(str2)) != def_map.end()) def_map.erase(n);
        else throw LABEL_UNDEFINED;
    }
}

std::string DEF::operator[](const std::string &str) {
    std::size_t i;
    std::map<std::string, std::string>::iterator j;

    try {
        stof(str);
    } catch(std::exception) {
        try {
            stoul(str);
        } catch(std::exception) {
            for (i = 0; i < rs.size(); i++) {
                if (str == rs[i]) return str;
            }
            if ((j = def_map.find(str)) != def_map.end()) return j->second;
            else throw LABEL_UNDEFINED;
        }
    }
    return str;
}

std::string find_label(std::string &line, const char &delim) {
    std::size_t i, j, k;
    std::string str;

    if (((i = line.find_first_not_of(space)) != std::string::npos) && ((std::isalpha(line[i]) != 0) || (line[i] == '_')) &&
        ((j = line.find_first_not_of(digit+alpha+'_', i)) != std::string::npos) &&
        ((k = line.find_first_not_of(space, j)) != std::string::npos) && (line[k] == delim)) {
        str = line.substr(i, j-i);
        line.erase(0, k+1);
        return str;
    }
    else throw SYNTAX_ERROR;
}

STR_INST instruction(std::string line) {
    std::size_t i, j, k;
    STR_INST str_inst;
    std::string str, op1, op2, condition, ra, rb, rc;
    INSTRUCTION_FORMAT inst_f;
    bool bop2, k_ra;


    if (((i = line.find_first_not_of(space)) != std::string::npos) && line[i] == '[') {
        if (((j = line.find_first_not_of(space, i+1)) != std::string::npos) && line[j] == '!') {
            line.erase(0, j+1);
            condition = "11"+crx(line, ']');
        }
        else {
            line.erase(0, i+1);
            condition = "10"+crx(line, ']');
        }
    }
    else {
        condition = "00000";
    }

    if (((i = line.find_first_not_of(space)) != std::string::npos) &&
        ((j = line.find_first_not_of(digit+alpha+'_', i)) != std::string::npos)) {
        str = line.substr(i, j-i);
        line.erase(0, j);
    }
    else throw SYNTAX_ERROR;

    str_inst.addr = false;
    bop2 = false;

    if (str == "nop") {
        inst_f = OP1_CONDITION_0_OP2_0;
        op1 = "00000";
        op2 = "000000";
        if (((i = line.find_first_not_of(space)) != std::string::npos) && (line[i] == ';')) line.erase(0, i+1);
        else throw SYNTAX_ERROR;
    }

    else if (str == "ploadf_l") {
        inst_f = OP1_CONDITION_OP2_0;
        op1 = "00001";
        op2 = find_number(line, ';', false).substr(16, 16)+'0';
    }
    else if (str == "loadf_h") {
        inst_f = OP1_CONDITION_OP2_RC;
        op1 = "00001";
        op2 = find_number(line, ',', false).substr(0, 16)+'1';
    }
    else if (str == "ploadu_l") {
        inst_f = OP1_CONDITION_OP2_0;
        op1 = "00001";
        op2 = find_number(line, ';', true).substr(16, 16)+'0';
    }
    else if (str == "loadu_h") {
        inst_f = OP1_CONDITION_OP2_RC;
        op1 = "00001";
        op2 = find_number(line, ',', true).substr(0, 16)+'1';
    }
    else if (str == "ploadaddr_l") {
        inst_f = OP1_CONDITION_OP2_0;
        op1 = "00001";
        op2 = find_number(line, ';', true).substr(16, 16)+'0';
        str_inst.addr = true;
    }
    else if (str == "loadaddr_h") {
        inst_f = OP1_CONDITION_OP2_RC;
        op1 = "00001";
        op2 = find_number(line, ',', true).substr(0, 16)+'1';
        str_inst.addr = true;
    }

    else if (str == "copy") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_0_RC;
        op1 = "00010";
        op2 = "000000";
    }
    else if (str == "fabs") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_0_RC;
        op1 = "00010";
        op2 = "000001";
    }
    else if (str == "fneg") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_0_RC;
        op1 = "00010";
        op2 = "000010";
    }
    else if (str == "fnabs") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_0_RC;
        op1 = "00010";
        op2 = "000011";
    }

    else if (str == "fmulp2") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RC;
        bop2 = true;
        op1 = "00011";
    }

    else if (str == "fadd") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_RC;
        op1 = "00100";
        op2 = "000000";
    }
    else if (str == "fsub") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_RC;
        op1 = "00100";
        op2 = "000001";
    }
    else if (str == "fmul") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_RC;
        op1 = "00101";
        op2 = "000000";
    }
    else if (str == "fdiv") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_RC;
        op1 = "00110";
        op2 = "000000";
    }

    else if (str == "fmin") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_RC;
        op1 = "00111";
        op2 = "000000";
    }
    else if (str == "fmax") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_RC;
        op1 = "00111";
        op2 = "000001";
    }

    else if (str == "trunc") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_0_RC;
        op1 = "01000";
        op2 = "000000";
    }
    else if (str == "round") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_0_RC;
        op1 = "01000";
        op2 = "000001";
    }
    else if (str == "ceil") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_0_RC;
        op1 = "01000";
        op2 = "000010";
    }
    else if (str == "floor") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_0_RC;
        op1 = "01000";
        op2 = "000011";
    }

    else if (str == "ftou8_ll") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_RC;
        op1 = "01001";
        op2 = "000000";
    }
    else if (str == "ftou8_lh") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_RC;
        op1 = "01001";
        op2 = "000001";
    }
    else if (str == "ftou8_hl") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_RC;
        op1 = "01001";
        op2 = "000010";
    }
    else if (str == "ftou8_hh") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_RC;
        op1 = "01001";
        op2 = "000011";
    }

    else if (str == "ftou16_l") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_RC;
        op1 = "01010";
        op2 = "000000";
    }
    else if (str == "ftou16_h") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_RC;
        op1 = "01010";
        op2 = "000001";
    }

    else if (str == "ftou32") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_0_RC;
        op1 = "01011";
        op2 = "000000";
    }

    else if (str == "u8tof_ll") {
        inst_f = OP1_CONDITION_0_OP2_RB_RC;
        op1 = "01100";
        op2 = "000000";
    }
    else if (str == "u8tof_lh") {
        inst_f = OP1_CONDITION_0_OP2_RB_RC;
        op1 = "01100";
        op2 = "000001";
    }
    else if (str == "u8tof_hl") {
        inst_f = OP1_CONDITION_0_OP2_RB_RC;
        op1 = "01100";
        op2 = "000010";
    }
    else if (str == "u8tof_hh") {
        inst_f = OP1_CONDITION_0_OP2_RB_RC;
        op1 = "01100";
        op2 = "000011";
    }

    else if (str == "u16tof_l") {
        inst_f = OP1_CONDITION_0_OP2_RB_RC;
        op1 = "01101";
        op2 = "000000";
    }
    else if (str == "u16tof_h") {
        inst_f = OP1_CONDITION_0_OP2_RB_RC;
        op1 = "01101";
        op2 = "000001";
    }

    else if (str == "u32tof") {
        inst_f = OP1_CONDITION_0_OP2_RB_RC;
        op1 = "01110";
        op2 = "000000";
    }

    else if (str == "fcomp_l") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_CR;
        op1 = "01111";
        op2 = "000000";
    }
    else if (str == "fcomp_le") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_CR;
        op1 = "01111";
        op2 = "000001";
    }
    else if (str == "fcomp_e") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_CR;
        op1 = "01111";
        op2 = "000010";
    }
    else if (str == "fcomp_ge") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_CR;
        op1 = "01111";
        op2 = "000011";
    }
    else if (str == "fcomp_g") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_CR;
        op1 = "01111";
        op2 = "000100";
    }
    else if (str == "fcomp_ne") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_CR;
        op1 = "01111";
        op2 = "000101";
    }
    else if (str == "fcomp_o") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_CR;
        op1 = "01111";
        op2 = "000110";
    }
    else if (str == "fcomp_u") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_CR;
        op1 = "01111";
        op2 = "000111";
    }

    else if (str == "add") {
        inst_f = OP1_CONDITION_1_RA_OP2_RB_RC;
        op1 = "10000";
        op2 = "000000";
    }
    else if (str == "load_addr") {
        inst_f = OP1_CONDITION_0_OP2_0_RC;
        op1 = "10001";
        op2 = "000000";
    }
    else if (str == "store_addr") {
        inst_f = OP1_CONDITION_0_OP2_RB_0;
        op1 = "10010";
        op2 = "000000";
    }

    else if (str == "d_load") {
        inst_f = OP1_CONDITION_0_OP2_0_RC;
        op1 = "10011";
        op2 = "000011";
    }
    else if ((str == "i_load") || (str == "pop")) {
        inst_f = OP1_CONDITION_0_OP2_0_RC;
        op1 = "10011";
        op2 = "000010";
    }
    else if (str == "load") {
        inst_f = OP1_CONDITION_0_OP2_RB_RC;
        op1 = "10011";
        op2 = "000000";
    }
    else if (str == "load_d") {
        inst_f = OP1_CONDITION_0_OP2_0_RC;
        op1 = "10011";
        op2 = "000111";
    }
    else if (str == "load_i") {
        inst_f = OP1_CONDITION_0_OP2_0_RC;
        op1 = "10011";
        op2 = "000110";
    }

    else if (str == "d_store") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_0;
        op1 = "10100";
        op2 = "000011";
    }
    else if (str == "i_store") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_0;
        op1 = "10100";
        op2 = "000010";
    }
    else if (str == "store") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_RB_0;
        op1 = "10100";
        op2 = "000000";
    }
    else if ((str == "store_d") || (str == "push")) {
        inst_f = OP1_CONDITION_KRA_RA_OP2_0;
        op1 = "10100";
        op2 = "000111";
    }
    else if (str == "store_i") {
        inst_f = OP1_CONDITION_KRA_RA_OP2_0;
        op1 = "10100";
        op2 = "000110";
    }

    else if (str == "jump") {
        inst_f = OP1_CONDITION_0_OP2_0;
        op1 = "10101";
        op2 = "000111";
        str_inst.label2 = find_label(line, ';');
    }
    else if (str == "rcall") {
        inst_f = OP1_CONDITION_0_OP2_0;
        op1 = "10101";
        op2 = "001111";
        str_inst.label2 = find_label(line, ';');
    }

    else if (str == "goto") {
        inst_f = OP1_CONDITION_0_OP2_RB_0;
        op1 = "10110";
        op2 = "000111";
    }
    else if (str == "call") {
        inst_f = OP1_CONDITION_0_OP2_RB_0;
        op1 = "10110";
        op2 = "001111";
    }

    else if (str == "ret") {
        inst_f = OP1_CONDITION_0_OP2_0;
        op1 = "10111";
        op2 = "000010";
        if (((i = line.find_first_not_of(space)) != std::string::npos) && (line[i] == ';')) line.erase(0, i+1);
        else throw SYNTAX_ERROR;
    }

    else if (str == "stop_core") {
        inst_f = OP1_CONDITION_0_OP2_0;
        op1 = "11000";
        op2 = "000000";
        if (((i = line.find_first_not_of(space)) != std::string::npos) && (line[i] == ';')) line.erase(0, i+1);
        else throw SYNTAX_ERROR;
    }

    else if (str == "irq") {
        inst_f = OP1_CONDITION_0_OP2_0;
        op1 = "11001";
        op2 = "000000";
        if (((i = line.find_first_not_of(space)) != std::string::npos) && (line[i] == ';')) line.erase(0, i+1);
        else throw SYNTAX_ERROR;
    }

    else throw INVALID_INSTRUCTION;

    k_ra = true;
    switch (inst_f) {
    case OP1_CONDITION_0_OP2_0:
    case OP1_CONDITION_OP2_0:
    case OP1_CONDITION_OP2_RC:
    case OP1_CONDITION_0_OP2_RB_RC:
    case OP1_CONDITION_1_RA_OP2_RB_RC:
    case OP1_CONDITION_0_OP2_0_RC:
    case OP1_CONDITION_0_OP2_RB_0:
        break;
    case OP1_CONDITION_KRA_RA_OP2_0_RC:
    case OP1_CONDITION_KRA_RA_OP2_RC:
    case OP1_CONDITION_KRA_RA_OP2_RB_RC:
    case OP1_CONDITION_KRA_RA_OP2_RB_CR:
    case OP1_CONDITION_KRA_RA_OP2_RB_0:
        if (((i = line.find_first_not_of(space)) != std::string::npos) &&
            ((j = line.find_first_not_of("-.01aefinp", i)) != std::string::npos) &&
            ((k = line.find_first_not_of(space, j)) != std::string::npos) && (line[k] == ',')) {
            str = line.substr(i, j-i);
            for (i = 0; i < ks.size(); i++) {
                if (str == ks[i]) {
                    line.erase(0, k+1);
                    k_ra = false;
                    ra = std::bitset<5>(i).to_string();
                    break;
                }
            }
        }
        break;
    case OP1_CONDITION_KRA_RA_OP2_0:
        if (((i = line.find_first_not_of(space)) != std::string::npos) &&
            ((j = line.find_first_not_of("-.01aefinp", i)) != std::string::npos) &&
            ((k = line.find_first_not_of(space, j)) != std::string::npos) && (line[k] == ';')) {
            str = line.substr(i, j-i);
            for (i = 0; i < ks.size(); i++) {
                if (str == ks[i]) {
                    line.erase(0, k+1);
                    k_ra = false;
                    ra = std::bitset<5>(i).to_string();
                    break;
                }
            }
        }
        break;
    }

    switch (inst_f) {
    case OP1_CONDITION_0_OP2_0:
    case OP1_CONDITION_OP2_0:
        break;
    case OP1_CONDITION_OP2_RC:
    case OP1_CONDITION_0_OP2_0_RC:
        rc = rx(line, ';');
        break;
    case OP1_CONDITION_KRA_RA_OP2_0_RC:
    case OP1_CONDITION_KRA_RA_OP2_RC:
        if (k_ra) ra = rx(line, ',');
        if (bop2) op2 = find_op2(line);
        rc = rx(line, ';');
        break;
    case OP1_CONDITION_KRA_RA_OP2_RB_RC:
    case OP1_CONDITION_1_RA_OP2_RB_RC:
        if (k_ra) ra = rx(line, ',');
        rb = rx(line, ',');
        rc = rx(line, ';');
        break;
    case OP1_CONDITION_0_OP2_RB_RC:
        rb = rx(line, ',');
        rc = rx(line, ';');
        break;
    case OP1_CONDITION_KRA_RA_OP2_RB_CR:
        if (k_ra) ra = rx(line, ',');
        rb = rx(line, ',');
        rc = "00"+crx(line, ';');
        break;
    case OP1_CONDITION_0_OP2_RB_0:
        rb = rx(line, ';');
        break;
    case OP1_CONDITION_KRA_RA_OP2_0:
        if (k_ra) ra = rx(line, ';');
        break;
    case OP1_CONDITION_KRA_RA_OP2_RB_0:
        if (k_ra) ra = rx(line, ',');
        rb = rx(line, ';');
        break;
    }

    if (line.find_first_not_of(space) != std::string::npos) throw SYNTAX_ERROR;

    switch (inst_f) {
    case OP1_CONDITION_0_OP2_0:
        str_inst.instruction = std::bitset<32>(op1+condition+"000000"+op2+"0000000000");
        break;
    case OP1_CONDITION_OP2_0:
        str_inst.instruction = std::bitset<32>(op1+condition+op2+"00000");
        break;
    case OP1_CONDITION_OP2_RC:
        str_inst.instruction = std::bitset<32>(op1+condition+op2+rc);
        break;
    case OP1_CONDITION_KRA_RA_OP2_0_RC:
        str_inst.instruction = std::bitset<32>(op1+condition+(k_ra? '1' : '0')+ra+op2+"00000"+rc);
        break;
    case OP1_CONDITION_KRA_RA_OP2_RC:
        str_inst.instruction = std::bitset<32>(op1+condition+(k_ra? '1' : '0')+ra+op2+rc);
        break;
    case OP1_CONDITION_KRA_RA_OP2_RB_RC:
    case OP1_CONDITION_KRA_RA_OP2_RB_CR:
    case OP1_CONDITION_1_RA_OP2_RB_RC:
        str_inst.instruction = std::bitset<32>(op1+condition+(k_ra? '1' : '0')+ra+op2+rb+rc);
        break;
    case OP1_CONDITION_0_OP2_RB_RC:
        str_inst.instruction = std::bitset<32>(op1+condition+"000000"+op2+rb+rc);
        break;
    case OP1_CONDITION_0_OP2_0_RC:
        str_inst.instruction = std::bitset<32>(op1+condition+"000000"+op2+"00000"+rc);
        break;
    case OP1_CONDITION_0_OP2_RB_0:
        str_inst.instruction = std::bitset<32>(op1+condition+"000000"+op2+rb+"00000");
        break;
    case OP1_CONDITION_KRA_RA_OP2_0:
        str_inst.instruction = std::bitset<32>(op1+condition+(k_ra? '1' : '0')+ra+op2+"0000000000");
        break;
    case OP1_CONDITION_KRA_RA_OP2_RB_0:
        str_inst.instruction = std::bitset<32>(op1+condition+(k_ra? '1' : '0')+ra+op2+rb+"00000");
        break;
    }

    return str_inst;
}

std::string find_number(std::string &line, const char &delim, const bool &float_unsigned) {
    std::size_t i, j;
    std::uint_least32_t x;
    std::string str;

    try {
        if (float_unsigned) x = stoul(line, &i);
        else x = FTOU(stof(line, &i)).u;
    }

    catch(std::invalid_argument) {
        str = def[find_label(line, delim)]+delim;
        return find_number(str, delim, float_unsigned);
    }
    catch(std::out_of_range) {
        throw SYNTAX_ERROR;
    }

    if (((j = line.find_first_not_of(space, i)) != std::string::npos) && (line[j] == delim)) {
        line.erase(0, j+1);
        return std::bitset<32>(x).to_string();
    }
    else throw SYNTAX_ERROR;
}

std::string rx(std::string &line, const char &delim) {
    std::size_t i, j, k;
    std::string str;

    if (((i = line.find_first_not_of(space)) != std::string::npos) &&
        ((j = line.find_first_not_of(digit+alpha+'_', i)) != std::string::npos) &&
        ((k = line.find_first_not_of(space, j)) != std::string::npos) && (line[k] == delim)) {
        str = def[line.substr(i, j-i)];
        for (i = 0; i < rs.size(); i++) {
            if (str == rs[i]) {
                line.erase(0, k+1);
                return std::bitset<5>(i).to_string();
            }
        }
    }
    throw SYNTAX_ERROR;
}

std::string find_op2(std::string &line) {
    std::size_t i, j;
    int x;

    try {
        x = stoi(line, &i);
    }
    catch(std::exception) {
        throw SYNTAX_ERROR;
    }
    if ((x >= -256) && (x <= 255) &&
        ((j = line.find_first_not_of(space, i)) != std::string::npos) && (line[j] == ',')) {
        line.erase(0, j+1);
        return std::bitset<11>(x).to_string();
    }
    else throw SYNTAX_ERROR;
}

std::string crx(std::string &line, const char &delim) {
    std::size_t i, j, k;
    std::string str;

    if (((i = line.find_first_not_of(space)) != std::string::npos) &&
        ((j = line.find_first_not_of("01234567cr", i)) != std::string::npos) &&
        ((k = line.find_first_not_of(space, j)) != std::string::npos) && (line[k] == delim)) {
        str = line.substr(i, j-i);
        for (i = 0; i < crs.size(); i++) {
            if (str == crs[i]) {
                line.erase(0, k+1);
                return std::bitset<3>(i).to_string();
            }
        }
    }
    throw SYNTAX_ERROR;
}

void save_vhd(const std::vector<STR_INST> &code) {
    std::ofstream wfile;
    std::size_t i;

    wfile.open("programa_pkg.vhd");
    wfile<<"library ieee;\n"
           "use ieee.std_logic_1164.all;\n"
           "\n"
           "package programa_pkg is\n"
           "    type data_array is array(natural range <>) of std_logic_vector(31 downto 0);\n"
           "    \n";
    for (i = 0; i < code.size(); i++) {
        if (i == 0) wfile<<"    constant programa : data_array := (\"";
        else wfile<<"                                       \"";
        wfile<<code[i].instruction;
        if (i < code.size()-1) wfile<<"\",\n";
        else wfile<<"\");\n";
        std::cout<<code[i].instruction<<'\n';
    }
    wfile<<"end package;";
    wfile.close();
}

void save_h(const std::vector<STR_INST> &code) {
    std::ofstream wfile;
    std::size_t i;

    wfile.open("gpu_program.h");
    wfile<<"#ifndef gpu_program_h\n"
           "#define gpu_program_h\n"
           "\n"
           "#include <stdint.h>\n"
           "#include <stddef.h>\n"
           "\n"
           "typedef struct __gpu_program {\n"
           "    uint32_t instruction;\n"
           "    bool     addr;\n"
           "} _gpu_program;\n"
           "\n"
           "const size_t gpu_program_size = "<<code.size()<<";\n"
         <<"const _gpu_program gpu_program[gpu_program_size] = {\n"
         <<std::hex<<std::boolalpha;

    for (i = 0; i < code.size(); i++) {
        wfile<<"    {0x"<<std::setfill('0')<<std::setw(8)<<code[i].instruction.to_ulong();
        wfile<<", "     <<std::setfill(' ')<<std::setw(5)<<code[i].addr<<"},// "<<code[i].instruction<<"\n";
        std::cout<<code[i].instruction<<'\n';
    }

    wfile<<"};\n"
           "\n"
           "#endif\n";
    wfile.close();
}
