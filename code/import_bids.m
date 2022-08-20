% ----------------------------------------------------------------------
% Import BIDS Function
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: imports data in DICOM format and converts them into .nii files
% in BIDS folder structure
% input: 
% output: 
% ----------------------------------------------------------------------
function import_bids(subdir, subject) 

% This is a workaround which imports DICOM files with SPM 12, converts 
% the files into .nii-format and creates a BIDS folder structure. Note
% however, that no .json files are created. Furthermore, log-files have
% to be moved manually to the func folders.

% currently the dicom files are floating in newfolder
% this script 
% 1) generates folder in newdir similar to bids structure (log, anat, func)
% 2) moves the log files lying one level above newdir
% 3) converts dicoms to nifti files and structures them into the folders


%% Create BIDS folder structure

% create new directories (sub-xx/...) if they do not exist already
dir_anat    = fullfile(subdir, 'anat');
dir_func    = fullfile(subdir, 'func');
dir_log     = fullfile(subdir, 'log');
dir_dicom   = fullfile(subdir, 'dicom');
if not(isfolder(dir_anat));  mkdir(dir_anat);   end
if not(isfolder(dir_func));  mkdir(dir_func);   end
if not(isfolder(dir_log));   mkdir(dir_log);    end
if not(isfolder(dir_dicom)); mkdir(dir_dicom);  end

% move dicom files into dicom folder
dicom_files = {dir(fullfile(subdir, '*dcm')).name}';
for f = 1:numel(dicom_files)
  movefile(fullfile(subdir, dicom_files{f}), dir_dicom);
end

%%%%%%%% adapted until here, TBC

%% Import DICOM-Files with SPM

% create cell with dcm files:
filt = '^.*\.dcm';
[files] = spm_select('FPList', dir_dicom, filt);
files = cellstr(files);

% where to save the unsorted .nii files: 
raw_data = fullfile(dir_source, 'raw_data');
if exist(raw_data, 'dir') ~= 7
    mkdir(raw_data); 
end 

% specify matlab batch
matlabbatch{1}.spm.util.import.dicom.data = files; 
matlabbatch{1}.spm.util.import.dicom.root = 'patid';
matlabbatch{1}.spm.util.import.dicom.outdir = cellstr(raw_data); 
matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
matlabbatch{1}.spm.util.import.dicom.convopts.meta = 0;
matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;

% run batch
spm_jobman('run', matlabbatch);

%% Identify different types of scans, rename them and move them into BIDS folders

% identify in which folder SPM saved the data for subject XX
name_folder = dir(raw_data); 
name_folder = name_folder(~ismember({name_folder.name},{'.','..', ...
    '.DS_Store'})); % we only want the subject folder
name_folder = string(name_folder.name);

% this folder is called nii_dir now:
nii_dir = fullfile(raw_data, name_folder);

%% Structural scans
% create filters to identify the structural scans within this folder
filt_1 = 't1*'; 
filt_2 = 'anat*'; % if filt_1 does not work

t1_folder  = {dir(fullfile(nii_dir, filt_1)).name}'; 
if isempty(t1_folder) == 1
    t1_folder = {dir(fullfile(nii_dir, filt_2)).name}'; 
    % if filt_1 does not work, try out filt_2
end 

% if no filter works, one has to identify T1 scan manually...
if isempty(t1_folder) == 1 
    message = ['Sorry, we could not find the folder with T1w images.' ...
        'Please specify manually.']; 
    error(message)
end 

% in case it worked, specify directory
t1_folder = fullfile(nii_dir, (t1_folder{1,1}));

% specify .nii in this t1_folder
structural_scan = {dir(t1_folder).name}';
structural_scan = structural_scan{3,1}; % to ignore '.' and '..'

bids_format = strcat(sub_name, '_ses-01_T1w.nii'); % how to rename file

% where to move the file
move_to = fullfile(anat_filepath, bids_format);

% specify directory of the .nii file
move_from = fullfile(t1_folder, structural_scan);

% finally, move the file
copyfile(move_from, move_to)

%% Functional scans
% create filters to identify the functional scans 

filt_3 = 'ep*'; 
filt_4 = 'func*';

func_folders = {dir(fullfile(nii_dir, filt_3)).name}'; 
if isempty(func_folders) == 1; 
    func_folders = {dir(fullfile(nii_dir, filt_4)).name}'; 
end 

if isempty(func_folders) == 1; 
    message = ['Sorry, we could not find the folder with the ' ...
        'functional scans. Please specify manually.']; 
    error(message)
end 

nrun = numel(func_folders); % number of runs

for run = 1:nrun 
    run_name = string(func_folders{run, 1}); % name of folder for run XX
    run_path = fullfile(nii_dir, run_name); % directory of this folder
    run_string = sprintf('run-%02d', run); % creates 'run-XX'

    filt_5 = '^.*\.nii$'; % create filter for finding volumes 
    [files_vol] = spm_select('FPList', run_path, filt_5); % list volumes
    files_vol = cellstr(files_vol);

    nvol = numel(files_vol); % number of volumes

    for volume = 1:nvol
        % create new name for volume in BIDS format
        bids_volume = strcat(sub_name, '_ses-01_task_', run_string, '_', ...
            num2str(volume), '_bold.nii');
        move_from = files_vol{volume, 1}; % where to find the volume
        move_to = fullfile(func_filepath, bids_volume); % where to save it

        copyfile(move_from, move_to) % finally move the file
    end 
end 

% delete the unsorted files (critical)
rmdir(raw_data, 's');

disp('Succesfully imported.'); 
end

