%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% Change the energy input coefficients according to IEA scenario
% this changes all energy carriers, including electricity, but only
% electricity total

for reg = 1:nreg
    natUSEcoefCou = natUSEcoefBnew(:,((reg-1)*nind+1):(reg*nind));
    % intermediate input share for rescaling
    interminputshare = sum(natUSEcoefCou,1);
    % the intermediate input share that are not touched by the growth rates
    interminputsharesumnogr = sum(natUSEcoefCou.*repmat(IEAEXIO.prodvecINV,1,nind),1);
    % the shares of the products in the no growth rate 
    shareinnogr = (natUSEcoefCou.*repmat(IEAEXIO.prodvecINV,1,nind))./repmat(interminputsharesumnogr,nprod,1);
    shareinnogr(isnan(shareinnogr)) = 0;
    
    % apply growth rates to those products where we have info from IEA
    % scenario
    for p = 1:nprod
        if IEAEXIO.prodvec(p)>0 % taken out the transport fuels from this prodvec
            gr = rind(IEAEXIO.prodvec(p),t,reg);
            natUSEcoefCou(p,IEAEXIO.iInd) = gr * natUSEcoefCou(p,IEAEXIO.iInd);
            natUSEcoefCou(p,IEAEXIO.iMiningTPED) = gr * natUSEcoefCou(p,IEAEXIO.iMiningTPED);
            gr = roth(IEAEXIO.prodvec(p),t,reg); %if t>40 gr = roth(IEAEXIO.prodvec(p),40,reg); end
            natUSEcoefCou(p,IEAEXIO.iAgrFishBuild) = gr * natUSEcoefCou(p,IEAEXIO.iAgrFishBuild);
        end
    end
    % transport fuels
    gr = rtra(1,t,reg); %oil
    IEAEXIO.transfueldiff = sum((1-gr) * natUSEcoefCou(IEAEXIO.transportfuels.oil,:),1);
    natUSEcoefCou(IEAEXIO.transportfuels.oil,:) = gr * natUSEcoefCou(IEAEXIO.transportfuels.oil,:);
    gr = rtra(3,t,reg); %gas
    IEAEXIO.transfueldiff = IEAEXIO.transfueldiff + sum((1-gr) * natUSEcoefCou(IEAEXIO.transportfuels.gas,:),1);
    natUSEcoefCou(IEAEXIO.transportfuels.gas,:) = gr * natUSEcoefCou(IEAEXIO.transportfuels.gas,:);
    gr = rtra(5,t,reg); %biofuels
    IEAEXIO.transfueldiff = IEAEXIO.transfueldiff + sum((1-gr) * natUSEcoefCou(IEAEXIO.transportfuels.bio,:),1);
    natUSEcoefCou(IEAEXIO.transportfuels.bio,:) = gr * natUSEcoefCou(IEAEXIO.transportfuels.bio,:);
    % reallocation of 20% of the savings to electricity
    for i=1:nind
        if IEAEXIO.transfueldiff(i) > 0 %only reallocate if there's fuel savings
            elecprodshares = natUSEcoefCou(elecprod,i)./repmat(sum(natUSEcoefCou(elecprod,i),1),length(elecprod),1);
            elecprodshares(isnan(elecprodshares)) = 0;
            elecprodshares(isinf(elecprodshares)) = 0;
            natUSEcoefCou(elecprod,i) = natUSEcoefCou(elecprod,i) + IEAEXIO.transfuelrealloc*repmat(IEAEXIO.transfueldiff(i),length(elecprod),1).*elecprodshares;
        end
    end
    % for rescaling: the difference needs to be allocated to the no growth
    interminputsharediff = interminputshare - sum(natUSEcoefCou,1);
    for i = 1:nind
        if (sum(natUSEcoefCou(:,i))+SUT_t.VAcoef(relVA,(reg-1)*nind+i)) <=1
            for j = 1:size(natUSEcoefCou,1)
                if natUSEcoefCou(j,i) + interminputsharediff(i)* shareinnogr(j,i) > 0
                    natUSEcoefCou(j,i) = natUSEcoefCou(j,i) + interminputsharediff(i)* shareinnogr(j,i);
                end
            end
        else % if it is larger than 1, we need to rescale to original
            origsum = sum(natUSEcoefBnew(:,(reg-1)*nind+i));
            tempsum = sum(natUSEcoefCou(:,i));
            natUSEcoefCou(:,i) = natUSEcoefCou(:,i)*origsum/tempsum;
        end
    end
  %  disp(['3. min use coefficient = ',num2str(min(min(natUSEcoefCou)))])
    natUSEcoefBnew(:,((reg-1)*nind+1):(reg*nind)) = natUSEcoefCou;
    % check
   % if reg==1 && year > 2042 && year < 2049
        %tmpcheck(year-2042,:) = interminputshare - sum(natUSEcoefCou,1);
        %natUSEcoefCou < 0
   % end
end
% check
%if t > 48 && t < 52
%    sum(natUSEcoefBnew,1)
%end
%check
%(sum(natUSEcoefB,1) - sum(natUSEcoefBnew,1))>0.0001