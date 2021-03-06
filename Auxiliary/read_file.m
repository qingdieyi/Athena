%% read_file
% This function is used in the batch mode to read the file containing the
% instruction to execute.
%
% parameters = read_file(dataFile)
%
% input:
%   dataFile is the name of the file (with its path) which contains all the
%       instructions to execute
%
% output:
%   parameters is a cell array which contains all the parameters which have
%       to be used in batch analysis (dataPath, fs, cf, epNum, filter_file,
%       epTime, tStart, totBand, measure, Subjects, locations, Index, 
%       MeasureExtraction, EpochsAverage, EpochsAnalysis, IndexCorrelation,
%       UTest, MeasuresCorrelation, ClassificationData, IC_Measure,
%       Group_IC, Areas_IC, Conservativeness_IC, Areas_EA, Areas_SA, 
%       Conservativeness_SA, Measure1, Measure2, Areas_MC, Group_MC,
%       MergingData, DataType, MergingMeasures, MergingAreas, Subject, 
%       Classification, ClassificationData, DefaultClassification, 
%       TrainPercentage, TreesNumber, FResampleValue, Pruning, 
%       Repetitions, MinimumClassExamples, PCAValue,
%       ScatterAnalysis, Scatter_Measure1, Scatter_Measure2, Scatter_Band1,
%       Scatter_Band2, Scatter_Location1, Scatter_Location2,
%       HistogramAnalysis, Histogram_Measure, Histogram_Bands,
%       Histogram_Location, Histogram_bins, DistributionsAnalysis,
%       Distributions_Measure, Distributions_Bands, UTestMeasure,
%       Distributions_Location, Distributions_Parameter, 
%       Descriptive_Measure, Descriptive_Band, Descriptive_Location, 
%       DescriptiveAnalysis, NetworkMetricsAnalysis, 
%       Network_Metrics_Measure, Network_Normalization, Network_Metric)

function parameters = read_file(dataFile)
    
    params_names = {'dataPath=', 'fs=', 'cf=', 'epNum=', 'epTime=', ...
        'tStart=', 'totBand=', 'measures=', 'Subjects=', 'Locations=', ...
        'Index=', 'MeasureExtraction=', 'EpochsAverage=', ...
        'EpochsAnalysis=', 'IndexCorrelation=', 'UTest=', ...
        'MeasuresCorrelation=', 'ClassificationData=', 'Group_IC=', ...
        'Areas_IC=', 'Conservativeness_IC=', 'Areas_EA=', 'Areas_UT=', ...
        'Conservativeness_UT=', 'Measure1=', 'Measure2=', 'Areas_MC=', ...
        'Group_MC=', 'MergingData=', 'MergingMeasures=', ...
        'MergingAreas=', 'Subject=', 'RF_Classification=', ...
        'DataType', 'RF_DefaultClassificationParameters=', ...
        'RF_TrainPercentage=', 'RF_TreesNumber=', 'RF_FResampleValue=', ...
        'RF_Pruning=', 'RF_Repetitions=', 'RF_MinimumClassExamples=', ...
        'RF_Evaluation=', 'RF_Rejection=', ...
        'NN_Classification=', 'NN_DefaultClassificationParameters=', ...
        'NN_TrainPercentage=', 'NN_HiddenLayersNumber=', ...
        'NN_ValidationValue=', 'NN_Repetitions=', ...
        'NN_MinimumClassExamples=', 'PCAValue=', 'NN_Evaluation=', ...
        'NN_Rejection=' , 'ScatterAnalysis=', 'Scatter_Measure1=', ...
        'Scatter_Measure2=', 'Scatter_Band1=', 'Scatter_Band2=', ...
        'Scatter_Location1=', 'Scatter_Location2=', ...
        'DistributionsAnalysis=', 'Distributions_Measure=', ...
        'Distributions_Band=', 'Distributions_Location=', ...
        'Distributions_Parameter=', 'HistogramAnalysis=', ...
        'Histogram_Measure=', 'Histogram_Band=', 'Histogram_bins=', ...
        'Histogram_Location=', 'save_figures=', 'format=', ...
        'filter_file=', 'Descriptive_Measure=', 'Descriptive_Band=', ...
        'Descriptive_Location=', 'DescriptiveAnalysis=', ...
        'NetworkMetricsAnalysis=', 'Network_Metrics_Measure=', ...
        'Network_Normalization=', 'Network_Metric=', 'UTestMeasure=', ...
        'IC_Measure='};
    n_params = length(params_names);
    pre_parameters = cell(n_params, 1);
    
    aux_cases = 1:n_params;
    par_cases = {aux_cases(contains(params_names, 'Conservativeness'))};
    par_cases = [par_cases, [aux_cases(contains(params_names, 'fs')), ...
        aux_cases(contains(params_names, 'epNum')), ...
        aux_cases(contains(params_names, 'epTime')), ...
        aux_cases(contains(params_names, 'tStart')), ...
        aux_cases(contains(params_names, 'RF_Repetitions')), ...
        aux_cases(contains(params_names, 'RF_MinimumClassExamples')), ...
        aux_cases(contains(params_names, 'RF_TrainPercentage')), ...
        aux_cases(contains(params_names, 'RF_TreesNumber')), ...
        aux_cases(contains(params_names, 'MergingAreas')), ...
        aux_cases(contains(params_names, 'RF_FResampleValue')), ...
        aux_cases(contains(params_names, 'RF_Rejection')), ...
        aux_cases(contains(params_names, 'NN_Repetitions')), ...
        aux_cases(contains(params_names, 'NN_MinimumClassExamples')), ...
        aux_cases(contains(params_names, 'NN_TrainPercentage')), ...
        aux_cases(contains(params_names, 'NN_HiddenLayersNumber')), ...
        aux_cases(contains(params_names, 'NN_ValidationValue')), ...
        aux_cases(contains(params_names, 'PCAValue')), ...
        aux_cases(contains(params_names, 'NN_Rejection')), ...
        aux_cases(contains(params_names, 'Scatter_Band1')), ...
        aux_cases(contains(params_names, 'Scatter_Band2')), ...
        aux_cases(contains(params_names, 'Distributions_Band')), ...
        aux_cases(contains(params_names, 'Histogram_Band')), ...
        aux_cases(contains(params_names, 'Descriptive_Band'))]];
    par_cases = [par_cases, ...
        [aux_cases(contains(params_names, 'measures')), ...
        aux_cases(contains(params_names, 'Areas_')), ...
        aux_cases(contains(params_names, 'Group_')), ...
        aux_cases(contains(params_names, 'MergingMeasures')), ...
        aux_cases(contains(params_names, 'MergingAreas')), ...
        aux_cases(contains(params_names, 'totBand'))]];
    cf = 3;
    par_functions = {@cons_check, @str2double, @split};
    
    
    auxID = fopen(dataFile, 'r');
    fseek(auxID, 0, 'bof');
    while ~feof(auxID)
        prop = fgetl(auxID);
        for i = 1:n_params
            if contains(prop, params_names{i})
                aux_par = split(prop, '=');
                aux_par = aux_par{2};
                if contains(prop, 'cf=')
                    pre_parameters{cf} = cf_reader(aux_par);
                else
                    check = 0;
                    for j = 1:length(par_functions)
                        if not(isempty(find(par_cases{j} == i)))
                            p_f = par_functions{j};
                            pre_parameters{i} = p_f(aux_par);
                            check = 1;
                        end
                    end
                    if check == 0
                        pre_parameters{i} = aux_par;
                    end
                end
            end
        end
    end
    fclose(auxID);
    
    n = length(pre_parameters)*2;
    parameters = cell(1, n);
    for i = 1:2:n
        idx = floor(i/2)+1;
        name = char_check(params_names{idx});
        parameters{i} = string(name(1:end-1));
        parameters{i+1} = pre_parameters{idx};
    end
end