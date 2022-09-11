function varargout = solver_opendss_37(X)
% function [Y, is_converge] = solver_opendss_37(X)
% % solver using opendss
% % X: N¡Ám, N samples, m features
% % Y: N¡Ák, N samples, k outputs
%% determine system & load_data & load,PV location & output --> now saved in <initial_input_37>
% % choose system and load data
% path_main = [pwd, '\IEEETestCases\37Bus\ieee37.dss'];
% path_data = [pwd, '\load_data.xlsx'];

%% preprocess
% % load variables
load([pwd, '\save\Input_setting'])
% ! do not know why it needs to be assigned in this way
[path, system_info, load_setting, pv_setting, output_choose] = v2struct(Input_setting);
v2struct(path); v2struct(system_info); v2struct(output_choose);
v2struct(load_setting); v2struct(pv_setting);
% % info from X
[n, m] = size(X);
% % initial Y
num_output_voltage = length(bus_name_output)*3;     % *3 because of 3 phases, exception?
num_output_power = length(line_name_output)*3;      % *3 because of 3 phases, exception: not 3 phases (799r-799r2)
num_output_all = num_output_voltage + num_output_power;
Y = NaN(n, num_output_all);
% % info --> now saved in <initial_input_37>
is_converge = ones(n,1); % check convergence

% % % read bus name and phase --> now saved in <initial_input_37>
% % % build the Matlab-OpenDSS COM interface
DSSObj = actxserver('OpenDSSEngine.DSS');       	% Register the COM server (initialization)
if ~DSSObj.Start(0)                                 % Start the OpenDSS. If the registration is unsuccessful, stop and remind the user
    disp('Unable to start OpenDSS Engine');
return
end
DSSText = DSSObj.Text;                             % Define a text interface variable
DSSCircuit = DSSObj.ActiveCircuit;                 % Define a circuit interface variable

%% get index 
% % find index for load old --> !changed: 'load_ind' is saved in <initial_input_37> as 'input_load_inde'
% % find load index for both old & new
% % initial
% pv_old index(index in X. e.g.: 1 --> X(i,1)) / bus_name(701) / node_name('a')
[pv_ind_old, pv_bus_old, pv_node_old]  = deal([]); 
% pv_new bus_name(701) / node_name('a') / bus_number '.1.2'
[pv_bus_new, pv_node_new, pv_bus_number]  = deal([]);
% % iter to find desired
for t=1:n_pv
    ind_tmp = intersect(find(bus_ind==input_pv_bus(t)), find(bus_node==input_pv_node(t)));
    if ind_tmp  % if pv injection bus already exists
        pv_ind_old = [pv_ind_old; ind_tmp];
        pv_bus_old = [pv_bus_old; input_pv_bus(t)];
        pv_node_old = [pv_node_old; input_pv_node(t)];
    else    % need to new Load
        pv_bus_new = [pv_bus_new; input_pv_bus(t)];
        pv_node_new = [pv_node_new; input_pv_node(t)];    % for pv new, kvar=0;
        % get corresponding number '1.2' in 'Bus1-701.1.2' when New Load
        switch input_pv_node(t)   
            case 'a'
                pv_bus_number = [pv_bus_number; '.1.2'];  
            case 'b'
                pv_bus_number = [pv_bus_number; '.2.3']; 
            case 'c'
                pv_bus_number = [pv_bus_number; '.3.1'];
            case ' '
                pv_bus_number = [pv_bus_number; '    '];
            otherwise
                error('Unknown bus number when new load');
        end
    end
end
% % update entire bus index & bus node
bus_ind_new = [bus_ind; pv_bus_new];
bus_node_new = [bus_node; pv_node_new];
n_pv_old = length(pv_bus_old);
n_pv_new = length(pv_bus_new);

%% prepare (extract input from X / New Load in opendss / ...)
% % get pv_old index in X
% in case no pv (n_pv_old=0)
ind_pv_old = [];
for t = 1:n_pv_old
    ind_pv_old(t) = intersect(find(input_pv_bus==pv_bus_old(t)), find(input_pv_node==pv_node_old(t)));
end
ind_pv_old = ind_pv_old + n_load;
% % get pv_new index in X
ind_pv_new = setdiff(1:m, 1:n_load);
ind_pv_new = setdiff(ind_pv_new, ind_pv_old);
%% change load in opendss
for i=1:n
    % % %TODO: load change & pv change redundent (load write more than once)
    % % % IMPORTANT!: re-compile file (changes are independent)
    DSSText.Command = ['Compile "', path_main, '"'];   % Specify the directory of OpenDSS master file 
    % DSSText.command = 'solve';
    % % New Load for pv_new
    for qq=1:n_pv_new
        DSSText.command = ['New Load.S', num2str(pv_bus_new(qq)), num2str(pv_node_new(qq)),...
            ' Bus1=', num2str(pv_bus_new(qq)), num2str(pv_bus_number(qq,:)), ' Phases=1 Conn=Delta Model=1 kV=4.800 kW=0 kvar=0'];
    end
    %% set load and solve in opendss
    % % initial
    load_original_p_tmp = load_original_p;
    load_original_q_tmp = load_original_q;
    % % uqdate load data
    load_original_p_tmp(input_load_ind) = X(i,1 : n_load)';                                       % update kw
    load_original_q_tmp(input_load_ind) = load_original_p_tmp(input_load_ind) .* load_ratio(input_load_ind);  % update kvar
    % % update combined load & pv_old
    load_original_p_tmp(pv_ind_old) = load_original_p_tmp(pv_ind_old) - X(i,ind_pv_old)';   % update kw only
    % % get pv_new data
    load_new_p = - X(i,ind_pv_new);
% %     load change
    for j=1:n_load
        % kw updated, kvar automatically changed
        DSSText.command = ['Load.S', num2str(input_load_bus(j)), num2str(input_load_node(j)),...
            '.kw=', num2str(load_original_p_tmp(input_load_ind(j)))];
    end
% %     pv old change
    for pp=1:n_pv_old
        % 	kw updated, kvar remains the same
        DSSText.command = ['Load.S', num2str(pv_bus_old(pp)), num2str(pv_node_old(pp)), ...
            '.kw=', num2str(load_original_p_tmp(pv_ind_old(pp))), ' kvar=', num2str(load_original_q_tmp(pv_ind_old(pp)))];
    end
% %     pv new change
    for qq=1:n_pv_new
        DSSText.command = ['Load.S', num2str(pv_bus_new(qq)), num2str(pv_node_new(qq)),...
            '.kW=', num2str(load_new_p(qq)), ' kvar=0'];
    end
    % % solve
    DSSText.command = 'solve';
%     DSSText.command = 'show voltage ln node';
    %% collect output from result
    % % % find voltage output
    % % voltage information 
    bus_name_all = DSSCircuit.AllBusNames;      % len=39, different from 'bus_ind' ; (! V LN nodes)
    bus_voltage_all = DSSCircuit.AllBusVmagPu;  % len=117, [Bus1(a,b,c), Bus2(a,b,c),...]
    % % find desired output voltage index & check if bus name all correct
    [res, ind_voltage_output] = ismember(num2str(bus_name_output), bus_name_all);
    if sum(res) ~= length(bus_name_output)
        error('Can not find output bus.')
    end
    % % divide all into three phases
%     [bus_voltage_phaseA, bus_voltage_phaseB, bus_voltage_phaseC] = deal(
    bus_voltage_phaseA = bus_voltage_all(1:3:end);
    bus_voltage_phaseB = bus_voltage_all(2:3:end);
    bus_voltage_phaseC = bus_voltage_all(3:3:end);
    % % find desired output voltage value
    bus_voltage_output_phaseA = bus_voltage_phaseA(ind_voltage_output);
    bus_voltage_output_phaseB = bus_voltage_phaseB(ind_voltage_output);
    bus_voltage_output_phaseC = bus_voltage_phaseC(ind_voltage_output);
    % output form: [701a, 702a, 703a, 701b, 702b, 703b,...]
%     bus_voltage_output_all = [bus_voltage_output_phaseA, bus_voltage_output_phaseB, bus_voltage_output_phaseC];
    % output form: [701a, 701b, 701c, 702a, 702b, 702c,...]
    bus_voltage_output_all = reshape([bus_voltage_output_phaseA; bus_voltage_output_phaseB; bus_voltage_output_phaseC],...
        1,num_output_voltage);

    % % % find line power output
    % % check if line name all correct
    line_name_all = DSSCircuit.Lines.AllNames;
    [res, ~] = ismember(line_name_output, line_name_all);
    if sum(res) ~= length(line_name_output)
        error('Can not find output power flow.')
    end
    % % initial 
    % line_name('l2') / line_name_frombus('701.1.2') / ...
    [line_name_frombus, line_name_tobus] = deal({});
    % line_power_P_output(600) / ...
    [line_power_P_output, line_power_Q_output] = deal([]);
    % % inter to get power flow result
    counter_power = DSSCircuit.Lines.First;
    while counter_power>0
%         [line_name_frombus, line_name_tobus] = deal(DSSCircuit.Lines.Name, DSSCircuit.Lines.Bus1, DSSCircuit.Lines.Bus2);
        line_name_frombus = [line_name_frombus; {DSSCircuit.Lines.Bus1}];
        line_name_tobus = [line_name_tobus; {DSSCircuit.Lines.Bus2}];
        if ismember(DSSCircuit.Lines.Name, line_name_output)
            % DSSCircuit.ActiveElement.Powers: len = 12 --> [Bus1: P1 Q1 P2 Q2 P3 Q3, Bus2:...]
            % output form: (from Bus1) [701a, 701b, 701c, 702a, 702b, 702c,...] (exception: power at 799r: [799r_a, 799r_b])
            line_power_P_output = [line_power_P_output, DSSCircuit.ActiveElement.Powers(1:2:length(DSSCircuit.ActiveElement.Powers)/2)];
            line_power_Q_output = [line_power_Q_output, DSSCircuit.ActiveElement.Powers(2:2:length(DSSCircuit.ActiveElement.Powers)/2)];
        end
        counter_power = DSSCircuit.Lines.Next;
    end
    Y(i,:) = [bus_voltage_output_all, line_power_P_output];
    % % % check convegence
    if ~DSSCircuit.Solution.Converged
        is_converge(i) = 0;
    end
end
% % set output variables
if nargout == 1
    varargout = {Y};
elseif nargout == 2
    varargout = {Y, is_converge};
end

% DSSText.command = 'show voltage ln nodes';
% DSSText.command = 'show power';
% if sum(find(is_is_converge==0))
%     error('exists not converged sample')
% end
% error








