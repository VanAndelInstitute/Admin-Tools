cd /var/mmfs
if [ -d mmsysmon ]; then
  echo "dir exists!"
  exit 0
fi

tar -xvf /varidata/research/admin/tools/fix_mmsysmon/mmsysmon.tar
