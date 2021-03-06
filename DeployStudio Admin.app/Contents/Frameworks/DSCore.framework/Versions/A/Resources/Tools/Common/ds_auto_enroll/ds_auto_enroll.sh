#!/bin/sh

# disable history characters
histchars=

SCRIPT_NAME=`/usr/bin/basename "${0}"`

echo "${SCRIPT_NAME} - v1.0 ("`date`")"

SSL_FILE=`echo "${0}" | sed s/\.sh$/_ssl\.mobileconfig/`
BOOTSTRAP_FILE=`echo "${0}" | sed s/\.sh$/_bootstrap\.mobileconfig/`

#
# Import trust profile first
#
if [ -e "${SSL_FILE}" ]
then
  profiles -I -F "${SSL_FILE}"
fi

#
# Import enrollment profile
#
if [ -e "${BOOTSTRAP_FILE}" ]
then
  profiles -I -F "${BOOTSTRAP_FILE}"
  if [ ${?} -ne 0 ]
  then
    echo "Auto enrollment failed, will retry on next boot!"
    exit 1
  fi
fi

#
# Self removal
#
/usr/bin/srm -mf "${0}"

exit 0