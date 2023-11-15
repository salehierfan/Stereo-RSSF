function PHASEe = PHASE(FirstFeatures,SecondFeatures)
for q=1:size(FirstFeatures,1)
x0 = FirstFeatures(q,1);x1 =SecondFeatures(q,1);
y0 = FirstFeatures(q,2);y1 = SecondFeatures(q,2);
if x1>x0 && y1>y0
PHASEe(q,1)=atand(abs((y1-y0)/(x1-x0)));
elseif x1>x0 && y1<y0
PHASEe(q,1)=360-atand(abs((y1-y0)/(x1-x0))); 
elseif x1<x0 && y1>y0
PHASEe(q,1)=180-atand(abs((y1-y0)/(x1-x0)));
else PHASEe(q,1)=180+atand(abs((y1-y0)/(x1-x0)));
end
end
%  PHASEe=PHASEe+90;
% w=(find(PHASEe>360));
% PHASEe(w)=PHASEe(w)-360;
end
