clc; clear all;
%% Define System Parameters
Fs   = 6.144e6;     %% System Sampling Rate
Fsym = 3.072e6;     %% System Symbol Rate
M    = 16;          %% M-ary value
init_ph = 0;        %% Modulator Initial Phase-Offset in radians
Eb_No_Start = 0;    %% Eb/No Start Value
Eb_No_Step  = 1;    %% Eb/N0 Step Value
Eb_No_End   = 18;   %% Eb/No End Value
num_bits    = 1e4;  %% Number of Bits to measure BER
num_errors  = 100;  %% Number of Errors to terminate each Eb/No case simulation
num_sps     = 1;    %% Number of Samples Per Symbol
mod_type    = 0;    %% Select modulation type 0:Standard 16-QAM; 1:Custom Circular Mapping 16-QAM 
init_phase  = 0;    %% Set initial phase of Mapper in radians
enab_scr    = 1;    %% Enable Scrambler and De-Scrambler
%% System Control Parameters 
fp_en   = 1;        %% To Enable Fixed-point output
fp_prec = 15;       %% Number of Fixed-Point Precision bit-widths
%%% Generate Random Numbers
k      = log2(M);   %% Bits per Symbol
rand_int = randi([0 M-1],num_bits/k,1);
%% Data Scrambling
scr_rand_int = data_scrambler(rand_int,enab_scr,M); % Perform scrambling to the input random integer  
%% QAM Modulator
[dataMod,mod_array] = QAM_modulate(scr_rand_int,mod_type,M,init_phase);     %% Use M-QAM Modulator to generate Modulated Symbols [symbol,mod_array] = QAM_modulate(bdata,modType,M,init_phase)
%% Generate Eb/No for each step
%%% Add AWGN to the Tx Modulated Samples
receivedSignal = zeros(num_bits/k,1);
i = 1;
tic;
while i <=((Eb_No_End-Eb_No_Start)/Eb_No_Step)+1

EbNo = Eb_No_Start + (i-1)*Eb_No_Step;
snr = EbNo + 10*log10(k) - 10*log10(num_sps);       %% num_sps is not being used in here, it can be used for future expansion
receivedSignal = awgn(dataMod,snr,'measured');

%scatterplot(receivedSignal,1);
fprintf('\n Computing BER for each Eb/No = %d',EbNo);
%% Plot Noisy Signal to Constellation Diagram wrt Tx Mod Constellation
% close all;
% sPlotFig = scatterplot(receivedSignal,1,0,'g.');
% hold on
% scatterplot(dataMod,1,0,'k*',sPlotFig)
%% Rx Demodulator

rx_symb= QAM_demodulate(receivedSignal,mod_array,(0:1:15),M,mod_type,init_phase); %[symbol] = QAM_demodulate(sym,mod_array,bin_array,M,mod_type,init_phase)
%rx_symb= qam_demod(receivedSignal,M,init_phase); 
%% Perform back De-Scrambling
rx_symb_dcsr = data_scrambler(rx_symb,enab_scr,M); % Perform scrambling to the input random integer 
%% Calculate Bits in error
% Reset the error and bit counters

    
    numErrs = 0;
    numBits = 0;

    
        dataIn  = de2bi(rand_int,k);
        dataOut = de2bi((rx_symb_dcsr),k);

        % Calculate the number of bit errors
        nErrors = biterr(dataIn,dataOut);

        % Increment the error and bit counters
        numErrs = numErrs + nErrors;
        numBits = numBits + size(rx_symb_dcsr,1)*k;
        ber_calc(i)  = numErrs/numBits;
        numErrs_calc(i)  = numErrs;
        numBits_calc(i)  = numBits;
        fprintf('\t BER Measured = %d',ber_calc(i));

        i = i + 1;
        
        clear  numErrs numBits nErrors
        
end
fprintf('\n');
toc;    
clear dataIn dataout nErrors
%% Plot BER Vs Eb/No
%% Plot Noisy Signal to Constellation Diagram wrt Tx Mod Constellation
close all;
sPlotFig = scatterplot(receivedSignal,1,0,'g.');
hold on;
scatterplot(dataMod,1,0,'k*',sPlotFig);
%% Plot Eb/No Vs BER
figure;
Eb_No = (Eb_No_Start:Eb_No_Step:Eb_No_End);
semilogy(Eb_No,ber_calc,'bs-', 'LineWidth',2);
grid on
legend('simulation');
xlabel('Eb/No, dB')
ylabel('Bit Error Rate')
title('Bit error probability curve for 16-QAM modulation')