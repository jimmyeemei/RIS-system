function [userlistcoorx,userlistcoory,hut] = userinstall( pedge,theatedge)
%�û�����������С���������η�Χ�ڣ��ܹ�usernum���û�
%���������usernum �û�����
%          userscalex �û��ֲ��߷�Χx����
%          userscaley �û��ֲ��߷�Χy����
%���������userlistcoorx �û�λ���б�x������
%          userlistcoory �û�λ���б�y������
%          hut �ն����߸߶�
%          out�������������û�   out=1Ϊ�����û�
%          d2_in�����û������ھ���
paramentss;
global sim;
usernumpercell=sim.usernumpercell;
sitenum=sim.sitenum;
usernum=sitenum*usernumpercell*3;

userlistcoorx=zeros(1,usernum);
userlistcoory=zeros(1,usernum);
hut=zeros(1,usernum);
maxp=max(pedge);%������귶Χ

angle(usernum)=struct('a',0,...
    'b',0,...
    'c',0); 

for i=1:usernum %��ʼ�û�����ѭ��
    loop=0; %����������loop=1���ҵ���С���ڵ��û�
    while loop==0       %ͨ��ת�������������ж��Ƿ�λ��С����
        x=2*(rand-0.5)*maxp; 
        y=2*(rand-0.5)*maxp; %�����������������������Χ����󳤶ȷ�Χ
        ptemp=sqrt(x^2+y^2); %�����ĳ�������
        if x==0  %�����ĽǶ�����
            if y>=0
                theat=pi/2;
            else
                theat=pi*3/2;
            end
        elseif x>0
            if y>=0
                theat=atan(y/x);
            else
                theat=atan(y/x)+2*pi;
            end
        else
            theat=atan(y/x)+pi;
        end
        indextemp=0; %��ʼ�ж�����������Ե������Ǹ��Ƕȷ�Χ֮��
        for j=1:length(theatedge) %Ѱ�������Ƕȴ����Ե����Ƕȵ����һ����Ե�������
            if theat>theatedge(j)
                indextemp=j;
            end
        end
        if indextemp==0 || indextemp==length(theatedge) %����ڵ�һ�������һ��֮�䣬���⴦��
            alpha=theat+2*pi-theatedge(length(theatedge));
            belt=theatedge(1)-theat;
            a=pedge(length(theatedge));
            b=pedge(1);
        else  %����ͨ����Ŵ���
            alpha=theat-theatedge(indextemp);
            belt=theatedge(indextemp+1)-theat;
            a=pedge(indextemp);
            b=pedge(indextemp+1);
        end
        pedgetemp=b*a*sin(alpha+belt)/(a*sin(alpha)+b*sin(belt)); %ͨ���Ƿֶ������Ĵ��ڱ�Եʱ��ļ����곤��
        if ptemp<=pedgetemp  %�жϳ����Ƿ�С�ڱ�Ե�����Ƿ���С����Χ��
            userlistcoorx(i)=x; %����x��y����
            userlistcoory(i)=y;
          

            loop=1; %����ѭ������������ѭ��  %%yangshan:��ʾ����û������ɹ�
%             disp(['ptemp=',int2str(ptemp),'pedgetemp=',int2str(pedgetemp)])
        else
%             disp('out range');
        end
    end
end

%%ȷ���������û��������û���ʼ�߶ȺͽǶ�


for i=1:usernum 
  Nf1=unifrnd(4,8);
  nf1=unifrnd(1,Nf1);
  hut(i)=3*(nf1-1)+1.5;
  angle(i).a=unifrnd(0,360);
  angle(i).b=90;
  angle(i).c=0;
 
  
  
end


sim.hut = hut;
sim.userlistcoorx = userlistcoorx;
sim.userlistcoory = userlistcoory;
sim.Qx = angle(i).a;
sim.Qy = angle(i).b;
sim.Qz = angle(i).c;
%%R_zyx=rotz(Qz)*roty(Qy)*rotx(Qz)
hold on;
plot(userlistcoorx,userlistcoory,'.k');
hold off;


