%% FEMRIO version1: EXIOfuturesIEAETP
% by Kirsten S. Wiebe

%%Plots of results until 2050
x=[1:(finalyear-startyear+1)];

%% demand side
figure()
subplot(2,4,1)
hold on    
for reg = selectedregions
    plot(x,MacroData.HOUS(reg,:));
end
title('Household consumption expenditure ');
hold off
set(gca,'Xtick',5:10:(finalyear-startyear+1))
set(gca,'XtickLabel',2000:10:finalyear)
subplot(2,4,2)
hold on    
for reg = selectedregions
    plot(x,MacroData.NPSH(reg,:));
end
title('NPSH consumption expenditure ');
hold off
set(gca,'Xtick',5:10:(finalyear-startyear+1))
set(gca,'XtickLabel',2000:10:finalyear)
subplot(2,4,3)
hold on    
for reg = selectedregions
    plot(x,MacroData.GOVE(reg,:));
end
title('Government consumption expenditure ');
hold off
set(gca,'Xtick',5:10:(finalyear-startyear+1))
set(gca,'XtickLabel',2000:10:finalyear)
subplot(2,4,4)
hold on    
for reg = selectedregions
    plot(x,MacroData.GFCF(reg,:));
end
title('Gross fixed capital formation ');
%legend(regionnames,'Location','northwest');
hold off
set(gca,'Xtick',5:10:(finalyear-startyear+1))
set(gca,'XtickLabel',2000:10:finalyear)

%% supply side
subplot(2,4,5)
hold on    
for reg = selectedregions
    plot(x,MacroData.TAX(reg,:));
end
title('Taxes and subsidies ');
hold off
set(gca,'Xtick',5:10:(finalyear-startyear+1))
set(gca,'XtickLabel',2000:10:finalyear)
subplot(2,4,6)
hold on    
for reg = selectedregions
    plot(x,MacroData.WAGE(reg,:));
end
title('Compensation of employees ');
hold off
set(gca,'Xtick',5:10:(finalyear-startyear+1))
set(gca,'XtickLabel',2000:10:finalyear)
subplot(2,4,7)
hold on    
for reg = selectedregions
    plot(x,MacroData.NOS(reg,:));
end
title('Net operating surplus ');
hold off
set(gca,'Xtick',5:10:(finalyear-startyear+1))
set(gca,'XtickLabel',2000:10:finalyear)
subplot(2,4,8)
hold on 
for reg = selectedregions
    plot(x,MacroData.GDPTR(reg,:));
end
title(['GDPTR (',scenarioname,')']);
set(gca,'Xtick',5:10:(finalyear-startyear+1))
set(gca,'XtickLabel',2000:10:finalyear)
legend(regioncodes(selectedregions),'Location','northwest');
%for reg = selectedregions
%    plot(x,MacroData.GDPTRshouldbe(reg,:),'--');
%end
hold off

%% store data in excel file

xlswrite([scenariopath,'MacroResultsselreg.xlsx'],1995:1:finalyear,['MacroResults'],'C1');

xlswrite([scenariopath,'MacroResultsselreg.xlsx'],'GDPTRshouldbe',['MacroResults'],'A2');
xlswrite([scenariopath,'MacroResultsselreg.xlsx'],regionnames(selectedregions),['MacroResults'],'B2');
xlswrite([scenariopath,'MacroResultsselreg.xlsx'],MacroData.GDPTRshouldbe(selectedregions,:),['MacroResults'],'C2');

xlswrite([scenariopath,'MacroResultsselreg.xlsx'],'GDPTR',['MacroResults'],'A8');
xlswrite([scenariopath,'MacroResultsselreg.xlsx'],regionnames(selectedregions),['MacroResults'],'B8');
xlswrite([scenariopath,'MacroResultsselreg.xlsx'],MacroData.GDPTR(selectedregions,:),['MacroResults'],'C8');

xlswrite([scenariopath,'MacroResultsselreg.xlsx'],'DFD',['MacroResults'],'A14');
xlswrite([scenariopath,'MacroResultsselreg.xlsx'],regionnames(selectedregions),['MacroResults'],'B14');
xlswrite([scenariopath,'MacroResultsselreg.xlsx'],MacroData.DFD(selectedregions,:),['MacroResults'],'C14');
