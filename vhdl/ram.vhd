---------------------------------------------------------------------
-- TITLE: Random Access Memory
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 4/21/01
-- FILENAME: ram.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Implements the RAM, reads the executable from either "code.txt",
--    or for Altera "code[0-3].hex".
--    Modified from "The Designer's Guide to VHDL" by Peter J. Ashenden
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.mlite_pack.all;

entity ram is
   generic(memory_type : string := "DEFAULT");
   port(clk               : in std_logic;
        enable            : in std_logic;
        write_byte_enable : in std_logic_vector(3 downto 0);
        address           : in std_logic_vector(31 downto 2);
        data_write        : in std_logic_vector(31 downto 0);
        data_read         : out std_logic_vector(31 downto 0));
end; --entity ram

architecture logic of ram is
   constant ADDRESS_WIDTH   : natural := 13;
begin

   generic_ram:
   if memory_type /= "ALTERA_LPM" generate 
   begin
   --Simulate a synchronous RAM
   ram_proc: process(clk, enable, write_byte_enable, 
         address, data_write) --mem_write, mem_sel
      variable mem_size : natural := 2 ** ADDRESS_WIDTH;
      variable data : std_logic_vector(31 downto 0); 
      subtype word is std_logic_vector(data_write'length-1 downto 0);
      type storage_array is
         array(natural range 0 to mem_size/4 - 1) of word;
      variable storage : storage_array;
      variable index : natural := 0;
      file load_file : text open read_mode is "code.txt";
      variable hex_file_line : line;
   begin

      --Load in the ram executable image
      if index = 0 then
         while not endfile(load_file) loop
--The following two lines had to be commented out for synthesis
            readline(load_file, hex_file_line);
            hread(hex_file_line, data);
            storage(index) := data;
            index := index + 1;
         end loop;
      end if;

      if rising_edge(clk) then
         index := conv_integer(address(ADDRESS_WIDTH-1 downto 2));
         data := storage(index);

         if enable = '1' then
            if write_byte_enable(0) = '1' then
               data(7 downto 0) := data_write(7 downto 0);
            end if;
            if write_byte_enable(1) = '1' then
               data(15 downto 8) := data_write(15 downto 8);
            end if;
            if write_byte_enable(2) = '1' then
               data(23 downto 16) := data_write(23 downto 16);
            end if;
            if write_byte_enable(3) = '1' then
               data(31 downto 24) := data_write(31 downto 24);
            end if;
         end if;
      
         if write_byte_enable /= "0000" then
            storage(index) := data;
         end if;
      end if;

      data_read <= data;
   end process;
   end generate; --generic_ram


   altera_ram:
   if memory_type = "ALTERA_LPM" generate
      signal byte_we : std_logic_vector(3 downto 0);
   begin
      byte_we <= write_byte_enable when enable = '1' else "0000";
      lpm_ram_io_component0 : lpm_ram_dq
         GENERIC MAP (
            intended_device_family => "UNUSED",
            lpm_width => 8,
            lpm_widthad => ADDRESS_WIDTH-2,
            lpm_indata => "REGISTERED",
            lpm_address_control => "REGISTERED",
            lpm_outdata => "UNREGISTERED",
            lpm_file => "code0.hex",
            use_eab => "ON",
            lpm_type => "LPM_RAM_DQ")
         PORT MAP (
            data    => data_write(31 downto 24),
            address => address(ADDRESS_WIDTH-1 downto 2),
            inclock => clk,
            we      => byte_we(3),
            q       => data_read(31 downto 24));

      lpm_ram_io_component1 : lpm_ram_dq
         GENERIC MAP (
            intended_device_family => "UNUSED",
            lpm_width => 8,
            lpm_widthad => ADDRESS_WIDTH-2,
            lpm_indata => "REGISTERED",
            lpm_address_control => "REGISTERED",
            lpm_outdata => "UNREGISTERED",
            lpm_file => "code1.hex",
            use_eab => "ON",
            lpm_type => "LPM_RAM_DQ")
         PORT MAP (
            data    => data_write(23 downto 16),
            address => address(ADDRESS_WIDTH-1 downto 2),
            inclock => clk,
            we      => byte_we(2),
            q       => data_read(23 downto 16));

      lpm_ram_io_component2 : lpm_ram_dq
         GENERIC MAP (
            intended_device_family => "UNUSED",
            lpm_width => 8,
            lpm_widthad => ADDRESS_WIDTH-2,
            lpm_indata => "REGISTERED",
            lpm_address_control => "REGISTERED",
            lpm_outdata => "UNREGISTERED",
            lpm_file => "code2.hex",
            use_eab => "ON",
            lpm_type => "LPM_RAM_DQ")
         PORT MAP (
            data    => data_write(15 downto 8),
            address => address(ADDRESS_WIDTH-1 downto 2),
            inclock => clk,
            we      => byte_we(1),
            q       => data_read(15 downto 8));

      lpm_ram_io_component3 : lpm_ram_dq
         GENERIC MAP (
            intended_device_family => "UNUSED",
            lpm_width => 8,
            lpm_widthad => ADDRESS_WIDTH-2,
            lpm_indata => "REGISTERED",
            lpm_address_control => "REGISTERED",
            lpm_outdata => "UNREGISTERED",
            lpm_file => "code3.hex",
            use_eab => "ON",
            lpm_type => "LPM_RAM_DQ")
         PORT MAP (
            data    => data_write(7 downto 0),
            address => address(ADDRESS_WIDTH-1 downto 2),
            inclock => clk,
            we      => byte_we(0),
            q       => data_read(7 downto 0));

   end generate; --altera_ram


   --For XILINX see ram_xilinx.vhd

end; --architecture logic
