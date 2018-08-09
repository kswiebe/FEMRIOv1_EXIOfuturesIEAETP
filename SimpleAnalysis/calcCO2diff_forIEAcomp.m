function [CO2diff] = calcCO2diff_forIEAcomp(results2deg_co2trade_cxc,results6deg_co2trade_cxc)

CO2prod2deg = sum(results2deg_co2trade_cxc);
CO2prod6deg = sum(results6deg_co2trade_cxc);
CO2diff(1) = sum(CO2prod2deg)/sum(CO2prod6deg)-1;
CO2diff(2) = CO2prod2deg(34)/CO2prod6deg(34)-1;
CO2diff(3) = CO2prod2deg(31)/CO2prod6deg(31)-1;
CO2diff(4) = sum(CO2prod2deg(1:28))/sum(CO2prod6deg(1:28))-1;
CO2diff(5) = CO2prod2deg(35)/CO2prod6deg(35)-1;
CO2diff(6) = CO2prod2deg(36)/CO2prod6deg(36)-1;
CO2diff(7) = CO2prod2deg(37)/CO2prod6deg(37)-1;
CO2diff(8) = CO2prod2deg(44)/CO2prod6deg(44)-1;
CO2diff(9) = CO2prod2deg(29)/CO2prod6deg(29)-1;

end