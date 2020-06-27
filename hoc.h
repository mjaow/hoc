typedef struct symbol{
    char *name;
    int type;   //VAR , BUILTIN  , UNDEF
    union{
        double val;
        double (*ptr)();
    } u;

    struct symbol *next;
} symbol;

int execerror(char *s,char *f);
int fpecatch();
void *emalloc(unsigned long size);
struct symbol *lookup(char *name);
struct symbol *install(char *name,int type,double val);
int init();
