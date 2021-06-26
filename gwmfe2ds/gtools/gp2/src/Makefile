# for gp2, the 2-D graphics processor

HEADERFILES = pgs2.h defs2.h
ROOT_SRC = alfa2.c clip2.c draw2.c matrix.c sysdep.c util2.c xs.c
ROOT_OBJS = alfa2.o clip2.o draw2.o matrix.o sysdep.o util2.o xs.o
INTERACTIVE_SRC = comact2.c init2.c rules2.c
INTERACTIVE_OBJS = comact2.o init2.o rules2.o
TEK_SRC = $(INTERACTIVE_SRC) $(ROOT_SRC) tek4010.c
TEK_OBJS = $(INTERACTIVE_OBJS) $(ROOT_OBJS) tek4010.o
GPLOT2_SRC = $(ROOT_SRC) gplot2.c pscript.c
GPLOT2_OBJS = $(ROOT_OBJS) gplot2.o pscript.o

CC = gcc
CFLAGS = -O

all	: gp2 gplot2 gpp cats

gp2	: $(TEK_OBJS)
	  $(CC) $(CFLAGS) $(TEK_OBJS) -lm -o gp2

gplot2	: $(GPLOT2_OBJS)
	  $(CC) $(CFLAGS) $(GPLOT2_OBJS) -lm -o gplot2

gpp	: gpp.o util2.o sysdep.o
	  $(CC) $(CFLAGS) gpp.o util2.o sysdep.o -o gpp

gpp.o	: defs2.h gpp.c
	  $(CC) -c $(CFLAGS) gpp.c
	
cats	: cats.o
	  $(CC) $(CFLAGS) cats.o -o cats

$(INTERACTIVE_OBJS) $(ROOT_OBJS): defs2.h
init2.o rules2.o: switches.h
tek4010.o: $(HEADERFILES)
$(GPLOT2_OBJS): $(HEADERFILES)
