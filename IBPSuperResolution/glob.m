%% glob.m
%% Returns a cell array of image filenames 
function result = glob(directory, pattern)
files = [];
for i = 1:numel(pattern)
    % Get full name of files according to the search pattern given
    d = fullfile(directory, pattern{i});
    % Return a struct array containing info on each file
    files = [files; dir(d)];
end
% Pre-alocate a cell column vector
result = cell(numel(files), 1);
for i = 1:numel(result)
    % Return cell array of full filenames of files specified
    result{i} = fullfile(directory, files(i).name);
end
