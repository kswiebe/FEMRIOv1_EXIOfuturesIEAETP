%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% Changing electricity technology coefficients

aMAEtemp = zeros(nprod,nreg);
aEMAtemp = zeros(nprod,nreg);

EXIOIRENA.InstalledCapacity(EXIOIRENA.InstalledCapacity<0)=0;
RenEnTech.PricePerkW(RenEnTech.PricePerkW<0)=0;
RenEnTech.CapitalCostShares(RenEnTech.CapitalCostShares<0)=0;
RenEnTech.ShareInBaseInd(RenEnTech.ShareInBaseInd<0)=0;

for reg=1:nreg
    for REtech = 1:nREtech
        % 1) update REtechGFCF
        % get elec ind from concordance
        el = find(IEAEXIO.ElectricityREtech(REtech,:)==1);
        % calculate grwoth rate of capacity of that elec ind
        tmpgrowth = IEAEXIO.ElecCapAllYears(el,t,reg)/IEAEXIO.ElecCapAllYears(el,t-1,reg);
        if t==nyears+1 
            tmpgrowth = IEAEXIO.ElecCapAllYears(el,t+1,reg)/IEAEXIO.ElecCapAllYears(el,t,reg);
        end
        if isnan(tmpgrowth)
            tmpgrowth = 1;
        end
        % increase REtech capacity with that growth rate
        EXIOIRENA.InstalledCapacity(REtech,t,reg) = EXIOIRENA.InstalledCapacity(REtech,t-1,reg) * tmpgrowth;
        % if something entirely new is build, take the absolute value (not
        % sure of that is 100% correct from the units. we'll see...
        if isinf(tmpgrowth) 
            EXIOIRENA.InstalledCapacity(REtech,t,reg) = IEAEXIO.ElecCapAllYears(el,t,reg);
        end
        % calculate difference to know how much has been added
        RenEnTech.NewCapacityScenarios(REtech,t,reg) = EXIOIRENA.InstalledCapacity(REtech,t,reg) - EXIOIRENA.InstalledCapacity(REtech,t-1,reg);
        if RenEnTech.NewCapacityScenarios(REtech,t,reg) < 0 
            RenEnTech.NewCapacityScenarios(REtech,t,reg) = 0;
        end
        % but some of the old have to be replaced, so add replacedCapacity
        RenEnTech.AddedCapacity(REtech,t,reg) = RenEnTech.NewCapacityScenarios(REtech,t,reg);% + ReplacedCapacity(REtech,t,reg);
        if isnan(RenEnTech.AddedCapacity(REtech,t,reg))
            RenEnTech.AddedCapacity(REtech,t,reg) = 0;
        end
            
        % Update replacedCapacity
        %if REtech > 1 % exclude hydro
        %    ReplacedCapacity(REtech,t+LifeSpan(REtech,t),reg) = ReplacedCapacity(REtech,t+LifeSpan(REtech,t),reg) + AddedCapacity(REtech,t,reg);
        %end
        % Calculate investment in EUR        
        RenEnTech.AddedCapacityGWEUR(REtech,t,reg) = RenEnTech.AddedCapacity(REtech,t,reg)* RenEnTech.PricePerkW(REtech,t);% it would need to be * 1000000; but SUT is in mio EUR     
        % calculate additional GFCF
        RenEnTech.REtechGFCF(REtech,t,reg,:) = RenEnTech.AddedCapacityGWEUR(REtech,t,reg) * RenEnTech.CapitalCostShares(REtech,t,:);
       

        % 2A) update shares for iter==1
        RETGFCF = RenEnTech.REtechGFCF(REtech,t,reg,1)/RenEnTech.REtechGFCF(REtech,t-1,reg,1);
        if isnan(RETGFCF)
            RETGFCF = 0;
        end
        if RETGFCF < 0
            RETGFCF = 0;
        end
        RETGDP = (1+MacroData.GDPgrowth(reg,t))/(1+MacroData.GDPgrowth(reg,t-1));
        if isinf(RETGFCF)
            RETGFCF = RETGDP;
        end
        RETscale = RETGFCF/RETGDP;
        RenEnTech.ShareInBaseInd(REtech,t,reg) = RETscale*RenEnTech.ShareInBaseInd(REtech,t-1,reg);
        %check REtech
        %check RenEnTech.ShareInBaseInd(REtech,t,reg)
        % 2B) update shares for iter >=1
    end %REtech
    % 3) calculate new coefs & additional GFCF
    sumMAE = 0; sumEMA = 0;
    sumMAEGFCF = 0; sumEMAGFCF = 0;
    sumOTHGFCF = zeros(length(RenEnTech.CapitalCostShareConcordance(2:end,1)),1);
    for REtech = 1:nREtech
        if RenEnTech.REbaseProdInd(REtech,4) == MAEind
            aMAEtemp(:,reg) = aMAEtemp(:,reg) + RenEnTech.ShareInBaseInd(REtech,t,reg) * RenEnTech.REtechCoef(:,REtech);
            sumMAE = sumMAE + RenEnTech.ShareInBaseInd(REtech,t,reg);
            % GFCF
            sumMAEGFCF = sumMAEGFCF + RenEnTech.REtechGFCF(REtech,t,reg,1);
        end
        if RenEnTech.REbaseProdInd(REtech,4) == EMAind
            aEMAtemp(:,reg) = aEMAtemp(:,reg) + RenEnTech.ShareInBaseInd(REtech,t,reg) * RenEnTech.REtechCoef(:,REtech);
            sumEMA = sumEMA + RenEnTech.ShareInBaseInd(REtech,t,reg);
            % GFCF
            sumEMAGFCF = sumEMAGFCF + RenEnTech.REtechGFCF(REtech,t,reg,1);
        end
        sumOTHGFCF = sumOTHGFCF + squeeze(RenEnTech.REtechGFCF(REtech,t,reg,2:end));
    end %REtech
    %reg
    %SUT_t.aMAE(:,reg) = aMAEtemp(:,reg) + (1 - sumMAE)*RenEnTech.aMAEex(:,reg);
    %SUT_t.aEMA(:,reg) = aEMAtemp(:,reg) + (1 - sumEMA)*RenEnTech.aEMAex(:,reg);
    %using actual current coefficients. assuming in 2014 there was no big
    %impact of REtech production on the coefficients of the industry
    SUT_t.aMAE(:,reg) = aMAEtemp(:,reg) + (1 - sumMAE)*RenEnTech.aMAE(:,reg);
    SUT_t.aEMA(:,reg) = aEMAtemp(:,reg) + (1 - sumEMA)*RenEnTech.aEMA(:,reg);
    %min(SUT_t.aMAE(:,reg))
    %min(SUT_t.aMAE(:,reg))
    % rescaling is done in the energy use
    natFDnew(MAEprod,(reg-1)*nfd+4) = natFDnew(MAEprod,(reg-1)*nfd+4) + sumMAEGFCF;
    natFDnew(EMAprod,(reg-1)*nfd+4) = natFDnew(EMAprod,(reg-1)*nfd+4) + sumEMAGFCF;
    natFDnew(RenEnTech.CapitalCostShareConcordance(2:end,1),(reg-1)*nfd+4) = natFDnew(RenEnTech.CapitalCostShareConcordance(2:end,1),(reg-1)*nfd+4) + sumOTHGFCF;

    AdditionalREinvestmentshare(:,t,reg) = sumOTHGFCF ./ natFDnew(RenEnTech.CapitalCostShareConcordance(2:end,1),(reg-1)*nfd+4);
    AdditionalREinvestmentshare(1,t,reg) = AdditionalREinvestmentshare(1,t,reg) + sumMAEGFCF ./ natFDnew(RenEnTech.CapitalCostShareConcordance(2,1),(reg-1)*nfd+4);
    AdditionalREinvestmentshare(2,t,reg) = AdditionalREinvestmentshare(2,t,reg) + sumEMAGFCF ./ natFDnew(RenEnTech.CapitalCostShareConcordance(3,1),(reg-1)*nfd+4);
%     AdditionalREinvestment(:,t,reg) = sumOTHGFCF;
%     AdditionalREinvestment(1,t,reg) = AdditionalREinvestment(1,t,reg) + sumMAEGFCF;
%     AdditionalREinvestment(2,t,reg) = AdditionalREinvestment(2,t,reg) + sumEMAGFCF;
    %disp(['reg ',num2str(reg),' sumMAEGFCF ',num2str(sumMAEGFCF),' sumEMAGFCF ',num2str(sumEMAGFCF)])
    %check sum(SUT_t.aMAE(:,reg))
    %check sum(SUT_t.aEMA(:,reg))
end %reg

%SUT_t.natUSEcoef(:,MAEind:nind:end) = SUT_t.aMAE; % machinery and equipment
%SUT_t.natUSEcoef(:,EMAind:nind:end) = SUT_t.aEMA; % electrical machinery and apparatus
natUSEcoefBnew(:,MAEind:nind:end) = SUT_t.aMAE; % machinery and equipment
natUSEcoefBnew(:,EMAind:nind:end) = SUT_t.aEMA; % electrical machinery and apparatus

%squeeze(AdditionalREinvestmentshare(:,t,:))
