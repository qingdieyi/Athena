%% Athena_utest
% This interface allows to execute the Mann�Whitney U-Test between the
% groups of subjects.


function varargout = Athena_utest(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_utest_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_utest_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end


%% Athena_utest_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_utest_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    if nargin >= 4
        path = varargin{1};
        set(handles.aux_dataPath, 'String', path)
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
        if not(strcmp(path, 'Static Text')) && ...
                not(strcmp(measure, 'Static Text'))
            set(handles.dataPath_text, 'String', path)
        end
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin >= 7
        loc = varargin{4};
        if not(strcmp(loc, 'Static Text'))
            set(handles.aux_loc, 'String', loc)
        end
    end
    if nargin >= 8
        set(handles.sub_types, 'Data', varargin{5})
    end
    dataPath_text_Callback(hObject, eventdata, handles)
            
                  
function varargout = Athena_utest_OutputFcn(hObject, ~, handles) 
    varargout{1} = handles.output;


%% dataPath_text_Callback
% This function is called when the dataPath is modified, in order to
% refresh the interface, and to set the available measures.
function dataPath_text_Callback(hObject, eventdata, handles)
    auxPath = pwd;
    funDir = which('Athena.m');
    funDir = split(funDir, 'Athena.m');
    cd(funDir{1});
    addpath 'Auxiliary'
    addpath 'Graphics'
    addpath 'Epochs Analysis'
    dataPath = get(handles.dataPath_text, 'String');
    subjectsFile = strcat(path_check(limit_path(dataPath, ...
        get(handles.aux_measure, 'String'))), 'Subjects.mat');
    if exist(subjectsFile, 'file')
        set(handles.aux_sub, 'String', subjectsFile)
        try
            sub_info = load(subjectsFile);
            aux_sub_info = fields(sub_info);
            eval(strcat("sub_info = sub_info.", aux_sub_info{1}, ";"));
            sub_types = categories(categorical(sub_info(:, end)));
            if length(sub_types) == 2
                set(handles.sub_types, 'Data', sub_types)
            end
        catch
        end
    end
    if exist(dataPath, 'dir')
        measures = available_measures(dataPath, 1, 1);
        set(handles.measure, 'String', measures)
        set(handles.measure, 'Value', 1)
    end
    hands = [handles.asy_button, handles.tot_button, ...
        handles.glob_button, handles.areas_button];
    types = {'Asymmetry', 'Total', 'Global', 'Areas'};
    for i = 1:length(types)
        try
            data_name = measurePath(dataPath, measure, types{i});
            load(strcat(path_check(data_name), 'Second.mat'))
            if isempty(Second.data)
                set(hands(i), 'Enable', 'off')
            else
                load(strcat(path_check(data_name), 'First.mat'))
                if isempty(First.data)
                    set(hands(i), 'Enable', 'off')
                else
                    set(hands(i), 'Enable', 'on')
                end
            end
        catch
            set(hands(i), 'Enable', 'off')
        end
    end


function dataPath_text_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


%% Run_Callback
% This function is used when the Run button is pushed, and it executes the
% U-Test by using the selected measure, with the chosen parameters.
function Run_Callback(hObject, eventdata, handles)
    save_check = 0;
    if strcmpi(user_decision(...
            'Do you want to save the resulting tables?', 'U Test'), 'yes')
        save_check = 1;
    end
    dataPath = get(handles.dataPath_text, 'String');
    dataPath = path_check(dataPath);
    measure = define_measure(handles);
    if not(exist(dataPath, 'dir'))
    	problem(strcat("Directory ", dataPath, " not found"));
        return;
    end
    
    cons = [0 1];
    cons_selected = [get(handles.minCons, 'Value'), ...
        get(handles.maxCons, 'Value')];
    cons(cons_selected == 0) = [];
    
    an_selected = [get(handles.asy_button, 'Value'), ...
        get(handles.tot_button, 'Value'), ...
        get(handles.glob_button, 'Value'), ...
        get(handles.areas_button, 'Value')];
    an_paths = {'Asymmetry', 'Total', 'Global', 'Areas'};
    analysis = an_paths(an_selected == 1);
    
    data_name = measurePath(dataPath, measure, analysis);
    try
        [HC, ~, locs] = load_data(strcat(data_name, 'First.mat'));
        PAT = load_data(strcat(data_name, 'Second.mat'));
    catch
        problem(strcat(measure, " epochs averaging of not computed"));
        return;
    end
    
    subjects_types = get(handles.sub_types, 'Data');
    try
        sub_text = strcat("{'", string(subjects_types{1}), "','", ...
            string(subjects_types{2}), "'}");
    catch
        sub_text = strcat("{'", string(subjects_types{1}), "'}");
    end
    strcat(data_name, 'First.mat')
    Athena_history_update(strcat('statistical_analysis(', ...
        strcat("'", strcat(data_name, 'First.mat'), "'"), ',',  ...
        strcat("'", strcat(data_name, 'Second.mat'), "'"), ',', '[],', ...
        string(cons), ",", strcat("'", dataPath, "'"), ",", ...
        strcat("'", measure, "'"), ',', strcat("'", analysis{1}, "'"), ...
        ",", sub_text, ',', string(save_check), ')'));
    statistical_analysis(HC, PAT, locs, cons, dataPath, measure, ...
        analysis, get(handles.sub_types, 'Data'), save_check);


%% data_search_Callback
% This function allows to search the data directory through the file
% explorer.
function data_search_Callback(hObject, eventdata, handles)
    d = uigetdir;
    if d ~= 0
        set(handles.dataPath_text, 'String', d)
        auxPath = pwd;
        dataPath = get(handles.dataPath_text, 'String');
        dataPath = path_check(dataPath);
        cd(dataPath)
        if exist('auxiliary.txt', 'file')
            auxID = fopen('auxiliary.txt', 'r');
            fseek(auxID, 0, 'bof');
            while ~feof(auxID)
                proper = fgetl(auxID);
                if contains(proper, 'Locations=')
                    locations = split(proper, '=');
                    locations = locations{2};
                    set(handles.aux_loc, 'String', locations)
                end
            end
            fclose(auxID);     
        end
        cd(auxPath)
    end


function meas_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


%% back_Callback
% This function switches to the Statistical Analysis list interface.
function back_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    if strcmp(dataPath, 'es. C:\User\Data')
        dataPath = "Static Text";
    end
    close(Athena_utest)
    Athena_statistics(dataPath, measure, sub, loc, sub_types)


function axes3_CreateFcn(hObject, eventdata, handles)


function aux_loc_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject, 'BackgroundColor'), ...
            get(0, 'defaultUicontrolBackgroundColor'))
        set(hObject, 'BackgroundColor', 'white');
    end


%% measure_Callback
% This function is used to set the check buttons when a measure is
% selected.
function measure_Callback(hObject, eventdata, handles)
    measure = define_measure(handles);
    dataPath = get(handles.dataPath_text, 'String');
    hands = [handles.asy_button, handles.tot_button, ...
        handles.glob_button, handles.areas_button];
    types = {'Asymmetry', 'Total', 'Global', 'Areas'};
    for i = 1:length(types)
        try
            data_name = measurePath(dataPath, measure, types{i});
            load(strcat(path_check(data_name), 'Second.mat'))
            if isempty(Second.data)
                set(hands(i), 'Enable', 'off')
            else
                load(strcat(path_check(data_name), 'First.mat'))
                if isempty(First.data)
                    set(hands(i), 'Enable', 'off')
                else
                    set(hands(i), 'Enable', 'on')
                end
            end
        catch
            set(hands(i), 'Enable', 'off')
        end
    end

    
function measure_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


%% define_measure
% This function returns the name of the selected measure.
function measure = define_measure(handles)
    measures_list = get(handles.measure, 'String');
    if iscell(measures_list)
        measure = measures_list{get(handles.measure, 'Value')};
    else
    	measure = measures_list;
    end