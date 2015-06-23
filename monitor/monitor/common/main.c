/*
 * main.c -- the main program
 */


#include "common.h"
#include "stdarg.h"
#include "romlib.h"
#include "command.h"
#include "getline.h"
#include "instr.h"
#include "cpu.h"


#define VERSION		"1.06"
#define PROMPT		"ECO32 > "


int main(void) {
  char *line;

  printf("\n\nECO32 Machine Monitor %s\n\n", VERSION);
  initInstrTable();
  cpuSetPC(0xC0010000);
  cpuSetPSW(0x08000000);
  while (1) {
    line = getLine(PROMPT);
    addHist(line);
    execCommand(line);
  }
  return 0;
}
