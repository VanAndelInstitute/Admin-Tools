if [  ${#1} -gt 4 ]
then
  echo silencing rsyslog broadcast on $1
  ssh $1 /primary/vari/admin/tools/silenceSyslogOnNode/silenceSyslogOnNode.sh  
  ssh $1 systemctl restart rsyslog
fi
if [ $# -eq 0 ]
then
  sed -e '/\*\.\* \@master\:514/ s/^\*/#\*/' -i /etc/rsyslog.conf
fi

