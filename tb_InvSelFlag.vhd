-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica             
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : EPC Class1 Gen2 RFID Tag - Inventoried and Selected Flags
--                      Test Bench
--
--     File name      : tb_InvSelFlag.vhd 
--
--     Description    : Inventoried and Selected flag test bench.
--                      
--     Authors        : Erwing R. Sanchez <erwing.sanchez@polito.it>
--                                 
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;

entity tb_InvSelFlag is
end tb_InvSelFlag;

architecture stim of tb_InvSelFlag is


  component InvSelFlag
    generic (
      S1INV_PERSISTENCE_TIME : time;
      S2INV_PERSISTENCE_TIME : time;
      S3INV_PERSISTENCE_TIME : time;
      SL_PERSISTENCE_TIME    : time);
    port (
      S1i : in  std_logic;
      S2i : in  std_logic;
      S3i : in  std_logic;
      SLi : in  std_logic;
      S1o : out std_logic;
      S2o : out std_logic;
      S3o : out std_logic;
      SLo : out std_logic);
  end component;


  constant S1INV_PERSISTENCE_TIME : time := 500 ms;
  constant S2INV_PERSISTENCE_TIME : time := 2 sec;
  constant S3INV_PERSISTENCE_TIME : time := 2 sec;
  constant SL_PERSISTENCE_TIME    : time := 2 sec;
  constant CKdiv2                 : time := 260 ns;

  signal Si  : std_logic_vector(1 to 3);
  signal Sli : std_logic;
  signal So  : std_logic_vector(1 to 3);
  signal Slo : std_logic;

  
begin  -- stim


  process

  begin  -- process

    Si  <= (others => '0');
    Sli <= '0';

    wait for 20 * CKdiv2;

    Si(1) <= '1';
    wait for 2 * CKdiv2;
    Si(1) <= '0';
    wait for 2 * CKdiv2;
    Si(1) <= '1';
    wait for 2 * CKdiv2;

    Si(2) <= '1';
    wait for 2 * CKdiv2;
    Si(2) <= '0';
    wait for 2 * CKdiv2;
    Si(2) <= '1';
    wait for 2 * CKdiv2;

    Si(3) <= '1';
    wait for 2 * CKdiv2;
    Si(3) <= '0';
    wait for 2 * CKdiv2;
    Si(3) <= '1';
    wait for 2 * CKdiv2;

    Sli <= '1';
    wait for 2 * CKdiv2;
    Sli <= '0';
    wait for 2 * CKdiv2;
    Sli <= '1';
    wait for 2 * CKdiv2;


    wait;
    
  end process;


  InvSelFlag_1 : InvSelFlag
    generic map (
      S1INV_PERSISTENCE_TIME => S1INV_PERSISTENCE_TIME,
      S2INV_PERSISTENCE_TIME => S2INV_PERSISTENCE_TIME,
      S3INV_PERSISTENCE_TIME => S3INV_PERSISTENCE_TIME,
      SL_PERSISTENCE_TIME    => SL_PERSISTENCE_TIME)
    port map (
      S1i => Si(1),
      S2i => Si(2),
      S3i => Si(3),
      SLi => Sli,
      S1o => So(1),
      S2o => So(2),
      S3o => So(3),
      SLo => Slo); 

end stim;
