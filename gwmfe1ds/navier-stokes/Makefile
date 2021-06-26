include ../Config/config

VPATH = .:../source/common:../source/system

PROBLEM = NAVIER-STOKES

OBJ = main.o enorm.o scheck.o wrlog.o wrgrf.o init.o rdvars.o ivals.o \
      res.o jac.o ydot.o linsol.o eltfy.o eltvec.o eltpp.o lapl.o laplvc.o \
      cres.o cmtx.o cdgl.o regrhs.o pde.o bdf2.o bsolve.o
SRC = $(OBJ:.o=.f) $(SYSOBJ:.o=.f)

go: $(OBJ) $(SYSOBJ)
	$(FC) $(FFLAGS) $(LDFLAGS) -o go $(OBJ) $(SYSOBJ) $(LIB)

$(OBJ): parameters.h

example1: go
	@cp -f Data/mfein-1 mfein
	@echo "Running example 1..."
	time go
	@echo "****************************************************"
	@echo "Compare results with Data/mfelog-1 and Data/mfelog-1"
	@echo "****************************************************"

source: $(SRC)
	cat $? > GWMFE1DS-$(PROBLEM).f

clean:
	-rm -f *.o go mfelog mfegrf bdfout
