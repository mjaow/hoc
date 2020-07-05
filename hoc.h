typedef struct symbol{
    char *name;
    int type;   //NUMBER, VAR , BUILTIN  , UNDEF
    union{
        double val;
        double (*ptr)();
    } u;

    struct symbol *next;
} symbol;

typedef union operand{
    double val;
    symbol *sym;
} operand;

typedef void (*inst)();

typedef struct inst_with_name{
    char *name;
    double d;
    inst inst;
} inst_with_name;

#define stop (inst) 0

int execerror(char *s,char *f);
int fpecatch();
void *emalloc(unsigned long size);
struct symbol *lookup(char *name);
struct symbol *install(char *name,int type,double val);

operand pop();

void init();
void add(),sub(),mul(),div(),neg(),pos(),power(),asg(),eval(),constpush(),varpush(),builtin(),print(),or_(),and_(),not_(),gt(),lt(),le(),ge(),eq(),ne();

extern inst prog[];

inst_with_name wrap(inst in,char *name,double d);

void execute(inst *in);

void code(inst_with_name inn);
