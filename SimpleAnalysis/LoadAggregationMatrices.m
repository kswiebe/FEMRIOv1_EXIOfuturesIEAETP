%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% Load aggregation matrices for analysis
% and make struct with all the aggregation and concordance and names
filenameagg = 'Aggregations.xlsx';
%AggConc.D = xlsread(filenameagg,'Aggreg_energ','C3:O165');
%[~,AggConc.Dnames] = xlsread(filenameagg,'Aggreg_energ','C2:O2');
AggConc.Dother = xlsread(filenameagg,'Aggreg_other','C3:N165');
[~,AggConc.Dothernames] = xlsread(filenameagg,'Aggreg_other','C2:N2');
AggConc.regionaggr = xlsread(filenameagg,'Aggreg_Region','C2:J50');
[~,AggConc.regionaggrnames] = xlsread(filenameagg,'Aggreg_Region','C1:J1');

% electricity industries
%AggConc.elec = 96:107;
%AggConc.elecnames = {'coal','gas','nuclear','hydro','wind','petroleum','biomass and waste','solar PV','solar thermal','tide,wave,ocean','geothermal','nec'};
%AggConc.exclelec = [1:(AggConc.elec(1)-1) (AggConc.elec(end)+1):nind];

AggConc.regioncodes =regioncodes;


% aggrnames
aggrnames.reg = AggConc.regionaggrnames;
aggrnames.cou = AggConc.regioncodes';
%aggrnames.ind = meta.secLabsZ.Name(1:nind)';
aggrnames.ind = meta.secLabsI.Name(1:nind)';
aggrnames.indaggr = AggConc.Dothernames;

couagg = zeros(nreg,nreg*nind);
for r = 1:nreg
    r1 = (r-1)*nind+1;
    r2 = r*nind;
    couagg(r,r1:r2) = 1;
end
