%{
	#include<stdio.h>
	#include<string.h>
	#include"Routine.h"
	#include "quad.h"
	extern FILE *yyin;
	extern int line;
	extern int colonne;
	int yylex();
	int yyerror(char* msg);
	
	int type; //sauvegarder le type des variables
	int valeur; //sauvegarder la valeur lu
	int bool; //designe si l'expression contient qu'une valeur ou pas
	float valeurf;
	char *tmp[2];
	int itmp = 0;
	int indice = 1;/*indice de temporaire*/	
	char s[10];
	char temp[60];
%}
%union{
	char *chaine;
	int entier;
	float reel;
	struct {
	   int type;
	   char val[60];
	}idf;
}
%token '&' '|' '!' '>' '<' subEgal infEgal doubleEgal notEgal '+' '-' '*' '/' '=' ')' '(' ';' ',' IF ELSE ENDIF FOR ENDFOR Uint Ufloat DEC INST FIN 
%token <chaine> idf Define
%token <entier> Int 
%token <reel> reel

%left '>' subEgal doubleEgal notEgal infEgal '<' 
%left '|' '&' 
%right '!'

%left '+' '-'
%left '*' '/'
%right '(' 

%type <entier> Value 
%type <idf> ExpArithmetique 

%%
S: entite DEC Dec INST Inst FIN {printf("programme correcte.\n");YYACCEPT;}
;
entite : idf {printf("le nom du programme %s.\n",$1);}
;
Dec : DecVar Dec 
	| DecCste Dec 
	| DecVar 
	| DecCste 
;
DecVar : Type listP ';' { }
;
DecCste : Define Type listC ';' { }
;
Type: Uint {type = 0; }
	| Ufloat {type = 1; }
;
listP: listP ',' idf {  if(!insert($3,type,0)) YYABORT; 
						if(type == 0) ajouter("DEC",$3,"Uint","");else ajouter("DEC",$3,"Ufloat",""); 
					}
	| listP ',' idf '=' Value { if (!insert($3,type,0)) YYABORT; if(!compatible_type( idf_type($3) ,$5))YYABORT;
				 if(type == 0){
				 	sprintf(s,"%d",valeur);
				 	ajouter("DEC",$3,"Uint",s);
				 } else {
					sprintf(s,"%f",valeurf);ajouter("DEC",$3,"Ufloat",s);
					}
				}
	| idf { if(!insert($1,type,0))YYABORT; 
			if(type == 0) ajouter("DEC",$1,"Uint",""); else ajouter("DEC",$1,"Ufloat","");
		}
	| idf '=' Value {  if(!insert($1,type,0))YYABORT; if(!compatible_type( idf_type($1) ,$3)) YYABORT;
				 if(type == 0){ 
				 	sprintf(s,"%d",valeur);
				 	ajouter("DEC",$1,"Uint",s);
				 } else {  
				sprintf(s,"%f",valeurf); ajouter("DEC",$1,"Ufloat",s);}  }
;
listC : listC ',' idf '=' Value  { if(!insert($3,type,1)) YYABORT; if(!compatible_type( idf_type($3) ,$5)) YYABORT;
				 if(type == 0){
				 	sprintf(s,"%d",valeur);
				 	ajouter("DEC",$3,"Uint",s);
				 } else {
					sprintf(s,"%f",valeurf); ajouter("DEC",$3,"Ufloat",s);
					} 
				}
	| idf '=' Value {  if(!insert($1,type,1)) YYABORT; if(!compatible_type( idf_type($1) ,$3)) YYABORT;
				 if(type == 0){ 
				 	sprintf(s,"%d",valeur); ajouter("DEC",$1,"Uint",s);
				 } else {  
					sprintf(s,"%f",valeurf); ajouter("DEC",$1,"Ufloat",s);
					}  
				}
;
Value : Int { valeur = $1; $$ = 0; }
	| reel { if( $1 == 0) valeur = 0; else valeur = -1; valeurf =$1;  $$ = 1; }
;
Inst : Affectation  ';' Inst  | Affectation  ';'
	 | Condition Inst | Condition
	 | Boucle Inst | Boucle
;
Affectation : idf '=' ExpArithmetique { if(non_dec($1)) YYABORT; if(modif_cste($1)) YYABORT; 
									if(!compatible_type( idf_type($1) ,$3.type)) YYABORT; ajouter(":=",$3.val,"",$1);  }
;
ExpArithmetique: ExpArithmetique '+' ExpArithmetique { bool = 1; if(!compatible_type( $1.type ,$3.type)) YYABORT; 
												$$.type = $1.type;
												sprintf(temp,"t%d",indice);ajoutTemp(temp);indice++;
												ajouter("+",$1.val,$3.val,temp);strcpy($$.val,temp); 
												} 
					  | ExpArithmetique '-' ExpArithmetique { bool = 1; if(!compatible_type( $1.type ,$3.type)) YYABORT; 
												$$.type = $1.type;
												sprintf(temp,"t%d",indice);ajoutTemp(temp);
												ajouter("-",$1.val,$3.val,temp);indice++;strcpy($$.val,temp); 
												} 
					  | ExpArithmetique '*' ExpArithmetique { bool = 1; if(!compatible_type( $1.type ,$3.type))YYABORT; 
												$$.type = $1.type;
												sprintf(temp,"t%d",indice);ajoutTemp(temp);
												ajouter("*",$1.val,$3.val,temp);indice++;strcpy($$.val,temp);
												} 
					  | ExpArithmetique '/' ExpArithmetique { if(bool == 0) if(div_par_zero(valeur)) YYABORT; 
												if(!compatible_type( $1.type ,$3.type)) YYABORT; $$.type = $1.type;
												sprintf(temp,"t%d",indice);ajoutTemp(temp);
												ajouter("/",$1.val,$3.val,temp);indice++;strcpy($$.val,temp);
												} 
					  | idf  { bool = 1; if(non_dec($1)) YYABORT; $$.type = idf_type($1); strcpy($$.val,$1);}
					  | Value { bool = 0; $$.type = $1;
								if($1 == 0){ 
								sprintf($$.val,"%d",valeur);
								} else {   
									sprintf($$.val,"%f",valeurf); }
							}
					  | '(' ExpArithmetique ')' {  $$.type = $2.type; strcpy($$.val,$2.val);  }
;
Condition: Else_cond Inst ENDIF {mise_a_jour_endIf(i);} 
;
Else_cond : EXP_IF ELSE { mise_a_jour();}
;
EXP_IF : Bloc_inst Inst {ajouterBR("BR","","","");}
;
Bloc_inst: Deb_Cond Expression ')'
;
Deb_Cond : IF '('  { empiler(&p,-1); }
;
Expression: EXPComparaison | ExpressionLogique
;
EXPComparaison: ExpArithmetique '>' ExpArithmetique {if(!compatible_type( $1.type ,$3.type)) YYABORT; empiler(&p,i);
												ajouter("BLE","",$1.val,$3.val); 
												}
				|ExpArithmetique '<' ExpArithmetique {if(!compatible_type( $1.type ,$3.type)) YYABORT; empiler(&p,i);
												ajouter("BGE","",$1.val,$3.val); 
												}
				|ExpArithmetique subEgal ExpArithmetique {if(!compatible_type( $1.type ,$3.type)) YYABORT; empiler(&p,i);
												ajouter("BL","",$1.val,$3.val); 
												}
				|ExpArithmetique infEgal ExpArithmetique {if(!compatible_type( $1.type ,$3.type)) YYABORT; empiler(&p,i);
												ajouter("BG","",$1.val,$3.val); 
												}
				|ExpArithmetique doubleEgal ExpArithmetique {if(!compatible_type( $1.type ,$3.type)) YYABORT;  empiler(&p,i);
												ajouter("BNE","",$1.val,$3.val); 
												}
				|ExpArithmetique notEgal ExpArithmetique {if(!compatible_type( $1.type ,$3.type)) YYABORT; empiler(&p,i);
												ajouter("BE","",$1.val,$3.val); 
												}
;  
  
ExpressionLogique: '(' Expression ')' '&' '(' Expression ')'  
					| '(' Expression ')' '|' '(' Expression ')'  {}
					| Exp_NOT '(' Expression ')' { inverserComp(); }
;
Exp_NOT: '!' {empiler(&p,-2);}
;
Boucle : Deb_for Expression ')' ';'  Affectation ')'  Inst ENDFOR { /* mise_a_jour end for *//**/ routine_reboucler();mise_a_jour();}
;
Deb_for : FOR '(' Affectation ';' '(' {  empiler(&p,-1); /*sauvegarde de indice condition for*/ empiler(&pFor,i);}
;

%%
int yyerror(char* msg)
{printf("%s: ligne %d,colonne %d.\n",msg,line,colonne);
return 1;
}
int main()
{

yyin=fopen("code.txt","r");
yyparse();
display();
afficher();

return 0;
}




