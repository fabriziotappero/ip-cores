/* C implementation of sudoku solver.
 *
 * David Sheffield (dsheffield@alumni.brown.edu)
 * September 2013
 *
 * Exact cover using bit vectors with
 * backtracking performed using an 
 * explict stack. 
 *
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <limits.h>

inline uint64_t rdtsc(void)
{
  uint32_t hi=0, lo=0;
#ifdef __amd64__
  __asm__ __volatile__ ("rdtsc" : "=a"(lo), "=d"(hi));
#endif
  return ( (uint64_t)lo)|( ((uint64_t)hi)<<32 );
}

inline uint32_t one_set(uint32_t x)
{
  /* all ones if pow2, otherwise 0 */
  uint32_t pow2 = (x & (x-1));
  uint32_t m = (pow2 == 0);
  return ((~m) + 1) & x;
}

inline uint32_t isPow2(uint32_t x)
{
  uint32_t pow2 = (x & (x-1));
  return (pow2 == 0);
}

inline uint32_t ln2(uint32_t x)
{
  uint32_t y = 1;
  while(x > 1)
    {
      y++;
      x = x>>1;
    }
  return y;
}


inline uint32_t count_ones(uint32_t x)
{
#ifdef __GNUC__
  return __builtin_popcount(x);
#else
  uint32_t y = 0;
  for(y=0;x!=0;y++)
    {
      x &= (x-1);
    }
  return y;
#endif
}

inline uint32_t find_first_set(uint32_t x)
{
#ifdef __GNUC__
  return __builtin_ctz(x);
#else
  /* copied from the sparc v9 reference manual */
  return count_ones(x ^ (~(-x))) - 1;
#endif
}

void sprintf_binary(uint32_t n, char *buf, uint32_t len)
{ 
  bzero(buf,len);
  uint32_t p = 0;
  while (p<9) 
    {
      if (n & 1)
	buf[8-p] = '1';
      else
	buf[8-p] = '0';
      n >>= 1;
      p++;
    }
}

void print_board(uint32_t *board)
{
  int32_t i,j;
  char buf[80] = {0};
  for(i=0;i<9;i++)
    {
      for(j=0;j<9;j++)
	{
	  /* sprintf_binary(board[i*9+j], buf, 80);
	   * printf("%s ", buf); */
	  printf("%d ", ln2(board[i*9+j]));
	}
      printf("\n");
    }
  printf("\n");
}

int32_t sudoku_norec(uint32_t *board, uint32_t *os);

int32_t solve(uint32_t *board, uint32_t *os)
{
  int32_t i,j,idx;
  int32_t ii,jj;
  int32_t ib,jb;
  uint32_t set_row, set_col, set_sqr;
  uint32_t row_or, col_or, sqr_or;
  uint32_t tmp;
  int32_t changed = 0;
    
  do
    {
      changed=0;
      //print_board(board);
      /* compute all positions one's set value */
      for(i = 0; i < 9; i++)
	{
	  for(j = 0; j < 9; j++)
	    {
	      idx = i*9 + j;
	      os[idx] = one_set(board[idx]);
	    }
	}

      for(i = 0; i < 9; i++)
	{
	  for(j = 0; j < 9; j++)
	    {
	      /* already solved */
	      if(isPow2(board[i*9+j]))
		continue;
	      else if(board[idx]==0)
		return 0;

	      row_or = set_row = 0;
	      for(jj = 0; jj < 9; jj++)
		{
		  idx = i*9 + jj;
		  if(jj == j)
		    continue;
		  set_row |= os[idx];
		  row_or |= board[idx];
		}
	      col_or = set_col = 0;
	      for(ii = 0; ii < 9; ii++)
		{
		  idx = ii*9 + j;
		  if(ii == i)
		    continue;
		  set_col |= os[idx];
		  col_or |= board[idx];
		}
	      sqr_or = set_sqr = 0;
	      ib = 3*(i/3);
	      jb = 3*(j/3);
	      for(ii=ib;ii < ib+3;ii++)
		{
		  for(jj=jb;jj<jb+3;jj++)
		    {
		      idx = ii*9 + jj;
		      if((i==ii) && (j == jj))
			continue;
		      set_sqr |= os[idx];
		      sqr_or |= board[idx];
		    }
		}
	      tmp = board[i*9 + j] & ~( set_row | set_col | set_sqr);
	      	      
	      if(tmp != board[i*9 + j])
		{
		  changed = 1;
		}
	      board[i*9+j] = tmp;

	      /* check for singletons */
	      tmp = 0;
	      tmp = one_set(board[i*9 + j] & (~row_or));
	      tmp |= one_set(board[i*9 + j] & (~col_or));
	      tmp |= one_set(board[i*9 + j] & (~sqr_or));
	      if(tmp != 0 && (board[i*9+j] != tmp))
		{
		  board[i*9+j] = tmp;
		  changed = 1;
		}
	    }
	}
      
    } while(changed);

  return 0;
}

int32_t check_correct(uint32_t *board, uint32_t *unsolved_pieces)
{
  int32_t i,j;
  int32_t ii,jj;
  int32_t si,sj;
  int32_t tmp;

  *unsolved_pieces = 0;
  int32_t violated = 0;

  uint32_t counts[81];
  for(i=0;i < 81; i++)
    {
      counts[i] = count_ones(board[i]);
      if(counts[i]!=1)
	{
	  *unsolved_pieces = 1;
	  return 0;
	}
    }
  

  /* for each row */
  for(i=0;i<9;i++)
    {
      uint32_t sums[9] = {0};
      for(j=0;j<9;j++)
	{
	  if(counts[i*9 +j] == 1)
	    {
	      tmp =ln2(board[i*9+j])-1;
	      sums[tmp]++;
	      if(sums[tmp] > 1)
		{
		  //char buf[80];
		  //sprintf_binary(board[i*9+j],buf,80);
		  //printf("violated row %d, sums[%d]=%d, board = %s\n", i, tmp, sums[tmp], buf);
		  //print_board(board);
		  violated = 1;
		  goto done;
		}
	    }
	}
    }
  /* for each column */

   for(j=0;j<9;j++)
   {
     uint32_t sums[9] = {0};
     for(i=0;i<9;i++)
     {
       if(counts[i*9 +j] == 1)
	 {
	   tmp =ln2(board[i*9+j])-1;
	   sums[tmp]++;
	   if(sums[tmp] > 1)
	     {
	       violated = 1;
	       goto done;
	       //printf("violated column %d, sums[%d]=%d\n", i, tmp, sums[tmp]);
	       //return 0;
	     }
	 }
     }
   }

   for(i=0;i<9;i++)
     {
       si = 3*(i/3);
       for(j=0;j<9;j++)
	 {
	   sj = 3*(j/3);
	   uint32_t sums[9] = {0};
	   for(ii=si;ii<(si+3);ii++)
	     {
	       for(jj=sj;jj<(sj+3);jj++)
		 {
		   if(counts[ii*9 +jj] == 1)
		     {
		       tmp =ln2(board[ii*9+jj])-1;
		       sums[tmp]++;
		       if(sums[tmp] > 1)
			 {
			   violated = 1;
			   goto done;
			 }
		     }
		 }
	     }
	 }
     }

done:
   return (violated == 0);
}

uint32_t count_poss(uint32_t *board)
{
  uint32_t i,t;
  uint32_t c=0;
  for(i=0;i<81;i++)
    {
      t = count_ones(board[i]);
      c += (t == 1) ? 0 : t;
    }
  return c;
}

inline void find_min(uint32_t *board, int32_t *min_idx, int *min_pos)
{
  int32_t tmp,idx,i,j;
  int32_t tmin_idx,tmin_pos;
  
  tmin_idx = 0;
  tmin_pos = INT_MAX;
  for(idx=0;idx<81;idx++)
    {
      tmp = count_ones(board[idx]);
      tmp = (tmp == 1) ? INT_MAX : tmp;
      if(tmp < tmin_pos)
	{
	  tmin_pos = tmp;
	  tmin_idx = idx;
	}
    }
  *min_idx = tmin_idx;
  *min_pos = tmin_pos;
}


int32_t sudoku(uint32_t *board, uint32_t *os, int d)
{
  int32_t rc;
  
  int32_t tmp,min_pos;
  int32_t min_idx;
  int32_t i,j,idx;
    
  uint32_t cell;
  uint32_t old[81];
 
  uint32_t unsolved_pieces = 0;

  //printf("%d poss\n", count_poss(board));

  solve(board,os);
  rc = check_correct(board, &unsolved_pieces);
  
  if(rc == 1 && unsolved_pieces == 0)
    {
      return 1;
    }
  else if(rc == 0 && unsolved_pieces == 0)
    {
      return -1;
    }
    
  /* find variable to branch on */
  find_min(board, &min_idx, &min_pos);
  
  bzero(os,sizeof(uint32_t)*81);
    
  cell = board[min_idx];  

  memcpy(old, board, sizeof(uint32_t)*81);

  while(cell != 0)
    {
      tmp = find_first_set(cell);
      cell &= ~(1 << tmp);
      board[min_idx] = 1 << tmp;

      rc = sudoku(board, os, d+1);

      if(rc == 1)
	{
	  return 1;
	}
      
      /* restart from previous state */
      memcpy(board,old,sizeof(uint32_t)*81);
    }
 
  /* we went down the wrong branch of the 
   * search tree */
  memcpy(board,old,sizeof(uint32_t)*81);
  return -1;
}

uint32_t board[81] = {0};
uint32_t os[81] = {0};

int main(int argc, char **argv)
{


  int32_t i=0,d=0j;
  FILE *fp  = 0;
  uint64_t c0 = 0;
  uint32_t rc;
 
  if(argc < 2)
    return -1;
  
  fp = fopen(argv[1], "r");
  assert(fp);

  while (i < 81) 
    {
      rc = fscanf(fp, "%x", board+i);
      if (rc != 1)
	break;
      
      i++;
    }
  fclose(fp);

  //printf("board[0] = %x, board[80] = %x\n", board[0], board[80]);
  
  

  c0 = rdtsc();
  sudoku_norec(board, os);
  c0 = rdtsc() - c0;

  print_board(board);
  printf("%lu cycles\n", c0);

  return 0;
}


int32_t sudoku_norec(uint32_t *board, uint32_t *os)
{
  int32_t rc;
  
  int32_t tmp,min_pos;
  int32_t min_idx;
  int32_t i,j,idx;
    
  uint32_t cell;
  uint32_t old[81];
 
  uint32_t unsolved_pieces = 0;
  uint32_t *bptr, *nbptr;

  int32_t stack_pos = 0;
  int32_t stack_size = (1<<6);
  uint32_t **stack = 0;
  
  stack = (uint32_t**)malloc(sizeof(uint32_t*)*stack_size);
  for(i=0;i<stack_size;i++)
    {
      stack[i] = (uint32_t*)malloc(sizeof(uint32_t)*81);
    }

  memcpy(stack[stack_pos++], board, sizeof(uint32_t)*81);

  //printf("%d poss\n", count_poss(board));
  while(stack_pos > 0)
    {
      unsolved_pieces = 0;
      bptr = stack[--stack_pos];
      
      bzero(os,sizeof(uint32_t)*81);
      solve(bptr,os);
      rc = check_correct(bptr, &unsolved_pieces);
      /* solved puzzle */
      if(rc == 1 && unsolved_pieces == 0)
	{
	  memcpy(board, bptr, sizeof(uint32_t)*81);
	  goto solved_puzzle;
	}
      /* traversed to bottom of search tree and
       * didn't find a valid solution */
      if(rc == 0 && unsolved_pieces == 0)
	{
	  continue;
	}
      
      find_min(bptr, &min_idx, &min_pos);
      cell = bptr[min_idx];  
      while(cell != 0)
	{
	  tmp = find_first_set(cell);
	  cell &= ~(1 << tmp);
	  nbptr = stack[stack_pos];
	  stack_pos++;
	  memcpy(nbptr, bptr, sizeof(uint32_t)*81);
	  nbptr[min_idx] = 1<<tmp;
	  
	  assert(stack_pos < stack_size);
	}
    }
 solved_puzzle:
    
  for(i=0;i<stack_size;i++)
    {
      free(stack[i]);
    } 
  free(stack);

  return 1;
}
