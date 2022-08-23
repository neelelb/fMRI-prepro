% ----------------------------------------------------------------------
% Normalization Function
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: normalize functional images with prefix w and apply the 
%   spatial normalization parameters to their biased-corrected anatomical 
%   image
% input: subdir (path to one participants' data in BIDS), anatomical
%   (default 1: anat also normalised, can be set to 0), format ('img' 
%   or 'nii', default is nii)
% output: normalized func files (and anat file) in participants' folder
% ----------------------------------------------------------------------
function normalise(subdir, nruns, voxel_size_func, voxel_size_anat, ...
    anatomical, format)

if nargin < 2; nruns = 1; end % default of nrun is 1
if nargin < 3; voxel_size_func = [2, 2, 2]; end 
% default of voxel_size_func is 2x2x2
if nargin < 4; voxel_size_anat = [1, 1, 1]; end 
% default of voxel_size_anat is 1x1x1
if nargin < 5; anatomical = 1; end % default of anatomical is 1
if nargin < 6; format = 'nii'; end % default of format is nii

% define the directories (BIDS format)
subdir_func = fullfile(subdir, 'func');
subdir_anat = fullfile(subdir, 'anat');

%% ----- create matlab batch ----- %
if strcmp(format, 'nii') == 1 
    filt_anat = '^y.*\.nii$';
    filt_anat_manat = '^m.*\.nii$';
elseif strcmp(format, 'img') == 1
    filt_anat = '^y.*\.img$';
    filt_anat_manat = '^m.*\.img$';
else 
    message = 'Wrong specified file format. See input arguments.'; 
    error(message)
end 

% SPM filter to select deformation field file
[deformation_field] = spm_select('FPList', subdir_anat, filt_anat); 
deformation_field = cellstr(deformation_field); 

for run = 1:nruns 
    if strcmp(format, 'nii') == 1 && nruns == 1
       filt_func = '^r.*\.nii$';
    elseif strcmp(format, 'nii') == 1 && nruns ~= 1
       filt_func = strcat('^r.*',sprintf('run-%02d',run));
    elseif strcmp(format, 'img') == 1 && nruns == 1 
       filt_func = '^r.*\.img$';
    elseif strcmp(format, 'img') == 1 && nruns ~= 1 
       filt_func = strcat('^r.*',sprintf('run-%02d',run));
    else 
    message = 'Wrong specified file format. See input arguments.'; 
    error(message)
    end

    % SPM filter to select all func files
    [files] = spm_select('ExtFPList', subdir_func, filt_func);
    files = cellstr(files); 
    files = cellstr(files); 
    % test if files found
    if isempty(files) == 1 
        message = 'No files found. Realigned the files?'; 
        error(message)
    else 
        matlabbatch{1}.spm.spatial.normalise.write.subj(run).resample = files;
    end 
    % test if file found
    if isempty(deformation_field) == 1 
        message = 'No deformation field found.'; 
        error(message)
    else
        matlabbatch{1}.spm.spatial.normalise.write.subj(run).def = ...
            deformation_field;
    end
end 

% matlab normalization batch to normalize func data
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb      = [-78 -112 -70
                                                                78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox     = voxel_size_func; 
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp  = 4;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix  = 'w';

% if anatomical is 1 (default): normalize anat file as well
if anatomical == 1
    matlabbatch{2}.spm.spatial.normalise.write.subj.def = deformation_field; 
    % SPM filter to select manat
    [manat] = spm_select('ExtFPList', subdir_anat, filt_anat_manat); 
    manat = cellstr(manat); 
    % test if file found
    if isempty(manat) == 1 
       message = 'No manat found.'; 
       error(message)
    end
    % matlab normalization batch for anat file
    matlabbatch{2}.spm.spatial.normalise.write.subj.resample    = manat;
    matlabbatch{2}.spm.spatial.normalise.write.woptions.bb      = [-78 -112 -70
                                                                    78 76 85];
    matlabbatch{2}.spm.spatial.normalise.write.woptions.vox     = voxel_size_anat;
    matlabbatch{2}.spm.spatial.normalise.write.woptions.interp  = 4;
    matlabbatch{2}.spm.spatial.normalise.write.woptions.prefix  = 'w';
end 


%% ----- save & run batch -----
subject     = string(regexp(subdir,'sub-\d{2}','match'));
batchname   = fullfile(subdir,strcat(subject,'_normalisation.mat'));
save(batchname, 'matlabbatch');

spm_jobman('run', batchname);
disp(strcat('Successfully ran normalisation for',32,subject))

end