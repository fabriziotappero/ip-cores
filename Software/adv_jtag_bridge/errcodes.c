/* errcodes.c - Error code to plaintext translator for the advanced JTAG bridge
   Copyright(C) 2008 - 2010 Nathan Yawn <nyawn@opencores.org>

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

#include <string.h>
#include "errcodes.h"

// We can declare the error string with a fixed size, because it can't
// have more than ALL of the error strings in it.  Be sure to expand it
// as more errors are added.  Also, put a space at the end of each
// error string, as there may be multiple errors.
char errstr[256];
char *get_err_string(int err)
{
  errstr[0] = '\0';

  if(err & APP_ERR_COMM)
    strcat(errstr, "\'JTAG comm error\' ");
  if(err & APP_ERR_MALLOC)
    strcat(errstr, "\'malloc failed\' ");
  if(err & APP_ERR_MAX_RETRY)
    strcat(errstr, "\'max retries\' ");
  if(err & APP_ERR_CRC)
    strcat(errstr, "\'CRC mismatch\' ");
  if(err & APP_ERR_MAX_BUS_ERR)
    strcat(errstr, "\'max WishBone bus errors\' ");  
  if(err & APP_ERR_CABLE_INVALID)
    strcat(errstr, "\'Invalid cable\' "); 
  if(err & APP_ERR_INIT_FAILED)
    strcat(errstr, "\'init failed\' "); 
  if(err & APP_ERR_BAD_PARAM)
    strcat(errstr, "\'bad command line parameter\' "); 
  if(err & APP_ERR_CONNECT)
    strcat(errstr, "\'connection failed\' "); 
  if(err & APP_ERR_USB)
    strcat(errstr, "\'USB\' "); 
  if(err & APP_ERR_CABLENOTFOUND)
    strcat(errstr, "\'cable not found\' "); 
  return errstr;
}
