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
function spec_first_v2(subdir, nruns, TR, time, duration, format, realign)

if nargin < 2; nruns = 1; end       % default of nrun is 1
if nargin < 3; TR = 2; end
if nargin < 4; time = 'secs'; end  % default of time format is seconds
if nargin < 5; duration = 6; end  % default of format is nii
if nargin < 6; format = 'nii'; end  % default of format is nii
if nargin < 7; realign = 0; end 

% define the directories (BIDS format)
subdir_func = fullfile(subdir, 'func');

% create new stats subdirectory (sub-xx/stats) if there is no such folder
dir_stats = fullfile(subdir, 'stats');
if not(isfolder(dir_stats))
    mkdir(dir_stats)
end

%% ----- load onset files -----
% specify the names of the conditions 
names = {'stimulation_vibration', 'stimulation_pressure', ...
    'stimulation_flutter', 'imagination_vibration', 'imagination_pressure', ...
    'imagination_flutter', 'attention'}; 

ncond = numel(names); % number of conditions in the design matrix

% prepare cell arrays
onsets = cell(1, ncond);
durations = cell(1, ncond);

filt = '^log.*\.mat$'; % adapt 
[files] = spm_select('FPList', subdir_func, filt);
files = cellstr(files);

for run = 1:nruns 

    log_file_path = files{run, 1}; 
    log_file = load(log_file_path); 
    design_matrix = log_file.log_ExPra19.Design;
    design_matrix(1, :) = design_matrix(1, :) ./ 1000; % to transform to seconds

    onsets{1, 1} = design_matrix(1, (design_matrix(3, :) == 1 & ...
        design_matrix(4, :) == 1));
    onsets{1, 2} = design_matrix(1, (design_matrix(3, :) == 2 & ...
        design_matrix(4, :) == 1));
    onsets{1, 3} = design_matrix(1, (design_matrix(3, :) == 3 & ...
        design_matrix(4, :) == 1));
    onsets{1, 4} = design_matrix(1, (design_matrix(3, :) == 2 & ...
        design_matrix(4, :) == 1));
    onsets{1, 5} = design_matrix(1, (design_matrix(3, :) == 2 & ...
        design_matrix(4, :) == 2));
    onsets{1, 6} = design_matrix(1, (design_matrix(3, :) == 2 & ...
        design_matrix(4, :) == 3));
    onsets{1, 7} = design_matrix(1, (design_matrix(3, :) == 3)); 

    for condition = 1:ncond
        durations{1, condition} = duration; % right format?
    end 

    conditions_path = fullfile(dir_stats, strcat('conditions_', ...
        sprintf('run-%02d', run), '.mat'));
    save(conditions_path, 'names', 'onsets', 'durations');

end
 
%% ----- create matlab batch -----

% matlab first function specification batch
matlabbatch{1}.spm.stats.fmri_spec.dir              = {dir_stats};
matlabbatch{1}.spm.stats.fmri_spec.timing.units     = time;
matlabbatch{1}.spm.stats.fmri_spec.timing.RT        = TR; % TR
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t    = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0   = 8;

% for loop for including each run
for run = 1:nruns
    % select filter according to image format & number of runs
    % based on BIDS file naming
    if strcmp(format, 'nii') == 1 && nruns == 1
       filt_func = '^swr.*\.nii$';
       filt_txt = '^rp.*\.txt$';
    elseif strcmp(format, 'nii') == 1 && nruns ~= 1
       filt_func = strcat('^swr.*',sprintf('run-%02d',run));
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
    file_condition = fullfile(dir_stats, strcat('conditions_', ...
        sprintf('run-%02d', run), '.mat'));

    if realign == 1
        % SPM filter to select all realignment parameter files
        [files_txt] = spm_select('FPList', subdir_func, filt_txt);
        files_txt   = cellstr(files);
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi_reg  = files_txt;
        % account for error
        if isempty(files) == 1 
            message = 'No realignment parameters found.'; 
            error(message)
        end 
    else 
        disp('Realignment parameters not included in design matrix.')
        matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi_reg  = {};
    end 

    % include files & condition in matlab batch for each run
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).scans = files;
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).multi = {file_condition};
    
    % hard coded
    matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
    % matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond.tmod  = 0;
    % matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond.pmod  = struct('name', {}, 'param', {}, 'poly', {});
    % matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond.orth  = 1;
    % matlabbatch{1}.spm.stats.fmri_spec.sess(run).regress    = struct('name', {}, 'val', {});
    % matlabbatch{1}.spm.stats.fmri_spec.sess(run).hpf        = 128;
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

%% moae 
%     matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond.name  = 'Listening';
%     matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond.onset = [6
%                                                               18
%                                                               30
%                                                               42
%                                                               54
%                                                               66
%                                                               78];
%     matlabbatch{1}.spm.stats.fmri_spec.sess(run).cond.duration = 6;