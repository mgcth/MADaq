function varargout = abraSCOPEgui(varargin)
% abraSCOPEgui MATLAB code for abraSCOPEgui.fig
%      abraSCOPEgui, by itself, creates a new abraSCOPEgui or raises the existing
%      singleton*.
%
%      H = abraSCOPEgui returns the handle to a new abraSCOPEgui or the handle to
%      the existing singleton*.
%
%      abraSCOPEgui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in abraSCOPEgui.M with the given input arguments.
%
%      abraSCOPEgui('Property','Value',...) creates a new abraSCOPEgui or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before abraSCOPE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to abraSCOPE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help abraSCOPEgui

% Last Modified by GUIDE v2.5 22-Aug-2017 16:10:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @abraSCOPEgui_OpeningFcn, ...
                   'gui_OutputFcn',  @abraSCOPEgui_OutputFcn, ...
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

% --- Executes just before abraSCOPEgui is made visible.
function abraSCOPEgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to abraSCOPE (see VARARGIN)

global abraScope

% Choose default command line output for abraSCOPE
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
initialize_gui(hObject, handles, false);


%% Some initial settings
abraScope.Type='time'; 
abraScope.Action='live';
abraScope.fps=10;
abraScope.Quit=false;
abraScope.YScale=1;
abraScope.FT='DC';
abraScope.LogData=false;
abraScope.AutoScale=false;

%% Figure data
bgc=[0 .2 0];

%% Identify control window and set it up
GH=groot;
for I=1:length(GH.Children)
  if strcmpi(GH.Children(I).Name,'abrascope control')
    FH=GH.Children(I);
  end
end  
FH.Resize='off';
abraScope.FH=FH;

%% Make time, Lissajous and Poincare plot windows
fht=figure; 
bgc=[0 .2 0]; fht.Color=bgc;
fht.NumberTitle='off'; fht.MenuBar='none'; fht.Name='abraSCOPE time';
fht.Visible='off';
fhl=figure; fhl.Color=bgc;
fhl.NumberTitle='off'; fhl.MenuBar='none'; fhl.Name='abraSCOPE Lissajous';
fhl.Visible='off';
fhp=figure; fhp.Color=bgc;
fhp.NumberTitle='off'; fhp.MenuBar='none'; fhp.Name='abraSCOPE Poincaré';
fhp.Visible='off';
abraScope.fht=fht; abraScope.fhl=fhl; abraScope.fhp=fhp;



%% Initiate signal strength graphics
for I=1:length(FH.Children)
  if strcmpi(FH.Children(I).Tag,'intensity'), IFH=FH.Children(I); end
end
IH=IFH.Children(2);% Axes
IRB=IFH.Children(1);% Refresh button
IRB.UserData=false;

x=[0 1 1 0]'; y=[0 0 1 1]'; X=[]; Y=[];
for J=0:9,for I=0:9, X=[X x+I]; Y=[Y y+9-J]; end, end  
X=0.1*X; Y=0.1*Y;
IM=fill(IH,X,Y,NaN*ones(1,100));

axis(IH,'equal'); axis(IH,'square'); IH.XLim=[0 1]; IH.YLim=[0 1]; 
IH.XTick=0:.1:1; IH.YTick=0:.1:1; IH.XGrid='on'; IH.YGrid='on';
IH.XTickLabel=''; 
IH.YTickLabel={'  ' '91-' '81-' '71-' '61-' '51-' '41-' '31-' '21-' '11-' ' 1-'};
abraScope.IRB=IRB;
abraScope.IM=IM;


% UIWAIT makes abraSCOPE wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = abraSCOPEgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)

% --- Executes on button press in scaleYup.
function scaleYup_Callback(hObject, eventdata, handles)
% hObject    handle to scaleYup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global abraScope
abraScope.YScale=2*abraScope.YScale;

% --- Executes on button press in scaleYdwn.
function scaleYdwn_Callback(hObject, eventdata, handles)
% hObject    handle to scaleYdwn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global abraScope
abraScope.YScale=abraScope.YScale/2;


% --- Executes on selection change in channel1select.
function channel1select_Callback(hObject, eventdata, handles)
% hObject    handle to channel1select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel1select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel1select
disp('');

% --- Executes during object creation, after setting all properties.
function channel1select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel1select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global abraScope
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
hObject.String={'Ch #1' 'Ch #2'};
abraScope.hCh1=hObject;



% --- Executes on selection change in channel2select.
function channel2select_Callback(hObject, eventdata, handles)
% hObject    handle to channel2select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel2select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel2select
disp('');


% --- Executes during object creation, after setting all properties.
function channel2select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel2select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global abraScope
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
hObject.String={'Ch #1' 'Ch #2'};
abraScope.hCh2=hObject;

% --- Executes on button press in Live!.
function LiveCB(hObject, eventdata, handles)
% hObject    handle to Live! (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global abraScope
abraScope.Action='live';

% --- Executes on button press in Freeze!.
function FreezeCB(hObject, eventdata, handles)
% hObject    handle to Freeze! (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global abraScope
abraScope.Action='freeze';

% --- Executes on button press in Pan!.
function PanCB(hObject, eventdata, handles)
% hObject    handle to Pan! (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global abraScope
abraScope.Action='pan';


% --- Executes on button press in Time.
function TimeCB(hObject, eventdata, handles)
% hObject    handle to Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global abraScope
abraScope.Type='time';
try
  abraScope.fht.Visible='on';
  abraScope.fhl.Visible='off';
  abraScope.fhp.Visible='off';
catch
end

% --- Executes on button press in Lissajous.
function LissajousCB(hObject, eventdata, handles)
% hObject    handle to Lissajous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global abraScope
abraScope.Type='lissajous';
try
  abraScope.fht.Visible='off';
  abraScope.fhl.Visible='on';
  abraScope.fhp.Visible='off';
catch
end

% --- Executes on button press in Poincare.
function PoincareCB(hObject, eventdata, handles)
% hObject    handle to Pan! (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global abraScope
abraScope.Type='poincare';
try
  abraScope.fht.Visible='off';
  abraScope.fhl.Visible='off';
  abraScope.fhp.Visible='on';
catch
end


% --- Executes on button press in logData.
function LogData_Callback(hObject, eventdata, handles)
% hObject    handle to logData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of logData
global abraScope
abraScope.LogData=true;

% --- Executes on button press in qui.
function qui_Callback(hObject, eventdata, handles)
% hObject    handle to qui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global abraScope
abraScope.Quit=true;


function FrameRate_Callback(hObject, eventdata, handles)
% hObject    handle to FrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameRate as text
%        str2double(get(hObject,'String')) returns contents of FrameRate as a double
global abraScope

fps=str2num(hObject.String);
if ~isempty(fps)
    fps=round(fps);
    if fps>50
      fps=50;
    elseif fps<1
      fps=1;
    end  
    abraScope.fps=fps;
    hObject.String=num2str(fps);
else
  hObject.String=num2str(abraScope.fps);
end


% --- Executes during object creation, after setting all properties.
function FrameRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Filter.
function Filter_Callback(hObject, eventdata, handles)
% hObject    handle to Filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Filter
global abraScope
abraScope.hFilter=hObject;
FT=get(hObject,'String');
switch FT
    case 'AC'
        abraScope.FT='DC';
        set(hObject,'String','DC')
    case 'DC'    
        abraScope.FT='AC';
        set(hObject,'String','AC')
end    

% --- Executes on button press in AutoScale.
function AutoScale_Callback(hObject, eventdata, handles)
% hObject    handle to AutoScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AutoScale
global abraScope
abraScope.AutoScale=true;

% AutoScale=get(hObject,'String');
% switch AutoScale
%   case 'Autoscale Y'
%     hObject.String='Normal';
%     abraScope.AutoScale=true;
%   case 'Normal'    
%     hObject.String='Autoscale Y';
% end    


% --- Executes on selection change in Tspan.
function Tspan_Callback(hObject, eventdata, handles)
% hObject    handle to Tspan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Tspan contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Tspan


% --- Executes during object creation, after setting all properties.
function Tspan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tspan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global abraScope
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
hObject.String={'1.0 s' '0.5 s' '100 ms' '50 ms' '10 ms' '5ms'};
abraScope.hTspan=hObject;


% --- Executes on button press in RefreshButton.
function RefreshButton_Callback(hObject, eventdata, handles)
% hObject    handle to RefreshButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hObject.UserData=true;
