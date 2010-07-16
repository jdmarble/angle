# Compile the experiment runner, run all the experiments, then typeset
# the paper.

LIB_SRC := $(shell find ./src -name "*.hs")
EXP_SRC := $(shell find ./experiments -name "*.hs")
TEST_SRC := $(shell find ./test -name "*.hs")
RUN_EXPERIMENT = ./dist/build/runexperiment/runexperiment
EXPERIMENT_INI = $(wildcard ./data/*.ini)
EXPERIMENT_CSV = $(EXPERIMENT_INI:.ini=.csv)

all: $(RUN_EXPERIMENT) \
     $(EXPERIMENT_CSV) \
     ./data/Yanbo2010.pdf

.PHONY: clean
clean:
	cabal clean
	rubber --clean --inplace --pdf
	rm -f $(EXPERIMENT_CSV)
	rm -f *.Rout
	cd data && rm -f *.pdf *.aux *.eps *.log *.tex *.pca

$(RUN_EXPERIMENT) : $(EXP_SRC) $(LIB_SRC) $(TEST_SRC)
	cabal configure
	cabal build
	./dist/build/test/test

.SECONDARY: $(EXPERIMENT_CSV)
%.csv : %.ini $(RUN_EXPERIMENT)
	$(RUN_EXPERIMENT) $< $@

RRT_PCA = data/rrt_pca.R
%.pca : %.csv $(RRT_PCA)
	R CMD BATCH --no-save --no-restore \
	'--args inputFile="$<" outputFile="$@"' \
	$(RRT_PCA)

%.pdf : %.Rnw
	cd $(<D) &&\
	export SWEAVE_STYLEPATH_DEFAULT="TRUE" &&\
	R CMD Sweave $(<F)
	rubber --inplace --pdf $*.tex

data/carlike2k_pca2k.csv : data/carlike2k_rrt.pca

data/Yanbo2010.pdf : data/carlike2k_rrt.csv data/carlike2k_pca2k.csv