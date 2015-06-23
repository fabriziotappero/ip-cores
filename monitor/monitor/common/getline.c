/*
 * getline.c -- line input
 */


#include "common.h"
#include "stdarg.h"
#include "romlib.h"
#include "getline.h"


#define MAX_HISTORY	20


static char history[MAX_HISTORY][80];
static int historyIndex;  /* next line to be written */


/*
 * Get a line from the console.
 */
char *getLine(char *prompt) {
  static char line[80];
  int index;
  int historyPointer;
  char c;
  int i;

  printf(prompt);
  index = 0;
  historyPointer = historyIndex;
  while (1) {
    c = getchar();
    switch (c) {
      case '\r':
        putchar('\n');
        line[index] = '\0';
        return line;
      case '\b':
      case 0x7F:
        if (index == 0) {
          break;
        }
        putchar('\b');
        putchar(' ');
        putchar('\b');
        index--;
        break;
      case 'P' & ~0x40:
        if (historyPointer == historyIndex) {
          line[index] = '\0';
          strcpy(history[historyIndex], line);
        }
        i = historyPointer - 1;
        if (i == -1) {
          i = MAX_HISTORY - 1;
        }
        if (i == historyIndex) {
          putchar('\a');
          break;
        }
        if (history[i][0] == '\0') {
          putchar('\a');
          break;
        }
        historyPointer = i;
        strcpy(line, history[historyPointer]);
        printf("\r");
        for (i = 0; i < 79; i++) {
          printf(" ");
        }
        printf("\r");
        printf(prompt);
        printf(line);
        index = strlen(line);
        break;
      case 'N' & ~0x40:
        if (historyPointer == historyIndex) {
          putchar('\a');
          break;
        }
        i = historyPointer + 1;
        if (i == MAX_HISTORY) {
          i = 0;
        }
        historyPointer = i;
        strcpy(line, history[historyPointer]);
        printf("\r");
        for (i = 0; i < 79; i++) {
          printf(" ");
        }
        printf("\r");
        printf(prompt);
        printf(line);
        index = strlen(line);
        break;
      default:
        if (c == '\t') {
          c = ' ';
        }
        if (c < 0x20 || c > 0x7E) {
          break;
        }
        putchar(c);
        line[index++] = c;
        break;
    }
  }
  /* never reached */
  return NULL;
}


/*
 * Add a line to the history.
 * Don't do this if the line is empty, or if its
 * contents exactly match the previous line.
 */
void addHist(char *line) {
  int lastWritten;

  if (*line == '\0') {
    return;
  }
  lastWritten = historyIndex - 1;
  if (lastWritten == -1) {
    lastWritten = MAX_HISTORY - 1;
  }
  if (strcmp(history[lastWritten], line) == 0) {
    return;
  }
  strcpy(history[historyIndex], line);
  if (++historyIndex == MAX_HISTORY) {
    historyIndex = 0;
  }
}
