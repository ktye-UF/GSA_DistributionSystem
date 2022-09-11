% function [mean_exp, var_exp, std_exp, mae, rmae, mse] = get_exp_stat(Y)
% for i=1:length(Y)
%     mean_exp(i,:) = mean(Y{i});
%     var_exp(i,:) = var(Y{i});
%     std_exp(i,:) = std(Y{i});   
%     mae(i,:) = mean(abs(Y{1} - Y{i}));
%     rmae(i,:) = mean(abs((Y{1} - Y{i}) ./ Y{1}));
%     mse(i,:) = mean((Y{1} - Y{i}).^2);
% end
% end

function [mean_exp, var_exp, std_exp, mae, rmae, mse, rmse] = get_exp_stat(Y)
for i=1:length(Y)
    mean_exp(i,:) = mean(Y{i});
    var_exp(i,:) = var(Y{i});
    std_exp(i,:) = std(Y{i});   
    mae(i,:) = mean(abs(Y{1} - Y{i}));
    rmae(i,:) = mean(abs((Y{1} - Y{i}) ./ Y{1}));
    mse(i,:) = mean((Y{1} - Y{i}).^2);
    rmse(i,:) = sqrt(mean((Y{1} - Y{i}).^2));
end
rmae(1,:) = [];
rmse(1,:) = [];
mse(1,:) = [];
end