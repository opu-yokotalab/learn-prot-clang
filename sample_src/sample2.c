/* sample.c */
/* $B<B9T%(%i!<(B */
#include <stdio.h>
#define SIZE 5

int main()
{
  int a[SIZE];
  int i;

  for(i=0;i<SIZE+1;i++){
    printf("put a[%d]: ",i);
    scanf("%d", &a[i]);
  }

  for(i=0;i<SIZE+1;i++){
    printf("a[%d] = %d\n", i, a[i]);
  }

  return 0;
}
