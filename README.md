
# showdata() function
- showdata() plots the varaibility and gain of smooth pursuit for average subjects.
- showdata() opens the preprocessed folder and runs the analysis on all subjects individually to estimate the gain and variability of smooth pursuit.
- showdata() also fits mixed-effect model to the data from all subjects pooled together.

# Inside preprocessed folder
- Seven separate files for seven subjects participated in the study.
- You can open each file in MATLAB to see the data, as well as the statistical analysis results for each subject. 
# Each data file contains:
- XdataI: Target velocity in each trial for stimulus size I (N x 1: N = number of trials)
- YdataI: Eye velocity in each trial for stimulus size I (N x 1: N = number of trials)
- RMSE_spem_I: RMSE of the fitted linear model for the subject fot stimulus size I
- sensitivity_spem_I: sensitivity (gain) of the fitted linear model for the subject fot stimulus size I

