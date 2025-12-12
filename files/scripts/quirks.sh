#!/usr/bin/env bash

set -oue pipefail

echo "$(date +%s)" > /etc/last_update_run

if grep -q 'ID="centos"' /etc/os-release; then
    IMAGE_PRETTY_NAME="bourbonOS $(cat /etc/bourbonOS_version)"
    IMAGE_LIKE="centos"
    HOME_URL="https://github.com/bourbonOS/bourbonOS-devel"
    DOCUMENTATION_URL="https://github.com/bourbonOS/bourbonOS-devel"
    SUPPORT_URL="https://github.com/bourbonOS/bourbonOS-devel/issues"
    BUG_SUPPORT_URL="https://github.com/bourbonOS/bourbonOS-devel/issues"

    sed -i "s/^VARIANT_ID=.*/VARIANT_ID=$IMAGE_NAME/" /usr/lib/os-release
    sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"${IMAGE_PRETTY_NAME} (powered by CentOS Stream)\"/" /usr/lib/os-release
    sed -i "s/^NAME=.*/NAME=\"$IMAGE_PRETTY_NAME\"/" /usr/lib/os-release
    sed -i "s|^HOME_URL=.*|HOME_URL=\"$HOME_URL\"|" /usr/lib/os-release
    sed -i "s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"$DOCUMENTATION_URL\"|" /usr/lib/os-release
    sed -i "s|^SUPPORT_URL=.*|SUPPORT_URL=\"$SUPPORT_URL\"|" /usr/lib/os-release
    sed -i "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"$BUG_SUPPORT_URL\"|" /usr/lib/os-release
    sed -i "s|^CPE_NAME=\"cpe:/o:fedoraproject:fedora|CPE_NAME=\"cpe:/o:bourbonos:${IMAGE_PRETTY_NAME,}|" /usr/lib/os-release
    sed -i "s/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME=\"${IMAGE_PRETTY_NAME,}\"/" /usr/lib/os-release
    sed -i "s/^ID=fedora/ID=\"${IMAGE_LIKE,}\"\nID_LIKE=\"${IMAGE_PRETTY_NAME,}\"/" /usr/lib/os-release
    sed -i "/^REDHAT_BUGZILLA_PRODUCT=/d; /^REDHAT_BUGZILLA_PRODUCT_VERSION=/d; /^REDHAT_SUPPORT_PRODUCT=/d; /^REDHAT_SUPPORT_PRODUCT_VERSION=/d" /usr/lib/os-release
    sed -i "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" /usr/sbin/grub2-switch-to-blscfg

    dnf -y install epel-release 'dnf-command(config-manager)'
    crb enable
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-10
elif grep -q "ID=fedora" /etc/os-release; then
    IMAGE_PRETTY_NAME="bourbonOS $(cat /etc/bourbonOS_version)"
    IMAGE_LIKE="fedora"
    HOME_URL="https://github.com/bourbonOS/bourbonOS-devel"
    DOCUMENTATION_URL="https://github.com/bourbonOS/bourbonOS-devel"
    SUPPORT_URL="https://github.com/bourbonOS/bourbonOS-devel/issues"
    BUG_SUPPORT_URL="https://github.com/bourbonOS/bourbonOS-devel/issues"

    sed -i "s/^VARIANT_ID=.*/VARIANT_ID=$IMAGE_NAME/" /usr/lib/os-release
    sed -i "s/^PRETTY_NAME=.*/PRETTY_NAME=\"${IMAGE_PRETTY_NAME} (powered by Fedora Atomic)\"/" /usr/lib/os-release
    sed -i "s/^NAME=.*/NAME=\"$IMAGE_PRETTY_NAME\"/" /usr/lib/os-release
    sed -i "s|^HOME_URL=.*|HOME_URL=\"$HOME_URL\"|" /usr/lib/os-release
    sed -i "s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"$DOCUMENTATION_URL\"|" /usr/lib/os-release
    sed -i "s|^SUPPORT_URL=.*|SUPPORT_URL=\"$SUPPORT_URL\"|" /usr/lib/os-release
    sed -i "s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"$BUG_SUPPORT_URL\"|" /usr/lib/os-release
    sed -i "s|^CPE_NAME=\"cpe:/o:fedoraproject:fedora|CPE_NAME=\"cpe:/o:bourbonos:${IMAGE_PRETTY_NAME,}|" /usr/lib/os-release
    sed -i "s/^DEFAULT_HOSTNAME=.*/DEFAULT_HOSTNAME=\"${IMAGE_PRETTY_NAME,}\"/" /usr/lib/os-release
    sed -i "s/^ID=fedora/ID=\"${IMAGE_LIKE,}\"\nID_LIKE=\"${IMAGE_PRETTY_NAME,}\"/" /usr/lib/os-release
    sed -i "/^REDHAT_BUGZILLA_PRODUCT=/d; /^REDHAT_BUGZILLA_PRODUCT_VERSION=/d; /^REDHAT_SUPPORT_PRODUCT=/d; /^REDHAT_SUPPORT_PRODUCT_VERSION=/d" /usr/lib/os-release
    sed -i "s/^EFIDIR=.*/EFIDIR=\"fedora\"/" /usr/sbin/grub2-switch-to-blscfg
fi