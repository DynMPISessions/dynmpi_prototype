# Make all example programs (except prefix if nvcc is not present and kmeans if upcc is not present)
all:
	$(MAKE) -f count.makefile
	$(MAKE) -f fruit.makefile
	$(MAKE) -f hello.makefile
	$(MAKE) -f heightmap.makefile
	$(MAKE) -f matrix_mult.makefile
	$(MAKE) -f memdebug.makefile
	$(MAKE) -f openmp.makefile
	$(MAKE) -f ring.makefile
	$(MAKE) -f seqtest.makefile
	$(MAKE) -f serial.makefile
	$(MAKE) -f simple.makefile
	$(MAKE) -f slow.makefile
	$(MAKE) -f stl_example.makefile
	$(MAKE) -f stl_example2.makefile
	$(MAKE) -f stl_example3.makefile
	$(MAKE) -f threaded.makefile
	$(MAKE) -f wave.makefile
	$(MAKE) -f python-debugging.makefile
	$(MAKE) -f python-profiling.makefile
	(which nvcc >/dev/null 2>/dev/null && $(MAKE) -f prefix.makefile) || echo "Skipping NVIDIA CUDA example (no nvcc in PATH)"; true
	(which upcc >/dev/null 2>/dev/null && $(MAKE) -f kmeans.makefile) || echo "Skipping UPC Example (no upcc in PATH)"; true

clean:
	$(MAKE) -f count.makefile clean
	$(MAKE) -f fruit.makefile clean
	$(MAKE) -f hello.makefile clean
	$(MAKE) -f heightmap.makefile clean
	$(MAKE) -f matrix_mult.makefile clean
	$(MAKE) -f memdebug.makefile clean
	$(MAKE) -f openmp.makefile clean
	$(MAKE) -f ring.makefile clean
	$(MAKE) -f seqtest.makefile clean
	$(MAKE) -f serial.makefile clean
	$(MAKE) -f simple.makefile clean
	$(MAKE) -f slow.makefile clean
	$(MAKE) -f stl_example.makefile clean
	$(MAKE) -f stl_example2.makefile clean
	$(MAKE) -f stl_example3.makefile clean
	$(MAKE) -f threaded.makefile clean
	$(MAKE) -f wave.makefile clean
	$(MAKE) -f python-debugging.makefile clean
	$(MAKE) -f python-profiling.makefile clean
	$(MAKE) -f prefix.makefile clean
	$(MAKE) -f kmeans.makefile clean
