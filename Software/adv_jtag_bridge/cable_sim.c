/* cable_sim.c - Simulation connection drivers for the Advanced JTAG Bridge
   Copyright (C) 2001 Marko Mlinar, markom@opencores.org
   Copyright (C) 2004 György Jeney, nog@sdf.lonestar.org
   
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */



#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#include "cable_sim.h"
#include "errcodes.h"

#define debug(...) //fprintf(stderr, __VA_ARGS__ )

/* Only used in the vpi */
jtag_cable_t vpi_cable_driver = {
    .name = "vpi",
    .inout_func = cable_vpi_inout,
    .out_func = cable_vpi_out,
    .init_func = cable_vpi_init,
    .opt_func = cable_vpi_opt,
    .bit_out_func = cable_common_write_bit,
    .bit_inout_func = cable_common_read_write_bit,
    .stream_out_func = cable_common_write_stream,
    .stream_inout_func = cable_common_read_stream,
    .flush_func = NULL,
    .opts = "s:p:",
    .help = "-p [port] Port number that the VPI module is listening on\n\t-s [server] Server that the VPI module is running on\n",
};

static int vpi_comm;
static int vpi_port = 4567;
static char *vpi_server = "localhost";

/* Only used for the rtl_sim */
jtag_cable_t rtl_cable_driver = {
    .name ="rtl_sim",
    .inout_func = cable_rtl_sim_inout,
    .out_func = cable_rtl_sim_out,
    .init_func = cable_rtl_sim_init,
    .opt_func = cable_rtl_sim_opt,
    .bit_out_func = cable_common_write_bit,
    .bit_inout_func = cable_common_read_write_bit,
    .stream_out_func = cable_common_write_stream,
    .stream_inout_func = cable_common_read_stream,
    .flush_func = NULL,
    .opts = "d:",
    .help = "-d [directory] Directory in which gdb_in.dat/gdb_out.dat may be found\n"
};

static char *gdb_in = "gdb_in.dat";
static char *gdb_out = "gdb_out.dat";



/*-------------------------------------------[ rtl_sim specific functions ]---*/
jtag_cable_t *cable_rtl_get_driver(void)
{
  return &rtl_cable_driver; 
}

int cable_rtl_sim_init()
{
  FILE *fin = fopen (gdb_in, "wt+");
  if(!fin) {
    fprintf(stderr, "Can not open %s\n", gdb_in);
    return APP_ERR_INIT_FAILED;
  }
  fclose(fin);
  return APP_ERR_NONE;
}

int cable_rtl_sim_out(uint8_t value)
{
  FILE *fout;
  int num_read;
  int r;
  debug("O (%x)\n", value);
  fout = fopen(gdb_in, "wt+");
  fprintf(fout, "F\n");
  fflush(fout);
  fclose(fout);
  fout = fopen(gdb_out, "wt+");
  fprintf(fout, "%02X\n", value);
  fflush(fout);
  fclose(fout);
  do {
    fout = fopen(gdb_out, "rt");
    r = fscanf(fout,"%x", &num_read);
    fclose(fout);
    usleep(1000);
    debug(" (Ack %x) ", num_read);
  } while(!r || (num_read != (0x10 | value)));
  debug("\n");
  return APP_ERR_NONE;
}

int cable_rtl_sim_inout(uint8_t value, uint8_t *inval)
{
  FILE *fin = 0;
  char ch;
  uint8_t data;
  debug("IO (");

  while(1) {
    fin = fopen(gdb_in, "rt");
    if(!fin) {
      usleep(1000);
      continue;
    }
    ch = fgetc(fin);
    fclose(fin);
    if((ch != '0') && (ch != '1')) {
      usleep(1000);
      continue;
    }
    else
      break;
  }
  data = ch == '1' ? 1 : 0;

  debug("%x,", data);

  cable_rtl_sim_out(value);

  debug("%x)\n", value);

  *inval = data;
  return APP_ERR_NONE;
}


int cable_rtl_sim_opt(int c, char *str)
{
  switch(c) {
  case 'd':
    if(!(gdb_in = malloc(strlen(str) + 12))) { /* 12 == strlen("gdb_in.dat") + 2 */
      fprintf(stderr, "Unable to allocate enough memory\n");
      return APP_ERR_MALLOC;
    }
    if(!(gdb_out = malloc(strlen(str) + 13))) { /* 13 == strlen("gdb_out.dat") + 2 */
      fprintf(stderr, "Unable to allocate enough memory\n");
      free(gdb_in);
      return APP_ERR_MALLOC;
    }

    sprintf(gdb_in, "%s/gdb_in.dat", str);
    sprintf(gdb_out, "%s/gdb_out.dat", str);
    break;
  default:
    fprintf(stderr, "Unknown parameter '%c'\n", c);
    return APP_ERR_BAD_PARAM;
  }
  return APP_ERR_NONE;
}

/*-----------------------------------------------[ VPI specific functions ]---*/
jtag_cable_t *cable_vpi_get_driver(void)
{
  return &vpi_cable_driver; 
}


int cable_vpi_init()
{
  struct sockaddr_in addr;
  struct hostent *he;

  if((vpi_comm = socket(PF_INET, SOCK_STREAM, 0)) < 0) {
    fprintf(stderr, "Unable to create socket (%s)\n", strerror(errno));
    return APP_ERR_CONNECT;
  }


  if((he = gethostbyname(vpi_server)) == NULL) {
    perror("gethostbyname");
    return APP_ERR_CONNECT;
  }

  addr.sin_family = AF_INET;
  addr.sin_port = htons(vpi_port);
  addr.sin_addr = *((struct in_addr *)he->h_addr);
  memset(addr.sin_zero, '\0', sizeof(addr.sin_zero));

  if(connect(vpi_comm, (struct sockaddr *)&addr, sizeof(addr)) == -1) {
    fprintf(stderr, "Unable to connect to %s port %d (%s)\n", vpi_server, vpi_port,
            strerror(errno));
    return APP_ERR_CONNECT;
  }

  debug("VPI connected!");

  return APP_ERR_NONE;
}

int cable_vpi_out(uint8_t value)
{
  uint8_t ack;
  int ret;

  /* Send the data to the socket */
  ret = send(vpi_comm, &value, 1, 0);
  debug("Sent %d, ret %d\n", value, ret);

  do {
    /* Ok, read the data */
    ret = recv(vpi_comm, &ack, 1, 0);
    if(ret < 0) {
      printf("Error during receive (%s)\n", strerror(errno));
      return APP_ERR_CONNECT;
    }
  } while(ack != (value | 0x10));

  cable_vpi_wait();  // finish the transaction

  return APP_ERR_NONE;
}

int cable_vpi_inout(uint8_t value, uint8_t *inval)
{
  uint8_t dat;

  /* ask vpi to send us the out-bit */
  dat = 0x80;
  send(vpi_comm, &dat, 1, 0);

  /* Wait and read the data */
  recv(vpi_comm, &dat, 1, 0);

  if(dat > 1)
    fprintf(stderr, "Unexpected value: %i\n", dat);

  cable_vpi_out(value);

  *inval = dat;

  cable_vpi_wait();  // finish the transaction

  return APP_ERR_NONE;
}

void cable_vpi_wait()
{
  uint8_t dat = 0x81;

  /* Get the sim to reply when the timeout has been reached */
  if(send(vpi_comm, &dat, 1, 0) < 1) {
    fprintf(stderr, "Failed to send pkt in cable_vpi_wait(): %s\n", strerror(errno));
  }

  /* block, waiting for the data */
  if(recv(vpi_comm, &dat, 1, 0) < 1) {
    fprintf(stderr, "Recv failed in cable_vpi_wait(): %s\n", strerror(errno));
  }

  if(dat != 0xFF)
    fprintf(stderr, "Warning: got wrong byte waiting for timeout: 0x%X\n", dat);

}

int cable_vpi_opt(int c, char *str)
{
  switch(c) {
  case 'p':
    if((vpi_port = atoi(str)) == 0) {
      fprintf(stderr, "Bad port value for VPI sim: %s\n", str);
      return APP_ERR_BAD_PARAM;
    }
    break;
  case 's':
    vpi_server = strdup(str);
    if(vpi_server == NULL) {
      fprintf(stderr, "Unable to allocate enough memory for server string\n");
      return APP_ERR_MALLOC;
    }
    break;
  default:
    fprintf(stderr, "Unknown parameter '%c'\n", c);
    return APP_ERR_BAD_PARAM;
  }
  return APP_ERR_NONE;
}
