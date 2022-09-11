function [error_mean, error_var] = get_error_exp(mean, var)
[m, n] = size(mean);
Y = mean;
for p=2:m
    for q=1:n
        error_mean(p-1,q) = abs(Y(p,q) - Y(1,q)) / abs(Y(1,q)).*100;
    end
end 
Y = var;
for p=2:m
    for q=1:n
        error_var(p-1,q) = abs(Y(p,q) - Y(1,q)) / abs(Y(1,q)).*100;
    end
end 
end