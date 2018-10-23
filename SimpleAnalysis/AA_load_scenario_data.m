%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe 

%% initializations
run('EXIOfutures_init.m');
addpath('SimpleAnalysis');
%% SCRIPT FOR loading result data and calculating prices
year=2014;
scenarioname = 'EXIOhist';
load([EXIOfuturepath,scenarioname,'\final_IOT_',num2str(year),'_ixi.mat']);
L = inv(eye(size(IO.A)) - IO.A); 
vs = sum(IO.V,1)./IO.x';
vs(isnan(vs)) = 1;
vs(isinf(vs)) = 1;
vs2014=vs;
p2014 = vs * L; 

year=2030;
scenarioname = '2degrees';
load([EXIOfuturepath,scenarioname,'\final_IOT_',num2str(year),'_ixi.mat']);
L = inv(eye(size(IO.A)) - IO.A); 
vs = sum(IO.V,1)./IO.x';
vs(isnan(vs)) = 1;
vs(isinf(vs)) = 1;
vs20302ds=vs;
vs(vs>1) = 1;
p20302ds = vs * L; 
p20302ds_nr = vs20302ds * L;


year=2030;
scenarioname = '6degreesIter';
load([EXIOfuturepath,scenarioname,'\final_IOT_',num2str(year),'_ixi.mat']);
L = inv(eye(size(IO.A)) - IO.A); 
vs = sum(IO.V,1)./IO.x';
vs(isnan(vs)) = 1;
vs(isinf(vs)) = 1;
vs20306ds=vs;
vs(vs>1) = 1;
p20306ds = vs * L; 
p20306ds_nr = vs20306ds * L;

%% plot prices
figure()
plot(1:7987,p2014,'*',1:7987,p20302ds,'o',1:7987,p20302ds_nr,'x',1:7987,p20306ds,'+')
legend({'p2014';'p20302ds';'p20302ds_nr';'p20306ds'})
ylim([0,100])
ylim([0.995,1.01])
figure()
subplot(1,3,1)
boxplot(p2014)
subplot(1,3,2)
boxplot(p20302ds)
subplot(1,3,3)
boxplot(p20306ds)

min([p2014,p20302ds_nr,p20306ds_nr])
max([p2014,p20302ds_nr,p20306ds_nr])
edges = [0 0.99:0.02:1.01 2];
figure()
subplot(1,3,1)
histogram(p2014,edges)
title('Prices in 2014')
subplot(1,3,2)
histogram(p20302ds_nr,edges)
title('Prices in 2030 (2deg)')
subplot(1,3,3)
histogram(p20306ds_nr,edges)
title('Prices in 2030 (6degIter)')

% x = randn(1000,1);
% edges = [-10 -2:0.25:2 10];
% h = histogram(x,edges);

length(find(p20302ds(p20302ds>2))) % 39
length(find(p20302ds(p20302ds_nr>2))) % 55
length(find(p20302ds(p20302ds>1.01))) % 57
length(find(p20302ds(p20302ds_nr>1.01))) % 70 < 1% of observations
length(find(p20302ds(p20302ds_nr<0.99))) % 2
length(find(p2014(p2014>1.00001))) % 39

figure()
subplot(2,1,1)
plot(1:7987,p2014,'*',1:7987,p20302ds,'o',1:7987,sum(IO.A,1),'x')
legend({'p2014';'p20302ds';'sumA'})
ylim([0.99,1.03]);
subplot(2,1,2)
plot(1:7987,vs2014,'*',1:7987,vs20302ds,'o',1:7987,vs20302ds-vs2014,'x')
ylim([-10,10])
legend({'vs2014';'vs20302ds';'diff'});

%% find industries
p20302ds_rect = reshape(p20302ds,nind,nreg);
figure()
%HeatMap(p20302ds_rect)
heatmap(p20302ds_rect)
title('Prices 2030 2deg')


p2014_rect = reshape(p2014,nind,nreg);
figure()
%HeatMap(p2014_rect)
heatmap(p2014_rect)
title('Prices 2014')

vs2014_rect = reshape(vs2014,nind,nreg);
figure()
%HeatMap(p2014_rect)
heatmap(vs2014_rect)
title('VA share 2014')
plot(vs2014_rect,'*')