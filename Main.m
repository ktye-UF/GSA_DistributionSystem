clearvars
addpath(genpath(pwd))
uqlab
%% parameter setting
% % !TODO seperate path(of system data form, i.e., 'load_data.xlsx') setting from 'initial_input_setting'
scenario = 10;
% initial_input_setting(scenerio)
initial_input_setting_v2(scenario)  % more input

%% generate input
% X: N¡Ám
myInput = initial_input_37();

%% generate data
% input form: each sample: [Load1, Load2, ..., PV1, PV2,...]
% output form: each sample: (at Line.Bus1) [701a, 701b, 701c, 702a, 702b, 702c,...] (exception: power at 799r: [799r_a, 799r_b])
% % !TODO solver depends on '\save\Input_setting'
n_train_pce = 5e2;
dataset_train_pce = generate_sample_feeder(myInput, n_train_pce);
n_train_krig = 2e2;
dataset_train_krig = generate_sample_feeder(myInput, n_train_krig);
tic
n_val = 1e4;
dataset_val = generate_sample_feeder(myInput, n_val);
toc

% % 
% save([pwd, '\save\dataset_train_pce_v5'], 'dataset_train_pce')
% save([pwd, '\save\dataset_val_v5'], 'dataset_val')
% X_train = dataset_train_pce.X; save([pwd, '\save\X_train'], 'X_train')
% Y_train = dataset_train_pce.Y; save([pwd, '\save\Y_train'], 'Y_train')
% X_val = dataset_val.X; save([pwd, '\save\X_val'], 'X_val')
% Y_val = dataset_val.Y; save([pwd, '\save\Y_val'], 'Y_val')
% X_sobol = dataset_train_pce.X; save([pwd, '\save\X_sobol'], 'X_sobol')

% load('save\dataset_train_pce_v5')
% load('save\dataset_val_v5')
% error
%% construct surrogate model
% % parameters: details see UQLab documents
degree = 2;
qnorm = 1;
trend_type = 'linear';	% simple, ordinary, linear, quadratic, polynomial
corr_fam = 'gaussian';  % linear, exponential, gaussian, matern-3_2, matern-5_2
estimate = 'CV';  % ML, CV
opt = 'HCMAES';    % none, LBFGS, GA, HGA, CMAES, HCMAES
noise_infer = [];   % 'auto', []
% % % PCE
clear param
param.degree = degree;   % [degree, n_coef] = [3,120]/[4,330]/[5,792]/[6,1716]
param.qnorm = qnorm;
n_input = length(myInput.Marginals);
n_term = [param.degree; factorial(param.degree+n_input) ./ factorial(param.degree) ./ factorial(n_input)];
% % % original model
model_opts.mFile = 'solver_opendss_37';
tic
myPCE = construct_pce(myInput, dataset_train_pce, param);
ctime(2) = toc
% % % Krig
clear param
param.trend_type = trend_type;
param.corr_fam = corr_fam;  
param.estimate = estimate;  
param.opt = opt;    
param.noise_infer = noise_infer;
tic
myKrig = construct_krig(myInput, dataset_train_krig, param);
ctime(3) = toc

%% evaluate
% return result follows this order
model = {myPCE, myKrig};    % original model not included
[error_model, mean_exp, var_exp] = evaluate_model(model, dataset_val.X, dataset_val.Y); % not percentage

% mean(error_model(:,setdiff(1:9,[])),2)
mean(error_model,2)
% error
%% sensitivity analysis
% % original model
ModelOpts.mFile = 'solver_opendss_37';
myModel = uq_createModel(ModelOpts);
% % % number of sample
n_sa = 5e3;
% % return result follows this order
% model_sa = [{myModel}, model];
model_sa = {myModel};
% [result, cpu_time] = sensitivity_analysis_sobol(model_sa, n_sa);
[result(1), cpu_time(1)] = sensitivity_analysis_sobol(model_sa, n_sa, 'mc');
% error
% save([pwd '\save\sobol_benchmark_paper_s10'], 'sobol_sa_benchmark', 'cpu_time')
% % tmp
n_sa_tmp = 1e4;
% % % % tmp: pce
[result(2), cpu_time(2)] = sensitivity_analysis_sobol({myPCE}, n_sa_tmp, 'mc');
% % % % tmp: krig
[result(3), cpu_time(3)] = sensitivity_analysis_sobol({myKrig}, n_sa_tmp, 'mc');

% % % evaluation CPU time
% cpu_time_eval = 0;
% for tt=1:20
%     [~, ct_tmp] = sensitivity_analysis_sobol({myPCE}, n_sa_tmp);
% %     [~, ct_tmp] = sensitivity_analysis_sobol({myKrig}, n_sa_tmp);
%     cpu_time_eval = cpu_time_eval + ct_tmp;
% end
% cpu_time_eval / 20
% cpu_time_eval = 0;
% for tt=1:20
% %     [~, ct_tmp] = sensitivity_analysis_sobol({myPCE}, n_sa_tmp);
%     [~, ct_tmp] = sensitivity_analysis_sobol({myKrig}, n_sa_tmp);
%     cpu_time_eval = cpu_time_eval + ct_tmp;
% end
% cpu_time_eval / 20

% model_sa = {myModel, myPCE, myKrig};
% result_sa = result;
% % result_sa(2)= [];
% error_sa = get_sa_acc(model_sa, result_sa)
% [mean(error_model(1:2,:),2); mean(error_sa,2)]
% error

%% sa post process
n_input = length(myInput.Marginals);
model_sa = [{myModel}, model];
th = 0;
% sum to 1 (not correct)
sa_select = 1:n_input*2;
for i=1:length(model_sa)
    result_tmp = result{i};
    % threshold less than zero
    result_tmp = postprocess_sa(result_tmp(sa_select,:), th);
	% sum to 1?
% 	result_tmp(1:n_input,:) = result_tmp(1:n_input,:) ./ sum(result_tmp(1:n_input,:));
    result_sa{i} = result_tmp;
end

% % error of sa?
result_bm = result_sa{1};
error_sa_ind = 7:12;
% error_sa_ind = 1:6;
for j=1:length(model_sa)-1
    for i=1:size(result_bm, 2)
        result_tmp_2 = result_sa{j+1};
        error_sa(j,i) = sqrt(immse(result_bm(error_sa_ind,i), result_tmp_2(error_sa_ind,i)));
        error_sa_rmae(j,i) = mean(abs((result_bm(:,i) - result_tmp_2(:,i))./result_bm(:,i)));
    end
end

% [cpu_time' mean(error_model(1:2,:),2) mean(error_model(5:6,:),2) mean(error_sa,2)]
mean(error_sa,2)
[mean(error_model(1:2,:),2); mean(error_sa,2)]

%% plot tmp
plot_bm = result_sa{1};
plot_pce = result_sa{2};
plot_gpr = result_sa{3};
for index_plot = 1:9
figure; hold on
% input_index = {'Load_{731b}','L_{733a}','L_{735c}','P_{731b}','P_{733a}','P_{735c}'};
input_index = {'P^{L}_{731b}','P^{L}_{733a}','P^{L}_{735c}','P^{I}_{731b}','P^{I}_{733a}','P^{I}_{735c}'};
X = categorical(input_index);
X = reordercats(X,input_index);
bar(X, [plot_bm(7:12,index_plot)'; plot_pce(7:12,index_plot)'; plot_gpr(7:12,index_plot)']', 1)
legend('M_{pf}', 'M_{pc}', 'M_{kr}')
% legend('boxoff')
ylabel('Total Sobol indices')
% saveas(gca, [pwd,'\plot\result-',num2str(index_plot)], 'jpg')
end
% error
% load([pwd, '\save\s10_noise_lvl_v2_v4'])
% save([pwd, '/save/result_sa'], 'result_sa')
