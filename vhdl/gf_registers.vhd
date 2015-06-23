library IEEE;
use IEEE.std_logic_1164.all;
-------------------------------------------------------------------------------
entity gf_phi1_register_out is

  port (
      reset        : in  std_logic;           -- #RESET
      phi1         : in  std_logic;           -- Clock
      input_wip    : in  std_logic_vector(31 downto 0);
      output_final : out std_logic_vector(31 downto 0));
  
end gf_phi1_register_out;


architecture behavior of gf_phi1_register_out is

begin  -- gf_phi1_register_out

  -- purpose: This is the final register in the GF multiplier.
  -- It is a different entuty since it is much smaller that the "standard" ones

  p_gf_phi1_register_out: process (phi1, reset)
  begin  -- process p_gf_phi1_register_out
    if reset = '0' then                 -- asynchronous reset (active low)
      output_final <= X"46AF6449";
    elsif phi1'event and phi1 = '1' then  -- rising clock edge
      output_final <= input_wip;
    end if;
  end process p_gf_phi1_register_out;

end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity gf_phi1_register_2 is

  port (
      reset      : in  std_logic;                      -- #RESET
      phi1       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched
  
end gf_phi1_register_2;


architecture behavior of gf_phi1_register_2 is

begin  -- behavior

  -- purpose: 63 bit pipeline register
  -- type   : sequential
  -- inputs : phi1, reset, input_fcs, input_wip
  -- outputs: output_fcs, output_wip
  p_gf_phi1_register_2: process (phi1, reset)
  begin  -- process p_gf_phi1_register
    if reset = '0' then                 -- asynchronous reset (active low)
      output_fcs <= X"68B932F5";
      output_wip <= X"E3ED5B2A";
    elsif phi1'event and phi1 = '1' then  -- rising clock edge
      output_fcs <= input_fcs;
      output_wip <= input_wip;
    end if;
  end process p_gf_phi1_register_2;

end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity gf_phi2_register_3 is

    port (
      reset      : in  std_logic;                      -- #RESET
      phi2       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched

end gf_phi2_register_3;


architecture behavior of gf_phi2_register_3 is

begin  -- behavior

  -- purpose: 63 bit pipeline register
  -- type   : sequential
  -- inputs : phi2, reset, input_fcs, input_wip
  -- outputs: output_fcs, output_wip
  p_gf_phi2_register_3: process (phi2, reset)
  begin  -- process p_gf_phi2_register
    if reset = '0' then                 -- asynchronous reset (active low)
      output_fcs <= X"68B932F5";
      output_wip <= X"CEAD1918";
    elsif phi2'event and phi2 = '1' then  -- rising clock edge
      output_fcs <= input_fcs;
      output_wip <= input_wip;
    end if;
  end process p_gf_phi2_register_3;

end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity gf_phi1_register_4 is

  port (
      reset      : in  std_logic;                      -- #RESET
      phi1       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched
  
end gf_phi1_register_4;


architecture behavior of gf_phi1_register_4 is

begin  -- behavior

  -- purpose: 63 bit pipeline register
  -- type   : sequential
  -- inputs : phi1, reset, input_fcs, input_wip
  -- outputs: output_fcs, output_wip
  p_gf_phi1_register_4: process (phi1, reset)
  begin  -- process p_gf_phi1_register
    if reset = '0' then                 -- asynchronous reset (active low)
      output_fcs <= X"68B932F5";
      output_wip <= X"90903DD8";
    elsif phi1'event and phi1 = '1' then  -- rising clock edge
      output_fcs <= input_fcs;
      output_wip <= input_wip;
    end if;
  end process p_gf_phi1_register_4;

end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity gf_phi2_register_5 is

    port (
      reset      : in  std_logic;                      -- #RESET
      phi2       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched

end gf_phi2_register_5;


architecture behavior of gf_phi2_register_5 is

begin  -- behavior

  -- purpose: 63 bit pipeline register
  -- type   : sequential
  -- inputs : phi2, reset, input_fcs, input_wip
  -- outputs: output_fcs, output_wip
  p_gf_phi2_register_5: process (phi2, reset)
  begin  -- process p_gf_phi2_register
    if reset = '0' then                 -- asynchronous reset (active low)
      output_fcs <= X"68B932F5";
      output_wip <= X"74EBF27F";
    elsif phi2'event and phi2 = '1' then  -- rising clock edge
      output_fcs <= input_fcs;
      output_wip <= input_wip;
    end if;
  end process p_gf_phi2_register_5;

end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity gf_phi1_register_6 is

  port (
      reset      : in  std_logic;                      -- #RESET
      phi1       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched
  
end gf_phi1_register_6;


architecture behavior of gf_phi1_register_6 is

begin  -- behavior

  -- purpose: 63 bit pipeline register
  -- type   : sequential
  -- inputs : phi1, reset, input_fcs, input_wip
  -- outputs: output_fcs, output_wip
  p_gf_phi1_register_6: process (phi1, reset)
  begin  -- process p_gf_phi1_register
    if reset = '0' then                 -- asynchronous reset (active low)
      output_fcs <= X"68B932F5";
      output_wip <= X"462A4987";
    elsif phi1'event and phi1 = '1' then  -- rising clock edge
      output_fcs <= input_fcs;
      output_wip <= input_wip;
    end if;
  end process p_gf_phi1_register_6;

end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity gf_phi2_register_7 is

    port (
      reset      : in  std_logic;                      -- #RESET
      phi2       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched

end gf_phi2_register_7;


architecture behavior of gf_phi2_register_7 is

begin  -- behavior

  -- purpose: 63 bit pipeline register
  -- type   : sequential
  -- inputs : phi2, reset, input_fcs, input_wip
  -- outputs: output_fcs, output_wip
  p_gf_phi2_register_7: process (phi2, reset)
  begin  -- process p_gf_phi2_register
    if reset = '0' then                 -- asynchronous reset (active low)
      output_fcs <= X"68B932F5";
      output_wip <= X"46AFBDFF";
    elsif phi2'event and phi2 = '1' then  -- rising clock edge
      output_fcs <= input_fcs;
      output_wip <= input_wip;
    end if;
  end process p_gf_phi2_register_7;

end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity gf_phi1_register_8 is

  port (
      reset      : in  std_logic;                      -- #RESET
      phi1       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched
  
end gf_phi1_register_8;


architecture behavior of gf_phi1_register_8 is

begin  -- behavior

  -- purpose: 63 bit pipeline register
  -- type   : sequential
  -- inputs : phi1, reset, input_fcs, input_wip
  -- outputs: output_fcs, output_wip
  p_gf_phi1_register_8: process (phi1, reset)
  begin  -- process p_gf_phi1_register_8
    if reset = '0' then                 -- asynchronous reset (active low)
      output_fcs <= X"68B932F5";
      output_wip <= X"46AF747D";
    elsif phi1'event and phi1 = '1' then  -- rising clock edge
      output_fcs <= input_fcs;
      output_wip <= input_wip;
    end if;
  end process p_gf_phi1_register_8;

end behavior;

-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity gf_phi2_register_9 is

    port (
      reset      : in  std_logic;                      -- #RESET
      phi2       : in  std_logic;                      -- Clock
      input_wip  : in  std_logic_vector(31 downto 0);  -- The incoming WIP
      input_fcs  : in  std_logic_vector(31 downto 0);
                    -- The original data for that step. Since we are using pipelining
                    -- we have to grant that we will have the original FCS data
                    -- available.
      output_wip : out std_logic_vector(31 downto 0);
                    -- The modified data -our "WIP"-
      output_fcs : out std_logic_vector(31 downto 0));
                    -- The original data is kept untouched

end gf_phi2_register_9;


architecture behavior of gf_phi2_register_9 is

begin  -- behavior

  -- purpose: 63 bit pipeline register
  -- type   : sequential
  -- inputs : phi2, reset, input_fcs, input_wip
  -- outputs: output_fcs, output_wip
  p_gf_phi2_register_9: process (phi2, reset)
  begin  -- process p_gf_phi2_register
    if reset = '0' then                 -- asynchronous reset (active low)
      output_fcs <= X"68B932F5";
      output_wip <= X"46AF7449";
    elsif phi2'event and phi2 = '1' then  -- rising clock edge
      output_fcs <= input_fcs;
      output_wip <= input_wip;
    end if;
  end process p_gf_phi2_register_9;

end behavior;











