clc; clear all;
%% Define System Parameters
Fs   = 6.144e6;     %% System Sampling Rate
Fsym = 3.072e6;     %% System Symbol Rate
M    = 16;          %% M-ary value
init_ph = 0;        %% Modulator Initial Phase-Offset in radians
Eb_No_Start = 0;    %% Eb/No Start Value
Eb_No_Step  = 1;    %% Eb/N0 Step Value
Eb_No_End   = 10;   %% Eb/No End Value
num_bits    = 1e8;  %% Number of Bits to know BER
num_errors  = 100;  %% Number of Errors to terminate each Eb/No case simulation
num_sps     = 1;    %% Number of Samples Per Symbol
%% System Control Parameters 
fp_en   = 1;        %% To Enable Fixed-point output
fp_prec = 15;       %% Number of Fixed-Point Precision bit-widths
%%% Generate Random Numbers
k      = log2(M);   %% Bits per Symbol
rand_int = randi([0 M-1],num_bits/k,1);
%% QAM Modulator
dataMod = qam_mod(rand_int,M,0,fp_en, fp_prec);     %% Use M-QAM Modulator to generate Modulated Symbols
%% Generate Eb/No for each step
%%% Add AWGN to the Tx Modulated Samples
receivedSignal = zeros(num_bits/k,1);
i = 1;
tic;
while i <=((Eb_No_End-Eb_No_Start)/Eb_No_Step)+1

EbNo = Eb_No_Start + (i-1)*Eb_No_Step;
snr = EbNo + 10*log10(k) - 10*log10(num_sps);       %% num_sps is not being used in here, it can be used for future expansion
receivedSignal = awgn(dataMod,snr,'measured');
fprintf('\n Computing BER for each Eb/No = %d',EbNo);
% %% Plot Noisy Signal to Constellation Diagram wrt Tx Mod Constellation
% sPlotFig = scatterplot(receivedSignal(:,Eb_No_End),1,0,'g.');
% hold on
% scatterplot(dataMod,1,0,'k*',sPlotFig)
%% Rx Demodulator
%rx_symb = zeros(num_bits/k,((Eb_No_End-Eb_No_Start)/Eb_No_Step)+1);zeros(num_bits/k,((Eb_No_End-Eb_No_Start)/Eb_No_Step)+1);

rx_symb= qam_demod(receivedSignal,M,0);

%% Calculate Bits in error
% Reset the error and bit counters

    
    numErrs = 0;
    numBits = 0;

    
        dataIn  = de2bi(rand_int,k);
        dataOut = de2bi((rx_symb),k);

        % Calculate the number of bit errors
        nErrors = biterr(dataIn,dataOut);

        % Increment the error and bit counters
        numErrs = numErrs + nErrors;
        numBits = numBits + size(rx_symb,1)*k;
        ber_calc(i)  = numErrs/numBits;
        numErrs_calc(i)  = numErrs;
        numBits_calc(i)  = numBits;
        i = i + 1;
end
toc;    
%% Plot BER Vs Eb/No

Eb_No = (Eb_No_Start:Eb_No_Step:Eb_No_End);
semilogy(Eb_No,ber_calc,'*')