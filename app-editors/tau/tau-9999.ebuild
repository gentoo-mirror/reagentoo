# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	addr2line-0.16.0
	adler-1.0.2
	aho-corasick-0.7.18
	anymap-0.12.1
	atk-0.8.0
	atk-sys-0.9.1
	atty-0.2.14
	autocfg-1.0.1
	backtrace-0.3.61
	base64-0.10.1
	bincode-1.3.3
	bitflags-1.3.2
	block-buffer-0.7.3
	block-padding-0.1.5
	byte-tools-0.3.1
	bytecount-0.6.2
	byteorder-1.4.3
	cairo-rs-0.7.1
	cairo-rs-0.8.1
	cairo-sys-rs-0.9.2
	cc-1.0.69
	cfg-if-0.1.10
	cfg-if-1.0.0
	chashmap-2.2.2
	chrono-0.4.19
	cloudabi-0.0.3
	crc32fast-1.2.1
	crossbeam-channel-0.3.9
	crossbeam-channel-0.4.4
	crossbeam-utils-0.6.6
	crossbeam-utils-0.7.2
	digest-0.8.1
	dirs-2.0.2
	dirs-sys-0.3.6
	env_logger-0.7.1
	fake-simd-0.1.2
	filetime-0.2.15
	flate2-1.0.20
	fnv-1.0.7
	fsevent-0.4.0
	fsevent-sys-2.0.1
	fuchsia-cprng-0.1.1
	fuchsia-zircon-0.3.3
	fuchsia-zircon-sys-0.3.3
	futures-channel-0.3.16
	futures-core-0.3.16
	futures-executor-0.3.16
	futures-io-0.3.16
	futures-macro-0.3.16
	futures-task-0.3.16
	futures-util-0.3.16
	gdk-0.12.1
	gdk-pixbuf-0.8.0
	gdk-pixbuf-sys-0.9.1
	gdk-sys-0.9.1
	generic-array-0.12.4
	getrandom-0.2.3
	gettext-rs-0.4.4
	gettext-sys-0.19.9
	gimli-0.25.0
	gio-0.8.1
	gio-sys-0.9.1
	glib-0.8.2
	glib-0.9.3
	glib-sys-0.9.1
	gobject-sys-0.9.1
	gtk-0.8.1
	gtk-sys-0.9.2
	hermit-abi-0.1.19
	human-panic-1.0.3
	humantime-1.3.0
	inotify-0.7.1
	inotify-sys-0.1.5
	iovec-0.1.4
	itoa-0.4.7
	kernel32-sys-0.2.2
	lazy_static-1.4.0
	lazycell-1.3.0
	libc-0.2.99
	libhandy-0.5.0
	libhandy-sys-0.5.0
	line-wrap-0.1.1
	linked-hash-map-0.5.4
	locale_config-0.2.3
	lock_api-0.3.4
	log-0.4.14
	maybe-uninit-2.0.0
	memchr-2.4.1
	miniz_oxide-0.4.4
	mio-0.6.23
	mio-extras-2.0.6
	miow-0.2.2
	net2-0.2.37
	notify-5.0.0-pre.1
	num-integer-0.1.44
	num-traits-0.2.14
	object-0.26.1
	opaque-debug-0.2.3
	os_type-2.3.0
	owning_ref-0.3.3
	pango-0.7.0
	pango-0.8.0
	pango-sys-0.9.1
	pangocairo-0.8.0
	pangocairo-0.9.0
	pangocairo-sys-0.10.1
	parking_lot-0.4.8
	parking_lot-0.10.2
	parking_lot_core-0.2.14
	parking_lot_core-0.7.2
	pin-project-lite-0.2.7
	pin-utils-0.1.0
	pipe-0.3.0
	pkg-config-0.3.19
	plist-0.4.2
	proc-macro-hack-0.5.19
	proc-macro-nested-0.1.7
	proc-macro2-1.0.28
	quick-error-1.2.3
	quote-1.0.9
	rand-0.4.6
	rand_core-0.3.1
	rand_core-0.4.2
	rdrand-0.4.0
	redox_syscall-0.1.57
	redox_syscall-0.2.10
	redox_users-0.4.0
	regex-1.5.4
	regex-syntax-0.6.25
	rustc-demangle-0.1.20
	ryu-1.0.5
	safemem-0.3.3
	same-file-1.0.6
	scopeguard-1.1.0
	serde-1.0.127
	serde_derive-1.0.127
	serde_json-1.0.66
	sha2-0.8.2
	slab-0.4.4
	smallvec-0.6.14
	smallvec-1.6.1
	stable_deref_trait-1.2.0
	syn-1.0.74
	syntect-3.3.0
	termcolor-1.1.2
	time-0.1.43
	toml-0.5.8
	typenum-1.13.0
	unicode-segmentation-1.8.0
	unicode-xid-0.2.2
	uuid-0.8.2
	vte-rs-0.4.0
	vte-sys-0.2.2
	walkdir-2.3.2
	wasi-0.10.2+wasi-snapshot-preview1
	winapi-0.2.8
	winapi-0.3.9
	winapi-build-0.1.1
	winapi-i686-pc-windows-gnu-0.4.0
	winapi-util-0.1.5
	winapi-x86_64-pc-windows-gnu-0.4.0
	ws2_32-sys-0.2.1
	xml-rs-0.8.4
	yaml-rust-0.4.5
"

inherit cargo gnome2-utils meson xdg

DESCRIPTION="GTK frontend for the Xi text editor, written in Rust"
HOMEPAGE="https://gitlab.gnome.org/World/Tau"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_REPO_URI="https://gitlab.gnome.org/World/Tau.git"
	RESTRICT="network-sandbox"
	KEYWORDS=""
else
	COMMIT_HASH="14037a7f98f475d2497b74bd74a0430e"
	SRC_URI="https://gitlab.gnome.org/World/Tau/uploads/${COMMIT_HASH}/${P}.tar.xz
		$(cargo_crate_uris ${CRATES})"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND="
	gui-libs/libhandy:0.0/0
	x11-libs/vte
"
DEPEND="${RDEPEND}"
BDEPEND=""

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
