%   Clear
% close all;
% clear;
% clear mex;
% clc;

% Acknowledgement
% The development of this software was funded by the INTERREG 4 A program
% in Southern Denmark – Schleswig-K.E.R.N, Germany with funding from the 
% European Fund for Regional Development.
%
% Author:     Kent Stark Olsen <kent.stark.olsen@gmail.com>
% Created:    02-05-2013
% Revision:   24-02-2015 1.3 minor bug changes


%   Setup environment
homePath = fileparts(mfilename('fullpath'));

addpath(genpath(homePath));

% fprintf(' Environmental paths settings changed ...\n\n');
% fprintf(' Opening GUI ...\n\n');

%scanForHardware();
main();

% Mladen test