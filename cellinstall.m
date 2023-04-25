function [sitecoorx,sitecoory,pedge,theatedge] =cellinstall
% ���������sitenumС������
%        intersitedistance С�����ļ��
%  ���������sitecoorx С������x������
%           sitecoory  С������y������
%           pedge  С���ֲ�������Ե��ļ����곤��pou
%           theatedge С���ֲ�������Ե��ļ�����Ƕ�theat
global sim;
sitenum=sim.sitenum;
intersitedistance=sim.intersitedistance;



%%����С���Ϸ���Ŀ����
supportnum=[1,7,19,37,61,127,169,217,271,331];%���㹫ʽΪ(sitenum-1)/6=n*(n-1)/2,nΪС������
if find(supportnum==sitenum)
    layernum=find(supportnum==sitenum)-1;%�����ܹ��м���С������һ��С���ǵ�0��
else
    error('wrong site number!');
end

sitecoorx=zeros(1,sitenum);
sitecoory=zeros(1,sitenum);

if layernum==0 %��С��ʱ������λ��ԭ��
    sitecoorx(1)=0.0;
    sitecoory(1)=0.0;
else
    for layercycle=1:layernum %�������
        for i=1:layercycle %ͨ��ѭ������һ��60�ȷ�Χ�ڵ�С����������ƫ��ֵ
            rou=zeros(1,layercycle);
            angle=zeros(1,layercycle);
            for k=1:i
                if k==1
                    rou(k)=layercycle*intersitedistance;  %��0�ȵ�ֱ���ϣ�ÿ�������վ���
                    angle(k)=0.0;
                else   %�����Ƕȣ�ͨ�����Ҷ�����㣬һ����Ϊ0��ֱ���ϵ�С�����ģ���һ����Ϊ0��ֱ���ϵ�С���뵱ǰС������С����������߼н�ʼ��Ϊ60��
                    rou(k)=sqrt(rou(1)^2+(intersitedistance*(k-1))^2-2*rou(1)*intersitedistance*(k-1)*cos(pi/3));
                    angle(k)=acos(((rou(1)^2+rou(k)^2-(intersitedistance*(k-1))^2)/2/rou(1)/rou(k)));
                end
            end
        end
        n=1; %��0��ı��
        for k=1:layercycle
            n=n+(k-1)*6; %������㿪ʼ��С�����
        end
        for j=1:6 %ÿ60�ȸ���һ��60���ڵĻ�����λ
            sitecoorx(n+(j-1)*layercycle+1:n+j*layercycle)=rou.*cos(pi/3*(j-1)+angle);
            sitecoory(n+(j-1)*layercycle+1:n+j*layercycle)=rou.*sin(pi/3*(j-1)+angle);
        end
    end
end

%����С������ͼ

angleplot=[pi/6:pi/3:pi/6+2*pi];
rouplot=intersitedistance/sqrt(3);
coorxplot=rouplot*cos(angleplot);
cooryplot=rouplot*sin(angleplot);
plot(sitecoorx,sitecoory,'ro');%��վλ��ͼ
hold on;
plot(sitecoorx,sitecoory,'r*');%��վλ��ͼ
plot(sitecoorx,sitecoory,'rp');%��վλ��ͼ
plot(sitecoorx,sitecoory,'r.');%��վλ��ͼ
hold on;
for i=1:sitenum
    plot(coorxplot+sitecoorx(i),cooryplot+sitecoory(i),'-k');%����С��ͼ��ͨ�������ε�ƽ��ʵ��
end

for i=1:sitenum
    for j=1:3
        plot([sitecoorx(i),sitecoorx(i)+sum(coorxplot(2*j-1:2*j))/2],[sitecoory(i),sitecoory(i)+sum(cooryplot(2*j-1:2*j))/2],'-k');
    end
end
hold off;
%��������С����Եת�۵�����
%ͨ������1/6�����Ȼ��ͨ����ת�õ��������
if layernum==0 %ֻ��һ��С��ʱ���������x��Ϊ30�ȵļн�
    scaletempx=intersitedistance/2; %x����
    scaletempy=intersitedistance/3^0.5/2; %y����
else
    scaletempx=zeros(1,2*layernum+1); %������������
    scaletempy=zeros(1,2*layernum+1);
    for i=1:2*layernum+1
        ntemp=supportnum(layernum)+floor((i+1)/2); %��ͬ���С�����ı�Ų�ͬ
        if mod(i,2)==1 %����ǵ���������
            scaletempx(i)=sitecoorx(ntemp)+intersitedistance/2; %x�����С�������������С�����
            scaletempy(i)=sitecoory(ntemp)+intersitedistance/3^0.5/2; %y���������������30�Ƚ�
        else %����ǵ�ż������
            scaletempx(i)=sitecoorx(ntemp); %x������С������������ͬ
            scaletempy(i)=sitecoory(ntemp)+2*intersitedistance/3^0.5/2; %y���������������90�Ƚ�
        end
    end
end


ptemp=zeros(1,6*(2*layernum+1)); %���ɼ��������
theattemp=zeros(1,6*(2*layernum+1));
for i=1:2*layernum+1 %ת���ɼ�����
    ptemp(i)=sqrt(scaletempx(i)^2+scaletempy(i)^2); 
    theattemp(i)=atan(scaletempy(i)/scaletempx(i));
end
for i=1:5 %��ת
    ptemp((2*layernum+1)*i+1:(2*layernum+1)*(i+1))= ptemp(1:2*layernum+1);
    theattemp((2*layernum+1)*i+1:(2*layernum+1)*(i+1))= theattemp(1:2*layernum+1)+ones(1,2*layernum+1)*pi/3*i;
end


pedge=ptemp; %����ֵ
theatedge=theattemp;










