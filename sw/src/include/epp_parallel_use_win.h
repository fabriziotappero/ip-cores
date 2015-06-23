/*
*


* Check action status is forced when return value is used.
*  When reading the port, data is obtaiend by reference (for consistency)

*/



#ifndef EPP_PARALLEL_USE_WIN_H
#define EPP_PARALLEL_USE_WIN_H

#include "epp_parallel_access_win.h"


class EppParallelUseWin {
  public:
    enum PPStatusType
    {
      PP_STATE_IDLE = 0,         // Estado inicial, sin negociación previa
      PP_CONECTED = 1,           // Luego de la negociación
      PP_COMUNICATION_FAIL = 2,  // Fallo en la comunicación (dispositivo no accesible o 
                                 //  desconectado)
      PP_NEGOTIATION_FAIL = 3,   // Dispositivo accesible, pero fallo en la negociación (existe 
                                 //  dispositivo pero no soporta modo EPP)
      PP_TIME_OUT = 4,           // Time out
  /*    PP_RA_TIME_OUT = 4,        // Read address fails
      PP_WA_TIME_OUT = 5,        // Write address fails
      PP_RB_TIME_OUT = 6,        // Read byte fails
      PP_WB_TIME_OUT = 7,        // Write byte fails
      PP_RW_TIME_OUT = 8,        // Read word fails
      PP_WW_TIME_OUT = 9,        // Write word fails*/
      PP_LOAD_LIBRARY_FAIL = 5, // Falla al cargar la librería
      PP_WRONG_BASE_ADDRESS = 6 // Dirección base incorrecta
    };
    
    // Inicializacón 
    EppParallelUseWin(); 
    // Inicialización con negociación
    EppParallelUseWin(const short int &base_address); 
    ~EppParallelUseWin();

    // Negociación con devolución de estado
    PPStatusType negotiateEPP();
    // Negociación con devolución de estado y seteo de dirección del puerto
    PPStatusType negotiateEPP(const unsigned short int &base_address);
                                                                      
    // Reinicia el estado del puerto  
    void closeEPP(); 
    
    // Dirección base del puerto (solo soporta 0x3BC, 0x378 y 0x278)
    PPStatusType setBaseAddress(const short int &address);
    short int getBaseAddress();
    
    // Escribe/lee dirección sin/con retorno de estado
    void writeAddress(const char &address); 
    //PPStatusType writeAddress(const char &address);

    void readAddress(char &return_address); 
    //PPStatusType readAddress(char &return_address) const;

    
    // Escribe/lee un byte sin/con retorno de estado y selección de direccón destino
    void writeByte(const char &byte);
    void writeByte(const char &byte, const char &address);
//    PPStatusType writeByte(const char &byte) const;
//    PPStatusType writeByte(const char &byte, const char &address) const;
    void readByte(char &return_byte); 
    void readByte(char &return_byte, const char &addresss);
//    PPStatusType readByte(char &return_byte) const;
//    PPStatusType readByte(char &return_byte, const char &addresss) const;
    
    // Escribe/lee dos bytes sin/con retorno de estado y selección de direccón destino
    void writeWord(const unsigned short int &word);
    void writeWord(const unsigned short int &word, const char &address);
//    PPStatusType writeWord(const short int &word)  const;
//    PPStatusType writeWord(const short int &word, const char &address) const;
    void readWord(unsigned  int &return_word);
    void readWord(unsigned  int &return_word, const char &address);
//    PPStatusType readWord(short int &return_word) const;
//    PPStatusType readWord(short int &return_word, const char &address) const;
    
    // Devolución de estado del puerto
    PPStatusType getStatus();

    // make private
    PPStatusType testDataTransfer() ;

  private:
    short int baseAddress;
    //int errorsCount;
    PPStatusType status;
    
    PPStatusType loadDLL();
    // Verifica si es un estado compatible con transferencia de datos (1 = posible, 0 = no permitir)
    bool testStatusForDataTransfer(); 
    // Resetea estado de time out
    void prepareTestDataTransfer();
    // Verifica estado de time out
    //PPStatusType testDataTransfer() ;
    
};

#endif //EPP_PARALLEL_USE_WIN_H
