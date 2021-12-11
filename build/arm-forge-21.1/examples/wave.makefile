include common.makefile

LD_FLAGS = -lm -lrt

targets = wave_c wave_f

.PHONY: all
all: $(targets)

wave_c: wave.c
	$(MPICC) $(MPI_MAP_CFLAGS) -o $@ $< $(LD_FLAGS)

wave_f: wave.f90
	$(MPIF90) $(MPI_MAP_FCFLAGS) -o $@ $< $(LD_FLAGS) $(LEGACY_STD_FCFLAG)

.PHONY: check
check:
	$(MPIRUN) -np 4 ./wave_c 3

.PHONY: clean
clean:
	$(RM) $(targets) wave.mod mod1.mod
