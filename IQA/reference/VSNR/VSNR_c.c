/*
 * version 0.013
 *
 * compile with:
 * mex version_0_013.c -lfttw3
 *
 *
 */

#include <math.h>
#include <stdlib.h>
#include "matrix.h"
#include "mex.h"
#include "fftw3.h"

#define EPSILON 1e-14
#define MIN(a, b)  (((a) < (b)) ? (a) : (b))
#define MAX(a, b)  (((a) > (b)) ? (a) : (b))

/*convolution between a and b (a is in space domain, B in fourier domain, c result, C Fourier result)*/
void convolution(int N, int M, fftw_complex *a, fftw_complex *B, fftw_complex *c, fftw_complex *A, fftw_complex *C)
{
    double scale = 1.0f / (double)(M * N);
    int i;
    fftw_plan p;
    
    p= fftw_plan_dft_2d(M, N, a, A, FFTW_FORWARD, FFTW_ESTIMATE);
    fftw_execute(p);
    fftw_destroy_plan(p);
    
    for (i=0;i<M*N;++i){
        C[i][0]=(A[i][0]*B[i][0]-A[i][1]*B[i][1])*scale;
        C[i][1]=(A[i][0]*B[i][1]+A[i][1]*B[i][0])*scale;
        /*mexPrintf("%1.5e+%1.5ei\n",C[i][0],C[i][1]);*/
    }
    
    p= fftw_plan_dft_2d(M, N, C, c, FFTW_BACKWARD,FFTW_ESTIMATE);
    fftw_execute(p);
    fftw_destroy_plan(p);
}

/*Adjoint convolution between a and b (a is in space domain, B in fourier domain, c result, C Fourier result)*/
void convolutionT(int N, int M, fftw_complex *a, fftw_complex *B, fftw_complex *c, fftw_complex *A, fftw_complex *C)
{
    double scale = 1.0f / (double)(M * N);
    int i;
    fftw_plan p;
    
    p= fftw_plan_dft_2d(M, N, a, A, FFTW_FORWARD, FFTW_ESTIMATE);
    fftw_execute(p);
    fftw_destroy_plan(p);
    
    for (i=0;i<M*N;++i){
        C[i][0]=(A[i][0]*B[i][0]+A[i][1]*B[i][1])*scale;
        C[i][1]=(A[i][1]*B[i][0]-A[i][0]*B[i][1])*scale;
    }
    
    p= fftw_plan_dft_2d(M, N, C, c, FFTW_BACKWARD,FFTW_ESTIMATE);
    fftw_execute(p);
    fftw_destroy_plan(p);
}

/*convolution between A and B (both in in fourier domain, c result, C Fourier result)*/
void fconvolution(int N, int M, fftw_complex *A, fftw_complex *B, fftw_complex *c, fftw_complex *C)
{
    double scale = 1.0f / (double)(M * N);
    int i;
    fftw_plan p;
    
    for (i=0;i<M*N;++i){
        C[i][0]=(A[i][0]*B[i][0]-A[i][1]*B[i][1])*scale;
        C[i][1]=(A[i][0]*B[i][1]+A[i][1]*B[i][0])*scale;
    }
    
    p= fftw_plan_dft_2d(M, N, C, c, FFTW_BACKWARD,FFTW_ESTIMATE);
    fftw_execute(p);
    fftw_destroy_plan(p);
}

/*Adjoint convolution between A and B (both in fourier domain, c result, C Fourier result)*/
void fconvolutionT(int N, int M, fftw_complex *A, fftw_complex *B, fftw_complex *c, fftw_complex *C){
    double scale = 1.0f / ((double)(M * N));
    int i;
    fftw_plan p;
    
    for (i=0;i<M*N;++i){
        C[i][0]=(A[i][0]*B[i][0]+A[i][1]*B[i][1])*scale;
        C[i][1]=(A[i][1]*B[i][0]-A[i][0]*B[i][1])*scale;
        /*mexPrintf("%1.2e+%1.2e \n",C[i][0]/scale,C[i][1]/scale);*/
    }
    
    p= fftw_plan_dft_2d(M, N, C, c, FFTW_BACKWARD,FFTW_ESTIMATE);
    fftw_execute(p);
    fftw_destroy_plan(p);
}

double maxi(double *lambda, int *dimLambda){
    double maximum;
    int i;
    maximum=lambda[0];
    for(i=1;i<dimLambda[0]*dimLambda[1];i++){
        if (lambda[i]>maximum)
            maximum=lambda[i];
    }
    return maximum;
}

double mini(double *lambda, int taille){
    double minimum;
    int i;
    minimum=lambda[0]; /*pour rentrer dans la boucle*/
    for(i=1;i<taille;i++){
        if (lambda[i]<minimum)
            minimum=lambda[i];
    }
    return minimum;
}

double Phi(fftw_complex *lambda, int *dimLambda, double p, double alpha){
    int i;
    double undemi=0.5f;
    double norme=0;
    if ((int)p==1){
        for(i=0;i<dimLambda[0]*dimLambda[1];i++)
            norme+=fabs(lambda[i][0]);
        norme*=alpha;
    }
    else if ((int)p==2){
        for(i=0;i<dimLambda[0]*dimLambda[1];i++)
            norme+=lambda[i][0]*lambda[i][0];
        norme*=alpha*undemi;
    }
    /* pour la norme infinie, on utilise p=3 pour pouvoir avoir un pointeur sur un double*/
    else if ((int)p==3){
        norme=0;
        for(i=0;i<dimLambda[0]*dimLambda[1];i++){
            norme=MAX(lambda[i][0],norme);
        }
        if(norme>alpha+EPSILON){
            norme=INFINITY;
        }
        else
            norme=0;
    }
    return norme;
}

/*[C] PROBLEME ICI !!! ALLOCATION ASTAR ligne 851???*/
/*PhiStar(Astarq[i], dim[0]*dim[1], p[i], contrainte, alpha[i]);*/
double PhiStar(fftw_complex *lambda, int taille, double p, double C, double alpha){
    double lambdaAbs;
    double m;
    int i;
    double norme=0;
    
    if ((int)p==1){
        for(i=0;i<taille;i++){
            lambdaAbs=C*(fabs(lambda[i][0])-alpha);
            if (lambdaAbs>0)
                norme+=lambdaAbs;
        }
    }
    else if ((int)p==2){
        for(i=0;i<taille;i++){
            lambdaAbs=fabs(lambda[i][0]/(alpha));
            m=lambdaAbs<C?lambdaAbs:C;
            norme+=fabs(m*(lambdaAbs-0.5f*m));
        }
        norme*=alpha;
    }
    /* pour la norme infinie, on utilise p=3 pour pouvoir avoir un pointeur sur un double*/
    else if ((int)p==3){
        for(i=0;i<taille;i++){
            lambdaAbs+=fabs(lambda[i][0]);
        }
        norme=MIN(C,alpha)*lambdaAbs;
    }
    return norme;
}

void ProxPhi(fftw_complex *lambda, int taille, double p, double *M, double tau, double C, double alpha, fftw_complex *y){
    double lambdaAbs;
    int i,sgn;
    
    if (tau==0){
        for(i=0;i<taille;i++){
            y[i][1]=0;
            lambdaAbs=fabs(lambda[i][0])/C;
            if (lambdaAbs>1)
                y[i][0]=lambda[i][0]/(lambdaAbs);
            else{
                y[i][0]=lambda[i][0];
            }
        }
    }
    else{
        if ((int)p==1){
            tau=alpha*tau;
            for(i=0;i<taille;i++){
	        /*mexPrintf("lambda[%i]:%1.4e -- ",i,lambda[i][0]);*/
                sgn=1;
		if (y[i][0]<0) {sgn=-1;}
		y[i][1]=0;
		
                lambdaAbs=fabs(lambda[i][0]*M[i])-tau;
                if (lambdaAbs>0){
                    y[i][0]=lambdaAbs;
                }
                else{
                    y[i][0]=0;
                }
                lambdaAbs=fabs(y[i][0])/C;
                if (lambdaAbs>1)
                    y[i][0]/=lambdaAbs;
                
		y[i][0]*=sgn;
		/*mexPrintf("y[%i]= %1.4e \n",i,y[i][0]);*/
	    }
        }
        else if ((int)p==2){
            tau=alpha*tau;
            for(i=0;i<taille;i++){
                y[i][1]=0;
                y[i][0]=M[i]*lambda[i][0]/(tau+M[i]);
                lambdaAbs=fabs(y[i][0]/C);
                if (lambdaAbs>1)
                    y[i][0]=y[i][0]/(lambdaAbs);
            }
        }
        /* pour la norme infinie, on utilise p=3 pour pouvoir avoir un pointeur sur un double*/
        else if ((int)p==3){
            if (C<alpha){
                for(i=0;i<taille;i++){
                    y[i][1]=0;
                    lambdaAbs=fabs(lambda[i][0])/C;
                    if (lambdaAbs>1)
                        y[i][0]=lambda[i][0]/(lambdaAbs);
                    else
                        y[i][0]=lambda[i][0];
                }
            }
            else{
                for(i=0;i<taille;i++){
                    y[i][1]=0;
                    lambdaAbs=fabs(lambda[i][0])/(alpha);
                    if (lambdaAbs>1)
                        y[i][0]=lambda[i][0]/(lambdaAbs);
                    else
                        y[i][0]=lambda[i][0];
                }
            }
        }
    }
}

/*partial derivative 1*/
void drond1(double *im, int *dimIm, double *d){
    int i, j;
    for(j=0;j<dimIm[1];j++){
        for(i=0;i<dimIm[0]-1;i++){
            d[j*dimIm[0]+i]=im[j*dimIm[0]+i+1]-im[j*dimIm[0]+i];
        }
        d[j*dimIm[0]+dimIm[0]-1]=0;
    }
}

/*partial derivative 2*/
void drond2(double *im, int *dimIm, double *d){
    int i, j;
    for(i=0;i<dimIm[0];i++){
        for(j=0;j<dimIm[1]-1;j++){
            d[j*dimIm[0]+i]=im[(j+1)*dimIm[0]+i]-im[j*dimIm[0]+i];
        }
        d[(dimIm[1]-1)*dimIm[0]+i]=0;
    }
}

/* transpose of partial derivative 1*/
void drond1T(double *im, int *dimIm, double *d){
    int i, j;
    for(j=0;j<dimIm[1];j++){
        d[j*dimIm[0]+dimIm[0]-1]=im[j*dimIm[0]+dimIm[0]-2];
        for(i=dimIm[0]-2;i>0;i--){
            d[j*dimIm[0]+i]=im[j*dimIm[0]+i-1]-im[j*dimIm[0]+i];
        }
        d[j*dimIm[0]]=-im[j*dimIm[0]];
    }
}

/*[C] revoir tous les d2T transpose of partial derivative 1*/
void drond2T(double *im, int *dimIm, double *d){
    int i, j;
    for(i=0;i<dimIm[0];i++){
        d[(dimIm[1]-1)*dimIm[0]+i]=im[(dimIm[1]-2)*dimIm[0]+i];
        for(j=dimIm[1]-2;j>0;j--){
            d[j*dimIm[0]+i]=im[(j-1)*dimIm[0]+i]-im[j*dimIm[0]+i];
        }
        d[i]=-im[i];
    }
}

/*partial derivative 1*/
void drond1f(fftw_complex *im, int *dimIm, fftw_complex *d){
    int i, j;
    for(j=0;j<dimIm[1];j++){
        for(i=0;i<dimIm[0]-1;i++){
            d[j*dimIm[0]+i][0]=im[j*dimIm[0]+i+1][0]-im[j*dimIm[0]+i][0];
            d[j*dimIm[0]+dimIm[0]-1][1]=0;
        }
        d[j*dimIm[0]+dimIm[0]-1][0]=0;
        d[j*dimIm[0]+dimIm[0]-1][1]=0;
    }
}

/*partial derivative 2*/
void drond2f(fftw_complex *im, int *dimIm, fftw_complex *d){
    int i, j;
    for(i=0;i<dimIm[0];i++){
        for(j=0;j<dimIm[1]-1;j++){
            d[j*dimIm[0]+i][0]=im[(j+1)*dimIm[0]+i][0]-im[j*dimIm[0]+i][0];
            d[j*dimIm[0]+i][1]=0;
        }
        d[(dimIm[1]-1)*dimIm[0]+i][0]=0;
        d[(dimIm[1]-1)*dimIm[0]+i][1]=0;
    }
}

/* transpose of partial derivative 1*/
void drond1Tf(fftw_complex *im, int *dimIm, fftw_complex *d){
    int i, j;
    for(j=0;j<dimIm[1];j++){
        d[j*dimIm[0]+dimIm[0]-1][0]=im[j*dimIm[0]+dimIm[0]-2][0];
        d[j*dimIm[0]+dimIm[0]-1][1]=0;
        for(i=dimIm[0]-2;i>0;i--){
            d[j*dimIm[0]+i][0]=im[j*dimIm[0]+i-1][0]-im[j*dimIm[0]+i][0];
            d[j*dimIm[0]+i][1]=0;
        }
        d[j*dimIm[0]][0]=-im[j*dimIm[0]][0];
        d[j*dimIm[0]][1]=0;
    }
}

/* transpose of partial derivative 1*/
void drond2Tf(fftw_complex *im, int *dimIm, fftw_complex *d){
    int i, j;
    for(i=0;i<dimIm[0];i++){
        d[(dimIm[1]-1)*dimIm[0]+i][0]=im[(dimIm[1]-2)*dimIm[0]+i][0];
        d[(dimIm[1]-1)*dimIm[0]+i][1]=0;
        for(j=dimIm[1]-2;j>0;j--){
            d[j*dimIm[0]+i][0]=im[(j-1)*dimIm[0]+i][0]-im[j*dimIm[0]+i][0];
            d[j*dimIm[0]+i][1]=0;
        }
        d[i][0]=-im[i][0];
        d[i][1]=0;
    }
}

/*partial derivative 1*/
void drond1f2r(fftw_complex *im, int *dimIm, double *d){
    int i, j;
    for(j=0;j<dimIm[1];j++){
        for(i=0;i<dimIm[0]-1;i++){
            d[j*dimIm[0]+i]=im[j*dimIm[0]+i+1][0]-im[j*dimIm[0]+i][0];
        }
        d[j*dimIm[0]+dimIm[0]-1]=0;
    }
}

/*partial derivative 2*/
void drond2f2r(fftw_complex *im, int *dimIm, double *d){
    int i, j;
    for(i=0;i<dimIm[0];i++){
        for(j=0;j<dimIm[1]-1;j++){
            d[j*dimIm[0]+i]=im[(j+1)*dimIm[0]+i][0]-im[j*dimIm[0]+i][0];
        }
        d[(dimIm[1]-1)*dimIm[0]+i]=0;
    }
}

/* transpose of partial derivative 1*/
void drond1Tf2r(fftw_complex *im, int *dimIm, double *d){
    int i, j;
    for(j=0;j<dimIm[1];j++){
        d[j*dimIm[0]+dimIm[0]-1]=im[j*dimIm[0]+dimIm[0]-2][0];
        for(i=dimIm[0]-2;i>0;i--){
            d[j*dimIm[0]+i]=im[j*dimIm[0]+i-1][0]-im[j*dimIm[0]+i][0];
        }
        d[j*dimIm[0]]=-im[j*dimIm[0]][0];
    }
}

/* transpose of partial derivative 1*/
void drond2Tf2r(fftw_complex *im, int *dimIm, double *d){
    int i, j;
    for(i=0;i<dimIm[0];i++){
        d[(dimIm[1]-1)*dimIm[0]+i]=im[(dimIm[1]-2)*dimIm[0]+i][0];
        for(j=dimIm[1]-2;j>0;j--){
            d[j*dimIm[0]+i]=im[(j-1)*dimIm[0]+i][0]-im[j*dimIm[0]+i][0];
        }
        d[i]=-im[i][0];
    }
}

/*returns the square modulus of a1*/
void module2(fftw_complex *a1, double *a2, int taille){
    int i;
    for (i=0;i<taille;++i){
        a2[i]=a1[i][0]*a1[i][0]+a1[i][1]*a1[i][1];
    }
}

void DispArray(double *u,int *dim){
    int i,j;
    
    for (i=0;i<dim[0];++i){
        for (j=0;j<dim[1];++j){
            mexPrintf("%1.2e     ",u[i+j*dim[0]]);
        }
        mexPrintf("\n");
    }
    mexPrintf("\n");
    
}

void DispArrayf(fftw_complex *u,int *dim){
    int i,j;
    
    for (i=0;i<dim[0];++i){
        for (j=0;j<dim[1];++j){
            mexPrintf("%1.2e %1.2ei     ",u[i+j*dim[0]][0],u[i+j*dim[0]][1]);
        }
        mexPrintf("\n");
    }
    mexPrintf("\n");
}

void somme(double *a, double *b, double *c, int taille){
    int i;
    for (i=0;i<taille;i++){c[i]=a[i]+b[i];}
}

void sommef(fftw_complex *a, fftw_complex *b, fftw_complex *c, int taille){
    int i;
    for (i=0;i<taille;i++){
        c[i][0]=a[i][0]+b[i][0];
        c[i][1]=a[i][1]+b[i][1];
    }
}

void sommerfr(double *a, fftw_complex *b, double *c, int taille){
    int i;
    for (i=0;i<taille;i++){c[i]=a[i]+b[i][0];}
}

void sommerrf(double *a, double  *b, fftw_complex*c, int taille){
    int i;
    for (i=0;i<taille;i++){
        c[i][0]=a[i]+b[i];
        c[i][1]=0;
    }
}

void soustraction(double *a, double *b, double *c, int taille){
    int i;
    for (i=0;i<taille;i++){c[i]=a[i]-b[i];}
}

void soustractionf(fftw_complex *a, fftw_complex *b, fftw_complex *c, int taille){
    int i;
    for (i=0;i<taille;i++){c[i][0]=a[i][0]-b[i][0];c[i][1]=a[i][1]-b[i][1];}
}

double norm2(double * a, int taille){
    int i;
    double res=0;
    for(i=0;i<taille;i++){
        res+=a[i]*a[i];
    }
    return res;
}

void assignation(double * a, double * b, int taille){
    int i;
    for(i=0;i<taille;i++){
        a[i]=b[i];
    }
    /*memcpy (b,a,sizeof(double)*taille);*/
}

void assignationf(fftw_complex* a, fftw_complex* b, int taille){
    int i;
    for(i=0;i<taille;i++){
        a[i][0]=b[i][0];
        a[i][1]=b[i][1];
    }
    /*memcpy (b,a,sizeof(double)*taille);*/
}

void zeros(double *a, int taille){
    int i;
    for(i=0;i<taille;i++){
        a[i]=0;
    }
}

void multiplicationMatrice(double *a, double *b, double *c, int taille){
    int i;
    for(i=0;i<taille;i++)
        c[i]=a[i]*b[i];
}

void multiplicationMatricerff(double *a, fftw_complex *b, fftw_complex *c, int taille){
    int i;
    for(i=0;i<taille;i++){
        c[i][0]=a[i]*b[i][0];
        c[i][1]=a[i]*b[i][1];
    }
}

void racine(double *a, double *b, int taille){
    int i;
    for(i=0;i<taille;i++)
        b[i]=sqrt(a[i]);
}

double sommeComposantes(double *a, int taille){
    int i;
    double somme=0;
    for(i=0;i<taille;i++)
        somme+=a[i];
    return somme;
}

void division(double *a, double eps, double *b, int taille){
    int i;
    if (eps!=0){
        for(i=0;i<taille;i++)
            b[i]=a[i]/eps;
    }
    else{
        mexPrintf("Vous essayez de diviser par 0.\n");
    }
}

void divisionMatrice(double *a, double *b, double *c, int taille){
    int i;
    
    for(i=0;i<taille;i++)
        if (b[i]!=0){
        c[i]=a[i]/b[i];
        }
        else{
        mexPrintf("Vous essayez de faire une division par 0.\n");
        c[i]=INFINITY;
        }
}

/*compare les elements de a et de b et met le resultat dans a*/
void comparaisonMin(double *a, double *b, int taille){
    int i;
    for(i=0;i<taille;i++){
        if(a[i]>b[i])
            a[i]=b[i];
    }
}

void comparaisonMax(double *a, double *b, int taille){
    int i;
    for(i=0;i<taille;i++){
        if(a[i]<b[i])
            a[i]=b[i];
    }
}

void comparaisonMinScalaire(double *a, double b, int taille){
    int i;
    for(i=0;i<taille;i++){
        if(a[i]>b)
            a[i]=b;
    }
}

void multiplicationScalaire(double *a, double multi, double *b, int taille){
    int i;
    for(i=0;i<taille;i++)
        b[i]=multi*a[i];
}

void multiplicationScalairef(fftw_complex *a, double multi, fftw_complex *b, int taille){
    int i;
    for(i=0;i<taille;i++){
        b[i][0]=multi*a[i][0];
        b[i][1]=multi*a[i][1];
    }
}

void matriceAbs(double *a, double *b, int taille){
    int i;
    for(i=0;i<taille;i++){
        b[i]=fabs(a[i]);
    }
}

/* FIN DES FONCTIONS INDEPENDANTES*/
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    /** --------------------------------------------------------------------------------------------------------------------
     *
     * INITIALIZATIONS (MEMORY ALLOCATION + COPY OF MATLAB VARIABLES)
     *
     * --------------------------------------------------------------------------------------------------------------------**/
    /*Input variables are in the order u0,gabor,eps,p,alpha,nit,prec,contrainte*/
    /* input variable*/
    double *pu0; /*pointer on the matlab image*/
    double *pgabor; /*pointer on the matlab filters*/
    double eps; /* TV regularisation parameter */
    double *p;	/*kind of norm used {1,2,3 (pour inf)}*/
    double *alpha;/* weight for phi, phi_star ...*/
    int nit;
    double prec; /* precision*/
    double contrainte; /* L infinite constraint on lambda*/
    double gamma;
    /*double *EstP, *EstD; /* optional parameters which are estimates of the primal.*/
    
    /*Variables used for converting Matlab vars into fftw_complex*/
    fftw_complex *u0; /* image u0*/
    fftw_complex **gabor;/* gabor filters : size m*/
    
    /* output variables */
    double *u;
    double *Gap, *Primal, *Dual; /* arrays of size nit, containing Gap, and Primal and Dual costs*/
    double *EstP,*EstD;
    
    /*other variables*/
    fftw_plan plan;
    int i, j, k, l,allp2;
    int cinq=5;
    double undemi=0.5;
    int dim[3]; /* image dimensions */
    int m; /* filter number*/
    double ngu,tmp1,tmp2,tmp3;
    double Fstar, Gstar;
    double Clambda;
    double MAXVAL;
    
    /* intern variables */
    fftw_complex **lambda; /* primal and dual variables*/
    fftw_complex **fgabor; /*All Fourier transforms of Gabor functions*/
    fftw_complex **Astarq; /*Temporary variables*/
    fftw_complex **lambdab, **lambdau; /*Memory of lambda*/
    fftw_complex *temp1; /*temporary variables to perform convolutions*/
    fftw_complex *temp2;
    fftw_complex *temp3;
    
    double *gu1, *gu2, *gu01, *gu02, *bruit; /*gradient of u (d1 d2), gradient of u0, noise*/
    double *qq1, *qq2; /*temporary variables to compute nqq*/
    double *nqq1, *nqq2; /* Gradient norms - computation of Fstar*/
    double *qtilde1, *qtilde2; /*Temporary variable to compute nqq...*/
    double **metricM, *metricN; /*Define the metrics M N*/
    double *q1, *q2;
    double tau;
    double sigma;
    double theta;
    double mu;
    double L; /*operator norm*/
    double weight; /*weight to balance primal and dual iterations*/
    
    /* check for proper input */
    switch(nrhs) {
        case 8 : /*mexPrintf("Good call.\n");*/
            break;
        default: mexErrMsgTxt("Bad number of inputs.\n");
        break;
    }
    if (nlhs > 6) {mexErrMsgTxt("Too many outputs.\n");}
    
    /*Input arguments are in the order*/
    /*u0,gabor,eps,p,alpha,nit,prec,contrainte*/
    dim[0]=mxGetM(prhs[0]);
    dim[1]=mxGetN(prhs[0]);
    dim[2]=mxGetN(prhs[2]);
    m=dim[2];
    
    pu0=mxGetPr(prhs[0]);
    eps=(*mxGetPr(prhs[1]));
    p=mxGetPr(prhs[2]);
    pgabor=mxGetPr(prhs[3]);
    alpha=mxGetPr(prhs[4]);
    nit=(int)*mxGetPr(prhs[5]);
    prec=*mxGetPr(prhs[6]);
    contrainte=*mxGetPr(prhs[7]);
    
    /*output arguments*/
    plhs[0] = mxCreateDoubleMatrix(dim[0], dim[1] , mxREAL);
    plhs[1] = mxCreateDoubleMatrix(nit,1 , mxREAL);
    plhs[2] = mxCreateDoubleMatrix(nit,1 , mxREAL);
    plhs[3] = mxCreateDoubleMatrix(nit,1 , mxREAL);
    plhs[4] = mxCreateNumericArray(3,dim,mxDOUBLE_CLASS,mxREAL);
    dim[2]=2;
    plhs[5] = mxCreateNumericArray(3,dim,mxDOUBLE_CLASS,mxREAL);
    dim[2]=m;
    
    u=mxGetPr(plhs[0]);
    Gap=mxGetPr(plhs[1]);
    Primal=mxGetPr(plhs[2]);
    Dual=mxGetPr(plhs[3]);
    EstP=mxGetPr(plhs[4]);
    EstD=mxGetPr(plhs[5]);
    
    /*Memory allocation*/
    u0= (fftw_complex*) fftw_malloc(sizeof(fftw_complex)*dim[0]*dim[1]);
    temp1= (fftw_complex*) fftw_malloc(sizeof(fftw_complex)*dim[0]*dim[1]);
    temp2= (fftw_complex*) fftw_malloc(sizeof(fftw_complex)*dim[0]*dim[1]);
    temp3= (fftw_complex*) fftw_malloc(sizeof(fftw_complex)*dim[0]*dim[1]);
    
    gabor=(fftw_complex**) fftw_malloc(sizeof(fftw_complex*)*m);
    lambda=(fftw_complex**) fftw_malloc(sizeof(fftw_complex*)*m);
    fgabor=(fftw_complex**) fftw_malloc(sizeof(fftw_complex*)*m);
    Astarq=(fftw_complex**) fftw_malloc(sizeof(fftw_complex*)*m);
    lambdab=(fftw_complex**) fftw_malloc(sizeof(fftw_complex*)*m);
    lambdau=(fftw_complex**) fftw_malloc(sizeof(fftw_complex*)*m);
    metricM=(double**) mxMalloc(sizeof(double*)*m);
    for (i=0;i<m;++i){
        gabor[i]=(fftw_complex*) fftw_malloc(sizeof(fftw_complex)*dim[0]*dim[1]);
        lambda[i]=(fftw_complex*) fftw_malloc(sizeof(fftw_complex)*dim[0]*dim[1]);
        fgabor[i]=(fftw_complex*) fftw_malloc(sizeof(fftw_complex)*dim[0]*dim[1]);
        Astarq[i]=(fftw_complex*) fftw_malloc(sizeof(fftw_complex)*dim[0]*dim[1]);
        lambdab[i]=(fftw_complex*) fftw_malloc(sizeof(fftw_complex)*dim[0]*dim[1]);
        lambdau[i]=(fftw_complex*) fftw_malloc(sizeof(fftw_complex)*dim[0]*dim[1]);
        metricM[i]=(double*) mxMalloc(sizeof(double)*dim[0]*dim[1]);
    }
    
    gu1=mxMalloc(dim[0]*dim[1]*sizeof(double));
    gu2=mxMalloc(dim[0]*dim[1]*sizeof(double));
    gu01=mxMalloc(dim[0]*dim[1]*sizeof(double));
    gu02=mxMalloc(dim[0]*dim[1]*sizeof(double));
    bruit=mxMalloc(dim[0]*dim[1]*sizeof(double));
    qq1=mxMalloc(dim[0]*dim[1]*sizeof(double));
    qq2=mxMalloc(dim[0]*dim[1]*sizeof(double));
    nqq1=mxMalloc(dim[0]*dim[1]*sizeof(double));
    nqq2=mxMalloc(dim[0]*dim[1]*sizeof(double));
    qtilde1=mxMalloc(dim[0]*dim[1]*sizeof(double));
    qtilde2=mxMalloc(dim[0]*dim[1]*sizeof(double));
    q1=mxMalloc(dim[0]*dim[1]*sizeof(double));
    q2=mxMalloc(dim[0]*dim[1]*sizeof(double));
    metricN=mxMalloc(dim[0]*dim[1]*sizeof(double));
    
    /* initialisation*/
    j=0;
    k=0;
    l=0;
    ngu=0;
    Fstar=0;
    Gstar=0;
    Clambda=0;
    tau=0; /*???*/
    sigma=0; /*???*/
    theta=0; /*???*/
    L=0; /*???*/
    weight=0; /*???*/
    MAXVAL=100000;
    
    allp2=0;
    for (i=0;i<m;++i){
        if (p[i]==2) allp2++;
    }
    allp2=(allp2==m?1:0);
    
    /*mexPrintf("m:%i - allp2: %i - eps: %1.5f - p:%1.1f - alpha:%1.5f - maxit:%i - prec:%1.5f \n", m,allp2,eps,p[0],alpha[0],nit,prec);*/

    /*initializes array to 0*/
    for(i=0;i<nit;i++){
        Gap[i]=0;
        Primal[i]=0;
        Dual[i]=0;
    }
    
    /*casts Matlab Gabor filters in the correct data type*/
    for (j=0;j<m;++j){
        for (i=0;i<dim[0]*dim[1];++i){
            k=i+j*dim[0]*dim[1];
            gabor[j][i][0]=pgabor[k];
            gabor[j][i][1]=0.0;
            lambdab[j][i][0]=0.0; /*[C] initialisation of primal -- could be user defined -- change here*/
            lambdab[j][i][1]=0.0;
            lambdau[j][i][0]=0.0;
            lambdau[j][i][1]=0.0;
            lambda[j][i][0]=0.0;
            lambda[j][i][1]=0.0;
            Astarq[j][i][0]=0;
            Astarq[j][i][1]=0;
            metricM[j][i]=1.0f;
        }
    }
    
    for(i=0;i<dim[0]*dim[1];i++){
        u0[i][0]=pu0[i]; /*retrieves Matlab data and cast it to fftw_complex*/
        u0[i][1]=0;
        u[i]=0;
        metricN[i]=1.0f;
        bruit[i]=0;
        gu1[i]=0;
        gu2[i]=0;
        q1[i]=0;  /*[C] initialisation of dual -- could be user defined -- change here*/
        q2[i]=0;
        qq1[i]=0;
        qq2[i]=0;
        nqq1[i]=0;
        nqq2[i]=0;
        qtilde1[i]=0;
        qtilde2[i]=0;
        temp1[i][0]=0.0;
        temp2[i][0]=0.0;
        temp3[i][0]=0.0;
        temp1[i][1]=0.0;
        temp2[i][1]=0.0;
        temp3[i][1]=0.0;
        
    }
    
    /** --------------------------------------------------------------------------------------------------------------------
     *
     *                  MAIN ALGORITHM
     * --------------------------------------------------------------------------------------------------------------------*/
    
    /*computation of the gradient of u0*/
    drond1f2r(u0, dim, gu01);
    drond2f2r(u0, dim, gu02);
    
    /*Computes Fourier transforms of Gabor filters*/
    for(i=0;i<m;i++){
        plan=fftw_plan_dft_2d(dim[1], dim[0], gabor[i], fgabor[i], FFTW_FORWARD, FFTW_ESTIMATE);
        fftw_execute(plan);
        fftw_destroy_plan(plan);
    }
    
    /** --------------------------------------------------------------------------------------------------------------------
     *
     *       INITIALISATION OF VARIABLES (COMPUTATION OF INITIAL PD INITIAL COST + LIPSCHITZ CONSTANT)
     *
     * --------------------------------------------------------------------------------------------------------------------**/
    
    /*First computes the initial duality gap.*/
    for(i=0;i<m;i++){
        /*convolution of lambda with gabor, result in temp1 -- Alambda*/
        convolution(dim[1], dim[0], lambda[i], fgabor[i], temp1, temp2, temp3);
        sommerfr(bruit, temp1, bruit, dim[0]*dim[1]);
    }
    
    /*Current estimate of the denoised image*/
    sommerfr(bruit,u0, u, dim[0]*dim[1]);
    
    /*Computation of the primal cost*/
    drond1(u, dim, gu1);
    drond2(u, dim, gu2);
    
    if (eps==0){
        ngu=0;
        for (i=0;i<dim[0]*dim[1];++i){
            ngu+=sqrt(gu1[i]*gu1[i]+gu2[i]*gu2[i]);
        }
    }
    else if (eps>0){
        ngu=0;
        for (i=0;i<dim[0]*dim[1];++i){
            tmp1=(gu1[i]*gu1[i]+gu2[i]*gu2[i]);
            ngu+=MIN(tmp1/eps,sqrt(tmp1))-0.5*MIN(tmp1/eps,eps);
        }
    }
    
    for (i=0;i<m;i++){
        Clambda+=Phi(lambdab[i], dim, p[i], alpha[i]);
    }
    Primal[0]=ngu+Clambda;
    
    /*Computation of the dual cost*/
    drond1T(q1, dim, qq1);/* qq[1]=dront1T(q(:,:,1)*/
    drond2T(q2, dim, qq2);/* qq[2]=dront2T(q(:,:,2)*/
    sommerrf(qq1, qq2, temp1, dim[0]*dim[1]);
    
    plan= fftw_plan_dft_2d(dim[1], dim[0], temp1, temp2, FFTW_FORWARD, FFTW_ESTIMATE); /*temp2=fft2(temp1)*/
    fftw_execute(plan);
    fftw_destroy_plan(plan);
    
    Gstar=0.0;
    for (i=0;i<m;i++){
        fconvolutionT(dim[1], dim[0], temp2, fgabor[i], Astarq[i], temp3); /*Astarq[i]=convolutionT(temp2,fgabor[i])*/
        multiplicationScalairef(Astarq[i], -1.0, Astarq[i], dim[0]*dim[1]); /*Aq*=-Aq**/
        multiplicationMatricerff(metricM[i], Astarq[i], Astarq[i], dim[0]*dim[1]); /*Aq*=M.*Aq**/
        Gstar=Gstar+PhiStar(Astarq[i], dim[0]*dim[1], p[i], contrainte, alpha[i]);
    }
    
    /*Computation of Fstar=F*(q)*/
    multiplicationMatrice(q1, metricN, qq1, dim[0]*dim[1]); /*qq1=q1*N*/
    multiplicationMatrice(q2, metricN, qq2, dim[0]*dim[1]); /*qq2=q2*N*/
    multiplicationMatrice(qq1, qq1, nqq1, dim[0]*dim[1]); /*nqq1=qq1*qq1*/
    multiplicationMatrice(qq2, qq2, nqq2, dim[0]*dim[1]); /*nqq2=qq2*qq2*/
    somme(nqq1, nqq2, nqq1, dim[0]*dim[1]); /* nqq1 contient nqq1+nqq2*/
    racine(nqq1, nqq1, dim[0]*dim[1]); /*nqq1 contient sqrt(nqq1)*/
    
    if (maxi(nqq1, dim)>1+EPSILON)
        Fstar=INFINITY;
    else{
        multiplicationMatrice(nqq1, nqq1, nqq2, dim[0]*dim[1]); /*nqq2=nqq1.*nqq1*/
        Fstar=eps*undemi*sommeComposantes(nqq2, dim[0]*dim[1]);
        multiplicationMatrice(gu01, qq1, nqq1, dim[0]*dim[1]); /*nqq1=gu01.*qq1*/
        multiplicationMatrice(gu02, qq2, nqq2, dim[0]*dim[1]); /*nqq2=gu02.*qq2*/
        Fstar=Fstar-sommeComposantes(nqq1, dim[0]*dim[1])-sommeComposantes(nqq2, dim[0]*dim[1]);
    }
    
    Dual[0]=-Fstar-Gstar;
    mexPrintf("Primal0 : %1.5f -- Dual0 :%1.5f\n", Primal[0], Dual[0]);
    
    Gap[0]=Primal[0]-Dual[0];
    
    /*Computation of the largest singular value of A -- A mettre en param entree ?*/
    /* VALIDATED*/
    temp1[0][0]=-1;
    temp1[dim[0]-1][0]=1;
    temp2[0][0]=-1;
    temp2[dim[0]*(dim[1]-1)][0]=1;
    plan=fftw_plan_dft_2d(dim[1], dim[0], temp1, temp1, FFTW_FORWARD, FFTW_ESTIMATE);
    fftw_execute(plan);
    fftw_destroy_plan(plan);
    plan=fftw_plan_dft_2d(dim[1], dim[0], temp2, temp2, FFTW_FORWARD, FFTW_ESTIMATE);
    fftw_execute(plan);
    fftw_destroy_plan(plan);
    zeros(bruit, dim[0]*dim[1]);
    for(i=0;i<m;i++){
        module2(fgabor[i], gu1, dim[0]*dim[1]);
        somme(bruit, gu1, bruit, dim[0]*dim[1]);
    }
    
    module2(temp1, nqq1, dim[0]*dim[1]);
    module2(temp2, nqq2, dim[0]*dim[1]);
    somme(nqq1, nqq2, gu1, dim[0]*dim[1]);
    multiplicationMatrice(bruit, gu1, bruit, dim[0]*dim[1]);
    L=sqrt(maxi(bruit,dim));
    
    Gap[1]=MAXVAL;
    
    gamma=mini(alpha, m);
    weight=1.0f;
    tau=weight/L;
    sigma=1.0f/(tau*L*L);
    theta=1.0f;
    /*mexPrintf("nx : %i -- ny : %i -- m : %i -- L : %1.5f -- weight:%1.5f -- Tau: %1.5f -- Sigma:%1.5f -- Gamma: %1.5f -- Theta : %1.5f\n", dim[0],dim[1],m,L, weight, tau, sigma, gamma, theta);*/
    
    
    /** --------------------------------------------------------------------------------------------------------------------
     *
     *  MAIN LOOP IN THE ALGORITHM
     *
     * --------------------------------------------------------------------------------------------------------------------**/
    
    /*  The actual algorithm*/
    for (j=1; j<nit; j++){
        /* I.1/ q_{n+1}=(I+sigma partial F^*)^{-1}(q_n+sigma A _n)*/
        /*     Computation of the convolutions with lambdab_n*/
        /*VALIDATED*/
        zeros(bruit, dim[0]*dim[1]);
        
        for (i=0;i<dim[0]*dim[1];++i){
            temp1[i][0]=0;
            temp2[i][0]=0;
            temp3[i][0]=0;
            temp1[i][1]=0;
            temp2[i][1]=0;
            temp3[i][1]=0;
        }
        
        for(i=0;i<m;i++){
            convolution(dim[0], dim[1], lambdab[i], fgabor[i], temp1, temp2, temp3);
            
            /*if (j==1){
             * mexPrintf("lambdab:\n ");
             * DispArrayf(lambdab[0],dim);
             * mexPrintf("fgabor:\n ");
             * DispArrayf(fgabor[0],dim);
             * mexPrintf("temp1:\n ");
             * DispArrayf(temp1,dim);
             * }*/
            
            sommerfr(bruit, temp1, bruit, dim[0]*dim[1]);
        }
        sommerfr(bruit,u0, u, dim[0]*dim[1]);
        
        /*mexPrintf("u : %1.2e\n",sigma);
         * DispArray(u,dim);*/
        
        /*Gradient (corresponds to tilde q_n in the article)*/
        drond1(u, dim, gu1);
        drond2(u, dim, gu2);
        multiplicationScalaire(gu1, sigma, qtilde1, dim[0]*dim[1]); /*qtilde1=sigma*gu1*/
        multiplicationScalaire(gu2, sigma, qtilde2, dim[0]*dim[1]); /*qtilde2=sigma*gu2*/
        
        /*mexPrintf("Sigma : %1.2e\n",sigma);
         * mexPrintf("sigma gu1 :\n ");
         * DispArray(qtilde1,dim);
         * mexPrintf("sigma gu2 :\n ");
         * DispArray(qtilde2,dim);*/
        
        somme(qtilde1, q1, qtilde1, dim[0]*dim[1]); /*qtilde1=q1+sigma*gu1*/
        somme(qtilde2, q2, qtilde2, dim[0]*dim[1]); /*qtilde2=q2+sigma*gu2*/
        
        /*Resolvent operator...*/
        multiplicationMatrice(qtilde1,qtilde1,nqq1,dim[0]*dim[1]); /*nqq1=qtilde1*qtilde1*/
        multiplicationMatrice(qtilde2, qtilde2, nqq2, dim[0]*dim[1]); /*nqq2=qtilde2*qtilde2*/
        somme(nqq1, nqq2, nqq1, dim[0]*dim[1]); /* nqq1 contient nqq1+nqq2*/
        racine(nqq1, nqq1, dim[0]*dim[1]); /*nqq1 contient sqrt(nqq1)*/
        multiplicationMatrice(nqq1, metricN, nqq1, dim[0]*dim[1]); /*nqq1=nqq1.*N*/
        multiplicationScalaire(metricN, eps*sigma, nqq2, dim[0]*dim[1]);
        for (i=0;i<dim[0]*dim[1];++i){nqq2[i]+=1.0;}
        comparaisonMax(nqq1, nqq2, dim[0]*dim[1]);/* max dans nqq1*/
        divisionMatrice(qtilde1, nqq1, q1, dim[0]*dim[1]);
        divisionMatrice(qtilde2, nqq1, q2, dim[0]*dim[1]);
        
        /*mexPrintf("q1 :\n ");
         * DispArray(q1,dim);
         * mexPrintf("q2 :\n ");
         * DispArray(q2,dim);*/
        
        /* II.1/ lambda_{n+1}=(I+tau partial G)^{-1}(lambda_{n+1}-tau A^*q_{n+1})*/
        /*Computation of ATq_{n+1}*/
        /*VALIDATED*/
        multiplicationMatrice(q1, metricN, qq1, dim[0]*dim[1]); /*qq1=q1.*N*/
        multiplicationMatrice(q2, metricN, qq2, dim[0]*dim[1]); /*qq2=q2.*N*/
        drond1T(qq1, dim, qq1);/* qq[1]=dront1T(q(:,:,1)*/
        drond2T(qq2, dim, qq2);/* qq[2]=dront2T(q(:,:,2)*/
        
        
        /*mexPrintf("qq1 :\n ");
         * DispArray(qq1,dim);
         * mexPrintf("qq2 :\n ");
         * DispArray(qq2,dim);*/
        
        sommerrf(qq1, qq2, temp1, dim[0]*dim[1]);
        /*mexPrintf("q1:\n ");
         * DispArray(q1,dim);*/
        /*mexPrintf("qq1:\n ");
         * DispArray(qq1,dim);
         * mexPrintf("qq2:\n ");
         * DispArray(qq2,dim);*/
        
        plan=fftw_plan_dft_2d(dim[1], dim[0], temp1, temp2, FFTW_FORWARD, FFTW_ESTIMATE);
        fftw_execute(plan);
        fftw_destroy_plan(plan);
        
        for(i=0;i<m;i++){
            /*mexPrintf("temp2 :\n ");
             * DispArrayf(temp2,dim);/*
             * mexPrintf("fgabor :\n ");
             * DispArrayf(fgabor[0],dim);*/
            
            fconvolutionT(dim[0], dim[1], temp2, fgabor[i], Astarq[i], temp3); /*Astarq[i]=convolutionT(temp2,fgabor[i])*/
            
            /*mexPrintf("Astarq :\n ");
             * DispArrayf(Astarq[0],dim);*/
            
            /*[C] multiplicationMatricerff(Astarq[i], metricN, Astarq[i], dim[0]*dim[1]);*/
            multiplicationScalairef(Astarq[i],  -tau, lambdau[i], dim[0]*dim[1]);
            sommef(lambda[i], lambdau[i], lambdau[i], dim[0]*dim[1]);
        }
        
        /*Computation of the resolvent of (I+tau partial G)^{-1}*/
        for(i=0;i<m;i++){
            ProxPhi(lambdau[i], dim[0]*dim[1], p[i], metricM[i], tau, contrainte, alpha[i], lambdau[i]);
        }
        
        /*mexPrintf("lambdau :\n ");
         * DispArrayf(lambdau[0],dim);*/
        
        /*__________________________________
         * /* III/ Step size update (TO BE DONE)*/
        if (allp2){
            if (eps>0){
                mu=2.0*sqrt(gamma*eps)/L;
                tau=mu/gamma;
                sigma=mu/(2*eps);
                theta=1.0/(1.0+mu);
            }
            else{
                theta=1/sqrt(1+2*gamma*tau);
                tau=theta*tau;
                sigma=sigma/theta;
            }
        }
        
        /* IV/ Correction bar x^{n+1}=x^{n+1}+theta(x^{n+1}-x^n)*/
        /*VALIDATED*/
        for(i=0;i<m;i++){
            soustractionf(lambdau[i], lambda[i], lambdab[i], dim[0]*dim[1]); /*lambdab=lambdau-lambda;*/
            multiplicationScalairef(lambdab[i],  theta, lambdab[i], dim[0]*dim[1]); /*lambdab=theta*(lambdau-lambda);*/
            sommef(lambdab[i], lambdau[i], lambdab[i], dim[0]*dim[1]); /*lambdab=lambdau+theta*(lambdau-lambda);*/
            assignationf(lambda[i], lambdau[i], dim[0]*dim[1]); /*lambda=lambdau;*/
        }
        
        /*mexPrintf("lambda :\n ");
         * DispArrayf(lambda[0],dim);*/
        
        /* V/ computation of the cost function */
        if(j%10==0){
            drond1(u, dim, gu1);
            drond2(u, dim, gu2);
            /* Computation of the primal cost*/
            /*VALIDATED*/
            if (eps==0){
                multiplicationMatrice(gu1, gu1, gu1, dim[0]*dim[1]);
                multiplicationMatrice(gu2, gu2, gu2, dim[0]*dim[1]);
                somme(gu1, gu2, gu1, dim[0]*dim[1]); /* gu1 contient gu1+gu2*/
                racine(gu1, gu1, dim[0]*dim[1]);
                ngu=sommeComposantes(gu1, dim[0]*dim[1]);
                /*mexPrintf("ngu:%1.4e \n",ngu);*/
            }
            else if (eps>0){
                multiplicationMatrice(gu1, gu1, gu1, dim[0]*dim[1]);
                multiplicationMatrice(gu2, gu2, gu2, dim[0]*dim[1]);
                somme(gu1, gu2, gu1, dim[0]*dim[1]); /* gu1 contient gu1+gu2=ngu*/
                division(gu1, eps, gu2, dim[0]*dim[1]); /* gu2 contient ngu/eps*/
                racine(gu1, gu1, dim[0]*dim[1]); /* gu1 contient sqrt(ngu)*/
                comparaisonMin(gu1, gu2, dim[0]*dim[1]); /* gu1 contient min(ngu/eps,sqrt(ngu)*/
                comparaisonMinScalaire(gu2, eps, dim[0]*dim[1]); /*gu2 contient min(ngu/eps,eps)*/
                multiplicationScalaire(gu2,  0.5f, gu2, dim[0]*dim[1]);
                soustraction(gu1, gu2, gu1, dim[0]*dim[1]); /* gu1 contient min(gu1)-min(gu2)*/
                ngu=sommeComposantes(gu1, dim[0]*dim[1]);
            }
            Clambda=0;
            for (i=0;i<m;i++){
                Clambda+=Phi(lambdab[i], dim, p[i], alpha[i]);
            }
            
            /*mexPrintf("lambdab:\n ");
             * DispArrayf(lambdab[0],dim);*/
            /*mexPrintf("Clambda:%1.4e \n",Clambda);*/
            Primal[j]=ngu+Clambda;
            
            /* Computation of the dual cost.*/
            /*VALIDATED*/
            Gstar=0;
            /* Computation of Gstar=G*(-A*q)*/
            for (i=0;i<m;i++){
                multiplicationScalairef(Astarq[i],  -1.0f, Astarq[i], dim[0]*dim[1]); /*Aq*=-Aq**/
                multiplicationMatricerff(metricM[i], Astarq[i], Astarq[i], dim[0]*dim[1]); /*Aq*=M.*Aq**/
                Gstar+=PhiStar(Astarq[i], dim[0]*dim[1], p[i], contrainte, alpha[i]);
            }
            /* Computation of Fstar=F*(q)*/
            multiplicationMatrice(q1, metricN, qq1, dim[0]*dim[1]); /*qq1=q1*N*/
            multiplicationMatrice(q2, metricN, qq2, dim[0]*dim[1]); /*qq2=q2*N*/
            multiplicationMatrice(qq1, qq1, nqq1, dim[0]*dim[1]); /*nqq1=qq1*qq1*/
            multiplicationMatrice(qq2, qq2, nqq2, dim[0]*dim[1]); /*nqq2=qq2*qq2*/
            somme(nqq1, nqq2, nqq1, dim[0]*dim[1]); /* nqq1 contient nqq1+nqq2*/
            racine(nqq1, nqq1, dim[0]*dim[1]); /*nqq1 contient sqrt(nqq1)*/
            if (maxi(nqq1, dim)>1+EPSILON)
                Fstar=INFINITY;
            else{
                multiplicationMatrice(nqq1, nqq1, nqq2, dim[0]*dim[1]); /*nqq2=nqq1.*nqq1*/
                Fstar=eps/2.0f*sommeComposantes(nqq2, dim[0]*dim[1]);
                multiplicationMatrice(gu01, qq1, nqq1, dim[0]*dim[1]); /*nqq1=gu01.*qq1*/
                multiplicationMatrice(gu02, qq2, nqq2, dim[0]*dim[1]); /*nqq2=gu02.*qq2*/
                Fstar=Fstar-sommeComposantes(nqq1, dim[0]*dim[1])-sommeComposantes(nqq2, dim[0]*dim[1]);
            }
            Dual[j]=-Fstar-Gstar;
            Gap[j]=Primal[j]-Dual[j];
            
            if(Gap[j]<(prec*Gap[0])){
                mexPrintf("Stopping criterion satisfied after %i iterations -- Successful\n",j);
                break;
            }
            
            /*mexPrintf("Iteration:%i -- Primal : %1.8f  -- Dual : %1.8f -- Gap : %1.8f\n",j, Primal[j],Dual[j],Gap[j]);*/
            /*mexPrintf("q1:\n ");
             * DispArray(q1,dim);
             * mexPrintf("q2:\n ");
             * DispArray(q2,dim);*/
        }
        /*mexPrintf("lambda :\n ");
         * DispArrayf(lambda[0],dim);++j
         * mexPrintf("lambdab :\n ");
         * DispArrayf(lambdab[0],dim);*/
        
    }
    
    /** --------------------------------------------------------------------------------------------------------------------
     *
     *                  COPY TO MATLAB WORKSPACE
     *
     * --------------------------------------------------------------------------------------------------------------------*/
    for (j=0;j<m;++j){
        for (i=0;i<dim[0]*dim[1];++i){
            EstP[j*dim[0]*dim[1]+i]=lambda[j][i][0];
        }
    }
    for (i=0;i<dim[0]*dim[1];++i){
        EstD[i]=q1[i];
    }
    for (i=0;i<dim[0]*dim[1];++i){
        EstD[i+dim[0]*dim[1]]=q2[i];
    }
    
    /** --------------------------------------------------------------------------------------------------------------------
     *
     *                  MEMORY DEALLOCATION
     *
     * --------------------------------------------------------------------------------------------------------------------*/
    
    
    /*Memory deallocation*/
    mxFree(gu1);
    mxFree(gu2);
    mxFree(gu01);
    mxFree(gu02);
    mxFree(bruit);
    mxFree(qq1);
    mxFree(qq2);
    mxFree(nqq1);
    mxFree(nqq2);
    mxFree(qtilde1);
    mxFree(qtilde2);
    mxFree(q1);
    mxFree(q2);
    mxFree(metricN);
    
    fftw_free(u0);
    fftw_free(temp1);
    fftw_free(temp2);
    fftw_free(temp3);
    
    for (i=0;i<m;++i){
        fftw_free(gabor[i]);
        fftw_free(lambda[i]);
        fftw_free(fgabor[i]);
        fftw_free(Astarq[i]);
        fftw_free(lambdab[i]);
        fftw_free(lambdau[i]);
        mxFree(metricM[i]);
    }
    fftw_free(gabor);
    fftw_free(lambda);
    fftw_free(fgabor);
    fftw_free(Astarq);
    fftw_free(lambdab);
    fftw_free(lambdau);
    mxFree(metricM);
    
    /*mexPrintf("fin du programme \n");*/
}