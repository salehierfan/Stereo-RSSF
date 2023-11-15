function D = DispPostProc(D,PAR)
FIRST1= imgaussfilt(D, PAR.GFsigma);
SECOND1= imgaussfilt(double(D>0), PAR.GFsigma);
FINAL1=zeros(size(FIRST1));
FINAL1(SECOND1>0)=FIRST1(SECOND1>0)./SECOND1(SECOND1>0);
AbsError1=abs(FINAL1-D);
Coef = 1;
RelError1 = AbsError1./(abs(FINAL1)+Coef);
% D(AbsError1>PAR.FLtresh1(xx) & RelError1>PAR.FLtresh3(xx) & SECOND1>PAR.FLtresh2(xx))=0;
  D(AbsError1>PAR.FLtresh1)=0;

% D(AbsError1>PAR.FLtresh1(xx))=FINAL1(AbsError1>PAR.FLtresh1(xx));


REJECT1 = imgaussfilt(double(D>0), PAR.REJsigma);
D(REJECT1<PAR.REJtresh)=0;
end

