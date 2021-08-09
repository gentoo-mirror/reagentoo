# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7..10} )
inherit desktop git-r3 python-r1 xdg

MY_PN="${PN^}"

DESCRIPTION="Small and highly customizable twin-panel file manager with plugin-support"
HOMEPAGE="https://github.com/MeanEYE/Sunflower http://sunflower-fm.org/"

EGIT_REPO_URI="https://github.com/MeanEYE/${MY_PN}.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="nls"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	${PYTHON_DEPS}
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	dev-python/chardet[${PYTHON_USEDEP}]
"
RDEPEND="${DEPEND}
	dev-python/pycairo[${PYTHON_USEDEP}]
"
BDEPEND="nls? ( sys-devel/gettext )"

src_prepare() {
	default

	find "${S}/translations" -name "*.mo" -delete || die
	rm "${S}/translations/${PN}.pot" || die
}

src_compile() {
	if use nls
	then
		local lang

		for lang in $(ls -1 translations)
		do
			msgfmt -o translations/${lang}/LC_MESSAGES/sunflower.{m,p}o || die
		done
	fi
}

src_install() {
	installme() {
		# install modules
		python_moduleinto ${PN}
		python_domodule images ${PN}/*

		# generate and install startup scripts
		sed -i -e "s#@SITEDIR@#$(python_get_sitedir)/${PN}#" \
			dist/${PN} || die
		python_doscript dist/${PN}
	}

	# install for all enabled implementations
	python_foreach_impl installme

	insinto /usr/share/sunflower/images
	doins images/splash.png
	doins images/sunflower_64.png

	insinto /usr/share/${PN}/styles
	doins styles/main.css

	if use nls
	then
		local lang

		for lang in $(ls -1 translations)
		do
			insinto /usr/share/locale/${lang}/LC_MESSAGES
			doins translations/${lang}/LC_MESSAGES/sunflower.mo
		done
	fi

	doicon -s scalable images/${PN}.svg
	newicon -s 64 images/${PN}_64.png ${PN}.png
	newmenu ${MY_PN}.desktop ${PN}.desktop
}

pkg_postinst() {
	xdg_pkg_postinst

	# TODO: better description
	elog "optional dependencies:"
	elog "  dev-python/libgnome-python"
	elog "  media-libs/mutagen"
	elog "  x11-libs/vte:0[python] (terminal support)"
}
