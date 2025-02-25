.PHONY: clean, all, example, run_example, install, build, doc, viewdoc, upload, examples, buildremote, tests, test

BUILD_DIR ?= build

SRC_DIR ?= src

EXAMPLE_DIR ?= example

OBJ_DIR ?= $(BUILD_DIR)/tmp

LIB_DIR = $(BUILD_DIR)/lib

INSTALL_PREFIX = /dss/dssfs02/lwp-dss-0001/pr63qi/pr63qi-dss-0000/ga84kaf2/shared-folder/install

# ctl directory of https://github.com/glouw/ctl
CTL_DIR ?= 3rdparty/ctl


MPICC ?= /dss/dssfs02/lwp-dss-0001/pr63qi/pr63qi-dss-0000/ga84kaf2/shared-folder/build/ompi/bin/mpicc

CFLAGS = -fPIC -Wall -Wpedantic -Wextra -std=gnu99 -Werror=implicit-function-declaration -Werror=format-security \
					-ggdb -O0 \
					-I $(BUILD_DIR)/include \
					-I $(CTL_DIR)

LDFLAGS ?= -L $(BUILD_DIR)/lib -lm

BROWSER ?= firefox



INCLUDE_EXPORT = $(wildcard public/*.h)
INCLUDE_EXPORT_DIR = $(BUILD_DIR)/include
INCLUDE_EXPORT_FILES = $(subst public,$(INCLUDE_EXPORT_DIR),$(INCLUDE_EXPORT))

#SRCS = $(shell find $(SRC_DIR) -name "*.c")
SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS_TMP = $(SRCS:.c=.o)
OBJS = $(subst $(SRC_DIR),$(OBJ_DIR),$(OBJS_TMP))

TESTS_SRCS = $(shell ls -1 tests/test_*.c)
TESTS_TMP = $(TESTS_SRCS:.c=)
TESTS = $(subst tests/,$(BUILD_DIR)/tests/,$(TESTS_TMP))

EXAMPLE_SRCS = $(shell ls -1 examples/*.c)
EXAMPLE_TMP = $(EXAMPLE_SRCS:.c=)
EXAMPLES = $(subst examples/,$(BUILD_DIR)/examples/,$(EXAMPLE_TMP))

all: build

build: $(LIB_DIR)/libmpidynres.so $(INCLUDE_EXPORT_FILES)

$(OBJS): $(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	mkdir -p $(dir $@)
	$(MPICC) $(CFLAGS) -c $^ -o $@

$(LIB_DIR)/libmpidynres.so: $(OBJS)
	mkdir -p $(LIB_DIR)
	$(MPICC) ${LDFLAGS} --shared -fPIC -o $@ $^

$(INCLUDE_EXPORT_FILES): $(INCLUDE_EXPORT)
	mkdir -p $(INCLUDE_EXPORT_DIR)
	cp -L $(INCLUDE_EXPORT) $(INCLUDE_EXPORT_DIR)

$(TESTS): $(BUILD_DIR)/tests/%: tests/%.c $(OBJS)
	mkdir -p "$(BUILD_DIR)/tests"
	$(MPICC) $(CFLAGS) $(LDFLAGS) $^ -o $@

$(EXAMPLES): $(BUILD_DIR)/examples/%: examples/%.c $(LIB_DIR)/libmpidynres.so $(INCLUDE_EXPORT_FILES)
	mkdir -p "$(BUILD_DIR)/examples"
	$(MPICC) $(CFLAGS) $(LDFLAGS) -lmpidynres $^ -o $@

tests: $(TESTS)

test: tests
	bash ./run_tests.sh "$(BUILD_DIR)"

examples: $(EXAMPLES)

install: build
	rsync -v --exclude 'tmp' --exclude 'tests' --exclude "examples" -avP $(BUILD_DIR)/ $(INSTALL_PREFIX)/

docs: $(SRCS) doc/Doxyfile
	cd doc; doxygen

viewdocs: docs
	$(BROWSER) doc/html/index.html

clean:
	rm -rf $(BUILD_DIR)
	rm -rf doc/html
	rm -rf doc/latex


buildremote: upload
	ssh lxlogin4.lrz.de '   \
MPICC=mpiicc make -C ~/libmpidynres examples'

upload:
	rsync --exclude build/\* --include example/\*.c --include example/Makefile --exclude example/\* -avz ./ lxlogin4.lrz.de:libmpidynres/
	rsync -avz ./../util/ lxlogin4.lrz.de:util/
