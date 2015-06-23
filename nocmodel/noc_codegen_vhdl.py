#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# NoC Code generator - VHDL generator
#
# Author:  Oscar Diaz
# Version: 0.1
# Date:    11-11-2011

#
# This code is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the
# Free Software  Foundation, Inc., 59 Temple Place, Suite 330,
# Boston, MA  02111-1307  USA
#

#
# Changelog:
#
# 11-11-2011 : (OD) initial release
#

"""
Code generation support for VHDL

This module defines:
* Class 'noc_codegen_vhdl'
* Function 'add_codegen_vhdl_support'
"""

from nocmodel import *
from noc_codegen_base import *
from myhdl import intbv, bin

class noc_codegen_vhdl(noc_codegen_base):
    """
    VHDL generator class
    
    This class defines methods used to generate VHDL code from any noc object.
    
    Like base class, this object has this base attributes:
    * docheader
    * libraries
    * modulename
    * generics
    * ports
    * implementation
    """
    def __init__(self, nocobject_ref, **kwargs):
        noc_codegen_base.__init__(self, nocobject_ref, **kwargs)
        
        # note: the noc object must be complete, in order to 
        # add code generation support
        #self.nocobject_ref = nocobject_ref
        self.modulename = self.to_valid_str(self.nocobject_ref.name)
        
        # default header and libraries
        self.docheader = "-- Document header"
        self.libraries = "library ieee;\nuse ieee.std_logic_1164.all;\nuse ieee.numeric_std.all;"

        # code generation attributes
        self.usetab = "    " # 4-space tabs
        self.full_comments = True
            
     # main methods
    def generate_file(self):
        """
        Generate the entire file that implements this object.
        """
        # Unless code generation is externally generated.
        if self.external_conversion:
            # use "codemodel" object on nocobject_ref
            if hasattr(self.nocobject_ref, "codemodel"):
                return self.nocobject_ref.codemodel.generate_file()
            else:
                raise AttributeError("External conversion flag is enabled, but there's no 'codemodel' object available in nocobject %s" % self.nocobject_ref)
        else:
            # first try to call build_implementation() method
            self.build_implementation()
            sret = self.docheader + "\n\n" + self.libraries + "\n\n"
            if self.full_comments:
                sret += self.make_comment("Object '%s' name '%s' description '%s'\n" % (repr(self.nocobject_ref), self.nocobject_ref.name, self.nocobject_ref.description))
            sret += self.generate_entity_section() + "\n\n"
            sret += self.generate_architecture_section() + "\n"
            return sret
    
    def generate_component(self):
        """
        Generate a component definition for this object.
        """
        sret = "component %s\n" % self.modulename
        stmp = self.generate_generics_section()
        if stmp != "":
            sret += self.add_tab(stmp) + ";\n"
        stmp = self.generate_ports_section()
        if stmp != "":
            sret += self.add_tab(stmp) + ";\n"
        sret += "end component;\n"
        return sret

    def generate_generic_declaration(self, generic=None, with_default=False):
        """
        Generate a generic declaration for this object.
        
        Arguments:
        * generic : either a name or a list index for a particular generic
        * with_default : True to add the default value
        
        Returns:
        * A string when generic argument is used
        * A list of strings with all generics 
        """
        if generic is None:
            # all generics
            l = []
            for i in range(len(self.generics)):
                l.append(self.generate_generic_declaration(i, with_default))
            return l
        else:
            # search for correct index
            if isinstance(generic, int):
                g = self.generics[generic]
            elif isinstance(generic, string):
                g = filter(lambda s: s["name"] == generic, self.generics)[0]
            else:
                raise TypeError("Don't know how to search with '%s'." % repr(generic))
            sret = "%s : %s" % (self.to_valid_str(g["name"]), g["type"])
            if with_default:
                sret += ' := %s' % convert_value(g["default_value"], g["type"], g["type_array"])
                # add string quotes
#                if g["type"] == "string":
#                    sret += ' := "%s"' % g["default_value"]
#                else:
#                    sret += ' := %s' % g["default_value"]
            return sret

    def generate_port_declaration(self, port=None, with_default=False):
        """
        Generate a port declaration for this object.
        
        Arguments:
        * port : either a name or a list index for a particular port
        * with_default : True to add the default value
        
        Returns:
        * A list of strings with all signals in port when port argument is used
        * A list of strings with all signals in all ports
        """
        if port is None:
            # all ports
            l = []
            for i in range(len(self.ports)):
                l.append(self.make_comment("Port '%s' : '%s'" % (self.to_valid_str(self.ports[i]["name"]), self.ports[i]["type"])))
                pl = self.generate_port_declaration(i, with_default)
                pl.sort()
                l.extend(pl)
            return l
        else:
            # search for correct index
            if isinstance(port, int):
                idx = port
            elif isinstance(port, string):
                p = filter(lambda s: s["name"] == port, self.ports)[0]
                idx = self.ports.index(p)
            else:
                raise TypeError("Don't know how to search with '%s'." % repr(port))
            return self.generate_signal_declaration(idx, None, with_default)

    def generate_signal_declaration(self, inport=None, signal=None, with_default=False):
        """
        Generate a signal declaration for this object.
        
        Arguments:
        * inport : either a name or a list index for a particular port. None 
            means use the external_signals list
        * signal : either a name or a list index for a particular signal
        * with_default : True to add the default value
        
        Returns:
        * A string when signal argument is used
        * A list of strings with all signals
        """
        if signal is None:
            # all signals
            l = []
            if inport is None:
                r = range(len(self.external_signals))
            else:
                # what port?
                if isinstance(inport, int):
                    g = self.ports[inport]
                elif isinstance(inport, string):
                    g = filter(lambda s: s["name"] == inport, self.ports)[0]
                else:
                    raise TypeError("Don't know how to search with '%s'." % repr(inport))
                r = range(len(g["signal_list"]))
            for i in r:
                l.append(self.generate_signal_declaration(inport, i, with_default))
            return l
        else:
            # locate either port or external_signals
            if inport is None:
                if isinstance(signal, int):
                    sig = self.external_signals[signal]
                elif isinstance(signal, string):
                    sig = filter(lambda s: s["name"] == signal, self.external_signals)[0]
                else:
                    raise TypeError("Don't know how to search with '%s'." % repr(signal))
                # put nothing as signal prefix
                sprefix = ""
            else:
                # what port?
                if isinstance(inport, int):
                    p = self.ports[inport]
                elif isinstance(inport, string):
                    p = filter(lambda s: s["name"] == inport, self.ports)[0]
                else:
                    raise TypeError("Don't know how to search with '%s'." % repr(inport))
                # what signal?
                if isinstance(signal, int):
                    sig = p["signal_list"][signal]
                elif isinstance(signal, string):
                    sig = filter(lambda s: s["name"] == signal, p["signal_list"])[0]
                else:
                    raise TypeError("Don't know how to search with '%s'." % repr(signal))
                # put port name as signal prefix
                #sprefix = self.to_valid_str(p["name"]) + "_"
                sprefix = ""
            sret = "%s%s : %s %s" % (sprefix, self.to_valid_str(sig["name"]), sig["direction"], sig["type"])
            if with_default:
                sret += ' := %s' % convert_value(sig["default_value"], sig["type"])
#                if sig["type"] == "string":
#                    sret += ' := "%s"' % sig["default_value"]
#                else:
#                    sret += ' := %s' % sig["default_value"]
            return sret
            
    def make_comment(self, data):
        """
        Convert string data to language comment
        
        Argument:
        * data: string or list of strings to convert
        
        Returns: a new string or list of strings with comments added.
        """
        if isinstance(data, str):
            return "-- %s%s" % (data[:-1].replace("\n", "\n-- "), data[-1])
        else:
            # don't put exception catch. It is an error if data is not
            # iterable.
            it = iter(data)
            retval = []
            for s in data:
                retval.append("-- %s%s" % (s[:-1].replace("\n", "\n-- "), s[-1]))
            return retval
            
    def add_tab(self, data, level=1):
        """
        Add an indentation level to the string
        
        Argument:
        * data: string or list of strings
        * level: how many indentation levels to add. Default 1
        
        Returns: string or list of strings with <level> indentation levels.
        """
        leveltabs = self.usetab*level
        if isinstance(data, str):
            return "%s%s%s" % (leveltabs, data[:-1].replace("\n", "\n%s" % leveltabs), data[-1])
        else:
            # don't put exception catch. It is an error if data is not
            # iterable.
            it = iter(data)
            retval = []
            for s in data:
                retval.append("%s%s%s" % (leveltabs, s[:-1].replace("\n", "\n%s" % leveltabs), s[-1]))
            return retval
            
    def to_valid_str(self, str_in):
        """
        Convert an input string, changing special characters used on
        the HDL language. Useful for set names .
        
        Argument:
        * str_in: string to convert
        
        Returns: the converted string.
        """
        # list of transformations:
        # * strip spaces
        # * space,":" with "_"
        s = str_in.strip()
        s = s.replace(" ", "_")
        s = s.replace(":", "_")
        return s

    # codegen model management
    def add_generic(self, name, value, description="", **kwargs):
        """
        Add a generic to the model - with VHDL type formatting. 
        """
        g = noc_codegen_base.add_generic(self, name, value, description, **kwargs)
        # Set correct type. String by default
        gadd = {"type": "string"}
        if "type" in kwargs:
            # Optional type must be a string with a custom type name.
            if isinstance(kwargs["type"], str):
                # custom type name. 
                gadd.update({"type": kwargs["type"]})
            #else:
                # default to use string
        else:
            gadd["type"] = self.calculate_type(value)
            ## use type in value
            #gadd["type"] = _pytovhdltype[type(value)]
            ## defined range
            #if "type_array" in kwargs:
                #if isinstance(value, int):
                    ## for an integer it means range
                    #gadd["type"] += " range %d to %d" % (kwargs["type_array"][0], kwargs["type_array"][1])
                #elif isinstance(value, intbv):
                    ## for a intbv it means bit boundaries
                    #gadd["type"] += "_vector(%d to %d)" % (kwargs["type_array"][0], kwargs["type_array"][1])
                ##else:
                    ## ignore array range
            #else:
                ## special case
                #if isinstance(value, intbv):
                    ## put vector only if necessary
                    #if value._nrbits > 1:
                        ## extract vector information
                        #gadd["type_array"] = [0, value._nrbits - 1]
                        #gadd["type"] += "_vector(%d to %d)" % (0, value._nrbits - 1)

        g.update(gadd)
        return g
        
    def add_port(self, name, signal_desc=None, description="", **kwargs):
        """
        Add a port to the model - with VHDL type formatting. 
        """
        p = noc_codegen_base.add_port(self, name, signal_desc, description, **kwargs)
        if signal_desc is None:
            # nothing else to do
            return p
        # set correct type for the particular signal_desc
        sig = filter(lambda x: x["name"] == signal_desc["name"], p["signal_list"])
        if len(sig) == 0:
            # strange error
            raise ValueError("Strange error: recently added signal '%s' to port '%s', but signal cannot be found." % (signal_desc["name"], p["name"]))
        else:
            sig = sig[0]
        # type inferring: only apply if signal_desc has empty type
        if sig["type"] != "":
            return p
        
        # integer by default
        sadd = {"type": "integer"}
        if "type" in kwargs:
            # Optional type must be a string with a custom type name.
            if isinstance(kwargs["type"], str):
                # custom type name. 
                sadd["type"] = kwargs["type"]
                # also add if it has default_value
                if "default_value" in kwargs:
                    sadd["default_value"] = kwargs["default_value"]
            #else:
                # default to use integer
        else:
            sadd["type"] = self.calculate_type(sig["default_value"])
            ## use type in value
            #sadd["type"] = _pytovhdltype[type(sig["default_value"])]
            ## defined range
            #if "type_array" in kwargs:
                #if isinstance(sig["default_value"], int):
                    #sadd["type"] += " range(%d to %d)" % (kwargs["type_array"][0], kwargs["type_array"][1])
                #elif isinstance(sig["default_value"], intbv):
                    #sadd["type"] += "_vector(%d downto %d)" % (kwargs["type_array"][1], kwargs["type_array"][0])
                ##else:
                    ## ignore array range
            #else:
                ## special case
                #if isinstance(sig["default_value"], intbv):
                    ## put vector only if necessary
                    #if sig["default_value"]._nrbits > 1:
                        ## extract vector information
                        #sadd["type_array"] = [0, sig["default_value"]._nrbits - 1]
                        #sadd["type"] += "_vector(%d downto 0)" % (sig["default_value"]._nrbits - 1)
        sig.update(sadd)
        return p
        
    def add_external_signal(self, name, direction, value, description="", **kwargs):
        """
        Add a external signal to the model - with VHDL type formatting. 
        """
        sig = noc_codegen_base.add_external_signal(self, name, direction, value, description, **kwargs)
        # Set correct type. integer by default
        sadd = {"type": "integer"}
        if "type" in kwargs:
            # Optional type must be a string with a custom type name.
            if isinstance(kwargs["type"], str):
                # custom type name. 
                sadd.update({"type": kwargs["type"]})
            #else:
                # default to use integer
        else:
            sadd["type"] = self.calculate_type(value)
            ## use type in value
            #sadd["type"] = _pytovhdltype[type(value)]
            ## defined range
            #if "type_array" in kwargs:
                #if isinstance(value, int):
                    #sadd["type"] += " range(%d to %d)" % (kwargs["type_array"][0], kwargs["type_array"][1])
                #elif isinstance(value, intbv):
                    #sadd["type"] += "_vector(%d to %d)" % (kwargs["type_array"][0], kwargs["type_array"][1])
                ##else:
                    ## ignore array range
            #else:
                ## special case
                #if isinstance(value, intbv):
                    ## extract vector information
                    #sadd["type_array"] = [0, sig["default_value"]._nrbits - 1]
                    #if None not in sadd["type_array"]:
                        #sadd["type"] += "_vector(%d to %d)" % (0, sig["default_value"]._nrbits - 1)
        sig.update(sadd)
        return sig
      
    # particular VHDL methods
    def generate_entity_section(self):
        """
        Generate entity section
        """
        sret = "entity %s is\n" % self.modulename
        stmp = self.generate_generics_section()
        if stmp != "":
            sret += self.add_tab(stmp) + ";\n"
        stmp = self.generate_ports_section()
        if stmp != "":
            sret += self.add_tab(stmp) + ";\n"
        sret += "end %s;\n" % self.modulename
        return sret
        
    def generate_architecture_section(self, archname="rtl"):
        """
        Generate architecture section
        """
        sret = "architecture %s of %s is\n" % (archname, self.modulename)
        if self.implementation != "":
            sret += self.add_tab(self.implementation)
        sret += "\nend %s;\n" % archname
        return sret

    def generate_generics_section(self):
        """
        Generate generics section used on entity and component
        """
        sret = "generic (\n"
        l = self.generate_generic_declaration(None, True)
        if len(l) > 0:
            l = self.add_tab(l)
            sret += ";\n".join(l)
            sret += "\n)"
        else:
            # empty generics section
            sret = ""
        return sret
        
    def generate_ports_section(self):
        """
        Generate ports section used on entity and component
        """
        # first ports and then external signals
        sret = "port (\n"
        l = self.generate_port_declaration(None, False)
        l.extend(self.generate_signal_declaration(None, None, False))
        if len(l) > 0:
            l = self.add_tab(l)
            sret += ";\n".join(l)
            sret += "\n)"
        else:
            # empty ports section
            sret = ""
        return sret
        
    def calculate_type(self, object, with_default=False):
        """
        Calculate the correct VHDL type for a particular object
        
        Arguments:
        * object:
        * with_default: True to add a default value at the end
        Returns:
        A string with the VHDL equivalent type
        """
        if isinstance(object, bool):
            return "std_logic"
        elif isinstance(object, (int, long)):
            # CHECK if this is a correct type translation
            return "integer"
        elif isinstance(object, str):
            return "string"
        elif isinstance(object, myhdl.intbv):
            width = object._nrbits
            initval = object._val
        elif isinstance(object, myhdl.SignalType):
            width = object._nrbits
            initval = object._init
        else:
            raise ValueError("Type conversion for object %s not found (type: %s)" % (repr(object), type(object)))
        if width <= 0:
            raise ValueError("Object %s don't have a valid bit width." % repr(object))
        if width == 1:
            retval = "std_logic"
            defval = "'%d'" % int(initval)
        else:
            retval = "unsigned(%s downto 0)" % (width - 1)
            defval = '"%s"' % myhdl.bin(initval, width)
        if with_default:
            return "%s := %s" % (retval, defval)
        else:
            return retval
        
# helper functions
def add_codegen_vhdl_support(instance, **kwargs):
    """
    This function will add for every object in instance a noc_codegen object
    """
    if isinstance(instance, noc):
        # add code generation object
        instance.codegen = noc_codegen_vhdl(instance, **kwargs)
        # and add cg objects recursively
        for obj in instance.all_list(True):
            add_codegen_vhdl_support(obj, **kwargs)
    elif isinstance(instance, (ipcore, router, channel)):
        instance.codegen = noc_codegen_vhdl(instance, **kwargs)
    else:
        raise TypeError("Unsupported object: type %s" % type(instance))
        
def convert_value(data, custom_type=None, type_array=[None, None]):
    """
    This function converts data to a string valid in VHDL syntax.
    """
    retval = ""
    numbits = 0
    usedata = data
    if custom_type is not None:
        # custom type
        if custom_type == int:
            usedata = int(data)
        elif custom_type == bool:
            usedata = data == True
        elif custom_type == intbv:
            # need fixed boundaries. Use type_array
            if type_array == [None, None]:
                # default: one bit width
                usedata = intbv(data)[1:]
            else:
                # intbv boundaries refer to bit width
                usedata = intbv(data)[type_array[1]+1:type_array[0]]
        elif custom_type == str:
            usedata = str(data)
        elif isinstance(custom_type, str):
            # type in a string format
            if custom_type == "integer":
                usedata = int(data)
            elif custom_type == "std_logic":
                usedata = intbv(data)[1:]
            elif custom_type == "string":
                usedata = str(data)
            elif custom_type.find("std_logic_vector") == 0:
                # strip values
                vecinfo = custom_type.replace("std_logic_vector", "").strip("()").split()
                if vecinfo[1] == "to":
                    vecmin = int(vecinfo[0])
                    vecmax = int(vecinfo[2])
                elif vecinfo[1] == "downto":
                    vecmin = int(vecinfo[2])
                    vecmax = int(vecinfo[0])
                usedata = intbv(data)[vecmax+1:vecmin]
            else:
                raise TypeError("Unsupported custom type string '%s' for VHDL conversion." % custom_type)
        else:
            raise TypeError("Unsupported custom type '%s' for VHDL conversion." % type(custom_type))
    # convert
    if isinstance(usedata, int):
        retval = "%d" % data
    elif isinstance(usedata, bool):
        retval = "'%d'" % int(data)
    elif isinstance(usedata, intbv):
        # check boundaries
        if usedata._nrbits > 1:
            # print vector in bits
            retval = '"%s"' % bin(usedata, usedata._nrbits)
        else:
            retval = "'%d'" % usedata
    elif isinstance(usedata, str):
        retval = '"%s"' % usedata
    else:
        raise TypeError("Unsupported type '%s' for VHDL conversion." % type(usedata))
    return retval

# helper structures:
# type conversions
_pytovhdltype = {
    "bool": "std_logic", 
    "int": "integer", 
    "intbv" : "unsigned", 
    "str" : "string", 
    bool: "std_logic", 
    int: "integer", 
    intbv : "unsigned", 
    str : "string"
    }
_pytovhdlzeroval = {
    "bool": "False", 
    "int": "0", 
    "intbv" : '"0"', 
    "str" : '""', 
    bool: "False", 
    int: "0", 
    intbv : '"0"', 
    str : '""'
    }    
    
