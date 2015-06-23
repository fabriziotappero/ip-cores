--------------------------------------------------------------------------------
-- Company: 
-- Engineer: Richard Hirsch
--
-- Create Date:    09:24:52 08/31/05
-- Design Name:    
-- Module Name:    Cycle_Simulator.vhd - Behavioral
-- Project Name:   HASM
-- Target Device:  
-- Tool versions:  ISE 7.1
-- Description: This is the VHDL-portion of the HASM assembler. This file 
-- generates generic bus cycles to be used by a bus-specific model. The location
-- of the vector file containing the HASM-generated vectors is defined by the
-- vector_filename generic.
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use std.textio.all;

-- synthesis translate_off
library UNISIM;
use UNISIM.VComponents.all;
-- synthesis translate_on

entity cycle_simulator is
    Generic (
      vector_filename      : string := "c:\Ortus\Hasm_vhdl\vectors.vct"	-- Vector file to execute
      );
    Port ( 
      rst                  : in std_logic;                        -- System reset
      clk                  : in std_logic;                        -- System clock

      enable_machine       : in std_logic;                        -- Set high to enable HASM machine

      machine_interrupt    : in std_logic;                        -- Set high to cause jump to .isr
      clr_machine_interrupt: out std_logic;                       -- Set by HASM to tell bus model to clear
                                                                  -- interrupt signal (interrupt acknowledge)

      cyc_rdwr             : out std_logic;                       -- Cycle type indicator, high when read, low when write
      cyc_rmw              : out std_logic;                       -- Set high after execution of rmw_en, low after rmw_dis
      cyc_siz              : out std_logic_vector(1 downto 0);    -- Cycle size indicator(00 8-bit, 01 16-bit, 10 32-bit, 11 24-bit)
      cyc_addr             : out std_logic_vector(31 downto 0);   -- Byte-aligned cycle address
      cyc_data_in          : in std_logic_vector(31 downto 0);    -- Data-in from bus model
      cyc_data_out         : out std_logic_vector(31 downto 0);   -- Data-out to bus model
      start_cyc            : out std_logic;                       -- Start cycle indicator to bus model
      cyc_done             : in std_logic;                        -- Cycle done from bus model		

      brst_cyc             : out std_logic;                       -- Burst cycle indicator to bus model
      brst_quantity        : out std_logic_vector(31 downto 0);   -- Indicates number of R/W cycles in burst
      brst_last            : out std_logic;                       -- Set high on last cycle of burst access
      brst_data_rdy        : in std_logic;                        -- Data ready indicator from bus model

      reg_user              : out std_logic_vector(31 downto 0);  -- General purpose register to be used by bus model
      -- following for debug
      instruction_out      : out std_logic_vector(31 downto 0);   -- Indicates current instruction being executed
      register_out         : out std_logic_vector(31 downto 0);   -- Indicates target register of current instruction
      literal_out          : out std_logic_vector(31 downto 0);   -- Indicates literal value of current instruction
      next_inst            : out std_logic_vector(31 downto 0)    -- Indicates address of next instruction to be executed

      );
end cycle_simulator;

architecture Behavioral of cycle_simulator is

signal registera: std_logic_vector(31 downto 0);
signal registerb: std_logic_vector(31 downto 0);
signal registerc: std_logic_vector(31 downto 0);
signal registerd: std_logic_vector(31 downto 0);
signal reg_user_int: std_logic_vector(31 downto 0);
signal register_delay: std_logic_Vector(31 downto 0);

type instruction is (load, read, write, comp_e, comp_ne, jump, and_inst, or_inst, 
                     ret, add, push, pop, call, rdmem, wrmem, rdbrst, wrbrst, wrb,
                     wrw, rdb, rdw, rmw_en, rmw_dis, rdt, wrt, rdbrstb, rdbrstw, rdbrstt,
                     wrbrstb, wrbrstw, wrbrstt, delay, wri, wrib, wriw, writ, rdi, rdib,
                     rdiw, rdit, compi_e, compi_ne, ldrr, shl, shr );

signal instruction_state : instruction;
signal loaded_instruction : instruction;
type register_type is (rega, regb, regc, regd, reguser);
signal register_sel : register_type;
signal literal_value: std_logic_vector(31 downto 0);
signal data_from_target: std_logic_Vector(31 downto 0);
signal temp: std_logic_vector(31 downto 0);

signal interrupt_cycle: std_logic;
signal brst_last_int: std_logic;



begin

reg_user(31 downto 0) <= reg_user_int(31 downto 0);
brst_last <= brst_last_int;

----------------------------------------------
-- Instruction encoding
--
-- ld       0x00000000
-- rd       0x00000001
-- wr       0x00000002
-- cmp_e    0x00000003
-- cmp_ne   0x00000004
-- jmp      0x00000005
-- and      0x00000006
-- or       0x00000007
-- ret      0x00000008
-- add      0x00000009
-- push     0x0000000a
-- pop      0x0000000b
-- call     0x0000000c
-- rdmem    0x0000000d
-- wrmem    0x0000000e
-- rdbrst   0x0000000f
-- wrbrst   0x00000010
-- wrb      0x00000011
-- wrw      0x00000012
-- rdb      0x00000013
-- rdw      0x00000014
-- rmw_en   0x00000015
-- rmw_dis  0x00000016
-- rdt      0x00000017
-- wrt      0x00000018
-- rdbrstb  0x00000019
-- rdbrstw  0x0000001a
-- rdbrstt  0x0000001b
-- wrbrstb  0x0000001c
-- wrbrstw  0x0000001d
-- wrbrstt  0x0000001e
-- delay    0x0000001f
-- wri      0x00000020
-- wrib     0x00000021
-- wriw     0x00000022
-- writ     0x00000023
-- rdi      0x00000024
-- rdib     0x00000025
-- rdiw     0x00000026
-- rdit     0x00000027
-- cmpie    0x00000028
-- cmpine   0x00000029
-- ldrr     0x0000002A
-- shl      0x0000002B
-- shr      0x0000002C
----------------------------------------------
-- Register encoding
--
-- rega     0x00000001
-- regb     0x00000002
-- regc     0x00000003
-- regd     0x00000004
-- reguser  0x00000005
-----------------------------------------------
-- SIZ encoding
-- 00       Byte wide
-- 01       Word wide (16-bit)
-- 10       Long wide (32-bit)
-- 11       Triple wide(24-bit)




run_instructions: process is
   file vector_file: text;
   variable instruction_offset: integer := 0;
   variable next_instruction: integer := 0;
   variable machine_interrupt_a_vector : integer := 31;        -- Jumps to this offset when interrupted
   variable stack : integer := 0;
   variable stack_a : integer := 0;
   variable L : line;
   variable ch: character;
   variable time_delay : integer := 0;

   variable instruction_type : integer := 0;
   variable register_select  : integer := 0;
   variable lit_val          : integer := 0;

   variable open_status : file_open_status;

   variable i : integer := 0;

   type stack_array is array (0 to 20) of integer;
   variable stack_memory : stack_array;
   variable stack_ptr : integer := 0;

   type burst_data_array is array(0 to 260) of integer;
   variable burst_memory : burst_data_array;
   variable burst_ptr : integer := 0;

   -- read_hex_natural converts ASCII hex representation in file
   -- to actual hex  
   procedure read_hex_natural (L:inout line; n:out integer) is
      variable result: integer := 0;
   begin
      for i in 1 to 8 loop
         read(L,ch);
         if '0'<=ch and ch <='9' then
            result := result * 16 + character'pos(ch) - character'pos('0');
         elsif 'A' <= ch and ch <= 'F' then
            result := result * 16 + character'pos(ch) - character'pos('A') + 10;
         elsif 'a' <= ch and ch<= 'f' then
            result := result * 16 + character'pos(ch) - character'pos('a') + 10;
         end if;
      end loop;
      n := result;
     
   end read_hex_natural;

   procedure bump_file_pointer(ptr: in integer; vectors_filename: IN string ) is
   begin
      file_close(vector_file);
      file_open(vector_file,vectors_filename,READ_MODE);
      readline(vector_file,L);							 -- Always read past interrupt vector line
      read_hex_natural (L, machine_interrupt_a_vector);  -- Get interrupt vector

      if(ptr /= 0) then
         for i in 0 to (ptr - 1) loop					 -- Keep reading lines until target line
            readline(vector_file,L);
         end loop;
      end if;
   end bump_file_pointer;



begin


   file_open(vector_file,vector_filename,READ_MODE);
   interrupt_cycle <= '0';       
   start_cyc <= '0';
   next_instruction := 0;
   instruction_offset := 0;
   clr_machine_interrupt <= '0';					
   stack_ptr := 0;									
   cyc_data_out(31 downto 0) <= (others => '0');
   cyc_addr(31 downto 0) <= (others => '0'); 
   cyc_rdwr <= '0';
   cyc_siz(1 downto 0) <= "00";
   cyc_rmw <= '0';
   brst_cyc <= '0';
   brst_quantity(31 downto 0) <= (others => '0');
   brst_last_int <= '0';
   literal_out(31 downto 0) <= (others => '0');
   next_inst(31 downto 0) <= (others => '0');
   registera(31 downto 0) <= (others => '0');
   registerb(31 downto 0) <= (others => '0');
   registerc(31 downto 0) <= (others => '0');
   registerd(31 downto 0) <= (others => '0');
   reg_user_int(31 downto 0) <= (others => '0');
   register_delay(31 downto 0) <= (others => '0');

   
   
   if(rst = '1') then
      wait on rst;
   end if;
   wait for 1 fs;
			
   for i in 0 to 1000000000 loop		   -- Infinite instruction loop      
      if(enable_machine = '0') then		-- Wait until DUT says OK to start
         wait on enable_machine;
      end if;

      if(cyc_done = '1') then			   -- Wait until last instruction completes (or DUT gets out of reset)
         wait on cyc_done;
      end if;
      wait for 10 ns;

      
      if(machine_interrupt = '1' and interrupt_cycle = '0') then  -- Check for interrupt
         stack_ptr := stack_ptr + 1;                              -- Interrupt active, bump stack to next open location
         stack_memory(stack_ptr) := next_instruction;             -- Save address of next instruction
         clr_machine_interrupt <= '1';                            -- Clear bus model's interrupt line
         wait for 10 ns;                                          -- Give bus model a chance
         clr_machine_interrupt <= '0';                            -- Clear the clear
         instruction_offset := machine_interrupt_a_vector;        -- Jump off to the isr
         interrupt_cycle <= '1';                                  -- Indicate we've entered the ISR
      end if;
      wait for 1 fs;
      bump_file_pointer(instruction_offset, vector_filename);		-- Bump file pointer to next instruction line
      wait for 1 fs;											
      
      readline(vector_file,L);										      -- Get desired instruction line
      read_hex_natural(L,instruction_type);							   -- Convert Ascii to hex
      instruction_out(31 downto 0) <= conv_std_logic_vector(instruction_type,32);

      wait for 1 fs;
      case instruction_type is					-- convert instruction number to human-readable form
         when 0 =>
            loaded_instruction <= load;
         when 1 =>
            loaded_instruction <= read;
         when 2 =>
            loaded_instruction <= write;
         when 3 => 
            loaded_instruction <= comp_e;
         when 4 =>
            loaded_instruction <= comp_ne;
         when 5 =>
            loaded_instruction <= jump;
         when 6 =>
            loaded_instruction <= and_inst;
         when 7 =>
            loaded_instruction <= or_inst;
         when 8 =>
            loaded_instruction <= ret;
         when 9 =>
            loaded_instruction <= add;
         when 10 =>
            loaded_instruction <= push;
         when 11 =>
            loaded_instruction <= pop;
         when 12 =>
            loaded_instruction <= call;
         when 13 =>
            loaded_instruction <= rdmem;
         when 14 =>
            loaded_instruction <= wrmem;
         when 15 =>                       -- 32-bit burst read
            loaded_instruction <= rdbrst;
         when 16 =>                       -- 32-bit burst write
            loaded_instruction <= wrbrst;
         when 17 =>
            loaded_instruction <= wrb;
         when 18 =>
            loaded_instruction <= wrw;
         when 19 =>
            loaded_instruction <= rdb;
         when 20 =>
            loaded_instruction <= rdw;
         when 21 =>
            loaded_instruction <= rmw_en;
         when 22 =>
            loaded_instruction <= rmw_dis;
         when 23 =>
            loaded_instruction <= rdt;
         when 24 =>
            loaded_instruction <= wrt;
         when 25 =>
            loaded_instruction <= rdbrstb;
         when 26 =>
            loaded_instruction <= rdbrstw;
         when 27 =>
            loaded_instruction <= rdbrstt;
         when 28 =>
            loaded_instruction <= wrbrstb;
         when 29 =>
            loaded_instruction <= wrbrstw;
         when 30 =>
            loaded_instruction <= wrbrstt;
         when 31 =>
            loaded_instruction <= delay;
         when 32 =>
            loaded_instruction <= wri;
         when 33 =>
            loaded_instruction <= wrib;
         when 34 =>
            loaded_instruction <= wriw;
         when 35 =>
            loaded_instruction <= writ;
         when 36 =>
            loaded_instruction <= rdi;
         when 37 =>
            loaded_instruction <= rdib;
         when 38 =>
            loaded_instruction <= rdiw;
         when 39 =>
            loaded_instruction <= rdit;
         when 40 => 
            loaded_instruction <= compi_e;
         when 41 =>
            loaded_instruction <= compi_ne;   
         when 42 =>
            loaded_instruction <= ldrr;   
         when 43 => 
            loaded_instruction <= shl;
         when 44 =>
            loaded_instruction <= shr;
            
         when others =>
            loaded_instruction <= load;
      end case;

      read(L,ch); -- bump past space between instruction number and register numebr

      read_hex_natural(L,register_select);		-- Convert register ASCII to register hex
      register_out(31 downto 0) <= conv_std_logic_vector(register_select,32);

      case register_select is			-- Convert register number to human-readable form
         when 1 =>
            register_sel <= rega;
         when 2 =>
            register_sel <= regb;
         when 3 =>
            register_sel <= regc;
         when 4 =>
            register_sel <= regd;
         when 5 =>
            register_sel <= reguser;
         when others =>
            register_sel <= rega;
      end case;
      
      read(L,ch);						   -- bump past space between reg number and literal  
      
      read_hex_natural(L,lit_val);
      literal_value <= conv_std_logic_vector(lit_val,32);	-- Get literal value
      wait for 1 fs;
      literal_out(31 downto 0) <= literal_value(31 downto 0);

      read(L,ch);

      read_hex_natural(L,next_instruction);     -- Get next instruction offset
      
      next_inst(31 downto 0) <= conv_std_logic_vector(next_instruction,32);

      wait for 1 fs;
	  -----------------------------------------------------------------------------------
	  -- The following case statement performs the instruction indicated in the vector
	  -- file.
	  -----------------------------------------------------------------------------------
      case loaded_instruction is

		 ------------------------------------------------------------
		 -- load loads the target register with the literal value
		 ------------------------------------------------------------
         when load =>
            case register_sel is
               when rega =>
                  registera <= literal_value;
               when regb =>
                  registerb <= literal_value;
               when regc =>
                  registerc <= literal_value;
               when regd =>
                  registerd <= literal_value;
               when reguser =>
                  reg_user_int <= literal_value;
               when others =>
                  registera <= registera;
            end case;
            instruction_offset := next_instruction;
		 ------------------------------------------------------------
		 -- comp_e compares the value in the target register to the
		 -- literal value. If the two are equal than the next 
		 -- instruction is executed. If not, the next instruction is
		 -- skipped.
		 ------------------------------------------------------------
         when comp_e =>
            case register_sel is
               when rega =>
                  if(registera(31 downto 0) = literal_value(31 downto 0)) then
                     instruction_offset := next_instruction;
                  else
                     instruction_offset := instruction_offset + 1;
                  end if;  

               when regb =>
                  if(registerb(31 downto 0) = literal_value(31 downto 0)) then
                     instruction_offset := next_instruction;
                  else
                     instruction_offset := instruction_offset + 1;
                  end if; 

               when regc =>
                  if(registerc(31 downto 0) = literal_value(31 downto 0)) then
                     instruction_offset := next_instruction;
                  else
                     instruction_offset := instruction_offset + 1;
                  end if; 

               when regd =>
                  if(registerd(31 downto 0) = literal_value(31 downto 0)) then
                     instruction_offset := next_instruction;
                  else
                     instruction_offset := instruction_offset + 1;
                  end if; 
               when reguser =>
                  if(reg_user_int(31 downto 0) = literal_value(31 downto 0)) then
                     instruction_offset := next_instruction;
                  else
                     instruction_offset := instruction_offset + 1;
                  end if; 
               when others =>
                  registera <= registera;
            end case;
         
		 ------------------------------------------------------------
		 -- comp_ne compares the value in the target register to the
		 -- literal value. If the two are equal than the next 
		 -- instruction is skipped. If not, the next instruction is
		 -- executed.
		 ------------------------------------------------------------
         when comp_ne =>
            case register_sel is
               when rega =>
                  if(registera(31 downto 0) /= literal_value(31 downto 0)) then
                     instruction_offset := next_instruction;
                  else
                     instruction_offset := instruction_offset + 1;
                  end if;  

               when regb =>
                  if(registerb(31 downto 0) /= literal_value(31 downto 0)) then
                     instruction_offset := next_instruction;
                  else
                     instruction_offset := instruction_offset + 1;
                  end if; 

               when regc =>
                  if(registerc(31 downto 0) /= literal_value(31 downto 0)) then
                     instruction_offset := next_instruction;
                  else
                     instruction_offset := instruction_offset + 1;
                  end if; 

               when regd =>
                  if(registerd(31 downto 0) /= literal_value(31 downto 0)) then
                     instruction_offset := next_instruction;
                  else
                     instruction_offset := instruction_offset + 1;
                  end if; 
               when reguser =>
                  if(reg_user_int(31 downto 0) /= literal_value(31 downto 0)) then
                     instruction_offset := next_instruction;
                  else
                     instruction_offset := instruction_offset + 1;
                  end if; 
               when others =>
                  registera <= registera;
            end case;
         
		 ------------------------------------------------------------
		 -- wr, wr.b, wr.w and wr.t perform a write cycle on the
		 -- target bus model. The address to be written to is the 
		 -- value stored as the literal, the data to be written is 
		 -- the value stored in the target register. The instructions
		 -- size suffix determines the contents of the cyc_siz bus
		 -- on the interface. 
		 ------------------------------------------------------------   
         when write | wrb | wrw | wrt =>
            case register_sel is
               when rega =>
                  cyc_data_out(31 downto 0) <= registera(31 downto 0);         
               when regb =>
                  cyc_data_out(31 downto 0) <= registerb(31 downto 0);
               when regc =>
                  cyc_data_out(31 downto 0) <= registerc(31 downto 0);
               when regd =>
                  cyc_data_out(31 downto 0) <= registerd(31 downto 0);
               when reguser =>
                  cyc_data_out(31 downto 0) <= reg_user_int(31 downto 0);
               when others =>
                  registera <= registera;
            end case;

            case loaded_instruction is
               when write =>  -- 32-bit write cycle
                  cyc_siz(1 downto 0) <= "10";
               when wrb =>    -- 8-bit
                  cyc_siz(1 downto 0) <= "00";
               when wrw =>    -- 16-bit
                  cyc_siz(1 downto 0) <= "01";
               when wrt =>    -- 16-bit
                  cyc_siz(1 downto 0) <= "11";
               when others =>
                  cyc_siz(1 downto 0) <= "00";
            end case;

            cyc_addr(31 downto 0) <= literal_value(31 downto 0);  
            cyc_rdwr <= '0';
            wait for 1 ns;
            start_cyc <= '1';
			   wait on cyc_done;
            wait for 1 fs;
			   start_cyc <= '0';
			   wait on cyc_done;
            
            wait for 20 ns;
            instruction_offset := next_instruction;

		 ------------------------------------------------------------
		 -- rd, rd.b, rd.w and rd.t perform a read cycle on the
		 -- target bus model. The address to be read from is the 
		 -- value stored as the literal, the data read is stored to 
		 -- the register indicated in the instruction. The instructions
		 -- size suffix determines the contents of the cyc_siz bus
		 -- on the interface. 
		 ------------------------------------------------------------   
         when read | rdb | rdw | rdt =>
            
            cyc_addr(31 downto 0) <= literal_value(31 downto 0);  
            cyc_rdwr <= '1';
            case loaded_instruction is
               when read =>  -- 32-bit write cycle
                  cyc_siz(1 downto 0) <= "10";
               when rdb =>    -- 8-bit
                  cyc_siz(1 downto 0) <= "00";
               when rdw =>    -- 16-bit
                  cyc_siz(1 downto 0) <= "01";
               when rdt =>    -- 16-bit
                  cyc_siz(1 downto 0) <= "11";
               when others =>
                  cyc_siz(1 downto 0) <= "00";
            end case;

            wait for 1 fs;
            if(cyc_done = '1') then    -- Make sure no cyc_done from last cycle
               wait on cyc_done;
            end if;
            wait for 1 fs;
            start_cyc <= '1';
		      wait on cyc_done;
            
            wait for 1 fs;
			   start_cyc <= '0';
            wait for 6.5 ns; 
                      
            case register_sel is
               when rega =>
                  registera(31 downto 0) <= cyc_data_in(31 downto 0);        
               when regb =>
                  registerb(31 downto 0) <= cyc_data_in(31 downto 0);
               when regc =>
                  
                  registerc(31 downto 0) <= cyc_data_in(31 downto 0);
               when regd =>
                  registerd(31 downto 0) <= cyc_data_in(31 downto 0);
               when reguser =>
                  reg_user_int(31 downto 0) <= cyc_data_in(31 downto 0);
               when others =>
                  registera <= registera;
            end case;
            instruction_offset := next_instruction;
            wait for 20 ns;


      
       ------------------------------------------------------------
		 -- wri, wri.b, wri.w and wri.t perform a write cycle on the
		 -- target bus model. The address to be written to is the 
		 -- value stored in the register pointed to by the literal
       -- value, the data to be written is the value stored in the 
       -- target register. The instructions size suffix determines 
       -- the contents of the cyc_siz bus on the interface. 
		 ------------------------------------------------------------   
         when wri | wrib | wriw | writ =>
            case register_sel is
               when rega =>
                  cyc_data_out(31 downto 0) <= registera(31 downto 0);         
               when regb =>
                  cyc_data_out(31 downto 0) <= registerb(31 downto 0);
               when regc =>
                  cyc_data_out(31 downto 0) <= registerc(31 downto 0);
               when regd =>
                  cyc_data_out(31 downto 0) <= registerd(31 downto 0);
               when reguser =>
                  cyc_data_out(31 downto 0) <= reg_user_int(31 downto 0);
               when others =>
                  registera <= registera;
            end case;

            case loaded_instruction is
               when wri =>  -- 32-bit write cycle
                  cyc_siz(1 downto 0) <= "10";
               when wrib =>    -- 8-bit
                  cyc_siz(1 downto 0) <= "00";
               when wriw =>    -- 16-bit
                  cyc_siz(1 downto 0) <= "01";
               when writ =>    -- 16-bit
                  cyc_siz(1 downto 0) <= "11";
               when others =>
                  cyc_siz(1 downto 0) <= "00";
            end case;

            case literal_value is
               when X"00000001" =>
                  cyc_addr(31 downto 0) <= registera(31 downto 0);         
               when X"00000002" =>
                  cyc_addr(31 downto 0) <= registerb(31 downto 0);
               when X"00000003" =>
                  cyc_addr(31 downto 0) <= registerc(31 downto 0);
               when X"00000004" =>
                  cyc_addr(31 downto 0) <= registerd(31 downto 0);
               when X"00000005" =>
                  cyc_addr(31 downto 0) <= reg_user_int(31 downto 0);
               when others =>
                  cyc_addr(31 downto 0) <= registera(31 downto 0);
            end case;

  
            cyc_rdwr <= '0';
            wait for 1 ns;
            start_cyc <= '1';
			   wait on cyc_done;
            wait for 1 fs;
			   start_cyc <= '0';
			   wait on cyc_done;
            
            wait for 20 ns;
            instruction_offset := next_instruction;

 
       ------------------------------------------------------------
		 -- rd, rd.b, rd.w and rd.t perform a read cycle on the
		 -- target bus model. The address to be read from is the 
		 -- value stored as the literal, the data read is stored to 
		 -- the register indicated in the instruction. The instructions
		 -- size suffix determines the contents of the cyc_siz bus
		 -- on the interface. 
		 ------------------------------------------------------------   
         when rdi | rdib | rdiw | rdit =>
            
            case literal_value(31 downto 0) is
               when X"00000001" =>
                  cyc_addr(31 downto 0) <= registera(31 downto 0);        
               when X"00000002" =>
                  cyc_addr(31 downto 0) <= registerb(31 downto 0);
               when X"00000003" =>
                  cyc_addr(31 downto 0) <= registerc(31 downto 0);
               when X"00000004" =>
                  cyc_addr(31 downto 0) <= registerd(31 downto 0);
               when X"00000005" =>
                  cyc_addr(31 downto 0) <= reg_user_int(31 downto 0);
               when others =>
                  cyc_addr(31 downto 0) <= (others => '0');
            end case;
            cyc_rdwr <= '1';

            case loaded_instruction is
               when rdi =>  -- 32-bit write cycle
                  cyc_siz(1 downto 0) <= "10";
               when rdib =>    -- 8-bit
                  cyc_siz(1 downto 0) <= "00";
               when rdiw =>    -- 16-bit
                  cyc_siz(1 downto 0) <= "01";
               when rdit =>    -- 16-bit
                  cyc_siz(1 downto 0) <= "11";
               when others =>
                  cyc_siz(1 downto 0) <= "00";
            end case;

            wait for 1 fs;
            if(cyc_done = '1') then    -- Make sure no cyc_done from last cycle
               wait on cyc_done;
            end if;
            wait for 1 fs;
            start_cyc <= '1';
		      wait on cyc_done;
            wait for 1 fs;
			   start_cyc <= '0';
            wait for 6.5 ns; 
            case register_sel is
               when rega =>
                  registera(31 downto 0) <= cyc_data_in(31 downto 0);        
               when regb =>
                  registerb(31 downto 0) <= cyc_data_in(31 downto 0);
               when regc =>
                  registerc(31 downto 0) <= cyc_data_in(31 downto 0);
               when regd =>
                  registerd(31 downto 0) <= cyc_data_in(31 downto 0);
               when reguser =>
                  reg_user_int(31 downto 0) <= cyc_data_in(31 downto 0);
               when others =>
                  registera <= registera;
            end case;
            instruction_offset := next_instruction;
            wait for 20 ns;

		 ------------------------------------------------------------
		 -- jump is an unconditional jump from the current instruction
		 -- offset to that indicated on the next instruction word.
		 ------------------------------------------------------------
         when jump =>
            instruction_offset := next_instruction;
            wait for 1 fs;

		 ------------------------------------------------------------
		 -- The AND instruction performs a logic AND between the 
		 -- contents of the indicated register and the literal value.
		 -- The result is stored in the indicated register.
		 ------------------------------------------------------------
         when and_inst=>
            case register_sel is
               when rega =>
                  registera(31 downto 0) <= registera(31 downto 0) AND literal_value(31 downto 0);        
               when regb =>
                  registerb(31 downto 0) <= registerb(31 downto 0) AND literal_value(31 downto 0);  
               when regc =>
                  registerc(31 downto 0) <= registerc(31 downto 0) AND literal_value(31 downto 0);  
               when regd =>
                  registerd(31 downto 0) <= registerd(31 downto 0) AND literal_value(31 downto 0);  
               when reguser =>
                  reg_user_int(31 downto 0) <= reg_user_int(31 downto 0) AND literal_value(31 downto 0);  
               when others =>
                  registera <= registera;
            end case;
            instruction_offset := next_instruction;
         
		 ------------------------------------------------------------
		 -- The OR instruction performs a logic OR between the 
		 -- contents of the indicated register and the literal value.
		 -- The result is stored in the indicated register.
		 ------------------------------------------------------------
         when or_inst=>
            case register_sel is
               when rega =>
                  registera(31 downto 0) <= registera(31 downto 0) OR literal_value(31 downto 0);        
               when regb =>
                  registerb(31 downto 0) <= registerb(31 downto 0) OR literal_value(31 downto 0);  
               when regc =>
                  registerc(31 downto 0) <= registerc(31 downto 0) OR literal_value(31 downto 0);  
               when regd =>
                  registerd(31 downto 0) <= registerd(31 downto 0) OR literal_value(31 downto 0);
               when reguser =>
                  reg_user_int(31 downto 0) <= reg_user_int(31 downto 0) OR literal_value(31 downto 0);  
               when others =>
                  registera <= registera;
            end case;
            instruction_offset := next_instruction;
         
		 ------------------------------------------------------------
		 -- The return instruction pops off the value stored at the
		 -- top of the stack into the instructions offset.
		 ------------------------------------------------------------
         when ret=>
            instruction_offset := stack_memory(stack_ptr);			-- Get number from top of stack into
																	-- next instruction
            stack_ptr := stack_ptr - 1;								-- Drop stack pointer down to next entry
            interrupt_cycle <= '0';
            wait for 1 fs;

		 ------------------------------------------------------------
		 -- The add instruction adds the literal value to the register
		 -- indicated by the instruction.
		 ------------------------------------------------------------
         when add =>
            case register_sel is
               when rega =>
                  registera(31 downto 0) <= registera(31 downto 0) + literal_value(31 downto 0);        
               when regb =>
                  registerb(31 downto 0) <= registerb(31 downto 0) + literal_value(31 downto 0);  
               when regc =>
                  registerc(31 downto 0) <= registerc(31 downto 0) + literal_value(31 downto 0);  
               when regd =>
                  registerd(31 downto 0) <= registerd(31 downto 0) + literal_value(31 downto 0);  
               when reguser =>
                  reg_user_int(31 downto 0) <= reg_user_int(31 downto 0) + literal_value(31 downto 0);  
               when others =>
                  registera <= registera;
            end case;
            instruction_offset := next_instruction;

		 ------------------------------------------------------------
		 -- The push instruction places the contents of the targetted
		 -- register onto the top of the stack.
		 ------------------------------------------------------------
         when push =>
            stack_ptr := stack_ptr + 1;			-- Stack point incremented to next available location
            wait for 1 fs;						-- Allow simulator to do it's business
            case register_sel is
               when rega =>
                  stack_memory(stack_ptr) := CONV_INTEGER(registera(31 downto 0));
               when regb =>
                  stack_memory(stack_ptr) := CONV_INTEGER(registerb(31 downto 0));
               when regc =>
                  stack_memory(stack_ptr) := CONV_INTEGER(registerc(31 downto 0));
               when regd =>
                  stack_memory(stack_ptr) := CONV_INTEGER(registerd(31 downto 0));
               when reguser =>
                  stack_memory(stack_ptr) := CONV_INTEGER(reg_user_int(31 downto 0));
               when others =>             
                  stack_memory(stack_ptr) := CONV_INTEGER(registera(31 downto 0));
            end case;
            instruction_offset := next_instruction;

		  ------------------------------------------------------------
		  -- The pop instruction retrieves the topmost entry on the
		  -- stack and places it into the targetted register.
		  ------------------------------------------------------------	
          when pop =>
            
            case register_sel is
               when rega =>
                  registera(31 downto 0) <= conv_std_logic_vector(stack_memory(stack_ptr),32);
               when regb =>
                  registerb(31 downto 0) <= conv_std_logic_vector(stack_memory(stack_ptr),32);
               when regc =>
                  registerc(31 downto 0) <= conv_std_logic_vector(stack_memory(stack_ptr),32);
               when regd =>
                  registerd(31 downto 0) <= conv_std_logic_vector(stack_memory(stack_ptr),32);
               when reguser =>
                  reg_user_int(31 downto 0) <= conv_std_logic_vector(stack_memory(stack_ptr),32);
               when others =>
                  registerd(31 downto 0) <= conv_std_logic_vector(stack_memory(stack_ptr),32);
            end case;
            stack_ptr := stack_ptr - 1;				-- Adjust stack pointer down
            instruction_offset := next_instruction;

		  ------------------------------------------------------------
		  -- The call instruction places the address of the next
		  -- instruction onto the top of the stack and then changes
		  -- the instruction pointer to the value of the next
		  -- instruction.
		  ------------------------------------------------------------
          when call =>
            -- instruction_offset holds current instruction
            stack_ptr := stack_ptr + 1;
            wait for 1 fs;
            stack_memory(stack_ptr) := instruction_offset + 1; -- set stack to next instruction

            instruction_offset := next_instruction;   -- load PC with called routine offset

		  ------------------------------------------------------------
		  -- HASM's method of performing burst read and write cycles
		  -- is to use a block of memory as the source and destination
		  -- of the data transferred in the burst cycle. In order for 
		  -- the HASM simulator to access this memory it must use a 
		  -- special instruction. The RDMEM instruction will read
		  -- the address specified by the second register in the 
		  -- instruction. The first register in the instruction 
		  -- receives the data from the memory.
		  ------------------------------------------------------------
          when rdmem =>
            instruction_offset := next_instruction;
            case register_sel is
               when rega =>
                  case literal_value(31 downto 0) is
                     when X"00000001" =>     -- rdmem rega,rega;
                        registera(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registera(31 downto 0))),32);
                     when X"00000002" =>     -- rdmem rega,regb;
                        registera(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerb(31 downto 0))),32);
                     when X"00000003" =>     -- rdmem rega,regc;
                        registera(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerc(31 downto 0))),32);
                     when X"00000004" =>     -- rdmem rega,regd;
                        registera(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerd(31 downto 0))),32);
                     when X"00000005" =>     -- rdmem rega,reguser;
                        registera(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(reg_user_int(31 downto 0))),32);
                     when others  =>         -- rdmem rega,rega;
                        registera(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registera(31 downto 0))),32);
                  end case;

               when regb =>
                  case literal_value(31 downto 0) is
                     when X"00000001" =>     -- rdmem regb,rega;
                        registerb(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registera(31 downto 0))),32);
                     when X"00000002" =>     -- rdmem regb,regb;
                        registerb(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerb(31 downto 0))),32);
                     when X"00000003" =>     -- rdmem regb,regc;
                        registerb(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerc(31 downto 0))),32);
                     when X"00000004" =>     -- rdmem regb,regd;
                        registerb(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerd(31 downto 0))),32);
                     when X"00000005" =>     -- rdmem regb,reguser;
                        registerb(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(reg_user_int(31 downto 0))),32);
                     when others  =>         -- rdmem regb,rega;
                        registerb(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registera(31 downto 0))),32);
                  end case;
         
               when regc =>
                  case literal_value(31 downto 0) is
                     when X"00000001" =>     -- rdmem regc,rega;
                        registerc(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registera(31 downto 0))),32);
                     when X"00000002" =>     -- rdmem regc,regb;
                        registerc(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerb(31 downto 0))),32);
                     when X"00000003" =>     -- rdmem regc,regc;
                        registerc(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerc(31 downto 0))),32);
                     when X"00000004" =>     -- rdmem regc,regd;
                        registerc(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerd(31 downto 0))),32);
                     when X"00000005" =>     -- rdmem regc,reguser;
                        registerc(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(reg_user_int(31 downto 0))),32);
                     
                     when others  =>         -- rdmem regc,rega;
                        registerc(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registera(31 downto 0))),32);
                  end case;

               when regd =>
                  case literal_value(31 downto 0) is
                     when X"00000001" =>     -- rdmem regd,rega;
                        registerd(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registera(31 downto 0))),32);
                     when X"00000002" =>     -- rdmem regd,regb;
                        registerd(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerb(31 downto 0))),32);
                     when X"00000003" =>     -- rdmem regd,regc;
                        registerd(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerc(31 downto 0))),32);
                     when X"00000004" =>     -- rdmem regd,regd;
                        registerd(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerd(31 downto 0))),32);
                     when X"00000005" =>     -- rdmem regd,reguser;
                        registerd(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(reg_user_int(31 downto 0))),32);
                     
                     when others  =>         -- rdmem regd,rega;
                        registerd(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registera(31 downto 0))),32);
                  end case;
      
               when reguser =>
                  case literal_value(31 downto 0) is
                     when X"00000001" =>     -- rdmem regd,rega;
                        reg_user_int(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registera(31 downto 0))),32);
                     when X"00000002" =>     -- rdmem regd,regb;
                        reg_user_int(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerb(31 downto 0))),32);
                     when X"00000003" =>     -- rdmem regd,regc;
                        reg_user_int(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerc(31 downto 0))),32);
                     when X"00000004" =>     -- rdmem regd,regd;
                        reg_user_int(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registerd(31 downto 0))),32);
                     when X"00000005" =>     -- rdmem reguser,reguser;
                        reg_user_int(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(reg_user_int(31 downto 0))),32);
                     
                     when others  =>         -- rdmem regd,rega;
                        registerd(31 downto 0) <= conv_std_logic_vector(burst_memory(CONV_INTEGER(registera(31 downto 0))),32);
                  end case;

               when others =>
            end case;
            
         ------------------------------------------------------------
		 -- WRMEM is the instruction used to write data to HASM's
		 -- internal memory block. This memory block is used as the
		 -- source and destination for burst read and write cycles
		 -- executed by the bus model.
		 -- WRMEM will write the contents of the second register 
		 -- to the block memory address stored in the first register.
		 ------------------------------------------------------------  
         when wrmem =>
            instruction_offset := next_instruction;
            case register_sel is
               when rega =>
                  case literal_value(31 downto 0) is
                     when X"00000001" =>     -- wrmem rega,rega;
                        burst_memory(CONV_INTEGER(registera(31 downto 0))) := CONV_INTEGER(registera(31 downto 0));
                     
                     when X"00000002" =>     -- wrmem rega,regb;
                        burst_memory(CONV_INTEGER(registerb(31 downto 0))) := CONV_INTEGER(registera(31 downto 0));
                     
                     when X"00000003" =>     -- wrmem rega,regc;
                        burst_memory(CONV_INTEGER(registerc(31 downto 0))) := CONV_INTEGER(registera(31 downto 0));
                     
                     when X"00000004" =>     -- wrmem rega,regd;
                        burst_memory(CONV_INTEGER(registerd(31 downto 0))) := CONV_INTEGER(registera(31 downto 0));

                     when X"00000005" =>     -- wrmem rega,reguser;
                        burst_memory(CONV_INTEGER(reg_user_int(31 downto 0))) := CONV_INTEGER(registera(31 downto 0));
                     
                     when others  =>         -- wrmem rega,rega;
                        burst_memory(CONV_INTEGER(registera(31 downto 0))) := CONV_INTEGER(registera(31 downto 0));
                  end case;

                when regb =>
                  case literal_value(31 downto 0) is
                     when X"00000001" =>     -- wrmem rega,rega;
                        burst_memory(CONV_INTEGER(registera(31 downto 0))) := CONV_INTEGER(registerb(31 downto 0));
                     when X"00000002" =>     -- wrmem rega,regb;
                        burst_memory(CONV_INTEGER(registerb(31 downto 0))) := CONV_INTEGER(registerb(31 downto 0));
                     when X"00000003" =>     -- wrmem rega,regc;                                                 
                        burst_memory(CONV_INTEGER(registerc(31 downto 0))) := CONV_INTEGER(registerb(31 downto 0));
                     when X"00000004" =>     -- wrmem rega,regd;
                        burst_memory(CONV_INTEGER(registerd(31 downto 0))) := CONV_INTEGER(registerb(31 downto 0));
                     when X"00000005" =>     -- wrmem rega,regd;
                        burst_memory(CONV_INTEGER(reg_user_int(31 downto 0))) := CONV_INTEGER(registerb(31 downto 0));
                     
                     when others  =>         -- wrmem rega,rega;
                        burst_memory(CONV_INTEGER(registera(31 downto 0))) := CONV_INTEGER(registerb(31 downto 0));
                  end case;

                 when regc =>
                  case literal_value(31 downto 0) is
                     when X"00000001" =>     -- wrmem rega,rega;
                        burst_memory(CONV_INTEGER(registera(31 downto 0))) := CONV_INTEGER(registerc(31 downto 0));
                     when X"00000002" =>     -- wrmem rega,regb;
                        burst_memory(CONV_INTEGER(registerb(31 downto 0))) := CONV_INTEGER(registerc(31 downto 0));
                     when X"00000003" =>     -- wrmem rega,regc;
                        burst_memory(CONV_INTEGER(registerc(31 downto 0))) := CONV_INTEGER(registerc(31 downto 0));
                     when X"00000004" =>     -- wrmem rega,regd;
                        burst_memory(CONV_INTEGER(registerd(31 downto 0))) := CONV_INTEGER(registerc(31 downto 0));
                     when X"00000005" =>     -- wrmem rega,regd;
                        burst_memory(CONV_INTEGER(reg_user_int(31 downto 0))) := CONV_INTEGER(registerc(31 downto 0));
                     
                     when others  =>         -- wrmem rega,rega;
                        burst_memory(CONV_INTEGER(registera(31 downto 0))) := CONV_INTEGER(registerc(31 downto 0));
                  end case;

                when regd =>
                  case literal_value(31 downto 0) is
                     when X"00000001" =>     -- wrmem rega,rega;
                        burst_memory(CONV_INTEGER(registera(31 downto 0))) := CONV_INTEGER(registerd(31 downto 0));
                     when X"00000002" =>     -- wrmem rega,regb
                        burst_memory(CONV_INTEGER(registerb(31 downto 0))) := CONV_INTEGER(registerd(31 downto 0));
                     when X"00000003" =>     -- wrmem rega,regc;
                        burst_memory(CONV_INTEGER(registerc(31 downto 0))) := CONV_INTEGER(registerd(31 downto 0));
                     when X"00000004" =>     -- wrmem rega,regd;
                        burst_memory(CONV_INTEGER(registerd(31 downto 0))) := CONV_INTEGER(registerd(31 downto 0));
                     when X"00000005" =>     -- wrmem rega,regd;
                        burst_memory(CONV_INTEGER(reg_user_int(31 downto 0))) := CONV_INTEGER(registerd(31 downto 0));
                     
                     when others  =>         -- wrmem rega,rega;
                        burst_memory(CONV_INTEGER(registera(31 downto 0))) := CONV_INTEGER(registerd(31 downto 0));
                  end case;
               
                when reguser =>
                  case literal_value(31 downto 0) is
                     when X"00000001" =>     -- wrmem rega,rega;
                        burst_memory(CONV_INTEGER(registera(31 downto 0))) := CONV_INTEGER(reg_user_int(31 downto 0));
                     when X"00000002" =>     -- wrmem rega,regb
                        burst_memory(CONV_INTEGER(registerb(31 downto 0))) := CONV_INTEGER(reg_user_int(31 downto 0));
                     when X"00000003" =>     -- wrmem rega,regc;
                        burst_memory(CONV_INTEGER(registerc(31 downto 0))) := CONV_INTEGER(reg_user_int(31 downto 0));
                     when X"00000004" =>     -- wrmem rega,regd;
                        burst_memory(CONV_INTEGER(registerd(31 downto 0))) := CONV_INTEGER(reg_user_int(31 downto 0));
                     when X"00000005" =>     -- wrmem rega,regd;
                        burst_memory(CONV_INTEGER(reg_user_int(31 downto 0))) := CONV_INTEGER(reg_user_int(31 downto 0));
                     
                     when others  =>         -- wrmem rega,rega;
                        burst_memory(CONV_INTEGER(registera(31 downto 0))) := CONV_INTEGER(reg_user_int(31 downto 0));
                  end case;
               
              
               when others =>
            end case; 

         ------------------------------------------------------------   
		 -- The rdbrst instruction causes the HASM simulator to 
		 -- execute a burst read cycle on the bus model. The first
		 -- register in the instruction contains the first address in
		 -- HASM's internal memory to receive the first value in the
		 -- burst cycle from the bus model. The second register in the
		 -- instruction contains the number of words to be transferred
		 -- in the burst.
		 ------------------------------------------------------------
         when rdbrst | rdbrstb | rdbrstw | rdbrstt =>
            instruction_offset := next_instruction;
            burst_ptr := 0;
            brst_quantity(31 downto 0) <= (others => '0');
            brst_cyc <= '1';
            cyc_rdwr <= '1';
            case loaded_instruction is
               when rdbrst => 
                  cyc_siz(1 downto 0) <= "10";
               when rdbrstb =>
                  cyc_siz(1 downto 0) <= "00";
               when rdbrstw =>
                  cyc_siz(1 downto 0) <= "01";
               when rdbrstt =>
                  cyc_siz(1 downto 0) <= "11";
               when others =>
                  cyc_siz(1 downto 0) <= "00";
            end case;
            case register_sel is    -- Get Address on target to read from
               when rega =>
                  cyc_addr(31 downto 0) <= registera(31 downto 0);
               when regb =>
                  cyc_addr(31 downto 0) <= registerb(31 downto 0);
               when regc =>
                  cyc_addr(31 downto 0) <= registerc(31 downto 0);
               when regd =>
                  cyc_addr(31 downto 0) <= registerd(31 downto 0); 
               when reguser =>
                  cyc_addr(31 downto 0) <= reg_user_int(31 downto 0); 
               when others =>
                  cyc_addr(31 downto 0) <= registera(31 downto 0);
            end case;
            wait for 1 fs;

            if(cyc_done = '1') then    -- Make sure no cyc_done from last cycle
               wait on cyc_done;
            end if;
            wait for 1 fs;
            if(brst_data_rdy = '1') then
               wait on brst_data_rdy;  -- Make sure of no left over ready signals
            end if;
            wait for 1 fs;

            start_cyc <= '1';
            brst_quantity(31 downto 0) <= literal_value(31 downto 0);
            for i in 0 to (CONV_INTEGER( (literal_value(31 downto 0)) - 1)   ) loop

               if(i = (CONV_INTEGER( (literal_value(31 downto 0)) - 1)   )   ) then
                  brst_last_int <= '1';
               end if;

               wait on brst_data_rdy;           -- rising edge burst ready
               wait for 6.5 ns;                   -- Space write operation in middle of data window
               burst_memory(i) := CONV_INTEGER(cyc_data_in(31 downto 0));
               wait for 1 fs;
               wait on brst_data_rdy;           -- falling edge burst ready

               if(brst_last_int = '1')then
                  brst_last_int <= '0';
               end if;

               wait for 1 fs;
            end loop;

            start_cyc <= '0';
            brst_last_int <= '0';
            brst_cyc <= '0';
            cyc_rdwr <= '0';
		      wait for 20 ns;
		 ------------------------------------------------------------
		 -- The wrbrst instruction causes the HASM simulator to execute
		 -- a burst write cycle on the bus model. The first register
		 -- in the instruction is the first address in HASM's memory 
		 -- block where the first data value to write is stored. The
		 -- second register in the instruction is the number of cycles
		 -- to execute in the burst.
		 ------------------------------------------------------------
         when wrbrst | wrbrstb | wrbrstw | wrbrstt  =>    
            instruction_offset := next_instruction;
            burst_ptr := 0;
            brst_quantity(31 downto 0) <= (others => '0');
            brst_cyc <= '1';
            cyc_rdwr <= '0';
            case loaded_instruction is
               when wrbrst => 
                  cyc_siz(1 downto 0) <= "10";
               when wrbrstb =>
                  cyc_siz(1 downto 0) <= "00";
               when wrbrstw =>
                  cyc_siz(1 downto 0) <= "01";
               when wrbrstt =>
                  cyc_siz(1 downto 0) <= "11";
               when others =>
                  cyc_siz(1 downto 0) <= "00";
            end case;
            case register_sel is
               when rega =>
                  cyc_addr(31 downto 0) <= registera(31 downto 0);
               when regb =>
                  cyc_addr(31 downto 0) <= registerb(31 downto 0);
               when regc =>
                  cyc_addr(31 downto 0) <= registerc(31 downto 0);
               when regd =>
                  cyc_addr(31 downto 0) <= registerd(31 downto 0); 
               when reguser =>
                  cyc_addr(31 downto 0) <= reg_user_int(31 downto 0); 
               when others =>
                  cyc_addr(31 downto 0) <= registera(31 downto 0);
            end case;
            wait for 1 fs;

            if(cyc_done = '1') then    -- Make sure no cyc_done from last cycle
               wait on cyc_done;
            end if;
            wait for 1 fs;
            if(brst_data_rdy = '1') then
               wait on brst_data_rdy;           -- make sure of no left over ready signals
            end if;
            wait for 1 fs;
            brst_quantity(31 downto 0) <= literal_value(31 downto 0);
            start_cyc <= '1';

            for i in 0 to (CONV_INTEGER( (literal_value(31 downto 0)) - 1)   ) loop

               if(i = CONV_INTEGER(literal_value(31 downto 0)) - 1) then
                  brst_last_int <= '1';
               end if;

               cyc_data_out(31 downto 0) <= conv_std_logic_vector(burst_memory(i),32);
               wait on brst_data_rdy;           -- rising edge burst ready
               wait for 1 fs;
               wait on brst_data_rdy;           -- falling edge burst ready
               wait for 1 fs;
            end loop;

            start_cyc <= '0';
            
            brst_cyc <= '0';
            cyc_rdwr <= '0';
            brst_last_int <= '0';
            wait for 20 ns;
   
		 ------------------------------------------------------------
		 -- The RMW_EN instruction sets HASM's read-modify-write line
		 -- high. This signal is meant to indicate to the bus model
		 -- that the next group of bus cycles should not be interupted.
		 ------------------------------------------------------------
         when rmw_en =>
            cyc_rmw <= '1';
            instruction_offset := next_instruction;

		 ------------------------------------------------------------
		 -- The RMW_DIS instruction shuts off HASM's read-modify-write
		 -- line.
		 ------------------------------------------------------------
         when rmw_dis =>
            cyc_rmw <= '0';
            instruction_offset := next_instruction;

       ------------------------------------------------------------
		 -- The delay instruction stops hasm for the number of 
       -- microseconds specified in the register field
		 ------------------------------------------------------------
         when delay =>
            register_delay(31 downto 0) <= conv_std_logic_vector(register_select,32);
            wait for 1 fs;
            time_delay := CONV_INTEGER((register_delay(31 downto 0) - X"00000001"));
            wait for 1 fs;
            for i in 0 to time_delay loop
               wait for 1 us;
            end loop;
            instruction_offset := next_instruction;
                          
       ------------------------------------------------------------
		 -- compi_e compares the value in the target register to the
		 -- value in another register. If the two are equal than the  
		 -- next instruction is executed. If not, the next 
		 -- instruction is skipped.
		 ------------------------------------------------------------
         when compi_e =>
            case register_sel is
               when rega =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" =>  -- Register A to Register A
                        if(registera(31 downto 0) = registera(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000002" =>  -- Register A to Register B
                        if(registera(31 downto 0) = registerb(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000003" =>  -- Register A to Register C
                        if(registera(31 downto 0) = registerc(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000004" =>  -- Register A to Register D
                        if(registera(31 downto 0) = registerd(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000005" =>  -- Register A to Register User
                        if(registera(31 downto 0) = reg_user_int(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when others =>
                        instruction_offset := next_instruction;
                  end case;
               when regb =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" =>  
                        if(registerb(31 downto 0) = registera(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000002" =>  
                        if(registerb(31 downto 0) = registerb(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000003" =>  
                        if(registerb(31 downto 0) = registerc(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000004" =>  
                        if(registerb(31 downto 0) = registerd(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000005" =>  
                        if(registerb(31 downto 0) = reg_user_int(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when others =>
                        instruction_offset := next_instruction;
                  end case;
                  
               when regc =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" =>  
                        if(registerc(31 downto 0) = registera(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000002" =>  
                        if(registerc(31 downto 0) = registerb(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000003" =>  
                        if(registerc(31 downto 0) = registerc(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000004" =>  
                        if(registerc(31 downto 0) = registerd(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000005" =>  
                        if(registerc(31 downto 0) = reg_user_int(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when others =>
                        instruction_offset := next_instruction;
                  end case;
                  
               when regd =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" =>  
                        if(registerd(31 downto 0) = registera(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000002" =>  
                        if(registerd(31 downto 0) = registerb(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000003" =>  
                        if(registerd(31 downto 0) = registerc(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000004" =>  
                        if(registerd(31 downto 0) = registerd(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000005" =>  
                        if(registerd(31 downto 0) = reg_user_int(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when others =>
                        instruction_offset := next_instruction;
                  end case;
                  
               when reguser =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" => 
                        if(reg_user_int(31 downto 0) = registera(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000002" =>  
                        if(reg_user_int(31 downto 0) = registerb(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000003" => 
                        if(reg_user_int(31 downto 0) = registerc(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000004" =>  
                        if(reg_user_int(31 downto 0) = registerd(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000005" => 
                        if(reg_user_int(31 downto 0) = reg_user_int(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when others =>
                        instruction_offset := next_instruction;
                     end case;
               end case;

       ------------------------------------------------------------
		 -- compi_e compares the value in the target register to the
		 -- value in another register. If the two are equal than the  
		 -- next instruction is executed. If not, the next 
		 -- instruction is skipped.
		 ------------------------------------------------------------
         when compi_ne =>
            case register_sel is
               when rega =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" =>  -- Register A to Register A
                        if(registera(31 downto 0) /= registera(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000002" =>  -- Register A to Register B
                        if(registera(31 downto 0) /= registerb(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000003" =>  -- Register A to Register C
                        if(registera(31 downto 0) /= registerc(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000004" =>  -- Register A to Register D
                        if(registera(31 downto 0) /= registerd(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000005" =>  -- Register A to Register User
                        if(registera(31 downto 0) /= reg_user_int(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when others =>
                        instruction_offset := next_instruction;
                  end case;
                        
               when regb =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" =>  
                        if(registerb(31 downto 0) /= registera(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000002" =>  
                        if(registerb(31 downto 0) /= registerb(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000003" =>  
                        if(registerb(31 downto 0) /= registerc(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000004" =>  
                        if(registerb(31 downto 0) /= registerd(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000005" =>  
                        if(registerb(31 downto 0) /= reg_user_int(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when others =>
                        instruction_offset := next_instruction;
                  end case;
                  
               when regc =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" =>  
                        if(registerc(31 downto 0) /= registera(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000002" =>  
                        if(registerc(31 downto 0) /= registerb(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000003" =>  
                        if(registerc(31 downto 0) /= registerc(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000004" =>  
                        if(registerc(31 downto 0) /= registerd(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000005" =>  
                        if(registerc(31 downto 0) /= reg_user_int(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when others =>
                        instruction_offset := next_instruction;
                  end case;
                  
               when regd =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" =>  
                        if(registerd(31 downto 0) /= registera(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000002" =>  
                        if(registerd(31 downto 0) /= registerb(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000003" =>  
                        if(registerd(31 downto 0) /= registerc(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000004" =>  
                        if(registerd(31 downto 0) /= registerd(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000005" =>  
                        if(registerd(31 downto 0) /= reg_user_int(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when others =>
                        instruction_offset := next_instruction;
                  end case;
                  
               when reguser =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" => 
                        if(reg_user_int(31 downto 0) /= registera(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000002" =>  
                        if(reg_user_int(31 downto 0) /= registerb(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000003" => 
                        if(reg_user_int(31 downto 0) /= registerc(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000004" =>  
                        if(reg_user_int(31 downto 0) /= registerd(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when X"00000005" => 
                        if(reg_user_int(31 downto 0) /= reg_user_int(31 downto 0)) then
                           instruction_offset := next_instruction;
                        else
                           instruction_offset := instruction_offset + 1;
                        end if;  
                     when others =>
                        instruction_offset := next_instruction;

                  end case;
               
               end case;
       ------------------------------------------------------------
		 -- ldrr loads one register with contents from another
		 ------------------------------------------------------------
         when ldrr =>
            case register_sel is
               when rega =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" => 
                        registera(31 downto 0) <= registera(31 downto 0);
                     when X"00000002" => 
                        registera(31 downto 0) <= registerb(31 downto 0);
                     when X"00000003" => 
                        registera(31 downto 0) <= registerc(31 downto 0);
                     when X"00000004" => 
                        registera(31 downto 0) <= registerd(31 downto 0);
                     when X"00000005" => 
                        registera(31 downto 0) <= reg_user_int(31 downto 0);
                     when others =>
                  end case;
               when regb =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" => 
                        registerb(31 downto 0) <= registera(31 downto 0);
                     when X"00000002" => 
                        registerb(31 downto 0) <= registerb(31 downto 0);
                     when X"00000003" => 
                        registerb(31 downto 0) <= registerc(31 downto 0);
                     when X"00000004" => 
                        registerb(31 downto 0) <= registerd(31 downto 0);
                     when X"00000005" => 
                        registerb(31 downto 0) <= reg_user_int(31 downto 0);
                     when others =>
                  end case;
               when regc =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" => 
                        registerc(31 downto 0) <= registera(31 downto 0);
                     when X"00000002" => 
                        registerc(31 downto 0) <= registerb(31 downto 0);
                     when X"00000003" => 
                        registerc(31 downto 0) <= registerc(31 downto 0);
                     when X"00000004" => 
                        registerc(31 downto 0) <= registerd(31 downto 0);
                     when X"00000005" => 
                        registerc(31 downto 0) <= reg_user_int(31 downto 0);
                     when others =>
                  end case;
               when regd =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" => 
                        registerd(31 downto 0) <= registera(31 downto 0);
                     when X"00000002" => 
                        registerd(31 downto 0) <= registerb(31 downto 0);
                     when X"00000003" => 
                        registerd(31 downto 0) <= registerc(31 downto 0);
                     when X"00000004" => 
                        registerd(31 downto 0) <= registerd(31 downto 0);
                     when X"00000005" => 
                        registerd(31 downto 0) <= reg_user_int(31 downto 0);
                     when others =>
                  end case;
               when reguser =>
                  case literal_value(31 downto 0) is 
                     when X"00000001" => 
                        reg_user_int(31 downto 0) <= registera(31 downto 0);
                     when X"00000002" => 
                        reg_user_int(31 downto 0) <= registerb(31 downto 0);
                     when X"00000003" => 
                        reg_user_int(31 downto 0) <= registerc(31 downto 0);
                     when X"00000004" => 
                        reg_user_int(31 downto 0) <= registerd(31 downto 0);
                     when X"00000005" => 
                        reg_user_int(31 downto 0) <= reg_user_int(31 downto 0);
                     when others =>
                  end case;
               when others =>
            end case;
            instruction_offset := next_instruction;                
      
         ------------------------------------------------------------
         -- shl shifts the contents of the target register left by
         -- the number of bit positions in the literal value.
         ------------------------------------------------------------
         when shl =>
            case register_sel is
               when rega =>
                  for i in 0 to CONV_INTEGER(literal_value(31 downto 0)) loop
                     registera(31 downto 0) <= registera(30 downto 0) & '0'; 
                     wait for 1 fs;                     
                  end loop;
               when regb =>
                  for i in 0 to CONV_INTEGER(literal_value(31 downto 0)) loop
                     registerb(31 downto 0) <= registerb(30 downto 0) & '0';  
                     wait for 1 fs;                     
                  end loop;
               when regc =>
                  for i in 0 to CONV_INTEGER(literal_value(31 downto 0)) loop
                     registerc(31 downto 0) <= registerc(30 downto 0) & '0'; 
                     wait for 1 fs;                     
                  end loop;
               when regd =>
                  for i in 0 to CONV_INTEGER(literal_value(31 downto 0)) loop
                     registerd(31 downto 0) <= registerd(30 downto 0) & '0';   
                     wait for 1 fs;                     
                  end loop;
               when reguser =>
                  for i in 0 to CONV_INTEGER(literal_value(31 downto 0)) loop
                     reg_user_int(31 downto 0) <= reg_user_int(30 downto 0) & '0'; 
                     wait for 1 fs;                     
                  end loop;
            end case;         
            instruction_offset := next_instruction;   
         
         ------------------------------------------------------------
         -- shr shifts the contents of the target register right by
         -- the number of bit positions in the literal value.
         ------------------------------------------------------------
         when shr =>
            case register_sel is
               when rega =>
                  for i in 0 to CONV_INTEGER(literal_value(31 downto 0) - X"00000001") loop
                     registera(31 downto 0) <= '0' & registera(31 downto 1); 
                     wait for 1 fs;
                  end loop;
               when regb =>
                  for i in 0 to CONV_INTEGER(literal_value(31 downto 0) - X"00000001") loop
                     registerb(31 downto 0) <= '0' & registerb(31 downto 1); 
                     wait for 1 fs;                     
                  end loop;
               when regc =>
                  for i in 0 to CONV_INTEGER(literal_value(31 downto 0) - X"00000001") loop
                     registerc(31 downto 0) <= '0' & registerc(31 downto 1);  
                     wait for 1 fs;                     
                  end loop;
               when regd =>
                  for i in 0 to CONV_INTEGER(literal_value(31 downto 0) - X"00000001") loop
                     registerd(31 downto 0) <= '0' & registerd(31 downto 1);   
                     wait for 1 fs;                     
                  end loop;
               when reguser =>
                  for i in 0 to CONV_INTEGER(literal_value(31 downto 0) - X"00000001") loop
                     reg_user_int(31 downto 0) <= '0' & reg_user_int(31 downto 1);  
                     wait for 1 fs;                     
                  end loop;
            end case;         
            instruction_offset := next_instruction;   
         
         
      
         when others =>

                   
      end case;

   end loop;
wait for 50 ms;
end process;


end Behavioral;
