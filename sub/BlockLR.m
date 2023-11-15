function block= BlockLR(PAR,x)

col=ceil(PAR.horANDvertRatio(1,x)*PAR.LKhorizon(1,x));
if mod(PAR.LKhorizon(1,x),2)==0
    PAR.LKhorizon(1,x)=PAR.LKhorizon(1,x)+1;end
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
if mod(ceil(PAR.LKhorizon(1,x)),2)==0
    PAR.LKhorizon(1,x)=ceil(PAR.LKhorizon(1,x))+1;
end
block =[ceil(PAR.LKhorizon(1,x)) col];
end

