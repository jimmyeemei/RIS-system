function [h_BIU] = BIU(mu_XPR, sigma_XPR,TXlocation,RISnodelocation,RXlocation)

%% %%%%%%%%%% 界面参数导入 %%%%%%%%%%
% 用户自定义参数
parament;
TX.location=TXlocation;
RISnode.location=RISnodelocation;
RX.location=RXlocation;
% 默认参数
if(sysflag.default == 1)
    sysdata_default;
end

%% %%%%%%%%%% 信道生成所需输入参数 %%%%%%%%%%
% 系统中心频率(转化为Hz)
fc = systempara.fc*10^9;
% 场景标志位
if(strcmp(systempara.scenario, 'UMa'))
    flag = 0;
else
    flag = 1;
end
% 双极化
P_T = 2; P_R = 2;
% 子径数
M = 20;
% 时刻
t = 0;
% 波长
c = 3*10^8;
lambda = c/fc;
% 接收天线单元数目(用户)
U = Rx.M_UE*Rx.N_UE*P_R;
% 发送天线单元数目(基站)
S = Tx.M_BS*Tx.N_BS*P_T;
% 3D位置坐标
BS = Tx.location; UE = Rx.location; RIS = RISnode.location;
% 室内/室外标志位
O2I = 1;
% 用户移动速度
v = 0;
% d_2D_in距离的计算
d_2D_BR = sqrt((BS(1) - RIS(1))^2 + (BS(2) - RIS(2))^2);
d_2D_RU = sqrt((RIS(1) - UE(1))^2 + (RIS(2) - UE(2))^2);

%% %%%%%%%%%% 级联链路Tx-RIS-Rx信道系数生成 %%%%%%%%%%
%% Tx-RIS/RIS-Rx子逻辑链路LOS径角度AOA,AOD,ZOA,ZOD计算
[LOS_AOD_BR,LOS_AOA_BR,LOS_ZOD_BR,LOS_ZOA_BR] = Init_angle(BS(1), BS(2),...
    RIS(1), RIS(2), RIS(3), BS(3));
[LOS_AOD_RU,LOS_AOA_RU,LOS_ZOD_RU,LOS_ZOA_RU] = Init_angle(RIS(1), RIS(2),...
    UE(1), UE(2), UE(3), RIS(3));

%% LOS概率生成
[Pr_LOS_BR] = Pr_LOS(BS(1), BS(2), RIS(1), RIS(2), RIS(3), flag);
[Pr_LOS_RU] = Pr_LOS(RIS(1), RIS(2), UE(1), UE(2), UE(3), flag);
% 判断是否存在LOS径
P = rand();
if(P < Pr_LOS_BR)
    LOS_BR = 1;
else
    LOS_BR = 0;
end
P = rand();
if(P < Pr_LOS_RU)
    LOS_RU = 1;
else
    LOS_RU = 0;
end

%% Tx-RIS/RIS-Rx子逻辑链路大尺度参数LSP生成
[LSP_BR] = larggescale(LOS_BR, O2I, RIS(3), BS(3), BS(1), BS(2), RIS(1),...
    RIS(2), fc, flag);
[LSP_RU] = larggescale(LOS_RU, O2I, UE(3), RIS(3), RIS(1), RIS(2), UE(1),...
    UE(2), fc, flag);
if(sysflag.flag_K == 1)
    % 配置输入莱斯因子(用户)
    LSP_BR(4) = systempara.Rician;
    LSP_RU(4) = systempara.Rician;
end

%% Tx-RIS/RIS-Rx子逻辑链路小尺度参数SSP生成
%LOS_BR = 0; LOS_RU = 1;
N_BR_input = 0; N_RU_input = 0;
[Pn_BR,N_BR,tau_BR] = smallscale(LSP_BR, LOS_BR, O2I, flag, N_BR_input);
[Pn_RU,N_RU,tau_RU] = smallscale(LSP_RU, LOS_RU, O2I, flag, N_RU_input);

% 默认Tx-RIS/RIS-Rx子逻辑链路的簇内子径角度生成(3GPP)
[~,~,~,~,phi_BR_nm_AOA,phi_BR_nm_AOD,theta_BR_nm_ZOA,theta_BR_nm_ZOD] =...
    phi(fc, N_BR, M, d_2D_BR, RIS(3), BS(3), LOS_BR, O2I, LSP_BR, Pn_BR,...
    LOS_AOA_BR, LOS_AOD_BR, LOS_ZOA_BR, LOS_ZOD_BR);
[~,~,~,~,phi_RU_nm_AOA,phi_RU_nm_AOD,theta_RU_nm_ZOA,theta_RU_nm_ZOD] =...
    phi(fc, N_RU, M, d_2D_RU, UE(3), RIS(3), LOS_RU, O2I, LSP_RU, Pn_RU,...
    LOS_AOA_RU, LOS_AOD_RU, LOS_ZOA_RU, LOS_ZOD_RU);

% 莱斯因子
if LOS_BR == 1
    K_BR = db2pow(LSP_BR(4));
else
    K_BR = 0;
end

if LOS_RU == 1
    K_RU = db2pow(LSP_RU(4));
else
    K_RU = 0;
end

% 阴影衰落
SF_BR = LSP_BR(5);
SF_RU = LSP_RU(5);

%% %%%%%%%%%% 信道生成所需输入参数 %%%%%%%%%%
rotation_angle = RISnode.rotation_angle;
K1 = RISnode.K1; K2 = RISnode.K2;
dx = RISnode.dxy(1); dy = RISnode.dxy(2);
phi_T = Tx.phi_T; psi_T = Tx.psi_T; tilt_BS = Tx.tilt_BS;
delta_T = Tx.delta_T;
phi_U = Rx.phi_U ; psi_U = Rx.psi_U; tilt_UE = Rx.tilt_UE;
delta_R = Rx.delta_R;

%% %%%%%%%%%% 初始化矩阵 %%%%%%%%%%
theta_t = zeros(K1,K2,S); phi_t = zeros(K1,K2,S);
theta_r = zeros(K1,K2,S); phi_r = zeros(K1,K2,S);
d_BR = zeros(K1,K2,S); d_RU = zeros(K1,K2,U);
k = zeros(1,S);
A_BS = zeros(S,3); A_UE = zeros(U,3);
BS_antenna = zeros(S,3); UE_antenna = zeros(U,3);
h1 = zeros(K1,K2);
h2 = zeros(K1,K2,N_BR);
h3 = zeros(K1,K2);
h4 = zeros(K1,K2,N_RU);
h_nm_temp1 = zeros(K1*K2,S,N_BR);
h_nm_temp2 = zeros(U,K1*K2,N_RU);

%% %%%%%%%%%% RIS辐射方向图 %%%%%%%%%%
% 读入测试数据
Test = csvread('radiation_pattern.csv',1,0,[1 0 724 1]);
% 取第一列角度值
theta_deg = Test(:,1);
% 取第二列辐射方向图值
gain = Test(:,2);
% 数据处理
theta_deg = theta_deg - 90;% 原点转化为0
gain = db2pow(gain)/max(db2pow(gain));% 归一化
F_RIS_BR = zeros(N_BR,M,2); F_RIS_RU = zeros(N_RU,M,2);
for n = 1:N_BR
    for m = 1:M
        [F_RIS_theta] = RIS_radiation_pattern(theta_deg, gain, theta_BR_nm_ZOA(n,m));
        [F_RIS_phi] = RIS_radiation_pattern(theta_deg, gain, phi_BR_nm_AOA(n,m));
        F_RIS_BR(n,m,:) = [F_RIS_theta, F_RIS_phi];

        [F_RIS_theta] = RIS_radiation_pattern(theta_deg, gain, theta_BR_nm_ZOA(n,m));
        [F_RIS_phi] = RIS_radiation_pattern(theta_deg, gain, phi_BR_nm_AOA(n,m));
        F_RIS_RU(n,m,:) = [F_RIS_theta, F_RIS_phi];
    end
end
% LOS径RIS辐射方向图
F_RIS_LOS_BR = [RIS_radiation_pattern(theta_deg, gain, LOS_ZOA_BR),...
    RIS_radiation_pattern(theta_deg, gain, LOS_AOA_BR)];

F_RIS_LOS_RU = [RIS_radiation_pattern(theta_deg, gain, LOS_ZOD_RU);...
    RIS_radiation_pattern(theta_deg, gain, LOS_AOD_RU)];

%% %%%%%%%%%% 级联链路Tx-RIS-Rx信道系数生成 %%%%%%%%%%
% 遍历所有反射单元
for k1 = 1:K1
    for k2 = 1:K2
        % RIS单元的距离矢量ARIS
        A_RIS_k = []; % RIS中心到RIS_nm反射单元的偏移向量
        A_RIS_k(1) = ((2*k1 - K1 -1)/2)*dx*cosd(rotation_angle);
        A_RIS_k(2) = ((2*k1 - K1 -1)/2)*dx*sind(rotation_angle);
        A_RIS_k(3) = ((2*k2 - K2 - 1)/2)*dy*1;
        % RIS_nm反射单元到原点的坐标
        RIS_k = RIS + A_RIS_k;
        % 旋转后以RIS面板为xoy面的z轴法向量
        RISz = [cosd(rotation_angle) sind(rotation_angle) 0];
        % 旋转后以RIS面板为xoy面的x轴法向量
        RISx = [-sind(rotation_angle) cosd(rotation_angle) 0];

        % 遍历所有发送天线
        for s = 1:S
            k(s) = (S - 2*s + 1)/2;
            % 基站单元偏移向量
            A_BS(s,:) = (k(s)*delta_T.*[cos(phi_T)*cos(psi_T); cos(phi_T)*...
                sin(psi_T); sin(phi_T)])';
            % 第s个发送天线单元的位置向量
            BS_antenna(s,:) = BS + A_BS(s);
            % RIS中心和基站天线单元s之间的向量
            vector_BR = RIS - BS_antenna(s);
            % RIS_nm反射单元和基站天线单元s之间的向量
            vector_BR_nm = vector_BR + A_RIS_k;
            % BS天线单元s到RIS_nm反射单元之间距离
            d_BR(k1,k2,s) = norm(vector_BR_nm);
            % 仰角和方位角的计算
            theta_t(k1,k2) = acosd(abs(dot(RISz,vector_BR_nm)/d_BR(k1,k2,s)));
            phi_t(k1,k2) = acosd(dot(RISx,vector_BR_nm)/d_BR(k1,k2,s));
            %% Tx-RIS子逻辑链路信道
            h1(k1,k2) = h_BR_LOS(LOS_AOA_BR,LOS_ZOA_BR,LOS_AOD_BR,LOS_ZOD_BR,...
                tilt_BS,d_BR,k1,k2,s,lambda,RIS_k,BS_antenna,F_RIS_LOS_BR);
            h2(k1,k2,:) = h_BR_NLOS(phi_BR_nm_AOA,theta_BR_nm_ZOA,phi_BR_nm_AOD,...
                theta_BR_nm_ZOD,tilt_BS,s,lambda,RIS_k,BS_antenna,N_BR,Pn_BR,...
                F_RIS_BR,mu_XPR,sigma_XPR);

            h_nm_temp1((k1 - 1)*K1 + k2,s,:) = sqrt(1/(1 + K_BR)).*h2(k1,k2,:);
            h_nm_temp1((k1 - 1)*K1 + k2,s,1) = (sqrt(K_BR/(1 + K_BR)).*h1(k1,k2) +...
                sqrt(1/(1 + K_BR)).*h2(k1,k2,1));
        end

        % 遍历所有接收天线
        for u = 1:U
            k(u) = (U - 2*u + 1)/2;
            % 基站单元偏移向量
            A_UE(U,:) = (k(u)*delta_R.*[cos(phi_U)*cos(psi_U); cos(phi_U)*sin(psi_U);...
                sin(phi_U)])';
            % 第s个发送天线单元的位置向量
            UE_antenna(u,:) = UE + A_BS(u);
            % RIS中心和基站天线单元s之间的向量
            vector_RU = UE_antenna(U) - RIS ;
            % UE天线单元到RIS_nm反射单元之间距离
            vector_RU_nm = vector_RU + A_RIS_k;
            d_RU(k1,k2,u) = norm(vector_RU_nm);
            % 仰角和方位角的计算
            theta_r(k1,k2) = acosd(abs(dot(RISz,vector_RU_nm)/d_RU(k1,k2)));
            phi_r(k1,k2) = acosd(abs(dot(RISx,vector_RU_nm)/d_RU(k1,k2)));
            %% RIS-Rx子逻辑链路信道
            h3(k1,k2) = h_RU_LOS(LOS_AOD_RU,LOS_ZOD_RU,LOS_AOA_RU,LOS_ZOA_RU,...
                tilt_BS,d_RU,k1,k2,u,lambda,RIS_k,UE_antenna,v,phi_U,psi_U,t,...
                F_RIS_LOS_RU);
            h4(k1,k2,:) = h_RU_NLOS(phi_RU_nm_AOD,theta_RU_nm_ZOD,phi_RU_nm_AOA,...
                theta_RU_nm_ZOA,tilt_UE,u,lambda,UE_antenna,RIS_k,N_RU,Pn_RU,v,...
                phi_U,psi_U,t,F_RIS_RU,mu_XPR,sigma_XPR);

            h_nm_temp2(u,(k1 - 1)*K1 + k2,:) = sqrt(1/(1 + K_RU)).*h4(k1,k2,:);
            h_nm_temp2(u,(k1 - 1)*K1 + k2,1) = (sqrt(K_RU/(1 + K_RU)).*h3(k1,k2) +...
                sqrt(1/(1 + K_RU)).*h4(k1,k2,1));

        end
    end
end

%% 整体时延以及功率计算
[tau_BIU,Pnm_BIU] = cluster_generation(Pn_BR, N_BR, tau_BR, Pn_RU, N_RU, tau_RU,M,...
    F_RIS_BR, F_RIS_RU);

% 信道状态信息CSI
temp_BR = 0; temp_RU = 0;
for i = 1:N_BR
    temp_BR = temp_BR + h_nm_temp1(:,:,i)*exp(-1i*2*pi*fc*tau_BR(i));
end
for i = 1:N_RU
    temp_RU = temp_RU + h_nm_temp2(:,:,i)*exp(-1i*2*pi*fc*tau_RU(i));
end
% 波束赋形
Phi = zeros(1,K1*K2);
for m = 1:K1*K2
    Phi(m) = exp(1i*pi*(2*rand(1,1)));
end

for i = 1:U
    temp_RU_1 = temp_RU(i,:);
    w_bar = temp_RU_1*diag(Phi)*temp_BR;
    w_bar = w_bar/norm(w_bar);
    phi_opt = zeros(1, K1*K2);
    for j = 1:K1*K2
        phi_opt(j) = -angle(temp_RU_1(j)*temp_BR(j,:)*w_bar');
    end
    CSI(i,:) = temp_RU_1*diag(phi_opt)*temp_BR;
end
CSI = CSI';
%{
CSI = zeros(S,U);
for s = 1:S
    for u = 1:U
        temp = 0;
        for i = 1:N_BR
            for j = 1:N_RU
                temp = temp + h_nm_temp2(u,:,j)*h_nm_temp1(:,s,i)*...
                    exp(-1i*2*pi*fc*tau_BIU(1,(i - 1)*N_BR + j));
            end
        end
        CSI(s,u) = temp;
    end
end
%}

% 级联路径损耗计算
theta_t1 = acosd(abs(dot(RISz,RIS-BS)/norm(RIS - BS)));
phi_t1 = acosd(dot(RISx,RIS-BS)/norm(RIS - BS));
theta_r1 = acosd(abs(dot(RISz,UE - RIS)/norm(UE - RIS)));
phi_r1 = acosd(abs(dot(RISx,UE - RIS)/norm(UE - RIS)));
% 默认级联路径损耗计算(文献)
pathloss = cascade_pl(K1,K2,dx,dy,lambda,norm(BS-RIS),norm(RIS-UE),theta_t1,theta_r1);
pathloss = 1/pathloss;
% 添加阴影衰落和路径损耗
CSI = CSI.*SF_BR.*SF_RU.*pathloss;
h_BIU = CSI;


end
