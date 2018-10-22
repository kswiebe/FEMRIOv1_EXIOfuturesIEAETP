function [results] = calculateTRADEmatrices(EXIOfuturepath,scenarioname,year,nreg,nind,nfd,char,couagg,AggConcregionaggrt)

load([EXIOfuturepath,scenarioname,'\final_IOT_',num2str(year),'_ixi.mat']);

[L, Ydiag, EXPdiag] = prepIOdata(IO.A,IO.Y,IO.x,nreg,nind,nfd);
LYdiag = L*Ydiag;
LEXPdiag = L*EXPdiag;

disp(['Calculating embodied fossil fuel trade matrices...'])
fostrade_pxp = calctradematrix_pxp(LYdiag,IO.S,charfos,nreg,nind);
fosexp_pxp = calctradematrix_pxp(LEXPdiag,IO.S,charfos,nreg,nind);
disp(['Calculating embodied metals trade matrices...'])
mettrade_pxp = calctradematrix_pxp(LYdiag,IO.S,charmet,nreg,nind);
metexp_pxp = calctradematrix_pxp(LEXPdiag,IO.S,charmet,nreg,nind);
disp(['Calculating embodied emissions trade matrices...'])
co2trade_pxp = calctradematrix_pxp(LYdiag,IO.S,charCO2,nreg,nind);

% prod and cons to country
fostrade_cxc = aggregate_pxp2cxc(fostrade_pxp,couagg);
mettrade_cxc = aggregate_pxp2cxc(mettrade_pxp,couagg);
co2trade_cxc = aggregate_pxp2cxc(co2trade_pxp,couagg);
% prod and cons to regions
fostrade_rxr = aggregate_pxp2cxc(fostrade_cxc,AggConcregionaggrt);
mettrade_rxr = aggregate_pxp2cxc(mettrade_cxc,AggConcregionaggrt);
co2trade_rxr = aggregate_pxp2cxc(co2trade_cxc,AggConcregionaggrt);
%fostrade_rxr
%mettrade_rxr
%co2trade_rxr

% exports to country level
fosexp_cxc = aggregate_pxp2cxc(fosexp_pxp,couagg);
metexp_cxc = aggregate_pxp2cxc(metexp_pxp,couagg);
% exports to region level
fosexp_rxr = aggregate_pxp2cxc(fosexp_cxc,AggConcregionaggrt);
metexp_rxr = aggregate_pxp2cxc(metexp_cxc,AggConcregionaggrt);


results.fostrade_cxc = fostrade_cxc;
results.mettrade_cxc = mettrade_cxc;
results.co2trade_cxc = co2trade_cxc;
results.fostrade_rxr = fostrade_rxr;
results.mettrade_rxr = mettrade_rxr;
results.co2trade_rxr = co2trade_rxr;
results.fosexp_rxr = fosexp_rxr;
results.metexp_rxr = metexp_rxr;


end