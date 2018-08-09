%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% Stressor selection

% Domestic extraction used
% totals
DEUfos = 724:734;
DEUmet = 736:747;
% fossil fuels
DEUcoal = [724, 725, 727, 731, 733, 734];
DEUoil = [726, 730, 732];
DEUgas = [728, 729];
% metals
%DEUiron = 739;
DEUnfm = [736:738, 740:747];

% Unused domestic extraction
% totals
UDEfos = 1114:1122;
UDEmet = 1124:1135;
% fossil fuels
UDEcoal = [1114, 1115, 1117, 1120:1122];
UDEoil = 1116;
UDEgas = [1118, 1119];
% metals
%UDEiron = 1127;
UDEnfm = [1124:1126, 1128:1135];

% Used and unused domestic extraction
% totals
DEfos = [DEUfos, UDEfos];
DEmet = [DEUmet, UDEmet];
% fossil fuels
DEcoal = [DEUcoal, UDEcoal];
DEoil = [DEUoil, UDEoil];
DEgas = [DEUgas, UDEgas];
% metals
%DEiron = [DEUiron, UDEiron];
DEnfm = [DEUnfm, UDEnfm];

% characterization matrix
%charfos = zeros(4*3,length(meta.labsF));
% charfos(1,DEfos) = 1;
% charfos(2,DEcoal) = 1;
% charfos(3,DEoil) = 1;
% charfos(4,DEgas) = 1;
% charfos(5,DEUfos) = 1;
% charfos(6,DEUcoal) = 1;
% charfos(7,DEUoil) = 1;
% charfos(8,DEUgas) = 1;
% charfos(9,UDEfos) = 1;
% charfos(10,UDEcoal) = 1;
% charfos(11,UDEoil) = 1;
% charfos(12,UDEgas) = 1;
charfos = zeros(4,length(meta.labsF));
% charfos(1,DEUfos) = 1;
% charfos(2,DEUcoal) = 1;
% charfos(3,DEUoil) = 1;
% charfos(4,DEUgas) = 1;
charfos(1,DEfos) = 1;
charfos(2,DEcoal) = 1;
charfos(3,DEoil) = 1;
charfos(4,DEgas) = 1;

% metals
%charmet = zeros(14*3,length(meta.labsF));
% charmet(1,DEmet) = 1;
% charmet(2,DEnfm) = 1;
% charmet(3:14,DEUmet) = eye(length(DEUmet));
% charmet(3:14,UDEmet) = eye(length(UDEmet));
% charmet(15,DEUmet) = 1;
% charmet(16,DEUnfm) = 1;
% charmet(17:28,DEUmet) = eye(length(DEUmet));
% charmet(29,UDEmet) = 1;
% charmet(30,UDEnfm) = 1;
% charmet(31:42,UDEmet) = eye(length(UDEmet));
charmet = zeros(14,length(meta.labsF));
% charmet(1,DEUmet) = 1;
% charmet(2,DEUnfm) = 1;
% charmet(3:14,DEUmet) = eye(length(DEUmet));
charmet(1,DEmet) = 1;
charmet(2,DEnfm) = 1;
charmet(3:14,DEUmet) = eye(length(DEUmet));
charmet(3:14,UDEmet) = eye(length(UDEmet));
% emissions
charCO2 = zeros(1,length(meta.labsF));
charCO2(CO2index) = 1;