APP = hoc

YFLAGS = -d

OBJS = hoc.o code.o init.o symbol.o

hoc: ${OBJS}
	gcc ${OBJS} -lm -o ${APP}

hoc.o: hoc.h

init.o symbol.o: hoc.h y.tab.h

clean:
	rm -rf y.tab.[ch] ${APP} ${OBJS}

run: hoc
	./${APP}
