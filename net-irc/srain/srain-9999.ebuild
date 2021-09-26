# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..10} pypy3 )
DOCS_BUILDER="sphinx"
DOCS_DIR="doc"
DOCS_AUTODOC=0

inherit python-any-r1 docs meson xdg

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/SrainApp/${PN}.git"
	KEYWORDS=""
else
	MY_PV="${PV/_rc/rc}"
	MY_P="${PN}-${MY_PV}"
	SRC_URI="https://github.com/SrainApp/${PN}/archive/${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~x86"
	S="${WORKDIR}/${MY_P}"
fi


LICENSE="GPL-3"
SLOT="0"
IUSE="+man"

RDEPEND="
	app-crypt/libsecret
	>=dev-libs/glib-2.39.3
	>=dev-libs/libconfig-1.5
	dev-libs/openssl
	net-libs/libsoup:2.4
	>=x11-libs/gtk+-3.22.15
"
DEPEND="${RDEPEND}"
BDEPEND="man? ( ${DOCS_DEPEND} )"

src_prepare() {
	sed -i "s:\('doc',[[:space:]]*meson\.project_name()\):\1 + '-${PF}':" \
		meson.build || die

	xdg_src_prepare
}

src_configure() {
	use man && emesonargs=( -Ddoc_builders='["man"]' )
	meson_src_configure
}

src_compile() {
	docs_compile
	meson_src_compile
}
