function [name, sex, group, age, line] = parse_name_glua2(name, round)
if nargin < 2
    round = 1;
end
disp(name)
f = strsplit(name, ' ');
slide = str2double(f{2});

switch round
    case 1
        %% 2 random and 2 rule round 1 BM / Tyra / Gabi training
        %bm6 518798 male slide 1,2
        %bm7 513832 male slide 4,5
        %bm8 513568 male slide 7,8
        %bm9 510158 male slide 10,11
        perfusion = datetime(2023, 6, 2);
        line = 1;
        switch slide
            case {1,2}
                name = 'BM6';
                sex = 'male';
                group = 'random';
                DOB = datetime(2022,12,02);
                age = between(DOB, perfusion, 'days');
              
            case {4,5}
                name = 'BM7';
                sex = 'male';
                group = 'random';
                DOB = datetime(2022,8,24);
                age = between(DOB, perfusion, 'days');
            case {7,8}
                name = 'BM8';
                sex = 'male';
                group = 'rule';
                DOB = datetime(2022,8,18);
                age = between(DOB, perfusion, 'days');
            case {10,11}
                name = 'BM9';
                sex = 'male';
                group = 'rule';
                DOB = datetime(2022,05,31);
                age = between(DOB, perfusion, 'days');
        end
    case 2
        %% control animals in homecage
        perfusion = datetime(2023, 7, 3);
        %  These are both 
        %C1 527210 male slide 1,2
        %C2 517803 female slide 4,5
        %C3 521815 male slide 7,8
        %C4 521817 female slide 10,11
        switch slide
            case {1,2}
                name = 'C1';
                sex = 'male';
                group = 'control';
                DOB = datetime(2023,04,20);
                age = between(DOB, perfusion, 'days');
                line = 1;
            case {4,5}
                name = 'C2';
                sex = 'female';
                group = 'control';
                DOB = datetime(2022,11,15);
                age = between(DOB, perfusion, 'days');
                line = 1;
            case {7,8}
                name = 'C3';
                sex = 'male';
                group = 'control';
                DOB = datetime(2023,01,24);
                age = between(DOB, perfusion, 'days');
                line = 4;
            case {10,11}
                name = 'C4';
                sex = 'female';
                group = 'control';
                DOB = datetime(2023,01,24);
                age = between(DOB, perfusion, 'days');
                line = 4;
        end
    case 3
        %  Negative controls and VH1 VH4
        %NC1 527211 male slide 1,2
        %NC2 517806 female slide 4,5
        %NC3 521816 male slide 7,8
        %NC4 521819 female slide 10,11
        %VH1 524913 female slide 13,14
        %VH4 520380 male slide 16,17
        switch slide
            case {1,2}
                perfusion = datetime(2023, 7, 3);
                name = 'NC1';
                sex = 'male';
                group = 'negative';
                DOB = datetime(2023,04,20);
                age = between(DOB, perfusion, 'days');
                line = 1;
            case {4,5}
                perfusion = datetime(2023, 7, 3);
                name = 'NC2';
                sex = 'female';
                group = 'negative';
                DOB = datetime(2022,11,15);
                age = between(DOB, perfusion, 'days');
                line = 1;
            case {7,8}
                perfusion = datetime(2023, 7, 3);
                name = 'NC3';
                sex = 'male';
                group = 'negative';
                DOB = datetime(2023,01,24);
                age = between(DOB, perfusion, 'days');
                line = 4;
            case {10,11}
                perfusion = datetime(2023, 7, 3);
                name = 'NC4';
                sex = 'male';
                group = 'negative';
                DOB = datetime(2023,01,24);
                age = between(DOB, perfusion, 'days');
                line = 4;
            case {13,14}
                perfusion = datetime(2023, 7,6);
                name = 'VH1';
                sex = 'female';
                group = 'rule';
                DOB = datetime(2023,03,13);
                age = between(DOB, perfusion, 'days');
                line = 4;
            case {16,17}
                perfusion = datetime(2023, 7,6);
                name = 'VH4';
                sex = 'male';
                group = 'random';
                DOB = datetime(2023,01,1);
                age = between(DOB, perfusion, 'days');
                line = 4;
        end
    case 4
        %% VH2,3 1 rule and 1 random
        %VH2 524914 female slide 1,2 random
        %VH3 520381 male slide 4,5 rule didn't learn
        line = 4;
        perfusion = datetime(2023, 7,6);
        switch slide
            case {1,2}
                name = 'VH2';
                sex = 'female';
                group = 'random';
                DOB = datetime(2023,03,13);
                age = between(DOB, perfusion, 'days');
            case {4,5}
                name = 'VH3';
                sex = 'male';
                group = 'rule2';
                DOB = datetime(2023,01,1);
                age = between(DOB, perfusion, 'days');
        end
    case 5
        %% Line 1 EE
        %EE1 524633
        %EE2 524630
        %EE3 524136
        line = 1;
        perfusion = datetime(2023, 8, 4);
        switch slide
            case {1,2}
                name = 'EE1';
                sex = 'female';
                group = 'EE';
                DOB = datetime(2023,03,10);
                age = between(DOB, perfusion, 'days');
            case {4,5}
                name = 'EE2';
                sex = 'female';
                group = 'EE';
                DOB = datetime(2023,03,10);
                age = between(DOB, perfusion, 'days');

            case {7,8}
                name = 'EE3';
                sex = 'male';
                group = 'EE';
                DOB = datetime(2023,03,01);
                age = between(DOB, perfusion, 'days');
        end
        case 6
        %% Line 4 EE
        %EE4
        %EE5
        line = 4;
        perfusion = datetime(2023, 8, 18);
        switch slide
            case {1,2}
                name = 'EE4';
                sex = 'female';
                group = 'EE';
                DOB = datetime(2023,03,13);
                age = between(DOB, perfusion, 'days');
            case {4,5}
                name = 'EE5';
                sex = 'male';
                group = 'EE';
                DOB = datetime(2023,01,1);
                age = between(DOB, perfusion, 'days');
        end
end
