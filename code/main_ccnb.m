% ----------------------------------------------------------------------
% FINAL ASSIGNMENT - Analyzing Real Participant
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI 
% course.....................Neurocognitive Methods and Data Analysis
% program....................Master of Cognitive Neuroscience, FU Berlin
% instructor.................Dr. Timo Torsten Schmidt
% semester...................Summer term 2022

% description: this code ...
% data: example fMRI data from one participant from a FU study about
% Tactile Imagery (data not opensource)
% ----------------------------------------------------------------------


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
    dir_source      = '/Users/neele/Documents/github/fMRI-prepro/data/ccnb';
    dir_spm         = '/Applications/MATLAB_R2021b.app/toolbox/spm12/tpm';
    disp('Hi Neele!')
elseif user == 'g'
    dir_analysis    = '[fill in your path to analysis code]'; 
    dir_source      = '[fill in your path to data]';
    dir_spm         = '[fill in your spm/tpm path]';
    disp('Welcome!')
else
    message = ['Code must be ''a'', ''n'', or ''g'' depending on which ' ...
        'computer this is running on. No directories could be assigned.']; 
    error(message)
end

cd(dir_analysis)

%% ----- Re-Format Data to Bids ----- %


%% ----- Initialise sub-IDs ----- %
% assuming that participants folders will be named according to the
% structure "ccnb_**xx", where xx denotes the participant number

% find all 'ccnb_**xx' folders in data source folder
ccnbs   = {dir(fullfile(dir_source, 'ccnb_*')).name}'; 
regex   = '\d{2}$'; % regular expression, look for xx
SJs     = regexp(ccnbs, regex, 'match'); % apply regex
N       = numel(SJs); % number of participants

% loop to rename 'ccnb_**xx' folders to 'sub-xx'
for subject = 1:N
    olddir = fullfile(dir_source, ccnbs{subject});
    newdir = fullfile(dir_source, string(strcat('sub-',SJs{subject})));
    movefile(olddir, newdir, 'f')
end


% move dicoms to dicom
% move log files to log folder

...




%% ----- Preprocessing For-Loop ----- %
% loops over 'subjects' in SJs and performs preprocessing steps
for subject = 1:N
    % initialise participants' subdirectory
    subdir = fullfile(dir_source, SJs{subject});

    % ---- Realignment ----- %
    % function realigns functional images
    realign(subdir)

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
% for subject = 1:N
%     % initialise participants' subdirectory
%     subdir = fullfile(dir_source, SJs{subject});
% 
%     % ----- Specify ----- %
%     % function specifies first level Design Matrix (SPM.mat)
%     % spec_first(subdir)
% 
%     % ----- Estimate ----- %
%     % function estimates formerly specified first level model (SPM.mat)
%     %est_first(subdir)
% end
