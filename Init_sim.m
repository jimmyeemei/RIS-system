function sim=Init_sim
global sim;

sim = struct( ...
    'flag',1,... %flag=0����UMi��flag=1����UMa
    'intersitedistance',500,... %վ���500m%%ϵͳ����         
    'sitenum',19,...  %��ʼ��7��С��,ȡ7,19�ȣ�һȦһȦ�ؼ�
    'cellnum',57,...  %��������Ŀ
    'raynum',20,...   %ÿ���Ӿ���
    'hbs',25,...  %��վ���߸߶�
    'Gain',49,...   %��վ���书��dBm
    'mind2d',10,... %�ն˵���վ����С2D����
    'wrap_offsetx',[0 4 7/2 -1/2 -4 -7/2 1/2],...%��λΪintersitedistance
    'wrap_offsety',[0 sqrt(3) -3*sqrt(3)/2 -5*sqrt(3)/2  -sqrt(3) 3*sqrt(3)/2 5*sqrt(3)/2],...%��λΪintersitedistance
    'usernumpersite',5,...
    'RISnumpersite',1,...%RIS��������
    'userlistcoorx',zeros(1,570),...%�û�����
    'userlistcoory',zeros(1,570),...
    'hut',25,...%�ն����߸߶�
    'Qx',zeros(1,570),...%�û���ʼ�Ƕ�
    'Qy',zeros(1,570),...
    'Qz',zeros(1,570),...
    'bandwidth',10,...% in MHz
    'RB_num',75,...
    'cluster_size',3,...
    'iter_times',1+4,...
    'sinrthreshold',-6,...
    'fc',6*10^9, ...
    'RIShut',15, ...
    'compthreshold',3 ...%����Ƶ�� 
    );


