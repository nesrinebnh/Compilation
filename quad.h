#include<stdio.h>
#include<string.h>
#include<stdlib.h>

struct tabquad{
	char *op,*op1,*op2,*tmp;
}tabquad;

//la pile

typedef struct elt  {
                int indice;
				struct elt *svt;
}pile;
typedef struct{             
    char name[20];
                     
}symb;

pile *p =  NULL,*Ptmp = NULL,*pileBR = NULL,*pFor = NULL;
symb tabtemp[9999];
int indicet=0;
int sauv_br;
void ajoutTemp(char* nom)   
{

strcpy(tabtemp[indicet].name,nom);

indicet++;
}

void initpile (pile ** sommet)
{*sommet=NULL;}

int pilevide( pile * sommet)
{
	if(sommet==NULL) return 1; return 0;
}

int sommetpile(pile * sommet) 
{ return sommet->indice;}

void empiler(pile **sommet, int x )

{pile *p;
p=(pile*)malloc(sizeof(pile));
p->indice=x;
p->svt=*sommet;
*sommet=p;
}


void depiler(pile **sommet, int * x )

{pile *p;
p = *sommet;
*sommet = p->svt;
*x = p->indice;
free(p);
}



struct tabquad tab[100];
int i = 0;

void ajouter(char *op,char *op1,char *op2, char *tmp){
	tab[i].op = strdup(op);
	tab[i].op1 = strdup(op1);
	tab[i].op2 = strdup(op2);
	tab[i].tmp = strdup(tmp);
	i++;
}

void afficher(){
	int j;
	printf("\n------Quadruplees------\n");
	for(j =0; j < i ;  j++){
		printf("%d - ( %s , %s , %s , %s)\n",j,tab[j].op,tab[j].op1,tab[j].op2,tab[j].tmp);
	}
}


void inverserComp()
{
	
	int var;
	char s[10];
	depiler(&p,&var);
	while(var != -2)
	{
		if (strcmp(tab[var].op,"BG")==0)  strcpy(tab[var].op,"BLE");
		else if (strcmp(tab[var].op,"BL")==0)  strcpy(tab[var].op,"BGE");
			else if (strcmp(tab[var].op,"BGE")==0)  strcpy(tab[var].op,"BL");
				else if (strcmp(tab[var].op,"BLE")==0)  strcpy(tab[var].op,"BG");
					else if (strcmp(tab[var].op,"BNE")==0)  strcpy(tab[var].op,"BE");
						else strcpy(tab[var].op,"BNE");
		empiler(&Ptmp,var);
		depiler(&p,&var);
	}
	while(!pilevide(Ptmp))
	{
		depiler(&Ptmp,&var);
		empiler(&p,var);
	}
}

void mise_a_jour()
{
	
	int var;
	char s[10];
	depiler(&p,&var);
	printf("var = %d\n",var );
	while(var != -1)
	{
		sprintf(s,"%d",i);
		tab[var].op1 = strdup(s);
		depiler(&p,&var);
	}
}
void ajouterBR(char *op,char *op1,char *op2, char *tmp){
	char s[60];
	tab[i].op = strdup(op);
	tab[i].op1 = strdup(op1);
	tab[i].op2 = strdup(op2);
	tab[i].tmp = strdup(tmp);
	sauv_br=i;
	empiler(&pileBR,sauv_br);
	i++;
	
}

void mise_a_jour_endIf(int i){
	char t[20];
	depiler(&pileBR,&sauv_br);
	sprintf(t,"%d",i);
	strcpy(tab[sauv_br].op1,t);
	
}

void routine_reboucler(){
	int var;
	char t[20];
	depiler(&pFor,&var);
	sprintf(t,"%d",var);
	ajouter("BR",t,"","");
}
