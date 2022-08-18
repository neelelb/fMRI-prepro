% ----------------------------------------------------------------------
% FINAL ASSIGNMENT - Automatization of data processing (SPM12 manual)
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

% !PLEASE NOTE!: if you are a guest (aka Timo) and you want to make this run on your 
% device, please fill in your respective paths under user == 'g'. The
% dir_spm directory needs to point to the "tpm" folder in your spm12
% folder.

user = input(['Insert ''a'' if you are Alex, ''n'' if you are Neele, ' ...
    'and ''g'' if you are a guest: '], 's');
if user == 'a'
    dir_analysis    = '/Users/AlexanderLenders/GitHub/fMRI-prepro/code';
    dir_source      = '/Users/AlexanderLenders/GitHub/fMRI-prepro/data/MoAEpilot';
    dir_spm         = '/Users/AlexanderLenders/Documents/MATLAB/spm12/tpm';
    disp('Hi Alex')
elseif user == 'n'
    dir_analysis    = '/Users/neele/Documents/github/fMRI-prepro/code'; 
    dir_source      = '/Users/neele/Documents/github/fMRI-prepro/data/MoAE';
    dir_spm         = '/Applications/MATLAB_R2021b.app/toolbox/spm12/tpm';
    disp('Hi Neele!')
elseif user == 'g'
    dir_analysis    = '[fill in path to analysis code]'; 
    dir_source      = '[fill in path to data]';
    dir_spm         = '[fill in spm/tpm path]';
    disp('Welcome!')
else
    message = ['Code must be ''a'', ''n'', or ''g'' depending on which ' ...
        'computer this is running on. No directories could be assigned.']; 
    error(message)
end


%% ----- Initialise sub-IDs ----- %
% find all 'sub-*' folders in data source folder. Extract 'sub-*' 
% information in character array SJs containing all participants
SJs     = {dir(fullfile(dir_source, 'sub-*')).name}'; % array with sub-IDs
N       = numel(SJs); % number of participants


%% ----- Preprocessing For-Loop ----- %

% loops over participants 'subject' in SJs and performs preprocessing steps
for subject = 1:N
    subdir = fullfile(subdir);

    % ---- Realignment ----- %
    % function realigns functional images
    realign(subdir)

    % ---- Coregistration ----- %
    % function coregisters functional and anatomical images
    coreg(dir_source, SJs{subject})
    
    % ---- Segmentation ----- %
    % function segments T1w image of participant
    segment(dir_source, dir_spm, SJs{subject})

    % ---- Normalise ----- %
    % function normalises functional (& per default anatomical) images
    normalise(dir_source, SJs{subject})

    % ----- Smoothing ----- %
    % function smoothes functional images with a FWHM of 6mm
    smooth(dir_source, SJs{subject})

end


%% ----- First Level Analysis For-Loop ----- %

for subject = 1:N
    % ----- Specify ----- %
    % function specifies first level Design Matrix (SPM.mat) according to 
    % spm12 manual instructions 
    spec_first(dir_source, SJs{subject})

    % ----- Estimate ----- %
    % function estimates formerly specified first level model (SPM.mat)
    est_first(dir_source, SJs{subject})
end



