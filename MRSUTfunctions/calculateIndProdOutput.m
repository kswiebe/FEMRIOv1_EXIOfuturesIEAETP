function [guse,quse] = calculateIndProdOutput(MRUSE,MRSUP,MRVA,MRFD)
    %MRVAttl(MRVAttl<0) = 0;
    % total industry output g
    gsup = sum(MRSUP,1);
    guse = sum(MRUSE,1) + sum(MRVA,1);
    disp(['Difference industry output use - supply: ',num2str(sum(gsup-guse))]);
    % total product output q
    qsup = sum(MRSUP,2);
    quse = sum(MRUSE,2) + sum(MRFD,2);
    disp(['Difference product output use - supply: ',num2str(sum(qsup-quse))]);
end