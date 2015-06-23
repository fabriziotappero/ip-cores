---------------------------------------------------------------------
-- TITLE: Memory Controller
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 1/31/01
-- FILENAME: mem_ctrl.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Memory controller for the Plasma CPU.
--    Supports Big or Little Endian mode.
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.mlite_pack.all;

entity mem_ctrl is
   port(clk          : in std_logic;
        reset_in     : in std_logic;
        pause_in     : in std_logic;
        nullify_op   : in std_logic;
        address_pc   : in std_logic_vector(31 downto 2);
        opcode_out   : out std_logic_vector(31 downto 0);

        address_in   : in std_logic_vector(31 downto 0);
        mem_source   : in mem_source_type;
        data_write   : in std_logic_vector(31 downto 0);
        data_read    : out std_logic_vector(31 downto 0);
        pause_out    : out std_logic;
        
        address_next : out std_logic_vector(31 downto 2);
        byte_we_next : out std_logic_vector(3 downto 0);

        address      : out std_logic_vector(31 downto 2);
        byte_we      : out std_logic_vector(3 downto 0);
        data_w       : out std_logic_vector(31 downto 0);
        data_r       : in std_logic_vector(31 downto 0));
end; --entity mem_ctrl

architecture logic of mem_ctrl is
   --"00" = big_endian; "11" = little_endian
   constant ENDIAN_MODE   : std_logic_vector(1 downto 0) := "00";
   signal opcode_reg      : std_logic_vector(31 downto 0);
   signal next_opcode_reg : std_logic_vector(31 downto 0);
   signal address_reg     : std_logic_vector(31 downto 2);
   signal byte_we_reg     : std_logic_vector(3 downto 0);

   signal mem_state_reg   : std_logic;
   constant STATE_ADDR    : std_logic := '0';
   constant STATE_ACCESS  : std_logic := '1';

begin

mem_proc: process(clk, reset_in, pause_in, nullify_op, 
                  address_pc, address_in, mem_source, data_write, 
                  data_r, opcode_reg, next_opcode_reg, mem_state_reg,
                  address_reg, byte_we_reg)
   variable address_var    : std_logic_vector(31 downto 2);
   variable data_read_var  : std_logic_vector(31 downto 0);
   variable data_write_var : std_logic_vector(31 downto 0);
   variable opcode_next    : std_logic_vector(31 downto 0);
   variable byte_we_var    : std_logic_vector(3 downto 0);
   variable mem_state_next : std_logic;
   variable pause_var      : std_logic;
   variable bits           : std_logic_vector(1 downto 0);
begin
   byte_we_var := "0000";
   pause_var := '0';
   data_read_var := ZERO;
   data_write_var := ZERO;
   mem_state_next := mem_state_reg;
   opcode_next := opcode_reg;

   case mem_source is
   when MEM_READ32 =>
      data_read_var := data_r;

   when MEM_READ16 | MEM_READ16S =>
      if address_in(1) = ENDIAN_MODE(1) then
         data_read_var(15 downto 0) := data_r(31 downto 16);
      else
         data_read_var(15 downto 0) := data_r(15 downto 0);
      end if;
      if mem_source = MEM_READ16 or data_read_var(15) = '0' then
         data_read_var(31 downto 16) := ZERO(31 downto 16);
      else
         data_read_var(31 downto 16) := ONES(31 downto 16);
      end if;

   when MEM_READ8 | MEM_READ8S =>
      bits := address_in(1 downto 0) xor ENDIAN_MODE;
      case bits is
      when "00" => data_read_var(7 downto 0) := data_r(31 downto 24);
      when "01" => data_read_var(7 downto 0) := data_r(23 downto 16);
      when "10" => data_read_var(7 downto 0) := data_r(15 downto 8);
      when others => data_read_var(7 downto 0) := data_r(7 downto 0);
      end case;
      if mem_source = MEM_READ8 or data_read_var(7) = '0' then
         data_read_var(31 downto 8) := ZERO(31 downto 8);
      else
         data_read_var(31 downto 8) := ONES(31 downto 8);
      end if;

   when MEM_WRITE32 =>
      data_write_var := data_write;
      byte_we_var := "1111";

   when MEM_WRITE16 =>
      data_write_var := data_write(15 downto 0) & data_write(15 downto 0);
      if address_in(1) = ENDIAN_MODE(1) then
         byte_we_var := "1100";
      else
         byte_we_var := "0011";
      end if;

   when MEM_WRITE8 =>
      data_write_var := data_write(7 downto 0) & data_write(7 downto 0) &
                  data_write(7 downto 0) & data_write(7 downto 0);
      bits := address_in(1 downto 0) xor ENDIAN_MODE;
      case bits is
      when "00" =>
         byte_we_var := "1000"; 
      when "01" => 
         byte_we_var := "0100"; 
      when "10" =>
         byte_we_var := "0010"; 
      when others =>
         byte_we_var := "0001"; 
      end case;

   when others =>
   end case;

   if mem_source = MEM_FETCH then --opcode fetch
      address_var := address_pc;
      opcode_next := data_r;
      mem_state_next := STATE_ADDR;
   else
      if mem_state_reg = STATE_ADDR then
         if pause_in = '0' then
            address_var := address_in(31 downto 2);
            mem_state_next := STATE_ACCESS;
            pause_var := '1';
         else
            address_var := address_pc;
            byte_we_var := "0000";
         end if;
      else  --STATE_ACCESS
         if pause_in = '0' then
            address_var := address_pc;
            opcode_next := next_opcode_reg;
            mem_state_next := STATE_ADDR;
            byte_we_var := "0000";
         else
            address_var := address_in(31 downto 2);
            byte_we_var := "0000";
         end if;
      end if;
   end if;

   if nullify_op = '1' and pause_in = '0' then
      opcode_next := ZERO;  --NOP after beql
   end if;

   if reset_in = '1' then
      mem_state_reg <= STATE_ADDR;
      opcode_reg <= ZERO;
      next_opcode_reg <= ZERO;
      address_reg <= ZERO(31 downto 2);
      byte_we_reg <= "0000";
   elsif rising_edge(clk) then
      if pause_in = '0' then
         address_reg <= address_var;
         byte_we_reg <= byte_we_var;
         mem_state_reg <= mem_state_next;
         opcode_reg <= opcode_next;
         if mem_state_reg = STATE_ADDR then
            next_opcode_reg <= data_r;
         end if;
      end if;
   end if;

   opcode_out <= opcode_reg;
   data_read <= data_read_var;
   pause_out <= pause_var;

   address_next <= address_var;
   byte_we_next <= byte_we_var;

   address <= address_reg;
   byte_we <= byte_we_reg;
   data_w <= data_write_var;

end process; --data_proc

end; --architecture logic
