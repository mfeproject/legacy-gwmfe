include ../Config/config

VPATH = .:../source/common:../source/scalar

PROBLEM = HEAT

OBJ = main.o enorm.o scheck.o wrlog.o wrhead.o wrsoln.o init.o rdhead.o \
      rdvars.o res.o jac.o ydot.o linsol.o dfdy.o cmtx.o cpmtx.o gthvec.o \
      sctvec.o sctmtx.o sctdgl.o locpp.o lapl.o laplvc.o ares.o amtx.o \
      regres.o regmtx.o regrhs.o pde.o prob.o bdf2.o bsolve.o meshlib.o
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

example4: go
	@cp -f Data/mfein-4 mfein 
	@echo "Running example 4..."
	time go
	@echo "****************************************************"
	@echo "Compare results with Data/mfelog-4 and Data/mfelog-4"
	@echo "****************************************************"

source: $(SRC)
	cat $? > GWMFE2DS-$(PROBLEM).f

clean:
	rm -f *.o go mkgrf mfelog mfeout mfegrf
