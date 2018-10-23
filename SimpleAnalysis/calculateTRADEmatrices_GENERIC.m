function [results] = calculateTRADEmatrices_GENERIC(EXIOfuturepath,scenarioname,year,nreg,nind,nfd,char,couagg,AggConcregionaggrt)

load([EXIOfuturepath,scenarioname,'\final_IOT_',num2str(year),'_ixi.mat']);

[L, Ydiag, EXPdiag] = prepIOdata(IO.A,IO.Y,IO.x,nreg,nind,nfd);
LYdiag = L*Ydiag;


disp(['Calculating pxp trade matrices...'])
trade_pxp = calctradematrix_pxp(LYdiag,IO.S,char,nreg,nind);

% prod and cons to country
disp(['Aggregation to cxc trade matrices...'])
trade_cxc = aggregate_pxp2cxc(trade_pxp,couagg);
% prod and cons to regions
disp(['Aggregation to rxr trade matrices...'])
trade_rxr = aggregate_pxp2cxc(trade_cxc,AggConcregionaggrt);

results.trade_pxp = trade_pxp;
results.trade_cxc = trade_cxc;
results.trade_rxr = trade_rxr;


end