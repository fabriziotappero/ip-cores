/*
 * Author: Lasse Lehtonen
 *
 * Top level containing all components for SAD hibi testbench:
 * hibi network's top-level, set of agents, and clk generation.
 *
 * $Id: top_level.hh 2002 2011-10-04 13:18:30Z ege $
 *
 */


#ifndef SAD_HIBI_TOPLEVEL_HH
#define SAD_HIBI_TOPLEVEL_HH

#include "constants.hh" // system size etc.
#include "agent.hh"     // stimulus + check
#include "hibiv3_r4.hh" // network toplevel
#include "hibiv3_r3.hh" // network toplevel

#include <sstream>
#include <vector>
using namespace std;

#include <systemc>
using namespace sc_core;
using namespace sc_dt;


class TopLevel : public sc_module
{
public:   
   
   SC_HAS_PROCESS(TopLevel);

   //* Constructor
   /* There are few #ifndefs in constructor because r3 and r4 
    * have different interface ports.
    */

   TopLevel(sc_module_name name)
      : sc_module(name),
	clk_ip("clk_ip", sc_core::sc_time(1000/agent_freq_c, sc_core::SC_NS)),
	clk_bus("clk_bus", sc_core::sc_time(1000/bus_freq_c, sc_core::SC_NS)),
	rst_n("rst_n"),
	b_comm_in("b_comm_in"),
	b_data_in("b_data_in"),
#ifndef USE_R3_WRAPPERS
	b_av_in("b_av_in"),
#else
	b_addr_in("b_addr_in"),
#endif
	b_we_in("b_we_in"),
	b_re_in("b_re_in"),
	b_comm_out("b_comm_out"),
	b_data_out("b_data_out"),
#ifndef USE_R3_WRAPPERS
	b_av_out("b_av_out"),
#else
	b_addr_out("b_addr_out"),
#endif
	b_full_out("b_full_out"),
	b_one_p_out("b_one_p_out"),
	b_empty_out("b_empty_out"),
	b_one_d_out("b_one_d_out"),
#ifndef USE_R3_WRAPPERS
	hibi("HIBI", "hibiv3_r4")
#else
	b_msg_comm_in("b_msg_comm_in"),
	b_msg_data_in("b_msg_data_in"),
	b_msg_addr_in("b_msg_addr_in"),
	b_msg_we_in("b_msg_we_in"),
	b_msg_re_in("b_msg_re_in"),
	b_msg_comm_out("b_msg_comm_out"),
	b_msg_data_out("b_msg_data_out"),
	b_msg_addr_out("b_msg_addr_out"),
	b_msg_full_out("b_msg_full_out"),
	b_msg_one_p_out("b_msg_one_p_out"),
	b_msg_empty_out("b_msg_empty_out"),
	b_msg_one_d_out("b_msg_one_d_out"),
	hibi("HIBI", "hibiv3_r3")
	
#endif
   {
      // Activate reset (active low)
      rst_n.write(false); 
    
      // Create agents (stimulus components)
      for(int i = 0; i < n_agents_c; ++i)
      {
	 ostringstream name;
	 name << "SAD_AGENT_" << i;      
	 agents.push_back(new Agent<addr_width_c, data_width_c, 
				       comm_width_c, separate_addr_c>
			  (name.str().c_str(), i, agents));
      }

      // Bind agents to signals
      for(int i = 0; i < n_agents_c; ++i)
      {
	 agents.at(i)->clk.bind(clk_ip);
	 agents.at(i)->rst_n.bind(rst_n);
	 agents.at(i)->comm_out.bind(a_comm_out[i]);
	 agents.at(i)->data_out.bind(a_data_out[i]);
#ifndef USE_R3_WRAPPERS
	 agents.at(i)->av_out.bind(a_av_out[i]);
#else
	 agents.at(i)->addr_out.bind(a_addr_out[i]);
#endif	 
	 agents.at(i)->we_out.bind(a_we_out[i]);
	 agents.at(i)->re_out.bind(a_re_out[i]);
	 agents.at(i)->comm_in.bind(a_comm_in[i]);
	 agents.at(i)->data_in.bind(a_data_in[i]);
#ifndef USE_R3_WRAPPERS
	 agents.at(i)->av_in.bind(a_av_in[i]);
#else
	 agents.at(i)->addr_in.bind(a_addr_in[i]);
#endif
	 agents.at(i)->full_in.bind(a_full_in[i]);
	 agents.at(i)->one_p_in.bind(a_one_p_in[i]);
	 agents.at(i)->empty_in.bind(a_empty_in[i]);
	 agents.at(i)->one_d_in.bind(a_one_d_in[i]);

#ifdef USE_R3_WRAPPERS
	 agents.at(i)->msg_comm_out.bind(a_msg_comm_out[i]);
	 agents.at(i)->msg_data_out.bind(a_msg_data_out[i]);
	 agents.at(i)->msg_addr_out.bind(a_msg_addr_out[i]);
	 agents.at(i)->msg_we_out.bind(a_msg_we_out[i]);
	 agents.at(i)->msg_re_out.bind(a_msg_re_out[i]);
	 agents.at(i)->msg_comm_in.bind(a_msg_comm_in[i]);
	 agents.at(i)->msg_data_in.bind(a_msg_data_in[i]);
	 agents.at(i)->msg_addr_in.bind(a_msg_addr_in[i]);
	 agents.at(i)->msg_full_in.bind(a_msg_full_in[i]);
	 agents.at(i)->msg_one_p_in.bind(a_msg_one_p_in[i]);
	 agents.at(i)->msg_empty_in.bind(a_msg_empty_in[i]);
	 agents.at(i)->msg_one_d_in.bind(a_msg_one_d_in[i]);
#endif
      }

      // Bind HIBI ports to signals
      hibi.clk_ip.bind(clk_ip);
      hibi.clk_noc.bind(clk_bus);
      hibi.rst_n.bind(rst_n);

      hibi.agent_comm_in.bind(b_comm_in);
      hibi.agent_data_in.bind(b_data_in);
#ifndef USE_R3_WRAPPERS
      hibi.agent_av_in.bind(b_av_in);
#else
      hibi.agent_addr_in.bind(b_addr_in);
#endif
      hibi.agent_we_in.bind(b_we_in);
      hibi.agent_re_in.bind(b_re_in);
      hibi.agent_comm_out.bind(b_comm_out);
      hibi.agent_data_out.bind(b_data_out);
#ifndef USE_R3_WRAPPERS
      hibi.agent_av_out.bind(b_av_out);
#else
      hibi.agent_addr_out.bind(b_addr_out);
#endif
      hibi.agent_full_out.bind(b_full_out);
      hibi.agent_one_p_out.bind(b_one_p_out);
      hibi.agent_empty_out.bind(b_empty_out);
      hibi.agent_one_d_out.bind(b_one_d_out);

#ifdef USE_R3_WRAPPERS
      hibi.agent_msg_comm_in.bind(b_msg_comm_in);
      hibi.agent_msg_data_in.bind(b_msg_data_in);
      hibi.agent_msg_addr_in.bind(b_msg_addr_in);
      hibi.agent_msg_we_in.bind(b_msg_we_in);
      hibi.agent_msg_re_in.bind(b_msg_re_in);
      hibi.agent_msg_comm_out.bind(b_msg_comm_out);
      hibi.agent_msg_data_out.bind(b_msg_data_out);
      hibi.agent_msg_addr_out.bind(b_msg_addr_out);
      hibi.agent_msg_full_out.bind(b_msg_full_out);
      hibi.agent_msg_one_p_out.bind(b_msg_one_p_out);
      hibi.agent_msg_empty_out.bind(b_msg_empty_out);
      hibi.agent_msg_one_d_out.bind(b_msg_one_d_out);
#endif

      // Spawn process to pass the data between hibi and agents            
      SC_METHOD(connectSignals);
      for(int i = 0; i < n_agents_c; ++i)
      {
	 sensitive << agents.at(i)->comm_out
		   << agents.at(i)->data_out
#ifndef USE_R3_WRAPPERS
		   << agents.at(i)->av_out
#else
		   << agents.at(i)->addr_out
#endif
		   << agents.at(i)->we_out
		   << agents.at(i)->re_out;
#ifdef USE_R3_WRAPPERS
	 sensitive << agents.at(i)->msg_comm_out
		   << agents.at(i)->msg_data_out
		   << agents.at(i)->msg_addr_out
		   << agents.at(i)->msg_we_out
		   << agents.at(i)->msg_re_out;
#endif
      }
      sensitive << hibi.agent_comm_out
		<< hibi.agent_data_out
#ifndef USE_R3_WRAPPERS
		<< hibi.agent_av_out
#else
		<< hibi.agent_addr_out
#endif
		<< hibi.agent_full_out
		<< hibi.agent_one_p_out
		<< hibi.agent_empty_out
		<< hibi.agent_one_d_out;
#ifdef USE_R3_WRAPPERS      
      sensitive << hibi.agent_msg_comm_out
		<< hibi.agent_msg_data_out
		<< hibi.agent_msg_full_out
		<< hibi.agent_msg_one_p_out
		<< hibi.agent_msg_empty_out
		<< hibi.agent_msg_one_d_out;
#endif

   }

   //* Destructor
   ~TopLevel()
   {
      for(int i = 0; i < n_agents_c; ++i)
      {
	 delete agents.at(i); agents.at(i) = 0;
      }
   }

   //* Sets reset to some value
   void setResetN(bool value)
   {
      rst_n.write(value);
   }


private:


   //* Connects signals from hibi to the agents and vice versa
   void connectSignals(void)
   {
      sc_bv<n_agents_c * comm_width_c>  b_comm_s;
      sc_bv<n_agents_c * data_width_c>  b_data_s;
#ifndef USE_R3_WRAPPERS
      sc_bv<n_agents_c>                 b_av_s;
#else
      sc_bv<n_agents_c * data_width_c>  b_addr_s;
#endif
      sc_bv<n_agents_c>                 b_we_s;
      sc_bv<n_agents_c>                 b_re_s;

#ifdef USE_R3_WRAPPERS
      sc_bv<n_agents_c * comm_width_c>  b_msg_comm_s;
      sc_bv<n_agents_c * data_width_c>  b_msg_data_s;
      sc_bv<n_agents_c * data_width_c>  b_msg_addr_s;
      sc_bv<n_agents_c>                 b_msg_we_s;
      sc_bv<n_agents_c>                 b_msg_re_s;
#endif
      
      for(int i = 0; i < n_agents_c; ++i)
      {
	 a_comm_in[i].write
	    (b_comm_out.read().range((i+1)*comm_width_c-1, i*comm_width_c));
	 a_data_in[i].write
	    (b_data_out.read().range((i+1)*data_width_c-1, i*data_width_c));
#ifndef USE_R3_WRAPPERS
	 a_av_in[i].write(b_av_out.read()[i].to_bool());
#else
	 a_addr_in[i].write
	    (b_addr_out.read().range((i+1)*addr_width_c-1, i*addr_width_c));
#endif
	 a_full_in[i].write(b_full_out.read()[i].to_bool());
	 a_one_p_in[i].write(b_one_p_out.read()[i].to_bool());
	 a_empty_in[i].write(b_empty_out.read()[i].to_bool());
	 a_one_d_in[i].write(b_one_d_out.read()[i].to_bool());

	 b_comm_s.range((i+1)*comm_width_c-1, i*comm_width_c) =
	    a_comm_out[i].read();
	 b_data_s.range((i+1)*data_width_c-1, i*data_width_c) =
	    a_data_out[i].read();
#ifndef USE_R3_WRAPPERS
	 b_av_s[i] = a_av_out[i].read();
#else
	 b_addr_s.range((i+1)*addr_width_c-1, i*addr_width_c) =
	    a_addr_out[i].read();
#endif
	 b_we_s[i] = a_we_out[i].read();
	 b_re_s[i] = a_re_out[i].read();

#ifdef USE_R3_WRAPPERS
	 a_msg_comm_in[i].write
	    (b_msg_comm_out.read().range((i+1)*comm_width_c-1, i*comm_width_c));
	 a_msg_data_in[i].write
	    (b_msg_data_out.read().range((i+1)*data_width_c-1, i*data_width_c));
	 a_msg_addr_in[i].write
	    (b_msg_addr_out.read().range((i+1)*addr_width_c-1, i*addr_width_c));
	 a_msg_full_in[i].write(b_msg_full_out.read()[i].to_bool());
	 a_msg_one_p_in[i].write(b_msg_one_p_out.read()[i].to_bool());
	 a_msg_empty_in[i].write(b_msg_empty_out.read()[i].to_bool());
	 a_msg_one_d_in[i].write(b_msg_one_d_out.read()[i].to_bool());

	 b_msg_comm_s.range((i+1)*comm_width_c-1, i*comm_width_c) =
	    a_msg_comm_out[i].read();
	 b_msg_data_s.range((i+1)*data_width_c-1, i*data_width_c) =
	    a_msg_data_out[i].read();
	 b_msg_addr_s.range((i+1)*addr_width_c-1, i*addr_width_c) =
	    a_msg_addr_out[i].read();
	 b_msg_we_s[i] = a_msg_we_out[i].read();
	 b_msg_re_s[i] = a_msg_re_out[i].read();
#endif
      }

      b_comm_in.write(b_comm_s);
      b_data_in.write(b_data_s);
#ifndef USE_R3_WRAPPERS
      b_av_in.write(b_av_s);
#else
      b_addr_in.write(b_addr_s);
#endif
      b_we_in.write(b_we_s);
      b_re_in.write(b_re_s);	 

#ifdef USE_R3_WRAPPERS
      b_msg_comm_in.write(b_msg_comm_s);
      b_msg_data_in.write(b_msg_data_s);
      b_msg_addr_in.write(b_msg_addr_s);
      b_msg_we_in.write(b_msg_we_s);
      b_msg_re_in.write(b_msg_re_s);	 
#endif

   }

   // Declare internals signals between agents and HIBI
   sc_clock          clk_ip;
   sc_clock          clk_bus;
   sc_signal<bool>   rst_n;

   sc_signal<sc_bv<n_agents_c * comm_width_c> >  b_comm_in;
   sc_signal<sc_bv<n_agents_c * data_width_c> >  b_data_in;
#ifndef USE_R3_WRAPPERS
   sc_signal<sc_bv<n_agents_c> >                 b_av_in;
#else
   sc_signal<sc_bv<n_agents_c * addr_width_c> >  b_addr_in;
#endif
   sc_signal<sc_bv<n_agents_c> >                 b_we_in;
   sc_signal<sc_bv<n_agents_c> >                 b_re_in;
   sc_signal<sc_bv<n_agents_c * comm_width_c> >  b_comm_out;
   sc_signal<sc_bv<n_agents_c * data_width_c> >  b_data_out;
#ifndef USE_R3_WRAPPERS
   sc_signal<sc_bv<n_agents_c> >                 b_av_out;
#else
   sc_signal<sc_bv<n_agents_c * addr_width_c> >  b_addr_out;
#endif
   sc_signal<sc_bv<n_agents_c> >                 b_full_out;
   sc_signal<sc_bv<n_agents_c> >                 b_one_p_out;
   sc_signal<sc_bv<n_agents_c> >                 b_empty_out;
   sc_signal<sc_bv<n_agents_c> >                 b_one_d_out;

   sc_signal<sc_bv<comm_width_c> >  a_comm_out[n_agents_c];
   sc_signal<sc_bv<data_width_c> >  a_data_out[n_agents_c];
#ifndef USE_R3_WRAPPERS
   sc_signal<bool>                  a_av_out[n_agents_c];
#else
   sc_signal<sc_bv<addr_width_c> >  a_addr_out[n_agents_c];
#endif
   sc_signal<bool>                  a_we_out[n_agents_c];
   sc_signal<bool>                  a_re_out[n_agents_c];
   sc_signal<sc_bv<comm_width_c> >  a_comm_in[n_agents_c];
   sc_signal<sc_bv<data_width_c> >  a_data_in[n_agents_c];
#ifndef USE_R3_WRAPPERS
   sc_signal<bool>                  a_av_in[n_agents_c];
#else
   sc_signal<sc_bv<addr_width_c> >  a_addr_in[n_agents_c];
#endif
   sc_signal<bool>                  a_full_in[n_agents_c];
   sc_signal<bool>                  a_one_p_in[n_agents_c];
   sc_signal<bool>                  a_empty_in[n_agents_c];
   sc_signal<bool>                  a_one_d_in[n_agents_c];

#ifdef USE_R3_WRAPPERS
   sc_signal<sc_bv<n_agents_c * comm_width_c> >  b_msg_comm_in;
   sc_signal<sc_bv<n_agents_c * data_width_c> >  b_msg_data_in;
   sc_signal<sc_bv<n_agents_c * addr_width_c> >  b_msg_addr_in;
   sc_signal<sc_bv<n_agents_c> >                 b_msg_we_in;
   sc_signal<sc_bv<n_agents_c> >                 b_msg_re_in;
   sc_signal<sc_bv<n_agents_c * comm_width_c> >  b_msg_comm_out;
   sc_signal<sc_bv<n_agents_c * data_width_c> >  b_msg_data_out;
   sc_signal<sc_bv<n_agents_c * addr_width_c> >  b_msg_addr_out;
   sc_signal<sc_bv<n_agents_c> >                 b_msg_full_out;
   sc_signal<sc_bv<n_agents_c> >                 b_msg_one_p_out;
   sc_signal<sc_bv<n_agents_c> >                 b_msg_empty_out;
   sc_signal<sc_bv<n_agents_c> >                 b_msg_one_d_out;

   sc_signal<sc_bv<comm_width_c> >  a_msg_comm_out[n_agents_c];
   sc_signal<sc_bv<data_width_c> >  a_msg_data_out[n_agents_c];
   sc_signal<sc_bv<addr_width_c> >  a_msg_addr_out[n_agents_c];
   sc_signal<bool>                  a_msg_we_out[n_agents_c];
   sc_signal<bool>                  a_msg_re_out[n_agents_c];
   sc_signal<sc_bv<comm_width_c> >  a_msg_comm_in[n_agents_c];
   sc_signal<sc_bv<data_width_c> >  a_msg_data_in[n_agents_c];
   sc_signal<sc_bv<addr_width_c> >  a_msg_addr_in[n_agents_c];
   sc_signal<bool>                  a_msg_full_in[n_agents_c];
   sc_signal<bool>                  a_msg_one_p_in[n_agents_c];
   sc_signal<bool>                  a_msg_empty_in[n_agents_c];
   sc_signal<bool>                  a_msg_one_d_in[n_agents_c];
#endif


   // Instantiate the network
#ifndef USE_R3_WRAPPERS
   hibiv3_r4<id_width_c, addr_width_c, data_width_c, comm_width_c, 
	     counter_width_c, rel_agent_freq_c, rel_bus_freq_c, 
	     arb_type_c, fifo_sel_c, rx_fifo_depth_c, rx_msg_fifo_depth_c, 
	     tx_fifo_depth_c, tx_msg_fifo_depth_c, max_send_c, 
	     n_cfg_pages_c, n_time_slots_c, keep_slot_c, n_extra_params_c, 
	     cfg_re_c, cfg_we_c, debug_width_c, 
	     n_agents_c, n_segments_c, separate_addr_c> hibi;
#else
   hibiv3_r3<id_width_c, addr_width_c, data_width_c, comm_width_c, 
	     counter_width_c, rel_agent_freq_c, rel_bus_freq_c, 
	     arb_type_c, fifo_sel_c, rx_fifo_depth_c, rx_msg_fifo_depth_c, 
	     tx_fifo_depth_c, tx_msg_fifo_depth_c, max_send_c, 
	     n_cfg_pages_c, n_time_slots_c, keep_slot_c, n_extra_params_c, 
	     cfg_re_c, cfg_we_c, debug_width_c, 
	     n_agents_c, n_segments_c, separate_addr_c> hibi;
#endif
  
   // Pointers and dynamically created because constructor parameters can't 
   // be given to tables of thingys
   vector<Agent<addr_width_c, data_width_c, 
		comm_width_c, separate_addr_c>* > agents;

   friend class Stimuli;

};


#endif


// Local Variables:
// mode: c++
// c-file-style: "ellemtel"
// c-basic-offset: 3
// End:

