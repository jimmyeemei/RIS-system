function [h_d, mu_XPR, sigma_XPR] = Tx_Rx(TXlocation,RXlocation)

%% %%%%%%%%%% 界面参数导入 %%%%%%%%%%
% 用户自定义参数
parament;
TX.location=TXlocation;
RX.location=RXlocation;
% 默认参数
%% %%%%%%%%%% 信道生成所需输入参数 %%%%%%%%%%
% 场景标志位
    flag = 0;
% 双极化
P_T = 2; P_R = 2;
% 3D位置坐标
BS = Tx.location; UE = Rx.location;
% 室内/室外标志位
O2I = 1;
% 系统中心频率(转化为Hz)
fc = systempara.fc*10^9;
% 用户移动速度
v = 3;
% 子径数
M = 20;
% d_2D_in生成
tempX = unifrnd(0,25);
tempY = unifrnd(0,25);
d_2D_in = min(tempX,tempY);

%% %%%%%%%%%% 直连链路Tx-Rx信道系数生成 %%%%%%%%%%
%% LOS径的AOA,AOD,ZOA,ZOD
[LOS_AOD,LOS_AOA,LOS_ZOD,LOS_ZOA] = Init_angle(BS(1), BS(2), UE(1), UE(2),...
    UE(3), BS(3));

%% LOS概率生成
Pr_LOS_d = Pr_LOS(BS(1), BS(2), UE(1), UE(2), UE(3), flag);
% 判断是否存在LOS径
P = rand();
if(P < Pr_LOS_d)
    LOS = 1;
else
    LOS = 0;
end

%% 路径损耗生成
% 默认路径损耗计算(3GPP)
[PL_b,PL_tw,PL_in,~] = calculation_pathloss(BS(1), BS(2), UE(1), UE(2),...
    BS(3), UE(3), LOS, fc, flag, d_2D_in, O2I);
sigma = 4.4;
% 总路径损耗(包括室外路损、穿透损耗以及室内损耗)
pathloss_basic = PL_b + PL_tw + PL_in + normrnd(0, sigma);

%% 大尺度参数LSP生成
[LSP] = larggescale(LOS, O2I, UE(3), BS(3), BS(1), BS(2), UE(1), UE(2),...
    fc, flag);
% 配置输入莱斯因子(用户)
if(sysflag.flag_K)
    LSP(4) = systempara.Rician;
end

%% 小尺度参数SSP生成
N_input = 0;
[Pn,N,tau] = smallscale(LSP, LOS, O2I, flag, N_input);

%% 簇内子径角度值生成
% 默认输入簇内子径角度(3GPP)
[clu_AOA,clu_AOD,clu_ZOA,clu_ZOD,~,~,~,~] = phi(fc, N, M, d_2D_in, UE(3),...
    BS(3), LOS, O2I, LSP, Pn, LOS_AOA, LOS_AOD, LOS_ZOA, LOS_ZOD);

%% 室内/室外用户标志位
if(O2I == 1)
    if(LOS == 1)
        O2I_LOS = 1;
    else
        O2I_LOS = 0;
    end
else
    O2I_LOS = NaN;
end
[c_ASA,c_ASD,c_ZSA,mu_lgZSD,mu_XPR,sigma_XPR] = Init_parameter_phi(UE(3),...
    BS(3), d_2D_in, LOS, O2I_LOS, flag);

%% 直连链路信道系数
[~, h_d] = calculation_pathgain(flag, fc, Tx.phi_T, Tx.psi_T, v, N, M, tau, Pn, LOS, LSP,...
    clu_AOA, clu_AOD, clu_ZOA, clu_ZOD, c_ASA, c_ASD, c_ZSA, mu_lgZSD,...
    mu_XPR, sigma_XPR, pathloss_basic, Tx.M_BS, Tx.N_BS, P_T, Rx.M_UE, Rx.N_UE, P_R);



