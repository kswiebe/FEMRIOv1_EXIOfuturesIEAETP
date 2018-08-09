%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% TECH SCENARIO: Electricity - Initializations: get electricity data from MRSUT
% Industries producing the technologies / product groups including the technologies
% 
% * MAE Machinery and equipment
% * EMA Electrcal machinery and apparatus

MAEind = 86; MAEprod = 118;
EMAind = 88; EMAprod = 120;
%% Electricity industries/products

elecind = 96:107; elecprod = 128:139;
%elecindRE = [99, 100, 102, 103, 104, 106];
elecindREindices = [4, 5, 5, 7, 7, 7, 8, 9, 11];

for year=startyear:endyear
    t = year-startyear+1;
    % column sum of use table + last row of VA, i.e. total VA
    for country = 1:nreg
        elecindcou = (country-1)*nind + elecind;
        % production of electricity industries in EUR
        ElecProdEURall(:,t,country) = sum(SUThist.MRUSE(:,elecindcou),1) + SUThist.MRVA(end,elecindcou); 
        % only of RE, wind and biomass have several RE categories but only one industry each
        RenEnTechSUT.ElecProdEUR(:,t,country) = ElecProdEURall(elecindREindices,t,country);
    end
end
for c=1:nreg
    c1=(c-1)*size(RenEnTechSUT.ElecProdEUR,1)+1;
    c2=c*size(RenEnTechSUT.ElecProdEUR,1);
    RenEnTechSUT.ElecProdEURmatrix(c1:c2,:) = RenEnTechSUT.ElecProdEUR(:,:,c);
end
clear ElecProdEURall;
clear elecindcou;
clear c; clear c1; clear c2; clear country;
