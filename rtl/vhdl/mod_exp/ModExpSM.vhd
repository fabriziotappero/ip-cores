-----------------------------------------------------------------------
----                                                               ----
---- Montgomery modular multiplier and exponentiator               ----
----                                                               ----
---- This file is part of the Montgomery modular multiplier        ----
---- and exponentiator project                                     ----
---- http://opencores.org/project,mod_mult_exp                     ----
----                                                               ----
---- Description:                                                  ----
----   This is state machine of the Montgomery modular             ----
----   exponentiator. It controls all the registers, block memory  ----
----   and the exponentiation process.                             ----
----                                                               ----
---- To Do:                                                        ----
----   Description                                                 ----
---- Author(s):                                                    ----
---- - Krzysztof Gajewski, gajos@opencores.org                     ----
----                       k.gajewski@gmail.com                    ----
----                                                               ----
-----------------------------------------------------------------------
----                                                               ----
---- Copyright (C) 2014 Authors and OPENCORES.ORG                  ----
----                                                               ----
---- This source file may be used and distributed without          ----
---- restriction provided that this copyright statement is not     ----
---- removed from the file and that any derivative work contains   ----
---- the original copyright notice and the associated disclaimer.  ----
----                                                               ----
---- This source file is free software; you can redistribute it    ----
---- and-or modify it under the terms of the GNU Lesser General    ----
---- Public License as published by the Free Software Foundation;  ----
---- either version 2.1 of the License, or (at your option) any    ----
---- later version.                                                ----
----                                                               ----
---- This source is distributed in the hope that it will be        ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied    ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR       ----
---- PURPOSE. See the GNU Lesser General Public License for more   ----
---- details.                                                      ----
----                                                               ----
---- You should have received a copy of the GNU Lesser General     ----
---- Public License along with this source; if not, download it    ----
---- from http://www.opencores.org/lgpl.shtml                      ----
----                                                               ----
-----------------------------------------------------------------------
library IEEE;
use work.properties.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ModExpSM is
    generic(
        word_size   : integer := WORD_LENGTH;
        word_binary : integer := WORD_INTEGER
    );
    port (
        data_in_ready  : in  STD_LOGIC;
        clk            : in  STD_LOGIC;
        exp_ctrl       : in  STD_LOGIC_VECTOR(2 downto 0);
        reset          : in  STD_LOGIC;
        in_mux_control : out STD_LOGIC_VECTOR(1 downto 0);
        -- finalizer end status
        ready          : out STD_LOGIC;
        -- control for multiplier
        modMultStart   : out STD_LOGIC;
        modMultReady   : in  STD_LOGIC;
        -- control for memory and registers
        addr_dataA     : out STD_LOGIC_VECTOR(3 downto 0);
        addr_dataB     : out STD_LOGIC_VECTOR(3 downto 0);
        regData_EnA    : out STD_LOGIC_vector(0 downto 0);
        regData_EnB    : out STD_LOGIC_vector(0 downto 0);
        regData_EnC    : out STD_LOGIC;
        regData_EnExponent   : out STD_LOGIC;
        ExponentData         : in  STD_LOGIC_VECTOR(word_size - 1 downto 0);
        memory_reset   : out std_logic
	 );
end ModExpSM;

architecture Behavioral of ModExpSM is

-- Enable signals for registers and block memory
signal regDataEnA  : STD_LOGIC_vector(0 downto 0);
signal regDataEnB  : STD_LOGIC_vector(0 downto 0);
signal regDataEnC  : STD_LOGIC;
signal regDataEnD2 : STD_LOGIC;

-- states data 
signal state      : exponentiator_states;
signal next_state : exponentiator_states;

-- addres data for block memory ''registers''
signal addr_reg_A : STD_LOGIC_VECTOR(3 downto 0);
signal addr_reg_B : STD_LOGIC_VECTOR(3 downto 0);

-- signal informing about first exponentiation in given word
signal first_exp  : STD_LOGIC; 

-- signal for counting the iterations during exponentiation
signal position_counter : std_logic_vector(word_binary downto 0);

begin
    -- signals assigment
	regData_EnA <= regDataEnA;
	regData_EnB <= regDataEnB;
	regData_EnC <= regDataEnC;
	regData_EnExponent <= regDataEnD2;
	addr_dataA <= addr_reg_A;
	addr_dataB <= addr_reg_B;

    -- State machine process
    SM : process(data_in_ready, exp_ctrl, modMultReady, state, position_counter)
        begin
            case state is
                when FIRST_RUN => 
                    -- Preparing the core before the exponentiation
                    in_mux_control <= "10";
                    ready          <= '0';
                    modMultStart   <= '0';
                    regDataEnA <= "0";
                    regDataEnB <= "0";
                    regDataEnC <= '0';
                    regDataEnD2 <= '0';
                    addr_reg_A <= addr_unused;
                    addr_reg_B <= addr_unused;
                    first_exp <= '1';
                    next_state <= NOP;
				-- ''No operation'' during waiting  for the command and suitable data
                when NOP =>
                    in_mux_control <= "11";
                    ready          <= '0';
                    modMultStart   <= '0';
                    first_exp <= '1';
                    regDataEnA <= "1";
                    regDataEnB <= "1";
                    regDataEnC <= '0';
                    regDataEnD2 <= '0';
                    -- Read base 
                    if (exp_ctrl = mn_read_base) and (data_in_ready = '1') then
                        addr_reg_A <= addr_base;
                        addr_reg_B <= addr_base;
                        next_state <= READ_DATA_BASE;
                    -- Read modulus
                    elsif (exp_ctrl = mn_read_modulus) and (data_in_ready = '1') then
                        regDataEnC <= '1';
                        addr_reg_A <= addr_modulus;
                        addr_reg_B <= addr_modulus;
                        next_state <= READ_DATA_MODULUS;
                    -- Read exponent
                    elsif (exp_ctrl = mn_read_exponent) and (data_in_ready = '1') then
                        regDataEnD2 <= '1';
                        addr_reg_A <= addr_exponent;
                        addr_reg_B <= addr_exponent;
                        next_state <= READ_DATA_EXPONENT;
                    -- Read residuum
                    elsif (exp_ctrl = mn_read_residuum) and (data_in_ready = '1') then
                        addr_reg_A <= addr_residuum;
                        addr_reg_B <= addr_residuum;
                        next_state <= READ_DATA_RESIDUUM;
                    -- Read power
                    elsif (exp_ctrl = mn_count_power) then
                        in_mux_control <= "01";
                        addr_reg_A <= addr_one;
                        addr_reg_B <= addr_one;
                        next_state <= COUNT_POWER;
                    -- Prepare the exponentiator for the new data 
                    -- i.e. wrong data was readed first. More important 
                    -- prepare is after the exponentiation (SHOW_RESULT)
                    elsif (exp_ctrl = mn_prepare_for_data) then
                        addr_reg_A <= addr_unused;
                        addr_reg_B <= addr_unused;
                        regDataEnA <= "0";
                        regDataEnB <= "0";
                        regDataEnC <= '0';
                        regDataEnD2 <= '0';
                        next_state <= FIRST_RUN;
                    -- in case of unpredicted ''command'' appear
                    else
                        addr_reg_A <= addr_unused;
                        addr_reg_B <= addr_unused;
                        regDataEnA <= "0";
                        regDataEnB <= "0";
                        regDataEnC <= '0';
                        regDataEnD2 <= '0';
                        next_state <= NOP;
                    end if;
                -- ''READ'' states differs only by the addres under
                -- which the data are written.
                -- State for reading base of the exponentiation
                when READ_DATA_BASE => 
                    in_mux_control <= "11";
                    ready          <= '0';
                    modMultStart   <= '0';
                    addr_reg_A <= addr_base;
                    addr_reg_B <= addr_base;
                    regDataEnA <= "1";
                    regDataEnB <= "1";
                    regDataEnC <= '0';
                    regDataEnD2 <= '0';
                    next_state <= NOP;
                    first_exp <= '1';
                -- State for reading the modulus
                when READ_DATA_MODULUS =>
                    in_mux_control <= "11";
                    ready          <= '0';
                    modMultStart   <= '0';
                    addr_reg_A <= addr_modulus;
                    addr_reg_B <= addr_modulus;
                    regDataEnA <= "1";
                    regDataEnB <= "1";
                    regDataEnC <= '1';
                    regDataEnD2 <= '0';
                    next_state <= NOP;
                    first_exp <= '1';
                -- State for reading the exponent
                when READ_DATA_EXPONENT =>
                    in_mux_control <= "11";
                    ready          <= '0';
                    modMultStart   <= '0';
                    addr_reg_A <= addr_exponent;
                    addr_reg_B <= addr_exponent;
                    regDataEnA <= "1";
                    regDataEnB <= "1";
                    regDataEnC <= '0';
                    regDataEnD2 <= '1';
                    next_state <= NOP;
                    first_exp <= '1';
                -- State for reading the residuum
                when READ_DATA_RESIDUUM =>
                    in_mux_control <= "11";
                    ready          <= '0';
                    modMultStart   <= '0';
                    addr_reg_A <= addr_residuum;
                    addr_reg_B <= addr_residuum;
                    regDataEnA <= "1";
                    regDataEnB <= "1";
                    regDataEnC <= '0';
                    regDataEnD2 <= '0';
                    next_state <= NOP;
                    first_exp <= '1';
                -- State for preparing the system for the exponentiation
                -- First pre computed value ''Z'' - prepare data
                when COUNT_POWER =>
                    in_mux_control <= "10";
                    ready          <= '0';
                    modMultStart   <= '0';
                    regDataEnA <= "0";
                    regDataEnB <= "0";
                    regDataEnC <= '0';
                    regDataEnD2 <= '0';
                    addr_reg_A <= addr_one;
                    addr_reg_B <= addr_residuum;
                    first_exp <= '1';
                    next_state <= EXP_Z;
                -- ''Z'' multiplying - in case if it is first computation or no
				-- system behaves a little bit different
                when EXP_Z =>
                    regDataEnC <= '0';
                    regDataEnD2 <= '0';
                    regDataEnD2 <= '0';
                    ready <= '0';
                    in_mux_control <= "10";
                    modMultStart <= '1';
					-- If end of multiplying
                    if (modMultReady = '1') then
                        addr_reg_A <= addr_z;
                        addr_reg_B <= addr_z;
                        regDataEnA <= "1";
                        regDataEnB <= "1";
                        if (first_exp = '1') then
                            first_exp <= '1';
                        else
                            first_exp <= '0';
                        end if;
                        next_state <= SAVE_EXP_Z;
                    else
					    -- During first exponentiation it is ''Z precomputing''
                        if (first_exp = '1') then
                            first_exp <= '1';
                            addr_reg_A <= addr_one;
                            addr_reg_B <= addr_residuum;
                        -- in another case computing related with the algorithm
                        else
                            first_exp <= '0';
                            if (ExponentData(conv_integer(position_counter)) = '1') then
                                addr_reg_A <= addr_z;
                                addr_reg_B <= addr_p;
                            else
                                addr_reg_A <= addr_p;
                                addr_reg_B <= addr_p;
                            end if;
                        end if;
                        regDataEnA <= "0";
                        regDataEnB <= "0";
                        next_state <= EXP_Z;
                    end if;
                -- Svaing the ''Z'' calculation result
                when SAVE_EXP_Z =>
                    modMultStart <= '0';
                    ready <= '0';
                    in_mux_control <= "10";
                    regDataEnA <= "0";
                    regDataEnB <= "0";
                    regDataEnC <= '0';
                    regDataEnD2 <= '0';
					-- Preparing for the ''P'' precalculation in case first 
                    -- calculation of the exponentiation
                    if (first_exp = '1') then
                        first_exp <= '1';
                        addr_reg_A <= addr_base;
                        addr_reg_B <= addr_residuum;
                        next_state <= EXP_P;
                    -- In another case ''P'' square is performed
                    else
                        first_exp <= '0';
                        addr_reg_A <= addr_p;
                        addr_reg_B <= addr_p;
                        next_state <= EXP_P;
                    end if;
                -- ''P'' multiplying - in case if it is first computation or no
				-- system behaves a little bit different
                when EXP_P =>
                    modMultStart <= '1';
                    ready <= '0';
                    in_mux_control <= "10";
                    regDataEnC <= '0';
                    regDataEnD2 <= '0';
					-- If end of multiplying
                    if (modMultReady = '1') then
                        addr_reg_A <= addr_p;
                        addr_reg_B <= addr_p;
                        regDataEnA <= "1";
                        regDataEnB <= "1";
                        if (first_exp = '1') then
                            first_exp <= '1';
                        else
                            first_exp <= '0';
                        end if;
                        next_state <= SAVE_EXP_P;
                    else
                        -- During first exponentiation it is ''P precomputing''
                        if (first_exp = '1') then
                            first_exp <= '1';
                            addr_reg_A <= addr_base;
                            addr_reg_B <= addr_residuum;
						-- in another case computing related with the algorithm
                        else
                            first_exp <= '0';
                            addr_reg_A <= addr_p;
                            addr_reg_B <= addr_p;
                        end if;
                        regDataEnA <= "0";
                        regDataEnB <= "0";
                        next_state <= EXP_P;
                    end if;
                -- Svaing the ''P'' calculation result
                when SAVE_EXP_P =>
                    ready <= '0';
                    modMultStart <= '0';
                    in_mux_control <= "10";
                    regDataEnA <= "0";
                    regDataEnB <= "0";
                    regDataEnC <= '0';
                    regDataEnD2 <= '0';
                    addr_reg_A <= addr_p;
                    addr_reg_B <= addr_p;
                    first_exp <= '0';
                    next_state <= EXP_CONTROL;
                -- State controlling the exponentiation process
                -- related to compute ''Z'' or ''P'' element
                when EXP_CONTROL =>
                    ready <= '0';
                    modMultStart <= '0';
                    in_mux_control <= "10";
                    regDataEnA <= "0";
                    regDataEnB <= "0";
                    regDataEnC <= '0';
                    regDataEnD2 <= '0';
                    -- Checking if it was last exponentiation (if yes
                    -- post computing stage is performed)
                    -- modify for change key size by properties 
                    -- (historical remark)
                    if (position_counter(word_binary - 1) = '1') then
                        addr_reg_A <= addr_one;
                        addr_reg_B <= addr_z;
                        next_state <= EXP_END;
                    -- in another case algorithm 'stage' checking is made 
                    else
                        if (ExponentData(conv_integer(position_counter)) = '1') then
                            addr_reg_A <= addr_z;
                            addr_reg_B <= addr_p;
                            next_state <= EXP_Z;
                        else
                            addr_reg_A <= addr_p;
                            addr_reg_B <= addr_p;
                            next_state <= EXP_P;
                        end if;
                    end if;
                    first_exp <= '0';
                -- Algorithm ''post computing''
                when EXP_END =>
                    modMultStart <= '1';
                    ready <= '0';
                    in_mux_control <= "10";
                    addr_reg_A <= addr_one;
                    addr_reg_B <= addr_z;
                    -- if end of ''post computing'' multiplying
                    -- save result
                    if (modMultReady = '1') then
                        addr_reg_A <= addr_power;
                        addr_reg_B <= addr_power;
                        regDataEnA <= "1";
                        regDataEnB <= "1";
                        regDataEnC <= '0';
                        regDataEnD2 <= '0';
                        next_state <= SAVE_EXP_MULT;
                    -- in another case ''wait'' for the end
                    else
                        regDataEnA <= "0";
                        regDataEnB <= "0";
                        regDataEnC <= '0';
                        regDataEnD2 <= '0';
                        next_state <= EXP_END;
                    end if;
                    first_exp <= '0';
                -- save step
                when SAVE_EXP_MULT =>
                    in_mux_control <= "10";
                    modMultStart <= '0';
                    ready <= '0';
                    addr_reg_A <= addr_power;
                    addr_reg_B <= addr_power;
                    regDataEnA <= "1";
                    regDataEnB <= "1";
                    regDataEnC <= '0';
                    regDataEnD2 <= '0';
                    first_exp <= '1';
                    next_state <= INFO_RESULT;
                -- Stage informing ''the world'' about end of 
				-- exponentiation
                when INFO_RESULT =>
                    modMultStart <= '0';
                    in_mux_control <= "10";
                    ready <= '1';
                    addr_reg_A <= addr_power;
                    addr_reg_B <= addr_power;
                    regDataEnA <= "0";
                    regDataEnB <= "0";
                    regDataEnC <= '0';
                    regDataEnD2 <= '0';
                    if (exp_ctrl = mn_show_result) then
                        next_state <= SHOW_RESULT;
                    else
                        next_state <= INFO_RESULT;
                    end if;
                    first_exp <= '1';
                -- Show result
                when SHOW_RESULT =>
                    ready <= '1';
                    in_mux_control <= "10";
                    modMultStart <= '0';
                    addr_reg_A <= addr_power;
                    addr_reg_B <= addr_power;
                    regDataEnA <= "0";
                    regDataEnB <= "0";
                    regDataEnC <= '0';
                    regDataEnD2 <= '0';
                    -- Here we are waiting until ''prepare data'' command
                    -- appears
                    if (exp_ctrl = mn_prepare_for_data) then
                        next_state <= FIRST_RUN;
                    else
                        next_state <= SHOW_RESULT;
                    end if;
                    first_exp <= '1';
            end case;
        end process SM;

    -- Process resetting the block memory and registers before each exponentiation
    memory_reset_proc : process(clk, reset, state)
        begin
            if (reset = '1') then
                memory_reset <= '1';
            elsif (clk = '1' and clk'Event) then
                if (state = FIRST_RUN) then
                    memory_reset <= '1';
                else
                    memory_reset <= '0';
                end if;
            end if;
        end process memory_reset_proc;

    -- State change process
    state_modifier : process (clk, reset)
        begin
            if (reset = '1') then
                state <= FIRST_RUN;				
            elsif (clk = '1' and clk'Event) then
                state <= next_state;
            end if;
        end process state_modifier;

    -- Counter process for the control of the exponentiation number iteration
    counter_modifier : process (state, clk, reset)
	    begin
            if (clk = '1' and clk'Event) then
                if (reset = '1') then
                    position_counter <= (others => '1');
                elsif (state = SAVE_EXP_P) then
                    position_counter <= position_counter + 1;
                elsif (state = EXP_END) then
                    position_counter <= (others => '1');
                else
                    position_counter <= position_counter;
                end if;
            end if;
		end process counter_modifier;

end Behavioral;