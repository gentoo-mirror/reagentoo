# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="GRUB wrappers and automation scripts"
HOMEPAGE="https://gitlab.com/reagentoo/egrub"
EGIT_REPO_URI="https://gitlab.com/reagentoo/${PN}.git"

KEYWORDS=""
LICENSE="GPL-3"
SLOT="0"

DEPEND="
	net-misc/rsync
	sys-apps/gptfdisk
	sys-apps/util-linux
	sys-block/parted
	sys-boot/grub
	sys-fs/dosfstools
	sys-fs/f2fs-tools
"
RDEPEND="${DEPEND}"

src_install() {
	for bin in "scripts"/*
	do
		dobin "${bin}"
	done

	insinto "/etc"
	doins -r "egrub.d"

	insinto "/usr/lib/grub"
	doins -r "emod"
}
