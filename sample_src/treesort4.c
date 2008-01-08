#include <stdio.h>
#include <stdlib.h>

struct node {
  int value;
  struct node *left;
  struct node *right;
};

void treeadd(struct node**, int);
void treewalk(struct node*);
void treefree(struct node*);

int main(int argc, char **argv) {
  struct node *rootp = (struct node *)0;
  int i;
  int array[15] = {50, 12, 18, 70, 41, 19, 91, 1, 7, 6, 81, 65, 55, 20, 0};
  
  for (i = 0; i < 15; i++) {
    treeadd(&rootp, array[i]);
  }
  
  treewalk(rootp);
  printf("\n");

  treefree(rootp);
  
  return 0;
}

void treeadd(struct node **pp, int val) {

  /* create new node if *p is null */
  if (*pp == (struct node *)0) {
    *pp = (struct node *)malloc(sizeof(struct node));
    (*pp)->value = val;
    (*pp)->left = (struct node *)0;
    (*pp)->right = (struct node *)0;
  }
  
  else if ((*pp)->value > val) {
    treeadd(&(*pp)->left, val);
  }

  else if ((*pp)->value < val) {
    treeadd(&(*pp)->right, val);
  }

  else /* (*pp)->value == val */ {
    /* do nothing */
  }
}

void treewalk(struct node *p) {

  /* return if p is empty node.. */
  if (p == (struct node *)0) {
    return;
  }
  
  else {
    treewalk(p->left);
    printf("%d ", p->value);
    treewalk(p->right);
  }
}

void treefree(struct node *p) {

  /* return if p is empty node.. */
  if (p == (struct node *)0) {
    return;
  }
  
  else {
    treefree(p->left);
    treefree(p->right);
    free(p);
    return;
  }
}

