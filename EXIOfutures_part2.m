%% FEMRIO version1: EXIOfuturesIEAETP 
% by Kirsten S. Wiebe 

%% Part2: calculating the the different futures
% The upper part are initializations. They only need be run once for all
% scenarios. This include the first 55 lines or so up to and including
% section "6.1 IEA ETP Technology scenarios Initializations"

%% clear 
% cd([myDropboxPath,'EXIOfuturesIEAETP']);
%% Initializations for EXIOfuturesIEAETP 

run('EXIOfutures_init.m');
%EXIOfutureyears = 2015; % for testing purposes
EXIOfutureyears = 2015:5:finalyear; %is used in the EXIOfutures_projection.m


%% Make sure to have the historical data in the memory

% either run the first script, when having access to NTNU IndEcol's servers
%run('EXIOfutures_part1_labourCoefElectricity.m');

% or load the prepared data in the format used here
load('EXIOhist\SUThist.mat');
load('EXIOhist\MacroDatahist.mat');
load('regres\regres.mat');

% reduce Irelands (15) growth in 2015 (21)
MacroDatahist.IMFGDPgrowth(15,21) = 0.055;
MacroDatahist.GDPgrowth(15,21) = 0.055;
for t = 21:36
    MacroDatahist.GDPTRshouldbe(15,t) = MacroDatahist.GDPTRshouldbe(15,t-1)*(1+MacroDatahist.GDPgrowth(15,t));
end

%% create base year MRSUT sytem and convert to MRIO
% the format in which EXIOBASE3 is published as well
createbaseyear_ixi = 0;
if createbaseyear_ixi == 1
    run('CreateBaseYearMRSUTandMRIOTixi.m');
end %createbaseyear_ixi

%% Household demand estimations
% initialize PADS model at beginning of each projection


%% 6 Scenarios
% The GDP growth rates are given by the IEAEPT2015 scenarios. The GDP growth 
% rates are all the same. Just the energy use is different.

%% 6.1 IEA ETP Technology scenarios Initializations
%Electricity industry & energy use

run('TECH_SCENARIOS\TECH_SCENARIO_ElectricityInitMRSUTdata.m');
filenameREtechCoef = [myDropboxPath,'Data\DIW\Datenübergabe_UL_2010_05_17.xls']; %confidential data, not published
%filenameREtechCoef = 'RawData\RenEnTechCoeff_round0.1.xlsx'; % confidential data rounded to first decimal
run('TECH_SCENARIOS\TECH_SCENARIO_ElectricityInitData_part1.m'); 

%% 6.2 IEA EPT scenarios
%% 6.2.1 IEA ETP 2 degree scenario

% set to 1 if you want it updated (and have access to the original IEA EPT 2015 data)
calculateEPT2015scendata = 0; 
scenname = '2degrees';
run('TECH_SCENARIOS\TECH_SCENARIO_ElectricityInitData_part2.m');

scenarioname = '2degrees';
% changeConsStructure = 1; usePADS = 0; % for ILO
changeConsStructure = 0; usePADS = 1;
FDestimations = 1;
changeEnergyUse = 1;
changeElecTechCoef = 1;
circulareconomy = 0;
greenagriculture = 0;
run('EXIOfutures_projection.m');
selectedregions = [6 11 28 29 30 31];
run('EXIOfutures_plotMacroResults.m');
selectedregions = [1 2 5 12 14 15 ];
run('EXIOfutures_plotMacroResults.m');
%projectpath = [myDropboxPath,'CurrentWork\Paper 1 - TransformationPathwaysMethodology\Analysis\'];
disp(['Done with Scenario ',scenarioname,'!'])

%% 6.2.2 IEA ETP 4 degree scenario

%% 6.2.3 IEA ETP 6 degree scenario
calculateEPT2015scendata = 0;
scenname = '6degrees';
run('TECH_SCENARIOS\TECH_SCENARIO_ElectricityInitData_part2.m');

scenarioname = '6degrees';
% changeConsStructure = 1; usePADS = 0; % for ILO
changeConsStructure = 0; usePADS = 1;
FDestimations = 1;
changeEnergyUse = 1;
changeElecTechCoef = 1;
circulareconomy = 0;
greenagriculture = 0;
run('EXIOfutures_projection.m');
selectedregions = [6 11 28 29 30 31];
run('EXIOfutures_plotMacroResults.m');
%projectpath = [myDropboxPath,'CurrentWork\Paper 1 - TransformationPathwaysMethodology\Analysis\'];
disp(['Done with Scenario ',scenarioname,'!'])

%% 6.2.4 Circular Economy scenario based on base projection of IEA ETP 6 degree scenario

calculateEPT2015scendata = 0;
scenname = '6degrees';
run('TECH_SCENARIOS\TECH_SCENARIO_ElectricityInitData_part2.m');

%  Circular Economy
run('CircularEconomy_init.m')

scenarioname = '6degreesCircularEconomy';
changeConsStructure = 0; usePADS = 1;
FDestimations = 1;
changeEnergyUse = 1;
changeElecTechCoef = 1;
circulareconomy = 1;
greenagriculture = 0;
run('EXIOfutures_projection_iteration.m');
selectedregions = [6 11 28 29 30 31];
run('EXIOfutures_plotMacroResults.m');
disp(['Done with Scenario ',scenarioname,'!'])

%% 6.2.5 IEA ETP 6 degree scenario: with Iterations
calculateEPT2015scendata = 0;
scenname = '6degrees';
run('TECH_SCENARIOS\TECH_SCENARIO_ElectricityInitData_part2.m');

scenarioname = '6degreesIter';
changeConsStructure = 0; usePADS = 1;
FDestimations = 1;
changeEnergyUse = 1;
changeElecTechCoef = 1;
circulareconomy = 0;
greenagriculture = 0;
run('EXIOfutures_projection_iteration.m');
selectedregions = [6 11 28 29 30 31];
run('EXIOfutures_plotMacroResults.m');
selectedregions = [1 2 5 12 14 15 ];
run('EXIOfutures_plotMacroResults.m');
selectedregions = [35 43 45:49 ];
run('EXIOfutures_plotMacroResults.m');
selectedregions = [38:44 ];
run('EXIOfutures_plotMacroResults.m');
disp(['Done with Scenario ',scenarioname,'!'])
