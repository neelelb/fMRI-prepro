% ----------------------------------------------------------------------
% Segmentation Function
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: segments anatomical images of one participant
% input: subdir (path to one participants' data in BIDS), dir_spm (path 
%   to tpm folder in spm), format ('img' or 'nii', default is nii)
% output: segmented T1 and deformation field files in participants' folder
% ----------------------------------------------------------------------
function segment(subdir, dir_spm, format)

if nargin < 3; format = 'nii'; end % default of format is nii

% define anatomical directories
subdir_anat = fullfile(subdir, 'anat');

% select filter according to image format based on BIDS file naming
if strcmp(format, 'nii') == 1 
    filt = '^.*\.nii$';
elseif strcmp(format, 'img') == 1
    filt = '^.*\.img$';
else 
    message = 'Wrong specified file format. See input arguments.'; 
    error(message)
end 

%% ----- create matlab batch ----- %
% SPM filter to select all func files
[t1]    = spm_select('ExtFPList', subdir_anat, filt);
t1      = cellstr(t1); 

% matlab segmentation batch
matlabbatch{1}.spm.spatial.preproc.channel.vols     = t1;
matlabbatch{1}.spm.spatial.preproc.channel.biasreg  = 0.001;
matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{1}.spm.spatial.preproc.channel.write    = [0 1];
matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm    = {fullfile(dir_spm, '/TPM.nii,1')};
matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus  = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm    = {fullfile(dir_spm, '/TPM.nii,2')};
matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus  = 1;
matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm    = {fullfile(dir_spm, '/TPM.nii,3')};
matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus  = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm    = {fullfile(dir_spm, '/TPM.nii,4')};
matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus  = 3;
matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm    = {fullfile(dir_spm, '/TPM.nii,5')};
matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus  = 4;
matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm    = {fullfile(dir_spm, '/TPM.nii,6')};
matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus  = 2;
matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{1}.spm.spatial.preproc.warp.mrf         = 1;
matlabbatch{1}.spm.spatial.preproc.warp.cleanup     = 1;
matlabbatch{1}.spm.spatial.preproc.warp.reg         = [0 0.001 0.5 0.05 0.2];
matlabbatch{1}.spm.spatial.preproc.warp.affreg      = 'mni';
matlabbatch{1}.spm.spatial.preproc.warp.fwhm        = 0;
matlabbatch{1}.spm.spatial.preproc.warp.samp        = 3;
matlabbatch{1}.spm.spatial.preproc.warp.write       = [0 1];
matlabbatch{1}.spm.spatial.preproc.warp.vox         = NaN;
matlabbatch{1}.spm.spatial.preproc.warp.bb          = [NaN NaN NaN
                                                        NaN NaN NaN];


%% ----- save & run batch -----
batchname = strcat(subdir,'_segmentation.mat');
save(batchname, 'matlabbatch');

spm_jobman('run', batchname);

end
