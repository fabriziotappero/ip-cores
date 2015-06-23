//
//
//


//-----------------------------------------------------------------------------
// String functions. Some of these are duplicates of the same functions in
// the I18N package.

// Validate a hex character
__inline__ static bool
_is_hex(char c)
{
    return (((c >= '0') && (c <= '9')) ||
            ((c >= 'A') && (c <= 'F')) ||            
            ((c >= 'a') && (c <= 'f')));
}

// Convert a single hex nibble
__inline__ static int
_from_hex(char c) 
{
    int ret = 0;

    if ((c >= '0') && (c <= '9')) {
        ret = (c - '0');
    } else if ((c >= 'a') && (c <= 'f')) {
        ret = (c - 'a' + 0x0a);
    } else if ((c >= 'A') && (c <= 'F')) {
        ret = (c - 'A' + 0x0A);
    }
    return ret;
}

// Convert a character to lower case
__inline__ static char
_tolower(char c)
{
    if ((c >= 'A') && (c <= 'Z')) {
        c = (c - 'A') + 'a';
    }
    return c;
}

// Validate alpha
__inline__ static bool
isalpha(int c)
{
    return (((c >= 'a') && (c <= 'z')) || 
            ((c >= 'A') && (c <= 'Z')));
}

// Validate digit
__inline__ static bool
isdigit(int c)
{
    return ((c >= '0') && (c <= '9'));
}

// Validate alphanum
__inline__ static bool
isalnum(int c)
{
    return (isalpha(c) || isdigit(c));
}

