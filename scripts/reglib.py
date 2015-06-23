#!/usr/bin/env python
# Copyright (c) 2004 Guy Hutchison (ghutchis@opencores.org)
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import string, math, re

def log2 (num):
    return math.ceil (math.log (num) / math.log (2))

# function that tries to interpret a number in Verilog notation
def number (str):
    try:
        robj = re.compile ("(\d+)'([dhb])([\da-fA-F]+)")
        mobj = robj.match (str)
        if (mobj):
            if mobj.group(2) == 'h': radix = 16
            elif mobj.group(2) == 'b': radix = 2
            else: radix = 10
    
            return int (mobj.group(3), radix)
        else:
            return int(str)
    except ValueError:
        print "ERROR: number conversion of %s failed" % str
        return 0

def int2bin (n):
    bStr = ''
    if (n < 0): raise ValueError, "must be positive integer"
    if (n == 0): return '0'
    while (n > 0):
        bStr = str (n%2) + bStr
        n = n >> 1
    return bStr
    
def comb_block (statements):
    result = 'always @*\n'
    result += '  begin\n'
    for s in statements:
        result += '    ' + s + '\n'
    result += '  end\n'
    return result

def seq_block (clock, statements):
    result = 'always @(posedge ' + clock + ' or negedge reset_n)\n'
    result += '  begin\n'
    for s in statements:
        result += '    ' + s + '\n'
    result += '  end\n'
    return result

class net:
    def __init__ (self, type, name, width=1):
        self.width = width
        self.name  = name
        self.type  = type

    def declaration (self):
        if (self.width == 1):
            return self.type + ' ' + self.name + ';'
        else:
            return "%s [%d:0] %s;" % (self.type, self.width-1, self.name)
        
class port:
    def __init__ (self, direction, name, width=1):
        self.direction = direction
        self.width = width
        self.name = name

    def declaration (self):
        if (self.width == 1):
            return self.direction + ' ' + self.name + ';'
        else:
            return "%s [%d:0] %s;" % (self.direction, self.width-1, self.name)

class decoder_range:
    def __init__ (self, name, base, bits):
        self.name = name
        self.base = base
        self.bits = bits

    def check_range(self):
        mask = (1 << self.bits) - 1
        if (self.base & mask):
            return 1
        else: return 0

    def get_base_addr(self):
        return self.base
        
class decoder_group:
    def __init__ (self, mem_mapped=0):
        self.addr_size = 16
        self.data_size = 8
        self.name = ''
        self.ranges = []
        self.ports = [port ('input', 'clk'), port('input','reset_n')]
        self.nets  = []

        self.blocks = []

    def build (self):
        self.ports.append (port ('input', 'cfgi_irdy'))
        self.ports.append (port ('output', 'cfgi_trdy'))
        self.ports.append (port ('input', 'cfgi_write'))
        self.ports.append (port ('input', 'cfgi_addr', self.addr_size))
        self.ports.append (port ('input', 'cfgi_wr_data', self.data_size))
        self.ports.append (port ('output', 'cfgo_wr_data', self.data_size))
        self.ports.append (port ('output', 'cfgi_rd_data', self.data_size))
        self.ports.append (port ('output', 'cfgo_addr', self.addr_size))
        self.ports.append (port ('output', 'cfgo_write'))
        self.nets.append (net('reg','cfgi_rd_data',self.data_size))
        self.nets.append (net('reg','nxt_rd_data',self.data_size))
        self.nets.append (net('reg', 'nxt_cfgi_trdy'))
        self.nets.append (net('reg', 'irdy_out'))
        self.nets.append (net('reg', 'trdy_out'))
        self.nets.append (net('reg', 'cfgo_wr_data', self.data_size))
        self.nets.append (net('reg', 'cfgo_addr', self.addr_size))
        self.nets.append (net ('reg', 'cfgo_write'))
        self.nets.append (net ('reg', 'cfgi_trdy'))
        self.blocks.append ( """
   always @(posedge clk or negedge reset_n)
    begin
      if (~reset_n)
        begin
          irdy_out <= #1 0;
          cfgo_wr_data <= #1 0;
          cfgo_addr <= #1 0;
          cfgo_write <= #1 0;
          cfgi_trdy  <= #1 0;
        end
      else
        begin
          irdy_out <= #1 (irdy_out) ? !trdy_out : cfgi_irdy & ~cfgi_trdy;
          cfgi_trdy <= #1 irdy_out & trdy_out;

          if (cfgi_irdy & !irdy_out)
           begin
            cfgo_wr_data  <= #1 cfgi_wr_data;
            cfgo_addr     <= #1 cfgi_addr;
            cfgo_write    <= #1 cfgi_write;
           end
          if (trdy_out & !cfgo_write)
           cfgi_rd_data <= #1 nxt_rd_data;
        end // else: !if(reset)
    end // always @ (posedge clk)\n""")

        addr_mux = ["casez (cfgo_addr)\n"]
        for r in self.ranges:
            self.ports.append (port ('output', r.name + "_irdy"))
            self.ports.append (port ('input', r.name + "_trdy"))
            self.ports.append (port ('input', r.name + "_rd_data", self.data_size))
            self.nets.append (net('reg', r.name + "_irdy"))
            addr_mux.insert(0, "%s_irdy = 0;" % r.name)
            base_addr = int2bin (r.base)
            #for b in range(-r.bits,0):
            #    base_addr[b] = 'z'
            fill = self.addr_size - len(base_addr)
            if (fill > 0):
                base_addr = '0' * fill + base_addr
            base_addr = base_addr[:-r.bits] + 'z'*r.bits
            addr_mux.append ("%d'b%s :" % (self.addr_size, base_addr))
            addr_mux.append ("begin")
            addr_mux.append ("%s_irdy = irdy_out;" % r.name)
            addr_mux.append ("trdy_out = %s_trdy;" % r.name)
            addr_mux.append ("nxt_rd_data = %s_rd_data;" % r.name)
            addr_mux.append ("end")

        addr_mux.append("""
        default :
          begin
            trdy_out = 1'b1;
            nxt_rd_data = 0;
          end
        endcase\n""")

        self.blocks.append (comb_block(addr_mux))
            
         
    def verilog (self):
        self.build()
        result = 'module ' + self.name + ' (\n'
        result += string.join (map (lambda x: x.name, self.ports), ',')
        result += ');\n'

        # print port list
        for p in self.ports:
            result += p.declaration() + '\n'

        # print net list
        for n in self.nets:
            result += n.declaration() + '\n'

        # create all blocks in block list
        for b in self.blocks:
            result += b
        
        result += 'endmodule\n'
        return result

      

    def add_range (self, r):
        self.ranges.append (r)

class register_group:
    def __init__ (self, mem_mapped=0):
        self.base_addr = 0
        self.addr_size = 16
        self.data_size = 8
        self.name = ''
        self.local_width = 1  # number of address bits consumed
        self.registers = []
        self.ports = [port ('input', 'clk'), port('input','reset_n')]
        self.nets  = []
        self.interrupts = 0   # if interrupt registers present
        self.user = 0         # if user-defined registers present
        self.blocks = []
        self.registered_read = 0
        self.hold_regs = 0
        self.hold_inputs = []

    def top_intf (self):
        self.ports.append (port ('input', 'rf_irdy'))
        self.ports.append (port ('output', 'rf_trdy'))
        self.ports.append (port ('input', 'rf_write'))
        self.ports.append (port ('input', 'rf_addr', self.addr_size))
        self.ports.append (port ('input', 'rf_wr_data', self.data_size))
        self.ports.append (port ('output', 'rf_rd_data', self.data_size))
        self.nets.append (net('reg','rf_rd_data',self.data_size))
        self.nets.append (net('reg', 'nxt_rf_trdy'))
        if (self.registered_read):
            self.nets.append (net('reg','nxt_rf_rd_data',self.data_size))
        for i in range(0,self.hold_regs):
            self.nets.append (net('reg',"xxhold_%d" % i,self.data_size))
            self.nets.append (net('reg',"nxt_xxhold_%d" % i,self.data_size))
        self.nets.append (net('reg', 'rf_trdy'))

    def build_load_mux (self):
        for i in range(0,self.hold_regs):
            nn = "nxt_xxhold_%d" % i
            txt = []
            for hi,nregs in self.hold_inputs:
                high = (i+1) * self.data_size - 1
                low = i* self.data_size
                if (i < nregs):
                    txt.append ("if (%s_rd_stb) %s = %s_in[%d:%d];" % (hi, nn, hi, high, low))
                    txt.append ("else if (%s_%d_wr_sel) %s = rf_wr_data; else " % (hi, i, nn))
            txt.append("%s = xxhold_%d;" % (nn, i))
            self.blocks.append (comb_block(txt))

    # create a hook for post-processing to be done after all data has been
    # added to the object.
    def post (self):
        self.top_intf()
        for reg in self.registers:
            self.ports.extend (reg.io())
            self.nets.extend (reg.nets())
            #self.local_width = int(math.ceil (log2 (len (self.registers))))
            self.local_width = self.addr_size;
            rnum = 0
            for r in self.registers:
                r.offset = rnum
                rnum += 1
        self.build_load_mux()
        if (self.interrupts):
            self.int_ports()
        
    # create port for interrupt pin, as well as port for data output enable
    # when interrupt is asserted.
    # This block should be called after all register data has been read.
    def int_ports (self):
        self.ports.append (port ('output','int_n'))
        self.nets.append (net ('reg','int_n'))
        #self.nets.append (net ('reg','int_vec',self.data_size))

    def int_logic (self):
        int_nets = []
        for r in self.registers:
            if r.interrupt: int_nets.append (r.name + "_int")
        self.blocks.append (comb_block (["int_n = ~(" + string.join (int_nets, ' | ') + ");"]))

    def wait_logic (self):
        wait_nets = []
        for r in self.registers:
            if r.type() == 'user':
                wait_nets.append (r.name + "_wait_n")
            elif r.type() == 'ext_load':
                if r.eindex == 0:
                    wait_nets.append (r.name + "_wait_n")
        if (len(wait_nets) > 0):
            self.blocks.append (comb_block (["if (rf_trdy) nxt_rf_trdy = 0;",
                                            "else if (rf_irdy) nxt_rf_trdy = " + ' & '.join (wait_nets) + ";",
                                            "else nxt_rf_trdy = 0;"]))
        else:
            self.blocks.append (comb_block (["if (rf_trdy) nxt_rf_trdy = 0;",
                                            "else if (rf_irdy) nxt_rf_trdy = 1;",
                                            "else nxt_rf_trdy = 0;"]))
        self.blocks.append (seq_block ("clk", ["if (~reset_n) rf_trdy <= #1 0;",
                                        "else rf_trdy <= #1 nxt_rf_trdy;"]))
        #if (len(wait_nets) > 0):
        #    self.blocks.append (comb_block (["wait_n = " + string.join (wait_nets, ' & ') + ";"]))

        if (self.registered_read):
            self.blocks.append (seq_block ("clk", ["if (~reset_n) rf_rd_data <= #1 0;", "else if (nxt_rf_trdy) rf_rd_data <= #1 nxt_rf_rd_data;"]))
        for i in range (0,self.hold_regs):
            self.blocks.append (seq_block ("clk", ["if (~reset_n) xxhold_%d <= 0;"%i,"else xxhold_%d <= nxt_xxhold_%d;" % (i, i)]))
        

    def global_logic (self):
        # create select pin for this block
        statements = []

        # create read and write selects for each register
        for r in self.registers:
            slogic =  "(rf_addr[%d:%d] == %d) & rf_irdy & !rf_write" % (self.local_width-1,0,r.offset)
            #if r.interrupt:
            #    slogic = "%s_int | (%s)" % (r.name, slogic)
            s = "%s_rd_sel = %s;" % (r.name,slogic)
            statements.append (s)
            if r.write_cap():
                s = "%s_wr_sel = (rf_addr[%d:%d] == %d) & rf_irdy & rf_write;\n" % (r.name,self.local_width-1,0,r.offset)
                statements.append (s)

        return comb_block (statements)

    def read_mux (self):
        s = ''
        sments = []
        rd_sel_list = []

        # create data-output mux
        sments.append ("case (1'b1)")
        if (self.registered_read):
            rd_target = "nxt_rf_rd_data"
        else:
            rd_target = "rf_rd_data"
        for r in self.registers:
            sments.append ("  %s_rd_sel : %s = %s;" % (r.name, rd_target, r.name))
            rd_sel_list.append (r.name + "_rd_sel")
        #if (self.interrupts):
        #    sments.append ("  default : rd_data = int_vec;")
        sments.append ("  default : %s = %d'b0;" % (rd_target, self.data_size))
        sments.append ("endcase")

        #sments.append ("doe = %s;" % string.join (rd_sel_list, ' | '))

        return comb_block (sments)
                
        
    def verilog (self):
        self.post()
        
        result = 'module ' + self.name + ' (\n'
        result += string.join (map (lambda x: x.name, self.ports), ',')
        result += ');\n'

        # print port list
        for p in self.ports:
            result += p.declaration() + '\n'

        # print net list
        for n in self.nets:
            result += n.declaration() + '\n'

        # create global logic
        result += self.global_logic()
        result += self.read_mux()
        if (self.interrupts > 0): self.int_logic()
        self.wait_logic()

        # create all blocks in block list
        for b in self.blocks:
            result += b
        
        # print function blocks
        for r in self.registers:
            result += r.verilog_body()
            
        result += 'endmodule\n'
        return result

    # calculate number of holding registers required and update
    # hold_regs internal property
    def calc_hold (self, width):
        hregs = width / self.data_size
        if (width % self.data_size) != 0:
            hregs += 1
        if (hregs > self.hold_regs):
            self.hold_regs = hregs
        return hregs

    def add_register (self, type, params):
    #def add_register (self, name, type, width):
        if (type == 'status'):
            self.add (status_reg (params['name'],params['width']))
        elif (type == 'config'):
            self.add (config_reg (params['name'],params['width'],params['default']))
        elif (type == 'int_msk'):
            r2 = config_reg (params['name'] + "_msk",params['width'],params['default'])
            r1 = int_msk_reg (params['name'],r2,params['width'])
            self.add (r1)
            self.add (r2)
            self.interrupts += 1
        elif (type == 'soft_set'):
            self.add (soft_set_reg(params['name'],params['width'],params['default']))
        elif (type == 'read_stb'):
            self.add (read_stb_reg (params['name'],params['width']))
        elif (type == 'write_stb'):
            self.add (write_stb_reg (params['name'],params['width'],params['default']))
        elif (type == 'user'):
            self.user = 1
            self.add (user_reg (params['name'],params['width']))
        elif (type == 'ext_load'):
            width = params['width']
            regs = self.calc_hold (width)
            print "ext_load %s, splitting into %d regs" % (params['name'],regs)
            for i in range(0,regs):
                last = (i == (regs-1))
                self.add (ext_load_reg(params['name'],self.data_size,i,params['width'],last))
            self.hold_inputs.append ( (params['name'], regs) )
        elif (type == 'count'):
            self.add (count_reg (params['name'],params['width']))
        else:
            print "Unknown register type",type

    def add (self, reg):
        self.registers.append (reg)
        #self.ports.extend (reg.io())
        #self.nets.extend (reg.nets())
        #self.local_width = int(math.ceil (log2 (len (self.registers))))
        #rnum = 0
        #for r in self.registers:
        #    r.offset = rnum
        #    rnum += 1
        
class basic_register:
    def __init__ (self, name='', width=0):
        self.offset = 0
        self.width  = width
        self.name   = name
        self.interrupt = 0

    def verilog_body (self):
        pass

    def type (self):
        return 'basic'
    
    def io (self):
        return []

    def nets (self):
        return []

    def write_cap (self):
        return 0

    def id_comment (self):
        return "// %s: %s\n" % (self.type(), self.name)

class status_reg (basic_register):
    def __init__ (self, name='', width=0):
        basic_register.__init__(self, name, width)

    def type (self):
        return 'status'
        
    def verilog_body (self):
        return self.id_comment()

    def io (self):
        return [port('input', self.name, self.width)]

    def nets (self):
        return [ net('reg', self.name + '_rd_sel')]

class ext_load_reg (basic_register):
    def __init__ (self, name='', width=0, eindex=0, twidth=0, last=0):
        basic_register.__init__(self, name+"_%d" % eindex, width)
        self.fullname = name
        self.eindex = eindex
        self.twidth = twidth
        self.last = last
        print "Adding %s eindex %d" % (name, eindex)

    def type (self): return "ext_load"

    def write_cap (self): return 1

    def verilog_body (self):
        print "Building %s eindex %d" % (self.name, self.eindex)

        txt = ""
        low = self.eindex * self.width
        high = (self.eindex + 1) * self.width - 1
        txt += "assign %s = xxhold_%d;\n" % (self.name, self.eindex)
        txt += "assign %s_out[%d:%d] = xxhold_%d;\n" % (self.fullname, high, low, self.eindex)
        if (self.eindex == 0):
            #txt += "assign %s_rd_stb = %s_rd_sel & !rf_trdy;\n" % (self.fullname,self.name)
            sm = state_machine ("sm_" + self.name)
            sm.add_state ('idle')
            sm.add_state ('rd_req')
            sm.add_state ('done')

            sm.add_trans ('idle','rd_req',self.name+"_rd_sel", self.name+"_wait_n = 0")
            sm.add_trans ('rd_req','done',"1'b1")
            sm.add_moore ('rd_req',self.name+"_wait_n = 1'b0")
            sm.add_moore ('rd_req',self.fullname+"_rd_stb = 1'b1")

            sm.add_trans ('done','idle',"~%s_rd_sel" % self.name)

            sm.add_default (self.fullname+"_rd_stb", "1'b0")
            sm.add_default (self.name+"_wait_n", "1'b1")
            txt += sm.verilog()

        if (self.last):
            txt += seq_block ("clk", ["if (~reset_n) %s_wr_stb <= 1'b0;" % self.fullname,
                                      "else %s_wr_stb <= %s_%d_wr_sel;" % (self.fullname,self.fullname,self.eindex)])
        return txt

    def nets (self):
        nets = [net('reg', self.name + '_rd_sel'),
                net('reg', self.name + '_wr_sel'),
                net('wire', self.name, self.width)]
        if (self.eindex == 0):
            nets.append (net('reg', self.name + "_wait_n"))
            nets.append (net('reg',"sm_%s_state" % self.name, 2))
            nets.append (net('reg',"nxt_sm_%s_state" % self.name, 2))
        if (self.last):
            nets.append (net('reg', self.fullname + '_rd_stb'))
            nets.append (net('reg', self.fullname + '_wr_stb'))
        return nets

    def io (self):
        # ports are all tied to the 0 eindex register
        plist = []
        if (self.eindex == 0):
            plist.append (port('input', self.fullname+"_in", self.twidth))
            plist.append (port('output', self.fullname+"_out", self.twidth))
            plist.append (port('output', self.fullname+"_rd_stb", 1))
            plist.append (port('output', self.fullname+"_wr_stb", 1))
        return plist
        

class config_reg (basic_register):
    def __init__ (self, name='', width=0, default=0):
        basic_register.__init__(self, name, width)
        self.default = default
        self.fields = []
        
    def verilog_body (self):
        vstr = self.id_comment()
        statements = ["if (%s_wr_sel) nxt_%s = %s;" % (self.name, self.name, 'rf_wr_data'),
                      "else nxt_%s = %s;" % tuple([self.name] * 2)]
        vstr += comb_block (statements)
        statements = ["if (~reset_n) %s <= #1 %d'h%x;" % (self.name, self.width, self.default),
                      "else %s <= #1 nxt_%s;" % tuple([self.name] * 2)]
                      
        vstr += seq_block ('clk', statements)
        if (len(self.fields) != 0):
            vstr += "assign {"
            vstr += ','.join (map(lambda(x):x.name,self.fields))
            vstr += "} = %s;\n" % self.name
        return vstr

    def type (self):
        return 'config'
        
    def io (self):
        if (len(self.fields) == 0):
            return [ port('output',self.name, self.width) ]
        else:
            plist = []
            for fld in self.fields:
                plist.append (port ('output', fld.name, fld.width))
            return plist

    def nets (self):
        return [ net('reg', self.name, self.width),
                 net('reg', "nxt_"+self.name, self.width),
                 net('reg', self.name + '_rd_sel'),
                 net('reg', self.name + '_wr_sel')]

    def write_cap (self):
        return 1

class count_reg (config_reg):
    def __init__ (self, name='', width=0, default=0):
        config_reg.__init__(self, name, width)
        self.default = default
        
    def verilog_body (self):
        txt = self.id_comment() 
        alist = (self.name, self.name, self.width, self.name, self.name)
        statements = [
                      "if (%s_wr_sel) nxt_%s = %s;" % (self.name, self.name, 'rf_wr_data'),
                      "else if (%s_inc && (%s != {%d{1'b1}})) nxt_%s = %s + 1;" % alist,
                      "else nxt_%s = %s;" % (self.name,self.name)
                      ]
        txt += comb_block (statements)
        statements = ["if (~reset_n) %s <= #1 %d;" % (self.name, self.default),
                      "else %s <= #1 nxt_%s;" % (self.name, self.name)
                      ]
        txt += seq_block ('clk', statements)
        return txt
    
    def io (self):
        return [ port('input',self.name + "_inc", 1) ]

class int_msk_reg (basic_register):
    def __init__ (self, name, mask_reg, width=0):
        basic_register.__init__(self, name, width)
        self.mask_reg = mask_reg
        self.interrupt = 1
        
    def verilog_body (self):
        text = self.id_comment()
        statements = ["nxt_%s = (%s_set | %s) & ~( {%d{%s}} & %s);" % (self.name, self.name, self.name, self.width, self.name + '_wr_sel', 'rf_wr_data')]
        statements += ["nxt_%s_int = |(%s & ~%s);" % (self.name, self.name, self.mask_reg.name)]
        text += comb_block (statements)
        statements = ["if (~reset_n) %s <= #1 %d;" % (self.name, 0),
                      "else %s <= #1 nxt_%s;" % (self.name, self.name)]
        text += seq_block ('clk', statements)
        statements = ["if (~reset_n) %s_int <= #1 0;" % self.name,
                      "else %s_int <= nxt_%s_int;" % (self.name, self.name)
                      ]
        text +=  seq_block ('clk', statements)
        return text

    def type (self):
        return 'int_msk'
        
    def io (self):
        return [ port('input',self.name+"_set", self.width) ]

    def nets (self):
        return [ net('reg', self.name + '_rd_sel'),
                 net('reg', self.name, self.width),
                 net('reg', "nxt_"+self.name, self.width),
                 net('reg', self.name + '_wr_sel'),
                 net('reg', 'nxt_'+self.name + '_int'),
                 net('reg', self.name + '_int')]

    def write_cap (self):
        return 1

class soft_set_reg (config_reg):
    def __init__ (self, name='', width=0, default=0):
        basic_register.__init__(self, name, width)
        self.default = default
        
    def verilog_body (self):
        txt = self.id_comment()
        statements = [
                      "nxt_%s = ( ({%d{%s}} & %s) | %s) & ~(%s);" %
                            (self.name, self.width, self.name+'_wr_sel', 'rf_wr_data',
                             self.name, self.name + '_clr')
                      ]
        txt += comb_block (statements)
        statements = ["if (~reset_n) %s <= #1 %d;" % (self.name, self.default),
                      "else %s <= #1 nxt_%s;" % (self.name, self.name)
                      ]
        txt += seq_block ('clk', statements)
        if (len(self.fields) != 0):
            txt += "assign {"
            txt += ','.join (map(lambda(x):x.name,self.fields))
            txt += "} = %s;\n" % self.name
        return txt

    def type (self):
        return 'soft_set'
        
    def io (self):
        return config_reg.io(self) + [port ('input',self.name+"_clr", self.width)]

    #def nets (self):
    #    return [ net('reg', self.name, self.width),
    #             net('reg', "nxt_"+self.name, self.width),
    #             net('reg', self.name + '_rd_sel'),
    #             net('reg', self.name + '_wr_sel')]

    #def write_cap (self):
    #    return 1

class write_stb_reg (config_reg):
    def __init__ (self, name='', width=0, default=0):
        config_reg.__init__(self, name, width, default)
        
    def verilog_body (self):
        txt = self.id_comment()
        statements = [
                      "if (%s_wr_sel) nxt_%s = %s;" % (self.name, self.name, 'rf_wr_data'),
                      "else nxt_%s = %s;" % (self.name, self.name)]
        txt += comb_block (statements)
        statements = ["if (~reset_n) %s <= #1 %d;" % (self.name, self.default),
                      "else %s <= #1 nxt_%s;" % (self.name, self.name)]
        txt += seq_block('clk',statements)
        statements = [
                      "if (~reset_n) %s_stb <= #1 0;" % (self.name),
                      "else %s_stb <= #1 %s_wr_sel & rf_trdy;" % (self.name, self.name),
                      ]
        txt += seq_block ('clk', statements)

        if (len(self.fields) != 0):
            txt += "assign {"
            txt += ','.join (map(lambda(x):x.name,self.fields))
            txt += "} = %s;\n" % self.name

        return txt+seq_block ('clk', statements)

    def type (self):
        return 'write_stb'
        
    def io (self):
        io_list = config_reg.io (self)
        io_list.append ( port('output',self.name+"_stb") )
        return io_list

    def nets (self):
        net_list = config_reg.nets (self)
        net_list.append ( net('reg', self.name + "_stb") )
        return net_list

class read_stb_reg (status_reg):
    def __init__ (self, name='', width=0):
        status_reg.__init__(self, name, width)
        
    def verilog_body (self):
        statements = [
                      "if (~reset_n) %s_stb <= #1 0;" % (self.name),
                      "else %s_stb <= #1 %s_rd_sel & rf_trdy;" % (self.name, self.name),
                      ]
        return self.id_comment() + seq_block ('clk', statements)

    def type (self):
        return 'read_stb'
        
    def io (self):
        io_list = status_reg.io (self)
        io_list.append (port('output',self.name+"_stb"))
        return io_list

    def nets (self):
        net_list = status_reg.nets(self)
        net_list.append (net('reg',self.name + '_stb'))
        return net_list

class state_machine:
    def __init__ (self, name='', clk="clk", reset="reset_n"):
        self.name = name
        self.states = {}
        self.trans = []
        self.clk = clk
        self.reset = reset
        self.idle = ""
        self.defaults = []

    def add_state (self, name):
        self.states[name] = []
        if (self.idle == ""):
            self.idle = name

    def add_trans (self, st_from, st_to, cond, asrt=''):
        self.states[st_from].append ( (st_to, cond, asrt) )

    def add_moore (self, st_name, asrt):
        self.states[st_name].append ( (st_name, '1', asrt) )

    def add_default (self, signal, value):
        self.defaults.append ( (signal, value) )

    def verilog (self):
        code = "// state machine %s\n" % self.name

        # create state names
        snum = 0
        for st in self.states.keys():
            code += "parameter st_%s_%s = %d;\n" % (self.name, st, snum)
            snum += 1
            
        # create combinatorial block
        cblk = []
        for d in self.defaults:
            cblk.append ( "%s = %s;" % d)
        cblk.append ("%s = %s;" % ("nxt_" + self.name + "_state", self.name + "_state"))
        cblk.append ("case (%s)" % (self.name + "_state"))
        for st in self.states.keys():
            cblk.append ( "st_%s_%s : " % (self.name, st))
            cblk.append ( "  begin")
            first = 1
            moore = []
            for c in self.states[st]:
                if (c[0] == st) and (c[1] == "1"):
                    moore.append (c[2])
                else:
                    if (not first): statement = "    else if"
                    else:
                        statement = "    if"
                        first = 0
                    cblk.append ( "%s (%s)" % (statement, c[1]))
                    cblk.append ("    begin")
                    if (c[0] != st):
                        cblk.append ( "    nxt_%s_state = st_%s_%s;" % (self.name, self.name, c[0]))
                    if (c[2] != ""):
                        cblk.append ( "    " + c[2] + ";")
                    cblk.append ( "    end")
            for m in moore:
                cblk.append ("    %s;" % m)
            cblk.append ("  end")
        cblk.append ( "endcase")
        code += comb_block (cblk)

        # create sequential block
        cblk = []
        cblk.append ("if(~%s)" % self.reset)
        cblk.append ("%s_state <= #1 st_%s_%s;" % (self.name, self.name, self.idle))
        cblk.append ("else")
        cblk.append ("%s_state <= #1 nxt_%s_state;" % (self.name, self.name))
        code += seq_block (self.clk, cblk)
        return code
        
class user_reg (basic_register):
    def __init__ (self, name='', width=0):
        basic_register.__init__(self, name, width)

    def io (self):
        io_list = []
        io_list.append (port('output',self.name+"_wr_stb"))
        io_list.append (port('output',self.name+"_rd_stb"))
        io_list.append (port('output',self.name+"_wr_data", self.width))
        io_list.append (port('input',self.name+"_rd_data",self.width))
        io_list.append (port('input',self.name+"_rd_ack"))
        io_list.append (port('input',self.name+"_wr_ack"))
        return io_list

    def type (self):
        return 'user'
        
    def nets (self):
        net_list = []
        net_list.append (net('reg',self.name+"_rd_sel"))
        net_list.append (net('reg',self.name+"_wr_sel"))
        net_list.append (net('reg',self.name+"_rd_stb"))
        net_list.append (net('reg',self.name+"_wr_stb"))
        net_list.append (net('reg',self.name+"_wait_n"))
        net_list.append (net('reg',self.name,self.width))
        net_list.append (net('reg',self.name+"_wr_data",self.width))
        net_list.append (net('reg',"sm_%s_state" % self.name, 2))
        net_list.append (net('reg',"nxt_sm_%s_state" % self.name, 2))
        return net_list
    
    def write_cap (self):
        return 1

    def verilog_body (self):
        sm = state_machine ("sm_" + self.name)
        sm.add_state ('idle')
        sm.add_state ('rd_req')
        sm.add_state ('wr_req')
        sm.add_state ('w_clear')
        #sm.add_state ('rd_ack')
        #sm.add_state ('wr_ack')
        sm.add_trans ('idle','rd_req',self.name+"_rd_sel", self.name+"_wait_n = 0")
        sm.add_trans ('idle','wr_req',self.name+"_wr_sel", self.name+"_wait_n = 0")
        sm.add_trans ('rd_req', 'w_clear', self.name+"_rd_ack", "")
        #sm.add_trans ('rd_req', 'rd_ack', '1','')
        sm.add_trans ('rd_req', 'rd_req', "!"+self.name+"_rd_ack", self.name+"_wait_n = 0")
        sm.add_moore ('rd_req', self.name+"_rd_stb = 1")
        sm.add_moore ('wr_req', self.name+"_wr_stb = 1")
        sm.add_trans ('wr_req', 'w_clear', self.name+"_wr_ack", "")
        sm.add_trans ('wr_req', 'wr_req', "!"+self.name+"_wr_ack", self.name+"_wait_n = 0")

        # added w_clear to avoid duplicate requests on interface
        sm.add_trans ('w_clear', 'idle', "~(%s_rd_sel | %s_wr_sel)" % (self.name,self.name), "")

        sm.add_default (self.name+"_rd_stb", "0")
        sm.add_default (self.name+"_wr_stb", "0")
        sm.add_default (self.name+"_wait_n", "1")

        comb = comb_block (["%s_wr_data = rf_wr_data;" % self.name,
                            "%s = %s_rd_data;" % (self.name, self.name)])

        return sm.verilog() + comb
