#!/bin/bash

pgrep "mmfs" | while read PID; do echo -17 > /proc/$PID/oom_adj; done

