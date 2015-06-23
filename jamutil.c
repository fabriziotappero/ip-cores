/****************************************************************************/
/*																			*/
/*	Module:			jamutil.c												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	Utility functions.  Most of these are private copies	*/
/*					of standard 'C' library functions.  Having them here	*/
/*					is intended to reduce porting hassles by eliminating	*/
/*					the need for local run-time library functions			*/
/*																			*/
/****************************************************************************/

/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/

#include "jamutil.h"

char jam_toupper(char ch)
{
	return ((char) (((ch >= 'a') && (ch <= 'z')) ? (ch + 'A' - 'a') : ch));
}

int jam_iscntrl(char ch)
{
	return (((ch >= 0) && (ch <= 0x1f)) || (ch == 0x7f));
}

int jam_isalpha(char ch)
{
	return (((ch >= 'A') && (ch <= 'Z')) || ((ch >= 'a') && (ch <= 'z')));
}

int jam_isdigit(char ch)
{
	return ((ch >= '0') && (ch <= '9'));
}

int jam_isalnum(char ch)
{
	return (((ch >= 'A') && (ch <= 'Z')) || ((ch >= 'a') && (ch <= 'z')) ||
		((ch >= '0') && (ch <= '9')));
}

int jam_isspace(char ch)
{
	return (((ch >= 0x09) && (ch <= 0x0d)) || (ch == 0x20));
}

int jam_is_name_char(char ch)
{
	return (((ch >= 'A') && (ch <= 'Z')) || ((ch >= 'a') && (ch <= 'z')) ||
		((ch >= '0') && (ch <= '9')) || (ch == '_'));
}

int jam_is_hex_char(char ch)
{
	return (((ch >= 'A') && (ch <= 'F')) || ((ch >= 'a') && (ch <= 'f')) ||
		((ch >= '0') && (ch <= '9')));
}

int jam_strlen(char *string)
{
	int len = 0;

	while (string[len] != '\0') ++len;

	return (len);
}

long jam_atol(char *string)
{
	long result = 0L;
	int index = 0;

	while ((string[index] >= '0') && (string[index] <= '9'))
	{
		result = (result * 10) + (string[index] - '0');
		++index;
	}

	return (result);
}

void jam_ltoa(char *buffer, long number)
{
	int index = 0;
	int rev_index = 0;
	char reverse[32];

	if (number < 0L)
	{
		buffer[index++] = '-';
		number = 0 - number;
	}
	else if (number == 0)
	{
		buffer[index++] = '0';
	}

	while (number != 0)
	{
		reverse[rev_index++] = (char) ((number % 10) + '0');
		number /= 10;
	}

	while (rev_index > 0)
	{
		buffer[index++] = reverse[--rev_index];
	}

	buffer[index] = '\0';
}

int jam_strcmp(char *left, char *right)
{
	int result = 0;
	char l, r;

	do
	{
		l = *left;
		r = *right;
		result = l - r;
		++left;
		++right;
	}
	while ((result == 0) && (l != '\0') && (r != '\0'));

	return (result);
}

int jam_stricmp(char *left, char *right)
{
	int result = 0;
	char l, r;

	do
	{
		l = jam_toupper(*left);
		r = jam_toupper(*right);
		result = l - r;
		++left;
		++right;
	}
	while ((result == 0) && (l != '\0') && (r != '\0'));

	return (result);
}

int jam_strncmp(char *left, char *right, int count)
{
	int result = 0;
	char l, r;

	do
	{
		l = *left;
		r = *right;
		result = l - r;
		++left;
		++right;
		--count;
	}
	while ((result == 0) && (count > 0) && (l != '\0') && (r != '\0'));

	return (result);
}

int jam_strnicmp(char *left, char *right, int count)
{
	int result = 0;
	char l, r;

	do
	{
		l = jam_toupper(*left);
		r = jam_toupper(*right);
		result = l - r;
		++left;
		++right;
		--count;
	}
	while ((result == 0) && (count > 0) && (l != '\0') && (r != '\0'));

	return (result);
}

void jam_strcpy(char *left, char *right)
{
	char ch;

	do
	{
		*left = *right;
		ch = *right;
		++left;
		++right;
	}
	while (ch != '\0');
}

void jam_strncpy(char *left, char *right, int count)
{
	char ch;

	do
	{
		*left = *right;
		ch = *right;
		++left;
		++right;
		--count;
	}
	while ((ch != '\0') && (count != 0));
}
