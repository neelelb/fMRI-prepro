% ----------------------------------------------------------------------
% Specificy 1st level Function 
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: creates a design matrix for 1st level stats
% input: subdir (path to one participants' data in BIDS)
% output: SPM.mat file written into participants' stats folder
% ----------------------------------------------------------------------
function spec_first(subdir, nruns, TR, realign, time, format)

if nargin < 2; nruns    = 1; end        % default of nrun is 1
if nargin < 3; TR       = 2; end        % default of TR
if nargin < 4; realign  = 1; end        % default of including realign par
if nargin < 5; time     = 'secs'; end   % default of time format is seconds
if nargin < 6; format   = 'nii'; end    % default of format is nii

% define the directories (BIDS format)
subdir_func = fullfile(subdir, 'func');

% create new stats subdirectory (sub-xx/stats) if there is no such folder
dir_stats = fullfile(subdir, 'stats');
if not(isfolder(dir_stats))
    mkdir(dir_stats)
end

%% ----- create matlab batch -----

% for loop for including each run
for run = 1:nruns
    % select filter according to image format & number of runs
    % based on BIDS file naming
    if strcmp(format, 'nii') == 1 && nruns == 1
       filt_func = '^swr.*\.nii$';
       filt_txt = '^rp.*\.txt$';
    elseif strcmp(format, 'nii') == 1 && nruns ~= 1
       filt_func = strcat('^swr.*', sprintf('run-%02d',run));
       filt_txt = strcat('^rp.*', sprintf('run-%02d',run));
    elseif strcmp(format, 'img') == 1 && nruns == 1 
       filt_func = '^swr.*\.img$';
       filt_txt = '^rp.*\.txt$';
    elseif strcmp(format, 'img') == 1 && nruns ~= 1 
       filt_func = strcat('^swr.*',sprintf('run-%02d',run));
       filt_txt = strcat('^rp.*', sprintf('run-%02d',run));
    else 
    message = 'Wrong specified file format. See input arguments.'; 
    error(message)
    end

    % SPM filter to select all func files
    [files] = spm_select('ExtFPList', subdir_func, filt_func);
    files   = cellstr(files);
    % account for error
    if isempty(files) == 1 
        message = 'No files found.'; 
        error(message)
    end 

    % filepath with conditions file
    if nruns == 1 
        file_condition = fullfile(subdir_func, 'conditions.mat');
    else 
        file_condition = fullfile(subdir_func, strcat('conditions_', ...
        sprintf('run-%02d', run), '.mat'));
    end

    if realign == 1 % include realignment parameters if TRUE
        % SPM filter to select all realignment parameter files
        [files_txt] = spm_select('FPList', subdir_func, filt_txt);
        files_txt   = cellstr(files_txt);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi_reg  = files_txt;
        % account for error
        if isempty(files) == 1 
            message = 'No realignment parameters found.'; 
            error(message)
        end 
    else % if realignment parameters should not be included
        disp('Realignment parameters not included in design matrix.')
    end 

    % include files & condition in matlab batch for each run
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = files;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi = {file_condition};
    
    % hard coded in each run
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond       = struct(...
        'name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).regress    = struct(...
        'name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).hpf        = 128;
end

% hard coded (independent of the run)
matlabbatch{1}.spm.stats.fmri_spec.dir              = {dir_stats};
matlabbatch{1}.spm.stats.fmri_spec.timing.units     = time;
matlabbatch{1}.spm.stats.fmri_spec.timing.RT        = TR; 
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t    = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0   = 8;
matlabbatch{1}.spm.stats.fmri_spec.fact             = struct('name',  ...
    {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt             = 1;
matlabbatch{1}.spm.stats.fmri_spec.global           = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh          = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask             = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi              = 'AR(1)';


%% ----- save & run batch -----
batchname = strcat(subdir,'_design_matrix.mat');
save(batchname, 'matlabbatch');

spm_jobman('run', batchname);

end