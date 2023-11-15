function [f_err,n_total,n_inlier,n_gt] = flow_error (F_gt,F_est,tau)

[E,F_val] = flow_error_map (F_gt,F_est);
F_mag = sqrt(F_gt(:,:,1).*F_gt(:,:,1)+F_gt(:,:,2).*F_gt(:,:,2));
n_err   = length(find(F_gt(:,:,3)>0 & F_est(:,:,3)>0 & F_val & E>tau(1) & E./F_mag>tau(2)));
n_total = length(find(F_val & F_gt(:,:,3)>0 & F_est(:,:,3)>0));
f_err = n_err/n_total;
n_inlier = length(find(F_est(:,:,3)>0));
n_gt = length(find(F_gt(:,:,3)>0));

