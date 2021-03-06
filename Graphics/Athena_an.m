%% Athena_an
% This interface allows to select the analysis to perform, or to return
% back to the previous interface.

function varargout = Athena_an(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Athena_an_OpeningFcn, ...
                   'gui_OutputFcn',  @Athena_an_OutputFcn, ...
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

%% Athena_an_OpeningFcn
% This function is called during the interface opening, and it sets all the
% initial parameters with respect to the arguments passed when it is
% called.
function Athena_an_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    guidata(hObject, handles);
    [x, ~] = imread('logo.png');
    Im = imresize(x, [250 250]);
    set(handles.help_button, 'CData', Im)
    if nargin >= 4 && not(islogical(varargin{1}))

        set(handles.aux_dataPath, 'String', varargin{1})
    end
    if nargin >= 5 && not(islogical(varargin{2}))
        set(handles.aux_measure, 'String', varargin{2})
    end
    if nargin >= 6 && not(islogical(varargin{3}))
        set(handles.aux_sub, 'String', varargin{3})
    end
    if nargin >= 7 && not(islogical(varargin{4}))
        set(handles.aux_loc, 'String', varargin{4})
    end
    if nargin >= 8 && not(islogical(varargin{5}))
        set(handles.sub_types, 'Data', varargin{5})
    end
    auxPath = pwd;
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    cd(auxPath)
    

function varargout = Athena_an_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


function back_Callback(hObject, eventdata, handles)
    tempav_Callback(hObject, eventdata, handles)
    
    
function axes3_CreateFcn(hObject, eventdata, handles)

%% StatAn_Callback
% This function switches to the Statistical Analysis interface.
function StatAn_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    close(Athena_an)
    Athena_statistics(dataPath, measure, sub, loc, sub_types)


%% clasData_Callback
% This function switches to the Classification Dataset Creation interface.
function clasData_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    close(Athena_an)
    Athena_mergsig2(dataPath, measure, sub, loc, sub_types)


%% EpAn_Callback
% This function switches to the Epoch Analysis interface.
function EpAn_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    close(Athena_an)
    Athena_epan(dataPath, measure, sub, loc, sub_types)


%% meaext_Callback
% This function switches to the Measure Selection interface.
function meaext_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    close(Athena_an)
    Athena_guided(dataPath, measure, sub, loc, sub_types)


%% tempav_Callback
% This function switches to the Temporal Average, Spatial Management and
% Subjects Grouping interface.
function tempav_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    close(Athena_an)
    Athena_epmean(dataPath, measure, sub, loc, sub_types)


%% scatterAn_Callback
% This function switches to the Scatter Analysis interface.
function scatterAn_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    close(Athena_an)
    Athena_scatter(dataPath, measure, sub, loc, sub_types)


%% netmeas_Callback
% This function switches to the Network Metrics Estimation interface.
function netmeas_Callback(hObject, eventdata, handles)
    funDir = mfilename('fullpath');
    funDir = split(funDir, 'Graphics');
    cd(char(funDir{1}));
    addpath 'Auxiliary'
    addpath 'Graphics'
    [dataPath, measure, sub, loc, sub_types] = GUI_transition(handles);
    close(Athena_an)
    Athena_netmeas(dataPath, measure, sub, loc, sub_types)