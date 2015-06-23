#device PIC16F54

#define    PORT_DATA        *(unsigned char*)0 
#define    IN_PORT_ADDR     *(unsigned char*)1 
#define    OUT_PORT_ADDR    *(unsigned char*)2 
#define    STATUS           *(unsigned char*)3 

#define PORT_ADDR_SEG    0
#define PORT_ADDR_LED    8
#define PORT_ADDR_SW     9
#define PORT_ADDR_KEY    10  
#define PORT_ADDR_BEEP   11 

void outport(unsigned  char addr,unsigned char data)
{
   OUT_PORT_ADDR = addr;
   PORT_DATA = data;
}

unsigned char inport(unsigned char addr)
{
   IN_PORT_ADDR = addr;
   return PORT_DATA;
}

#define GetKey() inport(PORT_ADDR_KEY)
#define GetSwich() inport(PORT_ADDR_SW)
#define BeepSet(data) outport(PORT_ADDR_BEEP,data)
   #define BeepON() outport(PORT_ADDR_BEEP,1)
   #define BeepOFF() outport(PORT_ADDR_BEEP,0)
#define SetLed(data) outport(PORT_ADDR_LED,data)

#define Seg7Led(addr,data) outport(addr,data)
   #define Seg7Led0(data)  outport(0,data)
   #define Seg7Led1(data)  outport(1,data)
   #define Seg7Led2(data)  outport(2,data)
   #define Seg7Led3(data)  outport(3,data)
   #define Seg7Led4(data)  outport(4,data)
   #define Seg7Led5(data)  outport(5,data)
   #define Seg7Led6(data)  outport(6,data)
   #define Seg7Led7(data)  outport(7,data)
   

void main()
{
     unsigned char i;
      while(1){ 
      i=GetSwich();
      SetLed(i);
      }

}
