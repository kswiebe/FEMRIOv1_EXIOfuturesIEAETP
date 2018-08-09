%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe
%% change shares of electricity consumption according to IEAEPT scenario

function newelectricitydemand = changeElecConsShare(nataggr,IEAshares,nreg,width,elecind,t)
newelectricitydemand = nataggr;  %where nataggr is natUSEcoefB or natFD
for r = 1:nreg
    r1 = (r-1)*width+1; %where width is nind or nfd
    r2 = r*width;
    tempsum = sum(nataggr(elecind,r1:r2),1);
    newelectricitydemand(elecind,r1:r2) = repmat(tempsum,size(elecind,2),1) .* repmat(IEAshares(:,t,r),1,width);
end

end