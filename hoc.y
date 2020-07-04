%{
#include "hoc.h"
#define code2(c1,c2) code(c1); code(c2)
#define code3(c1,c2,c3) code(c1); code(c2); code(c3)

inst_with_name add_with_name = {"add",0,add};
inst_with_name sub_with_name = {"sub",0,sub};
inst_with_name mul_with_name = {"mul",0,mul};
inst_with_name div_with_name = {"div",0,div};
inst_with_name neg_with_name = {"neg",0,neg};
inst_with_name pos_with_name = {"pos",0,pos};
inst_with_name power_with_name = {"power",0,power};
inst_with_name asg_with_name = {"asg",0,asg};
inst_with_name eval_with_name = {"eval",0,eval};
inst_with_name constpush_with_name = {"constpush",0,constpush};
inst_with_name varpush_with_name = {"varpush",0,varpush};
inst_with_name builtin_with_name = {"builtin",0,builtin};
inst_with_name print_with_name = {"print",0,print};
inst_with_name pop_with_name = {"pop",0,pop};
inst_with_name stop_with_name = {"stop",0,stop};

%}
%union {
    struct symbol *sym;
    struct inst *inst;
}
%token <sym> NUMBER VAR BUILTIN UNDEF
%right '='
%left '+' '-'
%left '*' '/'
%left UNARYMINUS
%left UNARYPLUS
%right '^'
%%
list:
        | list '\n'
        | list assign '\n' { code2(pop_with_name,stop_with_name);return 1; }
        | list expr '\n' { code2(print_with_name,stop_with_name);return 1; }
        | list error '\n' { yyerrok;}
        ;

assign:   VAR '=' expr { code3(varpush_with_name,wrap((inst)$1,$1->name,0),asg_with_name); }

expr:     NUMBER  { code2(constpush_with_name,wrap((inst)$1,0,$1->u.val)); }
        | VAR   { code3(varpush_with_name,wrap((inst)$1,$1->name,0),eval_with_name); }
        | assign
        | BUILTIN '(' expr ')' { code2(builtin_with_name,wrap((inst)$1,"func",0)); }
        | '-' expr %prec UNARYMINUS { code(neg_with_name); }
        | '+' expr %prec UNARYPLUS { code(pos_with_name); }
        | expr '+' expr { code(add_with_name); }
        | expr '-' expr { code(sub_with_name); }
        | expr '*' expr { code(mul_with_name); }
        | expr '/' expr { code(div_with_name); }
        | expr '^' expr { code(power_with_name); }
        | '(' expr ')'
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

    for(initcode();yyparse();initcode()){
        execute(prog);
    }
}

yylex(){
    int c;
    while((c=getchar())==' '||c=='\t'){
    }

    if(c=='.'||isdigit(c)){
        ungetc(c,stdin);
        double d=0;
        scanf("%lf",&d);
        
        yylval.sym=install("",NUMBER,d);

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
