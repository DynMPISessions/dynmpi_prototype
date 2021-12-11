include common.makefile

####### Definitions

objects = threaded.o
cflags = -g -O0 $(MPI_PTHREAD_CFLAG)
lflags = 
target = threaded

####### Implicit rules

.SUFFIXES: .c
.c.o:
	$(MPICC) -c $(cflags) -o $@ $<

####### Target

.PHONY: all
all: $(target)

$(target): $(objects)
	$(MPICC) $(cflags) -o $@ $^ $(lflags)

####### Objects

threaded.o:

####### Clean

.PHONY: clean
clean:
	$(RM) $(target) core $(objects) *~
