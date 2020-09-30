# Copyright 2017-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
aes-0.3.2
aes-ctr-0.3.0
aes-soft-0.3.3
aesni-0.6.0
ahash-0.2.18
aho-corasick-0.7.10
ansi_term-0.11.0
arrayref-0.3.6
arrayvec-0.5.1
assert_matches-1.3.0
attohttpc-0.4.5
atty-0.2.14
autocfg-0.1.7
autocfg-1.0.0
backtrace-0.3.45
backtrace-sys-0.1.34
base64-0.10.1
base64-0.12.0
base64-0.9.3
bincode-1.2.1
bindgen-0.53.2
bit-set-0.4.0
bit-vec-0.4.4
bitflags-1.2.1
bitvec-0.15.2
block-buffer-0.7.3
block-cipher-trait-0.6.2
block-modes-0.3.3
block-padding-0.1.5
bs58-0.3.0
bstr-0.2.12
build_const-0.2.1
bumpalo-3.2.0
byte-slice-cast-0.3.5
byte-tools-0.3.1
byteorder-1.3.4
bytes-0.4.12
cast-0.2.3
cc-1.0.41
cexpr-0.4.0
cfg-if-0.1.10
chrono-0.4.11
clang-sys-0.29.2
clap-2.33.0
cloudabi-0.0.3
cmake-0.1.42
const-random-0.1.8
const-random-macro-0.1.8
core-foundation-0.6.4
core-foundation-sys-0.6.2
crc-1.8.1
criterion-0.3.1
criterion-plot-0.4.1
crossbeam-deque-0.7.3
crossbeam-epoch-0.8.2
crossbeam-queue-0.2.1
crossbeam-utils-0.7.2
crunchy-0.2.2
crypto-mac-0.7.0
csv-1.1.3
csv-core-0.1.10
ct-logs-0.6.0
ctr-0.3.2
ctrlc-3.1.4
derive_more-0.99.3
difference-1.0.0
digest-0.8.1
docopt-1.1.0
edit-distance-2.1.0
either-1.5.3
elastic-array-0.10.3
enr-0.1.0-alpha.5
enum_primitive-0.1.1
env_logger-0.5.13
env_logger-0.6.2
env_logger-0.7.1
ethabi-12.0.0
ethabi-contract-11.0.0
ethabi-derive-12.0.0
ethbloom-0.9.0
ethereum-forkid-0.2.0
ethereum-types-0.9.0
failsafe-0.3.1
failure-0.1.7
failure_derive-0.1.7
fake-simd-0.1.2
fdlimit-0.1.4
fixed-hash-0.6.0
fnv-1.0.6
fs-swap-0.2.4
fs_extra-1.1.0
fuchsia-cprng-0.1.1
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.1.29
futures-cpupool-0.1.8
fxhash-0.2.1
generic-array-0.12.3
getrandom-0.1.14
glob-0.3.0
globset-0.4.5
h2-0.1.26
hamming-0.1.3
hash-db-0.15.2
hash256-std-hasher-0.15.2
hashbrown-0.6.3
heapsize-0.4.2
heck-0.3.1
hermit-abi-0.1.8
hex-0.4.2
hex-literal-0.2.1
hex-literal-impl-0.2.1
hmac-0.7.1
home-0.5.3
http-0.1.21
http-body-0.1.0
httparse-1.3.4
humantime-1.3.0
hyper-0.12.35
hyper-rustls-0.18.0
idna-0.1.5
idna-0.2.0
if_chain-0.1.3
igd-0.10.0
impl-codec-0.4.2
impl-rlp-0.2.1
impl-serde-0.3.0
impl-trait-for-tuples-0.1.3
indexmap-1.3.2
interleaved-ordered-0.1.1
iovec-0.1.4
ipnetwork-0.12.8
itertools-0.8.2
itoa-0.4.5
jemalloc-sys-0.3.2
jemallocator-0.3.2
js-sys-0.3.36
jsonrpc-core-14.0.5
jsonrpc-derive-14.0.5
jsonrpc-http-server-14.0.6
jsonrpc-ipc-server-14.0.7
jsonrpc-pubsub-14.0.6
jsonrpc-server-utils-14.0.5
jsonrpc-tcp-server-14.0.6
jsonrpc-ws-server-14.0.6
keccak-hash-0.5.1
keccak-hasher-0.15.2
kernel32-sys-0.2.2
kvdb-0.5.0
kvdb-memorydb-0.5.0
kvdb-rocksdb-0.7.0
lazy_static-1.4.0
lazycell-1.2.1
libc-0.2.68
libloading-0.5.2
librocksdb-sys-6.6.4
linked-hash-map-0.5.2
lock_api-0.1.5
lock_api-0.3.3
log-0.4.8
logos-0.7.7
logos-derive-0.7.7
lru-0.4.3
lru-cache-0.1.2
lunarity-lexer-0.2.1
maplit-1.0.2
matches-0.1.8
maybe-uninit-2.0.0
memchr-2.3.3
memmap-0.6.2
memoffset-0.5.4
memory-db-0.20.0
memory_units-0.3.0
mime-0.3.16
mime_guess-2.0.3
mio-0.6.21
mio-extras-2.0.6
mio-named-pipes-0.1.6
mio-uds-0.6.7
miow-0.2.1
miow-0.3.3
nan-preserving-float-0.1.0
natpmp-0.2.0
net2-0.2.33
nix-0.17.0
nom-5.1.1
num-0.1.42
num-bigint-0.1.44
num-integer-0.1.42
num-iter-0.1.40
num-traits-0.1.43
num-traits-0.2.11
num_cpus-1.12.0
number_prefix-0.2.8
ole32-sys-0.2.0
oorandom-11.1.0
opaque-debug-0.2.3
openssl-probe-0.1.2
order-stat-0.1.3
owning_ref-0.4.1
parity-bytes-0.1.2
parity-crypto-0.6.1
parity-daemonize-0.3.0
parity-path-0.1.3
parity-runtime-0.1.1
parity-scale-codec-1.2.0
parity-snappy-0.1.0
parity-snappy-sys-0.1.2
parity-tokio-ipc-0.4.0
parity-util-mem-0.6.0
parity-util-mem-derive-0.1.0
parity-wasm-0.31.3
parity-wordlist-1.3.1
parking_lot-0.10.0
parking_lot-0.6.4
parking_lot-0.9.0
parking_lot_core-0.3.1
parking_lot_core-0.6.2
parking_lot_core-0.7.0
pbkdf2-0.3.0
peeking_take_while-0.1.2
percent-encoding-1.0.1
percent-encoding-2.1.0
plain_hasher-0.2.3
plotters-0.2.12
ppv-lite86-0.2.6
pretty_assertions-0.1.2
primal-0.2.3
primal-bit-0.2.4
primal-check-0.2.3
primal-estimate-0.2.1
primal-sieve-0.2.9
primitive-types-0.7.0
proc-macro-crate-0.1.4
proc-macro-hack-0.5.14
proc-macro2-0.4.30
proc-macro2-1.0.9
pwasm-utils-0.6.2
quick-error-1.2.3
quote-0.6.13
quote-1.0.3
rand-0.4.6
rand-0.5.6
rand-0.6.5
rand-0.7.3
rand_chacha-0.1.1
rand_chacha-0.2.2
rand_core-0.3.1
rand_core-0.4.2
rand_core-0.5.1
rand_hc-0.1.0
rand_hc-0.2.0
rand_isaac-0.1.1
rand_jitter-0.1.4
rand_os-0.1.3
rand_pcg-0.1.2
rand_xorshift-0.1.1
rand_xorshift-0.2.0
rayon-1.3.0
rayon-core-1.7.0
rdrand-0.4.0
redox_syscall-0.1.56
regex-1.3.5
regex-automata-0.1.9
regex-syntax-0.6.17
remove_dir_all-0.5.2
ring-0.16.11
ripemd160-0.8.0
rlp-0.4.5
rlp-derive-0.1.0
rocksdb-0.13.0
rpassword-1.0.2
rprompt-1.0.5
rustc-demangle-0.1.16
rustc-hash-1.1.0
rustc-hex-2.1.0
rustc-serialize-0.3.24
rustc_version-0.2.3
rustls-0.16.0
rustls-native-certs-0.1.0
ryu-1.0.3
safemem-0.3.3
same-file-1.0.6
schannel-0.1.18
scopeguard-0.3.3
scopeguard-1.1.0
scrypt-0.2.0
sct-0.6.0
secp256k1-0.17.2
secp256k1-sys-0.1.2
security-framework-0.3.4
security-framework-sys-0.3.3
semver-0.9.0
semver-parser-0.7.0
serde-1.0.105
serde_derive-1.0.105
serde_json-1.0.48
sha-1-0.8.2
sha2-0.8.1
shell32-sys-0.1.2
shlex-0.1.1
slab-0.4.2
smallvec-0.6.13
smallvec-1.2.0
socket2-0.3.11
spin-0.5.2
stable_deref_trait-1.1.1
static_assertions-1.1.0
stream-cipher-0.3.2
string-0.2.1
strsim-0.8.0
strsim-0.9.3
subtle-1.0.0
subtle-2.2.2
syn-0.15.44
syn-1.0.17
synstructure-0.12.3
target_info-0.1.0
tempfile-3.1.0
term_size-0.3.1
termcolor-1.1.0
textwrap-0.11.0
thread_local-1.0.1
threadpool-1.7.1
time-0.1.42
timer-0.2.0
tiny-keccak-1.5.0
tiny-keccak-2.0.2
tinytemplate-1.0.3
tokio-0.1.22
tokio-buf-0.1.1
tokio-codec-0.1.2
tokio-current-thread-0.1.7
tokio-executor-0.1.10
tokio-fs-0.1.7
tokio-io-0.1.13
tokio-named-pipes-0.1.0
tokio-reactor-0.1.12
tokio-rustls-0.10.3
tokio-service-0.1.0
tokio-sync-0.1.8
tokio-tcp-0.1.4
tokio-threadpool-0.1.18
tokio-timer-0.2.13
tokio-udp-0.1.6
tokio-uds-0.2.6
toml-0.5.6
toolshed-0.6.3
trace-time-0.1.3
transaction-pool-2.0.3
transient-hashmap-0.4.1
trie-db-0.20.0
trie-standardmap-0.15.2
triehash-0.8.3
try-lock-0.2.2
typenum-1.11.2
uint-0.8.2
unicase-2.6.0
unicode-bidi-0.3.4
unicode-normalization-0.1.12
unicode-segmentation-1.6.0
unicode-width-0.1.7
unicode-xid-0.1.0
unicode-xid-0.2.0
untrusted-0.7.0
url-1.7.2
url-2.1.1
utf8-ranges-1.0.4
validator-0.8.0
validator_derive-0.8.0
vec_map-0.8.1
vergen-3.1.0
version_check-0.9.1
void-1.0.2
walkdir-2.3.1
want-0.2.0
wasi-0.9.0+wasi-snapshot-preview1
wasm-bindgen-0.2.59
wasm-bindgen-backend-0.2.59
wasm-bindgen-macro-0.2.59
wasm-bindgen-macro-support-0.2.59
wasm-bindgen-shared-0.2.59
wasmi-0.3.0
web-sys-0.3.36
webpki-0.21.2
which-3.1.1
winapi-0.2.8
winapi-0.3.8
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.3
winapi-x86_64-pc-windows-gnu-0.4.0
ws-0.9.1
ws2_32-sys-0.2.1
xdg-2.2.0
xml-rs-0.7.0
xmltree-0.8.0
zeroize-1.1.0
"

CRATES="
${CRATES}
bincode-0.6.0
byteorder-0.5.3
fixedbitset-0.1.4
libsecp256k1-0.3.5
ordermap-0.2.2
petgraph-0.4.5
rustc-hex-1.0.0
tempdir-0.3.7
thread-id-3.3.0
"

inherit cargo systemd user

DESCRIPTION="Fast and feature-rich multi-network Ethereum client."
HOMEPAGE="https://github.com/openethereum/openethereum"

if [[ ${PV} == 9999 ]]
then
	inherit git-r3
	EGIT_COMMIT="v3.0.1"
	EGIT_REPO_URI="https://github.com/openethereum/${PN}.git"
	KEYWORDS=""
else
	AD_COMMIT="0b37f9481ce29e9d5174ad185bca695b206368eb"
	BN_COMMIT="635c4cdd560bc0c8b262e6bf809dc709da8bcd7e"
	SS_COMMIT="02964410fc05d7f94a133c0a2e5632f386040854"

	SRC_URI="
		https://github.com/openethereum/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
		https://github.com/paritytech/app-dirs-rs/archive/${AD_COMMIT}.tar.gz -> app-dirs-rs-${AD_COMMIT::7}.tar.gz
		https://github.com/paritytech/bn/archive/${BN_COMMIT}.tar.gz -> bn-${BN_COMMIT::7}.tar.gz
		https://github.com/paritytech/secret-store/archive/${SS_COMMIT}.tar.gz -> secret-store-${SS_COMMIT::7}.tar.gz
		$(cargo_crate_uris ${CRATES})
	"

	KEYWORDS="~amd64 ~x86"
	RESTRICT="mirror"
fi

LICENSE="Apache-2.0 Apache-2.0 CC0-1.0 ISC MIT Unlicense"
SLOT="0"
IUSE="cli evm"

DEPEND=""
RDEPEND=""

pkg_setup() {
	enewgroup openethereum
	enewuser openethereum -1 -1 -1 openethereum
}

src_unpack() {
	if [[ ${PV} == 9999 ]]
	then
		git-r3_src_unpack
		cargo_live_src_unpack
		return
	fi

	cargo_src_unpack

	mv app-dirs-rs-${AD_COMMIT} \
		${P}/util/dir/app-dirs || die
	mv bn-${BN_COMMIT} \
		${P}/ethcore/builtin/bn || die
	mv secret-store-${SS_COMMIT} \
		${P}/secret-store || die
}

src_prepare() {
	default

	[[ ${PV} == 9999 ]] && return

	sed -i -e '/app_dirs/ s:git = ".*":path = "app-dirs":' \
		util/dir/Cargo.toml || die
	sed -i -e '/bn/ s:git = ".*":path = "bn":' \
		ethcore/builtin/Cargo.toml || die
	sed -i -e '/parity-secretstore/ s:git = ".*":path = "secret-store":' \
		Cargo.toml || die
}

src_compile() {
	local mypackages=(
		openethereum
		$(usex evm evmbin '')
		$(usex cli ethkey-cli '')
		$(usex cli ethstore-cli '')
	)

	cargo_src_compile ${mypackages[@]/#/--package } --features final
}

src_install() {
	cargo_src_install
	use evm && dobin target/release/openethereum-evm
	use cli && dobin target/release/eth{key,store}

	insinto /etc/openethereum
	doins "${FILESDIR}/config.toml"

	newconfd "${FILESDIR}/${PN}-confd" "${PN}"
	newinitd "${FILESDIR}/${PN}-initd" "${PN}"

	systemd_dounit "${FILESDIR}"/openethereum-{system,user}.service

	keepdir /var/lib/openethereum
	fowners openethereum:openethereum /var/lib/openethereum
}
