#! /usr/bin/env python2.6
# -*- mode: python; coding: utf-8; -*-
import os, sys, shelve, shutil
from os.path import join
from config.projpaths import *
from config.configuration import *
from scripts.baremetal.baremetal_generator import *
from scripts.kernel.generate_kernel_cinfo import *
from scripts.cml.generate_container_cml import *
from optparse import OptionParser

#
# Rarely required. Only required when:
# The number of containers defined in the ruleset are not enough.
# E.g. you want 16 containers instead of 4.
# You want to start from scratch and set _all_ the parameters yourself.
#
def autogen_rules_file(options, args):
    # Prepare default if arch not supplied
    if not options.arch:
        print "No arch supplied (-a), using `arm' as default."
        options.arch = "or1k"

    # Prepare default if number of containers not supplied
    if not options.ncont:
        options.ncont = 4
        print "Max container count not supplied (-n), using %d as default." % options.ncont

    return generate_container_cml(options.arch, options.ncont)


def cml2_header_to_symbols(cml2_header, config):
    with file(cml2_header) as header_file:
        for line in header_file:
            pair = config.line_to_name_value(line)
            if pair is not None:
                name, value = pair
                config.get_all(name, value)
                config.get_cpu(name, value)
                config.get_arch(name, value)
                config.get_subarch(name, value)
                config.get_platform(name, value)
                config.get_ncpu(name, value)
                config.get_ncontainers(name, value)
                config.get_container_parameters(name, value)
                config.get_toolchain(name, value)

def cml2_update_config_h(config_h_path, config):
    with open(config_h_path, "a") as config_h:
        config_h.write("#define __ARCH__ " + config.arch + '\n')
        config_h.write("#define __PLATFORM__ " + config.platform + '\n')
        config_h.write("#define __SUBARCH__ " + config.subarch + '\n')
        config_h.write("#define __CPU__ " + config.cpu + '\n')

def configure_kernel(cml_file):
    config = configuration()

    if not os.path.exists(BUILDDIR):
        os.mkdir(BUILDDIR)

    cml2_configure(cml_file)



# Parse options + autogenerate cml rule file if necessary.
def build_parse_options():
    autogen_true = 0
    usage = "usage: %prog [options] arg"
    parser = OptionParser(usage)

    parser.add_option("-a", "--arch", type = "string", dest = "arch",
                      help = "Use configuration file for architecture")
    parser.add_option("-n", "--num-containers", type = "int", dest = "ncont",
                      help = "Maximum number of containers that will be "
                             "made available in configuration")
    parser.add_option("-c", "--configure-first", action = "store_true", dest = "config",
                      help = "Tells the build script to run configurator first")
    parser.add_option("-f", "--use-file", dest = "cml_file",
                      help = "Supply user-defined cml file "
                             "(Use only if you want to override default)")
    parser.add_option("-r", "--reset-config", action = "store_true",
                      default = False, dest = "reset_config",
                      help = "Reset configuration file settings "
                             "(If you had configured before and changing the "
                             "rule file, this will reset existing values to default)")
    parser.add_option("-s", "--save-old-config", action = "store_true",
                      default = False, dest = "backup_config",
                      help = "Backs up old configuration file settings to a .saved file"
                             "(Subsequent calls would overwrite. Only meaningful with -r)")
    parser.add_option("-p", "--print-config", action = "store_true",
                      default = False, dest = "print_config",
                      help = "Prints out configuration settings"
                             "(Symbol values and container parameters are printed)")
    parser.add_option("-q", "--quite", action="store_true", dest="quite", default = False,
                      help = "Enable quite mode"
                             "(will not be presented with a configuration screen)")


    (options, args) = parser.parse_args()

    if options.cml_file and options.reset_config:
        parser.error("options -f and -r are mutually exclusive")
        exit()

    # -f or -r or -n or -a implies -c
    if options.cml_file or options.ncont or options.arch or options.reset_config \
       or not os.path.exists(BUILDDIR) or not os.path.exists(CONFIG_SHELVE_DIR):
        options.config = 1

    return options, args


def configure_system(options, args):
    #
    # Configure only if we are told to do so.
    #
    if not options.config:
        return

    if not os.path.exists(BUILDDIR):
        os.mkdir(BUILDDIR)

    #
    # If we have an existing config file or one supplied in options
    # and we're not forced to autogenerate, we use the config file.
    #
    # Otherwise we autogenerate a ruleset and compile it, and create
    # a configuration file from it from scratch.
    #
    if (options.cml_file or os.path.exists(CML2_CONFIG_FILE)) \
            and not options.reset_config:
        if options.cml_file:
            cml2_config_file = options.cml_file
        else:
            cml2_config_file = CML2_CONFIG_FILE

        #
        # If we have a valid config file but not a rules file,
        # we still need to autogenerate the rules file.
        #
        if not os.path.exists(CML2_COMPILED_RULES):
            rules_file = autogen_rules_file(options, args)

            # Compile rules file.
            os.system(CML2TOOLSDIR + '/cmlcompile.py -o ' + \
                      CML2_COMPILED_RULES + ' ' + rules_file)

        #
        # If there was an existing config file in default cml path
        # and -s was supplied, save it.
        #
        if os.path.exists(CML2_CONFIG_FILE) and options.backup_config:
            shutil.copy(CML2_CONFIG_FILE, CML2_CONFIG_FILE_SAVED)

        if options.quite:
                # Create configuration from existing file
                os.system(CML2TOOLSDIR + '/cmlconfigure.py -b -o ' + \
                        CML2_CONFIG_FILE + ' -i ' + cml2_config_file + \
                        ' ' + CML2_COMPILED_RULES)
        else:
                # Create configuration from existing file
                os.system(CML2TOOLSDIR + '/cmlconfigure.py -c -o ' + \
                        CML2_CONFIG_FILE + ' -i ' + cml2_config_file + \
                        ' ' + CML2_COMPILED_RULES)

    else:
        rules_file = autogen_rules_file(options, args)

        # Compile rules file.
        os.system(CML2TOOLSDIR + '/cmlcompile.py -o ' + \
                  CML2_COMPILED_RULES + ' ' + rules_file)

        # Create configuration from scratch
        os.system(CML2TOOLSDIR + '/cmlconfigure.py -c -o ' + \
                  CML2_CONFIG_FILE + ' ' + CML2_COMPILED_RULES)

    # After configure, if user might have chosen to quit without saving
    if not os.path.exists(CML2_CONFIG_FILE):
        print "Exiting without saving configuration."
        sys.exit()

    # Create header file
    os.system(TOOLSDIR + '/cml2header.py -o ' + \
              CML2_CONFIG_H + ' -i ' + CML2_CONFIG_FILE)

    # The rest:
    if not os.path.exists(os.path.dirname(CONFIG_H)):
        os.mkdir(os.path.dirname(CONFIG_H))

    shutil.copy(CML2_CONFIG_H, CONFIG_H)

    config = configuration()
    cml2_header_to_symbols(CML2_CONFIG_H, config)
    cml2_update_config_h(CONFIG_H, config)

    configuration_save(config)

    # Generate baremetal container files if new ones defined
    baremetal_cont_gen = BaremetalContGenerator()
    baremetal_cont_gen.baremetal_container_generate(config)

   # Print out the configuration if asked
    if options.print_config:
        config.config_print()

    return config

# Generate kernel cinfo structure for container definitions
def generate_cinfo():
    config = configuration_retrieve()
    generate_kernel_cinfo(config, KERNEL_CINFO_PATH)

if __name__ == "__main__":
    opts, args = build_parse_options()

    # We force configuration when calling this script
    # whereas build.py can provide it as an option
    opts.config = 1

    configure_system(opts, args)
