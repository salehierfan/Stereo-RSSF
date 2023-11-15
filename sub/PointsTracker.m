function [PointsResult,Idx]= PointsTracker(CG,img_1l,img_1r,PAR,Idx)
% % LK search block
col=ceil(PAR.horANDvertRatio*PAR.LKhorizon);
if mod(PAR.LKhorizon,2)==0
    PAR.LKhorizon=PAR.LKhorizon+1;end
if col==1
col=col+4;
elseif col==2
    col=col+3;
elseif col==3
    col=col+2;
elseif col==4
    col=col+1;
end
if mod(col,2)==0
    col=col+1;end
if mod(ceil(PAR.LKhorizon),2)==0
    PAR.LKhorizon=ceil(PAR.LKhorizon)+1;
end
Block=[ceil(PAR.LKhorizon) col];Pyramid=PAR.pyramidLR;
% % Tracking
[PointsResult, Idx] = tracking(CG, Idx, img_1l, img_1r, Block, Pyramid);
end