%{
#include <stdlib.h>

/* Types */

// Left Parenthesis
#define LPAR_TYPE 0
// Right Parenthesis
#define RPAR_TYPE 1 
// Operators
#define OPERATOR_TYPE 2
// Negation
#define NEGATION_TYPE 3
// Statements
#define STMT_TYPE 4

/* Operator Values */

// And
#define AND_VALUE 0
// Or
#define OR_VALUE 1
// Implication
#define IMPL_VALUE 2
// Dummy
#define DUMMY_VALUE 3

/* end Types */


/* Linked List */

typedef struct {
  int value;
  int type;
} pListItem;

typedef struct _pListNode {
  pListItem data;
  struct _pListNode *next;
  struct _pListNode *prev;
} pListNode;

typedef struct {
  pListNode *curr;
  pListNode *nil;
  pListNode *tail;
  unsigned int curr_pos;
  unsigned int length;
} tLinkedList;

pListNode *tmp_pListNode;

/* Initialise */
void pListInit(tLinkedList *L) {
  L->nil = L->tail = L->curr = (pListNode *) malloc(sizeof(pListNode)); //sentinela
  L->curr->next = L->curr->prev = L->nil;
  L->length = 0;
  L->curr_pos = 0; // lista vacia
}

/* Append Item */
void pListAppend(tLinkedList *L, pListItem item){
  tmp_pListNode = L->tail->next;
  L->tail->next = (pListNode *) malloc(sizeof(pListNode));
  L->tail->next->prev = L->tail;
  L->tail = L->tail->next;
  L->tail->data = item;
  L->tail->next = tmp_pListNode;
  L->curr = L->tail;
  L->length++;
}

/* Insert Item */
int pListInsert(tLinkedList *L, pListItem item) {
  tmp_pListNode = L->curr->next;
  L->curr->next = (pListNode *) malloc(sizeof(pListNode)); // []-> +[]
  L->curr->next->data = item; //
  L->curr->next->next = tmp_pListNode; // []->[]-> +[]
  L->curr->next->prev = L->curr;
  if (L->curr == L->tail)
      L->tail = L->curr->next;
  else
      L->curr->next->next->prev = L->curr->next;
  L->length++;
    return L->curr_pos;
}

/* Remove Item */
void pListRemove(tLinkedList *L) { 
  pListNode *aux;
  if (L->curr != L->nil) {
    L->curr->prev->next = L->curr->next;
    if (L->curr != L->tail) {
      L->curr->next->prev = L->curr->prev;
    }
    aux = L->curr->prev;
    free((void *) L->curr);
    L->curr = aux;
    L->tail = aux;
    L->length--;
  }
}

/* Clear List */
void pListClear(tLinkedList *L){
  int i;
  L->curr = L->nil->next;
  for (i = 0; i < L->length; ++i){
    tmp_pListNode = L->curr->next;
    free((void *) L->curr);
    L->curr = tmp_pListNode;
  }
  L->tail = L->curr = L->nil;
  L->curr->next = L->curr->prev = NULL;
  L->length = L->curr_pos = 0;
  return;
}

/* Get Current Element Value */
pListItem pListGetValue(tLinkedList *L) {
  return L->curr->data;
}

/* Get Length */
int pListLength(tLinkedList *L) {
  return L->length;
}

/* Move Current Pointer to Start */
void pListMoveToStart(tLinkedList *L) {
  L->curr = L->nil->next;
  L->curr_pos = 0;
}

/* Move Current Pointer to End */
void pListMoveToEnd(tLinkedList *L){
  L->curr = L->tail;
  L->curr_pos = L->length-1;
}

/* Move to Previous Item */
void pListPrev(tLinkedList *L){
  if (L->curr != L->nil->next) {
    L->curr = L->curr->prev;
    L->curr_pos--;
  }
}

/* Move to Next Item */
void pListNext(tLinkedList *L){
  if (L->curr != L->tail){
    L->curr = L->curr->next;
    L->curr_pos++;
  }
}

/* Move to Custom Position */
void pListMoveToPos(tLinkedList *L, int pos){
  int i;
  if (pos < 0 || pos >= L->length) { return; }
  L->curr = L->nil->next;
  L->curr_pos = 0;
  for (i = 0; i < pos; i++){
    L->curr = L->curr->next;
    L->curr_pos++;
  }
}

/* Parenthesis Counter */
int pc = 0;

/* Primary Linked List */
tLinkedList L1;

/* Secondary Linked List */
tLinkedList L2;

/* Helper Item */
pListItem aux;

/* End Linked List */

%}

%%

                                      pListInit(&L1);
"\\documentclass"(.|\n)*"\n$$"        ;
"("                                   {
                                        aux.type = LPAR_TYPE;
                                        aux.value = pc;
                                        pListAppend(&L1, aux);
                                        pc++;
                                      }
")"                                   {
                                        pc--; 
                                        aux.type = 1;
                                        aux.value = pc;
                                        pListAppend(&L1, aux);
                                      }
"\\rightarrow"                        {
                                        aux.type = OPERATOR_TYPE;
                                        aux.value = IMPL_VALUE;
                                        pListAppend(&L1, aux);
                                      }
"\\vee"                               {
                                        aux.type = OPERATOR_TYPE;
                                        aux.value = OR_VALUE;
                                        pListAppend(&L1, aux);
                                      }
"\\wedge"                             {
                                        aux.type = OPERATOR_TYPE;
                                        aux.value = AND_VALUE;
                                        pListAppend(&L1, aux);
                                      }
"\\neg"                               {
                                        aux.type = NEGATION_TYPE;
                                        aux.value = DUMMY_VALUE;
                                        pListAppend(&L1, aux);
                                      }
[a-zA-Z]                              {
                                        aux.type = STMT_TYPE;
                                        aux.value = yytext[0];
                                        pListAppend(&L1, aux);
                                      }
[ \t]+                                ;
"$$\n"(.|\n)*"\\end{document}"        ;

%%

void IMPL_FREE(tLinkedList *list, tLinkedList *resultList, int start, int end);
void NNF(tLinkedList *list, tLinkedList *resultList, int start, int end);
void dNNF(tLinkedList *list, tLinkedList *resultList, int start, int end);
void CNF(tLinkedList *list, tLinkedList *resultList, int start, int end);

int yywrap() {
  int i, l, type, value;

  pListMoveToStart(&L1);

  printf("INPUT\n");

  l = pListLength(&L1);
  pListMoveToStart(&L1);
  for (i = 0; i < l; i++){
    type = pListGetValue(&L1).type;
    value = pListGetValue(&L1).value;

    if (type == STMT_TYPE){
      printf(" %c ", value);
    } else if (type == OPERATOR_TYPE) {
      if (value == AND_VALUE){
        printf(" & ");
      } else if (value == OR_VALUE){
        printf(" || ");
      } else {
        printf(" -> ");
      }
    } else if (type == NEGATION_TYPE){
      printf(" ~ ");
    } else if (type == LPAR_TYPE) {
      printf(" ( ");
    } else if (type == RPAR_TYPE) {
      printf(" ) ");
    } 

    pListNext(&L1);
  }

  printf("\nIMPL_FREE\n");

  pListInit(&L2);
  IMPL_FREE(&L1, &L2, 0, pListLength(&L1)-1);

  
  l = pListLength(&L2);
  pListMoveToStart(&L2);
  for (i = 0; i < l; i++){
    type = pListGetValue(&L2).type;
    value = pListGetValue(&L2).value;

    if (type == STMT_TYPE){
      printf(" %c ", value);
    } else if (type == OPERATOR_TYPE) {
      if (value == AND_VALUE){
        printf(" & ");
      } else if (value == OR_VALUE){
        printf(" || ");
      } else {
        printf(" -> ");
      }
    } else if (type == NEGATION_TYPE){
      printf(" ~ ");
    } else if (type == LPAR_TYPE) {
      printf(" ( ");
    } else if (type == RPAR_TYPE) {
      printf(" ) ");
    } 

    pListNext(&L2);
  }

  printf("\nNNF\n");

  tLinkedList L3;
  pListInit(&L3);
  NNF(&L2, &L3, 0, pListLength(&L2)-1);

  l = pListLength(&L3);
  pListMoveToStart(&L3);
  for (i = 0; i < l; i++){
    type = pListGetValue(&L3).type;
    value = pListGetValue(&L3).value;

    if (type == STMT_TYPE){
      printf(" %c ", value);
    } else if (type == OPERATOR_TYPE) {
      if (value == AND_VALUE){
        printf(" & ");
      } else if (value == OR_VALUE){
        printf(" || ");
      } else {
        printf(" -> ");
      }
    } else if (type == NEGATION_TYPE){
      printf(" ~ ");
    } else if (type == LPAR_TYPE) {
      printf(" ( ");
    } else if (type == RPAR_TYPE) {
      printf(" ) ");
    } 

    pListNext(&L3);
  }

  printf("\nCNF\n");

  tLinkedList L4;
  pListInit(&L4);
  CNF(&L3, &L4, 0, pListLength(&L3)-1);

  l = pListLength(&L4);
  pListMoveToStart(&L4);
  for (i = 0; i < l; i++){
    type = pListGetValue(&L4).type;
    value = pListGetValue(&L4).value;

    if (type == STMT_TYPE){
      printf(" %c ", value);
    } else if (type == OPERATOR_TYPE) {
      if (value == AND_VALUE){
        printf(" & ");
      } else if (value == OR_VALUE){
        printf(" || ");
      } else {
        printf(" -> ");
      }
    } else if (type == NEGATION_TYPE){
      printf(" ~ ");
    } else if (type == LPAR_TYPE) {
      printf(" ( ");
    } else if (type == RPAR_TYPE) {
      printf(" ) ");
    } 

    pListNext(&L4);
  }

  return 1;
}

void IMPL_FREE(tLinkedList *list, tLinkedList *resultList, int start, int end){
  pListMoveToPos(list,start);

  pListItem statement;
  pListItem left_parenthesis;
  pListItem right_parenthesis;
  pListItem and;
  pListItem or;
  pListItem negation;

  /* if Statement */
  if (start >= end-1){
    statement.type = STMT_TYPE;
    statement.value = pListGetValue(list).value;

    pListAppend(resultList, statement);
    return;
  } else {
    /* if Statement and Operator */
    if (pListGetValue(list).type == STMT_TYPE){
      statement.type = STMT_TYPE;
      statement.value = pListGetValue(list).value;

      pListNext(list);
      if (pListGetValue(list).type == OPERATOR_TYPE) {
        int operator_value = pListGetValue(list).value;
        if (operator_value == IMPL_VALUE){
          pListItem negation;
          negation.type = NEGATION_TYPE;
          negation.value = DUMMY_VALUE;
          pListAppend(resultList, negation);
          pListAppend(resultList, statement);

          or.type = OPERATOR_TYPE;
          or.value = OR_VALUE;
          pListAppend(resultList, or);
        } else if (operator_value == AND_VALUE){
          pListAppend(resultList, statement);

          and.type = OPERATOR_TYPE;
          and.value = AND_VALUE;
          pListAppend(resultList, and);
        } else if (operator_value == OR_VALUE) {
          pListAppend(resultList, statement);

          or.type = OPERATOR_TYPE;
          or.value = OR_VALUE;
          pListAppend(resultList, or);
        }
      } else {
        printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
        exit(0);
      }

      /* Check Next Item */
      pListNext(list);
      if (pListGetValue(list).type == STMT_TYPE){
        IMPL_FREE(list, resultList, start+2, end);
      } else if (pListGetValue(list).type == NEGATION_TYPE){
        negation.type = NEGATION_TYPE;
        negation.value = DUMMY_VALUE;
        pListAppend(resultList, negation);

        pListNext(list);
        if (pListGetValue(list).type == STMT_TYPE){
          IMPL_FREE(list, resultList, start+3, end);
        } else if (pListGetValue(list).type == LPAR_TYPE){
          left_parenthesis.type = LPAR_TYPE;
          left_parenthesis.value = pListGetValue(list).value;
          pListAppend(resultList, left_parenthesis);

          IMPL_FREE(list, resultList, start+4, end-1);

          right_parenthesis.type = RPAR_TYPE;
          right_parenthesis.value = pListGetValue(list).value;
          pListAppend(resultList, right_parenthesis);
        } else {
          printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
        }
      } else if (pListGetValue(list).type == LPAR_TYPE){
        IMPL_FREE(list, resultList, start+2, end-1);
      } else {
        printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
      }

    /* if Negation of Statement */
    } else if (pListGetValue(list).type == NEGATION_TYPE) {
      pListItem negation;
      negation.type = NEGATION_TYPE;
      negation.value = DUMMY_VALUE;
      pListAppend(resultList, negation);

      /* Check next item */
      pListNext(list);

      if (pListGetValue(list).type == STMT_TYPE){
        IMPL_FREE(list, resultList, start+1, end);
      } else if (pListGetValue(list).type == LPAR_TYPE) {
        left_parenthesis.type = LPAR_TYPE;
        left_parenthesis.value = pListGetValue(list).value;
        pListAppend(resultList, left_parenthesis);

        IMPL_FREE(list, resultList, start+2, end-1);

        right_parenthesis.type = RPAR_TYPE;
        right_parenthesis.value = pListGetValue(list).value;
        pListAppend(resultList, right_parenthesis);
      } else {
        printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
      }
      
    /* if Left Parenthesis */
    } else if (pListGetValue(list).type == LPAR_TYPE){
      int START_PARENTHESIS = start;
      int END_PARENTHESIS;
      int PARENTHESIS_LEVEL = pListGetValue(list).value;
      
      int i;
      for (i=start+1; i < end; i++){  
        if (pListGetValue(list).type == RPAR_TYPE && pListGetValue(list).value == PARENTHESIS_LEVEL) {
          END_PARENTHESIS = i-1;
          
          pListNext(list);
          if (pListGetValue(list).type == OPERATOR_TYPE) {
            int operator_value = pListGetValue(list).value;
            if (operator_value == IMPL_VALUE){
              negation.type = NEGATION_TYPE;
              negation.value = DUMMY_VALUE;
              pListAppend(resultList, negation);
              
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              IMPL_FREE(list, resultList, START_PARENTHESIS+1, END_PARENTHESIS-1);

              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);

              or.type = OPERATOR_TYPE;
              or.value = OR_VALUE;
              pListAppend(resultList, or);
            } else if (operator_value == AND_VALUE){
              pListItem left_parenthesis;
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              IMPL_FREE(list, resultList, START_PARENTHESIS+1, END_PARENTHESIS-1);

              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);

              and.type = OPERATOR_TYPE;
              and.value = AND_VALUE;
              pListAppend(resultList, and);
            } else if (operator_value == OR_VALUE) {
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              IMPL_FREE(list, resultList, START_PARENTHESIS+1, END_PARENTHESIS-1);

              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);

              or.type = OPERATOR_TYPE;
              or.value = OR_VALUE;
              pListAppend(resultList, or);
            }

            pListMoveToPos(list, END_PARENTHESIS+1);
            /* Check Next Item */
            pListNext(list);
            if (pListGetValue(list).type == STMT_TYPE){
              IMPL_FREE(list, resultList, END_PARENTHESIS+2, end);
            } else if (pListGetValue(list).type == NEGATION_TYPE){
              IMPL_FREE(list, resultList, END_PARENTHESIS+2, end);
            } else if (pListGetValue(list).type == LPAR_TYPE){
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              IMPL_FREE(list, resultList, END_PARENTHESIS+3, end-1);

              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);
            } else {
              printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
              exit(0);
            }
          } else {
            printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
            exit(0);
          }
          break;
        }
        pListNext(list);
      }
    } else {
      printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
      exit(0);
    }
  }
}

void NNF(tLinkedList *list, tLinkedList *resultList, int start, int end){
  pListMoveToPos(list, start);

  pListItem statement;
  pListItem left_parenthesis;
  pListItem right_parenthesis;
  pListItem and;
  pListItem or;
  pListItem negation;
  pListItem operator;

  /* if Statement */
  if (start >= end-1){
    statement.type = STMT_TYPE;
    statement.value = pListGetValue(list).value;

    pListAppend(resultList, statement);
    return;
  } else {
    if (pListGetValue(list).type == STMT_TYPE){
      NNF(list, resultList, start, start+1);

      /* Check Operator */
      pListNext(list);
      if (pListGetValue(list).type == OPERATOR_TYPE) {
        int operator_value = pListGetValue(list).value;
        if (operator_value == AND_VALUE){
          and.type = OPERATOR_TYPE;
          and.value = AND_VALUE;
          pListAppend(resultList, and);
        } else if (operator_value == OR_VALUE) {
          or.type = OPERATOR_TYPE;
          or.value = OR_VALUE;
          pListAppend(resultList, or);
        }
      } else {
        printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
        exit(0);
      }

      /* Check Next Item */
      pListMoveToPos(list, start+1);

      pListNext(list);
      if (pListGetValue(list).type == LPAR_TYPE){
        left_parenthesis.type = LPAR_TYPE;
        left_parenthesis.value = pListGetValue(list).value;

        NNF(list,resultList, start+3, end-1);

        right_parenthesis.type = RPAR_TYPE;
        right_parenthesis.value = pListGetValue(list).value;
      } else {
        NNF(list, resultList, start+2, end);
      }
    } else if (pListGetValue(list).type == NEGATION_TYPE){
      negation.type = NEGATION_TYPE;
      negation.value = DUMMY_VALUE;

      /* Check if is another negation */
      pListNext(list);
      if (pListGetValue(list).type == NEGATION_TYPE){
        pListNext(list);

        if (pListGetValue(list).type == STMT_TYPE){
          NNF(list, resultList, start+2, end);
        } else if (pListGetValue(list).type == LPAR_TYPE){
          left_parenthesis.type = LPAR_TYPE;
          left_parenthesis.value = pListGetValue(list).value;

          NNF(list, resultList, start+2, end-1);

          right_parenthesis.type = RPAR_TYPE;
          right_parenthesis.value = pListGetValue(list).value;
        } else {
          printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
          exit(0);
        }
      } else if (pListGetValue(list).type == STMT_TYPE){
        pListAppend(resultList, negation);

        statement.type = STMT_TYPE;
        statement.value = pListGetValue(list).value;

        pListAppend(resultList, statement);

        if (start+1 < end){
          pListNext(list);

          if (pListGetValue(list).type == OPERATOR_TYPE){
            operator.type = pListGetValue(list).type;
            operator.value = pListGetValue(list).value;

            pListAppend(resultList,operator);

            pListNext(list);
            if (pListGetValue(list).type == LPAR_TYPE){
              NNF(list, resultList, start+4, end-1);
            } else {
              NNF(list, resultList, start+3, end);
            }
          } else {
            printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
            exit(0);
          }
        }
      } else if (pListGetValue(list).type == LPAR_TYPE){
        left_parenthesis.type = LPAR_TYPE;
        left_parenthesis.value = pListGetValue(list).value;
        pListAppend(resultList, left_parenthesis);
        
        dNNF(list, resultList, start+2, end-1);

        right_parenthesis.type = RPAR_TYPE;
        right_parenthesis.value = pListGetValue(list).value;
        pListAppend(resultList, right_parenthesis);
      }
    } else if (pListGetValue(list).type == LPAR_TYPE){
      int START_PARENTHESIS = start;
      int END_PARENTHESIS;
      int PARENTHESIS_LEVEL = pListGetValue(list).value;
      
      int i;
      for (i=start+1; i < end; i++){  
        if (pListGetValue(list).type == RPAR_TYPE && pListGetValue(list).value == PARENTHESIS_LEVEL) {
         END_PARENTHESIS = i-1;
          
          pListNext(list);
          if (pListGetValue(list).type == OPERATOR_TYPE) {
            int operator_value = pListGetValue(list).value;
            if (operator_value == AND_VALUE){
              pListItem left_parenthesis;
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              NNF(list, resultList, START_PARENTHESIS+1, END_PARENTHESIS-1);

              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);

              and.type = OPERATOR_TYPE;
              and.value = AND_VALUE;
              pListAppend(resultList, and);
            } else if (operator_value == OR_VALUE) {
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              NNF(list, resultList, START_PARENTHESIS+1, END_PARENTHESIS-1);

              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);

              or.type = OPERATOR_TYPE;
              or.value = OR_VALUE;
              pListAppend(resultList, or);
            }

            pListMoveToPos(list, END_PARENTHESIS+1);
            /* Check Next Item */
            pListNext(list);
            if (pListGetValue(list).type == LPAR_TYPE){
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              NNF(list, resultList, END_PARENTHESIS+3, end-1);

              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);
            } else {
              NNF(list, resultList, END_PARENTHESIS+2, end);
            }
          } else {
            printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
            exit(0);
          }

          break;
        }
        pListNext(list);
      }
    } else {
      printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
      exit(0);
    }
  }
}

void dNNF(tLinkedList *list, tLinkedList *resultList, int start, int end){
  pListMoveToPos(list, start);

  pListItem statement;
  pListItem left_parenthesis;
  pListItem right_parenthesis;
  pListItem and;
  pListItem or;
  pListItem negation;
  pListItem operator;

  /* if Statement */
  if (start >= end-1){
    negation.type = NEGATION_TYPE;
    negation.value = DUMMY_VALUE;
    pListAppend(resultList, negation);

    statement.type = STMT_TYPE;
    statement.value = pListGetValue(list).value;

    pListAppend(resultList, statement);
    return;
  } else {
    if (pListGetValue(list).type == STMT_TYPE){
      dNNF(list, resultList, start, start+1);

      pListMoveToPos(list, start);
      /* Check Operator */
      pListNext(list);
      if (pListGetValue(list).type == OPERATOR_TYPE) {
        int operator_value = pListGetValue(list).value;
        if (operator_value == AND_VALUE){
          or.type = OPERATOR_TYPE;
          or.value = OR_VALUE;
          pListAppend(resultList, or);
        } else if (operator_value == OR_VALUE) {
          and.type = OPERATOR_TYPE;
          and.value = AND_VALUE;
          pListAppend(resultList, and);
        }
      } else {
        printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
        exit(0);
      }

      /* Check Next Item */
      pListMoveToPos(list, start+1);

      pListNext(list);
      if (pListGetValue(list).type == LPAR_TYPE){
        left_parenthesis.type = LPAR_TYPE;
        left_parenthesis.value = pListGetValue(list).value;

        dNNF(list,resultList, start+3, end-1);

        right_parenthesis.type = RPAR_TYPE;
        right_parenthesis.value = pListGetValue(list).value;
      } else if (pListGetValue(list).type == NEGATION_TYPE) {
        NNF(list, resultList, start+2, end);
      } else {
        negation.type = NEGATION_TYPE;
        negation.value = DUMMY_VALUE;
        pListAppend(resultList, negation);

        NNF(list, resultList, start+2, end);
      }
    } else if (pListGetValue(list).type == NEGATION_TYPE){
      negation.type = NEGATION_TYPE;
      negation.value = DUMMY_VALUE;

      /* Check if is another negation */
      pListNext(list);
      if (pListGetValue(list).type == NEGATION_TYPE){
        pListNext(list);

        if (pListGetValue(list).type == STMT_TYPE){
          dNNF(list, resultList, start+2, end);
        } else if (pListGetValue(list).type == LPAR_TYPE){
          NNF(list, resultList, start+2, end-1);
        } else {
          printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
          exit(0);
        }
      } else if (pListGetValue(list).type == STMT_TYPE){
        statement.type = STMT_TYPE;
        statement.value = pListGetValue(list).value;

        pListAppend(resultList, statement);

        if (start+1 < end){
          pListNext(list);

          if (pListGetValue(list).type == OPERATOR_TYPE){
            operator.type = pListGetValue(list).type;
            operator.value = pListGetValue(list).value;

            if (operator.value == AND_VALUE){
              operator.value = OR_VALUE;
            } else {
              operator.value = AND_VALUE;
            }

            pListAppend(resultList,operator);

            pListNext(list);
            if (pListGetValue(list).type == LPAR_TYPE){
              dNNF(list, resultList, start+4, end-1);
            } else {
              dNNF(list, resultList, start+3, end);
            }
          } else {
            printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
            exit(0);
          }
        }
      } else if (pListGetValue(list).type == LPAR_TYPE){
        NNF(list, resultList, start+2, end-1);
      }
    } else if (pListGetValue(list).type == LPAR_TYPE){
      int START_PARENTHESIS = start;
      int END_PARENTHESIS;
      int PARENTHESIS_LEVEL = pListGetValue(list).value;
      
      int i;
      for (i=start+1; i < end; i++){  
        if (pListGetValue(list).type == RPAR_TYPE && pListGetValue(list).value == PARENTHESIS_LEVEL) {
         END_PARENTHESIS = i-1;
          
          pListNext(list);
          if (pListGetValue(list).type == OPERATOR_TYPE) {
            int operator_value = pListGetValue(list).value;
            if (operator_value == OR_VALUE){
              pListItem left_parenthesis;
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              dNNF(list, resultList, START_PARENTHESIS+1, END_PARENTHESIS-1);

              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);

              and.type = OPERATOR_TYPE;
              and.value = AND_VALUE;
              pListAppend(resultList, and);
            } else if (operator_value == AND_VALUE) {
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              dNNF(list, resultList, START_PARENTHESIS+1, END_PARENTHESIS-1);

              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);

              or.type = OPERATOR_TYPE;
              or.value = OR_VALUE;
              pListAppend(resultList, or);
            }

            pListMoveToPos(list, END_PARENTHESIS+1);
            /* Check Next Item */
            pListNext(list);
            if (pListGetValue(list).type == LPAR_TYPE){
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              NNF(list, resultList, END_PARENTHESIS+3, end-1);

              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);
            } else {
              NNF(list, resultList, END_PARENTHESIS+2, end);
            }
          } else {
            printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
            exit(0);
          }

          break;
        }
        pListNext(list);
      }
    } else {
      printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
      exit(0);
    }
  }
}

void CNF(tLinkedList *list, tLinkedList *resultList, int start, int end){
  printf("CNF: %d %d\n", start, end);
  pListMoveToPos(list,start);

  pListItem statement;
  pListItem left_parenthesis;
  pListItem right_parenthesis;
  pListItem and;
  pListItem or;
  pListItem negation;
  pListItem operator;

  /* if Statement */
  if (start >= end-1){
    statement.type = STMT_TYPE;
    statement.value = pListGetValue(list).value;

    pListAppend(resultList, statement);
    return;
  } else {
    if (pListGetValue(list).type == STMT_TYPE){
      statement.type = STMT_TYPE;
      statement.value = pListGetValue(list).value;

      pListNext(list);

      if (pListGetValue(list).type == OPERATOR_TYPE){
        operator.type = OPERATOR_TYPE;
        operator.value = pListGetValue(list).value;

        pListAppend(resultList, statement);
        pListAppend(resultList, operator);

        pListNext(list);
        if (pListGetValue(list).type == STMT_TYPE){
          statement.type = STMT_TYPE;
          statement.value = pListGetValue(list).value;
          pListAppend(resultList, statement);
          return;
        } else if (pListGetValue(list).type == LPAR_TYPE){
          CNF(list, resultList, start+3, end-1);
        } else if (pListGetValue(list).type == NEGATION_TYPE){
          CNF(list, resultList, start+2, end);
        } else {
          printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
          exit(0);
        }
      } else {
        printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
        exit(0);
      }
    } else if (pListGetValue(list).type == NEGATION_TYPE){
      negation.type = NEGATION_TYPE;
      negation.value = DUMMY_VALUE;
      pListAppend(resultList, negation);

      pListNext(list);
      if (pListGetValue(list).type == LPAR_TYPE){
        CNF(list, resultList, start+2, end-1);
      } else {
        CNF(list, resultList, start+1, end);
      }
    } else if (pListGetValue(list).type == LPAR_TYPE){
      int START_PARENTHESIS = start;
      int END_PARENTHESIS;
      int PARENTHESIS_LEVEL = pListGetValue(list).value;
      
      int i;
      for (i=start+1; i < end; i++){  
        if (pListGetValue(list).type == RPAR_TYPE && pListGetValue(list).value == PARENTHESIS_LEVEL) {
          END_PARENTHESIS = i-1;
          
          pListNext(list);
          if (pListGetValue(list).type == OPERATOR_TYPE) {
            int operator_value = pListGetValue(list).value;
            if (operator_value == AND_VALUE) {
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              CNF(list, resultList, START_PARENTHESIS+1, END_PARENTHESIS-1);

              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);

              and.type = OPERATOR_TYPE;
              and.value = AND_VALUE;
              pListAppend(resultList, and);
            } else if (operator_value == OR_VALUE){
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              CNF(list, resultList, START_PARENTHESIS+1, END_PARENTHESIS-1);

              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);

              and.type = OPERATOR_TYPE;
              and.value = AND_VALUE;
              pListAppend(resultList, and);
            }

            /* Check Next Item */
            pListMoveToPos(list, END_PARENTHESIS+1);
            pListNext(list);
            if (pListGetValue(list).type == LPAR_TYPE){
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              CNF(list, resultList, END_PARENTHESIS+3, end-1);

              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);
            } else {
              CNF(list, resultList, END_PARENTHESIS+2, end);
            }
          } else {
            printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
            exit(0);
          }

          break;
        }
        pListNext(list);
      }
    } else {
      printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
      exit(0);
    }
  }
}