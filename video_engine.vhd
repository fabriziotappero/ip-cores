--
--  File: video_engine.vhd
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--

library IEEE;
use IEEE.std_logic_1164.all;

library wb_tk;
use wb_tk.technology.all;

entity video_engine is
	generic (
		v_mem_width: positive := 16;
		v_addr_width: positive:= 20;
		fifo_size: positive := 256;
		dual_scan_fifo_size: positive := 256
	);
	port (
		clk: in std_logic;
		clk_en: in std_logic := '1';
		reset: in std_logic := '0';
		
		v_mem_end: in std_logic_vector(v_addr_width-1 downto 0);   -- video memory end address in words
		v_mem_start: in std_logic_vector(v_addr_width-1 downto 0) := (others => '0'); -- video memory start adderss in words
		fifo_treshold: in std_logic_vector(7 downto 0);        -- priority change threshold
		bpp: in std_logic_vector(1 downto 0);                  -- number of bits makes up a pixel valid values: 1,2,4,8
		multi_scan: in std_logic_vector(1 downto 0);           -- number of repeated scans

		hbs: in std_logic_vector(7 downto 0);
		hss: in std_logic_vector(7 downto 0);
		hse: in std_logic_vector(7 downto 0);
		htotal: in std_logic_vector(7 downto 0);
		vbs: in std_logic_vector(7 downto 0);
		vss: in std_logic_vector(7 downto 0);
		vse: in std_logic_vector(7 downto 0);
		vtotal: in std_logic_vector(7 downto 0);
		
		pps: in std_logic_vector(7 downto 0);

		high_prior: out std_logic;                      -- signals to the memory arbitrer to give high 
		                                                -- priority to the video engine
		v_mem_rd: out std_logic;                        -- video memory read request
		v_mem_rdy: in std_logic;                        -- video memory data ready
		v_mem_addr: out std_logic_vector (v_addr_width-1 downto 0); -- video memory address
		v_mem_data: in std_logic_vector (v_mem_width-1 downto 0);   -- video memory data

		h_sync: out std_logic;
		h_blank: out std_logic;
		v_sync: out std_logic;
		v_blank: out std_logic;
		h_tc: out std_logic;
		v_tc: out std_logic;
		blank: out std_logic;
		video_out: out std_logic_vector (7 downto 0)    -- video output binary signal (unused bits are forced to 0)
	);
end video_engine;

architecture video_engine of video_engine is
	component hv_sync
		port (
			clk: in std_logic;
			pix_clk_en: in std_logic := '1';
			reset: in std_logic := '0';
	
			hbs: in std_logic_vector(7 downto 0);
			hss: in std_logic_vector(7 downto 0);
			hse: in std_logic_vector(7 downto 0);
			htotal: in std_logic_vector(7 downto 0);
			vbs: in std_logic_vector(7 downto 0);
			vss: in std_logic_vector(7 downto 0);
			vse: in std_logic_vector(7 downto 0);
			vtotal: in std_logic_vector(7 downto 0);
	
			h_sync: out std_logic;
			h_blank: out std_logic;
			v_sync: out std_logic;
			v_blank: out std_logic;
			h_tc: out std_logic;
			v_tc: out std_logic;
			blank: out std_logic
		);
	end component;

	component mem_reader
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
	end component;

	signal pix_clk_en: std_logic;

	signal i_h_sync: std_logic;
	signal i_h_blank: std_logic;
	signal i_v_sync: std_logic;
	signal i_v_blank: std_logic;
	signal i_h_tc: std_logic;
	signal i_v_tc: std_logic;
	signal i_blank: std_logic;
	
begin
	pps_gen: process is
		variable cnt: std_logic_vector(3 downto 0);
	begin
		wait until clk'EVENT and clk = '1';
		if (reset = '1') then
			cnt := (others => '0');
			pix_clk_en <= '0';
		else
			if (clk_en = '0') then
				pix_clk_en <= '0';
			else
				if (cnt = pps(3 downto 0)) then
					cnt := (others => '0');
					pix_clk_en <= '1';
				else
					cnt := add_one(cnt);
					pix_clk_en <= '0';
				end if;
			end if;
		end if;
	end process;
	
	mem_engine : mem_reader
		generic map (
			v_mem_width => v_mem_width,
			v_addr_width => v_addr_width,
			fifo_size => fifo_size,
			dual_scan_fifo_size => dual_scan_fifo_size
		)
		port map (
			clk => clk,
			clk_en => clk_en,
			pix_clk_en => pix_clk_en,
			reset => reset,
    		v_mem_end => v_mem_end,
		    v_mem_start => v_mem_start,
			fifo_treshold => fifo_treshold,
			bpp => bpp,
			multi_scan => multi_scan,
			high_prior => high_prior,
			v_mem_rd => v_mem_rd,
			v_mem_rdy => v_mem_rdy,
			v_mem_addr => v_mem_addr,
			v_mem_data => v_mem_data,
			blank => i_blank,
			h_tc => i_h_tc,
			video_out => video_out
		);

	sync_engine : hv_sync
		port map (
			clk => clk,
			pix_clk_en => pix_clk_en,
			reset => reset,
	
			hbs => hbs,
			hss => hss,
			hse => hse,
			htotal => htotal,
			vbs => vbs,
			vss => vss,
			vse => vse,
			vtotal => vtotal,
	
			h_sync => i_h_sync,
			h_blank => i_h_blank,
			v_sync => i_v_sync,
			v_blank => i_v_blank,
			h_tc => i_h_tc,
			v_tc => i_v_tc,
			blank => i_blank
		);

  -- Delay all sync signals with one pixel. That's becouse of the syncron output of the mem_reader
  sync_delay: process is
  begin
    wait until (clk'EVENT and clk='1');
    if (reset = '1') then
  		h_sync <= '0';
  		h_blank <= '1';
  		v_sync <= '0';
  		v_blank <= '1';
    	blank <= '1';
    elsif (pix_clk_en = '1') then
    		h_sync <= i_h_sync;
    		h_blank <= i_h_blank;
    		v_sync <= i_v_sync;
    		v_blank <= i_v_blank;
      	blank <= i_blank;
      end if;
  end process;
  
	h_tc <= i_h_tc;
	v_tc <= i_v_tc;

end video_engine;

