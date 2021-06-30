include ../Config/config

VPATH = .:../source/common:../source/system

PROBLEM = BURGERS

OBJ = main.o enorm.o scheck.o wrlog.o wrgrf.o init.o rdvars.o ivals.o \
      res.o jac.o ydot.o linsol.o eltfy.o eltvec.o eltpp.o lapl.o laplvc.o \
      cres.o cmtx.o cdgl.o regrhs.o pde.o bdf2.o bsolve.o
SRC = $(OBJ:.o=.f)

go: $(OBJ)
	$(FC) $(FFLAGS) $(LDFLAGS) -o go $(OBJ) $(LIB)

$(OBJ): parameters.h

example1: go
	@cp -f Data/mfein-1 mfein
	@echo "Running example 1..."
	time go
	@echo "****************************************************"
	@echo "Compare results with Data/mfelog-1 and Data/mfegrf-1"
	@echo "****************************************************"

example2: go
	@cp -f Data/mfein-2 mfein
	@echo "Running example 2..."
	time go
	@echo "****************************************************"
	@echo "Compare results with Data/mfelog-2 and Data/mfegrf-2"
	@echo "****************************************************"

example3: go
	@cp -f Data/mfein-3 mfein
	@echo "Running example 3..."
	time go
	@echo "****************************************************"
	@echo "Compare results with Data/mfelog-3 and Data/mfegrf-3"
	@echo "****************************************************"

example4: go
	@cp -f Data/mfein-4 mfein
	@echo "Running example 4..."
	time go
	@echo "****************************************************"
	@echo "Compare results with Data/mfelog-4 and Data/mfegrf-4"
	@echo "****************************************************"

example5: go
	@cp -f Data/mfein-5 mfein
	@echo "Running example 5..."
	time go
	@echo "****************************************************"
	@echo "Compare results with Data/mfelog-5 and Data/mfegrf-5"
	@echo "****************************************************"

source: $(SRC)
	cat $? > GWMFE1DS-$(PROBLEM).f

clean:
	-rm -f *.o go mfelog mfegrf bdfout
