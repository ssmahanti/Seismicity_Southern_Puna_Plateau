%This script creates the histograms that compare our result with Mulachy et
%al. 2014 results
clear;
data=load('/Users/sankha/Desktop/research/Spuna_plateau/velest/output/catalog_velest_puna_crust_v5.txt');
data2=load('/Users/sankha/Desktop/research/Spuna_plateau/paper_figures/plotdata/mulcahy_freq.txt');
y1=data(:,1);
m1=data(:,2);
d1=data(:,3);
hh1=data(:,4);
mm1=data(:,5);
ss1=data(:,6);
y2=data2(:,1);
m2=data2(:,2);
d2=data2(:,3);
hh2=data2(:,4);
mm2=data2(:,5);
ss2=data2(:,6);
t1=datetime(2000+y1,m1,d1,hh1,mm1,ss1);
t2=datetime(y2,m2,d2,hh2,mm2,ss2);
set(gcf, 'Position',  [100, 100, 1800, 1000]);
histogram(t1,213,'facecolor','r','edgecolor','black','linewidth',0.01,'facealpha',1.0)
hold on
histogram(t2,213,'facecolor','#0072BD','edgecolor','black','linewidth',0.01,'facealpha',1.0)
legend('This Study ','Mulcahy et al. 2014')
set(gca,'FontSize',35)
ylabel('No. of Events')
saveas(gcf,'event_histogram.jpg')