# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6..9} )

inherit gnome2-utils meson python-single-r1 xdg

DESCRIPTION="A drawing application for the GNOME desktop"
HOMEPAGE="https://github.com/maoschanz/drawing"

if [[ "${PV}" == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/maoschanz/${PN}.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/maoschanz/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-libs/appstream-glib[introspection]
	dev-python/pygobject[cairo]
"
DEPEND="${RDEPEND}"
