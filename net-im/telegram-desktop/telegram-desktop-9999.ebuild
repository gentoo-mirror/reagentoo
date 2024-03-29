# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{7..10} )

inherit cmake flag-o-matic optfeature python-any-r1 toolchain-funcs xdg

DESCRIPTION="Official desktop client for Telegram"
HOMEPAGE="https://desktop.telegram.org"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3

	EGIT_BRANCH="dev"
	EGIT_REPO_URI="https://github.com/telegramdesktop/tdesktop.git"
	EGIT_SUBMODULES=(
		'*'
		'-Telegram/ThirdParty/hunspell'
		'-Telegram/ThirdParty/jemalloc'
		'-Telegram/ThirdParty/libdbusmenu-qt'
		'-Telegram/ThirdParty/lz4'
	)

	KEYWORDS=""
else
	MY_PN="tdesktop"
	MY_P="${MY_PN}-${PV}-full"

	ABSEIL_VER="20220623.1"
	CRC32C_VER="1.1.2"
	QTBASE_VER="5.15.2"

	LIBYUV_COMMIT="00950840d1c9bcbb3eb6ebc5aac5793e71166c8b"
	TG_OWT_COMMIT="5098730b9eb6173f0b52068fe2555b7c1015123a"

	SRC_URI="
		https://github.com/telegramdesktop/${MY_PN}/releases/download/v${PV}/${MY_P}.tar.gz

		https://github.com/abseil/abseil-cpp/archive/refs/tags/${ABSEIL_VER}.tar.gz -> abseil-cpp-${ABSEIL_VER}.tar.gz
		https://github.com/google/crc32c/archive/refs/tags/${CRC32C_VER}.tar.gz -> crc32c-${CRC32C_VER}.tar.gz
		https://download.qt.io/official_releases/qt/${QTBASE_VER%.*}/${QTBASE_VER}/submodules/qtbase-everywhere-src-${QTBASE_VER}.tar.xz

		https://gitlab.com/chromiumsrc/libyuv/-/archive/${LIBYUV_COMMIT}/libyuv-${LIBYUV_COMMIT}.tar.gz -> libyuv-${LIBYUV_COMMIT::7}.tar.gz
		https://github.com/desktop-app/tg_owt/archive/${TG_OWT_COMMIT}.tar.gz -> tg_owt-${TG_OWT_COMMIT::7}.tar.gz
	"

	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${MY_P}"
fi

LICENSE="BSD GPL-3-with-openssl-exception LGPL-2+"
SLOT="0"
IUSE="alsa crashreporter custom-api-id +dbus enchant +fonts +hunspell wayland +X"

REQUIRED_USE="
	enchant? ( !hunspell )
"

RDEPEND="
	!net-im/telegram-desktop-bin
	app-arch/lz4:=
	>=dev-cpp/abseil-cpp-20220623.1:=
	dev-libs/crc32c
	dev-libs/glib:2
	dev-libs/jemalloc:=[-lazy-lock]
	dev-libs/libevent:=
	dev-libs/openssl:=
	dev-libs/protobuf:=
	>=dev-qt/qtcore-5.15:5
	>=dev-qt/qtgui-5.15:5[dbus?,jpeg,png,wayland?,X?]
	>=dev-qt/qtimageformats-5.15:5
	>=dev-qt/qtnetwork-5.15:5[ssl]
	>=dev-qt/qtsvg-5.15:5
	>=dev-qt/qtwidgets-5.15:5[png,X?]
	kde-frameworks/kcoreaddons:=
	media-fonts/open-sans
	media-libs/fontconfig:=
	media-libs/libjpeg-turbo:=
	>=media-libs/libvpx-1.10.0:=
	media-libs/openal
	media-libs/openh264:=
	media-libs/opus:=
	media-libs/rnnoise
	media-sound/pulseaudio
	media-video/ffmpeg:=[opus]
	media-video/pipewire:=
	net-libs/usrsctp
	sys-libs/zlib:=[minizip]
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrender
	x11-libs/libXrandr
	x11-libs/libXtst
	alsa? ( media-libs/alsa-lib )
	crashreporter? ( dev-util/google-breakpad )
	dbus? ( dev-cpp/glibmm:2.68 )
	enchant? ( app-text/enchant:= )
	hunspell? ( >=app-text/hunspell-1.7:= )
	X? ( x11-libs/libxcb:= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	>=dev-util/cmake-3.16
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/tdesktop-4.3.4-qt5-incompatibility-2.patch"
	"${FILESDIR}/tdesktop-4.4.1-fix-dupe-main-decl.patch"
)

TG_OWT_PATCHES=(
	"${FILESDIR}/tg_owt-0_pre20220209-gcc-12-cstddef.patch"
	"${FILESDIR}/tg_owt-0_pre20220209-gcc-12-cstdint.patch"
)

# Current desktop-file-utils-0.26 does not understand Version=1.5
QA_DESKTOP_FILE="usr/share/applications/${PN}.desktop"

QTBASE_DIR="${WORKDIR}"/Libraries/qtbase
TG_OWT_DIR="${WORKDIR}"/Libraries/tg_owt

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
	EGIT_CHECKOUT_DIR="${QTBASE_DIR}"

	git-r3_src_unpack

	EGIT_REPO_URI="https://github.com/desktop-app/tg_owt.git"
	EGIT_CHECKOUT_DIR="${TG_OWT_DIR}"

	git-r3_src_unpack
}

src_unpack() {
	if [[ ${PV} == 9999 ]]
	then
		git_unpack
		return
	fi

	unpack "${MY_P}.tar.gz"

	local commit=$(
		cat "${MY_P}"/Telegram/build/docker/centos_env/Dockerfile \
			| sed '/^RUN.*git.*init.*tg_owt/,/git.*fetch/!d' \
			| tail -n1 | sed 's/.*\([0-9a-zA-Z]\{40\}\).*/\1/'
	)

	if [[ "${commit}" != "${TG_OWT_COMMIT}" ]]
	then
		die "You should update \${TG_OWT_COMMIT} to ${commit}"
	fi

	mkdir Libraries || die
	cd Libraries || die

	unpack "qtbase-everywhere-src-${QTBASE_VER}.tar.xz"
	mv "qtbase-everywhere-src-${QTBASE_VER}" "qtbase" || die

	unpack "tg_owt-${TG_OWT_COMMIT::7}.tar.gz"
	mv "tg_owt-${TG_OWT_COMMIT}" "tg_owt" || die

	cd "tg_owt/src/third_party" || die

	unpack "abseil-cpp-${ABSEIL_VER}.tar.gz"
	rmdir "abseil-cpp" || die
	mv "abseil-cpp-${ABSEIL_VER}" "abseil-cpp" || die

	unpack "crc32c-${CRC32C_VER}.tar.gz"
	rmdir "crc32c/src" || die
	mv "crc32c-${CRC32C_VER}" "crc32c/src" || die

	unpack "libyuv-${LIBYUV_COMMIT::7}.tar.gz"
	rmdir "libyuv" || die
	mv "libyuv-${LIBYUV_COMMIT}" "libyuv" || die
}

qt_prepare() {
	local qt_src="${QTBASE_DIR}"/src
	local qt_fun="${S}"/Telegram/lib_ui/ui/text/qtextitemint.cpp

	echo "#include <QtGui/private/qtextengine_p.h>" > "${qt_fun}"

	sed '/^QTextItemInt::QTextItemInt.*QGlyphLayout/,/^\}/!d' \
		"${qt_src}"/gui/text/qtextengine.cpp >> "${qt_fun}"

	sed '/^void.*QTextItemInt::initWithScriptItem.*QScriptItem/,/^\}/!d' \
		"${qt_src}"/gui/text/qtextengine.cpp >> "${qt_fun}"

}

tg_owt_prepare() {
	local PATCHES=( "${TG_OWT_PATCHES[@]}" )

	pushd "${TG_OWT_DIR}" >/dev/null || die

	sed -i -e '/include.*libopenh264/d' \
		CMakeLists.txt || die

	BUILD_DIR="${TG_OWT_DIR}/out" CMAKE_USE_DIR="${TG_OWT_DIR}" \
		cmake_src_prepare

	popd >/dev/null || die
}

src_prepare() {
	qt_prepare
	tg_owt_prepare

	cp "${FILESDIR}"/breakpad.cmake \
		cmake/external/crash_reports/breakpad/CMakeLists.txt || die

	sed -i -e 's:DESKTOP_APP_USE_PACKAGED:False:' \
		cmake/external/{expected,gsl,ranges,variant,xxhash}/CMakeLists.txt \
		Telegram/cmake/lib_tgvoip.cmake || die

	sed -i -e 's:find_package.*tg_owt:\0 PATHS ${libs_loc}/tg_owt/out:' \
		cmake/external/webrtc/CMakeLists.txt || die

	sed -i -e '/find_package/ s:Qt6::' \
		cmake/external/qt/package.cmake || die

	# TDESKTOP_API_{ID,HASH} related:

	sed -i -e 's:if.*TDESKTOP_API_[A-Z]*.*:if(False):' \
		Telegram/cmake/telegram_options.cmake || die

	sed -i -e '/TDESKTOP_API_[A-Z]*/d' \
		Telegram/CMakeLists.txt || die

	if use custom-api-id
	then
		local -A api_defs=(
			[ID]="#define TDESKTOP_API_ID ${TDESKTOP_API_ID}"
			[HASH]="#define TDESKTOP_API_HASH ${TDESKTOP_API_HASH}"
		)
	else
		local -A api_defs=(
			[ID]=$(
				cat snap/snapcraft.yaml \
					| ( grep TDESKTOP_API_ID || die ) \
					| sed 's:.*=\(.*\):#define TDESKTOP_API_ID \1:'
			)

			[HASH]=$(
				cat snap/snapcraft.yaml \
					| ( grep TDESKTOP_API_HASH || die ) \
					| sed 's:.*=\(.*\):#define TDESKTOP_API_HASH \1:'
			)
		)
	fi

	sed -i \
		-e "/#if.*defined.*TDESKTOP_API_ID/i ${api_defs[ID]}" \
		-e "/#if.*defined.*TDESKTOP_API_HASH/i ${api_defs[HASH]}" \
		Telegram/SourceFiles/config.h || die

	cmake_src_prepare
}

tg_owt_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DTG_OWT_BUILD_AUDIO_BACKENDS=OFF
		-DTG_OWT_USE_PROTOBUF=ON
	)

	BUILD_DIR="${TG_OWT_DIR}/out" CMAKE_USE_DIR="${TG_OWT_DIR}" \
		cmake_src_configure
}

src_configure() {
	local mycxxflags=(
		-Wno-array-bounds
		-Wno-free-nonheap-object
		-Wno-uninitialized
	)

	append-cxxflags ${mycxxflags[@]}

	tg_owt_configure

	local mycmakeargs=(
		-DDESKTOP_APP_USE_PACKAGED=ON
		-DDESKTOP_APP_USE_PACKAGED_RLOTTIE=OFF
		-DLIBTGVOIP_DISABLE_PULSEAUDIO=OFF

		-DDESKTOP_APP_DISABLE_CRASH_REPORTS=$(usex !crashreporter)
		-DDESKTOP_APP_DISABLE_DBUS_INTEGRATION=$(usex !dbus)
		-DDESKTOP_APP_DISABLE_SPELLCHECK=$(usex !enchant $(usex !hunspell))
		-DDESKTOP_APP_DISABLE_WAYLAND_INTEGRATION=$(usex !wayland)
		-DDESKTOP_APP_DISABLE_X11_INTEGRATION=$(usex !X)
		-DDESKTOP_APP_USE_ENCHANT=$(usex enchant)
		-DDESKTOP_APP_USE_PACKAGED_FONTS=$(usex !fonts)
		-DLIBTGVOIP_DISABLE_ALSA=$(usex !alsa)
	)

	cmake_src_configure
}

src_compile() {
	BUILD_DIR="${TG_OWT_DIR}/out" CMAKE_USE_DIR="${TG_OWT_DIR}" \
		cmake_src_compile

	cmake_src_compile
}

pkg_postinst() {
	xdg_pkg_postinst
	if has_version '<dev-qt/qtcore-5.15.2-r10'; then
		ewarn "Versions of dev-qt/qtcore lower than 5.15.2-r10 might cause telegram"
		ewarn "to crash when pasting big images from the clipboard."
	fi
	optfeature_header
	optfeature "shop payment support (requires USE=dbus enabled)" net-libs/webkit-gtk
}
