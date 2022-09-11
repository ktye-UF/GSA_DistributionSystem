function dataset = generate_sample_feeder(myInput, n)
% IEEE 123 feeder calculation time: 1.1 sec/sample
X = uq_getSample(myInput,n);
% [solved]! some samples in X do not yield converged results, 
[output, is_converge] = solver_opendss_37(X);
% remove those not converged pairs
X(is_converge==0,:) = [];
output(is_converge==0,:) = [];
dataset.X = X;
dataset.Y = output;
% save('save/dataset', 'dataset')