//Author     : Alex Zhang (cgzhangwei@gmail.com)
//Date       : March.05.2015
//Description: Wishbone B3 protocol interface
//             TGC : {AWPROT,AWCACHE, AWLOCK} | {ARPROT, ARCACHE,ARLOCK}
//             TGD : WID,
//             TGA : AWID| ARID,
interface wishbone_if #(
  WB_ADR_WIDTH = 32,
  WB_BTE_WIDTH = 2 , 
  WB_CTI_WIDTH = 3 ,
  WB_DAT_WIDTH = 32,
  WB_TGA_WIDTH = 8,
  WB_TGD_WIDTH = 8,
  WB_TGC_WIDTH = 4,
  WB_SEL_WIDTH = 4 

);
logic [WB_ADR_WIDTH -1 : 0] ADR;
logic [WB_TGA_WIDTH -1 :0 ] TGA;
logic [WB_DAT_WIDTH -1 : 0] DAT_I;
logic [WB_TGD_WIDTH -1 : 0] TGD_I;
logic [WB_DAT_WIDTH -1 : 0] DAT_O;
logic [WB_TGD_WIDTH -1 : 0] TGD_O;
logic                       WE;
logic [WB_SEL_WIDTH -1 : 0] SEL;
logic                       STB;
logic                       ACK;
logic                       CYC;
logic                       ERR;
logic                       LOCK;
logic [WB_BTE_WIDTH -1 :0 ] BTE;
logic                       RTY;
logic [WB_CTI_WIDTH -1 :0 ] CTI;
logic [WB_TGA_WIDTH -1 :0 ] TGC;


modport  master(
output ADR  ,
output TGA  ,
input  DAT_I,
input  TGD_I,
output DAT_O,
output TGD_O,
output WE   ,
output SEL  ,
output STB  ,
input  ACK  ,
output CYC  ,
input  ERR  ,
output LOCK ,
output BTE  ,
input  RTY  ,
output CTI  ,
output TGC
);

modport  slave(
input  ADR  ,
input  TGA  ,
output DAT_O,
output TGD_O,
input  DAT_I,
input  TGD_I,
input  WE   ,
input  SEL  ,
input  STB  ,
output ACK  ,
input  CYC  ,
output ERR  ,
input  LOCK ,
input  BTE  ,
output RTY  ,
input  CTI  ,
input  TGC
);


endinterface
