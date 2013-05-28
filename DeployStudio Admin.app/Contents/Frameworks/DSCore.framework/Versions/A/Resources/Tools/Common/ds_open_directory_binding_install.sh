#!/bin/sh

SCRIPT_NAME=`basename "${0}"`
SCRIPT_PATH=`dirname "${0}"`

echo "${SCRIPT_NAME} - v1.10 ("`date`")"

if [ ${#} -lt 1 ]
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

if [ ! -e "${VOLUME_PATH}"/etc/deploystudio/bin/ds_open_directory_binding.plist ]
then
  echo "Command: ${SCRIPT_NAME} ${*}"
  echo "Usage: ${SCRIPT_NAME} <volume name>"
  echo "RuntimeAbortWorkflow: \"${VOLUME_PATH}/etc/deploystudio/bin/ds_open_directory_binding.plist\" configuration file not found!"
  exit 1
else
  chmod 600 "${VOLUME_PATH}"/etc/deploystudio/bin/ds_open_directory_binding.plist
  chown root:wheel "${VOLUME_PATH}"/etc/deploystudio/bin/ds_open_directory_binding.plist
fi

VOLUME_SYS=`defaults read "${VOLUME_PATH}"/System/Library/CoreServices/SystemVersion ProductVersion | awk -F. '{ print $2 }'`
if [ -z "${VOLUME_SYS}" ]
then
  VOLUME_SYS=`sw_vers -productVersion | awk -F. '{ print $2 }'`
fi

if [ `sw_vers -productVersion | awk -F. '{ print $2 }'` -gt 5 ]
then
  diskutil enableOwnership "${VOLUME_PATH}"
else
  /usr/sbin/vsdbutil -a "${VOLUME_PATH}"
fi

if [ ${VOLUME_SYS} -lt 7 ]
then
  cp "${SCRIPT_PATH}"/ds_open_directory_binding/ds_open_directory_binding.10.5.sh "${VOLUME_PATH}"/etc/deploystudio/bin/ds_open_directory_binding.sh
else
  cp "${SCRIPT_PATH}"/ds_open_directory_binding/ds_open_directory_binding.10.7.sh "${VOLUME_PATH}"/etc/deploystudio/bin/ds_open_directory_binding.sh
fi

if [ ${?} -ne 0 ]
then
  echo "RuntimeAbortWorkflow: OD binding script installation failed!"
  exit 1
fi
	
chmod 700 "${VOLUME_PATH}"/etc/deploystudio/bin/ds_open_directory_binding.sh
chown root:wheel "${VOLUME_PATH}"/etc/deploystudio/bin/ds_open_directory_binding.sh

if [ -e "${VOLUME_PATH}"/System/Library/CoreServices/ServerVersion.plist ]
then
  rm -f  "${VOLUME_PATH}"/var/db/dslocal/nodes/Default/config/KerberosKDC.plist 2>&1 >/dev/null
  rm -f  "${VOLUME_PATH}"/Library/Keychains/System.keychain 2>&1 >/dev/null
  rm -f  "${VOLUME_PATH}"/etc/krb5.keytab 2>&1 >/dev/null
  rm -rf "${VOLUME_PATH}"/var/db/krb5kdc 2>&1 >/dev/null
fi

#"${SCRIPT_PATH}"/ds_enable_verbose_reboot.sh "${1}"

echo "${SCRIPT_NAME} - end"

exit 0