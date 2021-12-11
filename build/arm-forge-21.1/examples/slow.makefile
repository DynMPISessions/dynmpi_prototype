include common.makefile

.PHONY: all
all: slow_f

slow_f: slow.f90
	$(MPIF90) $(MPI_MAP_FCFLAGS) -o $@ $^ -lm -lrt

.PHONY: check
check:
	$(MPIRUN) -np 4 ./slow_f 3

.PHONY: clean
clean:
	$(RM) slow_f
