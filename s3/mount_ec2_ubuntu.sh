#!/bin/bash

# 必要なパッケージのインストール
sudo apt-get -y update
sudo apt-get -y install automake autotools-dev g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config postgresql-client

# s3fsのインストール
git clone https://github.com/s3fs-fuse/s3fs-fuse.git
cd s3fs-fuse
./autogen.sh
./configure --prefix=/usr
make
sudo make install

# マウントポイントの設定
# 権限は実行権限がないとマウントできないため755にしている
sudo mkdir /mnt/s3
sudo chown ubuntu: /mnt/s3/
sudo chmod 755 /mnt/s3

/usr/bin/s3fs sample-company /mnt/s3 -o rw,allow_other,uid=1000,gid=1000,default_acl=public-read,iam_role='sample-iam-role'

# 再起動後もマウントするように設定
cat <<EOF > /etc/init.d/s3mount
#!/bin/sh
# Start/stop the s3 mount.
#
### BEGIN INIT INFO
# Provides:          s3
# Required-Start:    $local_fs
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: s3 mount
### END INIT INFO

/usr/bin/s3fs sample-company /mnt/s3 -o rw,allow_other,uid=1000,gid=1000,default_acl=public-read,iam_role='sample-iam-role'
EOF
chmod 777 /etc/init.d/s3mount
update-rc.d s3mount defaults
