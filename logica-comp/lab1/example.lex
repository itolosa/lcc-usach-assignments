%{
#include <stdlib.h>

typedef struct {
  int n;
  int type;
} pListItem;

typedef struct _pListNode {
  pListItem data;
  struct _pListNode *next;
  struct _pListNode *prev;
} pListNode;

//doble enlazada extendida con sentinela
typedef struct {
  pListNode *curr;
  pListNode *nil;
  pListNode *tail;
  unsigned int curr_pos;
  unsigned int length;
} tLinkedList;

/*
//doble enlazada extendida sin sentinela
typedef struct {
  pListNode *curr;
  pListNode *head;
  pListNode *tail;
  unsigned int curr_pos;
  unsigned int length;
} tLinkedList;
*/

pListNode *tmp_pListNode;

/*
//insercion en lista simple con sentinela en posicion actual
//no insertar en el sentinela, queda la zorra
//queda el nodo y luego el nil por lo tanto no hacer eso
int pListInsert(tLinkedList *L, pListItem item){
  tmp_pListNode = L->curr;
  L->curr = (pListNode *) malloc(sizeof(pListNode)); // []-> +[]
  L->curr->data = item; //
  L->curr->next = tmp_pListNode; // []->[]-> +[]
  L->curr->prev = L->curr->next->prev;
  L->curr->next->prev = L->curr;
  if (L->curr->next != L->nil) //WARNING!!: cuando se inserta en esta condicion queda la REAL zorra!
      L->curr->prev->next = L->curr;
  L->length++;
    return L->curr_pos;
}
*/

//insercion en lista con sentinela en posicion siguiente
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



/*

si esta vacia, cuidado con cola y cabeza

si no esta vacia, pero, la posicion es 0, cuidado con la cabeza

si no pasa nada de eso, insertar normalmente
*/

/*
//insercion lista doblemente enlazada abierta sin sentinela en posicion actual
int pListInsert(tLinkedList *L, pListItem item) {
  if (L->length == 0) {
    //cuidado con cola y cabeza
    L->curr = (pListNode *) malloc(sizeof(pListNode));
    L->curr->data = item;
    L->curr->next = L->tail;
    L->curr->prev = L->head;
    L->tail = L->curr;
    L->head = L->curr;
  } else {
    //insersion normal
    tmp_pListNode = L->curr;
    L->curr = (pListNode *) malloc(sizeof(pListNode));
    L->curr->data = item;
    L->curr->next = tmp_pListNode;
    L->curr->prev = tmp_pListNode->prev;
    L->curr->next->prev = L->curr;
    //if (L->curr_pos != 0) { //cuidado con cabeza
    if (L->head != L->curr) {
      L->curr->prev->next = L->curr;
    }
  }
  L->length++;
    return L->curr_pos;
}
*/

/*
si esta vacia cuidado con cola y cabeza

si no esta vacia, pero, esta en la cola, cuidado con la cola

en otro caso si no esta en la cola entonces insertar normalmente
*/
/*
//insercion en lista simple sin sentinela en posicion siguiente
int pListInsert(tLinkedList *L, pListItem item) {
  if (L->length == 0) {
    L->curr = (pListNode *) malloc(sizeof(pListNode));
    L->curr->data = item;
    L->curr->next = L->tail;
    L->curr->prev = L->head;
    L->tail = L->curr;
    L->head = L->curr;
  } else {
    tmp_pListNode = L->curr->next;
    L->curr->next = (pListNode *) malloc(sizeof(pListNode));
    L->curr->next->data = item;
    L->curr->next->next = tmp_pListNode;
    L->curr->next->prev = L->curr;
    //if (L->curr_pos == (L->length-1)) {
    if (L->curr != L->tail) {
      L->curr->next->next->prev = L->curr->next;
    }
  }
  L->length++;
    return L->curr_pos;
}

*/

//inicializacion para sentinela
void pListInit(tLinkedList *L) {
  L->nil = L->tail = L->curr = (pListNode *) malloc(sizeof(pListNode)); //sentinela
  L->curr->next = L->curr->prev = L->nil;
  L->length = 0;
  L->curr_pos = 0; // lista vacia
}

/*
//inicializacion sin sentinela
void pListInit(tLinkedList *L) {
  L->head = L->tail = L->curr = NULL; //sentinela
  L->curr->next = L->curr->prev = NULL;
  L->length = 0;
  L->curr_pos = 0; // lista vacia
}
*/
//usando sentinela
void pListMoveToStart(tLinkedList *L) {
  L->curr = L->nil->next;
  L->curr_pos = 0;
}

/*
//sin sentinela
void pListMoveToStart(tLinkedList *L) {
  L->curr = L->head;
  L->curr_pos = 0;
}
*/

//para las dos
void pListMoveToEnd(tLinkedList *L){
  L->curr = L->tail;
  L->curr_pos = L->length-1;
}

//no circular con centinela
void pListPrev(tLinkedList *L){
  if (L->curr != L->nil->next) {
    L->curr = L->curr->prev;
    L->curr_pos--;
  }
}

/*
//no circular sin centinela
void pListPrev(tLinkedList *L){
  if (L->curr != L->head) {
    L->curr = L->curr->prev;
    L->curr_pos--;
  }
}
*/
/*
//sin centinela no circular
void pListNext(tLinkedList *L) {
  if (L->curr != L->tail) {
    L->curr = L->curr->next;
    L->curr_pos++;
  }
}
*/

//ambas
pListItem pListGetValue(tLinkedList *L) {
  return L->curr->data;
}

//con sentinela
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

/*
//sin centinela
void pListMoveToPos(tLinkedList *L, int pos){
  int i;
  if (pos < 0 || pos >= L->length) { return; }
  L->curr = L->head;
  L->curr_pos = 0;
  for (i = 0; i < pos; i++){
    L->curr = L->curr->next;
    L->curr_pos++;
  }
}
*/
/*
//sin centinela
void pListRemove(tLinkedList *L)
{
  if (L->curr != L->head)
    L->curr->prev->next = L->curr->next;
  if (L->curr != L->tail)
    L->curr->next->prev = L->curr->prev;
  free((void *) L->curr);
  L->length--;
}
*/

//con sentinela
void pListRemove(tLinkedList *L)
{ 
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

//con sentinela
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

/*
//sin sentinela
void pListClear(tLinkedList *L){
  int i;
  for (i = 0; i < L->length; ++i){
    tmp_pListNode = L->head->next;
    free((void *) L->head);
    L->head = tmp_pListNode;
  }
  L->tail = L->curr = L->head = NULL;
  L->curr->next = L->curr->prev = NULL;
  L->length = L->curr_pos = 0;
  return;
}
*/

int pListLength(tLinkedList *L) {
  return L->length;
}

//solo con Sentinela extendida
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

/*
//sin sentinela extendida
void pListAppend(tLinkedList *L, pListItem item){
  if (L->length == 0) {
    L->tail = (pListNode *) malloc(sizeof(pListNode));
    L->tail->next = L->tail->prev = NULL;
    L->head = L->tail;
  } else {
    tmp_pListNode = L->tail->next;
    L->tail->next = (pListNode *) malloc(sizeof(pListNode));
    L->tail->next->prev = L->tail;
    L->tail = L->tail->next;
    L->tail->data = item;
    L->tail->next = tmp_pListNode;
  }
  L->length++;
}
*/

int pc = 0;
tLinkedList L1;
tLinkedList L2;
pListItem aux;

%}

%%
                                      
                                      pListInit(&L1);
"\\documentclass"(.|\n)*"\n$$"        ;
"("                                   {
                                        aux.n = -pc-5;
                                        aux.type = 1;
                                        pListAppend(&L1, aux);
                                        pc++;
                                      }
")"                                   {
                                        pc--; 
                                        aux.n = -pc-5;
                                        aux.type = 1;
                                        pListAppend(&L1, aux);
                                      }
[a-zA-Z]                              {
                                        aux.n = yytext[0];
                                        aux.type = 2;
                                        pListAppend(&L1, aux);
                                      }
"\\rightarrow"                        {
                                        aux.n = -1;
                                        aux.type = 3;
                                        pListAppend(&L1, aux);
                                      }
"\\vee"                               {
                                        aux.n = -2;
                                        aux.type = 3;
                                        pListAppend(&L1, aux);
                                      }
"\\neg"                               {
                                        aux.n = -3;
                                        aux.type = 3;
                                        pListAppend(&L1, aux);
                                      }
"\\wedge"                             {
                                        aux.n = -4;
                                        aux.type = 3;
                                        pListAppend(&L1, aux);
                                      }
[ \t]+                                ;
"$$\n"(.|\n)*"\\end{document}"        ;
%%


int yywrap() {
  int i;
  int l = pListLength(&L1);
  printf("\n\n\n");
  for (i = 0; i < l; i++){
    printf(" %d ", pListGetValue(&L1).n);
    pListRemove(&L1);
    pListMoveToStart(&L1);
  }
  return 1;
}

