// Recursively compute fibonnaci sequence, using a 
// really inefficient algorithm.
// (Stack exercise test)

#include "tv80_env.h"

int answers[] = { 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144,
                  233, 377, 610, 987, 1597, 2584, 4181 };

int fib (int n)
{
  int rv;
  timeout_port = 0x02;

  if (n < 2) rv = n;
  else rv = fib(n-1) + fib(n-2);

  timeout_port = 0x01;
  return rv;
}

int main ()
{
  int fn, fr;
  char pass;

  set_timeout (60000);
  pass = 1;

  for (fn = 1; fn < 20; fn++) {
    print ("Computing Fibonacci number ");
    print_num (fn);
    print ("\n");
    
    fr = fib(fn);
    print ("Number is: ");
    print_num (fr);

    if (fr == answers[fn-1]) {
      print (" (correct)\n");
    } else {
      print (" (incorrect)\n");
      print ("Correct result: ");
      print_num (answers[fn-1]);
      pass = 0;
      print ("\n");
    }
  }

  if (pass)
    sim_ctl (SC_TEST_PASSED);
  else
    sim_ctl (SC_TEST_FAILED);
}
