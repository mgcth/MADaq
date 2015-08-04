function viblab_report(varargin)
%VIBLAB_REPORT.

%Written: 2015-03-08, Thomas Abrahamsson, Chalmers University of Technology

RPT=viblab_report_code(varargin{1},varargin{2});
report(RPT);



function RPT=viblab_report_code(Data,handles)

%Copy the stylesheet
copyfile([handles.homePath '\functions\report\madaq.css'],pwd)

%%                                                              Unpack data
assignin('base','RPTdta',Data);% Data need to be put in Workspace (as
%                                  RPTdta) so that plots can be generated
try, UD=Data.UserData; catch, UD=[];end
try, Sensor=UD.Sensor; catch, Sensor=[];end
try, Author=UD.Tester;catch, Author='Anonymous';end
try, Folder=UD.Folder;catch, Folder=pwd;end
try, Title=UD.TestTitles{1};catch, Title='Vibration Test Report';end
try, Subtitle=UD.TestTitles{2};catch, Subtitle='A test made in Vibrations and Smart Structures Lab';end
try, Affiliation=UD.Affiliation;catch, Affiliation='Some organisation';end

SensorFields=fieldnames(Sensor);Nsf=length(SensorFields);
PhotoFolder=[Folder filesep 'Photos' filesep];
try, Photos=ls([PhotoFolder '*.jpg']);catch, Photos=[];end

%%                                                            Create report
%RPT = RptgenML.CReport('Description','A vibration test report',...
%    'Format','doc-rtf','Stylesheet','!print-NoOptions','DirectoryType','pwd');
RPT = RptgenML.CReport('Description','A vibration test report','DirectoryType','pwd','Stylesheet',...
'madaq','isIncrementFilename',true,...
'FilenameName',Title,...
'FilenameType','other');
%RPT = RptgenML.CReport('isIncrementFilename',true);
% RPT = RptgenML.CReport('Description','A vibration test report',...
% 'Format','dom-docx','Stylesheet','default-rg-docx','DirectoryType','pwd');

%%                                                               Title page
tmpClock=clock; % Get the time (year) of test and report making
Titlepage = rptgen.cfr_titlepage('Copyright_Date','2015',...
    'Author',Author,...
    'Title',Title,...
    'Subtitle',Subtitle,...
    'Copyright_Holder',Affiliation,...
    'Include_Copyright',true);

% Make this more general later...
[~,Day]=weekday(date,'long');LF=char(10);
Text=sprintf(['This report describes the test conducted in the '...
    'Vibrations and Smart Structures Lab on ' Day ', ' date ...
    '. The Smart Structures and Vibrations Lab is at the Department of Applied Machanics, ' ...
    'Chalmers University of Technology, Gothenburg, Sweden.' LF]);
Abstract = rptgen.cfr_text('isLiteral',true,'isBold',false,'Content',Text);
set(Titlepage,'AbstractComp',Abstract);

Picture=[];
for I=1:size(Photos,1)
    if strcmpi(deblank(Photos(I,:)),'TestPiece.jpg')
        Picture=[Folder '\Photos\' deblank(Photos(I,:))];
    end
end
if ~isempty(Picture)
    Image = rptgen.cfr_image('MaxViewportSize',[7 9],'FileName',Picture,...
        'Caption','Test Setup');
%     Image = rptgen.cfr_image('MaxViewportSize',[7 9],'FileName',Picture,...
%         'Caption','Test Setup');
    set(Titlepage,'ImageComp',Image);
end
setParent(Titlepage,RPT);

%%                                                         Section 1: Plots
Section = rptgen.cfr_section('StyleName','rgChapterTitle',...
    'SectionTitle','Sensor Output');
setParent(Section,RPT);
Paragraph = rptgen.cfr_paragraph('ParaTitle','4.2');
Text = rptgen.cfr_text;
set(Paragraph,'ParaTextComp',Text);
setParent(Paragraph,Section);
switch class(Data)
    case 'timeseries'
        Nch=size(Data.Data,2);
        Text = rptgen.cfr_text('isLiteral',true,'isBold',false,...
            'Content',['The following ' int2str(Nch) ' plots show data of a Time Series data object from the test.' char(13) char(13)]);
        setParent(Text,Paragraph);
        for I=1:Nch
            Eval = rptgen.cml_eval('isInsertString',false,'isDiary',false,...
                'EvalString',...
                ['figure;plot(RPTdta.Time,RPTdta.Data(:,' int2str(I) '));' ...
                'ylabel(''Sensor Data'');title(''Time Series Data'');'], ...
                'CatchString','disp(''Could not do it'')');
            setParent(Eval,Paragraph);
            Snap = rptgen_hg.chg_fig_snap('isCapture',true,...
                'MaxViewportSize',[7 9],'DocHorizAlign','left',...
                'Caption',['Figure 1.' int2str(I) ' Data from channel #' int2str(I) char(13)]);
            setParent(Snap,Paragraph);
            %       Text = rptgen.cfr_text('isLiteral',true,'isBold',true,...
            %          'Content',['Figure 1.' int2str(I) ' Data from channel #' int2str(I) char(13)]);
            %       setParent(Text,Paragraph);
        end
    case 'iddata'
        Domain=get(Data,'Domain');
        switch Domain
            case 'Time'
                nu=length(get(Data,'Inputname'));
                ny=length(get(Data,'Outputname'));
                nt=size(get(Data,'y'),1);
                Ts=get(Data,'Ts');Times=[0:nt-1]*Ts;tUnit=get(Data,'TimeUnit');
                uData=get(Data,'u');yData=get(Data,'y');
                Text = rptgen.cfr_text('isLiteral',true,'isBold',false,...
                    'Content',['The following shows temporal input data of test.' char(13)]);
                setParent(Text,Paragraph);
                FigNo=0;
                for I=1:nu
                    RPTs.t=Times;
                    RPTs.data=uData(:,I);
                    uName=get(Data,'Inputname');uName=uName{I};
                    uUnit=get(Data,'InputUnit');uUnit=uUnit{I};
                    RPTs.xlabel=['t [' tUnit ']'];
                    RPTs.ylabel=[uName ' [' uUnit ']'];
                    assignin('base','RPTs',RPTs)
                    Eval = rptgen.cml_eval('isInsertString',false,'isDiary',false,...
                        'EvalString',...
                        ['figure;plot(RPTs.t,RPTs.data);xlabel(RPTs.xlabel);ylabel(RPTs.ylabel);'], ...
                        'CatchString','disp(''Could not do it'')');
                    setParent(Eval,Paragraph);
                    FigNo=FigNo+1;
                    Snap = rptgen_hg.chg_fig_snap('isCapture',true,...
                        'MaxViewportSize',[7 9],'DocHorizAlign','left',...
                        'Caption',['Figure 1.' int2str(FigNo) ' Input u' int2str(I) char(13)]);
                    setParent(Snap,Paragraph);
                end
                for I=1:ny
                    RPTs.t=Times;
                    RPTs.data=yData(:,I);
                    yName=get(Data,'Outputname');yName=yName{I};
                    yUnit=get(Data,'OutputUnit');yUnit=yUnit{I};
                    RPTs.xlabel=['t [' tUnit ']'];
                    RPTs.ylabel=[yName ' [' yUnit ']'];
                    assignin('base','RPTs',RPTs)
                    Eval = rptgen.cml_eval('isInsertString',false,'isDiary',false,...
                        'EvalString',...
                        ['figure;plot(RPTs.t,RPTs.data);xlabel(RPTs.xlabel);ylabel(RPTs.ylabel);'], ...
                        'CatchString','disp(''Could not do it'')');
                    setParent(Eval,Paragraph);
                    FigNo=FigNo+1;
                    Snap = rptgen_hg.chg_fig_snap('isCapture',true,...
                        'MaxViewportSize',[7 9],'DocHorizAlign','left',...
                        'Caption',['Figure 1.' int2str(FigNo) ' Output y' int2str(I) char(13)]);
                    setParent(Snap,Paragraph);
                end
            otherwise
        end
    case {'frd' 'idfrd'}
        [ny,nu,nf]=size(get(Data,'ResponseData'));
        Text = rptgen.cfr_text('isLiteral',true,'isBold',false,...
            'Content',['The following shows a Bode Plot of the FRD object from the test.' char(13) char(13)]);
        setParent(Text,Paragraph);
        for I=1:nu
            for J=1:ny
                Eval = rptgen.cml_eval('isInsertString',false,'isDiary',false,...
                    'EvalString',['fh=figure;figure(fh);magphase([' int2str(I) ' ' int2str(J) '],RPTdta);'], ...
                    'CatchString','disp(''Could not do it'')');
                setParent(Eval,Paragraph);
                Snap = rptgen_hg.chg_fig_snap('isCapture',true,...
                    'MaxViewportSize',[7 9],'DocHorizAlign','left',...
                    'Caption',['Figure 1.' int2str((I-1)*ny+J) ' Transfer function u' int2str(I) ' to y' int2str(J) char(13)]);
                setParent(Snap,Paragraph);
                %         Text = rptgen.cfr_text('isLiteral',true,'isBold',true,...
                %          'Content',['Figure 1.' int2str((I-1)*ny+J) ' Transfer function u' int2str(I) ' to y' int2str(J) char(13)]);
                %         setParent(Text,Paragraph);
            end
        end
    otherwise
end

%%                                                 Section 2: Sensor layout
Section = rptgen.cfr_section('StyleName','rgChapterTitle',...
    'SectionTitle','Sensor Layout');
setParent(Section,RPT);
U=1;Y=1;
for I=1:size(Photos,1)
    if strcmpi(deblank(Photos(I,:)),['Sensor' int2str(U) '.jpg'])
        Paragraph = rptgen.cfr_paragraph('ParaTitle','4.1');
        Text = rptgen.cfr_text;
        set(Paragraph,'ParaTextComp',Text);
        Picture=[PhotoFolder deblank(Photos(I,:))];
        [~,pictname,~]=fileparts(Picture);
        try
            Evalc=['type('''  Folder filesep 'Photos' filesep pictname '.txt'')'];
            Caption=['Figure 2.' int2str(U+Y-1) evalc(Evalc)];
        catch
            Caption=['Figure 2.' int2str(U+Y-1) '. Sensor u' int2str(U)];
        end
        %Image = rptgen.cfr_image('FileName',Picture,...
        %'DocHorizAlign','center','MaxViewportSize',[7 9],'Caption',Caption);
        Image = rptgen.cfr_image('FileName',Picture,...
        'DocHorizAlign','center','MaxViewportSize',[7 9],'Caption',Caption);
        setParent(Image,Section);
        U=U+1;
    end
%       if strcmpi(deblank(Photos(I,:)),['Sensor' int2str(Y) '.jpg'])
%         Paragraph = rptgen.cfr_paragraph('ParaTitle','4.1');
%         Text = rptgen.cfr_text;
%         set(Paragraph,'ParaTextComp',Text);
%         Picture=[Folder '\Photos\' deblank(Photos(I,:))];
%         [~,pictname,~]=fileparts(Picture);
%         try
%           Evalc=['type('''  Folder filesep 'Photos' filesep pictname '.txt'')'];
%           Caption=['Figure 2.' int2str(U+Y-1) evalc(Evalc)];
%         catch
%           Caption=['Figure 2.' int2str(U+Y-1) '. Sensor y' int2str(U)];
%         end
%         Image = rptgen.cfr_image('FileName',Picture,...
%         'DocHorizAlign','center','MaxViewportSize',[7 9],'Caption',Caption);
%         setParent(Image,Section);
%         Y=Y+1;
%       end
end

%%                                            Section 3: Measurement system
Section = rptgen.cfr_section('StyleName','rgChapterTitle',...
    'SectionTitle','Measurement System Data');
setParent(Section,RPT);
Paragraph = rptgen.cfr_paragraph('ParaTitle','4.2');
Text = rptgen.cfr_text;
set(Paragraph,'ParaTextComp',Text);
setParent(Paragraph,Section);

Nrow=length(Sensor.Manufacturer);Ncol=Nsf+1;
Table = rptgen.cfr_ext_table('NumCols',int2str(Ncol),...
    'TableTitle','Sensor Data');
setParent(Table,Paragraph);
Tablehead = rptgen.cfr_ext_table_head;
setParent(Tablehead,Table);
TableRow = rptgen.cfr_ext_table_row;
setParent(TableRow,Tablehead);
for I=1:Ncol
    TableEntry = rptgen.cfr_ext_table_entry;
    setParent(TableEntry,TableRow);
    Paragraph = rptgen.cfr_paragraph;
    if I==1
        Text = rptgen.cfr_text('Content','Channel #');
    else
        Text = rptgen.cfr_text('Content',SensorFields{I-1});
    end
    set(Paragraph,'ParaTextComp',Text);
    setParent(Paragraph,TableEntry);
end
TableBody = rptgen.cfr_ext_table_body;
setParent(TableBody,Table);
for I=1:Nrow
    TableRow = rptgen.cfr_ext_table_row;
    setParent(TableRow,TableBody);
    for J=1:Ncol
        TableEntry = rptgen.cfr_ext_table_entry;
        setParent(TableEntry,TableRow);
        Paragraph = rptgen.cfr_paragraph;
        if J==1
            Text = rptgen.cfr_text('Content',int2str(I));
        else
            CellTxt=eval(['Sensor.' SensorFields{J-1} '{' int2str(I) '};']);
            if isnumeric(CellTxt),CellTxt=num2str(CellTxt);end
            Text = rptgen.cfr_text('Content',CellTxt);
        end
        set(Paragraph,'ParaTextComp',Text);
        setParent(Paragraph,TableEntry);
    end
end

%%                                                     Section 4: Test team
Section = rptgen.cfr_section('StyleName','rgChapterTitle',...
    'SectionTitle','Test Team');
setParent(Section,RPT);
Picture=[];
for I=1:size(Photos,1)
    if strcmpi(deblank(Photos(I,:)),'TestTeam.jpg')
        Picture=[Folder '\Photos\TestTeam.jpg'];
        PictCap=[Folder '\Photos\TestTeam.txt'];
    end
end
if ~isempty(Picture)
    ParaTxt='Greetings from the Test Team!';
    Text = rptgen.cfr_text('isLiteral',true,'Content',ParaTxt);
    set(Paragraph,'ParaTextComp',Text);
    setParent(Paragraph,Section);
    Image = rptgen.cfr_image('FileName',Picture,...
        'DocHorizAlign','center','MaxViewportSize',[7 9]);
    setParent(Image,Section);
    Paragraph = rptgen.cfr_paragraph('ParaTitle','4.1');
    try
        Evalc=['type(''' PictCap ''')'];
        Caption=['Figure 4.1' evalc(Evalc)];
    catch
        Caption='Figure 4.1 The Test Team';
    end
    Text = rptgen.cfr_text('isLiteral',true,'isBold',true,'Content',Caption);
    set(Paragraph,'ParaTextComp',Text);
    setParent(Paragraph,Section);
end

Eval=rptgen.cml_eval('isInsertString',false,'EvalString','clear RPTdta');
setParent(Eval,Paragraph);

