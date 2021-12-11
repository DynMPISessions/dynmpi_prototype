include common.makefile

.PHONY: all
all: fruit

fruit: fruit.cc
	$(CXX) -g -O0 -o $@ $^

.PHONY: clean
clean:
	$(RM) fruit
