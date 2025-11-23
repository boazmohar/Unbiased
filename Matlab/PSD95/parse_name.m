function [name, sex, EE] = parse_name(name, round)
    if nargin < 2
        round = 2;
    end
    disp(name)
    f = strsplit(name, '_');
    f = f{1};
    number = str2double(f(end));
    sex = f(1);
    name = sprintf('R%d_%c%d', round, sex, number);
    
    switch round
        case 2
        if number < 3
            EE = false;
        else
            EE = true;
        end
        case 3
            EE = true;
    end
end