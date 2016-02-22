#!/bin/sh

#set -e

# quickstart -- downloads utilities to be installed on the VM
# and does some very basic setup.

# you must have curl and GPG installed on the host system, along with
# vagrant and puppet

# developed with Vagrant 1.7.4 and VirtualBox 5.0.14 on Fedora 23. 
# Puppet 4.2.1 installed from puppetlabs (not Fedora repositories)

WD=$(pwd)

die() {
	echo "$1"
	exit 1
}

assert_success() {
	if [ $? -ne 0 ]; then
		die "$1"
	fi
}

POSTMODERN_PUBKEY="https://raw.github.com/postmodern/postmodern.github.io/master/postmodern.asc"

for binary in "puppet" "vboxmanage" "vagrant" "wget" "gpg" ; do
	result=$(which $binary)
	if [ "$?" != "0" ]; then
		 echo "${binary} not found.  Please install before proceeding"
		exit 1
	fi
done

puppet module install puppetlabs-stdlib
puppet module install puppetlabs-vcsrepo

# some of the puppet diagnostics fail if the 'environments' directory isn't 
# available in the right place.  So let's try to symlink the local environments
# directory there, unless it already exists. We can go on if this isn't 
# possible, it will just be harder to debug.

PUPPET_HOME_ENVS="${HOME}/.puppet/code"

MODULES_DIR="environments/test/modules"

link_environment() {

	PUPPET_ENV_MODULES_DIR="${PUPPET_HOME_ENVS}/${MODULES_DIR}"

	for i in $(ls "${WD}/../${MODULES_DIR}"); do
		if [ -d "${WD}/../${MODULES_DIR}/${i}" ]; then
			REALPATH=$(readlink -e "${WD}/../${MODULES_DIR}/${i}")
			DIRNAME=$(dirname "${REALPATH}")
			TARGET="${PUPPET_ENV_MODULES_DIR}/${DIRNAME}"
			if  [ -d "${TARGET}" -o -h "${TARGET}" ]; then
				if [ ! -d $(dirname "${TARGET}") ]; then
					mkdir -p "$(dirname "${TARGET}")"
				fi
				ln -s "${REALPATH}" "${TARGET}"
			fi
		fi
	done
}

download() {
	URL="$1"
	DEST="${2:-"$(pwd)/.cache"}"
	DESTFILE
	if [ ! -d dirname "$DEST" ]; then	
		mkdir -p "$DEST"
	fi
	pushd "$DEST" > /dev/null
	curl -o "${URL}"
}

link_environment

# check for existence of "postmodern" PGP key
# http://postmodern.github.io/contact.html#pgp

KEY_ID="B9515E77"

RESULT=$(gpg --list-keys "$KEY_ID" 2>&1)

if [ $? -ne 0 ]; then
	echo "Fetching PGP key to verify integrity of chruby and ruby-install packages"

	wget -O postmodern.asc "$POSTMODERN_PUBKEY"
	gpg --import postmodern.asc
	assert_success "Unable to import GPG key.  Cannot continue"
fi

# check key against "known good" download

gpg --fingerprint "$KEY_ID" | cmp - "${WD}/postmodern-fingerprint"

assert_success "Fingerprint of PGP key is unexpected.  Will not continue"


echo "Checking chruby and ruby-install packages"

fetch_and_verify() {
	BIN_NAME="$1"
	MODULE_NAME="$2"
	BIN_URL="$3"
	ASC_URL="$4"

	BIN_PATH="../${MODULES_DIR}/${MODULE_NAME}/files/${BIN_NAME}"

	if [ ! -e "${BIN_PATH}" ]; then
		RESULT=$(wget -O "${BIN_PATH}" "${BIN_URL}" 2>&1)
		assert_success "Unable to download ${BIN_NAME}: $RESULT"
	fi

	if [ ! -e "${BIN_PATH}.asc" ]; then
		RESULT=$(wget -O "${BIN_PATH}.asc" "${ASC_URL}" 2>&1)
		assert_success "Unable to download ${BIN_NAME}.asc: $RESULT"
	fi
	pushd $(dirname "${BIN_PATH}") > /dev/null

	RESULT=$(gpg --verify  "${BIN_NAME}.asc" 2>&1)
	assert_success "Integrity of $BIN_NAME archive is in question.: $RESULT"
	echo "${BIN_NAME} downloaded and verified"
	popd > /dev/null
}

CHRUBY_VERSION="0.3.9"
RUBY_INSTALL_VERSION="0.6.0"

fetch_and_verify "chruby-${CHRUBY_VERSION}.tar.gz" "chruby" "https://github.com/postmodern/chruby/archive/v${CHRUBY_VERSION}.tar.gz" "https://raw.githubusercontent.com/postmodern/chruby/master/pkg/chruby-${CHRUBY_VERSION}.tar.gz.asc"

fetch_and_verify "ruby-install-${RUBY_INSTALL_VERSION}.tar.gz" "chruby" "https://github.com/postmodern/ruby-install/archive/v${RUBY_INSTALL_VERSION}.tar.gz" "https://raw.github.com/postmodern/ruby-install/master/pkg/ruby-install-${RUBY_INSTALL_VERSION}.tar.gz.asc"
