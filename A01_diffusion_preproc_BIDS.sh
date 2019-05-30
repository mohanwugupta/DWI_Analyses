#!/bin/bash

#Set Directory Paths - CHANGE
HOME_DIR=/u/SET/PATH/HERE

#Readout Time - dcmdump on dicom and look at 1/(0019,1028) -CHANGE
rt=0.04829984544049

#Number of Timepoints - # of shell1 dicoms + # of shell2 dicoms - CHANGE
t=142

#Argument Inputs
STUDY=${1}
SUBJID=${2}

#Clear symlinks
rm ${HOME_DIR}/${STUDY}/${SUBJID}/dwi/DTI*

mkdir -p ${HOME_DIR}/${STUDY}/derivatives/DTI/${SUBJID}
out_dir=${HOME_DIR}/${STUDY}/derivatives/DTI/${SUBJID}


cd ${out_dir}

#Create subdirectories for the subject
for dir in topup eddy_1_shell eddy_2_shell dtifit; do
if [ ! -d "${out_dir}/${dir}" ]; then
	mkdir ${out_dir}/${dir}
fi
done

ln -sf ${HOME_DIR}/${STUDY}/${SUBJID}/dwi/* ${out_dir}
mv ${out_dir}/*run-1* ${out_dir}/eddy_1_shell
mv ${out_dir}/*run-2* ${out_dir}/eddy_2_shell

#Change directory to subject
cd ${out_dir}

#Merge diffusuion data
echo "Merging 1st and 2nd shell vectors and b-values, respectively"
paste -d"\n" ${out_dir}/eddy_1_shell/${SUBJID}_run-1_dwi.bvec ${out_dir}/eddy_2_shell/${SUBJID}_run-2_dwi.bvec | paste - - >> ${out_dir}/bvecs
paste -d"\n" ${out_dir}/eddy_1_shell/${SUBJID}_run-1_dwi.bval ${out_dir}/eddy_2_shell/${SUBJID}_run-2_dwi.bval | paste - -  >> ${out_dir}/bvals

sed -i.bak $'s/\t/    /g' ${out_dir}/bvecs
sed -i.bak $'s/\t/    /g' ${out_dir}/bvals


echo "Merging 1st and 2nd shell data"
fslmerge -t ${out_dir}/${SUBJID}_dwi.nii.gz ${out_dir}/eddy_1_shell/${SUBJID}_run-1_dwi.nii.gz ${out_dir}/eddy_2_shell/${SUBJID}_run-2_dwi.nii.gz

#Extract b0 Maps for Topup
echo "Preparing b0 maps for topup"
fslroi ${out_dir}/eddy_1_shell/${SUBJID}_run-1_dwi.nii.gz ${out_dir}/AP_b0 0 -1 0 -1 0 -1 0 1
fslroi ${out_dir}/eddy_2_shell/${SUBJID}_run-2_dwi.nii.gz ${out_dir}/PA_b0 0 -1 0 -1 0 -1 0 1
fslmerge -a ${out_dir}/AP_b0_PA_b0 ${out_dir}/AP_b0 ${out_dir}/PA_b0
ln -sf ${out_dir}/AP_b0_PA_b0.nii.gz topup/.

#Create Acquisition Parameters File
echo "Creating acquisition parameters file"
echo 0 -1 0 ${rt} >${out_dir}/topup/acqparams.txt
echo 0 1 0 ${rt} >>${out_dir}/topup/acqparams.txt

#Run Topup
topup --imain=${out_dir}/topup/AP_b0_PA_b0 --datain=${out_dir}/topup/acqparams.txt --config=$FSLDIR/etc/flirtsch/b02b0.cnf --out=${out_dir}/topup/topup --iout=${out_dir}/topup/b0_unwarped --fout=${out_dir}/topup/fieldmap_Hz -v

#Create a binary brain mask for Eddy Current Correction
fslmaths ${out_dir}/topup/b0_unwarped -Tmean ${out_dir}/topup/b0_unwarped_mean
bet ${out_dir}/topup/b0_unwarped_mean ${out_dir}/topup/b0_unwarped_brain -m -f 0.3 -R

#Create Index File for eddy
#NOTE THAT THE VALUE IS THE NUMBER OF TIME POINTS AND MUST BE ADJUSTED ACCORDING TO THE STUDY
echo "Creating index file for eddy"
for ((i=0; i<${t}; ++i)); do
	indx="$indx 1";
done
echo $indx > ${out_dir}/index.txt

#Copy files to Eddy directory
ln -sf ${out_dir}/topup/b0_unwarped_brain_mask.nii.gz ${out_dir}/nodif_brain_mask.nii.gz
ln -sf ${out_dir}/topup/acqparams.txt ${out_dir}/

