%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% Implementation of the PADS demand model
% called from EXIOfutures_projection

%% function called in every year
function [newExpEXIO,PADS] = implementationPADSmodel(t,nyears,nreg,nprod,HOUSpc,POPU,PADS,oldexp)
% PADS is a struct containing
% * the concordance matrix between pg product groups and nprod products
% * the time trend coefficient a(i,c) by product group i and country c
% * the expenditure coefficient b(i,c) by product group i and country c
% * the price adjustment term pc2014(i,c), which is constant as prices remain
% constant at 2014 prices

% PADS equation
% ypg(i,c) = ( at(i,c)*t + b(i,c)*HOUSpc(c,t) ) * (product_of_prices_2014(i,c)  )

% as the PADS is estimated for 21 product groups we'll calculate the growth
% rates for the 21 product groups and then drive all products of that group
% with the same growth rate
% the number of product groups might vary
pg = size(PADS.bridge,2);

% we need the estimated household expenditure per capita at the 21 product group level
%  from the previous year
ypg_tminus1 = zeros(pg,nreg);
for c = 1:nreg
    ypg_tminus1(:,c) = ( PADS.at(:,c)*(t-1) + PADS.b(:,c)*HOUSpc(c,t-1) ) .* (PADS.product_of_prices_2014(:,c)  );
end
%disp(['min(min(ypg_tminus1)) during PADS = ',num2str(min(min(ypg_tminus1)))])
%ypg_tminus1
% and from the current year
ypg_t = zeros(pg,nreg);
for c = 1:nreg
    ypg_t(:,c) = ( PADS.at(:,c)*(t) + PADS.b(:,c)*HOUSpc(c,t) ) .* (PADS.product_of_prices_2014(:,c)  );
end
%disp(['min(min(ypg_t)) during PADS = ',num2str(min(min(ypg_t)))])
%ypg_t
% calculate the growth rate as the ratio
ypg_gratio = ypg_t ./ ypg_tminus1;

% Some of the regressions result in negative estimates in 2014. For those
% countries/product groups, spending decreased over the past years or was 
% very close to zero.
% To not have negative spending, keep the 2014 value, i.e. set the growth
% rate ypg_gratio to 1
% determine those with a negative estimate in 2014
if t == nyears+1 %i.e. 2015
    PADS.negativestimates = (ypg_tminus1<0);
end
% for all years, set those growth rates to zero
ypg_gratio(PADS.negativestimates) = 1;

% household spending per capita and nprod products in previous year
yp_tminus1 = oldexp ./ repmat(POPU(:,t-1)',nprod,1);

% household spending per capita and nprod products in current year 
yp_t = zeros(nprod,nreg);
for c = 1:nreg
    yp_t(:,c) = yp_tminus1(:,c) .* (PADS.bridge * ypg_gratio(:,c));
end

% multiply with POPU to get total values, not only per capita
newExpEXIO = yp_t .* repmat(POPU(:,t)',nprod,1);
%disp(['min(min(newExpEXIO)) during PADS = ',num2str(min(min(newExpEXIO)))])

end


