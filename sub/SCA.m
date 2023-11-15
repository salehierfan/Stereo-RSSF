function Ind=SCA(a,b,I1_l,PAR,Indx,I2_l)
w=[a b];
%blocking process (by increasing PAR.blockY, the block size and RT are decreased )
addresX=round(linspace(1,size(I1_l,1),PAR.blockY));
addresY=round(linspace(1,size(I1_l,2),PAR.blockX));

a1=a(:,1);a2=a(:,2);finalPOINTS=[];
%cutoff freauency
cutoff = ceil(3*PAR.sigma);
% gaussian filter mask with cutoff frequency and sigma
h = fspecial('gaussian',[1,2*cutoff+1],PAR.sigma); % 1D filter
% blockprocessing
for i=1:size(addresX,2)-1
    for j=1:size(addresY,2)-1
ax=addresX(1,i);ay=addresX(1,i+1);
bx=addresY(1,j);by=addresY(1,j+1);
% block addresses to find matched features in that areas (FinFe)
Bb = w((a1>bx & a1<=by & a2>ax & a2<=ay),:);
 FinFe=Bb; 
%  PHASE analysing
 if size(FinFe,1)>1 
     PHASEe = PHASE(FinFe(:,1:2),FinFe(:,3:4));
% Histogram of PHASE with PAR.BINnum bin width
[N,edges] = histcounts(PHASEe,[0:360/PAR.BINnum:360]);
aa =N;
res = circshift(cconv(aa,h,length(aa)),-(length(h)-1)/2);

phaseeMAIN= edges(find(res>PAR.distTH*max(res)));
lastPOINTS=[];
for q=1:size(phaseeMAIN,2)
add=find(PHASEe<phaseeMAIN(q)+360/PAR.BINnum & PHASEe>=phaseeMAIN(q));
    lastPOINTS(size(lastPOINTS,1)+1:size(lastPOINTS,1)+size(add,1),:)=FinFe(add,:);
end
finalPOINTS(size(finalPOINTS,1)+1:size(finalPOINTS,1)+size(lastPOINTS,1),:)=lastPOINTS;
  end
    end
end
[~,pos]=intersect(w(:,1),finalPOINTS(:,1));
if PAR.verbosity
    figure,subplot(2,1,2),showMatchedFeaturesNew(I2_l, I1_l,w(pos(1:14:end),1:2),w(pos(1:14:end),3:4)) 
    subplot(2,1,1),showMatchedFeaturesNew(I2_l, I1_l,w(1:14:end,1:2),w(1:14:end,3:4)) 
end
    final=zeros(size(w));final(pos,:)=w(pos,:);
  Ind=zeros(size(Indx,1),1);
  Ind(pos)=1;