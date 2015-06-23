/*
 * Author: Lasse Lehtonen
 *
 * Constants for SAD HIBI testbench
 * 
 *
 * $Id: constants.hh 1488 2010-12-03 13:06:04Z lehton87 $
 *
 */

#ifndef SAD_HIBI_CONSTANTS_HH
#define SAD_HIBI_CONSTANTS_HH

#include <string>
using namespace std; // hyi

#include <systemc>
using namespace sc_core; // Hyi hyi
using namespace sc_dt;   // No häpy at all


/*
 * Constants: Generics (passed to the VHDL DUV)
 */

const int id_width_c          = 8;
const int addr_width_c        = 16;

#ifndef HIBI_IN_SAD_MODE // Normal mode

const int data_width_c        = 32; 
const int separate_addr_c     = 0;

#else // Separate address bus

#ifdef USE_R3_WRAPPERS
const int data_width_c        = 32; 
const int separate_addr_c     = 1;
#else
const int data_width_c        = addr_width_c + 32; 
const int separate_addr_c     = 1;
#endif

#endif

const int comm_width_c        = 5;
const int counter_width_c     = 16;

const int agent_freq_c        = 100;   // In MHz
const int bus_freq_c          = 100;   // In MHz

const int rel_agent_freq_c    = 1;   
const int rel_bus_freq_c      = 1;    

const int arb_type_c          = 3;
const int fifo_sel_c          = 0;
const int rx_fifo_depth_c     = 4;
const int rx_msg_fifo_depth_c = 4;
const int tx_fifo_depth_c     = 4;
const int tx_msg_fifo_depth_c = 4;
const int max_send_c          = 10;

const int n_cfg_pages_c       = 1;
const int n_time_slots_c      = 0;
const int keep_slot_c         = 1;
const int n_extra_params_c    = 1;

const int cfg_re_c            = 1; 
const int cfg_we_c            = 1;
const int debug_width_c       = 1;

const int n_agents_c          = 12;
const int n_segments_c        = 3;   

/*
 * Constants: Base addresses 
 *
 * Make sure that these are same in TB's hibiv3.vhd!
 */

const sc_bv<addr_width_c> addresses_c[n_agents_c] =
  {0x00000010, 0x00000030, 0x00000050, 0x00000070,
   0x00000110, 0x00000130, 0x00000150, 0x00000170,
   0x00000310, 0x00000330, 0x00000350, 0x00000370};

const sc_bv<addr_width_c> addresses_max_c[n_agents_c] =
  {0x0000001F, 0x0000003F, 0x0000005F, 0x0000007F,
   0x0000011F, 0x0000013F, 0x0000015F, 0x0000017F,
   0x0000031F, 0x0000033F, 0x0000035F, 0x0000037F};

enum HibiCommand {IDLE = 0, 
		  NOT_USED_1,

		  DATA_WR,
		  MSG_WR,
		  DATA_RD,
		  MSG_RD,
		  DATA_RDL,
		  MSG_RDL,
		  DATA_WRNP,
		  MSG_WRNP,
		  DATA_WRC,
		  MSG_WRC,
		  
		  NOT_USED_2,
		  EXCL_LOCK,		  
		  NOT_USED_3,
		  EXCL_WR,
		  NOT_USED_4,		  
		  EXCL_RD,
		  NOT_USED_5,
		  EXCL_RELEASE,

		  NOT_USED_6,		  		  
		  CFG_WR,
		  NOT_USED_7,
		  CFG_RD,

		  NOT_USED_8,		  
		  NOT_USED_9,
		  NOT_USED_10,
		  NOT_USED_11,
		  NOT_USED_12,
		  NOT_USED_13,
		  NOT_USED_14,
		  NOT_USED_15
		  };

const sc_bv<comm_width_c> commands_c[32] = 
{0,  1,   2,  3,  4,  5,  6,  7, 
 8,  9,  10, 11, 12, 13, 14, 15,
 16, 17, 18, 19, 20, 21, 22, 23,
 24, 25, 26, 27, 28, 29, 30, 31};


string commmand2str(unsigned int cmd)
{
   switch(cmd)
   {
      case IDLE:
	 return string("IDLE        ");
      case DATA_WR:
	 return string("DATA_WR     ");
	 break;
      case DATA_RD:
	 return string("DATA_RD     ");
	 break;
      case DATA_RDL:
	 return string("DATA_RDL ¨  ");
	 break;
      case DATA_WRNP:
	 return string("DATA_WRNP   ");
	 break;
      case DATA_WRC:
	 return string("DATA_WRC    ");
	 break;

      case MSG_WR:
	 return string("MSG_WR      ");
	 break;
      case MSG_RD: 
	 return string("MSG_RD      ");
	 break;
      case MSG_RDL:
	 return string("MSG_RDL     ");
	 break;
      case MSG_WRNP:
	 return string("MSG_WRNP    ");
	 break;
      case MSG_WRC:
	 return string("MSG_WRC     ");
	 break;

      case EXCL_LOCK:
	 return string("EXCL_LOCK   ");
	 break;
      case EXCL_WR:
	 return string("EXCL_WR     ");
	 break;
      case EXCL_RD:
	 return string("EXCL_RD     ");
	 break;
      case EXCL_RELEASE:
	 return string("EXCL_RELEASE");
	 break;	 
	 

      case CFG_WR:
	 return string("CFG_WR      ");
	 break;
      case CFG_RD:
	 return string("CFG_RD      ");
	 break;	 

      default:
	 break;
   }
   return string("Not supported hibi command");
}

#endif

// Local Variables:
// mode: c++
// c-file-style: "ellemtel"
// c-basic-offset: 3
// End:

