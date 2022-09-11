function myInput = initial_input_37()
%% determine system & load_original_data  & output --> now saved in 'Input_setting'
% % % choose system 
% path_main = [pwd, '\IEEETestCases\37Bus\ieee37.dss'];
% % % set load_original_data (!TODO: re-consider data structure)
% path_data = [pwd, '\load_data.xlsx'];
% sheet_data = 'load_original';
% % % % desired output
% % % bus_name of desired output
% bus_name_output = [701; 733; 737]; % n¡Á1 number. must be n¡Á1 (to apply num2str)clear 
% % % line_name(line power flow) of desired output     
% line_name_output = {}; % n¡Á1 cell
% %% determine input parameters
% % % % determine bus and node of input

%% unpack variables
load([pwd, '\save\Input_setting'])
% ! do not know why it needs to be assigned in this way 'path' not needed
% [~, system_info, load_setting, pv_setting, output_choose] = v2struct(Input_setting);
[~, output_choose, system_info, load_setting, pv_setting] = v2struct(Input_setting);
v2struct(system_info); v2struct(output_choose);
v2struct(load_setting); v2struct(pv_setting);

%% get load statistics: mean & std
% % % find index for load old
load_original_p_select = load_original_p(input_load_ind);
% determine mean & std
load_mean = load_original_p_select;
load_std = load_mean .* load_lvl;

%% Input: load(input_load_bus order), PV(input_pv_bus order)
% % load
for ii = 1 : n_load
    InputOpts.Marginals(ii).Type = 'Gaussian';  % !TODO: change to variable
    InputOpts.Marginals(ii).Parameters = [load_mean(ii), load_std(ii)];
end
% % PV
for ii = 1 + n_load : n_load + n_pv
    InputOpts.Marginals(ii).Type = 'Beta';
    InputOpts.Marginals(ii).Parameters = pv_param(ii-n_load,:);
end

%% create
myInput = uq_createInput(InputOpts);
%%


        

