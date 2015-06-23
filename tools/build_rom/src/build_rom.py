#!/usr/bin/env python
"""
build_rom.py: Create VHDL package with ROM initialization constant from 
Intel-HEX object code file.
Please use with --help to get some brief usage instructions.
"""
__author__ = "Jose A. Ruiz"
__license__ = "LGPL"


"""
Please see the usage instructions and the comments for function 'main'.
"""


import sys
import getopt



def usage():
    """Print usage instructions"""
    print ""
    print "usage:"
    print "python build_rom.py [arguments]\n"
    print "Builds VHDL ROM constant from template and Intel HEX object file.\n"
    print "ALL of the following arguments should be given, in any order:"
    print "{f|file} <filename>        Object code file name"
    print ""
    print "Additionally, any of these arguments can be given:"
    print "{h|help}                   Show help string and exit"
    print "{c|constant} <name>        Name of target VHDL object code constant"
    print "{p|package} <name>         Name of target VHDL package"
    print "{n|name} <name>            Name of project (used only in comments)"
    print "{o|output} <filename>      Target VHDL file name"
    print "{xcode} <number>           Size of XCODE memory in bytes"
    print "         (defaults to 2048)"
    print "{xdata} <number>           Size of XDATA memory in bytes"
    print "         (defaults to 0)"
    print "{v|vhdl} <filename>        VHDL template"
    print "         (defaults to templates/obj_code_kg_template.vhdl)"
    print "{i|indent} <number>        Indentation in VHDL tables (decimal)"
    print "         (defaults to 4)"


    
def help():
    """Print help message a bit longer than usage message."""
    print "\nPurpose:\n"
    print "Builds initialization package for Light52 MCU core."
    print "The object code bytes are converted to VHDL strings and then inserted"
    print "into the vhdl template, in place of tag @code_bytes@.\n"
    print "Template tags are replaced as follows:"
    print "@obj_pkg_name@        : Name of package in target vhdl file."
    print "@const_name@          : Name of object code constant (VHDL table)."
    print "@obj_size@            : Total size of code table in bytes."
    print "@obj_bytes@           : Array of object code bytes."
    print "@project_name@        : Project name."
    print "@xcode_size@          : Size of XCODE memory."
    print "@xdata_size@          : Size of XDATA memory."

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
    Read Intel HEX file into a 64KB array.
    The file is assumed not to have any object code outside the 64K boundary.
    Return the 64K array plus the size and bounds of the read data.
    """
    
    # CODE array, initialized to 64K of zeros...
    xcode = [0, ] * 65536
    # ...and code boundaries, initialized out of range.
    bottom = 100000
    top = -1
    (xcode, top, bottom)

    # Read the whole file to a list of lines...
    fin = open(ihex_filename, "r")
    ihex_lines = fin.readlines()
    fin.close()
    
    # ...and parse the lines one by one.
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

    
def build_vhdl_code(params, xcode, obj_size):
    """
    Read VHDL template file and replace all the tags with the values given in
    the command line parameters.
    Return the new file contents as a string.
    """
    
    # The resulting VHDL text will be stored here.
    vhdl_code = ""

    
    # Open file and read it into a list of lines.
    fin = open(params['template'], "r")
    lines = fin.readlines()
    fin.close()
        
    # Now process the template lines one by one.
    for line in lines:
        line = line.strip()
        
        if line.rfind("@obj_bytes@") >= 0:
            # insert object code as list of byte literals.
            obj_str = "    "
            for i in range(obj_size):
                if i != (obj_size-1):
                    sbyte = "X\"%02x\", " % xcode[i]
                else:
                    sbyte = "X\"%02x\" " % xcode[i]
                obj_str = obj_str + sbyte
                if (i % 8) == 7:
                    obj_str = obj_str + "\n    "
                
            line = line.replace("@obj_bytes@",obj_str)
        
        elif line.rfind("@obj_size@") >= 0:
            # Insert object code size (not necessarily equal to xcode_size)
            line = line.replace("@obj_size@","%d" % (obj_size-1))

        elif line.rfind("@xcode_size@") >= 0:
            # Insert XCODE memory
            line = line.replace("@xcode_size@","%d" % (params['xcode_size']))

        elif line.rfind("@xdata_size@") >= 0:
            # Insert XDATA memory
            line = line.replace("@xdata_size@","%d" % (params['xdata_size']))
            
        elif line.rfind("@obj_pkg_name@") >= 0:
            # Insert package name: hardwired
            line = line.replace("@obj_pkg_name@",params['package'])
        
        elif line.rfind("@project_name@") >= 0:
            # Insert project name 
            line = line.replace("@project_name@",params['project'])
        
        
        vhdl_code = vhdl_code + line + "\n"
    
    return vhdl_code
    

def main(argv):
    """Main body of the program."""
    
    # Parse command line parameters using GetOpt 
    try:                                
        opts, args = getopt.getopt(argv, "hf:n:p:c:o:i:v:", 
        ["help", "file=", "name=", "package=", "constant=", 
         "output=", "indent=", "vhdl=", "xcode=", "xdata=" ])
    except getopt.GetoptError, err:
        print ""
        print err
        usage()
        sys.exit(2)  

    # Command line parameters, initialized to their default values
    params = {'project':    '<unknown>',
              'package':    'obj_code_pkg',
              'indent':     4,
              'constant':   'obj_code',
              'target':     'obj_code_pkg.vhdl',
              'hex':        '',
              'xcode_size': 2048,
              'xdata_size': 0,
              'template':   "./templates/obj_code_pkg_template.vhdl"
              }
                

    # Parse coommand line parameters
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            help()
            exit(1)
        if opt in ("-v", "--vhdl"):
            params['template'] = arg
        elif opt in ("-o", "--output"):
            params['target'] = arg
        elif opt in ("-c", "--constant"):
            params['constant'] = arg
        elif opt in ("-f", "--file"):
            params['hex'] = arg
        elif opt in ("-p", "--package"):
            params['package'] = arg
        elif opt in ("-n", "--name"):
            params['project'] = arg
        elif opt in ("-i", "--indent"):
            params['indent'] = int(arg)
        elif opt in ("--xcode"):
            params['xcode_size'] = int(arg)
        elif opt in ("--xdata"):
            params['xdata_size'] = int(arg)

    # Ok, now read and parse the input Intel HEX object code file.
    if params['hex']:
        (xcode, total_bytes, bottom, top) = read_ihex_file(params['hex']);
    else:
        print "Object HEX file name missing.";
        usage()
        return 1
    
    
    # Make sure the object code fits into the implemented XCODE space.
    # If it doesn't, print a warning and let the user deal with it.
    # Assuming that XCODE starts at address zero -- that's how the core works.
    if params['xcode_size'] < top:
        print "\nWARNING: Object code does not fit XCODE space!\n"
        

    # Build the package source...
    vhdl_code = build_vhdl_code(params, xcode, top);
    
    # ...and write it to the target file.
    fout = None
    try:
        fout = open(params['target'], "w")
        fout.write(vhdl_code)
        fout.close()
        print "VHDL code table written to %s" % params['target']
    except:
        print "Trouble opening %s for output" % params['target']
    finally:
        if fout: fout.close()
    
    
if __name__ == "__main__":
    main(sys.argv[1:])
    sys.exit(0)

 