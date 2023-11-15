function floww = FlowPostProc(floww,PAR)
FIRST1= imgaussfilt(floww(:,:,1), PAR.GFsigma);
SECOND= imgaussfilt(double(floww(:,:,3)), PAR.GFsigma);
FINAL1=zeros(size(FIRST1));
FINAL1(SECOND>0)=FIRST1(SECOND>0)./SECOND(SECOND>0);
res1=(FINAL1-floww(:,:,1));
FINAL2=zeros(size(FIRST1));
FIRST2= imgaussfilt(floww(:,:,2), PAR.GFsigma);
FINAL2(SECOND>0)=FIRST2(SECOND>0)./SECOND(SECOND>0);
res2=(FINAL2-floww(:,:,2));
FL3=floww(:,:,3);
AbsError = sqrt(res2.*res2+res1.*res1);
Coef = 1;
RelError = AbsError./(sqrt(FINAL1.*FINAL1+FINAL2.*FINAL2)+Coef); 
% FL3( (AbsError>PAR.FLtresh1(xx) & RelError>PAR.FLtresh3(xx) ) & SECOND>PAR.FLtresh2(xx))=0;

 FL3(AbsError>PAR.FLtresh1)=0;

% FL3(AbsError>PAR.FLtresh1(xx))=FINAL1(AbsError>PAR.FLtresh1(xx));
% FL3 =FL3>0;
REJECT3 = imgaussfilt(double(FL3>0), PAR.REJsigma);
FL3(REJECT3<PAR.REJtresh)=0;


floww(:,:,3)=FL3;
