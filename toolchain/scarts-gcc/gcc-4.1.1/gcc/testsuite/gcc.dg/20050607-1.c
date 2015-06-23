/* { dg-do compile } */
/* { dg-options "-Wpadded" }
/* { dg-skip-if "trampolines not supported" { "scarts_32-*-*" || "scarts_16-*-*" } { "*" } { "" } } */
/* The struct internally constructed for the nested function should
   not result in a warning from -Wpadded. */
extern int baz(int (*) (int));
int foo(void)
{
  int k = 3;
  int bar(int x) {
    return x + k;
  }
  return baz(bar);
}
