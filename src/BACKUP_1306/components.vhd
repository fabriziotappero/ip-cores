library ieee;
use ieee.std_logic_1164.all;
use work.cpu_types.all;

package components is
  component alu is
    port( a,b,rom_data,ram_data : in d_bus; control : in opcode; carry,zero : in std_logic;
          result : OUT d_bus; carry_out,zero_out : OUT STD_LOGIC );
  end component;
  
  component control is
    port( clk,rst,carry,zero : in std_logic; input : IN d_bus;
          output : out opcode );
  end component;
  
  component pc is
    port( clk,rst : in std_logic; addr_in : IN d_bus; control : IN opcode;
          pc : out d_bus);
  end component;

  component ram_control is
    port( clk,rst : in std_logic; input_a,input_rom, input_ram : IN d_bus; control: IN opcode;
          addr,data,ram_data_reg : out d_bus; ce_nwr,ce_nrd : OUT STD_LOGIC );
  end component;  

  COMPONENT reg is
    port( clk,rst,carry_in,zero_in : IN std_logic; result_in : IN d_bus; control : IN opcode;
          a_out,b_out : OUT d_bus; carry_out,zero_out : OUT STD_LOGIC );
  END COMPONENT;
end components;
