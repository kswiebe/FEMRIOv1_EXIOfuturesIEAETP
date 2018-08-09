function [grlong] = calcIEAgrowthrates(nreg,yearvec,growthbase,ttlyears,startyear)
    growthbase(growthbase<0) = 0;
    gr = growthbase; gr(:,:,:) = 0;
    for c = 1:nreg
        for t = 2:size(yearvec,2)
            temp = (growthbase(:,t,c)./growthbase(:,t-1,c));
            temp(isnan(temp)) = 1;
            gr(:,t,c) = temp.^(1/(yearvec(t)-yearvec(t-1)))-1;
        end
    end
    grlong = zeros(size(growthbase,1),ttlyears,nreg);
    for y = 2:size(yearvec,2)
        for t = (yearvec(y-1) - startyear + 1):(yearvec(y) - startyear + 1)
            grlong(:,t,:) = gr(:,y,:);
        end
    end
    grlong(isinf(grlong))=0;
    grlong(isnan(grlong))=0;
end