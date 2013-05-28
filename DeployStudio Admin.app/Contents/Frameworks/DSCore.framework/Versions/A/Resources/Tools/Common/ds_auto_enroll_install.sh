#!/bin/sh

SCRIPT_NAME=`basename "${0}"`
SCRIPT_PATH=`dirname "${0}"`

echo "${SCRIPT_NAME} - v1.0 ("`date`")"

if [ ${#} -ne 1 ]
then
  echo "Command: ${SCRIPT_NAME} ${*}"
  echo "Usage: ${SCRIPT_NAME} <volume name>"
  echo "RuntimeAbortWorkflow: missing arguments!"
  exit 1
fi

if [ "${1}" = "/" ]
then
  VOLUME_PATH=/
else
  VOLUME_PATH=/Volumes/${1}
fi

if [ ! -e "${VOLUME_PATH}" ]
then
  echo "Command: ${SCRIPT_NAME} ${*}"
  echo "Usage: ${SCRIPT_NAME} <volume name>"
  echo "RuntimeAbortWorkflow: \"${VOLUME_PATH}\" volume not found!"
  exit 1
fi

if [ `sw_vers -productVersion | awk -F. '{ print $2 }'` -gt 5 ]
then
  diskutil enableOwnership "${VOLUME_PATH}"
else
  /usr/sbin/vsdbutil -a "${VOLUME_PATH}"
fi

"${SCRIPT_PATH}"/ds_finalize_install.sh "${1}"

cp "${SCRIPT_PATH}"/ds_auto_enroll/ds_auto_enroll.sh "${VOLUME_PATH}"/etc/deploystudio/bin/ds_auto_enroll.sh
	
chmod 700 "${VOLUME_PATH}"/etc/deploystudio/bin/ds_auto_enroll.sh
chown root:wheel "${VOLUME_PATH}"/etc/deploystudio/bin/ds_auto_enroll.sh

echo "${SCRIPT_NAME} - end"

exit 0
