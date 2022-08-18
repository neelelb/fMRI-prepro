% ----------------------------------------------------------------------
% Realignment Function for MoAE dataset
% ----------------------------------------------------------------------
% group......................Neele Elbersgerd & Alexander Lenders
% task.......................fMRI, automatization of data processing

% function: realigns functional nifti images of participant 'sj'
% input:    dir_source (path to MoAE data), sj (sub-ID), nruns (as
% integer), format as string ('img' or 'nii', default is nii)
% output:   realigned func files written into participants' folder
% ----------------------------------------------------------------------
function realign(subdir, nruns, format)

if nargin < 2; nruns = 1; end       % default of nrun is 1
if nargin < 3; format = 'nii'; end  % default of format is nii

% define the functional directory (BIDS format)
subdir_func      = fullfile(subdir, 'func');


%% ----- create matlab batch ----- %
matlabbatch{1}.spm.spatial.realign.estwrite.data = cell(1,nruns);

% for loop for realigning functional data for each run
for run = 1:nruns
    % select filter according to image format & number of runs
    % based on BIDS file naming
    if strcmp(format, 'nii') == 1 
        if nruns == 1
            filt = '^.*\.nii$';
        else 
            filt = strcat('^.*',sprintf('run-%02d',run),'*\.nii$');
        end
    elseif strcmp(format, 'img') == 1 
        if nruns == 1
            filt = '^.*\.nii$';
        else
            filt = strcat('^.*run-',num2str(run),'*\.img$');
        end
    else 
        message = 'Wrong specified file format. See input arguments.'; 
        error(message)
    end

    % SPM filter to select all func files
    [files] = spm_select('ExtFPList', subdir_func, filt);
    files = cellstr(files);
    % account for error
    if isempty(files) == 1 
        message = 'No files found.'; 
        error(message)
    end 
    % include files in matlab batch
    matlabbatch{1}.spm.spatial.realign.estwrite.data{run} = files; 
end

% matlab realignment batch options
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality    = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep        = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm       = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm        = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp     = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap       = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight     = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which      = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp     = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap       = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask       = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix     = 'r';


%% ----- save & run batch -----
batchname = strcat(subdir,'_realign.mat');
save(batchname, 'matlabbatch');

spm_jobman('run', batchname);

end
