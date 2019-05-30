#!/bin/sh
#Use this script to preprocess diffusion data - DTIFIT to derive FA maps

#Set Directory Paths - CHANGE
HOME_DIR=/u/CHANGE/THIS/PATH

#Argument Inputs
STUDY=${1}
SUBJID=${2}
out_dir=${HOME_DIR}/${STUDY}/derivatives/DTI/${SUBJID}

#Change directory to subject
cd ${out_dir}

#Prep files for DTIFIT
echo "Organizing files for DTIFit"
ln -sf ${out_dir}/bvecs ${out_dir}/dtifit/.
ln -sf ${out_dir}/bvals ${out_dir}/dtifit/.
ln -sf ${out_dir}/nodif_brain_mask.nii.gz ${out_dir}/dtifit/.
ln -sf ${out_dir}/eddy_unwarped_images.nii.gz ${out_dir}/dtifit/${SUBJID}_dwidata.nii.gz

#Run DTIFIT
echo "Running DTIFit"
dtifit --data=${out_dir}/dtifit/${SUBJID}_dwidata.nii.gz --out=${out_dir}/dtifit/${SUBJID} --save_tensor --mask=${out_dir}/dtifit/nodif_brain_mask.nii.gz --bvecs=${out_dir}/dtifit/bvecs --bvals=${out_dir}/dtifit/bvals
echo "Finished DTIFit for Subject ${SUBJID}"

