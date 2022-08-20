% ----------------------------------------------------------------------
% Specificy 1st level Function for MoAE dataset
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: specifies SPM.mat for first level analysis according to the
%   spm12 MoAE dataset tutorial
% input: subdir (path to one participants' data in BIDS)
% output: SPM.mat file written into participants' stats folder
% ----------------------------------------------------------------------
function spec_first(subdir, nruns, time, format)

if nargin < 2; nruns = 1; end       % default of nrun is 1
if nargin < 3; time = 'secs'; end  % default of time format is seconds
if nargin < 4; format = 'nii'; end  % default of format is nii

% define the directories (BIDS format)
subdir_func = fullfile(subdir, 'func');

% create new stats subdirectory (sub-xx/stats) if there is no such folder
dir_stats = fullfile(subdir, 'stats');
if not(isfolder(dir_stats))
    mkdir(dir_stats)
end

%% ----- create matlab batch -----

% matlab first function specification batch
matlabbatch{1}.spm.stats.fmri_spec.dir              = {dir_stats};
matlabbatch{1}.spm.stats.fmri_spec.timing.units     = time;
matlabbatch{1}.spm.stats.fmri_spec.timing.RT        = 7;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t    = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0   = 8;

% for loop for including each run
for run = 1:nruns
    % select filter according to image format & number of runs
    % based on BIDS file naming
    if strcmp(format, 'nii') == 1 
        if nruns == 1
            filt = '^swr.*\.nii$';
        else 
            filt = strcat('^swr.*',sprintf('run-%02d',run),'*\.nii$');
        end
    elseif strcmp(format, 'img') == 1 
        if nruns == 1
            filt = '^swr.*\.img$';
        else
            filt = strcat('^swr.*run-',num2str(run),'*\.img$');
        end
    else 
        message = 'Wrong specified file format. See input arguments.'; 
        error(message)
    end

    % SPM filter to select all func files
    [files] = spm_select('ExtFPList', subdir_func, filt);
    files   = cellstr(files);
    % account for error
    if isempty(files) == 1 
        message = 'No files found.'; 
        error(message)
    end 
    % include files & condition in matlab batch for each run
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans      = files;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond.name  = 'Listening';
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond.onset = [6
                                                              18
                                                              30
                                                              42
                                                              54
                                                              66
                                                              78];
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond.duration = 6;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond.tmod  = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond.pmod  = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond.orth  = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi      = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).regress    = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi_reg  = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).hpf        = 128;
end

% matlab specify first level batch
matlabbatch{1}.spm.stats.fmri_spec.fact             = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt             = 1;
matlabbatch{1}.spm.stats.fmri_spec.global           = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh          = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask             = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi              = 'AR(1)';


%% ----- save & run batch -----
batchname = strcat(subdir,'_specify.mat');
save(batchname, 'matlabbatch');

spm_jobman('run', batchname);

end