

import sys
import getopt

default_template = (
    "-- @obj_pkg_name@ -- Object code in VHDL constant table for "\
    "BRAM initialization.",
    "-- Generated automatically with script 'build_rom.py'.",
    "",
    "library ieee;",
    "use ieee.std_logic_1164.all;",
    "use ieee.numeric_std.all;",
    "use work.l80pkg.all;",
    "",
    "package @obj_pkg_name@ is",
    "",
    "constant @constant@ : obj_code_t(0 to @obj_size@) := (",
    "    @obj_bytes@",
    "    );",
    "",
    "end package @obj_pkg_name@;",       
    )


class command_line_params():
    def __init__(self):
        self.template_file = None
        self.package_name = None
        self.constant_name = "object_code"
        self.indent = 2
        self.proj_name = None
        
    

def usage():
    """Print usage instructions"""
    print ""
    print "usage:"
    print "python build_rom.py [arguments]\n"
    print "Builds VHDL ROM constant from template and Intel HEX object file.\n"
    print "ALL of the following arguments should be given, in any order:"
    print "{f|file} <filename>        Object code file name"
    print "{c|constant} <name>        Name of target VHDL constant"
    print "{p|package} <name>         Name of target VHDL package"
    print "{n|name} <name>            Name of project (used only in comment)"
    print "{o|output} <filename>      Target VHDL file name"
    print ""
    print "Additionally, any of these arguments can be given:"
    print "{v|vhdl} <filename>        VHDL template"
    print "         (defaults to templates/obj_code_kg_template.vhdl)"
    print "{i|indent} <number>        Indentation in VHDL tables (decimal)"
    print "         (defaults to 4)"


def help():
    """Print help message a bit longer than usage message."""
    print "\nPurpose:\n"
    print "Reads the code and data binary files and 'slices' them in byte"
    print "columns."
    print "The data columns are converted to VHDL strings and then inserted"
    print "into the vhdl template, in place of tags @code0@ .. @code3@ and "
    print "@data0@ .. @data3@. Column 0 is LSB and column3 is MSB.\n"
    print "Tags like @data31@ and @data20@ etc. can be used to initialize"
    print "memories in 16-bit buses, also split in byte columns.\n"
    print "Template tags are replaced as follows:"
    print "@obj_pkg_name@        : Name of package in target vhdl file"
    print "@const_name@          : Name of constant (VHDL table)"
    print "@obj_size@            : Total size of code table in bytes"


def parse_hex_line(line):
    """Parse code line in HEX object file."""
    line = line.strip()
    slen = int(line[1:3],16)
    sloc = int(line[3:7],16)
    stype = line[7:9]
    sdata = line[9:len(line)-2]
    schk = int(line[len(line)-2:],16)
        
    csum = slen + int(sloc / 256) + (sloc % 256) + int(stype,16)
    bytes = [0, ] * slen
    for i in range(slen):
        sbyte = int(sdata[i*2:i*2+2],16)
        bytes[i] = sbyte;
        csum = csum + sbyte
    
    csum = ~csum
    csum = csum + 1
    csum = csum % 256
    if csum != schk:
        return (None, None)
        
    return (sloc, bytes)

    
def read_ihex_file(ihex_filename):
    """
    """
    xcode = [0, ] * 65536
    bottom = 100000
    top = -1
    (xcode, top, bottom)

    fin = open(ihex_filename, "r")
    ihex_lines = fin.readlines()
    fin.close()
    
    total_bytes = 0
    for line in ihex_lines:
        (address, bytes) = parse_hex_line(line)
        if address == None:
            print "Checksum error!"
            sys.exit(1)
        total_bytes = total_bytes + len(bytes)
        for i in range(len(bytes)):
            xcode[address + i] = bytes[i]
        
        if address < bottom:
            bottom = address
    
        if (address + len(bytes)) > top:
            top = (address + len(bytes))
    
    print "Read %d bytes from file '%s'" % (total_bytes, ihex_filename)
    print "Code range %04xh to %04xh" % (bottom, top)
    return (xcode, total_bytes, bottom, top)

    
def build_vhdl_code(template_filename, xcode, rom_size, params):

    if not template_filename:
        lines = default_template
    else:
        fin = open(template_filename, "r")
        lines = fin.readlines()
        fin.close()
    
    vhdl_code = ""
    
    for line in lines:
        line = line.strip()
        
        if line.rfind("@obj_bytes@") >= 0:
            obj_str = "    "
            for i in range(rom_size):
                if i != (rom_size-1):
                    sbyte = "X\"%02x\", " % xcode[i]
                else:
                    sbyte = "X\"%02x\" " % xcode[i]
                obj_str = obj_str + sbyte
                if (i % 8) == 7:
                    obj_str = obj_str + "\n    "
                
            line = line.replace("@obj_bytes@",obj_str)
        
        if line.rfind("@obj_size@") >= 0:
            line = line.replace("@obj_size@","%d" % (rom_size-1))
        
        if line.rfind("@constant@") >= 0:
            line = line.replace("@constant@", params.constant_name)
        
        if line.rfind("@obj_pkg_name@") >= 0:
            line = line.replace("@obj_pkg_name@","obj_code_pkg")
            
        vhdl_code = vhdl_code + line + "\n"
    
    return vhdl_code
    

def main(argv):

    try:                                
        opts, _ = getopt.getopt(argv, "hf:n:p:c:o:i:v:", 
        ["help", "file=", "name=", "package=", "constant=", 
         "output=", "indent=", "vhdl=", ])
    except getopt.GetoptError, err:
        print ""
        print err
        usage()
        sys.exit(2)  

    # Give default values to command line parameters
    params = command_line_params()

    # Parse coommand line parameters
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            help()
            exit(1)
        if opt in ("-v", "--vhdl"):
            params.template_file = arg
        elif opt in ("-o", "--output"):
            target_filename = arg
        elif opt in ("-c", "--constant"):
            params.constant_name = arg
        elif opt in ("-f", "--file"):
            hex_filename = arg
        elif opt in ("-p", "--package"):
            params.package_name = arg
        elif opt in ("-n", "--name"):
            params.proj_name = arg
        elif opt in ("-i", "--indent"):
            params.indent = int(arg)
    
    if not target_filename:
        print "Missing target file name."
        usage()
        sys.exit(2)
        
    
    (xcode, total_bytes, bottom, top) = read_ihex_file(hex_filename);
    vhdl_code = build_vhdl_code(params.template_file, xcode, top, params);
    
    fout = None
    try:
        fout = open(target_filename, "w")
        fout.write(vhdl_code)
        fout.close()
        print "VHDL code table written to %s" % target_filename
    except:
        print "Trouble opening %s for output" % target_filename
    finally:
        if fout: fout.close()
    
    
    
    

if __name__ == "__main__":
    main(sys.argv[1:])

    sys.exit(0)

 