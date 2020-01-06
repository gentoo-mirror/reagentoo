# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{5,6,7} )
inherit cmake-utils flag-o-matic python-any-r1 toolchain-funcs \
	desktop xdg \
	git-r3

DESCRIPTION="Official desktop client for Telegram"
HOMEPAGE="https://desktop.telegram.org"

EGIT_REPO_URI="https://github.com/telegramdesktop/tdesktop.git"
EGIT_SUBMODULES=(
	'*'
	'-Telegram/ThirdParty/Catch'
	'-Telegram/ThirdParty/lz4'
)

if [[ ${PV} == 9999 ]]
then
	EGIT_BRANCH="dev"
	KEYWORDS=""
else
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~x86"

	QTBASE_VER="5.14.0"
	RANGE_V3_VER="0.10.0"
fi

LICENSE="GPL-3-with-openssl-exception"
SLOT="0"
IUSE="alsa crashreporter custom-api-id debug +effects gtk3 +pulseaudio +spell test"

REQUIRED_USE="
	|| ( alsa pulseaudio )
"

RDEPEND="
	app-arch/lz4
	app-arch/xz-utils
	dev-libs/openssl:0
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5[jpeg,png,xcb]
	dev-qt/qtnetwork:5
	dev-qt/qtimageformats:5
	dev-qt/qtwidgets:5[png,xcb]
	media-libs/openal
	media-libs/opus
	sys-libs/zlib[minizip]
	virtual/ffmpeg
	x11-libs/libva[X,drm]
	x11-libs/libX11
	!net-im/telegram-desktop-bin
	crashreporter? ( dev-util/google-breakpad )
	gtk3? (
		dev-libs/libappindicator:3
		x11-libs/gtk+:3
	)
	pulseaudio? ( media-sound/pulseaudio )
	spell? ( app-text/enchant )
	test? ( dev-cpp/catch )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

CMAKE_MIN_VERSION="3.16"

pkg_pretend() {
	if use custom-api-id
	then
		[[ -n "${TDESKTOP_API_ID}" ]] && \
		[[ -n "${TDESKTOP_API_HASH}" ]] && (
			einfo "Will be used custom 'api_id' and 'api_hash':"
			einfo "API_ID=${TDESKTOP_API_ID}"
			einfo "API_HASH=${TDESKTOP_API_HASH//[!\*]/*}"
		) || (
			eerror "It seems you did not set one or both of"
			eerror "TDESKTOP_API_ID and TDESKTOP_API_HASH variables,"
			eerror "which are required for custom-api-id USE-flag."
			eerror "You can set them either in your env or bashrc."
			die
		)
	fi

	if tc-is-gcc && [[ $(gcc-major-version) -lt 7 ]]
	then
		die "At least gcc 7.0 is required"
	fi
}

src_unpack() {
	git-r3_src_unpack

	unset EGIT_COMMIT
	unset EGIT_COMMIT_DATE
	unset EGIT_SUBMODULES

	EGIT_REPO_URI="https://code.qt.io/qt/qtbase.git"
	EGIT_CHECKOUT_DIR="${WORKDIR}"/Libraries/qtbase

	if [[ ${PV} == 9999 ]]
	then
		EGIT_COMMIT_DATE=$(GIT_DIR="${S}/.git" git show -s --format=%ct || die)
	else
		EGIT_COMMIT="v${QTBASE_VER}"
	fi

	git-r3_src_unpack

	EGIT_REPO_URI="https://github.com/ericniebler/range-v3.git"
	EGIT_CHECKOUT_DIR="${WORKDIR}"/Libraries/range-v3

	if [[ ${PV} == 9999 ]]
	then
		EGIT_COMMIT_DATE=$(GIT_DIR="${S}/.git" git show -s --format=%ct || die)
	else
		EGIT_COMMIT="${RANGE_V3_VER}"
	fi

	git-r3_src_unpack
}

qt_prepare() {
	local qt_src="${WORKDIR}"/Libraries/qtbase/src
	local qt_fun="${S}"/Telegram/SourceFiles/qt_functions.cpp

	echo "#include <QtGui/private/qtextengine_p.h>" > "${qt_fun}"

	sed -n '/^QStringList.*qt_make_filter_list.*QString/,/^\}$/p' \
		"${qt_src}"/widgets/dialogs/qfiledialog.cpp >> "${qt_fun}"

	sed -n '/^QTextItemInt::QTextItemInt.*QGlyphLayout/,/^\}$/p' \
		"${qt_src}"/gui/text/qtextengine.cpp >> "${qt_fun}"

	sed -n '/^void.*QTextItemInt::initWithScriptItem.*QScriptItem/,/^\}$/p' \
		"${qt_src}"/gui/text/qtextengine.cpp >> "${qt_fun}"
}

src_prepare() {
	qt_prepare

	cp "${FILESDIR}"/external.cmake cmake || die

	sed -i \
		-e '/add_subdirectory.*crash_reports/d' \
		-e '/add_subdirectory.*ffmpeg/d' \
		-e '/add_subdirectory.*lz4/d' \
		-e '/add_subdirectory.*openal/d' \
		-e '/add_subdirectory.*openssl/d' \
		-e '/add_subdirectory.*opus/d' \
		-e '/add_subdirectory.*qt/d' \
		-e '/add_subdirectory.*zlib/d' \
		cmake/external/CMakeLists.txt || die

	sed -i \
		-e '/LINK_SEARCH_START_STATIC/d' \
		cmake/init_target.cmake || die

	sed -i \
		-e '/include.*options/d' \
		cmake/options.cmake || die

	sed -i \
		-e 's:include.*cmake.*external.*:include(cmake/external.cmake):' \
		CMakeLists.txt || die

	sed -i \
		-e '/AL_ALEXT_PROTOTYPES/d' \
		-e '/AL_LIBTYPE_STATIC/d' \
		-e '/ayatana-appindicator/d' \
		-e '/third_party_loc.*minizip/d' \
		-e 's/qt_static_plugins\.cpp/qt_functions.cpp/' \
		-e 's/\(pkg_check_modules.*gtk+\)-2/\1-3/' \
		-e 's/\(pkg_check_modules.*APPIND[^[:space:]]\+\)/\1 REQUIRED/' \
		-e 's/if.*NOT[[:space:]]*build_macstore.*/if(False)/' \
		-e 's:\${output_folder}:${CMAKE_BINARY_DIR}/bin:' \
		Telegram/CMakeLists.txt || die

	local qt_plugins=/usr/$(get_libdir)/qt5/plugins
	local qt_add_lib_path="QCoreApplication::addLibraryPath(\"${qt_plugins}\");"

	sed -i \
		-e "/Launcher::init/a ${qt_add_lib_path}" \
		Telegram/SourceFiles/core/launcher.cpp || die

	sed -i \
		-e '1s:^:#include <QtCore/QVersionNumber>\n:' \
		Telegram/SourceFiles/platform/linux/notifications_manager_linux.cpp || die

	if use !crashreporter
	then
		sed -i -e '/external_crash_reports/d' \
			Telegram/lib_base/CMakeLists.txt || die
	else
		sed -i -e 's:\(#include.*\)\"\(client.*handler.*\)\":\1<\2>:' \
			Telegram/lib_base/base/crash_report_writer.cpp || die
	fi

	if use !custom-api-id
	then
		sed -i -e '/error.*API_ID.*API_HASH/d' \
			Telegram/SourceFiles/config.h || die
	else
		sed -i -e 's/if.*TDESKTOP_API_[A-Z]*.*/if(False)/' \
			Telegram/cmake/telegram_options.cmake || die

		sed -i -e 's/\(TDESKTOP_API_[A-Z]*=\$\)\({[_A-Z]*}\)/\1ENV\2/' \
			Telegram/CMakeLists.txt || die
	fi

	cmake-utils_src_prepare
}

src_configure() {
	local mycxxflags=(
		-Wno-deprecated-declarations
		-Wno-error=deprecated-declarations
		-Wno-switch
		$(usex !alsa -DWITHOUT_ALSA '')
		$(usex !pulseaudio -DWITHOUT_PULSE '')
	)

	append-cxxflags ${mycxxflags[@]}

	local mycmakeargs=(
		-DDESKTOP_APP_DISABLE_CRASH_REPORTS=$(usex !crashreporter)
		-DDESKTOP_APP_DISABLE_SPELLCHECK=$(usex !spell)
		-DTDESKTOP_API_TEST=$(usex !custom-api-id)
		-DTDESKTOP_DISABLE_DESKTOP_FILE_GENERATION=ON
		-DTDESKTOP_DISABLE_GTK_INTEGRATION=$(usex !gtk3)
		-DTDESKTOP_DISABLE_OPENAL_EFFECTS=$(usex !effects)
		-DTDESKTOP_FORCE_GTK_FILE_DIALOG=$(usex gtk3)
	)

	cmake-utils_src_configure
}

src_install() {
	newbin "${BUILD_DIR}"/bin/Telegram ${PN}
	domenu lib/xdg/telegramdesktop.desktop
	einstalldocs

	local icon_size
	for icon_size in 16 32 48 64 128 256 512
	do
		newicon -s ${icon_size} \
			Telegram/Resources/art/icon${icon_size}.png telegram.png
	done
}
