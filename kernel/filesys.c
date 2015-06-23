/*--------------------------------------------------------------------
 * TITLE: Plasma File System
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 4/26/07
 * FILENAME: filesys.c
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Plasma File System.  Supports RAM, flash, and disk file systems.
 *    Possible call tree:
 *      OS_fclose()
 *        FileFindRecursive()      //find the existing file
 *          FileOpen()             //open root file system
 *          FileFind()             //find the next level of directory
 *            OS_fread()           //read the directory file
 *              BlockRead()        //read blocks of directory
 *                MediaBlockRead() //low level read
 *          FileOpen()             //open next directory
 *        OS_fwrite()              //write file entry into directory
 *        BlockRead()              //flush changes to directory
 *--------------------------------------------------------------------*/
#include "rtos.h"

#define FLASH_SIZE        (1024*1024*16)
#define FLASH_SECTOR_SIZE (1024*128)
#define FLASH_BLOCK_SIZE  512
#define FLASH_LN2_SIZE    9                  //2^FLASH_LN2_SIZE == FLASH_BLOCK_SIZE
#define FLASH_OFFSET      FLASH_SECTOR_SIZE  //offset to start of flash file system
#define FLASH_BLOCKS      FLASH_SIZE/FLASH_BLOCK_SIZE
#define FLASH_START       (FLASH_OFFSET+FLASH_BLOCKS/8*2)/FLASH_BLOCK_SIZE

#define BLOCK_SIZE        512
#define FILE_NAME_SIZE    40
#define FULL_NAME_SIZE    128
#define BLOCK_MALLOC      0x0
#define BLOCK_EOF         0xffffffff

typedef enum {
   FILE_MEDIA_RAM,
   FILE_MEDIA_FLASH,
   FILE_MEDIA_DISK
} OS_MediaType_e;

typedef struct OS_FileEntry_s {
   char name[FILE_NAME_SIZE];
   uint32 blockIndex;       //first block of file
   uint32 modifiedTime;
   uint32 length;
   uint8 isDirectory;
   uint8 attributes;
   uint8 valid;
   uint8 mediaType;
   uint16 blockSize;        //Normally BLOCK_SIZE
   uint8 pad1, pad2;
} OS_FileEntry_t;

typedef struct OS_Block_s {
   uint32 next;
   uint8 data[BLOCK_SIZE - sizeof(uint32)];
} OS_Block_t;

struct OS_FILE_s {
   OS_FileEntry_t fileEntry;  //written to directory upon OS_fclose()
   uint8 fileModified;
   uint8 blockModified;
   uint8 pad1, pad2;
   uint32 blockIndex;         //index of block
   uint32 blockOffset;        //byte offset into block
   uint32 fileOffset;         //byte offset into file
   char fullname[FULL_NAME_SIZE]; //includes full path
   OS_Block_t *block;
   OS_Block_t blockLocal;     //local copy for flash or disk file system
};

static OS_FileEntry_t rootFileEntry;
static OS_Mutex_t *mutexFilesys;

// Public prototypes
#ifndef _FILESYS_
typedef struct OS_FILE_s OS_FILE;
#endif
OS_FILE *OS_fopen(char *name, char *mode);
void OS_fclose(OS_FILE *file);
int OS_fread(void *buffer, int size, int count, OS_FILE *file);
int OS_fwrite(void *buffer, int size, int count, OS_FILE *file);
int OS_fseek(OS_FILE *file, int offset, int mode);
int OS_fmkdir(char *name);
int OS_fdir(OS_FILE *dir, char name[64]);
void OS_fdelete(char *name);


/***************** Media Functions Start ***********************/
#ifndef EXCLUDE_FLASH
static unsigned char FlashBlockEmpty[FLASH_BLOCKS/8];
static unsigned char FlashBlockUsed[FLASH_BLOCKS/8];
static int FlashBlock;

//Free unused flash blocks
static int MediaBlockCleanup(void)
{
   int i, sector, block, count=0;
   unsigned char *buf;

   printf("FlashCleanup\n");
   buf = (unsigned char*)malloc(FLASH_SECTOR_SIZE);
   if(buf == NULL)
      return 0;
   FlashLock();
   for(sector = FLASH_OFFSET / FLASH_SECTOR_SIZE; sector < FLASH_SIZE / FLASH_SECTOR_SIZE; ++sector)
   {
      printf(".");
      FlashRead((uint16*)buf, FLASH_SECTOR_SIZE*sector, FLASH_SECTOR_SIZE);
      if(sector == FLASH_OFFSET / FLASH_SECTOR_SIZE)
      {
         for(i = FLASH_START/8; i < FLASH_BLOCKS/8; ++i)
            FlashBlockEmpty[i] |= ~FlashBlockUsed[i];
         memset(FlashBlockEmpty, 0, FLASH_START/8);
         memcpy(buf, FlashBlockEmpty, sizeof(FlashBlockEmpty));
         memset(FlashBlockUsed, 0xff, sizeof(FlashBlockUsed));
         memset(buf+sizeof(FlashBlockEmpty), 0xff, sizeof(FlashBlockUsed));
      }
      //Erase empty blocks
      for(block = 0; block < FLASH_SECTOR_SIZE / FLASH_BLOCK_SIZE; ++block)
      {
         i = sector * FLASH_SECTOR_SIZE / FLASH_BLOCK_SIZE + block;
         if(FlashBlockEmpty[i >> 3] & (1 << (i & 7)))
         {
            memset(buf + FLASH_BLOCK_SIZE*block, 0xff, FLASH_BLOCK_SIZE);
            ++count;
         }
      }
      FlashErase(FLASH_SECTOR_SIZE * sector);
      FlashWrite((uint16*)buf, FLASH_SECTOR_SIZE * sector, FLASH_SECTOR_SIZE);
   }
   FlashBlock = FLASH_START;
   FlashUnlock();
   free(buf);
   return count;
}


int MediaBlockInit(void)
{
   FlashRead((uint16*)FlashBlockEmpty, FLASH_OFFSET, sizeof(FlashBlockEmpty));
   FlashRead((uint16*)FlashBlockUsed, FLASH_OFFSET+sizeof(FlashBlockEmpty), 
             sizeof(FlashBlockUsed));
   FlashBlock = FLASH_START;
   memset(FlashBlockEmpty, 0, FLASH_START/8);  //space for FlashBlockEmpty/Used
   return FlashBlockEmpty[FlashBlock >> 3] & (1 << (FlashBlock & 7));
}
#endif  //!EXCLUDE_FLASH


static uint32 MediaBlockMalloc(OS_FILE *file)
{
   int i, j;
   (void)i; (void)j;

   if(file->fileEntry.mediaType == FILE_MEDIA_RAM)
      return (uint32)malloc(file->fileEntry.blockSize);
#ifndef EXCLUDE_FLASH
   //Find empty flash block
   for(i = FlashBlock; i < FLASH_BLOCKS; ++i)
   {
      if(FlashBlockEmpty[i >> 3] & (1 << (i & 7)))
      {
         FlashBlock = i + 1;
         FlashBlockEmpty[i >> 3] &= ~(1 << (i & 7));
         j = i >> 3;
         j &= ~1;
         FlashWrite((uint16*)(FlashBlockEmpty + j), FLASH_OFFSET + j, 2);
         return i;
      }
   }

   i = MediaBlockCleanup();
   if(i == 0)
      return 0;
   FlashBlock = FLASH_START;
   return MediaBlockMalloc(file);
#else
   return 0;
#endif
}


static void MediaBlockFree(OS_FILE *file, uint32 blockIndex)
{
   if(file->fileEntry.mediaType == FILE_MEDIA_RAM)
      free((void*)blockIndex);
#ifndef EXCLUDE_FLASH
   else
   {
      int i=blockIndex, j;
      FlashBlockUsed[i >> 3] &= ~(1 << (i & 7));
      j = i >> 3;
      j &= ~1;
      FlashWrite((uint16*)(FlashBlockUsed + j), FLASH_OFFSET + sizeof(FlashBlockEmpty) + j, 2);
   }
#endif
}


static void MediaBlockRead(OS_FILE *file, uint32 blockIndex)
{
   if(file->fileEntry.mediaType == FILE_MEDIA_RAM)
      file->block = (OS_Block_t*)blockIndex;
#ifndef EXCLUDE_FLASH
   else
   {
      file->block = &file->blockLocal;
      FlashRead((uint16*)file->block, blockIndex << FLASH_LN2_SIZE, FLASH_BLOCK_SIZE);
   }
#endif
}


static void MediaBlockWrite(OS_FILE *file, uint32 blockIndex)
{
   (void)file;
   (void)blockIndex;
#ifndef EXCLUDE_FLASH
   if(file->fileEntry.mediaType != FILE_MEDIA_RAM)
      FlashWrite((uint16*)file->block, blockIndex << FLASH_LN2_SIZE, FLASH_BLOCK_SIZE);
#endif
}

/***************** Media Functions End *************************/

// Get the next block and write the old block if it was modified
static void BlockRead(OS_FILE *file, uint32 blockIndex)
{
   uint32 blockIndexSave = blockIndex;

   OS_MutexPend(mutexFilesys);
   if(blockIndex == BLOCK_MALLOC)
   {
      // Get a new block
      blockIndex = MediaBlockMalloc(file);
      if(blockIndex == 0)
         blockIndex = BLOCK_EOF;
      if(file->block)
      {
         // Set next pointer in previous block
         file->block->next = blockIndex;
         file->blockModified = 1;
      }
   }
   if(file->block && file->blockModified)
   {
      // Write block back to flash or disk
      MediaBlockWrite(file, file->blockIndex);
      file->blockModified = 0;
   }
   if(blockIndex == BLOCK_EOF)
   {
      OS_MutexPost(mutexFilesys);
      return;
   }
   file->blockIndex = blockIndex;
   file->blockOffset = 0;
   MediaBlockRead(file, blockIndex);
   if(blockIndexSave == BLOCK_MALLOC)
   {
      memset(file->block, 0xff, file->fileEntry.blockSize);
      file->blockModified = 1;
   }
   OS_MutexPost(mutexFilesys);
}


int OS_fread(void *buffer, int size, int count, OS_FILE *file)
{
   int items, bytes;
   uint8 *buf = (uint8*)buffer;

   for(items = 0; items < count; ++items)
   {
      for(bytes = 0; bytes < size; ++bytes)
      {
         if(file->fileOffset >= file->fileEntry.length && 
            file->fileEntry.isDirectory == 0)
            return items;
         if(file->blockOffset >= file->fileEntry.blockSize - sizeof(uint32))
         {
            if(file->block->next == BLOCK_EOF)
               return items;
            BlockRead(file, file->block->next);
         }
         *buf++ = file->block->data[file->blockOffset++];
         ++file->fileOffset;
      }
   }
   return items;
}


int OS_fwrite(void *buffer, int size, int count, OS_FILE *file)
{
   int items, bytes;
   uint8 *buf = (uint8*)buffer;

   OS_MutexPend(mutexFilesys);
   file->blockModified = 1;
   for(items = 0; items < count; ++items)
   {
      for(bytes = 0; bytes < size; ++bytes)
      {
         if(file->blockOffset >= file->fileEntry.blockSize - sizeof(uint32))
         {
            if(file->block->next == BLOCK_EOF)
               file->block->next = BLOCK_MALLOC;
            BlockRead(file, file->block->next);
            if(file->blockIndex == BLOCK_EOF)
            {
               count = 0;
               --items;
               break;
            }
            file->blockModified = 1;
         }
         file->block->data[file->blockOffset++] = *buf++;
         ++file->fileOffset;
      }
   }
   file->blockModified = 1;
   file->fileModified = 1;
   if(file->fileOffset > file->fileEntry.length)
      file->fileEntry.length = file->fileOffset;
   OS_MutexPost(mutexFilesys);
   return items;
}


int OS_fseek(OS_FILE *file, int offset, int mode)
{
   if(mode == 1)      //SEEK_CUR
      offset += file->fileOffset;
   else if(mode == 2) //SEEK_END
      offset += file->fileEntry.length;
   file->fileOffset = offset;
   BlockRead(file, file->fileEntry.blockIndex);
   while(offset > (int)file->fileEntry.blockSize - (int)sizeof(uint32))
   {
      BlockRead(file, file->block->next);
      offset -= file->fileEntry.blockSize - (int)sizeof(uint32);
   }
   file->blockOffset = offset;
   return 0;
}


static int FileOpen(OS_FILE *file, char *name, OS_FileEntry_t *fileEntry)
{
   memset(file, 0, sizeof(OS_FILE));
   if(fileEntry == NULL)
   {
      // Open root file
      memcpy(&file->fileEntry, &rootFileEntry, sizeof(OS_FileEntry_t));
   }
   else if(fileEntry->valid == 1)
   {
      // Open existing file
      memcpy(&file->fileEntry, fileEntry, sizeof(OS_FileEntry_t));
   }
   else
   {
      // Initialize new file
      file->fileModified = 1;
      file->blockModified = 1;
      memset(&file->fileEntry, 0, sizeof(OS_FileEntry_t));
      file->fileEntry.isDirectory = 0;
      file->fileEntry.length = 0;
      strncpy(file->fileEntry.name, name, FILE_NAME_SIZE-1);
      file->fileEntry.blockIndex = 0;
      file->fileEntry.valid = 1;
      file->fileEntry.blockSize = fileEntry->blockSize;
      file->fileEntry.mediaType = fileEntry->mediaType;
   } 
   BlockRead(file, file->fileEntry.blockIndex);    //Get first block
   file->fileEntry.blockIndex = file->blockIndex;
   file->fileOffset = 0;
   if(file->blockIndex == BLOCK_EOF)
      return -1;
   return 0;
}


static int FileFind(OS_FILE *directory, char *name, OS_FileEntry_t *fileEntry)
{
   int count, rc = -1;
   uint32 blockIndex, blockOffset;
   uint32 blockIndexEmpty=BLOCK_EOF, blockOffsetEmpty=0, fileOffsetEmpty=0;

   // Loop through files in directory
   for(;;)
   {
      blockIndex = directory->blockIndex;
      blockOffset = directory->blockOffset;
      count = OS_fread(fileEntry, sizeof(OS_FileEntry_t), 1, directory);
      if(count == 0 || fileEntry->blockIndex == BLOCK_EOF)
         break;
      if(fileEntry->valid == 1 && strcmp(fileEntry->name, name) == 0)
      {
         rc = 0;  //Found the file in the directory
         break;
      }
      if(fileEntry->valid != 1 && blockIndexEmpty == BLOCK_EOF)
      {
         blockIndexEmpty = blockIndex;
         blockOffsetEmpty = blockOffset;
         fileOffsetEmpty = directory->fileOffset - sizeof(OS_FileEntry_t);
      }
   }
   if(rc == 0 || directory->fileEntry.mediaType == FILE_MEDIA_FLASH || 
      blockIndexEmpty == BLOCK_EOF)
   {
      // Backup to start of fileEntry or last entry in directory
      if(directory->blockIndex != blockIndex)
         BlockRead(directory, blockIndex);
      directory->blockOffset = blockOffset;
   }
   else if(blockIndexEmpty != BLOCK_EOF)
   {
      // Backup to empty slot
      if(directory->blockIndex != blockIndexEmpty)
         BlockRead(directory, blockIndexEmpty);
      directory->blockOffset = blockOffsetEmpty;
      directory->fileOffset = fileOffsetEmpty;
   }
   return rc;
}


static int FileFindRecursive(OS_FILE *directory, char *name, 
                             OS_FileEntry_t *fileEntry, char *filename)
{
   int rc, length;

   rc = FileOpen(directory, NULL, NULL);            //Open root directory
   for(;;)
   {
      if(name[0] == '/')
         ++name;
      for(length = 0; length < FILE_NAME_SIZE-1; ++length)
      {
         if(name[length] == 0 || name[length] == '/')
            break;
         filename[length] = name[length];
      }
      filename[length] = 0;
      rc = FileFind(directory, filename, fileEntry);  //Find file
      if(rc)
      {
         // File not found
         fileEntry->mediaType = directory->fileEntry.mediaType;
         fileEntry->blockSize = directory->fileEntry.blockSize;
         fileEntry->valid = 0;
         if(strstr(name, "/") == NULL)
            return rc;
         else
            return -2;  //can't find parent directory
      }
      name += length;
      if(name[0])
         rc = FileOpen(directory, filename, fileEntry);  //Open subdir
      else
         break;
   }
   return rc;
}


OS_FILE *OS_fopen(char *name, char *mode)
{
   OS_FILE *file;
   OS_FileEntry_t fileEntry;
   OS_FILE dir;
   char filename[FILE_NAME_SIZE];  //Name without directories
   int rc;

   //printf("OS_fopen(%s)\n", name);
   if(rootFileEntry.blockIndex == 0)
   {
      // Mount file system
      mutexFilesys = OS_MutexCreate("filesys");
      memset(&dir, 0, sizeof(OS_FILE));
      dir.fileEntry.blockSize = BLOCK_SIZE;
      //dir.fileEntry.mediaType = FILE_MEDIA_FLASH;  //Test flash
      BlockRead(&dir, BLOCK_MALLOC);
      strcpy(rootFileEntry.name, "/");
      rootFileEntry.mediaType = dir.fileEntry.mediaType;
      rootFileEntry.blockIndex = dir.blockIndex;
      rootFileEntry.blockSize = dir.fileEntry.blockSize;
      rootFileEntry.isDirectory = 1;
      BlockRead(&dir, BLOCK_EOF);    //Flush data
#ifndef EXCLUDE_FLASH
      file = OS_fopen("flash", "w+");
      if(file == NULL)
         return NULL;
      file->fileEntry.isDirectory = 1;
      file->fileEntry.mediaType = FILE_MEDIA_FLASH;
      file->fileEntry.blockSize = FLASH_BLOCK_SIZE;
      file->block = NULL;
      rc = MediaBlockInit();
      if(rc == 1)
         BlockRead(file, BLOCK_MALLOC);
      else
         BlockRead(file, FLASH_START);
      file->fileEntry.blockIndex = file->blockIndex;
      OS_fclose(file);
#endif
   }

   file = (OS_FILE*)malloc(sizeof(OS_FILE));
   if(file == NULL)
      return NULL;
   OS_MutexPend(mutexFilesys);
   if(name[0] == 0 || strcmp(name, "/") == 0)
   {
      FileOpen(file, NULL, NULL);
      OS_MutexPost(mutexFilesys);
      return file;
   }
   if(mode[0] == 'w')
   {
      //Don't over write a directory
      fileEntry.isDirectory = 0;
      rc = FileFindRecursive(&dir, name, &fileEntry, filename);
      if(rc == 0)
      {
         if(fileEntry.isDirectory)
         {
            free(file);
            return NULL;
         }
         OS_fdelete(name);
      }
   }
   rc = FileFindRecursive(&dir, name, &fileEntry, filename);
   if(rc == -2 || (rc && mode[0] == 'r'))
   {
      free(file);
      OS_MutexPost(mutexFilesys);
      return NULL;
   }
   if(rc)
      fileEntry.valid = 0;
   rc = FileOpen(file, filename, &fileEntry);  //Open file
   file->fullname[0] = 0;
   strncat(file->fullname, name, FULL_NAME_SIZE);
   OS_MutexPost(mutexFilesys);
   if(mode[0] == 'a')
      OS_fseek(file, 0, 2);  //goto end of file
   return file;
}


void OS_fclose(OS_FILE *file)
{
   OS_FileEntry_t fileEntry;
   OS_FILE dir;
   char filename[FILE_NAME_SIZE];
   int rc;

   if(file->fileModified)
   {
      // Write file->fileEntry into parent directory
      OS_MutexPend(mutexFilesys);
      BlockRead(file, BLOCK_EOF);
      rc = FileFindRecursive(&dir, file->fullname, &fileEntry, filename);
      if(file->fileEntry.mediaType == FILE_MEDIA_FLASH && rc == 0)
      {
         // Invalidate old entry and add new entry at the end
         fileEntry.valid = 0;
         OS_fwrite(&fileEntry, sizeof(OS_FileEntry_t), 1, &dir);
         FileFind(&dir, "endoffile", &fileEntry);
      }
      OS_fwrite(&file->fileEntry, sizeof(OS_FileEntry_t), 1, &dir);
      BlockRead(&dir, BLOCK_EOF);  //flush data
      OS_MutexPost(mutexFilesys);
   }
   free(file);
}


int OS_fmkdir(char *name)
{
   OS_FILE *file;
   file = OS_fopen(name, "w+");
   if(file == NULL)
      return -1;
   file->fileEntry.isDirectory = 1;
   OS_fclose(file);
   return 0;
}


void OS_fdelete(char *name)
{
   OS_FILE dir, file;
   OS_FileEntry_t fileEntry;
   int rc;
   uint32 blockIndex;
   char filename[FILE_NAME_SIZE];  //Name without directories

   OS_MutexPend(mutexFilesys);
   rc = FileFindRecursive(&dir, name, &fileEntry, filename);
   if(rc == 0)
   {
      FileOpen(&file, NULL, &fileEntry);
      for(blockIndex = file.blockIndex; file.block->next != BLOCK_EOF; blockIndex = file.blockIndex)
      {
         BlockRead(&file, file.block->next);
         MediaBlockFree(&file, blockIndex);
      }
      MediaBlockFree(&file, blockIndex);
      fileEntry.valid = 0;
      OS_fwrite((char*)&fileEntry, sizeof(OS_FileEntry_t), 1, &dir);
      BlockRead(&dir, BLOCK_EOF);
   }
   OS_MutexPost(mutexFilesys);
}


int OS_flength(char *entry)
{
   OS_FileEntry_t *entry2=(OS_FileEntry_t*)entry;
   return entry2->length;
}


int OS_fdir(OS_FILE *dir, char name[64])
{
   OS_FileEntry_t *fileEntry = (OS_FileEntry_t*)name;
   int count;
   for(;;)
   {
      count = OS_fread(fileEntry, sizeof(OS_FileEntry_t), 1, dir);
      if(count == 0 || fileEntry->blockIndex == BLOCK_EOF)
         return -1;
      if(fileEntry->valid == 1)
         break;
   }
   return 0;
}

/*************************************************/
#define TEST_FILES
#ifdef TEST_FILES
int DirRecursive(char *name)
{
   OS_FileEntry_t fileEntry;
   OS_FILE *dir;
   char fullname[FULL_NAME_SIZE];
   int rc;

   dir = OS_fopen(name, "r");
   if(dir == NULL)
      return 0;
   for(;;)
   {
      rc = OS_fdir(dir, (char*)&fileEntry);
      if(rc)
         break;
      printf("%s %d\n", fileEntry.name, fileEntry.length);
      if(fileEntry.isDirectory)
      {
         if(strcmp(name, "/") == 0)
            sprintf(fullname, "/%s", fileEntry.name);
         else
            sprintf(fullname, "%s/%s", name, fileEntry.name);
         DirRecursive(fullname);
      }
   }
   OS_fclose(dir);
   return 0;
}

int OS_ftest(void)
{
   OS_FILE *file;
   char *buf;
   int count;
   int i, j;

   buf = (char*)malloc(5000);
   if(buf == NULL)
      return -1;
   memset(buf, 0, 5000);
   for(count = 0; count < 4000; ++count)
      buf[count] = (char)('A' + (count % 26));
   OS_fmkdir("dir");
   OS_fmkdir("/dir/subdir");
   file = OS_fopen("/dir/subdir/test.txt", "w");
   if(file == NULL)
      return -1;
   count = OS_fwrite(buf, 1, 4000, file);
   OS_fclose(file);
   memset(buf, 0, 5000);
   file = OS_fopen("/dir/subdir/test.txt", "r");
   if(file == NULL)
      return -1;
   count = OS_fread(buf, 1, 5000, file);
   OS_fclose(file);
   printf("(%s)\n", buf);

   DirRecursive("/");

   for(i = 0; i < 5; ++i)
   {
      sprintf(buf, "/dir%d", i);
      OS_fmkdir(buf);
      for(j = 0; j < 5; ++j)
      {
         sprintf(buf, "/dir%d/file%d%d", i, i, j);
         file = OS_fopen(buf, "w");
         if(file)
         {
            sprintf(buf, "i=%d j=%d", i, j);
            OS_fwrite(buf, 1, 8, file);
            OS_fclose(file);
         }
      }
   }

   OS_fdelete("/dir1/file12");
   DirRecursive("/");
   file = OS_fopen("/baddir/myfile.txt", "w");
   if(file)
      printf("ERROR!\n");

   for(i = 0; i < 5; ++i)
   {
      for(j = 0; j < 5; ++j)
      {
         sprintf(buf, "/dir%d/file%d%d", i, i, j);
         file = OS_fopen(buf, "r");
         if(file)
         {
            count = OS_fread(buf, 1, 500, file);
            printf("i=%d j=%d count=%d (%s)\n", i, j, count, buf);
            OS_fclose(file);
         }
      }
   }

   OS_fdelete("/dir/subdir/test.txt");
   OS_fdelete("/dir/subdir");
   OS_fdelete("/dir");
   for(i = 0; i < 5; ++i)
   {
      for(j = 0; j < 5; ++j)
      {
         sprintf(buf, "/dir%d/file%d%d", i, i, j);
         OS_fdelete(buf);
      }
      sprintf(buf, "/dir%d", i);
      OS_fdelete(buf);
   }

   DirRecursive("/");

   free(buf);
   return 0;
}
#endif  //TEST_FILES
