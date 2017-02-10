% function [u,Gap,Primal,Dual,EstP,EstD]=VSNR_c(u0,Gabor,eps,p,alpha,nit,prec,C)
%
% C-function equivalent to Denoise_PD_StructuredNoise.
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
% - Gabor : a nx*ny*m array containing the shape of m Gabor filters.
% - eps : regularization parameter for TV norm (can be 0).
% - p : either a value in {1,2,Inf}, either a vector of size m with values in the previous set.
% - alpha : either a value in R_+^* either a vector of size m in the with
% all value in R_+^*.
% - nit : maximum iterations number.
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