function [LOS_AOD,LOS_AOA,LOS_ZOD,LOS_ZOA] = Init_angle(X_BS,Y_BS,X_UT,Y_UT,h_UT,h_BS)
%% %%%%%%%%%% 计算LOS径的AOA,AOD,ZOA,ZOD(角度值) %%%%%%%%%%
% 输入参数:X_BS, Y_BS 基站坐标
%         X_UT, Y_UT 用户坐标
%         h_BS 基站天线高度
%         h_UT 用户天线高度
% 输出参数:LOS_AOA 水平到达角
%         LOS_AOD 水平发射角
%         LOS_ZOA 垂直到达角
%         LOS_ZOD 垂直发射角

%% %%%%%%%%%% LOS_ZOA和LOS_ZOD的计算 %%%%%%%%%%
% 2D距离计算
d_2D = sqrt((X_BS - X_UT)^2 + (Y_BS - Y_UT)^2);
% 角度值
LOS_ZOA = atand(d_2D/(h_BS - h_UT));
LOS_ZOD = 180 - LOS_ZOA;

%% %%%%%%%%%% LOS_AOA和LOS_AOD的计算 %%%%%%%%%%
delta_x = X_UT - X_BS; delta_y = Y_UT - Y_BS;
%dx1 = abs(X_BS - X_UT); dy1 = abs(Y_BS - Y_UT);
if(delta_x < 0)
    if(delta_y > 0)
        LOS_AOA = -atand(abs(delta_y/delta_x));
        LOS_AOD = LOS_AOA + 180;
    elseif(delta_y == 0)
        LOS_AOD = -180;
        LOS_AOA = 0;
    else
       LOS_AOA = atand(abs(delta_y/delta_x));
       LOS_AOD = LOS_AOA - 180;
    end
elseif(delta_x == 0)
    if(delta_y > 0)
        LOS_AOD = 90;
        LOS_AOA = -90;
    else
        LOS_AOD = -90;
        LOS_AOA = 90;
    end
else
    if(delta_y > 0)
        LOS_AOD = atand(abs(delta_y/delta_x));
        LOS_AOA = LOS_AOD - 180;
    elseif(delta_y == 0)
        LOS_AOD = 0;
        LOS_AOA = -180;
    else
       LOS_AOD = -atand(abs(delta_y/delta_x));
       LOS_AOA = LOS_AOD + 180;
    end
end

