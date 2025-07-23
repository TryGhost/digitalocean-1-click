################################
## PART: Write the application tag
##
## vi: syntax=sh expandtab ts=4

build_date=$(date +%Y-%m-%d)
version=$(cd /var/www/ghost; ghost version | awk '/Ghost Version/{print$NF}')

cat >> /var/lib/digitalocean/application.info <<EOM
appiication_name="Ghost"
build_date="${build_date}
distro=Ubuntu
distro_release=24.04
distro_codename=noble
distro_arch=amd64
application_version="${version}"
EOM
