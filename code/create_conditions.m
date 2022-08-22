% ----------------------------------------------------------------------
% Create Conditions for the Imagery Experiment
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: this function creates a conditions_run-XX.mat which specifies
% the names, onsets and durations for each condition for each run
% input: subdir (path to one participants' data in BIDS), nruns, duration
% output: conditions_run-XX.mat file written into participants' func folder
% ----------------------------------------------------------------------
function create_conditions(subdir, nruns, duration)

if nargin < 2; nruns = 1; end     % default of nrun is 1
if nargin < 3; duration = 6; end  % default of format is nii

% define the directories (BIDS format)
subdir_func = fullfile(subdir, 'func');

%% ----- load onset files -----
% names of the conditions
names = {'stimulation_vibration', 'stimulation_pressure', ...
    'stimulation_flutter', 'imagination_vibration', ...
    'imagination_pressure', 'imagination_flutter', 'attention'}; 

ncond = numel(names); % number of conditions 

% prepare cell arrays 
onsets = cell(1, ncond);
durations = cell(1, ncond);

% select the full filepaths of the log files 
filt = '^log.*$'; % still adapt (dependent on the new folder structure)
[files] = spm_select('FPList', subdir_func, filt);
files = cellstr(files);

% create condition.mat for every run (in SPM: session)
for run = 1:nruns 
    % specify filepath for log file of run XX
    log_file_path = files{run, 1}; 
    log_file = load(log_file_path); % load this log file

    design_matrix = log_file.log_ExPra19.Design;
    design_matrix(1, :) = design_matrix(1, :) ./ 1000; %tran sform to seconds
    
    % specify onsets for ncond conditions 
    onsets{1, 1} = design_matrix(1, (design_matrix(3, :) == 1 & ...
        design_matrix(4, :) == 1));
    onsets{1, 2} = design_matrix(1, (design_matrix(3, :) == 1 & ...
        design_matrix(4, :) == 2));
    onsets{1, 3} = design_matrix(1, (design_matrix(3, :) == 1 & ...
        design_matrix(4, :) == 3));
    onsets{1, 4} = design_matrix(1, (design_matrix(3, :) == 2 & ...
        design_matrix(4, :) == 1));
    onsets{1, 5} = design_matrix(1, (design_matrix(3, :) == 2 & ...
        design_matrix(4, :) == 2));
    onsets{1, 6} = design_matrix(1, (design_matrix(3, :) == 2 & ...
        design_matrix(4, :) == 3));
    onsets{1, 7} = design_matrix(1, (design_matrix(3, :) == 3)); 

    % specify the duration of the trials for each condition
    for condition = 1:ncond
        durations{1, condition} = duration; 
    end 
    
    % save the conditions for run XX as 'conditions_run-XX.mat' in
    % subdir_func
    conditions_path = fullfile(subdir_func, strcat('conditions_', ...
        sprintf('run-%02d', run), '.mat'));
    save(conditions_path, 'names', 'onsets', 'durations');

    clear onsets durations log_file design_matrix

end
disp('Successfully created condition file.')
end 
 