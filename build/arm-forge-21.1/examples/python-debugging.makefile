include common.makefile

object = pythonlib.o
target = pythonlib.so

.PHONY: all
all: $(target)

$(target): pythonlib.c
	$(CC) -g $(SHARED_LIBRARY_CFLAGS) -O0 -c -o $(object) $<
	$(CC) $(SHARED_LIBRARY_LINKER_FLAGS) -o $@ $(object)

.PHONY: clean
clean:
	$(RM) $(target) $(object)
