// switch test

void main()
{
  volatile char c = 5;
  
  // JUMPTABLE generated
  switch(c)
  {
    case 10: c = 11; break;
    case 11: c = 22; break;
    case 12: c = 33; break;
    case 13: c = 44; break;
    case 14: c = 55; break;
    default: c = 99;
    break;
  }  
  
  // sequence of IFXs generated
  switch(c)
  {
    case 10: c = 11; break;
    case 23: c = 22; break;
    case 31: c = 33; break;
    case 4: c = 44; break;
    case 59: c = 55; break;
    default: c = 99;
    break;
  }

}
