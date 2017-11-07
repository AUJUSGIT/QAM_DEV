%%% Function:   [scr_dbit] = data_scrambler(in_dbit,enab,M)
%%% Description:
%%%             Function to perform a data scrambling on data symbols. The 
%%%             scrambling sequence generator polynomial shall be x9 +x4 +1 
%%%             and the generator shall be initialized to 1 at the start of 
%%%             each data frame. 
%%%             Use modulo-8 operation for 8-PSK and XOR for 16-QAM & 64-QAM
%
%%% Inputs:-    in_dbit     ==> Input data bits to scramble
%%%             enab        ==> To enable scrambler
%%%             M           ==> M-ary value; M = 2^k; where k= Number of
%%%                             bit group to form a symbol
%%% Output:-    scr_dbit    ==> Output scramble data bits
%%%             mod_array   ==> Modulated array for all the constellation
%%%                             points
%
%%% Author:     NIL
%%% Version:    1.0
%%% Date:       1st Nov 2017

function [scr_dbit] = data_scrambler(in_dbit,enab,M)
k = ceil(log2(M));
L = length(in_dbit);
scr_data           = [1 zeros(1,8)];      %% Initialize the scrambler
scr_data_calc(:,1) = scr_data;            %% Store the very first scrambler out as init data 
for ii=1:L-1
    for kk=1:k
        scr_data      = [scr_data(2:end)  xor(scr_data(1),scr_data(5))];
    end
scr_data_calc(:,ii+1) = scr_data;
scr_data_rev          = scr_data_calc(1:4,:);
end;
for jj=1:L
    in_bits  = de2bi(in_dbit(jj),k)';
    if enab == 1
        out_bits = [xor(in_bits(1),scr_data_rev(1)) xor(in_bits(2),scr_data_rev(2)) xor(in_bits(3),scr_data_rev(3)) xor(in_bits(4),scr_data_rev(4))];
    else
        out_bits = [in_bits(1) in_bits(2) in_bits(3) in_bits(4)];
    end
    scr_dbit(jj,1) = bi2de(out_bits);
end   
end

