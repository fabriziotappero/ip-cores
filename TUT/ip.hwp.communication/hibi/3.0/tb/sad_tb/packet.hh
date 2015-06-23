/*
 * Author: Lasse Lehtonen
 *
 * Packet that's sent through hibi
 *
 * $Id: packet.hh 2010 2011-10-07 08:16:05Z ege $
 *
 */

#ifndef SAD_HIBI_PACKET_HH
#define SAD_HIBI_PACKET_HH


#include "constants.hh"

#include <sstream>
using namespace std;

#include <systemc>
using namespace sc_core;
using namespace sc_dt;



class Packet
{
public:

   //* Constructor
   Packet(unsigned int words, sc_bv<addr_width_c> source,
	  sc_bv<addr_width_c> destination, HibiCommand command,
	  unsigned int data1 = 0, unsigned int data2 = 0,
	  unsigned int data3 = 0)
      : _words(words),
	_receivedWords(0),
	_source(source),
	_destination(destination),
	_command(command),
	_data(static_cast<sc_bv<data_width_c> >(0)),
	_id(Packet::packet_id),
	_respSize(0)
   {
      
      // Packet contents depend on the command: 
      // write, exclusive lock/release, read, config
      if(_command == DATA_WR ||
	 _command == MSG_WR ||
	 _command == DATA_WRNP ||
	 _command == MSG_WRNP ||
	 _command == EXCL_WR )
      {
	 _data = static_cast<sc_bv<data_width_c> >(Packet::packet_id);	 
      }
      else if(_command == EXCL_LOCK ||
	      _command == EXCL_RELEASE )
      {
	 _words = 1;
	 _data = static_cast<sc_bv<data_width_c> >(Packet::packet_id);
      }
      else if(_command == EXCL_RD ||
	      _command == DATA_RD ||
	      _command == MSG_RD ||
	      _command == DATA_RDL ||
	      _command == MSG_RDL)
      {
	 _data = _source;
	 _id = _source;
	 _respSize = data1;
      }
      else if(_command == CFG_WR)
      {
	 // data1 = cfg page, data2 = cfg slot, data3 = the data
	 // Sent addr must contain dst id, cfg page, and cfg param index
	 unsigned int pagesize = 2;
	 unsigned int pagewidth = 1;
	 unsigned int timeslots = n_time_slots_c == 0 ? 1 : n_time_slots_c;
	 while(pagesize < 9 + timeslots*3)
	 {
	    pagesize *= 2;
	    pagewidth++;
	 }
	 int totpages = 2;
	 unsigned int totpageswidth = 1;
	 while(totpages < n_cfg_pages_c)
	 {
	    totpages *= 2;
	    totpageswidth++;
	 }
	 _data = data3; 
	 _destination.range(addr_width_c-1, addr_width_c-id_width_c) =
	    destination.range(id_width_c-1, 0);
	 _destination.range(totpageswidth+pagewidth-1, pagewidth) = data1;
	 _destination.range(pagewidth-1, 0) = data2;
	 
      }
      else if(_command == CFG_RD)
      {
	 // data1 = cfg page, data2 = cfg index
	 // Sent addr must contain dst id, cfg page, and cfg param index
	 unsigned int pagesize = 2;
	 unsigned int pagewidth = 1;
	 unsigned int timeslots = n_time_slots_c == 0 ? 1 : n_time_slots_c;
	 while(pagesize < 9 + timeslots*3)
	 {
	    pagesize *= 2;
	    pagewidth++;
	 }
	 int totpages = 2;
	 unsigned int totpageswidth = 1;
	 while(totpages < n_cfg_pages_c)
	 {
	    totpages *= 2;
	    totpageswidth++;
	 }
	 _data = _source;
	 _destination.range(addr_width_c-1, addr_width_c-id_width_c) =
	    destination.range(id_width_c-1, 0);
	 _destination.range(totpageswidth+pagewidth-1, pagewidth) = data1;
	 _destination.range(pagewidth-1, 0) = data2;
      }
      else
      {
	 cout << "Unsupported command" << endl;
      }

      Packet::packet_id++;
   }

   //* Destructor
   ~Packet()
   {
      
   }

   //* Returns hibi command as a bit vector
   const sc_bv<comm_width_c>& getCommand() const
   { return commands_c[_command]; }

   //* Returns hibi command as enumeration
   const HibiCommand& getHibiCommand() const
   { return _command; }

   //* Returns destination address as a bit vector
   const sc_bv<addr_width_c>& getDstAddress() const
   { return _destination; }

   //* Returns source address as a bit vector
   const sc_bv<addr_width_c>& getSrcAddress() const
   { return _source; }

   //* Returns destination Id
   unsigned int getDstId() const
   { 
      return _destination.range(addr_width_c-1, addr_width_c-id_width_c).
	 to_uint(); 
   }

   //* Returns the data to send
   const sc_bv<data_width_c>& getData() const
   { return _data; }

   //* Returns packet's ID
   const sc_uint<16>& getId() const
   { return _id; }
   
   //* Returns packet's size in words
   const unsigned int& getSize() const
   { return _words; }

   //* Returns the number of received words
   const unsigned int& getReceived() const
   { return _receivedWords; }

   //* Returns packet's size in words
   const unsigned int& getResponseSize() const
   { return _respSize; }

   //* Increments received word counter
   void receiveWord()
   {      
      if(++_receivedWords > _words)
      {
	 ostringstream oss;
	 oss << "Received too many words for packet with id: " << _id;
	 SC_REPORT_FATAL(oss.str().c_str(),"");
      }
   }

   //* True if packet has received all words already
   bool complete()
   { return _receivedWords >= _words ? true : false; }

private:

   // This helps creating unique id for all packets
   static sc_uint<16> packet_id;
   
   // Other params for a packet. All commands do 
   // not need all these
   unsigned int        _words;         // num of data_words
   unsigned int        _receivedWords; // obsolete???
   sc_bv<addr_width_c> _source;        // return addr in read rq
   sc_bv<addr_width_c> _destination;   // where to send
   HibiCommand         _command;
   sc_bv<data_width_c> _data;          // remains same during burst
   sc_uint<16>         _id;            // uniques
   unsigned int        _respSize;      // #words reutrned in reads

};

// Initializing static class member 
sc_uint<16> Packet::packet_id = 100;

#endif

// Local Variables:
// mode: c++
// c-file-style: "ellemtel"
// c-basic-offset: 3
// End:

