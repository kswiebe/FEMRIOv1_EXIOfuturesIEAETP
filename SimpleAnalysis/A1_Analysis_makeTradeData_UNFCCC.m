%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe 
% for presentation at UNFCCC Workshop in September 2018
clear
%% Initializations
run('EXIOfutures_init.m');
addpath('SimpleAnalysis\');
EXIOfuturepath = 'futures\';
EXIOfuturepath = 'C:\Users\kirstesw\Dropbox\Workshops&Presentations\201809 UNFCCC cape town\Data\futures\'; % DataFromJECSpublication
load([EXIOfuturepath,'EXIOhist\','meta.mat']);
regioncodes=meta.countries;


%% Load aggregation matrices
run('LoadAggregationMatrices.m');

%% Path to data for analysis
% needed in A1_ and A2_
TRADEresultspath = 'SimpleAnalysis\TRADEresults\';
TRADEresultspath = 'C:\Users\kirstesw\Dropbox\Workshops&Presentations\201809 UNFCCC cape town\Data\TRADEresults\';
%% Stressor selection
% emissions
charCO2 = zeros(1,length(meta.labsF));
charCO2(CO2index) = 1;

% employment
charEMPL = zeros(1,length(meta.labsF));
charEMPL(emplidx) = 1;

%% base 2014
year=2014;
scenarioname = 'EXIOhist';
tic
disp(['Calculations for ',scenarioname,' for ',num2str(year),' ...'])
char = charCO2;
resultsCO2 = calculateTRADEmatrices_GENERIC(EXIOfuturepath,scenarioname,year,nreg,nind,nfd,char,couagg,AggConc.regionaggr');
save([TRADEresultspath,'results_',scenarioname,'_',num2str(year),'UNFCCC_CO2.mat'],'resultsCO2');
char = charEMPL;
resultsEMPL = calculateTRADEmatrices_GENERIC(EXIOfuturepath,scenarioname,year,nreg,nind,nfd,char,couagg,AggConc.regionaggr');
save([TRADEresultspath,'results_',scenarioname,'_',num2str(year),'UNFCCC_EMPL.mat'],'resultsEMPL');
toc
%% Loop over 3 years: 2020, 2025, 2030
%yearlist = [2020 2025 2030];
yearlist = 2030;

% scenarios = {'6degrees','2degrees'}; % doesn't work for the loading
% because it's a cell and not a string

year = 2030;


for s = 1:2
        if s==1
            scenarioname = '6degrees'
        end
        if s==2
            scenarioname = '2degrees'
        end
    for year = yearlist
        disp(['Calculations for ',scenarioname,' for ',num2str(year),' ...'])
        tic
        char = charCO2;
        resultsCO2 = calculateTRADEmatrices_GENERIC(EXIOfuturepath,scenarioname,year,nreg,nind,nfd,char,couagg,AggConc.regionaggr');
        save([TRADEresultspath,'results_',scenarioname,'_',num2str(year),'UNFCCC_CO2.mat'],'resultsCO2');
        char = charEMPL;
        resultsEMPL = calculateTRADEmatrices_GENERIC(EXIOfuturepath,scenarioname,year,nreg,nind,nfd,char,couagg,AggConc.regionaggr');
        save([TRADEresultspath,'results_',scenarioname,'_',num2str(year),'UNFCCC_EMPL.mat'],'resultsEMPL');
        toc
    end
end


