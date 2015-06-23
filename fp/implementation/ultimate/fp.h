/*
 * fp.h -- floating point arithmetic
 */


typedef enum {
  false, true
} bool;

typedef unsigned int tetra;

typedef struct {
  tetra h, l;
} octa;

typedef enum {
  zro, num, inf, nan
} ftype;


octa oplus (octa, octa);
octa ominus (octa, octa);
octa incr (octa, int);
octa shift_left (octa, int);
octa shift_right (octa, int, int);
octa omult (octa, octa);
octa signed_omult (octa, octa);
octa odiv (octa, octa, octa);
octa signed_odiv (octa, octa);
octa oand (octa, octa);
octa oandn (octa, octa);
octa oxor (octa, octa);
int count_bits (tetra);
tetra byte_diff (tetra, tetra);
tetra wyde_diff (tetra, tetra);
octa bool_mult (octa, octa, bool);
octa fpack (octa, int, char, int);
tetra sfpack (octa, int, char, int);
ftype funpack (octa, octa *, int *, char *);
ftype sfunpack (tetra, octa *, int *, char *);
octa load_sf (tetra);
tetra store_sf (octa);
octa fmult (octa, octa);
octa fdivide (octa, octa);
octa fplus (octa, octa);
int fepscomp (octa, octa, octa, int);
void print_float (octa);
int scan_const (char *);
int fcomp (octa, octa);
octa fintegerize (octa, int);
octa fixit (octa, int);
octa floatit (octa, int, int, int);
octa froot (octa, int);
octa fremstep (octa, octa, int);
