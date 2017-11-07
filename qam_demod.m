function [dataSymbolsOut] = qam_demod(receivedSignal,M,init_phase)
meanPower      = sqrt(mean(abs(receivedSignal(1:1024)).^2)); 
meanPower_ref  = sqrt(mean(abs(qammod((0:1:M-1),M,init_phase,'gray').^2))); 
receivedSignal = receivedSignal.*(meanPower_ref/meanPower);
dataSymbolsOut = qamdemod(receivedSignal,M,0,'gray');
end

