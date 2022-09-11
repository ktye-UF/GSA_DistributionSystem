function [result, cpu_time] = sensitivity_analysis_sobol(model, n, sampling)
n_model = length(model);
% % original model
SobolOpts.Type = 'Sensitivity';
SobolOpts.Method = 'Sobol';
SobolOpts.Sobol.PCEBased = false;
SobolOpts.Sobol.SampleSize = n;
% SobolOpts.Sobol.Sampling = 'LHS'; % mc, lhs, pseudo-random sampling (halton, sobol)
SobolOpts.Sobol.Sampling = sampling;     
% 
for i=1:n_model
    uq_selectModel(model{i});
    tic
    SobolAnalysis = uq_createAnalysis(SobolOpts);
    cpu_time(i) = toc;
    result{i} = [SobolAnalysis.Results.FirstOrder; SobolAnalysis.Results.Total];
end
    







