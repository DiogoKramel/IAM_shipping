%% Initialization
clear all; clc; close all; 

load('dataset.mat');

vett_dist_o= zeros(3,20);
vett_dist_v= zeros(64, 2);
%the 2 vectors above are used to separate different tables while building a
%global database

tabella_tot_1=[];
tabella_tot_2=[];
tabella_tot_3=[];
tabella_tot_4=[];
tabella_tot_5=[];
tonn_nm_1=[];
tonn_nm_2=[];
tonn_nm_3=[];
tonn_nm_4=[];
tonn_nm_5=[];
tabella_tot_tot=[];
tabella_tot_pesi_1=[];
tabella_tot_pesi_2=[];
tabella_tot_pesi_3=[];
tabella_tot_pesi_4=[];
tabella_tot_pesi_5=[];
tabella_tot_tot_pesi=[];
transport_demand_1=[];
transport_demand_2=[];
transport_demand_3=[];
transport_demand_4=[];
transport_demand_5=[];
transport_demand_tot=[];

ratio=somme_navi_line_2015./metric; %USD/metric-tons
%somme_navi_line_2015 is a vector with monetary values of freight
%transported by any ship type in 2015 (splited into 5 continents)
ratio= [ratio(1:4,1)'; ratio(5:8,1)'; ratio(9:12,1)'; ratio(13:16, 1)'; ratio(17:20,1)'];

%% SSP1 (the structure is the same for every SSP 'for' cycle)

for i=1:8
 % transpose element in column 3 (4,5..) horizontally per each repeated
 % value in column 1
 
   y=2010+5*i;
   tabella=[];
   tabella(1,1)= y;
   tabella(2:26,1)=table2array(M_SSP1(1:25,2));
   tabella(1,2:26)=table2array(M_SSP1(1:25,2))'; 
   map_y=table2array(M_SSP1(:,i+2));


vettore=[];
vettore_tot=[];

for p=1:25:625
    inizio=p;
    fine=p+24;
    vettore=map_y(inizio:fine,1)';
    vettore_tot=[vettore_tot; vettore];
    p=p+25;
end

tabella(2:26, 2:26)=vettore_tot;

%aggregates data by continent 

tab_som=[];
tab_som(1,1)= y;

tab_som(2,2)= sum(tabella(2:9, 2:9), 'all');
tab_som(3,2)= sum(tabella(10:12, 2:9), 'all');
tab_som(4,2)= sum(tabella(13:17, 2:9), 'all');
tab_som(5,2)= sum(tabella(18:25, 2:9), 'all');
tab_som(6,2)= sum(tabella(26, 2:9), 'all');

tab_som(2,3)= sum(tabella(2:9, 10:12), 'all');
tab_som(3,3)= sum(tabella(10:12, 10:12), 'all');
tab_som(4,3)= sum(tabella(13:17, 10:12), 'all');
tab_som(5,3)= sum(tabella(18:25, 10:12), 'all');
tab_som(6,3)= sum(tabella(26, 10:12), 'all');

tab_som(2,4)= sum(tabella(2:9, 13:17), 'all');
tab_som(3,4)= sum(tabella(10:12, 13:17), 'all');
tab_som(4,4)= sum(tabella(13:17, 13:17), 'all');
tab_som(5,4)= sum(tabella(18:25, 13:17), 'all');
tab_som(6,4)= sum(tabella(26, 13:17), 'all');

tab_som(2,5)= sum(tabella(2:9, 18:25), 'all');
tab_som(3,5)= sum(tabella(10:12, 18:25), 'all');
tab_som(4,5)= sum(tabella(13:17, 18:25), 'all');
tab_som(5,5)= sum(tabella(18:25, 18:25), 'all');
tab_som(6,5)= sum(tabella(26, 18:25), 'all');

tab_som(2,6)= sum(tabella(2:9, 26), 'all');
tab_som(3,6)= sum(tabella(10:12, 26), 'all');
tab_som(4,6)= sum(tabella(13:17, 26), 'all');
tab_som(5,6)= sum(tabella(18:25, 26), 'all');
tab_som(6,6)= sum(tabella(26, 26), 'all');

%split each monetary value of bilateral trade into the 4 ship categories
%(through the table 'coefficients'). So in the end I have trade Asia-Asia
%containers, Asia-Asia DryBulks ecc..

tab_split=[];
contatore=0;
%t= n righe, q=n colonne
for t=1:5
    for q=1:20
        if (1 <= q) && (q <= 4)
            contatore =2;
        elseif (5 <= q) && (q <= 8);
            contatore =3;
        elseif (9 <= q) && (q <= 12);
            contatore =4;
        elseif (13 <= q) && (q <= 16);
            contatore =5;
        elseif (17 <= q) && (q <= 20)
            contatore =6;
        else
            disp(errore)
        end
        
            tab_split(t, q)= coefficients(t, q)*tab_som(t+1, contatore);
        
    end
end
tabella_tot_1=[tabella_tot_1; vett_dist_o; tab_split];

%converts monetary values into tons 

tabella_pesi=[];
tabella_pesi_full=[];
for g=1:4:20
    tabella_pesi= (tab_split(:, g:g+3))./ratio;
    tabella_pesi_full=[tabella_pesi_full, tabella_pesi];

end

tabella_tot_pesi_1= [tabella_tot_pesi_1; vett_dist_o; tabella_pesi_full];

%multiplies data from last step for the distances between continents
tab_dist=[];
contatore=0; t=0; q=0; 
for t=1:5
    for q=1:20
        if (1 <= q) && (q <= 4);
            contatore =2;
        elseif (5 <= q) && (q <= 8);
            contatore =3;
        elseif (9 <= q) && (q <= 12);
            contatore =4;
        elseif (13 <= q) && (q <= 16);
            contatore =5;
        elseif (17 <= q) && (q <= 20)
            contatore =6;
        else
            disp(errore)
        end
        
        tab_dist(t, q)= tabella_pesi_full(t, q)*distances(t, contatore-1)*10^6;
        
    end
end
%NB before data were in million tons and now they're just tons

tonn_nm_1=[tonn_nm_1; vett_dist_o; tab_dist];

transport_demand_1(i,1)=sum(tab_dist(:,1))+sum(tab_dist(:,5))+sum(tab_dist(:,9))+sum(tab_dist(:,13))+sum(tab_dist(:,17));
transport_demand_1(i,2)=sum(tab_dist(:,2))+sum(tab_dist(:,6))+sum(tab_dist(:,20))+sum(tab_dist(:,14))+sum(tab_dist(:,18));
transport_demand_1(i,3)=sum(tab_dist(:,3))+sum(tab_dist(:,7))+sum(tab_dist(:,11))+sum(tab_dist(:,15))+sum(tab_dist(:,19));
transport_demand_1(i,4)=sum(tab_dist(:,4))+sum(tab_dist(:,8))+sum(tab_dist(:,12))+sum(tab_dist(:,16))+sum(tab_dist(:,20));

end

x=1:8
plot(x, transport_demand_1);
legend('cont','db','oil','chem')
%% SSP2
for i=1:8
   
   y=2010+5*i;
tabella=[];
   tabella(1,1)= y;
   tabella(2:26,1)=table2array(M_SSP2(1:25,2));
   tabella(1,2:26)=table2array(M_SSP2(1:25,2))'; 
   map_y=table2array(M_SSP2(:,i+2));


vettore=[];
vettore_tot=[];

for p=1:25:625
    inizio=p;
    fine=p+24;
    vettore=map_y(inizio:fine,1)';
    vettore_tot=[vettore_tot; vettore];
    p=p+25;
end
tabella(2:26, 2:26)=vettore_tot;

tab_som=[];

tab_som(2:6,1)= ["asia", "africa", "america", "europa", "oceania"];
tab_som(1, 2:6)=["asia", "africa", "america", "europa", "oceania"];
tab_som(1,1)= y;

tab_som(2,2)= sum(tabella(2:9, 2:9), 'all');
tab_som(3,2)= sum(tabella(10:12, 2:9), 'all');
tab_som(4,2)= sum(tabella(13:17, 2:9), 'all');
tab_som(5,2)= sum(tabella(18:25, 2:9), 'all');
tab_som(6,2)= sum(tabella(26, 2:9), 'all');

tab_som(2,3)= sum(tabella(2:9, 10:12), 'all');
tab_som(3,3)= sum(tabella(10:12, 10:12), 'all');
tab_som(4,3)= sum(tabella(13:17, 10:12), 'all');
tab_som(5,3)= sum(tabella(18:25, 10:12), 'all');
tab_som(6,3)= sum(tabella(26, 10:12), 'all');

tab_som(2,4)= sum(tabella(2:9, 13:17), 'all');
tab_som(3,4)= sum(tabella(10:12, 13:17), 'all');
tab_som(4,4)= sum(tabella(13:17, 13:17), 'all');
tab_som(5,4)= sum(tabella(18:25, 13:17), 'all');
tab_som(6,4)= sum(tabella(26, 13:17), 'all');

tab_som(2,5)= sum(tabella(2:9, 18:25), 'all');
tab_som(3,5)= sum(tabella(10:12, 18:25), 'all');
tab_som(4,5)= sum(tabella(13:17, 18:25), 'all');
tab_som(5,5)= sum(tabella(18:25, 18:25), 'all');
tab_som(6,5)= sum(tabella(26, 18:25), 'all');

tab_som(2,6)= sum(tabella(2:9, 26), 'all');
tab_som(3,6)= sum(tabella(10:12, 26), 'all');
tab_som(4,6)= sum(tabella(13:17, 26), 'all');
tab_som(5,6)= sum(tabella(18:25, 26), 'all');
tab_som(6,6)= sum(tabella(26, 26), 'all');

tab_split=[];
contatore=0;
%t= n righe, q=n colonne
for t=1:5
    for q=1:20
        if (1 <= q) && (q <= 4)
            contatore =2;
        elseif (5 <= q) && (q <= 8);
            contatore =3;
        elseif (9 <= q) && (q <= 12);
            contatore =4;
        elseif (13 <= q) && (q <= 16);
            contatore =5;
        elseif (17 <= q) && (q <= 20)
            contatore =6;
        else
            disp(errore)
        end
        
            tab_split(t, q)= coefficients(t, q)*tab_som(t+1, contatore);
        
    end
end

tabella_tot_2=[tabella_tot_2; vett_dist_o; tab_split];


tabella_pesi=[];
tabella_pesi_full=[];
for g=1:4:20
    tabella_pesi= (tab_split(:, g:g+3))./ratio;
    tabella_pesi_full=[tabella_pesi_full, tabella_pesi];

end

tabella_tot_pesi_2= [tabella_tot_pesi_2; vett_dist_o; tabella_pesi_full];


tab_dist=[];
contatore=0; t=0; q=0; 
for t=1:5
    for q=1:20
        if (1 <= q) && (q <= 4);
            contatore =2;
        elseif (5 <= q) && (q <= 8);
            contatore =3;
        elseif (9 <= q) && (q <= 12);
            contatore =4;
        elseif (13 <= q) && (q <= 16);
            contatore =5;
        elseif (17 <= q) && (q <= 20)
            contatore =6;
        else
            disp(errore)
        end
        
        tab_dist(t, q)= tabella_pesi_full(t, q)*distances(t, contatore-1)*10^6;
        
    end
end
%NB i dati nelle altre tabelle erano in milioni di tonnellate e ora invece
%sono tonnellate e basta

tonn_nm_2=[tonn_nm_2; vett_dist_o; tab_dist];

transport_demand_2(i,1)=sum(tab_dist(:,1))+sum(tab_dist(:,5))+sum(tab_dist(:,9))+sum(tab_dist(:,13))+sum(tab_dist(:,17));
transport_demand_2(i,2)=sum(tab_dist(:,2))+sum(tab_dist(:,6))+sum(tab_dist(:,20))+sum(tab_dist(:,14))+sum(tab_dist(:,18));
transport_demand_2(i,3)=sum(tab_dist(:,3))+sum(tab_dist(:,7))+sum(tab_dist(:,11))+sum(tab_dist(:,15))+sum(tab_dist(:,19));
transport_demand_2(i,4)=sum(tab_dist(:,4))+sum(tab_dist(:,8))+sum(tab_dist(:,12))+sum(tab_dist(:,16))+sum(tab_dist(:,20));

end


x=1:8
plot(x, transport_demand_2);
legend('cont','db','oil','chem')
%% SSP3
for i=1:8
   
   y=2010+5*i;
tabella=[];
   tabella(1,1)= y;
   tabella(2:26,1)=table2array(M_SSP3(1:25,2));
   tabella(1,2:26)=table2array(M_SSP3(1:25,2))'; 
   map_y=table2array(M_SSP3(:,i+2));


vettore=[];
vettore_tot=[];

for p=1:25:625
    inizio=p;
    fine=p+24;
    vettore=map_y(inizio:fine,1)';
    vettore_tot=[vettore_tot; vettore];
    p=p+25;
end
tabella(2:26, 2:26)=vettore_tot;

tab_som=[];

tab_som(2:6,1)= ["asia", "africa", "america", "europa", "oceania"];
tab_som(1, 2:6)=["asia", "africa", "america", "europa", "oceania"];
tab_som(1,1)= y;

tab_som(2,2)= sum(tabella(2:9, 2:9), 'all');
tab_som(3,2)= sum(tabella(10:12, 2:9), 'all');
tab_som(4,2)= sum(tabella(13:17, 2:9), 'all');
tab_som(5,2)= sum(tabella(18:25, 2:9), 'all');
tab_som(6,2)= sum(tabella(26, 2:9), 'all');

tab_som(2,3)= sum(tabella(2:9, 10:12), 'all');
tab_som(3,3)= sum(tabella(10:12, 10:12), 'all');
tab_som(4,3)= sum(tabella(13:17, 10:12), 'all');
tab_som(5,3)= sum(tabella(18:25, 10:12), 'all');
tab_som(6,3)= sum(tabella(26, 10:12), 'all');

tab_som(2,4)= sum(tabella(2:9, 13:17), 'all');
tab_som(3,4)= sum(tabella(10:12, 13:17), 'all');
tab_som(4,4)= sum(tabella(13:17, 13:17), 'all');
tab_som(5,4)= sum(tabella(18:25, 13:17), 'all');
tab_som(6,4)= sum(tabella(26, 13:17), 'all');

tab_som(2,5)= sum(tabella(2:9, 18:25), 'all');
tab_som(3,5)= sum(tabella(10:12, 18:25), 'all');
tab_som(4,5)= sum(tabella(13:17, 18:25), 'all');
tab_som(5,5)= sum(tabella(18:25, 18:25), 'all');
tab_som(6,5)= sum(tabella(26, 18:25), 'all');

tab_som(2,6)= sum(tabella(2:9, 26), 'all');
tab_som(3,6)= sum(tabella(10:12, 26), 'all');
tab_som(4,6)= sum(tabella(13:17, 26), 'all');
tab_som(5,6)= sum(tabella(18:25, 26), 'all');
tab_som(6,6)= sum(tabella(26, 26), 'all');

tab_split=[];
contatore=0;
%t= n righe, q=n colonne
for t=1:5
    for q=1:20
        if (1 <= q) && (q <= 4)
            contatore =2;
        elseif (5 <= q) && (q <= 8);
            contatore =3;
        elseif (9 <= q) && (q <= 12);
            contatore =4;
        elseif (13 <= q) && (q <= 16);
            contatore =5;
        elseif (17 <= q) && (q <= 20)
            contatore =6;
        else
            disp(errore)
        end
        
            tab_split(t, q)= coefficients(t, q)*tab_som(t+1, contatore);
        
    end
end

tabella_tot_3=[tabella_tot_3; vett_dist_o; tab_split];


tabella_pesi=[];
tabella_pesi_full=[];
for g=1:4:20
    tabella_pesi= (tab_split(:, g:g+3))./ratio;
    tabella_pesi_full=[tabella_pesi_full, tabella_pesi];

end

tabella_tot_pesi_3= [tabella_tot_pesi_3; vett_dist_o; tabella_pesi_full];


tab_dist=[];
contatore=0; t=0; q=0; 
for t=1:5
    for q=1:20
        if (1 <= q) && (q <= 4);
            contatore =2;
        elseif (5 <= q) && (q <= 8);
            contatore =3;
        elseif (9 <= q) && (q <= 12);
            contatore =4;
        elseif (13 <= q) && (q <= 16);
            contatore =5;
        elseif (17 <= q) && (q <= 20)
            contatore =6;
        else
            disp(errore)
        end
        
        tab_dist(t, q)= tabella_pesi_full(t, q)*distances(t, contatore-1)*10^6;
        
    end
end
%NB i dati nelle altre tabelle erano in milioni di tonnellate e ora invece
%sono tonnellate e basta

tonn_nm_3=[tonn_nm_3; vett_dist_o; tab_dist];

transport_demand_3(i,1)=sum(tab_dist(:,1))+sum(tab_dist(:,5))+sum(tab_dist(:,9))+sum(tab_dist(:,13))+sum(tab_dist(:,17));
transport_demand_3(i,2)=sum(tab_dist(:,2))+sum(tab_dist(:,6))+sum(tab_dist(:,20))+sum(tab_dist(:,14))+sum(tab_dist(:,18));
transport_demand_3(i,3)=sum(tab_dist(:,3))+sum(tab_dist(:,7))+sum(tab_dist(:,11))+sum(tab_dist(:,15))+sum(tab_dist(:,19));
transport_demand_3(i,4)=sum(tab_dist(:,4))+sum(tab_dist(:,8))+sum(tab_dist(:,12))+sum(tab_dist(:,16))+sum(tab_dist(:,20));

end


x=1:8
plot(x, transport_demand_3);
legend('cont','db','oil','chem')
%% SSP4
for i=1:8
   
   y=2010+5*i;
tabella=[];
   tabella(1,1)= y;
   tabella(2:26,1)=table2array(M_SSP4(1:25,2));
   tabella(1,2:26)=table2array(M_SSP4(1:25,2))'; 
   map_y=table2array(M_SSP4(:,i+2));


vettore=[];
vettore_tot=[];

for p=1:25:625
    inizio=p;
    fine=p+24;
    vettore=map_y(inizio:fine,1)';
    vettore_tot=[vettore_tot; vettore];
    p=p+25;
end
tabella(2:26, 2:26)=vettore_tot;

tab_som=[];

tab_som(2:6,1)= ["asia", "africa", "america", "europa", "oceania"];
tab_som(1, 2:6)=["asia", "africa", "america", "europa", "oceania"];
tab_som(1,1)= y;

tab_som(2,2)= sum(tabella(2:9, 2:9), 'all');
tab_som(3,2)= sum(tabella(10:12, 2:9), 'all');
tab_som(4,2)= sum(tabella(13:17, 2:9), 'all');
tab_som(5,2)= sum(tabella(18:25, 2:9), 'all');
tab_som(6,2)= sum(tabella(26, 2:9), 'all');

tab_som(2,3)= sum(tabella(2:9, 10:12), 'all');
tab_som(3,3)= sum(tabella(10:12, 10:12), 'all');
tab_som(4,3)= sum(tabella(13:17, 10:12), 'all');
tab_som(5,3)= sum(tabella(18:25, 10:12), 'all');
tab_som(6,3)= sum(tabella(26, 10:12), 'all');

tab_som(2,4)= sum(tabella(2:9, 13:17), 'all');
tab_som(3,4)= sum(tabella(10:12, 13:17), 'all');
tab_som(4,4)= sum(tabella(13:17, 13:17), 'all');
tab_som(5,4)= sum(tabella(18:25, 13:17), 'all');
tab_som(6,4)= sum(tabella(26, 13:17), 'all');

tab_som(2,5)= sum(tabella(2:9, 18:25), 'all');
tab_som(3,5)= sum(tabella(10:12, 18:25), 'all');
tab_som(4,5)= sum(tabella(13:17, 18:25), 'all');
tab_som(5,5)= sum(tabella(18:25, 18:25), 'all');
tab_som(6,5)= sum(tabella(26, 18:25), 'all');

tab_som(2,6)= sum(tabella(2:9, 26), 'all');
tab_som(3,6)= sum(tabella(10:12, 26), 'all');
tab_som(4,6)= sum(tabella(13:17, 26), 'all');
tab_som(5,6)= sum(tabella(18:25, 26), 'all');
tab_som(6,6)= sum(tabella(26, 26), 'all');

tab_split=[];
contatore=0;
%t= n righe, q=n colonne
for t=1:5
    for q=1:20
        if (1 <= q) && (q <= 4)
            contatore =2;
        elseif (5 <= q) && (q <= 8);
            contatore =3;
        elseif (9 <= q) && (q <= 12);
            contatore =4;
        elseif (13 <= q) && (q <= 16);
            contatore =5;
        elseif (17 <= q) && (q <= 20)
            contatore =6;
        else
            disp(errore)
        end
        
            tab_split(t, q)= coefficients(t, q)*tab_som(t+1, contatore);
        
    end
end

tabella_tot_4=[tabella_tot_4; vett_dist_o; tab_split];

tabella_pesi=[];
tabella_pesi_full=[];
for g=1:4:20
    tabella_pesi= (tab_split(:, g:g+3))./ratio;
    tabella_pesi_full=[tabella_pesi_full, tabella_pesi];

end

tabella_tot_pesi_4= [tabella_tot_pesi_4; vett_dist_o; tabella_pesi_full];


tab_dist=[];
contatore=0; t=0; q=0; 
for t=1:5
    for q=1:20
        if (1 <= q) && (q <= 4);
            contatore =2;
        elseif (5 <= q) && (q <= 8);
            contatore =3;
        elseif (9 <= q) && (q <= 12);
            contatore =4;
        elseif (13 <= q) && (q <= 16);
            contatore =5;
        elseif (17 <= q) && (q <= 20)
            contatore =6;
        else
            disp(errore)
        end
        
        tab_dist(t, q)= tabella_pesi_full(t, q)*distances(t, contatore-1)*10^6;
        
    end
end
%NB i dati nelle altre tabelle erano in milioni di tonnellate e ora invece
%sono tonnellate e basta

tonn_nm_4=[tonn_nm_4; vett_dist_o; tab_dist];

transport_demand_4(i,1)=sum(tab_dist(:,1))+sum(tab_dist(:,5))+sum(tab_dist(:,9))+sum(tab_dist(:,13))+sum(tab_dist(:,17));
transport_demand_4(i,2)=sum(tab_dist(:,2))+sum(tab_dist(:,6))+sum(tab_dist(:,20))+sum(tab_dist(:,14))+sum(tab_dist(:,18));
transport_demand_4(i,3)=sum(tab_dist(:,3))+sum(tab_dist(:,7))+sum(tab_dist(:,11))+sum(tab_dist(:,15))+sum(tab_dist(:,19));
transport_demand_4(i,4)=sum(tab_dist(:,4))+sum(tab_dist(:,8))+sum(tab_dist(:,12))+sum(tab_dist(:,16))+sum(tab_dist(:,20));

end


x=1:8
plot(x, transport_demand_4);
legend('cont','db','oil','chem')
%% SSP5
for i=1:8
   
   y=2010+5*i;
tabella=[];
   tabella(1,1)= y;
   tabella(2:26,1)=table2array(M_SSP5(1:25,2));
   tabella(1,2:26)=table2array(M_SSP5(1:25,2))'; 
   map_y=table2array(M_SSP5(:,i+2));


vettore=[];
vettore_tot=[];

for p=1:25:625
    inizio=p;
    fine=p+24;
    vettore=map_y(inizio:fine,1)';
    vettore_tot=[vettore_tot; vettore];
    p=p+25;
end
tabella(2:26, 2:26)=vettore_tot;

tab_som=[];

tab_som(2:6,1)= ["asia", "africa", "america", "europa", "oceania"];
tab_som(1, 2:6)=["asia", "africa", "america", "europa", "oceania"];
tab_som(1,1)= y;

tab_som(2,2)= sum(tabella(2:9, 2:9), 'all');
tab_som(3,2)= sum(tabella(10:12, 2:9), 'all');
tab_som(4,2)= sum(tabella(13:17, 2:9), 'all');
tab_som(5,2)= sum(tabella(18:25, 2:9), 'all');
tab_som(6,2)= sum(tabella(26, 2:9), 'all');

tab_som(2,3)= sum(tabella(2:9, 10:12), 'all');
tab_som(3,3)= sum(tabella(10:12, 10:12), 'all');
tab_som(4,3)= sum(tabella(13:17, 10:12), 'all');
tab_som(5,3)= sum(tabella(18:25, 10:12), 'all');
tab_som(6,3)= sum(tabella(26, 10:12), 'all');

tab_som(2,4)= sum(tabella(2:9, 13:17), 'all');
tab_som(3,4)= sum(tabella(10:12, 13:17), 'all');
tab_som(4,4)= sum(tabella(13:17, 13:17), 'all');
tab_som(5,4)= sum(tabella(18:25, 13:17), 'all');
tab_som(6,4)= sum(tabella(26, 13:17), 'all');

tab_som(2,5)= sum(tabella(2:9, 18:25), 'all');
tab_som(3,5)= sum(tabella(10:12, 18:25), 'all');
tab_som(4,5)= sum(tabella(13:17, 18:25), 'all');
tab_som(5,5)= sum(tabella(18:25, 18:25), 'all');
tab_som(6,5)= sum(tabella(26, 18:25), 'all');

tab_som(2,6)= sum(tabella(2:9, 26), 'all');
tab_som(3,6)= sum(tabella(10:12, 26), 'all');
tab_som(4,6)= sum(tabella(13:17, 26), 'all');
tab_som(5,6)= sum(tabella(18:25, 26), 'all');
tab_som(6,6)= sum(tabella(26, 26), 'all');

tab_split=[];
contatore=0;
%t= n righe, q=n colonne
for t=1:5
    for q=1:20
        if (1 <= q) && (q <= 4)
            contatore =2;
        elseif (5 <= q) && (q <= 8);
            contatore =3;
        elseif (9 <= q) && (q <= 12);
            contatore =4;
        elseif (13 <= q) && (q <= 16);
            contatore =5;
        elseif (17 <= q) && (q <= 20)
            contatore =6;
        else
            disp(errore)
        end
        
            tab_split(t, q)= coefficients(t, q)*tab_som(t+1, contatore);
        
    end
end
%tab_split(1,1)= y;
tabella_tot_5=[tabella_tot_5; vett_dist_o; tab_split];


tabella_pesi=[];
tabella_pesi_full=[];
for g=1:4:20
    tabella_pesi= (tab_split(:, g:g+3))./ratio;
    tabella_pesi_full=[tabella_pesi_full, tabella_pesi];

end

tabella_tot_pesi_5= [tabella_tot_pesi_5; vett_dist_o; tabella_pesi_full];


tab_dist=[];
contatore=0; t=0; q=0; 
for t=1:5
    for q=1:20
        if (1 <= q) && (q <= 4);
            contatore =2;
        elseif (5 <= q) && (q <= 8);
            contatore =3;
        elseif (9 <= q) && (q <= 12);
            contatore =4;
        elseif (13 <= q) && (q <= 16);
            contatore =5;
        elseif (17 <= q) && (q <= 20)
            contatore =6;
        else
            disp(errore)
        end
        
        tab_dist(t, q)= tabella_pesi_full(t, q)*distances(t, contatore-1)*10^6;
        
    end
end
%NB i dati nelle altre tabelle erano in milioni di tonnellate e ora invece
%sono tonnellate e basta

tonn_nm_5=[tonn_nm_5; vett_dist_o; tab_dist];

transport_demand_5(i,1)=sum(tab_dist(:,1))+sum(tab_dist(:,5))+sum(tab_dist(:,9))+sum(tab_dist(:,13))+sum(tab_dist(:,17));
transport_demand_5(i,2)=sum(tab_dist(:,2))+sum(tab_dist(:,6))+sum(tab_dist(:,20))+sum(tab_dist(:,14))+sum(tab_dist(:,18));
transport_demand_5(i,3)=sum(tab_dist(:,3))+sum(tab_dist(:,7))+sum(tab_dist(:,11))+sum(tab_dist(:,15))+sum(tab_dist(:,19));
transport_demand_5(i,4)=sum(tab_dist(:,4))+sum(tab_dist(:,8))+sum(tab_dist(:,12))+sum(tab_dist(:,16))+sum(tab_dist(:,20));

end

x=1:8
plot(x, transport_demand_5);
legend('cont','db','oil','chem')

%% Merge Tables

tabella_tot_tot=[vett_dist_v, tabella_tot_1, vett_dist_v, tabella_tot_2, vett_dist_v, tabella_tot_3, vett_dist_v,tabella_tot_4, vett_dist_v,tabella_tot_5];
tabella_tot_tot_pesi=[vett_dist_v, tabella_tot_pesi_1, vett_dist_v, tabella_tot_pesi_2, vett_dist_v, tabella_tot_pesi_3, vett_dist_v, tabella_tot_pesi_4, vett_dist_v, tabella_tot_pesi_5];
transport_demand_tot=[transport_demand_1; zeros(1,4); transport_demand_2; zeros(1,4); transport_demand_3; zeros(1,4); transport_demand_4; zeros(1,4); transport_demand_5]
transport_demand_tot=array2table(transport_demand_tot);
transport_demand_tot.Properties.VariableNames{1} = 'Containers';
transport_demand_tot.Properties.VariableNames{2} = 'DryBulks';
transport_demand_tot.Properties.VariableNames{3} = 'OilTankers';
transport_demand_tot.Properties.VariableNames{4} = 'ChemicalTankers';
%%
filename = 'risultati_new_new.xlsx';
writematrix(tabella_tot_tot,filename,'Sheet',1)
writematrix(tabella_tot_tot_pesi,filename,'Sheet',2)
writetable(transport_demand_tot,filename,'Sheet',3)

%%
figure(1)
x=2015:5:2050
plot(x, transport_demand_5(:,1),x, transport_demand_1(:,1),x, transport_demand_2(:,1),x, transport_demand_3(:,1),x, transport_demand_4(:,1));
legend( 'SSP5','SSP1', 'SSP2', 'SSP4', 'SSP3', 'Location', 'southeast')
xlabel('years')
ylabel('Transport demand in tons-nm')
title('Transport demand projections for containerships')
%%
figure(2)
x=2015:5:2050
plot(x, transport_demand_5(:,2),x, transport_demand_1(:,2),x, transport_demand_2(:,2),x, transport_demand_3(:,2),x, transport_demand_4(:,2));
legend('SSP5', 'SSP1', 'SSP2', 'SSP4', 'SSP3', 'Location', 'southeast')
xlabel('years')
ylabel('Transport demand in tons-nm')
title('Transport demand projections for bulk carriers')
%%
figure(3)
x=2015:5:2050
plot(x, transport_demand_5(:,3),x, transport_demand_1(:,3),x, transport_demand_2(:,3),x, transport_demand_3(:,3),x, transport_demand_4(:,3));
legend('SSP5', 'SSP1', 'SSP2', 'SSP3', 'SSP4', 'Location', 'southeast')
xlabel('years')
ylabel('Transport demand in tons-nm')
title('Transport demand projections for oil tankers')
%%
figure(4)
x=2015:5:2050
plot(x, transport_demand_5(:,4),x, transport_demand_1(:,4),x, transport_demand_2(:,4),x, transport_demand_3(:,4),x, transport_demand_4(:,4));
legend('SSP5', 'SSP1', 'SSP2', 'SSP3', 'SSP4', 'Location', 'southeast')
xlabel('years')
ylabel('Transport demand in tons-nm')
title('Transport demand projections for chemical tankers')