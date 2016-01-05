function g = plot3k(L,c,crange,mark,nlab,strs,varargin)
% PLOT3K  Color coded 3D scatterplot
%    g = plot3k(L,c,crange,mark,nlab,strs,varargin)
% Input
%    L         x,y,z location vector, n x 3
%              or an n x m matrix
%              or 3 element cell array containing x, y and z
%    c         color vector,              default = 3rd column of L
%    crange    range of color indices     [min max], [max min] or []
%                                         default = [min(c) max(c)]
%    mark      marker character and size, default = {'.',6}
%    nlab      number of colorbar labels, default = 10
%    strs      cell arrary of label strings, {title xlabel ylabel zlabel}
%    varargin  optional axes property,value arguments
% Output
%    g         figure handle for the plot
%
% Generate a 3D point plot of L=(x,y,z) using the values in the vector c to
% determine the color of each point.  If c is empty, then z (column 3 of L)
% is used to color the plot.  The data points are sorted so that plot3 is
% only called once for each group of points that map to the same color.  The
% upper and lower limits of the color range (and the z axis) can be defined
% with crange.  This is useful for creating a series of plots with the same
% coloring.  The colormap (but not the colorbar) is flipped upside down if
% crange is given as [max min] instead of [min max].  The figure handle is
% returned if an output argument is given.  
%
% Example
%    [x,y,z] = peaks(101);
%    plot3k({x y z},gradient(z),[-0.5 0.5],{'o',2},11,{'Peaks'},...
%           'FontName','Arial','FontSize',18,'FontWeight','Bold');
%    - a point-by-point plot of the peaks function is drawn using the
%      gradient of z to color each point
%
% Ken Garrard, North Carolina State University, 2005, 2008
% Based on plot3c by Uli Theune, University of Alberta
%
% 2008.11.07  Updated color range and marker arguments

if nargin < 1
   figure;
   [x,y,z] = peaks(101);
   plot3k({x y z},gradient(z),[-0.5 0.5],{'o',2},11,{'Peaks'},...
          'FontName','Arial','FontSize',18,'FontWeight','Bold');
   error(['No input arguments given\n'...
          'Please consult the help text and the example plot\n'...
          '--------\n%s'],help(mfilename));
end

% check for cell array location data

% convert singleton cell array to its contents
while iscell(L) && length(L) == 1, L = L{1}; end

if iscell(L)
   
   % cell array input must have three elements
   if length(L) ~= 3
      error('Location cell array must contain three elements');
   end

   % convert cell array elements to column vectors
   x = L{1}(:);   y = L{2}(:);   z = L{3}(:);
   
   % equal length x, y and z vectors ?
   if ~isequal(length(x),length(y),length(z))
      error('Location cell array elements must be same length');
   end

   % convert to n x 3 matrix
   L = [x y z];

% location data may be a 2d matrix
elseif ndims(L) == 2 && size(L,2) > 3
   sz = size(L);

   % use pixel values for x,y
   [x,y] = meshgrid(1:sz(2),1:sz(1));

   % convert to n x 3 matrix
   L = [x(:) y(:) L(:)];
   
% otherwise location data must be a three column vector
elseif size(L,2) ~= 3
   error('Location vector must have 3 columns');
end

% set defaults for missing arguments
if nargin < 2 || isempty(c),    c     = L(:,3);        end % color by z values
if nargin < 4 || isempty(mark), mark  = {'.',6};       end % marker is 6pt '.'
if nargin < 5 || isempty(nlab), nlab  = 10;            end % 10 colorbar labels
if nargin < 6 || isempty(strs), strs  = {'','','',''}; end % no plot labels

% color vector must be same length as x,y,z location data
c = c(:);
if length(L) ~= length(c)
   error('Location vector and color vector must be the same length');
end

% validate marker character
if ~iscell(mark), mark_ch = mark;  mark_sz = 6;
else
    mark_ch = mark{1};
    if length(mark)>1, mark_sz = mark{2};
    else               mark_sz = 6;
    end
end
marker_str = '+o*.xsd^v><ph';
if (length(mark_ch) ~= 1) || isempty(strfind(marker_str,mark_ch))
   error('Invalid marker character, select one of ''%s''', marker_str);
end
mark_sz = max(mark_sz,0.5);

% validate label strings cell array structure
if ~iscell(strs)
   error('label argument should be a cell arrary with title and x,y,z strings');
end

% find color limits and range
if nargin < 3 || isempty(crange)   % auto
   min_c   = min(c);
   max_c   = max(c);
else                               % user specified
   min_c = crange(1);
   max_c = crange(2);
end
range_c = max_c - min_c;

% get current colormap
cmap = colormap;
if range_c < 0, cmap = flipud(cmap); end
clen = length(cmap);

% calculate color map index for each point
L(:,4) = min(max(round((c-min(min_c,max_c))*(clen-1)/abs(range_c)),1),clen);

% sort by color map index
L = sortrows(L,4);

% build index vector of color transitions (last point for each color)
dLix = [find(diff(L(:,4))>0); length(L)];

% plot data points in groups by color map index
hold on;                           % add points to one set of axes
s = 1;                             % index of 1st point in a  color group
for k = 1:length(dLix)             % loop over each non-empty color group
   plot3(L(s:dLix(k),1), ...       % call plot3 once for each color group
         L(s:dLix(k),2), ...
         L(s:dLix(k),3), ...
         mark_ch,           ...
         'MarkerSize',mark_sz, ...
         'MarkerEdgeColor',  cmap(L(s,4),:)  ); % , ... % same marker color from cmap
         % 'MarkerFaceColor',cmap(L(s,4),:) );   %   for all points in group
   s = dLix(k)+1;                  % next group starts at next point
end
hold off;

% set plot characteristics
view(3);                           % use default 3D view, (-37.5,30)
grid on;
if isempty(varargin)
     set(gca,'FontName','Arial','FontSize',10,'FontWeight','bold');
else set(gca,varargin{:});
end

% add title and axes labels
filler = repmat({''},4-length(strs),1);
strlab = {strs{:} filler{:}};

title (strlab{1});
xlabel(strlab{2});
ylabel(strlab{3});
zlabel(strlab{4});

% format the colorbar
h    = colorbar;
nlab = abs(nlab);                        % number of labels must be positive
set(h,'YLim',[1 clen]);                  % set colorbar limits
set(h,'YTick',linspace(1,clen,nlab));    % set tick mark locations

% create colorbar tick labels based on color vector data values
tick_vals = linspace(min_c,max_c,nlab);

% create cell array of color bar tick label strings
labels = cell(1,nlab);
warning off MATLAB:log:logOfZero;
for i = 1:nlab
   if abs(min(log10(abs(tick_vals)))) <= 3, fm = '%-4.3f';   % fixed
   else                                     fm = '%-4.2E';   % floating
   end
   labels{i} = sprintf(fm,tick_vals(i));
end
warning on MATLAB:log:logOfZero;

% set tick label strings
set(h,'YTickLabel',labels,'FontName','Arial','FontSize',9,'FontWeight','bold');

if nargout > 0, g = gcf; end             % return figure handle
