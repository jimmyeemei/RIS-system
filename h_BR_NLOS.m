function [h_BR_NLOS_clu] = h_BR_NLOS(phi_BR_nm_AOA,theta_BR_nm_ZOA,phi_BR_nm_AOD,theta_BR_nm_ZOD,tilt_BS,...
    s,lambda,RIS_k,BS_antenna,N_BR,Pn_BR,F_RIS_BR,mu_XPR,sigma_XPR)
%% %%%%%% 20221202 %%%%%% %%
%% %%%%%% 簇/子径信道系数计算NLOS信道系数计算 %%%%%%
h_BR_NLOS = zeros(N_BR,20);
for n = 1:N_BR
    for m = 1:20
        %% RIS的辐射方向图
        F_RIS_BR_temp = [F_RIS_BR(n,m,1),F_RIS_BR(n,m,2)];
        %F_RIS_BR_temp = F_RIS_BR(n,m);  %% 发送天线的辐射方向图
        [A_dB_vertical,A_dB_horizontal] = Field_3GPP(phi_BR_nm_AOD(n,m),theta_BR_nm_ZOD(n,m),tilt_BS);

        %% %%%%%% 第一个指数项 %%%%%%
        %% Tx-RIS子逻辑链路波离径
        r_BR_tx_nm = [sind(theta_BR_nm_ZOD(n,m))*cosd(phi_BR_nm_AOD(n,m)); sind(theta_BR_nm_ZOD(n,m)*sind(phi_BR_nm_AOD(n,m))); cosd(theta_BR_nm_ZOD(n,m))];

        %% RIS单元的位置矢量
        d_rx = RIS_k';
        temp1 = exp(1i*2*pi*r_BR_tx_nm'*d_rx/lambda);

        %% %%%%%% 第二个指数项 %%%%%%
        %% Tx-RIS子逻辑链路波达径
        r_BR_rx_nm = [sind(theta_BR_nm_ZOA(n,m))*cosd(phi_BR_nm_AOA(n,m)); sind(theta_BR_nm_ZOA(n,m))*sind(phi_BR_nm_AOA(n,m)); cosd(theta_BR_nm_ZOA(n,m))];

        %% Tx单元的位置矢量
        d_tx = BS_antenna(s,:)';
        temp2 = exp(1i*2*pi*r_BR_rx_nm'*d_tx/lambda);

        %% %%%%%% 第三个指数项 %%%%%%
        %% 交叉极化增益
        XPR_BR_nm = normrnd(mu_XPR,sigma_XPR,N_BR,20);
        %% 初始相位角(单位degrees)
        % (-pi,pi)的均匀分布
        InitialPhases = -pi + 2*pi.*rand(1,4);
        temp3 = [exp(1i*InitialPhases(1)) sqrt(XPR_BR_nm(n,m)^(-1))*exp(1i*InitialPhases(2));...
            sqrt(XPR_BR_nm(n,m)^(-1))*exp(1i*InitialPhases(3)) exp(1i*InitialPhases(4))];

        %% Tx-RIS子逻辑链路LOS信道系数
        h_BR_NLOS_temp = sqrt(Pn_BR(n)/20).*F_RIS_BR_temp*temp3*[A_dB_vertical; A_dB_horizontal]*temp1*temp2;
        h_BR_NLOS(n,m) = h_BR_NLOS_temp;
    end

end
h_BR_NLOS_clu = sum(h_BR_NLOS,2);

end

