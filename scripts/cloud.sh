#!/bin/bash -e
ls -la /etc/zypp/repos.d
sed -i 's@baseurl=.*@baseurl=https://download.opensuse.org/distribution/leap/15.1/repo/oss@g' /etc/zypp/repos.d/openSUSE-Leap-15.1-1.repo

zypper -n addrepo -f https://download.opensuse.org/repositories/Cloud:Tools/openSUSE_Leap_15.1/Cloud:Tools.repo
zypper -n addrepo https://download.opensuse.org/distribution/leap/15.1/repo/oss/ openSUSE-Leap-15.1-Oss 
zypper -n addrepo https://download.opensuse.org/distribution/leap/15.1/repo/non-oss/ openSUSE-Leap-15.1-Non-Oss
zypper -n addrepo -f https://download.opensuse.org/update/leap/15.1/oss/ openSUSE-Leap-15.1-Update
zypper -n addrepo -f https://download.opensuse.org/update/leap/15.1/non-oss/ repo-update-non-oss
zypper --gpg-auto-import-keys refresh
zypper --non-interactive up

zypper --non-interactive install cloud-init vim less

cat > /etc/cloud/cloud.cfg.d/90_datasource_list.cfg <<EOF
datasource_list: [ NoCloud, GCE, Ec2, None ]
EOF

cat > /etc/cloud/cloud.cfg.d/00_Ec2.cfg <<EOF
datasource:
 Ec2:
  strict_id: false
manage_etc_hosts: true
EOF

cat > /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg <<EOF
# Disable cloud-init networking
# Network handeled by default ifcfg-eth0 and cloud-netconfig
network: {config: disabled}
EOF

systemctl enable cloud-init.service cloud-config.service cloud-final.service cloud-init-local.service

sed -i 's/Before=wicked.service/After=wicked.service/g' /usr/lib/systemd/system/cloud-init.service
sed -i '/After=wicked.service/a Requires=wicked.service' /usr/lib/systemd/system/cloud-init.service

sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="net.ifnames=0 showopts console=ttyS0"/g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
