#!/bin/bash
ispc spmm.ispc -o spmm.o -h spmm.h --pic
g++ tasksys.cpp -c -o tasksys.o -fpic
matlab -nodisplay -nojvm -r "mex spmm_mex.cpp spmm.o tasksys.o; exit"
