// <File Header>
// </File Header>

// <File Info>
// </File Info>

// <File Body>
// Maximum length of tag scanning error messages.
#define TAG_SCAN_MSG_MAX_LEN 100
// Tag scanning error codes.
#define TAG_SCAN_OK                0
#define TAG_SCAN_TAG_NOT_FOUND     1
#define TAG_SCAN_MULTIPLE_TAG      2
#define TAG_SCAN_END_BEFORE_BEGIN  3
#define TAG_SCAN_FILE_NOT_FOUND    4
#define TAG_SCAN_MALLOC_ERR        5
#define TAG_SCAN_FILE_IO_ERR       6
#define TAG_SCAN_UNKNOWN_ERR      -1

// Configure the tag scan utility through these defines.
#define ALLOW_MULTIPLE_MATCH 0   // !!! This feature is not yet implemented.



typedef struct {
   int errCode;
   char *errMsg;
   char *readText;
}  scanTag_t;



// scanTag_t public methods
void  scanTag_t_construct      (scanTag_t *stag);
void  scanTag_t_destruct       (scanTag_t *stag);
char *scanTag_t_getStatus      (scanTag_t *stag);
void  scanTag_t_readTaggedText (char *tagBegin, char *tagEnd,                char *fName, scanTag_t *stag);
void  scanTag_t_writeTaggedText(char *tagBegin, char *tagEnd, char *newText, char *fName, scanTag_t *stag);
// </File Body>


// !!! To modify scan tag methods so that no FILE type is involved, but only char*
// !!! introduce new const parameters
//    - multiple_hit_mode: TAG_GET_ALL_MATCHES or TAG_GET_ONE_MATCH. TAG_GET_ONE_MATCH will return error if multiple matches.
//    - case_mode: TAG_CASE_SENSITIVE or TAG_CASE_INSENSITIVE
