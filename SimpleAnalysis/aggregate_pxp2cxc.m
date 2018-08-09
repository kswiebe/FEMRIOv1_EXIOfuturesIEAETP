function trade_cxc = aggregate_pxp2cxc(pxp,couagg)
    % works on pxp to cxc
    % but also on cxc to region aggregates

    trade_cxc = zeros(size(couagg,1),size(couagg,1),size(pxp,3));
    
    for c = 1:size(pxp,3)
        trade_cxc(:,:,c) = couagg * pxp(:,:,c) * couagg';
    end

end