function dum_k = calc_find_k_110131(dum_depth,dum_kmax)
% calc_find_k_110131
%
%   *******************************************************************   %
%   *** Calculate k location of a specified depth *********************   %
%   *******************************************************************   %
%
%
%   *******************************************************************   %
%   *** HISTORY *******************************************************   %
%   *******************************************************************   %
%
%   11/01/31: CREATED [COPIED FROM calc_find_ij_v100706]
%
%   *******************************************************************   %

% \/\/\/ USER SETTINGS \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ %
par_D_max = 5000.0;     % max depth (m)
par_ez0 = 0.1;          % GOLDSTEIN ez0 parameter
% /\/\/\ USER SETTINGS /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ %

% *********************************************************************** %
% *** INITIALIZE PARAMETERS & VARIABLES ********************************* %
% *********************************************************************** %
%
% set depth array
D = -get_gdep(dum_kmax,par_ez0,par_D_max);
%
% *********************************************************************** %

% *********************************************************************** %
% *** CALCULATE (k) ***************************************************** %
% *********************************************************************** %
%
% CALCULATE 'k'
loc_n_k = dum_kmax;
for n_k = dum_kmax:-1:2,
    if dum_depth > D(n_k), loc_n_k = n_k - 1; end
end
if dum_depth > D(1), loc_n_k = 1; end
%
% *********************************************************************** %

% *********************************************************************** %
% *** RETURN RESULT ***************************************************** %
% *********************************************************************** %
%
dum_k = [loc_n_k];
%
% *********************************************************************** %

