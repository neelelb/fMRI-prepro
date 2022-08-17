% ----------------------------------------------------------------------
% Estimate 1st level Function for MoAE dataset
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: estimate 1stlevel
% input:    dir_source (path to MoAE data), sj (sub-ID)
% output:   realigned func files written into participants' folder
% ----------------------------------------------------------------------
function est_first(dir_source, sj)

subdir      = fullfile(dir_source, sj);
dir_stats = fullfile(dir_source, sj, 'stats');

matlabbatch{1}.spm.stats.fmri_est.spmmat = {fullfile(dir_stats, 'SPM.mat')};
matlabbatch{1}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

%% ----- save & run batch -----
batchname = strcat(subdir,'_estimate.mat');
save(batchname, 'matlabbatch');

spm_jobman('run', batchname);

end