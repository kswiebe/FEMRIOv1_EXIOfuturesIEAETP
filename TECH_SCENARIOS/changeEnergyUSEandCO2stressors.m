%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% change stressor intensities
% default no change is set in iteration
%SUT_t.S = SUT.S;
%IEAEXIO.EnergyUseIndFDstressors; % concordance matrix from energy carriers to stressors
for reg=1:nreg

     r0 = (reg-1)*nind;   
    %% Energy use stressors
    % TODO
    
    %% CO2 stressors
    Sselect = CO2index;
    
    % rCO2
    %{'Industry';'Buildings, agriculture, fishing, non-specified other';'Transport';'Power';'Other transformation';'Total'}
    
    %1 'Industry'
    SUT_t.S(Sselect,r0 + IEAEXIO.iInd) = rCO2(1,t,reg) * SUT.S(Sselect,r0 + IEAEXIO.iInd);
    
    %2 'Buildings, agriculture, fishing, non-specified other'
    SUT_t.S(Sselect,r0 + IEAEXIO.iAgrFishBuild) = rCO2(2,t,reg) * SUT.S(Sselect,r0 + IEAEXIO.iAgrFishBuild);
    
    %3 'Transport'
    % direct emissions by households is mostly transport
    SUT_t.S_fd(Sselect,reg,:) = rCO2(3,t,reg) * SUT.S_fd(Sselect,reg,:);
    %%%% TODO
    % get TRANSPORT out of iInd or iAgrFishBuild but that would require
    % some EV / hybrid modelling
    
    %4 'Power'
    SUT_t.S(Sselect,r0 + IEAEXIO.iElec) = rCO2(4,t,reg) * SUT.S(Sselect,r0 + IEAEXIO.iElec);
    
    %5 'Other transformation'
    SUT_t.S(Sselect,r0 + IEAEXIO.iMiningTPED) = rCO2(5,t,reg) * SUT.S(Sselect,r0 + IEAEXIO.iMiningTPED);

    
    
end % for reg