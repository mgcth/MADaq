function abraDAQpath
pf=which('abraDAQ');
[p,f]=fileparts(pf);
addpath([p filesep 'functions']);
addpath([p filesep 'functions' filesep 'impact']);
addpath([p filesep 'functions' filesep 'multisine']);
addpath([p filesep 'functions' filesep 'oscilloscope']);
addpath([p filesep 'functions' filesep 'periodic']);
addpath([p filesep 'functions' filesep 'report']);
addpath([p filesep 'functions' filesep 'teds']);
