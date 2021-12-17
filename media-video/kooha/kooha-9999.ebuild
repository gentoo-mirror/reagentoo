# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
	aho-corasick-0.7.18
	anyhow-1.0.44
	approx-0.5.0
	ashpd-0.2.0-alpha-4
	async-broadcast-0.3.4
	async-channel-1.6.1
	async-executor-1.4.1
	async-io-1.6.0
	async-lock-2.4.0
	async-recursion-0.3.2
	async-task-4.0.3
	atomic_refcell-0.1.7
	atty-0.2.14
	autocfg-1.0.1
	bitflags-1.2.1
	block-0.1.6
	byteorder-1.4.3
	cache-padded-1.1.1
	cairo-rs-0.14.7
	cairo-sys-rs-0.14.0
	cc-1.0.70
	cfg-expr-0.8.1
	cfg-expr-0.9.0
	cfg-if-1.0.0
	chrono-0.4.19
	color_quant-1.1.0
	concurrent-queue-1.2.2
	derivative-2.2.0
	dlib-0.5.0
	downcast-rs-1.2.0
	easy-parallel-3.1.0
	either-1.6.1
	enumflags2-0.6.4
	enumflags2_derive-0.6.4
	env_logger-0.7.1
	event-listener-2.5.1
	fastrand-1.5.0
	field-offset-0.3.4
	futures-0.3.17
	futures-channel-0.3.17
	futures-core-0.3.17
	futures-executor-0.3.17
	futures-io-0.3.17
	futures-lite-1.12.0
	futures-macro-0.3.17
	futures-sink-0.3.17
	futures-task-0.3.17
	futures-util-0.3.17
	gdk-pixbuf-0.14.0
	gdk-pixbuf-sys-0.14.0
	gdk4-0.3.0
	gdk4-sys-0.3.0
	gdk4-wayland-0.3.0
	gdk4-wayland-sys-0.3.0
	gdk4-x11-0.3.0
	gdk4-x11-sys-0.3.0
	getrandom-0.2.3
	gettext-rs-0.7.0
	gettext-sys-0.21.2
	gif-0.11.2
	gio-0.14.6
	gio-sys-0.14.0
	glib-0.14.5
	glib-macros-0.14.1
	glib-sys-0.14.0
	gobject-sys-0.14.0
	graphene-rs-0.14.0
	graphene-sys-0.14.0
	gsk4-0.3.0
	gsk4-sys-0.3.0
	gst-plugin-gif-0.7.2
	gst-plugin-version-helper-0.7.1
	gstreamer-0.17.4
	gstreamer-base-0.17.2
	gstreamer-base-sys-0.17.0
	gstreamer-sys-0.17.3
	gstreamer-video-0.17.2
	gstreamer-video-sys-0.17.0
	gtk4-0.3.0
	gtk4-macros-0.3.0
	gtk4-sys-0.3.0
	heck-0.3.3
	hermit-abi-0.1.19
	hex-0.4.3
	humantime-1.3.0
	instant-0.1.10
	itertools-0.10.1
	lazy_static-1.4.0
	libadwaita-0.1.0-alpha-5
	libadwaita-sys-0.1.0-alpha-5
	libc-0.2.102
	libloading-0.7.0
	libpulse-binding-2.25.0
	libpulse-sys-1.19.2
	locale_config-0.3.0
	log-0.4.14
	malloc_buf-0.0.6
	memchr-2.4.1
	memoffset-0.6.4
	muldiv-1.0.0
	nix-0.20.1
	nix-0.21.1
	num-derive-0.3.3
	num-integer-0.1.44
	num-rational-0.4.0
	num-traits-0.2.14
	objc-0.2.7
	objc-foundation-0.1.1
	objc_id-0.1.1
	once_cell-1.8.0
	pango-0.14.3
	pango-sys-0.14.0
	parking-2.0.0
	paste-1.0.5
	pest-2.1.3
	pin-project-lite-0.2.7
	pin-utils-0.1.0
	pkg-config-0.3.19
	polling-2.1.0
	ppv-lite86-0.2.10
	pretty-hex-0.2.1
	pretty_env_logger-0.4.0
	proc-macro-crate-1.1.0
	proc-macro-error-1.0.4
	proc-macro-error-attr-1.0.4
	proc-macro-hack-0.5.19
	proc-macro-nested-0.1.7
	proc-macro2-1.0.29
	pulsectl-rs-0.3.2
	quick-error-1.2.3
	quote-1.0.9
	rand-0.8.4
	rand_chacha-0.3.1
	rand_core-0.6.3
	rand_hc-0.3.1
	regex-1.5.4
	regex-syntax-0.6.25
	rustc_version-0.3.3
	scoped-tls-1.0.0
	semver-0.11.0
	semver-parser-0.10.2
	serde-1.0.130
	serde_derive-1.0.130
	serde_repr-0.1.7
	sha1-0.6.0
	slab-0.4.4
	slotmap-1.0.6
	smallvec-1.6.1
	socket2-0.4.2
	static_assertions-1.1.0
	strum-0.21.0
	strum_macros-0.21.1
	syn-1.0.76
	system-deps-3.2.0
	system-deps-4.0.0
	temp-dir-0.1.11
	termcolor-1.1.2
	thiserror-1.0.29
	thiserror-impl-1.0.29
	time-0.1.43
	toml-0.5.8
	tracing-0.1.28
	tracing-attributes-0.1.16
	tracing-core-0.1.20
	ucd-trie-0.1.3
	unicode-segmentation-1.8.0
	unicode-xid-0.2.2
	version-compare-0.0.11
	version_check-0.9.3
	waker-fn-1.1.0
	wasi-0.10.2+wasi-snapshot-preview1
	wayland-client-0.28.6
	wayland-commons-0.28.6
	wayland-scanner-0.28.6
	wayland-sys-0.28.6
	weezl-0.1.5
	wepoll-ffi-0.1.2
	winapi-0.3.9
	winapi-i686-pc-windows-gnu-0.4.0
	winapi-util-0.1.5
	winapi-x86_64-pc-windows-gnu-0.4.0
	x11-2.19.0
	xml-rs-0.8.4
	zbus-2.0.0-beta.6
	zbus_macros-2.0.0-beta.6
	zbus_names-1.0.0
	zvariant-2.8.0
	zvariant_derive-2.8.0
"

inherit cargo gnome2-utils meson xdg

MY_PN="${PN^}"

DESCRIPTION="Elegantly record your screen"
HOMEPAGE="https://github.com/SeaDve/Kooha"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/SeaDve/${MY_PN}.git"
	RESTRICT="network-sandbox"
	KEYWORDS=""
else
	SRC_URI="https://github.com/SeaDve/${MY_PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
		$(cargo_crate_uris ${CRATES})"
	KEYWORDS="~amd64 ~arm64 ~x86"
fi

LICENSE="GPL-3"
SLOT="0"

RDEPEND="
	>=dev-lang/python-3.7
	gnome-base/gnome-shell
	>=gui-libs/libadwaita-1.0.0_alpha_rc1
"
DEPEND="${RDEPEND}"
BDEPEND=""

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	default
	sed -i '/export[[:space:]]\+CARGO_HOME/d' build-aux/cargo.sh || die
}

src_configure() {
	meson_src_configure
}

src_compile() {
	export CARGO_HOME="${ECARGO_HOME}"
	meson_src_compile
}

src_install() {
	meson_src_install
}

src_test() {
	meson_src_test
}

pkg_postinst() {
	gnome2_schemas_update
	xdg_pkg_postrm
}

pkg_postrm() {
	gnome2_schemas_update
	xdg_pkg_postrm
}
