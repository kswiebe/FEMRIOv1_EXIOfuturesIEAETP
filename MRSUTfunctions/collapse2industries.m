function result = collapse2industries(matrix,dim1,dim2,nind)
    % either one of dim1 or dim2 or both need to be nind
    % if one of those is not nind, then that size is kept
    
    temp1 = zeros(dim1,size(matrix,2));
    temp2 = zeros(dim1,dim2);
    % collapse first dimension
    if dim1 == nind
        for d1 = 1:dim1
            temp1(d1,:) = sum(matrix(d1:nind:end,:),1);
        end
    else
        temp1 = matrix;
    end
    if dim2 == nind
        for d2 = 1:dim2
            temp2(:,d2) = sum(temp1(:,d2:nind:end),2);
        end
    else
        temp2 = temp1;
    end
    result = temp2;
end