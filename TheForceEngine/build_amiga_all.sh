#!/bin/sh
clear

CPUS="020 030 040 060"
FPUS="0 1"

for CPU in $CPUS; do
    for FPU in $FPUS; do
        echo "Building CPU=$CPU FPU=$FPU"
        
        make -f Makefile.amiga clean CPU=$CPU FPU=$FPU
        make -j12 -f Makefile.amiga CPU=$CPU FPU=$FPU $* || { echo "BUILD FAILED for CPU=$CPU FPU=$FPU"; exit 1; }
    done
done

echo "All CPU/FPU builds done"
