function [h_RU_LOS] = h_RU_LOS(LOS_AOD_RU,LOS_ZOD_RU,LOS_AOA_RU,LOS_ZOA_RU,tilt_UE,...
    d_RU,k1,k2,u,lambda,RIS_nm,UE_antenna,v,phi_U,psi_U,t,F_RIS_LOS_RU)
%% %%%%%% 簇/子径信道系数计算LOS信道系数计算 %%%%%%
%F_RIS_theta = radiation_pattern(LOS_ZOD_RU + 90);
%F_RIS_phi = radiation_pattern(LOS_AOD_RU + 90);

%% RIS的辐射方向图
%F_RIS = [F_RIS_theta; F_RIS_phi];

%% 发送天线的辐射方向图
[A_dB_vertical,A_dB_horizontal] = Field_3GPP(LOS_AOA_RU,LOS_ZOA_RU,tilt_UE);

%% %%%%%% 第一个指数项 %%%%%%
temp1 = exp(-1i*2*pi*d_RU(k1,k2,u)/lambda);

%% %%%%%% 第二个指数项 %%%%%%
%% RIS-UE子逻辑链路LOS波达径
r_RU_tx_LOS = [sind(LOS_ZOA_RU)*cosd(LOS_AOA_RU); sind(LOS_ZOA_RU)*sind(LOS_AOA_RU); cosd(LOS_ZOA_RU)];

%% RIS单元的位置矢量
d_tx = RIS_nm';
temp2 = exp(1i*2*pi*r_RU_tx_LOS'*d_tx/lambda);

%% %%%%%% 第三个指数项 %%%%%%
%% RIS-UE子逻辑链路
r_RU_rx_LOS = [sind(LOS_ZOD_RU)*cosd(LOS_AOD_RU); sind(LOS_ZOD_RU)*sind(LOS_AOD_RU); cosd(LOS_ZOD_RU)];

%% Tx单元的位置矢量
d_rx = UE_antenna(u,:)';
temp3 = exp(1i*2*pi*r_RU_rx_LOS'*d_rx/lambda);

%% %%%%%% 第四个指数项 %%%%%%
v = v/3.6; % m/s
v_bar = v.*[sind(phi_U)*cosd(psi_U) sind(phi_U)*cosd(psi_U) cosd(phi_U)]';
temp4 = exp(1i*2*pi*r_RU_rx_LOS'*v_bar*t/lambda);

%% Tx-RIS子逻辑链路LOS信道系数
h_RU_LOS = [A_dB_vertical,A_dB_horizontal]*[1 0; 0 -1]*F_RIS_LOS_RU*temp1*temp2*temp3*temp4;

end
