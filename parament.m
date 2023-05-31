%% %%%%%%%%%% 场景参数配置 %%%%%%%%%
systempara.scenario = 'UMa';          % UMi或UMa
systempara.fc = 6;                    % 单位GHz
systempara.Rician = 6.9438;           % 莱斯因子(dB)
systempara.shadowing = 0.7971;        % 阴影衰落(dB)
systempara.lambda = (3*10^8)/(systempara.fc*10^9);
systempara.cyclenum = 20;             % 循环次数

%% %%%%%%%%%% Tx参数配置 %%%%%%%%%
Tx.location = [0, 0, 25];             % Tx的位置坐标
Tx.phi_T = 7;                         % Tx的下倾角
Tx.psi_T = 60;                        % Tx的方位角
Tx.delta_T = systempara.lambda/2;     % Tx的天线单元间距
Tx.M_BS = 2;                          % Tx单面板垂直阵子数
Tx.N_BS = 2;                          % Tx单面板水平阵子数
Tx.Mg_BS = 1;                         % Tx垂直面板数
Tx.Ng_BS = 1;                         % Tx水平面板数

%% %%%%%%%%%% Rx参数配置 %%%%%%%%%
Rx.location = [100, 0, 1.5];          % Rx的位置坐标
Rx.phi_U = 0;                         % Rx的下倾角
Rx.psi_U = 0;                         % Rx的方位角
Rx.delta_R = systempara.lambda/2;     % Rx的天线单元间距
Rx.M_UE = 1;                          % Rx单面板垂直阵子数
Rx.N_UE = 1;                          % Rx单面板水平阵子数
Rx.Mg_UE = 1;                         % Rx垂直面板数
Rx.Ng_UE = 1;                         % Rx水平面板数

%% %%%%%%%%%% RIS参数配置 %%%%%%%%%
RISnode.location = [70, 8, 15];       % RIS的位置坐标
RISnode.rotation_angle = 20;          % RIS的朝向角度(参考方向:正北,法向量与x轴正向平行)/逆时针为正
RISnode.K1 = 8;                       % RIS面板阵列行数
RISnode.K2 = 8;                       % RIS面板阵列列数
RISnode.dxy = [systempara.lambda/4,...
    systempara.lambda/4];             % RIS单元尺寸dx,dy

% 监听
sysflag.default = 1;                  % 默认参数
sysflag.flag_K = 1;                   % 配置输入莱斯因子(用户)
sysflag.flag_Tx = 1;
sysflag.flag_Rx = 1;
sysflag.flag_RIS = 1;



