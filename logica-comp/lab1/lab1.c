#include <stdlib.h>
#include <stdio.h>

#define EXPR_LEN 100

typedef struct _logic_expr_t {
  char expr[EXPR_LEN];
  int marks[EXPR_LEN];
  int size;
} logic_expr_t;

int impl_free(logic_expr_t *l) {

}

void gen_marks(logic_expr_t *l, int start, int end) {
  int i, j;
  j = 0;
  for (i = start; i < end; i++) {
    if (l->expr[i] == '(') {
      l->marks[i] = j;
      j++;
    } else if (l->expr[i] == ')') {
      l->marks[i] = j;
      j--;
    }
  }
}

logic_expr_t *new_logic_expr() {
  logic_expr_t *l;
  l = (logic_expr_t *) malloc(sizeof(logic_expr_t));
  l->size = 0;
  return l;
}

int main(int argc, char *argv) {
  logic_expr_t *l;
  l = new_logic_expr();
  gen_marks(l, 0, EXPR_LEN);
  return 0;
}