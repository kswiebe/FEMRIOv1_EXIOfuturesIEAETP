%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% Initialization for the PADS demand model
% called from EXIOfutures_projection

%% (update and) load PADS coefficients
clear 'PADS';

pathPADS = 'DemandModelPADS\';

updatePADS = 0;
if updatePADS == 1
	load('X:\indecol\USERS\Eivind\Demand model\PADSEXIO.mat'); 
    PADS = PADSEXIO;
    save([pathPADS,'PADS.mat'],'PADS');
else 
    load([pathPADS,'PADS.mat']);
end
% matrix of household expenditure in 2014 per capita in Euros, all countries (200x49)
PADS.EXIO2014 = SUThist.natFD(:,1:nfd:end); 
   