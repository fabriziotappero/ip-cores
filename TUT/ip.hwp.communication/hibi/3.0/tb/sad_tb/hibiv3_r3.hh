/*
 * Author: Lasse Lehtonen
 *
 * Instantiates hibiv3_r3.vhd VHDL component for SystemC.
 * hibi wrapper_r3 has
 *   - separate IP interface for regular and hi-prior data
 *   - IP writes/gets addr and data in parallel
 *
 *
 * $Id: hibiv3_r3.hh 2002 2011-10-04 13:18:30Z ege $
 *
 */


#ifndef _HUUHAA_hibiv3_r3_
#define _HUUHAA_hibiv3_r3_

#include <systemc>
using namespace sc_core;
using namespace sc_dt;

template<int id_width_g, 
	 int addr_width_g, 
	 int data_width_g, 
	 int comm_width_g, 
	 int counter_width_g, 
	 int rel_agent_freq_g, 
	 int rel_bus_freq_g, 
	 int arb_type_g, 
	 int fifo_sel_g, 
	 int rx_fifo_depth_g, 
	 int rx_msg_fifo_depth_g, 
	 int tx_fifo_depth_g, 
	 int tx_msg_fifo_depth_g, 
	 int max_send_g, 
	 int n_cfg_pages_g, 
	 int n_time_slots_g, 
	 int keep_slot_g, 
	 int n_extra_params_g, 

	 int cfg_re_g, 
	 int cfg_we_g, 
	 int debug_width_g, 
	 int n_agents_g, 
	 int n_segments_g,
	 int separate_addr_g>
class hibiv3_r3 : public sc_foreign_module
{
public:
   sc_in_clk                                         clk_ip;
   sc_in_clk                                         clk_noc;
   sc_in<bool>                                       rst_n;
   sc_in<sc_bv<n_agents_g * comm_width_g - 1 + 1> >  agent_comm_in;
   sc_in<sc_bv<n_agents_g * data_width_g - 1 + 1> >  agent_data_in;
   sc_in<sc_bv<n_agents_g * addr_width_g - 1 + 1> >  agent_addr_in;
   sc_in<sc_bv<n_agents_g - 1 + 1> >                 agent_we_in;
   sc_in<sc_bv<n_agents_g - 1 + 1> >                 agent_re_in;
   sc_out<sc_bv<n_agents_g * comm_width_g - 1 + 1> > agent_comm_out;
   sc_out<sc_bv<n_agents_g * data_width_g - 1 + 1> > agent_data_out;
   sc_out<sc_bv<n_agents_g * addr_width_g - 1 + 1> > agent_addr_out;
   sc_out<sc_bv<n_agents_g - 1 + 1> >                agent_full_out;
   sc_out<sc_bv<n_agents_g - 1 + 1> >                agent_one_p_out;
   sc_out<sc_bv<n_agents_g - 1 + 1> >                agent_empty_out;
   sc_out<sc_bv<n_agents_g - 1 + 1> >                agent_one_d_out;
   sc_in<sc_bv<n_agents_g * comm_width_g - 1 + 1> >  agent_msg_comm_in;
   sc_in<sc_bv<n_agents_g * data_width_g - 1 + 1> >  agent_msg_data_in;
   sc_in<sc_bv<n_agents_g * addr_width_g - 1 + 1> >  agent_msg_addr_in;
   sc_in<sc_bv<n_agents_g - 1 + 1> >                 agent_msg_we_in;
   sc_in<sc_bv<n_agents_g - 1 + 1> >                 agent_msg_re_in;
   sc_out<sc_bv<n_agents_g * comm_width_g - 1 + 1> > agent_msg_comm_out;
   sc_out<sc_bv<n_agents_g * data_width_g - 1 + 1> > agent_msg_data_out;
   sc_out<sc_bv<n_agents_g * addr_width_g - 1 + 1> > agent_msg_addr_out;
   sc_out<sc_bv<n_agents_g - 1 + 1> >                agent_msg_full_out;
   sc_out<sc_bv<n_agents_g - 1 + 1> >                agent_msg_one_p_out;
   sc_out<sc_bv<n_agents_g - 1 + 1> >                agent_msg_empty_out;
   sc_out<sc_bv<n_agents_g - 1 + 1> >                agent_msg_one_d_out;
   


   hibiv3_r3(sc_module_name nm, const char* hdl_name)
      : sc_foreign_module(nm),
	clk_ip("clk_ip"),
	clk_noc("clk_noc"),
	rst_n("rst_n"),
	agent_comm_in("agent_comm_in"),
	agent_data_in("agent_data_in"),
	agent_addr_in("agent_addr_in"),
	agent_we_in("agent_we_in"),
	agent_re_in("agent_re_in"),
	agent_comm_out("agent_comm_out"),
	agent_data_out("agent_data_out"),
	agent_addr_out("agent_addr_out"),
	agent_full_out("agent_full_out"),
	agent_one_p_out("agent_one_p_out"),
	agent_empty_out("agent_empty_out"),
	agent_one_d_out("agent_one_d_out"),
	agent_msg_comm_in("agent_msg_comm_in"),
	agent_msg_data_in("agent_msg_data_in"),
	agent_msg_addr_in("agent_msg_addr_in"),
	agent_msg_we_in("agent_msg_we_in"),
	agent_msg_re_in("agent_msg_re_in"),
	agent_msg_comm_out("agent_msg_comm_out"),
	agent_msg_data_out("agent_msg_data_out"),
	agent_msg_addr_out("agent_msg_addr_out"),
	agent_msg_full_out("agent_msg_full_out"),
	agent_msg_one_p_out("agent_msg_one_p_out"),
	agent_msg_empty_out("agent_msg_empty_out"),
	agent_msg_one_d_out("agent_msg_one_d_out")
   {
      this->add_parameter("id_width_g", id_width_g);
      this->add_parameter("addr_width_g", addr_width_g);
      this->add_parameter("data_width_g", data_width_g);
      this->add_parameter("comm_width_g", comm_width_g);
      this->add_parameter("counter_width_g", counter_width_g);
      this->add_parameter("rel_agent_freq_g", rel_agent_freq_g);
      this->add_parameter("rel_bus_freq_g", rel_bus_freq_g);
      this->add_parameter("arb_type_g", arb_type_g);
      this->add_parameter("fifo_sel_g", fifo_sel_g);
      this->add_parameter("rx_fifo_depth_g", rx_fifo_depth_g);
      this->add_parameter("rx_msg_fifo_depth_g", rx_msg_fifo_depth_g);
      this->add_parameter("tx_fifo_depth_g", tx_fifo_depth_g);
      this->add_parameter("tx_msg_fifo_depth_g", tx_msg_fifo_depth_g);
      this->add_parameter("max_send_g", max_send_g);
      this->add_parameter("n_cfg_pages_g", n_cfg_pages_g);
      this->add_parameter("n_time_slots_g", n_time_slots_g);
      this->add_parameter("keep_slot_g", keep_slot_g);
      this->add_parameter("n_extra_params_g", n_extra_params_g);

      this->add_parameter("cfg_re_g", cfg_re_g);
      this->add_parameter("cfg_we_g", cfg_we_g);
      this->add_parameter("debug_width_g", debug_width_g);
      this->add_parameter("n_agents_g", n_agents_g);
      this->add_parameter("n_segments_g", n_segments_g);
      this->add_parameter("separate_addr_g", separate_addr_g);
      elaborate_foreign_module(hdl_name);
   }

   ~hibiv3_r3()
   {
   }

};

#endif


// Local Variables:
// mode: c++
// c-file-style: "ellemtel"
// c-basic-offset: 3
// End:

