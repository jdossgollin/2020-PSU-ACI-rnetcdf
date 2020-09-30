#!/bin/bash -l
#PBS -N make-env
#PBS -l walltime=0:30:00
#PBS -l nodes=1
#PBS -l pmem=8gb
#PBS -j oe

# this actually uses mamba, which is a fast reimplementation of conda
# don't worry about these details

module load python/3.6.3-anaconda5.0.1
cd /gpfs/group/kzk10/default/private/rnetcdf-demo/2020-PSU-ACI-rnetcdf
conda env create --file environment.yml
source deactivate
