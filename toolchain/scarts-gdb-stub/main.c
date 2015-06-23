/* Copyright (C) 2010, 2011 Embedded Computing Systems Group,
Department of Computer Engineering, Vienna University of Technology.
Contributed by Martin Walter <mwalter@opencores.org>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation, either version 2.1 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>. */


#include <inttypes.h>
#include <signal.h>
#include <stdint.h>
#include <string.h>
#include <machine/interrupt.h>
#include <machine/modules.h>
#include "breakpoint/breakpoint.h"

#if defined __SCARTS_16__
  #include "scarts_16-tdep.h"
  #define SCARTS_ADDR_CTYPE  uint16_t
#elif defined __SCARTS_32__
  #include "scarts_32-tdep.h"
  #define SCARTS_ADDR_CTYPE  uint32_t
#else
  #error "Unsupported target machine type"
#endif

typedef struct
{
  uint8_t is_used;
  uint8_t type; // 2 := write, 3 := read, 4 := access
  SCARTS_ADDR_CTYPE address;
  SCARTS_ADDR_CTYPE length;
} watchpoint_entry_t;

#define NUMREGS 17
#define DEBUG_INT 11
#define REG_TYPE SCARTS_ADDR_CTYPE

/* Macros for boolean datatype definition. */
#define BOOL  uint8_t
#define TRUE  1
#define FALSE 0

/* Macros for bit manipulations. */
#define read_bit(regfile, bitpos) (((regfile) >> (bitpos)) & 1)
#define write_bit(regfile, bitpos, value) (void)((value) ? ((regfile) |= (1 << (bitpos))) : ((regfile) &= ~(1 << (bitpos))))

#define NUM_WATCHPOINTS 3

static int read_status_to_reset_ei_flag;
static watchpoint_entry_t watchpoints[NUM_WATCHPOINTS]; 

/* Number of bytes of registers.  */
#define NUMREGBYTES (NUMREGS * SCARTS_WORD_SIZE)

/************************************************************************/
/* BUFMAX defines the maximum number of characters in inbound/outbound buffers*/
/* at least NUMREGBYTES*2 are needed for register packets */
#define BUFMAX 256

#define CTRL_C 0x03

static uint8_t msg_buffer[BUFMAX+1], *msg_tx, *msg_write;
static int msg_size = 0; //Pointing to first free byte in buffer.
static volatile enum recv_states { recv_start, recv_data, recv_chk1, recv_chk2, 
	recv_transmit_start, recv_transmit_data } 
	recv_state = recv_start;

#define SAVED_FPY (*(REG_TYPE*)(SCARTS_DATAMEM_SIZE - SCARTS_WORD_SIZE * (NUMREGS)))
#define SAVED_FPZ (*(REG_TYPE*)(SCARTS_DATAMEM_SIZE - SCARTS_WORD_SIZE * (NUMREGS+1)))
/* Points to the register values stored by ASM_SAVE_REG */
static REG_TYPE* const saved_registers = (REG_TYPE*)(SCARTS_DATAMEM_SIZE - SCARTS_WORD_SIZE * (NUMREGS-1));//[NUMREGS-1]; /*Without PC. */
static REG_TYPE stop_pc;
static BOOL is_stopped = FALSE,  
	stop_reply_pending = FALSE,
	app_loaded = FALSE; /* Has an application been transfered to the target? */

static BOOL wp_hit(REG_TYPE addr);
static BOOL wp_add(uint8_t type, REG_TYPE addr, REG_TYPE length);
static BOOL wp_remove(uint8_t type, REG_TYPE addr, REG_TYPE length);
static BOOL bp_remove(void* addr);
static BOOL bp_add(void* addr);
static void** bp_find(void* addr);
static void send_stop_reply();
void miniuart_isr1();
void miniuart_isr();
extern void stub_init();


int main() {
	stub_init();
	
	/* Wait for application download */
	
	stop_pc = 0;	
	is_stopped = TRUE;
	
	FPY = 0; //Frameptr
	FPZ = 0; //Stackptr
	
	asm("main_endles_loop: jmpi main_endles_loop\n");
	
	return 0;
}	

/* Saves all register values to the location directed by FPX.
 * Saved registers can be accessed through the global saved_registers. */
#define ASM_SAVE_REG \
";Save all registers\n\
stfpx_dec r15,-1\n\
stfpx_dec r14,-1\n\
stfpx_dec r13,-1\n\
stfpx_dec r12,-1\n\
stfpx_dec r11,-1\n\
stfpx_dec r10,-1\n\
stfpx_dec r9,-1\n\
stfpx_dec r8,-1\n\
stfpx_dec r7,-1\n\
stfpx_dec r6,-1\n\
stfpx_dec r5,-1\n\
stfpx_dec r4,-1\n\
stfpx_dec r3,-1\n\
stfpx_dec r2,-1\n\
stfpx_dec r1,-1\n\
stfpx_dec r0,-1\n"

#define ASM_SAVE_FPYZ \
";save Stack- and Frame-Pointer\n\
ldli r1, -16 ;FPY\n\
ldw r0,r1\n\
stfpx_dec r0,-1\n\
ldli r1, -12 ;FPZ\n\
ldw r0,r1\n\
stfpx_dec r0,-1\n"

#define ASM_INIT_STACK \
";Set Stack-Start into Stub-Memory\n\
ldli r3, -20 ;FPX\n\
ldw r2,r3\n\
ldli r1, -12 ;FPZ\n\
stw r2,r1 ;FPZ=FPX\n\
ldli r1, -16 ;FPY\n\
stw r2,r1 ;FPY=FPX\n"


#define ASM_RESTORE_FPYZ \
";restore Stack- and Frame-Pointer\n\
ldli r0, -12 ;FPZ\n\
ldfpx_inc r1, 0\n\
stw r1, r0\n\
ldli r0, -16 ;FPY\n\
ldfpx_inc r1, 0\n\
stw r1, r0\n"	

#define ASM_RESTORE_REG \
";restore all registers\n\
ldfpx_inc r0, 0\n\
ldfpx_inc r1, 0\n\
ldfpx_inc r2, 0\n\
ldfpx_inc r3, 0\n\
ldfpx_inc r4, 0\n\
ldfpx_inc r5, 0\n\
ldfpx_inc r6, 0\n\
ldfpx_inc r7, 0\n\
ldfpx_inc r8, 0\n\
ldfpx_inc r9, 0\n\
ldfpx_inc r10, 0\n\
ldfpx_inc r11, 0\n\
ldfpx_inc r12, 0\n\
ldfpx_inc r13, 0\n\
ldfpx_inc r14, 0\n\
ldfpx_inc r15, 0\n"

	
static void STOP_HERE() {
	if(!is_stopped)
		stop_pc = (saved_registers)[SCARTS_RTE_REGNUM]; //Dont loose PC when called twice.

	is_stopped = TRUE;
asm(ASM_RESTORE_FPYZ);
asm(ASM_RESTORE_REG);
asm("ldhi r15, 4th(__stop_here_enable_gie)\n"
"ldliu r15, 3rd(__stop_here_enable_gie)\n"
"sli r15, 8\n"
"ldliu r15, hi(__stop_here_enable_gie)\n"
"sli r15, 8\n"
"ldliu r15, lo(__stop_here_enable_gie)\n"
"rte			; Enable GIE\n"
"__stop_here_enable_gie: jmpi __stop_here_enable_gie\n");
}

/* Convert ch from a hex digit to an int */
static int
hex (unsigned char ch)
{
  if (ch >= 'a' && ch <= 'f')
    return ch-'a'+10;
  if (ch >= '0' && ch <= '9')
    return ch-'0';
  if (ch >= 'A' && ch <= 'F')
    return ch-'A'+10;
  return -1;
}

const char hexchars[]="0123456789abcdef";


static inline void uart_recv_mode() {
	MINI_UART_CMD = 0x60; //Start Receiver, Event-Selector = 0!! Required to Start receiver.
	//Receiver is now active, set EVS next.
	MINI_UART_CMD = 0x64; //Start Receiver, Enable Interrupt when receive complete!!
}

static inline void uart_stop() {
	MINI_UART_CMD = 0x0;
}


static void send_byte(uint8_t send) {
	MINI_UART_CMD = 0x0;

	  /* Zu sendende Nachricht in Messageregister laden */
    MINI_UART_MSG_L = send;

	  /* Starte Transmitter (ERRI=0, EI=1, AsA="011", EvS="11")*/
    MINI_UART_CMD = 0x58;	
    MINI_UART_CMD = 0x5E;	
}

static void byte_received(uint8_t byte);

#ifdef TARGET_SIM

typedef struct {void* start,*end; } mem_region;
static mem_region valid_regions[] = { 
	{(void*)SCARTS_DATAMEM_LMA, (void*)SCARTS_DATAMEM_SIZE }, //Data
	{(void*)PROC_CTRL_BADDR, (void*)(PROC_CTRL_BADDR + PROC_CTRL_SIZE) }, //Sysctrl 
	{(void*)DISP7SEG_BADDR, (void*)(DISP7SEG_BADDR+DISP7SEG_SIZE) }, //Display 
	{(void*)MINI_UART_BADDR, (void*)(MINI_UART_BADDR+MINI_UART_SIZE }, //miniUART 
	{0,0}};

int is_valid_mem(void* addr) {
	mem_region* rgn = valid_regions;
	while(rgn->start != rgn->end) {
		if(addr >= rgn->start && addr < rgn->end)
			return 1;
		
		++rgn;
	}
	return 0;
}
#endif//TARGET_SIM

char *
mem2hex(uint8_t *mem, char *buf, int count)
{
  unsigned char ch;

  while (count-- > 0)
    {
#ifdef TARGET_SIM	  
      ch = is_valid_mem(mem) ? *mem : 0;
#else//TARGET_SIM
      ch = *mem;
#endif//TARGET_SIM
      *buf++ = hexchars[ch >> 4];
      *buf++ = hexchars[ch & 0xf];
      mem++;
    }

  return buf;
}



asm("miniuart_isr:\n");
asm(ASM_SAVE_REG);
asm(ASM_SAVE_FPYZ);
asm(ASM_INIT_STACK);
asm(";call actual interrupt handler\n\
ldhi  r0,4th(miniuart_isr1)\n\
ldliu r0,3rd(miniuart_isr1)\n\
sli   r0,8\n\
ldliu r0,hi(miniuart_isr1)\n\
sli   r0,8\n\
ldliu r0,lo(miniuart_isr1)\n\
jsr r0\n");
asm(ASM_RESTORE_FPYZ);
asm(ASM_RESTORE_REG);
asm("rte;\n");


void miniuart_isr1() {

	if (read_bit(BREAKPOINT_STATUS, BREAKPOINT_STATUS_INT)) {
		//Handle single-step interrupt.

		//Interrupt Ack.
		BREAKPOINT_CONFIG |= (1 << BREAKPOINT_CONFIG_INTA);

		send_stop_reply();
		STOP_HERE();
	} else if (read_bit(MINI_UART_STATUS, MINI_UART_STATUS_INT)) {
		//Handle miniUART interrupt.
	
		read_status_to_reset_ei_flag = MINI_UART_STATUS; //Reading status resets EI-Flag
			 
		//Interrupt Ack.
		MINI_UART_CONFIG |= (1 << MINI_UART_CONFIG_INTA);
	
		switch(recv_state) {
		case recv_transmit_data:
			if(msg_tx >= msg_write) {
				msg_write = msg_buffer; 
				recv_state = recv_start;
				uart_recv_mode(); //Put UART-HW in receive mode.
			} else {
				send_byte(*msg_tx++);
			}
			break;
		default: //receive	
			byte_received(MINI_UART_MSG_L);
			break;
		}
		
		if (recv_state == recv_start 
			&& stop_reply_pending) {
			send_stop_reply();
		}
	}
}

static uint8_t checksum, pkgchecksum;

#define start_send() recv_state = recv_transmit_data; msg_tx = msg_buffer; send_byte(*msg_tx++);

void add_chk(uint8_t* msg_start_chk) {
	uint8_t checksum = 0;
	while(msg_start_chk < msg_write)
		checksum += *msg_start_chk++;

	*msg_write++ = '#';
	*msg_write++ = hexchars[checksum >> 4];
	*msg_write++ = hexchars[checksum & 0xf];
}


static void request_received();
static void ctrl_c_received();

static void byte_received(uint8_t byte) {

	switch(recv_state) {
	case recv_start: 
		if (byte == '$') {
restart_receive:
			msg_write = msg_buffer;
			checksum = 0;
			recv_state = recv_data;
		} else if (byte == CTRL_C) {
			ctrl_c_received();
		}
		break;
	case recv_data:
		if (byte == '$') //$ must noch occur in package data.
			goto restart_receive; 
		else if (msg_write >= msg_buffer + BUFMAX) { //request too large
			msg_write = msg_buffer;
			*msg_write++ = '+';
			start_send()
		} else if (byte == '#') {
			recv_state = recv_chk1;
		} else {
			*msg_write++ = byte;
			checksum += byte;
		}
		break;
	case recv_chk1:
		pkgchecksum = hex(byte) << 4;
		recv_state = recv_chk2;
		break;
	case recv_chk2:
		pkgchecksum += hex(byte);

		if(checksum != pkgchecksum) { //Checksum error.
			msg_write = msg_buffer;
			*msg_write++ = '-';  //NACK
			start_send();
		} else {
			msg_size = msg_write - msg_buffer;
			*msg_write = '\0'; //Terminate for mem2hex
			msg_write = msg_buffer; //Place response in the same buffer;
			request_received();
		}
		break;
	case recv_transmit_start:
	case recv_transmit_data:
		break; //Should not happen.
	}
}

int hexToInt(uint8_t **ptr, SCARTS_ADDR_CTYPE *intValue)
{
  int numChars = 0;
  int hexValue;

  *intValue = 0;

  while (**ptr)
    {
      hexValue = hex(**ptr);
      if (hexValue < 0)
	break;

      *intValue = (*intValue << 4) | hexValue;
      numChars ++;

      (*ptr)++;
    }

  return (numChars);
}

static void send_stop_reply() {
	stop_reply_pending = FALSE;
	
	*msg_write++ = '$';
	uint8_t* start_chk = msg_write;	
	*msg_write++ = 'S';
	*msg_write++ = '0'; //Signal value
	*msg_write++ = '5'; //Signal value
	
	add_chk(start_chk);
	start_send();
}

REG_TYPE tmp_regval14, tmp_regval15;

static void ctrl_c_received() {
	if (is_stopped)
		return; //Already stopped. Ignore further Ctrl+C requests.

	msg_write = msg_buffer;
	
	send_stop_reply();
	STOP_HERE();	
}

// Complete Request is in msg_buffer now. Craft a response.
static void request_received() {

	if(msg_size < 1) { //Emypt request ???
		*msg_write++ = '+';
		start_send();
		return;
	}
	
	uint8_t* ptr = msg_buffer;
	uint8_t pkg_type = *ptr++; 
	*msg_write++ = '+'; //Overwrites pkg_type-
	
	switch(pkg_type) {
	
	case '?': /* Indicate halt reason */
	{
		if(is_stopped) {
			send_stop_reply();
		} else {
			stop_reply_pending = TRUE;
		}
	}
	break;
	  
	case 'c': //"c [addr]" Continue. addr is address to resume.
	{
		SCARTS_ADDR_CTYPE addr;
		if(hexToInt(&ptr, &addr))
			(saved_registers)[SCARTS_RTE_REGNUM] = addr; //Continue at specified program adress.
		else if (is_stopped)
			(saved_registers)[SCARTS_RTE_REGNUM] = stop_pc;

		is_stopped = FALSE;
		start_send();
		//send_stop_replay as soon as stopping.
	}
	break;
	
	case 'g': /* Read general registers */
	{
		*msg_write++ = '$';
		uint8_t* chk_start = msg_write;
		
		uint8_t* preg = (uint8_t*)saved_registers;
		int i; 
		for (i = 0; i < (NUMREGS-1)*SCARTS_WORD_SIZE; ++i) {
			*msg_write++ = hexchars[*preg >> 4];
			*msg_write++ = hexchars[*preg & 0xf];
			++preg;
		}
		
		//PC = RTE
		if(is_stopped)
			preg = (uint8_t*)&stop_pc;
		else
			preg = (uint8_t*)(saved_registers + SCARTS_RTE_REGNUM);
		
		for (i = 0; i < SCARTS_WORD_SIZE; ++i) {
			*msg_write++ = hexchars[*preg >> 4];
			*msg_write++ = hexchars[*preg & 0xf];
			++preg;
		}
		
		add_chk(chk_start);
		start_send();
	}
	break;
	
	case 'G': /* Write general registers. */
	{
		uint8_t* chk_start;

		if(msg_size <  1/*G*/ + NUMREGS * SCARTS_WORD_SIZE * 2) {
			/* Message doesnt contain data for all registers! */
			*msg_write++ = '$';
			chk_start = msg_write;
			*msg_write++ = 'E';
			*msg_write++ = '0';
			*msg_write++ = '1';
		} else {
			/* Set Registers. */
			int lonib, hinib;
			uint8_t* preg = (uint8_t*)saved_registers;
			
			int i; 
			for (i = 0; i < (NUMREGS-1)*SCARTS_WORD_SIZE; ++i) {
				hinib = hex(*ptr++);
				lonib = hex(*ptr++);
				*preg++ = (hinib << 4) | lonib;
			}		

			/* Set PC */
			if(is_stopped)
				preg = (uint8_t*)&stop_pc;
			else
				preg = (uint8_t*)(saved_registers + SCARTS_RTE_REGNUM);

			for (i = 0; i < SCARTS_WORD_SIZE; ++i) {
				hinib = hex(*ptr++);
				lonib = hex(*ptr++);
				*preg++ = (hinib << 4) | lonib;
			}
			
			*msg_write++ = '$';
			chk_start = msg_write;
			*msg_write++ = 'O';
			*msg_write++ = 'K';
		}
			
		add_chk(chk_start);
		start_send();
	}
	break;

	case 'm': //"m addr,length" Read length bytes of memory starting at address addr
	{
		uint8_t* chk_start;

		SCARTS_ADDR_CTYPE addr,length;
		if (hexToInt(&ptr, &addr)
			&& *ptr++ == ','
			&& hexToInt(&ptr, &length)) {

			*msg_write++ = '$';
			chk_start = msg_write;
			
			if(addr == PROC_CTRL_FPY_BADDR && length <= 4)//Return Saved Frame-pointer. 
				msg_write = (uint8_t*)mem2hex((uint8_t*)&SAVED_FPY, (char*)msg_write, length);
			else if(addr == PROC_CTRL_FPZ_BADDR && length <= 4)//Return Saved Stack-pointer. 
				msg_write = (uint8_t*)mem2hex((uint8_t*)&SAVED_FPZ, (char*)msg_write, length);
			else			
				msg_write = (uint8_t*)mem2hex((uint8_t*)addr, (char*)msg_write, length); 
		} else {
			*msg_write++ = '$';
			chk_start = msg_write;
			*msg_write++ = 'E';
			*msg_write++ = '0';
			*msg_write++ = '1';
		}
		
		add_chk(chk_start);
		start_send();
	}
	break;

	case 'M': //"M addr,length:XX" Write length bytes of memory starting at address addr
	{
		SCARTS_ADDR_CTYPE addr,length;
		int lonib, hinib;
		uint8_t w_byte;

		uint8_t* chk_start;

		if (hexToInt(&ptr, &addr)
			&& *ptr++ == ','
			&& hexToInt(&ptr, &length)
			&& *ptr++ == ':') {
			
			while(length > 0
				&& (hinib = hex(*ptr++)) != -1
				&& (lonib = hex(*ptr++)) != -1) {
					
				w_byte = (hinib << 4) | lonib;
			
				if (addr >= SCARTS_CODEMEM_LMA && addr <= SCARTS_CODEMEM_LMA + SCARTS_CODEMEM_SIZE * SCARTS_INSN_SIZE) {
				// Write to instruction-memory. Use Programmer-Module!
					if(addr % 2 == 0) {
						/* Store first byte (LSB) in programmer-module. Wait for 2nd byte. */
						*(uint8_t*)(PROGRAMMER_BADDR+8) = w_byte; //LSB
					} else {
						/* 16-Bit word complete. Execute write. */
						*(uint8_t*)(PROGRAMMER_BADDR+9) = w_byte; //MSB
						PROGRAMMER_ADDRESS = addr / 2; //Address

						PROGRAMMER_CONFIG_C |= (1 << PROGRAMMER_CONFIG_C_PREXE); //Prog Exe
						
						app_loaded = TRUE;
					} 
				} else {
				//Write to data-memory
					*(uint8_t*)addr = w_byte; 
				}
				
				++addr;
				--length;
			}
			
			if(length == 0) {
				*msg_write++ = '$';
				chk_start = msg_write;
				*msg_write++ = 'O';
				*msg_write++ = 'K';
			} else {
				*msg_write++ = '$';
				chk_start = msg_write;
				*msg_write++ = 'E';
				*msg_write++ = '0';
				*msg_write++ = '3';
			}
		} else {
			*msg_write++ = '$';
			chk_start = msg_write;
			*msg_write++ = 'E';
			*msg_write++ = '0';
			*msg_write++ = '4';
		}

		add_chk(chk_start);
		start_send();
	}
	break;

	case 's': //"s [addr]" Single Step.
	{
		uart_stop();
		/* If there is an interrupt request protocoled, throw it away.
		Even though there should be no request until this one ins served.
		If this is not done, after the RTE at the end of this function,
		there would no single step in the application code happen, 
		but instead control would return to the isr immediately. */
		if(PROC_CTRL_INTPROT & (1<<DEBUG_INT)) {
			MINI_UART_CONFIG |= (1 << MINI_UART_CONFIG_INTA);
		} 
		
		SCARTS_ADDR_CTYPE addr;
		if(hexToInt(&ptr, &addr))
			(saved_registers)[SCARTS_RTE_REGNUM] = addr; //Step at specified program adress.
		else if (is_stopped)
			(saved_registers)[SCARTS_RTE_REGNUM] = stop_pc;

		is_stopped = FALSE;
		
		//Prepare register values for the breakpoint/single-step module.
		//Execute 4 instructions before generating an interrupt.
		tmp_regval14 = BREAKPOINT_SET_STEP_COUNT(BREAKPOINT_CONFIG_C, 4);
		tmp_regval15 = (REG_TYPE)&(BREAKPOINT_CONFIG_C); //CONFIG_C in breakpoint module.

//tmp_regval14 -> r14
asm("\
ldhi  r0,4th(tmp_regval14)\n\
ldliu r0,3rd(tmp_regval14)\n\
sli   r0,8\n\
ldliu r0,hi(tmp_regval14)\n\
sli   r0,8\n\
ldliu r0,lo(tmp_regval14)\n\
ldw r14,r0\n");
//tmp_regval15 -> r15
asm("\
ldhi  r0,4th(tmp_regval15)\n\
ldliu r0,3rd(tmp_regval15)\n\
sli   r0,8\n\
ldliu r0,hi(tmp_regval15)\n\
sli   r0,8\n\
ldliu r0,lo(tmp_regval15)\n\
ldw r15,r0\n");
asm(ASM_RESTORE_FPYZ);
asm("\
;restore all registers\n\
ldfpx_inc r0, 0\n\
ldfpx_inc r1, 0\n\
ldfpx_inc r2, 0\n\
ldfpx_inc r3, 0\n\
ldfpx_inc r4, 0\n\
ldfpx_inc r5, 0\n\
ldfpx_inc r6, 0\n\
ldfpx_inc r7, 0\n\
ldfpx_inc r8, 0\n\
ldfpx_inc r9, 0\n\
ldfpx_inc r10, 0\n\
ldfpx_inc r11, 0\n\
ldfpx_inc r12, 0\n\
ldfpx_inc r13, 0\n\
stb r14, r15 ;Start Single-Stepping\n\
ldfpx_inc r14, 0 ; -- 1 --\n\
ldfpx_inc r15, 0 ; -- 2 --\n\
\n\
rte; ; -- 3 --\n");		
	}
	break;

	case 'Z': //Insert breakpoint/watchpoint
	case 'z': //Remove breakpoint/watchpoint
	{
		uint8_t bp_type = *ptr++;
		*msg_write++ = '$';
		uint8_t* chk_start = msg_write;
		
		switch(bp_type) { /* msg_buffer[1] */
		case '0': //"Z0,addr,length" Insert or remove a memory breakpoint.
		case '2': /* write watchpoint */
		case '3': /* read watchpoint */
		case '4': /* access watchpoint */
		{

			SCARTS_ADDR_CTYPE addr,length;
			if (*ptr++ == ','
				&& hexToInt(&ptr, &addr)
				&& *ptr++ == ','
				&& hexToInt(&ptr, &length)) {
				
				if(bp_type == '0') { /* Breakpoint */
					if(addr < SCARTS_CODEMEM_LMA)
						goto bp_error;
					
					addr = (addr - SCARTS_CODEMEM_LMA) / 2;

					if((pkg_type == 'Z' && !bp_add((void*)addr))
						|| (pkg_type == 'z' && !bp_remove((void*)addr)))
						goto bp_error;
				} else { /* Watchpoint */			
					if((pkg_type == 'Z' && !wp_add(bp_type, addr, length))
						|| (pkg_type == 'z' && !wp_remove(bp_type, addr, length)))
						goto bp_error;
				}
			
				*msg_write++ = 'O';
				*msg_write++ = 'K';
			} else {
bp_error:
				*msg_write++ = 'E';
				*msg_write++ = '0';
				*msg_write++ = '2';
			}
			add_chk(chk_start);
			start_send();
		}	
		break;
		default: goto packet_not_supported;
		}
	}
	break;
	
	default:
packet_not_supported:  //Reply: "Not supported"  "+$#00"
		*msg_write++ = '$';
		add_chk(msg_write);
		start_send();
		break;
	}
	
}

static BOOL wp_remove(uint8_t type, REG_TYPE addr, REG_TYPE length) {
	watchpoint_entry_t* wp = watchpoints;
	int i;
	for(i = 0; i < NUM_WATCHPOINTS; ++i, ++wp)
		if(wp->is_used
			&& wp->type == type
			&& wp->address == addr
			&& wp-> length == length) {
			wp->is_used = FALSE;
			WATCHPOINT_CONFIG_C &= ~(0x3<<(i*2));
			return TRUE;
		}
	
	return FALSE;
}

static BOOL wp_add(uint8_t type, REG_TYPE addr, REG_TYPE length) {
	watchpoint_entry_t* wp = watchpoints;
	int i,bitnum;
	for(i = 0; i < NUM_WATCHPOINTS; ++i, ++wp)
		if(!wp->is_used) {
			wp->is_used = TRUE;
			wp->type = type;
			wp->address = addr;
			wp->length = length;

			uint8_t bits = 0;
			switch(type) {
			case '2': bits = 0x2; break; /* write */
			case '3': bits = 0x1; break; /* read */
			case '4': bits = 0x3; break; /* access */
			}
			
			REG_TYPE mask = addr + length - 1;
			mask ^= addr; /* all bits different in start and end address. */
			
			bitnum = SCARTS_WORD_SIZE*8;
			while(bitnum-->0)
				if(mask & (1<<bitnum))
					break; /* Find highest bit that is 1 */
			
			/* Set all lower bits */
			while(bitnum-->0)
				mask |= (1<<bitnum);
						
			*(&(WATCHPOINT_ADDR0) + i) = addr;
			*(&(WATCHPOINT_MASK0) + i) = mask;
			
			WATCHPOINT_CONFIG_C |= bits<<(i*2);
			return TRUE;
		}
	
	return FALSE;
}

static BOOL wp_hit(REG_TYPE addr) {
	watchpoint_entry_t* wp = watchpoints;
	int i;
	for(i = 0; i < NUM_WATCHPOINTS; ++i, ++wp)
		if(wp->is_used
			&& addr >= wp->address
			&& addr < wp->address + wp->length)
			return TRUE;

	return FALSE;
}

		
#define BP_NUM 7
#define BP_START ((void**)(BREAKPOINT_BADDR+4))

static void** bp_find(void* addr){
	
	void** bp_end = BP_START + BREAKPOINT_GET_BP_COUNT(BREAKPOINT_CONFIG_C); 
	void** ptr = BP_START;
	while(ptr < bp_end) {
		if(*ptr == addr)
			return ptr;
		++ptr;
	}
		
	return NULL;
}

static BOOL bp_add(void* addr) {
	int count = BREAKPOINT_GET_BP_COUNT(BREAKPOINT_CONFIG_C);
	if (count >= BP_NUM)
		return FALSE; //BP-Limit exceeded.

	BP_START[count] = addr;
	BREAKPOINT_CONFIG_C = BREAKPOINT_SET_BP_COUNT(BREAKPOINT_CONFIG_C, count + 1);
	return TRUE;
}

static BOOL bp_remove(void* addr) {
	void** ptr = bp_find(addr);
	if(ptr == NULL) //Breakpoint at addr doeesnt exists. 
		return FALSE;
		
	int count = BREAKPOINT_GET_BP_COUNT(BREAKPOINT_CONFIG_C);
	void** bp_end = BP_START + count; 

	while(ptr < bp_end) {
		*ptr = *(ptr + 1);
		++ptr;
	}
	
	BREAKPOINT_CONFIG_C = BREAKPOINT_SET_BP_COUNT(BREAKPOINT_CONFIG_C, count - 1);

	return TRUE;
}




void trap0();
void trap0_c();


asm("trap0:\n");
asm(ASM_SAVE_REG);
asm(ASM_SAVE_FPYZ);
asm(ASM_INIT_STACK);
asm(";call actual interrupt handler\n\
ldhi  r0,4th(trap0_c)\n\
ldliu r0,3rd(trap0_c)\n\
sli   r0,8\n\
ldliu r0,hi(trap0_c)\n\
sli   r0,8\n\
ldliu r0,lo(trap0_c)\n\
jsr r0\n");
asm(ASM_RESTORE_FPYZ);
asm(ASM_RESTORE_REG);
asm("rte;\n");

/* TRAP0. Called when a breakpoint is hit. */
void trap0_c() {
	/* Trap may have been triggered by watchpoint-module. */ 
	if(read_bit(WATCHPOINT_STATUS, WATCHPOINT_STATUS_INT)) {
		/* Int-Ack */
		WATCHPOINT_CONFIG |= (1 << WATCHPOINT_CONFIG_INTA);

		--saved_registers[SCARTS_RTE_REGNUM]; /* Execute the instruction that has been replaced by the TRAP. */
		
		if(!wp_hit(WATCHPOINT_ACCESS_ADDR)) {
			return; /* Watchpoint triggered by an access that didnt fall into watched area. */
		}
	}

	if(recv_state != recv_start) { /* Prevent overwriting of send-buffer. */
		stop_reply_pending = TRUE;
	}else {
		send_stop_reply();
	}

	STOP_HERE();
}

void stub_init() {
	/* When the Remote-stub is entered (by interrupt or trap),
	 * the first task is to save all Register-Values (see ASM_SAVE_REG).
	 * FPX is used as a pointer to the memory.where the registers are stored. 
	 * !!! FPX MUST NEVER BE MODIFIED BY THE DEBUGGED APPLICATION !!! */
	FPX = SCARTS_DATAMEM_SIZE;
		
	/* NO Parity, 1 Stopbits, TrCtrl=1, MsgLength=8 */
	MINI_UART_CFG = 0x07;
	/* Baud Rate 57600 bit/s at 40 MHz */
//	MINI_UART_UBRS_H = 0x2B;
//	MINI_UART_UBRS_L = 0x67;
	//14400 baud
//	MINI_UART_UBRS_H = 0x82;
//	MINI_UART_UBRS_L = 0x35;
	//115200 baud
	MINI_UART_UBRS_H = 0x15;
	MINI_UART_UBRS_L = 0xB3;
	//115200 baud @ 20mhz
//	MINI_UART_UBRS_H = 0x0A;
//	MINI_UART_UBRS_L = 0xDA;

	STVEC(miniuart_isr, DEBUG_INT - 16); //Interrupt-Vectors are stored from -16 to -1.
	STVEC(trap0, -16); // Trap 0. https://trac.ecs.tuwien.ac.at/SCARTS/ticket/3

	sei();

	//Make sure interrupt is not masked by GIM.
	PROC_CTRL_INTMASK &= ~(1<<DEBUG_INT);
	
	BREAKPOINT_CONFIG_C |= (1 << BREAKPOINT_CONFIG_C_EN); //Enable Breakpoints.
	
	uart_recv_mode();
}


