function rmse = evaluate_sensitivity_analysis(result_bm, S_all)
for i=1:length(S_all)
    for j=1:size(result_bm, 2)
        result_tmp = S_all{i};
        rmse(i,j) = sqrt(immse( result_bm(:,j), result_tmp(:,j) ));
    end
end








