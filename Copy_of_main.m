clear;
%% 参数初始化
Init_sim;
global sim;
Bandwidth_MHz=400;%载波带宽
Subcarrier_Spacing_kHz=120;%子载波间隔
frame=10e-3;%无线帧10ms
half_of_frame=frame/2;
subframe=1e-3;%子帧1ms，一个tti
subcarrierSpacingHz =Subcarrier_Spacing_kHz*10^3;%FR2频段支持的子载波间隔为60 kHz（数据信道，如PDSCH、PUSCH）、120 kHz及240 kHz（仅应用于同步信道如PSS、SSS、PBCH)。
slotDuration = 15e3/subcarrierSpacingHz*1e-3;%时隙15-1ms,60-0.25
symbolDurationS= slotDuration/14;%符号周期=时隙/14
Number_of_slots_per_simulation=frame/slotDuration;%半个个无线帧中的时隙数
bandwidthHz=Bandwidth_MHz*10^6;%毫米波最高支持400MHz带宽
Frame_Structure='DDDSU';
segment=[0 0 0 2 1];   
%dl 0 ul1 sl2
nsegment=floor(Number_of_slots_per_simulation/length(segment));
nsegment=2;
nremainslots=mod(Number_of_slots_per_simulation,length(segment));
segment_total=[];
for islot=1:nsegment
    segment_total=[segment_total segment];
end
segment_total=[segment_total segment(1:nremainslots)];
length_segment_UL=length(find(segment_total==1));
length_segment_DL=length(find(segment_total==0));
length_segment_SL=length(find(segment_total==2));
Special_Slot_Configuration='10:2:2';
switch Special_Slot_Configuration
    case '10:2:2'
        Special_Slot_UL=2;
        Special_Slot_DL=10;
   case '3:10:1'  
       Special_Slot_UL=1;
        Special_Slot_DL=3;
end
%% 资源块设计
resourceGrid.nSubcarrierRb = 12;%一个RB块里有12个子载波
resourceGrid.nRBTime =1;%假设为固定参数，
resourceGrid.sizeRbTimeS =slotDuration/resourceGrid.nRBTime;%一个RB块时间
resourceGrid.sizeRbFreqHz = resourceGrid.nSubcarrierRb .* subcarrierSpacingHz;%一个RB块带宽=每个RB块子载波个数*子载波间隔
resourceGrid.nSymbolRb = 14;%每个RB块14个符号周期
resourceGrid.nSymbolSlot = 14;%每个时隙14个符号周
usableBandwidth=1;%5G中为0.98，LTE中为0.8
resourceGrid.nRBFreq = floor(bandwidthHz .* usableBandwidth ./resourceGrid.sizeRbFreqHz);
resourceGrid.nRBTot = resourceGrid.nRBFreq *resourceGrid.nRBTime;
resourceGrid.nCRCBits = 24;
nSubcarrierSlot = resourceGrid.nRBFreq .*resourceGrid. nSubcarrierRb;%每个时隙中子载波数
nSymbolSlot = resourceGrid.nRBTime .* floor(resourceGrid.sizeRbTimeS ./symbolDurationS);%每个时隙符号数
%每个时隙符号数

%% 初始化
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%小区初始化，输入小区站间距intercelldistance和需要构建的小区数目cellnum，输出小区中心坐标x，y
%以及拓扑图边缘点的极坐标
% cellinstall：输入小区数量和间隔
%输出参数：sitex 小区中心x轴坐标
%           sitey 小区中心y轴坐标
%           pedge  小区分布地区边缘点的极坐标长度pou
%           theatedge 小区分布地区边缘点的极坐标角度theat
%wrap_around,平移到周边6个区域
[sitecoorx,sitecoory,pedge,theatedge]=cellinstall;
[sitex_wrap,sitey_wrap]=wraparound(sitecoorx,sitecoory);

%%循环控制参数
cyclenum=1;
for cyclei=1:cyclenum
    [userlistcoorx,userlistcoory]=userinstall(pedge,theatedge); 
    %输入参数：usernum 用户数量
    %          userscalex 用户分布边范围x坐标
    %          userscaley 用户分布边范围y坐标
    %输出参数：userlistcoorx 用户位置列表x轴坐标
    %          userlistcoory 用户位置列表y轴坐标

    
    %%%%% 服务小区确定，输出用户、小区结构体，记录用户所属小区情况和小区内服务用户情况 %%%%%
    [userservice,cellservice,pathloss,pathloss_min]=servicecell_wrap(sitex_wrap,sitey_wrap,userlistcoorx,userlistcoory);    
    %userservice：1x570 struct; cellservice: 1x57 struct
    %pathloss:570*57，the pathloss between each user and each cell
    %pathloss_min:570*3，每个UE与服务小区之间的pathloss
    %%RIS随机撒点，输出RIS位置坐标RISlistcoorx,RISlistcoory
    [RISlistcoorx,RISlistcoory,RIShut] = RISinstall( pedge,theatedge);
     %%确定用户位置坐标x,y以及初始角度和距离
      hut=25;
      angle.a=unifrnd(0,360);
      angle.b=90;
      angle.c=0;
     
     
end
