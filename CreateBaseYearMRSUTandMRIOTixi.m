%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe 

%% Converts the SUT format into the EXIOBASE3 MRSUT and MRIOT format for the baseyear 2014
% called from EXIOfutures_part2


    year = endyear;
    scenarioname = 'EXIOhist';
    mrio_result_path = ['futures\',scenarioname,'\'];

    [MRSUT] = createEXIOBASEMRSUT(SUThist,nreg,nprod,nind,nfd,nva);
    %[guse,quse] = calculateIndProdOutput(SUThist.MRUSE,SUThist.MRSUP',SUThist.MRVA(1:nva,:),SUThist.MRFD);
    save([mrio_result_path,'MRSUT_',num2str(year),'.mat'],'MRSUT','-v7.3');
    Extensions.S = SUThist.S;
    Extensions.S_fd = SUThist.S_fd;
    Extensions.char = SUThist.char;
    Extensions.labsF = SUThist.Extensions.labsF;
    Extensions.labsC = SUThist.Extensions.labsC;
    save([mrio_result_path,'Extensions_',num2str(year),'_ixi.mat'],'Extensions','-v7.3');

    load([mrio_result_path,'MRSUT_',num2str(year),'.mat']);
    load([mrio_result_path,'Extensions_',num2str(year),'_ixi.mat']);
    %projectpath = 'X:\indecol\Projects\ILO_Scenarios\Analysis\'; % is used in create_mriot_rebuildEXIOBASE3MATPack_ixi_oneyear_new.m
    run('PrepareMRSUTandCREATEixi.m');
    % name your file whatever you like
    meta = SUThist.meta;
    meta.labsF = Extensions.labsF;
    meta.labsC = Extensions.labsC;
    save([mrio_result_path,'final_IOT_',num2str(year),'_ixi.mat'], 'IO','meta');
    save([mrio_result_path,'meta.mat'], 'meta');