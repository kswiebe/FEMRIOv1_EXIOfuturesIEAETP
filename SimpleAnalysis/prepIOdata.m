function [L, Ydiag, EXPdiag] = prepIOdata(A,Y,x,nreg,nind,nfd)
    L = inv(eye(size(A)) - A);
    
    % calculate diagonalized final demand
    Ydiag = zeros(nreg*nind,nreg*nind); % product*regions x product*regions
    for r = 1:nreg
        fd1 = (r-1)*nfd+1;
        fd2 = r*nfd;
        c1 = (r-1)*nind+1;
        c2 = r*nind;
        Ytemp = sum(Y(:,fd1:fd2),2);
        for rr = 1:nreg
            r1 = (rr-1)*nind+1;
            r2 = rr*nind;
            Ydiag(r1:r2,c1:c2) = diag(Ytemp(r1:r2));
        end
    end
    
    % calculate exports
    % intermediate exports
    Z = A*diag(x);
    % exp incl to domestic
    intexp = sum(Z,2); %intermediate
    fdexp = sum(Y,2);
    % need to subtract domestic
    for r = 1:nreg
        fd1 = (r-1)*nfd+1;
        fd2 = r*nfd;
        c1 = (r-1)*nind+1;
        c2 = r*nind;
        intexp(c1:c2) = intexp(c1:c2) - sum(Z(c1:c2,c1:c2),2);
        fdexp(c1:c2) = fdexp(c1:c2) - sum(Y(c1:c2,fd1:fd2),2);
    end
    EXPdiag = diag(intexp + fdexp);
    
end % prepIOdata