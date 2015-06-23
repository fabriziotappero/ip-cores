int i;
struct stype {
 int x;
 int y;
} str;

int f(char a, short b)
{
  return a + b;
}


int main(void)
{
//	stype lstr;
	i = str.x = str.y = 13;
	return f(i, str.x);
}