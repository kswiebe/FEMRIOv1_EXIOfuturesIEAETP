function [cons_t,prod_t] = calculateConsProd(trade_rxr,reg)
cons_t = sum(squeeze(trade_rxr(:,reg,:)),1)';  
prod_t = sum(squeeze(trade_rxr(reg,:,:)),1)'; 
end