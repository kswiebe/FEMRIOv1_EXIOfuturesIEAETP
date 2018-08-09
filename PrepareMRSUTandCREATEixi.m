%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%% Converts the SUT format into the EXIOBASE3 MRSUT and MRIOT format
% called from EXIOfutures_projection



%% Creating MRIO tables:
tmp_mruse=[MRSUT.mrbpdom+MRSUT.mrbpimp,MRSUT.mrbpdomfd+MRSUT.mrbpimpfd];
tmp_mruse=[tmp_mruse;MRSUT.mrbpdomva,zeros(size(MRSUT.mrbpdomva,1),size(MRSUT.mrbpdomfd,2))];
tic
[IO.S,IO.A,~,IO.V,IO.Y,IO.x,IO.FY]=CreateMRIOT_ixi_v2(MRSUT.mrsup,tmp_mruse);


toc
IO.meta = MRSUT.meta;

% this is just a nice plot to check whether all coefficients sum up to one
% or less
figure()
plot(1:7987,sum(IO.A),'*')

if sum(IO.x)>1e10
    disp('rebasing from EUR to M.EUR')
    IO.x=IO.x*1e-6;
    IO.V=IO.V*1e-6;
    IO.Y=IO.Y*1e-6;
    IO.FY=IO.FY*1e-6;
end

% load meta info for impact categories
toc
%set dimensions:
IO.F=zeros(size(Extensions.S));
IO.S=zeros(size(Extensions.S));
% IO.F=zeros(isnan(IO.F));
% IO.F_fd=zeros(size(stressor_names,1),meta.Ydim);


IO.meta.secLabsF = Extensions.labsF;
IO.meta.secLabsC = Extensions.labsC;
VAforExtensions = [1 4 6:8 9:12];
IO.F(1:9,:) = IO.V(VAforExtensions,:);
IO.F(10:end,:) = 1e6 * Extensions.S(10:end,:).*repmat(IO.x',size(Extensions.S(10:end,:),1),1);
IO.S(1:9,:) = IO.F(1:9,:)./repmat(IO.x',9,1);
IO.S(10:end,:) = 1e6 * Extensions.S(10:end,:);
IO.S_fd = 1e6 * Extensions.S_fd;
IO.S(isnan(IO.S))=0;
IO.S(isinf(IO.S))=0;
IO.char = Extensions.char;

IO.x(isnan(IO.x))=0;