function Intervals = getIntervals()
%%  intervals of pulse and chanse 
% map each animals to the interval of injections: 
% first is 552 out of 552 + 669
% Second is 552+669 out of 552+669+608
% third is 669 out of 552+669+608
Intervals = containers.Map();
Intervals('460140') = [1,192,193];
Intervals('460141') = [2,72,74];
Intervals('473364') = [10,64,74];
Intervals('473365') = [53,64,117];
Intervals('473366') = [22,96,118];
end

