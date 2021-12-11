include common.makefile

LD_FLAGS = -lm -lrt

.PHONY: all
all: ring_c ring_f

ring_c: ring.c
	$(MPICC) $(MPI_MAP__CFLAGS) -o $@ $< $(LD_FLAGS)

ring_f: ring.f90
	$(MPIF90) $(MPI_MAP_FCFLAGS) -o $@ $< $(LD_FLAGS)

.PHONY: check
check:
	$(MPIRUN) -np 4 ./ring_c 3

.PHONY: clean
clean:
	$(RM) ring_c ring_f
