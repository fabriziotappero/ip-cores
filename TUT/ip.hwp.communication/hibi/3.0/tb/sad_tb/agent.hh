/*
 * Author: Lasse Lehtonen
 *
 * Agent for hibi. Sends packets when told to and checks that correct
 * packets are received. Wrapper types r3 and r4 have different interfaces and 
 * infndefs are needed every now and then.
 *
 * $Id: agent.hh 2008 2011-10-06 13:49:53Z ege $
 *
 */


#ifndef SAD_HIBI_AGENT_HH
#define SAD_HIBI_AGENT_HH

#include "constants.hh"
#include "packet.hh"

#include <queue>
#include <map>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <cstdlib>
using namespace std;

#include <systemc>
using namespace sc_core;
using namespace sc_dt;


template<int addr_width_g, 
	 int data_width_g, 
	 int comm_width_g,
	 int separate_addr_g>
class Agent : public sc_module
{
public:
   sc_in_clk                    clk;
   sc_in<bool>                  rst_n;

   sc_out<sc_bv<comm_width_g> > comm_out;
   sc_out<sc_bv<data_width_g> > data_out;
#ifndef USE_R3_WRAPPERS
   sc_out<bool>                 av_out;
#else
   sc_out<sc_bv<addr_width_g> > addr_out;
#endif
   sc_out<bool>                 we_out;
   sc_out<bool>                 re_out;
   sc_in<sc_bv<comm_width_g> >  comm_in;
   sc_in<sc_bv<data_width_g> >  data_in;
#ifndef USE_R3_WRAPPERS
   sc_in<bool>                  av_in;
#else
   sc_out<sc_bv<addr_width_g> > addr_in;
#endif
   sc_in<bool>                  full_in;
   sc_in<bool>                  one_p_in;
   sc_in<bool>                  empty_in;
   sc_in<bool>                  one_d_in;

#ifdef USE_R3_WRAPPERS
   sc_out<sc_bv<comm_width_g> > msg_comm_out;
   sc_out<sc_bv<data_width_g> > msg_data_out;
   sc_out<sc_bv<addr_width_g> > msg_addr_out;
   sc_out<bool>                 msg_we_out;
   sc_out<bool>                 msg_re_out;
   sc_in<sc_bv<comm_width_g> >  msg_comm_in;
   sc_in<sc_bv<data_width_g> >  msg_data_in;
   sc_in<sc_bv<addr_width_g> >  msg_addr_in;
   sc_in<bool>                  msg_full_in;
   sc_in<bool>                  msg_one_p_in;
   sc_in<bool>                  msg_empty_in;
   sc_in<bool>                  msg_one_d_in;
#endif

   SC_HAS_PROCESS(Agent);


   //* Constructor 
   // Initalize ports to 0 and 
   // tx and rx threads
   Agent(sc_module_name name, unsigned int id, 
	 vector<Agent<addr_width_c, data_width_c, 
		      comm_width_c, separate_addr_c>* >& agents)
      : sc_module(name),
	clk("clk"),
	rst_n("rst_n"),
	comm_out("comm_out"),
	data_out("data_out"),
#ifndef USE_R3_WRAPPERS
	av_out("av_out"),
#else
	addr_out("addr_out"),
#endif
	we_out("we_out"),
	re_out("re_out"),
	comm_in("comm_in"),
	data_in("data_in"),
#ifndef USE_R3_WRAPPERS
	av_in("av_in"),
#else
	addr_in("addr_in"),
#endif
	full_in("full_in"),
	one_p_in("one_p_in"),
	empty_in("empty_in"),
	one_d_in("one_d_in"),
#ifdef USE_R3_WRAPPERS
	msg_comm_out("msg_comm_out"),
	msg_data_out("msg_data_out"),
	msg_addr_out("msg_addr_out"),
	msg_we_out("msg_we_out"),
	msg_re_out("msg_re_out"),
	msg_comm_in("msg_comm_in"),
	msg_data_in("msg_data_in"),
	msg_addr_in("msg_addr_in"),
	msg_full_in("msg_full_in"),
	msg_one_p_in("msg_one_p_in"),
	msg_empty_in("msg_empty_in"),
	msg_one_d_in("msg_one_d_in"),
#endif
	_id(id),
	_rxBusyChance(0),
	_txBusyChance(0),
	_agents(agents),
	_locked(false)
   {
      comm_out.initialize(0);
      data_out.initialize(0);
#ifndef USE_R3_WRAPPERS
      av_out.initialize(false);
#else
      addr_out.initialize(0);
#endif
      we_out.initialize(false);
      re_out.initialize(false);
#ifdef USE_R3_WRAPPERS
      msg_comm_out.initialize(0);
      msg_data_out.initialize(0);
      msg_addr_out.initialize(0);
      msg_we_out.initialize(false);
      msg_re_out.initialize(false);
#endif



      // Launch threads for tx and rx
      SC_THREAD(sender);
      SC_THREAD(receiver);

#ifdef USE_R3_WRAPPERS
      // Launch threads for message tx and rx
      SC_THREAD(msg_sender);
      SC_THREAD(msg_receiver);
#endif

   }


   //* Destructor
   ~Agent() 
   {
      freePackets();      
   }
   

   //* Adds packet for this agent to send
   void send(Packet* packet)
   {
#ifdef USE_R3_WRAPPERS
      if(packet->getHibiCommand() == DATA_WR ||
	 packet->getHibiCommand() == DATA_RD ||
	 packet->getHibiCommand() == DATA_RDL ||
	 packet->getHibiCommand() == DATA_WRNP ||
	 packet->getHibiCommand() == DATA_WRC)
      {
	 _packetsOut.push(packet);
      }
      else
      {
	 _msgPacketsOut.push(packet);
      }
#else
      _packetsOut.push(packet);
#endif

      /*
      cout << "At " << setprecision(10) << sc_time_stamp().to_double() << " : "
	   << "Agent " << setfill(' ') << setw(3) << dec << _id << " queued   " 
	   << commmand2str(packet->getHibiCommand())
	   << " packet: " 
	   << setw(5) << setfill(' ') << packet->getId() << " to   ";
      if(packet->getHibiCommand() == CFG_WR ||
	 packet->getHibiCommand() == CFG_RD)
      {
	 cout << "id: " << packet->getDstId() << endl;
      }
      else
      {
	 cout << "address: 0x" 
	      << hex << setw(8) << setfill('0')
	      << packet->getDstAddress().to_uint()
	      << endl; 
      }

      */

   }

   //* Tells agent to expect this packet
   void expect(Packet* packet)
   {
      //_packetsIn[packet->getId()] = packet;
      _packetsIn.insert(pair<sc_uint<16>, Packet*>(packet->getId(), packet));
   }

   //* Tells agent to expect this packet, custom id
   void expect(Packet* packet, unsigned int id)
   {
      //_packetsIn[id] = packet;
      _packetsIn.insert(pair<sc_uint<16>, Packet*>(id, packet));
   }


   //* True if all packets have been received
   bool allDone() const
   { 
      return _packetsIn.empty(); 
   }

   //* Print unfinished packet ids
   void printExpected()
   {
      for(map<sc_uint<16>, Packet*>::iterator iter = _packetsIn.begin();
	  iter != _packetsIn.end(); ++iter)
      {
	 cout << " +- packet " 
	      << dec << setw(5) << setfill(' ') << (*iter).second->getId() 
	      << " missing " 
	      << (*iter).second->getSize() - (*iter).second->getReceived()
	      << " words"
	      << endl;
      }
   }

   //* Sets RX change to be busy on any clock cycle (0-100)
   void setRxBusyChance(unsigned int chance)
   { _rxBusyChance = chance; }

   //* Sets TX change to be busy on any clock cycle (0-100)
   void setTxBusyChance(unsigned int chance)
   { _txBusyChance = chance; }


private:


   //* Frees all memory elements
   void freePackets()
   {
      while(!_packetsOut.empty())
      {
	 // Only pointers on RX side will be deleted as they point
	 // to the same object
	 _packetsOut.pop();
      }

#ifdef USE_R3_WRAPPERS
      while(!_msgPacketsOut.empty())
      {
	 // Only pointers on RX side will be deleted as they point
	 // to the same object
	 _msgPacketsOut.pop();
      }
#endif

      for(map<sc_uint<16>, Packet*>::iterator iter = _packetsIn.begin();
	  iter != _packetsIn.end(); ++iter )
      {
	 delete (*iter).second;
      }
   }


   //* TX thread, handles pushing packets to hibi
   void sender()
   {
      while(true)
      {
	 // Sync to pos edge
	 wait(clk.posedge_event());
	 
	 // Handle reset
	 if(rst_n.read() == false)
	 {
	    comm_out.write(0);
	    data_out.write(0);
#ifndef USE_R3_WRAPPERS
	    av_out.write(false);
#else
	    addr_out.write(0);
#endif
	    we_out.write(false);
	    freePackets(); // Deletes all packets
	    continue; 
	 }



	 // No packets to send
	 if(_packetsOut.empty()) continue; 



	 // There is data to send in the FIFO
	 Packet* packet = _packetsOut.front();
	 _packetsOut.pop();
	 
#ifndef USE_R3_WRAPPERS
	 // Put address before data flits in normal mode
	 if(separate_addr_g == 0)
	 {
	    // Wait if NI is full
	    while(full_in.read() == true) wait(clk.posedge_event());

	    we_out.write(true);
	    av_out.write(true);
	    comm_out.write(packet->getCommand());
	    data_out.write(packet->getDstAddress());

	    wait(clk.posedge_event());
	 }
#endif



	 // Send all flits
	 for(unsigned int i = 0; i < packet->getSize();)
	 {
	    // Occasionally, play dead and not send anything
	    // This doesn't work, need second cycle wait, stupido we_out!
	    // if((unsigned(rand()) % 100) < _txBusyChance) 
	    // {
	    //    we_out.write(false);
	    //    wait(clk.posedge_event());	       
	    //    continue; 
	    // }

	    // Wait if NI is full
	    while(full_in.read() == true) 
	    {	       
	       //we_out.write(true);
	       wait(clk.posedge_event());
	    }	    

	    we_out.write(true);
	    
#ifndef USE_R3_WRAPPERS
	    if(separate_addr_g == 0)
	    {
	       av_out.write(false);
	       comm_out.write(packet->getCommand());
	       data_out.write(packet->getData());
	    }
	    else
	    {
	       // AV is high for the whole packet in SAD mode
	       av_out.write(true);
	       // Substitute address to MSBs of data_out
	       data_out.write((packet->getDstAddress(), 
			       packet->getData().
			       range(data_width_c-addr_width_c-1, 0)));
	       comm_out.write(packet->getCommand());
	    }
#else
	    comm_out.write(packet->getCommand());
	    data_out.write(packet->getData());
	    addr_out.write(packet->getDstAddress());
#endif	    

	    wait(clk.posedge_event());
	    ++i;
	 }



	 // Wait if NI is full when last flit is being sent
	 while(full_in.read() == true) 
	 {	       
	    wait(clk.posedge_event());
	 }
	 
	 cout << "At " << setprecision(10) << sc_time_stamp().to_double() 
	      << " : "
	      << "Agent " << setfill(' ') << setw(3) << dec << _id 
	      << " sent     " 
	      << commmand2str(packet->getHibiCommand())
	      << " packet: " 
	      << setw(5) << setfill(' ') <<  packet->getId() << " to   ";
	 if(packet->getHibiCommand() == CFG_WR ||
	    packet->getHibiCommand() == CFG_RD)
	 {
	    cout << "id: " << packet->getDstId() << endl;
	 }
	 else
	 {
	    cout << "address: 0x" 
		 << hex << setw(8) << setfill('0')
		 << packet->getDstAddress().to_uint()
		 << endl; 
	 }

	 we_out.write(false);
#ifndef USE_R3_WRAPPERS
	 av_out.write(false);
#else
	 addr_out.write(0);
#endif
	 comm_out.write(commands_c[IDLE]);
	 data_out.write(0);
	 packet = 0;
      }
   }


   //* RX thread, handles receiving packets from hibitys
   void receiver()
   {
      sc_uint<16> packetId;
      bool reading = false;
      
      while(true)
      {
	 // Sync to pos edge and handle reset
	 wait(clk.posedge_event());
	 re_out.write(false); // Default
	 if(rst_n.read() == false) 
	 {
	    continue;
	 }

	 if(reading)
	 {
	    reading = false;
	    
	    if(empty_in.read() == true)
	    {
	       // There's nothing to read
	    }
#ifndef USE_R3_WRAPPERS
	    else if(separate_addr_g == 0 && av_in.read() == true) 
	    {	    
	       // Skip the address flit if in normal mode
	    }
#endif
	    else
	    {
	       // Check that we're expecting a packet with this ID
	       packetId = (data_in.read().range(15, 0).to_uint());
	       if(_packetsIn.find(packetId) == _packetsIn.end())
	       {
		  ostringstream oss;
		  oss << "At " << setprecision(10) 
		      << sc_time_stamp().to_double()
		      << " : " << "Agent " << setfill(' ') << setw(3) << _id 
		      << " received unexpected flit with id: " << packetId;
		  SC_REPORT_WARNING("warning", oss.str().c_str());
		  re_out.write(true);
		  continue;
	       }

	       HibiCommand cmd = (*_packetsIn.find(packetId)).second->
		     getHibiCommand();

	       // Check that we are not getting normal stuff while locked!
	       if(_locked &&
		  cmd != EXCL_WR &&
		  cmd != EXCL_RD &&
		  cmd != EXCL_RELEASE)
	       {
		  ostringstream oss;
		  oss << "At " << setprecision(10) 
		      << sc_time_stamp().to_double()
		      << " : " << "Agent " << setfill(' ') << setw(3) << _id 
		      << " received non-exclusive packet while locked, id: " 
		      << packetId;
		  SC_REPORT_WARNING("warning", oss.str().c_str());
	       }


	       // Lock this agent when getting lock command
	       if(cmd == EXCL_LOCK && !_locked)
	       { _locked = true; }

	       // Release the lock
	       if(cmd == EXCL_RELEASE && _locked)
	       { _locked = false; }

	       //_packetsIn[packetId]->receiveWord();
	       (*_packetsIn.find(packetId)).second->receiveWord();
	 
	       //if(_packetsIn[packetId]->complete())
	       if((*_packetsIn.find(packetId)).second->complete())
	       {
		  // Packet is fully received, remove it to save some memory
		  cout << "At " 
		       << setprecision(10) << sc_time_stamp().to_double() 
		       << " : " << "Agent " << setfill(' ') << setw(3) << dec 
		       << _id << " received " 
		       << commmand2str(comm_in.read().to_uint()) 
		       << " packet: "
		       << setw(5) << setfill(' ') << packetId << " from ";
		  cout << "address: 0x" 
		       << hex << setw(8) << setfill('0')
		     //<< _packetsIn[packetId]->getSrcAddress().to_uint()
		       << (*_packetsIn.find(packetId)).second->getSrcAddress()
		     .to_uint()
		       << endl; 	       		  

		  if(cmd == DATA_RD ||
		     cmd == MSG_RD ||
		     cmd == EXCL_RD ||
		     cmd == DATA_RDL ||
		     cmd == MSG_RDL)
		  {
		     // Generate response packet
		     Packet* packet = 0;
		     packet = new Packet((*_packetsIn.find(packetId)).second->
					 getResponseSize(), 
					 addresses_c[_id], 
					 (*_packetsIn.find(packetId)).second->
					 getSrcAddress(),
					 DATA_WRNP);
		     this->send(packet);
		     for(unsigned int i = 0; i < _agents.size(); ++i)
		     {
			if(addresses_c[i] == 
			   (*_packetsIn.find(packetId)).second->getSrcAddress())
			{
			   _agents.at(i)->expect(packet);
			}
		     }
		  }
		     
		  //delete _packetsIn[packetId];
		  delete (*_packetsIn.find(packetId)).second;
		  //_packetsIn.erase(packetId);
		  _packetsIn.erase(_packetsIn.find(packetId));
	       }
	    }
	 }

	 // Do nothing if there's nothing to do...
	 if(empty_in.read() == true) continue;

	 // Chance to play dead for this cycle
	 if((unsigned(rand()) % 100) < _rxBusyChance) continue; 
	 

	 // Read the flit
	 re_out.write(true);
	 reading = true;
		 
	    
      }
   }


#ifdef USE_R3_WRAPPERS

   //* TX thread, handles pushing packets to hibitys
   void msg_sender()
   {
      while(true)
      {
	 // Sync to pos edge
	 wait(clk.posedge_event());
	 
	 // Handle reset
	 if(rst_n.read() == false)
	 {
	    msg_comm_out.write(0);
	    msg_data_out.write(0);
	    msg_addr_out.write(0);
	    msg_we_out.write(false);
	    freePackets(); // Deletes all packets
	    continue; 
	 }

	 if(_msgPacketsOut.empty()) continue; // No packets to send	 
	 
	 // Take packets from the FIFO
	 Packet* packet = _msgPacketsOut.front();
	 _msgPacketsOut.pop();
	 

	 // Send all flits
	 for(unsigned int i = 0; i < packet->getSize();)
	 {
	    // Chance to play dead for this cycle
	    // This doesn't work, need second cycle wait, stupido we_out!
	    // if((unsigned(rand()) % 100) < _txBusyChance) 
	    // {
	    //    we_out.write(false);
	    //    wait(clk.posedge_event());	       
	    //    continue; 
	    // }

	    // Wait if NI is full
	    while(msg_full_in.read() == true) 
	    {	       
	       //msg_we_out.write(true);
	       wait(clk.posedge_event());
	    }	    

	    msg_we_out.write(true);
	    
	    msg_comm_out.write(packet->getCommand());
	    msg_data_out.write(packet->getData());
	    msg_addr_out.write(packet->getDstAddress());


	    wait(clk.posedge_event());
	    ++i;
	 }

	 // Wait if NI is full
	 while(msg_full_in.read() == true) 
	 {	       
	    wait(clk.posedge_event());
	 }
	 
	 cout << "At " << setprecision(10) << sc_time_stamp().to_double() 
	      << " : "
	      << "Agent " << setfill(' ') << setw(3) << dec << _id 
	      << " sent     " 
	      << commmand2str(packet->getHibiCommand())
	      << " packet: " 
	      << setw(5) << setfill(' ') <<  packet->getId() << " to   ";
	 if(packet->getHibiCommand() == CFG_WR ||
	    packet->getHibiCommand() == CFG_RD)
	 {
	    cout << "id: " << packet->getDstId() << endl;
	 }
	 else
	 {
	    cout << "address: 0x" 
		 << hex << setw(8) << setfill('0')
		 << packet->getDstAddress().to_uint()
		 << endl; 
	 }

	 msg_we_out.write(false);
	 msg_addr_out.write(0);
	 msg_comm_out.write(commands_c[IDLE]);
	 msg_data_out.write(0);
	 packet = 0;
      }
   }


   //* RX thread, handles receiving packets from hibitys
   void msg_receiver()
   {
      sc_uint<16> packetId;
      bool reading = false;
      
      while(true)
      {
	 // Sync to pos edge and handle reset
	 wait(clk.posedge_event());
	 msg_re_out.write(false); // Default
	 if(rst_n.read() == false) 
	 {
	    continue;
	 }

	 if(reading)
	 {
	    reading = false;
	    
	    if(msg_empty_in.read() == true)
	    {
	       // There's nothing to read
	    }
	    else
	    {
	       // Check that we're expecting a packet with this ID
	       packetId = (msg_data_in.read().range(15, 0).to_uint());
	       if(_packetsIn.find(packetId) == _packetsIn.end())
	       {
		  ostringstream oss;
		  oss << "At " << setprecision(10) 
		      << sc_time_stamp().to_double()
		      << " : " << "Agent " << setfill(' ') << setw(3) << _id 
		      << " received unexpected flit with id: " << packetId;
		  SC_REPORT_WARNING("warning", oss.str().c_str());
		  msg_re_out.write(true);
		  continue;
	       }

	       HibiCommand cmd = (*_packetsIn.find(packetId)).second->
		     getHibiCommand();

	       // Check that we are not getting normal stuff while locked!
	       if(_locked &&
		  cmd != EXCL_WR &&
		  cmd != EXCL_RD &&
		  cmd != EXCL_RELEASE)
	       {
		  ostringstream oss;
		  oss << "At " << setprecision(10) 
		      << sc_time_stamp().to_double()
		      << " : " << "Agent " << setfill(' ') << setw(3) << _id 
		      << " received non-exclusive packet while locked, id: " 
		      << packetId;
		  SC_REPORT_WARNING("warning", oss.str().c_str());
	       }


	       // Lock this agent when getting lock command
	       if(cmd == EXCL_LOCK && !_locked)
	       { _locked = true; }

	       // Release the lock
	       if(cmd == EXCL_RELEASE && _locked)
	       { _locked = false; }

	       //_packetsIn[packetId]->receiveWord();
	       (*_packetsIn.find(packetId)).second->receiveWord();
	 
	       //if(_packetsIn[packetId]->complete())
	       if((*_packetsIn.find(packetId)).second->complete())
	       {
		  // Packet is fully received, remove it to save some memory
		  cout << "At " 
		       << setprecision(10) << sc_time_stamp().to_double() 
		       << " : " << "Agent " << setfill(' ') << setw(3) << dec 
		       << _id << " received " 
		       << commmand2str(msg_comm_in.read().to_uint()) 
		       << " packet: "
		       << setw(5) << setfill(' ') << packetId << " from ";
		  cout << "address: 0x" 
		       << hex << setw(8) << setfill('0')
		     //<< _packetsIn[packetId]->getSrcAddress().to_uint()
		       << (*_packetsIn.find(packetId)).second->getSrcAddress()
		     .to_uint()
		       << endl; 	       		  

		  if(cmd == DATA_RD ||
		     cmd == MSG_RD ||
		     cmd == EXCL_RD ||
		     cmd == DATA_RDL ||
		     cmd == MSG_RDL)
		  {
		     // Generate response packet
		     Packet* packet = 0;
		     packet = new Packet((*_packetsIn.find(packetId)).second->
					 getResponseSize(), 
					 addresses_c[_id], 
					 (*_packetsIn.find(packetId)).second->
					 getSrcAddress(),
					 DATA_WRNP);
		     this->send(packet);
		     for(unsigned int i = 0; i < _agents.size(); ++i)
		     {
			if(addresses_c[i] == 
			   (*_packetsIn.find(packetId)).second->getSrcAddress())
			{
			   _agents.at(i)->expect(packet);
			}
		     }
		  }
		     
		  //delete _packetsIn[packetId];
		  delete (*_packetsIn.find(packetId)).second;
		  //_packetsIn.erase(packetId);
		  _packetsIn.erase(_packetsIn.find(packetId));
	       }
	    }
	 }

	 // Do nothing if there's nothing to do...
	 if(msg_empty_in.read() == true) continue;

	 // Chance to play dead for this cycle
	 if((unsigned(rand()) % 100) < _rxBusyChance) continue; 
	 

	 // Read the flit
	 msg_re_out.write(true);
	 reading = true;
		 
	    
      }
   }



#endif      

   // 
   // Private members
   // 

   // FIFO(s) for packets to be send
   queue<Packet*>            _packetsOut;
#ifdef USE_R3_WRAPPERS
   queue<Packet*>            _msgPacketsOut;
#endif

   // Expected packets by their ID
   multimap<sc_uint<16>, Packet*> _packetsIn;

   // agent identifier
   unsigned int _id; 
   
   // Agent might be busy doing other things occasionally 
   // Hence, transfer do not necessarily happen at max speed
   unsigned int _rxBusyChance;
   unsigned int _txBusyChance;

   // List of all agents is needed to notify them about 
   // new packets
   vector<Agent<addr_width_c, data_width_c, 
		comm_width_c, separate_addr_c>* >& _agents;

   // True when agent is locked
   bool _locked; 

};

#endif

// Local Variables:
// mode: c++
// c-file-style: "ellemtel"
// c-basic-offset: 3
// End:

