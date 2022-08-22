% ----------------------------------------------------------------------
% Create Contrasts for the Imagery Experiment
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: this function creates 3 contrasts for the imagery experiment
% input: subdir (path to one participants' data in BIDS)
% output: con_000x.nii images in the stats folder.
% ----------------------------------------------------------------------
function create_contrasts(subdir)

SPM_path = fullfile(subdir, 'stats', 'SPM.mat'); 

% enter contrast names
contrast_names = {'Stimulation > Imagery', 'Imagery > Stimulation', ...
    'Imagery Flutter > Attention', 'Attention > Stimulation'}; 
ncontrasts = numel(contrast_names);

%% ----- create contrasts ----- %
% INDEXES regressors in design matrix (for one run)
% 1 = Stimulation vibration 
% 2 = Stimulation pressure 
% 3 = Stimulation flutter
% 4 = Imagery vibration 
% 5 = Imagery pressure 
% 6 = Imagery flutter
% 7 = Attention
% 8:13 = Realignment parameters

% prepare cell array
contrast_weights = cell(1, ncontrasts);

% stimulation > imagery
contrast_weights{1, 1} = [1 1 1 -1 -1 -1 0 0 0 0 0 0 0]; 

% imagery > stimulation
contrast_weights{1, 2} = [-1 -1 -1 1 1 1 0 0 0 0 0 0 0]; 

% imagery flutter > attention
contrast_weights{1, 3} = [0 0 1 0 0 0 -1 0 0 0 0 0 0]; 

% attention > stimulation 
contrast_weights{1, 4} = [-1 -1 -1 0 0 0 3 0 0 0 0 0 0]; 


%% ----- create matlab batch -----

for contrast = 1:ncontrasts 
    matlabbatch{contrast}.spm.stats.con.spmmat = {SPM_path};
    matlabbatch{contrast}.spm.stats.con.consess{1}.tcon.name = ...
        contrast_names{1, contrast};
    matlabbatch{contrast}.spm.stats.con.consess{1}.tcon.weights = ...
        contrast_weights{1, contrast};
    matlabbatch{contrast}.spm.stats.con.consess{1}.tcon.sessrep = 'repl';
    % 'repl' - replicate the contrast weights for the number of runs 
    matlabbatch{contrast}.spm.stats.con.delete = 0;
end 

%% ----- save & run batch -----
subject     = string(regexp(subdir,'sub-\d{2}','match'));
batchname   = fullfile(subdir,strcat(subject,'_contrasts.mat'));
save(batchname, 'matlabbatch');

spm_jobman('run', batchname);

disp(strcat('Successfully created contrast images in',32,subject,'/stats folder.'))
end 


