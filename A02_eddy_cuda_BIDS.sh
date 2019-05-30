#!/bin/bash

#Eddy current correction

#Set Directory Paths - CHANGE
HOME_DIR=/u/CHANGE/THIS/PATH

#Argument Inputs
STUDY=${1}
SUBJID=${2}

mkdir -p ${HOME_DIR}/${STUDY}/derivatives/DTI/${SUBJID}
out_dir=${HOME_DIR}/${STUDY}/derivatives/DTI/${SUBJID}


#Change directory to subject
cd ${out_dir}
#IF YOU DON'T HAVE ACCESS TO A GPU CHANGE THIS COMMAND TO THE NON GPU COMMAND
eddy_cuda --imain=${out_dir}/${SUBJID}_dwi --mask=${out_dir}/nodif_brain_mask --index=${out_dir}/index.txt --acqp=${out_dir}/acqparams.txt --bvecs=${out_dir}/bvecs --bvals=${out_dir}/bvals --fwhm=0 --topup=${out_dir}/topup/topup --out=${out_dir}/eddy_unwarped_images --flm=quadratic --data_is_shelled --verbose


