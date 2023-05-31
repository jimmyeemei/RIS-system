function [C_phi_NLOS,C_theta_NLOS,alpha_m] = Init_number
%% %%%%%%%%%% 缩放因子查表函数 %%%%%%%%%%
%% AOA/AOD生成的缩放因子 3GPP表7.5-2
C_phi_NLOS = zeros(1,25);
C_phi_NLOS(4) = 0.779; C_phi_NLOS(5) = 0.806;
C_phi_NLOS(8) = 1.018; C_phi_NLOS(10) = 1.090;
C_phi_NLOS(11) = 1.123; C_phi_NLOS(12) = 1.146;
C_phi_NLOS(14) = 1.190; C_phi_NLOS(15) = 1.211;
C_phi_NLOS(16) = 1.226; C_phi_NLOS(19) = 1.273;
C_phi_NLOS(20) = 1.289; C_phi_NLOS(25) = 1.358;

%% ZOA/ZOD生成的缩放因子 3GPP表7.5-4
C_theta_NLOS = zeros(1,25);
C_theta_NLOS(8) = 0.889; C_theta_NLOS(10) = 0.957;
C_theta_NLOS(11) = 1.031; C_theta_NLOS(12) = 1.104;
C_theta_NLOS(15) = 1.1088; C_theta_NLOS(19) = 1.184;
C_theta_NLOS(20) = 1.178; C_theta_NLOS(25) = 1.282;

%% 归一化簇内子路径偏移值 3GPP表7.5-3
alpha_m = zeros(1,20);
alpha_m(1) = 0.0447; alpha_m(2) = -0.0447;
alpha_m(3) = 0.1413; alpha_m(4) = -0.1413;
alpha_m(5) = 0.2492; alpha_m(6) = -0.2492;
alpha_m(7) = 0.3715; alpha_m(8) = -0.3715;
alpha_m(9) = 0.5129; alpha_m(10) = -0.5129;
alpha_m(11) = 0.6797; alpha_m(12) = -0.6797;
alpha_m(13) = 0.8844; alpha_m(14) = -0.8844;
alpha_m(15) = 1.1481; alpha_m(16) = -1.1481;
alpha_m(17) = 1.5195; alpha_m(18) = -1.5195;
alpha_m(19) = 2.1551; alpha_m(20) = -2.1551;

