#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

main (argc, argv)
  int argc; char **argv;
{
  struct stat sbuf;
  char x[128];
  int i, res, fsize, abits, tmp;
  FILE *fp, *wfp;

  if (argc < 2) exit(1);
  res = stat(argv[1], &sbuf);
  if (res < 0) exit(2);
  fsize = sbuf.st_size;
  fp = fopen(argv[1], "rb");
  wfp = fopen(argv[2], "w+");
  if (fp == NULL) exit(2);
  if (wfp == NULL) exit(2);

  tmp = fsize; abits = 0;
  while (tmp) {tmp >>= 1; abits++;}
  printf("Creating %s : file size: %d bytes, address bits %d\n", argv[2], fsize, abits);
  fprintf(wfp, "\n\
----------------------------------------------------------------------------\n\
--  This file is a part of the GRLIB VHDL IP LIBRARY\n\
--  Copyright (C) 2004 GAISLER RESEARCH\n\
--\n\
--  This program is free software; you can redistribute it and/or modify\n\
--  it under the terms of the GNU General Public License as published by\n\
--  the Free Software Foundation; either version 2 of the License, or\n\
--  (at your option) any later version.\n\
--\n\
--  See the file COPYING for the full details of the license.\n\
--\n\
-----------------------------------------------------------------------------\n\
-- Entity: 	ahbrom\n\
-- File:	ahbrom.vhd\n\
-- Author:	Jiri Gaisler - Gaisler Research\n\
-- Description:	AHB rom. 0/1-waitstate read\n\
------------------------------------------------------------------------------\n\
library ieee;\n\
use ieee.std_logic_1164.all;\n\
library grlib;\n\
use grlib.amba.all;\n\
use grlib.stdlib.all;\n\
use grlib.devices.all;\n\
\n\
entity ahbrom is\n\
  generic (\n\
    hindex  : integer := 0;\n\
    haddr   : integer := 0;\n\
    hmask   : integer := 16#fff#;\n\
    pipe    : integer := 0;\n\
    tech    : integer := 0;\n\
    kbytes  : integer := 1);\n\
  port (\n\
    rst     : in  std_ulogic;\n\
    clk     : in  std_ulogic;\n\
    ahbsi   : in  ahb_slv_in_type;\n\
    ahbso   : out ahb_slv_out_type\n\
  );\n\
end;\n\
\n\
architecture rtl of ahbrom is\n\
constant abits : integer := %d;\n\
constant bytes : integer := %d;\n\
\n\
constant hconfig : ahb_config_type := (\n\
  0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_AHBROM, 0, 0, 0),\n\
  4 => ahb_membar(haddr, '1', '1', hmask), others => zero32);\n\
\n\
signal romdata : std_logic_vector(31 downto 0);\n\
signal addr : std_logic_vector(abits-1 downto 2);\n\
signal hsel, hready : std_ulogic;\n\
\n\
begin\n\
\n\
  ahbso.hresp   <= \"00\"; \n\
  ahbso.hsplit  <= (others => '0'); \n\
  ahbso.hirq    <= (others => '0');\n\
  ahbso.hcache  <= '1';\n\
  ahbso.hconfig <= hconfig;\n\
  ahbso.hindex  <= hindex;\n\
\n\
  reg : process (clk)\n\
  begin\n\
    if rising_edge(clk) then \n\
      addr <= ahbsi.haddr(abits-1 downto 2);\n\
    end if;\n\
  end process;\n\
\n\
  p0 : if pipe = 0 generate\n\
    ahbso.hrdata  <= romdata;\n\
    ahbso.hready  <= '1';\n\
  end generate;\n\
\n\
  p1 : if pipe = 1 generate\n\
    reg2 : process (clk)\n\
    begin\n\
      if rising_edge(clk) then\n\
	hsel <= ahbsi.hsel(hindex) and ahbsi.htrans(1);\n\
	hready <= ahbsi.hready;\n\
	ahbso.hready <=  (not rst) or (hsel and hready) or\n\
	  (ahbsi.hsel(hindex) and not ahbsi.htrans(1) and ahbsi.hready);\n\
	ahbso.hrdata  <= romdata;\n\
      end if;\n\
    end process;\n\
  end generate;\n\
\n\
  comb : process (addr)\n\
  begin\n\
    case conv_integer(addr) is\n\
", abits, fsize, abits-1);

  i = 0;
  while (!feof(fp)) {
    fread(&tmp, 1, 4, fp);
    fprintf(wfp, "    when 16#%05X# => romdata <= X\"%08X\";\n", i++, htonl(tmp));
  }
  fprintf(wfp, "\
    when others => romdata <= (others => '-');\n\
    end case;\n\
  end process;\n\
  -- pragma translate_off\n\
  bootmsg : report_version \n\
  generic map (\"ahbrom\" & tost(hindex) &\n\
  \": 32-bit AHB ROM Module,  \" & tost(bytes/4) & \" words, \" & tost(abits-2) & \" address bits\" );\n\
  -- pragma translate_on\n\
  end;\n\
");

 fclose (wfp);
 fclose (fp);
 return(0);
 exit(0);
}
