

void sys_bashfilename(char *d,char *s) {
  unsigned int c;
  while (c = *s++) {
#ifdef NT
    if (c == '/') c = '\\';
#endif
    *d++ = c;
  }
  *d = 0;
}

void sys_unbashfilename(char *d,char *s) {
  unsigned int c;
  while (c = *s++) {
#ifdef NT
    if (c == '\\') c = '/';
#endif
    *d++ = c;
  }
  *d = 0;
}
