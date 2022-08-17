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
% device, please fill in your respective paths under user == 'g'. 

user = input('Insert ''a'' if you are Alex, ''n'' if you are Neele, and ''g'' if you are a guest: ', 's');
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
    dir_analysis    = ''; 
    dir_source      = '';
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

for subject = 1:N
    % ---- Realignment ----- %
    % function realigns functional nifti images of participant 'sj'
    % realign(dir_source, SJs{subject})

    % ---- Coregistration ----- %
    % coreg(dir_source, SJs{subject})
    
    % ---- Segmentation ----- %
    % segment(dir_source, dir_spm, SJs{subject})

    % ---- Normalise ----- %
    normalise(dir_source, SJs{subject})

    % ----- Smoothing ----- %
    smooth(dir_source, SJs{subject})

end

%% ----- First Level Analysis For-Loop ----- %

for subject = 1:N
    % ----- Specify ----- %
    spec_first(dir_source, SJs{subject})

    % ----- Estimate ----- %
    est_first(dir_source, SJs{subject})
end



