clear;
%% ������ʼ��
Init_sim;
global sim;
Number_of_drops=1;
for idrop=Number_of_drops
    tic
    nUsergroups=57;
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
    %��ֻ��������
    % Frame_Structure='DDDSU';
    %segment=[0 0 0 2 1];
    Frame_Structure='DDDDD';
    segment=[0 0 0 0 0];
    Uplink_control_overhead=0.3;
    Downlink_control_overhead=0.2;
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
        %         userscalex �û��ֲ��߷�Χx����
        %         userscaley �û��ֲ��߷�Χy����
        %���������userlistcoorx �û�λ���б�x������
        %         userlistcoory �û�λ���б�y������
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
        [userservice,cellservice_UE,~,~]=servicecell_wrap(sitex_wrap,sitey_wrap,userlistcoorx,userlistcoory,UE);
        %UE��BS�������
        %userservice�û�����С���� struct; cellservice��С�������û����Լ���ţ�: struct
        %pathloss:570*57��the pathloss between each user and each cell
        %pathloss_min:570*3��ÿ��UE�����С��֮���pathloss
       
        [RISservice,cellservice_RIS,~,~]=servicecell_wrap(sitex_wrap,sitey_wrap,RISlistcoorx,RISlistcoory,RIS);
        [h_d_UE]=hd_everyBS(sitex_wrap,sitey_wrap,userlistcoorx,userlistcoory,UE,userservice);%jisuanÿ����վ��ÿ���û���ֱ���ŵ�
        %RIS��BS�������
        [unit_vector_RIS]=RISvector(RISservice,RIS,BS);
        for i=1:RISnum
            RIS{i}.unit_vector=unit_vector_RIS{i};%ÿ��RIS�ĳ���λ����
        end
        %BS-RIS-UE�������


        [RISlink]= linkmatch(sitex_wrap,sitey_wrap,userlistcoorx,userlistcoory,UE,RIS,BS,cellservice_UE,cellservice_RIS);
        %% ��ѯ����
        %�շָ��ÿ���ÿ����������PRB
        schedulelist=cell(Number_of_drops,1);
        schedulelist{idrop}.DL=cell(57,1);
        schedulelist{idrop}.UL=cell(57,1);
        schedulelist{idrop}.SL=cell(57,1);
        %����ÿ��slot
        [UL_PRB,DL_PRB]=cost_PRB(resourceGrid,Uplink_control_overhead,Downlink_control_overhead);%�������������
        for ig=1:57%ÿ������%�Ĳ�������
            iue=1;
            for islot=1:length(segment_total)
                switch  segment_total(islot)
                    case 1
                        UsersToBeScheduled_UL= UL_PRB;
                        [ind_RB,ind_slot]=find(UsersToBeScheduled_UL);%Ƶ���ʱ��
                        attachedUser=cell(cellservice_UE(ig).anchorusernum,1);
                        for a=1:(cellservice_UE(ig).anchorusernum)
                            attachedUser{a}.ID=a-1;
                        end
                        %attachedUser=cellservice_UE(ig).anchoruserlist; %�Ĳ�������
                        if ~isempty(attachedUser)
                            for is=1:length(ind_RB)
                                if (iue<=cellservice_UE(ig).anchorusernum)
                                    UsersToBeScheduled_UL(ind_RB(is),ind_slot(is))=attachedUser{iue}.ID+1;%id��0��ʼ��
                                    iue=iue+1;
                                else
                                    iue=1;
                                    UsersToBeScheduled_UL(ind_RB(is),ind_slot(is))=attachedUser{iue}.ID+1;
                                    iue=iue+1;
                                end
                            end
                        else
                        end
                        iulslot=find(find(segment_total==1)==islot);
                        schedulelist{idrop}.UL{ig}.UsersToBeScheduled(:,iulslot)=UsersToBeScheduled_UL;

                    case 0
                        UsersToBeScheduled_DL= DL_PRB;
                        [ind_RB,ind_slot]=find(UsersToBeScheduled_DL);%Ƶ���ʱ��
                        attachedUser=cell(1,cellservice_UE(ig).anchorusernum);
                        for a=1:(cellservice_UE(ig).anchorusernum)
                            attachedUser{a}.ID=a-1;
                        end
                        if ~isempty(attachedUser)
                            for is=1:length(ind_RB)
                                if (iue<=cellservice_UE(ig).anchorusernum)
                                    UsersToBeScheduled_DL(ind_RB(is),ind_slot(is))=attachedUser{iue}.ID+1;%id��0��ʼ��
                                    iue=iue+1;
                                else
                                    iue=1;
                                    UsersToBeScheduled_DL(ind_RB(is),ind_slot(is))=attachedUser{iue}.ID+1;
                                    iue=iue+1;
                                end
                            end
                        else
                        end
                        idlslot=find(find(segment_total==0)==islot);
                        schedulelist{idrop}.DL{ig}.UsersToBeScheduled(:,idlslot)=UsersToBeScheduled_DL;

                    case 2
                        UsersToBeScheduled_SL= DL_PRB;
                        [ind_RB,ind_slot]=find(UsersToBeScheduled_SL);%Ƶ���ʱ��
                        attachedUser=cell(cellservice_UE(ig).anchorusernum,1);
                        for a=1:(cellservice_UE(ig).anchorusernum)
                            attachedUser{a}.ID=a-1;
                        end
                        if ~isempty(attachedUser)
                            for is=1:length(ind_RB)
                                if (iue<=cellservice_UE(ig).anchorusernum)
                                    UsersToBeScheduled_SL(ind_RB(is),ind_slot(is))=attachedUser{iue}.ID+1;%id��0��ʼ��
                                    iue=iue+1;
                                else
                                    iue=1;
                                    UsersToBeScheduled_SL(ind_RB(is),ind_slot(is))=attachedUser{iue}.ID+1;
                                    iue=iue+1;
                                end
                            end
                        else
                        end
                        islslot=find(find(segment_total==2)==islot);
                        schedulelist{idrop}.SL{ig}.UsersToBeScheduled(:,islslot)=UsersToBeScheduled_SL;

                end
            end
        end


        toc
        %% sinr����
        for ig=1:nUsergroups
            for iu=1:cellservice_UE(ig).anchorusernum
                for islot=1:length(segment_total)
                    switch  segment_total(islot)
                        case 0%����sinr����
                            %prb����
                            idlslot=find(find(segment_total==0)==islot);
                            pos_PRB_DL(ig,iu,idrop).prb=find(schedulelist{idrop}.DL{ig}.UsersToBeScheduled(:,idlslot)==iu);
                            length_PRB_DL=length(pos_PRB_DL(ig ...
                                ,iu,idrop).prb);
                            length_RE_DL=length(pos_PRB_DL(ig,iu,idrop).prb)*12;
                            %��ʼ����sinr
                            if ~isempty( pos_PRB_DL(ig,iu,idrop).prb)%���û�prbռ�÷ǿ�
                                signal_DL=RISlink{cellservice_UE(ig).anchoruserlist(iu)}.BIUpower;%��С������
                                signal_other=sum(abs(h_d_UE).^2,2);
                                aa=max(h_d_UE(cellservice_UE(ig).anchoruserlist(iu)));
                                other_DL=signal_other(cellservice_UE(ig).anchoruserlist(iu),1)-abs(aa)^2;
                                B = resourceGrid.sizeRbFreqHz;%һ����Դ��Ĵ���
                                N0 = -174; % ���������ܶ���dBm/Hz
                                sigma2 = B*10^((N0 - 30)/10);
                                sinr_BIU(cellservice_UE(ig).anchoruserlist(iu),islot) = abs(RISlink{cellservice_UE(ig).anchoruserlist(iu)}.BIUpower)^2/(sigma2+other_DL/12);
                            end
                    end
                end
            end
        end


        hut=25;
        angle.a=unifrnd(0,360);
        angle.b=90;
        angle.c=0;
    end
end