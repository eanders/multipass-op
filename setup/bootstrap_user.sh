#!/usr/bin/env bash

echo "export AWS_VAULT_BACKEND=file" >> /home/ubuntu/.bashrc
echo "export GPG_TTY=$(tty)" >> /home/ubuntu/.bashrc
echo "export AWS_ACCESS_KEY_ID=unknown" >> /home/ubuntu/.bashrc
echo "export AWS_SECRET_ACCESS_KEY=unknown" >> /home/ubuntu/.bashrc
echo "export AWS_SESSION_TOKEN=unknown" >> /home/ubuntu/.bashrc
echo "export AWS_SECURITY_TOKEN=unknown" >> /home/ubuntu/.bashrc
echo "alias dcr='docker-compose run --rm'" >> /home/ubuntu/.bashrc

# add keys so we don't need to enter the password always
echo "ssh-add" >> /home/ubuntu/.bashrc

if [ ! -d /multipass/boston-cas/config ]; then
  git clone git@github.com:greenriver/boston-cas.git /multipass/boston-cas/
  cp /multipass/setup/cas-docker-compose.override.yml /multipass/boston-cas/docker-compose.override.yml
  cp /multipass/boston-cas/.env.sample /multipass/boston-cas/.env.local
  echo "RAILS_ENV=test" > /multipass/boston-cas/.env.test
fi

if [ ! -d /multipass/hmis-warehouse/config ]; then
  git clone git@github.com:greenriver/hmis-warehouse.git /multipass/hmis-warehouse/
  cp /multipass/setup/hmis-docker-compose.override.yml /multipass/hmis-warehouse/docker-compose.override.yml
  cp /multipass/hmis-warehouse/sample.env /multipass/hmis-warehouse/.env.local
  openssl req -new -newkey rsa:2048 -sha256 -days 3650 -nodes -x509 \
    -keyout /multipass/hmis-warehouse/docker/nginx-proxy/certs/dev.test.key \
    -out /multipass/hmis-warehouse/docker/nginx-proxy/certs/dev.test.crt \
    -config /multipass/setup/openssl.cnf
fi

ln -s /multipass/boston-cas ~/boston-cas
ln -s /multipass/hmis-warehouse ~/hmis-warehouse
ln -s /multipass/hmis-frontend ~/hmis-frontend
ln -s /multipass/deploy ~/deploy
ln -s /multipass/sftp ~/sftp

source ~/.bashrc

gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
command curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
curl -sSL https://get.rvm.io | bash -s stable
source /home/ubuntu/.rvm/scripts/rvm

cd ~/hmis-warehouse
rvm install "ruby-2.7.6"
gem install bundler:2.3.8
gem install overcommit
gem install aws-sdk-secretsmanager
gem install aws-sdk-ecr
gem install aws-sdk-elasticloadbalancingv2
overcommit --sign
bundle config build.nokogiri --use-system-libraries

mkdir ~/.aws
touch ~/.aws/config

# TODO:
# git credentials (and verification)
# Notes: you'll need to copy your gpg keys from the host (if you have them)
# Instructions for the github side are here: https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits
# git config commit.gpgsign true
# Will auto sign all commits
# https://gist.github.com/paolocarrasco/18ca8fe6e63490ae1be23e84a7039374 might help you solve:
# error: gpg failed to sign the data
# fatal: failed to write commit object

# aws-vault add openpath
