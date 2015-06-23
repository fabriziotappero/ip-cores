------------------------------------------------------------------------------------
-- Company: 
-- Engineer: 		 Benny Thörnberg
-- 
-- Create Date:    14:12:25 04/11/2008 
-- Design Name: 
-- Module Name:    line_buffer_Xb - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

-- This entity constitutes a FIFO-register that can be used for storage of line delays 
-- for image processing. It is implemented as a circular buffer using one single pointer.
-- The address for this pointer must be driven externally by the interface signal "pointer". 
-- Data is first read from the memory location referenced by "pointer" to "odata" on the falling 
-- clock edge and then data is written to the same location from "idata" on the rising clock edge.
-- An additional register on the data output is clocked on the rising clockedge such that data output
-- appears on the output on rising edge allthough it is read on the falling edge.
-- The maximum size of the final line buffer is 1025 by 8 bits. The size of this line buffer can be
-- any size ranging from 1 to 1025 depending on the sequence of addressses driven on "pointer".

entity line_buffer_Xb is
	generic (
		CODE_WIDTH	: integer := 10;
		ADDRESS_BITS : integer := 10
		);
    Port ( idata : in  STD_LOGIC_VECTOR (CODE_WIDTH-1 downto 0); -- input data port
           odata : out  STD_LOGIC_VECTOR (CODE_WIDTH-1 downto 0); -- output data port
			  pointer : in STD_LOGIC_VECTOR (ADDRESS_BITS-1 downto 0); -- reference to a memory location
           ena : in  STD_LOGIC; -- must be high to enable shifting of data
           clk : in  STD_LOGIC);
end line_buffer_Xb;

architecture behave of line_buffer_Xb is

type ram_type is array((2**ADDRESS_BITS)-1 downto 0) of std_logic_vector(CODE_WIDTH-1 downto 0);
signal ram_array : ram_type:=(others=>(others=>'0'));
begin

  process(clk)
  begin
    if clk'event and clk ='1' then
      odata <= ram_array(conv_integer(pointer));
      if ena='1' then
        ram_array(conv_integer(pointer)) <= idata;
      end if;	
    end if;
    
  end process;
end behave;


