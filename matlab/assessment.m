%function [pearson,spearman]=assessment(result,subject,flag_plot)
%090119 ģ���������۲���
 clc;
 %绘制传统方法曲线专用
 fid1=fopen('/media/s408/GLORIA/ACMM/code/niqe/niqe_scores.txt');
 fid2=fopen('/media/s408/GLORIA/ACMM/code/niqe/niqe_val.txt');
 c1=textscan(fid1,'%f');
 c2=textscan(fid2,'%f');
 fclose(fid1);
 fclose(fid2);
 subject=cell2mat(c1);
 result=cell2mat(c2); 
 tdatatemp=result(:);
 cdatatemp=subject(:);
 [cdata,index]=sort(cdatatemp,1,'descend');
 tdata=tdatatemp(index(find(cdata>0))); 
%绘制QL-IQA专用
%  fid1=fopen('cdata.txt');
%  fid2=fopen('tdata.txt');
%  c1=textscan(fid1,'%f');
%  c2=textscan(fid2,'%f');
%  fclose(fid1);
%  fclose(fid2);
%  cdata=cell2mat(c1);
%  tdata=cell2mat(c2);
  
% xini=[max(cdata),min(cdata),mean(tdata),2]; %logistic ����ĳ�ʼ����ֵ
%  %dmosp=curvefit(xini,tdata,cdata); %ʹ����С���˷��Կ͹�ֵ������ֵ������ϣ��ҵ�logistic����Ĳ���������֪�Ĳ�������͹�ֵtdata��Ӧ������Ԥ��ֵ  
% %xini=[1,1,1,1,1];
%  %options = statset('nlinfit'); 
% options.MaxIter = 1000;
% xk=nlinfit(tdata,cdata,@logistic,xini,options); 
% dmosp=logistic(xk,tdata);  
dmosp = verify_performance_single(cdata,tdata);
pearson=corr([dmosp,cdata], 'type','Pearson');
pearson=pearson(2);
spearman=corr([cdata,dmosp],'type','Spearman');
spearman=spearman(2);
% KRCC =corr([cdata,dmosp],'type','Kendall');    %Kendall�����ϵ��
% KRCC=KRCC(2);
if true
     figure,
     AX1=axes('Pos',[0.16 0.17 0.79 0.8],'Box','on','FontSize',10.5);
     set(AX1,'XLim',[0 100],'YLim',[0 100]);
     plot(tdata,cdata,'*');   %�����͹�ֵ������ֵ��ɢ��ͼ
     hold
     [tdata1,index]=sort(tdata,1,'descend'); %�͹�ֵ�Ӵ�С����         
     dmosp1=zeros(size(dmosp));
     dmosp1(:)=dmosp(index(:));
     plot(tdata1,dmosp1,'-');
     %������ϵ�����
     ylabel('DMOS');
     xlabel('predicted DMOS'); 
     legend('Image in LIVE MD','Curve fitted with logistic function','northwest');
end

