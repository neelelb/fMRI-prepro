% ----------------------------------------------------------------------
% Coregistration Function
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: coregisters functional and anatomical images
% input: subdir (path to one participants' data in BIDS), format ('img' 
%   or 'nii', default is nii)
% output: files in participants' folder are coregistered
% ----------------------------------------------------------------------
function coreg(subdir, format)

if nargin < 2; format = 'nii'; end % default of format is nii

% define the directories (BIDS format)
subdir_func = fullfile(subdir, 'func');
subdir_anat = fullfile(subdir, 'anat');

% choose filter according to file format
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

%% ----- create matlab batch ----- %
% SPM filter to select mean func file
[reference] = spm_select('ExtFPList', subdir_func, filt_func); % mean image
reference = cellstr(reference); 
% test if mean image found
if isempty(reference) == 1 
   message = 'No mean image found.'; 
   error(message)
elseif numel(reference) > 1
    disp('More than one mean image found. Using the mean image of run 1.')
    reference = reference{1, 1}; 
end 

% SPM filter to select anat file
[source] = spm_select('ExtFPList', subdir_anat, filt_anat); % anat image
source = cellstr(source); 
% test if anat file found
if isempty(source) == 1 
    message = 'No anatomical image found.'; 
    error(message)
end 

% matlab coregistration batch
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