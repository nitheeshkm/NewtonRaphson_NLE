clc;
clear all;

X0 = [1;2;3];
maxIter = 25;
req_error = 1e-10;

Xn = X0;
for i = 1:maxIter
    [Xn_plus_1] = NR_multivariate(Xn);
    error = abs(Xn-Xn_plus_1);
    Xn = Xn_plus_1;
    if(error < req_error)
        break;
    end
end
i
Xn_plus_1
error