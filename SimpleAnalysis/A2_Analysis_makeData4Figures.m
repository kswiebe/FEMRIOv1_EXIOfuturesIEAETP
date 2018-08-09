%% FEMRIO version1: EXIOfuturesIEAEPT
% by Kirsten S. Wiebe 

%% SCRIPT FOR CALCUATING RESULTS FOR THE JECS paper based on the IEA 6 degree and 2 degree scenarios
% Part 2: load trade matrices and prepare data for Figures



%% Preparations
filename = 'SimpleAnalysis\Analysis.xlsx';
% The data is written into Analysis.xlsx with this script.
% The figures are prepared in AnalysisFigures.xlsx, which is linked to 
% Analysis.xlsx. 

%% Selection of aggregated regions to analyse

regnums = [7,8,2,3,5,1];
regs = length(regnums);
wrldttl = 6;
analysisregions = aggrnames.reg(regnums);

%% load results
scenarioname = 'EXIOhist'; year = 2014;
load([TRADEresultspath,'results_',scenarioname,'_',num2str(year),'.mat']);
results2014 = results;

scenarioname = '2degrees'; 
year = 2020;
load([TRADEresultspath,'results_',scenarioname,'_',num2str(year),'.mat']);
results20202deg = results;
year = 2025;
load([TRADEresultspath,'results_',scenarioname,'_',num2str(year),'.mat']);
results20252deg = results;
year = 2030;
load([TRADEresultspath,'results_',scenarioname,'_',num2str(year),'.mat']);
results20302deg = results;

scenarioname = '6degrees'; 
year = 2020;
load([TRADEresultspath,'results_',scenarioname,'_',num2str(year),'.mat']);
results20206deg = results;
year = 2025;
load([TRADEresultspath,'results_',scenarioname,'_',num2str(year),'.mat']);
results20256deg = results;
year = 2030;
load([TRADEresultspath,'results_',scenarioname,'_',num2str(year),'.mat']);
results20306deg = results;


%%  Figure 2: CO2 emissions
sheetname2 = 'Figure2';

%%% for Supplmentary Information
% Production for comparison with IEA scenario
% Global, BR, CN, EU28, IN, MX, RU, ZA, US
% 1:49, 34, 31, 1:28, 35, 36, 37, 44, 29
diff2020 = calcCO2diff_forIEAcomp(results20202deg.co2trade_cxc,results20206deg.co2trade_cxc)
diff2025 = calcCO2diff_forIEAcomp(results20252deg.co2trade_cxc,results20256deg.co2trade_cxc)
diff2030 = calcCO2diff_forIEAcomp(results20302deg.co2trade_cxc,results20306deg.co2trade_cxc)
xlswrite(filename,diff2020,sheetname2,'D6');
xlswrite(filename,diff2025,sheetname2,'D8');
xlswrite(filename,diff2030,sheetname2,'D10');


%%% for main text
global2deg(1) = sum(sum(results2014.co2trade_cxc));
global2deg(2) = sum(sum(results20202deg.co2trade_cxc));
global2deg(3) = sum(sum(results20252deg.co2trade_cxc));
global2deg(4) = sum(sum(results20302deg.co2trade_cxc));
xlswrite(filename,global2deg,sheetname2,'D30');

global6deg(1) = sum(sum(results2014.co2trade_cxc));
global6deg(2) = sum(sum(results20206deg.co2trade_cxc));
global6deg(3) = sum(sum(results20256deg.co2trade_cxc));
global6deg(4) = sum(sum(results20306deg.co2trade_cxc));
xlswrite(filename,global6deg,sheetname2,'D31');

EUprod2deg(1) = sum(sum(results2014.co2trade_cxc(1:28,:)));
EUprod2deg(2) = sum(sum(results20202deg.co2trade_cxc(1:28,:)));
EUprod2deg(3) = sum(sum(results20252deg.co2trade_cxc(1:28,:)));
EUprod2deg(4) = sum(sum(results20302deg.co2trade_cxc(1:28,:)));
xlswrite(filename,EUprod2deg,sheetname2,'D32');
EUprod6deg(1) = sum(sum(results2014.co2trade_cxc(1:28,:)));
EUprod6deg(2) = sum(sum(results20206deg.co2trade_cxc(1:28,:)));
EUprod6deg(3) = sum(sum(results20256deg.co2trade_cxc(1:28,:)));
EUprod6deg(4) = sum(sum(results20306deg.co2trade_cxc(1:28,:)));
xlswrite(filename,EUprod6deg,sheetname2,'D33');

EUcons2deg(1) = sum(sum(results2014.co2trade_cxc(:,1:28)));
EUcons2deg(2) = sum(sum(results20202deg.co2trade_cxc(:,1:28)));
EUcons2deg(3) = sum(sum(results20252deg.co2trade_cxc(:,1:28)));
EUcons2deg(4) = sum(sum(results20302deg.co2trade_cxc(:,1:28)));
xlswrite(filename,EUcons2deg,sheetname2,'D34');
EUcons6deg(1) = sum(sum(results2014.co2trade_cxc(:,1:28)));
EUcons6deg(2) = sum(sum(results20206deg.co2trade_cxc(:,1:28)));
EUcons6deg(3) = sum(sum(results20256deg.co2trade_cxc(:,1:28)));
EUcons6deg(4) = sum(sum(results20306deg.co2trade_cxc(:,1:28)));
xlswrite(filename,EUcons6deg,sheetname2,'D35');


%% Figure 3: prod and cons 2014 
sheetname3 = 'Figure3';

fos = results2014.fostrade_rxr(regnums,regnums); %  used 
met = results2014.mettrade_rxr(regnums,regnums);

xlswrite(filename,fos,sheetname3,'C3');
xlswrite(filename,met,sheetname3,'P3');


%% Figure 4: net imports (imports-exports = cons - prod) over time
% yearlist
%sheetname4cons = 'Figure4cons';
%sheetname4prod = 'Figure4prod';
sheetname4 = 'Figure4';
% analysisregions: EU28 is the first
% consumption is the sum of the first column

clear cons prod
% 2deg fossil
trade_rxr = results2014.fostrade_rxr(regnums,regnums,:); t = 1; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg);
trade_rxr = results20202deg.fostrade_rxr(regnums,regnums,:); t = 2; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg);
trade_rxr = results20252deg.fostrade_rxr(regnums,regnums,:); t = 3; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg);
trade_rxr = results20302deg.fostrade_rxr(regnums,regnums,:); t = 4; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg)
%xlswrite(filename,cons,sheetname4cons,'D11');
%xlswrite(filename,prod,sheetname4prod,'D11');
neti_fos_2deg = cons-prod;
clear cons prod
xlswrite(filename,neti_fos_2deg,sheetname4,'D11');


% 6deg fossil
trade_rxr = results2014.fostrade_rxr(regnums,regnums,:); t = 1; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg);
trade_rxr = results20206deg.fostrade_rxr(regnums,regnums,:); t = 2; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg);
trade_rxr = results20256deg.fostrade_rxr(regnums,regnums,:); t = 3; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg);
trade_rxr = results20306deg.fostrade_rxr(regnums,regnums,:); t = 4; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg)
%xlswrite(filename,cons,sheetname4cons,'D3');
%xlswrite(filename,prod,sheetname4prod,'D3');
neti_fos_6deg = cons-prod;
clear cons prod
xlswrite(filename,neti_fos_6deg,sheetname4,'D3');


% 2deg metals
trade_rxr = results2014.mettrade_rxr(regnums,regnums,:); t = 1; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg);
trade_rxr = results20202deg.mettrade_rxr(regnums,regnums,:); t = 2; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg);
trade_rxr = results20252deg.mettrade_rxr(regnums,regnums,:); t = 3; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg);
trade_rxr = results20302deg.mettrade_rxr(regnums,regnums,:); t = 4; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg)
%xlswrite(filename,cons,sheetname4cons,'O31');
%xlswrite(filename,prod,sheetname4prod,'O31');
neti_met_2deg = cons-prod;
clear cons prod
xlswrite(filename,neti_met_2deg,sheetname4,'O31');

% 6deg metals
trade_rxr = results2014.mettrade_rxr(regnums,regnums,:); t = 1; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg);
trade_rxr = results20206deg.mettrade_rxr(regnums,regnums,:); t = 2; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg);
trade_rxr = results20256deg.mettrade_rxr(regnums,regnums,:); t = 3; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg);
trade_rxr = results20306deg.mettrade_rxr(regnums,regnums,:); t = 4; reg = 1; %EU
[cons(:,t),prod(:,t)] = calculateConsProd(trade_rxr,reg)
%xlswrite(filename,cons,sheetname4cons,'O3');
%xlswrite(filename,prod,sheetname4prod,'O3');
neti_met_6deg = cons-prod;
clear cons prod
xlswrite(filename,neti_met_6deg,sheetname4,'O3');


 
%% Figure 5: embodied in exports
sheetname5 = 'Figure5';

reg = 7; %EU
% 6deg fossil (total = 1)
clear exp
t = 1; 
exp(:,t) = results20206deg.fosexp_rxr(regnums,reg,1);
t = 2;
exp(:,t) = results20256deg.fosexp_rxr(regnums,reg,1);
t = 3;
exp(:,t) = results20306deg.fosexp_rxr(regnums,reg,1);
xlswrite(filename,exp,sheetname5,'C3');

% 6deg metal (total = 1)
clear exp
t = 1;
exp(:,t) = results20206deg.metexp_rxr(regnums,reg,1);
t = 2;
exp(:,t) = results20256deg.metexp_rxr(regnums,reg,1);
t = 3;
exp(:,t) = results20306deg.metexp_rxr(regnums,reg,1);
xlswrite(filename,exp,sheetname5,'P3');


% 2deg fossil (total = 1)
clear exp
t = 1;
exp(:,t) = results20202deg.fosexp_rxr(regnums,reg,1);
t = 2;
exp(:,t) = results20252deg.fosexp_rxr(regnums,reg,1);
t = 3;
exp(:,t) = results20302deg.fosexp_rxr(regnums,reg,1);
xlswrite(filename,exp,sheetname5,'C13');

% 2deg metal (total = 1)
clear exp
t = 1;
exp(:,t) = results20202deg.metexp_rxr(regnums,reg,1);
t = 2;
exp(:,t) = results20252deg.metexp_rxr(regnums,reg,1);
t = 3;
exp(:,t) = results20302deg.metexp_rxr(regnums,reg,1);
xlswrite(filename,exp,sheetname5,'P13');


%% VA difference for Supplementary Information

% base 2014
counter = 1;
year=2014;
scenarioname = 'EXIOhist';
IO = load([EXIOfuturepath,scenarioname,'\final_IOT_',num2str(year),'_ixi.mat']);

regioncodes=IO.IO.meta.countries;



[VA(counter,:),VAlong(counter,:)] = calculateMACRO(IO.IO,nreg,nind,nfd);

yearlist = [2020 2025 2030];

for s = 1:2
        if s==1
            scenarioname = '6degrees'
        end
        if s==2
            scenarioname = '2degrees'
        end
    for year = yearlist
        counter = counter+1;
        year
        tic
        IO = load([EXIOfuturepath,scenarioname,'\final_IOT_',num2str(year),'_ixi.mat']);
        [VA(counter,:),VAlong(counter,:)] = calculateMACRO(IO.IO,nreg,nind,nfd);
        toc
    end
end


xlswrite(filename,VA,'FigureSI1_VA','B2');
 
