%% %%%%%%%%%% 场景参数配置 %%%%%%%%%
systempara.scenario = 'UMa';          % 对应flag = 0;
systempara.fc = 6;                    % GHz
systempara.cyclenum = 20;             % 循环次数

%% %%%%%%%%%% Tx参数配置 %%%%%%%%%
Tx.location = [0, 0, 25];             % Tx的位置坐标
Tx.phi_T = 7;                         % Tx的下倾角
Tx.psi_T = 60;                        % Tx的方位角
Tx.tilt_BS = 45;                      % Tx的极化倾角
Tx.delta_T = 0.025;                   % Tx的天线单元间距
Tx.M_BS = 2;                          % Tx的单面板垂直阵子数
Tx.N_BS = 2;                          % Tx的单面板水平阵子数
Tx.Mg_BS = 1;                         % Tx垂直面板数
Tx.Ng_BS = 1;                         % Tx水平面板数

%% %%%%%%%%%% Rx参数配置 %%%%%%%%%
Rx.location = [100, 0, 1.5];          % Rx的位置坐标
Rx.phi_U = 0;                         % Rx的下倾角
Rx.psi_U = 0;                         % Rx的方位角
Rx.tilt_UE = 45;                      % Rx的极化倾角
Rx.delta_R = 0.025;                   % Rx的天线单元间距
Rx.M_UE = 1;                          % Rx的单面板垂直阵子数
Rx.N_UE = 1;                          % Rx的单面板水平阵子数
Rx.Mg_UE = 1;                         % Rx垂直面板数
Rx.Ng_UE = 1;                         % Rx水平面板数

%% %%%%%%%%%% RIS参数配置 %%%%%%%%%
RISnode.location = [70, 8, 15];       % RIS的位置坐标
RISnode.rotation_angle = 20;          % RIS的朝向角度
RISnode.K1 = 8;                       % RIS面板阵列行数
RISnode.K2 = 8;                       % RIS面板阵列列数
RISnode.dxy = [0.0125, 0.0125];       % RIS单元尺寸dx,dy

F_RIS = csvread('radiation_pattern.csv',1,0,[1 0 724 1]);

% 监听
sysflag.flag_K = 0;                   % 配置输入莱斯因子(用户)
sysflag.flag_Tx = 0;
sysflag.flag_Rx = 0;
sysflag.flag_RIS = 0;




