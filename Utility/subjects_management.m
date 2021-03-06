%% subjects_management
% This function saves the only common subjects related to two different
% dataset, saving them in a subdirectory of the respective directory,
% saving the only common locations too, ordered in the same way.
%
% [subjects, locations] = subjects_management(test_path, retest_path, ...
%               subjects)
%
% Input:
%   test_path is the name of the directory containing the time series
%       related to the first recording session
%   retest_path is the name of the directory containing the time series
%       related to the second recording session
%   subjects is the matrix which contains the list of subjects with the
%       belonging group identifier on the last column, or the name of the
%       file (with the related path) which contains it (optional, a single
%       group will be considered if not given)

function [subjects, locations] = subjects_management(test_path, ...
    retest_path, subjects)

    if nargin < 3
        subjects = [];
    end

    test_cases = define_cases(test_path);
    retest_cases = define_cases(retest_path);
    test_locations = common_locations(test_path, 0);
    retest_locations = common_locations(retest_path, 0);
    
    locations = common_elements(test_locations, retest_locations);
    subjects_list = common_elements(test_cases, retest_cases);
    
    save_subjects(test_cases, subjects_list, locations);
    save_subjects(retest_cases, subjects_list, locations);
    
    if not(isempty(subjects))
        subjects = common_subjects_matrix(subjects, subjects_list);
    end
end


%% common_elements
% This function returns the only common elements between two cell arrays or
% two structures.
%
% common = common_elements(test, retest)
%
% Input:
%   test is the first cell array or structure (in the last case, the name
%       field will be evaluated)
%   test is the first cell array or structure (in the last case, the name
%       field will be evaluated)
%
% Output:
%   common is the cell array or the structure containing the only common
%       elements

function common = common_elements(test, retest)
    del_ind = [];
    for i = 1:length(test)
        check = 0;
        for j = 1:length(retest)
            try 
                cond = strcmpi(test{i}, retest{j});
            catch
                cond = contains(strtok(test(i).name, '.'), ...
                    strtok(retest(j).name, '.')) || ...
                    contains(strtok(retest(j).name, '.'), ...
                    strtok(test(i).name, '.'));
            end
            if cond == 1
                check = 1;
                break;
            end
        end
        if check == 0
            del_ind = [del_ind, i];
        end
    end
    test(del_ind) = [];
    common = test;
end


%% sort_locations
% This functions sorts the data matrix in such a way to sort the time
% series related to the only common locations, and in the same order.
%
% data = sort_locations(data, locations, sorted_locations)
%
% Input:
%   data is the (locations x samples) data matrix
%   locations is the list of locations related to the data matrix
%   sorted_locations is the list of common locations
%
% Output:
%   data is the (locations x samples) sorted data matrix which considers
%       the only common locations

function data = sort_locations(data, locations, sorted_locations)
    ind = [];
    for i = 1:length(sorted_locations)
        for j = 1:length(locations)
            if strcmpi(locations{j}, sorted_locations{i}) || ...
                    contains(locations{j}, sorted_locations{i})
                ind = [ind, j];
                break;
            end
        end
    end
    data = data(ind, :);
end


%% save_subjects
% This functions saves the only common subjects, ordering the time series
% related to the considered locations in the same way.
%
% save_subjects(cases, subjects_list, locations)
%
% Input:
%   cases is the structure which contains the information related to all
%       data files inside the same diretory
%   subjects_list is the list of data files which have to be considered
%   locations is the list of locations which have to be considered

function save_subjects(cases, subjects_list, locations)
    dataPath = path_check(cases(1).folder);
    outPath = path_check(create_directory(dataPath, 'Common_Subjects'));
    data = struct();
    for i = 1:length(cases)
        for j = 1:length(subjects_list)
            if contains(strtok(cases(i).name, '.'), ...
                    strtok(subjects_list(j).name, '.')) || ...
                    contains(strtok(subjects_list(j).name, '.'), ...
                    strtok(cases(i).name, '.'))
                [ts, fs, locs] = load_data(strcat(dataPath,cases(i).name));
                ts = sort_locations(ts, locs, locations);
                data.time_series = ts;
                data.fs = fs;
                data.locations = locations;
                save(strcat(outPath, strtok(cases(i).name, '.'), ...
                    '.mat'), 'data');
            end
        end
    end
end


%% common_subjects_matrix
% This function returns the subjects information matrix related to the onl
% considered subjects.
%
% subjects = common_subjects_matrix(subjects, subjects_list)
%
% Input:
%   subjects is the (subjects x information) subjects matrix
%   subjects_list is the (subjects x 1) list of considered subjects
%
% Output:
%   subjects is the (subjects x information) subjects matrix considering
%       the subjects contained in subjects_list

function subjects = common_subjects_matrix(subjects, subjects_list)
    del_ind = [];
    if min(size(subjects)) == 1
        subjects = load_data(subjects);
    end
    for i = 1:length(subjects)
        check = 0;
        for j = 1:length(subjects_list)
            try
                if contains(subjects_list(j).name, subjects{i, 1}) || ...
                        contains(subjects{i, 1}, subjects_list(j).name)
                    check = 1;
                    break;
                end
            catch
                if contains(subjects_list(j).name, ...
                        string(subjects(i, 1))) || ...
                        contains(string(subjects(i, 1)), ...
                        subjects_list(j).name)
                    check = 1;
                    break;
                end
            end
        end
        if check == 0
            del_ind = [del_ind, i];
        end
    end
    subjects(del_ind, :) = [];
end