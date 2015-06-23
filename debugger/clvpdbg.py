from pyparsing import *
import serial

#------------------------------------------------------------------------------------------------------
# CLASS STACK
#------------------------------------------------------------------------------------------------------ 
class Stack(object):
    def __init__(self):
        self.stack = []
    
    def push(self, value):
        self.stack.append(value)
    
    def pop(self):
        if len(self.stack) == 0:
            return None
        value = self.stack[-1]
        del self.stack[-1]
        return value
        
#------------------------------------------------------------------------------------------------------
# CLASS PROFILER
#------------------------------------------------------------------------------------------------------ 
class Profiler(object):
    def __init__(self):
        self.steps = 0
        
        self.load = 0
        self.store = 0
        self.jumpbranch = 0
        self.flag = 0
        self.alu = 0
        self.movmova = 0
        
        self.vload = 0
        self.vstore = 0
        self.valu = 0
        self.vmov = 0
        self.shuffle = 0
        
        self.scalar = 0
        self.vector = 0
        self.coopsimul = 0
    
    def add(self, irval):
        if irval == None:
            return
        
        self.steps = self.steps +1
        
        s = False
        v = False
        
        #scalar cmd
        if (irval & string.atoi("11100000000000000000000000000000",2)) != 0: 
            s = True
        
        #vector cmd
        if (irval & string.atoi("00000000000011100000000000000000",2)) != 0:
            v = True
        
        if s == True and v == True:
            self.coopsimul = self.coopsimul + 1
        else:
            if s == True:
                self.scalar = self.scalar + 1
            if v == True:
                self.vector = self.vector + 1
        
        #alu cmd
        if (irval & string.atoi("11000000000000000000000000000000",2))\
         == string.atoi("01000000000000000000000000000000",2):
            self.alu = self.alu +1
        
        #jmp/jcc cmd
        if (irval & string.atoi("11100000000000000000000000000000",2))\
         == string.atoi("00100000000000000000000000000000",2):
            self.jumpbranch = self.jumpbranch +1
            
        #flag
        if (irval & string.atoi("11000000000000000000000000000000",2))\
         == string.atoi("11000000000000000000000000000000",2):
            self.flag = self.flag +1
            
        #load 
        if (irval & string.atoi("11110000000000000000000000000000",2))\
         == string.atoi("10000000000000000000000000000000",2):
            self.load = self.load +1
            
        #store
        if (irval & string.atoi("11110000000000000000000000000000",2))\
         == string.atoi("10100000000000000000000000000000",2):
            self.store = self.store +1
            
        #vload
        if (irval & string.atoi("11110000000000000000000000000000",2))\
         == string.atoi("10010000000000000000000000000000",2):
            self.vload = self.vload +1

        #vstore
        if (irval & string.atoi("11111100000000000000000000000000",2))\
         == string.atoi("10110000000000000000000000000000",2):
            self.vstore = self.vstore +1
        
        #mov
        if (irval & string.atoi("11111000000000000000000000000000",2))\
         == string.atoi("10111000000000000000000000000000",2):
            self.movmova = self.movmova +1
            
        #mova
        if (irval & string.atoi("11111100000000000000000000000000",2))\
         == string.atoi("10110100000000000000000000000000",2):
            self.movmova = self.movmova +1
            
        #valu
        if (irval & string.atoi("00000000000011000000000000000000",2))\
         == string.atoi("00000000000001000000000000000000",2):
            self.valu = self.valu +1
            
        #vmov
        if (irval & string.atoi("00000000000011100000000000000000",2))\
         == string.atoi("00000000000000100000000000000000",2):
            self.vmov = self.vmov +1
            
        #vshuf
        if (irval & string.atoi("00000000000011000000000000000000",2))\
         == string.atoi("00000000000011000000000000000000",2):
            self.shuffle = self.shuffle +1
            
        
        
    def printanalysis(self):
        if self.steps == 0:
            print "No commands since reset"
            return
            
        print "Analysis of " + str(self.steps) + " commands is:"
        print "  " + "jumps / branches :".ljust(30," ") + str(self.jumpbranch).ljust(10," ") + self.toString(self.jumpbranch)
        print "  " + "flag modifications :".ljust(30," ") + str(self.flag).ljust(10," ") + self.toString(self.flag)
        print "  " + "scalar load :".ljust(30," ") + str(self.load).ljust(10," ") + self.toString(self.load)
        print "  " + "scalar store :".ljust(30," ") + str(self.store).ljust(10," ") + self.toString(self.store)
        print "  " + "vector load :".ljust(30," ") + str(self.vload).ljust(10," ")+ self.toString(self.vload)
        print "  " + "vector store :".ljust(30," ") + str(self.vstore).ljust(10," ")+ self.toString(self.vstore)
        print "  " + "scalar alu :".ljust(30," ") + str(self.alu).ljust(10," ")+ self.toString(self.alu)
        print "  " + "vector alu :".ljust(30," ") + str(self.valu).ljust(10," ")+ self.toString(self.valu)
        print "  " + "mov / mova :".ljust(30," ") + str(self.movmova).ljust(10," ")+ self.toString(self.movmova)
        print "  " + "vmov / vmol / vmor :".ljust(30," ") + str(self.vmov).ljust(10," ")+ self.toString(self.vmov)
        print "  " + "shuffle :".ljust(30," ") + str(self.shuffle).ljust(10," ")+ self.toString(self.shuffle)
        print "  " + "scalar commands :".ljust(30," ") + str(self.scalar).ljust(10," ")+ self.toString(self.scalar)
        print "  " + "vector commands :".ljust(30," ") + str(self.vector).ljust(10," ")+ self.toString(self.vector)
        print "  " + "cooperative / simultaneous :".ljust(30," ") + str(self.coopsimul).ljust(10," ")+ self.toString(self.coopsimul)
       
    def toString(self, cmd):
        val = float(cmd) * 100.0 / float(self.steps)
        string = ("%.2f" % (val)).rjust(5," ") +  " %"
        return string

#------------------------------------------------------------------------------------------------------
# CLASS DEBUGGER
#------------------------------------------------------------------------------------------------------ 
class Debugger(object):
    stack = Stack()
    profiler = Profiler()
    profiling = True
    
    def __init__(self, args):
        if len(args) > 3 or len(args) < 2: 
            print
            print "usage: python clvpdbg.py portnumber [symboltablefilename]"
            print
            sys.exit(1)
        
        if len(args) == 3:
            symbols = self.getSymbols(args[2])
        else:
            symbols = None
        
        self.shell(args[1], symbols)
        
    def getSymbols(self, filename):
        try:
            file = open (filename,"r")
            
            symbols = {}
            
            for s in  file.readlines():
                x=s.replace("\n","").replace("\r","")
                symbols[x.split(":")[1].upper()] = string.atoi(x.split(":")[0])
            
            return symbols
            
        except IOError:
            print
            print "error: unable to open symboltable file: " + filename
            sys.exit(1)
    
    def tointeger(self,s):
        if s[0] == "$":
            return string.atoi(s[1:], base = 16)
        
        if s[0] == "%":
            return string.atoi(s[1:], base = 2)
            
        return string.atoi(s)
    
    def shell(self, portnr, symbols):
        
        try:
            self.ser = ser = serial.Serial(string.atoi(portnr), 38400, 8, serial.PARITY_NONE, serial.STOPBITS_ONE, Settings().getTimeout(), 0, 0)
        except serial.SerialException:
            print
            print "An error occured while trying to open the serial port"
            sys.exit(1)
        
        print "\nWelcome to the HiCoVec Debugger !!!\n\nEnter 'help' for a list of commands"
        print
         
        self.echo(True)
        
        print
        
        while(1):
            sys.stdout.write("#")
            line=sys.stdin.readline().upper()
            if line.strip() != "":
            
                try:
                    cmd = LineParser().parseLine(line)
                
                    if cmd.command == "QUIT" or cmd.command == "EXIT" or cmd.command == "Q":
                        sys.exit(0)
                    
                    elif cmd.command == "HELP":
                        length = 23
                        print "The following commands are availiable:"
                        print "  " + "C / CLOCK".ljust(length," ") + "-- generate one clock signal for cpu"
                        print "  " + "R / RESET".ljust(length," ") + "-- reset cpu and trace stats"
                        print "  " + "S / STEP [NUMBER]".ljust(length," ") +  "-- execute NUMBER instructions"
                        print "  " + "JUMP ADDRESS".ljust(length," ") + "-- execute until command at ADDRESS"
                        print "  " + "M / DATA".ljust(length," ") + "-- display data of memory output"
                        print "  " + "N / ADDR".ljust(length," ") + "-- display memory address line"
                        print "  " + "A".ljust(length," ") + "-- display value of register A"
                        print "  " + "X".ljust(length," ") + "-- display value of register X"
                        print "  " + "Y".ljust(length," ") + "-- display value of register Y "
                        print "  " + "I / IR".ljust(length," ") + "-- display value of instruction register "
                        print "  " + "J / IC".ljust(length," ") + "-- display value of instruction counter "
                        print "  " + "F / FLAGS".ljust(length," ") + "-- display value of various flags and signals"
                        print "  " + "T / STATUS".ljust(length," ") + "-- display value of all registers"
                        print "  " + "E / ECHO".ljust(length," ") + "-- test if device is responding"
                        print "  " + "READ ADDRESS".ljust(length," ") + "-- read memory value at given ADDRESS"
                        print "  " + "WRITE ADDRESS VALUE".ljust(length," ") + "-- write VALUE to given memory ADDRESS"
                        print "  " + "DOWNLOAD ADDRESS COUNT".ljust(length," ") + "-- download data from memory into FILE"
                        print "  " + "UPLOAD ADDRESS".ljust(length," ") + "-- upload data from FILE into memory"
                        print "  " + "CCSTART ADDRESS".ljust(length," ") + "-- start counting clockticks to reach given ADDRESS"
                        print "  " + "CCSTOP".ljust(length," ") + "-- aborts counting clockticks"
                        print "  " + "CCSTATUS".ljust(length," ") + "-- displays clocktick counter status and value"
                        print "  " + "TRACE [NUMBER]".ljust(length," ") + "-- display IC value of last NUMBER commands"
                        print "  " + "PROFILE".ljust(length," ") + "-- show analysis of commands since reset"
                        print "  " + "TOGGLEPROFILING".ljust(length," ") + "-- activate/deaktivate profiling"
                        print "  " + "SYMBOLS".ljust(length," ") + "-- lists symbols imported from file"
                        print "  " + "Q / QUIT / EXIT".ljust(length," ") + "-- exit debugger"

                    elif cmd.command == "SYMBOLS":
                        if symbols != None:
                            print "The following symbols are known:"
                            for k,v in sorted(symbols.iteritems()):
                                print "  0x" + str(hex(v))[2:].rjust(8,"0").upper() + " : " + k
                        else:
                            print "No symbol file given"
                    
                    elif cmd.command == "CLOCK" or cmd.command == "C":
                        self.clock(True)
                        
                    elif cmd.command == "RESET" or cmd.command == "R":
                        self.reset(True)
                        self.clock(False)
                    
                    elif cmd.command == "A":
                        self.rega(True)
                        
                    elif cmd.command == "X":
                        self.regx(True)
                    
                    elif cmd.command == "Y":
                        self.regy(True)
                        
                    elif cmd.command == "FLAGS" or cmd.command == "F":
                        self.flags(True)
                    
                    elif cmd.command == "IR" or cmd.command == "I":
                        self.ir(True)
                    
                    elif cmd.command == "IC" or cmd.command == "J":
                        self.ic(True)
                    
                    elif cmd.command == "STEP" or cmd.command == "S":
                        if cmd.value != "":
                            self.step(self.tointeger(cmd.value), True, self.profiling)
                        else:
                            self.step(1, True)
                    
                    elif cmd.command == "TRACE":
                        if cmd.value != "":
                            self.trace(self.tointeger(cmd.value))
                        else:
                            self.trace(10)
                            
                    elif cmd.command == "PROFILE":
                        self.profiler.printanalysis();
                    
                    elif cmd.command == "JUMP":
                        try:
                            if cmd.value:
                                address = self.tointeger(cmd.value)
                            else:
                                address = symbols[cmd.symbol]
                            
                            self.jump(address, True, self.profiling)
                        
                        except KeyError:
                            print "Symbol " + cmd.symbol + " is not known"
                    
                    
                    elif cmd.command == "WRITE":
                        try:
                            if cmd.newval_value:
                                newval = self.tointeger(cmd.newval_value)
                            else:
                                newval = symbols[cmd.newval_symbol]
                                
                            try:
                                if cmd.value:
                                    address = self.tointeger(cmd.value)
                                else:
                                    address = symbols[cmd.symbol]
                                
                                self.write(address, newval, True)
                        
                            except KeyError:
                                print "Symbol " + cmd.symbol + " is not known" 
                        
                        except KeyError:
                            print "Symbol " + cmd.newval_symbol + " is not known"                        
                        
                    
                    elif cmd.command == "READ":
                        try:
                            if cmd.value:
                                address = self.tointeger(cmd.value)
                            else:
                                address = symbols[cmd.symbol]
                                
                            self.read(address, True)
                            
                        except KeyError:
                            print "Symbol " + cmd.symbol + " is not known"

                    
                    elif cmd.command == "DOWNLOAD":
                        try:
                            if cmd.value:
                                address = self.tointeger(cmd.value)
                            else:
                                address = symbols[cmd.symbol]
                            
                            sys.stdout.write("Enter filename: ")
                            filename=sys.stdin.readline().lstrip().rstrip()
                            
                            self.download(address, self.tointeger(cmd.count), filename, True)
                            
                        except KeyError:
                            print "Symbol " + cmd.symbol + " is not known"
                    
                    elif cmd.command == "UPLOAD":
                        try:
                            if cmd.value:
                                address = self.tointeger(cmd.value)
                            else:
                                address = symbols[cmd.symbol]
                            
                            sys.stdout.write("Enter filename: ")
                            filename=sys.stdin.readline().lstrip().rstrip()
                            
                            self.upload(address, filename, True)
                            
                        except KeyError:
                            print "Symbol " + cmd.symbol + " is not known"
                    
                    
                    elif cmd.command == "CCSTART":
                        try:
                            if cmd.value:
                                address = self.tointeger(cmd.value)
                            else:
                                address = symbols[cmd.symbol]
                            
                            self.ccstart(address, True)
                            
                        except KeyError:
                            print "Symbol " + cmd.symbol + " is not known"
                    
                    elif cmd.command == "CCSTOP":
                        self.ccstop(True)
                    
                    elif cmd.command == "CCSTATUS":
                        self.ccstatus(True)

                    elif cmd.command == "DATA"  or cmd.command == "M":
                        self.data(True)
                        
                    elif cmd.command == "ADDR" or cmd.command == "N":
                        self.addr(True)
                    
                    elif cmd.command == "STATUS" or cmd.command == "T":
                        self.status(True)
                       
                    elif cmd.command == "ECHO" or cmd.command == "E":
                        self.echo(True)
                        
                    elif cmd.command == "GO" or cmd.command == "G":
                        self.go(True)
                        
                    elif cmd.command == "PAUSE" or cmd.command == "P":
                        self.pause(True)
                        
                    elif cmd.command == "TOGGLEPROFILING":
                        self.toggleprofiling()
                                        
                except ParseException, err:
                    print "Unknown command or incorrect parameters"
            
            print
    
    def ccstop(self, verbose = True):
        self.ser.write("5")
        if self.ser.read(1) != "5":         
            if verbose == True:
                print "Stop clock counter was NOT successful"
            return False
        
        if verbose == True:
            print "Clock counter has been stopped"
        return True
    
    def ccstart(self, address, verbose = True):
        if self.pause(False) == False:
            if verbose == True:
                print "Enter debugging-mode signal NOT accepted"
            return False
        
        if self.put("0", address, 0) == False:
            if verbose == True:
                print "Transmitting address was NOT successful"
            return False
            
        self.ser.write("4")
        if self.ser.read(1) != "4":         
            if verbose == True:
                print "Start clock counter was NOT successful"
            return False          
        
        if verbose == True:
            print "Clock counter has been started"
        return True 
        
    def ccstatus(self, verbose = True):
        self.ser.write("6")
        status = self.ser.read(1)
        
        if status != "":
            if ord(status) == 1:
                if verbose == True:
                    print "Counting clock cycles is finished"
            else:
                if verbose == True:
                    print "Counting clock cycles is NOT finished, yet"            
        else:
            if verbose == True:
                print "Request to get status was NOT successful"
            return None
            
        return self.get32BitReg("Clock cycles","7", verbose)
            
    
    def toggleprofiling(self):
        if self.profiling == False:
            self.profiling = True
            print "Profiling now ON"
        else:
            self.profiling = False
            print "Profiling now OFF"
        
    def upload(self, address, filename, verbose = True):
        try:
            f=open(filename,"rb")
            
            i = 0
            
            while f:
                x3 = f.read(1)
                x2 = f.read(1)
                x1 = f.read(1)
                x0 = f.read(1)
                
                if x0 == "" or x1 == "" or x2 == "" or x3 == "":
                    f.close()            
                    print "File has been uploaded"
                    return True
                
                value = ord(x0) + ord(x1) * 256 + ord(x2) * 256 * 256 + ord(x3) * 256 * 256 * 256
                
                trys = 0
                done = False
                s = Settings()
                
                while trys < s.getRetrys() and done == False:                
                    if self.write(address + i, value, False) == False:
                        trys = trys +1
                    else:
                        done = True
                
                if done == False:
                    if verbose == True:
                        print "File has NOT been uploaded"                   
                    return False
                
                i=i+1

        except IOError:
            print "File IO-error occured" 
        
    def download(self, address, count, filename, verbose = True):
        try:
            f=open(filename,"wb")
        
            for i in range(count):
                value = self.read(address + i, False)
                
                if value == None:
                    if verbose == True:
                        print "Download was NOT successful"
                    return False
               
                m = string.atoi("11111111000000000000000000000000",2)
                for j in range(4):        
                    a = (value & m) >> 8 * (3-j)
                    m = m >> 8
                    f.write(chr(a))
            
            f.close()
            print "Download into file " + filename + " was successful"
            
        except IOError:
            print "Unable to write file: " + filename
    
    def read(self, address, verbose = True):
        if self.put("0", address, 0) == False:
            if verbose == True:
                print "Transmitting address was NOT successful"
            return None
                
        return self.get32BitReg("value","2", verbose)
    
    def write(self, address, value, verbose = True):
        if self.put("0", address, 0) == False:
            if verbose == True:
                print "Transmitting address was NOT successful"
            return False
        
        if self.put("1", value, 0) == False:
            if verbose == True:
                print "Transmitting data was NOT successful"
            return False
        
        self.ser.write("3")
        if self.ser.read(1) != "3": 
            if verbose == True:
                print "Write was NOT successful"
            return False  
        
        else:
            if verbose == True:
                print "Data has been written"
            return True
    
    def put(self, command, value, trys):
        err = False
        m = string.atoi("11111111000000000000000000000000",2)
        
        self.ser.write(command)
        if self.ser.read(1) != command:         
            return False          
        
        for i in range(4):        
            a = (value & m) >> 8 * (3-i)
            m = m >> 8
            self.ser.write(chr(a))
            if ord(self.ser.read(1)) != a:
                err = True
                
        if err == True:
            s= Settings()
            if trys == s.getRetrys():
                return False                
            return self.put(command, value, trys +1)
        else:
            return True
            
    
    
    
    def echo(self, verbose = True):
        self.ser.write("e")
        if self.ser.read(1) == "e":
            if verbose == True:
                print "Device is responding"
            return True
        else:
            if verbose == True:
                print "Device is NOT responding"
            return False
            
    def go(self, verbose = True):
        self.ser.write("g")
        if self.ser.read(1) == "g":
            if verbose == True:
                print "System now in free-running-mode"
            return True
        else:
            if verbose == True:
                print "Enter free-running-mode signal NOT accepted"
            return False
    
    def pause(self, verbose = True):
        self.ser.write("p")
        if self.ser.read(1) == "p":
            if verbose == True:
                print "System now in debugging-mode"
            return True
        else:
            if verbose == True:
                print "Enter debugging-mode signal NOT accepted"
            return False
    
    def clock(self, verbose = True):
        self.ser.write("c")
        clock = self.ser.read(1)
        
        try:
            if ord(clock) == 255:            #workaround for belkin usb-to-serial-adapter problems ...
                return self.clock (verbose)         
        
        except TypeError: 
            if verbose == True:
                print "Clock signal NOT accepted"
            return False   
        
        if  clock == "c":
            if verbose == True:
                print "Clock signal accepted"
            return True
        else:
            if verbose == True:
                print "Clock signal NOT accepted"
            return False
        
    def reset(self, verbose = True):
        
        self.ser.write("r")
        if self.ser.read(1) == "r":
            self.stack = Stack();
            self.profiler = Profiler()
            if verbose == True:
                print "Reset signal (CPU, trace, profiler) accepted"
            return True
        else:
            if verbose == True:
                print "Reset signal NOT accepted"
            return False
    
    def rega(self, verbose = True):
        return self.get32BitReg("register a","a", verbose)
        
    def regx(self, verbose = True):
        return self.get32BitReg("register x","x", verbose)
        
    def regy(self, verbose = True):
        return self.get32BitReg("register y","y", verbose)
    
    def ic(self, verbose = True):
        return self.get32BitReg("instruction counter","j", verbose)
    
    def ir(self, verbose = True):
        return self.get32BitReg("instruction register","i", verbose)
        
    def data(self, verbose = True):
        return self.get32BitReg("memory output data","m", verbose)
        
    def addr(self, verbose = True):
        return self.get32BitReg("memory address signal","n", verbose)
        
    def status(self, verbose = True):
        return self.data(verbose), self.addr(verbose), self.ir(verbose), self.ic(verbose), self.rega(verbose),\
               self.regx(verbose), self.regy(verbose), self.flags(verbose), \
    
    def get32BitReg(self, name, command, verbose = True):
        errors = 0
        success = 0
        
        while not success and errors < Settings().getRetrys():
            self.ser.write(command)
            x0=self.ser.read(1)
            x1=self.ser.read(1)
            x2=self.ser.read(1)
            x3=self.ser.read(1)
            checksum = self.ser.read(1)
            
            if x0 == "" or x1 == "" or x2 == "" or x3 == "" or checksum == "":
                errors = errors + 1
            else:
                if  ord(checksum) != ord(x0) ^ ord(x1) ^ ord(x2) ^ ord(x3):
                    errors = errors +1 
                else:
                    success = 1
        
        if success:
            x = ord(x0) + 256 * ord(x1) + 256 * 256 * ord(x2) + 256 * 256 * 256 * ord(x3)
            
            if verbose == True:
                print name + ": 0x" + hex(ord(x3))[2:].rjust(2,"0").upper() + hex(ord(x2))[2:].rjust(2,"0").upper() \
                                    + hex(ord(x1))[2:].rjust(2,"0").upper() + hex(ord(x0))[2:].rjust(2,"0").upper()
            return x
        else:
            print "request to get " + name + " was NOT successful"
            return None
    
    def flags(self, verbose = True):
        self.ser.write("f")
        flags = self.ser.read(1)
        
        if flags != "":
            ir_ready = int((ord(flags) & string.atoi("10000000",2)) > 0)
            mem_ready = int((ord(flags) & string.atoi("01000000",2)) > 0)
            mem_access = (ord(flags) & string.atoi("00111000",2)) >> 3
            mem_access_0 = int((mem_access & 1) > 0)
            mem_access_1 = int((mem_access & 2) > 0)
            mem_access_2 = int((mem_access & 4) > 0)
            halted = int((ord(flags) & string.atoi("00000100",2)) > 0)
            zero = int((ord(flags) & string.atoi("00000010",2)) > 0)
            carry = int((ord(flags) & string.atoi("00000001",2)) > 0)
        
            if verbose == True:
                print "ir_ready: " + str(ir_ready)
                print "mem_ready: " + str(mem_ready)
                print "mem_access: " + str(mem_access_2) + str(mem_access_1) + str(mem_access_0)
                print "halted: " + str(halted)
                print "zero: " + str(zero)
                print "carry: " + str(carry)
                
            return ir_ready, mem_ready, mem_access, halted, zero, carry
        else:
            print "Request to get flags was NOT successful"
            return None
    
    def step(self, steps, verbose = True, profile = True):
        
        ticks = 0
        ic = None
		
        for i in range(steps):
            ir_ready = 0
            clocks = 0

            while(ir_ready == 0):
                if self.clock(False) == False:
                    text = "Device is not responding (Clock)"
                    if verbose == True:
                        print text
                    return 0, text, None
				
                flags =  self.flags(False)
                if flags == None:
                    text = "Device is not responding (Flags)"
                    if verbose == True:
                        print text
                    return 0, text, None
                else:
                    ir_ready, mem_ready, mem_access, halted, zero, carry = flags
                
                clocks = clocks + 1
                
                if clocks > Settings().getMaxClocks():
                    text = "Exceeded limit of " + str(Settings().getMaxClocks()) + " clock ticks for one command, aborting"
                    if verbose == True:
                        print text
                    return 0, text, None
            
            ticks = ticks + clocks
            ic = self.ic(False)
            
            if profile == True:
                self.profiler.add(self.ir(False))
        
        if self.clock(False) == False:
                    text = "Device is not responding (Clock)"
                    if verbose == True:
                        print text
                    return 0, text, None
        
        ticks = ticks + 1
        self.stack.push(ic)
        
        text = "Stepping "+ str(steps) +" command(s) successfull" + "\n" + "Required "+ str(ticks) + " clock ticks"
        if verbose == True:
            print text
        return ticks, text, ic
    
    def jump(self, address, verbose = True, profile = True):
        
        ic = 0
        steps = 0
        ticks = 0
        
        while(ic != address):
            steps = steps +1
            
            clocks, text, ic = self.step(1, False, profile)
            if  clocks == 0:
                if verbose == True:
                    print "Step " + str(steps) + " was NOT successful"
                    print text
                return 0
            
            if ic == None:
                if verbose == True:
                    print "Device is NOT responding (IC)"
                return 0
            
            if steps > Settings().getMaxSteps():
                if verbose == True:
                    print "Exceeded limit of " + str(Settings().getMaxSteps()) + " steps, aborting"
                return 0
                
            ticks = ticks + clocks

        if verbose == True:
            print "Instruction counter value after " + str(steps) + " commands reached"
            print "Required " + str(ticks) + " clock ticks"
        return ticks
        
    def trace(self,n):
        print "trace of the last " + str(n) +" instruction counter values: "
        
        import copy
        newstack = copy.deepcopy(self.stack)
        
        val = newstack.pop()
        
        x = 0
        
        while( val != None and x < n ):
            print "0x" + hex(val)[2:].rjust(8,"0").upper()
            val = newstack.pop()
            x = x + 1
            
#------------------------------------------------------------------------------------------------------
# CLASS LINEPARSER
#------------------------------------------------------------------------------------------------------    
class LineParser:
    def parseLine(self,line):
        
        expression = Forward()
        
        dec_value = Word("0123456789", min=1)
        hex_value = Word("$","ABCDEF0123456789", min=2)
        bin_value = Word("%","10", min=2)
        
        value = (dec_value ^ hex_value ^ bin_value).setResultsName("value")
        ident = Word( alphas, alphanums + "_" ).setResultsName("symbol")
        
        address = (value ^ ident).setResultsName("address")
       
        newval_value = (dec_value ^ hex_value ^ bin_value).setResultsName("newval_value")
        newval_ident = Word( alphas, alphanums + "_" ).setResultsName("newval_symbol")
        newval_address = (newval_value ^ newval_ident).setResultsName("newval_address")
        
        count = (dec_value ^ hex_value ^ bin_value).setResultsName("count")
        
        cmd_1 = ( Keyword("C") ^ Keyword("CLOCK") ^ Keyword("RESET")^ Keyword("R")  ^ Keyword("A") ^ Keyword("X") ^ Keyword("Y") \
                ^ Keyword("FLAGS") ^ Keyword("F") ^ Keyword("IR") ^ Keyword("IC") ^ Keyword("ECHO") ^ Keyword("QUIT") \
                ^ Keyword("Q") ^ Keyword("STATUS") ^ Keyword("E") ^ Keyword("HELP") ^ Keyword("EXIT") ^ Keyword("I") \
                ^ Keyword("J") ^ Keyword("T") ^ Keyword("M") ^Keyword("N") ^ Keyword("ADDR") ^ Keyword("DATA") \
                ^ Keyword("GO") ^ Keyword("PAUSE") ^ Keyword("G") ^ Keyword("P") ^  Keyword("SYMBOLS") ^ Keyword("PROFILE")
                ^ Keyword("TOGGLEPROFILING")).setResultsName("command")
        
        cmd_2 = ((Keyword("STEP") ^ Keyword("S")).setResultsName("command")) ^ ((Keyword("STEP") ^ Keyword("S")).setResultsName("command") + value)
        
        cmd_3 = Keyword("JUMP").setResultsName("command") + address
        
        cmd_4 = ((Keyword("TRACE")).setResultsName("command")) ^ ((Keyword("TRACE")).setResultsName("command") + value)
        
        cmd_5 = (Keyword("WRITE")).setResultsName("command") + address + newval_address
        
        cmd_6 = (Keyword("READ")).setResultsName("command") + address 
        
        cmd_7 = (Keyword("UPLOAD")).setResultsName("command") + address
        
        cmd_8 = (Keyword("DOWNLOAD")).setResultsName("command") + address + count 
        
        cmd_9 = (Keyword("CCSTART")).setResultsName("command") + address
        
        cmd_10 = (Keyword("CCSTOP")).setResultsName("command")
        
        cmd_11 = (Keyword("CCSTATUS")).setResultsName("command")
        
        command = (cmd_1 ^ cmd_2 ^ cmd_3 ^ cmd_4 ^ cmd_5 ^ cmd_6 ^ cmd_7 ^ cmd_8 ^ cmd_9 ^ cmd_10 ^ cmd_11)
        
        expression << command + lineEnd
        
        result = expression.parseString(line)
        
        return result

#------------------------------------------------------------------------------------------------------
# CLASS SETTINGS
#------------------------------------------------------------------------------------------------------            
class Settings(object):
    def getMaxClocks(self):
        return 100
    
    def getMaxSteps(self):
        return 50000   
    
    def getRetrys(self):
        return 15
        
    def getTimeout(self):
        return 0.1
#------------------------------------------------------------------------------------------------------
# MAIN PROGRAM
#------------------------------------------------------------------------------------------------------        
if __name__ == '__main__':
    import sys
    Debugger(sys.argv)       
