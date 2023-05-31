clear;
%% ������ʼ��
Init_sim;
global sim;
way_of_userinstall='�޶�����';
limit_min_distance=150;
limit_max_distance=160;
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
%wrap-around��ȡƽ�Ƶķ�ʽ������ԵЧӦ
BSnum=sim.cellnum;
    BS=cell(BSnum,1);
    for i=1:BSnum
        BS{i}.hbs=sim.hbs;%��վͳһ�߶�hbs25m
        BS{i}.site=[sitex_wrap(i),sitey_wrap(i) sim.hbs];%��¼ÿ����վ������
    end      


%%ѭ�����Ʋ���
cyclenum=1;
for cyclei=1:cyclenum
    if way_of_userinstall=='�޶�����'
        [userlistcoorx,userlistcoory]=limit_userinstall_limit(BS,limit_min_distance,limit_max_distance);

    elseif way_of_userinstall=='�������'
        [userlistcoorx,userlistcoory]=userinstall(pedge,theatedge); %�ο�comp���û����㷽ʽ��19��С�����������
    end
    %���������usernum �û�����
    %          userscalex �û��ֲ��߷�Χx����
    %          userscaley �û��ֲ��߷�Χy����
    %���������userlistcoorx �û�λ���б�x������
    %          userlistcoory �û�λ���б�y������
    usernum=sim.usernumpercell*sim.cellnum;
    UE=cell(usernum,1);
    for i=1:usernum
        UE{i}.site=[userlistcoorx(i), userlistcoory(i)];%��¼ÿ���û�������
        Nf1=unifrnd(1,4,1);
        nf1=unifrnd(1,Nf1,1);
        hut=3*(nf1-1)+1.5;
        UE{i}.hut=hut;
    end
      %%RIS������㣬���RISλ������RISlistcoorx,RISlistcoory
    [RISlistcoorx,RISlistcoory] = RISinstall( pedge,theatedge);
    RISnum=sim.RISnumpercell*sim.cellnum;
    RIS=cell(RISnum,1);
    for i=1:RISnum
       RIS{i}.hut=sim.RIShut;%risͳһ�߶�rishut25m  
       RIS{i}.site=[RISlistcoorx(i),RISlistcoory(i) sim.RIShut];%��¼ÿ���û�������
       RIS{i}.unit_vector=[];
    end
%%  %%%%% ����С��ȷ��������û���С���ṹ�壬��¼�û�����С�������С���ڷ����û���� %%%%%
    [userservice,cellservice_UE,pathloss_UE,pathloss_min_UE]=servicecell_wrap(sitex_wrap,sitey_wrap,userlistcoorx,userlistcoory,UE);
    %UE��BS�������
    %userservice�û�����С���� struct; cellservice��С�������û����Լ���ţ�: struct
    %pathloss:570*57��the pathloss between each user and each cell
    %pathloss_min:570*3��ÿ��UE�����С��֮���pathloss
    [RISservice,cellservice_RIS,pathloss_RIS,pathloss_min_RIS]=servicecell_wrap(sitex_wrap,sitey_wrap,RISlistcoorx,RISlistcoory,RIS);
     %RIS��BS�������
     [unit_vector_RIS]=RISvector(RISservice,RIS,BS);
    for i=1:RISnum
       RIS{i}.unit_vector=unit_vector_RIS{i};%ÿ��RIS�ĳ���λ����
    end
%BS-RIS-UE�������


[RISlink]= linkmatch(sitex_wrap,sitey_wrap,userlistcoorx,userlistcoory,UE,RIS,BS,cellservice_UE,cellservice_RIS);

      hut=25;
      angle.a=unifrnd(0,360);
      angle.b=90;
      angle.c=0;  
end
