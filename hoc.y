%{
#include "hoc.h"
%}
%union {
    struct symbol *sym;
    double val;
}
%token <val> NUMBER
%token <sym> VAR BUILTIN UNDEF
%type <val> expr assign
%right '='
%left '+' '-'
%left '*' '/'
%left UNARYMINUS
%left UNARYPLUS
%right '^'
%%
list:
        | list '\n'
        | list assign '\n'
        | list expr '\n' { printf("\t%.8g\n", $2); }
        | list error '\n' { yyerrok;}
        ;

assign:   VAR '=' expr { $1->type=VAR;$$ = $1->u.val = $3; }

expr:     NUMBER  { $$ = $1; }
        | VAR   { 
            if($1->type==UNDEF){
                execerror("undefine var",$1->name);
            }
            $$ = $1->u.val; }
        | assign
        | BUILTIN '(' expr ')' { $$ = (*($1->u.ptr))($3); }
        | '-' expr %prec UNARYMINUS { $$ = -$2; }
        | '+' expr %prec UNARYPLUS { $$ = $2; }
        | expr '+' expr { $$ = $1 + $3; }
        | expr '-' expr { $$ = $1 - $3; }
        | expr '*' expr { $$ = $1 * $3; }
        | expr '/' expr { 
            if($3 == 0){
                execerror("div by zero","");
            }
            $$ = $1 / $3; }
        | expr '^' expr { $$ = pow($1,$3); }
        | '(' expr ')' { $$ = $2; }
        ;
%%

#include <stdio.h>
#include <ctype.h>
#include <setjmp.h>
#include <signal.h>

jmp_buf begin;
char *progname;
int lineno = 0;

main(int argc,char **argv)
{
    init();
    progname = argv[0];
    setjmp(begin);
    signal(SIGFPE,fpecatch);
    yyparse();
}

yylex(){
    int c;
    while((c=getchar())==' '||c=='\t'){
    }

    if(c=='.'||isdigit(c)){
        ungetc(c,stdin);
        scanf("%lf",&yylval.val);
        return NUMBER;
    }
    
    if(isalpha(c)){
        symbol *s;
        char buf[100];
        char *p=buf;

        do{
            *p++=c;
        }while((c=getchar())!=0&&isalnum(c));
        ungetc(c,stdin);
        *p=0;
        
        if((s=lookup(buf))==0){
            s=install(buf,UNDEF,0);
        }
        yylval.sym=s;

        return s->type==UNDEF?VAR:s->type;
    }

    if(c=='\n'){
        lineno++;
    }

    return c;
}

execerror(char *s,char *f)
{
    fprintf(stderr, "%s: %s %s near line %d\n",progname, s,f,lineno);
    longjmp(begin,0);
}

fpecatch()
{
    execerror("float point exception","");   
}

yyerror(char *s)
{
    fprintf(stderr, "%s: %s near line %d\n",progname, s,lineno);
}
