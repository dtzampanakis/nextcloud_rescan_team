#!/bin/bash

if [ `ps -aux|grep scanteam|wc -l` -eq 3 ]; then
exit 20
fi

exit 1
