function myPCE = construct_pce(myInput, dataset, param)
% model = param.model;
degree = param.degree;
% load('..\save\118_lws\dataset')
%% pce
MetaOpts.Type = 'Metamodel';
MetaOpts.MetaType = 'PCE';
% MetaOpts.FullModel = myModel;
MetaOpts.Degree = degree;
% MetaOpts.PolyTypes = repelem({'arbitrary'}, size(dataset.X,2));
MetaOpts.Method = 'lars';
% MetaOpts.ExpDesign.NSamples = 1000;
MetaOpts.ExpDesign.X = dataset.X;
MetaOpts.ExpDesign.Y = dataset.Y;
% % 
uq_selectInput(myInput);
myPCE = uq_createModel(MetaOpts);


