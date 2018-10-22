%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% change electricity consumption according to IEAETP scenario
% is based on previous years t-1 electricity use and then rescaled to this
% year's total electricity
%
function newelectricitydemand = changeElectricityTypeUse(natMatrix,natmatrixtminus1,ElecGenAllYears,nreg,ncol,elecprod,t)
    newelectricitydemand = natMatrix;  %where nataggr is natUSEcoefB or natFD
    for r = 1:nreg
        r1 = (r-1)*ncol+1; %where ncol is nind or nfd
        r2 = r*ncol;
        origsum = sum(natMatrix(elecprod,r1:r2),1);
        tempgrowth = (ElecGenAllYears(:,t,r)./ElecGenAllYears(:,t-1,r));
        tempgrowth(isnan(tempgrowth))=1;
        tempgrowth(isinf(tempgrowth))=1;
        if sum(sum(natmatrixtminus1(elecprod,r1:r2)))==0
            natmatrixtminus1(elecprod,r1:r2) = natMatrix(elecprod,r1:r2);
        end
        tempuse = repmat(tempgrowth,1,ncol).*natmatrixtminus1(elecprod,r1:r2);
        % if a new type is introduced, e.g. solar PV or so
        for p = elecprod
            if ElecGenAllYears(p-elecprod(1)+1,t,r) > 0 && ElecGenAllYears(p-elecprod(1)+1,t-1,r) == 0 && sum(tempuse(p-elecprod(1)+1,:))==0
                tempuse(p-elecprod(1)+1,:) = sum(tempuse).*ElecGenAllYears(p-elecprod(1)+1,t,r)./sum(ElecGenAllYears(:,t,r));
                %p
            end
        end
        tempsum = sum(tempuse,1);
        tempsum(isnan(tempsum))=1;
        tempsum(isinf(tempsum))=1;
        tempsum(tempsum==0)=1;
        tempratio = origsum./tempsum;
        tempratio(isnan(tempratio)) = 1;
        tempratio(isinf(tempratio)) = 1;
        newelectricitydemand(elecprod,r1:r2) = repmat(tempratio,size(elecprod,2),1) .* tempuse;
        if isnan(sum(sum( newelectricitydemand(elecprod,r1:r2))))
             r
     %   sum(sum( newelectricitydemand(elecprod,r1:r2)))
        end
        
    end

end