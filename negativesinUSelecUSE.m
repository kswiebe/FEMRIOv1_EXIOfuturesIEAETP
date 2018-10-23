%X:\indecol\Projects\DESIRE\wp5_eeio\const_time_series\MRSUT\processed
load('MRSUT_2014.mat')
MRuse = MRSUT.mrbpdom + MRSUT.mrbpimp;
USAuse = MRSUT.mrbpdom(:,4565:4727) + MRSUT.mrbpimp(:,4565:4727);
USAnatuse = zeros(200,163);
MRnatuse = zeros(200,7987);
for r = 1:49
    r1 = (r-1)*200+1;
    r2 = r*200;
    USAnatuse = USAnatuse + USAuse(r1:r2,:);
    MRnatuse = MRnatuse + MRuse(r1:r2,:);
end
min(min(MRnatuse))
%-1.2733e+09
[row,col,~] = find(MRnatuse == min(min(MRnatuse)) )
% row =
% 
%    119
% 
% 
% col =
% 
%         4699
% 
% 4699/163
% 
% ans =
% 
%    28.8282
% 
% 0.8282*163
% 
% ans =
% 
%   134.9966
% ==> "office machinery and computer" inputs into "other business activities" in the US = -1.2733e+09

% electricity industries starting from column 96, to construction 113
USAnatuse(62:75,96:113)
% product inputs
% 62	'Paper and paper products'
% 63	'Printed matter and recorded media (22)'
% 64	'Coke Oven Coke'
% 65	'Gas Coke'
% 66	'Coal Tar'
% 67	'Motor Gasoline'
% 68	'Aviation Gasoline'
% 69	'Gasoline Type Jet Fuel'
% 70	'Kerosene Type Jet Fuel'
% 71	'Kerosene'
% 72	'Gas/Diesel Oil'
% 73	'Heavy Fuel Oil'
% 74	'Refinery Gas'
% 75	'Liquefied Petroleum Gases (LPG)'
% 
%    -0.0004   -0.0003   -0.0003   -0.0001   -0.0000         0   -0.0000         0         0         0         0         0   -0.0002   -0.0007   -0.0001         0   -0.0000    0.2570
%    -0.0000   -0.0000   -0.0000   -0.0000         0         0         0         0         0         0         0         0   -0.0000   -0.0000   -0.0000         0   -0.0000    0.0034
%          0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0
%          0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0
%          0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0
%    -0.0002   -0.0003   -0.0002   -0.0001   -0.0001    0.0000   -0.0001    0.0000         0         0   -0.0000         0   -0.0001   -0.0005   -0.0000         0   -0.0001    0.1115
%          0    0.0000         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0    0.0000
%          0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0
%    -0.0000   -0.0000   -0.0000   -0.0000   -0.0000         0   -0.0000         0         0         0         0         0   -0.0000   -0.0000    0.0000         0   -0.0000    0.0033
%    -0.0001   -0.0001   -0.0000   -0.0000   -0.0000    0.0001   -0.0000         0         0         0         0         0   -0.0000   -0.0000         0         0         0         0
%    -0.0026   -0.0028   -0.0004   -0.0008   -0.0004    0.0003   -0.0002    0.0002    0.0002         0   -0.0001    0.0002   -0.0007   -0.0042   -0.0000         0   -0.0005    1.3354
%    -0.0070   -0.0043   -0.0021   -0.0021   -0.0004    0.0119   -0.0001    0.0000         0         0   -0.0000    0.0000   -0.0024   -0.0034         0    0.0000   -0.0002         0
%          0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0         0
%    -0.0049   -0.0044   -0.0008   -0.0004   -0.0001    0.0009   -0.0000    0.0000         0         0    0.0000    0.0000   -0.0007   -0.0068   -0.0025         0   -0.0000    0.0016