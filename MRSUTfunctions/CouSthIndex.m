function cx = CouSthIndex(country,something,nsth)
% something can be the industry / product / FD category number
% nsth is the total number of industries / products / FD categories
    cx=(country-1)*nsth+something;
end