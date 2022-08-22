% ----------------------------------------------------------------------
% Import BIDS Function
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% 1) function: this is a workaround which imports DICOM files with SPM 12, 
% converts the files into .nii-format and creates a BIDS folder structure. 
% 2) Before: dicom files of subject are floating in subdir, logfiles are in
% parent-directory
% 3) Input: subdir (path to one participants' data), subject (sub-xx)
% 4) Output: this script
%   4.1) generates folder in subdir similar to bids structure (anat, func)
%   4.2) converts dcm to nii and structures files into anat & func,
%       while accounting for different runs and merging func files to 4D
%       nii images.
%   4.3) moves the log files lying in parent-dir to subdir/func
%   Note: no .json files are created.
% ----------------------------------------------------------------------
function import_bids(subdir, subject) 

%% ----- Create BIDS Folder Structure ----- % 

% create new directories (sub-xx/...) if they do not exist already
dir_anat    = fullfile(subdir, 'anat');
dir_func    = fullfile(subdir, 'func');
dir_dicom   = fullfile(subdir, 'dicom');
if not(isfolder(dir_anat));  mkdir(dir_anat);   end
if not(isfolder(dir_func));  mkdir(dir_func);   end
if not(isfolder(dir_dicom)); mkdir(dir_dicom);  end

% move dicom files into dicom folder
dicom_files = {dir(fullfile(subdir, '*dcm')).name}';
for f = 1:numel(dicom_files)
  movefile(fullfile(subdir, dicom_files{f}), dir_dicom);
end


%% ----- Convert DICOM-Files to Nifti Files using SPM ----- %

% create cell with dcm files:
filt    = '^.*\.dcm';
[files] = spm_select('FPList', dir_dicom, filt);
files   = cellstr(files);

% temporary folder to save the unsorted .nii files from conversion process 
tmp_nii = fullfile(subdir, '..', 'raw_data');
if exist(tmp_nii, 'dir') ~= 7
    mkdir(tmp_nii); 
end 

% specify matlab batch
matlabbatch{1}.spm.util.import.dicom.data               = files; 
matlabbatch{1}.spm.util.import.dicom.root               = 'patid';
matlabbatch{1}.spm.util.import.dicom.outdir             = cellstr(tmp_nii); 
matlabbatch{1}.spm.util.import.dicom.protfilter         = '.*';
matlabbatch{1}.spm.util.import.dicom.convopts.format    = 'nii';
matlabbatch{1}.spm.util.import.dicom.convopts.meta      = 0;
matlabbatch{1}.spm.util.import.dicom.convopts.icedims   = 0;

% run batch
spm_jobman('run', matlabbatch);

% Interim result: newly created nifti files in folder 'tmp_nii'. For each
% functional run one folder where each volume is stored as a 3D nifti
% image. Later those will be merged to one 4D nifti image.


%% ----- Rename & Sort Nifti-Scans and Log-Files ----- %

% 1) identify in which folder SPM saved the data for subject XX
    dir_nii = {dir(tmp_nii).name}';
    dir_nii = dir_nii{contains( ... % we only want the visible folder
                dir_nii, regexpPattern('^[^.].*'))}; 
    dir_nii = fullfile(tmp_nii, dir_nii);


% 2) Anatomical Scans
    % identify t1 folder and move file to sub-xx/anat
    
    % create two filters to identify the anatomical folder within this dir_nii
    filt_1 = 't1*'; filt_2 = 'anat*';
    
    % find folder
    dir_nii_t1  = {dir(fullfile(dir_nii, filt_1)).name}'; 
    if isempty(dir_nii_t1) == 1
        % if filt_1 does not work, try out filt_2
        dir_nii_t1 = {dir(fullfile(dir_nii, filt_2)).name}'; 
      
        % if no filter works, one has to identify T1 scan manually...
        if isempty(dir_nii_t1) == 1 
        message = ['Sorry, we could not find the folder with T1w images.' ...
            'Please specify manually.']; 
        error(message)
        end 
    end 
    % in case it worked, specify directory
    dir_nii_t1 = fullfile(dir_nii, (dir_nii_t1{1}));

    % identify t1 nifti file in this folder
    t1 = dir(dir_nii_t1);           % list content of folder
    t1 = t1([t1.isdir]==0).name;    % filter for file
    t1 = fullfile(dir_nii_t1, t1);  % full path to t1

    % rename and move it
    movefile(t1, ...
        fullfile(dir_anat, strcat(subject,'_ses-01_T1w.nii')), 'f');


% 3) Functional Scans
    % identify func folders, rename & move files to sub-xx/func
    
    % create filters to identify the functional folders 
    filt_3 = 'ep*'; filt_4 = 'func*';

    % find folders using one of the filters
    dir_nii_func = {dir(fullfile(dir_nii, filt_3)).name}'; 
    if isempty(dir_nii_func) == 1
        dir_nii_func = {dir(fullfile(dir_nii, filt_4)).name}'; 
        if isempty(dir_nii_func) == 1
        message = ['Sorry, we could not find the folder with the ' ...
            'functional scans. Please specify manually.']; 
        error(message)
        end
    end 

    % prepare & identify log files in parent folder
    filt        = strcat('^FMRI_log_',subject(5:6),'.*\.mat');
    [log_files] = spm_select('FPList', fullfile(subdir, '..'), filt);
    log_files   = cellstr(log_files);

    % loop over runs, merge nifti files to 4D and move to BIDS folder
    for run = 1:numel(dir_nii_func) 
        run_dir     = string(dir_nii_func{run, 1}); % name of folder
        run_path    = fullfile(dir_nii, run_dir);   % path to this folder
    
        % select all niftis in run_dir
        [files_vol] = spm_select('FPList', run_path, '^.*\.nii$'); % list volumes
        files_vol = cellstr(files_vol);
   
        % create BIDS-compliant file name
        run_name = strcat(subject, '_ses-01_task_', ...
                sprintf('run-%02d', run), '_bold.nii');
        
        % merge all 3D niftis from run to one 4D nifti
        spm_file_merge(files_vol, run_name)

        % move that 4D nifti to BIDS folder
        movefile(fullfile(run_path, run_name), dir_func, 'f')

        % finally, move matching log file into func folder as well
        log_name = strcat('log-file_', sprintf('run-%02d', run), '.mat');
        movefile(log_files{run, 1}, fullfile(dir_func, log_name), 'f'); 
    end 


% 4) Delete the temporary folder
    rmdir(tmp_nii, 's');
    disp(strcat('Succesfully imported to BIDS for participant: ', subject)); 

end

