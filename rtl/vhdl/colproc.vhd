--
-- File colproc.vhd, Color Processor
-- Project: VGA
-- Author : Richard Herveille. Ideas and thoughts: Sherif Taher Eid
-- rev.: 0.1 May     1st, 2001
-- rev.: 0.2 June   23rd, 2001. Removed unused "prev_state" references from statemachine. Removed unused "dWB_Di" signal.
-- rev.: 1.0 July    6th, 2001. Fixed a bug where the core did not repond correctly to a delayed clut_ack signal in 8bpp_pseudo_color mode.
-- rev.: 1.1 August  2nd, 2001. Changed 24bpp section in output-decoder. Smaller/faster synthesis results.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity colproc is
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
end entity colproc;

architecture structural of colproc is
	signal DataBuffer : std_logic_vector(31 downto 0);
	signal colcnt : unsigned(1 downto 0);
	signal RGBbuf_wreq : std_logic;
begin
	-- store word from pixelbuffer / wishbone input
	process(clk)
	begin
		if (clk'event and clk = '1') then
			if (pixel_buffer_rreq = '1') then
				DataBuffer <= pixel_buffer_Di;
			end if;
		end if;
	end process;

	-- extract color information from data buffer
	statemachine: block
		type states is (idle, fill_buf, bw_8bpp, col_8bpp, col_16bpp_a, col_16bpp_b, col_24bpp);
		signal c_state : states;

		signal Ra, Ga, Ba : std_logic_vector(7 downto 0);
	begin
		gen_nxt_state: process(clk, c_state, pixel_buffer_empty, ColorDepth, PseudoColor, RGB_fifo_full, colcnt, clut_ack)
			variable nxt_state : states;
		begin

			-- initial value
			nxt_state := c_state;

			case c_state is
				-- idle state
				when idle =>
					if (pixel_buffer_empty = '0') then
						nxt_state := fill_buf;
					end if;

				when fill_buf =>
					case ColorDepth is
						when "00" => 
							if (PseudoColor = '1') then
								nxt_state := col_8bpp;
							else
								nxt_state := bw_8bpp;
							end if;

						when "01" => 
							nxt_state := col_16bpp_a;

						when others => 
							nxt_state := col_24bpp;

					end case;

				--
				-- 8 bits per pixel
				--
				when bw_8bpp =>
					if ((RGB_fifo_full = '0') and (colcnt = 0)) then
						nxt_state := idle;
					end if;

				when col_8bpp =>
					if ((RGB_fifo_full = '0') and (colcnt = 0)) then
						if (clut_ack = '1') then
							nxt_state := idle;
						end if;
					end if;

				--
				-- 16 bits per pixel
				--
				when col_16bpp_a =>
					if (RGB_fifo_full = '0') then
						nxt_state := col_16bpp_b;
					end if;

				when col_16bpp_b =>
					if (RGB_fifo_full = '0') then
						nxt_state := idle;
					end if;

				--
				-- 24 bits per pixel
				--
				when col_24bpp =>
					if (RGB_fifo_full = '0') then
						if (colcnt = 1) then
							nxt_state := col_24bpp; -- stay in current state
						else
							nxt_state := idle;
						end if;
					end if;
			end case;

			if (clk'event and clk = '1') then
				if (ctrl_Ven = '0') then
					c_state <= idle;
				else
					c_state <= nxt_state;
				end if;
			end if;
		end process gen_nxt_state;

		--
		-- output decoder
		--
		gen_odec: process(clk, c_state, pixel_buffer_empty, colcnt, DataBuffer, RGB_fifo_full, clut_ack, WB_Di, Ba, Ga, Ra)
			variable clut_acc : std_logic;
			variable pixelbuf_rreq : std_logic;
			variable iR, iG, iB, iRa, iGa, iBa : std_logic_vector(7 downto 0);
		begin
			-- initial values
			pixelbuf_rreq := '0';
			RGBbuf_wreq <= '0';
			clut_acc := '0';
				
			iR := (others => '0');
			iG := (others => '0');
			iB := (others => '0');
			iRa := (others => '0');
			iGa := (others => '0');
			iBa := (others => '0');

			case c_state is
				when idle =>
					if (pixel_buffer_empty = '0') then
						pixelbuf_rreq := '1';
					end if;

				--		
				-- 8 bits per pixel
				--
				when bw_8bpp =>
					if (RGB_fifo_full = '0') then
						RGBbuf_wreq <= '1';
					end if;

					case colcnt is
						when "11" =>
							iR := DataBuffer(31 downto 24);
							iG := iR;
							iB := iR;

						when "10" =>
							iR := DataBuffer(23 downto 16);
							iG := iR;
							iB := iR;

						when "01" =>
							iR := DataBuffer(15 downto 8);
							iG := iR;
							iB := iR;

						when others =>
							iR := DataBuffer(7 downto 0);
							iG := iR;
							iB := iR;
					end case;

				when col_8bpp =>
					if ((RGB_fifo_full = '0') and (clut_ack = '1')) then
						RGBbuf_wreq <= '1';
					end if;

					iR := WB_Di(23 downto 16);
					iG := WB_Di(15 downto  8);
					iB := WB_Di( 7 downto  0);

					clut_acc := not RGB_fifo_full;

					if ((colcnt = 0) and (clut_ack = '1')) then
						clut_acc := '0';
					end if;

				--
				-- 16 bits per pixel
				--
				when col_16bpp_a =>
					if (RGB_fifo_full = '0') then
						RGBbuf_wreq <= '1';
					end if;
					iR(7 downto 3) := DataBuffer(31 downto 27);
					iG(7 downto 2) := DataBuffer(26 downto 21);
					iB(7 downto 3) := DataBuffer(20 downto 16);

				when col_16bpp_b =>
					if (RGB_fifo_full = '0') then
						RGBbuf_wreq <= '1';
					end if;
					iR(7 downto 3) := DataBuffer(15 downto 11);
					iG(7 downto 2) := DataBuffer(10 downto  5);
					iB(7 downto 3) := DataBuffer( 4 downto  0);

				--
				-- 24 bits per pixel
				--
				when col_24bpp =>
					if (RGB_fifo_full = '0') then
						RGBbuf_wreq <= '1';
					end if;

					case colcnt is
					when "11" =>
							iR  := DataBuffer(31 downto 24);
							iG  := DataBuffer(23 downto 16);
							iB  := DataBuffer(15 downto  8);
							iRa := DataBuffer( 7 downto  0);

						when "10" =>
							iR  := Ra;
							iG  := DataBuffer(31 downto 24);
							iB  := DataBuffer(23 downto 16);
							iRa := DataBuffer(15 downto  8);
							iGa := DataBuffer( 7 downto  0);

						when "01" =>
							iR  := Ra;
							iG  := Ga;
							iB  := DataBuffer(31 downto 24);
							iRa := DataBuffer(23 downto 16);
							iGa := DataBuffer(15 downto  8);
							iBa := DataBuffer( 7 downto  0);

						when others =>
							iR := Ra;
							iG := Ga;
							iB := Ba;
					end case;

				when others =>
					null;

			end case;

			if (clk'event and clk = '1') then
				R  <= iR;
				G  <= iG;
				B  <= iB;

				if (RGBbuf_wreq = '1') then
					Ra <= iRa;
					Ba <= iBa;
					Ga <= iGa;
				end if;

				if (ctrl_Ven = '0') then
					pixel_buffer_rreq <= '0';
					RGB_fifo_wreq <= '0';
					clut_req <= '0';
				else
					pixel_buffer_rreq <= pixelbuf_rreq;
					RGB_fifo_wreq <= RGBbuf_wreq;
					clut_req <= clut_acc;
				end if;
			end if;
		end process gen_odec;

		-- assign clut offset
		with colcnt select
			clut_offs <= unsigned(DataBuffer(31 downto 24)) when "11",
			             unsigned(DataBuffer(23 downto 16)) when "10",
			             unsigned(DataBuffer(15 downto  8)) when "01",
			             unsigned(DataBuffer( 7 downto  0)) when others;

	end block statemachine;


	-- color counter
	gen_colcnt: process(clk)
	begin
		if (clk'event and clk = '1') then
			if (ctrl_Ven = '0') then
				colcnt <= (others => '1');
			elsif (RGBbuf_wreq = '1') then
				colcnt <= colcnt -1;
			end if;
		end if;
	end process gen_colcnt;

end architecture structural;



