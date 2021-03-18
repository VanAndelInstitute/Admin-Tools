if [ -L /home ]; then
    echo "home linked"
    exit 0
fi
if [ -d /home/zack.ramjan ]; then
    echo "homedir present"
    exit 0
fi
if [ ! -d /varidata/research/home/zack.ramjan ]; then
    echo "gpfs homedir not present"
    exit 1
fi
cd /
rmdir home
ln -s /varidata/research/home

