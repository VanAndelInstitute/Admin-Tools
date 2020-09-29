#!/bin/bash

chmod 1777 /cm/local/apps/torque/var/spool/spool
chmod 1777 /cm/local/apps/torque/var/spool/undelivered
systemctl restart torque_mom
