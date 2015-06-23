/*
 * ar.c -- archiver
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>

#include "endian.h"
#include "ranlib.h"
#include "../include/ar.h"


/**************************************************************/


#define BUFSIZE	512

#define SKIP	0x01
#define IODD	0x02
#define OODD	0x04
#define HEAD	0x08


char *com = "drqtpmx";
char *opt = "vuabcls";

int signums[] = { SIGHUP, SIGINT, SIGQUIT, 0 };

void (*comfun)(void);
int flg[26];

char *arnam;
int af;

char **namv;
int namc;

int baState;
char *posName;

char tmp0nam[20];
char tmp1nam[20];
char tmp2nam[20];
char *tf0nam;
char *tf1nam;
char *tf2nam;
int tf0;
int tf1;
int tf2;
int qf;

char *file;
char name[MAX_NAME];

struct stat stbuf;
ArHeader arbuf;
unsigned char buf[BUFSIZE];


/**************************************************************/


#define IFMT	070000
#define SUID	004000
#define SGID	002000
#define STXT	001000
#define ROWN	000400
#define WOWN	000200
#define XOWN	000100
#define RGRP	000040
#define WGRP	000020
#define XGRP	000010
#define ROTH	000004
#define WOTH	000002
#define XOTH	000001


int m1[] = { 1, ROWN, 'r', '-' };
int m2[] = { 1, WOWN, 'w', '-' };
int m3[] = { 2, SUID, 's', XOWN, 'x', '-' };
int m4[] = { 1, RGRP, 'r', '-' };
int m5[] = { 1, WGRP, 'w', '-' };
int m6[] = { 2, SGID, 's', XGRP, 'x', '-' };
int m7[] = { 1, ROTH, 'r', '-' };
int m8[] = { 1, WOTH, 'w', '-' };
int m9[] = { 2, STXT, 't', XOTH, 'x', '-' };

int *m[] = { m1, m2, m3, m4, m5, m6, m7, m8, m9 };


void selectChar(int *pairp) {
  int *ap;
  int n;

  ap = pairp;
  n = *ap++;
  while (--n >= 0 && (arbuf.mode & *ap++) == 0) {
    ap++;
  }
  putchar(*ap);
}


void printMode(void) {
  int **mp;

  for (mp = &m[0]; mp < &m[9]; mp++) {
    selectChar(*mp);
  }
}


void showAttributes(void) {
  char *cp;

  printMode();
  printf("%4d/%4d", arbuf.uid, arbuf.gid);
  printf("%8d", arbuf.size);
  cp = ctime(&arbuf.date);
  printf(" %-12.12s %-4.4s ", cp + 4, cp + 20);
}


/**************************************************************/


void mesg(int c) {
  if (flg['v' - 'a']) {
    printf("%c - %s\n", c, file);
  }
}


char *trim(char *s) {
  char *p1;
  char *p2;

  for (p1 = s; *p1 != '\0'; p1++) ;
  while (p1 > s) {
    if (*--p1 != '/') {
      break;
    }
    *p1 = '\0';
  }
  p2 = s;
  for (p1 = s; *p1 != '\0'; p1++) {
    if (*p1 == '/') {
      p2 = p1 + 1;
    }
  }
  return p2;
}


int notFound(void) {
  int n;
  int i;

  n = 0;
  for (i = 0; i < namc; i++) {
    if (namv[i] != NULL) {
      fprintf(stderr, "ar: %s not found\n", namv[i]);
      n++;
    }
  }
  return n;
}


int moreFiles(void) {
  int n;
  int i;

  n = 0;
  for (i = 0; i < namc; i++) {
    if (namv[i] != NULL) {
      n++;
    }
  }
  return n;
}


void unlinkTempFiles(void) {
  if (tf0nam != NULL) {
    unlink(tf0nam);
  }
  if (tf1nam != NULL) {
    unlink(tf1nam);
  }
  if (tf2nam != NULL) {
    unlink(tf2nam);
  }
}


void done(int c) {
  unlinkTempFiles();
  exit(c);
}


void sigDone(int signum) {
  done(100);
}


void noArchive(void) {
  fprintf(stderr, "ar: %s does not exist\n", arnam);
  done(1);
}


void writeError(void) {
  perror("ar write error");
  done(1);
}


void phaseError(void) {
  fprintf(stderr, "ar: phase error on %s\n", file);
}


int stats(void) {
  int f;

  f = open(file, O_RDONLY);
  if (f < 0) {
    return f;
  }
  if (fstat(f, &stbuf) < 0) {
    close(f);
    return -1;
  }
  return f;
}


int match(void) {
  int i;

  for (i = 0; i < namc; i++) {
    if (namv[i] == NULL) {
      continue;
    }
    if (strcmp(trim(namv[i]), file) == 0) {
      file = namv[i];
      namv[i] = NULL;
      return 1;
    }
  }
  return 0;
}


void baMatch(void) {
  int f;

  if (baState == 1) {
    if (strcmp(file, posName) != 0) {
      return;
    }
    baState = 2;
    if (flg['a' - 'a']) {
      return;
    }
  }
  if (baState == 2) {
    baState = 0;
    tf1nam = mktemp(tmp1nam);
    close(creat(tf1nam, 0600));
    f = open(tf1nam, O_RDWR);
    if (f < 0) {
      fprintf(stderr, "ar: cannot create second temp file\n");
      return;
    }
    tf1 = tf0;
    tf0 = f;
  }
}


/**************************************************************/


void init(void) {
  unsigned int mbuf;

  write4ToEco((unsigned char *) &mbuf, AR_MAGIC);
  tf0nam = mktemp(tmp0nam);
  close(creat(tf0nam, 0600));
  tf0 = open(tf0nam, O_RDWR);
  if (tf0 < 0) {
    fprintf(stderr, "ar: cannot create temp file\n");
    done(1);
  }
  if (write(tf0, &mbuf, sizeof(mbuf)) != sizeof(mbuf)) {
    writeError();
  }
}


int getArchive(void) {
  unsigned int mbuf;

  af = open(arnam, O_RDONLY);
  if (af < 0) {
    return 1;
  }
  if (read(af, &mbuf, sizeof(mbuf)) != sizeof(mbuf) ||
      read4FromEco((unsigned char *) &mbuf) != AR_MAGIC) {
    fprintf(stderr, "ar: %s not in archive format\n", arnam);
    done(1);
  }
  return 0;
}


void getQuick(void) {
  unsigned int mbuf;

  qf = open(arnam, O_RDWR);
  if (qf < 0) {
    if (!flg['c' - 'a']) {
      fprintf(stderr, "ar: creating %s\n", arnam);
    }
    close(creat(arnam, 0666));
    qf = open(arnam, O_RDWR);
    if (qf < 0) {
      fprintf(stderr, "ar: cannot create %s\n", arnam);
      done(1);
    }
    write4ToEco((unsigned char *) &mbuf, AR_MAGIC);
    if (write(qf, &mbuf, sizeof(mbuf)) != sizeof(mbuf)) {
      writeError();
    }
  } else
  if (read(qf, &mbuf, sizeof(mbuf)) != sizeof(mbuf) ||
      read4FromEco((unsigned char *) &mbuf) != AR_MAGIC) {
    fprintf(stderr, "ar: %s not in archive format\n", arnam);
    done(1);
  }
}


int getMember(void) {
  int i;

  i = read(af, &arbuf, sizeof(arbuf));
  if (i != sizeof(arbuf)) {
    if (tf1nam != NULL) {
      i = tf0;
      tf0 = tf1;
      tf1 = i;
    }
    return 1;
  }
  conv4FromEcoToNative((unsigned char *) &arbuf.date);
  conv4FromEcoToNative((unsigned char *) &arbuf.uid);
  conv4FromEcoToNative((unsigned char *) &arbuf.gid);
  conv4FromEcoToNative((unsigned char *) &arbuf.mode);
  conv4FromEcoToNative((unsigned char *) &arbuf.size);
  for (i = 0; i < MAX_NAME; i++) {
    name[i] = arbuf.name[i];
  }
  file = name;
  return 0;
}


void copyFile(int fi, int fo, int flags) {
  int pe;
  int icount, ocount;
  int pad;

  if (flags & HEAD) {
    conv4FromNativeToEco((unsigned char *) &arbuf.date);
    conv4FromNativeToEco((unsigned char *) &arbuf.uid);
    conv4FromNativeToEco((unsigned char *) &arbuf.gid);
    conv4FromNativeToEco((unsigned char *) &arbuf.mode);
    conv4FromNativeToEco((unsigned char *) &arbuf.size);
    if (write(fo, &arbuf, sizeof(arbuf)) != sizeof(arbuf)) {
      writeError();
    }
    conv4FromEcoToNative((unsigned char *) &arbuf.date);
    conv4FromEcoToNative((unsigned char *) &arbuf.uid);
    conv4FromEcoToNative((unsigned char *) &arbuf.gid);
    conv4FromEcoToNative((unsigned char *) &arbuf.mode);
    conv4FromEcoToNative((unsigned char *) &arbuf.size);
  }
  pe = 0;
  while (arbuf.size > 0) {
    icount = ocount = BUFSIZE;
    if (arbuf.size < icount) {
      icount = ocount = arbuf.size;
      pad = -icount & 0x03;
      if (flags & IODD) {
        icount += pad;
      }
      if (flags & OODD) {
        ocount += pad;
      }
    }
    if (read(fi, buf, icount) != icount) {
      pe++;
    }
    if ((flags & SKIP) == 0) {
      if (write(fo, buf, ocount) != ocount) {
        writeError();
      }
    }
    arbuf.size -= BUFSIZE;
  }
  if (pe != 0) {
    phaseError();
  }
}


void moveFile(int f) {
  char *cp;
  int i;

  cp = trim(file);
  for (i = 0; i < MAX_NAME; i++) {
    if ((arbuf.name[i] = *cp) != '\0') {
      cp++;
    }
  }
  arbuf.size = stbuf.st_size;
  arbuf.date = stbuf.st_mtime;
  arbuf.uid = stbuf.st_uid;
  arbuf.gid = stbuf.st_gid;
  arbuf.mode = stbuf.st_mode;
  copyFile(f, tf0, OODD | HEAD);
  close(f);
}


void install(void) {
  int i;

  for (i = 0; signums[i] != 0; i++) {
    signal(signums[i], SIG_IGN);
  }
  if (af < 0) {
    if (!flg['c' - 'a']) {
      fprintf(stderr, "ar: creating %s\n", arnam);
    }
  }
  close(af);
  af = creat(arnam, 0666);
  if (af < 0) {
    fprintf(stderr, "ar: cannot create %s\n", arnam);
    done(1);
  }
  if (tf0nam != NULL) {
    lseek(tf0, 0, SEEK_SET);
    while ((i = read(tf0, buf, BUFSIZE)) > 0) {
      if (write(af, buf, i) != i) {
        writeError();
      }
    }
  }
  if (tf2nam != NULL) {
    lseek(tf2, 0, SEEK_SET);
    while ((i = read(tf2, buf, BUFSIZE)) > 0) {
      if (write(af, buf, i) != i) {
        writeError();
      }
    }
  }
  if (tf1nam != NULL) {
    lseek(tf1, 0, SEEK_SET);
    while ((i = read(tf1, buf, BUFSIZE)) > 0) {
      if (write(af, buf, i) != i) {
        writeError();
      }
    }
  }
}


void cleanup(void) {
  int i;
  int f;

  for (i = 0; i < namc; i++) {
    file = namv[i];
    if (file == NULL) {
      continue;
    }
    namv[i] = NULL;
    mesg('a');
    f = stats();
    if (f < 0) {
      fprintf(stderr, "ar: cannot open %s\n", file);
      continue;
    }
    moveFile(f);
  }
}


/**************************************************************/


void dCmd(void) {
  init();
  if (getArchive()) {
    noArchive();
  }
  while (!getMember()) {
    if (match()) {
      mesg('d');
      copyFile(af, -1, IODD | SKIP);
      continue;
    }
    mesg('c');
    copyFile(af, tf0, IODD | OODD | HEAD);
  }
  install();
}


void rCmd(void) {
  int f;

  init();
  getArchive();
  while (!getMember()) {
    baMatch();
    if (namc == 0 || match()) {
      f = stats();
      if (f < 0) {
        if (namc != 0) {
          fprintf(stderr, "ar: cannot open %s\n", file);
        }
        goto cp;
      }
      if (flg['u' - 'a']) {
        if (stbuf.st_mtime <= arbuf.date) {
          close(f);
          goto cp;
        }
      }
      mesg('r');
      copyFile(af, -1, IODD | SKIP);
      moveFile(f);
      continue;
    }
cp:
    mesg('c');
    copyFile(af, tf0, IODD | OODD | HEAD);
  }
  cleanup();
  install();
}


void qCmd(void) {
  int i;
  int f;

  if (flg['a' - 'a'] || flg['b' - 'a']) {
    fprintf(stderr, "ar: [ab] not allowed with -q\n");
    done(1);
  }
  getQuick();
  for (i = 0; signums[i] != 0; i++) {
    signal(signums[i], SIG_IGN);
  }
  lseek(qf, 0, SEEK_END);
  for (i = 0; i < namc; i++) {
    file = namv[i];
    if (file == NULL) {
      continue;
    }
    namv[i] = NULL;
    mesg('q');
    f = stats();
    if (f < 0) {
      fprintf(stderr, "ar: cannot open %s\n", file);
      continue;
    }
    tf0 = qf;
    moveFile(f);
    qf = tf0;
  }
}


void tCmd(void) {
  if (getArchive()) {
    noArchive();
  }
  while (!getMember()) {
    if (namc == 0 || match()) {
      if (flg['v' - 'a']) {
        showAttributes();
      }
      printf("%s\n", trim(file));
    }
    copyFile(af, -1, IODD | SKIP);
  }
}


void pCmd(void) {
  if (getArchive()) {
    noArchive();
  }
  while (!getMember()) {
    if (namc == 0 || match()) {
      if (flg['v' - 'a']) {
        printf("\n<%s>\n\n", file);
        fflush(stdout);
      }
      copyFile(af, 1, IODD);
      continue;
    }
    copyFile(af, -1, IODD | SKIP);
  }
}


void mCmd(void) {
  init();
  if (getArchive()) {
    noArchive();
  }
  tf2nam = mktemp(tmp2nam);
  close(creat(tf2nam, 0600));
  tf2 = open(tf2nam, O_RDWR);
  if (tf2 < 0) {
    fprintf(stderr, "ar: cannot create third temp file\n");
    done(1);
  }
  while (!getMember()) {
    baMatch();
    if (match()) {
      mesg('m');
      copyFile(af, tf2, IODD | OODD | HEAD);
      continue;
    }
    mesg('c');
    copyFile(af, tf0, IODD | OODD | HEAD);
  }
  install();
}


void xCmd(void) {
  int f;

  if (getArchive()) {
    noArchive();
  }
  while (!getMember()) {
    if (namc == 0 || match()) {
      f = creat(file, arbuf.mode & 0777);
      if (f < 0) {
        fprintf(stderr, "ar: cannot create %s\n", file);
        goto sk;
      }
      mesg('x');
      copyFile(af, f, IODD);
      close(f);
      continue;
    }
sk:
    mesg('c');
    copyFile(af, -1, IODD | SKIP);
    if (namc > 0 && !moreFiles()) {
      done(0);
    }
  }
}


/**************************************************************/

/* specialized r command for updating symbols */


int exec_rCmd(int create, char *args[]) {
  int i;
  int res;

  /* reset all global variables */
  comfun = NULL;
  for (i = 0; i < 26; i++) {
    flg[i] = 0;
  }
  arnam = NULL;
  af = 0;
  namv = NULL;
  namc = 0;
  baState = 0;
  posName = NULL;
  for (i = 0; i < 20; i++) {
    tmp0nam[i] = '\0';
    tmp1nam[i] = '\0';
    tmp2nam[i] = '\0';
  }
  tf0nam = NULL;
  tf1nam = NULL;
  tf2nam = NULL;
  tf0 = 0;
  tf1 = 0;
  tf2 = 0;
  qf = 0;
  file = NULL;
  for (i = 0; i < MAX_NAME; i++) {
    name[i] = '\0';
  }
  /* prepare arguments, call r command, cleanup */
  comfun = rCmd;
  flg['l' - 'a'] = 1;
  strcpy(tmp0nam, "v0XXXXXX");
  strcpy(tmp1nam, "v1XXXXXX");
  strcpy(tmp2nam, "v2XXXXXX");
  if (create) {
    /* ar -rlb firstName archive TEMP_NAME */
    flg['b' - 'a'] = 1;
    baState = 1;
    posName = trim(args[0]);
    arnam = args[1];
    namv = &args[2];
    namc = 1;
  } else {
    /* ar -rl archive TEMP_NAME */
    arnam = args[0];
    namv = &args[1];
    namc = 1;
  }
  (*comfun)();
  res = notFound();
  unlinkTempFiles();
  return res;
}


/**************************************************************/


void usage(void) {
  printf("usage: ar -[%s][%s] archive files ...\n", com, opt);
  done(1);
}


void setcom(void (*fun)(void)) {
  if (comfun != NULL) {
    fprintf(stderr, "ar: only one of [%s] allowed\n", com);
    done(1);
  }
  comfun = fun;
}


int cmdCanChangeSymbols(void) {
  return comfun == dCmd ||
         comfun == rCmd ||
         comfun == mCmd;
}


int main(int argc, char *argv[]) {
  int i;
  char *cp;
  int res;

  for (i = 0; signums[i] != 0; i++) {
    if (signal(signums[i], SIG_IGN) != SIG_IGN) {
      signal(signums[i], sigDone);
    }
  }
  strcpy(tmp0nam, "/tmp/v0XXXXXX");
  strcpy(tmp1nam, "/tmp/v1XXXXXX");
  strcpy(tmp2nam, "/tmp/v2XXXXXX");
  if (argc < 3 || *argv[1] != '-') {
    usage();
  }
  for (cp = argv[1] + 1; *cp != '\0'; cp++) {
    switch (*cp) {
      case 'd':
        setcom(dCmd);
        break;
      case 'r':
        setcom(rCmd);
        break;
      case 'q':
        setcom(qCmd);
        break;
      case 't':
        setcom(tCmd);
        break;
      case 'p':
        setcom(pCmd);
        break;
      case 'm':
        setcom(mCmd);
        break;
      case 'x':
        setcom(xCmd);
        break;
      case 'v':
      case 'u':
      case 'a':
      case 'b':
      case 'c':
      case 'l':
      case 's':
        flg[*cp - 'a'] = 1;
        break;
      default:
        fprintf(stderr, "ar: bad option '%c'\n", *cp);
        done(1);
    }
  }
  if (flg['l' - 'a']) {
    strcpy(tmp0nam, "v0XXXXXX");
    strcpy(tmp1nam, "v1XXXXXX");
    strcpy(tmp2nam, "v2XXXXXX");
  }
  if (flg['a' - 'a'] || flg['b' - 'a']) {
    baState = 1;
    posName = trim(argv[2]);
    argv++;
    argc--;
    if (argc < 3) {
      usage();
    }
  }
  arnam = argv[2];
  namv = argv + 3;
  namc = argc - 3;
  if (comfun == NULL && !flg['s' - 'a']) {
    fprintf(stderr, "ar: one of [%ss] must be specified\n", com);
    done(1);
  }
  res = 0;
  if (comfun != NULL) {
    (*comfun)();
    res = notFound();
    unlinkTempFiles();
    if (res != 0) {
      return res;
    }
  }
  if (flg['s' - 'a'] ||
      (cmdCanChangeSymbols() && hasSymbols(arnam))) {
    res = updateSymbols(arnam, flg['v' - 'a']);
  }
  return res;
}
