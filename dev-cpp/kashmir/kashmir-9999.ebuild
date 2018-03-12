# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="Dependency needed for net-libs/restbed"
HOMEPAGE="https://github.com/Corvusoft/kashmir-dependency"
EGIT_REPO_URI="https://github.com/Corvusoft/${PN}-dependency.git"
KEYWORDS=""

LICENSE="Boost-1.0"
SLOT="0"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_install() {
	insinto "/usr/include/${PN}"
	doins ${PN}/*.h

	insinto "/usr/include/${PN}/system"
	doins ${PN}/system/*.h
}
