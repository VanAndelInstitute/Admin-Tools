#PBS -l nodes=1
#PBS -l ppn=40
#PBS -l walltime=480:00:00

cd /primary/vari/admin/tools/cryoRecycler
./recycler.pl /primary/instruments/cryoem/arctica/ /secondary/instruments/cryoem/arctica/
