if [  ${#1} -gt 4 ]
then
  echo unsilencing rsyslog broadcast on $1
  ssh $1 /primary/vari/admin/tools/silenceSyslogOnNode/unsilenceSyslogOnNode.sh  
fi
if [ $# -eq 0 ]
then
  sed -e '/^\#\*\.\* \@master\:514/ s/^#//' -i /etc/rsyslog.conf
fi

