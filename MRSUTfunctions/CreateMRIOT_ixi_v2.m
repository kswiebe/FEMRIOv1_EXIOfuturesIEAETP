% by Richard Wood, NTNU Industrial Ecology Program
function [S,A,Z,F,Y,x,FY]=CreateMRIOT_ixi_v2(sup,use)
% #constructs
%%
%fixed product sales assumption

% indout = sum(sup,1);
% indout(indout<1)=1;
prodout_dom=sum(sup,2);
prodout_dom(prodout_dom<1)=1;
make=sup';
n_i=size(sup,2);
n_p=size(sup,1);
tic
D = sparse(make/(sparse(1:n_p,1:n_p,prodout_dom(1:n_p))));
%toc
Z= D*use(1:n_p,1:n_i);
F= use(n_p+1:end,1:n_i);
Y= D*use(1:n_p,n_i+1:end);
FY=use(n_p+1:end,n_i+1:end);
%toc
% Z= [Z;use(n_p+1:end,:)];
Z(Z<1e-9&Z>0)=0;
indout=sum(Z(1:n_i,:),2)+sum(Y(1:n_i,:),2);
% indout=sum(sup,1)';
indout2=indout;
indout2(indout<1e-3)=1;
A= Z(:,1:n_i)/sparse(1:n_i,1:n_i,indout2);
S= F(:,1:n_i)/sparse(1:n_i,1:n_i,indout2);
A(:,indout<1e-6)=0;
%toc
% A(A<1e-9&A>0)=0;

% L=inv(eye(n_i)-A(1:n_i,1:n_i));
% toc
% tmp=L(1:n_i,1:n_i);
% disp('min value in L:')
% min(min(tmp))
% % tmp(tmp<1e-8)=0;
% % L(1:n_i,1:n_i)=tmp;

% x=sum(sup,1)';
x=sum(Z(1:n_i,:),2)+sum(Y(1:n_i,:),2);
% y=Z(1:n_i,n_i+1:end);


% S=A(n_i+1:end,:);
% A=A(1:n_i,:);
  

return