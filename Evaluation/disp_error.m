function [n_total,d_err,n_err,n_inlier,n_gt] = disp_error (D_gt,D_est,tau)

E = abs(D_gt-D_est);
n_err   = length(find(D_gt>0 & D_est>0 & E>tau(1) & E./abs(D_gt)>tau(2)));
n_total = length(find(D_gt>0 & D_est>0));
d_err = n_err/n_total;
n_inlier = length(find(D_est>0));
n_gt = length(find(D_gt>0));
