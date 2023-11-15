function hImage = showMatchedPoints(I1, I2, matchedPoints1, matchedPoints2, varargin)

if nargin > 4
    [varargin{:}] = convertStringsToChars(varargin{:});
end

narginchk(4,9);
 
[matchedPoints1, matchedPoints2, method, lineSpec, hAxes] = ...
    parseInputs(I1, I2, matchedPoints1, matchedPoints2, varargin{:});

% pad the smaller image
paddedSize = [max(size(I1,1), size(I2,1)), max(size(I1,2), size(I2,2))];
I1pad = [paddedSize(1) - size(I1,1), paddedSize(2) - size(I1,2)];
I2pad = [paddedSize(1) - size(I2,1), paddedSize(2) - size(I2,2)];
I1pre = round(I1pad/2);
I2pre = round(I2pad/2);
I1 = padarray(I1, I1pre, 0, 'pre');
I2 = padarray(I2, I2pre, 0, 'pre');
I1 = padarray(I1, I1pad-I1pre, 0, 'post');
I2 = padarray(I2, I2pad-I2pre, 0, 'post');

switch lower(method)
    case {'falsecolor'}
        imgOverlay = imfuse(I1, I2);
        % create red-cyan image instead of the imfuse default
        imgOverlay(:,:,1) = imgOverlay(:,:,2);
        imgOverlay(:,:,2) = imgOverlay(:,:,3);
    case {'blend'}
        imgOverlay = imfuse(I1,I2,'blend');        
    case {'montage'}
        imgOverlay = imfuse(I1,I2,'montage');
end

% Display the composite image
if nargout > 0
    hImage = imshow(imgOverlay, 'Parent', hAxes);
else
    imshow(imgOverlay, 'Parent', hAxes);
end

holdState = get(hAxes,'NextPlot'); % store the state for 'hold' before changing it
set(hAxes, 'NextPlot', 'add');

%============
% Plot points
%============
% Calculate the offsets needed to adjust plot after images were fused
offset1 = fliplr(I1pre);
offset2 = fliplr(I2pre);
if strcmp(method, 'montage')
    offset2 = offset2 + fliplr([0 size(I1,2)]);
end

matchedPoints1 = bsxfun(@plus, matchedPoints1, offset1);
matchedPoints2 = bsxfun(@plus, matchedPoints2, offset2);

if ~isempty(lineSpec{1})
    plot(hAxes, matchedPoints1(:,1), matchedPoints1(:,2), lineSpec{1}); % marker 1
end
if ~isempty(lineSpec{2})
    plot(hAxes, matchedPoints2(:,1), matchedPoints2(:,2), lineSpec{2}); % marker 2
end

% Plot by using a single line object with line segments broken by using
% NaNs. This is more efficient and makes it easier to customize the lines.
lineX = [matchedPoints1(:,1)'; matchedPoints2(:,1)'];
numPts = numel(lineX);
lineX = [lineX; NaN(1,numPts/2)];

lineY = [matchedPoints1(:,2)'; matchedPoints2(:,2)'];
lineY = [lineY; NaN(1,numPts/2)];

plot(hAxes, lineX(:), lineY(:), lineSpec{3}); % line

set(hAxes, 'NextPlot', holdState); % restore the hold state

drawnow();

%==========================================================================
% Input parser
%==========================================================================
function [matchedPoints1, matchedPoints2, method, lineSpec, hAxes] = ...
    parseInputs(I1, I2, matchedPoints1, matchedPoints2, varargin)

% do only basic image validation; let padarray and imfuse take care of 
% the rest
validateattributes(I1,{'numeric','logical'},{'real','nonsparse',...
    'nonempty'},mfilename,'I1',1)
validateattributes(I2,{'numeric','logical'},{'real','nonsparse',...
    'nonempty'},mfilename,'I2',2)

matchedPoints1 = parsePoints(matchedPoints1, 1);
matchedPoints2 = parsePoints(matchedPoints2, 2);

if size(matchedPoints1,1) ~= size(matchedPoints2,1)
    error(message('vision:showMatchedFeatures:numPtsMustMatch'));
end

% Process the rest of inputs
parser = inputParser;
parser.FunctionName  = mfilename;

parser.addOptional('Method', 'falsecolor', @checkMethod);
parser.addParameter('PlotOptions', {'ro','g+','y-'}, @checkPlotOptions);
parser.addParameter('Parent', [], ...
    @vision.internal.inputValidation.validateAxesHandle);

% Parse inputs
parser.parse(varargin{:});

% Calling validatestring again permits easy handling of partial string matches
method = validatestring(parser.Results.Method,...
    {'falsecolor','blend','montage'},mfilename,'Method');

lineSpec = parser.Results.PlotOptions;

hAxes = newplot(parser.Results.Parent);

%==========================================================================
function points=parsePoints(points, ptsInputNumber)

fcnInputVarNumber = 2 + ptsInputNumber; 
varName = ['matchedPoints', num2str(ptsInputNumber)];

if ~isa(points, 'vision.internal.FeaturePoints') && ~isa(points, 'MSERRegions')
    validateattributes(points,{'int16', 'uint16', 'int32', 'uint32', ...
        'single', 'double'}, {'2d', 'nonsparse', 'real', 'size', [NaN 2]},...
        mfilename, varName, fcnInputVarNumber);
else
    points = points;
%     .Location;
end

points = double(points);

%==========================================================================
function tf = checkMethod(method)

validatestring(method,{'falsecolor','blend','montage'},mfilename,'Method');

tf = true;

%==========================================================================
function tf = checkPlotOptions(options)

validateattributes(options,{'cell'}, {'size', [1 3]},...
    mfilename, 'PlotOptions');

validateattributes(options{1},{'char'},{},mfilename,'MarkerStyle1');
validateattributes(options{2},{'char'},{},mfilename,'MarkerStyle2');
validateattributes(options{3},{'char'},{},mfilename,'LineStyle');

% Now check valid strings
checkMarkerStyle(options{1}, 1);
checkMarkerStyle(options{2}, 2);

checkLineStyle(options{3});

tf = true;

%==========================================================================
function style=eliminateColorSpec(style)

colorSpec = cell2mat({'r','g','b','c','m','y','k','w'});

% Color can be specified only at the beginning or end of the style string.
% Look for only one specifier. If color was specified twice, it will cause
% a failure in later stages of parsing
if ~isempty(style)
    if isempty(strfind(colorSpec, style(1)))
        % try the other end
        if ~isempty(strfind(colorSpec, style(end)))
            style(end) = [];
        end
    else
        style(1) = [];
    end
end

%==========================================================================
function checkMarkerStyle(style, id)

style = strtrim(style); % remove blanks from either end of the string
style = strtrim(eliminateColorSpec(style)); % pull out valid color spec

if isempty(style)
   % permit empty marker style, which amounts to marker not being displayed 
else
    markerSpec = {'+','o','*','.','x','square','s','diamond','d','^',...
        'v','>','<','pentagram','p','hexagram','hImage'};
    
    try
        validatestring(style,markerSpec);
    catch %#ok<CTCH>
        error(message('vision:showMatchedFeatures:invalidMarkerStyle',id));
    end
end

%==========================================================================
function checkLineStyle(style)

style = strtrim(style); % remove blanks from either end of the string
style = strtrim(eliminateColorSpec(style)); % pull out valid color spec

if isempty(style)
    % permit empty line style thus letting plot use its default settings
else
    lineSpec = {'-','--',':','-.'};
    
    try
        validatestring(style,lineSpec);
    catch %#ok<CTCH>
        error(message('vision:showMatchedFeatures:invalidLineStyle'));
    end
end
