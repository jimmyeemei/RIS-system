function [h_BR_LOS] = h_BR_LOS(LOS_AOA_BR,LOS_ZOA_BR,LOS_AOD_BR,LOS_ZOD_BR,tilt_BS,...
    d_BR,k1,k2,s,lambda,RIS_nm,BS_antenna,F_RIS_LOS_BR)
%% %%%%%% 20221202 %%%%%% %%
%% %%%%%% 簇/子径信道系数计算LOS信道系数计算 %%%%%%
%% 发送天线的辐射方向图
[A_dB_vertical,A_dB_horizontal] = Field_3GPP(LOS_AOD_BR,LOS_ZOD_BR,tilt_BS);

%% %%%%%% 第一个指数项 %%%%%%
temp1 = exp(-1i*2*pi*d_BR(k1,k2,s)/lambda);

%% %%%%%% 第二个指数项 %%%%%%
%% Tx-RIS子逻辑链路LOS波达径
r_BR_tx_LOS = [sind(LOS_ZOD_BR)*cosd(LOS_AOD_BR); sind(LOS_ZOD_BR)*sind(LOS_AOD_BR); cosd(LOS_ZOD_BR)];

%% RIS单元的位置矢量
d_rx = RIS_nm';
temp2 = exp(1i*2*pi*r_BR_tx_LOS'*d_rx/lambda);

%% %%%%%% 第三个指数项 %%%%%%
%% Tx-RIS子逻辑链路
r_BR_rx_LOS = [sind(LOS_ZOA_BR)*cosd(LOS_AOA_BR); sind(LOS_ZOA_BR)*sind(LOS_AOA_BR); cosd(LOS_ZOA_BR)];

%% Tx单元的位置矢量
d_tx = BS_antenna(s,:)';
temp3 = exp(1i*2*pi*r_BR_rx_LOS'*d_tx/lambda);



%% Tx-RIS子逻辑链路LOS信道系数
h_BR_LOS = F_RIS_LOS_BR*[1 0; 0 -1]*[A_dB_vertical; A_dB_horizontal]*temp1*temp2*temp3;

end
