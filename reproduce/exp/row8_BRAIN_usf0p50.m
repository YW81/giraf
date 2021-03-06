% Table 1, Row 8
% data: BRAIN, USF: 0.50
load dataset_BRAIN.mat;
load samples_dataset_BRAIN_usf0p50.mat;
name = 'row8_BRAIN_usf0p50';
%%
%global settings
settings.filter_siz = filter_siz;
settings.r = r;
settings.res = size(x0);
settings.weighting = 'grad'; %gradient weighting
settings.exit_tol = 1e-5;   %exit algorithm if NMSE below this 
settings.cost_computations = false; %save time by switching off cost computations

ind_samples = find(sampmask~=0);
[A,At] = defAAt(ind_samples,settings.res);

%AP settings
param_ap.r = settings.r;
param_ap.lambda = 0; %regularization parameter (set to 0 for equality constraints)
param_ap.iter = 100;  %number of iterations
param_ap.svd_type = 'econ'; %'econ'  = MATLAB svd with 'econ' option (best for large r)
                                %'lansvd'= Lanczos partial svd (best for small r)
                                %'rsvd'  = Random partial svd (best for small r)

exp_loraks.name = 'AP';
exp_loraks.opt_handle = @opt_ap_prox;
exp_loraks.settings = settings;
exp_loraks.param = param_ap;

%SVT settings
param_svt.lambda = 0; %regularization parameter (set to 0 for equality constraints)
param_svt.beta = 2;   %ADMM parameter
param_svt.iter = 50;  %number of ADMM iterations

exp_svt.name = 'SVT';
exp_svt.opt_handle = @opt_svt;
exp_svt.settings = settings;
exp_svt.param = param_svt;

%SVT+UV settings
param_svt_uv.r = settings.r; %rank cutoff (inner dimension of U,V matricies)
param_svt_uv.lambda = 0; %regularization parameter (set to 0 for equality constraints)
param_svt_uv.beta = 1e3;   %ADMM parameter
param_svt_uv.iter = 50;  %number of ADMM iterations

exp_svt_uv.name = 'SVT+UV';
exp_svt_uv.opt_handle = @opt_svt_uv;
exp_svt_uv.settings = settings;
exp_svt_uv.param = param_svt_uv;

%IRLS settings
param_irls.lambda = 0; %regularization parameter
param_irls.iter = 10; %number of iterations
param_irls.eta = 1.3; %epsilon decrease factor;
param_irls.eps = 1e-2;
param_irls.epsmin = 1e-9;
param_irls.p = 1;
param_irls.lsqr_iter = 10;
param_irls.lsqr_tol = 1e-4;

param_irls.p = 0;
exp_irls_p0.name = 'IRLS-0';
exp_irls_p0.opt_handle = @opt_irls;
exp_irls_p0.settings = settings;
exp_irls_p0.param = param_irls;

%GIRAF settings
param_giraf.lambda = 0; %regularization parameter
param_giraf.iter = 10; %number of iterations
param_giraf.eta = 1.3; %epsilon decrease factor;
param_giraf.eps = 1e-2;
param_giraf.epsmin = 1e-9;
param_giraf.p = 1;
param_giraf.ADMM_iter = 200;
param_giraf.ADMM_tol = 1e-4;
param_giraf.gam_fac = 10;
param_giraf.overres = settings.res + 2*settings.filter_siz;

exp_giraf_p0.name = 'GIRAF-0';
exp_giraf_p0.opt_handle = @opt_giraf;
exp_giraf_p0.settings = settings;
exp_giraf_p0.param = param_giraf;
exp_giraf_p0.param.p = 0;
exp_giraf_p0.param.gam_fac = 100;
%% Run experiments
if ~exist('GIRAF_ONLY','var')
    GIRAF_ONLY = false;
end

%list of experiments to run
if GIRAF_ONLY 
    exp = {exp_giraf_p0};
else
    exp = {exp_ap,exp_svt,exp_svt_uv,exp_irls_p0,exp_giraf_p0}; 
end
results = run_experiments(x0,b,A,At,sampmask,exp);
print_convergence_results(results,1e-4);
%plot_convergence_results(results);
%save([name,'_results.mat'],'results');