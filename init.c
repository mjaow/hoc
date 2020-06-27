#include "hoc.h"
#include "y.tab.h"
#include <math.h>

static struct{
    char *name;
    double val;
} consts[] = {
    { "PI" , 3.14 },
    { "E" , 2.71 },
    { 0, 0 }
};

static struct{
    char *name;
    double (*func)();
} builtins[] = {
    { "cos", cos },
    { "sin", sin },
    { "log", log },
    { "log10", log10 },
    { "abs", fabs },
    { 0, 0 },
};

init()
{
    for(int i=0;consts[i].name;i++){
        install(consts[i].name,VAR,consts[i].val);
    }

    struct symbol *s;
    for(int i=0;builtins[i].name;i++){
        s=install(builtins[i].name,BUILTIN,0);
        s->u.ptr=builtins[i].func;
    }
}
