
clc;clear;close all;dbstop error;
data_params1 = 'F:\my paper\clearCODE\data_scene_flow\training\image_2/';
data_params2 = 'F:\my paper\clearCODE\data_scene_flow\training\image_3/';
img_files1 = dir(strcat(data_params1,'*.png'));img_files2 = dir(strcat(data_params2,'*.png'));
num_of_images = length(img_files1);tau = [3 0.05];
 opticFlow = opticalFlowHS;

  for t =1:num_of_images
img = imread(([img_files1(t).folder, '/', img_files1(t).name]));
frameGray = im2gray(img); figure,imshow(img)
 
flow = estimateFlow(opticFlow,frameGray);
% flow_valid= zeros(size(flow_v));%flow_u=medfilt2(flow_u); flow_v=medfilt2(flow_v);
 floww(:,:,1)=(65*flow.Vx); floww(:,:,2)=(65*flow.Vy);fl1=floww(:,:,1)>0;fl2=floww(:,:,2)>0;

 floww(:,:,3)=fl1 & fl2;
% FLOWzarbshode{xx,t}= medfilt2(floww);
figure,imshow(floww)
 % %      img(:,:,1)=round(65*img(:,:,1))+(2^15);img(:,:,2)=round(65*img(:,:,2))+(2^15);
%  imwrite(uint16(img), img_files1(i).name);
  end
for t =1:num_of_images   
D_est = disp_read(([img_files1(t).folder, '/', img_files1(t).name]));
D_gt = disp_read([img_files2(t).folder, '/', img_files2(t).name]);
d_err(t) = disp_error(D_gt,D_est,tau);
end
mean (d_err*100)