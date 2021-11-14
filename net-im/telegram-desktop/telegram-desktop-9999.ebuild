# Copyright 2020-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7..10} )

inherit cmake flag-o-matic python-any-r1 toolchain-funcs xdg

DESCRIPTION="Official desktop client for Telegram"
HOMEPAGE="https://desktop.telegram.org"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3

	EGIT_BRANCH="dev"
	EGIT_REPO_URI="https://github.com/telegramdesktop/tdesktop.git"
	EGIT_SUBMODULES=(
		'*'
		'-Telegram/ThirdParty/Catch'
		'-Telegram/ThirdParty/hunspell'
		'-Telegram/ThirdParty/jemalloc'
		'-Telegram/ThirdParty/libdbusmenu-qt'
		'-Telegram/ThirdParty/lz4'
	)

	KEYWORDS=""
else
	MY_PN="tdesktop"
	MY_P="${MY_PN}-${PV}-full"

	QTBASE_VER="5.15.2"

	SRC_URI="
		https://github.com/telegramdesktop/${MY_PN}/releases/download/v${PV}/${MY_P}.tar.gz
		https://download.qt.io/official_releases/qt/${QTBASE_VER%.*}/${QTBASE_VER}/submodules/qtbase-everywhere-src-${QTBASE_VER}.tar.xz
	"

	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${MY_P}"
fi

LICENSE="BSD GPL-3-with-openssl-exception LGPL-2+"
SLOT="0"
IUSE="alsa crashreporter custom-api-id +dbus enchant +hunspell +pulseaudio screencast test wayland +X"

REQUIRED_USE="
	|| ( alsa pulseaudio )
	enchant? ( !hunspell )
"

RDEPEND="
	!net-im/telegram-desktop-bin
	app-arch/lz4:=
	dev-libs/jemalloc:=[-lazy-lock]
	dev-libs/openssl:=
	>=dev-qt/qtcore-5.15:5
	>=dev-qt/qtgui-5.15:5[dbus?,jpeg,png,wayland?,X?]
	>=dev-qt/qtimageformats-5.15:5
	>=dev-qt/qtnetwork-5.15:5[ssl]
	>=dev-qt/qtsvg-5.15:5
	>=dev-qt/qtwidgets-5.15:5[png,X?]
	media-fonts/open-sans
	media-libs/fontconfig:=
	media-libs/openal
	media-libs/opus:=
	media-libs/rnnoise
	~media-libs/tg_owt-0_pre20210626[screencast=,X=]
	media-video/ffmpeg:=[opus]
	sys-libs/zlib:=[minizip]
	crashreporter? ( dev-util/google-breakpad )
	dbus? (
		dev-cpp/glibmm:2
		dev-qt/qtdbus:5
		dev-libs/libdbusmenu-qt[qt5(+)]
	)
	enchant? ( app-text/enchant:= )
	hunspell? ( >=app-text/hunspell-1.7:= )
	pulseaudio? ( media-sound/pulseaudio )
	test? ( dev-cpp/catch )
	wayland? ( kde-frameworks/kwayland:= )
	X? ( x11-libs/libxcb:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	>=dev-util/cmake-3.16
	virtual/pkgconfig
"

#PATCHES=(
#	"${FILESDIR}/tdesktop-2.9.3-jemalloc-only-telegram.patch"
#)

pkg_pretend() {
	if use custom-api-id
	then
		[[ -n "${TDESKTOP_API_ID}" ]] && \
		[[ -n "${TDESKTOP_API_HASH}" ]] && (
			einfo "Will be used custom 'api_id' and 'api_hash':"
			einfo "TDESKTOP_API_ID=${TDESKTOP_API_ID}"
			einfo "TDESKTOP_API_HASH=${TDESKTOP_API_HASH//[!\*]/*}"
		) || (
			eerror "It seems you did not set one or both of"
			eerror "TDESKTOP_API_ID and TDESKTOP_API_HASH variables,"
			eerror "which are required for custom-api-id USE-flag."
			eerror "You can set them either in your env or bashrc."
			die
		)

		echo ${TDESKTOP_API_ID} | grep -q "^[0-9]\+$" || (
			eerror "Please check your TDESKTOP_API_ID variable"
			eerror "It should consist of decimal numbers only"
			die
		)

		echo ${TDESKTOP_API_HASH} | grep -q "^[0-9A-Fa-f]\{32\}$" || (
			eerror "Please check your TDESKTOP_API_HASH variable"
			eerror "It should consist of 32 hex numbers only"
			die
		)
	fi

	if tc-is-gcc && [[ $(gcc-major-version) -lt 7 ]]
	then
		die "At least gcc 7.0 is required"
	fi
}

git_unpack() {
	git-r3_src_unpack

	unset EGIT_BRANCH
	unset EGIT_SUBMODULES

	EGIT_COMMIT_DATE=$(GIT_DIR="${S}/.git" git show -s --format=%ct || die)

	EGIT_REPO_URI="https://code.qt.io/qt/qtbase.git"
	EGIT_CHECKOUT_DIR="${WORKDIR}"/Libraries/qtbase

	git-r3_src_unpack
}

src_unpack() {
	if [[ ${PV} == 9999 ]]
	then
		git_unpack
		return
	fi

	unpack ${MY_P}.tar.gz

	mkdir Libraries || die
	cd Libraries || die

	unpack "qtbase-everywhere-src-${QTBASE_VER}.tar.xz"
	mv "qtbase-everywhere-src-${QTBASE_VER}" "qtbase" || die
}

qt_prepare() {
	local qt_src="${WORKDIR}"/Libraries/qtbase/src
	local qt_fun="${S}"/Telegram/lib_ui/ui/text/qtextitemint.cpp

	echo "#include <QtGui/private/qtextengine_p.h>" > "${qt_fun}"

	sed '/^QTextItemInt::QTextItemInt.*QGlyphLayout/,/^\}/!d' \
		"${qt_src}"/gui/text/qtextengine.cpp >> "${qt_fun}"

	sed '/^void.*QTextItemInt::initWithScriptItem.*QScriptItem/,/^\}/!d' \
		"${qt_src}"/gui/text/qtextengine.cpp >> "${qt_fun}"

}

src_prepare() {
	qt_prepare

	cp "${FILESDIR}"/breakpad.cmake \
		cmake/external/crash_reports/breakpad/CMakeLists.txt || die

	sed -i -e 's/if.*DESKTOP_APP_USE_PACKAGED.*/if(False)/' \
		cmake/external/{expected,gsl,ranges,rlottie,variant,xxhash}/CMakeLists.txt || die

	if use !alsa
	then
		sed -i -e '/alsa/Id' \
			Telegram/cmake/lib_tgvoip.cmake
	fi

	if use !pulseaudio
	then
		sed -i -e '/pulse/Id' \
			Telegram/cmake/lib_tgvoip.cmake
	fi

	# TDESKTOP_API_{ID,HASH} related:

	sed -i -e 's/if.*TDESKTOP_API_[A-Z]*.*/if(False)/' \
		Telegram/cmake/telegram_options.cmake || die

	sed -i -e '/TDESKTOP_API_[A-Z]*/d' \
		Telegram/CMakeLists.txt || die

	if use !custom-api-id
	then
		sed -i -e '/#error.*API_ID.*API_HASH/d' \
			Telegram/SourceFiles/config.h || die
	else
		local -A api_defs=(
			[ID]="#define TDESKTOP_API_ID ${TDESKTOP_API_ID}"
			[HASH]="#define TDESKTOP_API_HASH ${TDESKTOP_API_HASH}"
		)

		sed -i \
			-e "/#if.*defined.*TDESKTOP_API_ID/i ${api_defs[ID]}" \
			-e "/#if.*defined.*TDESKTOP_API_HASH/i ${api_defs[HASH]}" \
			Telegram/SourceFiles/config.h || die
	fi

	cmake_src_prepare
}

src_configure() {
	local mycxxflags=(
		-Wno-array-bounds
		-Wno-free-nonheap-object
		$(usex !alsa -DWITHOUT_ALSA '')
		$(usex !pulseaudio -DWITHOUT_PULSE '')
	)

	append-cxxflags ${mycxxflags[@]}

	local mycmakeargs=(
		-DDESKTOP_APP_QT6=OFF
		-DDESKTOP_APP_USE_PACKAGED=ON
		-DDESKTOP_APP_DISABLE_CRASH_REPORTS=$(usex !crashreporter)
		-DDESKTOP_APP_DISABLE_DBUS_INTEGRATION=$(usex !dbus)
		-DDESKTOP_APP_DISABLE_SPELLCHECK=$(usex !enchant $(usex !hunspell))
		-DDESKTOP_APP_DISABLE_WAYLAND_INTEGRATION=$(usex !wayland)
		-DDESKTOP_APP_DISABLE_X11_INTEGRATION=$(usex !X)
		-DDESKTOP_APP_USE_ENCHANT=$(usex enchant)
	)

	cmake_src_configure
}
