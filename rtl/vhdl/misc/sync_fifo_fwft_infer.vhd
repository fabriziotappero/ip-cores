------------------------------------------------------------------- 
--                                                               --
--  Copyright (C) 2013 Author and VariStream Studio              --
--  Author : Yu Peng                                             --
--                                                               -- 
--  This source file may be used and distributed without         -- 
--  restriction provided that this copyright statement is not    -- 
--  removed from the file and that any derivative work contains  -- 
--  the original copyright notice and the associated disclaimer. -- 
--                                                               -- 
--  This source file is free software; you can redistribute it   -- 
--  and/or modify it under the terms of the GNU Lesser General   -- 
--  Public License as published by the Free Software Foundation; -- 
--  either version 2.1 of the License, or (at your option) any   -- 
--  later version.                                               -- 
--                                                               -- 
--  This source is distributed in the hope that it will be       -- 
--  useful, but WITHOUT ANY WARRANTY; without even the implied   -- 
--  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      -- 
--  PURPOSE.  See the GNU Lesser General Public License for more -- 
--  details.                                                     -- 
--                                                               -- 
--  You should have received a copy of the GNU Lesser General    -- 
--  Public License along with this source; if not, download it   -- 
--  from http://www.opencores.org/lgpl.shtml                     -- 
--                                                               -- 
------------------------------------------------------------------- 
-- Description:
--   Implement BRAM according to gADDRESS_WIDTH and gDATA_WIDTH
--   Maxim number of data word is (2**gADDRESS_WIDTH - 1)
-------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;  
USE ieee.std_logic_arith.all;
--use synplify.attributes.all;

entity sync_fifo_fwft_infer is
	generic (
		gADDRESS_WIDTH : integer range 4 to (integer'HIGH) := 8; 
		gDATA_WIDTH : integer := 32;
		gDYNAMIC_PROG_FULL_TH : boolean := false;
		gDYNAMIC_PROG_EMPTY_TH : boolean := false
		);
	port(
		iClk : in std_logic := '0';
		iReset_sync : in std_logic := '0';

		ivProgFullTh : in std_logic_vector(gADDRESS_WIDTH-1 downto 0) := conv_std_logic_vector(2**gADDRESS_WIDTH-3, gADDRESS_WIDTH);
		ivProgEmptyTh : in std_logic_vector(gADDRESS_WIDTH-1 downto 0) := conv_std_logic_vector(2, gADDRESS_WIDTH);
		
		iWrEn : in std_logic := '0';
		iRdEn : in std_logic := '0';
		ivDataIn : in std_logic_vector(gDATA_WIDTH-1 downto 0) := (others=>'0');
		ovDataOut : out std_logic_vector(gDATA_WIDTH-1 downto 0) := (others=>'0');
		oDataOutValid : out std_logic := '0';
		
		oFull : out std_logic := '0';
		oEmpty : out std_logic := '1';
		oAlmostFull : out std_logic := '0';
		oAlmostEmpty : out std_logic := '1';
		oProgFull : out std_logic := '0';
		oProgEmpty : out std_logic := '1';
		
		oOverflow : out std_logic := '0';
		oUnderflow : out std_logic := '0'
	);
end sync_fifo_fwft_infer;

ARCHITECTURE behavioral OF sync_fifo_fwft_infer IS

	component sdpram_infer_read_first is
	    generic (
	        gADDRESS_WIDTH : integer := 5;
	        gDATA_WIDTH : integer := 24
	        );
	    port (
	        iClk : in std_logic;
	        iReset_sync : in std_logic;
	        iWe : in std_logic;
	        ivWrAddr : in std_logic_vector(gADDRESS_WIDTH-1 downto 0);
			ivRdAddr : in std_logic_vector(gADDRESS_WIDTH-1 downto 0);
	        ivDataIn : in std_logic_vector(gDATA_WIDTH-1 downto 0);
	        ovDataOut : out std_logic_vector(gDATA_WIDTH-1 downto 0)
	        );
	end component;
	
	component pipelines_without_reset IS
		GENERIC (gBUS_WIDTH : integer := 1; gNB_PIPELINES: integer range 1 to 255 := 2);
		PORT(
			iClk				: IN		STD_LOGIC;
			iInput				: IN		STD_LOGIC;
			ivInput				: IN		STD_LOGIC_VECTOR(gBUS_WIDTH-1 downto 0);
			oDelayed_output		: OUT		STD_LOGIC;
			ovDelayed_output	: OUT		STD_LOGIC_VECTOR(gBUS_WIDTH-1 downto 0)
		);
	END component;
	
	signal svWriteAddr : std_logic_vector(gADDRESS_WIDTH-1 downto 0) := (others=>'0');
	signal svReadAddr : std_logic_vector(gADDRESS_WIDTH-1 downto 0) := (others=>'0');
	signal sEffectiveWrEn : std_logic := '0';
	signal sEffectiveRdEn : std_logic := '0';
	signal svFifoCount : std_logic_vector(gADDRESS_WIDTH-1 downto 0) := (others=>'0');
	signal svProgFullThM1 : std_logic_vector(gADDRESS_WIDTH-1 downto 0) := conv_std_logic_vector(2**gADDRESS_WIDTH-4, gADDRESS_WIDTH);
	signal svProgEmptyThP1 : std_logic_vector(gADDRESS_WIDTH-1 downto 0) := conv_std_logic_vector(3, gADDRESS_WIDTH);
	signal sFifoFull : std_logic := '0';
	signal sFifoEmpty : std_logic := '1';
	signal sAlmostFull : std_logic := '0';
	signal sAlmostEmpty : std_logic := '1';
	signal sProgFull : std_logic := '0';
	signal sProgEmpty : std_logic := '1';
	signal sFifoOverflow : std_logic := '0';
	signal sFifoUnderflow : std_logic := '0';
	
	signal svMemDataOut : std_logic_vector(gDATA_WIDTH-1 downto 0) := (others=>'0');
	signal sMemDataOutValid : std_logic := '0';
	signal svPipeDataOut : std_logic_vector(gDATA_WIDTH-1 downto 0) := (others=>'0');
	signal sPipeDataOutValid: std_logic := '0';

	
BEGIN
	sdpram_inst: sdpram_infer_read_first
	    generic map(
	        gADDRESS_WIDTH => gADDRESS_WIDTH,
	        gDATA_WIDTH => gDATA_WIDTH
	        )
	    port map(
	        iClk => iClk,
	        iReset_sync => iReset_sync,
	        iWe => iWrEn,
	        ivWrAddr => svWriteAddr,
			ivRdAddr => svReadAddr,
	        ivDataIn => ivDataIn,
	        ovDataOut => svMemDataOut
	        );
			
	sMemDataOutValid <= iRdEn;

	-----------------------------------------------------------------------------------------------
	-- Generate the write and read pointers
	-----------------------------------------------------------------------------------------------
	process(iClk)
	begin
		if rising_edge(iClk) then
			if iReset_sync = '1' then
				svWriteAddr <= (others=>'0');
			elsif sEffectiveWrEn = '1' then
				svWriteAddr <= svWriteAddr + '1';
			end if;
		end if;
	end process;
	
	process(iClk)
	begin
		if rising_edge(iClk) then
			if iReset_sync = '1' then
				svReadAddr <= (others=>'0');
			elsif sEffectiveRdEn = '1' then
				svReadAddr <= svReadAddr + '1';
			end if;
		end if;
	end process;
 
	-----------------------------------------------------------------------------------------------
	-- Generate Fifo Flags
	-----------------------------------------------------------------------------------------------
	sEffectiveWrEn <= iWrEn and (not sFifoFull); 
	sEffectiveRdEn <= iRdEn and (not sFifoEmpty);
	
	ProgFullThM1_gen_dynamic : if gDYNAMIC_PROG_FULL_TH = true generate
		process (iClk)
		begin
			if rising_edge(iClk) then
				svProgFullThM1 <= ivProgFullTh - '1';
			end if;
		end process;
	end generate;
	
	ProgFullThM1_gen_static : if gDYNAMIC_PROG_FULL_TH = false generate
		svProgFullThM1 <= ivProgFullTh - '1';
	end generate;
	
	ProgEmptyThM1_gen_dynamic : if gDYNAMIC_PROG_EMPTY_TH = true generate
		process (iClk)
		begin
			if rising_edge(iClk) then
				svProgEmptyThP1 <= ivProgEmptyTh + '1';
			end if;
		end process;
	end generate;
	
	ProgEmptyThM1_gen_static : if gDYNAMIC_PROG_EMPTY_TH = false generate
		svProgEmptyThP1 <= ivProgEmptyTh + '1';
	end generate;
	
	process (iClk)
	begin
		if rising_edge(iClk) then
			if (iReset_sync = '1') then
				svFifoCount <= (others => '0');
				sFifoFull <= '0';
				sFifoEmpty <= '1';
				sAlmostFull <= '0';
				sAlmostEmpty <= '1';
				sProgFull <= '0';
				sProgEmpty <= '1';
				
				sFifoOverflow <= '0';
				sFifoUnderflow <= '0';
			else
				-- Fifo count when it is read or written
				if (sEffectiveWrEn = '1') and (sEffectiveRdEn = '0') then
					svFifoCount <= svFifoCount + '1';
				elsif (sEffectiveWrEn = '0') and (sEffectiveRdEn = '1') then
					svFifoCount <= svFifoCount - '1';
				end if;
				
				if svFifoCount = conv_std_logic_vector((2**gADDRESS_WIDTH)-2, gADDRESS_WIDTH) then
					if (iWrEn = '1') and (iRdEn = '0') then
						sFifoFull <= '1';
					else
						sFifoFull <= '0';
					end if;
				elsif svFifoCount = conv_std_logic_vector((2**gADDRESS_WIDTH)-1, gADDRESS_WIDTH) then
					if iRdEn = '1' then
						sFifoFull <= '0';
					else
						sFifoFull <= '1';
					end if;
				else
					sFifoFull <= '0';
				end if;
				
				if svFifoCount = conv_std_logic_vector(1, gADDRESS_WIDTH) then
					if (iWrEn = '0') and (iRdEn = '1') then
						sFifoEmpty <= '1';
					else
						sFifoEmpty <= '0';
					end if;
				elsif svFifoCount = conv_std_logic_vector(0, gADDRESS_WIDTH) then
					if (iWrEn = '1') then
						sFifoEmpty <= '0';
					else
						sFifoEmpty <= '1';
					end if;
				else
					sFifoEmpty <= '0';
				end if;
				
				if svFifoCount = conv_std_logic_vector((2**gADDRESS_WIDTH)-3, gADDRESS_WIDTH) then
					if (iWrEn = '1') and (iRdEn = '0') then
						sAlmostFull <= '1';
					else
						sAlmostFull <= '0';
					end if;
				elsif svFifoCount = conv_std_logic_vector((2**gADDRESS_WIDTH)-2, gADDRESS_WIDTH) then
					if (iWrEn = '0') and (iRdEn = '1') then 
						sAlmostFull <= '0';
					else
						sAlmostFull <= '1';
					end if;
				elsif svFifoCount = conv_std_logic_vector((2**gADDRESS_WIDTH)-1, gADDRESS_WIDTH) then
					sAlmostFull <= '1';
				else
					sAlmostFull <= '0';
				end if;
				
				if svFifoCount = conv_std_logic_vector(2, gADDRESS_WIDTH) then
					if (iWrEn = '0') and (iRdEn = '1') then
						sAlmostEmpty <= '1';
					else
						sAlmostEmpty <= '0';
					end if;
				elsif svFifoCount = conv_std_logic_vector(1, gADDRESS_WIDTH) then
					if (iWrEn = '1') and (iRdEn = '0') then 
						sAlmostEmpty <= '0';
					else
						sAlmostEmpty <= '1';
					end if;
				elsif svFifoCount = conv_std_logic_vector(0, gADDRESS_WIDTH) then
					sAlmostEmpty <= '1';
				else
					sAlmostEmpty <= '0';
				end if;
				
				if svFifoCount = svProgFullThM1 then
					if (iWrEn = '1') and (iRdEn = '0') then 
						sProgFull <= '1';
					else
						sProgFull <= '0';
					end if;
				elsif svFifoCount = ivProgFullTh then
					if (iWrEn = '0') and (iRdEn = '1') then 
						sProgFull <= '0';
					else
						sProgFull <= '1';
					end if;
				elsif svFifoCount > ivProgFullTh then
					sProgFull <= '1';
				else
					sProgFull <= '0';
				end if;
				
				if svFifoCount = svProgEmptyThP1 then
					if (iWrEn = '0') and (iRdEn = '1') then 
						sProgEmpty <= '1';
					else
						sProgEmpty <= '0';
					end if;
				elsif svFifoCount = ivProgEmptyTh then
					if (iWrEn = '1') and (iRdEn = '0') then 
						sProgEmpty <= '0';
					else
						sProgEmpty <= '1';
					end if;
				elsif svFifoCount < ivProgEmptyTh then
					sProgEmpty <= '1';
				else
					sProgEmpty <= '0';
				end if;
				--------------------------------
				-- Generate the error flag
				-------------------------------
				if sFifoFull = '1' and iWrEn = '1'  then  	
					sFifoOverflow <= '1';
				end if;
				
				if sFifoEmpty = '1' and iRdEn = '1'  then
					sFifoUnderflow <= '1';	
				end if;
			end if;
		end if;
	end process;
	
	oFull <= sFifoFull;
	oEmpty <= sFifoEmpty;
	oAlmostFull <= sAlmostFull;
	oAlmostEmpty <= sAlmostEmpty;
	oProgFull <= sProgFull;
	oProgEmpty <= sProgEmpty;
	oOverflow <= sFifoOverflow;
	oUnderflow <= sFifoUnderflow;

	ovDataOut <= svMemDataOut;
	oDataOutValid <= sMemDataOutValid;
				
END behavioral;	



