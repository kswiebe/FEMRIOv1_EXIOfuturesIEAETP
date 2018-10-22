%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% Regressions of macro-economic demand-side variables
% FD estimated based on GDP growth from scenarios, well based FD[j,c,t] ~ VA[c,t], 
% for j being HH, GOV, INV
% 
% The estimation needs to be done in levels, see INFORUM literature, rather 
% than in first differences as suggest by the consumption literature.
% 
% 
constants = ones(nyears,1);

regres.HOUSpc = zeros(nreg,2);
regres.HOUS = zeros(nreg,2);
regres.NPSH = zeros(nreg,2);
regres.GOVE = zeros(nreg,2);
regres.GFCF = zeros(nreg,2);

%figure() 
diary('HOUSpc.txt')
for reg = 1:nreg
    %figure() %subplot(1,nreg,reg)
    %plot(MacroData.VApc(reg,1:(nyears-1)),MacroData.HOUSpc(reg,1:(nyears-1)),'.');
    %lsline
    %title(regioncodes(reg,:));
    
    reg %to display the region
    % to get model fit
    % (the last variable is the response variable and the others are the 
    %  predictor variables by default)
    mdl = fitlm(transpose(MacroData.VApc(reg,1:nyears)),transpose(MacroData.HOUSpc(reg,1:nyears))) %display model fit
    % store results (reg,(intercept, slope))
    [regres.HOUSpc(reg,:)] = regress(transpose(MacroData.HOUSpc(reg,1:nyears)),[constants transpose(MacroData.VApc(reg,1:nyears))]);   
    if regres.HOUSpc(reg,2)<0
        regres.HOUSpc(reg,1) = 0;
        [regres.HOUSpc(reg,2)] = regress(transpose(MacroData.HOUSpc(reg,1:nyears)),[transpose(MacroData.VApc(reg,1:nyears))]); 
    end
end
diary off

diary('HOUS.txt')
for reg = 1:nreg    
    reg %to display the region
    % to get model fit
    % (the last variable is the response variable and the others are the 
    %  predictor variables by default)
    mdl = fitlm(transpose(MacroData.VA(reg,1:nyears)),transpose(MacroData.HOUS(reg,1:nyears))) %display model fit
    % store results (reg,(intercept, slope))
    [regres.HOUS(reg,:)] = regress(transpose(MacroData.HOUS(reg,1:nyears)),[constants transpose(MacroData.VA(reg,1:nyears))]);  
    if regres.HOUS(reg,2)<0
        regres.HOUS(reg,1) = 0;
        [regres.HOUS(reg,2)] = regress(transpose(MacroData.HOUS(reg,1:nyears)),[transpose(MacroData.VA(reg,1:nyears))]); 
    end
end
diary off

diary('NPSH.txt')
for reg = 1:nreg    
    reg %to display the region
    % to get model fit
    % (the last variable is the response variable and the others are the 
    %  predictor variables by default)
    mdl = fitlm(transpose(MacroData.VA(reg,1:nyears)),transpose(MacroData.NPSH(reg,1:nyears))) %display model fit
    % store results (reg,(intercept, slope))
    [regres.NPSH(reg,:)] = regress(transpose(MacroData.NPSH(reg,1:nyears)),[constants transpose(MacroData.VA(reg,1:nyears))]);  
    if regres.NPSH(reg,2)<0
        regres.NPSH(reg,1) = 0;
        [regres.NPSH(reg,2)] = regress(transpose(MacroData.NPSH(reg,1:nyears)),[transpose(MacroData.VA(reg,1:nyears))]); 
    end
end
diary off

diary('GOVE.txt')
for reg = 1:nreg    
    reg %to display the region
    % to get model fit
    % (the last variable is the response variable and the others are the 
    %  predictor variables by default)
    mdl = fitlm(transpose(MacroData.VA(reg,1:nyears)),transpose(MacroData.GOVE(reg,1:nyears))) %display model fit
    % store results (reg,(intercept, slope))
    [regres.GOVE(reg,:)] = regress(transpose(MacroData.GOVE(reg,1:nyears)),[constants transpose(MacroData.VA(reg,1:nyears))]);  
    if regres.GOVE(reg,2)<0
        regres.GOVE(reg,1) = 0;
        [regres.GOVE(reg,2)] = regress(transpose(MacroData.GOVE(reg,1:nyears)),[transpose(MacroData.VA(reg,1:nyears))]); 
    end
end
diary off

diary('GFCF.txt')
for reg = 1:nreg    
    reg %to display the region
    % to get model fit
    % (the last variable is the response variable and the others are the 
    %  predictor variables by default)
    mdl = fitlm(transpose(MacroData.VA(reg,1:nyears)),transpose(MacroData.GFCF(reg,1:nyears))) %display model fit
    % store results (reg,(intercept, slope))
    [regres.GFCF(reg,:)] = regress(transpose(MacroData.GFCF(reg,1:nyears)),[constants transpose(MacroData.VA(reg,1:nyears))]);  
    if regres.GFCF(reg,2)<0
        regres.GFCF(reg,1) = 0;
        [regres.GFCF(reg,2)] = regress(transpose(MacroData.GFCF(reg,1:nyears)),[transpose(MacroData.VA(reg,1:nyears))]); 
    end
end
diary off

