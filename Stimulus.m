function varargout = Stimulus(varargin)
% STIMULUS MATLAB code for Stimulus.fig
%      STIMULUS, by itself, creates a new STIMULUS or raises the existing
%      singleton*.
%
%      H = STIMULUS returns the handle to a new STIMULUS or the handle to
%      the existing singleton*.
%
%      STIMULUS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STIMULUS.M with the given input arguments.
%
%      STIMULUS('Property','Value',...) creates a new STIMULUS or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Stimulus_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Stimulus_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Stimulus

% Last Modified by GUIDE v2.5 16-Sep-2017 16:21:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Stimulus_OpeningFcn, ...
                   'gui_OutputFcn',  @Stimulus_OutputFcn, ...
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
% End initialization code - DO NOT EDIT

% --- Executes on button press in Sinusoidal.
function Sinusoidal_Callback(hObject, eventdata, handles)
% hObject    handle to Sinusoidal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% handles.Sinusoidal.UserData = true;
% handles.Periodic.UserData = false;
% guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function Frequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Frequency_Callback(hObject, eventdata, handles)
% hObject    handle to Frequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Frequency as text
%        str2double(get(hObject,'String')) returns contents of Frequency as a double
Frequency = str2double(get(hObject, 'String'));
if isnan(Frequency)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
% Save the new Frequency value
handles.Frequency.Value = Frequency;
guidata(hObject,handles)

% % --- Executes during object creation, after setting all properties.
% function PeriodicFcnRadio_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to Periodic (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: popupmenu controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end

% --- Executes on button press in Periodic.
function Periodic_Callback(hObject, eventdata, handles)
% hObject    handle to Periodic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Periodic
% handles.Sinusoidal.UserData = false;
% handles.Periodic.UserData = true;
% guidata(hObject,handles)

function PeriodicFcn_Callback(hObject, eventdata, handles)
% hObject    handle to PeriodicFcn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PeriodicFcn as text
%        str2double(get(hObject,'String')) returns contents of PeriodicFcn as a double
try
  t=[0 1];
  eval([hObject.String ';']);
  hObject.String=hObject.String;
catch
  try
    t=[0 1];
    feval(hObject.String,t);
    hObject.String=[hObject.String '(t)'];
  catch
    hObject.String='Matlab fcn in here';
  end
end  

% --- Executes during object creation, after setting all properties.
function PeriodicFcn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PeriodicFcn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function PeriodT_Callback(hObject, eventdata, handles)
% hObject    handle to PeriodT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PeriodT = str2double(get(hObject, 'String'));
if isnan(PeriodT)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
% Save the new Frequency value
handles.PeriodT.Value = PeriodT;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function PeriodT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PeriodT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Activate.
function Activate_Callback(hObject, eventdata, handles)
% hObject    handle to Activate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Activate.UserData = true;
guidata(hObject,handles)

% --- Executes just before Stimulus is made visible.
function Stimulus_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Stimulus (see VARARGIN)

% Choose default command line output for Stimulus
handles.output = hObject;
handles.Activate.UserData = false;
% Update handles structure
guidata(hObject, handles);
initialize_gui(hObject, handles, false);

% UIWAIT makes Stimulus wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)
% If the metricdata field is present and the reset flag is false, it means
% we are we are just re-initializing a GUI by calling it from the cmd line
% while it is up. So, bail out as we dont want to reset the data.
if isfield(handles, 'metricdata') && ~isreset
    return;
end
% Update handles structure
guidata(handles.figure1, handles);

% --- Outputs from this function are returned to the command line.
function varargout = Stimulus_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
