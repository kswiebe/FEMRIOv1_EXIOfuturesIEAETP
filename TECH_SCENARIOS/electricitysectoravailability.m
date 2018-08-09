function [elecprodavailability,elecindavailability] = electricitysectoravailability(MRSUT,nreg,nind,nprod,elecind, elecprod)
    % product availability determined by the rowsum of the use table plus
    % final demand
    prodavailability = sum(MRSUT.mrbpdom + MRSUT.mrbpimp,2) + sum(MRSUT.mrbpdomfd + MRSUT.mrbpimpfd,2);
    % industry production determined by the column sum of use and va
    indavailability = sum(MRSUT.mrbpdom + MRSUT.mrbpimp,1) + sum(MRSUT.mrbpdomva,1);
    % matrices country by electricity technology
    elecprodavailability = zeros(nreg,size(elecprod,1));
    elecindavailability = zeros(nreg,size(elecind,1));
    for p = elecprod
        elecprodavailability(:,p-elecprod(1)+1) = prodavailability(p:nprod:end);
    end
    for i = elecind
        elecindavailability(:,i-elecind(1)+1) = indavailability(i:nind:end);
    end
end%funciton
