--
-- File wb_master.vhd, WISHBONE MASTER interface (video-memory/clut memory)
-- Project: VGA
-- Author : Richard Herveille
-- rev.: 1.0 May 1st, 2001
-- rev.: 1.1 June  3rd, 2001. Changed address related sections.
-- rev.: 1.2 June 23nd, 2001. Removed unused "sel_vba", "vmem_offs" and "bl" signals.
-- rev.: 1.3 July  6th, 2001. Major bug fixes; core did not respond correctly to delayed ACK_I generation.
-- rev.: 1.4 July 15th, 2001. Added CLUT bank switching.
--                            Removed multiplier, replaced it by counters
--                            Fixed timing bug.
-- rev.: 1.5 July 17th, 2001. Fixed a weird condition where to core got stuck during a video memory access, caused by
--                            the image_done timers.
-- rev.: 1.6 July 31th, 2001. Fixed a bug where the video/clut banks would switch with a 1 frame delay.
--                            Fixed a bug where the data in the RGB-buffer could be overwritten.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library count;
use count.count.all;

entity wb_master is
	port(
		-- WISHBONE signals
		CLK_I : in std_logic;                        -- master clock input
		RST_I : in std_logic;                        -- synchronous active high reset
		nRESET : in std_logic;                       -- asynchronous active low reset
		CYC_O : out std_logic;                       -- cycle output
		STB_O : out std_logic;                       -- strobe output
		CAB_O : out std_logic;                       -- Consecutive Address Burst output
		WE_O  : out std_logic;                       -- write enable output
		ADR_O : out unsigned(31 downto 2);           -- address output
		SEL_O : out std_logic_vector(3 downto 0);    -- Byte Select outputs (only 32bit accesses are supported)
		ACK_I : in std_logic;                        -- WISHBONE cycle acknowledge signal
		ERR_I : in std_logic;                        -- oops, bus-error
		DAT_I : in std_logic_vector(31 downto 0);    -- WISHBONE data in

		SINT : out std_logic;                        -- Non recoverable error, interrupt host

		-- control register settings
		ctrl_Ven : in std_logic;                     -- video enable bit
		ctrl_cd : in std_logic_vector(1 downto 0);   -- color depth
		ctrl_pc : in std_logic;                      -- 8bpp pseudo color/bw
		ctrl_vbl : in std_logic_vector(1 downto 0);  -- burst length
		ctrl_vbsw : in std_logic;                    -- enable video bank switching
		ctrl_cbsw : in std_logic;                    -- enable clut bank switching

		-- video memory addresses
		VBAa,                                        -- Video Memory Base Address-A
		VBAb : in unsigned(31 downto 2);             -- Video Memory Base Address-B
		CBA : in unsigned(31 downto 11);             -- CLUT Base Address Register

		Thgate : in unsigned(15 downto 0);           -- horizontal visible area (in pixels)
		Tvgate : in unsigned(15 downto 0);           -- vertical visible area (in horizontal lines)
	
		stat_AVMP : out std_logic;                   -- active video memory page
		stat_ACMP : out std_logic;                   -- active color lookup table
		bs_req : out std_logic;                      -- bank-switch request: memory page switched (when enabled). bs_req is always generated

		-- to/from line fifo
		line_fifo_wreq : out std_logic;
		line_fifo_d : out std_logic_vector(23 downto 0);
		line_fifo_full : in std_logic
	);
end entity wb_master;

architecture structural of wb_master is
	--
	-- component declarations
	--
	-- FIFO
	component FIFO is
	generic(
		DEPTH : natural := 128;
		WIDTH : natural := 32
	);
	port(
		clk : in std_logic;                           -- clock input
		aclr : in std_logic := '1';                   -- active low asynchronous clear
		sclr : in std_logic := '0';                   -- active high synchronous clear

		D : in std_logic_vector(WIDTH -1 downto 0);   -- Data input
		wreq : in std_logic;                          -- write request

		Q : out std_logic_vector(WIDTH -1 downto 0);  -- Data output
		rreq : in std_logic;                          -- read request
		
		empty,                                        -- FIFO is empty
		hfull,                                        -- FIFO is half full
		full : out std_logic                          -- FIFO is full
	);
	end component FIFO;

	-- color processor (convert data from pixel buffer to RGB)
	component colproc is
	port(
		clk : in std_logic;                            -- master clock
		ctrl_Ven : in std_logic;                       -- Video Enable

		pixel_buffer_Di,                               -- Pixel Buffer data input
		WB_Di : in std_logic_vector(31 downto 0);      -- WISHBONE data input

		ColorDepth : in std_logic_vector(1 downto 0);  -- color depth (8bpp, 16bpp, 24bpp)
		PseudoColor : in std_logic;                    -- pseudo color enabled (only for 8bpp color depth)

		pixel_buffer_empty : in std_logic;
		pixel_buffer_rreq : buffer std_logic;          -- pixel buffer read request

		RGB_fifo_full : in std_logic;
		RGB_fifo_wreq : out std_logic;
		R,G,B : out std_logic_vector(7 downto 0);      -- pixel color (to RGB fifo)

		clut_req : out std_logic;                      -- CLUT access request
		clut_offs: out unsigned(7 downto 0);           -- offset into color lookup table
		clut_ack : in std_logic                        -- CLUT data acknowledge
	);
	end component colproc;

	signal nVen : std_logic;                                                 -- NOT ctrl_Ven (video enable)
	signal vmem_acc, clut_acc : std_logic;                                   -- video memory access // clut access
	signal clut_req, clut_ack : std_logic;                                   -- clut access request // clut access acknowledge
	signal clut_offs : unsigned(7 downto 0);                                 -- clut memory offset
	signal nvmem_req, vmem_ack : std_logic;                                  -- NOT video memory access request // video memory access acknowledge
	signal ImDoneStrb, dImDoneStrb : std_logic;                              -- image done (strobe signal)
	signal pixelbuf_rreq, pixelbuf_empty, pixelbuf_empty_flush, pixelbuf_flush, pixelbuf_hfull : std_logic;
	signal pixelbuf_q : std_logic_vector(31 downto 0);
	signal RGBbuf_rreq, RGBbuf_wreq, RGBbuf_empty, RGBbuf_full, fill_RGBfifo, RGB_fifo_full : std_logic;
	signal RGBbuf_d : std_logic_vector(23 downto 0);
begin

	
	--
	-- WISHBONE block
	--
	WB_block: block
		signal burst_cnt : unsigned(2 downto 0);               -- video memory burst access counter
		signal ImDone, dImDone, burst_done : std_logic;        -- Done reading image from video mem // delayed ImDone // completed burst access to video mem
		signal sel_VBA, sel_CBA : std_logic;                   -- select video memory base address // select clut base address
		signal vmemA, clutA : unsigned(31 downto 2);           -- video memory address // clut address
		signal hgate_cnt, vgate_cnt : unsigned(15 downto 0);   -- horizontal / vertical pixel counters
		signal hdone, vdone : std_logic;                       -- horizontal count done / vertical count done
	begin
		--
		-- wishbone access controller, video memory access request has highest priority (try to keep fifo full)
		--
		access_ctrl: process(CLK_I)
		begin
			if(CLK_I'event and CLK_I = '1') then
				if (ctrl_Ven = '0') then
					vmem_acc <= '0';
					clut_acc <= '0';
				else
					clut_acc <= clut_req and ( (nvmem_req and not vmem_acc) or clut_acc);
					vmem_acc <= (not nvmem_req or (vmem_acc and not (burst_done and vmem_ack) )) and not clut_acc;
				end if;
			end if;
		end process access_ctrl;

		vmem_ack <= ACK_I and vmem_acc;
		clut_ack <= ACK_I and clut_acc;

		SINT <= (vmem_acc or clut_acc) and ERR_I; -- Non recoverable error, interrupt host system

		-- select active memory page
		gen_sel_VBA: process(CLK_I)
		begin
			if(CLK_I'event and CLK_I = '1') then
				if (ctrl_Ven = '0') then
					sel_VBA <= '0';
				elsif (ctrl_vbsw = '1') then
					sel_VBA <= sel_VBA xor ImDoneStrb; -- select next video memory bank when finished reading current bank (and bank switch enabled)
				end if;
			end if;
		end process gen_sel_VBA;
		stat_AVMP <= sel_VBA; -- assign output

		gen_sel_CBA: process(CLK_I)
		begin
			if(CLK_I'event and CLK_I = '1') then
				if (ctrl_Ven = '0') then
					sel_CBA <= '0';
				elsif (ctrl_cbsw = '1') then
					sel_CBA <= sel_CBA xor ImDoneStrb; -- select next clut when finished reading current video bank
				end if;
			end if;
		end process gen_sel_CBA;
		stat_ACMP <= sel_CBA; -- assign output

		-- assign bank_switch_request (status register) output
		bs_req <= ImDoneStrb and ctrl_Ven; -- bank switch request

		-- generate burst counter
		gen_burst_cnt: process(CLK_I, ctrl_vbl, burst_cnt)
			variable bl  : unsigned(2 downto 0);
			variable val : unsigned(3 downto 0);
		begin
			case ctrl_vbl is
				when "00"   => bl := "000"; -- burst length 1
				when "01"   => bl := "001"; -- burst length 2
				when "10"   => bl := "011"; -- burst length 4
				when others => bl := "111"; -- burst length 8
			end case;

			val := ('0' & burst_cnt) -1;

			if (CLK_I'event and CLK_I = '1') then
				if ( ((burst_done = '1') and (vmem_ack = '1')) or (vmem_acc = '0')) then
					burst_cnt <= bl;
				elsif (vmem_ack = '1') then
					burst_cnt <= val(2 downto 0);
				end if;
			end if;

			burst_done <= val(3);
		end process gen_burst_cnt;

		--
		-- generate image counters
		--

		-- hgate counter
		hgate_count: process(CLK_I, hgate_cnt)
			variable val : unsigned(16 downto 0);
		begin
			val := ('0' & hgate_cnt) -1;

			if (CLK_I'event and CLK_I = '1') then
				if (ctrl_Ven = '0') then
					hgate_cnt <= Thgate;
				elsif (RGBbuf_wreq = '1') then
					if (hdone = '1') then
						hgate_cnt <= Thgate;
					else
						hgate_cnt <= val(15 downto 0);
					end if;
				end if;
			end if;

			hdone <= val(16);
		end process hgate_count;

		vgate_count: process(CLK_I, vgate_cnt)
			variable val : unsigned(16 downto 0);
		begin
			val := ('0' & vgate_cnt) -1;

			if (CLK_I'event and CLK_I = '1') then
				if (ctrl_Ven = '0') then
					vgate_cnt <= Tvgate;
				elsif ((hdone = '1') and (RGBbuf_wreq = '1')) then
					if (ImDone = '1') then
						vgate_cnt <= Tvgate;
					else
						vgate_cnt <= val(15 downto 0);
					end if;
				end if;
			end if;

			vdone <= val(16);
		end process vgate_count;

		ImDone <= hdone and vdone;
		ImDoneStrb <= ImDone and not dImDone;

		gen_pix_done: process(CLK_I)
		begin
			if (CLK_I'event and CLK_I = '1') then
				if (ctrl_Ven = '0') then
					dImDone <= '0';
				else
					dImDone <= ImDone;
				end if;

				dImDoneStrb <= ImDoneStrb;
			end if;
		end process gen_pix_done;

		--
		-- generate addresses
		--
		addr: process(CLK_I, sel_VBA, VBAa, VBAb)
		begin
			-- select video memory base address
			if (CLK_I'event and CLK_I = '1') then
				-- calculate video memory address
				if ((dImDoneStrb = '1') or (ctrl_Ven = '0')) then
					if (sel_VBA = '0') then
						vmemA <= VBAa;
					else
						vmemA <= VBAb;
					end if;
				elsif (vmem_ack = '1') then
					vmemA <= vmemA + 1;
				end if;
			end if;
		end process addr;

		-- calculate CLUT address
		clutA <= (CBA & sel_CBA & clut_offs);

		-- generate wishbone signals
		gen_wb_sigs: process(CLK_I, nRESET, vmemA, clutA, vmem_acc)
		begin

			-- assign wishbone address
			if (vmem_acc = '1') then
				ADR_O <= vmemA;
			else
				ADR_O <= clutA;
			end if;

			if (nRESET = '0') then
				CYC_O <= '0';
				STB_O <= '0';
				SEL_O <= "1111";
				CAB_O <= '0';
				WE_O  <= '0';
			elsif (CLK_I'event and CLK_I = '1') then
				if (RST_I = '1') then
					CYC_O <= '0';
					STB_O <= '0';
					SEL_O <= "1111";
					CAB_O <= '0';
					WE_O  <= '0';
				else
					CYC_O <= (clut_acc and clut_req and not ACK_I) or (vmem_acc and not (burst_done and vmem_ack and nvmem_req) );
					STB_O <= (clut_acc and clut_req and not ACK_I) or (vmem_acc and not (burst_done and vmem_ack and nvmem_req) ); -- same as CYC_O; only 1 register+logic needed
					SEL_O <= "1111"; -- only 32bit accesses are supported
					CAB_O <= vmem_acc and not (burst_done and vmem_ack and nvmem_req);
					WE_O  <= '0';    -- read only
				end if;
			end if;
		end process gen_wb_sigs;
	end block WB_block;


	nVen <= not ctrl_Ven;
	pixelbuf_flush <= nVen or ImDoneStrb;

	-- pixel buffer (temporary store data read from video memory)
	pixel_buf: FIFO generic map (DEPTH => 16, WIDTH => 32)
		port map(clk => CLK_I, sclr => pixelbuf_flush, D => DAT_I, wreq => vmem_ack, Q => pixelbuf_q, rreq => pixelbuf_rreq, 
						empty => pixelbuf_empty, hfull => pixelbuf_hfull);

	nvmem_req <= not (not pixelbuf_hfull and not ImDoneStrb);

	-- hookup color processor
	gen_fill_RGBfifo: process(CLK_I)
	begin
		if (CLK_I'event and CLK_I = '1') then
			if (ctrl_Ven = '0') then
				fill_RGBfifo <= '0';
			else
				fill_RGBfifo <= (RGBbuf_empty or fill_RGBfifo) and not RGBbuf_full;
			end if;
		end if;
	end process gen_fill_RGBfifo;
	RGB_fifo_full <= not (fill_RGBfifo and not RGBbuf_full); -- not fill_RGBfifo or RGBbuf_full

	pixelbuf_empty_flush <= pixelbuf_empty or pixelbuf_flush;
	color_proc: colproc port map (clk => CLK_I, ctrl_Ven => ctrl_Ven, pixel_buffer_di => pixelbuf_q, WB_Di => DAT_I, ColorDepth => ctrl_CD,
						PseudoColor => ctrl_PC, pixel_buffer_empty => pixelbuf_empty_flush, pixel_buffer_rreq => pixelbuf_rreq, 
						RGB_fifo_full => RGB_fifo_full, RGB_fifo_wreq => RGBbuf_wreq, R => RGBbuf_d(23 downto 16), G => RGBbuf_d(15 downto 8),
						B => RGBbuf_d(7 downto 0), clut_req => clut_req, clut_offs => clut_offs, clut_ack => clut_ack);

	-- hookup RGB buffer (temporary station between WISHBONE-clock-domain and pixel-clock-domain)
	RGB_buf: FIFO generic map (DEPTH => 8, WIDTH => 24)
		port map (clk => CLK_I, sclr => nVen, D => RGBbuf_d, wreq => RGBbuf_wreq, Q => line_fifo_d, rreq => RGBbuf_rreq, 
						empty => RGBbuf_empty, hfull => RGBbuf_full);

	-- hookup line fifo
	gen_lfifo_wreq: process(CLK_I)
	begin
		if (CLK_I'event and CLK_I = '1') then
			if (ctrl_Ven = '0') then
				RGBbuf_rreq <= '0';
			else
				RGBbuf_rreq <= not line_fifo_full and not RGBbuf_empty and not RGBbuf_rreq;
			end if;
		end if;
	end process gen_lfifo_wreq;
	line_fifo_wreq <= RGBbuf_rreq;

end architecture structural;
