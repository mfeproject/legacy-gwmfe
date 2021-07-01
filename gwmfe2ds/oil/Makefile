include ../Config/config

VPATH = .:../source/common:../source/system

PROBLEM = OIL

OBJ = main.o enorm.o scheck.o wrlog.o wrhead.o wrsoln.o init.o rdhead.o \
      rdvars.o res.o jac.o ydot.o linsol.o dfdy.o cmtx.o cpmtx.o gthvec.o \
      sctvec.o sctmtx.o sctdgl.o locpp.o lapl.o laplvc.o ares.o amtx.o \
      regres.o regmtx.o regrhs.o pde.o 5spot.o bdf2.o bsolve.o sbsolve.o \
      meshlib.o
SRC = $(OBJ:.o=.f)

go: $(OBJ)
	$(FC) $(FFLAGS) $(LDFLAGS) -o go $(OBJ) $(LIB)

$(OBJ): parameters.h

example1: go
	@cp -f Data/mfein-1 mfein
	@echo "Running example 1..."
	time go
	@echo "****************************************************"
	@echo "Compare results with Data/mfelog-1 and Data/mfelog-1"
	@echo "****************************************************"

example2: go
	@cp -f Data/mfein-2 mfein
	@echo "Running example 2..."
	time go
	@echo "****************************************************"
	@echo "Compare results with Data/mfelog-2 and Data/mfelog-2"
	@echo "****************************************************"

example3: go
	@cp -f Data/mfein-3 mfein
	@echo "Running example 3..."
	time go
	@echo "****************************************************"
	@echo "Compare results with Data/mfelog-3 and Data/mfelog-3"
	@echo "****************************************************"

source: $(SRC)
	cat $? > GWMFE2DS-$(PROBLEM).f

clean:
	rm -f *.o go mkgrf mfelog mfeout mfegrf bdfout
