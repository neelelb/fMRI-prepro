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
% data experiment 'm': mother of all experiments (MoAE) data as analyzed in 
% Ch.31 of SPM12 Manual (https://www.fil.ion.ucl.ac.uk/spm/doc/spm12_manual.pdf),
% data experiment 'h': example fMRI data from one participant from a FU 
% study about Tactile Imagery (data not publicly available)
% ----------------------------------------------------------------------

clear; close all; clc

%% ----- Initialise User's Paths ----- %

% !PLEASE NOTE!: if you are a guest and you want to make this run on your 
% device, please fill in your respective paths under user == 'g'. The
% dir_spm directory needs to point to the 'tpm' folder in your spm12
% folder.

user = input(['Insert ''a'' if you are Alex, ''n'' if you are Neele, ' ...
    'and ''g'' if you are a guest: '], 's');
exp = input(['Insert ''m'' if you want to analyse the data from ' ...
    'the SPM tutorial, insert ''h'' if you want to analyse the data from ' ...
    'the imagery experiment. '], 's');

if user == 'a'
    dir_analysis    = '/Users/AlexanderLenders/GitHub/fMRI-prepro/code';
    dir_source_m    = '/Users/AlexanderLenders/GitHub/fMRI-prepro/data/MoAEpilot';
    dir_source_h    = '/Users/AlexanderLenders/GitHub/fMRI-prepro/data/experiment';
    dir_spm         = '/Users/AlexanderLenders/Documents/MATLAB/spm12/tpm';
    disp('Hi Alex!')
elseif user == 'n'
    dir_analysis    = '/Users/neele/Documents/github/fMRI-prepro/code'; 
    dir_source_m    = '/Users/neele/Documents/github/fMRI-prepro/data/MoAE';
    dir_source_h    = '/Users/neele/Documents/github/fMRI-prepro/data/ccnb';
    dir_spm         = '/Applications/MATLAB_R2021b.app/toolbox/spm12/tpm';
    disp('Hi Neele!')
elseif user == 'g'
    dir_analysis    = '[fill in your path to analysis code]'; 
    dir_source_m    = '[fill in your path to MoAE data]';
    dir_source_h    = '[fill in your path to ccnb (Tactile Imagery) data]';
    dir_spm         = '[fill in your spm/tpm path]';
    disp('Welcome!')
else
    message = ['User must be ''a'', ''n'', or ''g'' depending on which '...
        'computer this is running on. No directories could be assigned.']; 
    error(message)
end

cd(dir_analysis)


%% ----- Initialise Parameters ----- %

% for Tactile Imagery experiment...
if exp == 'h'
    % --- set correct dir_source
    dir_source = dir_source_h;

    % --- Scanning & Preprocessing Parameters
    nruns      = 6;        % number of runs
    voxel_size = 3;        % voxel size for normalisation
    fwhm       = 6;        % ADAPT?, filter for smoothing
    time       = 'secs';   % time unit scans or seconds

    % --- Initialise Subject-IDs
    % assuming that participants folders will be named according to the
    % structure 'ccnb_**xx', where xx denotes the subject number.
    % Find all 'ccnb_**xx' folders and create 'sub-*' array: 
    ccnbs   = {dir(fullfile(dir_source, 'ccnb_*')).name}'; 
    regex   = '\d{2}$'; % regular expression, parse for xx
    SJs     = regexp(ccnbs, regex, 'match'); % apply regex
    SJs     = strcat('sub-',string(SJs)); % convert to 'sub-*' form
    N       = numel(SJs); % number of participants

    % --- Import DICOM files and create BIDS folder structure
    % import DICOM files, convert them into .nii and create a BID format
    % folder structure
    for subject = 1:N
        % renaming folder from 'ccnb_**xx' to 'sub-xx'
        olddir = fullfile(dir_source, ccnbs{subject});
        subdir = fullfile(dir_source, SJs{subject});
        movefile(olddir, subdir, 'f')

        % convert dicoms to nifti images & create BIDS structure
        import_bids(subdir, SJs{subject});
    end
   
% for MoAE experiment...
elseif exp == 'm'
    % --- set correct dir_source
    dir_source = dir_source_m;

    % --- Scanning & Preprocessing Parameters
    nruns      = 1;        % number of runs
    fwhm       = 6;        % filter setting for smoothing
    voxel_size = 3;        % voxel size for normalisation
    time       = 'scans';  % time unit: scans or seconds

    % --- Initialise Subject-IDs
    % find all 'sub-*' folders in data source folder. Extract 'sub-*' 
    % information in character array SJs containing all participants
    SJs     = {dir(fullfile(dir_source, 'sub-*')).name}';
    N       = numel(SJs); % number of participants
end



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
    normalise(subdir, nruns, voxel_size)

    % ----- Smoothing ----- %
    % function smoothes functional images with a FWHM of 6mm
    smooth(subdir, fwhm, nruns)

end


%% ----- First Level Analysis For-Loop ----- %
% loops over 'subjects' in SJs and performs first level analysis
for subject = 1:N
    % ----- TEMPORARY -------------%
    SJs = {dir(fullfile(dir_source, 'sub-*')).name}'; % array with sub-IDs
    N   = numel(SJs); % number of participants
    % initialise participants' subdirectory
    subdir = fullfile(dir_source, SJs{subject});
    % ----- TEMPORARY -------------%


    % ----- Create conditions ----- %
    if exp == 'm' 
        % create conditions.mat file for MoAE experiment in .../func
        names          = {'listening'}; 
        onsets{1,1}    = [6:12:78]; 
        durations{1,1} = 6; 
        conditions_path = fullfile(subdir, 'func', 'conditions.mat');
        save(conditions_path, 'names', 'onsets', 'durations'); 
    elseif exp == 'h'
       % function creates conditions.mat file for each run in .../func
       create_conditions(subdir, nruns)
    end 

    % ----- Specify design matrix %
    % function specifies first level Design Matrix (SPM.mat) according to 
    % spm12 manual instructions 
    spec_first_v2(subdir, nruns, 2, 1, time)

    % ----- Estimate ----- %
    % function estimates formerly specified first level model (SPM.mat)
    est_first(subdir)

    % ---- Contrasts ---- %
    % to be continued...
end




