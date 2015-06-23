-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica               
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : EPC Class1 Gen2 RFID Tag constants   
--
--     File name      : epc_tag.vhd 
--
--     Description    : EPC tag package
--
--     Authors        : Erwing R. Sanchez <erwing.sanchez@polito.it>
--
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;


package EPC_TAG is

  constant MASKLENGTH : integer := 256;

  subtype Rec_Out_T is std_logic_vector(31 downto 0);



--  type CommandInternalCode_t is (cmd_NULL, cmd_QueryRep, cmd_Ack, cmd_Query, cmd_QueryAdjust,
--                                 cmd_Select, cmd_Nak, cmd_ReqRN, cmd_Read, cmd_Write, cmd_Kill,
--                                 cmd_Lock, cmd_Access, cmd_BlockWrite, cmd_BlockErase, cmd_Invalid);

  subtype CommandInternalCode_t is std_logic_vector(3 downto 0);

  constant cmd_NULL        : std_logic_vector(3 downto 0) := "0000";
  constant cmd_QueryRep    : std_logic_vector(3 downto 0) := "0001";
  constant cmd_Ack         : std_logic_vector(3 downto 0) := "0010";
  constant cmd_Query       : std_logic_vector(3 downto 0) := "0011";
  constant cmd_QueryAdjust : std_logic_vector(3 downto 0) := "0100";
  constant cmd_Select      : std_logic_vector(3 downto 0) := "0101";
  constant cmd_Nak         : std_logic_vector(3 downto 0) := "0110";
  constant cmd_ReqRN       : std_logic_vector(3 downto 0) := "0111";
  constant cmd_Read        : std_logic_vector(3 downto 0) := "1000";
  constant cmd_Write       : std_logic_vector(3 downto 0) := "1001";
  constant cmd_Kill        : std_logic_vector(3 downto 0) := "1010";
  constant cmd_Lock        : std_logic_vector(3 downto 0) := "1011";
  constant cmd_Access      : std_logic_vector(3 downto 0) := "1100";
  constant cmd_BlockWrite  : std_logic_vector(3 downto 0) := "1101";
  constant cmd_BlockErase  : std_logic_vector(3 downto 0) := "1110";
  constant cmd_Invalid     : std_logic_vector(3 downto 0) := "1111";


--  subtype CommandTransmitter_t is std_logic_vector(2 downto 0)
  constant trmcmd_Null         : std_logic_vector(2 downto 0) := "000";
  constant trmcmd_Send         : std_logic_vector(2 downto 0) := "001";
  constant trmcmd_SendError    : std_logic_vector(2 downto 0) := "010";
  constant trmcmd_SendRData    : std_logic_vector(2 downto 0) := "011";
  constant trmcmd_SendRHandler : std_logic_vector(2 downto 0) := "100";
  

end EPC_TAG;

