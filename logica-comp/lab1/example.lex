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

void IMPL_FREE(tLinkedList *list, tLinkedList *resultList, int start, int end){
  pListMoveToPos(list,start);

  /* if Statement */
  if (start >= end-1){
    pListItem statement;
    statement.type = STMT_TYPE;
    statement.value = pListGetValue(list).value;

    pListAppend(resultList, statement);
    return;
  } else {
    /* if Statement and Operator */
    if (pListGetValue(list).type == STMT_TYPE){
      pListItem statement;
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

          pListItem or;
          or.type = OPERATOR_TYPE;
          or.value = OR_VALUE;
          pListAppend(resultList, or);

          IMPL_FREE(list, resultList, start+2, end-1);
        } else if (operator_value == AND_VALUE){
          pListAppend(resultList, statement);

          pListItem and;
          and.type = OPERATOR_TYPE;
          and.value = AND_VALUE;
          pListAppend(resultList, and);

          IMPL_FREE(list, resultList, start+2, end-1);
        } else if (operator_value == OR_VALUE) {
          pListAppend(resultList, statement);

          pListItem or;
          or.type = OPERATOR_TYPE;
          or.value = OR_VALUE;
          pListAppend(resultList, or);

          IMPL_FREE(list, resultList, start+2, end-1);
        }
      } else {
        printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
        exit(0);
      }
    /* if Negation of Statement */
    } else if (pListGetValue(list).type == NEGATION_TYPE) {
      pListItem negation;
      negation.type = NEGATION_TYPE;
      negation.value = DUMMY_VALUE;
      pListAppend(resultList, negation);

      IMPL_FREE(list, resultList, start+1, end-1);
      
    /* if Left Parenthesis */
    } else if (pListGetValue(list).type == LPAR_TYPE){
      int START_PARENTHESIS = start;
      int END_PARENTHESIS;
      int PARENTHESIS_LEVEL = pListGetValue(list).value;
      
      int i;
      for (i=start+1; i < end; i++){  
        if (pListGetValue(list).type == RPAR_TYPE && pListGetValue(list).value == PARENTHESIS_LEVEL) {
          END_PARENTHESIS = i;
          
          pListNext(list);
          printf("Operador %d", pListGetValue(list).type);
          if (pListGetValue(list).type == OPERATOR_TYPE) {
            printf(" Operador ");
            int operator_value = pListGetValue(list).value;
            if (operator_value == IMPL_VALUE){
              pListItem negation;
              negation.type = NEGATION_TYPE;
              negation.value = DUMMY_VALUE;
              pListAppend(resultList, negation);
              
              pListItem left_parenthesis;
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              IMPL_FREE(list, resultList, START_PARENTHESIS+1, END_PARENTHESIS-1);

              pListItem right_parenthesis;
              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);

              pListItem or;
              or.type = OPERATOR_TYPE;
              or.value = OR_VALUE;
              pListAppend(resultList, or);

              IMPL_FREE(list, resultList, END_PARENTHESIS+2, end);
            } else if (operator_value == AND_VALUE){
              pListItem left_parenthesis;
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              IMPL_FREE(list, resultList, START_PARENTHESIS+1, END_PARENTHESIS-1);

              pListItem right_parenthesis;
              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);

              pListItem and;
              and.type = OPERATOR_TYPE;
              and.value = AND_VALUE;
              pListAppend(resultList, and);

              IMPL_FREE(list, resultList, END_PARENTHESIS+2, end);
            } else if (operator_value == OR_VALUE) {
              pListItem left_parenthesis;
              left_parenthesis.type = LPAR_TYPE;
              left_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, left_parenthesis);

              IMPL_FREE(list, resultList, START_PARENTHESIS+1, END_PARENTHESIS-1);

              pListItem right_parenthesis;
              right_parenthesis.type = RPAR_TYPE;
              right_parenthesis.value = PARENTHESIS_LEVEL;
              pListAppend(resultList, right_parenthesis);

              pListItem or;
              or.type = OPERATOR_TYPE;
              or.value = OR_VALUE;
              pListAppend(resultList, or);

              IMPL_FREE(list, resultList, END_PARENTHESIS+2, end);
            }
          } else {
            printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
            exit(0);
          }
        }
        pListNext(list);
      }
    } else {
      printf("Malformed Expression!!\n"); printf("Start: %d & End: %d", start, end);
      exit(0);
    }
  }
}

int yywrap() {
  pListMoveToStart(&L1);

  int i;
  int l = pListLength(&L2);
  printf("\n\n\n");
  int type;
  int value;

  pListMoveToStart(&L1);
  for (i = 0; i < pListLength(&L1); i++){
    printf("\t%d\t", pListGetValue(&L1).type );
    pListNext(&L1);
  }
  printf("\n");
  pListMoveToStart(&L1);
  for (i = 0; i < pListLength(&L1); i++){
   printf("\t%d\t", pListGetValue(&L1).value );
    pListNext(&L1); 
  }
  printf("\n");

  pListInit(&L2);
  IMPL_FREE(&L1, &L2, 0, pListLength(&L1));

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
  return 1;
}