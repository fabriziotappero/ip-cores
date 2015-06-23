/* adv_jtag_bridge.c -- JTAG protocol bridge between GDB and Advanced debug module.
   Copyright(C) 2001 Marko Mlinar, markom@opencores.org
   Code for TCP/IP copied from gdb, by Chris Ziomkowski
   Refactoring by Nathan Yawn <nyawn@opencores.org> (C) 2008 - 2010

   This file was part of the OpenRISC 1000 Architectural Simulator.
   It is now also used to connect GDB to a running hardware OpenCores / OR1200
   advanced debug unit.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

/* Establishes jtag proxy server and communicates with parallel
   port directly.  Requires root access. */

#include <stdio.h>
#include <stdlib.h>  // for exit(), atoi(), strtoul()
#include <unistd.h>
#include <stdarg.h>
#include <string.h>  // for strstr()
#include <sys/types.h>


#include "adv_jtag_bridge.h"
#include "rsp-server.h"
#include "chain_commands.h"
#include "cable_common.h"
#include "or32_selftest.h"
#include "bsdl.h"
#include "errcodes.h"
#include "hardware_monitor.h"
#include "jsp_server.h"
#include "hwp_server.h"

#define debug(...) //fprintf(stderr, __VA_ARGS__ )

// How many command-line IR length settings to create by default
#define IR_START_SETS 16

//////////////////////////////////////////////////
// Command line option flags / values

/* Which device in the scan chain we want to target.
 * 0 is the first device we find, which is nearest the data input of the cable.
 */
unsigned int target_dev_pos = 0;

// Do test before setting up server?
unsigned char do_selftest = 0;

// IR register length in TAP of 
// Can override autoprobe, or set if IDCODE not supported
typedef struct {
  int dev_index;
  int ir_length;
} irset;

#define START_IR_SETS 16
int reallocs = 0;
int num_ir_sets = 0;
irset * cmd_line_ir_sizes = NULL;

// DEBUG command for target device TAP
// May actually be USER1, for Xilinx devices using internal BSCAN modules
// Can override autoprobe, or set if unable to find in BSDL files
int cmd_line_cmd_debug = -1;  // 0 is a valid debug command, so use -1

// TCP port to set up the server for GDB on
char *port = NULL;
char default_port[] = "9999";

#ifdef ENABLE_JSP
char *jspport = NULL;
char default_jspport[] = "9944";
#endif

char *hwpport = NULL;
char default_hwpport[] = "9928";

// Force altera virtual jtag mode on(1) or off(-1)
int force_alt_vjtag = 0;


// Pointer to the command line arg used as the cable name
char * cable_name = NULL;

////////////////////////////////////////////////////////
// List of IDCODES of devices on the JTAG scan chain
// The array is dynamically allocated in chain_commands/jtag_enumerate_chain()

uint32_t *idcodes = NULL;
int num_devices = 0;


const char *name_not_found = "(unknown)";

///////////////////////////////////////////////////////////
// JTAG constants

// Defines for Altera JTAG constants
#define ALTERA_MANUFACTURER_ID   0x6E

// Defines for Xilinx JTAG constants
#define XILINX_MANUFACTURER_ID   0x49


///////////////////////////////////////////////////
// Prototypes for local / helper functions
int get_IR_size(int devidx);
uint32_t get_debug_cmd(int devidx);
void configure_chain(void);
void print_usage(char *func);
void parse_args(int argc, char **argv);
void get_ir_opts(char *optstr, int *idx, int *val);


//////////////////////////////////////////////////////////////////////////////////////
/*----------------------------------------------------------------------------------*/
// Functions
/////////////////////////////////////////////////////////////////////////////////////

// Resets JTAG, and sets up DEBUG scan chain
void configure_chain(void)
{
  int i;
  unsigned int manuf_id;
  uint32_t cmd;
  const char *name;
  int irlen;
  int err = APP_ERR_NONE;

  err |= tap_reset();
  err |= jtag_enumerate_chain(&idcodes, &num_devices);

  if(err != APP_ERR_NONE) {
    printf("Error %s enumerating JTAG chain, aborting.\n", get_err_string(err));
    exit(1);
  }

  printf("\nDevices on JTAG chain:\n");
  printf("Index\tName\t\tID Code\t\tIR Length\n");
  printf("----------------------------------------------------------------\n");
  for(i = 0; i < num_devices; i++)
    {
      if(idcodes[i] != IDCODE_INVALID) {
	name = bsdl_get_name(idcodes[i]);
	irlen = bsdl_get_IR_size(idcodes[i]);
	if(name == NULL)
	  name = name_not_found;
      } else {
	name = name_not_found;
	irlen = -1;
      }
      printf("%d: \t%s \t0x%08X \t%d\n", i, name, idcodes[i], irlen);
    }
  printf("\n");

#ifdef __LEGACY__
// The legacy debug interface cannot support multi-device chains.  If there is more than
// one device on this chain, pull the cord.
if(num_devices > 1) {
	fprintf(stderr, "\n*** ERROR: The legacy debug hardware cannot support JTAG chains with\n");
	fprintf(stderr, "*** more than one device.  Reconnect the JTAG cable to ONLY the legacy\n");
	fprintf(stderr, "*** debug unit, or change your SoC to use the Advanced Debug Unit.\n");
	exit(0);
}
#endif


  if(target_dev_pos >= num_devices) {
    printf("ERROR:  Requested target device (%i) beyond highest device index (%i).\n", target_dev_pos, num_devices-1);
    exit(1);
  } else {
    printf("Target device %i, JTAG ID = 0x%08x\n", target_dev_pos, idcodes[target_dev_pos]);
  }

  manuf_id = (idcodes[target_dev_pos] >> 1) & 0x7FF;

  // Use BSDL files to determine prefix bits, postfix bits, debug command, IR length
  config_set_IR_size(get_IR_size(target_dev_pos));

  // Set the IR prefix / postfix bits
  int total = 0;
  for(i = 0; i < num_devices; i++) {
    if(i == target_dev_pos) {
      config_set_IR_postfix_bits(total);
      //debug("Postfix bits: %d\n", total);
      total = 0;
      continue;
    }
    
    total += get_IR_size(i);
    debug("Adding %i to total for devidx %i\n", get_IR_size(i), i);
  }
  config_set_IR_prefix_bits(total);
  debug("Prefix bits: %d\n", total);


  // Note that there's a little translation here, since device index 0 is actually closest to the cable data input
  config_set_DR_prefix_bits(num_devices - target_dev_pos - 1);  // number of devices between cable data out and target device
  config_set_DR_postfix_bits(target_dev_pos);  // number of devices between target device and cable data in

  // Set the DEBUG command for the IR of the target device.
  // If this is a Xilinx device, use USER1 instead of DEBUG
  // If we Altera Virtual JTAG mode, we don't care.
  if((force_alt_vjtag == -1) || ((force_alt_vjtag == 0) &&  (manuf_id != ALTERA_MANUFACTURER_ID))) {
    cmd = get_debug_cmd(target_dev_pos);
    if(cmd == TAP_CMD_INVALID) {
      printf("Unable to find DEBUG command, aborting.\n");
      exit(1);
    }
    config_set_debug_cmd(cmd);  // This may have to be USER1 if this is a Xilinx device   
  }

  // Enable the kludge for Xilinx BSCAN, if necessary.
  // Safe, but slower, for non-BSCAN TAPs.
  if(manuf_id == XILINX_MANUFACTURER_ID) {
    config_set_xilinx_bscan(1);
  }
 
  // Set Altera Virtual JTAG mode on or off.  If not forced, then enable
  // if the target device has an Altera manufacturer IDCODE
  if(force_alt_vjtag == 1) {
    config_set_alt_vjtag(1);
  } else if(force_alt_vjtag == -1) {
    config_set_alt_vjtag(0);
  } else {
    if(manuf_id == ALTERA_MANUFACTURER_ID) {
      config_set_alt_vjtag(1);
    } else {
      config_set_alt_vjtag(0);
    }
  }
  
  // Do a sanity test
  cmd = bsdl_get_idcode_cmd(idcodes[target_dev_pos]);
  if(cmd != TAP_CMD_INVALID) {
       uint32_t id_read;
       err |= jtag_get_idcode(cmd, &id_read);

       if(err != APP_ERR_NONE) {
	 printf("Error %s checking IDCODE, aborting.\n", get_err_string(err));
	 exit(1);
       }

       if(id_read == idcodes[target_dev_pos]) {
	 printf("IDCODE sanity test passed, chain OK!\n");
       } else {
	 printf("Warning: IDCODE sanity test failed.  Read IDCODE 0x%08X, expected 0x%08X\n", id_read, idcodes[target_dev_pos]);
       }
     }

  if(err |= tap_enable_debug_module()) {  // Select the debug unit in the TAP.
    printf("Error %s enabling debug module, aborting.\n", get_err_string(err));
    exit(1);
  }
}


void print_usage(char *func)
{
  printf("JTAG connection between GDB and the SoC debug interface.\n");
#ifdef __LEGACY__
  printf("Compiled with support for the Legacy debug unit (debug_if).\n");
#else
  printf("Compiled with support for the Advanced Debug Interface (adv_dbg_if).\n");
#endif
#ifdef ENABLE_JSP
  printf("Compiled with support for the JTAG Serial Port (JSP).\n");
#else
  printf("Support for the JTAG serial port is NOT compiled in.\n");
#endif
  printf("Copyright (C) 2011 Nathan Yawn, nathan.yawn@opencores.org\n\n");
  printf("Usage: %s (options) [cable] (cable options)\n", func);
  printf("Options:\n");
  printf("\t-g [port]     : port number for GDB (default: %s)\n", default_port);
#ifdef ENABLE_JSP
  printf("\t-j [port]     : port number for JSP Server (default: %s)\n", default_jspport);
#endif
  printf("\t-w [port]     : port number for HWP server (default: %s)\n", default_hwpport);
  printf("\t-x [index]    : Position of the target device in the scan chain\n");
  printf("\t-a [0 / 1]    : force Altera virtual JTAG mode off (0) or on (1)\n");
  printf("\t-l [<index>:<bits>]     : Specify length of IR register for device\n");
  printf("\t                <index>, override autodetect (if any)\n");
  printf("\t-c [hex cmd]  : Debug command for target TAP, override autodetect\n");
  printf("\t                (ignored for Altera targets)\n");
  printf("\t-v [hex cmd]  : VIR command for target TAP, override autodetect\n");
  printf("\t                (Altera virtual JTAG targets only)\n");
  printf("\t-r [hex cmd]  : VDR for target TAP, override autodetect\n");
  printf("\t                (Altera virtual JTAG targets only)\n");
  printf("\t-b [dirname]  : Add a directory to search for BSDL files\n");
  printf("\t-t            : perform CPU / memory self-test before starting server\n");
  printf("\t-h            : show help\n\n");
  cable_print_help();
}


void parse_args(int argc, char **argv)
{
  int c;
  int i;
  int idx, val;
  const char *valid_cable_args = NULL;
  port = NULL;
#ifdef ENABLE_JSP
  jspport = NULL;
#endif
  force_alt_vjtag = 0;
  cmd_line_cmd_debug = -1;

  /* Parse the global arguments (if-any) */
  while((c = getopt(argc, argv, "+g:j:w:x:a:l:c:v:r:b:th")) != -1) {
    switch(c) {
    case 'h':
      print_usage(argv[0]);
      exit(0);
      break;
    case 'g':
      port = optarg;
      break;
#ifdef ENABLE_JSP
    case 'j':
      jspport = optarg;
      break;
#endif
    case 'w':
      hwpport = optarg;
      break;
    case 'x':
      target_dev_pos = atoi(optarg);
      break;
    case 'l':
      get_ir_opts(optarg, &idx, &val);        // parse the option
      if(num_ir_sets >= (IR_START_SETS<<reallocs)) {
	cmd_line_ir_sizes = (irset *) realloc(cmd_line_ir_sizes, (IR_START_SETS<<(++reallocs))*sizeof(irset));
	if(cmd_line_ir_sizes == NULL) {
	  printf("Error: out of memory while parsing command line.  Aborting.\n");
	  exit(1);
	}
      }
      cmd_line_ir_sizes[num_ir_sets].dev_index = idx;
      cmd_line_ir_sizes[num_ir_sets].ir_length = val;
      num_ir_sets++;
      break;
    case 'c':
      cmd_line_cmd_debug = strtoul(optarg, NULL, 16);
      break;
    case 'v':
      config_set_vjtag_cmd_vir(strtoul(optarg, NULL, 16));
      break;
    case 'r':
      config_set_vjtag_cmd_vdr(strtoul(optarg, NULL, 16));
      break;
    case 't':
      do_selftest = 1;
      break;
     case 'a': 
       if(atoi(optarg) == 1) 
 	force_alt_vjtag = 1; 
       else 
 	force_alt_vjtag = -1; 
       break;
    case 'b':
       bsdl_add_directory(optarg);
      break;
    default:
      print_usage(argv[0]);
      exit(1);
    }
  }

  if(port == NULL)
    port = default_port;
  
#ifdef ENABLE_JSP
  if(jspport == NULL)
    jspport = default_jspport;
#endif

  if(hwpport == NULL)
    hwpport = default_hwpport;

  int found_cable = 0;
  char* start_str = argv[optind];
  int start_idx = optind;
  for(i = optind; i < argc; i++) {
    if(cable_select(argv[i]) == APP_ERR_NONE) {
      found_cable = 1;
      cable_name = argv[i];
      argv[optind] = argv[start_idx];  // swap the cable name with the other arg,
      argv[start_idx] = start_str;     // keep all cable opts at the end
      break;
    }
  }
  

  if(!found_cable) {
    fprintf(stderr, "Error: No valid cable specified.\n");
    print_usage(argv[0]);
    exit(1);
  }
  
  optind = start_idx+1;  // reset the parse index

    /* Get the cable-arguments */
  valid_cable_args = cable_get_args();

  /* Parse the remaining options for the cable.
   * Note that this will include unrecognized option from before the cable name.
   */
  while((c = getopt(argc, argv, valid_cable_args)) != -1) {
    //printf("Got cable opt %c (0x%X)\n", (char)c, c);
    if(c == '?') {
      printf("\nERROR:  Unknown cable option \'-%c\'\n\n", optopt);
      print_usage(argv[0]);
      exit(1);
    }
    else if(cable_parse_opt(c, optarg) != APP_ERR_NONE) {
      printf("\nERROR:  Failed to parse cable option \'-%c\' %s\n\n", (char)c, optarg);
      print_usage(argv[0]);
      exit(1);
    }
  }
}



int main(int argc,  char *argv[]) {
  char *s;
  long int serverPort;

  srand(getpid());
  bsdl_init();
  cmd_line_ir_sizes = (irset *) malloc(IR_START_SETS * sizeof(irset));
  if(cmd_line_ir_sizes == NULL) {
    printf("ERROR: out of memory allocating array for IR sizes.\n");
    return 1;
  }

  cable_setup();

  parse_args(argc, argv);

  if(cable_init() != APP_ERR_NONE) {
    printf("Failed to initialize cable \'%s\', aborting.\n", cable_name);
    exit(1);
  }


  /* Initialize a new connection to the or1k board, and make sure we are
     really connected.  */
  configure_chain();

  if(do_selftest) {
    // Test the connection.
    printf("*** Doing self-test ***\n");
    if(dbg_test() != APP_ERR_NONE) {
      printf("Self-test FAILED *** Bailing out!\n");
      exit(1);
    }
    printf("*** Self-test PASSED ***\n");
  }
    
  /* We have a connection.  Establish server.  */
  serverPort = strtol(port,&s,10);
  if(*s) {
    printf("Failed to get RSP server port \'%s\', using default \'%s\'.\n", port, default_port);
    serverPort = strtol(default_port,&s,10);
    if(*s) {
      printf("Failed to get RSP default port, exiting.\n");
      return -1;
    }
  }

  // Start the thread which handle CPU stall/unstall
  start_monitor_thread();

  rsp_init(serverPort);

#ifdef ENABLE_JSP
  long int jspserverport;
  jspserverport = strtol(jspport,&s,10);
  if(*s) {
    printf("Failed to get JSP server port \'%s\', using default \'%s\'.\n", jspport, default_jspport);
    serverPort = strtol(default_jspport,&s,10);
    if(*s) {
      printf("Failed to get default JSP port, exiting.\n");
      return -1;
    }
  }

  jsp_init(jspserverport);
  jsp_server_start();
#endif

  long int hwpserverport;
  hwpserverport = strtol(hwpport,&s,10);
  if(*s) {
    printf("Failed to get HWP server port \'%s\', using default \'%s\'.\n", hwpport, default_hwpport);
    serverPort = strtol(default_hwpport,&s,10);
    if(*s) {
      printf("Failed to get default HWP port, exiting.\n");
      return -1;
    }
  }

  if(hwp_init(hwpserverport))
    {
      // Only start the server if the init succeeded
      hwp_server_start();
    }

  printf("JTAG bridge ready!\n");

  // This handles requests from GDB.  I'd prefer the while() loop to be in the function
  // with the select()/poll(), but the or1ksim rsp code (ported for use here) doesn't work 
  // that way, and I don't want to rework that code (to make it easier to import fixes
  // written for the or1ksim rsp server).  --NAY
  while(handle_rsp());

  return 0;
}

//////////////////////////////////////////////////
// Helper functions

int get_IR_size(int devidx)
{
  int retval = -1;
  int i;
  
  if(idcodes[devidx] != IDCODE_INVALID) {
    retval = bsdl_get_IR_size(idcodes[devidx]);
  }
 
  // Search for this devices in the array of command line IR sizes
  for(i = 0; i < num_ir_sets; i++) {
    if(cmd_line_ir_sizes[i].dev_index == devidx) {
      if((retval > 0) && (retval != cmd_line_ir_sizes[i].ir_length)) 
	printf("Warning: overriding autoprobed IR length (%i) with command line value (%i) for device %i\n", retval, 
			    cmd_line_ir_sizes[i].ir_length, devidx);
      retval = cmd_line_ir_sizes[i].ir_length;
    }
  }

  if(retval < 0) {  // Make sure we have a value
    printf("ERROR! Unable to autoprobe IR length for device index %i;  Must set IR size on command line. Aborting.\n", devidx);
    exit(1);
  }

  return retval;
}


uint32_t get_debug_cmd(int devidx)
{
  int retval = TAP_CMD_INVALID;
  uint32_t manuf_id = (idcodes[devidx] >> 1) & 0x7FF;

  if(idcodes[devidx] != IDCODE_INVALID) {
    if(manuf_id == XILINX_MANUFACTURER_ID) {
      retval = bsdl_get_user1_cmd(idcodes[devidx]);
      if(cmd_line_cmd_debug < 0) printf("Xilinx IDCODE, assuming internal BSCAN mode\n\t(using USER1 instead of DEBUG TAP command)\n");
    } else {
      retval = bsdl_get_debug_cmd(idcodes[devidx]);
    }
  } 

  if(cmd_line_cmd_debug >= 0) {
    if(retval != TAP_CMD_INVALID) {
      printf("Warning: overriding autoprobe debug command (0x%X) with command line value (0x%X)\n", retval, cmd_line_cmd_debug);
    } else {
      printf("Using command-line debug command 0x%X\n", cmd_line_cmd_debug);
    }
    retval = cmd_line_cmd_debug;
  }

  if(retval == TAP_CMD_INVALID) {
    printf("ERROR!  Unable to find DEBUG command for device index %i, device ID 0x%0X\n", devidx, idcodes[devidx]);
  }

  return retval;
}


// Extracts two values from an option string
// of the form "<index>:<value>", where both args
// are in base 10
void get_ir_opts(char *optstr, int *idx, int *val)
{
  char *ptr;

  ptr = strstr(optstr, ":");
  if(ptr == NULL) {
    printf("Error: badly formatted IR length option.  Use format \'<index>:<value>\', without spaces, where both args are in base 10\n");
    exit(1);
  }

  *ptr = '\0';
  ptr++;  // This now points to the second (value) arg string

  *idx = strtoul(optstr, NULL, 10);
  *val = strtoul(ptr, NULL, 10);
  // ***CHECK FOR SUCCESS
}

