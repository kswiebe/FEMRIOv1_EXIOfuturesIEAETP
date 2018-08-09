function [gr] = calcEnergyUSEcoefGrowthFactor(growthbase,nreg,nyears,ttlyears,gdpgrowth)
    gr = growthbase; gr(:,:,:) = 0;
    for c = 1:nreg
        for t = (nyears+1):ttlyears
            temp = (1+growthbase(:,t,c))./(1+gdpgrowth(c,t));
            temp(isnan(temp)) = 1;
            temp(isinf(temp)) = 1;
            gr(:,t,c) = temp;
        end
    end

end