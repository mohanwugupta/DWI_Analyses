#!/bin/sh

#Export Matlab Path #CHANGE PATH
export MATLABPATH=EXPORTMATLABPATH:$MATLABPATH

#Command Argument Inputs (If using wrapper script, these are already setup)
STUDY=${1}
SUBJID=${2}

#Setup Directory Paths - CHANGE
HOME_DIR=/u/CHANGE/THIS/PATH
AMICO_DIR=${HOME_DIR}/${STUDY}/derivatives/amico
SUBJ_DIR_O=${AMICO_DIR}/${SUBJID}

#Create a temporary input file that Matlab can read
echo ${SUBJ_DIR_O}>${SUBJ_DIR_O}/abtin_input.txt
echo ${SUBJ_DIR_O}>>${SUBJ_DIR_O}/abtin_input.txt
echo "Created Input file for subject ${SUBJID}."

cp /u/SCRIPT/LOCATION/A04_Karlsgodt_ABTIN.m ${SUBJ_DIR_O}
cd ${SUBJ_DIR_O};
#Call matlab script - THIS LINE MIGHT BE DIFFERENT FOR YOU
matlab -nodesktop -nojvm -nosplash -nodisplay -r "cd ${SUBJ_DIR_O}; run('${SUBJ_DIR_O}/A04_Karlsgodt_ABTIN.m'); exit"

