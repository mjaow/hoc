#include "hoc.h"
#include "y.tab.h"

static struct symbol *symlist = 0;

struct symbol *lookup(char *name)
{
    if(name==0){
        return 0;
    }

    struct symbol *s;

    for(s=symlist;s!=0;s=s->next)
    {
        if(strcmp(name,s->name)==0){
            return s;
        }
    }

    return 0;
}

struct symbol *install(char *name,int type,double val)
{
    if(name==0){
        return 0;
    }

    struct symbol *s = emalloc(sizeof(struct symbol));
    s->name=emalloc(strlen(name)+1);
    strcpy(s->name,name);
    s->type=type;
    s->u.val=val;

    s->next=symlist;

    symlist=s;

    return s;
}

void *emalloc(unsigned long size)
{
    void *r=malloc(size);

    if(r==0){
        execerror("out of memory","");
    }

    return r;
}
