/*********************************************************************
 *
 * Copyright (C) 2002-2004  Karlsruhe University
 *
 * File path:     generic/printk.cc
 * Description:   Implementation of printf
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 ********************************************************************/
#include <stdarg.h>	/* for va_list, ... comes with gcc */
#include <l4/lib/printk.h>
#include <l4/lib/mutex.h>

/* FIXME: LICENSE LICENCE */
typedef unsigned int word_t;

extern void putc(const char c);
extern int print_tid (word_t val, word_t width, word_t precision, int adjleft);


/* convert nibble to lowercase hex char */
#define hexchars(x) (((x) < 10) ? ('0' + (x)) : ('a' + ((x) - 10)))

/**
 *	Print hexadecimal value
 *
 *	@param val		value to print
 *	@param width		width in caracters
 *	@param precision	minimum number of digits to apprear
 *	@param adjleft		left adjust the value
 *	@param nullpad		pad with leading zeros (when right padding)
 *
 *	Prints a hexadecimal value with leading zeroes of given width
 *	using putc(), or if adjleft argument is given, print
 *	hexadecimal value with space padding to the right.
 *
 *	@returns the number of charaters printed (should be same as width).
 */
int print_hex64(u64 val, int width, int precision, int adjleft, int nullpad)
{
    int i, n = 0;
    int nwidth = 0;
    u32 high, low;

    high = val >> 32;
    low = (u32)val;

    // Find width of hexnumber
    if (high) {
	while ((high >> (4 * nwidth)) && ((unsigned) nwidth <  2 * sizeof (u32)))
	    nwidth++;
	nwidth += 32;
    } else {
	while ((low >> (4 * nwidth)) && ((unsigned) nwidth <  2 * sizeof (u32)))
	    nwidth++;
    }

    if (nwidth == 0)
	nwidth = 1;

    // May need to increase number of printed digits
    if (precision > nwidth)
	nwidth = precision;

    // May need to increase number of printed characters
    if (width == 0 && width < nwidth)
	width = nwidth;

    // Print number with padding
    if (high)
    {
	if (!adjleft)
	    for (i = width - nwidth; i > 0; i--, n++)
		putc (nullpad ? '0' : ' ');
	for (i = 4 * (nwidth - 33); i >= 0; i -= 4, n++)
	    putc (hexchars ((high >> i) & 0xF));
	if (adjleft)
	    for (i = width - nwidth; i > 0; i--, n++)
		putc (' ');
	width -= 32;
	nwidth -= 32;
	nullpad = 1;
    }
    if (! adjleft)
	for (i = width - nwidth; i > 0; i--, n++)
	    putc (nullpad ? '0' : ' ');
    for (i = 4 * (nwidth - 1); i >= 0; i -= 4, n++)
	putc (hexchars ((low >> i) & 0xF));
    if (adjleft)
	for (i = width - nwidth; i > 0; i--, n++)
	    putc (' ');

    return n;
}

int print_hex_3arg(const word_t val, int width, int precision)
{
    long i, n = 0;
    long nwidth = 0;
    int adjleft = 0;
    int nullpad = 0;

    // Find width of hexnumber
    while ((val >> (4 * nwidth)) && (word_t) nwidth <  2 * sizeof (word_t))
	nwidth++;

    if (nwidth == 0)
	nwidth = 1;

    // May need to increase number of printed digits
    if (precision > nwidth)
	nwidth = precision;

    // May need to increase number of printed characters
    if (width == 0 && width < nwidth)
	width = nwidth;

    // Print number with padding
    if (! adjleft)
	for (i = width - nwidth; i > 0; i--, n++)
	    putc (nullpad ? '0' : ' ');
    for (i = 4 * (nwidth - 1); i >= 0; i -= 4, n++)
	putc (hexchars ((val >> i) & 0xF));
    if (adjleft)
	for (i = width - nwidth; i > 0; i--, n++)
	    putc (' ');

    return n;
}

int print_hex_5arg(const word_t val, int width,
		   int precision, int adjleft, int nullpad)
{
    long i, n = 0;
    long nwidth = 0;

    // Find width of hexnumber
    while ((val >> (4 * nwidth)) && (word_t) nwidth <  2 * sizeof (word_t))
	nwidth++;

    if (nwidth == 0)
	nwidth = 1;

    // May need to increase number of printed digits
    if (precision > nwidth)
	nwidth = precision;

    // May need to increase number of printed characters
    if (width == 0 && width < nwidth)
	width = nwidth;

    // Print number with padding
    if (! adjleft)
	for (i = width - nwidth; i > 0; i--, n++)
	    putc (nullpad ? '0' : ' ');
    for (i = 4 * (nwidth - 1); i >= 0; i -= 4, n++)
	putc (hexchars ((val >> i) & 0xF));
    if (adjleft)
	for (i = width - nwidth; i > 0; i--, n++)
	    putc (' ');

    return n;
}
/**
 *	Print a string
 *
 *	@param s	zero-terminated string to print
 *	@param width	minimum width of printed string
 *
 *	Prints the zero-terminated string using putc().  The printed
 *	string will be right padded with space to so that it will be
 *	at least WIDTH characters wide.
 *
 *      @returns the number of charaters printed.
 */
int print_string_3arg(const char * s, const int width, const int precision)
{
    int n = 0;

    for (;;)
    {
	if (*s == 0)
	    break;

	putc(*s++);
	n++;
	if (precision && n >= precision)
	    break;
    }

    while (n < width) { putc(' '); n++; }

    return n;
}

int print_string_1arg(const char * s)
{
	int n = 0;
	int width = 0;
	int precision = 0;

	for (;;) {
		if (*s == 0)
			break;

		putc(*s++);
		n++;
		if (precision && n >= precision)
			break;
	}

	while (n < width) { 
		putc(' '); 
		n++; 
	}

	return n;
}


/**
 *	Print hexadecimal value with a separator
 *
 *	@param val	value to print
 *	@param bits	number of lower-most bits before which to
 *                      place the separator
 *      @param sep      the separator to print
 *
 *	@returns the number of charaters printed.
 */
int print_hex_sep(const word_t val, const int bits, const char *sep)
{
    int n = 0;

    n = print_hex_3arg(val >> bits, 0, 0);
    n += print_string_1arg(sep);
    n += print_hex_3arg(val & ((1 << bits) - 1), 0, 0);

    return n;
}


/**
 *	Print decimal value
 *
 *	@param val	value to print
 *	@param width	width of field
 *      @param pad      character used for padding value up to width
 *
 *	Prints a value as a decimal in the given WIDTH with leading
 *	whitespaces.
 *
 *	@returns the number of characters printed (may be more than WIDTH)
 */
int print_dec(const word_t val, int width)
{
    word_t divisor;
    int digits;
    /* estimate number of spaces and digits */
    for (divisor = 1, digits = 1; val/divisor >= 10; divisor *= 10, digits++);

    /* print spaces */
    for ( ; digits < width; digits++ )
	putc(' ');

    /* print digits */
    do {
	putc(((val/divisor) % 10) + '0');
    } while (divisor /= 10);

    /* report number of digits printed */
    return digits;
}

/**
 *	Does the real printk work
 *
 *	@param format_p		pointer to format string
 *	@param args		list of arguments, variable length
 *
 *	Prints the given arguments as specified by the format string.
 *	Implements a subset of the well-known printf plus some L4-specifics.
 *
 *	@returns the number of characters printed
 */
int do_printk(char* format_p, va_list args)
{
    const char* format = format_p;
    int n = 0;
    int i = 0;
    int width = 8;
    int precision = 0;
    int adjleft = 0, nullpad = 0;

#define arg(x) va_arg(args, x)

    /* sanity check */
    if (format == '\0')
    {
	return 0;
    }

    while (*format)
    {
	switch (*(format))
	{
	case '%':
	    width = precision = 0;
	    adjleft = nullpad = 0;
	reentry:
	    switch (*(++format))
	    {
		/* modifiers */
	    case '.':
		for (format++; *format >= '0' && *format <= '9'; format++)
		    precision = precision * 10 + (*format) - '0';
		if (*format == 'w')
		{
		    // Set precision to printsize of a hex word
		    precision = sizeof (word_t) * 2;
		    format++;
		}
		format--;
		goto reentry;
	    case '0':
		nullpad = (width == 0);
	    case '1'...'9':
		width = width*10 + (*format)-'0';
		goto reentry;
	    case 'w':
		// Set width to printsize of a hex word
		width = sizeof (word_t) * 2;
		goto reentry;
	    case '-':
		adjleft = 0;
		goto reentry;
	    case 'l':
		goto reentry;
		break;
	    case 'c':
		putc(arg(int));
		n++;
		break;
	    case 'm':	/* microseconds */
	    {
		n += print_hex64(arg(u64), width, precision,
			       adjleft, nullpad);
		break;
	    }
	    case 'd':
	    {
		long val = arg(long);
		if (val < 0)
		{
		    putc('-');
		    val = -val;
		}
		n += print_dec(val, width);
		break;
	    }
	    case 'u':
		n += print_dec(arg(long), width);
		break;
	    case 'p':
		precision = sizeof (word_t) * 2;
	    case 'x':
		n += print_hex_5arg(arg(long), width, precision, adjleft, nullpad);
		break;
	    case 's':
	    {
		char* s = arg(char*);
		if (s)
		    n += print_string_3arg(s, width, precision);
		else
		    n += print_string_3arg("(null)", width, precision);
	    }
	    break;

	    case 't':
	    case 'T':
	    	// Do nothing for now.
		//n += print_tid (arg (word_t), width, precision, adjleft);
		break;

	    case '%':
		putc('%');
		n++;
		format++;
		continue;
	    default:
		n += print_string_1arg("?");
		break;
	    };
	    i++;
	    break;
	default:
	    putc(*format);
	    n++;
	    break;
	}
	format++;
    }

    return n;
}

DECLARE_SPINLOCK(printk_lock);

/**
 *	Flexible print function
 *
 *	@param format	string containing formatting and parameter type
 *			information
 *	@param ...	variable list of parameters
 *
 *	@returns the number of characters printed
 */
int printk(char *format, ...)
{
    va_list args;
    int i;
    unsigned long irqstate;

    va_start(args, format);

    spin_lock_irq(&printk_lock, &irqstate);
    i = do_printk(format, args);
    spin_unlock_irq(&printk_lock, irqstate);

    va_end(args);
    return i;
}


