%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe 

%% SCRIPT FOR CALCUATING RESULTS FOR THE JECS paper based on the IEA 6 degree and 2 degree scenarios
% Part 1: calculate stressor trade matrices

%% Start Analysis: make trade data of embodied flows


%% base 2014
year=2014;
scenarioname = 'EXIOhist';
tic
disp(['Calculations for ',scenarioname,' for ',num2str(year),' ...'])
results = calculateTRADEmatrices(EXIOfuturepath,scenarioname,year,nreg,nind,nfd,charfos,charmet,charCO2,couagg,AggConc.regionaggr');
toc
save([TRADEresultspath,'results_',scenarioname,'_',num2str(year),'.mat'],'results');


%% Loop over 3 years: 2020, 2025, 2030
yearlist = [2020 2025 2030];

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
        results = calculateTRADEmatrices(EXIOfuturepath,scenarioname,year,nreg,nind,nfd,charfos,charmet,charCO2,couagg,AggConc.regionaggr');
        save([TRADEresultspath,'results_',scenarioname,'_',num2str(year),'.mat'],'results');
        toc
    end
end


