%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe 

% ***************************************************************
% This script produces the Figures published in 
% 
% Journal of Economic Structures (JECS)
% https://journalofeconomicstructures.springeropen.com/
% The Official Journal of the Pan-Pacific Association of 
% Input-Output Studies (PAPAIOS)
% Special Thematic Series on: 
% Method development in EEIOA – novel advances and best practices
% 
% Title: 
% Implementing exogenous scenarios in a global MRIO model for the 
% estimation of future environmental footprints
% 
% Kirsten Svenja Wiebe kirsten.s.wiebe@ntnu.no
% Eivind Lekve Bjelle eivind.bjelle@ntnu.no
% Johannes Többen johannes.tobben@ntnu.no
% Richard Wood richard.wood@ntnu.no
% 
% Industrial Ecology Programme, Department of Energy and Process 
% Engineering, Norwegian University of Science and Technology, 
% 7491 Trondheim, Norway.                    
% ***************************************************************

%% Part 3 Simple Analysis
clear
%% Initializations
run('EXIOfutures_init.m');
addpath('SimpleAnalysis\');
EXIOfuturepath = 'futures\';
load([EXIOfuturepath,'EXIOhist\','meta.mat']);
regioncodes=meta.countries;

%% Stressor selection
run('StressorSelection.m');

%% Load aggregation matrices
run('LoadAggregationMatrices.m');

%% Path to data for analysis
% needed in A1_ and A2_
TRADEresultspath = 'SimpleAnalysis\TRADEresults\';

%% to update the data after new scenario runs
run('A1_Analysis_makeTradeData.m')

%% to make the Figures
run('A2_Analysis_makeData4Figures.m')

