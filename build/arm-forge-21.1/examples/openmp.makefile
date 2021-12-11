include common.makefile

LD_FLAGS = -lm -lrt

.PHONY: all
all: openmp_c openmp_f slow_openmp wave_openmp

openmp_c: openmp.c
	$(MPICC) $(MPI_MAP_CFLAGS) $(MPI_OPENMP_CFLAG) -o $@ $< $(LD_FLAGS)

openmp_f: openmp.f90
	$(MPIF90) $(MPI_MAP_FCFLAGS) $(MPI_OPENMP_FCFLAG) -o $@ $< $(LD_FLAGS)

slow_openmp: slow_openmp.f90
	$(MPIF90) $(MPI_MAP_FCFLAGS) $(MPI_OPENMP_FCFLAG) -o $@ $< $(LD_FLAGS)

wave_openmp: wave_openmp.c
	$(MPICC) $(MPI_MAP_CFLAGS) $(MPI_OPENMP_CFLAG) -o $@ $< $(LD_FLAGS)

.PHONY: check
check:
	OMP_NUM_THREADS=4 $(MPIRUN) -np 4 ./openmp_f 3
	OMP_NUM_THREADS=4 $(MPIRUN) -np 4 ./openmp_c 3
	OMP_NUM_THREADS=4 $(MPIRUN) -np 4 ./slow_openmp
	OMP_NUM_THREADS=4 $(MPIRUN) -np 4 ./wave_openmp 3

.PHONY: clean
clean:
	$(RM) openmp_c openmp_f slow_openmp wave_openmp
