function [H_d, h_d] = calculation_pathgain(flag,fc,phi_T,psi_T,v,N,M,tau,Pn,isLOS,...
    LSP,clu_AOA,clu_AOD,clu_ZOA,clu_ZOD,c_ASA,c_ASD,c_ZSA,mu_lgZSD,mu_XPR,...
    sigma_XPR,pathloss_basic,M_T,N_T,P_T,M_R,N_R,P_R)
%% %%%%%%%%%% 生成nrCDL信道 %%%%%%%%%%
%% 相关参数
% 起始时间为0
initTim = 0;
sampleNum = 1;
% 用户移动速度(km/h)
c = 3*10^8;% 光速(m/s)
% 多普勒(Hz)
fd = (v*1000/3600)/c*fc;
sampleDensity = sampleNum/(fd*2);

%% 声明nrCDLchannel类
cdl = nrCDLChannel;

%% DelayProfile设置
cdl.DelayProfile = 'Custom';

%% 簇时延(单位s)
cdl.PathDelays = tau;

%% 簇功率(单位dB)
cdl.AveragePathGains = pow2db(Pn);

%% 每簇角度(单位degrees)
cdl.AnglesAoA = clu_AOA;
cdl.AnglesAoD = clu_AOD;
cdl.AnglesZoA = clu_ZOA;
cdl.AnglesZoD = clu_ZOD;

%% 是否有LOS簇
cdl.HasLOSCluster = isLOS;

%% 第一簇的K因子(单位dB)
if(isLOS)
    cdl.KFactorFirstCluster = LSP(4);
end

%% 角度扩展
cdl.AngleSpreads = [c_ASD, c_ASA, (3/8)*10^mu_lgZSD, c_ZSA];

%% 角度随机组合Raycoupling(N不包含LOS簇)
Ray_C = zeros(N,M,3);
for i = 1:N
    for j = 1:3
        rowrank = randperm(size(Ray_C,2));% 生成从1到N没有重复元素的整数随机排列
        Ray_C(i,:,j) = rowrank;
    end
end
cdl.RayCoupling = Ray_C;

%% 交叉极化增益(单位dB)
%% 生成每个子路径的交叉极化增益(单位dB)
XPR = normrnd(mu_XPR,sigma_XPR,N,M);
cdl.XPR = XPR;

%% 初始相位角(单位degrees)
InitialPhases = zeros(N,M,4);
for n = 1:N
    % (-pi,pi)的均匀分布
    InitialPhases(n,:,:) = -pi + 2*pi.*rand(M,4);
end
cdl.InitialPhases = InitialPhases;

%% 载波频率(单位Hz)
cdl.CarrierFrequency = fc;
cdl.SampleRate = fd*2*sampleDensity;
cdl.SampleDensity = sampleDensity;

%% 多普勒频率
cdl.MaximumDopplerShift = fd;

%% 发送天线配置
cdl.TransmitAntennaArray.Size = [M_T N_T P_T 1 1];
cdl.TransmitArrayOrientation = [0; phi_T; psi_T];

%% 接收天线配置
cdl.ReceiveAntennaArray.Size = [M_R N_R P_R 1 1];
%bearing_Rx = unifrnd(0,360);
%cdl.ReceiveArrayOrientation = [bearing_Rx; 90; 0];
% 用户移动方向
%cdl.UTDirectionOfTravel = [bearing_Rx; 90];
cdl.ReceiveArrayOrientation = [0; 0; 0];

%% 最强簇
cdl.NumStrongestClusters = 2;

%% 簇时延扩展(单位s)
if(flag)
    % UMi
    if(isLOS)
        cdl.ClusterDelaySpread = 5*10^(-9);
    else
        cdl.ClusterDelaySpread = 11*10^(-9);
    end
else
    % UMa
    cdl.ClusterDelaySpread = max(0.25, 6.5622 - 3.4084*log10(6))*10^(-9);
end

%% 无参量输出信道增益
cdl.ChannelFiltering = false;
cdl.NormalizeChannelOutputs = false;
cdl.NormalizePathGains = false;
cdl.InitialTime = initTim;

%% 信道增益输出
[pathGains] = cdl();
SF = LSP(5); % 线性值

%% 直连链路
channel_coef = squeeze(pathGains(1,1,:,:));
PL = db2pow(-pathloss_basic);
H_d = channel_coef;
% 添加路径损耗和阴影衰落
h_d = ifft(H_d).*PL.*SF;

end


