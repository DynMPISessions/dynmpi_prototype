include common.makefile

ALLINEA_FORGE_PATH ?= ..

LD_FLAGS = -lm -lrt

.PHONY: all
all: serial_c serial_static_c serial_f serial_static_f

allinea-profiler.ld:
	echo Running make-profiler-libraries
	if [ -f ${ALLINEA_FORGE_PATH}/bin/make-profiler-libraries ]; then ${ALLINEA_FORGE_PATH}/bin/make-profiler-libraries --lib-type=static; else make-profiler-libraries --lib-type=static; fi > examples-make-profiler-libraries.log

serial_c: serial.c
	$(CC) $(MAP_CFLAGS) -o $@ $< $(LD_FLAGS)

serial_static_c: serial.c allinea-profiler.ld
	$(CC) $(MAP_CFLAGS) $(MAP_STATIC_C_LINKFLAGS) -o $@ $< -Wl,@allinea-profiler.ld

serial_f: serial.f90
	$(FC) $(MAP_FCFLAGS) -o $@ $< $(LD_FLAGS)

serial_static_f: serial.f90 allinea-profiler.ld
	$(FC) $(MAP_FCFLAGS) $(MAP_STATIC_FC_LINKFLAGS) -o $@ $< -Wl,@allinea-profiler.ld

.PHONY: check
check:
	./serial_f

.PHONY: clean
clean:
	$(RM) serial_f serial_c serial_static_c serial_static_f
	$(RM) allinea-profiler.ld libmap-sampler.a libmap-sampler-pmpi.a examples-make-profiler-libraries.log
