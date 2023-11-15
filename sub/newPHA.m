function [IndexOut,spac] = newPHA(Start, Final, Index, PARAM)
% This function implement phase analyzer

% select inputs based on index
Index = logical(Index);
ind = find(Index);

% compute slope2 and magnitude
xdiff = Start(Index,1) - Final(Index,1);
ydiff = Start(Index,2) - Final(Index,2);
ydiff2 = ydiff.* ydiff;
xdiff2 = xdiff.* xdiff;
dist2 = xdiff2 + ydiff2;
slope2 = ydiff2./dist2;    

% index of points that should be kept
subind = (slope2 < sind(PARAM.phaseLR)^2 & xdiff > 0) | ...
    (slope2 < sind(PARAM.phaseLR1)^2 & xdiff > 0 & dist2 < PARAM.distt^2);

subindd = (slope2 > sind(PARAM.phaseLR)^2 & xdiff > 0 & slope2 < sind(PARAM.phaseLR11)^2) | ...
    (slope2 < sind(PARAM.phaseLR11)^2 & xdiff > 0 & dist2 < PARAM.distt^2 & slope2 > sind(PARAM.phaseLR1)^2);

% final index
IndexOut = Index;
IndexOut1 = Index;

IndexOut(ind(~subind)) = 0;
IndexOut1(ind(~subindd)) = 0;
IndexOut=IndexOut | IndexOut1;
spac = zeros(size(Start));
spac(find(IndexOut1>0),:)= [Start(IndexOut1,1) Final(IndexOut1,2)];
spac(IndexOut,:)= Final(IndexOut,:);

end