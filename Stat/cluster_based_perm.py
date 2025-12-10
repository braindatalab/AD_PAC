from functools import partial
import numpy as np
from scipy import stats as stats
import mne
from mne.stats import permutation_cluster_test
from scipy.io import loadmat
from scipy.io import savemat

data = loadmat('pac.mat')
mask = loadmat('mask.mat')

mask = mask['mask']
sigma=1e-3
#print(mask.shape)
data_AD=data['pac_AD']
data_cont=data['pac_Control']

nROI=data_cont.shape[1] # 68 regions from DK atlas
#print(nROI)
def stat_fun(*args):
    return mne.stats.ttest_ind_no_p(args[0],args[1], equal_var=False, sigma=0.0)

def stat_fun_hat(*args):
    return mne.stats.ttest_ind_no_p(args[0],args[1], equal_var=True, sigma=sigma)

cond1=data_AD
cond2=data_cont
p_threshold=0.05
n_subjects1=cond1.shape[0]
n_subjects2=cond2.shape[0]
sig_region=[]
sig_cluster=[]
sig_T=[]
sig_P_val=[]

t_threshold=stats.distributions.f.ppf(1. - p_threshold / 2.,
                                      n_subjects1 - 1, n_subjects2 - 1)
print(t_threshold)

#threshold_tfce = dict(start=0.5, step=0.2)

for r in range(0,nROI):
# perform permutation cluster test
    T,cluster,cluster_pvalues,H0=permutation_cluster_test([cond1[:,r,:,:],cond2[:,r,:,:]],n_permutations=1024,
                      t_power=1, verbose=40, threshold=t_threshold,out_type='mask',tail=0,seed=np.random.seed(0),stat_fun=stat_fun,exclude=mask)
# pick clusters p<=0.05
    for c, p_val in zip(cluster, cluster_pvalues):
        if p_val <= 0.05:
            sig_region.append(r)
            sig_cluster.append(c)
            sig_T.append(T)
            sig_P_val.append(p_val)
#print(sig_P_val)
res={"sig_T": sig_T, "sig_region":sig_region, "sig_cluster":sig_cluster,"sig_P_val":sig_P_val}
savemat("res.mat",res)
