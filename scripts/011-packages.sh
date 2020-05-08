################################
## PART: install the packages
##
## vi: syntax=sh expandtab ts=4

pkgs=(cloud-image-utils
      git
      jq
      libguestfs-tools
      make
      mysql-server
      make
      nginx
      postfix
      python3-certbot
      super
      unzip)

apt-get -qqy update
apt-get -qqy install "${pkgs[@]}"
apt-get -qqy clean
