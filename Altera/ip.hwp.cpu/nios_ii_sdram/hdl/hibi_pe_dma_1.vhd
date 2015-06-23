-- hibi_pe_dma_1.vhd

-- This file was auto-generated as part of a SOPC Builder generate operation.
-- If you edit it your changes will probably be lost.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity hibi_pe_dma_1 is
	port (
		avalon_cfg_addr_in         : in  std_logic_vector(6 downto 0)  := (others => '0'); --   avalon_slave_0.address
		avalon_cfg_we_in           : in  std_logic                     := '0';             --                 .write
		avalon_cfg_re_in           : in  std_logic                     := '0';             --                 .read
		avalon_cfg_cs_in           : in  std_logic                     := '0';             --                 .chipselect
		avalon_cfg_waitrequest_out : out std_logic;                                        --                 .waitrequest
		avalon_cfg_writedata_in    : in  std_logic_vector(31 downto 0) := (others => '0'); --                 .writedata
		avalon_cfg_readdata_out    : out std_logic_vector(31 downto 0);                    --                 .readdata
		hibi_data_in               : in  std_logic_vector(31 downto 0) := (others => '0'); --      conduit_end.export
		hibi_av_in                 : in  std_logic                     := '0';             --                 .export
		hibi_empty_in              : in  std_logic                     := '0';             --                 .export
		hibi_comm_in               : in  std_logic_vector(4 downto 0)  := (others => '0'); --                 .export
		hibi_re_out                : out std_logic;                                        --                 .export
		hibi_data_out              : out std_logic_vector(31 downto 0);                    --                 .export
		hibi_av_out                : out std_logic;                                        --                 .export
		hibi_full_in               : in  std_logic                     := '0';             --                 .export
		hibi_comm_out              : out std_logic_vector(4 downto 0);                     --                 .export
		hibi_we_out                : out std_logic;                                        --                 .export
		clk                        : in  std_logic                     := '0';             --       clock_sink.clk
		rst_n                      : in  std_logic                     := '0';             -- clock_sink_reset.reset_n
		rx_irq_out                 : out std_logic;                                        -- interrupt_sender.irq
		avalon_addr_out_rx         : out std_logic_vector(31 downto 0);                    --    avalon_master.address
		avalon_we_out_rx           : out std_logic;                                        --                 .write
		avalon_be_out_rx           : out std_logic_vector(3 downto 0);                     --                 .byteenable
		avalon_writedata_out_rx    : out std_logic_vector(31 downto 0);                    --                 .writedata
		avalon_waitrequest_in_rx   : in  std_logic                     := '0';             --                 .waitrequest
		avalon_readdatavalid_in_tx : in  std_logic                     := '0';             --  avalon_master_1.readdatavalid
		avalon_waitrequest_in_tx   : in  std_logic                     := '0';             --                 .waitrequest
		avalon_readdata_in_tx      : in  std_logic_vector(31 downto 0) := (others => '0'); --                 .readdata
		avalon_re_out_tx           : out std_logic;                                        --                 .read
		avalon_addr_out_tx         : out std_logic_vector(31 downto 0)                     --                 .address
	);
end entity hibi_pe_dma_1;

architecture rtl of hibi_pe_dma_1 is
	component hibi_pe_dma is
		generic (
			data_width_g       : integer := 32;
			addr_width_g       : integer := 32;
			words_width_g      : integer := 16;
			n_stream_chans_g   : integer := 4;
			n_packet_chans_g   : integer := 4;
			n_chans_bits_g     : integer := 3;
			hibi_addr_cmp_lo_g : integer := 8;
			hibi_addr_cmp_hi_g : integer := 31
		);
		port (
			avalon_cfg_addr_in         : in  std_logic_vector(6 downto 0)  := (others => 'X'); -- address
			avalon_cfg_we_in           : in  std_logic                     := 'X';             -- write
			avalon_cfg_re_in           : in  std_logic                     := 'X';             -- read
			avalon_cfg_cs_in           : in  std_logic                     := 'X';             -- chipselect
			avalon_cfg_waitrequest_out : out std_logic;                                        -- waitrequest
			avalon_cfg_writedata_in    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- writedata
			avalon_cfg_readdata_out    : out std_logic_vector(31 downto 0);                    -- readdata
			hibi_data_in               : in  std_logic_vector(31 downto 0) := (others => 'X'); -- export
			hibi_av_in                 : in  std_logic                     := 'X';             -- export
			hibi_empty_in              : in  std_logic                     := 'X';             -- export
			hibi_comm_in               : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- export
			hibi_re_out                : out std_logic;                                        -- export
			hibi_data_out              : out std_logic_vector(31 downto 0);                    -- export
			hibi_av_out                : out std_logic;                                        -- export
			hibi_full_in               : in  std_logic                     := 'X';             -- export
			hibi_comm_out              : out std_logic_vector(4 downto 0);                     -- export
			hibi_we_out                : out std_logic;                                        -- export
			clk                        : in  std_logic                     := 'X';             -- clk
			rst_n                      : in  std_logic                     := 'X';             -- reset_n
			rx_irq_out                 : out std_logic;                                        -- irq
			avalon_addr_out_rx         : out std_logic_vector(31 downto 0);                    -- address
			avalon_we_out_rx           : out std_logic;                                        -- write
			avalon_be_out_rx           : out std_logic_vector(3 downto 0);                     -- byteenable
			avalon_writedata_out_rx    : out std_logic_vector(31 downto 0);                    -- writedata
			avalon_waitrequest_in_rx   : in  std_logic                     := 'X';             -- waitrequest
			avalon_readdatavalid_in_tx : in  std_logic                     := 'X';             -- readdatavalid
			avalon_waitrequest_in_tx   : in  std_logic                     := 'X';             -- waitrequest
			avalon_readdata_in_tx      : in  std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
			avalon_re_out_tx           : out std_logic;                                        -- read
			avalon_addr_out_tx         : out std_logic_vector(31 downto 0)                     -- address
		);
	end component hibi_pe_dma;

begin

	hibi_pe_dma_1 : component hibi_pe_dma
		generic map (
			data_width_g       => 32,
			addr_width_g       => 32,
			words_width_g      => 16,
			n_stream_chans_g   => 0,
			n_packet_chans_g   => 8,
			n_chans_bits_g     => 3,
			hibi_addr_cmp_lo_g => 0,
			hibi_addr_cmp_hi_g => 31
		)
		port map (
			avalon_cfg_addr_in         => avalon_cfg_addr_in,         --   avalon_slave_0.address
			avalon_cfg_we_in           => avalon_cfg_we_in,           --                 .write
			avalon_cfg_re_in           => avalon_cfg_re_in,           --                 .read
			avalon_cfg_cs_in           => avalon_cfg_cs_in,           --                 .chipselect
			avalon_cfg_waitrequest_out => avalon_cfg_waitrequest_out, --                 .waitrequest
			avalon_cfg_writedata_in    => avalon_cfg_writedata_in,    --                 .writedata
			avalon_cfg_readdata_out    => avalon_cfg_readdata_out,    --                 .readdata
			hibi_data_in               => hibi_data_in,               --      conduit_end.export
			hibi_av_in                 => hibi_av_in,                 --                 .export
			hibi_empty_in              => hibi_empty_in,              --                 .export
			hibi_comm_in               => hibi_comm_in,               --                 .export
			hibi_re_out                => hibi_re_out,                --                 .export
			hibi_data_out              => hibi_data_out,              --                 .export
			hibi_av_out                => hibi_av_out,                --                 .export
			hibi_full_in               => hibi_full_in,               --                 .export
			hibi_comm_out              => hibi_comm_out,              --                 .export
			hibi_we_out                => hibi_we_out,                --                 .export
			clk                        => clk,                        --       clock_sink.clk
			rst_n                      => rst_n,                      -- clock_sink_reset.reset_n
			rx_irq_out                 => rx_irq_out,                 -- interrupt_sender.irq
			avalon_addr_out_rx         => avalon_addr_out_rx,         --    avalon_master.address
			avalon_we_out_rx           => avalon_we_out_rx,           --                 .write
			avalon_be_out_rx           => avalon_be_out_rx,           --                 .byteenable
			avalon_writedata_out_rx    => avalon_writedata_out_rx,    --                 .writedata
			avalon_waitrequest_in_rx   => avalon_waitrequest_in_rx,   --                 .waitrequest
			avalon_readdatavalid_in_tx => avalon_readdatavalid_in_tx, --  avalon_master_1.readdatavalid
			avalon_waitrequest_in_tx   => avalon_waitrequest_in_tx,   --                 .waitrequest
			avalon_readdata_in_tx      => avalon_readdata_in_tx,      --                 .readdata
			avalon_re_out_tx           => avalon_re_out_tx,           --                 .read
			avalon_addr_out_tx         => avalon_addr_out_tx          --                 .address
		);

end architecture rtl; -- of hibi_pe_dma_1
