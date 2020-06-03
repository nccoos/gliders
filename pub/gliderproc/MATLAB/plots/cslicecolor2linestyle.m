function cslicecolor2linestyle(h)
%CSLICECOLOR2BW(H) Function takes the handles of patches returned by CONTOURSLICE
% and alters the contour slice such that each color corresponds to a LineSpec.
% The LineSpec is {'-','--',':','-.'}, and repeats through the colors found in the
% contour slice.
%
% Calls: none

% Find all the unique colors
colors = get(h,'cdata');
colors=unique(cat(1,colors{:}));
colors=colors(~isnan(colors));

% Loop through all the patches returned by CONTOURSLICE, and designate a linestyle for each
% Define the line style (note that this can be changed since the code is written generally)
linespec = {'-','--',':','-.'};
linestyles = repmat(linespec,1,ceil(length(colors)/length(linespec)));
linestyles = {linestyles{1:length(colors)}};

for n=1:length(h)
    % Find the unique color number associated with the handle
    color = find(max(get(h(n),'cdata'))==colors);
    % Convert the color to the associated linestyle
    linestyle = linestyles{color};
    set(h(n),'linestyle',linestyle);
end
