/*
 * main.c -- ECO32 simulator
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common.h"
#include "console.h"
#include "error.h"
#include "command.h"
#include "instr.h"
#include "cpu.h"
#include "trace.h"
#include "mmu.h"
#include "memory.h"
#include "timer.h"
#include "dspkbd.h"
#include "serial.h"
#include "disk.h"
#include "output.h"
#include "shutdown.h"
#include "graph.h"


static void usage(char *myself) {
  fprintf(stderr, "Usage: %s\n", myself);
  fprintf(stderr, "    [-i]           set interactive mode\n");
  fprintf(stderr, "    [-m <n>]       install n MB of RAM (1-%d)\n",
          RAM_SIZE_MAX / M);
  fprintf(stderr, "    [-l <prog>]    set program file name\n");
  fprintf(stderr, "    [-a <addr>]    set program load address\n");
  fprintf(stderr, "    [-r <rom>]     set ROM image file name\n");
  fprintf(stderr, "    [-d <disk>]    set disk image file name\n");
  fprintf(stderr, "    [-s <n>]       install n serial lines (0-%d)\n",
          MAX_NSERIALS);
  fprintf(stderr, "    [-t <k>]       connect terminal to line k (0-%d)\n",
          MAX_NSERIALS - 1);
  fprintf(stderr, "    [-g]           install graphics controller\n");
  fprintf(stderr, "    [-c]           install console\n");
  fprintf(stderr, "    [-o <file>]    bind output device to file\n");
  fprintf(stderr, "The options -l and -r are mutually exclusive.\n");
  fprintf(stderr, "If both are omitted, interactive mode is assumed.\n");
  fprintf(stderr, "Unconnected serial lines can be accessed by opening\n");
  fprintf(stderr, "their corresponding pseudo terminal (path is shown).\n");
  exit(1);
}


int main(int argc, char *argv[]) {
  int i, j;
  char *argp;
  char *endp;
  Bool interactive;
  int memSize;
  char *progName;
  unsigned int loadAddr;
  char *romName;
  char *diskName;
  int numSerials;
  Bool connectTerminals[MAX_NSERIALS];
  Bool graphics;
  Bool console;
  char *outputName;
  Word initialPC;
  char command[20];
  char *line;

  interactive = false;
  memSize = RAM_SIZE_DFL / M;
  progName = NULL;
  loadAddr = 0;
  romName = NULL;
  diskName = NULL;
  numSerials = 0;
  for (j = 0; j < MAX_NSERIALS; j++) {
    connectTerminals[j] = false;
  }
  graphics = false;
  console = false;
  outputName = NULL;
  for (i = 1; i < argc; i++) {
    argp = argv[i];
    if (*argp != '-') {
      usage(argv[0]);
    }
    argp++;
    switch (*argp) {
      case 'i':
        interactive = true;
        break;
      case 'm':
        if (i == argc - 1) {
          usage(argv[0]);
        }
        memSize = strtol(argv[++i], &endp, 10);
        if (*endp != '\0' ||
            memSize <= 0 ||
            memSize > RAM_SIZE_MAX / M) {
          usage(argv[0]);
        }
        break;
      case 'l':
        if (i == argc - 1 || progName != NULL || romName != NULL) {
          usage(argv[0]);
        }
        progName = argv[++i];
        break;
      case 'a':
        if (i == argc - 1) {
          usage(argv[0]);
        }
        loadAddr = strtoul(argv[++i], &endp, 0);
        if (*endp != '\0') {
          usage(argv[0]);
        }
        break;
      case 'r':
        if (i == argc - 1 || romName != NULL || progName != NULL) {
          usage(argv[0]);
        }
        romName = argv[++i];
        break;
      case 'd':
        if (i == argc - 1 || diskName != NULL) {
          usage(argv[0]);
        }
        diskName = argv[++i];
        break;
      case 's':
        if (i == argc - 1) {
          usage(argv[0]);
        }
        numSerials = strtol(argv[++i], &endp, 10);
        if (*endp != '\0' ||
            numSerials < 0 ||
            numSerials > MAX_NSERIALS) {
          usage(argv[0]);
        }
        break;
      case 't':
        if (i == argc - 1) {
          usage(argv[0]);
        }
        j = strtol(argv[++i], &endp, 10);
        if (*endp != '\0' ||
            j < 0 ||
            j > MAX_NSERIALS - 1) {
          usage(argv[0]);
        }
        connectTerminals[j] = true;
        break;
      case 'g':
        graphics = true;
        break;
      case 'c':
        console = true;
        break;
      case 'o':
        if (i == argc - 1 || outputName != NULL) {
          usage(argv[0]);
        }
        outputName = argv[++i];
        break;
      default:
        usage(argv[0]);
    }
  }
  cInit();
  cPrintf("ECO32 Simulator started\n");
  if (progName == NULL && romName == NULL && !interactive) {
    cPrintf("Neither a program to load nor a system ROM was\n");
    cPrintf("specified, so interactive mode is assumed.\n");
    interactive = true;
  }
  for (j = MAX_NSERIALS - 1; j >= 0; j--) {
    if (connectTerminals[j] && j >= numSerials) {
      /* user wants a terminal on a line which is not installed */
      numSerials = j + 1;
      cPrintf("Serial lines 0..%d automatically installed.\n", j);
      break;
    }
  }
  initInstrTable();
  timerInit();
  if (console) {
    displayInit();
    keyboardInit();
  }
  serialInit(numSerials, connectTerminals);
  diskInit(diskName);
  outputInit(outputName);
  shutdownInit();
  if (graphics) {
    graphInit();
  }
  memoryInit(memSize * M, progName, loadAddr, romName);
  mmuInit();
  traceInit();
  if (progName != NULL) {
    initialPC = 0xC0000000 | loadAddr;
  } else {
    initialPC = 0xC0000000 | ROM_BASE;
  }
  cpuInit(initialPC);
  if (!interactive) {
    cPrintf("Start executing...\n");
    strcpy(command, "c\n");
    execCommand(command);
  } else {
    while (1) {
      line = cGetLine("ECO32 > ");
      if (*line == '\0') {
        break;
      }
      cAddHist(line);
      if (execCommand(line)) {
        break;
      }
    }
  }
  cpuExit();
  traceExit();
  mmuExit();
  memoryExit();
  timerExit();
  displayExit();
  keyboardExit();
  serialExit();
  diskExit();
  outputExit();
  shutdownExit();
  graphExit();
  cPrintf("ECO32 Simulator finished\n");
  cExit();
  return 0;
}
