%%% Function:   [symbol] = QAM_demodulate(sym,mod_array,bin_array,M,mod_type,init_phase)
%%% Description:
%%%             Function to perform a hard decision demodulation for QAM
%%%             symbols (QPSK, 16-QAM, 64-QAM)
%
%%% Inputs:-    sym         ==> Input Symbols
%%%             mod_array   ==> Array of modulated QAM symbols (used for
%%%                             demodulation)
%%%             bin_array   ==> Array of modulated binary data (used for
%%%                             demodulation)
%%%             M           ==> M-ary value M = 2^k;   
%%%             mod_type    ==> Select either 0 or 1 between standard
%%%                             rectangular 16-QAM modulation or custom 16-QAM mapping
%%%             init_phase  ==> In case the constellation to be
%%%                             phase-shifted, value in radian

%%% Output:-    symbol      ==> Output demodulated symbol
%
%%% Author:     NIL
%%% Version:    1.0
%%% Date:       1st Nov 2017


function [symbol] = QAM_demodulate(sym,mod_array,bin_array,M,mod_type,init_phase)
[MM,NN]    = size(sym);
    max_size   = max(MM,NN); 
    %% Restrict to compute average power on modulated symbols for more than specified points. 
    max_sym  = 1024;    % Number of points till average power computation to be restricted
    if max_size > max_sym
        dim = max_sym;
    else 
        dim = max_size;
    end
    meanPower  = mean(abs(sym(1:dim)).^2);          

meanPower_ref  = sqrt(mean(abs(QAM_modulate((0:1:M-1),mod_type,M,init_phase).^2))); 
receivedSignal = sym.*(meanPower_ref/meanPower);
for i =1:length(receivedSignal)
    min_error = 1e6;            % Set minimum error to some high value
    index = -1 ;                % Set symbol index to out-of-range
    for ii = 1:M                % Iterate through every symbol in the constellation
        mse = abs((receivedSignal(i) -mod_array(ii)).^2); % Compute the MSE between received data and ideal symbol
        if mse< min_error                % If the MSE is the smallest found
            min_error = mse;             % Store the MSE
            index = ii;                  % Store the symbol index
        end
    end
    if index == -1              % Error trap if there are no close symbols
        error('Demodulation Error: No close symbol in constellation found');
    end
    symbol(i,1) = bin_array(index);% Compute the estimated transmitted binary sequence (hard-decision)
end
end

