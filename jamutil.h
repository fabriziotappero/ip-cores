/****************************************************************************/
/*																			*/
/*	Module:			jamutil.h												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	Prototypes for miscelleneous utility functions			*/
/*																			*/
/****************************************************************************/

/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/

#ifndef INC_JAMUTIL_H
#define INC_JAMUTIL_H

/****************************************************************************/
/*																			*/
/*	Function Prototypes														*/
/*																			*/
/****************************************************************************/

char jam_toupper(char ch);

int jam_iscntrl(char ch);

int jam_isalpha(char ch);

int jam_isdigit(char ch);

int jam_isalnum(char ch);

int jam_isspace(char ch);

int jam_is_name_char(char ch);

int jam_is_hex_char(char ch);

int jam_strlen(char *string);

long jam_atol(char *string);

void jam_ltoa(char *string, long value);

int jam_strcmp(char *left, char *right);

int jam_stricmp(char *left, char *right);

int jam_strncmp(char *left, char *right, int count);

int jam_strnicmp(char *left, char *right, int count);

void jam_strcpy(char *dest, char *source);

void jam_strncpy(char *dest, char *source, int count);

#endif /* INC_JAMUTIL_H */
