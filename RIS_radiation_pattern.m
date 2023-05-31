function [RIS_radiation_pattern] = RIS_radiation_pattern(theta_deg,gain,theta)
%% 根据实测数据拟合的RIS辐射方向图(theta表示实际信号入射角度)
% 计算辐射方向图增益
% [fitresult, gof] = createFit1(theta_deg, gain);
%% Fit: 'untitled fit 2'.
[xData, yData] = prepareCurveData( theta_deg, gain );

% Set up fittype and options.
ft = fittype( 'smoothingspline' );

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft );

% 实测数据范围内(-30到30)
if theta >= -30 && theta <= 30
    RIS_radiation_pattern = fitresult(theta);
else
    %RIS_radiation_pattern = 5.7535e-04;
    RIS_radiation_pattern = fitresult(-30);
end

end