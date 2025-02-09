#!/bin/bash

# This script is only tested on CentOS 6.5 and Ubuntu 12.04 LTS with Percona XtraDB Cluster 5.6.
# You can customize variables such as MOUNTPOINT, RAIDCHUNKSIZE and so on to your needs.
# You can also customize it to work with other Linux flavours and versions.
# If you customize it, copy it to either Azure blob storage or GitHub so that Azure
# custom script Linux VM extension can access it, and specify its location in the
# parameters of DeployPXC powershell script or runbook or Azure Resource Manager CRP template.

NODEID=${1}
NODEADDRESS=${2}
MYCNFTEMPLATE=${3}
RPLPWD=${4}
ROOTPWD=${5}
PROBEPWD=${6}
MASTERIP=${7}
VERSION=5.5

MOUNTPOINT="/datadrive"
RAIDCHUNKSIZE=512

RAIDDISK="/dev/md127"
RAIDPARTITION="/dev/md127p1"
# An set of disks to ignore from partitioning and formatting
BLACKLIST="/dev/sda|/dev/sdb"

check_os() {
    grep ubuntu /proc/version > /dev/null 2>&1
    isubuntu=${?}
    grep centos /proc/version > /dev/null 2>&1
    iscentos=${?}
}

scan_for_new_disks() {
    # Looks for unpartitioned disks
    declare -a RET
    DEVS=($(ls -1 /dev/sd*|egrep -v "${BLACKLIST}"|egrep -v "[0-9]$"))
    for DEV in "${DEVS[@]}";
    do
        # Check each device if there is a "1" partition.  If not,
        # "assume" it is not partitioned.
        if [ ! -b ${DEV}1 ];
        then
            RET+="${DEV} "
        fi
    done
    echo "${RET}"
}

get_disk_count() {
    DISKCOUNT=0
    for DISK in "${DISKS[@]}";
    do
        DISKCOUNT+=1
    done;
    echo "$DISKCOUNT"
}

create_raid0_ubuntu() {
    dpkg -s mdadm
    if [ ${?} -eq 1 ];
    then
        echo "installing mdadm"
        wget --no-cache http://mirrors.cat.pdx.edu/ubuntu/pool/main/m/mdadm/mdadm_3.2.5-5ubuntu4_amd64.deb
        dpkg -i mdadm_3.2.5-5ubuntu4_amd64.deb
    fi
    echo "Creating raid0"
    udevadm control --stop-exec-queue
    echo "yes" | mdadm --create "$RAIDDISK" --name=data --level=0 --chunk="$RAIDCHUNKSIZE" --raid-devices="$DISKCOUNT" "${DISKS[@]}"
    udevadm control --start-exec-queue
    mdadm --detail --verbose --scan > /etc/mdadm.conf
}

create_raid0_centos() {
    echo "Creating raid0"
    yes | mdadm --create "$RAIDDISK" --name=data --level=0 --chunk="$RAIDCHUNKSIZE" --raid-devices="$DISKCOUNT" "${DISKS[@]}"
    mdadm --detail --verbose --scan > /etc/mdadm.conf
}

do_partition() {
# This function creates one (1) primary partition on the
# disk, using all available space
    DISK=${1}
    echo "Partitioning disk $DISK"
    echo "n
p
1


w
" | fdisk "${DISK}"
#> /dev/null 2>&1

#
# Use the bash-specific $PIPESTATUS to ensure we get the correct exit code
# from fdisk and not from echo
if [ ${PIPESTATUS[1]} -ne 0 ];
then
    echo "An error occurred partitioning ${DISK}" >&2
    echo "I cannot continue" >&2
    exit 2
fi
}

add_to_fstab() {
    UUID=${1}
    MOUNTPOINT=${2}
    grep "${UUID}" /etc/fstab >/dev/null 2>&1
    if [ ${?} -eq 0 ];
    then
        echo "Not adding ${UUID} to fstab again (it's already there!)"
    else
        LINE="UUID=${UUID} ${MOUNTPOINT} ext4 defaults,noatime 0 0"
        echo -e "${LINE}" >> /etc/fstab
    fi
}

configure_disks() {
	ls "${MOUNTPOINT}"
	if [ ${?} -eq 0 ]
	then
		return
	fi
    DISKS=($(scan_for_new_disks))
    echo "Disks are ${DISKS[@]}"
    declare -i DISKCOUNT
    DISKCOUNT=$(get_disk_count)
    echo "Disk count is $DISKCOUNT"
    if [ $DISKCOUNT -gt 1 ];
    then
    	if [ $iscentos -eq 0 ];
    	then
       	    create_raid0_centos
    	elif [ $isubuntu -eq 0 ];
    	then
            create_raid0_ubuntu
    	fi
        do_partition ${RAIDDISK}
        PARTITION="${RAIDPARTITION}"
    else
        DISK="${DISKS[0]}"
        do_partition ${DISK}
        PARTITION=$(fdisk -l ${DISK}|grep -A 1 Device|tail -n 1|awk '{print $1}')
    fi

    echo "Creating filesystem on ${PARTITION}."
    mkfs -t ext4 -E lazy_itable_init=1 ${PARTITION}
    mkdir "${MOUNTPOINT}"
    read UUID FS_TYPE < <(blkid -u filesystem ${PARTITION}|awk -F "[= ]" '{print $3" "$5}'|tr -d "\"")
    add_to_fstab "${UUID}" "${MOUNTPOINT}"
    echo "Mounting disk ${PARTITION} on ${MOUNTPOINT}"
    mount "${MOUNTPOINT}"
}

open_ports() {
    iptables -A INPUT -p tcp -m tcp --dport 3306 -j ACCEPT
    iptables -A INPUT -p tcp -m tcp --dport 9200 -j ACCEPT
    iptables-save
}

disable_apparmor_ubuntu() {
    /etc/init.d/apparmor stop
    /etc/init.d/apparmor teardown
    update-rc.d -f apparmor remove
    apt-get remove apparmor apparmor-utils -y
}

disable_selinux_centos() {
    sed -i 's/^SELINUX=.*/SELINUX=disabled/I' /etc/selinux/config
    setenforce 0
}

configure_network() {
    open_ports
    if [ $iscentos -eq 0 ];
    then
        disable_selinux_centos
    elif [ $isubuntu -eq 0 ];
    then
        disable_apparmor_ubuntu
    fi
}

create_mycnf() {
    wget "${MYCNFTEMPLATE}" -O /etc/my.cnf
    sed -i "s/^server_id=.*/server_id=${NODEID}/I" /etc/my.cnf
    sed -i "s/^report-host=.*/report-host=${NODEADDRESS}/I" /etc/my.cnf
    sed -i "s/^bind-address.*/bind-address=0.0.0.0/I" /etc/mysql/my.cnf
}

install_mysql_ubuntu() {
    dpkg -s mysql-$VERSION
    if [ ${?} -eq 0 ];
    then
        return
    fi
    echo "installing mysql"
    apt-get update
    export DEBIAN_FRONTEND=noninteractive
	apt-get install -y mysql-server-$VERSION
	chown -R mysql:mysql "${MOUNTPOINT}/mysql/mysql"
	apt-get install -y mysql-server-$VERSION
	wget http://dev.mysql.com/get/Downloads/Connector-Python/mysql-connector-python_2.1.3-1ubuntu14.04_all.deb
	dpkg -i mysql-connector-python_2.1.3-1ubuntu14.04_all.deb
	wget http://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-utilities_1.6.4-1ubuntu14.04_all.deb
    dpkg -i mysql-utilities_1.6.4-1ubuntu14.04_all.deb
    apt-get -y install xinetd
}

install_mysql_centos() {
    rpm -qa |grep MySQL-server-5.6.26-1.el6.x86_64
    if [ ${?} -eq 0 ];
    then
        return
    fi
    echo "installing mysql"
    wget https://dev.mysql.com/get/Downloads/MySQL-5.6/MySQL-5.6.26-1.el6.x86_64.rpm-bundle.tar
    tar -xvf MySQL-5.6.26-1.el6.x86_64.rpm-bundle.tar
	curlib=$(rpm -qa |grep mysql-libs-)
    rpm -e --nodeps $curlib
    rpm -ivh MySQL-server-5.6.26-1.el6.x86_64.rpm
    rpm -ivh MySQL-client-5.6.26-1.el6.x86_64.rpm
	wget http://dev.mysql.com/get/Downloads/Connector-Python/mysql-connector-python-2.0.4-1.el6.noarch.rpm
	rpm -ivh mysql-connector-python-2.0.4-1.el6.noarch.rpm
	wget http://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-utilities-1.5.5-1.el6.noarch.rpm
	rpm -ivh mysql-utilities-1.5.5-1.el6.noarch.rpm
    yum -y install xinetd
}

create_mysql_probe() {
if [ ${NODEID} -eq 1 ];
then
# create a probe user with minimum privilege
    mysql -u root -p"${ROOTPWD}" <<EOF
CREATE USER 'probeuser'@'%' IDENTIFIED BY '${PROBEPWD}';
GRANT SELECT ON *.* TO 'probeuser'@'%';
FLUSH PRIVILEGES;
EOF
fi

# create a probe script
    cat <<EOF >/usr/bin/mysqlprobe
#!/bin/bash

MYSQL_HOST="${NODEADDRESS}"
MYSQL_USERNAME="probeuser"
MYSQL_PASSWORD='${PROBEPWD}'

ERROR_MSG=\`/usr/bin/mysqladmin --host=\${MYSQL_HOST} --port=3306 --user=\${MYSQL_USERNAME} --password=\${MYSQL_PASSWORD} status 2>/dev/null\`
#ERROR_MSG=\`/usr/bin/mysql --host=\${MYSQL_HOST} --port=3306 --user=\${MYSQL_USERNAME} --password=\${MYSQL_PASSWORD} -e "show databases;" 2>/dev/null\`

if [ "\$ERROR_MSG" != "" ]
then
        # mysql is fine, return http 200
        echo -en "HTTP/1.1 200 OK\r\n"
        echo -en "Content-Type: text/plain\r\n"
        echo -en "Connection: close\r\n"
        echo -en "Content-Length: 19\r\n"
        echo -en "\r\n"
        echo -en "MySQL is running.\r\n"
        sleep 0.1
        exit 0
else
        # mysql is down, return http 503
        echo -en "HTTP/1.1 503 Service Unavailable\r\n"
        echo -en "Content-Type: text/plain\r\n"
        echo -en "Connection: close\r\n"
        echo -en "Content-Length: 16\r\n"
        echo -en "\r\n"
        echo -en "MySQL is down.\r\n"
        sleep 0.1
        exit 1
fi
EOF

chmod 755 /usr/bin/mysqlprobe

# create a http service that runs the script
    cat <<EOF >/etc/xinetd.d/mysqlprobe
# default: on
# description: mysqlprobe
service mysqlprobe
{
        disable = no
        flags = REUSE
        socket_type = stream
        port = 9200
        wait = no
        user = nobody
        server = /usr/bin/mysqlprobe
        log_on_failure += USERID
        only_from = 0.0.0.0/0
        per_source = UNLIMITED
}
EOF

# add the service to xinet
    grep "mysqlprobe" /etc/services >/dev/null 2>&1
    if [ ${?} -ne 0 ];
    then
        sed -i "\$amysqlprobe  9200\/tcp  #mysqlprobe" /etc/services
    fi
    service xinetd restart
}

configure_mysql_replication() {
if [ ${NODEID} -eq 1 ];
then
    mysql -u root -p"${ROOTPWD}" <<EOF
CREATE USER 'rpluser'@'%' IDENTIFIED BY '${RPLPWD}';
GRANT REPLICATION SLAVE ON *.* TO 'rpluser'@'%';
FLUSH PRIVILEGES;
EOF
else
    mysql -u root -p"${ROOTPWD}" <<EOF
change master to master_host='${MASTERIP}', master_port=3306, master_user='rpluser', master_password='${RPLPWD}', master_auto_position=1;
START slave;
EOF
fi
}

configure_mysql() {
    /etc/init.d/mysql status
    if [ ${?} -eq 0 ];
    then
       return
    fi

    mkdir "${MOUNTPOINT}/mysql"
    ln -s "${MOUNTPOINT}/mysql" /var/lib/mysql
    chmod o+x /var/lib/mysql
    groupadd mysql
    useradd -r -g mysql mysql
    chmod o+x "${MOUNTPOINT}/mysql"
    chown -R mysql:mysql "${MOUNTPOINT}/mysql"

    if [ $iscentos -eq 0 ];
    then
        install_mysql_centos
    elif [ $isubuntu -eq 0 ];
    then
        install_mysql_ubuntu
    fi

    create_mycnf
    /etc/init.d/mysql restart
    mysql_secret=$(awk '/password/{print $NF}' ${HOME}/.mysql_secret)
    mysqladmin -u root --password=${mysql_secret} password ${ROOTPWD}
if [ ${NODEID} -eq 1 ];
then
    mysql -u root -p"${ROOTPWD}" <<EOF
SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('${ROOTPWD}');
SET PASSWORD FOR 'root'@'::1' = PASSWORD('${ROOTPWD}');
CREATE USER 'admin'@'%' IDENTIFIED BY '${ROOTPWD}';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' with grant option;
FLUSH PRIVILEGES;
EOF
fi
    configure_mysql_replication
    create_mysql_probe
}

check_os
if [ $iscentos -ne 0 ] && [ $isubuntu -ne 0 ];
then
    echo "unsupported operating system"
    exit 1
else
    configure_network
    configure_disks
    configure_mysql
	#yum -y erase hypervkvpd.x86_64
	#yum -y install microsoft-hyper-v
#	echo "/sbin/reboot" | /usr/bin/at now + 3 min >/dev/null 2>&1
fi

