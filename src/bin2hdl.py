""" 
Builds VHDL file from a template by replacing tags with parameter values.
See the makefiles of the code samples included in project ION for usage 
examples.
"""
import sys
import getopt
import math
import datetime


def usage():
    print ""
    print "usage:"
    print "python bin2hdl.py [arguments]\n"
    print "Inserts data in VHDL template\n"
    print "ALL of the following arguments should be given, in any order:"
    print "{c|code} <filename>        Code binary image file name"
    print "{v|vhdl} <filename>        VHDL template"
    print "{a|architecture} <name>    Name of target VHDL architecture"
    print "{e|entity} <name>          Name of target VHDL entity"
    print "{n|name} <name>            Name of project (used only in comment)"
    print "{o|output} <filename>      Target VHDL file name"
    print "code_size <number>         Size of bram memory in words (decimal)"
    print "data_size <number>         Size of data memory in words (decimal)"
    print "flash_size <number>        Size of flash memory in words (decimal)"
    print "(note the flash and xram info are used in simulation only)"
    print ""
    print "Additionally, any of these arguments can be given:"
    print "{t|log_trigger} <number>   Fetch address that triggers file logging"
    print "{s|sim_len} <number>       Length of simulation in clock cycles"
    print "{d|data} <filename>        Data binary image file name or 'empty'"
    print "{h|help}                   Display some help text and exit"
    print "{i|indent} <number>        Indentation in VHDL tables (decimal)"

def help():
    print "\nPurpose:\n"
    print "Reads the code and data binary files and 'slices' them in byte"
    print "columns."
    print "The data columns are converted to VHDL strings and then inserted"
    print "into the vhdl template, in place of tags @code0@ .. @code3@ and "
    print "@data0@ .. @data3@. Column 0 is LSB and column3 is MSB.\n"
    print "Tags like @data31@ and @data20@ etc. can be used to initialize"
    print "memories in 16-bit buses, also split in byte columns.\n"
    print "Other template tags are replaced as follows:"
    print "@entity_name@         : Name of entity in target vhdl file"
    print "@arch_name@           : Name of architecture in target vhdl file"
    print "@fileinfo@            : Info about the generated vhdl file"
    print "@sim_len@             : Length of simulation in clock cycles"
    print "@code_table_size@     : Size of code RAM block, in words"
    print "@code_addr_size@      : ceil(Log2(@code_table_size@))"
    print "@data_table_size@     : Size of data RAM block, in words"
    print "@data_addr_size@      : ceil(Log2(@data_table_size@))"
    

def build_vhdl_flash_table(flash, table_size, indent_size):
    # Build vhdl table for flash data
       
    # fill up empty table space with zeros
    if len(flash) < table_size*4:
        flash = flash + '\0'*4*(table_size-len(flash)/4)
            
    num_words = len(flash)/4
    remaining = num_words;
    col = 0
    vhdl_flash_string = "\n" + " "*indent_size
    for w in range(num_words):
        b0 = ord(flash[w*4+0]);
        b1 = ord(flash[w*4+1]);
        b2 = ord(flash[w*4+2]);
        b3 = ord(flash[w*4+3]);
        
        if remaining > 1:
            item = "X\"%02X%02X%02X%02X\"," % (b0, b1, b2, b3)
        else:
            item = "X\"%02X%02X%02X%02X\"" % (b0, b1, b2, b3)
        
        remaining = remaining - 1
        col = col + 1
        if col == 4:
           col = 0
           item = item + "\n" + " "*indent_size
        
        vhdl_flash_string = vhdl_flash_string + item
    
    return vhdl_flash_string

    
    
def build_vhdl_tables(code,table_size, indent_size):
    # Build the four byte column tables. [0] is LSB, [3] is MSB
    # Useful only for BRAM and SRAM tables
    tables = [[0 for i in range(table_size)] for i in range(4)]

    # Separate binary data into byte columns
    # (here's where data endianess matters, we're assuming big endian)
    byte = 0    # byte 0 is LSB, 3 is MSB
    index = 0   # index into column table    
    for c in code:
        #print str(ord(c)) + " " +  str(byte) + " " + str(index)
        tables[3-byte][index] = ord(c)
        #for k in tables:
        #    print k[0:4]
        byte = byte + 1
        if byte == 4:
            byte = 0
            index = index + 1
    
    # Write the data for each of the four column tables as a VHDL byte
    # constant table.
    vhdl_data_strings = [" "*indent_size]*7
    
    for j in range(4):
        col = 0
        word = len(tables[j])
        for c in tables[j]:
            word = word - 1
            if word > 0:
                item = "X\"%02X\"," % c
            else:
                item = "X\"%02X\"" % c
            col = col + 1
            if col == 8:
                col = 0
                item = item + "\n" + " "*indent_size
            vhdl_data_strings[j] = vhdl_data_strings[j] + item
        vhdl_data_strings[j] = "\n" + vhdl_data_strings[j]
    
    # ok, now build init strings for 16-bit wide memories, split in 2 byte 
    # columns: an odd column with bytes 3:1 and an even column with bytes 2:0
    byte_order = [3,1,2,0]
    for j in range(2):
        col = 0
        word_count = len(tables[j*2])
        for i in range(word_count):
            w_high = tables[byte_order[j*2+0]][i]
            w_low  = tables[byte_order[j*2+1]][i]
            word_count = word_count - 1
            if word_count > 0:
                item_h = "X\"%02X\"," % w_high
                item_l = "X\"%02X\"," % w_low
            else:
                item_h = "X\"%02X\"," % w_high
                item_l = "X\"%02X\"" % w_low
            item = item_h + item_l
            col = col + 1
            if col == 4:
                col = 0
                item = item + "\n" + " "*indent_size
            vhdl_data_strings[4+j] = vhdl_data_strings[4+j] + item
        vhdl_data_strings[4+j] = "\n" + vhdl_data_strings[4+j]
        
    # finally, build init strings for 32-bit wide memories not split into 
    # byte columns; useful for read-only 32-bit wide BRAMs
    byte_order = [3,2,1,0]
    col = 0
    word_count = len(tables[0])
    for i in range(word_count):
        w3 = tables[byte_order[0]][i]
        w2 = tables[byte_order[1]][i]
        w1 = tables[byte_order[2]][i]
        w0 = tables[byte_order[3]][i]
            
        word_count = word_count - 1
        if word_count > 0:
            item = "X\"%02X%02X%02X%02X\"," % (w3, w2, w1, w0)
        else:
            item = "X\"%02X%02X%02X%02X\"" % (w3, w2, w1, w0)

        col = col + 1
        if col == 4:
            col = 0
            item = item + "\n" + " "*indent_size
        vhdl_data_strings[6] = vhdl_data_strings[6] + item
    vhdl_data_strings[6] = "\n" + vhdl_data_strings[6]
        
        
        
    return vhdl_data_strings
    
def main(argv):
    code_filename = ""          # file with bram contents ('code')
    data_filename = ""          # file with xram contents ('data')
    flash_filename = ""         # file with flash contents ('flash')
    vhdl_filename = ""          # name of vhdl template file
    entity_name = "mips_tb"     # name of vhdl entity to be generated
    arch_name = "testbench"     # name of vhdl architecture to be generated
    proj_name = "<?>"           # name of project as shown in file info comment
    target_filename = "tb.vhdl" # name of target vhdl file
    indent = 4                  # indentation for table data, in spaces
    code_table_size = -1        # size of VHDL table
    data_table_size = -1        # size of VHDL table
    flash_table_size = 32;      # default size of flash table in 32-bit words
    log_trigger_addr = "X\"FFFFFFFF\"" # default log trigger address
    flash = ['\0']*4*flash_table_size # default simulated flash
    bin_words = 0               # size of binary file in 32-bit words 
    simulation_length = 22000   # length of logic simulation in clock cycles
    
    #

    try:                                
        opts, args = getopt.getopt(argv, "hc:d:v:a:e:o:i:s:f:t:n:", 
        ["help", "code=", "data=", "vhdl=", "architecture=", 
         # long name args that have short version
         "entity=", "output=", "indent=", "sim_len=", "flash=", "log_trigger=",
         "name=",
         # long name args that DON'T have short version
         "code_size=", "data_size=", "flash_size="])
    except getopt.GetoptError, err:
        print ""
        print err
        usage()
        sys.exit(2)  

    # Parse coommand line parameters
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            help()
            exit(1)
        if opt in ("-v", "--vhdl"):
            vhdl_filename = arg
        elif opt in ("-o", "--output"):
            target_filename = arg
        elif opt in ("-c", "--code"):
            code_filename = arg
        elif opt in ("-d", "--data"):
            data_filename = arg
        elif opt in ("-f", "--flash"):
            flash_filename = arg
        elif opt in ("-a", "--architecture"):
            arch_name = arg
        elif opt in ("-e", "--entity"):
            entity_name = arg
        elif opt in ("-n", "--name"):
            proj_name = arg
        elif opt in ("-i", "--indent"):
            indent = int(arg)
        elif opt in ("-t", "--log_trigger"):
            log_trigger_addr = "X\"%08X\"" % (int(arg,16))
        elif opt in ("-s", "--sim_len"):
            simulation_length = int(arg)
        elif opt == "--code_size":
            code_table_size = int(arg)
        elif opt == "--data_size":
            data_table_size = int(arg)
        elif opt == "--flash_size":
            flash_table_size = int(arg)
    
    # See if all mandatory options are there
    if code_filename=="" or vhdl_filename=="" or \
       code_table_size < 0 or data_table_size<0:
        print "Some mandatory parameter is missing\n"
        usage()
        sys.exit(2)

    # Once all cmd line argumets are parsed, build secondary stuff out of them.
    # Contents of 1st vhdl comment line
    fileinfo = "File built automatically for project '" + proj_name + \
               "' by bin2hdl.py" # + \
               #str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M"))

        
    #---------------------------------------------------------------------------    
    # Read BRAM initialization file, if any
    try:
        fin = open(code_filename, "rb")
        code = fin.read()
        fin.close()
    except IOError:
        print "Binary File %s not found" % code_filename

    # Make sure the code and data will fit in the tables
    bin_words = len(code) / 4
    if bin_words > code_table_size:
        print "Code does not fit table: " + str(bin_words) + " words,",
        print str(code_table_size) + " table entries"
        sys.exit(1)

    # Build the VHDL strings for each slice of the BRAM tables
    vhdl_code_strings = build_vhdl_tables(code, code_table_size, indent)
        

    #---------------------------------------------------------------------------
    # Read XRAM initialization file, if any.
    if data_filename != "":
        if data_filename == "empty":
            data = []
        else:
            try:
                fin = open(data_filename, "rb")
                data = fin.read()
                fin.close()
            except IOError:
                print "Binary File %s not found" % data_filename
                
        # FIXME We're not checking for BSS size here, only .data (?)
        bin_words = len(data) / 4
        if bin_words > data_table_size:
            print "Data does not fit table: " + str(bin_words) + " words,",
            print str(data_table_size) + " table entries"
            sys.exit(1)

        vhdl_data_strings = build_vhdl_tables(data, data_table_size, indent)
    else:
        # In case we didn't get a data binary, we will initialize any XRAM in
        # the template with zeros
        vhdl_data_strings = (["(others => X\"00\")"]*4) + \
                            (["(others => X\"00\")"]*2) + \
                            (["(others => X\"00000000\")"])
            
            
    #---------------------------------------------------------------------------
    # Read FLASH initialization file, if any 
    
    if flash_filename != "":
        if flash_filename == "empty":
            flash = [0]*flash_table_size
        else:
            try:
                fin = open(flash_filename, "rb")
                flash = fin.read()
                fin.close()
            except IOError:
                print "Binary File %s not found" % flash_filename

        # make sure file will fit simulated FLASH size
        bin_words = len(flash) / 4
        if bin_words > flash_table_size:
            print "Flash data does not fit table: " + str(bin_words) + " words,",
            print str(flash_table_size) + " table entries"
            sys.exit(1)


        # Build the VHDL strings for the simulated FLASH
    vhdl_flash_string = build_vhdl_flash_table(flash, flash_table_size, indent)
    
    
    #===========================================================================
    # OK, we just read all binary files and built all VHDL memory initialization
    # strings. Now start scanning the VHDL template, inserting data where needed
    
    # Read template file...
    fin = open(vhdl_filename, "r")
    vhdl_lines = fin.readlines()
    fin.close()        
    
    # ...and build the keyword and replacement tables
    keywords = ["@code0@","@code1@","@code2@","@code3@",
                "@code31@", "@code20@",
                "@code-32bit@",
                "@data0@","@data1@","@data2@","@data3@",
                "@data31@", "@data20@",
                "@data-32bit@",
                "@flash@",
                "@entity_name@","@arch_name@",
                "@fileinfo@",
                "@sim_len@",
                "@xram_size@",
                "@code_table_size@","@code_addr_size@",
                "@data_table_size@","@data_addr_size@",
                "@prom_size@",
                "@log_trigger_addr@"];
    replacement = vhdl_code_strings + vhdl_data_strings + \
                 [vhdl_flash_string,
                  entity_name, arch_name,
                  fileinfo,
                  str(simulation_length),
                  str(data_table_size),
                  str(code_table_size),
                  str(int(math.floor(math.log(code_table_size,2)))),
                  str(data_table_size), 
                  str(int(math.floor(math.log(data_table_size,2)))),
                  str(flash_table_size),
                  log_trigger_addr]
    
    # Now traverse the template lines replacing any keywords with the proper 
    # vhdl stuff we just built above.
    output = ""
    for vhdl_line in vhdl_lines:
        temp = vhdl_line
        for i in range(len(keywords)):
            if temp.rfind(keywords[i]) >= 0:
                temp = temp.replace(keywords[i], replacement[i])
                # uncomment this break to check for ONE keyword per line only
                #break
        output = output + temp
    
    try:
        fout = open(target_filename, "w")
        fout.write(output)
        fout.close()
        print "Wrote VHDL file '%s'" % target_filename
    except IOError:
        print "Could not write to file %s" % target_filename
    
    
    sys.exit(0)
        


if __name__ == "__main__":
    main(sys.argv[1:])

    sys.exit(0)

