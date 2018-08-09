% compare 2030 and 2014 final demand of households

load('C:\Users\kirstesw\Dropbox\EXIOfuturesJECS\futures\2degrees\final_IOT_2030_ixi.mat')
IO20302deg = IO;
load('C:\Users\kirstesw\Dropbox\EXIOfuturesJECS\futures\EXIOhist\final_IOT_2014_ixi.mat')
IO2014hist = IO;

nreg = 49;
nprod = 200;
nind = 163;
nfd=7;
HOUS2030 = zeros(nind,nreg);
HOUS2014 = zeros(nind,nreg);

for p = 1:nreg
    p1 = (p-1)*nind+1;
    p2 = nind*p;
    HOUS2030 = HOUS2030 + IO20302deg.Y(p1:p2,1:nfd:end);
    HOUS2014 = HOUS2014 + IO2014hist.Y(p1:p2,1:nfd:end);
end

ratio = HOUS2030./HOUS2014;