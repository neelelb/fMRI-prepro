% ----------------------------------------------------------------------
% Smoothing Function for MoAE dataset
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: smoothes functional images 
% input:    dir_source (path to MoAE data), dir_spm (path to tpm folder in 
% spm), sj (sub-ID), format ('img' or 'nii', default is nii)
% output:   segmented anat files written into participants' folder
% ----------------------------------------------------------------------
function smooth(dir_source, sj, format)

if nargin < 3; format = 'nii'; end % default of format is nii

% define functional directories
subdir     = fullfile(dir_source, sj);
subdir_func     = fullfile(dir_source, sj, 'func');

% select filter according to image format based on BIDS file naming
if strcmp(format, 'nii') == 1 
    filt = '^w.*\.nii$';
elseif strcmp(format, 'img') == 1
    filt = '^w.*\.img$';
else 
    message = 'Wrong specified file format. See input arguments.'; 
    error(message)
end 


%% ----- create matlab batch ----- %
% SPM filter to select all func files
[files]            = spm_select('ExtFPList', subdir_func, filt); % select all
files              = cellstr(files); 

% matlab smoothing batch
matlabbatch{1}.spm.spatial.smooth.data      = files;
matlabbatch{1}.spm.spatial.smooth.fwhm      = [6 6 6];
matlabbatch{1}.spm.spatial.smooth.dtype     = 0;
matlabbatch{1}.spm.spatial.smooth.im        = 0;
matlabbatch{1}.spm.spatial.smooth.prefix    = 's';


%% ----- save & run batch -----
batchname = strcat(subdir,'_smoothing.mat');
save(batchname, 'matlabbatch');

spm_jobman('run', batchname);

end


