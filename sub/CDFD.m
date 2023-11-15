function  [Index,InNUM,matches]=CDFD(I1_l, I2_l, I1_r, I2_r,M1L_1R,PAR,Index)

% Get the parameters 
PARAM.phaseLR = PAR.phaseLR;
PARAM.phaseLR1 = PAR.phaseLR1;
PARAM.distt = PAR.distt;
PARAM.phaseLR11 = PAR.phaseLR11;

% Left to Right phase analysis
 if PAR.inlier
     if PAR.coarse
 [Index, M1L_1R(:,3:4)]= newPHA(M1L_1R(:,1:2),M1L_1R(:,3:4),Index, PARAM);
     end
 end
% first right to second right LKT
block12= TemporalBlock(PAR);
[M1R_2R,Index] = tracking(M1L_1R(:,3:4),Index,I1_r,I2_r,block12,PAR.pyramid1to2);

% Spatial correlation (SCRR)
 if PAR.inlier
          if PAR.coarse
 Index=SCA(M1R_2R(:,1:2),M1R_2R(:,3:4),I1_r,PAR,Index,I2_r);
          end
 end
 
% second right to second left LKT
blockLR= BlockLR(PAR,1);
[M2R_2L, Index] = tracking(M1R_2R(:,3:4),Index,I2_r,I2_l, blockLR,PAR.pyramidLR);

% Right to Left phase analysis
     if PAR.inlier
              if PAR.coarse
 [Index,M2R_2L(:,1:2)]= newPHA(M2R_2L(:,3:4),M2R_2L(:,1:2),Index, PARAM);
              end
     end
% second left to first left LKT
[M2L_1L,Index] = tracking(M2R_2L(:,3:4),Index,I2_l,I1_l,block12,PAR.pyramid1to2);

% Spatial correlation (SCRR)
 if PAR.inlier
          if PAR.coarse

   Index=SCA(M2L_1L(:,1:2),M2L_1L(:,3:4),I1_l,PAR,Index,I2_l);
          end
 end
% Fine Decision
matches(:,1:4) = M1L_1R(Index==1,:);
matches(:,5:6) = M1R_2R(Index==1,3:4);
matches(:,7:8) = M2R_2L(Index==1,3:4);
matches(:,9:10) = M2L_1L(Index==1,3:4);
 if PAR.inlier
          if PAR.fine

dist = distance(matches(:,9),matches(:,10),matches(:,1),matches(:,2));
y1= [matches(:,1:2) matches(:,3:4)];y2= [matches(:,3:4) matches(:,5:6)];
y3= [matches(:,5:6) matches(:,7:8)];y4 = [matches(:,7:8) matches(:,9:10)];
threshold = PAR.tresh*(distance(y1(:,1),y1(:,2),y1(:,3),y1(:,4))+ ...
    distance(y2(:,1),y2(:,2),y2(:,3),y2(:,4))+ ...
    distance(y3(:,1),y3(:,2),y3(:,3),y3(:,4))+...
    distance(y4(:,1),y4(:,2),y4(:,3),y4(:,4)));
  matches = matches(dist < threshold,:);
          end
 end
 
InNUM = size(matches,1);
end