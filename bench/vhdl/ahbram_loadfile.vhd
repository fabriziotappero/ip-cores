--
-- AHB slave simulating random access memory.
-- Initial contents are loaded from an SREC file at the start of the simulation.
--


library ieee;
use ieee.std_logic_1164.all, ieee.numeric_std.all;
use std.textio.all;
library grlib;
use grlib.amba.all;
use grlib.devices.all;
use grlib.stdlib.all;


entity ahbram_loadfile is

    generic (
        hindex:     integer;
        haddr:      integer;
        hmask:      integer := 16#fff#;
        abits:      integer range 10 to 24;
        fname:      string );

    port (
        rstn:       in  std_logic;
        clk:        in  std_logic;
        ahbi:       in  ahb_slv_in_type;
        ahbo:       out ahb_slv_out_type );

end entity ahbram_loadfile;

architecture ahbram_arch of ahbram_loadfile is

    type mem_type is array(natural range <>) of std_logic_vector(31 downto 0);
    signal mem: mem_type(0 to (2**(abits-2)-1));

    signal s_load:  std_ulogic := '1';
    signal s_rdata: std_logic_vector(31 downto 0) := (others => '0');
    signal s_wdata: std_logic_vector(31 downto 0) := (others => '0');
    signal s_ready: std_ulogic := '0';
    signal s_write: std_ulogic := '0';
    signal s_waddr: std_logic_vector(31 downto 0) := (others => '0');
    signal s_wsize: std_logic_vector(2 downto 0)  := "000";

    constant hconfig : ahb_config_type := (
        0 => ahb_device_reg(VENDOR_GAISLER, GAISLER_AHBRAM, 0, 0, 0),
        4 => ahb_membar(haddr, '1', '1', hmask),
        others => zero32);

    function fromhex(s: string) return unsigned is
        variable v: unsigned(31 downto 0);
        variable t: unsigned(3 downto 0);
    begin
        v := to_unsigned(0, 32);
        for i in s'range loop
            case s(i) is
                when '0' => t := "0000";
                when '1' => t := "0001";
                when '2' => t := "0010";
                when '3' => t := "0011";
                when '4' => t := "0100";
                when '5' => t := "0101";
                when '6' => t := "0110";
                when '7' => t := "0111";
                when '8' => t := "1000";
                when '9' => t := "1001";
                when 'a' => t := "1010";
                when 'A' => t := "1010";
                when 'b' => t := "1011";
                when 'B' => t := "1011";
                when 'c' => t := "1100";
                when 'C' => t := "1100";
                when 'd' => t := "1101";
                when 'D' => t := "1101";
                when 'e' => t := "1110";
                when 'E' => t := "1110";
                when 'f' => t := "1111";
                when 'F' => t := "1111";
                when others => assert false report "invalid syntax in SREC file";
            end case;
            v := v(27 downto 0) & t;
        end loop;
        return v;
    end function;

begin

    ahbo.hready     <= s_ready;
    ahbo.hresp      <= HRESP_OKAY;
    ahbo.hrdata     <= ahbdrivedata(s_rdata);
    ahbo.hsplit     <= (others => '0');
    ahbo.hirq       <= (others => '0');
    ahbo.hconfig    <= hconfig;
    ahbo.hindex     <= hindex;

    s_wdata         <= ahbreadword(ahbi.hwdata, s_waddr(4 downto 2));

    process (clk) is

        procedure loadfile is
            file fd: text open read_mode is fname;
            variable lin: line;
            variable c0, c1, c2, c3, c4, c5, c6, c7: character;
            variable n, t: integer;
            variable adr: unsigned(31 downto 0);
            variable dat: unsigned(31 downto 0);
        begin
            for i in mem'range loop
                mem(i) <= zero32;
            end loop;
            while not endfile(fd) loop
                readline(fd, lin);
                read(lin, c0);
                if c0 = 'S' then
                    read(lin, c0);
                    if c0 = '1' or c0 = '2' or c0 = '3' then
                        t := to_integer(fromhex(c0 & ""));
                        read(lin, c0);
                        read(lin, c1);
                        n := to_integer(fromhex((c0, c1))) - t - 2;
                        assert n >= 0 and (n rem 4) = 0 report "invalid record length in SREC file";
                        read(lin, c0);
                        read(lin, c1);
                        read(lin, c2);
                        read(lin, c3);
                        if t = 2 then
                            read(lin, c4);
                            read(lin, c5);
                            adr := fromhex((c0, c1, c2, c3, c4, c5));
                        elsif t = 3 then
                            read(lin, c4);
                            read(lin, c5);
                            read(lin, c6);
                            read(lin, c7);
                            adr := fromhex((c0, c1, c2, c3, c4, c5, c6, c7));
                        else
                            adr := fromhex((c0, c1, c2, c3));
                        end if;
                        assert adr(1 downto 0) = "00" report "invalid address in SREC file";
                        for i in 0 to (n-4) / 4 loop
                            read(lin, c0);
                            read(lin, c1);
                            read(lin, c2);
                            read(lin, c3);
                            read(lin, c4);
                            read(lin, c5);
                            read(lin, c6);
                            read(lin, c7);
                            dat := fromhex((c0, c1, c2, c3, c4, c5, c6, c7));
                            mem(to_integer(adr(abits-1 downto 2)) + i) <= std_logic_vector(dat);
                        end loop;
                    end if;
                end if;
            end loop;
            report "Loaded AHBRAM contents";
        end procedure;

        variable wa: integer;
    begin
        if s_load = '1' then

            -- Load RAM contents at start of simulation.
            s_load  <= '0';
            loadfile;

        elsif rising_edge(clk) then

            -- Clock tick.

            s_ready <= '1';
            s_rdata <= mem(to_integer(unsigned(ahbi.haddr(abits-1 downto 2))));

            if ahbi.hready = '1' then
                s_write <= ahbi.hsel(hindex) and ahbi.htrans(1) and ahbi.hwrite;
                s_waddr <= ahbi.haddr;
                s_wsize <= ahbi.hsize;
                s_ready <= not (s_ready and ahbi.hsel(hindex) and ahbi.htrans(1) and ahbi.hwrite);
            end if;

            wa := to_integer(unsigned(s_waddr(abits-1 downto 2)));
            if s_write = '1' and s_ready = '1' then
                case s_wsize is
                    when HSIZE_BYTE =>
                        case s_waddr(1 downto 0) is
                            when "00" =>
                                mem(wa)(31 downto 24) <= s_wdata(31 downto 24);
                            when "01" =>
                                mem(wa)(23 downto 16) <= s_wdata(23 downto 16);
                            when "10" =>
                                mem(wa)(15 downto 8)  <= s_wdata(15 downto 8);
                            when others =>
                                mem(wa)(7 downto 0)   <= s_wdata(7 downto 0);
                        end case;
                    when HSIZE_HWORD =>
                        if s_waddr(1) = '1' then
                            mem(wa)(15 downto 0)  <= s_wdata(15 downto 0);
                        else
                            mem(wa)(31 downto 16) <= s_wdata(31 downto 16);
                        end if;
                    when others =>
                        mem(wa) <= s_wdata;
                end case;
            end if;

            if rstn = '0' then
                s_ready <= '0';
                s_rdata <= (others => '0');
                s_write <= '0';
            end if;
                
        end if;
    end process;

-- pragma translate_off
    bootmsg : report_version
        generic map ( "ahbram_loadfile: 32-bit AHB RAM module, hindex=" & tost(hindex) & ", abits=" & tost(abits) & ", fname=" & fname);
-- pragma translate_on

end architecture ahbram_arch;
