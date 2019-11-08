#include<stdio.h>
#include<string.h>
#include<stdlib.h>
extern int line;
extern int colonne;
extern int yyerror(char* msg);

typedef struct element{
	char name[20];
	int type; // 0=Uint , 1=Ufloat
	int nature; // 0=var , 1=cste 
	struct element *next;
}element;

typedef element* listElts;
listElts list = NULL;

/* Fonction qui alloue espace pour un noeud */
listElts memoryAllocation(){
	listElts list= (listElts) malloc(sizeof(element)) ;
    if (list == NULL){
       printf("error: no memory space available\n") ;
       exit(EXIT_FAILURE);
    }
    return list;
}

/* Fonction qui recherche un élément dans la liste selon le champ "name" */
listElts search(char name[20]){
	listElts l = list;
	
	while((l!= NULL) && (strcmp(l->name,name) != 0))
		l = l->next;
	return l;
}


/* Fonction qui insére un élément en tete de liste */
int insert(char name[20],int type,int nature){
	if (search(name) == NULL)
	{
		listElts l = memoryAllocation();
		strcpy(l->name,name);
		l->type = type;
		l->nature = nature;
	    l->next = list;
	    list = l;
		return 1;
	}
    else {
    	//printf("erreur semantique, ligne %d,colonne %d : idf %s deja declare \n",line,colonne,name);
		// exit(1);
		char msg [50];
		sprintf(msg,"erreur semantique, idf %s deja declare ",name);
    	yyerror(msg);
		return 0;
	}	
}

int idf_type(char idf[20]){
	listElts l = search(idf);
	return l->type;
}


int compatible_type(int type1,int type2){
	
	if(type1 != type2) {
		char msg [50];
		sprintf(msg,"erreur semantique, incompatibilite de type ");
    	yyerror(msg);
		return 0;
		//printf("erreur semantique, ligne %d,colonne %d : incompatibilite de type\n",line,colonne);
    	//exit(1);
	}
	return 1;
}


int modif_cste(char idf[20]){
	listElts l = search(idf);
	if(l->nature == 1){
		// printf("erreur semantique, ligne %d,colonne %d : modification de constante %s non autorisee\n",line,colonne,idf);
    	// exit(1);
		char msg [50];
		sprintf(msg,"erreur semantique, modification de constante %s non autorisee ",idf);
    	yyerror(msg);
		return 1;
	}
	return 0;
}

int non_dec(char idf[20]){
	listElts l = search(idf);
	if(l == NULL){
		// printf("erreur semantique, ligne %d,colonne %d : variable %s non declaree\n",line,colonne,idf);
    	// exit(1);
		char msg [50];
		sprintf(msg,"erreur semantique, variable %s non declaree ",idf);
    	yyerror(msg);
		return 1;
	}
	return 0;
}

int div_par_zero(int value){
	if((value == 0)){
		// printf("erreur semantique, ligne %d,colonne %d : division par zero\n",line,colonne);
    	// exit(1);
		char msg [50];
		sprintf(msg,"erreur semantique, division par zero ");
    	yyerror(msg);
		return 1;
	}
	return 0;
}

/* Fonction qui affiche tous les elements de la liste */
void display(){
	listElts l = list;
	printf("\n------La table des symboles------\n");
	if(l == NULL) printf("the list is empty\n");
	while(l != NULL){
		printf("name: %s,  type: %s,  nature: %s\n",l->name,l->type==0?"Uint":"Ufloat",l->nature==0?"variable":"constante");
		l = l->next;
	}
}
