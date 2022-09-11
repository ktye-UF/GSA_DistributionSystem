function [error_model, mean_exp, var_exp] = evaluate_model(model, X, Y)
n_model = length(model);
Y_all = {Y};
for i=1:n_model
    Y_model = uq_evalModel(model{i}, X);
    Y_all = [Y_all, {Y_model}];
end
% % 
[mean_exp, var_exp, std_exp, mae, rmae, mse, rmse] = get_exp_stat(Y_all);
% % error of surrogate model
[error_mean_exp, error_var_exp] = get_error_exp(mean_exp, var_exp); % percentage
% 
error_model = [rmae; error_mean_exp; error_var_exp];









