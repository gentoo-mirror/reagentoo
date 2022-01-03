# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	addr2line-0.15.1
	adler-1.0.2
	aho-corasick-0.7.18
	ansi_term-0.11.0
	anyhow-1.0.40
	atk-0.9.0
	atk-sys-0.10.0
	atty-0.2.14
	autocfg-1.0.1
	backtrace-0.3.59
	base64-0.9.3
	base64-0.13.0
	bitflags-1.2.1
	block-buffer-0.9.0
	bumpalo-3.6.1
	byteorder-1.4.3
	bytes-0.4.12
	bytes-0.5.6
	bytes-1.0.1
	cairo-rs-0.9.1
	cairo-sys-rs-0.10.0
	cc-1.0.67
	cfg-if-0.1.10
	cfg-if-1.0.0
	clap-2.33.3
	console-0.14.1
	core-foundation-0.9.1
	core-foundation-sys-0.8.2
	cpufeatures-0.1.4
	digest-0.9.0
	directories-3.0.2
	dirs-sys-0.3.6
	either-1.6.1
	encode_unicode-0.3.6
	encoding_rs-0.8.28
	failure-0.1.8
	failure_derive-0.1.8
	fnv-1.0.7
	foreign-types-0.3.2
	foreign-types-shared-0.1.1
	form_urlencoded-1.0.1
	fuchsia-zircon-0.3.3
	fuchsia-zircon-sys-0.3.3
	futures-0.3.15
	futures-channel-0.3.15
	futures-core-0.3.15
	futures-executor-0.3.15
	futures-io-0.3.15
	futures-macro-0.3.15
	futures-sink-0.3.15
	futures-task-0.3.15
	futures-util-0.3.15
	gdk-0.13.2
	gdk-pixbuf-0.9.0
	gdk-pixbuf-sys-0.10.0
	gdk-sys-0.10.0
	generic-array-0.14.4
	getrandom-0.2.3
	gimli-0.24.0
	gio-0.9.1
	gio-sys-0.10.1
	glib-0.10.3
	glib-macros-0.10.1
	glib-sys-0.10.1
	gobject-sys-0.10.0
	gstreamer-0.16.7
	gstreamer-base-0.16.5
	gstreamer-base-sys-0.9.1
	gstreamer-player-0.16.5
	gstreamer-player-sys-0.9.1
	gstreamer-sys-0.9.1
	gstreamer-video-0.16.7
	gstreamer-video-sys-0.9.1
	gtk-0.9.2
	gtk-sys-0.10.0
	h2-0.2.7
	hashbrown-0.9.1
	heck-0.3.2
	hermit-abi-0.1.18
	http-0.2.4
	http-body-0.3.1
	httparse-1.4.1
	httpdate-0.3.2
	hyper-0.13.10
	hyper-old-types-0.11.0
	hyper-tls-0.4.3
	idna-0.2.3
	indexmap-1.6.2
	indicatif-0.13.0
	iovec-0.1.4
	ipnet-2.3.0
	itertools-0.9.0
	itoa-0.4.7
	js-sys-0.3.51
	kernel32-sys-0.2.2
	language-tags-0.2.2
	lazy_static-1.4.0
	libc-0.2.94
	log-0.4.14
	matches-0.1.8
	memchr-2.4.0
	mime-0.3.16
	mime_guess-2.0.3
	miniz_oxide-0.4.4
	mio-0.6.23
	miow-0.2.2
	muldiv-0.2.1
	native-tls-0.2.7
	net2-0.2.37
	num-integer-0.1.44
	num-rational-0.3.2
	num-traits-0.2.14
	num_cpus-1.13.0
	number_prefix-0.3.0
	object-0.24.0
	once_cell-1.7.2
	opaque-debug-0.3.0
	openssl-0.10.34
	openssl-probe-0.1.4
	openssl-sys-0.9.63
	pango-0.9.1
	pango-sys-0.10.0
	paste-1.0.5
	percent-encoding-1.0.1
	percent-encoding-2.1.0
	pin-project-1.0.7
	pin-project-internal-1.0.7
	pin-project-lite-0.1.12
	pin-project-lite-0.2.6
	pin-utils-0.1.0
	pkg-config-0.3.19
	ppv-lite86-0.2.10
	pretty-hex-0.2.1
	proc-macro-crate-0.1.5
	proc-macro-error-1.0.4
	proc-macro-error-attr-1.0.4
	proc-macro-hack-0.5.19
	proc-macro-nested-0.1.7
	proc-macro2-1.0.27
	quick-xml-0.17.2
	quote-1.0.9
	rand-0.8.3
	rand_chacha-0.3.0
	rand_core-0.6.2
	rand_hc-0.3.0
	redox_syscall-0.2.8
	redox_users-0.4.0
	regex-1.5.4
	regex-syntax-0.6.25
	remove_dir_all-0.5.3
	reqwest-0.10.10
	rustc-demangle-0.1.19
	ryu-1.0.5
	safemem-0.3.3
	schannel-0.1.19
	security-framework-2.2.0
	security-framework-sys-2.2.0
	self_update-0.16.0
	semver-0.9.0
	semver-parser-0.7.0
	serde-1.0.126
	serde_derive-1.0.126
	serde_json-1.0.64
	serde_urlencoded-0.7.0
	sha2-0.9.5
	slab-0.4.3
	socket2-0.3.19
	strsim-0.8.0
	structopt-0.3.21
	structopt-derive-0.4.14
	strum-0.18.0
	strum_macros-0.18.0
	syn-1.0.72
	synstructure-0.12.4
	system-deps-1.3.2
	tempfile-3.2.0
	terminal_size-0.1.17
	textwrap-0.11.0
	thiserror-1.0.25
	thiserror-impl-1.0.25
	time-0.1.43
	tinyvec-1.2.0
	tinyvec_macros-0.1.0
	tokio-0.2.25
	tokio-tls-0.3.1
	tokio-util-0.3.1
	toml-0.5.8
	tower-service-0.3.1
	tracing-0.1.26
	tracing-core-0.1.18
	tracing-futures-0.2.5
	try-lock-0.2.3
	typenum-1.13.0
	unicase-2.6.0
	unicode-bidi-0.3.5
	unicode-normalization-0.1.17
	unicode-segmentation-1.7.1
	unicode-width-0.1.8
	unicode-xid-0.2.2
	url-2.2.2
	vcpkg-0.2.13
	vec_map-0.8.2
	version-compare-0.0.10
	version_check-0.9.3
	want-0.3.0
	wasi-0.10.2+wasi-snapshot-preview1
	wasm-bindgen-0.2.74
	wasm-bindgen-backend-0.2.74
	wasm-bindgen-futures-0.4.24
	wasm-bindgen-macro-0.2.74
	wasm-bindgen-macro-support-0.2.74
	wasm-bindgen-shared-0.2.74
	web-sys-0.3.51
	winapi-0.2.8
	winapi-0.3.9
	winapi-build-0.1.1
	winapi-i686-pc-windows-gnu-0.4.0
	winapi-x86_64-pc-windows-gnu-0.4.0
	winreg-0.7.0
	ws2_32-sys-0.2.1
"

inherit cargo meson xdg

DESCRIPTION="Cross-platform media player based on GStreamer and GTK+"
HOMEPAGE="https://github.com/philn/glide"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/philn/${PN}.git"
	RESTRICT="network-sandbox"
	KEYWORDS=""
else
	SRC_URI="https://github.com/philn/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
		$(cargo_crate_uris ${CRATES})"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND="
	media-libs/gst-plugins-bad
	media-libs/gst-plugins-base
	media-plugins/gst-plugins-gtk
"
DEPEND="${RDEPEND}"

src_prepare() {
	default

	sed -i -e '/self-updater.*self_update/d' \
		Cargo.toml || die
	sed -i -e 's/\(Icon=.*\)\.svg/\1/' \
		data/net.baseart.Glide.desktop || die
	sed -i -e '/export.*CARGO_HOME/d' \
		scripts/cargo.sh || die
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
