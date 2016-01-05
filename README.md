Dirichlet Process Tracking
==========================

A repository and code library for the dependent Dirichlet process mixture of
objects (DDPMO) model for detection-free tracking and object modeling.

Code to perform feature extraction, inference, visualization, and other tasks
are contained in the src/ directory. Within src/, a few of the important
directories are:
- extract/: code for extracting data/features from videos.
- smc1/: the main directory containing inference code (for a SMC procedure).
- smc/: additional inference code (for a more-general SMC procedure).
- mcmc/: additional inference code (for a Gibbs sampling procedure).
- pmcmc/: additional inference code (for a PMCMC procedure).
- prob/: code relating to probability densities.
- my\_log\_prob/: code relating to log-probability densities.
- viz/: code for visualizations.

Within the data/ directory are extracted data files for a few (short) sample
videos. An example of inference on these data files can be run with code in the
main inference directory (src/smc1/). For example, the file
src/smc1/smc1\_main\_tcellExp1.m carries out inference on the the extracted data
file data/tcell\_exp1\_fluor\_bwseg.mat. Note that when run, this demo file
displays some visualizations.
