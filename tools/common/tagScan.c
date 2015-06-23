// <File Header>
// </File Header>

// <File Info>
// </File Info>

// <File Body>
#include <string.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include "tagScan.h"

// File IO operations (read/write) occur in chunks of FILE_IO_DATA_CHUNK.
// A tag must be shorter than FILE_IO_DATA_CHUNK/2.
#define FILE_IO_DATA_CHUNK 1000



// scanTag_t private methods

void scanTag_t_setStatus(scanTag_t *stag, int errCode)
{
   stag->errCode = errCode;
   switch (stag->errCode)
   {
      case TAG_SCAN_OK:
      {
         strcpy(stag->errMsg, "Tag scanning OK.\n");
      }; break;
      case TAG_SCAN_TAG_NOT_FOUND:
      {
         strcpy(stag->errMsg, "Tag scanning error: could not find tag.\n");
      }; break;
      case TAG_SCAN_MULTIPLE_TAG:
      {
         strcpy(stag->errMsg, "Tag scanning error: multiple tag match.\n");
      }; break;
      case TAG_SCAN_END_BEFORE_BEGIN:
      {
         strcpy(stag->errMsg, "Tag scanning error: `end' tag before `begin' tag.\n");
      }; break;
      case TAG_SCAN_FILE_NOT_FOUND:
      {
         strcpy(stag->errMsg, "Tag scanning error: file not found.");
      }; break;
      case TAG_SCAN_MALLOC_ERR:
      {
         strcpy(stag->errMsg, "Tag scanning error: could not allocate memory.\n");
      }; break;
      case TAG_SCAN_FILE_IO_ERR:
      {
         strcpy(stag->errMsg, "Tag scanning error: file IO error.\n");
      }; break;
      default:
      {
         strcpy(stag->errMsg, "Unknown error during tag scanning.");
      }; break;
   }
}



long int scanTag_t_findNextTag(char* tag, long int crtPos, FILE* fStr, scanTag_t *stag)
{
   char str1[FILE_IO_DATA_CHUNK+2];
   char *stringPos1, *stringPos2, *stringPos3;
   long int retVal, str1offset, str1offsetTot;
   long int nrItemsRead;
   int tagFound;
   int partialMatch;
   int fStrEOF;

   retVal = crtPos;
   if (fseek(fStr, crtPos, SEEK_SET)==0)
   {
      tagFound = 0;
      fStrEOF=0;
      while ((tagFound==0) && (fStrEOF==0))
      {
         nrItemsRead = fread(str1, 1, FILE_IO_DATA_CHUNK, fStr);
         if (nrItemsRead!=FILE_IO_DATA_CHUNK) fStrEOF=1;
         str1[nrItemsRead] = NULL;
         str1offset = 0;
         str1offsetTot = 0;

         stringPos1 = str1;
         while ((tagFound==0) && (*stringPos1!=NULL))
         {
            stringPos2 = tag;
            str1offset = str1offsetTot;
            partialMatch = 0;
            while ((tagFound==0) && (*stringPos1!=NULL) && (*stringPos2!=NULL))
            {
               if (*stringPos1==*stringPos2)
               {
                  partialMatch = 1;
                  stringPos1++;
                  stringPos2++;
                  str1offsetTot++;
                  if (*stringPos2==NULL)
                  {
                     tagFound = 1;
                     retVal = ftell(fStr)-nrItemsRead+str1offset;
                     break;
                  }
               }
               else
               {
                  if (partialMatch==0)
                  {
                     stringPos1++;
                     str1offset++;
                     str1offsetTot++;
                  }
                  partialMatch = 0;
                  break;
               }
            }
         }
         if (tagFound==0)
         {
            // Tag not found in this data chunk.
            // Rewind with twice tag's length and get a new data chunk.
            fseek(fStr, -2*strlen(tag), SEEK_CUR);
         }
      }
   }
   if (tagFound == 0)
      scanTag_t_setStatus(stag, TAG_SCAN_TAG_NOT_FOUND);
   return retVal;
}



long int scanTag_t_findTag(char *tag, FILE *fStr, scanTag_t *stag)
{
   long int pos1, pos2;

   pos1 = 0;
   pos2 = scanTag_t_findNextTag(tag, pos1, fStr, stag);
   // Does that tag appear at least once?
   if (stag->errCode == TAG_SCAN_OK) {
      // Yes, the tag appears at least once.
      scanTag_t_findNextTag(tag, pos2+strlen(tag), fStr, stag);
      // Does that tag appear exactly once?
      if (stag->errCode == TAG_SCAN_TAG_NOT_FOUND) {
         // Yes, the tag appears exactly once. Reset status to OK.
         scanTag_t_setStatus(stag, TAG_SCAN_OK);
         return pos2;
      }
      else {
         // No, multiple tag matched.
         scanTag_t_setStatus(stag, TAG_SCAN_MULTIPLE_TAG);
         return 0;
      }
   }
   else {
      // No, tag not found.
      scanTag_t_setStatus(stag, TAG_SCAN_TAG_NOT_FOUND);
      return 0;
   }
}



// scanTag_t public methods

void scanTag_t_construct(scanTag_t *stag)
{
   stag->readText = (char *) malloc(1);
   if (stag->readText==NULL)
   {
      fprintf(stdout, "Error: could not allocate memory. Exitting...\n");
      exit(1);
   }
   stag->errMsg = (char*) malloc(TAG_SCAN_MSG_MAX_LEN);
   if (stag->errMsg==NULL)
   {
      fprintf(stdout, "Error: could not allocate memory. Exitting...\n");
      exit(1);
   }
   scanTag_t_setStatus(stag, TAG_SCAN_OK);
}



void scanTag_t_destruct(scanTag_t *stag)
{
   free(stag->readText);
   free(stag->errMsg);
}



char *scanTag_t_getStatus(scanTag_t *stag)
{
   return stag->errMsg;
}



void scanTag_t_readTaggedText(char *tagBegin, char *tagEnd, char *fName, scanTag_t *stag)
{
   long int pos1, pos2;
   FILE *fStr;
   long int nrItemsRead;

   scanTag_t_setStatus(stag, TAG_SCAN_OK);
   fStr = fopen(fName, "rb");
   if (fStr != NULL)
   {
      pos1 = scanTag_t_findTag(tagBegin, fStr, stag);
      pos2 = scanTag_t_findTag(tagEnd, fStr, stag);
      if (stag->errCode == TAG_SCAN_OK)
      {
         if ((long int)(pos1+strlen(tagBegin))<=pos2)
         {
            free(stag->readText);
            stag->readText = (char*) malloc(pos2-pos1-strlen(tagBegin)+2);
            if (stag->readText!=NULL)
            {
               fseek(fStr, pos1+strlen(tagBegin), SEEK_SET);
               nrItemsRead = fread(stag->readText, 1, pos2-pos1-strlen(tagBegin), fStr);
               if (nrItemsRead == (long int)(pos2-pos1-strlen(tagBegin)))
               {
                  stag->readText[pos2-pos1-strlen(tagBegin)] = NULL;
                  fclose(fStr);
               }
               else
               {
                  scanTag_t_setStatus(stag, TAG_SCAN_UNKNOWN_ERR);
                  fclose(fStr);
               }
            }
            else
            {
               scanTag_t_setStatus(stag, TAG_SCAN_MALLOC_ERR);
               fclose(fStr);
            }
         }
         else
         {
            scanTag_t_setStatus(stag, TAG_SCAN_END_BEFORE_BEGIN);
            fclose(fStr);
         }
      }
   }
   else
   {
      scanTag_t_setStatus(stag, TAG_SCAN_FILE_NOT_FOUND);
   }
}



void scanTag_t_writeTaggedText(char* tag_begin, char* tag_end, char* newText, char* fName, scanTag_t* stag)
{
   long int pos1, pos2;
   FILE *fSrc, *fDst;
   char *tStr;
   long int nrItemsRead;
   int fSrcEOF;
   long int fSrcOffsetNew, fSrcOffsetOld;

   scanTag_t_setStatus(stag, TAG_SCAN_OK);
   fSrc = fopen(fName, "rb");
   if (fSrc != NULL)
   {
      pos1 = scanTag_t_findTag(tag_begin, fSrc, stag);
      pos2 = scanTag_t_findTag(tag_end, fSrc, stag);
      if (stag->errCode == TAG_SCAN_OK)
      {
         if ((long int)(pos1+strlen(tag_begin))<=pos2)
         {
            // Open src and dst file.
            tStr = (char*) malloc(strlen(fName)+1+2);
            if (tStr!=NULL)
            {
               strcpy(tStr, fName);
               strcat(tStr, "~");
               fSrc = fopen(fName, "rb");
               fDst = fopen(tStr, "wb+");
               if ((fSrc!=NULL) && (fDst!=NULL))
               {
                  // Both src and dst opened.
                  free(tStr);
                  tStr = (char*) malloc(FILE_IO_DATA_CHUNK+2);
                  if (tStr!=NULL)
                  {
                     // Blindly copy src to dst.
                     fSrcEOF = 0;
                     while (fSrcEOF == 0)
                     {
                        nrItemsRead = fread(tStr, 1, FILE_IO_DATA_CHUNK, fSrc);
                        tStr[nrItemsRead] = NULL;
                        if (nrItemsRead != FILE_IO_DATA_CHUNK)
                           fSrcEOF = 1;
                        fwrite(tStr, 1, strlen(tStr), fDst);
                     }

                     // Copy back only what's needed.
                     // First, interchange src and dst.
                     fclose(fSrc);
                     fclose(fDst);
                     free(tStr);
                     tStr = (char*) malloc(strlen(fName)+1+2);
                     strcpy(tStr, fName);
                     strcat(tStr, "~");
                     fSrc = fopen(tStr, "rb");
                     fDst = fopen(fName, "wb+");
                     // Now scan for tags and replace text.
                     free(tStr);
                     tStr = (char*) malloc(FILE_IO_DATA_CHUNK+2);
                     //pos1 = scanTag_t_findTag(tag_begin, fSrc, stag);
                     //pos2 = scanTag_t_findTag(tag_end, fSrc, stag);
                     fseek(fSrc, 0, SEEK_SET);
                     fseek(fDst, 0, SEEK_SET);
                     fSrcOffsetNew = 0;
                     while (fSrcOffsetNew < pos1)
                     {
                        nrItemsRead = fread(tStr, 1, FILE_IO_DATA_CHUNK, fSrc);
                        tStr[nrItemsRead] = NULL;
                        fSrcOffsetOld = fSrcOffsetNew;
                        fSrcOffsetNew = ftell(fSrc);
                        if (fSrcOffsetNew > pos1)
                           tStr[pos1 - fSrcOffsetOld] = NULL;
                        fwrite(tStr, 1, strlen(tStr), fDst);
                        fflush(fDst);
                     }

                     fwrite(tag_begin, 1, strlen(tag_begin), fDst);
                     fflush(fDst);
                     fwrite(newText, 1, strlen(newText), fDst);
                     fflush(fDst);
                     fwrite(tag_end, 1, strlen(tag_end), fDst);
                     fflush(fDst);

                     if (fseek(fSrc, pos2+strlen(tag_end), SEEK_SET)==0)
                     {
                        fSrcEOF = 0;
                        while (fSrcEOF == 0)
                        {
                           nrItemsRead = fread(tStr, 1, FILE_IO_DATA_CHUNK, fSrc);
                           tStr[nrItemsRead] = NULL;
                           if (nrItemsRead != FILE_IO_DATA_CHUNK)
                              fSrcEOF = 1;
                           fwrite(tStr, 1, strlen(tStr), fDst);
                        }
                     }
                     else
                     {
                        free(tStr);
                        fclose(fSrc);
                        fclose(fDst);
                        scanTag_t_setStatus(stag, TAG_SCAN_UNKNOWN_ERR);
                        return;
                     }

                     free(tStr);
                     fclose(fSrc);
                     fclose(fDst);
                  }
                  else
                  {
                     scanTag_t_setStatus(stag, TAG_SCAN_MALLOC_ERR);
                     return;
                  }
               }
               else
               {
                  free(tStr);
                  scanTag_t_setStatus(stag, TAG_SCAN_FILE_IO_ERR);
                  return;
               }
            }
            else
            {
               scanTag_t_setStatus(stag, TAG_SCAN_MALLOC_ERR);
               return;
            }
         }
         else
         {
            scanTag_t_setStatus(stag, TAG_SCAN_END_BEFORE_BEGIN);
            fclose(fSrc);
            return;
         }
      }
   }
   else
   {
      scanTag_t_setStatus(stag, TAG_SCAN_FILE_NOT_FOUND);
      return;
   }
}
// </File Body>
