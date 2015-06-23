/* $Id: testbench.cc,v 1.6 2008-04-27 16:04:42 sybreon Exp $
** 
** AEMB Function Verification C++ Testbench
** Copyright (C) 2004-2008 Shawn Tan <shawn.tan@aeste.net>
**
** This file is part of AEMB.
**
** AEMB is free software: you can redistribute it and/or modify it
** under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** AEMB is distributed in the hope that it will be useful, but WITHOUT
** ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
** or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
** License for more details.
**
** You should have received a copy of the GNU General Public License
** along with AEMB.  If not, see <http://www.gnu.org/licenses/>.
*/
/**
AEMB Software Verification
@file testbench.cc

This programme performs numerical and functional verification of the
AEMB. It can be compiled by the GCC compiler.
*/

#include <stdio.h>
#include <stdlib.h>
#include "aemb/core.hh"
#include "literate.hh"
#include "simboard.hh"
#include "corefunc.hh"

#define MAX_TEST 3

void checkcode(int code)
{
  if (code == EXIT_SUCCESS)
    iprintf("\t\t-PASS-\n");
  else
    iprintf("\t\t*FAIL*\n");
}

void printtest(char *msg)
{
  static int count = 1;
  iprintf("\t%d. %s\n",count++, msg);
}

void numtests()
{
  // *** 1. FIBONACCI ***
  printtest("Integer Arithmetic");
  checkcode(fibonacciTest(MAX_TEST));

  // *** 2. EUCLIDEAN ***
  printtest("Integer Factorisation");
  checkcode(euclideanTest(MAX_TEST));

  // *** 3. NEWTON-RHAPSON ***
  printtest("Floating Point Arithmetic");
  checkcode(newtonTest(MAX_TEST));

}

void coretests()
{
  // *** 4. MEMORY-ALLOC ***
  printtest("Memory Allocation");
  checkcode(memoryTest(MAX_TEST));

  // *** 5. INTERRUPT ***
  printtest("Hardware Interrupts");
  checkcode(interruptTest(MAX_TEST));

  // *** 6. EXTENSION ***
  printtest("Accellerator Link");
  checkcode(xslTest(MAX_TEST));

  // *** 7. EXCEPTIONS ***
  printtest("Hardware Exceptions");
  checkcode(exceptionTest(MAX_TEST));
}

// run tests
int main() 
{
  iprintf("AEMB2 32-bit Microprocessor Core Tests\n");
  
  numtests();
  coretests();

  return EXIT_SUCCESS;
}
