/****************************************************************************/
/*																			*/
/*	Module:			jamstub.c												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997-2000				*/
/*																			*/
/*	Description:	Main source file for stand-alone JAM test utility.		*/
/*																			*/
/*					Supports Altera ByteBlaster hardware download cable		*/
/*					on Windows 95 and Windows NT operating systems.			*/
/*					(A device driver is required for Windows NT.)			*/
/*																			*/
/*					Also supports BitBlaster hardware download cable on		*/
/*					Windows 95, Windows NT, and UNIX platforms.				*/
/*																			*/
/*	Revisions:		1.1	added dynamic memory allocation						*/
/*					1.11 added multi-page memory allocation for file_buffer */
/*                    to permit DOS version to read files larger than 64K   */
/*					1.2 fixed control port initialization for ByteBlaster	*/
/*					2.2 updated usage message, added support for alternate	*/
/*					  cable types, moved porting macros in jamport.h,		*/
/*					  fixed bug in delay calibration code for 16-bit port	*/
/*																			*/
/****************************************************************************/
/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/
/****************************************************************************/
/*																			*/
/*	Andrei Sukhanov v3.2	August: 2014										*/
/*																			*/
/****************************************************************************/
#ifndef NO_ALTERA_STDIO
#define NO_ALTERA_STDIO
#endif

#if ( _MSC_VER >= 800 )
#pragma warning(disable:4115)
#pragma warning(disable:4201)
#pragma warning(disable:4214)
#pragma warning(disable:4514)
#endif

#include "jamport.h"

#if PORT == WINDOWS
#include <windows.h>
#else
typedef int BOOL;
typedef unsigned short WORD;
typedef unsigned long DWORD;
#define TRUE 1
#define FALSE 0
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "io.h"
#include <fcntl.h>
#include <malloc.h>
#include <time.h>
//&RA/#include <conio.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/stat.h>

#if PORT == DOS
#include <bios.h>
#endif

#include "jamexprt.h"

#ifdef FS2
#include "abiactel.h"
#endif

#define WPI 1   //Raspberry Pi P1 pins using WiringPi library
#define JTAGIO WPI

#if JTAGIO == WPI
#include <unistd.h>
#include <ctype.h>
#include <wiringPi.h>
#define WPI_JTAG1_TCK	7	//P1.7
#define WPI_JTAG1_TDO	2	//P1.13
#define	WPI_JTAG1_TMS	0	//P1.11
#define WPI_JTAG1_TDI	1	//P1.12
#define WPI_JTAG2_TCK 3   //P1.15
#define WPI_JTAG2_TDO 6   //P1.22
#define WPI_JTAG2_TMS 4   //P1.16
#define WPI_JTAG2_TDI 5   //P1.18
int	jtag_cable_WPI = 0;
#endif

#if PORT == WINDOWS
#define PGDC_IOCTL_GET_DEVICE_INFO_PP 0x00166A00L
#define PGDC_IOCTL_READ_PORT_PP       0x00166A04L
#define PGDC_IOCTL_WRITE_PORT_PP      0x0016AA08L
#define PGDC_IOCTL_PROCESS_LIST_PP    0x0016AA1CL
#define PGDC_READ_INFO                0x0a80
#define PGDC_READ_PORT                0x0a81
#define PGDC_WRITE_PORT               0x0a82
#define PGDC_PROCESS_LIST             0x0a87
#define PGDC_HDLC_NTDRIVER_VERSION    2
#define PORT_IO_BUFFER_SIZE           256
#endif

#if PORT == WINDOWS
#ifdef __BORLANDC__
/* create dummy inp() and outp() functions for Borland 32-bit compile */
WORD inp(WORD address) { address = address; return(0); }
void outp(WORD address, WORD data) { address = address; data = data; }
#else
#pragma intrinsic (inp, outp)
#endif
#endif

/*
*	For Borland C compiler (16-bit), set the stack size
*/
#if PORT == DOS
#ifdef __BORLANDC__
extern unsigned int _stklen = 50000;
#endif
#endif

/************************************************************************
*
*	Global variables
*/

/* file buffer for JAM input file */
#if PORT == DOS
char **file_buffer = NULL;
#else
char *file_buffer = NULL;
#endif
long file_pointer = 0L;
long file_length = 0L;

/* delay count for one millisecond delay */
long one_ms_delay = 0L;

/* delay count to reduce the maximum TCK frequency */
int tck_delay = 0;

/* serial port interface available on all platforms */
BOOL jtag_hardware_initialized = FALSE;
int reset_jtag = 1;
char *serial_port_name = NULL;
BOOL specified_com_port = FALSE;
int com_port = -1;
void initialize_jtag_hardware(void);
void close_jtag_hardware(void);

#if PORT == WINDOWS || PORT == DOS
/* parallel port interface available on PC only */
BOOL specified_lpt_port = FALSE;
BOOL specified_lpt_addr = FALSE;
int lpt_port = 1;
int initial_lpt_ctrl = 0;
WORD lpt_addr = 0x3bc;
WORD lpt_addr_table[3] = { 0x3bc, 0x378, 0x278 };
BOOL alternative_cable_l = FALSE;
BOOL alternative_cable_x = FALSE;
void write_byteblaster(int port, int data);
int read_byteblaster(int port);
#endif

#if PORT==WINDOWS
#ifndef __BORLANDC__
WORD lpt_addresses_from_registry[4] = { 0 };
#endif
#endif

#if PORT == WINDOWS
/* variables to manage cached I/O under Windows NT */
BOOL windows_nt = FALSE;
int port_io_count = 0;
HANDLE nt_device_handle = INVALID_HANDLE_VALUE;
struct PORT_IO_LIST_STRUCT
{
	USHORT command;
	USHORT data;
} port_io_buffer[PORT_IO_BUFFER_SIZE];
extern void flush_ports(void);
BOOL initialize_nt_driver(void);
#endif

/* function prototypes to allow forward reference */
extern void delay_loop(long count);
//&RA
extern JAM_RETURN_TYPE jam_set_ir_preamble(int count, int start_index, int *data);
extern JAM_RETURN_TYPE jam_set_ir_postamble(int count, int start_index, int *data);
extern JAM_RETURN_TYPE jam_set_dr_preamble(int count, int start_index, int *data);
extern JAM_RETURN_TYPE jam_set_dr_postamble(int count, int start_index, int *data);
/*
*	This structure stores information about each available vector signal
*/
struct VECTOR_LIST_STRUCT
{
	char *signal_name;
	int  hardware_bit;
	int  vector_index;
};

/*
*	Vector signals for ByteBlaster:
*
*	tck (dclk)    = register 0, bit 0
*	tms (nconfig) = register 0, bit 1
*	tdi (data)    = register 0, bit 6
*	tdo (condone) = register 1, bit 7 (inverted!)
*	nstatus       = register 1, bit 4 (not inverted)
*/
struct VECTOR_LIST_STRUCT vector_list[] =
{
	/* add a record here for each vector signal */
	{ "**TCK**",   0, -1 },
	{ "**TMS**",   1, -1 },
	{ "**TDI**",   6, -1 },
	{ "**TDO**",   7, -1 },
	{ "TCK",       0, -1 },
	{ "TMS",       1, -1 },
	{ "TDI",       6, -1 },
	{ "TDO",       7, -1 },
	{ "DCLK",      0, -1 },
	{ "NCONFIG",   1, -1 },
	{ "DATA",      6, -1 },
	{ "CONF_DONE", 7, -1 },
	{ "NSTATUS",   4, -1 }
};

#define VECTOR_SIGNAL_COUNT ((int)(sizeof(vector_list)/sizeof(vector_list[0])))

long verbose = 0;

/************************************************************************
*
*	Customized interface functions for JAM interpreter I/O:
*
*	jam_getc()
*	jam_seek()
*	jam_jtag_io()
*	jam_message()
*	jam_delay()
*/

int jam_getc(void)
{
	int ch = EOF;

	if (file_pointer < file_length)
	{
#if PORT == DOS
		ch = (int) file_buffer[file_pointer >> 14L][file_pointer & 0x3fffL];
		++file_pointer;
#else
		ch = (int) file_buffer[file_pointer++];
#endif
	}

	return (ch);
}

int jam_seek(long offset)
{
	int return_code = EOF;

	if ((offset >= 0L) && (offset < file_length))
	{
		file_pointer = offset;
		return_code = 0;
	}

	return (return_code);
}

int jam_jtag_io(int tms, int tdi, int read_tdo)
{
	int data = 0;
	int tdo = 0;
	int i = 0;
	int result = 0;
	char ch_data = 0;
	
	//printf("io(%1i,%1i,%1i\n",tms,tdi,tdo);//&RA
	if (!jtag_hardware_initialized)
	{
		initialize_jtag_hardware();
		jtag_hardware_initialized = TRUE;
	}

	if (specified_com_port)
	{
		ch_data = (char)
			((tdi ? 0x01 : 0) | (tms ? 0x02 : 0) | 0x60);

		write(com_port, &ch_data, 1);

		if (read_tdo)
		{
			ch_data = 0x7e;
			write(com_port, &ch_data, 1);
			for (i = 0; (i < 100) && (result != 1); ++i)
			{
				result = read(com_port, &ch_data, 1);
			}
			if (result == 1)
			{
				tdo = ch_data & 0x01;
			}
			else
			{
				printf( "Error:  BitBlaster not responding\n");
			}
		}

		ch_data = (char)
			((tdi ? 0x01 : 0) | (tms ? 0x02 : 0) | 0x64);

		write(com_port, &ch_data, 1);
	}
	else
	{
#if PORT == WINDOWS || PORT == DOS
		data = (alternative_cable_l ? ((tdi ? 0x01 : 0) | (tms ? 0x04 : 0)) :
		       (alternative_cable_x ? ((tdi ? 0x01 : 0) | (tms ? 0x04 : 0) | 0x10) :
		       ((tdi ? 0x40 : 0) | (tms ? 0x02 : 0))));

		write_byteblaster(0, data);

		if (read_tdo)
		{
			tdo = read_byteblaster(1);
			tdo = (alternative_cable_l ? ((tdo & 0x40) ? 1 : 0) :
			      (alternative_cable_x ? ((tdo & 0x10) ? 1 : 0) :
			      ((tdo & 0x80) ? 0 : 1)));
		}

		write_byteblaster(0, data | (alternative_cable_l ? 0x02 : (alternative_cable_x ? 0x02: 0x01)));

		write_byteblaster(0, data);
#else
#if JTAGIO == WPI
		data = tdi ? 1 : 0;
		if(jtag_cable_WPI == 0)
		{
			digitalWrite(WPI_JTAG1_TMS,tms);
			digitalWrite(WPI_JTAG1_TDI,data);
			  if (tck_delay != 0) delay_loop(tck_delay);
			digitalWrite(WPI_JTAG1_TCK,1);
			  if (tck_delay != 0) delay_loop(tck_delay);
			tdo = digitalRead(WPI_JTAG1_TDO);
			digitalWrite(WPI_JTAG1_TCK,0);
		}
		else
		{
            digitalWrite(WPI_JTAG2_TMS,tms);
            digitalWrite(WPI_JTAG2_TDI,data);
            digitalWrite(WPI_JTAG2_TCK,1);
            tdo = digitalRead(WPI_JTAG2_TDO);
            digitalWrite(WPI_JTAG2_TCK,0);
		}
		if (verbose&2) printf("tms/i/o=%1i,%1i,%1i\n",tms,data,tdo); //&RA
#else
		/* parallel port interface not available */
		tdo = 0;
#endif	//JTAGIO
#endif
	}

	if (tck_delay != 0) delay_loop(tck_delay);

	return (tdo);
}

void jam_message(char *message_text)
{
	puts(message_text);
	fflush(stdout);
}

void jam_export_integer(char *key, long value)
{
	//&RA140507//if (verbose)
	{
		printf("Export: key = \"%s\", value = %ld\n", key, value);
		fflush(stdout);
	}
}

#define HEX_LINE_CHARS 72
#define HEX_LINE_BITS (HEX_LINE_CHARS * 4)

char conv_to_hex(int value)
{
	char c;

	if (value > 9)
	{
		c = (char) (value + ('A' - 10));
	}
	else
	{
		c = (char) (value + '0');
	}

	return (c);
}

void jam_export_boolean_array(char *key, unsigned char *data, long count)
{
	unsigned int size, line, lines, linebits, value, j, k;
	char string[HEX_LINE_CHARS + 1];
	long i, offset;

	//&RA140507//if (verbose)
	{
		if (count > HEX_LINE_BITS)
		{
			printf("Export: key = \"%s\", %ld bits, value = HEX\n", key, count);
			lines = (unsigned int)
				((count + (HEX_LINE_BITS - 1)) / HEX_LINE_BITS);

			for (line = 0; line < lines; ++line)
			{
				if (line < (lines - 1))
				{
					linebits = HEX_LINE_BITS;
					size = HEX_LINE_CHARS;
					offset = count - ((line + 1) * HEX_LINE_BITS);
				}
				else
				{
					linebits = (unsigned int)
						(count - ((lines - 1) * HEX_LINE_BITS));
					size = (linebits + 3) / 4;
					offset = 0L;
				}

				string[size] = '\0';
				j = size - 1;
				value = 0;

				for (k = 0; k < linebits; ++k)
				{
					i = k + offset;
					if (data[i >> 3] & (1 << (i & 7))) value |= (1 << (i & 3));
					if ((i & 3) == 3)
					{
						string[j] = conv_to_hex(value);
						value = 0;
						--j;
					}
				}
				if ((k & 3) > 0) string[j] = conv_to_hex(value);

				printf("%s\n", string);
			}

			fflush(stdout);
		}
		else
		{
			size = (unsigned int) ((count + 3) / 4);
			string[size] = '\0';
			j = size - 1;
			value = 0;

			for (i = 0; i < count; ++i)
			{
				if (data[i >> 3] & (1 << (i & 7))) value |= (1 << (i & 3));
				if ((i & 3) == 3)
				{
					string[j] = conv_to_hex(value);
					value = 0;
					--j;
				}
			}
			if ((i & 3) > 0) string[j] = conv_to_hex(value);

			printf("Export: key = \"%s\", %ld bits, value = HEX %s\n",
				key, count, string);
			fflush(stdout);
		}
	}
}

void jam_delay(long microseconds)
{
#ifdef FS2
	U32 hz;
	AbiGetTckRate(&hz);
	AbiJtagWait((U32) (1e-6 * microseconds * hz));
#else


#if PORT == WINDOWS
	/* if Windows NT, flush I/O cache buffer before delay loop */
	if (windows_nt && (port_io_count > 0)) flush_ports();
#endif

	delay_loop(microseconds *
		((one_ms_delay / 1000L) + ((one_ms_delay % 1000L) ? 1 : 0)));

#endif
}

int jam_vector_map
(
	int signal_count,
	char **signals
)
{
	int signal, vector, ch_index, diff;
	int matched_count = 0;
	char l, r;

	for (vector = 0; (vector < VECTOR_SIGNAL_COUNT); ++vector)
	{
		vector_list[vector].vector_index = -1;
	}

	for (signal = 0; signal < signal_count; ++signal)
	{
		diff = 1;
		for (vector = 0; (diff != 0) && (vector < VECTOR_SIGNAL_COUNT);
			++vector)
		{
			if (vector_list[vector].vector_index == -1)
			{
				ch_index = 0;
				do
				{
					l = signals[signal][ch_index];
					r = vector_list[vector].signal_name[ch_index];
					diff = (((l >= 'a') && (l <= 'z')) ? (l - ('a' - 'A')) : l)
						- (((r >= 'a') && (r <= 'z')) ? (r - ('a' - 'A')) : r);
					++ch_index;
				}
				while ((diff == 0) && (l != '\0') && (r != '\0'));

				if (diff == 0)
				{
					vector_list[vector].vector_index = signal;
					++matched_count;
				}
			}
		}
	}

	return (matched_count);
}

int jam_vector_io
(
	int signal_count,
	long *dir_vect,
	long *data_vect,
	long *capture_vect
)
{
	int signal, vector, bit;
	int matched_count = 0;
	int data = 0;
	int mask = 0;
	int dir = 0;
	int i = 0;
	int result = 0;
	char ch_data = 0;

	if (!jtag_hardware_initialized)
	{
		initialize_jtag_hardware();
		jtag_hardware_initialized = TRUE;
	}

	/*
	*	Collect information about output signals
	*/
	for (vector = 0; vector < VECTOR_SIGNAL_COUNT; ++vector)
	{
		signal = vector_list[vector].vector_index;

		if ((signal >= 0) && (signal < signal_count))
		{
			bit = (1 << vector_list[vector].hardware_bit);

			mask |= bit;
			if (data_vect[signal >> 5] & (1L << (signal & 0x1f))) data |= bit;
			if (dir_vect[signal >> 5] & (1L << (signal & 0x1f))) dir |= bit;

			++matched_count;
		}
	}

	/*
	*	Write outputs to hardware interface, if any
	*/
	if (dir != 0)
	{
		if (specified_com_port)
		{
			ch_data = (char) (((data >> 6) & 0x01) | (data & 0x02) |
					  ((data << 2) & 0x04) | ((data << 3) & 0x08) | 0x60);
			write(com_port, &ch_data, 1);
		}
		else
		{
#if PORT == WINDOWS || PORT == DOS

			write_byteblaster(0, data);

#endif
		}
	}

	/*
	*	Read the input signals and save information in capture_vect[]
	*/
	if ((dir != mask) && (capture_vect != NULL))
	{
		if (specified_com_port)
		{
			ch_data = 0x7e;
			write(com_port, &ch_data, 1);
			for (i = 0; (i < 100) && (result != 1); ++i)
			{
				result = read(com_port, &ch_data, 1);
			}
			if (result == 1)
			{
				data = ((ch_data << 7) & 0x80) | ((ch_data << 3) & 0x10);
			}
			else
			{
				printf( "Error:  BitBlaster not responding\n");
			}
		}
		else
		{
#if PORT == WINDOWS || PORT == DOS

			data = read_byteblaster(1) ^ 0x80; /* parallel port inverts bit 7 */

#endif
		}

		for (vector = 0; vector < VECTOR_SIGNAL_COUNT; ++vector)
		{
			signal = vector_list[vector].vector_index;

			if ((signal >= 0) && (signal < signal_count))
			{
				bit = (1 << vector_list[vector].hardware_bit);

				if ((dir & bit) == 0)	/* if it is an input signal... */
				{
					if (data & bit)
					{
						capture_vect[signal >> 5] |= (1L << (signal & 0x1f));
					}
					else
					{
						capture_vect[signal >> 5] &= ~(unsigned long)
							(1L << (signal & 0x1f));
					}
				}
			}
		}
	}

	return (matched_count);
}


int jam_set_frequency(long hertz)
{
	if (verbose)
	{
		printf("Frequency: %ld Hz\n", hertz);
		fflush(stdout);
	}

#ifdef FS2
	AbiSetTckRate(hertz);
	if (verbose) {
		U32 h;
		AbiGetTckRate(&h);
		printf("Actual Frequency: %ld Hz\n", h);
	}
#else



	if (hertz == -1)
	{
		/* no frequency limit */
		tck_delay = 0;
	}
	else if (hertz == 0)
	{
		/* stop the clock */
		tck_delay = -1;
	}
	else
	{
		/* set the clock delay to the period */
		/* corresponding to the selected frequency */
		tck_delay = (one_ms_delay * 1000) / hertz;
	}
#endif
	return (0);
}

void *jam_malloc(unsigned int size)
{
	return (malloc(size));
}

void jam_free(void *ptr)
{
	free(ptr);
}
static void io_setup()
{
#if JTAGIO == WPI
    if (wiringPiSetup() == -1)
      printf("ERROR in wiringPiSetup()\n");
    else
    {
		if(jtag_cable_WPI == 0)
		{
			pinMode(WPI_JTAG1_TCK,OUTPUT);
			pinMode(WPI_JTAG1_TMS,OUTPUT);
			pinMode(WPI_JTAG1_TDI,OUTPUT);
			pinMode(WPI_JTAG1_TDO,INPUT);
		}
		else
		{
            pinMode(WPI_JTAG2_TCK,OUTPUT);
            pinMode(WPI_JTAG2_TMS,OUTPUT);
            pinMode(WPI_JTAG2_TDI,OUTPUT);
            pinMode(WPI_JTAG2_TDO,INPUT);
		}
    }
    if (verbose&4) printf("IO setup\n");
#endif
}
static void io_shutdown(void)
{
#if JTAGIO == WPI
    if(reset_jtag)
    {
	if(jtag_cable_WPI == 0)
	{
    	pinMode (WPI_JTAG1_TCK,INPUT);
    	pinMode (WPI_JTAG1_TMS,INPUT);
    	pinMode (WPI_JTAG1_TDI,INPUT);
    	pinMode (WPI_JTAG1_TDO,INPUT);
	}
	else
	{
	    pinMode (WPI_JTAG2_TCK,INPUT);
        pinMode (WPI_JTAG2_TMS,INPUT);
        pinMode (WPI_JTAG2_TDI,INPUT);
        pinMode (WPI_JTAG2_TDO,INPUT);
	}
    if (verbose&4) printf("IO shutdown\n");
    }
#endif
}

/************************************************************************
*
*	get_tick_count() -- Get system tick count in milliseconds
*
*	for DOS, use BIOS function _bios_timeofday()
*	for WINDOWS use GetTickCount() function
*	for UNIX use clock() system function
*/
DWORD get_tick_count(void)
{
	DWORD tick_count = 0L;

#if PORT == WINDOWS
	tick_count = GetTickCount();
#elif PORT == DOS
	_bios_timeofday(_TIME_GETCLOCK, (long *)&tick_count);
	tick_count *= 55L;	/* convert to milliseconds */
#else
	/* assume clock() function returns microseconds */
	//&RA//tick_count = (DWORD) (clock() / 1000L);
	//clock_t	clk;
	//DWORD clk_per_ms = CLOCKS_PER_SEC/1000L;
	//clk = clock();
	tick_count = (DWORD) (clock() / (CLOCKS_PER_SEC/1000L));
#endif

	return (tick_count);
}

#define DELAY_SAMPLES 10
#define DELAY_CHECK_LOOPS 10000

void calibrate_delay(void)
{
	int sample = 0;
	int count = 0;
	DWORD tick_count1 = 0L;
	DWORD tick_count2 = 0L;

	one_ms_delay = 0L;

//#if PORT == WINDOWS || PORT == DOS
	for (sample = 0; sample < DELAY_SAMPLES; ++sample)
	{
		count = 0;
		tick_count1 = get_tick_count();
		while ((tick_count2 = get_tick_count()) == tick_count1) {};
		do { delay_loop(DELAY_CHECK_LOOPS); count++; } while
			((tick_count1 = get_tick_count()) == tick_count2);
		one_ms_delay += ((DELAY_CHECK_LOOPS * (DWORD)count) /
			(tick_count1 - tick_count2));
	}

	one_ms_delay /= DELAY_SAMPLES;
	//if(verbose)
	//{
	//	printf("Checking calibrated delay for 10 s\n");
	//	delay_loop(10000*one_ms_delay);
	//	printf("10s passed\n");
	//}
//#else
//	one_ms_delay = 1000L;
//#endif
}

char *error_text[] =
{
/* JAMC_SUCCESS            0 */ "success",
/* JAMC_OUT_OF_MEMORY      1 */ "out of memory",
/* JAMC_IO_ERROR           2 */ "file access error",
/* JAMC_SYNTAX_ERROR       3 */ "syntax error",
/* JAMC_UNEXPECTED_END     4 */ "unexpected end of file",
/* JAMC_UNDEFINED_SYMBOL   5 */ "undefined symbol",
/* JAMC_REDEFINED_SYMBOL   6 */ "redefined symbol",
/* JAMC_INTEGER_OVERFLOW   7 */ "integer overflow",
/* JAMC_DIVIDE_BY_ZERO     8 */ "divide by zero",
/* JAMC_CRC_ERROR          9 */ "CRC mismatch",
/* JAMC_INTERNAL_ERROR    10 */ "internal error",
/* JAMC_BOUNDS_ERROR      11 */ "bounds error",
/* JAMC_TYPE_MISMATCH     12 */ "type mismatch",
/* JAMC_ASSIGN_TO_CONST   13 */ "assignment to constant",
/* JAMC_NEXT_UNEXPECTED   14 */ "NEXT unexpected",
/* JAMC_POP_UNEXPECTED    15 */ "POP unexpected",
/* JAMC_RETURN_UNEXPECTED 16 */ "RETURN unexpected",
/* JAMC_ILLEGAL_SYMBOL    17 */ "illegal symbol name",
/* JAMC_VECTOR_MAP_FAILED 18 */ "vector signal name not found",
/* JAMC_USER_ABORT        19 */ "execution cancelled",
/* JAMC_STACK_OVERFLOW    20 */ "stack overflow",
/* JAMC_ILLEGAL_OPCODE    21 */ "illegal instruction code",
/* JAMC_PHASE_ERROR       22 */ "phase error",
/* JAMC_SCOPE_ERROR       23 */ "scope error",
/* JAMC_ACTION_NOT_FOUND  24 */ "action not found",
};

#define MAX_ERROR_CODE (int)((sizeof(error_text)/sizeof(error_text[0]))+1)

/************************************************************************/

int main(int argc, char **argv)
{
	BOOL help = FALSE;
	BOOL error = FALSE;
	char *filename = NULL;
	long offset = 0L;
	long error_line = 0L;
	JAM_RETURN_TYPE crc_result = JAMC_SUCCESS;
	JAM_RETURN_TYPE exec_result = JAMC_SUCCESS;
	unsigned short expected_crc = 0;
	unsigned short actual_crc = 0;
	char key[33] = {0};
	char value[257] = {0};
	int exit_status = 0;
	int arg = 0;
	int exit_code = 0;
	int format_version = 0;
	time_t start_time = 0;
	time_t end_time = 0;
	int time_delta = 0;
	char *workspace = NULL;
	char *action = NULL;
	int interactive = 0;
	char action_string[80];
	char *init_list[10];
	int init_count = 0;
	FILE *fp = NULL;
	struct stat sbuf;
	long workspace_size = 0;
	char *exit_string = NULL;
	//int reset_jtag = 1;
	int tms,tdi,tdo;

	verbose = FALSE;

	init_list[0] = NULL;

	for (arg = 1; arg < argc; arg++)
	{
#if PORT == UNIX
		if (argv[arg][0] == '-')
#else
		if ((argv[arg][0] == '-') || (argv[arg][0] == '/'))
#endif
		{
			switch(toupper(argv[arg][1]))
			{
			case 'A':				/* set action name */
				action = &argv[arg][2];
				if (action[0] == '"') ++action;
				break;

#if PORT == WINDOWS || PORT == DOS
			case 'C':				/* Use alternative ISP download cable */
				if(toupper(argv[arg][2]) == 'L')
					alternative_cable_l = TRUE;
				else if(toupper(argv[arg][2]) == 'X')
					alternative_cable_x = TRUE;
				break;
#endif

			case 'D':				/* initialization list */
				if (argv[arg][2] == '"')
				{
					init_list[init_count] = &argv[arg][3];
				}
				else
				{
					init_list[init_count] = &argv[arg][2];
				}
				init_list[++init_count] = NULL;
				break;

#if PORT == WINDOWS || PORT == DOS
			case 'P':				/* set LPT port address */
				specified_lpt_port = TRUE;
				if (sscanf(&argv[arg][2], "%d", &lpt_port) != 1) error = TRUE;
				if ((lpt_port < 1) || (lpt_port > 3)) error = TRUE;
				if (error)
				{
					if (sscanf(&argv[arg][2], "%x", &lpt_port) == 1)
					{
						if ((lpt_port == 0x278) ||
							(lpt_port == 0x27c) ||
							(lpt_port == 0x378) ||
							(lpt_port == 0x37c) ||
							(lpt_port == 0x3b8) ||
							(lpt_port == 0x3bc))
						{
							error = FALSE;
							specified_lpt_addr = TRUE;
							lpt_addr = (WORD) lpt_port;
							lpt_port = 1;
						}
					}
				}
				break;
#endif

			case 'R':		/* don't reset the JTAG chain after use */
				reset_jtag = 0;
				break;

			case 'S':				/* set serial port address */
				serial_port_name = &argv[arg][2];
				specified_com_port = TRUE;
				break;

			case 'M':				/* set memory size */
				if (sscanf(&argv[arg][2], "%ld", &workspace_size) != 1)
					error = TRUE;
				if (workspace_size == 0) error = TRUE;
				break;

			case 'H':				/* help */
				help = TRUE;
				break;

			case 'V':				/* verbose */
				if (sscanf(&argv[arg][2], "%ld", &verbose) != 1)
				{
                                        verbose = 1;
        /* print out the version string and coiyright message */
        printf("STAPL Player Version 3.2\n");
        printf("Ported to RPi from Jam STAPL Player Version 2.2\nCopyright (C) 1997-2000 Altera Corporation\n");
				}
				break;

			case 'J':
				tms = (argv[arg][2]=='1') ? 1 : 0;
                                tdi = (argv[arg][3]=='1') ? 1 : 0;
				tdo = jam_jtag_io(tms,tdi,1);
                                printf("TDO(%i,%i)=%d\n",tms,tdi,tdo);
				break;
			case 'P':
				sscanf(&argv[arg][4],"%d",&tdo);//get numerical value
				if (argv[arg][2]=='e')
				{
					if (argv[arg][3]=='i')
						jam_set_ir_preamble(tdo,0,0);
					else if (argv[arg][3]=='d')
						jam_set_dr_preamble(tdo,0,0);
				}
				else if (argv[arg][2]=='o')
				{
                    if (argv[arg][3]=='i')
						jam_set_ir_postamble(tdo,0,0);
                    else if (argv[arg][3]=='d')
						jam_set_dr_postamble(tdo,0,0);
				}
				else
				{
					printf("Wrong PRE/POST syntax\n");
					error = TRUE;
				}
				break;
#if JTAGIO == WPI
			case 'G':
				jtag_cable_WPI = 1;
				break;
#endif
			case 'I':
				interactive = 1;
				break;
			default:
				error = TRUE;
				break;
			}
		}
		else
		{
			/* it's a filename */
			if (filename == NULL)
			{
				filename = argv[arg];
			}
			else
			{
				/* error -- we already found a filename */
				error = TRUE;
			}
		}

		if (error)
		{
			printf( "Illegal argument: \"%s\"\n", argv[arg]);
			help = TRUE;
			error = FALSE;
		}
	}

#if PORT == WINDOWS || PORT == DOS
	if (specified_lpt_port && specified_com_port)
	{
		printf( "Error:  -s and -p options may not be used together\n\n");
		help = TRUE;
	}
#endif

	if (help)
	{
		printf( "Usage:  stapl player [options] <filename>\n");
		printf( "\nAvailable options:\n");
		printf( "    -h          : show help message\n");
		printf( "    -v          : show verbose messages\n");
		printf( "    -a<action>  : specify action name (Jam STAPL)\n");
		printf( "    -d<var=val> : initialize variable to specified value (Jam 1.1)\n");
		printf( "    -d<proc=1>  : enable optional procedure (Jam STAPL)\n");
		printf( "    -d<proc=0>  : disable recommended procedure (Jam STAPL)\n");
#if PORT == WINDOWS || PORT == DOS
		printf( "    -p<port>    : parallel port number or address (for ByteBlaster)\n");
		printf( "    -c<cable>   : alternative download cable compatibility: -cl or -cx\n");
#endif
		printf( "    -s<port>    : serial port name (for BitBlaster)\n");
		printf( "    -r          : don't reset JTAG TAP after use\n");
		//&RA
		printf( "    -j<TMS><TDI>: execute JTAG cycle with TMS and TDI\n");
        printf( "    -p(e/o)(i/d) val; set (PRE/POST)(IR/DR) chain parameter:\n");
#if JTAGIO == WPI
        printf( "    -g			 : use alternative GPIO set (WPI_JTAG2_xxx)\n");
#endif
		exit_status = 1;
	}
	if(filename == NULL)	
		exit_status = 1;
	else if ((workspace_size > 0) &&
		((workspace = (char *) malloc((size_t) workspace_size)) == NULL))
	{
		printf( "Error: can't allocate memory (%d Kbytes)\n",
			(int) (workspace_size / 1024L));
		exit_status = 1;
	}
	else if (access(filename, 0) != 0)
	{
		printf( "Error: can't access file \"%s\"\n", filename);
		exit_status = 1;
	}
	else
	{
		/* get length of file */
		if (stat(filename, &sbuf) == 0) file_length = sbuf.st_size;

		if ((fp = fopen(filename, "rb")) == NULL)
		{
			printf( "Error: can't open file \"%s\"\n", filename);
			exit_status = 1;
		}
		else
		{
			/*
			*	Read entire file into a buffer
			*/
#if PORT == DOS
			int pages = 1 + (int) (file_length >> 14L);
			int page;
			file_buffer = (char **) malloc((size_t) (pages * sizeof(char *)));
			for (page = 0; page < pages; ++page)
			{
				/* allocate enough 16K blocks to store the file */
				file_buffer[page] = (char *) malloc (0x4000);
				if (file_buffer[page] == NULL)
				{
					/* flag error and break out of loop */
					file_buffer = NULL;
					page = pages;
				}
			}
#else
			file_buffer = (char *) malloc((size_t) file_length);
#endif
			if (file_buffer == NULL)
			{
				printf( "Error: can't allocate memory (%d Kbytes)\n",
					(int) (file_length / 1024L));
				exit_status = 1;
			}
			else
			{
#if PORT == DOS
				int pages = 1 + (int) (file_length >> 14L);
				int page;
				size_t page_size = 0x4000;
				for (page = 0; (page < pages) && (exit_status == 0); ++page)
				{
					if (page == (pages - 1))
					{
						/* last page may not be full 16K bytes */
						page_size = (size_t) (file_length & 0x3fffL);
					}
					if (fread(file_buffer[page], 1, page_size, fp) != page_size)
					{
						printf( "Error reading file \"%s\"\n", filename);
						exit_status = 1;
					}
				}
#else
				if (fread(file_buffer, 1, (size_t) file_length, fp) !=
					(size_t) file_length)
				{
					printf( "Error reading file \"%s\"\n", filename);
					exit_status = 1;
				}
#endif
			}

			fclose(fp);
		}

		if (exit_status == 0)
		{
			/*
			*	Get Operating System type
			*/
#if PORT == WINDOWS
			windows_nt = !(GetVersion() & 0x80000000);
#endif

			/*
			*	Calibrate the delay loop function
			*/
			calibrate_delay();

			/*
			*	Check CRC
			*/
			crc_result = jam_check_crc(
#if PORT==DOS
				0L, 0L,
#else
				file_buffer, file_length,
#endif
				&expected_crc, &actual_crc);

			if (verbose || (crc_result == JAMC_CRC_ERROR))
			{
				switch (crc_result)
				{
				case JAMC_SUCCESS:
					printf("CRC matched: CRC value = %04X\n", actual_crc);
					break;

				case JAMC_CRC_ERROR:
					printf("CRC mismatch: expected %04X, actual %04X\n",
						expected_crc, actual_crc);
					break;

				case JAMC_UNEXPECTED_END:
					printf("Expected CRC not found, actual CRC value = %04X\n",
						actual_crc);
					break;

				default:
					printf("CRC function returned error code %d\n", crc_result);
					break;
				}
			}

			/*
			*	Dump out NOTE fields
			*/
			if (verbose)
			{
				while (jam_get_note(
#if PORT==DOS
					0L, 0L,
#else
					file_buffer, file_length,
#endif
					&offset, key, value, 256) == 0)
				{
					printf("NOTE \"%s\" = \"%s\"\n", key, value);
				}
			}


#ifdef FS2
			{ HRESULT h;
			h=AbiInit();
			h=AbiOpenPort("lpt1");
			if (h == GOOD) {
				h=AbiSetSupply(ABI_VDDP, ABI_POWER, 2500);
				if (h == GOOD) {
					//h=AbiSetSupply(ABI_VDDL, ABI_GROUND, 2500);//ProASIC;
					h=AbiSetSupply(ABI_VDDL, ABI_POWER, 2500);//ProASICplus;
					if (h == GOOD) {
						//h=AbiSetSupply(ABI_VPP, ABI_POWER, 16500);//ProASIC;
						h=AbiSetSupply(ABI_VPP, ABI_POWER, 16200);//ProASICplus;
						if (h == GOOD) {
							//h=AbiSetSupply(ABI_VPN, ABI_POWER, -12000);//ProASIC;
							h=AbiSetSupply(ABI_VPN, ABI_POWER, -13600);//ProASICplus;
						}
					}
				}
			}

			if (h != GOOD) {
					printf("FS2 error = %lu\n", h);
					exit(1);
			}
			}
#endif


			/*
			*	Execute the JAM program
			*/
			while(1)
			{
			if(interactive)
			{
			  printf("Enter action:");
			  if(fgets(action_string,80,stdin) == NULL)
			    strcpy(action_string," ");
			  action_string[strlen(action_string)-1]=0; //trim the newline
			  action = action_string;
			}
			time(&start_time);
			exec_result = jam_execute(
#if PORT==DOS
				0L, 0L,
#else
				file_buffer, file_length,
#endif
				workspace, workspace_size, action, init_list,
				reset_jtag, &error_line, &exit_code, &format_version);
			time(&end_time);

#ifdef FS2
			{ HRESULT h;

			h=AbiSetSupply(ABI_VPN, ABI_HIZ, -13600);//ProASICplus;
			h=AbiSetSupply(ABI_VPP, ABI_HIZ, 16200);//ProASICplus;
//			h=AbiSetSupply(ABI_VPN, ABI_HIZ, -12000);//ProASIC;
//			h=AbiSetSupply(ABI_VPP, ABI_HIZ, 16500);//ProASIC;
			h=AbiSetSupply(ABI_VDDP, ABI_HIZ, 2500);
			h=AbiSetSupply(ABI_VDDL, ABI_HIZ, 2500);
			h=AbiCleanup();			
			}
#endif


			if (exec_result == JAMC_SUCCESS)
			{
				if (format_version == 2)
				{
					switch (exit_code)
					{
					case  0: exit_string = "Success"; break;
					case  1: exit_string = "Checking chain failure"; break;
					case  2: exit_string = "Reading IDCODE failure"; break;
					case  3: exit_string = "Reading USERCODE failure"; break;
					case  4: exit_string = "Reading UESCODE failure"; break;
					case  5: exit_string = "Entering ISP failure"; break;
					case  6: exit_string = "Unrecognized device"; break;
					case  7: exit_string = "Device revision is not supported"; break;
					case  8: exit_string = "Erase failure"; break;
					case  9: exit_string = "Device is not blank"; break;
					case 10: exit_string = "Device programming failure"; break;
					case 11: exit_string = "Device verify failure"; break;
					case 12: exit_string = "Read failure"; break;
					case 13: exit_string = "Calculating checksum failure"; break;
					case 14: exit_string = "Setting security bit failure"; break;
					case 15: exit_string = "Querying security bit failure"; break;
					case 16: exit_string = "Exiting ISP failure"; break;
					case 17: exit_string = "Performing system test failure"; break;
					default: exit_string = "Unknown exit code"; break;
					}
				}
				else
				{
					switch (exit_code)
					{
					case 0: exit_string = "Success"; break;
					case 1: exit_string = "Illegal initialization values"; break;
					case 2: exit_string = "Unrecognized device"; break;
					case 3: exit_string = "Device revision is not supported"; break;
					case 4: exit_string = "Device programming failure"; break;
					case 5: exit_string = "Device is not blank"; break;
					case 6: exit_string = "Device verify failure"; break;
					case 7: exit_string = "SRAM configuration failure"; break;
					default: exit_string = "Unknown exit code"; break;
					}
				}

				printf("Exit code = %d... %s\n", exit_code, exit_string);
			}
			else if ((format_version == 2) &&
				(exec_result == JAMC_ACTION_NOT_FOUND))
			{
				if ((action == NULL) || (*action == '\0'))
				{
					printf("Error: no action specified for Jam file.\nProgram terminated.\n");
				}
				else
				{
					printf("Error: action \"%s\" is not supported for this Jam file.\nProgram terminated.\n", action);
				}
			}
			else if (exec_result < MAX_ERROR_CODE)
			{
				printf("Error on line %ld: %s.\nProgram terminated.\n",
					error_line, error_text[exec_result]);
			}
			else
			{
				printf("Unknown error code %d\n", exec_result);
			}

			/*
			*	Print out elapsed time
			*/
			if (verbose || 1)
			{
				time_delta = (int) (end_time - start_time);
				printf("Elapsed time = %02u:%02u:%02u\n",
					time_delta / 3600,			/* hours */
					(time_delta % 3600) / 60,	/* minutes */
					time_delta % 60);			/* seconds */
			}
			if(!interactive)	break;
			}
		}
	}

	if (jtag_hardware_initialized) close_jtag_hardware();

	if (workspace != NULL) free(workspace);
	if (file_buffer != NULL) free(file_buffer);

	return (exit_status);
}

#if PORT==WINDOWS
#ifndef __BORLANDC__
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*	SEARCH_DYN_DATA
*
*	Searches recursively in Windows 95/98 Registry for parallel port info
*	under HKEY_DYN_DATA registry key.  Called by search_local_machine().
*/
void search_dyn_data
(
	char *dd_path,
	char *hardware_key,
	int lpt
)
{
	DWORD index;
	DWORD size;
	DWORD type;
	LONG result;
	HKEY key;
	int length;
	WORD address;
	char buffer[1024];
	FILETIME last_write = {0};
	WORD *word_ptr;
	int i;

	length = strlen(dd_path);

	if (RegOpenKeyEx(
		HKEY_DYN_DATA,
		dd_path,
		0L,
		KEY_READ,
		&key)
		== ERROR_SUCCESS)
	{
		size = 1023;

		if (RegQueryValueEx(
			key,
			"HardWareKey",
			NULL,
			&type,
			(unsigned char *) buffer,
			&size)
			== ERROR_SUCCESS)
		{
			if ((type == REG_SZ) && (stricmp(buffer, hardware_key) == 0))
			{
				size = 1023;

				if (RegQueryValueEx(
					key,
					"Allocation",
					NULL,
					&type,
					(unsigned char *) buffer,
					&size)
					== ERROR_SUCCESS)
				{
					/*
					*	By "inspection", I have found five cases: size 32, 48,
					*	56, 60, and 80 bytes.  The port address seems to be
					*	located at different offsets in the buffer for these
					*	five cases, as shown below.  If a valid port address
					*	is not found, or the size is not one of these known
					*	sizes, then I search through the entire buffer and
					*	look for a value which is a valid port address.
					*/

					word_ptr = (WORD *) buffer;

					if ((type == REG_BINARY) && (size == 32))
					{
						address = word_ptr[10];
					}
					else if ((type == REG_BINARY) && (size == 48))
					{
						address = word_ptr[18];
					}
					else if ((type == REG_BINARY) && (size == 56))
					{
						address = word_ptr[22];
					}
					else if ((type == REG_BINARY) && (size == 60))
					{
						address = word_ptr[24];
					}
					else if ((type == REG_BINARY) && (size == 80))
					{
						address = word_ptr[24];
					}
					else address = 0;

					/* if not found, search through entire buffer */
					i = 0;
					while ((i < (int) (size / 2)) &&
						(address != 0x278) &&
						(address != 0x27C) &&
						(address != 0x378) &&
						(address != 0x37C) &&
						(address != 0x3B8) &&
						(address != 0x3BC))
					{
						if ((word_ptr[i] == 0x278) ||
							(word_ptr[i] == 0x27C) ||
							(word_ptr[i] == 0x378) ||
							(word_ptr[i] == 0x37C) ||
							(word_ptr[i] == 0x3B8) ||
							(word_ptr[i] == 0x3BC))
						{
							address = word_ptr[i];
						}
						++i;
					}

					if ((address == 0x278) ||
						(address == 0x27C) ||
						(address == 0x378) ||
						(address == 0x37C) ||
						(address == 0x3B8) ||
						(address == 0x3BC))
					{
						lpt_addresses_from_registry[lpt] = address;
					}
				}
			}
		}

		index = 0;

		do
		{
			size = 1023;

			result = RegEnumKeyEx(
				key,
				index++,
				buffer,
				&size,
				NULL,
				NULL,
				NULL,
				&last_write);

			if (result == ERROR_SUCCESS)
			{
				dd_path[length] = '\\';
				dd_path[length + 1] = '\0';
				strcpy(&dd_path[length + 1], buffer);

				search_dyn_data(dd_path, hardware_key, lpt);
	
				dd_path[length] = '\0';
			}
		}
		while (result == ERROR_SUCCESS);

		RegCloseKey(key);
	}
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*	SEARCH_LOCAL_MACHINE
*
*	Searches recursively in Windows 95/98 Registry for parallel port info
*	under HKEY_LOCAL_MACHINE\Enum.  When parallel port is found, calls
*	search_dyn_data() to get the port address.
*/
void search_local_machine
(
	char *lm_path,
	char *dd_path
)
{
	DWORD index;
	DWORD size;
	DWORD type;
	LONG result;
	HKEY key;
	int length;
	char buffer[1024];
	FILETIME last_write = {0};

	length = strlen(lm_path);

	if (RegOpenKeyEx(
		HKEY_LOCAL_MACHINE,
		lm_path,
		0L,
		KEY_READ,
		&key)
		== ERROR_SUCCESS)
	{
		size = 1023;

		if (RegQueryValueEx(
			key,
			"PortName",
			NULL,
			&type,
			(unsigned char *) buffer,
			&size)
			== ERROR_SUCCESS)
		{
			if ((type == REG_SZ) &&
				(size == 5) &&
				(buffer[0] == 'L') &&
				(buffer[1] == 'P') &&
				(buffer[2] == 'T') &&
				(buffer[3] >= '1') &&
				(buffer[3] <= '4') &&
				(buffer[4] == '\0'))
			{
				/* we found the entry in HKEY_LOCAL_MACHINE, now we need to */
				/* find the corresponding entry under HKEY_DYN_DATA.  */
				/* add 5 to lm_path to skip over "Enum" and backslash */
				search_dyn_data(dd_path, &lm_path[5], (buffer[3] - '1'));
			}
		}

		index = 0;

		do
		{
			size = 1023;

			result = RegEnumKeyEx(
				key,
				index++,
				buffer,
				&size,
				NULL,
				NULL,
				NULL,
				&last_write);

			if (result == ERROR_SUCCESS)
			{
				lm_path[length] = '\\';
				lm_path[length + 1] = '\0';
				strcpy(&lm_path[length + 1], buffer);

				search_local_machine(lm_path, dd_path);
	
				lm_path[length] = '\0';
			}
		}
		while (result == ERROR_SUCCESS);

		RegCloseKey(key);
	}
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
*	GET_LPT_ADDRESSES_FROM_REGISTRY
*
*	Searches Win95/98 registry recursively to get I/O port addresses for
*	parallel ports.
*/
void get_lpt_addresses_from_registry()
{
	char lm_path[1024];
	char dd_path[1024];

	strcpy(lm_path, "Enum");
	strcpy(dd_path, "Config Manager");
	search_local_machine(lm_path, dd_path);
}
#endif
#endif

void initialize_jtag_hardware()
{
#ifdef JTAGIO
	io_setup();
#else
	if (specified_com_port)
	{
		com_port = open(serial_port_name, O_RDWR);
		if (com_port == -1)
		{
			printf( "Error: can't open serial port \"%s\"\n",
				serial_port_name);
		}
		else
		{
			int i = 0, result = 0;
			char data = 0;

			data = 0x7e;
			write(com_port, &data, 1);

			for (i = 0; (i < 100) && (result != 1); ++i)
			{
				result = read(com_port, &data, 1);
			}

			if (result == 1)
			{
				data = 0x70; write(com_port, &data, 1); /* TDO echo off */
				data = 0x72; write(com_port, &data, 1); /* auto LEDs off */
				data = 0x74; write(com_port, &data, 1); /* ERROR LED off */
				data = 0x76; write(com_port, &data, 1); /* DONE LED off */
				data = 0x60; write(com_port, &data, 1); /* signals low */
			}
			else
			{
				printf( "Error: BitBlaster is not responding on %s\n",
					serial_port_name);
				close(com_port);
				com_port = -1;
			}
		}
	}
	else
	{
#if PORT == WINDOWS || PORT == DOS

#if PORT == WINDOWS
		if (windows_nt)
		{
			initialize_nt_driver();
		}
		else
		{
#ifdef __BORLANDC__
			printf( "Error: parallel port access is not available\n");
#else
			if (!specified_lpt_addr)
			{
				get_lpt_addresses_from_registry();

				lpt_addr = 0;

				if (specified_lpt_port)
				{
					lpt_addr = lpt_addresses_from_registry[lpt_port - 1];
				}

				if (lpt_addr == 0)
				{
					if (lpt_addresses_from_registry[3] != 0)
						lpt_addr = lpt_addresses_from_registry[3];
					if (lpt_addresses_from_registry[2] != 0)
						lpt_addr = lpt_addresses_from_registry[2];
					if (lpt_addresses_from_registry[1] != 0)
						lpt_addr = lpt_addresses_from_registry[1];
					if (lpt_addresses_from_registry[0] != 0)
						lpt_addr = lpt_addresses_from_registry[0];
				}

				if (lpt_addr == 0)
				{
					if (specified_lpt_port)
					{
						lpt_addr = lpt_addr_table[lpt_port - 1];
					}
					else
					{
						lpt_addr = lpt_addr_table[0];
					}
				}
			}
			initial_lpt_ctrl = windows_nt ? 0x0c : read_byteblaster(2);
#endif
		}
#endif

#if PORT == DOS
		/*
		*	Read word at specific memory address to get the LPT port address
		*/
		WORD *bios_address = (WORD *) 0x00400008;

		if (!specified_lpt_addr)
		{
			lpt_addr = bios_address[lpt_port - 1];

			if ((lpt_port != 0x278) &&
				(lpt_port != 0x27c) &&
				(lpt_port != 0x378) &&
				(lpt_port != 0x37c) &&
				(lpt_port != 0x3b8) &&
				(lpt_port != 0x3bc))
			{
				lpt_addr = lpt_addr_table[lpt_port - 1];
			}
		}
		initial_lpt_ctrl = read_byteblaster(2);
#endif

		/* set AUTO-FEED low to enable ByteBlaster (value to port inverted) */
		/* set DIRECTION low for data output from parallel port */
		write_byteblaster(2, (initial_lpt_ctrl | 0x02) & 0xDF);
#endif
	}
#endif //JTAGIO
}

void close_jtag_hardware()
{
#ifdef JTAGIO
    io_shutdown();
#else
	if (specified_com_port)
	{
		if (com_port != -1) close(com_port);
	}
	else
	{
#if PORT == WINDOWS || PORT == DOS
		/* set AUTO-FEED high to disable ByteBlaster */
		write_byteblaster(2, initial_lpt_ctrl & 0xfd);

#if PORT == WINDOWS
		if (windows_nt && (nt_device_handle != INVALID_HANDLE_VALUE))
		{
			if (port_io_count > 0) flush_ports();

			CloseHandle(nt_device_handle);
		}
#endif
#endif
	}
#endif //JTAGIO
}

#if PORT == WINDOWS
/**************************************************************************/
/*                                                                        */

BOOL initialize_nt_driver()

/*                                                                        */
/*  Uses CreateFile() to open a connection to the Windows NT device       */
/*  driver.                                                               */
/*                                                                        */
/**************************************************************************/
{
	BOOL status = FALSE;

	ULONG buffer[1];
	ULONG returned_length = 0;
	char nt_lpt_str[] = { '\\', '\\', '.', '\\',
		'A', 'L', 'T', 'L', 'P', 'T', '1', '\0' };


	nt_lpt_str[10] = (char) ('1' + (lpt_port - 1));

	nt_device_handle = CreateFile(
		nt_lpt_str,
		GENERIC_READ | GENERIC_WRITE,
		0,
		NULL,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL,
		NULL);

	if (nt_device_handle == INVALID_HANDLE_VALUE)
	{
		printf(
			"I/O error:  cannot open device %s\nCheck port number and device driver installation",
			nt_lpt_str);
	}
	else
	{
		if (DeviceIoControl(
			nt_device_handle,			/* Handle to device */
			PGDC_IOCTL_GET_DEVICE_INFO_PP,	/* IO Control code */
			(ULONG *)NULL,					/* Buffer to driver. */
			0,								/* Length of buffer in bytes. */
			&buffer,						/* Buffer from driver. */
			sizeof(ULONG),					/* Length of buffer in bytes. */
			&returned_length,				/* Bytes placed in data_buffer. */
			NULL))							/* Wait for operation to complete */
		{
			if (returned_length == sizeof(ULONG))
			{
				if (buffer[0] == PGDC_HDLC_NTDRIVER_VERSION)
				{
					status = TRUE;
				}
				else
				{
					printf(
						"I/O error:  device driver %s is not compatible\n(Driver version is %lu, expected version %lu.\n",
						nt_lpt_str,
						(unsigned long) buffer[0],
						(unsigned long) PGDC_HDLC_NTDRIVER_VERSION);
				}
			}
			else
			{
				printf( "I/O error:  device driver %s is not compatible.\n",
					nt_lpt_str);
			}
		}

		if (!status)
		{
			CloseHandle(nt_device_handle);
			nt_device_handle = INVALID_HANDLE_VALUE;
		}
	}

	if (!status)
	{
		/* error message already given */
		exit(1);
	}

	return (status);
}
#endif

#if PORT == WINDOWS || PORT == DOS
/**************************************************************************/
/*                                                                        */

void write_byteblaster
(
	int port,
	int data
)

/*                                                                        */
/**************************************************************************/
{
#if PORT == WINDOWS
	BOOL status = FALSE;

	int returned_length = 0;
	int buffer[2];


	if (windows_nt)
	{
		/*
		*	On Windows NT, access hardware through device driver
		*/
		if (port == 0)
		{
			port_io_buffer[port_io_count].data = (USHORT) data;
			port_io_buffer[port_io_count].command = PGDC_WRITE_PORT;
			++port_io_count;

			if (port_io_count >= PORT_IO_BUFFER_SIZE) flush_ports();
		}
		else
		{
			if (port_io_count > 0) flush_ports();

			buffer[0] = port;
			buffer[1] = data;

			status = DeviceIoControl(
				nt_device_handle,			/* Handle to device */
				PGDC_IOCTL_WRITE_PORT_PP,	/* IO Control code for write */
				(ULONG *)&buffer,			/* Buffer to driver. */
				2 * sizeof(int),			/* Length of buffer in bytes. */
				(ULONG *)NULL,				/* Buffer from driver.  Not used. */
				0,							/* Length of buffer in bytes. */
				(ULONG *)&returned_length,	/* Bytes returned.  Should be zero. */
				NULL);						/* Wait for operation to complete */

			if ((!status) || (returned_length != 0))
			{
				printf( "I/O error:  Cannot access ByteBlaster hardware\n");
				CloseHandle(nt_device_handle);
				exit(1);
			}
		}
	}
	else
#endif
	{
		/*
		*	On Windows 95, access hardware directly
		*/
		outp((WORD)(port + lpt_addr), (WORD)data);
	}
}

/**************************************************************************/
/*                                                                        */

int read_byteblaster
(
	int port
)

/*                                                                        */
/**************************************************************************/
{
	int data = 0;

#if PORT == WINDOWS

	BOOL status = FALSE;

	int returned_length = 0;


	if (windows_nt)
	{
		/* flush output cache buffer before reading from device */
		if (port_io_count > 0) flush_ports();

		/*
		*	On Windows NT, access hardware through device driver
		*/
		status = DeviceIoControl(
			nt_device_handle,			/* Handle to device */
			PGDC_IOCTL_READ_PORT_PP,	/* IO Control code for Read */
			(ULONG *)&port,				/* Buffer to driver. */
			sizeof(int),				/* Length of buffer in bytes. */
			(ULONG *)&data,				/* Buffer from driver. */
			sizeof(int),				/* Length of buffer in bytes. */
			(ULONG *)&returned_length,	/* Bytes placed in data_buffer. */
			NULL);						/* Wait for operation to complete */

		if ((!status) || (returned_length != sizeof(int)))
		{
			printf( "I/O error:  Cannot access ByteBlaster hardware\n");
			CloseHandle(nt_device_handle);
			exit(1);
		}
	}
	else
#endif
	{
		/*
		*	On Windows 95, access hardware directly
		*/
		data = inp((WORD)(port + lpt_addr));
	}

	return (data & 0xff);
}

#if PORT == WINDOWS
void flush_ports(void)
{
	ULONG n_writes = 0L;
	BOOL status;

	status = DeviceIoControl(
		nt_device_handle,			/* handle to device */
		PGDC_IOCTL_PROCESS_LIST_PP,	/* IO control code */
		(LPVOID)port_io_buffer,		/* IN buffer (list buffer) */
		port_io_count * sizeof(struct PORT_IO_LIST_STRUCT),/* length of IN buffer in bytes */
		(LPVOID)port_io_buffer,	/* OUT buffer (list buffer) */
		port_io_count * sizeof(struct PORT_IO_LIST_STRUCT),/* length of OUT buffer in bytes */
		&n_writes,					/* number of writes performed */
		0);							/* wait for operation to complete */

	if ((!status) || ((port_io_count * sizeof(struct PORT_IO_LIST_STRUCT)) != n_writes))
	{
		printf( "I/O error:  Cannot access ByteBlaster hardware\n");
		CloseHandle(nt_device_handle);
		exit(1);
	}

	port_io_count = 0;
}
#endif /* PORT == WINDOWS */
#endif /* PORT == WINDOWS || PORT == DOS */

#if !defined (DEBUG)
#pragma optimize ("ceglt", off)
#endif

void delay_loop(long count)
{
	while (count != 0L) count--;
}
