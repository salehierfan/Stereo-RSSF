clc
clear
close all
tau = [3 0.05];x=1;

addpath 'sub'
addpath 'Evaluation'
addpath 'Input images'
addpath 'Ground truth'

% % Parameter Definition
PAR= LoadParameters();

% % module Active and Deactivation
PAR.inlier=1;
PAR.fine=1;
PAR.coarse=1;
PAR.post=1;

%% Start Algorithm
% all pixel adresses
Allpix =load('ALLpixelAdress.mat');Allpix=Allpix.CG;
Allpix=Allpix(1:PAR.pixelsamRate:end,:);
% scene images
I1_l =imread('1L.png');
I1_r = imread('1R.png');
I2_l = imread('2L.png');
I2_r = imread('2R.png');
% ground truth
D1_gt = disp_read('D1GT.png');
D2_gt = disp_read('D2GT.png');
F_gt  = flow_read('FlowGT.png');
% Initialization
D1= zeros(size(I1_l,[1 2]));D2= zeros(size(I1_l,[1 2]));
FLOW=zeros(size(I1_l,[1 2])); flow_u= FLOW(:,:,1); flow_v= flow_u;
FLOWe= flow_u; E= zeros(size(FLOWe));  Index=ones(size(Allpix,1),1);
tim=clock;

% % Track CG in Left to Right 
[vo_previous,IndexResult]= PointsTracker(Allpix,I1_l,I1_r,PAR,Index);

% % Course Decision and Soft Decision (CDSD)
[Indxm,OutLen,bucketed_matches]=CDFD(I1_l, I2_l, I1_r, I2_r,vo_previous,PAR,IndexResult);
% % show matched points 
if (PAR.verbosity)
    figure,showMatchedPoints(I1_l, I1_r,bucketed_matches(:,1:2),bucketed_matches(:,3:4))
    figure,showMatchedPoints(I1_r, I2_r,bucketed_matches(:,3:4),bucketed_matches(:,5:6))
    figure,showMatchedPoints(I2_r, I2_l,bucketed_matches(:,5:6),bucketed_matches(:,7:8))
    figure,showMatchedPoints(I2_l, I1_l,bucketed_matches(:,7:8),bucketed_matches(:,9:10))
end
if size(bucketed_matches,1)>0
    % %  First Disparity estimation
    addres=bucketed_matches(:,1:2);
    for j=1:size(addres,1)
        D1(addres(j,2),addres(j,1))=bucketed_matches(j,9)-bucketed_matches(j,3);
    end
    % %  Second Disparity estimation
    for j=1:size(addres,1)
        D2(addres(j,2),addres(j,1))=bucketed_matches(j,7)-bucketed_matches(j,5);
    end
    % %  Flow estimation
    for j=1:size(addres,1)
        flow_v(addres(j,2),addres(j,1))=bucketed_matches(j,8)-bucketed_matches(j,10);
        flow_u(addres(j,2),addres(j,1))=bucketed_matches(j,7)-bucketed_matches(j,9);
        if (flow_u(addres(j,2),addres(j,1))~=0 | flow_v(addres(j,2),addres(j,1))~=0)==1
            E(addres(j,2),addres(j,1))=1;
        end
    end
    floww(:,:,1)= flow_u(1:size(I1_l,1),1:size(I1_l,2));
    floww(:,:,2)= flow_v(1:size(I1_l,1),1:size(I1_l,2));
    floww(:,:,3)= E(1:size(I1_l,1),1:size(I1_l,2));
    % % Postprocessing
    if PAR.post
        D1post=DispPostProc(D1,PAR);
        D1post=D1post(1:size(I1_l,1),1:size(I1_l,2));
        D2post=DispPostProc(D2,PAR);
        D2post=D2post(1:size(I1_l,1),1:size(I1_l,2));
        Flow_post=FlowPostProc(floww,PAR); 
    else
        D1post=D1;D2post=D2;Flow_post=floww;Flow=floww;
    end
    timee=etime(clock,tim);
    % Writing Main results and evaluation
    % D1
    imwrite(uint16(round(D1*255)), 'D1.png');
    D1_est = disp_read('D1.png');
    [D1n_total,D1_err,D1num] = disp_error(D1_gt,D1_est(1:size(I1_l,1),1:size(I1_l,2)),tau);
    D1_err=100*D1_err;
    D1_inlier=nnz(D1);
    % D2
    imwrite(uint16(round(D2*255)), 'D2.png');
    D2_est = disp_read('D2.png');
    [D2n_total,D2_err,D2num] = disp_error(D2_gt,D2_est(1:size(I1_l,1),1:size(I1_l,2)),tau);
    D2_err=100*D2_err;     
    D2_inlier=nnz(D2);
    % % Flow
    floww(:,:,1)=round(64*(floww(:,:,1)))+(2^15);
    floww(:,:,2)=round(64*(floww(:,:,2)))+(2^15);
    imwrite(uint16(floww), 'Flow.png');
    F_est = flow_read('Flow.png');
    Flow_inlier=nnz(floww(:,:,3));
    [F_err,n_total,Flow_n_inlier] = flow_error(F_gt,F_est,tau);
    F_err=F_err*100;
    % % Writing post-processed results and evaluation
    % %  D1       
    imwrite(uint16(round(D1post*255)), 'D1p.png');
    D1post=[];D1=[];
    D1p_est = disp_read('D1p.png');
    [D1np_totalp,D1p_err,D1pnum,INLD1] = disp_error(D1_gt,D1p_est(1:size(I1_l,1),1:size(I1_l,2)),tau);
    D1p_err=100*D1p_err;
    D1p_inlier=nnz(D1post); 
    % % D2 
    imwrite(uint16(round(D2post(1:size(I1_l,1),1:size(I1_l,2))*255)), 'D2p.png');D2post=[];D2=[];
    D2p_est = disp_read('D2p.png');
    [D2pn_totalp,D2p_err,D2pnum,INLD2] = disp_error(D2_gt,D2p_est(1:size(I1_l,1),1:size(I1_l,2)),tau);
    D2p_err=100*D2p_err;     
    D2p_inlier=nnz(D2post);
    % %  Flow   
    Flow_post(:,:,1)=round(64*(Flow_post(1:size(I1_l,1),1:size(I1_l,2),1)))+(2^15);
    Flow_post(:,:,2)=round(64*(Flow_post(1:size(I1_l,1),1:size(I1_l,2),2)))+(2^15);
    Flow_post(:,:,3)=Flow_post(1:size(I1_l,1),1:size(I1_l,2),3);
    imwrite(uint16(Flow_post), 'Flowp.png');
    F_est = flow_read('Flowp.png');
    FlowNUM=nnz(Flow_post(:,:,3));
    [Fp_err,Np_total,Flowp_n_inlier] = flow_error(F_gt,F_est,tau);
    Fp_err=Fp_err*100;
    Flowp_inlier=nnz(Flow_post(:,:,3));
end
['  D1       D1p       D2        D2p      Flow        Flowp']
[D1_err D1p_err D2_err D2p_err F_err Fp_err]
['  D1_n        D1p_n        D2_n        D2p_n      Flow_n      Flowp_n']  
[D1_inlier INLD1 D2_inlier INLD2 Flow_inlier Flowp_inlier]    
Time=timee
  