%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe 
myDropboxPath = 'C:\Users\kirstesw\Dropbox\';

%% Initializations
% this file should always be called in all scripts to initialize the model

%% change to reflect folder structure
thispath = [myDropboxPath,'FEMRIOv1_EXIOfuturesIEAETP'];


%% Set working directory
cd(thispath);

%% Useful functions
addpath('MRSUTfunctions');

%% Initializations
startyear = 1995;
endyear = 2014;nyears = endyear-startyear+1;
finalyear=2030;
ttlyears = finalyear-startyear+1;
finalyearnames=num2str(startyear:finalyear);

nprod = 200;
nind = 163;
nva = 12;
nfd = 7;
nreg = 49;
relVA = 1:12; %relevant VA coefficients for total VA

[~,regioncodes,~] = xlsread('EXIOBASE_metadata.xlsx','Countries','B1:B49');
[~,regionnames,~] = xlsread('EXIOBASE_metadata.xlsx','Countries','C1:C49');
[ProdIndConcordance,~,~] = xlsread('EXIOBASE_metadata.xlsx','ProdIndConcordance','F7:FL206');

%% for electric vehicle modelling
motvehind = 91;
elecmachprod = 120;

%% find construction product
constructionprod = 150;
constructionind = 113;

%% Stressor indices
% confirm when using a different EXIOBASE version

CO2index = 24;
VAindex = 1:9;

% Employment
CoEidx=3:5;
emplidx=10:15;
LSidx=10:11;
MSidx=12:13;
HSidx=14:15;
Maleidx = [10 12 14];
Femaleidx = [11 13 15];
Vulneridx = 22;

