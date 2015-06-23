
#include "FTD2XX.h"
#include <queue.h>

#define   DEFAULT_DEVICE           0
#define   INIT_CMD_SIZE            5
#define   MAX_TOTAL_PACKET         256-20
#define   MAX_TXD_PACKET           256
#define   MAX_RXD_PACKET           100
#define   ALMOST_FULL_SIZE         20

class USB_JTAG
{
     FT_HANDLE FT_Handle;
     FT_STATUS FT_Status;
     int  DeviceNumber;
     unsigned long  NumOfWritten;
     unsigned long  NumOfRead;
     unsigned char  Init_CMD[INIT_CMD_SIZE];
     unsigned char  Close_CMD;
     unsigned char  TXD_Buffer[MAX_TXD_PACKET];
     queue<unsigned char> Buffer;
public:
     USB_JTAG();
     FT_STATUS Get_Status();
     void Select_Device(int Number);
     int  Number_Of_Device();
     int  Number_Of_Queue_Data();
     bool Open_Device();
     bool Close_Device();
     bool Reset_Device(int sleep);
     bool Initial_JTAG();
     bool Write_Data(unsigned char* Source, int Size, int WithRead, bool Immediate);
     bool Read_Data(unsigned char* Dest, int Size);
     ~USB_JTAG();
};

/* TODO : USB_JTAG */
USB_JTAG::USB_JTAG()
{
     Init_CMD[0]    = 0x26;
     Init_CMD[1]    = 0x27;
     Init_CMD[2]    = 0x26;
     Init_CMD[3]    = 0x81;
     Init_CMD[4]    = 0x00;
     Close_CMD      = 0x1F;
     DeviceNumber   = DEFAULT_DEVICE;
     FT_Status      = FT_OK;
}

/* TODO : Get_Status */
FT_STATUS USB_JTAG::Get_Status()
{
     return FT_Status;
}

/* TODO : Select_Device */
void USB_JTAG::Select_Device(int Number)
{
     DeviceNumber=Number;
}

/* TODO : Number_Of_Device */
int  USB_JTAG::Number_Of_Device()
{
     unsigned long numDevs=0;
     FT_Status=FT_ListDevices(&numDevs,NULL,FT_LIST_NUMBER_ONLY);
     return numDevs;
}

/* TODO : Number_Of_Queue_Data */
int  USB_JTAG::Number_Of_Queue_Data()
{
     unsigned long numData=0;
     FT_Status=FT_GetQueueStatus(FT_Handle,&numData);
     return numData;
}

/* TODO : Open_Device */
bool USB_JTAG::Open_Device()
{
     FT_Status=FT_Open(DeviceNumber,&FT_Handle);
     if(FT_Status!=FT_OK)  return false;
     FT_SetLatencyTimer(FT_Handle,0x02);
     return true;
}

/* TODO : Close_Device */
bool USB_JTAG::Close_Device()
{
     FT_Status=FT_Write(FT_Handle,&Close_CMD,1,&NumOfWritten);
     if(FT_Status!=FT_OK)  return false;
     FT_Status=FT_Close(FT_Handle);
     if(FT_Status!=FT_OK)  return false;
     return true;
}

/* TODO : Reset_Device */
bool USB_JTAG::Reset_Device(int sleep)
{
     Close_Device();
     Sleep(sleep);
     Open_Device();
     Initial_JTAG();
     if(FT_Status!=FT_OK)  return false;
     return true;
}

/* TODO : Initial_JTAG */
bool USB_JTAG::Initial_JTAG()
{
     FT_Status=FT_Write(FT_Handle,Init_CMD,5,&NumOfWritten);
     if(FT_Status!=FT_OK)  return false;
     return true;
}

/* TODO : Write_Data */
bool USB_JTAG::Write_Data(unsigned char* Source, int Size, int WithRead, bool Immediate)
{
     int i;
     if(Size!=0)
     {
          //   Insert Write Command
          Buffer.push((unsigned char)Size|0x80);
          for(i=0;i<Size;i++)
          Buffer.push(Source[i]);
     }
     if(WithRead!=0)
     {
          //   Insert Read Command
          Buffer.push((unsigned char)WithRead|0xC0);
          for(i=0;i<WithRead;i++)
          Buffer.push(0x00);
     }
     //   Transfer Queue To Array
     int Trans_Size=Buffer.size();
     if(Immediate || Trans_Size>MAX_TXD_PACKET-ALMOST_FULL_SIZE)
     {
          for(i=0;i<Trans_Size;i++)
          {
               TXD_Buffer[i]=Buffer.front();
               Buffer.pop();
          }
          FT_Status=FT_Write(FT_Handle,TXD_Buffer,Trans_Size,&NumOfWritten);
     }
     if(FT_Status!=FT_OK)  return false;
     return true;
}

/* TODO : Read_Data */
bool  USB_JTAG::Read_Data(unsigned char* Dest, int Size)
{
     FT_Status=FT_Read(FT_Handle,Dest,Size,&NumOfRead);
     if(FT_Status!=FT_OK)  return false;
     return true;
}

/* TODO : ~USB_JTAG */
USB_JTAG::~USB_JTAG()
{
     Close_Device();
}


