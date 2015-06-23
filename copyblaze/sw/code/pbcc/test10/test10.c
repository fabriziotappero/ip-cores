// test array of ints

#define ARRAY_SIZE 10

volatile short numbers[ARRAY_SIZE] = {9,8,7,6,5,4,3,2,1,0};

void main()
{
  short i, j, temp;
 
  for (i = (ARRAY_SIZE - 1); i > 0; i--)
  {
    for (j = 1; j <= i; j++)
    {
      if (numbers[j-1] > numbers[j])
      {
        temp = numbers[j-1];
        numbers[j-1] = numbers[j];
        numbers[j] = temp;
      }
    }
  }
}
