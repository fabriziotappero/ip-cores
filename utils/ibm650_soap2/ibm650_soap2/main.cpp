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

#include <getopt.h>
#include "soap2.h"

static void usage() {
    cout << "Usage: ibm650_soap2 [options] source_file" << endl;
    cout << "Options" << endl;
    cout << "  -h, --help           Print this message and exit." << endl;
    cout << "  -c, --punch_comments Punches comment cards." << endl;
    cout << "  -e, --punch_800x     Punches 800x cards." << endl;
    cout << "  -p, --punch_pseudo   Punches pseudo op cards." << endl;
    cout << "  -k, --check_object   Compare generated object to 7-word deck." << endl;
}

int main(int argc, char *argv[]) {
    ifstream file_source, file_check;
    ofstream file_list, file_obj;
    string name_prefix, name_source, name_list, name_obj, name_check;
    int ch;
    int help_flag = 0;
    int err_flag  = 0;
    int flags     = 0;

    static struct option longopts[] = {
        { "help",           no_argument,    NULL,   'h' },
        { "punch_comments", no_argument,    NULL,   'c' },
        { "punch_800x",     no_argument,    NULL,   'e' },
        { "punch_pseudo",   no_argument,    NULL,   'p' },
        { "check_object",   no_argument,    NULL,   'k' },
        { NULL,             0,              NULL,     0 }
    };

    while ((ch = ::getopt_long(argc, argv, "hcepk", longopts, NULL)) != -1)
        switch (ch) {
            case 'h':
                help_flag = 1;
                break;
            case 'c':
                flags |= asmflag_c;
                break;
            case 'e':
                flags |= asmflag_e;
                break;
            case 'p':
                flags |= asmflag_p;
                break;
            case 'k':
                flags |= asmflag_k;
                break;
            default:
                err_flag = 1;
                break;
    }
    argc -= optind;
    argv += optind;
    if (argc == 0) {
        cout << "Error: Missing source_file." << endl;
        err_flag = 1;
    }
    if (argc > 1) {
        cout << "Error: Extraneous argument(s)." << endl;
        err_flag = 1;
    }
    if (err_flag) {
        usage();
        return -1;
    }
    if (help_flag) {
        usage();
        return 0;
    }
    name_source = argv[0];
    if (string::npos != name_source.rfind('.')) {
        name_prefix = name_source.substr(0, name_source.rfind('.'));
        if (name_prefix.empty()) {
            cout << "Error: Malformed source_file." << endl;
            err_flag = 1;
        }
    } else {
        name_prefix = name_source;
    }
    name_list = name_prefix + ".listing";
    name_obj  = name_prefix + ".obj";
    name_check= name_prefix + ".7wd";
    file_source.open(name_source);
    if (!file_source) {
        cout << "Error: Unable to open source_file." << endl;
        err_flag = 1;
    }
    file_list.open(name_list);
    if (!file_list) {
        cout << "Error: Unable to open list_file." << endl;
        err_flag = 1;
    }
    file_obj.open(name_obj);
    if (!file_obj) {
        cout << "Error: Unable to open obj_file." << endl;
        err_flag = 1;
    }
    if (flags & asmflag_k) {
        file_check.open(name_check);
        if (!file_check) {
            cout << "Error: Unable to open check_file." << endl;
            err_flag = 1;
        }
    }
    if (err_flag) {
        usage();
        return -1;
    }
    soap2 myasm(cs_bcd48+cs_bcd48_f, flags, file_source, file_obj, file_list, file_check);
    return 0;
}
