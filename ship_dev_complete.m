%% Initialization

clear all; clc; close all;
load('ship_dev_complete.mat');

TOT_Ships_=[];
TOT_SSP_ships=[];
Storage_results_en_dem_x_SSP=[];
%%
%%% 1=Container, 2=drybulk, 3=chem, 4=oil  
for SSP=1:5
    En_demand=[];
    TOT_Ships_=[];
for sh = 1:4
%% Importing the number of ship in 2050, per each SSP 
%the data are stored in the NN table

if sh ==1
    n_ships201517=table2array(container1517);
    NAVI_FINAL=table2array(NN(1:8,2:6));
elseif sh ==2
    n_ships201517=table2array(drybulk1517);
    NAVI_FINAL=table2array(NN(10:15,2:6));
elseif sh==3
    n_ships201517=table2array(chemical1517);
    NAVI_FINAL=table2array(NN(17:20,2:6));
elseif sh==4
    n_ships201517=table2array(oil1517);
    NAVI_FINAL=table2array(NN(22:29,2:6));
end
    
tot_n_ships2015=sum(n_ships201517);

%% avg.capacity is in dwt/ship
if sh == 1
    capacity=containercap2050';
elseif sh==2
    capacity=drybulkcap2050;
elseif sh==3
    capacity=chemcp2050;
elseif sh==4
    capacity=oilcap2050;
end

%(dwt/ship)the avarage per every bin size is going to remain constant from 2012 values
% (IMO3) but
%the distribution of bin sizes is gonna change sooo the avg size is gonna
%increase
%% productivity
if sh == 1
    productivity=readmatrix('Fuel_data.xlsx', 'Sheet', 'FleetDevelopment', 'Range', 'E19:AN26');
elseif sh==2
    productivity=readmatrix('Fuel_data.xlsx', 'Sheet', 'FleetDevelopment', 'Range', 'E85:AN90');
elseif sh==3
    productivity=readmatrix('Fuel_data.xlsx', 'Sheet', 'FleetDevelopment', 'Range', 'E139:AN142');
elseif sh==4
    productivity=readmatrix('Fuel_data.xlsx', 'Sheet', 'FleetDevelopment', 'Range', 'E118:AN125');
end
%productivity= prod(1,sh); %(tonne miles/dwt) from IMO 3
%% N. ships in the fleet in 2050 

TR_WORK_ship= capacity.*productivity; %this is ton-nm/ship and is one for every ship cathegoty


%% Distribution of the bin sizes over the total

if sh==1
    percentages=distcont';
elseif sh==2
    percentages=distdb';
elseif sh==3
    percentages=distchem';
elseif sh==4
    percentages=distoil';
end

%n_ships2050=tot_n_ships2050*percentages; %distribution
n_ships2050=NAVI_FINAL(:,SSP);
%%
k=1.008;
r=-0.2;
y= [2018:1:2050];
y_tot= [2015, 2016, 2017, y];
age_of_ship=[0:1:25];
y_max= 2033; %year in which the curve is forcasted to invert concavity
%%
n_ships= zeros(length(n_ships201517), length(y_tot)); %distribution of every ship size for every age
n_ships(:,1:3)=n_ships201517;

%% Initializing table total ships per year per bin size

tot_ships_size=zeros(length(capacity), length(y));
if sh==1
    tot_ships_size(:,1:3)=[926, 920, 914; 1307, 1315, 1328; 670, 679, 696; 1003, 989, 976; 624, 624, 625; 544, 578, 605; 175, 187, 203; 64, 81, 108];
elseif sh==2
    tot_ships_size(:,1:3)=[202, 201, 203; 1798, 1823, 1810; 3119, 3222, 3304; 2858, 3120, 3354; 1314, 1368, 1380; 404, 436, 467];
elseif sh==3
    tot_ships_size(:,1:3)=[957, 924, 891; 818, 806, 805; 1002, 1031, 1049; 1704, 1837, 1937];
elseif sh==4
    tot_ships_size(:,1:3)=[1846, 1812, 1749; 608, 616, 623; 174, 177, 185; 596, 584, 573; 405, 422, 433; 940, 983, 1030; 509, 531, 583; 662, 708, 754];
end

%% 

for i=1:length(y)
    tot_ships_size(:,i+3)= (tot_ships_size(:,3)*k)+(n_ships2050(:,1)-tot_ships_size(:,3)*k)/(1+exp(r*(y(i)-y_max)));
    
end

sum_s= sum(tot_ships_size);
TOT_Ships_=[TOT_Ships_; sum_s];

%% Estimate of the energy consumption
%fuel demand is per every year 2015-2050 in kWh/ton-nm

energy_cn=[];
energy_cn_tot=[];

if sh==1
    fuel_table=table2array(Fuel_container);
elseif sh==2
    fuel_table=table2array(Fuel_db);
elseif sh==3
    fuel_table=table2array(Fuel_chem);
elseif sh==4
    fuel_table=table2array(Fuel_oil);
end
%%
for k=1:length(y_tot)
    
    energy_cn(:,k)=tot_ships_size(:,k).*fuel_table(:,k).*TR_WORK_ship(:,k); 
    energy_cn_tot(1,k)=sum(energy_cn(:,k));
end

En_demand=[En_demand, energy_cn_tot']; %this is in kWh

%% GRAPHS
if SSP==2
if sh==1 
figure()
plot(y_tot, tot_ships_size);
title('N. containers for each size bin')
xlabel('year')
ylabel('N. ships')
legend ('TEU 0-999','TEU 1000-1999','TEU 2000-2999','TEU 3000-4999','TEU 5000-7999','TEU 8000-11999','TEU 12000-14500','TEU 14500 +','Location','eastoutside', 'Orientation', 'vertical')
figure()
plot(y_tot, energy_cn);
title('Containers energy consumption for each size bin')
xlabel('year')
ylabel('kWh')
legend ('TEU 0-999','TEU 1000-1999','TEU 2000-2999','TEU 3000-4999','TEU 5000-7999','TEU 8000-11999','TEU 12000-14500','TEU 14500 +','Location','eastoutside', 'Orientation', 'vertical')

elseif sh==2
figure()
plot(y_tot, tot_ships_size);
title('N. drybulks for each size bin')
xlabel('year')
ylabel('N. ships')
legend ('dwt 0-9999','dwt 10000-34999','dwt 35000-59999','dwt 60000-99999','dwt 100000-199999','dwt 200000+','Location','eastoutside', 'Orientation', 'vertical')
figure()
plot(y_tot, energy_cn);
title('Drybulks energy consumption for each size bin')
xlabel('year')
ylabel('kWh')
legend ('dwt 0-9999','dwt 10000-34999','dwt 35000-59999','dwt 60000-99999','dwt 100000-199999','dwt 200000+','Location','eastoutside', 'Orientation', 'vertical')

elseif sh==3
figure()
plot(y_tot, tot_ships_size);
title('N. chemical tankers for each size bin')
xlabel('year')
ylabel('N. ships')
legend ('dwt 0-4999','dwt 5000-9999','dwt 10000-19999','dwt 20000+','Location','eastoutside', 'Orientation', 'vertical')
figure()
plot(y_tot, energy_cn);
title('Chemical tankers energy consumption for each size bin')
xlabel('year')
ylabel('kWh')
legend ('dwt 0-4999','dwt 5000-9999','dwt 10000-19999','dwt 20000+','Location','eastoutside', 'Orientation', 'vertical')

elseif sh==4
figure()
plot(y_tot, tot_ships_size);
title('N. oil tankers for each size bin')
xlabel('year')
ylabel('N. ships')
legend ('dwt 0-4999','dwt 5000-9999','dwt 10000-19999','dwt 20000-59999','dwt 60000-79999', 'dwt 80000-119999', 'dwt 120000-199999', 'dwt 200000+','Location','eastoutside', 'Orientation', 'vertical')
figure()
plot(y_tot, energy_cn);
title('Oil tankers enetgy consumption for each size bin')
xlabel('year')
ylabel('N. ships')
legend ('dwt 0-4999','dwt 5000-9999','dwt 10000-19999','dwt 20000-59999','dwt 60000-79999', 'dwt 80000-119999', 'dwt 120000-199999', 'dwt 200000+','Location','eastoutside', 'Orientation', 'vertical')


end
end
end

Storage_results_en_dem_x_SSP=[Storage_results_en_dem_x_SSP; zeros(1,4); En_demand];
TOT_SSP_ships=[TOT_SSP_ships; zeros(1,36); TOT_Ships_];

end

figure()
plot(y_tot, TOT_SSP_ships(2,:), y_tot, TOT_SSP_ships(7,:), y_tot, TOT_SSP_ships(12,:), y_tot, TOT_SSP_ships(17,:), y_tot, TOT_SSP_ships(22,:));
title('Evolution of containers fleet for each scenario')
xlabel('year')
ylabel('N. ships')
legend('SSP1', 'SSP2', 'SSP3', 'SSP4', 'SSP5', 'Location','southeast')

figure()
plot(y_tot, TOT_SSP_ships(3,:), y_tot, TOT_SSP_ships(8,:), y_tot, TOT_SSP_ships(13,:), y_tot, TOT_SSP_ships(18,:), y_tot, TOT_SSP_ships(23,:));
title('Evolution of dry bulks fleet for each scenario')
xlabel('year')
ylabel('N. ships')
legend('SSP1', 'SSP2', 'SSP3', 'SSP4', 'SSP5', 'Location','southeast')

figure()
plot(y_tot, TOT_SSP_ships(4,:), y_tot, TOT_SSP_ships(9,:), y_tot, TOT_SSP_ships(14,:), y_tot, TOT_SSP_ships(19,:), y_tot, TOT_SSP_ships(24,:));
title('Evolution of chemical tankers fleet for each scenario')
xlabel('year')
ylabel('N. ships')
legend('SSP1', 'SSP2', 'SSP3', 'SSP4', 'SSP5', 'Location','southeast')

figure()
plot(y_tot, TOT_SSP_ships(5,:), y_tot, TOT_SSP_ships(10,:), y_tot, TOT_SSP_ships(15,:), y_tot, TOT_SSP_ships(20,:), y_tot, TOT_SSP_ships(25,:));
title('Evolution of oil tankers fleet for each scenario')
xlabel('year')
ylabel('N. ships')
legend('SSP1', 'SSP2', 'SSP3', 'SSP4', 'SSP5', 'Location','southeast')

%%

filename = 'risultati_energy_cn3.xlsx';
writematrix(En_demand,filename,'Sheet',1);
writematrix(Storage_results_en_dem_x_SSP, filename, 'Sheet', 2);
writematrix(TOT_SSP_ships, filename, 'Sheet', 3);

En_demand=array2table(En_demand);
En_demand.Properties.VariableNames{1} = 'Containers';
En_demand.Properties.VariableNames{2} = 'DryBulks';
En_demand.Properties.VariableNames{3} = 'Chemical Tamkers';
En_demand.Properties.VariableNames{4} = 'Oil Tankers';
