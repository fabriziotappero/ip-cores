"""
    build_pkg.py -- builds simulation and synthesis configuration package.
    
    The generated package contains configuration constants used by the 
    simulation test bench 'mips_tb.vhdl' and by the hardware demo 
    'c2sb_demo.vhdl'.
    
    It too includes memory initialization constants containing object code,
    used to initialize simulated and inferred memories, both in simulation
    and in synthesis.
    
    In the code samples, this script is used to generate two separate packages
    for simulation and synthesis. Please refer to the makefiles for detailed
    usage examples.
"""

import sys
import os
import getopt



def usage():
    """Print usage instructions"""
    print ""
    print "usage:"
    print "python build_pkg.py [arguments]\n"
    print "Builds VHDL package from template and binary object files.\n"
    print "The following arguments can be given, in any order:"
    print ""
    print "{b|bin} <filename>         Object code file name (Plain binary)"
    print "{n|name} <name>            Name of object code constant"
    print "{p|package} <name>         Name of target VHDL package"
    print "{project} <name>           Name of project (used only in comment)"
    print "{o|output} <filename>      Target VHDL file name"
    print "{v|vhdl} <filename>        VHDL template"
    print "         (defaults to templates/obj_code_kg_template.vhdl)"
    print "{i|indent} <number>        Indentation in VHDL tables (decimal)"
    print "         (defaults to 4)"
    print "{o|output} <filename>      Target VHDL file name"
    print "{t|templates} <path>       Path of VHDL template directory"
    print "         (defaults to '../templates')"
    print ""
    print "The following optional parameters will define a constant in the VHDL"
    print "package if they are used (simulation configuration):"
    print ""
    print "{s|sim_length} <value>     Value of SIMULATION_LENGTH constant."
    print "{log_trigger} <value>      Value of LOG_TRIGGER_ADDRESS constant."
    print "{xram_size} <value>        Value of SRAM_SIZE constant."
    print "{flash_size} <value>       Value of PROM_SIZE constant."
    print "{xram_size} <value>        Value of SRAM_SIZE constant."    
    print ""
    print "The following optional parameters will define a constant in the VHDL"
    print "package if they are used (simulation and synthesis configuration):"
    print ""
    print "{bram_size} <value>        Value of BRAM_SIZE constant."    

    
def help():
    """Print help message a bit longer than the usage message."""
    print "\nPurpose:\n"
    print "Builds a VHDL package with configuration constants used in the "
    print "simulation test bench and in the synthesis of the SoC entity."
    print ""
    print "The package file is built from a template (presumably the template"
    print "included with this tool)."
    print ""
    print "See the makefiles of the code samples for usage examples."


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

    

def read_bin_file(bin_filename):
    """
    Read binary file into a byte array.
    Returns (code, size, bottom, top), where:
    
    code = array of bytes in file order (endianess irrelevant).
    size = number of bytes read from file.
    bottom = always zero.
    top = size - 1
    """
    objcode = [0, ] * 128*1024 # FIXME arbitrary limit should be removed
    bottom = 0
    top = -1
    #(objcode, top, bottom)

    # Read binary file
    f = open(bin_filename, "rb")
    try:
        size = os.path.getsize(bin_filename)
        objcode = [0, ] * size
        i = 0
        byte = f.read(1)
        while byte != "":
            objcode[i] = ord(byte)
            # Do stuff with byte.
            byte = f.read(1)
            i = i + 1
    finally:
            f.close()

    top = i-1
    total_bytes = i
    print "Read %d bytes from file '%s'" % (total_bytes, bin_filename)
    return (objcode, total_bytes, bottom, top)


def defined(pkg, val):
    
    return pkg.has_key(val) and pkg[val]
    

    
def build_vhdl_code(template_filename, blocks, package_params):

    fin = open(template_filename, "r")
    lines = fin.readlines()
    fin.close()
    
    vhdl_code = ""
    
    for line in lines:
        line = line.strip()
        
        while(True):
            if line.rfind("@obj_tables@") >= 0:
                obj_str = "";
                for block in blocks:
                    block_size = block['top']
                    block_data = block['data']
                    if not block.has_key('constant_name'):
                        print "Missing initialization constant name"
                        sys.exit(2)
                    block_name = block['constant_name']
                    block_top = block['top']
                    
                    if block_top <= 0:
                        # If the array is empty, we need to use special syntax 
                        obj_str = obj_str + \
                                  ("constant %s : t_obj_code(0 to 0) := " + \
                                  "(others => X\"00\");\n") % block_name            
                    else:                        
                        # Array contains binary data from file: write it
                        obj_str = obj_str + \
                                  "constant %s : t_obj_code(0 to %d) := (\n" % \
                                  (block_name, block_top-1)            
                        obj_str = obj_str + " "*package_params['indent']
                        for i in range(block_size):
                            if i != (block_size-1):
                                sbyte = "X\"%02x\", " % block_data[i]
                            else:
                                sbyte = "X\"%02x\" " % block_data[i]
                            obj_str = obj_str + sbyte
                            if (i % 8) == 7:
                                obj_str = obj_str + "\n" + " "*package_params['indent']
                        obj_str = obj_str + ");\n\n"
                    
                line = line.replace("@obj_tables@",obj_str)
            elif line.rfind("@constants@") >= 0:
                str = ""
                
                if defined(package_params, 'sim_length'):
                    str = str + \
                          "constant SIMULATION_LENGTH : integer := %d;\n" % \
                          int(package_params['sim_length'])
                if defined(package_params,'trigger_address'): 
                    str = str + \
                          "constant LOG_TRIGGER_ADDRESS : t_word := X\"%08x\";\n" % \
                          int(package_params['trigger_address'],16) 
                if defined(package_params,'xram_size'): 
                    str = str + \
                          "constant SRAM_SIZE : integer := %d;\n" % \
                          int(package_params['xram_size']) 
                if defined(package_params,'flash_size'): 
                    str = str + \
                          "constant PROM_SIZE : integer := %d;\n" % \
                          int(package_params['flash_size']) 
                if defined(package_params,'boot_bram_size'): 
                    str = str + \
                          "constant BRAM_SIZE : integer := %d;\n" % \
                          int(package_params['boot_bram_size']) 
                
                line = line.replace("@constants@", str)
            elif line.rfind("@project_name@") >= 0:
                line = line.replace("@project_name@",package_params['proj_name'])
            elif line.rfind("@obj_pkg_name@") >= 0:
                line = line.replace("@obj_pkg_name@",package_params['package_name'])
            else:
                break
            
        vhdl_code = vhdl_code + line + "\n"
    
    return vhdl_code
    

def main(argv):

    try:                                
        opts, _ = getopt.getopt(argv, "hp:c:o:i:v:b:t:n:s:", 
        ["help", "package=", "constant=", 
         "output=", "indent=", "vhdl=", "bin=", "templates=", 
         "name=", "sim_length=", 
         # parameters with no short-form
         "project=", "log_trigger=", "xram_size=", "flash_size=",
         "bram_size=", 
         "empty"])
    except getopt.GetoptError, err:
        print ""
        print err
        usage()
        sys.exit(2)  

    # Set default values for all command line parameters
    template_dir_name = "../templates"
    vhdl_filename = "obj_code_pkg_template.vhdl"
    target_filename = None
    
    package_params = {
        'boot_bram_size': 1024,
        'xram_size': 0,
        'flash_size': 0,
        'trigger_address': None,
        'indent': 2,
        'project_name': "<anonymous>",
        'package_name': "obj_code_pkg"      
        }
    
    block_params = {}
    blocks = []


    # Parse command line parameters
    for opt, arg in opts:
        # Options that affect the whole file
        if opt in ("-h", "--help"):
            usage()
            help()
            exit(1)
        if opt in ("-v", "--vhdl"):
            vhdl_filename = arg
        elif opt in ("-t", "--templates"):
            template_dir_name = arg
        elif opt in ("-i", "--indent"):
            package_params['indent'] = int(arg)
        elif opt in ("-o", "--output"):
            target_filename = arg
        elif opt in ("-p", "--package"):
            package_params['package_name'] = arg
        elif opt in ("--project"):
            package_params['proj_name'] = arg
        elif opt in ("--log_trigger"):
            package_params['trigger_address'] = arg
        elif opt in ("-s", "--sim_length"):
            package_params['sim_length'] = arg
        elif opt in ("--xram_size"):
            package_params['xram_size'] = arg
        elif opt in ("--flash_size"):
            package_params['flash_size'] = arg
        elif opt in ("--bram_size"):
            package_params['boot_bram_size'] = arg
        # Options for one initialization block 
        elif opt in ("-n", "--name"):
            if block_params.has_key('constant_name'):
                blocks.append(block_params)
                block_params = {}
            block_params['constant_name'] = arg
        elif opt in ("-b", "--bin"):
            if block_params.has_key('bin_filename'):
                blocks.append(block_params)
                block_params = {}
            block_params['bin_filename'] = arg

    if len(block_params.keys())>0:
        blocks.append(block_params)

    # Make sure we have a target file name
    if not target_filename:
        print "Target file not specified -- use -o"
        sys.exit(1)

    # Read all the binary data blocks
    for block in blocks:           
        if block.has_key('bin_filename'):
            if block['bin_filename']:
                (xcode, size, _, top) = read_bin_file(block['bin_filename']);
                block['data'] = xcode
                block['top'] = size
        else:
            # Named block is empty
            block['data'] = []
            block['top'] = 0
            
    # Compose template file name         
    template_filename = template_dir_name + "/" + vhdl_filename
    
    # Ready to go: build the package file contents
    vhdl_code = build_vhdl_code(template_filename, blocks, package_params);
    
    # Finally, write the package text to the target file
    fout = None
    try:
        fout = open(target_filename, "w")
        fout.write(vhdl_code)
        fout.close()
        print "VHDL code written to %s" % target_filename
    except:
        print "Trouble opening %s for output" % target_filename
    finally:
        if fout: fout.close()
    

if __name__ == "__main__":
    main(sys.argv[1:])

    sys.exit(0)

