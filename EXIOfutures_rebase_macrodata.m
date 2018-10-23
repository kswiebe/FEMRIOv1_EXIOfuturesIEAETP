% This is necessary because we want to run the future model in 2014 prices
% based on the current price tables as the constant price EXIOBASE 3.6 does not yet make sense

%MacroDataCons
%MacroDataCurr

%MacroData_cell = struct2cell(MacroData);

MacroDataCons_cell = struct2cell(MacroDataCons);
MacroDataCurr_cell = struct2cell(MacroDataCurr);
MacroData_cell = MacroDataCurr_cell;
for f = 1:size(MacroData_cell,1)
    % calculate 2014price = current/constant
    prices2014 = MacroDataCurr_cell{f}(:,end) ./ MacroDataCons_cell{f}(:,end);
    % then rebase by constantnew = constant*2014price
    MacroData_cell{f} = MacroDataCons_cell{f} .* repmat(prices2014,1,size(MacroData_cell{1},2));
    MacroData_cell{f}(isnan(MacroData_cell{f})) = 0.0001;
    MacroData_cell{f}(isinf(MacroData_cell{f})) = 0.0001;
end
MacroData = cell2struct(MacroData_cell,fields(MacroData),1);
