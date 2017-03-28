predmos = textread('/Users/rwa56/project/videocodec/deepQA/datasets/predict.txt','%f');

mos = textread('/Users/rwa56/Downloads/tid2013/mos.txt','%f');
mos2 = mos ./ 10;
[srocc,krocc,plcc,rmse] = verify_performance(mos,predmos)