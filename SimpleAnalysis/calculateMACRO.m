function [VA,VAlong] = calculateMACRO(IO,nreg,nind,nfd)
    
    VAlong = sum(IO.V);
    VA = zeros(1,nreg);
    for c = 1:nreg
        c1 = (c-1)*nind+1;
        c2 = c*nind;
        VA(1,c) = sum(VAlong(c1:c2));
    end
    
    
end