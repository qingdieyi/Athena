%% Athena_tfShow
% This function is used to execute the time-frequency analysis of the time
% series, allowing to select the time window, the cut frequencies, the
% location, and to switch between the subjects.


function varargout = Athena_tfShow(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_tfShow_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_tfShow_OutputFcn, ...
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


%% data_search_Callback
% This function allows to search the data directory through the file
% explorer.
function Athena_tfShow_OpeningFcn(hObject, ~, handles, varargin)
    handles.output = hObject;
    try 
        net_name = strcat(path_check(limit_path(mfilename('fullpath'), ...
            'Graphics')), 'Classification', filesep, 'TrainedDNN', ...
            filesep, 'commandNet.mat');
        load(net_name);
        handles.net = trainedNet;
    catch
    end
    guidata(hObject, handles);
    try
        handles.signal.Children.CData = [];
    catch
    end
    myImage = imread('logo.png');
    set(handles.signal, 'Units', 'pixels');
    resizePos = get(handles.signal, 'Position');
    myImage = imresize(myImage, [resizePos(3) resizePos(3)]);
    axes(handles.signal);
    imshow(myImage);
    set(handles.signal, 'Units', 'normalized');
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    if nargin >= 4
        f = waitbar(0, 'Initialization', 'Color', '[1 1 1]');
        fchild = allchild(f);
        fchild(1).JavaPeer.setForeground(...
            fchild(1).JavaPeer.getBackground.BLUE)
            fchild(1).JavaPeer.setStringPainted(true)
        dataPath = varargin{1};
        dataPath = path_check(dataPath);
        set(handles.aux_dataPath, 'String', dataPath)
        if exist(dataPath, 'dir')
            cases = define_cases(dataPath);
            case_name = split(cases(1).name, '.');
            case_name = case_name{1};
            set(handles.Title, 'String', ...
                strcat("    subject: ", case_name));
            [data, fs, locs] = load_data(strcat(dataPath, cases(1).name));
            if size(data, 1) > size(data, 2)
                data = data';
            end
            if isempty(locs)
                NLOC = min(size(data));
                locs = cell(NLOC, 1);
                for i = 1:NLOC
                    locs{i} = char_check(string(i));
                end
            end
            set(handles.locs_ind, 'Data', [1; zeros(length(locs)-1, 1)]);
            set(handles.locs_matrix, 'Data', locs);
            set(handles.signal_matrix, 'Data', data);
            set(handles.case_number, 'String', '1');
            if not(isempty(fs))
                set(handles.fs_text, 'String', string(fs));
                set(handles.fs_check, 'String', 'detected');
            else
                fs_ClickedCallback(1, 1, handles)
            end
            set(handles.time_shown_value, 'Data', [0, min(10, ...
                length(data)/str2double(get(handles.fs_text, 'String')))])
            waitbar(0.5, f)
            close(f)
            start_show_ClickedCallback(1, 1, handles);
        else
            set(handles.Title, 'String', "    Data directory not found");
        end
    end
    if nargin >= 5
        measure = varargin{2};
        set(handles.aux_measure, 'String', measure)
    end
    if nargin >= 6
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin >= 7
        set(handles.aux_loc, 'String', varargin{4})
    end
    if nargin >= 8
        set(handles.sub_types, 'Data', varargin{5})
    end

    
function varargout = Athena_tfShow_OutputFcn(~, ~, handles) 
    varargout{1} = handles.output;


%% back_Callback
% This function switches to the initial interface of the toolbox.
function back_Callback(~, ~, handles)
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    close(Athena_tfShow)
    Athena(dataPath, measure, sub, loc, sub_types)


function signal_CreateFcn(~, ~, ~)


%% next_Callback
% This function allows to show the time-frequency analysis related to the
% following signal's file in the data directory.
function next_Callback(hObject, eventdata, handles)
    case_number = str2double(get(handles.case_number, 'String'))+2;
    set(handles.case_number, 'String', string(case_number));
    Previous_Callback(hObject, eventdata, handles)
    

function Ampliude_text_Callback(~, ~, ~)


function Ampliude_text_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), ....
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function time_text_Callback(~, ~, ~)


function time_text_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


%% Previous_Callback
% This function allows to show the time-frequency analyisi related to the
% previous signal's file in the data directory.
function Previous_Callback(~, ~, handles)    
    dataPath = get(handles.aux_dataPath, 'String');
    dataPath = path_check(dataPath);
    case_number = str2double(get(handles.case_number, 'String'))-1;
    cases = define_cases(dataPath);
    case_max = length(cases);
    if case_number <= case_max && case_number > 0
        f = waitbar(0, 'Data loading', 'Color', '[1 1 1]');
        fchild = allchild(f);
        fchild(1).JavaPeer.setForeground(...
            fchild(1).JavaPeer.getBackground.BLUE)
        fchild(1).JavaPeer.setStringPainted(true)
        [data, fs, locs] = load_data(strcat(dataPath, ...
            cases(case_number).name));
        waitbar(0.5, f, 'Processing your data')
        hold off
        if size(data, 1) > size(data, 2)
            data = data';
        end
        if isempty(locs)
            locs = get(handles.locs_matrix, 'Data');
            check = 0;
            for i = 1:length(locs)
                if not(strcmp(locs{i}, string(i)))
                    check = 1;
                    break;
                end
            end
            if check == 0
                NLOC = min(size(data));
                locs = cell(NLOC, 1);
                for i = 1:NLOC
                    locs{i} = char_check(string(i));
                end
            end    
        end
        locs_ind = 1;
        set(handles.signal_matrix, 'Data', data);
        set(handles.locs_matrix, 'Data', locs);
        set(handles.locs_ind, 'Data', [1; zeros(length(locs)-1, 1)]);
        time = get(handles.time_shown_value, 'Data');
        fs = find_fs(fs, handles);
        set(handles.time_shown_value, 'Data', [0, ...
            min(time(2)-time(1), length(data)/fs)])
        set(handles.case_number, 'String', case_number);
        case_name = split(cases(case_number).name, '.');
        case_name = case_name{1};
        set(handles.Title, 'String', strcat("    subject: ", case_name));
        close(f)
        start_show_ClickedCallback(1, 1, handles);
    elseif case_number > length(cases)
        set(handles.case_number, 'String', string(case_max));
    else
        set(handles.case_number, 'String', '1');
    end
    

%% right_Callback
% This function allows to show the time-frequency analysis related to the
% following one second forward time window.
function right_Callback(~, ~, handles)
    [data, fmin, fmax, time, fs] = get_data(handles);
    time = time+1;
    Limit = max(size(data));
    if time(2)*fs <= Limit
        set(handles.time_shown_value, 'Data', time)
    else
        dt = time(2)-time(1);
        set(handles.time_shown_value, 'Data', [Limit/fs-dt Limit/fs])
    end
    start_show_ClickedCallback(1, 1, handles);
    

%% left_Callback
% This function allows to show the time-frequency analysis related to the
% previous one second backward time window.
function left_Callback(~, ~, handles)
    [data, fmin, fmax, time, fs] = get_data(handles);
    time = time-1;
    if time(1)*fs+1 >= 1
        set(handles.time_shown_value, 'Data', time)
    else
        dt = time(2)-time(1);
        set(handles.time_shown_value, 'Data', [0 dt])
    end
    start_show_ClickedCallback(1, 1, handles);
    

%% big_right_Callback
% This function allows to show the time-frequency analysis related to the
% following time window.
function big_right_Callback(~, ~, handles)
    [data, fmin, fmax, time, fs] = get_data(handles);
    dt = time(2)-time(1);
    time = time+dt;
    Limit = max(size(data));
    if time(2)*fs <= Limit
        set(handles.time_shown_value, 'Data', time)
    else
        set(handles.time_shown_value, 'Data', [Limit/fs-dt, Limit/fs])
    end
    start_show_ClickedCallback(1, 1, handles);
    

%% big_left_Callback
% This function allows to show the time-frequency analysis related to the previous
% previous time window.
function big_left_Callback(~, ~, handles)
    [data, fmin, fmax, time, fs] = get_data(handles);
    dt = time(2)-time(1);
    time = time-dt;
    if time(1)*fs+1 >= 1
        set(handles.time_shown_value, 'Data', time)
    else
        set(handles.time_shown_value, 'Data', [0 dt])
    end
    start_show_ClickedCallback(1, 1, handles);


%% fs_ClickedCallback
% This function allows to set the sampling frequency, if its value is not
% already contained in the signal's file.
function fs_ClickedCallback(~, ~, handles)
    try
        fs_check = get(handles.fs_check, 'String');
        data = get(handles.signal_matrix, 'Data');
        locs = get(handles.locs_matrix, 'Data');
        fs = str2double(get(handles.fs_text, 'String'));
        if strcmp(fs, 'not detected') || isnan(fs)
            fs = 1;
        end
        if fs == 1
            sliding_check = 1;
        else 
            sliding_check = 0;
        end
        axis(handles.signal);
        if strcmp(fs_check, 'not detected')
            fs = value_asking(fs, 'Sampling frequency', ...
                    'Insert the sampling frequency of the signal');
            while fs <= 0
                fs = value_asking(fs, 'Sampling frequency', ...
                    'Insert the sampling frequency of the signal');
            end 
            set(handles.fs_text, 'String', string(fs));
            start_show_ClickedCallback(1, 1, handles);
        else
            problem('The sampling frequency is already setted in the file');
        end
    catch
    end


function amplitude_ClickedCallback(~, ~, ~)


%% time_window_ClickedCallback
% This function allows to set the length (in seconds) of the time window
% related to the shown time-frequency analysis.
function time_window_ClickedCallback(~, ~, handles)
    try
        [data, fmin, fmax, time, fs] = get_data(handles);
        Limit = max(size(data))/fs;
        initialValue = time(2)-time(1);
        tw = value_asking(initialValue, 'Time window', ...
            'Insert the wished time window', Limit-time(1));
        while tw <= 0
            tw = value_asking(initialValue, 'Time window', ...
                'Insert the wished time window', Limit-time(1));
        end
        if time(1)+tw <= Limit
            set(handles.time_shown_value, 'Data', [time(1), time(1)+tw])
            start_show_ClickedCallback(1, 1, handles);
        end
    catch
    end
    

%% Go_to_ClickedCallback
% This function allows to set the first time instant related to the time
% window of the shown time-frequency analysis.
function Go_to_ClickedCallback(~, ~, handles)
    try
        [data, fmin, fmax, time, fs] = get_data(handles);
        dt = time(2)-time(1);
        tmax = max(size(data))/fs;
        tmax = tmax-dt;
        tmin = value_asking(time(1), 'Go to...', ...
            'Insert the time you want to inspect', tmax);
        if tmin < 0
            problem('The time cannot be less than 0');
        else
            set(handles.time_shown_value, 'Data', [tmin tmin+dt])
            start_show_ClickedCallback(1, 1, handles);
        end
    catch
    end
    

%% Loc_ClickedCallback
% This function allows to set the locations list's file.
function Loc_ClickedCallback(~, ~, handles)
    try
        msg = 'Select the file which contains the locations of the signal';
        title = 'Locations file';
        definput = get(handles.aux_loc, 'String');
        if strcmp(definput, 'Static Text')
            definput = 'es. C:\User\Locationsfile.mat';
        end
        filename = file_asking(definput, title, msg);
        [data, ~, locs] = load_data(filename);
        if isempty(locs)
            locs = data;
        end
        locs(:, 2) = [];
        set(handles.locs_matrix, 'Data', locs);
        set(handles.aux_loc, 'String', filename);
        start_show_ClickedCallback(1, 1, handles);
    catch
    end
    

%% LocsToShow_ClickedCallback
% This function allows to select the location which has to be analyzed.
function LocsToShow_ClickedCallback(~, ~, handles)
    locs = get(handles.locs_matrix, 'Data');
    data = get_data(handles);
    fs = str2double(get(handles.fs_text, 'String'));
    current_ind = get(handles.locs_ind, 'Data');
    locs_ind = Athena_locsSelecting(locs, current_ind);
    waitfor(locs_ind);
    selectedLocs = evalin('base', 'Athena_locsSelecting');
    if isobject(selectedLocs)
        close(selectedLocs)
    end
    evalin( 'base', 'clear Athena_locsSelecting' )
    if length(selectedLocs) > 1
        problem("You can select only one location to show")
    elseif sum(selectedLocs ~= 0) && not(isobject(selectedLocs))
        locs_ind = zeros(length(locs), 1);
        locs_ind(selectedLocs) = 1;
        set(handles.locs_ind, 'Data', locs_ind);
        start_show_ClickedCallback(1, 1, handles);
    end


%% forward_show_ClickedCallback
% This function shows the time-frequency analysis, automatically going 
% forward in time, one second per interaction.
function forward_show_ClickedCallback(hObject, eventdata, handles)
     set_off(handles, 'forward')
     while 1
         if check_off(handles, 'forward')
             set(handles.stop_show, 'State', 'off')
             set(handles.forward_show, 'State', 'off')
             break
         end
         right_Callback(hObject, eventdata, handles)
         pause(1)
     end


%% backwards_show_ClickedCallback
% This function shows the time-frequency analysis, automatically going
% backward in time, one second per interaction.
function backwards_show_ClickedCallback(hObject, eventdata, handles)
     set_off(handles, 'backwards')
     while 1
         if check_off(handles, 'backwards')
             set(handles.stop_show, 'State', 'off')
             set(handles.back_show, 'State', 'off')
             break
         end
         left_Callback(hObject, eventdata, handles)
         pause(1)
     end
     
     
%% big_forward_show_ClickedCallback
% This function shows the time-frequency analysis, automatically going
% forward in time, one time window per interaction.     
function big_forward_show_ClickedCallback(hObject, eventdata, handles)
     set_off(handles, 'big_forward')
     while 1
         if check_off(handles, 'big_forward')
             set(handles.stop_show, 'State', 'off')
             set(handles.big_forward_show, 'State', 'off')
             break
         end
         big_right_Callback(hObject, eventdata, handles)
         pause(1)
     end
     
     
%% big_backwards_show_ClickedCallback
% This function shows the time-frequency analysis, automatically going
% backward in time, one time window per interaction.     
function big_backwards_show_ClickedCallback(hObject, eventdata, handles)
     set_off(handles, 'big_backwards')
     while 1
         if check_off(handles, 'big_backwards')
             set(handles.stop_show, 'State', 'off')
             set(handles.big_back_show, 'State', 'off')
             break
         end
         big_left_Callback(hObject, eventdata, handles)
         pause(1)
     end

     
%% set_off
% This function stops all the automatic time-frequency analysis time window
% switching.
function set_off(handles, hand_name_not)
     hands = {handles.back_show, handles.forward_show, ...
         handles.stop_show, handles.big_back_show, ...
         handles.big_forward_show};
     names = {'backwards', 'forward', 'stop', 'big_backwards', ...
         'big_forward'};
     searchname = cellfun(@(x)isequal(x, hand_name_not), names);
         [~, c] = find(searchname);
         values = {'off', 'off', 'off', 'off', 'off'};
         values{c} = 'on';
     for i = 1:length(values)
         set(hands{i}, 'State', values{i})
     end
     

%% check_off
% This function checks if some of the automatic time window switching
% options are running (it returns 1 if one of them is running, 0
% otherwise).
function check = check_off(handles, hand_name)
     check = 0;
     if strcmpi(get(handles.stop_show, 'State'), 'on')
         check = 1;
     else
         names = {'backwards', 'forward', 'big_backwards', 'big_forward'};
         hands = {handles.back_show, handles.forward_show, ...
             handles.big_back_show, handles.big_forward_show};
         searchname = cellfun(@(x)isequal(x, hand_name), names);
         [~, c] = find(searchname);
         values = {'on', 'on', 'on', 'on'};
         values{c} = 'off';
         for i = 1:length(values)
             if strcmpi(get(hands{i}, 'State'), values{i})
                 check = 1;
             end
         end
     end
         

%% end_show_ClickedCallback
% This function shows the time-frequency analysis related to the last
% available time window.
function end_show_ClickedCallback(~, ~, handles)
     axes(handles.signal);
     [data, ~, ~, time, fs] = get_data(handles);
     final = floor(length(data)/fs);
     dt = time(2)-time(1);
     set(handles.time_shown_value, 'Data', [final-dt final]);
     start_show_ClickedCallback(1, 1, handles);
     

%% restart_show_ClickedCallback
% This function shows the time-frequency analysis related to the first
% available time window.     
function restart_show_ClickedCallback(~, ~, handles)
     axes(handles.signal);
     [~, ~, ~, time, ~] = get_data(handles);
     dt = time(2)-time(1);
     set(handles.time_shown_value, 'Data', [0, dt]);
     start_show_ClickedCallback(1, 1, handles);
         

%% start_show_ClickedCallback
% This function shows the time-frequency analysis related to the first
% available time window.
function start_show_ClickedCallback(~, ~, handles)
     axes(handles.signal);
     [data, fmin, fmax, time, fs] = get_data(handles);
     locs_ind = get(handles.locs_ind, 'Data');
     locs = get(handles.locs_matrix, 'Data');
     axis(handles.signal);
     idx_chan = 1:length(locs);
     idx_chan(locs_ind == 0) = [];
     time_string = strcat(string(time(1)), " - ", ...
        string(time(2)), " s");
     try
         location_string = locs{locs_ind == 1};
     catch
         [~, location_string] = max(locs_ind);
             location_string = string(location_string);
     end
     set(handles.time_text, 'String', time_string)
     set(handles.loc_shown, 'String', location_string)
     [tf, times, frequencies, f_ticks, t_ticks, n_steps] = ...
         time_frequency_analysis(data, fs, idx_chan, fmin, fmax, ...
         time(1), time(2), 40, 3, 10, 'linear', 0);
     axes(handles.signal);
     axis(handles.signal);
     contourf(times, frequencies, tf, n_steps, 'linecolor', 'none');
     yticks(f_ticks);
     if time(1) == 0
         xticks([t_ticks t_ticks(end)+1]);
     else
        xticks(t_ticks);
     end
     xticklabels(string(linspace(time(1), time(2), length(t_ticks))))
     

%% stop_show_ClickedCallback
% This function stops all the automatic time window switching modalities.
function stop_show_ClickedCallback(~, ~, handles)
     set(handles.big_forward_show, 'State', 'off')
     set(handles.big_back_show, 'State', 'off')
     set(handles.forward_show, 'State', 'off')
     set(handles.back_show, 'State', 'off')
   

%% location_index
% This function return the index related to the selected location.
function locs_ind = location_index(locs, data)
     locs_ind = ones(length(locs), 1);
     if isempty(locs_ind)
         locs_ind = ones(min(size(data)), 1);
     end


%% get_data
% This function returns the current signal and the related parameters.   
function [data, fmin, fmax, time, fs] = get_data(handles)
    data = get(handles.signal_matrix, 'Data');
    fmin = str2double(get(handles.fmin, 'String'));
    fmax = str2double(get(handles.fmax, 'String'));
    time = get(handles.time_shown_value, 'Data');
    fs = str2double(get(handles.fs_text, 'String'));


%% fmin_Callback
% This function is used when the lower cut frequency is changed, in order
% to execute some controls on the value and to show the time-frequency
% analysis.
function fmin_Callback(hObject, eventdata, handles)
        frequencies = get(handles.freq_matrix, 'Data');
    try
        [~, fmin, fmax] = get_data(handles);
        if fmin >= fmax
            problem(strcat("The minimum frequency cannot be higher ", ...
                "than or equal to the maximum frequency"))
        elseif fmin < 0
            problem('The minimum frequency cannot be less than zero')
        elseif fmin > str2double(get(handles.fs_text, 'String'))/2
            problem(strcat("The minimum frequency cannot be higher ", ...
                "than the Nyquist frequency (", ...
                string(str2double(get(handles.fs_text, 'String'))/2), ")"))
        else
            start_show_ClickedCallback(1, 1, handles);
            frequencies{1} = fmin;
            set(handles.freq_matrix, 'Data', frequencies)
        end
    catch
        problem("Invalid minimum frequency value")
    end
    set(handles.fmin, 'String', string(frequencies{1}));

    
function fmin_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


%% fmax_Callback
% This function is used when the higher cut frequency is changed, in order
% to execute some controls on the value and to show the time-frequency
% analysis.
function fmax_Callback(hObject, eventdata, handles)
    frequencies = get(handles.freq_matrix, 'Data');
    try
        [~, fmin, fmax] = get_data(handles);
        if fmin >= fmax
            problem(strcat("The maximum frequency cannot be lower ", ...
                "than or equal to the minimum frequency"))
        elseif fmax < 0
            problem('The maximum frequency cannot be less than zero')
        elseif fmax > str2double(get(handles.fs_text, 'String'))/2
            problem(strcat("The maximum frequency cannot be higher ", ...
                "than the Nyquist frequency (", ...
                string(str2double(get(handles.fs_text, 'String'))/2), ")"))
        else
            start_show_ClickedCallback(1, 1, handles);
            frequencies{2} = fmax;
            set(handles.freq_matrix, 'Data', frequencies)
        end
    catch
        problem("Invalid maximum frequency value")
    end
    set(handles.fmax, 'String', string(frequencies{2}));
   
    
function fmax_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
%% find_fs
% This function assigns a value to the fs variable.
function fs = find_fs(fs, handles)
    if isempty(fs)
        fs = str2double(get(handles.fs_text, 'String'));
        set(handles.fs_check, 'String', 'not detected');
    else
        set(handles.fs_text, 'String', string(fs))
        set(handles.fs_check, 'String', 'detected');
    end


%% screen_ClickedCallback
% This function is used to save a screenshot of the shown time-frequency 
% analysis, inside a subdirectory of the current directory.
function screen_ClickedCallback(hObject, eventdata, handles)
    dataPath = path_check(get(handles.aux_dataPath, 'String'));
    outDir = create_directory(dataPath, 'Images');
    location = get(handles.loc_shown, 'String');
    time = split(get(handles.time_text, 'String'));
    time = strcat(time{1}, time{2}, time{3});
    freq = strcat(get(handles.fmin, 'String'), '-', get(handles.fmax, ...
        'String'));
    subject = split(get(handles.Title, 'String'), 'subject: ');
    subject = subject{2};
    axes(handles.signal)
    Image = getframe(handles.signal);
    for i = 1:6
        aux = 0.15*i*ones(1, 3);
        handles.signal.XColor = aux;
        handles.signal.YColor = aux;
        pause(0.03)
    end
    for i = 1:6
        aux = 0.15*(7-i)*ones(1, 3);
        handles.signal.XColor = aux;
        handles.signal.YColor = aux;
        pause(0.03)
    end
    imwrite(Image.cdata, char_check(strcat(path_check(outDir), 'TF_', ...
        subject, '_', location, '_', time, '_', freq, 'Hz.jpg')));
   
    
%% subject_selection_ClickedCallback
% This function allows to select the subject which has to be shown.
function subject_selection_ClickedCallback(hObject, eventdata, handles)
    dataPath = get(handles.aux_dataPath, 'String');
    dataPath = path_check(dataPath);
    cases = define_cases(dataPath);
    case_number = str2double(get(handles.case_number, 'String'));
    n = Athena_locsSelecting({cases.name}, case_number, 1);
    waitfor(n);
    case_n = evalin('base', 'Athena_locsSelecting');
    if isobject(case_n)
        close(case_n)
    end
    evalin( 'base', 'clear Athena_locsSelecting' )
    if length(case_n) > 1
        problem('You can select only a subject')
        return
    end
    if not(isobject(case_n)) && case_number ~= case_n
        set(handles.case_number, 'String', string(case_n+1))
        Previous_Callback(hObject, eventdata, handles)
    end

    
    
%% Home_WindowKeyPressFcn
% This function is used to use a speech command when 0 key is pressed.
function Home_WindowKeyPressFcn(hObject, eventdata, handles)
    if contains('0123456789', eventdata.Key) || strcmpi(eventdata.Key, ...
            'backspace') || strcmpi(eventdata.Key, 'delete')
        if not(strcmpi(get(handles.tStart_text, 'String'), '0'))
            tStart_text_Callback(hObject, eventdata, handles)
        end
        return;
    end
    if not(strcmpi(eventdata.Key, 'space'))
        return;
    end
    try
        set(handles.recording_button, 'Visible', 'on');
        set(handles.recording_text, 'Visible', 'on');
        pause(0.001)
        record = audio_recording();
        set(handles.recording_button, 'Visible', 'off');
        set(handles.recording_text, 'Visible', 'off');
        recorded_command = classify_command(record, handles.net);  
        if strcmpi(recorded_command, 'left')
            left_Callback(hObject, eventdata, handles)
        elseif strcmpi(recorded_command, 'right')
            right_Callback(hObject, eventdata, handles)
        elseif strcmpi(recorded_command, 'zero')
            Go_to_ClickedCallback(hObject, eventdata, handles, 0)
        elseif strcmpi(recorded_command, 'stop')
            set(handles.big_forward_show, 'State', 'off')
            set(handles.big_back_show, 'State', 'off')
            set(handles.forward_show, 'State', 'off')
            set(handles.back_show, 'State', 'off')
        elseif strcmpi(recorded_command, 'go')
            big_forward_show_ClickedCallback(hObject, eventdata, handles)
        elseif strcmpi(recorded_command, 'backward')
            big_left_Callback(hObject, eventdata, handles)
        elseif strcmpi(recorder_command, 'forward')
            big_right_Callback(hObject, eventdata, handles)
        elseif strcmpi(recorded_command, 'yes')
        elseif strcmpi(recorded_command, 'no')
        elseif strcmpi(recorded_command, 'unknown') || ...
                strcmpi(recorded_command, 'background')
        end
    catch
    end

    
%% Home_KeyPressFcn
% This function is used to use a keyboard command.
function Home_KeyPressFcn(hObject, eventdata, handles)
    if strcmpi(eventdata.Key, 'leftarrow')
        left_Callback(hObject, eventdata, handles)
    elseif strcmpi(eventdata.Key, 'rightarrow')
        right_Callback(hObject, eventdata, handles)
    end
    
    
    
%% fmin_KeyPressFcn
% This function is used to use a keyboard command on the fmin edit text.
function fmin_KeyPressFcn(hObject, eventdata, handles)
    if strcmpi(eventdata.Key, 'downarrow') || strcmpi(eventdata.Key, ...
        'uparrow')
        uicontrol(handles.fmax);
    end

    
%% fmax_KeyPressFcn
% This function is used to use a keyboard command on the fmax edit text.
function fmax_KeyPressFcn(hObject, eventdata, handles)
    if strcmpi(eventdata.Key, 'downarrow') || strcmpi(eventdata.Key, ...
        'uparrow')
        uicontrol(handles.fmin);
    end
