% ----------------------------------------------------------------------
% FINAL ASSIGNMENT - Automatization of data processing
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI 
% course.....................Neurocognitive Methods and Data Analysis
% program....................Master of Cognitive Neuroscience, FU Berlin
% instructor.................Dr. Timo Torsten Schmidt
% semester...................Summer term 2022

% description: this code ...
% data: mother of all experiments (MoAE) data as analyzed in Chapter 31 of 
% SPM12 Manual (https://www.fil.ion.ucl.ac.uk/spm/doc/spm12_manual.pdf),
% in BIDS format
% ----------------------------------------------------------------------

clear; close all; clc

%% ----- Initialise User's Paths ----- %

% !PLEASE NOTE!: if you are a guest and you want to make this run on your 
% device, please fill in your respective paths under user == 'g'. The
% dir_spm directory needs to point to the "tpm" folder in your spm12
% folder.

user = input(['Insert ''a'' if you are Alex, ''n'' if you are Neele, ' ...
    'and ''g'' if you are a guest: '], 's');

experiment = input(['Insert ''m'' if you want to analyse the data from ' ...
    'the SPM tutorial, insert ''h'' if you want to analyse the data from ' ...
    'the imagery experiment. '], 's');

if user == 'a'
    dir_analysis    = '/Users/AlexanderLenders/GitHub/fMRI-prepro/code';
    if experiment == 'm' 
       dir_source = '/Users/AlexanderLenders/GitHub/fMRI-prepro/data/MoAEpilot';
    elseif experiment == 'h'
       dir_source = '/Users/AlexanderLenders/GitHub/fMRI-prepro/data/experiment';
       dir_dcm    = '/Users/AlexanderLenders/GitHub/fMRI-prepro/data/NCM-II Homework Dataset';
    end
    dir_spm         = '/Users/AlexanderLenders/Documents/MATLAB/spm12/tpm';
    disp('Hi Alex!')
elseif user == 'n'
    dir_analysis    = '/Users/neele/Documents/github/fMRI-prepro/code'; 
    if experiment == 'm'
       dir_source = '/Users/neele/Documents/github/fMRI-prepro/data/MoAE';
    elseif experiment == 'h'
       % dir_source = '/Users/AlexanderLenders/GitHub/fMRI-prepro/data/experiment';
       % dir_dcm    = '/Users/AlexanderLenders/GitHub/fMRI-prepro/data/NCM-II Homework Dataset';
    end
    dir_spm         = '/Applications/MATLAB_R2021b.app/toolbox/spm12/tpm';
    disp('Hi Neele!')
elseif user == 'g'
    dir_analysis    = '[fill in your path to analysis code]'; 
    if experiment == 'm'
        dir_source = '[fill in your path to data]';
    elseif experiment == 'h'
       dir_source  = '[fill in your path to data]';
       dir_dcm     = '[fill in your path to data]';
    end
    dir_spm         = '[fill in your spm/tpm path]';
    disp('Welcome!')
else
    message = ['Code must be ''a'', ''n'', or ''g'' depending on which ' ...
        'computer this is running on. No directories could be assigned.']; 
    error(message)
end

cd(dir_analysis)

if experiment == 'h'
    %% ----- Parameters ----- %
    nruns = 6; 
    %% ----- Import DICOM files and create BID folder structure ----- %
    % import DICOM files, convert them into .nii and create a BID format
    % folder structure
    SJs     = {dir(fullfile(dir_dcm, 'ccnb*')).name}'; % array with sub-IDs
    N       = numel(SJs); % number of participants

    for nsubject = 1:N
        sub = SJs{nsubject, 1}; 
        import_bids(dir_dcm, dir_source, sub, nsubject);
    end
elseif experiment == 'm'
    nruns = 1;
end

%% ----- Initialise sub-IDs ----- %
% find all 'sub-*' folders in data source folder. Extract 'sub-*' 
% information in character array SJs containing all participants
SJs     = {dir(fullfile(dir_source, 'sub-*')).name}'; % array with sub-IDs
N       = numel(SJs); % number of participants


%% ----- Preprocessing For-Loop ----- %
% loops over 'subjects' in SJs and performs preprocessing steps
for subject = 1:N
    % initialise participants' subdirectory
    subdir = fullfile(dir_source, SJs{subject});

    % ---- Realignment ----- %
    % function realigns functional images
    realign(subdir, nruns)

    % ---- Coregistration ----- %
    % function coregisters functional and anatomical images
    coreg(subdir)
    
    % ---- Segmentation ----- %
    % function segments T1w image of participant
    segment(subdir, dir_spm)

    % ---- Normalise ----- %
    % function normalises functional (& per default anatomical) images
    normalise(subdir)

    % ----- Smoothing ----- %
    % function smoothes functional images with a FWHM of 6mm
    smooth(subdir)

end


%% ----- First Level Analysis For-Loop ----- %
% loops over 'subjects' in SJs and performs first level analysis
for subject = 1:N
    % initialise participants' subdirectory
    subdir = fullfile(dir_source, SJs{subject});

    % ----- Specify ----- %
    % function specifies first level Design Matrix (SPM.mat) according to 
    % spm12 manual instructions 
    spec_first(subdir)

    % ----- Estimate ----- %
    % function estimates formerly specified first level model (SPM.mat)
    est_first(subdir)
end



