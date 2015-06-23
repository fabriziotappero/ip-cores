--
--  File: mem_reader.vhd
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--

library IEEE;
use IEEE.std_logic_1164.all;

library wb_tk;
use wb_tk.technology.all;

entity mem_reader is
	generic (
		v_mem_width: positive := 16;
		v_addr_width: positive:= 20;
		fifo_size: positive := 256;
		dual_scan_fifo_size: positive := 256
	);
	port (
		clk: in std_logic;
		clk_en: in std_logic;
		pix_clk_en: in std_logic;
		reset: in std_logic := '0';
		
		v_mem_end: in std_logic_vector(v_addr_width-1 downto 0);   -- video memory end address in words
		v_mem_start: in std_logic_vector(v_addr_width-1 downto 0) := (others => '0'); -- video memory start adderss in words
		fifo_treshold: in std_logic_vector(7 downto 0);        -- priority change threshold
		bpp: in std_logic_vector(1 downto 0);                  -- number of bits makes up a pixel valid values: 1,2,4,8
		multi_scan: in std_logic_vector(1 downto 0);           -- number of repeated scans

		-- Can be githces on it!!! Don't clock by it!!!
		high_prior: out std_logic;                      -- signals to the memory arbitrer to give high 
		                                                -- priority to the video engine
		v_mem_rd: out std_logic;                        -- video memory read request
		v_mem_rdy: in std_logic;                        -- video memory data ready
		v_mem_addr: out std_logic_vector (v_addr_width-1 downto 0); -- video memory address
		v_mem_data: in std_logic_vector (v_mem_width-1 downto 0);   -- video memory data

		blank: in std_logic;                            -- video sync generator blank output
		h_tc: in std_logic; 							-- horizontal sync pulse. Must be 1 clock wide!
		video_out: out std_logic_vector (7 downto 0)    -- video output binary signal (unused bits are forced to 0)
	);
end mem_reader;

architecture mem_reader of mem_reader is
	component fifo
		generic (fifo_width : positive;
				 used_width : positive;
				 fifo_depth : positive
		);
		port (d_in : in std_logic_vector(fifo_width-1 downto 0);
			  clk : in std_logic;
			  wr : in std_logic;
			  rd : in std_logic;
			  a_clr : in std_logic := '0';
			  s_clr : in std_logic := '0';
			  d_out : out std_logic_vector(fifo_width-1 downto 0);
			  used : out std_logic_vector(used_width-1 downto 0);
			  full : out std_logic;
			  empty : out std_logic
		);
	end component;

	signal fifo_rd: std_logic;
	signal fifo_out: std_logic_vector(v_mem_width-1 downto 0);

	signal video_fifo_out: std_logic_vector(v_mem_width-1 downto 0);
	signal video_fifo_usedw: std_logic_vector(7 downto 0);
	signal video_fifo_rd: std_logic;
	signal video_fifo_full: std_logic;
	signal video_fifo_empty: std_logic;
	
	signal ds_fifo_out: std_logic_vector(v_mem_width-1 downto 0);
--	signal ds_fifo_usedw: std_logic_vector(7 downto 0);
	signal ds_fifo_rd: std_logic;
	signal ds_fifo_clr: std_logic;
--	signal ds_fifo_full: std_logic;
--	signal ds_fifo_empty: std_logic;
	
	signal i_video_out: std_logic_vector(7 downto 0);
	signal ds_mode: std_logic;

	subtype pixel_cntr_var is integer range 0 to 7;
	
--	signal i_v_mem_rd: std_logic := '0';
	
begin
	-- memory decoupler FIFO
	pixel_fifo: fifo
		generic map (
			fifo_width => v_mem_width,
			used_width => 8,
			fifo_depth => fifo_size
		)
		port map (
			d_in => v_mem_data,
			clk => clk,
			wr => v_mem_rdy,
			rd => video_fifo_rd,
--			a_clr => '0',
			a_clr => reset,
			s_clr => reset,
			full => video_fifo_full,
			d_out => video_fifo_out,
			used => video_fifo_usedw,
		  empty => video_fifo_empty
		);
	
	-- dual-scan FIFO
	ds_pixel_fifo: fifo
		generic map (
			fifo_width => v_mem_width,
			used_width => 8,
			fifo_depth => dual_scan_fifo_size
		)
		port map (
			d_in => fifo_out,
			clk => clk,
			wr => fifo_rd,
			rd => ds_fifo_rd,
--			a_clr => '0',
			a_clr => reset,
			s_clr =>  ds_fifo_clr,
			d_out => ds_fifo_out
		);
	
	-- Multiplexer for DS data handling
	fifo_mux: for i in v_mem_width-1 downto 0 generate
	begin
		fifo_out(i) <= (video_fifo_out(i) and not ds_mode) or (ds_fifo_out(i) and ds_mode);
--		fifo_out(i) <= (video_fifo_out(i) and not ds_mode);
	end generate;
	--fifo_out <= (video_fifo_out and not ds_mode);
	ds_fifo_rd    <= ('0'     and not ds_mode) or (fifo_rd and ds_mode);
	video_fifo_rd <= (fifo_rd and not ds_mode) or ('0'     and ds_mode);
	
	-- Counter handles DS
	ds_counter : process is
		variable cnt: std_logic_vector(1 downto 0);
	begin
		wait until clk'EVENT and clk = '1';
		if (reset = '1') then
			cnt := (others => '0');
			ds_fifo_clr <= '1';
			ds_mode <= '0';
		else
			if (clk_en = '1') then
				if (h_tc = '1') then
					if (is_zero(cnt)) then
						ds_mode <= '0';
						ds_fifo_clr <= '1';
					else
						ds_mode <= '1';
						ds_fifo_clr <= '0';
					end if;
					if (cnt = multi_scan) then
						cnt := (others => '0');
					else
						cnt := add_one(cnt);
					end if;
				else
					ds_fifo_clr <= '0';
				end if;
			else
				ds_fifo_clr <= '1';
				ds_mode <= '0';
			end if;
		end if;
	end process;
	
	-- Pixel data reader state machine
	pixel_cntr : process is
		variable pixel_cnt: std_logic_vector(v_addr_width-1 downto 0);
	begin
		wait until clk'EVENT and clk='1';
		if (reset = '1') then
			pixel_cnt := v_mem_start;
		else
			-- A little cheet. It won't work with constant v_mem_rdy.
			if (v_mem_rdy = '1') then
				-- data is already written to the FIFO, all we need to do is to update the counter,
				-- and remove the request
				if (pixel_cnt = v_mem_end) then
					pixel_cnt := v_mem_start;
				else
					pixel_cnt := add_one(pixel_cnt);
				end if;
			end if;
		end if;
		v_mem_addr <= pixel_cnt;
	end process;
	v_mem_rd <= (not video_fifo_full) and (not reset);

	-- Pixel data output state machine.
	pixel_output: process is
		subtype pixel_cntr_var is integer range 0 to v_mem_width-1;

		variable pixel_cntr : pixel_cntr_var;
		variable shift_reg : std_logic_vector (v_mem_width-1 downto 0);
  	type rst_states is (in_reset,read,normal);
		variable rst_state : rst_states := in_reset;
	begin
		wait until clk'EVENT and clk='1';
		if (reset = '1') then
			fifo_rd <= '0';
			i_video_out <= (others => '0');
			shift_reg := (others => '0');
			pixel_cntr := 0;
			rst_state := in_reset;
		else 
		  if (not (rst_state = normal)) then
		    -- perform one read after reset otherwise the picture will be shifted rigth one pixel
		    case (rst_state) is
		      when in_reset =>
    		    if (video_fifo_empty = '0') then
		          fifo_rd <= '1';
		          rst_state := read;
		        else
		          fifo_rd <= '0';
		        end if;
		      when read =>
						pixel_cntr := 0;
						shift_reg := fifo_out;
		        fifo_rd <= '0';
		        rst_state := normal;
		      when others =>
		    end case;
		  else
  			if (pix_clk_en = '0') then
  				fifo_rd <= '0'; -- clear any pending read requests
  			else
  				if (blank = '1') then
  					fifo_rd <= '0'; -- clear any pending read requests
   					i_video_out <= (others => '0'); -- disable output
-- 					i_video_out <= (others => 'U'); -- disable output
  				else
  					case (bpp) is
  						when "00" =>
  							-- shift next data to the output and optionally read the next data from the fifo
  							i_video_out(0) <= shift_reg(v_mem_width-1);
  							i_video_out(7 downto 1) <= (others => '0');
  							if (pixel_cntr = v_mem_width-1) then
  								-- Read next data
  								pixel_cntr := 0;
  								shift_reg := fifo_out;
  								fifo_rd <= '0';
  							elsif (pixel_cntr = v_mem_width-2) then
  								-- Request next data from FIFO
  								pixel_cntr := pixel_cntr + 1;
  								fifo_rd <= '1';
  								shift_reg := sl(shift_reg,1);
  							else
  								-- Simple increment
  								pixel_cntr := pixel_cntr + 1;
  								fifo_rd <= '0';
  								shift_reg := sl(shift_reg,1);
  							end if;
  						when "01" =>
  							-- shift next data to the output and optionally read the next data from the fifo
  							i_video_out(1 downto 0) <= shift_reg(v_mem_width-1 downto v_mem_width-2);
  							i_video_out(7 downto 2) <= (others => '0');
  							if (pixel_cntr = v_mem_width/2-1) then
  								-- Read next data
  								pixel_cntr := 0;
  								shift_reg := fifo_out;
  								fifo_rd <= '0';
  							elsif (pixel_cntr = v_mem_width/2-2) then
  								-- Request next data from FIFO
  								pixel_cntr := pixel_cntr + 1;
  								fifo_rd <= '1';
  								shift_reg := sl(shift_reg,2);
  							else
  								-- Simple increment
  								pixel_cntr := pixel_cntr + 1;
  								fifo_rd <= '0';
  								shift_reg := sl(shift_reg,2);
  							end if;
  						when "10" =>
  							-- shift next data to the output and optionally read the next data from the fifo
  							i_video_out(3 downto 0) <= shift_reg(v_mem_width-1 downto v_mem_width-4);
  							i_video_out(7 downto 4) <= (others => '0');
  							if (pixel_cntr = v_mem_width/4-1) then
  								-- Read next data
  								pixel_cntr := 0;
  								shift_reg := fifo_out;
  								fifo_rd <= '0';
  							elsif (pixel_cntr = v_mem_width/4-2) then
  								-- Request next data from FIFO
  								pixel_cntr := pixel_cntr + 1;
  								fifo_rd <= '1';
  								shift_reg := sl(shift_reg,4);
  							else
  								-- Simple increment
  								pixel_cntr := pixel_cntr + 1;
  								fifo_rd <= '0';
  								shift_reg := sl(shift_reg,4);
  							end if;
  						when "11" =>
  							if (v_mem_width = 8) then
  								-- 8 bit memory with 8 bit output: every clock reads a byte from the fifo.
  								fifo_rd <= '1';
  								i_video_out(7 downto 0) <= fifo_out;
  							else
  								-- shift next data to the output and optionally read the next data from the fifo
  								i_video_out(7 downto 0) <= shift_reg(v_mem_width-1 downto v_mem_width-8);
  								if (pixel_cntr = v_mem_width/8-1) then
  									-- Read next data
  									pixel_cntr := 0;
  									shift_reg := fifo_out;
  									fifo_rd <= '0';
  								elsif (pixel_cntr = v_mem_width/8-2) then
  									-- Request next data from FIFO
  									pixel_cntr := pixel_cntr + 1;
  									fifo_rd <= '1';
  									shift_reg := sl(shift_reg,8);
  								else
  									-- Simple increment
  									pixel_cntr := pixel_cntr + 1;
  									fifo_rd <= '0';
  									shift_reg := sl(shift_reg,8);
  								end if;
  							end if;
  						when others => -- Unsupported setting. Do nothing
  							i_video_out(7 downto 0) <= (others => '0');
  							fifo_rd <= '0';
  							pixel_cntr := 0;
  					end case;
  				end if;
  			end if;
  		end if;
  	end if;
	end process;

	video_out <= i_video_out;
		
	-- Simple logic generates the high_prior output
	priority: process is
	begin
		wait on video_fifo_usedw,fifo_treshold,video_fifo_full;
		if (video_fifo_usedw < fifo_treshold and video_fifo_full = '0') then
			high_prior <= '1';
		else
			high_prior <= '0';
		end if;
	end process;
end mem_reader;
