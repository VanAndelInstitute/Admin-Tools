#!/bin/bash

chmod 1777 /cm/local/apps/torque/var/spool/spool
chmod 1777 /cm/local/apps/torque/var/spool/undelivered
systemctl is-active --quiet torque_mom && exit
systemctl restart torque_mom
