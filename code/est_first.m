% ----------------------------------------------------------------------
% Estimate 1st level Function
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: estimate 1stlevel model for one participant
% input: subdir (path to one participants' data in BIDS)
% output: beta files in participants' stats folder
% ----------------------------------------------------------------------
function est_first(subdir)

% define stats directory of participant
SPM_path = fullfile(subdir, 'stats', 'SPM.mat');


%% ----- create matlab batch -----
matlabbatch{1}.spm.stats.fmri_est.spmmat            = {SPM_path};
matlabbatch{1}.spm.stats.fmri_est.write_residuals   = 0;
matlabbatch{1}.spm.stats.fmri_est.method.Classical  = 1;


%% ----- save & run batch -----
subject     = string(regexp(subdir,'sub-\d{2}','match'));
batchname   = fullfile(subdir,strcat(subject,'_estimate.mat'));
save(batchname, 'matlabbatch');

spm_jobman('run', batchname);

disp(strcat('Successfully estimated first level model for',32,subject))
end