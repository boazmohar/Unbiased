function [name, sex, group, age, line, p_c_interval] = parse_name_glua2(name, round)
if nargin < 2
    round = 1;
end
disp(name)
if round == 11
    f = strsplit(name, '_');
    num = f{2};
    slide = str2double(num(1:end-4));
else
    f = strsplit(name, ' ');
    slide = str2double(f{2});
end
p_c_interval = 3;
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
    case 7
        %% 3 random early in learning Alyssa Michel
        %bm10 535775 female slide 1,2
        %bm12 536874 female slide 4,5
        %bm13 538340 male slide 7,8 skip - didn't run / behave
        %bm14 536047 female slide 10,112/16/2024
        perfusion = datetime(2024, 2, 16);

        switch slide
            case {1,2}
                line = 1;
                name = 'BM10';
                sex = 'female';
                group = 'early';
                DOB = datetime(2023,8,16);
                age = between(DOB, perfusion, 'days');
            case {4,5}
                line = 1;
                name = 'BM12';
                sex = 'female';
                group = 'early';
                DOB = datetime(2023,8,31);
                age = between(DOB, perfusion, 'days');
                % case {7,8}
                %     line = 4;
                %     name = 'BM13';
                %     sex = 'male';
                %     group = 'early';
                %     DOB = datetime(2023,9,22);
                %     age = between(DOB, perfusion, 'days');
            case {10,11}
                line = 4;
                name = 'BM14';
                sex = 'female';
                group = 'early';
                DOB = datetime(2023,8,20);
                age = between(DOB, perfusion, 'days');
        end
    case 8
        %% 2 zero day controls JF552
        %JF552_1 539863 male slide 7,8
        %JF552_1 539859 female slide 10,11\
        perfusion = datetime(2024, 3, 8);
        DOB = datetime(2023,10,15);
        age = between(DOB, perfusion, 'days');
        group = 'zero552';
        switch slide
            case {7,8}
                line = 4;
                name = 'JF552_1';
                sex = 'male';
            case {10,11}
                line = 1;
                name = 'JF552_2';
                sex = 'female';
        end
    case 9
        %% 3 zero day controls JF552 and JF673
        %JF552_3 539862 male slide 1,2
        %JF673_1 538989 female  slide 4,5
        %JF673_1 540626 male slide 7,8
        perfusion = datetime(2024, 3, 8);
        switch slide
            case {1,2}
                line = 4;
                name = 'JF552_3';
                sex = 'male';
                DOB = datetime(2023,10,15);
                age = between(DOB, perfusion, 'days');
                group = 'zero552';
            case {4,5}
                line = 1;
                name = 'JF673_1';
                sex = 'female';
                DOB = datetime(2023,10,3);
                age = between(DOB, perfusion, 'days');
                group = 'zero673';
            case {7,8}
                line = 4;
                name = 'JF673_2';
                sex = 'male';
                DOB = datetime(2023,10,26);
                age = between(DOB, perfusion, 'days');
                group = 'zero673';
        end
    case 10
        %% 3 DOI animals
        %JF552_3 539862 male slide 1,2
        %JF673_1 538989 female  slide 4,5
        %JF673_1 540626 male slide 7,8
        sex = 'female';
        DOB = datetime(2024,2,20);
        perfusion = datetime(2024, 6, 14);
        line = 1;
        age = between(DOB, perfusion, 'days');
        group = 'DOI';
        switch slide
            case {4,5}
                name = 'DOI1';
            case {7,8}
                name = 'DOI2';
            case {10,11}
                name = 'DOI3';
        end
    case 11
        %% MicroStim animals
        name = f{1};
        p_c_interval = 4;
        switch name
            case 'MS5'
                sex = 'female';
                DOB = datetime(2024,10,22);
                perfusion = datetime(2025, 2, 10);
                line = 4;
                age = between(DOB, perfusion, 'days');
                group = 'StimLearn';
            case 'MS6'
                sex = 'female';
                DOB = datetime(2024,10,22);
                perfusion = datetime(2025, 2, 10);
                line = 4;
                age = between(DOB, perfusion, 'days');
                group = 'StimLearn';
            case 'MS7'
                sex = 'male';
                DOB = datetime(2024,9,24);
                perfusion = datetime(2025, 2, 10);
                line = 1;
                age = between(DOB, perfusion, 'days');
                group = 'StimControl';
            case 'MS8'
                sex = 'female';
                DOB = datetime(2024,9,24);
                perfusion = datetime(2025, 2, 18);
                line = 1;
                age = between(DOB, perfusion, 'days');
                group = 'StimLearn';
            case 'MS10'
                sex = 'male';
                DOB = datetime(2024,8,13);
                perfusion = datetime(2025, 2, 18);
                line = 1;
                age = between(DOB, perfusion, 'days');
                group = 'StimControl';
            case 'MS14'
                sex = 'female';
                DOB = datetime(2024,9,3);
                perfusion = datetime(2025, 2, 19);
                line = 1;
                age = between(DOB, perfusion, 'days');
                group = 'StimControl';
        end
    case 12
        %% Reversal 4 day pulse chase
        line = 1;
        p_c_interval = 4;
        switch slide
            case {1,2} % ANM570359
                name = 'BM32';
                sex = 'male';
                DOB = datetime(2024,12,7);
                perfusion = datetime(2025,6,30);
                age = between(DOB, perfusion, 'days');
                group = 'reversal';
            case {4,5}
                name = 'BM33'; % ANM570361
                sex = 'female';
                DOB = datetime(2024,12,7);
                perfusion = datetime(2025,8,5);
                age = between(DOB, perfusion, 'days');
                group = 'reversal';
            case {7,8}
                name = 'BM34';
                sex = 'female';
                DOB = datetime(2024,12,7);
                perfusion = datetime(2025,8,5);
                age = between(DOB, perfusion, 'days');
                group = 'reversal_control';
        end
end


