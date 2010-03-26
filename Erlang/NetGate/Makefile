## Modified BSD License
NETGATE_REV=0.1

ifndef ROOT
	ROOT=$(shell pwd)
endif

DEPENDENT_DIRS=$(wildcard $(ROOT)/deps/*)
DEPENDENT_EBIN_OPTIONS=$(DEPENDENT_DIRS:%=-pa %/ebin)

COMMON_TEST=$(shell erl -noshell -eval 'io:format("~s~n", [code:lib_dir(common_test)]).' -s init stop)
RUN_TEST_CMD=$(COMMON_TEST)/priv/bin/run_test

all: subdirs

subdirs:
	for i in $(DEPENDENT_DIRS); do (cd $$i; make); done
	cd src; NETGATE_REV=$(NETGATE_REV) ROOT=$(ROOT) make

test: test_do

test_compile: subdirs
	cd test; \
		ROOT=$(ROOT) COMMON_TEST=$(COMMON_TEST) make

test_do: test_compile
	${RUN_TEST_CMD} -dir . \
		-logdir test/log -cover test/ermlia.coverspec \
		-I$(ROOT)/include \
		-pa $(ROOT)/ebin $(DEPENDENT_EBIN_OPTIONS)

test_single: test_compile
	${RUN_TEST_CMD} -suite $(SUITE) \
		-logdir test/log -cover test/ermlia.coverspec \
		-I$(ROOT)/include \
		-pa $(ROOT)/ebin $(DEPENDENT_EBIN_OPTIONS)

docs:
	erl -noshell -run edoc_run application "'ermlia'" \
		'"."' '[{def,{vsn, "$(ERMLIA_VSN)"}}]'

dialyze:
	cd src; make dialyze

clean:	
	rm -rf *.beam erl_crash.dump log/* doc/*
	cd src; ROOT=$(ROOT) make clean
	cd test; ROOT=$(ROOT) make clean
	for i in $(DEPENDENT_DIRS); do (cd $$i; make clean); done

