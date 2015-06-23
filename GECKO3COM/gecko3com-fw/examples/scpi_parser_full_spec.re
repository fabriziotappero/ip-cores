/* GECKO3COM
 *
 * Copyright (C) 2009 by
 *   ___    ____  _   _
 *  (  _`\ (  __)( ) ( )   
 *  | (_) )| (_  | |_| |   Berne University of Applied Sciences
 *  |  _ <'|  _) |  _  |   School of Engineering and
 *  | (_) )| |   | | | |   Information Technology
 *  (____/'(_)   (_) (_)
 *
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details. 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*********************************************************************/
/** \cond EXAMPLE \file     scpi_parser.re
 *********************************************************************
 * \brief     Parser for the SCPI commands. Excecutes the necessary 
 *            Function.
 *
 *            The SCPI Parser is developed as a set of regular 
 *            expressions and blocks of C code to excecute. \n
 *            We use the opensource programm re2c (http://re2c.org/) to
 *            generate the parser. With solution we have an easy to 
 *            maintain and extend parser definitions without the hassle 
 *            of optimizing the parser sourcecode by hand. \n \n
 *            Don't forget to use the "-s" option with re2c to generate
 *            nested ifs for some switches because sdcc hates long 
 *            switch case structures.
 *
 * \todo      use newer re2c to generate state event diagramm to include here
 *
 * \author    Christoph Zimmermann bfh.ch
 * \date      2009-02-04
 *
 * \endcond
*/

#include <stdint.h>
#include <ctype.h>

#include "scpi_parser.h"
#include "debugprint.h"


#define	YYCTYPE		uint8_t
#define	YYCURSOR	s->cur
#define	YYLIMIT		s->lim
#define	YYMARKER	s->ptr
#define	YYFILL(n)	{YYCURSOR = fill(s, buffer, n);}
/*!max:re2c */          /* this will define YYMAXFILL */


uint8_t* fill(Scanner *s, int16_t *buffer, uint8_t n){
  uint8_t i = 0;

  for(i;i<n;i++) {
    buffer[i] = tolower(*(s->source));
    s->source++;
  }

  s->cur = buffer;
  s->lim = &buffer[n];

  return s->cur;    
}


int8_t scpi_scan(Scanner *s){

  int8_t buffer[YYMAXFILL];

  /** \cond SCANNER  
   * this is a ugly hack to avoid that the regular expressions are included in 
   * the doxygen documentation
  */

  /*!re2c	

  /* place here the regular expressions to detect the end of a message */

  /* FIXME end detection missing */
  "\n"					{ /* end of message reached */
					  return 99;
					}

  /* this set of regular expressions are for the mandatory IEEE488 commands */

  "*cls"				{ /* clear status command */

					  return 1;  
					}

  "*ese"				{ /* standard event status enable command */

					  return 1;  
					}

  "*ese?"				{ /* standard event status enable query */

					  return 1;  
					}

  "*esr?"				{ /* standard event status register query */

					  return 1;  
					}

  "*idn?"				{ /* identification query */

					  return 1;  
					}

  "*opc"				{ /* operation complete command */

					  return 1;  
					}

  "*opc?"				{ /* operation complete query */

					  return 1;  
					}

  "*rst"				{ /* reset command */

					  return 1;  
					}

  "*sre"				{ /* service request enable command */

					  return 1;  
					}

  "*sre?"				{ /* service request enable query */

					  return 1;  
					}

  "*stb?"				{ /* read status byte query */

					  return 1;  
					}

  "*tst?"				{ /* self-test query */

					  return 1;  
					}

  "*wai"				{ /* wait-to-continue command */

					  return 1;  
					}



  /* this set of regular expressions are for the mandatory SCPI 99 commands */

  "syst:err?"|"syst:err:next?"		{ /* gets an error message if ther is one */
				  	
					  return 1;  
					}

  "syst:vers"				{ /* returns the firmware version number */
				  	
					  return 1;  
					}

  "stat:oper?"|"stat:oper:even?"	{ /* dfsg */
				  	
					  return 1;  
					}

  "stat:oper:cond?"			{ // fsdgsg
				  	
					  return 1;  
					}

  "stat:oper:enab"			{ // sfgsdf
				  	
					  return 1;  
					}

  "stat:oper:enab?"			{ // sfgfsdg
				  	
					  return 1;  
					}

  "stat:ques?"|"stat:ques:even?"	{ // sfgfsdg
				  	
					  return 1;  
					}

  "stat:ques:cond?"			{ // sfgsdfg
				  	
					  return 1;  
					}

  "stat:ques:enab"			{ // sfgsdfg
				  	
					  return 1;  
					}

  "stat:ques:enab?"			{ // sfgfg
				  	
					  return 1;  
					}

  "stat:pres"				{ // sfgfg
				  	
					  return 1;  
					}



  /* this set of regular expressions are for the device functions */


  "diag:mes?" 	       		       	{ /* ask if there is a message to read available */
				  	  print_info("scpi: diag:mes?\n"); 
					  return 1;  
					}

  "diag:mes"				{ /* reads the message from the message buffer */
				  	  print_info("scpi: diag:mes\n"); 
				  	  return 1; 
					}

  "diag:gpif?"				{ /* reads the GPIF state */
				  	  print_info("scpi: diag:gpif?\n"); 
					  return 1; 
					}

*/

/** \endcond */
}
