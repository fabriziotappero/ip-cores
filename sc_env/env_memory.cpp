#include "env_memory.h"
#include <stdio.h>

void env_memory::event()
{
  int lcl_cs;
  int ad;
  
  // ignore activity during reset
  if (!reset_n)
  	return;
  if (!mreq_n && !wr_n && (addr < AM_DEPTH)) {
    ad = (int) addr;
    assert (memory != NULL);
    memory[ad] = (unsigned char) wr_data.read();
#ifdef DEBUG
    //printf ("MEM WR %04x=%02x\n", ad, (int) wr_data.read());
#endif
  } 
  
  // async read output
  if (addr < AM_DEPTH) {
    ad = (int) addr;
    assert (memory != NULL);
    rd_data.write ( (unsigned int) memory[ad] );
  }
}

int inline readline(FILE *fh, char *buf)
{
	int c = 1, cnt = 0;
	
	assert (fh != NULL);
	
	if (feof(fh)) {
		*buf = (char) 0;
		return 0;
	}
	while (c) {
		c = fread (buf, 1, 1, fh);
		cnt++;
		if (c && (*buf == '\n')) {
			buf++;
			*buf = (char) 0;
			c = 0;
		}
		else buf++;
	}
	return cnt;
}

/*
        line = ifh.readline()
        while (line != ''):
            if (line[0] == ':'):
                rlen = int(line[1:3], 16)
                addr = int(line[3:7], 16)
                rtyp = int(line[7:9], 16)
                ptr = 9
                for i in range (0, rlen):
                    laddr = addr + i
                    val = int(line[9+i*2:9+i*2+2], 16)
                    self.map[laddr] = val
                    self.bcount += 1
                    if (laddr > self.max): self.max = laddr
                    if (laddr < self.min): self.min = laddr

            line = ifh.readline()
 */
 void env_memory::load_ihex(char *filename)
{
	FILE *fh;
	char line[80];
    char *lp;
    int rlen, addr, rtyp, databyte;
    int rv;
    int dcount = 0;
	
	fh = fopen (filename, "r");
	
	rv = readline (fh, line);
    while (strlen(line) > 0) {
      //printf ("DEBUG: strlen(line)=%d rv=%d line=%s\n", strlen(line), rv, line);
      sscanf (line, ":%02x%04x%02x", &rlen, &addr, &rtyp);
      //printf ("DEBUG: rlen=%d addr=%d rtyp=%d\n", rlen, addr, rtyp);
      lp = line + 9;
      for (int c=0; c<rlen; c++) {
      	sscanf (lp, "%02x", &databyte);
      	lp += 2;
      	//printf ("DEBUG: loaded mem[%04x]=%02x\n", addr+c, databyte);
      	assert ( (addr+c) < AM_DEPTH );
      	memory[addr+c] = databyte; dcount++;
      }
      rv = readline (fh, line);
    }
	
	fclose (fh);
	printf ("ENVMEM  : Read %d bytes from %s\n", dcount, filename);
}
