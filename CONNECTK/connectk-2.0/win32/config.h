
/*

connectk -- UMN CSci 5512W project

*/

/* Cannot take SVG screenshots with outdated Cairo DLLs -- it prevents the program
   from starting! */
#define NO_CAIRO_SVG

/* g_mutex_trylock() breaks the AI thread on Windows */
#define NO_TRYLOCK

/* The Visual Studio compiler generates warnings that we can safely ignore:
   4200 -- zero-sized array in struct 
   4244 -- conversion from double to int */
#pragma warning( disable : 4200 4244 )
