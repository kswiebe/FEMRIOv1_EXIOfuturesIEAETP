function [MRUSEcoefB,VAcoef] = rescale_MRUSEB_VAcoef_to_one(MRUSEcoefB,VAcoef,nreg,nind,relVA)
% works for both MRUSE and natUSE
    % make sure that USE coef + relevant VAcoef relVA=[1 4 6:12] add up to 1
    for i = 1:(nreg*nind)
        temp = (sum(MRUSEcoefB(:,i)) + sum(VAcoef(relVA,i)));
        if (temp < 0.9999 & temp > 0) | temp > 1.0001
            j = mod(i,nind);
            c = (i-j)/nind + 1;
            disp(['coef sums to ',num2str(temp),' for country ',num2str(c),' industry ',num2str(j),' lfd nummer ',num2str(i)])
            MRUSEcoefB(:,i) = MRUSEcoefB(:,i)/temp;
            VAcoef(:,i) = VAcoef(:,i)/temp;
        end
    end
end