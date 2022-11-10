function data = add_marker(data)

switch data.Round
    case 0
        data.marker = 'h';
    case 2
        data.marker = 'v';
    case 3
        data.marker = 'd';
    case 5
        data.marker = 'o';
    case 6
        data.marker = 's';
    case 7
        data.marker = '^';
    case 8
        data.marker = 'p';
    case 10
        data.marker = '<';
    case 11
        data.marker = '>';
end
switch data.invivo_dye
    case 669
        data.dye_name = 'JF669';
        data.color='Magenta';
    case 612
        data.dye_name = 'SF612';
        data.color='b';
    case 608
        data.dye_name = 'JF608';
        data.color='b';
    case 609
        data.dye_name = 'JFx608';
        data.color='b';
    case 552
        data.dye_name = 'JF552';
        data.color='Red';
    case 541
        data.dye_name = 'JF541';
        data.color='b';
    case 559
        data.dye_name = 'JF559';
        data.color='b';
    case 533
        data.dye_name = 'JF533';
        data.color='b';
    case 646
        data.dye_name = 'JF646Bio';
        data.color='b';
    case 570
        data.dye_name = 'JF570';
        data.color='b';
    case 585
        data.dye_name = 'JF585';
        data.color='y';
    case 525
        data.dye_name = 'JF525';
        data.color='g';
    case 0
        data.dye_name = 'Blank';
        data.color='k';
        
end
% if data.v
switch data.virus_name
    case 'GFP'
        data.virus_index = 1;
        if data.invivo_dye > 600
            data.invivo_index = 3;
            data.exvivo_index = 2;
        else
            data.invivo_index = 2;
            data.exvivo_index = 3;
            
        end
    case 'mRuby'
        data.virus_index = 2;
        if data.invivo_dye > 600
            data.invivo_index = 3;
            data.exvivo_index = 1;
        else
            data.invivo_index = 1;
            data.exvivo_index = 3;
            
        end
    case 'None'
        data.virus_index = 1;
        data.invivo_index = 3;
        data.exvivo_index = 2;
    otherwise
        error('Wrong virus name')
end
fprintf('Virus: %s-->%d:%s, invivo: %d-->%d:%s, exvivo: %d-->%d:%s\n',  ...
    data.virus_name, data.virus_index, data.Ch_Names{data.virus_index}, ...
    data.invivo_dye, data.invivo_index,data.Ch_Names{data.invivo_index}, ...
    data.exvivo_dye, data.exvivo_index, data.Ch_Names{data.exvivo_index});
if strfind(data.cond, 'double')  | strfind(data.cond, ',')
    data.double = 1;
else
    data.double = 0;
end

