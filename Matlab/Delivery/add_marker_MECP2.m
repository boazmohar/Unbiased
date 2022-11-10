function current = add_marker_MECP2(current)
names = {};
colors = {};
for i = 1:height(current.dye_table)
    
    switch  current.dye_table.Dye(i)
        case 669
            dye_name = 'JF669';
            color='Magenta';
        case 612
            dye_name = 'SF612';
            color='b';
        case 608
            dye_name = 'JF608';
            color='b';
        case 609
            dye_name = 'JFx608';
            color='b';
        case 552
            dye_name = 'JF552';
            color='Red';
        case 541
            dye_name = 'JF541';
            color='b';
        case 559
            dye_name = 'JF559';
            color='b';
        case 533
            dye_name = 'JF533';
            color='b';
        case 646
            dye_name = 'JF646Bio';
            color='b';
        case 570
            dye_name = 'JF570';
            color='b';
        case 585
            dye_name = 'JF585';
            color='y';
        case 525
            dye_name = 'JF525';
            color='g';
        case 0
            dye_name = 'Blank';
            color='k';
            
    end
    names(i) = {dye_name};
    colors(i) = {color};
end
%%
current.dye_table.Names = names';
current.dye_table.Colors = colors';
%%
disp(current.ANM)
current.dye_table

