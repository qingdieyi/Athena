%% distribution_histogram_analysis
% This function shows the scatterplot of the histogram of the distributions
% of a measure related to the groups of subjects
%
% distribution_histogram_analysis(dataPath, measure, area, ...
%     band_number, location_number, sub_types, parameter, ...
%     location_name, band_name)
%
% Input:
%   dataPath is the main  directory of the study
%   measure is the name of the analyzed measure
%   area is the spatial subdivision analyzed
%   band_number is the number of the analyzed frequency band
%   location_number is the number of the analyzed location
%   bins is the number of bins of the histogram, or a character array which
%       can be 'fd' or 'auto' in order to apply the Freedman-Diaconis rule,
%       or 'scott' in order to apply the Scott's rule
%   location_name is the name of the analyzed location ('' by default)
%   band_name is the name of the analyzed frequency band ('' by default)

function distribution_histogram_analysis(dataPath, measure, area, ...
    band_number, location_number, sub_types, bins, location_name, ...
    band_name)
    
    if nargin < 8
        location_name = '';
    end
    if nargin < 9
        band_name = '';
    end
        
    measure_path = path_check(strcat(path_check(dataPath), ...
        path_check(measure), path_check('Epmean'), area));
    
    if sum(contains(area, {'Asymmetry', 'Global'})) == 0
        location_number = 1;
    end
    
    [PAT, ~, locs] = load_data(strcat(measure_path, 'Second.mat'));
    HC = load_data(strcat(measure_path, 'First.mat'));
    
    PAT = check_data(PAT, location_number, band_number);
    HC = check_data(HC, location_number, band_number);

    distributions_histogram(HC, PAT, measure, ...
        sub_types, location_name, band_name, bins)
end


%% check_data
% This function returns the data vector used in distribution analysis
% 
% data = check_data(data, loc, band)
%
% Input:
%   data is the data matrix
%   loc is the location index
%   band is the frequency band index
%
% Output:
%   data is the data array

function data = check_data(data, loc, band)
    dim = length(size(data));
    aux_idx = max(loc, band);
    if dim == 1
        data = data(aux_idx);
    elseif dim == 2 && min(loc, band) == 1
        data = data(:, aux_idx);
    elseif dim == 2
        data = data(band, loc);
    else
        data = data(:, band, loc);
    end
    data = squeeze(data);
end