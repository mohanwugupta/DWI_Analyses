import os
import sys
from sys import argv
import dipy
import amico

print(sys.version)

amico.core.setup()

print sys.argv[1]
print sys.argv[2]

study = str(sys.argv[1])
subj = str(sys.argv[2])
print 'Study: ' + study
print 'Begining Subject ' + subj

#Define paths
base_dir = '/u/CHANGE/THIS/PATH/%s/derivatives/amico'%(study) #CHANGE PATH
dwi_bval = '%s/%s/bvals'%(base_dir, subj)
print 'bval path: ' + dwi_bval
dwi_bvec = '%s/%s/bvecs'%(base_dir, subj)
print 'bvec path: ' + dwi_bvec
dwi_scheme = '%s/%s/scheme'%(base_dir, subj)
print 'diffusion scheme path: ' + dwi_scheme
dwi_data = '%s/%s/data.nii.gz'%(base_dir,subj)
print 'diffusion data path: ' + dwi_data
dwi_mask = '%s/%s/nodif_brain_mask.nii.gz'%(base_dir, subj)
print 'diffusion data mask path: ' + dwi_mask

#Set the current AMICO directory
ae = amico.Evaluation(base_dir,'/',subj)

#Convert the bvec + bvals into scheme file
amico.util.fsl2scheme('%s' %(dwi_bval),'%s' %(dwi_bvec),schemeFilename = '%s' %(dwi_scheme), bStep = 100)

#Load the data
print 'Loading the data'
ae.load_data(dwi_filename = "%s" %(dwi_data), scheme_filename = "%s" %(dwi_scheme), mask_filename = "%s" %(dwi_mask), b0_thr = 0)

#Define the model
print 'Defining the model'
ae.set_model("NODDI")

#Generate kernels - only needs to be fully run once per study if all subjects have the same diffusion parameters
print 'Generating the kernels'
ae.generate_kernels()

#Load the kernels for the subject
print 'Loading the kernels'
ae.load_kernels()

#Fit the AMICO diffusion model
print 'Fitting the AMICO model'
ae.fit()

#Save the results in NIFTI format
print 'Saving AMICO maps'
ae.save_results()
