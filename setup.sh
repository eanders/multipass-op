#! /bin/sh
# NOTE: you'll probably want to run these manually, sometimes they don't work correctly when scripted

multipass launch focal --name op --cpus 4 --disk 80G --mem 8G
multipass set client.primary-name=op
# Setup SSH (NOTE you may need to adjust .ssh/config to accommodate linux)
files=(`ls ~/.ssh/`)
for i in $files
do

  if [[ "$i" == "authorized_keys" ]]; then
    continue
  fi
  if [ "$i" = "known_hosts" ]; then
    continue
  fi

  multipass transfer "$HOME/.ssh/$i" op:/home/ubuntu/.ssh/
  multipass exec op -- chmod 600 "/home/ubuntu/.ssh/$i"
done

multipass exec op -- sudo mkdir /multipass
multipass exec op -- sudo chown ubuntu:ubuntu /multipass
# NOTE, you may need to change ~/Sites/multipass/op to match your setup
# mkdir -p ~/Sites/multipass/op/docker_data
mkdir -p ~/Sites/multipass/op/setup
mkdir -p ~/Sites/multipass/op/boston-cas
mkdir -p ~/Sites/multipass/op/hmis-warehouse
mkdir -p ~/Sites/multipass/op/hmis-frontend
mkdir -p ~/Sites/multipass/op/deploy

# multipass umount op:/multipass/setup
# multipass umount op:/multipass/boston-cas
# multipass umount op:/multipass/hmis-warehouse
# multipass umount op:/multipass/hmis-frontend
# multipass umount op:/multipass/deploy

multipass mount -t native ~/Sites/multipass/op/setup op:/multipass/setup
multipass mount -t native ~/Sites/multipass/op/boston-cas op:/multipass/boston-cas
multipass mount -t native ~/Sites/multipass/op/hmis-warehouse op:/multipass/hmis-warehouse
multipass mount -t native ~/Sites/multipass/op/hmis-frontend op:/multipass/hmis-frontend
multipass mount -t native ~/Sites/multipass/op/hmis-frontend op:/multipass/deploy

multipass exec op -- sudo chmod 777 /multipass/setup/bootstrap.sh
multipass exec op -- sudo chmod 777 /multipass/setup/bootstrap_user.sh
multipass exec op -- sudo chmod 777 /multipass/setup/bootup.sh
multipass exec op -- sudo /multipass/setup/bootstrap.sh
multipass exec op -- /multipass/setup/bootstrap_user.sh
multipass exec op -- /multipass/setup/bootup.sh

multipass exec op -- sudo cp /multipass/setup/op.service /etc/systemd/system/
multipass exec op -- sudo chown root:root /etc/systemd/system/op.service
multipass exec op -- sudo chmod 644 /etc/systemd/system/op.service

# TODO:
# Mount this so that we can still read it even though it'll be owned as root
# multipass mount ~/Sites/multipass/op/docker_data op:/var/lib/docker --uid-map "$(id -u)":1000
# multipass exec op -- sudo chown root:root /var/lib/docker
# multipass exec op -- sudo chmod u+rwx /var/lib/docker
# multipass exec op -- sudo chmod g+rx /var/lib/docker

# NOTE
# multipass will write /var/db/dhcpd_leases on the host
# it will contain dhcd IP addresses for the containers, which,
# in theory shouldn't change unless you rebuild them.
# So you can add those as appropriate to /etc/hosts
# Something like:

# # Nginx Proxy setup for multipass  development
# 192.168.64.6 hmis.dev.test
# 192.168.64.6 hmis-warehouse.dev.test
# 192.168.64.6 mail.hmis-warehouse.dev.test
# 192.168.64.6 boston-cas.dev.test
# 192.168.64.6 mail.boston-cas.dev.test
# 192.168.64.6 springfield-warehouse.dev.test
# 192.168.64.6 mail.springfield-warehouse.dev.test
