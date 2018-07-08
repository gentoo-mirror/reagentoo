# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-multilib

DESCRIPTION="Linux port of Apple's open-source concurrency library"
HOMEPAGE="http://nickhutchinson.me/${PN}"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/nickhutchinson/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/nickhutchinson/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD"
SLOT="0"
IUSE=""

RDEPEND="
	dev-libs/blocks-runtime[${MULTILIB_USEDEP}]
	dev-libs/libkqueue[${MULTILIB_USEDEP}]
	dev-libs/libpwq
"

DEPEND="${RDEPEND}
	>=sys-devel/clang-3.4
	dev-lang/python:2.7
	>=dev-util/cmake-2.8.7
"

src_configure() {
	export CC=clang
	export CXX=clang++
	
	cmake-multilib_src_configure
}
