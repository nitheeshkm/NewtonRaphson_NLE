function [Xn_plus_1] = NR_multivariate(Xn)

% Xn =[0.1026;1.6410;2.5641];

x = Xn(1);
y = Xn(2);
z = Xn(3);

F = [x^2-2*x+y^2-z+1;
     x*y^2-x-3*y+y*z+2;
     x*z^2-3*z+y*z^2+x*y];

j00 = 2*x-2;
j01 = 2*y;
j02 = -1;

j10 = y^2-1;
j11 = 2*x*y-3+z;
j12 = y;

j20 = z^2+y;
j21 = z^2+x;
% j22 = 2*x*z-3+2*y*z; 
j22 = 2*z*(x+y)-3;

% Ij00 = (2*x*y-3+z)*(2*x*z-3+2*y*z)-(z^2+x)*y;
Aj00 = j11*j22 - j12*j21;
Aj01 = j10*j22 - j20*j12;
Aj02 = j10*j21 - j20*j11;
Aj10 = j01*j22 - j21*j02;
Aj11 = j00*j22 - j20*j02;
Aj12 = j00*j21 - j01*j20;
Aj20 = j01*j12 - j11*j02;
Aj21 = j00*j12 - j10*j02;
Aj22 = j00*j11 - j10*j01;

% Aj00 = Aj00;
Aj01 = -Aj01;
% Aj02 = Aj02;
Aj10 = -Aj10;
% Aj11 = Aj11;
Aj12 = -Aj12;
% Aj20 = Aj20
Aj21 = -Aj21;
% Aj22 = Aj22;


D = j00*Aj00+ j01*Aj01 + j02*Aj02;
D0 = j00*Aj00;
D1 = j01*Aj01;
D2 = j02*Aj02;
Dbuffer  = D;

A = [Aj00, Aj10, Aj20;
     Aj01, Aj11, Aj21;
     Aj02, Aj12, Aj22];
 
D = 1/D;

I = D*A;
IFBuffer = I*F;
Xn_plus_1 = Xn-I*F




