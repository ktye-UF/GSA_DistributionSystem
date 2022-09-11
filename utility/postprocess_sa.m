function result_sa = postprocess_sa(result_sa, th)
if ~isempty(th)
    result_sa(result_sa<th) = 0;
end
% result_sa = result_sa ./ sum(result_sa,1);