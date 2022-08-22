% ----------------------------------------------------------------------
% Smoothing Function
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: smoothes functional images 
% input: subdir (path to one participants' data in BIDS), nruns (as
%   integer), format ('img' or 'nii', default is nii)
% output: smoothed functional fileswritten into participants' folder
% ----------------------------------------------------------------------
function smooth(subdir, fwhm, nruns, format)

if nargin < 3; nruns = 1; end       % default of nrun is 1
if nargin < 4; format = 'nii'; end  % default of format is nii

% define functional directories
subdir_func = fullfile(subdir, 'func');

%% ----- create matlab batch ----- %
matlabbatch{1}.spm.spatial.smooth.data = cell(1,nruns);

% for loop for smoothing normalized functional data for each run
for run = 1:nruns
    % select filter according to image format & number of runs
    % based on BIDS file naming
    if strcmp(format, 'nii') == 1 
        if nruns == 1
            filt = '^w.*\.nii$';
        else 
            filt = strcat('^w.*',sprintf('run-%02d',run),'.*\.nii$');
        end
    elseif strcmp(format, 'img') == 1 
        if nruns == 1
            filt = '^w.*\.img$';
        else
            filt = strcat('^w.*',sprintf('run-%02d',run),'.*\.img$');
        end
    else 
        message = 'Wrong specified file format. See input arguments.'; 
        error(message)
    end

    % SPM filter to select all func files
    [files]     = spm_select('ExtFPList', subdir_func, filt);
    files       = cellstr(files); 

    % account for error
    if isempty(files) == 1 
        message = 'No files found.'; 
        error(message)
    end 
    % include files in matlab batch
    matlabbatch{1}.spm.spatial.smooth.data{run} = files;
end

% matlab smoothing batch
matlabbatch{1}.spm.spatial.smooth.fwhm      = [fwhm fwhm fwhm];
matlabbatch{1}.spm.spatial.smooth.dtype     = 0;
matlabbatch{1}.spm.spatial.smooth.im        = 0;
matlabbatch{1}.spm.spatial.smooth.prefix    = 's';


%% ----- save & run batch -----
batchname = strcat(subdir,'_smoothing.mat');
save(batchname, 'matlabbatch');

spm_jobman('run', batchname);
end
