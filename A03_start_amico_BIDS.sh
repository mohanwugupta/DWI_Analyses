#!/bin/sh

####################
#Use this script to initiate AMICO NODDI analysis on subjects
####################

#Setup Directory Paths
HOME_DIR=/u/CHANGE/THIS/PATH/

#Command Argument Inputs (If using wrapper script, these are already setup)
STUDY=${1}
SUBJID=${2}
AMICO_DIR=${HOME_DIR}/${STUDY}/derivatives/amico

GROUP_DIR_I=${HOME_DIR}/${STUDY}/derivatives
SUBJ_DIR_I=${HOME_DIR}/${STUDY}/derivatives/${SUBJID}
SUBJ_DIR=${HOME_DIR}/${STUDY}/derivatives/DTI/${SUBJID}
GROUP_DIR_O=${AMICO_DIR}
SUBJ_DIR_O=${AMICO_DIR}/${SUBJID}

dwi_dir=${HOME_DIR}/${STUDY}/derivatives/DTI/${SUBJID}
#Create an amico study folder if one does not already exist
mkdir -p ${SUBJ_DIR_O}

#LOOP THROUGH EACH SUBJECT
cd ${GROUP_DIR_I};

		#Prep files for NODDI
		echo "Organizing files for NODDI from Eddy current correction outputs"
		ln -sf ${dwi_dir}/eddy_unwarped_images.eddy_rotated_bvecs ${SUBJ_DIR_O}/bvecs
		ln -sf ${dwi_dir}/bvals ${SUBJ_DIR_O}/
		ln -sf ${dwi_dir}/nodif_brain_mask.nii.gz ${SUBJ_DIR_O}/
		ln -sf ${dwi_dir}/eddy_unwarped_images.nii.gz ${SUBJ_DIR_O}/data.nii.gz

		cd ${AMICO_DIR}/${SUBJID}
		echo "Running AMICO for Subject ${SUBJID}"
		python /u/project/CCN/kkarlsgo/data/pipeline_scripts/UCLA_final/Diffusion/BIDS/run_amico.py ${STUDY} ${SUBJID}
		echo "Finished AMICO for Subject ${SUBJID}"
			
		#ADJUST FISO AND FICVF OUTPUTS FOR ABTIN
		for noddi in _ICVF _ISOVF _OD _dir; do 
		mv ${SUBJ_DIR_O}/${SUBJID}/FIT${noddi}.nii.gz ${SUBJ_DIR_O}/${SUBJID}${noddi}.nii.gz
		done			
		mv ${SUBJ_DIR_O}/${SUBJID}/config.pickle ${SUBJ_DIR_O}/
		mkdir ${SUBJ_DIR_O}/NODDI
		mkdir ${SUBJ_DIR_O}/ABTIN
		mv ${SUBJ_DIR_O}/sub* ${SUBJ_DIR_O}/NODDI	

		#remove extraneous directory
		rm -r ${SUBJ_DIR_O}/NODDI/${SUBJID}
		rm -r ${SUBJ_DIR_O}/standard

		echo "${SUBJ_DIR_O}/NODDI">${SUBJ_DIR_O}/abtin.txt
		echo "${SUBJ_DIR_O}/ABTIN">>${SUBJ_DIR_O}/abtin.txt
		#CREATE ABTIN OUTPUT DIRECTORY
               	#Call the script to begin ABTIN
		echo "Running ABTIN for Subject ${SUBJID}"
		bash /u/project/CCN/kkarlsgo/mohanwug/DWI_tutorial/code/A04_start_abtin_BIDS.sh ${STUDY} ${SUBJID}
		echo "Finished ABTIN for Subject ${SUBJID}"

