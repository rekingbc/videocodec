% function [u,Gap,Primal,Dual,EstP,EstD]=VSNR(u0,eps,p,Gabor,alpha,maxit,prec,C,[EstP,EstD])
%
% This function helps removing "structured"
% additive noise. By "structured", we mean that the noise consists of
% convolving a white noise with a given filter.
%
% PD stands for Primal-Dual, as the core of the program is a
% first-order primal-dual algorithm (described in
% "A first-order Primal-Dual Algorithm for convex problems with application to imaging",
% by A. Chambolle and T. Pock).
%
% This function solves (in the sense that the duality gap is less than prec):
% Min_{Lambda} ||nabla u||_{1,eps} + sum_{i=1}^m alpha(i)||Lambda_i||_p_i
% over the constraint that ||lambda||_infty<=C
%
% where :
% - u=u0+sum_{i=1}^m conv(Lambda_i,Gabor(i))
% - ||q||_{1,eps}= sum_{i=1}^n f(|q|) where f(x)=|x| if |x|>eps and
% f(x)=x^2/2eps+eps/2 otherwise.
% - ||.||_p is the standard l^p-norm
%
% IN :
% - u0 : original image (size nx*ny).
% - eps : regularization parameter for TV norm (can be 0).
% - p : either a value in {1,2,Inf}, either a vector of size m with values in the previous set.
% - Gabor : a nx*ny*m array containing the shape of m Gabor filters.
% - alpha : either a value in R_+^* either a vector of size m in the with
% all value in R_+^*.
% - maxit : maximum iteration number.
% - prec : a value in R_+^* that specifies the desired precision (typical=1e-2).
% - C    : l-infinite constraint on lambda.
% - EstP and EstD : optional parameters which are estimates of the primal.
% and dual solutions. (Note : EstP is actually Lambda)
%
% OUT :
% - u : u0+sum_{i=1}^m conv(Lambda_i,Gabor(i))
% - Gap, Primal, Dual : vectors of size equal to the iterations number that
% specifies the duality gap, Primal cost and Dual Cost at each iteration.
% - EstP and EstD : solutions of primal and dual problem.
%
% Any comments: please contact Pierre Weiss, pierre.armand.weiss@gmail.com
function [u,Gap,Primal,Dual,EstP,EstD]=VSNR(u0,eps,p,Gabor,alpha,maxit,prec,C,varargin)

%% Initializations
Gap=zeros(maxit,1);
Primal=zeros(maxit,1);
Dual=zeros(maxit,1);

% Retrieves informations about the problem type. m is the filters number.
if ndims(Gabor)==2
  m=1;
  [nx,ny]=size(Gabor);
else
  [nx,ny,m]=size(Gabor);
end

% Makes every parameters of size m
if (m>1)
  if (length(p)~=m)
    p=p(1)*ones(m,1);
  end
  if (length(alpha)~=m)
    alpha=alpha(1)*ones(m,1);
  end
end

% Gives values to the initial guesses
if (size(varargin,2)>=1) %Primal variable
  lambda=varargin{1};
else
  lambda=zeros(nx,ny,m);
end
if (size(varargin,2)>=2) %Dual variable
  q=varargin{2};
else
  q=zeros(nx,ny,2);
end

gu0=zeros(nx,ny,2); % stores he gradient of u0
gu0(:,:,1)=drond1(u0);
gu0(:,:,2)=drond2(u0);

%Computes Fourier transforms
FGabor=zeros(size(Gabor));
for i=1:m
  FGabor(:,:,i)=fft2(Gabor(:,:,i));
end

%% Primal-Dual Algorithm

%Metric specification
N=ones(size(u0));
M=ones(size(lambda));

%Parameter specification
lambdab=lambda;

%% First computes the initial duality gap.
b=zeros(size(u0));
for i=1:m
  b=b+ifft2(fft2(lambda(:,:,i)).*FGabor(:,:,i));
end
b=real(b); %at this point b represents the noise.

%Current estimate of the denoised image
u=u0+b;

%Computation of the primal cost
d1u=drond1(u);d2u=drond2(u);
if (eps==0)
  ngu=sum(sqrt(d1u(:).^2+d2u(:).^2));
else
  ngu=d1u(:).^2+d2u(:).^2;
  ngu=sum(min(ngu/eps,sqrt(ngu)) - .5*min (ngu/eps,eps));
end
Clambda=0;for i=1:m;Clambda=Clambda+Phi(lambdab(:,:,i),p(i),alpha(i));end
primal0=ngu+Clambda;
%Computation of the dual cost
Astarq=zeros(size(lambda));
gradTq=fft2(drond1T(q(:,:,1))+drond2T(q(:,:,2)));
for i=1:m
  Astarq(:,:,i)=real(ifft2(conj(FGabor(:,:,i)).*gradTq));
end
Gstar=0;
for i=1:m
  Gstar=Gstar+PhiStar(-M(:,:,i).*Astarq(:,:,i),p(i),C,alpha(i));
end
%Computation of Fstar=F*(q)
qq(:,:,1)=q(:,:,1).*N;
qq(:,:,2)=q(:,:,2).*N;
nqq=sqrt(qq(:,:,1).^2+qq(:,:,2).^2);
if (max(nqq(:))>1)
  Fstar=Inf;
else
  Fstar=eps/2*norm(nqq(:))^2-sum(sum(gu0(:,:,1).*qq(:,:,1)))-sum(sum(gu0(:,:,2).*qq(:,:,2)));
end
dual0=-Fstar-Gstar;

gap0=primal0-dual0;
Gap(1)=gap0;
Primal(1)=primal0;
Dual(1)=dual0;


%% Computation of the largest singular value of A
d1=zeros(size(u0));
d1(end,1)=1;d1(1,1)=-1;
d2=zeros(size(u0));
d2(1,end)=1;d2(1,1)=-1;
d1h=fft2(d1);
d2h=fft2(d2);

H=zeros(size(u0));
for i=1:m
  H=H+abs(FGabor(:,:,i)).^2;
end
L=sqrt(max(H(:).*(abs(d1h(:)).^2+abs(d2h(:)).^2)));
%disp(sprintf('Operator norm : %1.5f',L))
clear d1 d2 d1h d2h H;

u=u0;
gap=Inf;

gamma=min(alpha(:));
weight=1;
tau=weight/L;
sigma=1/(tau*L^2);
theta=1;
nit=2;

if (isnan(gap0))
    fprintf('INITIAL DUAL GAP IS INFINITE -- PROGRAM WILL STOP AFTER %i ITERATIONS \n',maxit);
    gap0=1e16;
end

%% The actual algorithm
while (nit<maxit)&&(gap>prec*gap0)
  %% I.1/ q_{n+1}=(I+sigma partial F^*)^{-1}(q_n+sigma A lambdab_n)
  %Computation of the convolutions with lambdab_n
  b=zeros(size(u0));
  for i=1:m
    b=b+ifft2(fft2(lambdab(:,:,i)).*FGabor(:,:,i));
  end
  b=real(b); %at this point b represents the noise.

  %Current estimate of the denoised image
  u=u0+b;
  %Gradient (corresponds to tilde q_n in the article)
  qtilde(:,:,1)=q(:,:,1)+sigma*drond1(u);
  qtilde(:,:,2)=q(:,:,2)+sigma*drond2(u);

  %Resolvent operator...
  nqq=sqrt(qtilde(:,:,1).^2+qtilde(:,:,2).^2);
  q(:,:,1)=qtilde(:,:,1)./(max(N.*nqq,N*eps*sigma+1));
  q(:,:,2)=qtilde(:,:,2)./(max(N.*nqq,N*eps*sigma+1));

  %% II.1/ lambda_{n+1}=(I+tau partial G)^{-1}(lambda_{n+1}-tau A^*
  %% q_{n+1})
  %Computation of ATq_{n+1}
  Astarq=zeros(size(lambda));
  gradTq=fft2(drond1T(q(:,:,1))+drond2T(q(:,:,2)));
  for i=1:m
    Astarq(:,:,i)=real(ifft2(conj(FGabor(:,:,i)).*gradTq));
  end
  lambdau=lambda-tau*Astarq;

  %Computation of the resolvent of (I+tau partial G)^{-1}
  for i=1:m
    lambdau(:,:,i)=Prox_Phi(lambdau(:,:,i),p(i),M(:,:,i),tau,alpha(i),C);
  end

  %% III/ Step size update (TO BE DONE)
  if (sum(p==2)==length(p)) %If all phi_i are l2
    if (eps>0)
      mu=2*sqrt(gamma*eps)/L;
      tau=mu/(2*gamma);
      sigma=mu/(2*eps);
      theta=1/(1+mu);
    else
      theta=1/sqrt(1+2*gamma*tau);
      tau=theta*tau;
      sigma=sigma/theta;
    end
  else
    if (eps>0)
%       theta=1/sqrt(1+2*eps*sigma);
%       tau=tau*theta;
%       sigma=sigma/theta;
    end
  end

  %% IV/ Correction bar x^{n+1}=x^{n+1}+theta(x^{n+1}-x^n)
  lambdab=lambdau+theta*(lambdau-lambda);
  lambda=lambdau;

  %% V/ Display (NOTE : computation of the cost function could be done in
  %% here, i.e. only once in a while)
  if (mod(nit,10)==0)
    %% I.2/ Computation of the primal cost (VALIDATED)
    d1u=drond1(u);d2u=drond2(u);
    if (eps==0)
      ngu=sum(sqrt(d1u(:).^2+d2u(:).^2));
    else
      ngu=d1u(:).^2+d2u(:).^2;
      ngu=sum(min(ngu/eps,sqrt(ngu)) - .5*min (ngu/eps,eps));
    end
    Clambda=0;
    for i=1:m;Clambda=Clambda+Phi(lambdab(:,:,i),p(i),alpha(i));end
    primal=ngu+Clambda;
    Primal(nit)=primal;

    %% II.2/ Computation of the dual cost.
    %Computation of Gstar=G*(-A*q)
    Gstar=0;
    for i=1:m
      Gstar=Gstar+PhiStar(-M(:,:,i).*Astarq(:,:,i),p(i),C,alpha(i));
    end
    %Computation of Fstar=F*(q)
    qq(:,:,1)=q(:,:,1).*N;
    qq(:,:,2)=q(:,:,2).*N;
    nqq=sqrt(qq(:,:,1).^2+qq(:,:,2).^2);
    if (abs(nqq>1))
      Fstar=0;
    else
      Fstar=eps/2*norm(nqq(:))^2-sum(sum(gu0(:,:,1).*qq(:,:,1)))-sum(sum(gu0(:,:,2).*qq(:,:,2)));
    end
    dual=-Fstar-Gstar;
    Dual(nit)=dual;

    gap=primal-dual;
    if isnan(gap)
        gap=1e16;
    end
    Gap(nit)=gap;    

    fprintf('Nit:%i -- Relative Dual Gap: %1.5e -- Objective: %1.4e -- Primal: %1.5e -- Dual:%1.5e\n', nit,gap/gap0,prec, primal,dual);
  else
    Primal(nit)=Primal(nit-1);
    Dual(nit)=Dual(nit-1);
    Gap(nit)=Gap(nit-1);
  end

  nit=nit+1;
end

if nit>=maxit
    disp('BEWARE, BAD CONVERGENCE, CHECK PARAMETERS !')
end

Gap=Gap(1:nit-1);
Primal=Primal(1:nit-1);
Dual=Dual(1:nit-1);

EstP=lambda;
EstD=q;

%% Companion functions

%This function computes Phi^*(lambda)
%where:
%Phi(x)=||x||_1 if p=1
%Phi(x)=1/2||x||_2^2 if p=2
%Phi(x)=0 if p=Infty and ||x||_inf<=1 inf otherwise
function v=PhiStar(lambda,p,C,alpha)
if (p==1)
  v=sum(max(0,C*(abs(lambda(:))-alpha)));
elseif (p==2)
  v=alpha*(sum(min(abs(lambda(:)/alpha),C).*abs(lambda(:)/alpha)- 0.5*min(abs(lambda(:)/alpha),C).^2));
elseif (p==Inf)
  v=min(C,alpha)*sum(abs(lambda(:)));
end

function n=Phi(x,p,alpha)
if (p==1)
  n=alpha*sum(abs(x(:)));
elseif (p==2)
  n=alpha/2*sum(x(:).^2);
elseif (p==Inf)
  if max(abs(x(:)))>alpha
    n=Inf;
  else
    n=0;
  end
end

%This function solves :
% argmin_{|y|<=C} tau alpha ||y||_p + 1/2 ||M(y-x)||_2^2
function y=Prox_Phi(x,p,M,tau,alpha,C)

if (tau==0)
  y=x./(max(1,abs(x)/C));
  return
end
if (p==1)
  tau=alpha*tau;
  y=max(abs(M.*x)-tau,0);
  y=y.*sign(x)./(max(abs(y)/C,1));
elseif (p==2)
  tau=tau*alpha;
  y=M.*x./(tau+M);
  y=y./(max(1,abs(y)/C));
elseif (p==Inf)
  delta=min(alpha,C);
  y=x./(max(1,abs(x)/delta));
end

function d=drond1(im)
d=zeros(size(im));
d(1:end-1,:)=im(2:end,:)-im(1:end-1,:);

function d=drond1T(im)
d=zeros(size(im));
d(2:end-1,:)=im(1:end-2,:)-im(2:end-1,:);
d(1,:)=-im(1,:);
d(end,:)=im(end-1,:);

function d=drond2(im)
d=zeros(size(im));
d(:,1:end-1)=im(:,2:end)-im(:,1:end-1);

function d=drond2T(im)
d=zeros(size(im));
d(:,2:end-1)=im(:,1:end-2)-im(:,2:end-1);
d(:,1)=-im(:,1);
d(:,end)=im(:,end-1);