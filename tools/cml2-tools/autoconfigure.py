#!/usr/bin/env python
#
#  linux/scripts/autoconfigure.py : Automagical Kernel Configuration.
#
#  Copyright (C) 2000-2002  Eric S. Raymond <esr@thyrsus.com>
#  This is free software, see GNU General Public License 2 for details.
#
# This script tries to autoconfigure the Linux kernel, detecting the
# hardware (devices, ...) and software (protocols, filesystems, ...).
# It uses soft detection: no direct IO access to unknown devices, thus
# it is always safe to run this script and it never hangs, but it cannot
# detect all hardware (mainly misses some very old hardware).  You don't
# need root, but you will need a CML2 rulebase handy.
#
# Most of the smarts in this script is in the file of probe rules
# maintained by Giacomo Catenazzi and brought in by execfile.

import sys, getopt, os, glob, commands, re
import cml, cmlsystem
from cml import y, m, n	# For use in the autoprobe rules

lang = {
    "COMPLETE":"Configuration complete.",
    "COMPLEMENT":"* Computing complement sets",
    "DERIVED":"Symbol %s is derived and cannot be set.",
    "DONE":"Done",
    "EFFECTS":"Side effects:",
    "NOCMDLINE":"%s is the wrong type to be set from the command line",
    "OPTUNKNOWN":"autoconfigure: unknown option.\n",
    "ROOTFS":"* %s will be hard-compiled in for the root filesystem\n",
    "ROOTHW":"* %s will be hard-compiled in to run the root device\n",
    "ROOTLOOK":"# Looking for your root filesystem...\n",
    "ROOTWARN":"** Warning: I could not identify the " \
    			"bus type of your root drive!\n",
    "SETFAIL" : "%s failed while %s was being set to %s\n",
    "SYMUNKNOWN":"cmlconfigure: unknown symbol %s\n",
    "TURNOFF":"# Turning off unprobed device symbols",
    "UNAME":"Can't determine ARCH, uname failed.",
    }

class ConfigFile:
    "Object that represents a generated configuration."
    def __init__(self, myconfiguration, hardcompile, debuglevel=0):
        # Prepare an output object to accept the configuration file
        self.hardcompile = hardcompile
        self.myconfiguration = myconfiguration
        myconfiguration.debug = debuglevel
        self.modified = {}
        self.emitted = {}
        if debuglevel:
            sys.stderr.write("* Debug level %d" % debuglevel)

    # 'found'     sets the value 'y/m' (driver detected)
    # 'found_y'   sets the value 'y' (driver detected, forces built-in)
    # 'found_m'   sets the value 'm' (driver detected, build as module)
    # 'found_n'   sets the value 'n' (driver not needed)
    #
    #  The priority is: y > m > n > 'other'
    def found(self, symbol, val=None, label=None):
        if type(symbol) == type(""):
            symbol = self.myconfiguration.dictionary.get(symbol)
        # Ignore obsolete symbols
        if not symbol:
            return
        # Ignore attempts to set derived symbols.  Some autoprobes
        # do this because they were composed in ignorance of the rulebase.
        elif symbol.is_derived():
            return
        # If no value specified, play some tricks.
        if val == None:
            if symbol.type=="bool" or (self.hardcompile and symbol.type=="trit"):
                val = cml.y
            elif symbol.type == "trit":
                val = cml.m
            elif symbol.is_numeric():
                val = 0
            elif symbol.type == "string":
                val = ""
        if not self.modified.has_key(symbol) or symbol.eval() < val:
            self.myconfiguration.set_symbol(symbol, val)
            self.modified[symbol] = 1
            (ok, effects, violations) = self.myconfiguration.set_symbol(symbol, val)
            if ok:
                if label:
                    symbol.setprop(label)
            else:
                for violation in violations:
                    sys.stderr.write(lang["SETFAIL"] % (`violation`, symbol.name, val))

    def found_y(self, var, label=None): self.found(var, cml.y, label) 
    def found_m(self, var, label=None): self.found(var, cml.m, label) 
    def found_n(self, var, label=None): self.found(var, cml.n, label) 

    def yak(self, symbol):
        if not self.emitted.has_key(symbol):
            try:
                entry = self.myconfiguration.dictionary[symbol]
                if entry.prompt:
                    sys.stderr.write("* " + symbol + ": " + entry.prompt + "\n")
                    self.emitted[symbol] = 1
            except KeyError:
                sys.stderr.write("! Obsolete symbol: " + symbol + "\n")

    def complement(self, symbol, value, baton, label):
        "Force a complement set to a specified value."
        symbol = self.myconfiguration.dictionary[symbol]
        if not symbol.eval():
            return
        for driver in self.myconfiguration.dictionary.values():
            if baton: baton.twirl()
            if driver.is_symbol() and driver.is_logical() \
                    and self.myconfiguration.is_visible(driver) \
                    and driver.setcount == 0 \
                    and symbol.ancestor_of(driver):
                set_to = value
                if driver.type == "bool" and value == cml.m:
                    set_to = cml.y
                self.found(driver.name, set_to, label)

    def force_dependents_modular(self, symbol, legend):
        "Force all trit-valued dependents of a symbol to be modular."
        net_ethernet = self.myconfiguration.dictionary[symbol]
        for driver in self.myconfiguration.dictionary.values():
            if driver.is_symbol() and driver.type == "trit" \
            		and driver.eval() == cml.y \
			and self.myconfiguration.is_visible(driver) \
        		and net_ethernet.ancestor_of(driver):
                driver.setprop(legend)
                self.found(driver, cml.m)

    def enabled(self, symbol):
        "Is a given symbol enabled?"
        return self.myconfiguration.dictionary[symbol]

# Now define classes for probing and reporting the system state

class PCIDevice:
    "Identification data for a device on the PCI bus."
    def __init__(self, procdata):
        "Initialize PCI device ID data based on what's in a /proc entry."
        procdata = map(ord, procdata)
        self.vendor = "%02x%02x" % (procdata[1], procdata[0])
        self.device = "%02x%02x" % (procdata[3], procdata[2])
        if procdata[14]:
            self.subvendor = None
            self.subdevice = None
        else:
            self.subvendor = "%02x%02x" % (procdata[45], procdata[44])
            self.subdevice = "%02x%02x" % (procdata[47], procdata[46])
        self.revision = "%02x" % procdata[8]
        self.deviceclass = "%02x%02x" % (procdata[11], procdata[10])
        self.interface = "%02x" % procdata[9]
        # Here is the digest format:
        #    "pci: xxxx,yyyy,zz:Class:aabb,cc"  or
        #    "pci: xxxx,yyyy,ssss,rrrr,zz:Class:aabbb,cc"
        #   where: xxxx,yyyy: the vendor and device id
        #         ssss,rrrr: the sub-vendor and sub-device id
        #         zz: revision
        #         aabb,cc: Device Class, Interface
        self.digest = self.vendor + "," + self.device
        if self.subvendor:
            self.digest += "," + self.subvendor + "," + self.subdevice
        self.digest += ",%s;Class:%s,%s\n" % (self.revision,self.deviceclass,self.interface)
    def __repr__(self):
        return "pci: " + self.digest

class PCIScanner:
    "Encapsulate the PCI hardware registry state."
    def __init__(self):
        "Unpack data from the PCI hardware registry."
        self.devices = []
        for f in glob.glob("/proc/bus/pci/??/*"):
            dfp = open(f)
            self.devices.append(PCIDevice(dfp.read()))
            dfp.close()
    def search(self, pattern):
        "Search for a device match by prefix in the digest."
        pattern = re.compile(pattern, re.I)
        return not not filter(lambda x, p=pattern: p.search(x.digest), self.devices)
    def __repr__(self):
        return "".join(map(repr, self.devices))

class FieldParser:
    "Parse entire lines, or a given field, out of a file or command output."
    def __init__(self, sources):
        self.items = []
        for item in sources:
            if type(item) == type(()):
                file = item[0]
                field = item[1]
            else:
                file = item
                field = None
            try:
                if file[0] == '/':
                    ifp = open(file, "r")
                    lines = ifp.readlines()
                    ifp.close()
                else:
                    (status, output) = commands.getstatusoutput(file)
                    if status:
                        raise IOError
                    lines = output.split("\n")
            except IOError:
                continue
            # No field specified, capture entire line
            if not field:
                self.items += lines
            # Numeric (1-origin) field index, capture that
            # space-separated field.
            elif type(field) == type(0):
                for line in lines:
                    fields = line.split()
                    if len(fields) >= field and fields[field-1] not in self.items:
                        self.items.append(fields[field-1])
            # Regexp specified, collect group 1
            else:
                for line in lines:
                    lookfor = re.compile(field)
                    match = lookfor.search(line)
                    if match:
                        res = match.group(1)
                        if res not in self.items:
                            self.items.append(res)
    def find(self, str, ind=0):
        "Is given string or regexp pattern found in the file?"
        match = re.compile(str)
        result = filter(lambda x: x, map(lambda x, ma=match: ma.search(x), self.items))
        if result:
            result = result[ind]
            if result.groups():
                result = ",".join(result.groups())
        return result
    def __repr__(self):
        return `self.items`

#
# Main sequence begins here
#

def get_arch():
    # Get the architecture (taken from top-level Unix makefile).
    (error, ARCH) = commands.getstatusoutput('uname -m | sed -e s/i.86/i386/ -e s/sun4u/sparc64/ -e s/arm.*/arm/ -e s/sa110/arm/')
    if error:
        sys.stderr.write(lang["UNAME"])
        raise SystemExit, 1
    # A platform symbol has to be set, otherwise many assignments will fail
    ARCHSYMBOL = re.compile("i.86").sub("x86", ARCH)
    ARCHSYMBOL = ARCHSYMBOL.replace("superh", "sh")
    ARCHSYMBOL = ARCHSYMBOL.replace("sparc32", "sparc")
    ARCHSYMBOL = ARCHSYMBOL.replace("sparc64", "sparc")
    ARCHSYMBOL = ARCHSYMBOL.upper()
    return(ARCH, ARCHSYMBOL)

# We can't assume 2.1 nested scopes, so refer shared stuff to global level.
config = cpu = cpu_id = pci = isapnp = mca = usbp = usbc = usbi = None
fs = devices = m_devices = misc = net = ide = dmesg = None
modules = cpu_latch = None
fsmap = {}
reliable = {}

def autoconfigure(configuration, hardcompile, debuglevel):
    global config, cpu, cpu_id, pci, isapnp, mca, usbp, usbc, usbi, fs
    global devices, m_devices, misc, net, ide, dmesg, modules, cpu_latch
    global fsmap, reliable
    configuration.interactive = 0	# Don't deduce from visibility.

    config = ConfigFile(configuration, hardcompile, debuglevel)

    #
    # Here is where we query the system state.
    #
    (ARCH, ARCHSYMBOL) = get_arch()
    config.found_y(ARCHSYMBOL)
    config.yak(ARCHSYMBOL)

    # Get the processor type
    cpu     = FieldParser(("/proc/cpuinfo",))
    if ARCHSYMBOL == 'SPARC':
      processors = int(cpu.find("^ncpus active.*: *([0-9]*)"))
      vendor     = cpu.find("^cpu.*: *(.*)")
      cpufam     = cpu.find("^type.*: *([-A-Za-z0-9_]*)")
      mod        = cpu.find("^fpu.*: *(.*)")
      name       = cpu.find("^MMU Type.*: *(.*)")
    else:
      processors = int(cpu.find("^processor.*: *([0-9]*)", -1)) + 1
      vendor  = cpu.find("^vendor_id.*: *([-A-Za-z0-9_]*)")
      cpufam  = cpu.find("^cpu family.*: *([-A-Za-z0-9_]*)")
      mod     = cpu.find("^model.*: *([-A-Za-z0-9_]*)")
      name    = cpu.find("^model name.*: *(.*)")

    cpu_id = vendor + ":" + cpufam + ":" + mod + ":" + name
    cpu_latch = 0

    # Now query for features
    pci     = PCIScanner()
    isapnp  = FieldParser((("/proc/bus/isapnp/devices", 2),))
    mca     = FieldParser(("/proc/mca/pos",))
    usbp    = FieldParser((("/proc/bus/usb/devices", "^P:.*Vendor=([A-Fa-f0-9]*)\s.*ProdID=\([A-Fa-f0-9]*\)"),))
    usbc    = FieldParser((("/proc/bus/usb/devices", "^D:.*Cls=([A-Fa-f0-9]*)[^A-Fa-f0-9].*Sub=([A-Fa-f0-9]*)[^A-Fa-f0-9].*Prot=([A-Fa-f0-9]*)"),))
    usbi    = FieldParser((("/proc/bus/usb/devices", "^I:.*Cls=([A-Fa-f0-9]*)[^A-Fa-f0-9].*Sub=([A-Fa-f0-9]*)[^A-Fa-f0-9].*Prot=([A-Fa-f0-9]*)"),))
    fs      = FieldParser((("/proc/mounts",3),
                           ("/etc/mtab", 3),
                           ("/etc/fstab", 3)))
    devices = FieldParser((("/proc/devices", "[0-9]+ (.*)"),))
    m_devices = FieldParser((("/proc/misc", "[0-9]+ (.*)"),))
    misc    = FieldParser(("/proc/iomem", "/proc/ioports", "/proc/dma", "/proc/interrupts"))
    net     = FieldParser((("/proc/net/sockstat","^([A-Z0-9]*): inuse [1-9]"),))
    ide     = FieldParser(glob.glob('/proc/ide/hd?/media'))
    dmesg   = FieldParser(("/var/log/dmesg", "dmesg"))
    modules = FieldParser((("/proc/modules", 1),))

    #
    # Tests that won't fit in the rulesfile format
    #

    # Source: linux/i386/kernel/setup.c
    if dmesg.find("Use a PAE"):
        config.found_y("HIGHMEM64G")	
    elif dmesg.find("Use a HIGHMEM"):
        config.found_y("HIGHMEM4G")	##Source: linux/i386/kernel/setup.c
    else:
        highmem = dmesg.find("([0-9]*)MB HIGHMEM avail.")
        if not highmem:
            config.found_y("NOHIGHMEM")
        elif int(highmem) > 3072:
            config.found_y("HIGHMEM64G")
        else:
            config.found_y("HIGHMEM4G")

    # SMP?  This test is reliable.
    if processors == 0:
      processors = len(filter(lambda x: x.find('processor') > -1, cpu.items))

    if processors > 1:
        config.found_y("SMP")
        config.yak("SMP")

    fsmap = {}
    reliable = {}

    #
    # Here are the function calls used by the rules file
    #
    TRUE = 1
    FALSE = 0
    PRESENT = 1
    ABSENT = 0
    
    def DEBUG(str):
        sys.stderr.write("# " + str + "\n")

    # Following three tests are reliable -- that is, if PCI or PNP
    # tests fail we know the feature is *not* there.

    def PCI(prefix, symbol):
        global pci, config
        reliable[symbol] = "PCI"
        if pci.search("^" + prefix):
            config.yak(symbol)
            config.found(symbol, None, "PCI")


    def PCI_CLASS(match, symbol):
        global pci, config
        reliable[symbol] = "PCI_CLASS"
        if pci.search("Class:" + match):
            config.yak(symbol)
            config.found(symbol, None, "PCI_CLASS")

    def PNP(match, symbol):
        global isapnp, config
        reliable[symbol] = "PNP"
        if isapnp.find(match):
            config.yak(symbol)
            config.found(symbol, None, "PNP")

    def MCA(match, symbol):
        global mca, config
        reliable[symbol] = "MCA"
        # FIXME: Not certain I've got the byte order right here
        if mca.find(": " + match[2:] + " " + match[:2]):
            config.yak(symbol)
            config.found(symbol, None, "MCA")

    # USB tests reliably detect connected devices, but the bus is hot-plug.

    def USBP(match, symbol):
        global usbp, config
        if usbp.find(match):
            config.yak(symbol)
            config.found(symbol, None, "USBP")

    def USBC(match, symbol):
        global usbc, config
        if usbc.find(match):
            config.yak(symbol)
            config.found(symbol, None, "USBC")

    def USBI(match, symbol):
        global usbi, config
        if usbi.find(match):
            config.yak(symbol)
            config.found(symbol, None, "USBI")

    # Remaining tests rely on prior kernel configuration.

    def FS(match, symbol):
        global fs, fsmap, config
        if fs.find(r"\b" + match + r"\b"):
            config.yak(symbol)
            config.found(symbol, None, "FS")
        # Also, build the map of file system types to symbols.
        fsmap[match] = symbol

    def DEV(match, symbol):
        global devices, config
        if devices.find(r"\b" + match + r"\b"):
            config.yak(symbol)
            config.found(symbol, None, "DEV")

    def DEVM(match, symbol):
        global m_devices, config
        if m_devices.find(r"\b" + match + r"\b"):
            config.yak(symbol)
            config.found(symbol, None, "DEV_M")

    def CONS(match, symbol):
        global dmesg, config
        if dmesg.find("^Console: .* " + match + " "):
            config.yak(symbol)
            config.found(symbol, None, "CONS")

    def DMESG(match, symbol, truthval=TRUE):
        global dmesg, config
        if dmesg.find(match):
            if truthval:
                config.found(symbol, None, "DMESG")
                config.yak(symbol)
            else:
                config.found_n(symbol, "DMESG")

    def NET(match, symbol):
        global net, config
        if net.find(match):
            config.yak(symbol)
            config.found(symbol, None, "NET")

    def IDE(match, symbol):
        global ide, config
        if ide.find(match):
            config.yak(symbol)
            config.found(symbol, None, "IDE")

    def REQ(match, symbol):
        global misc, config
        if misc.find(match):
            config.yak(symbol)
            config.found(symbol, None, "REQ")

    def CPUTYPE(match, symbol):
        global cpu_latch, config
        if not cpu_latch and re.search(match, cpu_id):
            config.found_y(symbol, "CPUTYPE")
            config.yak(symbol)
            cpu_latch = 1

    def CPUINFO(match, symbol, present=PRESENT, truthval=cml.y):
        global cpu, config
        if (not not cpu.find(match)) == present:
            config.found(symbol, truthval, "CPUINFO")
            if truthval:
                config.yak(symbol)

    def EXISTS(procfile, symbol):
        global config
        if os.path.exists(procfile):
            config.found(symbol, None, "EXISTS")
            config.yak(symbol)
        else:
            config.found(symbol, n, "EXISTS")

    def MODULE(name, symbol):
        global modules, config
        if modules.find(r"\b" + name + r"\b"):
            config.found(symbol, None, "MODULES")
            config.yak(symbol)

    def GREP(pattern, file, symbol):
        global config
        try:
            fp = open(file)
        except IOError:
            return
        if re.compile(pattern).search(fp.read()):
            config.found(symbol, None, "GREP")
            config.yak(symbol)
        fp.close()  

    def LINKTO(file, pattern, symbol):
        global config
        if not os.path.exists(file):
            return
        file = os.readlink(file)
        if re.compile(pattern).search(file):
            config.found(symbol, None, "LINKTO")
            config.yak(symbol)

    # Use this to avoid conflicts

    def PRIORITY(symbols, cnf=configuration):
        global config
        legend = "PRIORITY" + `symbols`
        dict = cnf.dictionary
        symbols = map(lambda x, d=dict: d[x], symbols)
        for i in range(len(symbols) - 1):
            if cml.evaluate(symbols[i]):
                for j in range(i+1, len(symbols)):
                    cnf.set_symbol(symbols[j], n)
                    symbols[j].setprop(legend)
                break

    ########################################################################
    ##
    ## Section            Command         Version        Status
    ## ------------------------------------------------------------------
    ##  /proc features     EXISTS          2.5.2-pre7     Partial 

    ########################################################################
    ## Section: System Features
    ## KernelOutput: /proc/*, /dev/*
    ## Detect system features based on existence of /proc and /dev/* files 
    DEBUG("autoconfigure.rules: EXISTS")

    ## These tests are unreliable; they depend on the current kernel config.
    EXISTS("/proc/sysvipc",		'SYSVIPC')
    EXISTS("/proc/sys",			'SYSCTL')
    EXISTS("/proc/scsi/ide-scsi",	'BLK_DEV_IDESCSI')
    EXISTS("/proc/scsi/imm",		'SCSI_IMM')
    EXISTS("/proc/scsi/ppa",		'SCSI_PPA')
    EXISTS("/dev/.devfsd",		'DEVFS_FS')
    # Giacomo does not have these yet.
    EXISTS("/proc/sys/net/khttpd",	'KHTTPD')
    EXISTS("/proc/sys/kernel/acct",	'BSD_PROCESS_ACCT')
    # This one is reliable, according to the MCA port documentation.
    EXISTS("/proc/mca",			'MCA')
    # This one is reliable too
    EXISTS("/proc/bus/isapnp/devices",	'ISAPNP')

    # Test the new probe function.
    GREP("scsi0", "/proc/scsi/scsi",	'SCSI')

    # These can be bogus because the file or directory in question
    # is empty, or consists of a banner string that does not describe
    # an actual device.  We need to do more analysis here.
    # EXISTS("/proc/bus/pci",		'PCI')
    # EXISTS("/proc/bus/usb",		'USB')
    # EXISTS("/proc/net",		'NET')
    # EXISTS("/proc/scsi",		'SCSI')		

    # These look tempting, but they're no good unless we're on a pure
    # devfs system, without support for old devices, where devices
    # only exist when they're needed.
    # EXISTS("/dev/agpgart",		'AGP')
    # EXISTS("/dev/floppy",		'BLK_DEV_FD')
    # EXISTS("/dev/fd0",		'BLK_DEV_FD')

    
    ########################################################################
    ## Section: Mice
    ## Detect the mouse type by looking at what's behind the /dev/mouse link.
    ## These are probes for 2.4 with the old input core
    LINKTO("/dev/mouse", "psaux",	'PSMOUSE')
    LINKTO("/dev/mouse", "ttyS",	'SERIAL')
    LINKTO("/dev/mouse", "logibm",	'LOGIBUSMOUSE')
    LINKTO("/dev/mouse", "inportbm",	'MS_BUSMOUSE')
    LINKTO("/dev/mouse", "atibm",	'ATIXL_BUSMOUSE')
    ## These are probes for 2.5 with the new input core
    LINKTO("/dev/mouse", "psaux",	'MOUSE_PS2')
    LINKTO("/dev/mouse", "ttyS",	'MOUSE_SERIAL')
    LINKTO("/dev/mouse", "logibm",	'MOUSE_LOGIBM')
    LINKTO("/dev/mouse", "inportbm",	'MOUSE_INPORT')
    LINKTO("/dev/mouse", "atibm",	'MOUSE_ATIXL')

    ########################################################################
    ## Section: IDE devices
    ## KernelOutput: /proc/ide/hd?/media
    ## Detect IDE devices based on contents of /proc files
    ## These tests are unreliable; they depend on the current kernel config.
    IDE('disk', 'BLK_DEV_IDEDISK')
    IDE('cdrom', 'BLK_DEV_IDECD')
    IDE('tape', 'BLK_DEV_IDETAPE')
    IDE('floppy', 'BLK_DEV_FLOPPY')
    EXISTS("/dev/ide/ide0",		'BLK_DEV_IDE')
    EXISTS("/dev/ide/ide1",		'BLK_DEV_IDE')
    EXISTS('/proc/ide/piix',		'PIIX_TUNING')

    ########################################################################
    # Miscellaneous tests that replace Giacomo's ad-hoc ones.
    DEV('pty', 'UNIX98_PTYS')
    REQ('SMBus', 'I2C')
    REQ('ATI.*Mach64', 'FB_ATY')
    #FS(r'xfs', 'XFS_FS')

    ########################################################################
    # This is a near complete set of MCA probes for hardware supported under
    # Linux, according to MCA maintainer David Weinehall.  The exception is
    # the IBMTR card, which cannot be probed reliably.
    if config.enabled("MCA"):
        MCA("ddff", 'BLK_DEV_PS2')
        MCA("df9f", 'BLK_DEV_PS2')
        MCA("628b", 'EEXPRESS')
        MCA("627[cd]", 'EL3')
        MCA("62db", 'EL3')
        MCA("62f6", 'EL3')
        MCA("62f7", 'EL3')
        MCA("6042", 'ELMC')
        MCA("0041", 'ELMC_II')
        MCA("8ef5", 'ELMC_II')
        MCA("61c[89]", 'ULTRAMCA')
        MCA("6fc[012]", 'ULTRAMCA')
        MCA("efd[45]", 'ULTRAMCA')
        MCA("efe5", 'ULTRAMCA')
        MCA("641[036]", 'AT1700')
        MCA("6def", 'DEPCA')
        MCA("6afd", 'SKMC')
        MCA("6be9", 'SKMC')
        MCA("6354", 'NE2_MCA')
        MCA("7154", 'NE2_MCA')
        MCA("56ea", 'NE2_MCA')
        MCA("ffe0", 'IBMLANA')
        MCA("8ef[8cdef]", 'SCSI_IBMMCA')
        MCA("5137", 'SCSI_FD_MCS')
        MCA("60e9", 'SCSI_FD_MCS')
        MCA("6127", 'SCSI_FD_MCS')
        MCA("0092", 'SCSI_NCR_D700')
        MCA("7f4c", 'SCSI_MCA_53C9X')
        MCA("0f1f", 'SCSI_AHA_1542')
        MCA("002d", 'MADGEMC')
        MCA("6ec6", 'SMCTR')
        MCA("62f3", 'SOUND_SB')
        MCA("7113", 'SOUND_SB')

    ########################################################################
    ## This requires Paul Gortmaker's EISA ID patch.
    REQ("EISA", "EISA")	# Someday, IOPORTS()

    ########################################################################
    ## The rest of the table is read in from Giacomo's Catenazzi's rulesfile.
    execfile(rulesfile)

    # If it has a reliable test, but was not found by any test, switch it off.
    # We do things in this order to avoid losing on symbols that are only set
    # to n by PNP and PCI tests.
    baton = cml.Baton(lang["TURNOFF"])
    for symbol in configuration.dictionary.values():
        baton.twirl()
        if symbol.is_symbol() and configuration.saveable(symbol) \
           and reliable.has_key(symbol.name) and not cml.evaluate(symbol):
            config.found(symbol.name, n, reliable[symbol.name])
    baton.end()

    ########################################################################
    ## Resolve conflicts.

    PRIORITY(("SCSI_SYM53C8XX_2", "SCSI_SYM53C8XX", \
                                 "SCSI_NCR53C8XX", "SCSI_GENERIC_NCR5380"))
    PRIORITY(("DE2104X", "TULIP"))

    ## End of probe logic.
    ##
    ########################################################################

    # More tests that don't fit the rulesfile format

    # Filesystem, bus, and controller for root cannot be modules.
    sys.stderr.write(lang["ROOTLOOK"])
    fstab_to_bus_map = {
        r"^/dev/sd" : ("SCSI",),
        r"^/dev/hd" : ("IDE",),
        r"\bnfs\b" : ("NFS_FS", "NFS_ROOT", "NET"),
        }
    ifp = open("/etc/mtab", "r")
    while 1:
        line = ifp.readline()
        if not line:
            break
        fields = line.split()
        mountpoint = fields[1]
        fstype = fields[2]
        if mountpoint == "/":
            # Figure out the drive type of the root partition.
            rootsymbols = []
            for (pattern, symbols) in fstab_to_bus_map.items():
                if re.compile(pattern).search(line):
                    rootsymbols = list(symbols)
            if fsmap.has_key(fstype):
                rootsymbols.append(fsmap[fstype])
            if not rootsymbols:
                sys.stderr.write(lang["ROOTWARN"])
                break
            # We should have a list of `buses' now...
            for roottype in rootsymbols:
                # First we have to force the bus the drive is on to y.
                config.found(roottype, y, "Root filesystem")
                sys.stderr.write(lang["ROOTFS"] % roottype)
                # Then force all bootable hardware previously set modular and
                # dependent on this bus to y.
                bus = configuration.dictionary[roottype]
                for symbol in configuration.dictionary.values():
                    if cml.evaluate(symbol) == m \
                       and symbol.hasprop("BOOTABLE") \
                       and bus.ancestor_of(symbol):
                        config.found(symbol.name, y, "Root filesystem")
                        sys.stderr.write(lang["ROOTHW"] % symbol.name)
    ifp.close()

    # PTY devices
    ptycount = dmesg.find('pty: ([0-9]*) Unix98 ptys')
    if ptycount:
        config.found("UNIX98_PTY_COUNT", int(ptycount))

    # Helper functions.

    def grepcmd(pattern, cmd):
        "Test for PATTERN in the output of COMMAND."
        (status, output) = commands.getstatusoutput(cmd)
        return status == 0 and re.compile(pattern).search(output)

    # Apply those sanity checks

    # Handle a subtle gotcha: if there are multiple NICs, they must be modular.
    if grepcmd("eth[1-3]", "/sbin/ifconfig -a"):
        config.force_dependents_modular("NET_ETHERNET",
                                        "Multiple NICs must be modular")

    # Now freeze complement sets.  With any luck, this will reduce the
    # set of drivers the user actually has to specify to zero.
    #
    # Giacomo writes:
    # "BTW I have done some test with USB, and it seems that you can
    # hotplug USB devices, also with hardcored drivers, and the driver
    # is initialized only at the hotplug event.
    # (This mean that USB devices can be set also to 'y', without
    # losing functionality.
    # This is not true for other 'hotplug' devices. I.e. my
    # parport ZIP will be loaded only at boot time (hardcoded) or
    # at modules loading (module)."
    #
    # So far I have not done anything about this.
    if not hardcompile:
        b = cml.Baton(lang["COMPLEMENT"])
        config.complement("HOTPLUG_PCI",cml.m, b, "PCI_HOTPLUG is a hot-plug bus")
        config.complement("USB",        cml.m, b, "USB is a hot-plug bus")
        config.complement("PCMCIA",     cml.m, b, "PCMCIA is a hot-plug bus")
        config.complement("IEEE1394",   cml.m, b, "IEEE1394 ia a hot-plug bus")
        b.end(lang["DONE"])

    DEBUG(lang["COMPLETE"])

def process_define(myconfiguration, val, freeze):
    "Process a -d=xxx or -D=xxx option."
    parts = val.split("=")
    sym = parts[0]
    if myconfiguration.dictionary.has_key(sym):
        sym = myconfiguration.dictionary[sym]
    else:
        myconfiguration.errout.write(lang["SYMUNKNOWN"] % (`sym`,))
        sys.exit(1)
    if sym.is_derived():
        myconfiguration.debug_emit(1, lang["DERIVED"] % (`sym`,))
        sys.exit(1)
    elif sym.is_logical():
        if len(parts) == 1:
            val = 'y'
        elif parts[1] == 'y':
            val = 'y'
        elif parts[1] == 'm':
            myconfiguration.trits_enabled = 1
            val = 'm'
        elif parts[1] == 'n':
            val = 'n'
    elif len(parts) == 1:
        print lang["NOCMDLINE"] % (`sym`,)
        sys.exit(1)
    else:
        val = parts[1]
    (ok, effects, violation) = myconfiguration.set_symbol(sym,
                                     myconfiguration.value_from_string(sym, val),
                                     freeze)
    if effects:
        sys.stderr.write(lang["EFFECTS"] + "\n")
        sys.stderr.write("\n".join(effects) + "\n\n")
    if not ok:
        sys.stderr.write((lang["ROLLBACK"] % (sym.name, val)) + "\n")
        sys.stderr.write("\n".join(violation)+"\n")

if __name__ == "__main__":
    # Process command-line options
    try:
        (options, arguments) = getopt.getopt(sys.argv[1:], "d:D:hr:st:v",
                                             ("hardcompile",
                                              "rules=",
                                              "standalone",
                                              "target=",
                                              "verbose"))
    except getopt.GetoptError:
        sys.stderr.write(lang["OPTUNKNOWN"])
        raise SystemExit, 2

    autoprobe_debug = hardcompile = standalone = 0
    objtree = os.environ.get("KBUILD_OBJTREE")
    rulesfile = "autoconfigure.rules"
    freeze_em = []
    set_em = []

    for (opt, val) in options:
	if opt == '-D':
            freeze_em.append(val)
	elif opt == '-d':
            set_em.append(val)
        elif opt in ("-v", "--verbose"):
            autoprobe_debug += 1
        elif opt in ("--hardcompile", "-h"):
            hardcompile = 1
        elif opt in ("--rules", "-r"):
            rulesfile = val
        elif opt in ("--standalone", "-s"):
            standalone = 1
        elif opt in ("--target", "-t"):
            objtree = os.path.expanduser(val)

    if objtree == None:
        objtree = "."

    #
    # Now use the rulebase information
    #
    rulebase = os.path.join(objtree, "rules.out")
    if not os.path.exists(rulebase):
        sys.stderr.write("autoconfigure: rulebase %s does not exist!\n" % rulebase)
        raise SystemExit, 1
    configuration = cmlsystem.CMLSystem(rulebase)
    if not cmlsystem:
        sys.stderr.write("autoconfigure: rulebase %s could not be read!\n" % rulebase)
        raise SystemExit, 1

    # Autoconfigure into the configuration object.
    for sym in freeze_em:
        process_define(configuration, sym, 1)
    for sym in set_em:
        process_define(configuration, sym, 0)
    autoconfigure(configuration, hardcompile, autoprobe_debug)

    # Write out this configuration, we're done.
    if standalone:
        configuration.save(sys.stdout, None, "normal")
    else:
        configuration.save(sys.stdout, None, "probe")

# End
