% ----------------------------------------------------------------------
% Normalization Function for MoAE dataset
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: normalize functional images with prefix w and apply the 
% spatial normalization parameters to their biased-corrected anatomical 
% image...
% input:    dir_source (path to MoAE data), sj (sub-ID)
% output:   realigned func files written into participants' folder
% ----------------------------------------------------------------------
function normalise(dir_source, sj, format, anatomical)
if nargin < 3; format = 'nii'; end 
if nargin < 4; anatomical = 1; end

% define the directories (BIDS format)
subdir     = fullfile(dir_source, sj);
subdir_func     = fullfile(dir_source, sj, 'func');
subdir_anat      = fullfile(dir_source, sj, 'anat');

%% ----- create matlab batch ----- %

% Define filter
if strcmp(format, 'nii') == 1 
    filt_anat = '^y.*\.nii$';
    filt_anat_manat = '^m.*\.nii$';
    filt_func = '^r.*\.nii$';
elseif strcmp(format, 'img') == 1 
    filt_anat = '^y.*\.img$';
    filt_anat_manat = '^m.*\.img$';
    filt_func = strcat('^r.*\.img$');
else 
    message = 'Wrong specified file format. See input arguments.'; 
    error(message)
end

% select realigned functional images 
[files] = spm_select('ExtFPList', subdir_func, filt_func); 
files = cellstr(files); 
if isempty(files) == 1 
    message = 'No files found. Realigned the files.'; 
    error(message)
else 
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = files;
end 

% select deformation field 
[deformation_field] = spm_select('FPList', subdir_anat, filt_anat); 
deformation_field = cellstr(deformation_field); 
if isempty(deformation_field) == 1 
    message = 'No deformation field found.'; 
    error(message)
else 
    matlabbatch{1}.spm.spatial.normalise.write.subj.def = deformation_field;
end 

matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [3 3 3];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';

if anatomical == 1
    matlabbatch{2}.spm.spatial.normalise.write.subj.def = deformation_field; 
    % select manat
    [manat] = spm_select('ExtFPList', subdir_anat, filt_anat_manat); 
    manat = cellstr(manat); 
    if isempty(manat) == 1 
       message = 'No manat found.'; 
       error(message)
    end
    matlabbatch{2}.spm.spatial.normalise.write.subj.resample = manat;
    matlabbatch{2}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
    matlabbatch{2}.spm.spatial.normalise.write.woptions.vox = [1 1 3];
    matlabbatch{2}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{2}.spm.spatial.normalise.write.woptions.prefix = 'w';
end 


%% ----- save & run batch -----
batchname = strcat(subdir,'_normalisation.mat');
save(batchname, 'matlabbatch');

spm_jobman('run', batchname);

end