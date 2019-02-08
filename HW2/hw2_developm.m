%%%%% Assignment 2 (HW2), Development Economics     %%%%%
%%%%                      Marina Rizzi              %%%%%
%%%%                      29 January 2019           %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set Up

clear
rng(22245)

%%% I set a folder, for storing results and tables
path_latex = '/Users/marinarizzi/Documents/Cemfi!!/2018:2019/2nd Trimester/Development Economics/Homeworks/HW2'; 


%%% I put the Matrix, for the values of the seasonality (for the moment,
%%% just for "Middle Values").

g_mid= [-0.147; -0.370; 0.141; 0.131; 0.090; 0.058; 0.036; 0.036; 0.036; 0.002; -0.033; -0.082];
    

% For a row vector, you could write: g_mid= [-0.147, -0.370]

%%%% Other option, is to put the whole matrix [directly, with all the seasons]:

%%% Recent Matrix (6febr19)

g_tot_originaria=[0.863, 0.727, 0.932;
           0.691, 0.381, 0.845;
           1.151, 1.303, 1.076;
           1.140, 1.280, 1.070;
           1.094, 1.188, 1.047;
           1.060, 1.119, 1.030;
           1.037, 1.073, 1.018;
           1.037, 1.073, 1.018;
           1.037, 1.073, 1.018;
           1.002, 1.004, 1.001;
           0.968, 0.935, 0.984;
           0.921, 0.843, 0.961;
           ];
           
g_tot=log(g_tot_originaria);
           
           

% OLD MATRIX
% g_tot= [-0.147, -0.293, -0.073;
%         -0.370, -0.739, -0.185;
%          0.141, 0.282, 0.071;
%          0.131, 0.262, 0.066;
%          0.090, 0.180, 0.045;
%          0.058, 0.116, 0.029;
%          0.036, 0.072, 0.018;
%          0.036, 0.072, 0.018;
%          0.036, 0.072, 0.018;
%          0.002, 0.004, 0.001;
%          -0.033, -0.066, -0.017;
%          -0.082, -0.164, -0.041];
%      

% I have to set up a Matrix 1000x40 (n. Individuals x n. Periods of time)

N=1000; % N. individuals
periods= 40*12;   %Periods in which the problem is optimized
years= 40; 
mat=zeros(N, periods);

sigmau=0.2;
sigmae=0.2;

beta=0.99;

seasons=[1, 2, 3];
%eta_values=[1, 2, 4];

%% Now, I have to construct consumption, first of all

%%% I extract a different z, for each household
%   [z is drawn at the beginning of their life, from lnu that is N(o,
%   sigmau)

lnu=randn(N,1)* sqrt(sigmau);
z=exp(-sigmau/2)*exp(lnu); 


%%%% In order to create the matrix with the individual parts for all the
%%%% periods (that are, 12*40, months*years), I use the following
%%%% procedure:

% You can do this

epsilon = zeros(N,years*12); % Initilaize matrix with zeros
 
for tt = 1:(years*12)
    % mod gives you the module (i.e. "il resto" from the division). Then,
    % when we have remainder of 1, we know we are in the first month of the
    % year!!
    if mod(tt,12) == 1 % In first month of a year draw the shocks
        epsilon(:,tt) = exp(sqrt(sigmae)*randn(N,1));
    % The : means that takes all the row (or column).          
    else % In other months copy the previous months shock
        epsilon(:,tt) = epsilon(:,tt-1); % 
    end
end
 
individ_part = exp(-sigmae/2) * epsilon;


%%% NB: randn returns number by a standard normal distrib. So, if I want to
%%% use a different variance, I multiply the result by the connected
%%% standard deviation.
%%% sqrt= square root.

%%%% ln(u)like N(0, sigmau)


%%% Part, in which I calculate utilities and etc.


%% I begin just doing it for eta=1, then I repeat for other values of eta
%for zz = 1:size(etas,2)

%%% Matrix, for results
results_eta1 = zeros(1000,4,1,size(seasons,2));

    
    for t = 1:3
        
        % I determine the current eta, and the season that is happen now
        eta = 1;
        season_now = seasons(t); % 1: Middle, 2: High, 3: Low
        

        % I calculate deterministic seasonal components (for each month and
        % individual)
        g_now = repmat(g_tot(:,season_now)',N,years);
        
        % I now calculate consumption (for each individual)
        cons_normal = repmat(z,1,years*12) .* exp(g_now) .* individ_part;
        cons_without_seasons = repmat(z,1,years*12) .* individ_part;
        cons_no_shocks = repmat(z,1,years*12) .* exp(g_now);
        cons_no_seas_no_shocks = repmat(z,1,years*12);
        
        % I now calculate the utility from consumpt.  (per periods, for all
        % individuals)
        
        util = log(cons_normal);
        util_no_seas = log(cons_without_seasons);
        util_no_shocks = log(cons_no_shocks);
        util_no_seas_no_shocks = log(cons_no_seas_no_shocks);
            
        % I calculate discount factors (for each period and all
        % individuals)
        discount_fact = repmat(beta.^(12+(0:years*12-1)),N,1);
        
        % Compute lifetime utility
        W = sum(discount_fact.*util,2);
        W_no_seas = sum(discount_fact.*util_no_seas,2);
        W_no_shocks = sum(discount_fact.*util_no_shocks,2);
        W_no_seas_no_shocks = sum(discount_fact.*util_no_seas_no_shocks,2);
        
        % Compute the welfare gains
        % WX = W + log(1+g)*sum(discountFactors,2)
            discount_sum = sum(discount_fact,2);
            
        %%% I want to obtain g ---> So, I use the formula above    
            g_no_seas = exp((W_no_seas-W)./discount_sum)-1;
            g_no_shocks = exp((W_no_shocks-W)./discount_sum)-1;
            g_no_seas_no_shocks = exp((W_no_seas_no_shocks-W)./discount_sum)-1;
            g_noshocks_VS_noshocksnoseas = exp((W_no_seas_no_shocks-W_no_shocks)./discount_sum)-1;
    
        
        % Store the results
        results_eta1(:,:,1,t) = [g_no_seas g_no_shocks g_no_seas_no_shocks g_noshocks_VS_noshocksnoseas];
        
    end
       
 results_eta1

%%% I now save the results in Latex!!
   
    for t = 1:3  %% I loop around seasons (
        
        FID = fopen(['Latex_report/tab2_eta1_seas_' num2str(t) '.tex'], 'w');
        
        for y = 1:size(results_eta1,2)-1
            
            g_mean = mean(results_eta1(:,y,1,t));
            g_median = median(results_eta1(:,y,1,t));
            %g5 = prctile(results_eta1(:,yy,zz,t),5);
            %g95 = prctile(results_eta1(:,yy,zz,t),95);
            lbls = {'No Seasons','No Shocks','No Seasons and No Shocks'};
            fprintf(FID, '%s & %2.4f & %2.4f \\\\ \n', lbls{y}, g_mean, g_median);
        
        end
        
        fclose(FID);

    end
    

%% I now replicate everything for eta=2 
 

%%% Matrix, for results
results_eta2 = zeros(1000,4,1,size(seasons,2));

    
    for t = 1:3
        
        % I determine the current eta, and the season that is happen now
        eta = 2;
        season_now = seasons(t); % 1: Middle, 2: High, 3: Low
        

        % I calculate deterministic seasonal components (for each month and
        % individual)
        g_now = repmat(g_tot(:,season_now)',N,years);
        
        % I now calculate consumption (for each individual)
        cons_normal = repmat(z,1,years*12) .* exp(g_now) .* individ_part;
        cons_without_seasons = repmat(z,1,years*12) .* individ_part;
        cons_no_shocks = repmat(z,1,years*12) .* exp(g_now);
        cons_no_seas_no_shocks = repmat(z,1,years*12);
        
        % I now calculate the utility from consumpt.  (per periods, for all
        % individuals)
        
        util = cons_normal.^(1-eta)/(1-eta);
        util_no_seas = cons_without_seasons.^(1-eta)/(1-eta);
        util_no_shocks = cons_no_shocks.^(1-eta)/(1-eta);
        util_no_seas_no_shocks = cons_no_seas_no_shocks.^(1-eta)/(1-eta);
        
            
        % I calculate discount factors (for each period and all
        % individuals)
        discount_fact = repmat(beta.^(12+(0:years*12-1)),N,1);
        
        % Compute lifetime utility
        W = sum(discount_fact.*util,2);
        W_no_seas = sum(discount_fact.*util_no_seas,2);
        W_no_shocks = sum(discount_fact.*util_no_shocks,2);
        W_no_seas_no_shocks = sum(discount_fact.*util_no_seas_no_shocks,2);
        
        % Compute the welfare gains
        % WX = (1+g)^(1-eta)*W
            discount_sum = sum(discount_fact,2);
            
        %%% I want to obtain g ---> So, I use the formula above   
            g_no_seas = (W_no_seas./W).^(1/(1-eta))-1;
            g_no_shocks = (W_no_shocks./W).^(1/(1-eta))-1;
            g_no_seas_no_shock = (W_no_seas_no_shocks./W).^(1/(1-eta))-1;
            g_noshocks_VS_noshocksnoseas = (W_no_seas_no_shocks./W_no_shocks).^(1/(1-eta))-1;
              
        
        % Store the results
        results_eta2(:,:,1,t) = [g_no_seas g_no_shocks g_no_seas_no_shocks g_noshocks_VS_noshocksnoseas];
        
    end
       
 results_eta2

%%% I now save the results in Latex!!
   
    for t = 1:3  %% I loop around seasons (
        
        FID = fopen(['Latex_report/tab2_eta2_seas_' num2str(t) '.tex'], 'w');
        
        for y = 1:size(results_eta2,2)-1
            
            g_mean = mean(results_eta2(:,y,1,t));
            g_median = median(results_eta2(:,y,1,t));
            %g5 = prctile(results_eta1(:,yy,zz,t),5);
            %g95 = prctile(results_eta1(:,yy,zz,t),95);
            lbls = {'No Seasons','No Shocks','No Seasons and No Shocks'};
            fprintf(FID, '%s & %2.4f & %2.4f \\\\ \n', lbls{y}, g_mean, g_median);
        
        end
        
        fclose(FID);

    end
    
    
 
%% I repeat, for eta=4

%%% Matrix, for results
results_eta4 = zeros(1000,4,1,size(seasons,2));

    
    for t = 1:3
        
        % I determine the current eta, and the season that is happen now
        eta = 4;
        season_now = seasons(t); % 1: Middle, 2: High, 3: Low
        

        % I calculate deterministic seasonal components (for each month and
        % individual)
        g_now = repmat(g_tot(:,season_now)',N,years);
        
        % I now calculate consumption (for each individual)
        cons_normal = repmat(z,1,years*12) .* exp(g_now) .* individ_part;
        cons_without_seasons = repmat(z,1,years*12) .* individ_part;
        cons_no_shocks = repmat(z,1,years*12) .* exp(g_now);
        cons_no_seas_no_shocks = repmat(z,1,years*12);
        
        % I now calculate the utility from consumpt.  (per periods, for all
        % individuals)
        
        util = cons_normal.^(1-eta)/(1-eta);
        util_no_seas = cons_without_seasons.^(1-eta)/(1-eta);
        util_no_shocks = cons_no_shocks.^(1-eta)/(1-eta);
        util_no_seas_no_shocks = cons_no_seas_no_shocks.^(1-eta)/(1-eta);
        
            
        % I calculate discount factors (for each period and all
        % individuals)
        discount_fact = repmat(beta.^(12+(0:years*12-1)),N,1);
        
        % Compute lifetime utility
        W = sum(discount_fact.*util,2);
        W_no_seas = sum(discount_fact.*util_no_seas,2);
        W_no_shocks = sum(discount_fact.*util_no_shocks,2);
        W_no_seas_no_shocks = sum(discount_fact.*util_no_seas_no_shocks,2);
        
        % Compute the welfare gains
        % WX = (1+g)^(1-eta)*W
            discount_sum = sum(discount_fact,2);
            
        %%% I want to obtain g ---> So, I use the formula above   
            g_no_seas = (W_no_seas./W).^(1/(1-eta))-1;
            g_no_shocks = (W_no_shocks./W).^(1/(1-eta))-1;
            g_no_seas_no_shock = (W_no_seas_no_shocks./W).^(1/(1-eta))-1;
            g_noshocks_VS_noshocksnoseas = (W_no_seas_no_shocks./W_no_shocks).^(1/(1-eta))-1;
              
        
        % Store the results
        results_eta4(:,:,1,t) = [g_no_seas g_no_shocks g_no_seas_no_shocks g_noshocks_VS_noshocksnoseas];
        
    end
       
 results_eta4

%%% I now save the results in Latex!!
   
    for t = 1:3  %% I loop around seasons (
        
        FID = fopen(['Latex_report/tab2_eta4_seas_' num2str(t) '.tex'], 'w');
        
        for y = 1:size(results_eta2,2)-1
            
            g_mean = mean(results_eta4(:,y,1,t));
            g_median = median(results_eta4(:,y,1,t));
            %g5 = prctile(results_eta1(:,yy,zz,t),5);
            %g95 = prctile(results_eta1(:,yy,zz,t),95);
            lbls = {'No Seasons','No Shocks','No Seasons and No Shocks'};
            fprintf(FID, '%s & %2.4f & %2.4f \\\\ \n', lbls{y}, g_mean, g_median);
        
        end
        
        fclose(FID);

    end
    

    
  %% Part 1.2 - With Stochastic Seasonality
  
  %%% I start with eta=1
  %%% See,code below:
  
%%% Matrix, with the stochastic component of seasons:
sigma_m_seas= [0.085, 0.171, 0.043;
              0.068, 0.137, 0.034;
              0.290, 0.580, 0.145;
              0.283, 0.567, 0.142;
              0.273, 0.546, 0.137;
              0.273, 0.546, 0.137;
              0.239, 0.478, 0.119;
              0.205, 0.410, 0.102;
              0.188, 0.376, 0.094;
              0.188, 0.376, 0.094;
              0.171, 0.341, 0.085;
              0.137, 0.273, 0.068]

              
% Matrix for results:
result_stoch_eta1 = zeros(1000,4,1,size(seasons,2));
 
    for t = 1:3
        
        % Set current eta and degree of seasonality
        eta = 1;
        season_now = seasons(t); % 1: Middle, 2: High, 3: Low
        
        % Draw types of individuals
        z = exp(-sigmau/2) * exp(sqrt(sigmau)*randn(N,1));
        % + Shocks
        epsilon = repelem(exp(sqrt(sigmae)*randn(N,years)),1,12);
        individual_part = exp(-sigmae/2) * epsilon;
        
        % Shocks (for seasons, individual component)
        sigma_m = repmat(sigma_m_seas(:,season_now)',N,years);
        stoch_seas_comp = exp(-sigma_m/2) .* exp(sqrt(sigma_m).*randn(N,years*12));
        
        % Get the deterministic seasonal components per month and individual
        gm_seas = repmat(g_tot(:,season_now)',N,years);
        
        % Compute the consumption for all individuals
        cons = repmat(z,1,years*12) .* exp(gm_seas) .* stoch_seas_comp .* individual_part;
        cons_no_seas_determ = repmat(z,1,years*12) .* stoch_seas_comp .* individual_part;
        cons_no_seas_stochast = repmat(z,1,years*12) .* exp(gm_seas) .* individual_part;
        cons_no_seas_determ_no_stochast = repmat(z,1,years*12) .* individual_part;
        cons_no_shock = repmat(z,1,years*12) .* exp(gm_seas) .* stoch_seas_comp;
        
        % Utility Comparison  (per periods for all individuals)
            util = log(cons);
            util_no_seas_det = log(cons_no_seas_determ);
            util_no_seas_stochast = log(cons_no_seas_stochast);
            util_no_seas_det_no_stoch = log(cons_no_seas_determ_no_stochast);
            util_no_shock= log(cons_no_shock);

        
        % Compute discount factors for each period and all individuals
        discount_factors = repmat(beta.^(12+(0:years*12-1)),N,1);
        
        % Compute lifetime utility
        W = sum(discount_factors.*util,2);
        W_no_det = sum(discount_factors.*util_no_seas_det,2);
        W_no_stoch = sum(discount_factors.*util_no_seas_stochast,2);
        W_no_det_no_stoch = sum(discount_factors.*util_no_seas_det_no_stoch,2);
        W_no_shock = sum(discount_factors.*util_no_shock,2);
        
        % Welfare gains
        % WX = W + log(1+g)*sum(discountFactors,2)
            discount_sum = sum(discount_factors,2);
            g_no_det = exp((W_no_det-W)./discount_sum)-1;
            g_no_stoch = exp((W_no_stoch-W)./discount_sum)-1;
            g_no_det_no_stoch = exp((W_no_det_no_stoch-W)./discount_sum)-1;
            g_no_shock = exp((W_no_shock-W)./discount_sum)-1;

        
        % Store the results
        result_stoch_eta1(:,:,1,t) = [g_no_det g_no_stoch g_no_det_no_stoch g_no_shock];
        
    end



% Generate Latex output    
    for t = 1:3
        
        FID = fopen(['Latex_report/tab_stochasticpart_eta1_seas_' num2str(seasons(t)) '.tex'], 'w');
        
        for y = 1:size(result_stoch_eta1,2)
            
            g_mean = mean(result_stoch_eta1(:,y,1,t));
            g_median = median(result_stoch_eta1(:,y,1,t));
            %g5 = prctile(result_stoch_eta1(:,y,1,t),5);
            %g95 = prctile(result_stoch_eta1(:,y,1,t),95);
            lbls = {'No seasons (determ. part)','No seasons (Stoch. part)','No seasons (determ. + stochast. part)', 'No shocks (i.e. no epsilon)'};
            fprintf(FID, '%s & %2.4f & %2.4f \\\\ \n', lbls{y}, g_mean, g_median);
        
        end
        
        fclose(FID);

    end
    
    

    %% For eta=2
 
    
 % Matrix for results:
result_stoch_eta2 = zeros(1000,4,1,size(seasons,2));
 
    for t = 1:3
        
        % Set current eta and degree of seasonality
        eta = 2;
        season_now = seasons(t); % 1: Middle, 2: High, 3: Low
        
        % Draw types of individuals
        z = exp(-sigmau/2) * exp(sqrt(sigmau)*randn(N,1));
        % + Shocks
        epsilon = repelem(exp(sqrt(sigmae)*randn(N,years)),1,12);
        individual_part = exp(-sigmae/2) * epsilon;
        
        % Shocks (for seasons, individual component)
        sigma_m = repmat(sigma_m_seas(:,season_now)',N,years);
        stoch_seas_comp = exp(-sigma_m/2) .* exp(sqrt(sigma_m).*randn(N,years*12));
        
        % Get the deterministic seasonal components per month and individual
        gm_seas = repmat(g_tot(:,season_now)',N,years);
        
        % Compute the consumption for all individuals
        cons = repmat(z,1,years*12) .* exp(gm_seas) .* stoch_seas_comp .* individual_part;
        cons_no_seas_determ = repmat(z,1,years*12) .* stoch_seas_comp .* individual_part;
        cons_no_seas_stochast = repmat(z,1,years*12) .* exp(gm_seas) .* individual_part;
        cons_no_seas_determ_no_stochast = repmat(z,1,years*12) .* individual_part;
        cons_no_shock = repmat(z,1,years*12) .* exp(gm_seas) .* stoch_seas_comp;
               
      
            util = cons.^(1-eta)/(1-eta);
            util_no_seas_det = cons_no_seas_determ.^(1-eta)/(1-eta);
            util_no_seas_stochast = cons_no_seas_stochast.^(1-eta)/(1-eta);
            util_no_seas_det_no_stoch = cons_no_seas_determ_no_stochast.^(1-eta)/(1-eta);
            util_no_shock = cons_no_shock.^(1-eta)/(1-eta);


        
        % Compute discount factors for each period and all individuals
        discount_factors = repmat(beta.^(12+(0:years*12-1)),N,1);
        
        % Compute lifetime utility
        W = sum(discount_factors.*util,2);
        W_no_det = sum(discount_factors.*util_no_seas_det,2);
        W_no_stoch = sum(discount_factors.*util_no_seas_stochast,2);
        W_no_det_no_stoch = sum(discount_factors.*util_no_seas_det_no_stoch,2);
        W_no_shock = sum(discount_factors.*util_no_shock,2);
        
        % Welfare gains
        % WX = (1+g)^(1-eta)*W
        %   discount_sum = sum(discount_factors,2);
            
            g_no_det = (W_no_det./W).^(1/(1-eta))-1;
            g_no_stoch = (W_no_stoch./W).^(1/(1-eta))-1;
            g_no_det_no_stoch = (W_no_det_no_stoch./W).^(1/(1-eta))-1;
            g_no_shock = (W_no_shock./W).^(1/(1-eta))-1;

            

        
        % Store the results
        result_stoch_eta2(:,:,1,t) = [g_no_det g_no_stoch g_no_det_no_stoch g_no_shock];
        
    end



% Generate Latex output    
    for t = 1:3
        
        FID = fopen(['Latex_report/tab_stochasticpart_eta2_seas_' num2str(seasons(t)) '.tex'], 'w');
        
        for y = 1:size(result_stoch_eta2,2)
            
            g_mean = mean(result_stoch_eta2(:,y,1,t));
            g_median = median(result_stoch_eta2(:,y,1,t));
            %g5 = prctile(result_stoch_eta1(:,y,1,t),5);
            %g95 = prctile(result_stoch_eta1(:,y,1,t),95);
            lbls = {'No seasons (determ. part)','No seasons (Stoch. part)','No seasons (determ. + stochast. part)', 'No shocks (i.e. no epsilon)'};
            fprintf(FID, '%s & %2.4f & %2.4f \\\\ \n', lbls{y}, g_mean, g_median);
        
        end
        
        fclose(FID);

    end
    
    
%% eta=4    
    
    
    
 % Matrix for results:
result_stoch_eta4 = zeros(1000,4,1,size(seasons,2));
 
    for t = 1:3
        
        % Set current eta and degree of seasonality
        eta = 4;
        season_now = seasons(t); % 1: Middle, 2: High, 3: Low
        
        % Draw types of individuals
        z = exp(-sigmau/2) * exp(sqrt(sigmau)*randn(N,1));
        % + Shocks
        epsilon = repelem(exp(sqrt(sigmae)*randn(N,years)),1,12);
        individual_part = exp(-sigmae/2) * epsilon;
        
        % Shocks (for seasons, individual component)
        sigma_m = repmat(sigma_m_seas(:,season_now)',N,years);
        stoch_seas_comp = exp(-sigma_m/2) .* exp(sqrt(sigma_m).*randn(N,years*12));
        
        % Get the deterministic seasonal components per month and individual
        gm_seas = repmat(g_tot(:,season_now)',N,years);
        
        % Compute the consumption for all individuals
        cons = repmat(z,1,years*12) .* exp(gm_seas) .* stoch_seas_comp .* individual_part;
        cons_no_seas_determ = repmat(z,1,years*12) .* stoch_seas_comp .* individual_part;
        cons_no_seas_stochast = repmat(z,1,years*12) .* exp(gm_seas) .* individual_part;
        cons_no_seas_determ_no_stochast = repmat(z,1,years*12) .* individual_part;
        cons_no_shock = repmat(z,1,years*12) .* exp(gm_seas) .* stoch_seas_comp;
               
      
            util = cons.^(1-eta)/(1-eta);
            util_no_seas_det = cons_no_seas_determ.^(1-eta)/(1-eta);
            util_no_seas_stochast = cons_no_seas_stochast.^(1-eta)/(1-eta);
            util_no_seas_det_no_stoch = cons_no_seas_determ_no_stochast.^(1-eta)/(1-eta);
            util_no_shock = cons_no_shock.^(1-eta)/(1-eta);


        
        % Compute discount factors for each period and all individuals
        discount_factors = repmat(beta.^(12+(0:years*12-1)),N,1);
        
        % Compute lifetime utility
        W = sum(discount_factors.*util,2);
        W_no_det = sum(discount_factors.*util_no_seas_det,2);
        W_no_stoch = sum(discount_factors.*util_no_seas_stochast,2);
        W_no_det_no_stoch = sum(discount_factors.*util_no_seas_det_no_stoch,2);
        W_no_shock = sum(discount_factors.*util_no_shock,2);
        
        % Welfare gains
        % WX = (1+g)^(1-eta)*W
        %   discount_sum = sum(discount_factors,2);
            
            g_no_det = (W_no_det./W).^(1/(1-eta))-1;
            g_no_stoch = (W_no_stoch./W).^(1/(1-eta))-1;
            g_no_det_no_stoch = (W_no_det_no_stoch./W).^(1/(1-eta))-1;
            g_no_shock = (W_no_shock./W).^(1/(1-eta))-1;

            

        
        % Store the results
        result_stoch_eta4(:,:,1,t) = [g_no_det g_no_stoch g_no_det_no_stoch g_no_shock];
        
    end



% Generate Latex output    
    for t = 1:3
        
        FID = fopen(['Latex_report/tab_stochasticpart_eta4_seas_' num2str(seasons(t)) '.tex'], 'w');
        
        for y = 1:size(result_stoch_eta4,2)
            
            g_mean = mean(result_stoch_eta4(:,y,1,t));
            g_median = median(result_stoch_eta4(:,y,1,t));
            %g5 = prctile(result_stoch_eta1(:,y,1,t),5);
            %g95 = prctile(result_stoch_eta1(:,y,1,t),95);
            lbls = {'No seasons (determ. part)','No seasons (Stoch. part)','No seasons (determ. + stochast. part)', 'No shocks (i.e. no epsilon)'};
            fprintf(FID, '%s & %2.4f & %2.4f \\\\ \n', lbls{y}, g_mean, g_median);
        
        end
        
        fclose(FID);

    end
   
  

