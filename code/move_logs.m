% ----------------------------------------------------------------------
% Move logs 
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: moves the log files to the sub-XX/func folder 
% input: 
% output: 
% ----------------------------------------------------------------------
function move_logs(dir_dcm, dir_source, nsubject, nruns) 

sub_name = sprintf('sub-%02d', nsubject); % create 'sub-XX' string
subdir = fullfile(dir_source, sub_name, 'func'); 

filt = '^FMRI_log.*.mat'; 
[files] = spm_select('FPList', dir_dcm, filt);
files = cellstr(files);

for run = 1:nruns 
    move_from = files{run, 1};
    new_name = strcat('log-file_', sprintf('run-%02d', run), '.mat');
    move_to = fullfile(subdir, new_name); 
    copyfile(move_from, move_to); 
end

end 

