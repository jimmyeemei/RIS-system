function [UL_PRB,DL_PRB]=cost_PRB(resourceGrid,cost_UL,cost_DL)
UL_useful_PRB= floor(resourceGrid.nRBFreq);%*(1-cost_UL));
DL_useful_PRB= floor(resourceGrid.nRBFreq);%*(1-cost_DL));

if  UL_useful_PRB<=273
UL_PRB =ones(UL_useful_PRB,1);
else
UL_PRB =ones(264,1);    
end
if DL_useful_PRB<=264
DL_PRB =ones(DL_useful_PRB,1);
else
  DL_PRB =ones(264,1);
end
% if UL_useful_PRB<=273&&UL_useful_PRB>=1
%     UL_PRB =ones(UL_useful_PRB,1);
%  elseif UL_useful_PRB>273
%     UL_PRB =ones(273,1);
% else
%    error('exceed cost');  
% end
% if DL_useful_PRB<=273&&DL_useful_PRB>=1
%     DL_PRB =ones(DL_useful_PRB,1);
%  elseif DL_useful_PRB>273
%     DL_PRB =ones(273,1);
% else
%    error('exceed cost');  
% end
end