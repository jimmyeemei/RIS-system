clear;
%% ������ʼ��
Init_sim;
global sim;
Bandwidth_MHz=400;%�ز�����
Subcarrier_Spacing_kHz=120;%���ز����
frame=10e-3;%����֡10ms
half_of_frame=frame/2;
subframe=1e-3;%��֡1ms��һ��tti
subcarrierSpacingHz =Subcarrier_Spacing_kHz*10^3;%FR2Ƶ��֧�ֵ����ز����Ϊ60 kHz�������ŵ�����PDSCH��PUSCH����120 kHz��240 kHz����Ӧ����ͬ���ŵ���PSS��SSS��PBCH)��
slotDuration = 15e3/subcarrierSpacingHz*1e-3;%ʱ϶15-1ms,60-0.25
symbolDurationS= slotDuration/14;%��������=ʱ϶/14
Number_of_slots_per_simulation=frame/slotDuration;%���������֡�е�ʱ϶��
bandwidthHz=Bandwidth_MHz*10^6;%���ײ����֧��400MHz����
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
%% ��Դ�����
resourceGrid.nSubcarrierRb = 12;%һ��RB������12�����ز�
resourceGrid.nRBTime =1;%����Ϊ�̶�������
resourceGrid.sizeRbTimeS =slotDuration/resourceGrid.nRBTime;%һ��RB��ʱ��
resourceGrid.sizeRbFreqHz = resourceGrid.nSubcarrierRb .* subcarrierSpacingHz;%һ��RB�����=ÿ��RB�����ز�����*���ز����
resourceGrid.nSymbolRb = 14;%ÿ��RB��14����������
resourceGrid.nSymbolSlot = 14;%ÿ��ʱ϶14��������
usableBandwidth=1;%5G��Ϊ0.98��LTE��Ϊ0.8
resourceGrid.nRBFreq = floor(bandwidthHz .* usableBandwidth ./resourceGrid.sizeRbFreqHz);
resourceGrid.nRBTot = resourceGrid.nRBFreq *resourceGrid.nRBTime;
resourceGrid.nCRCBits = 24;
nSubcarrierSlot = resourceGrid.nRBFreq .*resourceGrid. nSubcarrierRb;%ÿ��ʱ϶�����ز���
nSymbolSlot = resourceGrid.nRBTime .* floor(resourceGrid.sizeRbTimeS ./symbolDurationS);%ÿ��ʱ϶������
%ÿ��ʱ϶������

%% ��ʼ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%С����ʼ��������С��վ���intercelldistance����Ҫ������С����Ŀcellnum�����С����������x��y
%�Լ�����ͼ��Ե��ļ�����
% cellinstall������С�������ͼ��
%���������sitex С������x������
%           sitey С������y������
%           pedge  С���ֲ�������Ե��ļ����곤��pou
%           theatedge С���ֲ�������Ե��ļ�����Ƕ�theat
%wrap_around,ƽ�Ƶ��ܱ�6������
[sitecoorx,sitecoory,pedge,theatedge]=cellinstall;
[sitex_wrap,sitey_wrap]=wraparound(sitecoorx,sitecoory);

%%ѭ�����Ʋ���
cyclenum=1;
for cyclei=1:cyclenum
    [userlistcoorx,userlistcoory]=userinstall(pedge,theatedge); 
    %���������usernum �û�����
    %          userscalex �û��ֲ��߷�Χx����
    %          userscaley �û��ֲ��߷�Χy����
    %���������userlistcoorx �û�λ���б�x������
    %          userlistcoory �û�λ���б�y������

    
    %%%%% ����С��ȷ��������û���С���ṹ�壬��¼�û�����С�������С���ڷ����û���� %%%%%
    [userservice,cellservice,pathloss,pathloss_min]=servicecell_wrap(sitex_wrap,sitey_wrap,userlistcoorx,userlistcoory);    
    %userservice��1x570 struct; cellservice: 1x57 struct
    %pathloss:570*57��the pathloss between each user and each cell
    %pathloss_min:570*3��ÿ��UE�����С��֮���pathloss
    %%RIS������㣬���RISλ������RISlistcoorx,RISlistcoory
    [RISlistcoorx,RISlistcoory,RIShut] = RISinstall( pedge,theatedge);
     %%ȷ���û�λ������x,y�Լ���ʼ�ǶȺ;���
      hut=25;
      angle.a=unifrnd(0,360);
      angle.b=90;
      angle.c=0;
     
     
end
