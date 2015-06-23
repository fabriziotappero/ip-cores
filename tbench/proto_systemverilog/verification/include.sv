typedef enum { NONE, TRANSMIT, RECEIVE } typeOfPkt;

typedef struct packed { 
   bit 	       startOfPacket;
   bit [63:0]  frame;
   bit 	       endOfPacket;
   bit [2:0]   packetModulus;
} packetFrame;

`define transmitData { packetData[7], packetData[6], packetData[5], packetData[4], packetData[3], packetData[2], packetData[1], packetData[0] }

`define receivedData { receivedData [7], receivedData[6], receivedData[5], receivedData[4], receivedData[3], receivedData[2], receivedData[1], receivedData[0] }
