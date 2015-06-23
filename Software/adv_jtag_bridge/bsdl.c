/* bsdl.c - BSDL file handler for the advanced JTAG bridge
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

#include <sys/types.h>
#include <string.h>
#include <stdio.h>
#include <dirent.h>
#include <stdlib.h>
#include <errno.h>
#include "bsdl.h"
#include "bsdl_parse.h"


#define debug(...) //fprintf(stderr, __VA_ARGS__ ) 

// Globals to deal with directory names
#define MAX_BSDL_DIRS 64  // Any more than this would take a looooong time...
static char *bsdl_dirs[MAX_BSDL_DIRS];
static int bsdl_current_dir = 0;  // We try them in reverse order

// Globals to hold the current, open directory
DIR *bsdl_open_dir = NULL;

// Globals to hold BSDL info
static bsdlinfo *bsdl_head = NULL;
static bsdlinfo *bsdl_tail = NULL;
static bsdlinfo *bsdl_last = NULL;  // optimization: pointer to the last struct we used (not necessarily the last in the linked list)

// Scratchpad for full pathname
int bsdl_scratchpad_size = 0;
char *bsdl_scratchpad = NULL;

// Prototypes for local functions
bsdlinfo *get_bsdl_info(uint32_t idcode);



//////////////////////////////////////////////////////////////////////
// API for init and config

void bsdl_init(void)
{
  bsdl_dirs[0] = strdup("/opt/bsdl"); 
  bsdl_dirs[1] = strdup("/usr/share/bsdl");
  bsdl_dirs[2] = strdup("~/.bsdl");
  bsdl_dirs[3] = strdup(".");
  bsdl_current_dir = 3;
  bsdl_scratchpad = (char *) malloc(64);
  bsdl_scratchpad_size = 64;
}

void bsdl_add_directory(const char *dirname)
{
  if(bsdl_current_dir >= (MAX_BSDL_DIRS-1)) {
    printf("Max BSDL dirs (%d) exceeded; failed to add directory %s\n", MAX_BSDL_DIRS, dirname);
    return;
  }

  bsdl_current_dir++;
  bsdl_dirs[bsdl_current_dir] = strdup(dirname);
}


///////////////////////////////////////////////////////////////////
// API  to get device info from BSDL files, if available


const char * bsdl_get_name(uint32_t idcode)
{
  bsdlinfo *info;
  info = get_bsdl_info(idcode);
  if(info != NULL)
    return info->name;

  return NULL;


}

// Return the IR length of the device with the given IDCODE,
// if its BSDL file is available.  Returns -1 on
// error, which is an invalid size.

int bsdl_get_IR_size(uint32_t idcode)
{
  bsdlinfo *info;
  info = get_bsdl_info(idcode);
  if(info != NULL)
    return info->IR_size;

  return -1;
}


// Returns the DEBUG command for the device with the gived IDCODE,
// if its BSDL file is available.  Returns 0xFFFFFFFF on error,
// which is as invalid command (because it's the BYPASS command)
uint32_t bsdl_get_debug_cmd(uint32_t idcode)
{  
  bsdlinfo *info;
  info = get_bsdl_info(idcode);
  if(info != NULL)
    return info->cmd_debug;
  return TAP_CMD_INVALID;
}

// Returns the USER1 command for the device with the gived IDCODE,
// if its BSDL file is available.  Returns 0xFFFFFFFF on error,
// which is as invalid command (because it's the BYPASS command)
uint32_t bsdl_get_user1_cmd(uint32_t idcode)
{
  bsdlinfo *info;
  info = get_bsdl_info(idcode);
  if(info != NULL)
    return info->cmd_user1;
  return TAP_CMD_INVALID;
}

// Returns the IDCODE command for the device with the gived IDCODE,
// if its BSDL file is available.  Returns 0xFFFFFFFF on error,
// which is as invalid command (because it's the BYPASS command)
uint32_t bsdl_get_idcode_cmd(uint32_t idcode)
{
  bsdlinfo *info;
  info = get_bsdl_info(idcode);
  if(info != NULL)
    return info->cmd_idcode;
  return TAP_CMD_INVALID;
}

/////////////////////////////////////////////////////////////////////////////
// Internal routines


// This uses a lazy algorithm...first, search data we already have.
// Then, parse new files (storing all data) only until we find
// the data we want.
bsdlinfo *get_bsdl_info(uint32_t idcode)
{
  struct dirent *direntry = NULL;
  bsdlinfo *ptr = bsdl_head;
  char *c;

  // Check the last place we looked
  if(bsdl_last != NULL)
      if((bsdl_last->idcode & bsdl_last->idcode_mask) == (idcode & bsdl_last->idcode_mask))
	return bsdl_last;

  // First, search through the info already parsed
  while(ptr != NULL)
    {
      if((ptr->idcode & ptr->idcode_mask) == (idcode & ptr->idcode_mask))
	{
	  bsdl_last = ptr;
	  return ptr;
	}
      ptr = ptr->next;
    }

  // Parse files until we get the IDCODE we want
  while(1) 
    {
      // Find and open a valid directory 
      while(bsdl_open_dir == NULL)
	{
	  if(bsdl_current_dir < 0)
	    return NULL;  // There are no more directories to check
	  debug("Trying BSDL dir \'%s\'\n", bsdl_dirs[bsdl_current_dir]);
	  bsdl_open_dir = opendir(bsdl_dirs[bsdl_current_dir]);
	  if((bsdl_open_dir == NULL) && (bsdl_current_dir > 2))  // Don't warn if default dirs not found
	    printf("Warning: unable to open BSDL directory \'%s\': %s\n", bsdl_dirs[bsdl_current_dir], strerror(errno));
	  bsdl_current_dir--;
	  direntry = NULL;
	}
      
      // Find a BSDL file
      do
	{
	  direntry = readdir(bsdl_open_dir);
	  if(direntry == NULL)
	    {  // We've exhausted this directory
	      debug("Next bsdl directory\n");
	      closedir(bsdl_open_dir);
	      bsdl_open_dir = NULL;
	      break;
	    }

	  // *** If a subdirectory, continue!!

	  // Check if it's a BSDL file: .bsd, .bsdl, .BSD, .BSDL
	  debug("Checking file \'%s\'\n", direntry->d_name);
	  c = strrchr(direntry->d_name, '.');
	  debug("File extension is \'%s\'\n", c);
	  if(c == NULL)
	    continue;
	  if(!strcmp(c, ".bsd") || !strcmp(c, ".bsdl") || !strcmp(c, ".BSD") || !strcmp(c, ".BSDL"))
	    break;
	  
	} 
      while(1);
      
      if(direntry == NULL)  // We need a new directory
	continue;

      // Make sure we can hold the full path (+2 for a '/' and the trailing NULL)
      if((strlen(direntry->d_name) + strlen(bsdl_dirs[bsdl_current_dir+1])+2) >= bsdl_scratchpad_size)
	{
	  char *tmp = (char *) realloc(bsdl_scratchpad, (bsdl_scratchpad_size*2));
	  if(tmp != NULL)
	    {
	      debug("Extending bsdl scratchpad to size %i", bsdl_scratchpad_size);
	      bsdl_scratchpad_size *= 2;  
	      bsdl_scratchpad = tmp;
	    }
	  else
	    {
	      fprintf(stderr, "Warning: failed to reallocate BSDL scratchpad to size %i", bsdl_scratchpad_size*2);
	      continue;
	    }
	}

      strcpy(bsdl_scratchpad, bsdl_dirs[bsdl_current_dir+1]);
      strcat(bsdl_scratchpad, "/");
      strcat(bsdl_scratchpad, direntry->d_name);

      // Parse the BSDL file we found
      debug("Parsing file \'%s\'\n", bsdl_scratchpad);
      ptr = parse_extract_values(bsdl_scratchpad);
      
      // If we got good data...
      if(ptr != NULL)
	{
	  // Store the values...
	  if(bsdl_head == NULL) {
	    bsdl_head = ptr;
	    bsdl_tail = ptr;
	  } else {
	    bsdl_tail->next = ptr;
	    bsdl_tail = ptr;
	  }
	  
	  // ...and return if we got an IDCODE match
	  if((ptr->idcode & ptr->idcode_mask) == (idcode & ptr->idcode_mask)) {
	    bsdl_last = ptr;
	    return ptr;
	  }
	}
    } // while(1), parse files until we find a match or run out of dirs / files


  // If no more files to parse and not found, return NULL
  return NULL;
}
