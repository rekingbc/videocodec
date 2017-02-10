我使用的12种算法：
FSIM
FSIMc
MSSIM
PSNR
PSNRc
PSNRHA
PSNRHMA
PSNRHVS
SSIM
VSNR
VSI
MAD

FSIM&FSIMc区别在于FSIMc有考虑颜色；
MSSIM PSNR SSIM VSNR 通过 metrix_mux_1.1 获得
 metrix_mux_1.1 算法一共包括
%%%             mean-squared error              'MSE'            1
%%%             peak signal-to-noise ratio      'PSNR'           2
%%%             structural similarity index     'SSIM'           3
%%%             multiscale SSIM index           'MSSIM'          4
%%%             visual signal-to-noise ratio    'VSNR'           5
%%%             visual information fidelity     'VIF'            6
%%%             pixel-based VIF                 'VIFP'           7
%%%             universal quality index         'UQI'            8
%%%             image fidelity criterion        'IFC'            9
%%%             noise quality measure           'NQM'            10
%%%             weighted signal-to-noise ratio  'WSNR'           11
%%%             signal-to-noise ratio           'SNR'            12

PSNR和PSNRc的区别也在于颜色的考虑；

