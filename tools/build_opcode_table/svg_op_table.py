#!/usr/bin/env python
"""
svg_op_table.py: Build 3 SVG files with the MCS51 opcode table decorated with 
cycle count information extracted from the cycle count simulation log file.
"""
__author__ = "Jose A. Ruiz"
__license__ = "LGPL"


import sys
import getopt


def read_cycle_info(filename):
    """
    the file should have 256 lines of text.
    Each line has 4 comma-separated fields:
        opcode, minimum cycle count, maximum cycle count, number of executions.
    The number of executions is the number of times the opcode was executed by 
    the simulation that produced the log.
    If this number is zero, or if the minimum cycle count is >= 999, then
    the opcode has not been executed and there's no cycle count data for it.
    
    This function returns a list of 256 tuples sorted by opcode, with the 
    above 3 values (the opcode is excluded).
    """
    
    # Open file and read it into a list of lines.
    fin = open(filename, "r")
    lines = fin.readlines()
    fin.close()
    
    info = [[]] * 256;

    for line in lines:
        fields = line.split(',')
        opc = int(fields[0],16)
        info[opc] = (int(fields[1]), int(fields[2]), int(fields[3]))
    return info


def read_opcode_info(filename):
    """
    Read a table of MCS51 opcodes from a plain text file.
    Rather than writing here a lengthy explanation I invite you to see the 
    opcode table text file "opcode_info.txt".
    Since the file is known, we don't provide for formatting errors, missing 
    lines or any kind of trouble.
    This file has been copy-pasted straight from Keil's website and slightly 
    edited.
    """
    
    # Open file and read it into a list of lines.
    fin = open(filename, "r")
    lines = fin.readlines()
    fin.close()
    
    # We'll build a table with 256 entries, one per opcode.
    info = [[]] * 256;

    for line in lines:
        [opcode, _, line] = line.partition('\t')
        [nbytes, _, line] = line.partition('\t')
        [mnemonic, _, operands] = line.partition('\t')
        i = int(opcode, 16)
        info[i] = [mnemonic.strip(), operands.strip(), int(nbytes)]
    
    return info
   
def opcode_unimplemented(opc):
    """Return true if the opcode is not implemented (implemented as NOP)."""
    # FIXME this should be optional, like the implementation itself.
    return opc=="DA" or opc=="XCHD"
   
    
def build_svg_table(info, cycles, part):
    """
    Render the opcode table, or one half of it, in SVG format.
    @arg info Array of opcode information as returned by read_opcode_info.
    @arg cycles Array of opcode cycle counts as returned by read_cycle_info.
    @arg part Can be one of ("left","right","full").
    Return a string in SVG format to be written to a file.
    """


    # (lc,hc) is the range of columns we're going to draw. It can be the whole 
    # table or the left or right half.
    if part=="left":
        lc = 0
        hc = 8
    elif part=="right":
        lc = 8
        hc = 16
    else:
        lc = 0
        hc = 16

    # Hardcode the rendering parameters: size of the cells, etc.
    # Note that other parameters (font size and text coordinates) are hardcoded
    # in the string literals below.
    scale = 1.0
    c_width = 300  
    c_height = 200
    cr_height = c_height
    cr_width = c_width / 2
    cc_height = c_height / 2
    cc_width = c_width

    # Compute the SVG frame size according to the selected part.
    w = hc - lc
    width = c_width*w + cr_width + 20
    height = c_height*16 + cc_height + 20
    
    # This is the SVG header template. 
    header = \
    "<svg xmlns='http://www.w3.org/2000/svg' \n" + \
    "xmlns:xlink='http://www.w3.org/1999/xlink' \n" + \
    "width='%d' height='%d' viewbox='0 0 %d %d' \n" + \
    "preserveAspectRatio='none'>\n\n"
    
    # We'll append all the SVG text onto this variable.
    svg = ""
    
    # Build the SVG header with the selected size.
    svg = svg + header % (width, height, width, height)

    # SVG definitions template. There's 3 cells, for the table borders and
    # the table body.
    defs = \
    '<defs>\n' + \
    '<!-- Basic table cell -->\n' + \
    '<rect height="%d" width="%d" stroke="black" stroke-width="1" id="s"/>\n' + \
    '<!-- Row index cell -->\n' + \
    '<rect height="%d" width="%d" stroke="black" stroke-width="1" id="r"/>\n' + \
    '<!-- Col index cell -->\n' + \
    '<rect height="%d" width="%d" stroke="black" stroke-width="1" id="c"/>\n' + \
    '</defs>\n\n'

    # Build SVG definitions block with its parameters -- cell sizes.
    svg = svg + defs % (c_height, c_width, cr_height, cr_width, cc_height, cc_width)

    # This is a SVG group template for the main table cell.
    # Note that the font sizes and text coordinates are hardcoded!
    base_cell = \
    '<g transform="translate(%d,%d) scale(%f)">\n' + \
    '<use x="0" y="0" xlink:href="#s" fill="%s"/>\n' + \
    '<text x="80" y="90" font-family="sans-serif" font-size="55">%s</text>\n' + \
    '<text x="80" y="140" font-family="sans-serif" font-size="40">%s</text>\n' + \
    '<text x="10" y="40" font-family="verdana" fill="red" font-size="40">%s</text>\n' + \
    '<text x="260" y="40" font-family="verdana" fill="blue" font-size="40">%d</text>\n' + \
    '</g>\n\n'
    
    # SCG group template for a cell to the left of the table with a row number.
    row_index_cell = \
    '<g transform="translate(%d,%d) scale(%f)">\n' + \
    '<use x="0" y="0" xlink:href="#r" fill="white"/>\n' + \
    '<text x="80" y="90" font-family="sans-serif" font-size="55">%01X</text>\n' + \
    '</g>\n\n'

    # SCG group template for a cell at the top of the table with a col number.
    col_index_cell = \
    '<g transform="translate(%d,%d) scale(%f)">\n' + \
    '<use x="0" y="0" xlink:href="#c" fill="white"/>\n' + \
    '<text x="80" y="70" font-family="sans-serif" font-size="55">%01X</text>\n' + \
    '</g>\n\n'
    
    # Build the top row of the table: cells with the column number.
    for col in range(lc,hc):
        y = 10
        x = 10 + (cr_width + (col-lc)*c_width)*scale
        svg = svg + col_index_cell % (x, 10, scale, col)
    
    # Now, for each of the 16 rows...
    for row in range(16):
        # ...compute the row vertical coordinate...
        y = 10 + (cc_height + row*c_height)*scale
        # ...render the leftmost cell with the row index...
        svg = svg + row_index_cell % (10, y, scale, row)
        # ...and render the row of main-table-body cells.
        
        # for each of the cells in the column range we're rendering...
        for col in range(lc,hc):
            # ...compute the horizintal coordinate of the cell...
            x = 10 + (cr_width + (col-lc)*c_width)*scale
            
            # ...and extract the cycle count data from the array.
            opc = col*16 + row
            min = cycles[opc][0]
            max = cycles[opc][1]
            # When min/=max we need to display both values (conditional
            # jumps, for instance).
            # Those opcodes with a min value >=999 have not been executed by 
            # the simulation and we'll render them in a darker shade of grey.
            if min < 999:
                if min==max:
                    count = str(min)
                else:
                    count = str(min) + "/" + str(max)
                color = "white"
            else:
                count = " "
                color = "#e0e0e0"
            
            # Render the cell with all its parameters.
            
            
            # Render the 'optional' opcodes in red.
            if opcode_unimplemented(info[opc][0]):
                color = "#f0b0b0"
            
            cell = base_cell % (x, y, scale, color, info[opc][0], info[opc][1], count, info[opc][2])
                
            svg = svg + cell
    
    # Done, close the SVG element and we're done.
    svg = svg + '</svg>'
    
    return svg


def write_cycle_table(cycle_info, c_table_file):
    """
    Writes the cycle count info in the format of a C literal table.
    Meant to be copied and pasted into the B51 simulator.
    """
    
    txt = "typedef struct {\n"
    txt = txt + "    int min;\n"
    txt = txt + "    int max;\n"
    txt = txt + "} cycle_count_t;\n"
    txt = txt + "\n\n"
    txt = txt + "cycle_count_t cycle_count[256] = {\n    "
    for i in range(len(cycle_info)):
        item = cycle_info[i]
        if item[2] == 0:
            txt = txt + "{ 0, 0}, "
        else:
            txt = txt + "{%2u,%2u}, " % (item[0], item[1])
        if (i % 8) == 7:
            txt = txt + "\n    "
    txt = txt + "};\n\n"
    
    
    fout = open(c_table_file, "w")
    fout.write(txt)
    fout.close()
    

def main(argv):
    """Main body of the program."""

    # We should parse the command line arguments, etc. 
    # For this quick-and-dirty script we'll hardcode all the parameters...
    
    # ...the target svg file names...
    svg_base_filename = "./table"
    # ...the target text file name where a C-format table with the cycle counts
    # will be written to...
    c_table_file = "./cycle_table.c"
    # ...and the source CSV cycle count log file. Note this path is the default
    # working path for the Modelsim simulations, change if necessary.
    cycle_log_filename = "../../sim/cycle_count_log.csv"
    
    # Read cycle count data...
    cycle_info = read_cycle_info(cycle_log_filename)
    # ...and read opcode table data (instruction mnemonics and byte counts).
    opcode_info = read_opcode_info("opcode_info.txt")
    
    # First of all, write the C-format cycle table, to be copied and pasted
    # into the B51 simulator.
    write_cycle_table(cycle_info, c_table_file)
    
    # We can render the opcode table 'whole', resulting in a wide table, or
    # we can render the left and right halves separately, which gives a format
    # better suted for a printed page. 
    
    # So, for all three possible rendering formats...
    parts = ("left", "right", "full")
    # ...render the opcode table.
    for part in parts:
        
        # Build the SVG text for the table...
        svg = build_svg_table(opcode_info, cycle_info, part)
        # ...and write it to the target file.
        fout = None
        try:
            full_filename = svg_base_filename + "_" + part + ".svg"
            fout = open(full_filename, "w")
            fout.write(svg)
            fout.close()
            print "SVG opcode table written to %s" % full_filename
        except:
            print "Trouble opening %s for output" % full_filename
        finally:
            if fout: fout.close()
    
    
if __name__ == "__main__":
    main(sys.argv[1:])
    sys.exit(0)

 