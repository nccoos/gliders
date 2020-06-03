%function [colors]=colors_jet(ncolors)
function [colors]=colors_jet(ncolors)
cmapjet=jet(64);
size(cmapjet);
njet=ans(1);
for i=1:ncolors
   colors(i,:)=cmapjet(1+round((njet-1)*(i-1)/(ncolors-1)),:);
end
