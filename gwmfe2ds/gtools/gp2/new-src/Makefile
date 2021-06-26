# for gp2, the 2-D graphics processor

HEADERFILES = pgs2.h defs2.h
SRCFILES = alfa2.c clip2.c comact2.c draw2.c gpp.c init2.c matrix.c rules2.y\
		sysdep.c tek4010.c util2.c gplot2.c xs.c pscript.c
ROOT_SRC = alfa2.c clip2.c draw2.c matrix.c sysdep.c util2.c xs.c
ROOT_OBJS = alfa2.o clip2.o draw2.o matrix.o sysdep.o util2.o xs.o
INTERACTIVE_SRC = comact2.c init2.c rules2.c
INTERACTIVE_OBJS = comact2.o init2.o rules2.o
TEK_SRC = $(INTERACTIVE_SRC) $(ROOT_SRC) tek4010.c
TEK_OBJS = $(INTERACTIVE_OBJS) $(ROOT_OBJS) tek4010.o
GPLOT2_SRC = $(ROOT_SRC) gplot2.c pscript.c
GPLOT2_OBJS = $(ROOT_OBJS) gplot2.o pscript.o
TEST_OBJS = $(INTERACTIVE_OBJS) $(ROOT_OBJS) disp.o

CC = gcc
CFLAGS = -O

all : gp2new gplot2new gpp

gp2new	: $(TEK_OBJS)
	  $(CC) $(CFLAGS) $(TEK_OBJS) -lm -o gp2new

gp2.test	: $(TEST_OBJS)
	  $(CC) $(CFLAGS) $(TEST_OBJS) -lm -o gp2.test

gp2.vt125	: $(VT125_OBJS)
	  $(CC) $(CFLAGS) $(VT125_OBJS) -lplotgigi -lm -o gp2.vt125

gplot2new	: $(GPLOT2_OBJS)
	  $(CC) $(CFLAGS) $(GPLOT2_OBJS) -lm -o gplot2new

gpp	: gpp.o util2.o sysdep.o
	  $(CC) $(CFLAGS) gpp.o util2.o sysdep.o -o gpp

gpp.o	: defs2.h gpp.c
	  $(CC) -c $(CFLAGS) gpp.c

$(INTERACTIVE_OBJS) $(ROOT_OBJS)	: defs2.h
init2.o rules2.o	: switches.h
tek4010.o disp.o : $(HEADERFILES)
$(GPLOT2_OBJS): $(HEADERFILES)

cleanup: 
	-rm *.o rules2.c

print	: $(SRCFILES)
	lpr $(SRCFILES)

tags	: $(SRCFILES)
	ctags $(SRCFILES)

lint	: 
	  yacc rules2.y;mv y.tab.c rules2.c
	  lint -h $(TEK_SRC)
	  lint -h $(GPLOT2_SRC)

#install	:
	#-strip gp2.tek
	#-strip gp2.vt125
	#-strip gplot2
	#-strip gpp
	#-mv gp2.tek ../bin
	#-mv gp2.vt125 ../bin
	#-mv gplot2 ../bin
	#-mv gpp ../bin

index	:
	 ctags -v $(SRCFILES) | sort -f > index
