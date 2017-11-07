%%% Function:   [symbol,mod_array] = QAM_modulate(bdata,modType,M,init_phase)
%%% Description:
%%%             Function to perform a modulation for QAM
%%%             symbols (QPSK, 16-QAM, 64-QAM)
%
%%% Inputs:-    bdata       ==> Input binary data
%%%             modType     ==> Choose to select between standard rectangular QAM and Custom Modulation Mapping for 16-QAM         
%%%             M           ==> M-ary value; M = 2^k; where k= Number of
%%%                             bit group to form a symbol
%%%             init_phase  ==> In case the constellation to be
%%%                             phase-shifted, value in radian
%%% Output:-    symbol      ==> Output modulated symbol
%%%             mod_array   ==> Modulated array for all the constellation
%%%                             points
%
%%% Author:     NIL
%%% Version:    1.0
%%% Date:       1st Nov 2017
function [symbol,mod_array] = QAM_modulate(bdata,modType,M,init_phase)
if modType == 0
    dataModG   = qammod(bdata,M,init_phase,'gray');           %% Gray coding, phase offset = 0
    [MM,NN]    = size(dataModG);
    max_size   = max(MM,NN); 
    %% Restrict to compute average power on modulated symbols for more than specified points. 
    max_sym  = 1024;    % Number of points till average power computation to be restricted
    if max_size > max_sym
        dim = max_sym;
    else 
        dim = max_size;
    end
    meanPower  = mean(abs(dataModG(1:dim)).^2);              %% Calculating Mean Power or Average Power
    symbol     = dataModG/sqrt(meanPower);                    %% Normalization of Modulated Samples using Average Power
    mod_array  = qammod((0:1:15),M,init_phase,'gray')/sqrt(meanPower);
elseif modType == 1
    %%% Custom Mapping of IQ symbols; Circular 16-QAM
    I = [0.866025,0.5,1,0.258819,-0.5,0,-0.866025,-0.258819,0.5,0,0.866025,0.258819,-0.866025,-0.5,-1,-0.258819];
    Q = [0.5,0.866025,0,0.258819,0.866025,1,0.5,0.258819,-0.866025,-1,-0.5,-0.258819,-0.5,-0.866025,0,-0.258819];
    for i=1:length(bdata)
        symbol(i) = I(bdata(i)+1) + 1i* Q(bdata(i)+1);
    end
    symbol        = symbol .* exp(1i*init_phase);
    mod_array = I + 1i*Q;
    mod_array = mod_array .* exp(1i*init_phase);
else
    symbol    = [];
    mod_array = [];
    error('Modulation Type Error: Modulation Type can be either 0 or 1');
end;
end

