function [PointsResult, IndexResult] = tracking(Point, Index, FirstIm, SecondIm, Block, Pyramid)
% This function tracking points from left image to right image

% Create the tracker
tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', Pyramid,'BlockSize',Block,'MaxIterations',20);

% Select Points for which the index is True
PointsIn = Point(find(Index==1),:);
refIndex = find(Index);

% Apply the tracker on points
initialize(tracker, PointsIn, FirstIm);
[PointsOut, isFoundrl] = step(tracker, SecondIm);

% Create the resulting points with correct indexing
IndexResult = Index;
IndexResult(refIndex(isFoundrl==0)) = 0;
PointsResult = zeros(size(Point,1),4);
PointsResult(refIndex(isFoundrl),1:2) = PointsIn(isFoundrl,:);
PointsResult(refIndex(isFoundrl),3:4) = PointsOut(isFoundrl,:);