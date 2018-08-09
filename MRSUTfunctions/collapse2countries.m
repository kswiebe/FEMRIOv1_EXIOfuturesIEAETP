function result = collapse2countries(matrix,dim1,dim2,nind,nreg)
    % either one of dim1 or dim2 or both need to be nreg
    % if one of those is not nreg, then that size is kept
    
    temp1 = zeros(dim1,size(matrix,2));
    temp2 = zeros(dim1,dim2);
    % collapse first dimension
    if dim1 == nreg
        for d1 = 1:dim1
            dd1 = (d1-1)*nind+1;
            dd2 = d1*nind;
            temp1(d1,:) = sum(matrix(dd1:dd2,:),1);
        end
    else
        temp1 = matrix;
    end
    if dim2 == nreg
        for d2 = 1:dim2
            dd1 = (d2-1)*nind+1;
            dd2 = d2*nind;
            temp2(:,d2) = sum(temp1(:,dd1:dd2),2);
        end
    else
        temp2 = temp1;
    end
    result = temp2;
end