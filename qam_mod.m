function [IQ_sym_out] = qam_mod(bits_in,M,init_phase,fp_en,fp_prec)
dataModG   = qammod(bits_in,M,init_phase,'gray');           %% Gray coding, phase offset = 0
meanPower  = mean(abs(dataModG).^2);                        %% Calculating Mean Power or Average Power
IQ_sym_out = dataModG/sqrt(meanPower);                      %% Normalization of Modulated Samples using Average Power
%%% In case fixed-point is enabled, the IQ samples will be truncated to
%%% fp_prec length
if fp_en == 1
    IQ_sym_out = floor(dataModG.*2^fp_prec)/2^fp_prec;
end

