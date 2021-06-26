# for gp1, the 1-D graphics program
YACC = yacc

HEADERFILES = defs1.h init1.h y.tab.h pgs1.h switches.h
SRCFILES = rules1.y draw1.c clip1.c util1.c comact1.c pass2.c alfa1.c\
	init1.c gplot1.c tek4010.c sysdep.c pscript.c
ROOT_SRC =   clip1.c draw1.c pass2.c util1.c sysdep.c init1.c
ROOT_OBJS =   clip1.o draw1.o pass2.o util1.o sysdep.o init1.o
INTERACTIVE_SRC = rules1.c comact1.c alfa1.c 
INTERACTIVE_OBJS = rules1.o comact1.o alfa1.o 
TEK_SRC = $(INTERACTIVE_SRC)$(ROOT_SRC) tek4010.c
TEK_OBJS = $(INTERACTIVE_OBJS)$(ROOT_OBJS) tek4010.o
GPLOT1_SRC = $(ROOT_SRC) gplot1.c pscript.c
GPLOT1_OBJS = $(ROOT_OBJS) gplot1.o pscript.o
TEST_OBJS = $(INTERACTIVE_OBJS) $(ROOT_OBJS) disp.o

CC = gcc
CFLAGS = -O

all	: gp1 gplot1

gp1	: $(TEK_OBJS)
	  $(CC) $(CFLAGS) $(TEK_OBJS) -lm -o gp1

#gplot1	: $(GPLOT1_OBJS)
#	  $(CC) $(CFLAGS) $(GPLOT1_OBJS) -libm -lm -o gplot1

gplot1	: $(GPLOT1_OBJS)
	  $(CC) $(CFLAGS) $(GPLOT1_OBJS) -lm -o gplot1

gp1.disp	: $(TEST_OBJS)
	  $(CC) $(CFLAGS) $(TEST_OBJS) -lm -o gp1.disp

$(ROOT_OBJS)	: defs1.h
$(INTERACTIVE_OBJS)	: defs1.h init1.h
$(TEK_OBJS): defs1.h
$(GPLOT1_OBJS): defs1.h init1.h
$(TEST_OBJS): defs1.h
comact1.o rules1.o : switches.h

cleanup: 
	-rm *.o

print	: $(SRCFILES)
	lpr $(SRCFILES)

tags	: $(SRCFILES)
	ctags $(SRCFILES)

index	:
	 ctags -x $(SRCFILES) | sort +2 > index
	
xref	:
	 cxref $(SRCFILES) > xref

lint	:
	 yacc  rules1.y;mv y.tab.c rules1.c
	 lint -h $(TEK_SRC)
	 lint -h $(GPLOT1_SRC)

#install	:
	#-strip gp1.tek
	#-strip vt1
	#-strip gplot1
	#-mv gp1.tek ../bin
	#-mv vt1 ../bin
	#-mv gplot1 ../bin
