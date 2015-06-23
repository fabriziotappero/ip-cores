-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica             
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : EPC Class1 Gen2 RFID Tag - Inventoried and Selected Flags Model
--
--     File name      : InvSelFlags.vhd 
--
--     Description    : Simulation model of Inventoried and Selected Flags. It
--                      includes persistence time as described in the EPC
--                      standard v. 1.09.
--                      
--     Authors        : Erwing R. Sanchez <erwing.sanchez@polito.it>
--                                 
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;



entity InvSelFlag is
  port (
    S1i : in  std_logic;
    S2i : in  std_logic;
    S3i : in  std_logic;
    SLi : in  std_logic;
    S1o : out std_logic;
    S2o : out std_logic;
    S3o : out std_logic;
    SLo : out std_logic);

end InvSelFlag;


architecture Flags1 of InvSelFlag is
-- synopsys synthesis_off
  constant S1INV_PERSISTENCE_TIME : time := 500 ms;
  constant S2INV_PERSISTENCE_TIME : time := 2 sec;
  constant S3INV_PERSISTENCE_TIME : time := 2 sec;
  constant SL_PERSISTENCE_TIME    : time := 2 sec;

  constant TM_STEP          : time      := 10 ns;
  signal   S1_time_cnt      : time      := 1 ns;
  signal   S2_time_cnt      : time      := 1 ns;
  signal   S3_time_cnt      : time      := 1 ns;
  signal   SL_time_cnt      : time      := 1 ns;
  signal   S1_time_cnt_flag : std_logic := '0';
  signal   S2_time_cnt_flag : std_logic := '0';
  signal   S3_time_cnt_flag : std_logic := '0';
  signal   SL_time_cnt_flag : std_logic := '0';



  -- synopsys synthesis_on 
begin  -- Flags1
-- synopsys synthesis_off
  S1FLAG : process (S1_time_cnt_flag, S1i)
  begin  -- process S1FLAG  
    if S1i'event and (S1i = '0' or S1i = '1') then
      S1o         <= S1i;
      S1_time_cnt <= 0 ns after TM_STEP;
    elsif S1_time_cnt_flag'event then
      if S1_time_cnt = S1INV_PERSISTENCE_TIME then
        S1o         <= 'X';
        S1_time_cnt <= 0 ns after TM_STEP;
      else
        S1_time_cnt <= S1_time_cnt + TM_STEP after TM_STEP;
      end if;
    end if;
  end process S1FLAG;

  S1FLAG_flag : process (S1_time_cnt)
  begin  -- process S1FLAG_MIRROR
    S1_time_cnt_flag <= not S1_time_cnt_flag;
  end process S1FLAG_flag;


  S2FLAG : process (S2_time_cnt_flag, S2i)
  begin  -- process S2FLAG  
    if S2i'event and (S2i = '0' or S2i = '1') then
      S2o         <= S2i;
      S2_time_cnt <= 0 ns after TM_STEP;
    elsif S2_time_cnt_flag'event then
      if S2_time_cnt = S2INV_PERSISTENCE_TIME then
        S2o         <= 'X';
        S2_time_cnt <= 0 ns after TM_STEP;
      else
        S2_time_cnt <= S2_time_cnt + TM_STEP after TM_STEP;
      end if;
    end if;
  end process S2FLAG;

  S2FLAG_flag : process (S2_time_cnt)
  begin  -- process S2FLAG_MIRROR
    S2_time_cnt_flag <= not S2_time_cnt_flag;
  end process S2FLAG_flag;

  S3FLAG : process (S3_time_cnt_flag, S3i)
  begin  -- process S3FLAG  
    if S3i'event and (S3i = '0' or S3i = '1') then
      S3o         <= S3i;
      S3_time_cnt <= 0 ns after TM_STEP;
    elsif S3_time_cnt_flag'event then
      if S3_time_cnt = S3INV_PERSISTENCE_TIME then
        S3o         <= 'X';
        S3_time_cnt <= 0 ns after TM_STEP;
      else
        S3_time_cnt <= S3_time_cnt + TM_STEP after TM_STEP;
      end if;
    end if;
  end process S3FLAG;

  S3FLAG_flag : process (S3_time_cnt)
  begin  -- process S3FLAG_MIRROR
    S3_time_cnt_flag <= not S3_time_cnt_flag;
  end process S3FLAG_flag;

  SLFLAG : process (SL_time_cnt_flag, SLi)
  begin  -- process SLFLAG  
    if SLi'event and (SLi = '0' or SLi = '1') then
      SLo         <= SLi;
      SL_time_cnt <= 0 ns after TM_STEP;
    elsif SL_time_cnt_flag'event then
      if SL_time_cnt = SL_PERSISTENCE_TIME then
        SLo         <= 'X';
        SL_time_cnt <= 0 ns after TM_STEP;
      else
        SL_time_cnt <= SL_time_cnt + TM_STEP after TM_STEP;
      end if;
    end if;
  end process SLFLAG;

  SLFLAG_flag : process (SL_time_cnt)
  begin  -- process SLFLAG_MIRROR
    SL_time_cnt_flag <= not SL_time_cnt_flag;
  end process SLFLAG_flag;
-- synopsys synthesis_on
end Flags1;
