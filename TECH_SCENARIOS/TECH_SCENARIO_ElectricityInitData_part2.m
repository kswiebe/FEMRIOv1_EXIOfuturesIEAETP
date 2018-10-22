%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% The renewable energy technology model for EXIOfuturesIEAETP
%% 2) Load scenario data 


% calculate scenario data or load the IEAEXIO struct if it exists

if calculateEPT2015scendata == 1
    if scenname == '6degrees' scen = 'C5:J125'; end
    if scenname == '4degrees' scen = 'O5:V125'; end
    if scenname == '2degrees' scen = 'AA5:AH125'; end 
    run('IEAEPT2015.m');
    save([thispath,'\RawData\IEAEPTscenario\',scenname,'.mat'],'IEAEXIO');    
end

load([thispath,'\RawData\IEAEPTscenario\',scenname,'.mat']);
IEAEXIO.scenarioname = scenname;
% set annual increase in electric vehicle share
IEAEXIO.EVshareincrease = zeros(nreg,ttlyears);
IEAEXIO.EVelecmachincoef = 0.45;
if scenname == '2degrees'
    for t = (nyears+1):ttlyears
        IEAEXIO.EVshareincrease(:,t) = 0.06;
    end
end
if scenname == '4degrees'
    for t = (nyears+1):ttlyears
        IEAEXIO.EVshareincrease(:,t) = 0.03;
    end
end

%% 3) Bringing it together
% From the scenario data we have energy demand by fuel, incl electricity, and 
% by user group (industry, transport and agriculture/fishing/buildings=FD).
% 
% Now, to implement this in the SUT, we cannot use the absolute levels, because 
% we project the use table as coefficients and feed the system with new final 
% demand. Hence, to estimate the new use coefficients we need the relative development 
% of energy inputs to the development of production. That is, the use coefficients 
% $a_{Ej t} = \frac{y_{Ej t}}{x_{j t}}$ of the energy inputs need to change in 
% the same way as the ratio (r) of energy inputs (E) to GDP:
% 
% $$r_{t+1} = \frac{E_{t+1}/GDP_{t+1}}{E_{t}/GDP_{t}} = \frac{E_{t+1}}{E_t}\frac{GDP_t}{GDP_{t+1}} 
% \\ = (1+gr(E_{t+1})) \frac{1}{1+gr(GDP_{t+1})}$$
% 
% with gr(x) being the growth rate of variable x. Hence, the use coefficient 
% at time t+1 is $a_{Ej t+1} = r_{t+1} a_{Ej t}$
% 
% Thus, I need to calculate the ratio r for the three user groups, all regions 
% and each energy carrier group. The concordances from the IEA energy products 
% to the EXiOBASE energy carrier groups are the same for industry and agriculture/fishing/FD, 
% but slightly different for transport.
% 
% The GDP grwoth rate is stored in MacroData.GDPgrowth(reg,t)

% from IEAEPT2015.mlx
% FENDindgrowth(prod,t,reg) is to be applied to industries EXIOiInd and EXIOiMiningTPED
% FENDothgrowth(prod,t,reg) is to be applied to industries EXIOiAgrFishBuild and GOVE, NPSH, GFCF
% IEAEXIOEnergyUseIndFD is the concordance matrix

%% set industries/products to which concordances apply
% industries
%EXIOiInd = [35:95, 108:114]; % manufacturing incl energy services and construction
%EXIOiAgrFishBuild = [1:19 , 115:163]; %Agriculture and fishing is clear, but buildings mainly refer to services and final demand,
%EXIOiMiningTPED = [20:34]; % this should also use the "industry sector data", but these industries are those who are demanded of less
%EXIOiElec = [96:107];
%% 
% rind(prod,t,reg) & roth(prod,t,reg)

[rind] = calcEnergyUSEcoefGrowthFactor(IEAEXIO.FENDindgrowth,nreg,nyears,ttlyears,MacroDatahist.GDPgrowth);
[roth] = calcEnergyUSEcoefGrowthFactor(IEAEXIO.FENDothgrowth,nreg,nyears,ttlyears,MacroDatahist.GDPgrowth);
[rtra] = calcEnergyUSEcoefGrowthFactor(IEAEXIO.FENDtragrowth,nreg,nyears,ttlyears,MacroDatahist.GDPgrowth);
% need to have transport fuel product indices
IEAEXIO.transportfuels.oil = [67:70];
IEAEXIO.transportfuels.gas = 75;
IEAEXIO.transportfuels.bio = [93:95];
IEAEXIO.transfuelrealloc = 0.2; % this is the ratio of the saved transport that will be reallocated to electricity if savings are positive
% assume same growth rate prior to 2012 as for 2012 onwards
rind(:,endyear+1-startyear,:) = rind(:,endyear+2-startyear,:);
roth(:,endyear+1-startyear,:) = roth(:,endyear+2-startyear,:);
rtra(:,endyear+1-startyear,:) = rtra(:,endyear+2-startyear,:);
% somethings off for "t>40 (2035) && reg==4 && IEAEXIO.prodvec(p)==5" it's 2.sth
for t=41:ttlyears rind(5,t,4) = rind(5,40,4); end

%% Growth rates for stressor intensities
% For the energy carrier use in the stressors 613:686 rind roth
% 
% CO2 growth rates relative to GDP
% 
% this can be used to change the CO2 intensity coefficients, industry  for 
% iInd and iMiningTPED and AgrBuildOth for those and final demand

[rCO2] = calcEnergyUSEcoefGrowthFactor(IEAEXIO.CO2emgrowth,nreg,nyears,ttlyears,MacroDatahist.GDPgrowth);