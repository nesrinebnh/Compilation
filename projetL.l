%{
#include<stdio.h>
#include<string.h>
#include "projetSi.tab.h"
extern YYSTYPE yylval;
int line = 1; 
int colonne = 1;
%}
DEFINE "define"
Uint 0|[1-9][0-9]*
Ufloat [0-9]+"."[0-9]+
idf [a-z][a-z0-9]*(_*[a-z0-9]+)*
commentaire <<(\n*[^(>>)])*>>
arithmetic_expression "+"|"-"|"*"|"/"
comparison_expression >|<|==|>=|<=|!=
logical_expression &|"|"|"!"
separator " "|\t
%%
{Uint} {
	if((atoi(yytext)<30000)){
		colonne = colonne+yyleng;
		yylval.entier = atoi(yytext);
		return Int;
	}
	printf("erreur lexical, ligne %d,colonne %d : entier '%s' trop long.\n",line,colonne,yytext);
	exit(1);
	}
{Ufloat} {
	colonne ++;
	yylval.reel = atof(yytext);
	return reel;}
{DEFINE} {
	colonne ++;
	yylval.chaine = strdup(yytext);
	return Define;
}
{idf} {
	if(yyleng>7){
		printf("erreur lexical, ligne %d,colonne %d : idf '%s' trop long.\n",line,colonne,yytext); 
		exit(1);
	}
	else{
		colonne = colonne + yyleng;
		yylval.chaine = strdup(yytext);
		return idf;
	}
}
{separator} {colonne ++;}
{commentaire} { colonne = colonne + yyleng; }
{logical_expression} {
	colonne ++;
	if(strcmp(yytext,"&")==0)
		return '&';
	else if(strcmp(yytext,"|")==0)
			return '|';
			else return '!';
}
{comparison_expression} {
	colonne = colonne + yyleng;
	if(strcmp(yytext,">")==0)
		return '>';
	else if(strcmp(yytext,"<")==0)
			return '<';
		else if(strcmp(yytext,"<=")==0)
				return infEgal;
			else if(strcmp(yytext,">=")==0)
					return subEgal;
				else if(strcmp(yytext,"==")==0)
						return doubleEgal;
					else if(strcmp(yytext,"!=")==0)
							return notEgal;
}
{arithmetic_expression} {
	colonne ++;
	if(strcmp(yytext,"+")==0)
		return '+';
	else if(strcmp(yytext,"*")==0)
			return '*';
		else if(strcmp(yytext,"-")==0)
				return '-';
			else if(strcmp(yytext,"/")==0)
					return '/';				
}
"=" {colonne ++; return '=';}
")" {colonne ++; return ')';}
"(" {colonne ++; return '(';}
";" {colonne ++; return ';';}
"," {colonne ++; return ',';}
[\n] { line ++; colonne = 0;}
IF { colonne = colonne + yyleng; return IF;}
ELSE {colonne = colonne + yyleng; return ELSE;}
ENDIF {colonne = colonne + yyleng; return ENDIF;}
FOR {colonne = colonne + yyleng; return FOR;}
ENDFOR {colonne = colonne + yyleng; return ENDFOR;}
Uint {colonne = colonne + yyleng; return Uint;}
Ufloat {colonne = colonne + yyleng; return Ufloat;}
DEC {colonne = colonne + yyleng; return DEC;}
INST {colonne = colonne + yyleng; return INST;}
FIN {colonne = colonne + yyleng; return FIN;} 
.	{printf("erreur lexical,ligne %d, colonne= %d: entite '%s' non reconnu.\n",line,colonne,yytext);  exit(1);}
%%
int yywrap(void)
{
return 0;
}
