function [] = initial_input_setting_v2(scenerio)
%% determine system & load_original_data  & output
% % choose system 
path_main = [pwd, '\IEEETestCases\37Bus\ieee37opendss.dss'];
% path_main = [pwd, '\IEEETestCases\123Bus\Run_IEEE123Bus.dss'];
% % set load_original_data (!TODO: re-consider data structure)
path_data = [pwd, '\load_data.xlsx'];
sheet_data = 'load_original';
% % % desired output
% % bus_name of desired output
% % ! IMPORTANT: output will follow natural number order, NOT this array
bus_name_output = [731; 733; 735]; % n¡Á1 number. must be n¡Á1 (to apply num2str)clear. ex. [701a, 701b, 701c, 702a, 702b, 702c,...]
bus_name_output = [731; 733; 735];
% bus_name_output = [732; 734; 736]; 
% % line_name(line power flow) of desired output     
% % ! IMPORTANT: output will follow natural number order, NOT this cell
line_name_output = {}; % n¡Á1 cell char 
% line_name_output = {'l14'; 'l15'; 'l18'; 'l19'; 'l28'; 'l30'};
%% determine input parameters
switch scenerio
    case 1
        % % % determine bus and node of input
        input_load_bus =       [731; 732; 733; 734; 735; 736; 737; 738; 740; 741];
        input_load_node = char({'b'; 'c'; 'a'; 'c'; 'c'; 'b'; 'a'; 'a'; 'c'; 'c'});
        input_pv_bus =       [732; 735; 736];
        input_pv_node = char({'b'; 'c'; 'a'});
        % % load
        load_lvl = 0.1;
        % % 
        pv_param = [3,  2.2,	0, 20;	% 
                    3,  2.2,    0, 20;	% 
                    3,  2.2     0, 20];
    case 2
        % same as github code version
        input_load_bus =       [733; 735; 737; 741];
        input_load_node = char({'a'; 'c'; 'a'; 'c'});
        input_pv_bus =       [732; 735; 737; 737; 741];
        input_pv_node = char({'c'; 'b'; 'a'; 'b'; 'c'});
        % % load
        load_lvl = 0.05;
        % % 
        pv_param = repelem([3, 2.2, 0, 20], length(input_pv_bus), 1);
        
    case 3
        % more input
        input_load_bus =       [731; 732; 733; 734; 735; 736; 737; 738; 740; 741];
        input_load_node = char({'b'; 'c'; 'a'; 'c'; 'c'; 'b'; 'a'; 'a'; 'c'; 'c'});
        input_pv_bus =       [708; 709; 710; 711; 731; 732; 733; 734; 735; 736; 737; 738; 740; 741];
        input_pv_node = char({'a'; 'b'; 'c'; 'a'; 'b'; 'c'; 'a'; 'c'; 'c'; 'b'; 'a'; 'a'; 'c'; 'c'});
        % % load
        load_lvl = 0.05;
        % % 
        pv_param = repelem([3, 2.2, 0, 20], length(input_pv_bus), 1);
    case 4
        % pv and load same node
        input_load_bus =       [731; 732; 733; 735; 736; 737];
        input_load_node = char({'b'; 'c'; 'a'; 'c'; 'b'; 'a'});
        input_pv_bus =       [731; 735; 737];
        input_pv_node = char({'b'; 'c'; 'a'});
%         input_pv_bus =       [731; 732; 737];
%         input_pv_node = char({'b'; 'c'; 'a'});
        % % load
        load_lvl = 0.05;
        % % 
%         pv_param = repelem([3, 2.2, 0, 20], length(input_pv_bus), 1);   
        %
        pv_param = [3,  2.2,	0, 30;	% 
                    3,  2.2,    0, 30;	% 
                    3,  2.2,    0, 30];
    case 5
        % load same value
        input_load_bus =       [731; 733; 735];
        input_load_node = char({'b'; 'a'; 'c'});
        input_pv_bus =       [731; 733; 735];
        input_pv_node = char({'b'; 'a'; 'c'});
%         input_pv_bus =       [731; 732; 737];
%         input_pv_node = char({'b'; 'c'; 'a'});
        % % load
        load_lvl = 0.05;
        % % 
%         pv_param = repelem([3, 2.2, 0, 20], length(input_pv_bus), 1);   
        % previous [0,10], CG KF GP -> [0,20]
        pv_param = [3,  2.2,	0, 10;	% b
                    3,  2.2,    0, 10;	% a
                    3,  2.2,    0, 10]; % c
    case 6
        % load same value
        input_load_bus =       [731; 733; 735];
        input_load_node = char({'b'; 'a'; 'c'});
        input_pv_bus =       [731; 733; 735];
        input_pv_node = char({'b'; 'a'; 'c'});
%         input_pv_bus =       [731; 732; 737];
%         input_pv_node = char({'b'; 'c'; 'a'});
        % % load
        load_lvl = 0.05;
        % % 
%         pv_param = repelem([3, 2.2, 0, 20], length(input_pv_bus), 1);   
        %
        pv_param = [3,  2.2,	0, 20;	% b
                    3,  2.2,    0, 20;	% a
                    3,  2.2,    0, 20]; % c
    case 7
        % load same value
        input_load_bus =       [731; 733; 735];
        input_load_node = char({'b'; 'a'; 'c'});
        input_pv_bus =       [731; 733; 735];
        input_pv_node = char({'b'; 'a'; 'c'});
%         input_pv_bus =       [731; 732; 737];
%         input_pv_node = char({'b'; 'c'; 'a'});
        % % load
        load_lvl = 0.05;
        % % 
%         pv_param = repelem([3, 2.2, 0, 20], length(input_pv_bus), 1);   
        %
        pv_param = [3,  2.2,	0, 15;	% b
                    3,  2.2,    0, 15;	% a
                    3,  2.2,    0, 15]; % c
    case 8
        % load same value
        input_load_bus =       [731; 733; 735];
        input_load_node = char({'b'; 'a'; 'c'});
        input_pv_bus =       [731; 733; 735];
        input_pv_node = char({'b'; 'a'; 'c'});
%         input_pv_bus =       [731; 732; 737];
%         input_pv_node = char({'b'; 'c'; 'a'});
        % % load
        load_lvl = 0.1;
        % % 
%         pv_param = repelem([3, 2.2, 0, 20], length(input_pv_bus), 1);   
        %
        pv_param = [3,  2.2,	0, 20;	% b
                    3,  2.2,    0, 20;	% a
                    3,  2.2,    0, 20]; % c    
    case 9
        % load same value
        input_load_bus =       [731; 733; 735];
        input_load_node = char({'b'; 'a'; 'c'});
        input_pv_bus =       [731; 733; 735];
        input_pv_node = char({'b'; 'a'; 'c'});
%         input_pv_bus =       [731; 732; 737];
%         input_pv_node = char({'b'; 'c'; 'a'});
        % % load
        load_lvl = 0.05;
        % % 
%         pv_param = repelem([3, 2.2, 0, 20], length(input_pv_bus), 1);   
        %
        pv_param = [3,  2.2,	0, 30;	% b
                    3,  2.2,    0, 30;	% a
                    3,  2.2,    0, 30]; % c
    case 10
        % load same value
        input_load_bus =       [731; 733; 735];
        input_load_node = char({'b'; 'a'; 'c'});
        input_pv_bus =       [731; 733; 735];
        input_pv_node = char({'b'; 'a'; 'c'});
%         input_pv_bus =       [731; 732; 737];
%         input_pv_node = char({'b'; 'c'; 'a'});
        % % load
        load_lvl = 0.1;
        % % 
%         pv_param = repelem([3, 2.2, 0, 20], length(input_pv_bus), 1);   
        %
        pv_param = [3,  2.2,	0, 30;	% b
                    3,  2.2,    0, 30;	% a
                    3,  2.2,    0, 30]; % c     
    case 11
        % load same value
        input_load_bus =       [731; 733; 735];
        input_load_node = char({'b'; 'a'; 'c'});
        input_pv_bus =       [731; 733; 735];
        input_pv_node = char({'b'; 'a'; 'c'});
%         input_pv_bus =       [731; 732; 737];
%         input_pv_node = char({'b'; 'c'; 'a'});
        % % load
        load_lvl = 0.1;
        % % 
%         pv_param = repelem([3, 2.2, 0, 20], length(input_pv_bus), 1);   
        %
        pv_param = [15,	2, 0, 30;	% b
                    15,	2, 0, 30;	% a
                    15,	2, 0, 30]; % c   
    otherwise
        error('unknown scenerio')
end

%% further postprocess
% % info
n_load = length(input_load_bus);
n_pv = length(input_pv_bus);
% % % read bus name and phase
% [raw_num, raw_str] = xlsread(path_data, sheet_data);
% load_data = v2struct(raw_num, raw_str, {'fieldNames', 'raw_num', 'raw_str'});
% save([pwd, '\save\load_data'], 'load_data')
load('load_data')
v2struct(load_data)
bus_ind = raw_num(:,1); % bus name index
load_original_p = raw_num(:,3); % P value
load_original_q = raw_num(:,4); % Q value
bus_node = char(raw_str);   % bus node index
% % P/Q ratio stays unchanged i.e., (! power factor not changed)
load_ratio = load_original_q ./ load_original_p;
% % find index for input load 
for k=1:n_load
    % index for load in 'path_data'
    input_load_ind(k,1) = intersect(find(bus_ind==input_load_bus(k)), find(bus_node==input_load_node(k)));
end
%% pack variables
path = v2struct(path_main, path_data, sheet_data);
% % [solved] ! it will throw a warning if no 'fieldNames' cell
output_choose = v2struct(bus_name_output, line_name_output, {'fieldNames', 'bus_name_output', 'line_name_output'});
system_info = v2struct(bus_ind, load_original_p, load_original_q, bus_node, load_ratio);
load_setting = v2struct(input_load_bus, input_load_node, load_lvl, n_load, input_load_ind);
pv_setting = v2struct(input_pv_bus, input_pv_node, pv_param, n_pv);
Input_setting = v2struct(path, output_choose, system_info, load_setting, pv_setting);
save([pwd, '\save\Input_setting'], 'Input_setting');
