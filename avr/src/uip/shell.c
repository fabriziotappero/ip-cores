 /*
 * Copyright (c) 2003, Adam Dunkels.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote
 *    products derived from this software without specific prior
 *    written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * This file is part of the uIP TCP/IP stack.
 *
 * $Id: shell.c,v 1.1 2006/06/07 09:43:54 adam Exp $
 *
 */

#include "shell.h"
#include <device.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <mmc.h>


static struct {
	struct buf readbuf;
	struct buf writebuf;
} telnet_data;

static igordev_read_fn_t  telnet_recv;
static igordev_write_fn_t telnet_send;
static igordev_init_fn_t  init;
static igordev_flush_fn_t telnet_flush;
void hexdump(uint8_t * p, uint16_t len);

struct igordev igordev_telnet = {
	.init = init,
	.read = telnet_recv,
	.write = telnet_send,
	.flush = telnet_flush,
	.read_status = 0,
	.write_status = 0,
	.priv = &telnet_data
};

//Initialize device
void init() {
	buf_init(&telnet_data.readbuf);
	buf_init(&telnet_data.writebuf);
	igordev_telnet.read_status = igordev_telnet.write_status = IDEV_STATUS_OK;
}

/*
 * Read num bytes from device and place it into data.
 * Data assumed to be a buffer large enough for num bytes.
 * Addr here is ignored.
 */
uint8_t
telnet_recv(uint64_t addr, uint8_t *data, uint8_t num)
{
	struct buf *buf;
	uint8_t byte;
	uint8_t i;

	buf = &telnet_data.readbuf;
	/* Avoid making larger buffers for now. */
	for (i = 0; i < num; i++) {
		buf_read(buf, &byte, 1);
		if (BUF_EMPTY(buf))
			break;
		*(data + i) = byte;
	}
	return (i);
}

/* 
 * Read from data to device
 */
uint8_t 
telnet_send(uint64_t addr, uint8_t *data, uint8_t num)
{
	struct buf *buf;
	uint8_t i = 0;

	if (num > 0 && data != NULL) {
		/* Copy data into write buffer. */
		buf = &telnet_data.writebuf;
		i = buf_write(buf, data, num);
	}
	return i;
}

/* Flush buffered data to shell output */
static void
telnet_flush(void)
{
	struct buf *buf;
	buf = &telnet_data.writebuf;
	uint8_t data[2];

	data[1] = '\0';
	igordev_telnet.write_status = IDEV_STATUS_BUSY;
	/* Flush as long as it is ok. */
	while (!BUF_EMPTY(buf)) {
		buf_read(buf, data, 1);
		shell_output((char *)data, "");
	}
	igordev_telnet.write_status = IDEV_STATUS_OK;
}


struct ptentry {
  char *commandstr;
  void (* pfunc)(char *str);
};

#define COMMAND_MODE 0
#define LISP_MODE 1
#define SHELL_PROMPT "IGOR> "

uint8_t mode = COMMAND_MODE;

/*---------------------------------------------------------------------------*/
static void
parse(register char *str, struct ptentry *t)
{
  struct ptentry *p;
  for(p = t; p->commandstr != NULL; ++p) {
    if(strncmp(p->commandstr, str, strlen(p->commandstr)) == 0) {
      break;
    }
  }

  p->pfunc(str);
}
/*---------------------------------------------------------------------------*/
static void
inttostr(register char *str, unsigned int i)
{
  str[0] = '0' + i / 100;
  if(str[0] == '0') {
    str[0] = ' ';
  }
  str[1] = '0' + (i / 10) % 10;
  if(str[0] == ' ' && str[1] == '0') {
    str[1] = ' ';
  }
  str[2] = '0' + i % 10;
  str[3] = ' ';
  str[4] = 0;
}
/*---------------------------------------------------------------------------*/
static void
help(char *str)
{
  shell_output("Available commands:", "");
  shell_output("help, ?    - show help", "");
  shell_output("+, -       - read SD card", "");
  shell_output("lisp       - switch to lisp mode", "");
  shell_output("exit       - exit shell", "");
}

static void
switch_lisp(char *str)
{
	shell_output("Not yet implemented!", "");
//	mode = LISP_MODE;
}

uint32_t lba = 0;

//Read one sector from the memory card and dump it to the shell
void
read_sd(void)
{
	char lbastr[5];
	inttostr(lbastr, lba);

	shell_output("Reading SD card: Sector", lbastr);

	uint8_t data[512];

	if (mmc_readsector(lba, data) == 0)	
		hexdump(data, 512);
	else
		shell_output("Failed to read that sector", "");
}

//Increase sector number by one and dump that sector
static void
sd_plus(char *str)
{
	lba++;
	read_sd();
}

//Decrease sector number by one and dump that sector
static void
sd_minus(char *str)
{
	if (lba > 0)
		lba--;
	read_sd();
}

/*---------------------------------------------------------------------------*/
static void
unknown(char *str)
{
  if(strlen(str) > 0) {
    shell_output("Unknown command: ", str);
  }
}
/*---------------------------------------------------------------------------*/
static struct ptentry parsetab[] =
  {{"lisp", switch_lisp},
   {"+", sd_plus},
   {"-", sd_minus},
   {"help", help},
   {"exit", shell_quit},
   {"?", help},

   /* Default action */
   {NULL, unknown}};
/*---------------------------------------------------------------------------*/
void
shell_init(void)
{}
/*---------------------------------------------------------------------------*/
void
shell_start(void)
{
	mode = COMMAND_MODE;
	shell_output("Greetings and salutations, sir or madam.", "");
	shell_output("I bid you welcome to the IGOR command shell!", "");
	shell_output("How may I serve you today?", "");
	shell_output("Please, type '?' and return for help.", "");
	shell_prompt(SHELL_PROMPT);
}
/*---------------------------------------------------------------------------*/
void
shell_input(char *cmd)
{
	if (mode == COMMAND_MODE) {
		parse(cmd, parsetab);
	}
	if (mode == COMMAND_MODE) {
		shell_prompt(SHELL_PROMPT);
	} else {
		//Lisp mode does not work yet
/*		struct buf *buf;
		buf = &telnet_data.readbuf;
		buf_write(buf, (uint8_t *)cmd, strlen(cmd));
*/	}
}
/*---------------------------------------------------------------------------*/
//Dump a memory card sector as a nice hex display
void hexdump(uint8_t * p, uint16_t len)
{
	int i,j;

	for (i=0;i<len/16;i++)
	{
		char str0[70] = "";

		char str1[5];
		sprintf(str1, "%03x ",i*16);
		strcat(str0, str1);
		for (j=0;j<16;j++) {
			char str2[5];
			sprintf(str2, "%02x ",p[i*16+j]);
			strcat(str0, str2);
		}
		for (j=0;j<16;j++) {
			char str3[5];
			sprintf(str3, "%c", isalpha(p[i*16+j]) ? p[i*16+j] : '.');
			strcat(str0, str3);
		}
		shell_output(str0, "");
	}
}
