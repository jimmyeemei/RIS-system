function [h_RU_NLOS_clu] = h_RU_NLOS(phi_RU_nm_AOD,theta_RU_nm_ZOD,phi_RU_nm_AOA,theta_RU_nm_ZOA,tilt_UE,...
    u,lambda,UE_antenna,RIS_nm,N_RU,Pn_RU,v,phi_U,psi_U,t,F_RIS_RU,mu_XPR,sigma_XPR)
%% %%%%%% 簇/子径信道系数计算NLOS信道系数计算 %%%%%%
h_RU_NLOS = zeros(N_RU,20);
for n = 1:N_RU
    for m = 1:20
%% RIS的辐射方向图
F_RIS_RU_temp = [F_RIS_RU(n,m,1),F_RIS_RU(n,m,2)];

%% 接收天线的辐射方向图
[A_dB_vertical,A_dB_horizontal] = Field_3GPP(phi_RU_nm_AOA(n,m),theta_RU_nm_ZOA(n,m),tilt_UE);

%% %%%%%% 第一个指数项 %%%%%%
%% RIS-Rx子逻辑链路波离径
r_RU_tx_nm = [sind(theta_RU_nm_ZOD(n,m))*cosd(phi_RU_nm_AOD(n,m)); sind(theta_RU_nm_ZOD(n,m))*sind(phi_RU_nm_AOD(n,m)); cosd(theta_RU_nm_ZOD(n,m))];

%% UE单元的位置矢量
d_rx = UE_antenna(u,:)';
temp1 = exp(1i*2*pi*r_RU_tx_nm'*d_rx/lambda);

%% %%%%%% 第二个指数项 %%%%%%
%% RIS-Rx子逻辑链路波达径
r_BR_rx_nm = [sind(theta_RU_nm_ZOA(n,m))*cosd(phi_RU_nm_AOA(n,m)); sind(theta_RU_nm_ZOA(n,m)*sind(phi_RU_nm_AOA(n,m))); cosd(theta_RU_nm_ZOA(n,m))];

%% RIS单元的位置矢量
d_tx = RIS_nm';
temp2 = exp(1i*2*pi*r_BR_rx_nm'*d_tx/lambda);

%% %%%%%% 第三个指数项 %%%%%%
%% 交叉极化增益
XPR_BR_nm = normrnd(mu_XPR,sigma_XPR,N_RU,20);
%% 初始相位角(单位degrees)
% (-pi,pi)的均匀分布
InitialPhases = -pi + 2*pi.*rand(1,4);
temp3 = [exp(1i*InitialPhases(1)) sqrt(XPR_BR_nm(n,m)^(-1))*exp(1i*InitialPhases(2));...
    sqrt(XPR_BR_nm(n,m)^(-1))*exp(1i*InitialPhases(3)) exp(1i*InitialPhases(4))];
%% %%%%%% 第四个指数项 %%%%%%
v = v/3.6; % m/s
v_bar = v.*[sind(phi_U)*cosd(psi_U) sind(phi_U)*cosd(psi_U) cosd(phi_U)]';
temp4 = exp(1i*2*pi*r_RU_tx_nm'*v_bar*t/lambda);

%% Tx-RIS子逻辑链路LOS信道系数
h_BR_NLOS_temp = sqrt(Pn_RU(n)/20).*F_RIS_RU_temp*temp3*[A_dB_vertical; A_dB_horizontal]*temp1*temp2*temp4;
h_RU_NLOS(n,m) = h_BR_NLOS_temp; 
    end
end
h_RU_NLOS_clu = sum(h_RU_NLOS,2);

end

