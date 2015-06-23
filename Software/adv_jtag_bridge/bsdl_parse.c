/* bsdl_parse.c - BSDL parser for the advanced JTAG bridge
   Copyright(C) 2008 - 2010 Nathan Yawn

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
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. 
*/

#include <stdio.h>
#include <string.h>
#include <ctype.h>  // isspace(), etc.
#include <stdlib.h>  // malloc(), strtoul(), etc.
#include "bsdl.h"  // has constants


#define debug(...) //fprintf(stderr, __VA_ARGS__ )

char * strtoupper(char *str);
int get_line(char *filedata, int startpos, char **linedata, int filesize);
char * strchr_s(char *str, char *chars);
void parse_opcodes(char *cmdbuf, uint32_t *debug_cmd, uint32_t *user1_cmd, uint32_t *idcode_cmd);

// We assume that no value will be more than 128 chars
char tmpbuf[128];


 /////////////////////////////////////////////////////////////////
 // API call: extract desired info from 1 BSDL fise

bsdlinfo *parse_extract_values(char *bsdlfilename)
{
  FILE *fd;
  int filesize;
  bsdlinfo *ret;
  char *filedata;
  char *linedata;
  char *token;
  char *last;
  char *cmdbuf;
  int filepos = 0;
  int i,j;
  char done,valid,opens;

  int IR_size = -1;
  uint8_t found_IR_size = 0;
  uint32_t debug_cmd = TAP_CMD_INVALID;
  uint32_t user1_cmd = TAP_CMD_INVALID;
  uint32_t idcode_cmd = TAP_CMD_INVALID;
  uint8_t found_cmds = 0;
  uint32_t idcode = 0;
  uint32_t idcode_mask = 0xFFFFFFFF;  // 'X' is a valid char in an IDCODE, set 0's here for X's.
  uint8_t found_idcode = 0;
  char *entityname = NULL;
  
  // Open the file
  fd = fopen(bsdlfilename, "r");
  if(fd == NULL) {
    printf("ERROR:  failed to open BSDL file %s\n", bsdlfilename);
    return NULL;
  }

  fseek(fd, 0, SEEK_END);
  filesize = ftell(fd);
  fseek(fd, 0, SEEK_SET);

  filedata = (char *) malloc(filesize);
  if(filedata == NULL) {
    printf("ERROR: failed to allocate memory for BSDL file %s\n", bsdlfilename);
    return NULL;
  }

  if(fread(filedata, 1, filesize, fd) < filesize) {  // 1 long read will be faster than many short ones
    printf("Warning: failed to read entire BSDL file %s\n", bsdlfilename);
  }

  fclose(fd);


  // while there's more data and not all values have been found
  while((filepos < filesize) && (!found_IR_size || !found_cmds || !found_idcode))
    {
      // Get a line.  Replace any "--" with a \0 char
      filepos = get_line(filedata, filepos, &linedata, filesize);

      // look for each value
      token = strtok_r(linedata, " \t", &last);
      if(token == NULL) {
	printf("ERROR: End of file reached before END statement is BSDL file \'%s\'\n", bsdlfilename);
	break;
      }

      if(!strcmp(strtoupper(token), "ENTITY")) {
	// Parse an entity line
	token = strtok_r(NULL, " \t", &last);
	if(token != NULL) {
	  entityname = strdup(token);
	  if(entityname != NULL) 
	    {
	      debug("Found entity \'%s\'\n", entityname);
	    }
	} else {
	  printf("Parse error near ENTITY token in file %s\n", bsdlfilename);
	}
      }
      else if(!strcmp(strtoupper(token), "CONSTANT")) {
	// Parse a constant declaration...we ignore them, just get lines until we find a ';' char
	// assume nothing else useful comes on the line after the ';'
	// Slightly awkward, since we have to search the rest of the line after the strtok, then possible
	// new lines as well.
	token = strtok_r(NULL, " \t", &last);  // debug...don't worry about error, token only used in printf
	debug("Ignoring constant \'%s\'\n", token);  // debug
	while(strchr(last, ';') == NULL) { 
	  filepos = get_line(filedata, filepos, &last, filesize); 
	}
      }
      else if(!strcmp(strtoupper(token), "GENERIC")) {
	// Parse a generic declaration...we ignore them, just get lines until we find a ';' char
	// assume nothing else useful comes on the line after the ';'
	// Slightly awkward, since we have to search the rest of the line after the strtok, then possible
	// new lines as well.
	token = strtok_r(NULL, " \t", &last);  // debug...don't worry about error, token only used in printf
	debug("Ignoring generic \'%s\'\n", token);  // debug
	while(strchr(last, ';') == NULL) { 
	  filepos = get_line(filedata, filepos, &last, filesize); 
	}
      }
      else if(!strcmp(strtoupper(token), "USE")) {
	// Parse a 'use' declaration...we ignore them, just get lines until we find a ';' char
	// assume nothing else useful comes on the line after the ';'
	// Note that there may be no space after the token, so add ';' to the tokenizing list in the debug bits.
	// Slightly awkward, since we have to search the rest of the line after the strtok, then possible
	// new lines as well.
	token = strtok_r(NULL, " \t;", &last);  // debug ...don't worry about error, token only used in printf
	debug("Ignoring use \'%s\'\n", token);  // debug
	while(strchr(last, ';') == NULL) { 
	  filepos = get_line(filedata, filepos, &last, filesize); 
	}
      }
      else if(!strcmp(strtoupper(token), "END")) {
	// We're done, whether we've found what we want or not.  Eject eject eject...
	debug("Found END token, stopping parser\n");
	break;
      }
      else if(!strcmp(strtoupper(token), "PORT")) {
	// Parse a port list.  Find a '(', find a ')', find a ';'.
	// Note that "()" pairs may occur in between.
	// 'last' must be set in the first two strchr() calls so that the next strchr() call will
	// begin parsing after the previous char position.  Otherwise, e.g. a ';' before the ')' but on the same
	// line would (incorrectly) satisfy the search.
	while((last = strchr(last, '(')) == NULL) { 
	  filepos = get_line(filedata, filepos, &last, filesize); 
	}
	opens = 1;
	last++;  // don't leave 'last' pointing at the '(' char, since we're looking for another

	do {
	  while((last = strchr_s(last, "()")) == NULL) { 
	    filepos = get_line(filedata, filepos, &last, filesize); // *** abort if new line is empty
	  }
	  if(*last == '(') opens++;
	  else if(*last == ')') opens--;
	  last++;  // don't leave last pointing at the same "()" char, since we're looking for another
	} while(opens);


	while(strchr(last, ';') == NULL) { 
	  filepos = get_line(filedata, filepos, &last, filesize); 
	}
	debug("Ignored port statement\n");
      }
      else if(!strcmp(strtoupper(token), "ATTRIBUTE")) {
	// Parse an attribute
	token = strtok_r(NULL, " \t", &last);  // *** check for error
	if(!strcmp(strtoupper(token), "INSTRUCTION_LENGTH")) {
	  // Find ':', then "entity", then "is", then take anything before the ';' as the value
	  while((last = strchr(last, ':')) == NULL) { 
	    filepos = get_line(filedata, filepos, &last, filesize); // *** check last actually has data?
	  }
	  while((last = strstr(last, "entity")) == NULL) { // don't do strtoupper() here, that would do the entire line
	    filepos = get_line(filedata, filepos, &last, filesize); // *** check last actually has data?
	  }
	  while((last = strstr(last, "is")) == NULL) { 
	    filepos = get_line(filedata, filepos, &last, filesize); // *** check last actually has data?
	  }

	  // scan until the end of the line looking for data
	  j = 0;
	  done = 0;
	  while(*last != '\0') {
	    if(isdigit(*last)) tmpbuf[j++] = *last;
	    else if(*last == ';') { done = 1; break;}
	    last++;
	  }
	  // May need to go to additional lines
	  while(!done) {
	    filepos = get_line(filedata, filepos, &linedata, filesize);  // *** break if linedata has no data
	    while(*linedata != '\0') {
	      if(isdigit(*linedata)) tmpbuf[j++] = *linedata;
	      else if(*linedata == ';') { done = 1; break;}
	      linedata++;
	    }
	  }

	  tmpbuf[j] = '\0';
	  IR_size = strtoul(tmpbuf, NULL, 0);
	  found_IR_size = 1;
	  debug("Found IR size %i (%s)\n", IR_size, tmpbuf);
	}  // end if INSTRUCTION_LENGTH

	else if(!strcmp(strtoupper(token), "INSTRUCTION_OPCODE")) {
	  // Find ": entity is"
	  while((last = strchr(last, ':')) == NULL) { 
	    filepos = get_line(filedata, filepos, &last, filesize); // *** check last actually has data?
	  }
	  while((last = strstr(last, "entity")) == NULL) { // don't do strtoupper() here, that would do the entire line
	    filepos = get_line(filedata, filepos, &last, filesize); // *** check last actually has data?
	  }
	  while((last = strstr(last, "is")) == NULL) { 
	    filepos = get_line(filedata, filepos, &last, filesize); // *** check last actually has data?
	  }

	  // We're going to copy the entire attribute (all commands) into a temp. buffer.  We need a big enough buffer,
	  // and we can't just scan for ';' to find out because there's a '\0' at the end of this line.
	  // But, it can't be bigger than the entire rest of the file, so...
	  cmdbuf = (char *) malloc(filesize-filepos);
	  debug("Malloc'd %i bytes for INSTRUCTION_OPCODE\n", filesize-filepos);

	  // Parse until ';', and grab everything between each pair of "" found
	  // Note that 'last' still points at "is"
	  j = 0;
	  done = 0;
	  valid = 0;
	  while(*last != '\0') {
	    if(*last == ';') { done = 1; break;}  // Put this first in case of badly formed BSDL files
	    else if(valid && (*last != '\"')) cmdbuf[j++] = *last;
	    else if(*last == '\"') valid = !valid;
	    last++;
	  }
	  // May need to go to additional lines
	  while(!done) {
	    filepos = get_line(filedata, filepos, &linedata, filesize); // *** break if linedata has no data
	    while(*linedata != '\0') {
	      if(valid && (*linedata != '\"')) cmdbuf[j++] = *linedata;
	      else if(*linedata == '\"') valid = !valid;
	      else if(*linedata == ';') { done = 1; break;}
	      linedata++;
	    }
	  }
	  cmdbuf[j] = '\0';
	  debug("Finished copying INSTRUCTION_OPCODE, copied %i bytes", j+1);

	  // Parse the opcodes attribute.  This is an exercise unto itself, so do it in another function.
	  parse_opcodes(cmdbuf, &debug_cmd, &user1_cmd, &idcode_cmd);
	  found_cmds = 1;
	  free(cmdbuf);

	}   // end if INSTRUCTION_OPCODE

	else if(!strcmp(strtoupper(token), "IDCODE_REGISTER")) {
	  // Find : entity is
	  while((last = strchr(last, ':')) == NULL) { 
	    filepos = get_line(filedata, filepos, &last, filesize); // *** check last actually has data?
	  }
	  while((last = strstr(last, "entity")) == NULL) { // don't do strtoupper() here, that would do the entire line
	    filepos = get_line(filedata, filepos, &last, filesize); // *** check last actually has data?
	  }
	  while((last = strstr(last, "is")) == NULL) { 
	    filepos = get_line(filedata, filepos, &last, filesize); // *** check last actually has data?
	  }

	  // Parse until ';', and grab everything between each pair of "" found
	  // Note that 'last' still points at "is"
	  j = 0;
	  done = 0;
	  valid = 0;
	  while(*last != '\0') {
	    if(*last == ';') { done = 1; break;}  // Put this first in case of badly formed BSDL files
	    else if(valid && (*last != '\"')) tmpbuf[j++] = *last;
	    else if(*last == '\"') valid = !valid;
	    last++;
	  }
	  // May need to go to additional lines
	  while(!done) {
	    filepos = get_line(filedata, filepos, &linedata, filesize); // *** break if linedata has no data
	    while(*linedata != '\0') {
	      if(valid && (*linedata != '\"')) tmpbuf[j++] = *linedata;
	      else if(*linedata == '\"') valid = !valid;
	      else if(*linedata == ';') { done = 1; break;}
	      linedata++;
	    }
	  }
	  tmpbuf[j] = '\0';

	  // Parse the tmpbuf
	  if(j != 32) printf("Warning:  found %i chars (expected 32) while getting IDCODE in BSDL file %s.\n", j, bsdlfilename);  // Sanity check
	  debug("Got IDCODE string \'%s\'\n", tmpbuf);
	  for(i = 0; i < j; i++) {
	    if(tmpbuf[i] == '1') idcode |= 0x1<<(31-i);
	    else if(toupper(tmpbuf[i]) == 'X') idcode_mask &= ~(0x1<<(31-i)); 
	  }
	  debug("Found IDCODE 0x%08X (%s), mask is 0x%08X\n", idcode, tmpbuf, idcode_mask);
	  found_idcode = 1;

	}  // end if IDCODE_REGISTER

	else {
	  debug("Ignoring attribute \'%s\'\n", token);
	  // Consume chars until ';' found
	  while(strchr(last, ';') == NULL) { 
	    filepos = get_line(filedata, filepos, &last, filesize); 
	  }
	}
      }
      else {
	debug("Unknown token \'%s\' found in BSDL file %s\n", token, bsdlfilename);
      }
    }

  free(filedata);

  // Put the data in a struct for return and storage
  ret = (bsdlinfo *) malloc(sizeof(bsdlinfo));
  if(ret == NULL) {
       printf("Error: out of memory, unable to store BSDL info for file %s\n", bsdlfilename);
       return NULL;
  }

  ret->name = entityname;  // this was malloc'd, so it's persistant, this is safe
  ret->idcode = idcode;
  ret->idcode_mask = idcode_mask;
  ret->IR_size = IR_size;
  ret->cmd_debug = debug_cmd;
  ret->cmd_user1 = user1_cmd;
  ret->cmd_idcode = idcode_cmd;
  ret->next = NULL;

  return ret;
}



//////////////////////////////////////////////////////////////////////////////////////////////
// Local / helper functions


// Returns 1 line from a complete file buffer pointed to by *filedata.  Removes leading
// whitespace, ignores comment lines, removes trailing comments (comments denoted by "--")
// startpos: index in filedata[] to start looking for a new line.
// linedata:  set to point to the first char of the new line.
// filesize:  used so we don't go past the end of filedata[]
// The return value is the first index after the returned line.  This may be 1 past the end of the buffer.
int get_line(char *filedata, int startpos, char **linedata, int filesize)
{
  int lineidx = startpos;
  unsigned char loop;
  char *commentptr;

  do {
    loop = 0;
    while(isspace(filedata[lineidx]) && (lineidx < filesize)) lineidx++;  // burn leading whitespace chars

    if(lineidx >= (filesize-1)) { // We look at the data at lineidx and lineidx+1...don't look at invalid offsets. 
      lineidx = filesize-1; 
      break; 
    }

    if((filedata[lineidx] == '-') && (filedata[lineidx+1] == '-'))
      {  // then this is a full-line comment, with no useful data
	while(((filedata[lineidx] != '\n') && (filedata[lineidx] != '\r')) && (lineidx < filesize))
	  lineidx++;  // burn comment line up to CR/LF
	loop = 1;
      }
  } while(loop);
  
  // Set the line pointer
  *linedata = &filedata[lineidx];

  // Put a NULL char at the newline
  while(!iscntrl(filedata[lineidx]) && (lineidx < filesize)) lineidx++;
  if(lineidx >= filesize) { // Don't write past the end of the array.
    lineidx = filesize-1; 
  }
  filedata[lineidx] = '\0';

  // Put a NULL at the first "--" string, if any
  commentptr = strstr(*linedata, "--");
  if(commentptr != NULL) *commentptr = '\0';

  return lineidx+1;
}


// In-place string capitalizer
char * strtoupper(char *str)
{
  int i = 0;

  while(str[i] != '\0') { 
    str[i] = toupper(str[i]);
    i++;
  }

  return str;
}

// Searches a string 'str' for the first occurance of any 
// character in the string 'chars'.  Returns a pointer to
// the char in 'str' if one is found, returns NULL if
// none of the chars in 'chars' are present in 'str'.
char * strchr_s(char *str, char *chars)
{
  int slen = strlen(chars);
  char *ptr = str;
  int i;

  while(*ptr != '\0') {
    for(i = 0; i < slen; i++) {
      if(*ptr == chars[i]) 
	return ptr;
    }
    ptr++;
  }

  return NULL;
}


// Parses a string with command name / opcode pairs of the format
// EXTEST    (1111000000),SAMPLE    (1111000001), [...]
// There may or may not be a space between the name and the open paren.
// We do not assume a comma after the last close paren.
#define TARGET_DEBUG  1
#define TARGET_USER1  2
#define TARGET_IDCODE 3
void parse_opcodes(char *cmdbuf, uint32_t *debug_cmd, uint32_t *user1_cmd, uint32_t *idcode_cmd)
{
  char *saveptr = NULL;
  char *cmd;
  char *token;
  char *saveptr2;
  int target;
  int opcode;
  
  cmd = strtok_r(cmdbuf, ",", &saveptr);
  while(cmd != NULL)
    {
      // 'cmd' should now have one pair in the form "EXTEST    (1111000000)"
      target = 0;
      token = strtok_r(cmd, " \t(", &saveptr2);
      if(!strcmp(strtoupper(token), "DEBUG")) {
	target = TARGET_DEBUG;
	debug("Found DEBUG opcode: ");
      }
      else if(!strcmp(strtoupper(token), "USER1")) {
	target = TARGET_USER1;
	debug("Found USER1 opcode:");
      }
      else if(!strcmp(strtoupper(token), "IDCODE")) {
	target = TARGET_IDCODE;
	debug("Found IDCODE opcode: ");
      }

      if(target) {  // don't parse opcode number unless necessary
	token = strtok_r(NULL, " \t()", &saveptr2);
	if(token != NULL) {
	  opcode = strtoul(token, NULL, 2); // *** Test for errors
	  debug("0x%X (%s)\n", opcode, token);
	  
	  if(target == TARGET_DEBUG) *debug_cmd = opcode;
	  else if(target == TARGET_USER1) *user1_cmd = opcode;
	  else if(target == TARGET_IDCODE) *idcode_cmd = opcode;
	}
	else {
	  printf("Error:  failed to find opcode value after identifier.\n");
	}
      }

      cmd = strtok_r(NULL,  ",", &saveptr);
    }


}
