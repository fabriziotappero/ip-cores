#include "assert.h"
#include "ctype.h"
#include "stdio.h"
#include "string.h"

//-----------------------------------------------------------------------------
int
main(int argc, const char * argv)
{
char buffer[2000];
int pc, val, val2;

   for (;;)
       {
         char * s = fgets(buffer, sizeof(buffer) - 2, stdin);
         if (s == 0)   return 0;

         // map lines '  xx:' and 'xxxxxxxx; to 2* the hex value.
         //
         if (
             (isxdigit(s[0]) || s[0] == ' ') &&
             (isxdigit(s[1]) || s[1] == ' ') &&
             (isxdigit(s[2]) || s[2] == ' ') &&
              isxdigit(s[3]) && s[4] == ':')   // '  xx:'
            {
              assert(1 == sscanf(s, " %x:", &pc));
              if (pc & 1)       printf("%4X+:", pc/2);
              else              printf("%4X:", pc/2);
              s += 5;
            }
         else if (isxdigit(s[0]) && isxdigit(s[1]) && isxdigit(s[2]) &&
                  isxdigit(s[3]) && isxdigit(s[4]) && isxdigit(s[5]) &&
                  isxdigit(s[6]) && isxdigit(s[7]))             // 'xxxxxxxx'
            {
              assert(1 == sscanf(s, "%x", &pc));
              if (pc & 1)   printf("%8.8X+:", pc/2);
              else          printf("%8.8X:", pc/2);
              s += 8;
            }
         else                             // other: copy verbatim
            {
              printf("%s", s);
              continue;
            }

          while (isblank(*s))   printf("%c", *s++);

          // endian swap.
          //
          while (isxdigit(s[0]) &&
                 isxdigit(s[1]) &&
                          s[2] == ' ' &&
                 isxdigit(s[3]) &&
                 isxdigit(s[4]) &&
                          s[5] == ' ')
             {
              assert(2 == sscanf(s, "%x %x ", &val, &val2));
              printf("%2.2X%2.2X  ", val2, val);
              s += 6;
             }

         char * s1 = strstr(s, ".+");
         char * s2 = strstr(s, ".-");
         if (s1)
            {
              assert(1 == sscanf(s1 + 2, "%d", &val));
              assert((val & 1) == 0);
              sprintf(s1, " 0x%X", (pc + val)/2 + 1);
              printf(s);
              s = s1 + strlen(s1) + 1;
            }
         else if (s2)
            {
              assert(1 == sscanf(s2 + 2, "%d", &val));
              assert((val & 1) == 0);
              sprintf(s2, " 0x%X", (pc - val)/2 + 1);
              printf(s);
              s = s2 + strlen(s2) + 1;
            }

         printf("%s", s);
       }
}
//-----------------------------------------------------------------------------
