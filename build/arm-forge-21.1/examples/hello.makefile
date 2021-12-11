include common.makefile

.PHONY: all
all: hello_c hello_f hello_f90

hello_c: hello.c
	$(MPICC) -g -O0 -o $@ $<

hello_f: hello.f
	$(MPIF77) -g -O0 -o $@ $<

hello_f90: hello.f90
	$(MPIF90) -g -O0 -o $@ $<

.PHONY: clean
clean:
	$(RM) hello_c hello_f hello_f90
