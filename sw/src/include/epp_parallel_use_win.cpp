#include "delay.h"
#include "delay.c"
#include "epp_parallel_access_win.h"
#include "epp_parallel_use_win.h"

 
//// CONEXIÓN //////////////////////////////////////////////////////////////////////////////////////
EppParallelUseWin::EppParallelUseWin() 
{
  baseAddress = 0;
  status = loadDLL();
}


EppParallelUseWin::EppParallelUseWin(const short int &base_address) 
{
  status = loadDLL();
  if (status == PP_STATE_IDLE) 
  {
    status = negotiateEPP(base_address);
  }
}

EppParallelUseWin::~EppParallelUseWin()
{
  closeEPP();
}
  
 
 EppParallelUseWin::PPStatusType EppParallelUseWin::negotiateEPP()
{
    
  switch(status) 
  {
/*  case PP_RA_TIME_OUT:
    case PP_WA_TIME_OUT:
    case PP_RB_TIME_OUT:
    case PP_WB_TIME_OUT:
    case PP_RW_TIME_OUT:
    case PP_WW_TIME_OUT:*/
    case PP_TIME_OUT:
    case PP_CONECTED:
      closeEPP();
    case PP_STATE_IDLE:
    case PP_COMUNICATION_FAIL:
    case PP_NEGOTIATION_FAIL:
      char data; // temporales
      int i;
      // Resumen de señales de los regisros
      //+1(/Busy, Ackm,   Paper end,  Select,  Error,      nc,     nc,         EPPtimeout?)
      //+1(/Busy, Ackm,   PError,     Select,  nFault,      nc,     nc,         nc)
      //+2(nc,    nc,     PCD,        IRQE,   /SelectIn,  init,   /autofeed,  /strobe)
      
      // Se indican los números de eventos y los nombres de los tiempos de espera según estándar
      
      // evento -1
      data = PortIn(baseAddress+2) & 0xDE ;
      PortOut(baseAddress+2, data);
      udelay(1); // Tp

      // evento 0
      PortOut(baseAddress, 0x40);
      udelay(1); // Tp

      // evento 1
      data = PortIn(baseAddress+2) & 0xF7 | 0x02;
      PortOut(baseAddress+2, data);

      // evento 2
      for (i=0; i<35; i++)
      {
          udelay(1000);
          data = PortIn(baseAddress+1);
          if ( (data & 0x78) == 0x38) break;
              //select =1  nFault = 1 nack = 0 perror = 1
      }
      if (i >= 35) status = PP_COMUNICATION_FAIL;
      else
      {

          // evento 3
          data = PortIn(baseAddress+2) | 0x01; // nstrobe = 1
          PortOut(baseAddress+2, data);
          udelay(1); // Tp
          //+2(nc,    nc,     PCD,        IRQE,   /SelectIn,  init,   /autofeed,  /strobe)

          // evento 4
          data = PortIn(baseAddress+2) & 0xfc; // nstrobe = 0 nautofeed = 0
          PortOut(baseAddress+2, data);
          udelay(1); // Tp
          //+2(nc,    nc,     PCD,        IRQE,   /SelectIn,  init,   /autofeed,  /strobe)

          // evento 6
          for (i=0; i<35; i++)
          {
              udelay(1000);
              data = PortIn(baseAddress+1);
              if ( (data & 0x50) == 0x50) break;
                  //nack = 1 select = 1
                  //+1(/Busy, Ackm,   PError,     Select,  nFault,      nc,     nc,         nc)

          }

          if (i >= 35) status = PP_NEGOTIATION_FAIL;
          else status = PP_CONECTED;

      }
      break;
  
    default:      
     break;
  }
  return(status);
}
 
 
EppParallelUseWin::PPStatusType EppParallelUseWin::negotiateEPP(const unsigned short int &address)
{
  status = setBaseAddress(address);
  if (status == PP_STATE_IDLE) status = negotiateEPP();
  return(status);
  
}
 

void EppParallelUseWin::closeEPP()
{
  char data;
  //+2(nc,    nc,     PCD,        IRQE,   /SelectIn,  init,   /autofeed,  /strobe)

  
  // evento initialization
  data = PortIn(baseAddress+2) & 0xFB | 0x08; //ninit=0 nselectin=1
  PortOut(baseAddress+2, data);
  udelay(500); // T_ER

  // se realiza dos veces por las dudas
  data = PortIn(baseAddress+2) | 0x04; //ninit=1
  PortOut(baseAddress+2, data);
  udelay(500); // T_ER
  
  status = PP_STATE_IDLE;
}



EppParallelUseWin::PPStatusType EppParallelUseWin::setBaseAddress(const short int &address)
{

  if (address == 0x3BC || address == 0x378 || address == 0x278) 
  {    
    baseAddress = address;
    closeEPP(); // Reinicia interfaz y setea status a PP_STATE_IDLE
  }
  else
  {
    baseAddress = 0;
    status = PP_WRONG_BASE_ADDRESS;
  }
  return(status);
}

short int EppParallelUseWin::getBaseAddress() {return(baseAddress);}


// LECTURA/ESCRITURA DIRECCIÓN /////////////////////////////////////////////////////////////////////

void EppParallelUseWin::writeAddress(const char &address)
{
  if (testStatusForDataTransfer()) PortOut(baseAddress + 3, address);

}


//EppParallelUseWin::PPStatusType EppParallelUseWin::writeAddress(const char &address)
//{
//  if (testStatusForDataTransfer())
//  {
//      prepareTestDataTransfer();
//      PortOut(baseAddress + 3, address);
//      status = testDataTransfer();
//  }
//  return(status);
//}

void EppParallelUseWin::readAddress(char &return_address)
{
  if (testStatusForDataTransfer())  return_address = PortIn(baseAddress + 3);
}

//EppParallelUseWin::PPStatusType EppParallelUseWin::readAddress(char &return_address) const
//{
//  if (testStatusForDataTransfer())
//  {
//      prepareTestDataTransfer();
//      return_address = PortIn(baseAddress + 3);
//      status = testDataTransfer();
//  }
//  return(status);
//}

// LECTURA/ESCRITURA BYTE //////////////////////////////////////////////////////////////////////////
void EppParallelUseWin::writeByte(const char &byte)
{
  if (testStatusForDataTransfer()) PortOut(baseAddress + 4, byte);
}


void EppParallelUseWin::writeByte(const char &byte, const char &address)
{
  writeAddress(address);
  if (testStatusForDataTransfer()) PortOut(baseAddress + 4, byte);
}


//EppParallelUseWin::PPStatusType EppParallelUseWin::writeByte(const char &byte) const
//{
//  if (testStatusForDataTransfer())
//  {
//    prepareTestDataTransfer();
//    PortOut(baseAddress + 4, byte);
//    status = testDataTransfer();
//  }
//  return(status);
//}
//
//
//EppParallelUseWin::PPStatusType EppParallelUseWin::writeByte(const char &byte, const char &address) const
//{
//  status = writeAddress(address);
//  if (status == PP_CONECTED)
//  {
//    prepareTestDataTransfer();
//    PortOut(baseAddress + 4, byte);
//    status = testDataTransfer();
//  }
//  return(status);
//}


void EppParallelUseWin::readByte(char &return_byte)
{
  if (testStatusForDataTransfer()) return_byte = PortIn(baseAddress+4);
}


void EppParallelUseWin::readByte(char &return_byte, const char &address)
{
  writeAddress(address);
  if (testStatusForDataTransfer()) return_byte = PortIn(baseAddress + 4);
}


//EppParallelUseWin::PPStatusType EppParallelUseWin::readByte(char &return_byte) const
//{
//  if (testStatusForDataTransfer())
//  {
//    prepareTestDataTransfer();
//    return_byte = PortIn(baseAddress + 4);
//    status = testDataTransfer();
//  }
//  return(status);
//}
//
//
//EppParallelUseWin::PPStatusType EppParallelUseWin::readByte(char &return_byte, const char &addresss) const
//{
//  status = writeAddress(address);
//  if (status == PP_CONECTED)
//  {
//    prepareTestDataTransfer();
//    return_byte = PortIn(baseAddress + 4);
//    status = testDataTransfer();
//  }
//  return(status);
//}


// LECTURA/ESCRITURA WORD //////////////////////////////////////////////////////////////////////////
void EppParallelUseWin::writeWord(const unsigned short int &word)
{
  if (testStatusForDataTransfer())
  {
    char data;
    data = word & 0x00FF;
    PortOut(baseAddress + 4, data);
    data = (word & 0xFF00) >> 8;
    PortOut(baseAddress + 4, data);
  }
}


void EppParallelUseWin::writeWord(const unsigned short int &word, const char &address)
{
  writeAddress(address);
  writeWord(word);
}


//EppParallelUseWin::PPStatusType EppParallelUseWin::writeWord(const short int &word) const
//{
//  if (testStatusForDataTransfer())
//  {
//    prepareTestDataTransfer();
//    char data;
//    data = word & 0xFF;
//    PortOut(baseAddress + 4, data);
//    data = (word & 0xFF00) >> 8;
//    PortOut(baseAddress + 4, data);
//    status = testDataTransfer();
//  }
//  return(status);
//}
//
//
//EppParallelUseWin::PPStatusType EppParallelUseWin::writeWord(const short int &word, const char &address) const
//{
//  status = writeAddress(address);
//  if (status == PP_CONECTED)
//  {
//    prepareTestDataTransfer();
//    char data;
//    data = word & 0xFF;
//    PortOut(baseAddress + 4, data);
//    data = (word & 0xFF00) >> 8;
//    PortOut(baseAddress + 4, data);
//    status = testDataTransfer();
//  }
//  return(status);
//}


void EppParallelUseWin::readWord(unsigned  int &return_word)
{
  if (testStatusForDataTransfer()) 
  {
    unsigned int data;
   
    data = PortIn(baseAddress + 4) & 0x00FF;
    data = (PortIn(baseAddress + 4) << 8) | data;
   // udelay(600);
    return_word = data & 0xFFFF;
  }
}


void EppParallelUseWin::readWord(unsigned int &return_word, const char &address)
{
  writeAddress(address);
  readWord(return_word); 
}


//EppParallelUseWin::PPStatusType EppParallelUseWin::readWord(short int &return_word) const
//{
//  if (testStatusForDataTransfer())
//  {
//    prepareTestDataTransfer();
//    short int data;
//    data = PortIn(baseAddress + 4);
//    data = PortIn(baseAddress + 4) << 8 | data;
//    return_word = data;
//    status = testDataTransfer();
//  }
//  return(status);
//}
//
//
//EppParallelUseWin::PPStatusType EppParallelUseWin::readWord(short int &return_word, const char &address) const
//{
//  status = writeAddress(address);
//  if (status == PP_CONECTED)
//  {
//    prepareTestDataTransfer();
//    short int data;
//    data = PortIn(baseAddress + 4);
//    data = PortIn(baseAddress + 4) << 8 | data;
//    return_word = data;
//    status = testDataTransfer();
//  }
//  return(status);
//}


// LECTURA DE ESTADO DE CONEXIÓN ///////////////////////////////////////////////////////////////////
EppParallelUseWin::PPStatusType EppParallelUseWin::getStatus() {return(status);}


// FUNCIONES PRIVADAS //////////////////////////////////////////////////////////////////////////////
EppParallelUseWin::PPStatusType EppParallelUseWin::loadDLL()
{
    int result;

    LoadIODLL();
    result = IsDriverInstalled(); // Funcion de testeo
    if (result == 0) { 
          LoadIODLL(); // Segundo intento, corrige errores en Windows Vista
          result = IsDriverInstalled();
          if (result == 0) return(PP_LOAD_LIBRARY_FAIL);
          else return(PP_STATE_IDLE);
    }
    else return(PP_STATE_IDLE);
}


bool EppParallelUseWin::testStatusForDataTransfer()
{
  switch(status)
  {
    case PP_CONECTED:
  /*  case PP_RA_TIME_OUT:
    case PP_WA_TIME_OUT:
    case PP_RB_TIME_OUT:
    case PP_WB_TIME_OUT:
    case PP_RW_TIME_OUT:
    case PP_WW_TIME_OUT:*/
    case PP_TIME_OUT:
      return(1);
      break;
    default:
      return(0);
      break;
  }
}


void EppParallelUseWin::prepareTestDataTransfer()
{
  char data; // temporal
  data = PortIn(baseAddress + 1) & 0xFE ; //EPP timeout = 0
  PortOut(baseAddress + 1, data);
}


EppParallelUseWin::PPStatusType EppParallelUseWin::testDataTransfer()
{
  char data;
  //udelay(50);
  data = PortIn(baseAddress + 1) & 0x01 ; // leer EPP timeout
  prepareTestDataTransfer();
  switch (data)
  {
    case 0:
      return(PP_CONECTED);
      break;
    default:
      return(PP_TIME_OUT);
      break;
  }
}
