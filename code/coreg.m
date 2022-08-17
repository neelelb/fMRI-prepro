% ----------------------------------------------------------------------
% Coregistration Function for MoAE dataset
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: coregisters functional nifti images of participant 'sj'
% input:    dir_source (path to MoAE data), sj (sub-ID)
% output:   realigned func files written into participants' folder
% ----------------------------------------------------------------------
function coreg(dir_source, sj, format)
if nargin < 3; format = 'nii'; end 

% define the directories (BIDS format)
subdir           = fullfile(dir_source, sj);
subdir_func      = fullfile(dir_source, sj, 'func');
subdir_anat      = fullfile(dir_source, sj, 'anat');

%% ----- create matlab batch ----- %
if strcmp(format, 'nii') == 1 
    filt_anat = '^.*\.nii$';
    filt_func = '^mean.*\.nii$';
elseif strcmp(format, 'img') == 1
    filt_anat = '^.*\.img$';
    filt_func = '^mean.*\.img$';
else 
    message = 'Wrong specified file format. See input arguments.';
    error(message)
end 

[reference] = spm_select('ExtFPList', subdir_func, filt_func); % mean image
reference = cellstr(reference); 
if isempty(reference) == 1 
   message = 'No mean image found.'; 
   error(message)
elseif numel(reference) > 1
    disp('More than one mean image found. Using the mean image of run 1.')
    reference = reference{1, 1}; 
end 

[source] = spm_select('ExtFPList', subdir_anat, filt_anat); % anat image
source = cellstr(source); 
if isempty(source) == 1 
    message = 'No anatomical image found.'; 
    error(message)
end 

matlabbatch{1}.spm.spatial.coreg.estimate.ref = reference;
matlabbatch{1}.spm.spatial.coreg.estimate.source = source; 
matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = ...
    [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

%% ----- save & run batch -----

batchname = strcat(subdir,'_coregister.mat');
save(batchname, 'matlabbatch');

spm_jobman('run', batchname);

end