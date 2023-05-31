function [A_dB_vertical,A_dB_horizontal] = Field_3GPP(phi,theta,tilt_BS)

%% 3GPP辐射方向图 表7.3-1
G_Emax = 8;
%% LOS情形
%% 垂直辐射方向图
SLA_v = 30;
theta_3dB = 65;
A_dB_vertical = G_Emax - min(12*((theta - 90)/theta_3dB)^2,SLA_v);

%% 水平辐射方向图
A_max = 30;
phi_3dB = 65;
A_dB_horizontal = G_Emax - min(12*(phi/phi_3dB)^2,A_max);

%% 最终辐射方向图(dB或线性值?)
A_dB_vertical = sqrt(A_dB_vertical)*cosd(tilt_BS);
A_dB_horizontal = sqrt(A_dB_horizontal)*sind(tilt_BS);
