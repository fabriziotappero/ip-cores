/*
 * Author: Lasse Lehtonen
 *
 * Stimuli creation for hibi
 * 
 *
 * $Id: stimuli.hh 2008 2011-10-06 13:49:53Z ege $
 *
 *
 * Most of the commands use agent position in the vector as the source
 * and destination (0-11 if you have 12 agents, which are not same as
 * wrapper ids!). Conf read commands need the receiving wrapper's id.
 * 
 * 
 *
 *
 *
 *
 *
 */

#ifndef SAD_HIBI_STIMULI_HH
#define SAD_HIBI_STIMULI_HH

#include "constants.hh"
#include "top_level.hh"
#include "packet.hh"

#include <iostream>
#include <vector>
using namespace std;

#include <systemc>
using namespace sc_core;
using namespace sc_dt;


class Stimuli : public sc_module
{
public:

   SC_HAS_PROCESS(Stimuli);

   //* Constructor, launch the main thread
   Stimuli(sc_module_name name, TopLevel& toplevel)
      : sc_module(name),
	_top(toplevel)
   {
      for(int i = 0; i < n_agents_c; ++i)
      {
	 _lastAddress[i] = addresses_c[i];
      }

      SC_THREAD(thread);
   }

   //* Destructor
   ~Stimuli()
   {

   }


   //* Main stimuli creation thread that orchestrates everythingys
   void thread()
   {     
      wait(42, SC_NS);

      cout << endl << "SAD HIBI TESTBENCH STARTING" << endl << endl;

      wait(58, SC_NS);
      _top.setResetN(true); // Release reset


      /*

      for(unsigned int a = 0; a < 4; ++a)
      {
	 setRxBusyChance(a, 50);
      }

      for(unsigned int i = 0; i < 625; ++i)
      {
	 for(unsigned int a = 0; a < 4; ++a)
	 {
	    writeNpData(16, a, 3-a, true);
	 }
      }
      
      waitAllPacketsReceived(sc_time(10, SC_MS));

      */

      

      // 1. two packets from agent 0 to 1 
      cout << "Phase 1. Write" << endl;
      wait(1, SC_US);
      writeNpData(4, 0, 1);      // #words, source, destination
      wait(100, SC_NS);
      writeNpData(6, 2, 1);
      
      // Wait that all sent packets packet reach their destinations (timeout)
      waitAllPacketsReceived(sc_time(100, SC_US));


      // 2. Now, agent 1 is busy with 80% chance (per clock cycle)
      cout << "Phase 2. Write but receiver partly busy" << endl;
      setRxBusyChance(1, 80);

      // and two packets again and wait that they are received
      writeNpData(8, 0, 1);
      wait(100, SC_NS);
      writeNpData(16, 2, 1);      
      waitAllPacketsReceived(sc_time(100, SC_US));



      // 3. Send lots of small packets to one target
      cout << "Phase 3. Write lots of small packets to one target" << endl;
      writeNpData(4, 0, 1);
      writeNpData(4, 0, 1);
      writeNpData(4, 0, 1);
      writeNpData(4, 0, 1);
      writeNpData(4, 0, 1);
      writeNpData(4, 0, 1);
      writeNpData(4, 0, 1);
      writeNpData(4, 0, 1);
      writeNpData(4, 0, 1);
      writeNpData(4, 0, 1);
      writeNpData(4, 0, 1);
      writeNpData(4, 0, 1);
      writeNpData(4, 0, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 2, 1);
      writeNpData(4, 3, 1);
      writeNpData(4, 3, 1);
      writeNpData(4, 3, 1);
      writeNpData(4, 3, 1);
      writeNpData(4, 3, 1);
      writeNpData(4, 3, 1);
      writeNpData(4, 3, 1);
      writeNpData(4, 3, 1);
      writeNpData(4, 3, 1);
      writeNpData(4, 3, 1);

      // Wait for all packets to be received
      waitAllPacketsReceived(sc_time(1000, SC_US));

      // Agent 1 is not busy anymore
      setRxBusyChance(1, 0);




      // 4.Read config mems: reader, dst, page, slot, expected value
      cout << "Phase 4. Read and write configurations" << endl;
      readCfg(0, 2, 1, 1, 2); // Prior should matche id
      readCfg(0, 3, 1, 1, 3);
      readCfg(0, 4, 1, 1, 4);

      waitAllPacketsReceived(sc_time(100, SC_US));     

      // Write config mem, src, dst, page, slot, data
      writeCfg(0, 2, 1, 1, 4);  // Changing priorities
      writeCfg(0, 3, 1, 1, 2);
      writeCfg(0, 4, 1, 1, 3);

      waitAllPacketsReceived(sc_time(100, SC_US));     

      // Read config mems: src, dst, page, slot, expected value
      readCfg(0, 2, 1, 1, 4);
      wait(300, SC_NS);
      readCfg(0, 3, 1, 1, 2);
      wait(300, SC_NS);
      readCfg(0, 4, 1, 1, 3);

      waitAllPacketsReceived(sc_time(100, SC_US));     

      // Write config mem, src, dst, page, slot, data
      writeCfg(0, 2, 1, 1, 2); // Changing priorities back to defaults
      writeCfg(0, 3, 1, 1, 3); 
      writeCfg(0, 4, 1, 1, 4);

      waitAllPacketsReceived(sc_time(100, SC_US));     
      
      // Read config mems: src, dst, page, slot, expected value
      readCfg(0, 2, 1, 1, 2);
      wait(300, SC_NS);
      readCfg(0, 3, 1, 1, 3);
      wait(300, SC_NS);
      readCfg(0, 4, 1, 1, 4);

      waitAllPacketsReceived(sc_time(100, SC_US));     

      // Configure all to some power mode (no idea)
      writeCfg(0, 0, 1, 4, 0);

      waitAllPacketsReceived(sc_time(100, SC_US));     
      

      // This killed the previous hibi version, agent 3 rx_ctrl went nuts
      // agents 0-2 read the power mode of agent 3
      readCfg(0, 4, 1, 4, 0);
      readCfg(1, 4, 1, 4, 0);
      readCfg(2, 4, 1, 4, 0);
      
      waitAllPacketsReceived(sc_time(100, SC_US));     
      wait(1, SC_US);	 

      

      
      // 5. Reading config mem from agents that are sending
      // Read config mems: src, dst, page, slot, expected value
      cout << "Phase 5. Reading configuration from a sending wrapper" << endl;
      writeNpData(200, 1, 0);      // size, source, destination
      wait(200, SC_NS);
      readCfg(0, 2, 1, 1, 2);
      readCfg(0, 3, 1, 1, 3);
      readCfg(0, 4, 1, 1, 4);
      wait(20, SC_NS);
      writeNpData(8, 1, 0);      // size, source, destination
      wait(20, SC_NS);
      writeNpData(4, 2, 3);      // size, source, destination
      wait(20, SC_NS);
      writeNpData(4, 2, 0);      // size, source, destination
      wait(20, SC_NS);
      writeNpData(8, 3, 2);      // size, source, destination

      waitAllPacketsReceived(sc_time(100, SC_US));           

      
      // 6. Send read commands
      cout << "Phase 6. Read" << endl;
      readData(10, 0, 3);
      readData(10, 1, 3);
      readData(10, 2, 3);

      waitAllPacketsReceived(sc_time(100, SC_US));      

      // 7. Test exclusiveness
      cout << "Phase 7. Exclusive access" << endl;
      lockExclusive(0, 1);
      wait(100, SC_NS);
      writeExclusive(100, 0, 1);
      writeNpData(50, 2, 1);
      wait(1, SC_US);
      releaseExclusive(0, 1);

      waitAllPacketsReceived(sc_time(100, SC_US));      


      setRxBusyChance(1, 85);
      lockExclusive(0, 1);
      wait(100, SC_NS);
      readExclusive(10, 0, 1);
      wait(300, SC_NS);
      writeExclusive(100, 0, 1);
      writeNpData(50, 2, 1);
      wait(1, SC_US);
      releaseExclusive(0, 1);
	 
      waitAllPacketsReceived(sc_time(100, SC_US));      


      setRxBusyChance(1, 85);
      writeNpData(50, 2, 1);
      wait(100, SC_NS);
      lockExclusive(0, 1);
      wait(100, SC_NS);
      readExclusive(10, 0, 1);
      wait(300, SC_NS);
      writeExclusive(10, 0, 1);      
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);      
      wait(300, SC_NS);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeExclusive(10, 0, 1);
      writeNpData(50, 2, 1);
      wait(1, SC_US);
      releaseExclusive(0, 1);
	 
      waitAllPacketsReceived(sc_time(1000, SC_US));      




      // 8. Communicate over bridge, normal commands
      cout << "Phase 8. Write over the bridges" << endl;
      setRxBusyChance(0, 85);
      setRxBusyChance(1, 85);
      setRxBusyChance(2, 85);
      setRxBusyChance(3, 85);
      setRxBusyChance(4, 85); // all agents are bit slow to read
      readData(10, 4, 0);
      readData(10, 4, 1);
      readData(10, 4, 2);
      readData(10, 4, 3);
      writeNpData(4, 0, 4);
      writeNpData(4, 1, 4);
      writeNpData(4, 2, 4);
      writeNpData(4, 3, 4);
      writeNpData(4, 0, 4);
      writeNpData(4, 1, 4);
      writeNpData(4, 2, 4);
      writeNpData(4, 3, 4);
      writeNpData(4, 0, 4);
      writeNpData(4, 1, 4);
      writeNpData(4, 2, 4);
      writeNpData(4, 3, 4);
      writeNpData(4, 0, 4);
      writeNpData(4, 1, 4);
      writeNpData(4, 2, 4);
      writeNpData(4, 3, 4);
      writeNpData(4, 4, 0);
      writeNpData(4, 4, 1);
      writeNpData(4, 4, 2);
      writeNpData(4, 4, 3);
            
      waitAllPacketsReceived(sc_time(1000, SC_US));      

      // 9. Exclusive and normal writes over bridge
      cout << "Phase 9. Normal and exclusive writes over the bridges" << endl;
      writeNpData(50, 6, 1);
      writeNpData(50, 0, 1);
      wait(200, SC_NS);

      lockExclusive(4, 1);
      writeExclusive(10, 4, 1);
      writeExclusive(10, 4, 1);
      writeExclusive(10, 4, 1);
      writeExclusive(10, 4, 1);
      writeExclusive(10, 4, 1);
      writeExclusive(10, 4, 1);
      writeExclusive(10, 4, 1);
      writeExclusive(10, 4, 1);
      writeExclusive(10, 4, 1);
      writeExclusive(10, 4, 1);
      writeExclusive(10, 4, 1);
      releaseExclusive(4, 1);
      
      writeNpData(50, 2, 5);
      writeNpData(50, 3, 5);

      wait(200, SC_NS);

      lockExclusive(1, 5);
      writeExclusive(10, 1, 5);
      writeExclusive(10, 1, 5);
      writeExclusive(10, 1, 5);
      writeExclusive(10, 1, 5);
      writeExclusive(10, 1, 5);
      releaseExclusive(1, 5);

      waitAllPacketsReceived(sc_time(1000, SC_US));      


      writeNpData(100, 8, 1);
      writeNpData(100, 5, 1);
      writeNpMsg(100, 9, 2);
      writeNpMsg(100, 4, 1);
      readCfg(0, 6, 1, 1, 1);
      readCfg(0, 7, 1, 1, 2);
      readCfg(0, 8, 1, 1, 3);
      
      wait(200, SC_NS);

      lockExclusive(11, 2);      
      writeExclusive(10, 11, 2);
      writeExclusive(10, 11, 2);
      writeExclusive(10, 11, 2);
      writeExclusive(10, 11, 2);
      writeExclusive(10, 11, 2);
      writeExclusive(10, 11, 2);
      writeExclusive(10, 11, 2);
      writeExclusive(10, 11, 2);
      writeExclusive(10, 11, 2);
      writeExclusive(10, 11, 2);
      writeExclusive(10, 11, 2);
      releaseExclusive(11, 2);

      waitAllPacketsReceived(sc_time(2, SC_MS));

      
      // 10. Regular and message to write to busy agents
      cout << "Phase 10. Many reg/Msg writes to busy agents" << endl;
      setRxBusyChance(5, 85);
      setRxBusyChance(6, 85);
      setRxBusyChance(7, 85);
      setRxBusyChance(8, 85);
      setRxBusyChance(9, 85);
      setRxBusyChance(10, 85);
      setRxBusyChance(11, 85);

      for(unsigned int i = 0; i < 100; ++i)
      {
	 writeNpData(1, 8, 0);
	 writeNpData(1, 9, 1);
	 writeNpMsg(1, 10, 4);
	 writeNpMsg(1, 11, 5);
	 
	 writeNpData(1, 4, 2);
	 writeNpData(1, 5, 3);
	 writeNpMsg(1, 6, 6);
	 writeNpMsg(1, 7, 7);
	 
	 writeNpData(1, 0, 4);
	 writeNpData(1, 1, 8);
	 writeNpMsg(1, 2, 7);
	 writeNpMsg(1, 3, 11);
	 
	 wait(200, SC_NS);
      }

      readCfg(0, 2, 1, 1, 2);
      readCfg(0, 3, 1, 1, 3);
      readCfg(0, 4, 1, 1, 4);

      for(unsigned int i = 0; i < 1000; ++i)
      {
	 writeNpData(1, 8, 0);
	 writeNpMsg(2, 8, 0);
	 
	 writeNpData(2, 9, 1);
	 writeNpMsg(1, 9, 1);
	 
	 writeNpMsg(1, 10, 4);
	 writeNpData(1, 10, 4);

	 writeNpMsg(1, 11, 5);
	 writeNpData(1, 11, 5);
	 
	 writeNpData(1, 4, 2);
	 writeNpMsg(1, 4, 2);

	 writeNpData(1, 5, 3);
	 writeNpMsg(3, 5, 3);

	 writeNpMsg(1, 6, 6);
	 writeNpData(1, 6, 6);

	 writeNpMsg(1, 7, 7);
	 writeNpData(3, 7, 7);
	 
	 writeNpData(1, 0, 4);
	 writeNpMsg(1, 0, 4);

	 writeNpData(1, 1, 8);
	 writeNpMsg(1, 1, 8);

	 writeNpMsg(1, 2, 7);
	 writeNpData(1, 2, 7);
	 
	 writeNpMsg(1, 3, 11);
	 writeNpData(1, 3, 11);
	 wait(600, SC_NS);
      }

      readCfg(1, 2, 1, 1, 2);
      readCfg(1, 3, 1, 1, 3);
      readCfg(1, 4, 1, 1, 4);

      readCfg(2, 3, 1, 1, 3);
      readCfg(2, 4, 1, 1, 4);
      readCfg(2, 5, 1, 1, 5);

      // 11. Regular and message to write to busy agents
      cout << "Phase 11. Lots of excl. accesses to busy agents over the bridges" << endl;

      for(unsigned int i = 0; i < 1000; ++i)
      {
	 if(i % 10 == 0)
	 {
	    lockExclusive(10, 1);
	    writeExclusive(1, 10, 1);	  
	    releaseExclusive(10, 1);

	    lockExclusive(2, 9);
	    writeExclusive(2, 2, 9);	  
	    releaseExclusive(2, 9);
	 }

	 writeNpData(1, 8, 0);
	 writeNpMsg(2, 8, 0);
	 
	 writeNpData(2, 9, 1);
	 writeNpMsg(1, 9, 1);
	 
	 writeNpMsg(1, 10, 4);
	 writeNpData(1, 10, 4);

	 writeNpMsg(1, 11, 5);
	 writeNpData(1, 11, 5);
	 
	 writeNpData(1, 4, 2);
	 writeNpMsg(1, 4, 2);

	 writeNpData(1, 5, 3);
	 writeNpMsg(3, 5, 3);

	 writeNpMsg(1, 6, 6);
	 writeNpData(1, 6, 6);

	 wait(200, SC_NS);

	 writeNpMsg(1, 7, 7);
	 writeNpData(3, 7, 7);
	 
	 writeNpData(1, 0, 4);
	 writeNpMsg(1, 0, 4);

	 writeNpData(1, 1, 8);
	 writeNpMsg(1, 1, 8);

	 writeNpMsg(1, 2, 7);
	 writeNpData(1, 2, 7);
	 
	 writeNpMsg(1, 3, 11);
	 writeNpData(1, 3, 11);

	 if(i % 10 == 1)
	 {
	    lockExclusive(10, 1);
	    writeExclusive(1, 10, 1);	  	    

	    lockExclusive(2, 9);
	    writeExclusive(2, 2, 9);	  

	    wait(8000, SC_NS);

	    releaseExclusive(10, 1);
	    releaseExclusive(2, 9);
	 }

      }

      
      waitAllPacketsReceived(sc_time(12, SC_MS));
      
      

      cout << endl << "SAD HIBI TESTBENCH FINISHED" << endl << endl;
      cout << "Remember to grep output for warnings" << endl << endl;
      sc_stop();
   }





private:

   // 
   // Set of helper functions to create packets
   // 5 categories: excl, read, write, cfg, and wait
   // Most functions just call source and dst agents with packet params
   //

   //
   // Exclusive acecsses
   // 
   void releaseExclusive(unsigned int src, unsigned int dst)
   {
      Packet* packet = 0;
      packet = new Packet(1, addresses_c[src], addresses_c[dst], EXCL_RELEASE);
      _top.agents.at(src)->send(packet);
      _top.agents.at(dst)->expect(packet);
   }


   void lockExclusive(unsigned int src, unsigned int dst)
   {
      Packet* packet = 0;
      packet = new Packet(1, addresses_c[src], addresses_c[dst], EXCL_LOCK);
      _top.agents.at(src)->send(packet);
      _top.agents.at(dst)->expect(packet);
   }

   
   void writeExclusive(unsigned int size, unsigned int src, unsigned int dst)
   {
      Packet* packet = 0;
      packet = new Packet(size, addresses_c[src], addresses_c[dst], EXCL_WR);
      _top.agents.at(src)->send(packet);
      _top.agents.at(dst)->expect(packet);
   }


   void readExclusive(unsigned int size,  unsigned int src, unsigned int dst)
   {
      Packet* packet = 0;
      packet = new Packet(1, addresses_c[src], addresses_c[dst], 
			  EXCL_RD, size);
      _top.agents.at(src)->send(packet);
      _top.agents.at(dst)->expect(packet);
   }


   //
   // Reading 
   // 
   void readData(unsigned int size,  unsigned int src, unsigned int dst)
   {
      Packet* packet = 0;
      packet = new Packet(1, addresses_c[src], addresses_c[dst], DATA_RD, size);
      _top.agents.at(src)->send(packet);
      _top.agents.at(dst)->expect(packet);
   }


   void readMsg(unsigned int size,  unsigned int src, unsigned int dst)
   {
      Packet* packet = 0;
      packet = new Packet(1, addresses_c[src], addresses_c[dst], MSG_RD, size);
      _top.agents.at(src)->send(packet);
      _top.agents.at(dst)->expect(packet);
   }

   //  
   // Configure the agent 
   //
   //* Sets the probability for agent to be busy (per clock cycle)
   void setRxBusyChance(unsigned int agent, unsigned int chance)
   {
      _top.agents.at(agent)->setRxBusyChance(chance); 
   }

   //* Sets the probability for agent to be busy (per clock cycle)
   void setTxBusyChance(unsigned int agent, unsigned int chance)
   {
      _top.agents.at(agent)->setTxBusyChance(chance); 
   }

   //
   // Writing 
   //
   //* Sends a regular packet from agent src to agent dst, np=nonposted
   void writeNpData(unsigned int size, unsigned int src, unsigned int dst,
		    bool useDiffAddr = true)
   {
      sc_bv<addr_width_c> addr = _lastAddress[dst];

      if(useDiffAddr)
      {
	 // Using different address than last time
	 if(addr == addresses_max_c[dst])
	 {
	    addr = addresses_c[dst]; // Wrap around
	 }
	 else
	 {
	    addr = sc_bv<addr_width_c>(addr.to_uint() + 1);
	 }
	 _lastAddress[dst] = addr;
      }

      Packet* packet = 0;
      packet = new Packet(size, addresses_c[src], addr, DATA_WRNP);
      _top.agents.at(src)->send(packet);
      _top.agents.at(dst)->expect(packet);
   }


   //* Sends a message packet from agent src to agent dst, nonposted
   void writeNpMsg(unsigned int size, unsigned int src, unsigned int dst)
   {
      Packet* packet = 0;
      packet = new Packet(size, addresses_c[src], addresses_c[dst], MSG_WRNP);
      _top.agents.at(src)->send(packet);
      _top.agents.at(dst)->expect(packet);
   }

   //
   // Configuring the HIBI
   //
   //* Read one config mem slot
   void readCfg(unsigned int src, unsigned int dst, unsigned int page,
		unsigned int slot, unsigned int expectedData)
   {
      Packet* packet = 0;
      packet = new Packet(1, addresses_c[src], dst, CFG_RD,
			  page, slot);
      _top.agents.at(src)->send(packet);
      _top.agents.at(src)->expect(packet, expectedData);
   }


   //* write one config mem slot
   void writeCfg(unsigned int src, unsigned int dst, unsigned int page,
		 unsigned int slot, unsigned int data)
   {
      Packet* packet = 0;
      packet = new Packet(1, addresses_c[src], dst, CFG_WR,
			  page, slot, data);
      _top.agents.at(src)->send(packet);
   }


   // 
   // Waiting
   // 
   //* Waits for all packets to be received or timeout which ever comes first
   //* Returns false if timeout was first
   bool waitAllPacketsReceived(sc_time timeout)
   {
      sc_time startWaiting = sc_time_stamp();
      bool endWait = true;
      while(endWait)
      {
	 wait(1, SC_US);	 
	 // End if all packets have been received	 
	 bool stillPacketsOutThereInTheVoid = false;
	 for(unsigned int i = 0; i < _top.agents.size(); ++i)
	 {
	    if(_top.agents.at(i)->allDone() == false)
	    {
	       stillPacketsOutThereInTheVoid = true;
	    }
	 }
	 endWait = stillPacketsOutThereInTheVoid;
	 // End anyway when waited more than timeout
	 if(sc_time_stamp() - startWaiting > timeout)
	 {
	    ostringstream oss;
	    oss << "At " << sc_time_stamp().to_double() << " : "
		<< "timeout failed when waiting for all packets to complete";
	    SC_REPORT_WARNING("warning", oss.str().c_str());
	    for(unsigned int i = 0; i < _top.agents.size(); ++i)
	    {
	       if(_top.agents.at(i)->allDone() == false)
	       {
		  cout << " - Agent " << i << " excpecting packet(s)" << endl;
		  _top.agents.at(i)->printExpected();
	       }
	    }
	    return false;
	 }
      }
      wait(1, SC_US);	 
      cout << "At " << setprecision(10) << sc_time_stamp().to_double()
	   << " : ** All packets have been received **"  << endl;
      return true;
   }

   /*
    *  MEMBER VARIABLES
    */

   // Pointer to toplevel where the agents are
   TopLevel& _top;

   sc_bv<addr_width_c> _lastAddress[n_agents_c];

};

#endif

// Local Variables:
// mode: c++
// c-file-style: "ellemtel"
// c-basic-offset: 3
// End:

