% from acceleration to velocit (mobility)

% load('WS_Exp1022_BracketE_clean.mat')

Acc = data_mod.ResponseData;
w = data_mod.Frequency;

for i = 1 :size(w);
    mob(:,:,i) = Acc(:,:,i)./(1j*w(i));
end
data_mob = frd(mob,w);
