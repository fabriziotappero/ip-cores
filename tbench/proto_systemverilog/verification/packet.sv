
/**
 * packet class file for 10 GE MAC Core.
 * The file holds packet class according to specs
 * @file: packet.sv
 * @author: Pratik Mahajan
 * @par Contact: pratik@e-pigeonpost.com
 * @par Company: NA (UCSC systemverilog for adv. verification course)
 * 
 * @version:
 * $LastChangedRevision$
 * @par Last Changed Date:
 * $LastChangedDate$
 * @par Last Changed By:
 * $LastChangedBy$
 * 
 */

/**
 * Packet class to represent packet for ethernet MAC core as per specs.
 * Class declaration and related methods
 * @class: packet
 */

class packet;

   rand bit [7:0] 	packetData [8];		///< random data variable used to send data in DUT
   bit [7:0] 		receivedData [8];   	///< placeholder variable for received data from DUT -- can't be same as packetData since transmission and reception can be full-duplex
   bit [2:0] 		packetLengthModulus;	///< modulus to report number of octates in last word of communication
   bit 			startOfPacket;		
   bit 			endOfPacket;
   bit 			packetValid;

   bit 			transmitFIFOFull;
   bit 			receiveReadEnable;
   bit 			receiveError;
   bit 			receiveAvailable;

   static bit [15:0] 	transmitPktId;
   static bit [15:0] 	receivePktId;

   typeOfPkt		pktClassPktType;

//`define printData { packetData[7], packetData[6], packetData[5], packetData[4], packetData[3], packetData[2], packetData[1], packetData[0] }

//`define printReceipt { receivedData [7], receivedData[6], receivedData[5], receivedData[4], receivedData[3], receivedData[2], receivedData[1], receivedData[0] }
   
   /**
    * Constructor for packet class.
    * It simply increments count of packet id depending on type of packet
    * @param typeOfPkt: input type to count number of packets sent / received.
    * @return : NA (creates objects and returns handle)
    */
   function new (input int pktClassPktType = NONE);
      if (pktClassPktType == TRANSMIT)
	transmitPktId++;
	 
      if (pktClassPktType == RECEIVE) 
	receivePktId++; 
   endfunction // new

   /**
    * Print function for packet class.
    * prints relevant information for each frame transfered
    * @param: NA
    * @return: NA
    */
   function void print (input int pktClassPktType = NONE);
      if (pktClassPktType == TRANSMIT)
	$display (" [Time %0t ps] SOP = %b, Transmitted Data = %x, EOP = %b, Modulus = %h ", $time, startOfPacket, `transmitData, endOfPacket, packetLengthModulus);
      if (pktClassPktType == RECEIVE)
	$display (" [Time %0t ps] SOP = %b, Received Data = %x, EOP = %b, Modulus = %h ", $time, startOfPacket, `receivedData, endOfPacket, packetLengthModulus);
   endfunction: print
   
endclass // packet
