function [LSP] = larggescale(LOS,O2I,h_UT,h_BS,BS_x,BS_y,UE_x,UE_y,fc,flag)
%% %%%%%%%%%% 直连链路Tx-Rx多径分量统计参数DS,ASD,ASA,K,SF,ZSD,ZSA生成 %%%%%%%%%%
%{
   LSP(1)代表DS
   LSP(2)代表ASD
   LSP(3)代表ASA
   LSP(4)代表K
   LSP(5)代表SF
   LSP(6)代表ZSD
   LSP(7)代表ZSA
%}

% 初始化LSP矩阵
LSP = zeros(1,7);     % LSP代表大尺度参数(large-scale parameters)
% fc的单位转换
fc = fc/10^9;         % fc单位为GHz(3GPP此处表7.5-6频率的单位为GHz)

%% %%%%%%%%%% 互相关矩阵A的生成 %%%%%%%%%%
if(flag == 0)
    %% UMa场景
    if(LOS == 1)
        % UMa LOS
        A=[1 0.4 0.8 -0.4 -0.4 -0.2 0;
            0.4 1 0 0 -0.5 0.5 0;
            0.8 0 1 -0.2 -0.5 -0.3 0.4;
            -0.4 0 -0.2 1 0 0 0;
            -0.4 -0.5 -0.5 0 1 0 -0.8;
            -0.2 0.5 -0.3 0 0 1 0;
            0 0 0.4 0 -0.8 0 1];
    elseif(LOS == 0)
        % UMa NLOS
        A=[1 0.4 0.6 0 -0.4 -0.5 0;
            0.4 1 0.4 0 -0.6 0.5 -0.1;
            0.6 0.4 1 0 0 0 0;
            0 0 0 1 0 0 0;
            -0.4 -0.6 0 0 1 0 -0.4;
            -0.5 0.5 0 0 0 1 0;
            0 -0.1 0 0 -0.4 0 1];
    end
    if(O2I == 1)
        A=[1 0.4 0.4 0 -0.5 -0.6 -0.2;
            0.4 1 0 0 0.2 -0.2 0;
            0.4 0 1 0 0 0 0.5;
            0 0 0 1 0 0 0;
            -0.5 0.2 0 0 1 0 0;
            -0.6 -0.2 0 0 0 1 0.5;
            -0.2 0 0.5 0 0 0.5 1];
    end
else
    %% UMi场景
    if(LOS == 1)
        % UMi LOS
        A=[1 0.5 0.8 -0.7 -0.4 0 0.2;
            0.5 1 0.4 -0.2 -0.5 0.5 0.3;
            0.8 0.4 1 -0.3 -0.4 0 0;
            -0.7 -0.2 -0.3 1 0.5 0 0;
            -0.4 -0.5 -0.4 0.5 1 0 0;
            0 0.5 0 0 0 1 0;
            0.2 0.3 0 0 0 0 1];
    elseif(LOS == 0)
        % UMi NLOS
        A=[1 0 0.4 0 -0.7 -0.5 0;
            0 1 0 0 0 0.5 0.5;
            0.4 0 1 0 -0.4 0 0.2;
            0 0 0 1 0 0 0;
            -0.7 0 -0.4 0 1 0 0;
            -0.5 0.5 0 0 0 1 0;
            0 0.5 0.2 0 0 0 1];
    end
    if(O2I == 1)
        A=[1 0.4 0.4 0 -0.5 -0.6 -0.2;
            0.4 1 0 0 0.2 -0.2 0;
            0.4 0 1 0 0 0 0.5;
            0 0 0 1 0 0 0;
            -0.5 0.2 0 0 1 0 0;
            -0.6 -0.2 0 0 0 1 0.5;
            -0.2 0 0.5 0 0 0.5 1];
    end
end

% 计算矩阵C,C=A^(1/2)
C = sqrtm(A);
% 均值为0,方差为1的独立高斯随机变量
w = normrnd(0,1,7,1);
s1 = C*w; % 式(11-37)
% 距离计算
d_2D = sqrt((BS_x - UE_x)^2 + (BS_y - UE_y)^2);

%% %%%%%%%%%% 均值/方差的计算(查3GPP表7.5-6) %%%%%%%%%%
if(flag == 0)
    %% UMa场景
    if(LOS == 1)
        % UMa LOS
        % 均值
        mu_DS = -6.955 - 0.0963*log10(fc);
        mu_ASD = 1.06 + 0.1114*log10(fc);
        mu_ASA = 1.81;
        mu_ZSA = 0.95;
        mu_K = 9;% 单位dB
        mu_ZSD = max(-0.5, -2.1*(d_2D/1000) - 0.01*(h_UT - 1.5) + 0.75);
        % 方差
        epsilon_DS = 0.66;
        epsilon_ASD = 0.28;
        epsilon_ASA = 0.20;
        epsilon_ZSA = 0.16;
        epsilon_K = 3.5;
        epsilon_SF = 4;% 单位为dB
        epsilon_ZSD = 0.40;
    elseif(LOS == 0)
        % UMa NLOS
        % 均值
        mu_DS = -6.28 - 0.204*log10(fc);
        mu_ASD = 1.5 - 0.1144*log10(fc);
        mu_ASA = 2.08 - 0.27*log10(fc);
        mu_K = NaN;
        mu_ZSA = -0.3236*log10(fc) + 1.512;
        mu_ZSD = max(-0.5, -2.1*(d_2D/1000) - 0.01*(h_UT - 1.5) + 0.9);
        % 方差
        epsilon_DS = 0.39;
        epsilon_ASD = 0.28;
        epsilon_ASA = 0.11;
        epsilon_K = NaN;
        epsilon_SF = 6;% 单位为dB
        epsilon_ZSA = 0.16;
        epsilon_ZSD = 0.49;
    end
else
    %% UMi场景
    if(LOS == 1)
        % UMi LOS
        % 均值
        mu_DS = -7.14 - 0.24*log10(1 + fc);
        mu_ASD = 1.21 - 0.05*log10(1 + fc);
        mu_ASA = 1.73 - 0.08*log10(1 + fc);
        mu_ZSA = 0.73 - 0.1*log10(1 + fc);
        mu_K = 9;% 单位dB
        mu_ZSD = max(-0.21, -14.8*(d_2D/1000) + 0.01*abs(h_UT - h_BS) + 0.83);
        % 方差
        epsilon_DS = 0.38;
        epsilon_ASD = 0.41;
        epsilon_ASA = 0.28 + 0.014*log10(1 + fc);
        epsilon_ZSA = 0.34 - 0.04*log10(1 + fc);
        epsilon_K = 5;
        epsilon_SF = 4;% 单位为dB
        epsilon_ZSD = 0.35;
    elseif(LOS == 0)
        % UMi NLOS
        % 均值
        mu_DS = -6.83 - 0.24*log10(1 + fc);
        mu_ASD = 1.53 - 0.23*log10(1 + fc);
        mu_ASA = 1.81 - 0.08*log10(1 + fc);
        mu_ZSA = 0.92 - 0.04*log10(1 + fc);
        mu_K = NaN;% 单位dB
        mu_ZSD = max(-0.5, -3.1*(d_2D/1000) + 0.01*max(h_UT - h_BS,0) + 0.2);
        % 方差
        epsilon_DS = 0.28 + 0.16*log10(1 + fc);
        epsilon_ASD = 0.33 + 0.11*log10(1 + fc);
        epsilon_ASA = 0.3 + 0.05*log10(1 + fc);
        epsilon_ZSA = 0.41 - 0.07*log10(1 + fc);
        epsilon_K = NaN;
        epsilon_SF = 7.82;% 单位为dB
        epsilon_ZSD = 0.35;
    end
end

%% %%%%%%%%%% 计算具有相关性的随机多径分量统计参数 %%%%%%%%%%
LSP(1) = 10^(epsilon_DS*s1(1) + mu_DS);
LSP(2) = min(10^(epsilon_ASD*s1(2) + mu_ASD), 104);% ASD/ASA限制在(0,104度)
LSP(3) = min(10^(epsilon_ASA*s1(3) + mu_ASA), 104);
LSP(4) = epsilon_K*s1(4) + mu_K;% dB
LSP(5) = 10^(epsilon_SF*s1(5)/10);
LSP(6) = min(10^(epsilon_ZSD*s1(6) + mu_ZSD), 52); % ZSD/ZSA限制在(0,52度)
LSP(7) = min(10^(epsilon_ZSA*s1(7) + mu_ZSA), 52);

