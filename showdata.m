function showdata()

global Subjects;
Subjects = [1:7];
addpath('.\ploterr');
if ~exist('results')
    mkdir('results');
end

for subcount = Subjects
data = loadrawdata(subcount);
models = fitmodel(data);
mkdir(['./results/',num2str(subcount)]);
save(['./results/',num2str(subcount),'/models'],'models');

end
plotdata();

X2 = [];X6 = [];X20 = [];
Y2 = [];Y6 = [];Y20 = [];
ID2 = [];ID6 = [];ID20 = [];

for subcount = Subjects
data = loadrawdata(subcount);
X2 = [X2;data.Xdata2];
Y2 = [Y2;data.Ydata2];
ID2 = [ID2;subcount*ones(length(data.Xdata2),1)];

X6 = [X6;data.Xdata6];
Y6 = [Y6;data.Ydata6];
ID6 = [ID6;subcount*ones(length(data.Xdata6),1)];

X20 = [X20;data.Xdata20];
Y20 = [Y20;data.Ydata20];
ID20 = [ID20;subcount*ones(length(data.Xdata20),1)];

end

dataForMixedEffect.X2 = X2;
dataForMixedEffect.X6 = X6;
dataForMixedEffect.X20 = X20;

dataForMixedEffect.Y2 = Y2;
dataForMixedEffect.Y6 = Y6;
dataForMixedEffect.Y20 = Y20;

dataForMixedEffect.ID2 = ID2;
dataForMixedEffect.ID6 = ID6;
dataForMixedEffect.ID20 = ID20;

[RMSE, sensitivity] = fitMixedEffectModel(dataForMixedEffect);

end


function data = loadrawdata(subcount)
Files = dir('./preprocessed/');
data = load(['./preprocessed/',Files(subcount + 2).name]);
   
end

function models = fitmodel(data)



mdl = LinearModel.fit(data.Xdata20,data.Ydata20);
sensitivity_spem_20 = mdl.Coefficients.Estimate(2);
RMSE_spem_20 = mdl.RMSE;


mdl = LinearModel.fit(data.Xdata6,data.Ydata6);
sensitivity_spem_6 = mdl.Coefficients.Estimate(2);
RMSE_spem_6 = mdl.RMSE;

mdl = LinearModel.fit(data.Xdata2,data.Ydata2);
sensitivity_spem_2 = mdl.Coefficients.Estimate(2);
RMSE_spem_2 = mdl.RMSE;

models.sensitivity_spem_20 = sensitivity_spem_20;
models.RMSE_spem_20 = RMSE_spem_20;
models.sensitivity_spem_6 = sensitivity_spem_6;
models.RMSE_spem_6 = RMSE_spem_6;
models.sensitivity_spem_2 = sensitivity_spem_2;
models.RMSE_spem_2 = RMSE_spem_2;


end

function [RMSE, sensitivity] = fitMixedEffectModel(dataForMixedEffect)

X = dataForMixedEffect.X2;
Y = dataForMixedEffect.Y2;
ID = dataForMixedEffect.ID2;

datatable = table(X,Y,ID);
mixedmodel = fitglme(datatable,'Y ~ 1 + X + (1|ID) + (X|ID)');
RMSE(1) = sqrt(mixedmodel.Dispersion);
sensitivity(1) = mixedmodel.Coefficients.Estimate(2);

X = dataForMixedEffect.X6;
Y = dataForMixedEffect.Y6;
ID = dataForMixedEffect.ID6;

datatable = table(X,Y,ID);
mixedmodel = fitglme(datatable,'Y ~ 1 + X + (1|ID) + (X|ID)');
RMSE(2) = sqrt(mixedmodel.Dispersion);
sensitivity(2) = mixedmodel.Coefficients.Estimate(2);


X = dataForMixedEffect.X20;
Y = dataForMixedEffect.Y20;
ID = dataForMixedEffect.ID20;

datatable = table(X,Y,ID);
mixedmodel = fitglme(datatable,'Y ~ 1 + X + (1|ID) + (X|ID)');
RMSE(3) = sqrt(mixedmodel.Dispersion);
sensitivity(3) = mixedmodel.Coefficients.Estimate(2);




end

function plotdata()
global Subjects;

% subjFolders = dir('./results');
numSubjects = length(Subjects);
figure(2);set(gcf,'color','w','position',[440   378   500   300]);
k = 0;
for jj = Subjects
    k = k + 1;
load(['./results/',num2str(jj),'/models'])

sensitivity_spem_2 = models.sensitivity_spem_2;
sensitivity_spem_6 = models.sensitivity_spem_6;
sensitivity_spem_20 = models.sensitivity_spem_20;

RMSE_spem_2 = models.RMSE_spem_2;
RMSE_spem_6 = models.RMSE_spem_6;
RMSE_spem_20 = models.RMSE_spem_20;


MAX = max([sensitivity_spem_2,sensitivity_spem_6,sensitivity_spem_20]);
MIN = min([sensitivity_spem_2,sensitivity_spem_6,sensitivity_spem_20]);
sensitivity_spem_2 = (sensitivity_spem_2 - MIN)./(MAX - MIN);
sensitivity_spem_6 = (sensitivity_spem_6 - MIN)./(MAX - MIN);
sensitivity_spem_20 = (sensitivity_spem_20 - MIN)./(MAX - MIN);
spem_sens(k,:) = [sensitivity_spem_2,sensitivity_spem_6,sensitivity_spem_20];
% subplot(1,2,1);hold on;plot([2,6,20],[sensitivity_spem_2,sensitivity_spem_6,sensitivity_spem_20],'o-','Color',[0.7,0.7,0.7]);ylabel('spem sens')


MAX = max([RMSE_spem_2,RMSE_spem_6,RMSE_spem_20]);
MIN = min([RMSE_spem_2,RMSE_spem_6,RMSE_spem_20]);
RMSE_spem_2 = (RMSE_spem_2 - MIN)./(MAX - MIN);
RMSE_spem_6 = (RMSE_spem_6 - MIN)./(MAX - MIN);
RMSE_spem_20 = (RMSE_spem_20 - MIN)./(MAX - MIN);
spem_rmse(k,:) = [RMSE_spem_2,RMSE_spem_6,RMSE_spem_20];
% subplot(1,2,2);hold on;plot([2,6,20],[RMSE_spem_2,RMSE_spem_6,RMSE_spem_20],'o-','Color',[0.7,0.7,0.7]);ylabel('spem RMSE')



end

% plot the gain (slope) and variability (rmse) of smooth pursuit for
% average subject
subplot(1,2,1);hold on;plot([2,6,20],median(spem_sens,1),'o-k','LineWidth',2,'MarkerSize',5);
set(gca,'FontSize',15,'LineWidth',3,'XTick',[2,6,20])
xlabel('diameter (degree)');ylabel('sensitivity');
subplot(1,2,2);hold on;plot([2,6,20],median(spem_rmse,1),'o-k','LineWidth',2,'MarkerSize',5);
set(gca,'FontSize',15,'LineWidth',3,'XTick',[2,6,20])
xlabel('diameter (degree)');ylabel('RMSE');

LY = max(0,median(spem_sens,1)-std(spem_sens,1)./sqrt(numSubjects));
UY = min(1,median(spem_sens,1)+std(spem_sens,1)./sqrt(numSubjects));
subplot(1,2,1);hold on;ploterr([2,6,20],median(spem_sens,1),[],{LY,UY},'.k');
LY = max(0,median(spem_rmse,1)-std(spem_rmse,1)./sqrt(numSubjects));
UY = min(1,median(spem_rmse,1)+std(spem_rmse,1)./sqrt(numSubjects));
subplot(1,2,2);hold on;ploterr([2,6,20],median(spem_rmse,1),[],{LY,UY},'.k')

 saveas(gcf,'./figures/fig4.svg')
end
