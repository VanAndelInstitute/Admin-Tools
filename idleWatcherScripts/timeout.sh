if [ -v PBS_JOBID ]
then
	TMOUT=300
	readonly TMOUT
	export TMOUT
fi
