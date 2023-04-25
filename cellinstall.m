function [sitecoorx,sitecoory,pedge,theatedge] =cellinstall
% 输入参数：sitenum小区数量
%        intersitedistance 小区中心间隔
%  输出参数：sitecoorx 小区中心x轴坐标
%           sitecoory  小区中心y轴坐标
%           pedge  小区分布地区边缘点的极坐标长度pou
%           theatedge 小区分布地区边缘点的极坐标角度theat
global sim;
sitenum=sim.sitenum;
intersitedistance=sim.intersitedistance;



%%输入小区合法数目计算
supportnum=[1,7,19,37,61,127,169,217,271,331];%计算公式为(sitenum-1)/6=n*(n-1)/2,n为小区层数
if find(supportnum==sitenum)
    layernum=find(supportnum==sitenum)-1;%查找总共有几层小区，第一个小区是第0层
else
    error('wrong site number!');
end

sitecoorx=zeros(1,sitenum);
sitecoory=zeros(1,sitenum);

if layernum==0 %单小区时，坐标位于原点
    sitecoorx(1)=0.0;
    sitecoory(1)=0.0;
else
    for layercycle=1:layernum %按层绘制
        for i=1:layercycle %通过循环计算一个60度范围内的小区中心坐标偏移值
            rou=zeros(1,layercycle);
            angle=zeros(1,layercycle);
            for k=1:i
                if k==1
                    rou(k)=layercycle*intersitedistance;  %在0度的直线上，每层相隔基站间距
                    angle(k)=0.0;
                else   %其它角度，通过余弦定理计算，一条边为0度直线上的小区中心，另一条边为0度直线上的小区与当前小区相差的小区间隔，两边夹角始终为60度
                    rou(k)=sqrt(rou(1)^2+(intersitedistance*(k-1))^2-2*rou(1)*intersitedistance*(k-1)*cos(pi/3));
                    angle(k)=acos(((rou(1)^2+rou(k)^2-(intersitedistance*(k-1))^2)/2/rou(1)/rou(k)));
                end
            end
        end
        n=1; %第0层的编号
        for k=1:layercycle
            n=n+(k-1)*6; %计算这层开始的小区编号
        end
        for j=1:6 %每60度复制一个60度内的基本单位
            sitecoorx(n+(j-1)*layercycle+1:n+j*layercycle)=rou.*cos(pi/3*(j-1)+angle);
            sitecoory(n+(j-1)*layercycle+1:n+j*layercycle)=rou.*sin(pi/3*(j-1)+angle);
        end
    end
end

%绘制小区构造图

angleplot=[pi/6:pi/3:pi/6+2*pi];
rouplot=intersitedistance/sqrt(3);
coorxplot=rouplot*cos(angleplot);
cooryplot=rouplot*sin(angleplot);
plot(sitecoorx,sitecoory,'ro');%基站位置图
hold on;
plot(sitecoorx,sitecoory,'r*');%基站位置图
plot(sitecoorx,sitecoory,'rp');%基站位置图
plot(sitecoorx,sitecoory,'r.');%基站位置图
hold on;
for i=1:sitenum
    plot(coorxplot+sitecoorx(i),cooryplot+sitecoory(i),'-k');%整体小区图，通过六边形的平移实现
end

for i=1:sitenum
    for j=1:3
        plot([sitecoorx(i),sitecoorx(i)+sum(coorxplot(2*j-1:2*j))/2],[sitecoory(i),sitecoory(i)+sum(cooryplot(2*j-1:2*j))/2],'-k');
    end
end
hold off;
%计算整体小区边缘转折点坐标
%通过计算1/6情况，然后通过旋转得到整体情况
if layernum==0 %只有一个小区时的情况，与x轴为30度的夹角
    scaletempx=intersitedistance/2; %x坐标
    scaletempy=intersitedistance/3^0.5/2; %y坐标
else
    scaletempx=zeros(1,2*layernum+1); %点数与层数相关
    scaletempy=zeros(1,2*layernum+1);
    for i=1:2*layernum+1
        ntemp=supportnum(layernum)+floor((i+1)/2); %不同点的小区中心编号不同
        if mod(i,2)==1 %如果是第奇数个点
            scaletempx(i)=sitecoorx(ntemp)+intersitedistance/2; %x坐标比小区中心坐标大半个小区间隔
            scaletempy(i)=sitecoory(ntemp)+intersitedistance/3^0.5/2; %y坐标与中心坐标成30度角
        else %如果是第偶数个点
            scaletempx(i)=sitecoorx(ntemp); %x坐标与小区中心坐标相同
            scaletempy(i)=sitecoory(ntemp)+2*intersitedistance/3^0.5/2; %y坐标与中心坐标成90度角
        end
    end
end


ptemp=zeros(1,6*(2*layernum+1)); %生成极坐标参数
theattemp=zeros(1,6*(2*layernum+1));
for i=1:2*layernum+1 %转化成极坐标
    ptemp(i)=sqrt(scaletempx(i)^2+scaletempy(i)^2); 
    theattemp(i)=atan(scaletempy(i)/scaletempx(i));
end
for i=1:5 %旋转
    ptemp((2*layernum+1)*i+1:(2*layernum+1)*(i+1))= ptemp(1:2*layernum+1);
    theattemp((2*layernum+1)*i+1:(2*layernum+1)*(i+1))= theattemp(1:2*layernum+1)+ones(1,2*layernum+1)*pi/3*i;
end


pedge=ptemp; %返回值
theatedge=theattemp;










