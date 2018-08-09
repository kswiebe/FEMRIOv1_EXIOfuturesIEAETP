%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% Change the energy use of final demand according to IEA scenario
% this changes all energy carriers, including electricity, but only
% electricity total
% define fdcat = 3; %GOVE, or fdcat = 2;% NPSH fdcat = 4; %GFCF
for reg = 1:nreg
    %%natFDnew(:,(reg-1)*nfd+3) = SUT(nyears).natFD(:,(reg-1)*nfd+3) * (GOVE(reg,t)/GOVE(reg,nyears));
    fdtemp = natFDnew(:,(reg-1)*nfd+fdcat);
    % total for rescaling: GOVE(reg,t)
    fdtemporigsum = sum(fdtemp);
    % the products that are not touched by the growth rates
    fdtempsumnogr = sum(fdtemp.*IEAEXIO.prodvecINV,1);
    % the shares of the products in the no growth rate 
    shareinnogr = (fdtemp.*IEAEXIO.prodvecINV)./repmat(fdtempsumnogr,nprod,1);
    shareinnogr(isnan(shareinnogr)) = 0;
    
    % apply growth rates to those products where we have info from IEA
    % scenario
    for p = 1:nprod
        if IEAEXIO.prodvec(p)>0
            gr = roth(IEAEXIO.prodvec(p),t,reg); 
            fdtemp(p) = gr * fdtemp(p);
        end
    end
       % transport fuels
    gr = rtra(1,t,reg); %oil
    IEAEXIO.transfueldiff = sum((1-gr) * fdtemp(IEAEXIO.transportfuels.oil),1);
    fdtemp(IEAEXIO.transportfuels.oil) = gr * fdtemp(IEAEXIO.transportfuels.oil);
    gr = rtra(3,t,reg); %gas
    IEAEXIO.transfueldiff = IEAEXIO.transfueldiff + sum((1-gr) * fdtemp(IEAEXIO.transportfuels.gas),1);
    fdtemp(IEAEXIO.transportfuels.gas) = gr * fdtemp(IEAEXIO.transportfuels.gas);
    gr = rtra(5,t,reg); %biofuels
    IEAEXIO.transfueldiff = IEAEXIO.transfueldiff + sum((1-gr) * fdtemp(IEAEXIO.transportfuels.bio),1);
    fdtemp(IEAEXIO.transportfuels.bio) = gr * fdtemp(IEAEXIO.transportfuels.bio);
    % reallocation of 20% of the savings to electricity
    if IEAEXIO.transfueldiff > 0
        elecprodshares = fdtemp(elecprod)./repmat(sum(fdtemp(elecprod),1),length(elecprod),1);
        elecprodshares(isnan(elecprodshares)) = 0;
        elecprodshares(isinf(elecprodshares)) = 0;
        fdtemp(elecprod) = fdtemp(elecprod) + IEAEXIO.transfuelrealloc*repmat(IEAEXIO.transfueldiff,length(elecprod),1).*elecprodshares;
    end
    % for rescaling: the difference needs to be allocated to the no growth
    % calculate the difference. if positive it goes to construction. if
    % negative, everything is rescaled
    difffd = fdtemporigsum - sum(fdtemp);
    % add difference to construction demand 
    if difffd > 0
        % that the difference is a very small percentage of total construction
        % demand
        fdtemp(constructionprod) = natFDnew(constructionprod,(reg-1)*nfd+fdcat) + difffd;
    end
    if difffd < 0
        fdtemp = fdtemp + difffd * shareinnogr;
    end
    
    %checktemp = natFDnew(:,(reg-1)*nfd+fdcat) - fdtemp;
    natFDnew(:,(reg-1)*nfd+fdcat) = fdtemp;
    if isnan(sum(sum(natFDnew)))
        reg
    end
end
