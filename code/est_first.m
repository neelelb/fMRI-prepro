% ----------------------------------------------------------------------
% Estimate 1st level Function for MoAE dataset
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: estimate 1stlevel model for one participant
% input: subdir (path to one participants' data in BIDS)
% output: beta files in participants' stats folder
% ----------------------------------------------------------------------
function est_first(subdir)

% define stats directory of participant
dir_stats = fullfile(subdir, 'stats');

%% ----- create matlab batch -----
matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(dir_stats, 'SPM.mat')};
matlabbatch{1}.spm.stats.fmri_est.write_residuals   = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical  = 1;

%% ----- save & run batch -----
batchname = strcat(subdir,'_estimate.mat');
save(batchname, 'matlabbatch');

spm_jobman('run', batchname);

end