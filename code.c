#include "hoc.h"
#include "y.tab.h"
#include <math.h>
#include <stdio.h>

#define MAX_OPERAND 1000
#define MAX_PROG 1000

inst prog[MAX_PROG];
operand stack[MAX_OPERAND];

inst *progp;
inst *pc;           // program counter for execution
operand *stackp;

void initcode()
{
    progp=prog;
    stackp=stack;
}

void execute(inst *in)
{
    for(pc=in;*pc!=stop;){
        inst *p=pc++;
        (*(*p))();          
    }
}

inst_with_name wrap(inst in,char *name,double d)
{
    inst_with_name n;
    n.inst=in;
    n.name=name;
    n.d=d;
    return n;
}

void code(inst_with_name inn)
{
    if(inn.name){
        printf("====>%s\n",inn.name);
    }else{
        printf("====>%.8g\n",inn.d);
    }
    inst *o=progp;
    if(progp>prog+MAX_PROG){
        execerror("program instructions overflow","");
    }
    *progp++=inn.inst;
}

operand pop()
{
    if(stackp<=stack){
        execerror("no operand","");
    }
    stackp--;
    return *stackp;
}

void push(operand d){
    if(stackp>stack+MAX_OPERAND){
        execerror("operand stack overflow","");
    }   

    *stackp=d;
    stackp++;
}

void constpush()
{
    inst *p=pc;
    pc++;

    operand d;
    d.val=((symbol *)*p)->u.val;
    push(d);
}

void varpush()
{
    inst *p=pc;
    pc++;

    operand d;
    d.sym=(symbol *)*p;
    push(d);
}   

void add()
{
    operand c1=pop();
    operand c2=pop();

    c2.val+=c1.val;
    push(c2);
}

void sub()
{
    operand c1=pop();
    operand c2=pop();

    c2.val-=c1.val;
    push(c2);
}

void mul()
{
    operand c1=pop();
    operand c2=pop();

    c2.val*=c1.val;
    push(c2);
}

void div()
{
    operand c1=pop();

    if(c1.val==0){
        execerror("div zero error","");
    }

    operand c2=pop();

    c2.val/=c1.val;
    push(c2);
}

void neg()
{
    operand c=pop();

    c.val=-c.val;
    push(c);
}

void pos()
{
    //do nothing
}

void power()
{
    operand c1=pop();
    operand c2=pop();

    c2.val=pow(c2.val,c1.val);   
    push(c2);
}

void asg()
{
    operand c1=pop();
    operand c2=pop();

    install(c1.sym->name,VAR,c2.val);
    push(c2);
}

void eval()
{
    //evaluate the value of variable
    operand c=pop();

    if(c.sym->type==UNDEF){
        execerror("variable not define",c.sym->name);
    }

    if(c.sym->type==NUMBER){
        execerror("variable cannot be number",c.sym->name);
    }

    c.val=c.sym->u.val;
    
    push(c);
}

void print()
{
    operand c=pop();
    printf("\t%.8g\n", c.val);
}

void builtin()
{
    inst *p=pc;
    pc++;

    symbol *s=(symbol *)*p;

    operand c=pop();
    double (*f)()=((symbol *)*p)->u.ptr;
    c.val=f(c.val);

    push(c);
}
