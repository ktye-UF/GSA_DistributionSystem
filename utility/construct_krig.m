% clearvars
function myKrig = construct_krig(myInput, dataset, param)
trend_type = param.trend_type;
if trend_type == "polynomial"
    trend_degree = param.trend_degree;
end
corr_fam = param.corr_fam;
if param.estimate
    estimate = param.estimate;
end
if param.opt
    opt = param.opt;
end
if param.noise_infer
    noise_infer = param.noise_infer;
end

% myModel
% load('..\save\118_lws\dataset')
%% choose Xval
% [~, n_input] = size(dataset.X);
%% krig
MetaOpts.Type = 'Metamodel';
MetaOpts.MetaType = 'Kriging';
if param.estimate
    MetaOpts.EstimMethod = estimate;
end
if param.opt
    MetaOpts.Optim.Method = opt;
end
MetaOpts.Trend.Type = trend_type; % simple, ordinary, linear, quadratic, polynomial
if trend_type == "polynomial"
    MetaOpts.Trend.Degree = trend_degree;
end
MetaOpts.Corr.Family = corr_fam; % linear, exponential, gaussian, matern-3_2, matern-5_2
if param.noise_infer
    MetaOpts.Regression.SigmaNSQ = noise_infer;
end
%         MetaOpts.Corr.Type = 'separable';
MetaOpts.ExpDesign.X = dataset.X;
MetaOpts.ExpDesign.Y = dataset.Y;
uq_selectInput(myInput);
myKrig = uq_createModel(MetaOpts);