# The crates the lock of yoke-sdk names, each at the version and checksum the lock records.

# from Cargo.lock
SRC_URI += " \
    crate://crates.io/anyhow/1.0.104 \
    crate://crates.io/asn1-rs/0.7.2 \
    crate://crates.io/asn1-rs-derive/0.6.0 \
    crate://crates.io/asn1-rs-impl/0.2.0 \
    crate://crates.io/async-trait/0.1.92 \
    crate://crates.io/atomic-waker/1.1.2 \
    crate://crates.io/autocfg/1.5.1 \
    crate://crates.io/axum/0.8.9 \
    crate://crates.io/axum-core/0.5.6 \
    crate://crates.io/base64/0.22.1 \
    crate://crates.io/base64/0.23.1 \
    crate://crates.io/bit-vec/0.9.1 \
    crate://crates.io/bitflags/2.13.2 \
    crate://crates.io/bytes/1.12.1 \
    crate://crates.io/cc/1.8.0 \
    crate://crates.io/cfg-if/1.0.5 \
    crate://crates.io/data-encoding/2.11.1 \
    crate://crates.io/der-parser/10.0.0 \
    crate://crates.io/deranged/0.5.9 \
    crate://crates.io/displaydoc/0.2.7 \
    crate://crates.io/either/1.18.0 \
    crate://crates.io/equivalent/1.0.2 \
    crate://crates.io/errno/0.3.14 \
    crate://crates.io/find-msvc-tools/0.1.14 \
    crate://crates.io/fnv/1.0.7 \
    crate://crates.io/futures-channel/0.3.34 \
    crate://crates.io/futures-core/0.3.34 \
    crate://crates.io/futures-sink/0.3.34 \
    crate://crates.io/futures-task/0.3.34 \
    crate://crates.io/futures-util/0.3.34 \
    crate://crates.io/getrandom/0.2.17 \
    crate://crates.io/h2/0.4.19 \
    crate://crates.io/hashbrown/0.17.1 \
    crate://crates.io/http/1.5.0 \
    crate://crates.io/http-body/1.1.0 \
    crate://crates.io/http-body-util/0.1.5 \
    crate://crates.io/httparse/1.10.1 \
    crate://crates.io/httpdate/1.0.3 \
    crate://crates.io/hyper/1.11.1 \
    crate://crates.io/hyper-timeout/0.5.2 \
    crate://crates.io/hyper-util/0.1.21 \
    crate://crates.io/indexmap/2.14.2 \
    crate://crates.io/itertools/0.14.0 \
    crate://crates.io/itoa/1.0.18 \
    crate://crates.io/lazy_static/1.5.1 \
    crate://crates.io/libc/0.2.189 \
    crate://crates.io/linux-raw-sys/0.12.1 \
    crate://crates.io/matchit/0.8.4 \
    crate://crates.io/memchr/2.8.3 \
    crate://crates.io/mime/0.3.17 \
    crate://crates.io/minimal-lexical/0.2.1 \
    crate://crates.io/mio/1.2.3 \
    crate://crates.io/nom/7.1.3 \
    crate://crates.io/num-bigint/0.4.8 \
    crate://crates.io/num-conv/0.2.2 \
    crate://crates.io/num-integer/0.1.47 \
    crate://crates.io/num-traits/0.2.19 \
    crate://crates.io/oid-registry/0.8.1 \
    crate://crates.io/once_cell/1.21.4 \
    crate://crates.io/pem/4.0.0 \
    crate://crates.io/percent-encoding/2.3.2 \
    crate://crates.io/pin-project/1.1.13 \
    crate://crates.io/pin-project-internal/1.1.13 \
    crate://crates.io/pin-project-lite/0.2.17 \
    crate://crates.io/powerfmt/0.2.1 \
    crate://crates.io/proc-macro2/1.0.107 \
    crate://crates.io/prost/0.14.4 \
    crate://crates.io/prost-derive/0.14.4 \
    crate://crates.io/prost-types/0.14.4 \
    crate://crates.io/quote/1.0.47 \
    crate://crates.io/rcgen/0.14.10 \
    crate://crates.io/ring/0.17.14 \
    crate://crates.io/rusticata-macros/4.1.0 \
    crate://crates.io/rustix/1.1.5 \
    crate://crates.io/rustls/0.23.46 \
    crate://crates.io/rustls-pki-types/1.15.1 \
    crate://crates.io/rustls-webpki/0.103.15 \
    crate://crates.io/serde/1.0.229 \
    crate://crates.io/serde_core/1.0.229 \
    crate://crates.io/serde_derive/1.0.229 \
    crate://crates.io/shlex/2.0.1 \
    crate://crates.io/signal-hook-registry/1.4.8 \
    crate://crates.io/slab/0.4.12 \
    crate://crates.io/smallvec/1.16.2 \
    crate://crates.io/socket2/0.6.5 \
    crate://crates.io/subtle/2.6.1 \
    crate://crates.io/syn/2.0.119 \
    crate://crates.io/syn/3.0.6 \
    crate://crates.io/sync_wrapper/1.0.2 \
    crate://crates.io/synstructure/0.13.2 \
    crate://crates.io/thiserror/2.0.21 \
    crate://crates.io/thiserror-impl/2.0.21 \
    crate://crates.io/time/0.3.55 \
    crate://crates.io/time-core/0.1.9 \
    crate://crates.io/time-macros/0.2.32 \
    crate://crates.io/tokio/1.53.1 \
    crate://crates.io/tokio-macros/2.7.2 \
    crate://crates.io/tokio-rustls/0.26.6 \
    crate://crates.io/tokio-stream/0.1.19 \
    crate://crates.io/tokio-util/0.7.19 \
    crate://crates.io/tonic/0.14.6 \
    crate://crates.io/tonic-prost/0.14.6 \
    crate://crates.io/tower/0.5.3 \
    crate://crates.io/tower-layer/0.3.3 \
    crate://crates.io/tower-service/0.3.3 \
    crate://crates.io/tracing/0.1.44 \
    crate://crates.io/tracing-attributes/0.1.31 \
    crate://crates.io/tracing-core/0.1.36 \
    crate://crates.io/try-lock/0.2.5 \
    crate://crates.io/unicode-ident/1.0.26 \
    crate://crates.io/untrusted/0.9.0 \
    crate://crates.io/want/0.3.1 \
    crate://crates.io/wasi/0.11.1+wasi-snapshot-preview1 \
    crate://crates.io/windows-link/0.2.1 \
    crate://crates.io/windows-sys/0.52.0 \
    crate://crates.io/windows-sys/0.61.2 \
    crate://crates.io/windows-targets/0.52.6 \
    crate://crates.io/windows_aarch64_gnullvm/0.52.6 \
    crate://crates.io/windows_aarch64_msvc/0.52.6 \
    crate://crates.io/windows_i686_gnu/0.52.6 \
    crate://crates.io/windows_i686_gnullvm/0.52.6 \
    crate://crates.io/windows_i686_msvc/0.52.6 \
    crate://crates.io/windows_x86_64_gnu/0.52.6 \
    crate://crates.io/windows_x86_64_gnullvm/0.52.6 \
    crate://crates.io/windows_x86_64_msvc/0.52.6 \
    crate://crates.io/x509-parser/0.18.1 \
    crate://crates.io/yasna/0.6.0 \
    crate://crates.io/yoke-proto/0.4.0 \
    crate://crates.io/zeroize/1.9.1 \
"

SRC_URI[anyhow-1.0.104.sha256sum] = "330a5ed07fa54e4702c9d6c4174f74427fc0ef6e214bbd677ae50a5099946470"
SRC_URI[asn1-rs-0.7.2.sha256sum] = "b7f43a50ac4fdca5df8e885c21b835997f0a1cdee65494a6847694a98652d9d8"
SRC_URI[asn1-rs-derive-0.6.0.sha256sum] = "3109e49b1e4909e9db6515a30c633684d68cdeaa252f215214cb4fa1a5bfee2c"
SRC_URI[asn1-rs-impl-0.2.0.sha256sum] = "7b18050c2cd6fe86c3a76584ef5e0baf286d038cda203eb6223df2cc413565f7"
SRC_URI[async-trait-0.1.92.sha256sum] = "82f6aeea286b8eb4dd3431a1be1b59d290ace00f5bfd8e2a159bc2a05e2c1667"
SRC_URI[atomic-waker-1.1.2.sha256sum] = "1505bd5d3d116872e7271a6d4e16d81d0c8570876c8de68093a09ac269d8aac0"
SRC_URI[autocfg-1.5.1.sha256sum] = "f2032f911046de80f0a198e0901378627c33f59ea0ac00e363d481118bd70a53"
SRC_URI[axum-0.8.9.sha256sum] = "31b698c5f9a010f6573133b09e0de5408834d0c82f8d7475a89fc1867a71cd90"
SRC_URI[axum-core-0.5.6.sha256sum] = "08c78f31d7b1291f7ee735c1c6780ccde7785daae9a9206026862dab7d8792d1"
SRC_URI[base64-0.22.1.sha256sum] = "72b3254f16251a8381aa12e40e3c4d2f0199f8c6508fbecb9d91f575e0fbb8c6"
SRC_URI[base64-0.23.1.sha256sum] = "ac07cdecf99051d9a5238b80f35af32cdeba5b336e55d957b318b50137e18da5"
SRC_URI[bit-vec-0.9.1.sha256sum] = "b71798fca2c1fe1086445a7258a4bc81e6e49dcd24c8d0dd9a1e57395b603f51"
SRC_URI[bitflags-2.13.2.sha256sum] = "3ded4057c258ba199e2d26386d3af3780957ecaee6c4ef4041c6b4b8b97c0b06"
SRC_URI[bytes-1.12.1.sha256sum] = "fc652a48c352aef3ea3aed32080501cf3ef6ed5da78602a020c991775b0aff04"
SRC_URI[cc-1.8.0.sha256sum] = "6651c9ed80effdc7db0ff72512157f901af5e3549e341e24b1dd4887d836d838"
SRC_URI[cfg-if-1.0.5.sha256sum] = "4e7648175b45a9a48536d676f68d918270699102aa8dab5496df06904c914600"
SRC_URI[data-encoding-2.11.1.sha256sum] = "4583a4551df46e2792f82ceeac45e850d2e2d5debba0b91f102385cda5b11f06"
SRC_URI[der-parser-10.0.0.sha256sum] = "07da5016415d5a3c4dd39b11ed26f915f52fc4e0dc197d87908bc916e51bc1a6"
SRC_URI[deranged-0.5.9.sha256sum] = "9e9de72ce2ad1f90dc62fa25f0f430ef85eb4b0d8fa0be4f30373bc40a21d28e"
SRC_URI[displaydoc-0.2.7.sha256sum] = "c6232dd377dcc64799954cbd3a9bb882e9cdc1308ccd87b1c098f1fb2eaf82a8"
SRC_URI[either-1.18.0.sha256sum] = "252afb9ae5eaa683babdc6a068b3f5726eb19e05070c731f9b2a23a7c3e8ed34"
SRC_URI[equivalent-1.0.2.sha256sum] = "877a4ace8713b0bcf2a4e7eec82529c029f1d0619886d18145fea96c3ffe5c0f"
SRC_URI[errno-0.3.14.sha256sum] = "39cab71617ae0d63f51a36d69f866391735b51691dbda63cf6f96d042b63efeb"
SRC_URI[find-msvc-tools-0.1.14.sha256sum] = "aedcfb3409746eddb02b9e19ebda1c3394f759a152e48ee875a0844d1b955484"
SRC_URI[fnv-1.0.7.sha256sum] = "3f9eec918d3f24069decb9af1554cad7c880e2da24a9afd88aca000531ab82c1"
SRC_URI[futures-channel-0.3.34.sha256sum] = "b1f9e3d69d39e4862ffed03ed071a76f9a13ba1d9109d355b0f0aa6b15e393c4"
SRC_URI[futures-core-0.3.34.sha256sum] = "92d699e522242e69e3003b94ecc1f960f3a5e015aa7c5d7486e65ad01dd94f5e"
SRC_URI[futures-sink-0.3.34.sha256sum] = "1944426bf7d03f1d14f708785e4b33efd750b36d48a157b836b3efc15ede8e1d"
SRC_URI[futures-task-0.3.34.sha256sum] = "cd417de3d1d015fc3bfd2b1ea46dfc7bab72ef86f1cc7cc9c78e728b34a6d1fd"
SRC_URI[futures-util-0.3.34.sha256sum] = "0d50a92467f8ba5dd6e3ee5d4bd04d73ab2e4e1c44474a0674821dfce14b79bc"
SRC_URI[getrandom-0.2.17.sha256sum] = "ff2abc00be7fca6ebc474524697ae276ad847ad0a6b3faa4bcb027e9a4614ad0"
SRC_URI[h2-0.4.19.sha256sum] = "ef8e5e5a340588f4452631496976cf8636d4a7ecf600239fdc27615d2530bc16"
SRC_URI[hashbrown-0.17.1.sha256sum] = "ed5909b6e89a2db4456e54cd5f673791d7eca6732202bbf2a9cc504fe2f9b84a"
SRC_URI[http-1.5.0.sha256sum] = "918d3568bebf352712bc2ef3d46a8bcf1a75b373be6539de198e9105cbbf9ce0"
SRC_URI[http-body-1.1.0.sha256sum] = "ca2a8f2913ee65f60facd6a5905613afaa448497a0230cc41ce022d93290bc2c"
SRC_URI[http-body-util-0.1.5.sha256sum] = "23169fe34a5fbcdd3f3862e78fb9b6fccd5f02a6dc6f732547005d45631ce71c"
SRC_URI[httparse-1.10.1.sha256sum] = "6dbf3de79e51f3d586ab4cb9d5c3e2c14aa28ed23d180cf89b4df0454a69cc87"
SRC_URI[httpdate-1.0.3.sha256sum] = "df3b46402a9d5adb4c86a0cf463f42e19994e3ee891101b1841f30a545cb49a9"
SRC_URI[hyper-1.11.1.sha256sum] = "27b501faa50e7a26c3d3560ca625132f4078a17771f4810baf70475ae48cbe43"
SRC_URI[hyper-timeout-0.5.2.sha256sum] = "2b90d566bffbce6a75bd8b09a05aa8c2cb1fabb6cb348f8840c9e4c90a0d83b0"
SRC_URI[hyper-util-0.1.21.sha256sum] = "ddc03d96684f9226b8a787cdb71488417b53ab5ea8fdb1dac946cb9431cc8bff"
SRC_URI[indexmap-2.14.2.sha256sum] = "cc4e190f5d26ca7051642629da2c52fc03bde85a03197c99408dcd291734c855"
SRC_URI[itertools-0.14.0.sha256sum] = "2b192c782037fadd9cfa75548310488aabdbf3d2da73885b31bd0abd03351285"
SRC_URI[itoa-1.0.18.sha256sum] = "8f42a60cbdf9a97f5d2305f08a87dc4e09308d1276d28c869c684d7777685682"
SRC_URI[lazy_static-1.5.1.sha256sum] = "20870f649af7073d53e38067b2a84312175d56ea15217e1b15bc83506ec50afb"
SRC_URI[libc-0.2.189.sha256sum] = "3eaf3ede3fee6db1a4c2ee091bf8a8b4dccdc6d17f656fb07896ee72867612f2"
SRC_URI[linux-raw-sys-0.12.1.sha256sum] = "32a66949e030da00e8c7d4434b251670a91556f4144941d37452769c25d58a53"
SRC_URI[matchit-0.8.4.sha256sum] = "47e1ffaa40ddd1f3ed91f717a33c8c0ee23fff369e3aa8772b9605cc1d22f4c3"
SRC_URI[memchr-2.8.3.sha256sum] = "cf8baf1c55e62ffcace7a9f06f4bd9cd3f0c4beb022d3b367256b91b87513d98"
SRC_URI[mime-0.3.17.sha256sum] = "6877bb514081ee2a7ff5ef9de3281f14a4dd4bceac4c09388074a6b5df8a139a"
SRC_URI[minimal-lexical-0.2.1.sha256sum] = "68354c5c6bd36d73ff3feceb05efa59b6acb7626617f4962be322a825e61f79a"
SRC_URI[mio-1.2.3.sha256sum] = "4b18443e9c262bfe8fa82f51666e2642c53393f7e5c27b3e1aeab922cff5b9d8"
SRC_URI[nom-7.1.3.sha256sum] = "d273983c5a657a70a3e8f2a01329822f3b8c8172b73826411a55751e404a0a4a"
SRC_URI[num-bigint-0.4.8.sha256sum] = "c89e69e7e0f03bea5ef08013795c25018e101932225a656383bd384495ecc367"
SRC_URI[num-conv-0.2.2.sha256sum] = "521739c6d2bac4aa25192232afe6841231376b2b26d4d9fae5ecf8ca5772e441"
SRC_URI[num-integer-0.1.47.sha256sum] = "7ce2d95d4b3734dc35aa2f45e1aa22cd416814592a4f9d9205e11affd5b8e10b"
SRC_URI[num-traits-0.2.19.sha256sum] = "071dfc062690e90b734c0b2273ce72ad0ffa95f0c74596bc250dcfd960262841"
SRC_URI[oid-registry-0.8.1.sha256sum] = "12f40cff3dde1b6087cc5d5f5d4d65712f34016a03ed60e9c08dcc392736b5b7"
SRC_URI[once_cell-1.21.4.sha256sum] = "9f7c3e4beb33f85d45ae3e3a1792185706c8e16d043238c593331cc7cd313b50"
SRC_URI[pem-4.0.0.sha256sum] = "d354a98a3d1251555de99e8fdd8afda05573c31b82f59063a7b0a29b5527f120"
SRC_URI[percent-encoding-2.3.2.sha256sum] = "9b4f627cb1b25917193a259e49bdad08f671f8d9708acfd5fe0a8c1455d87220"
SRC_URI[pin-project-1.1.13.sha256sum] = "2466b2336ed02bcdca6b294417127b90ec92038d1d5c4fbeac971a922e0e0924"
SRC_URI[pin-project-internal-1.1.13.sha256sum] = "c96395f0a926bc13b1c17622aaddda1ecb55d49c8f1bf9777e4d877800a43f8b"
SRC_URI[pin-project-lite-0.2.17.sha256sum] = "a89322df9ebe1c1578d689c92318e070967d1042b512afbe49518723f4e6d5cd"
SRC_URI[powerfmt-0.2.1.sha256sum] = "4a6394b9e965e73d0a289ee54f589087e2c676aedf60885baf52c76b771e4958"
SRC_URI[proc-macro2-1.0.107.sha256sum] = "985e7ec9bb745e6ce6535b544d84d6cd6f7ad8bd711c398938ae983b91a766d9"
SRC_URI[prost-0.14.4.sha256sum] = "528ac67416ff8646872a3c02cad9cc4ee5dc9f9540c9b10771855c95cb2e5ae1"
SRC_URI[prost-derive-0.14.4.sha256sum] = "b570b25f7617e43d59005d0990ccb79e950a423952cea19671b7a876da390adf"
SRC_URI[prost-types-0.14.4.sha256sum] = "f94967dc7688f3054c7fac87473ffae4cc4c3904800e2d9f5b857246d8963b0a"
SRC_URI[quote-1.0.47.sha256sum] = "1fbf4db142a473a8d80c26bbf18454ed458bf8d26c8219c331daecfdbd079001"
SRC_URI[rcgen-0.14.10.sha256sum] = "8774e05a7d0de114588e6a28fe7e71694b82614ed569d86d8b389dfbc98b8ad8"
SRC_URI[ring-0.17.14.sha256sum] = "a4689e6c2294d81e88dc6261c768b63bc4fcdb852be6d1352498b114f61383b7"
SRC_URI[rusticata-macros-4.1.0.sha256sum] = "faf0c4a6ece9950b9abdb62b1cfcf2a68b3b67a10ba445b3bb85be2a293d0632"
SRC_URI[rustix-1.1.5.sha256sum] = "891efababe418670775f199f0d233d84843c227a0949a883ce15b37c78d6629d"
SRC_URI[rustls-0.23.46.sha256sum] = "48e13bd8c0e9365c43cfa5c9e8f9ad49d3c8444926c9aac819e0e4dc503c8fdf"
SRC_URI[rustls-pki-types-1.15.1.sha256sum] = "2f4925028c7eb5d1fcdaf196971378ed9d2c1c4efc7dc5d011256f76c99c0a96"
SRC_URI[rustls-webpki-0.103.15.sha256sum] = "f3c3cf1d8b1e7d4927e2d154c3fcb02979afb9939629c62cd9048d4f07b60ac2"
SRC_URI[serde-1.0.229.sha256sum] = "4148590afebada386688f18773da617792bf2ef03ffc1e4cbd2b1d45b023e0ba"
SRC_URI[serde_core-1.0.229.sha256sum] = "67dca2c9c51e58a4791a4b1ed58308b39c64224d349a935ab5039aa360942a48"
SRC_URI[serde_derive-1.0.229.sha256sum] = "e7a5d71263a5a7d47b41f6b3f06ba276f10cc18b0931f1799f710578e2309348"
SRC_URI[shlex-2.0.1.sha256sum] = "f8fadd59c855ef2080decdef8ff161eb6661b86933c9d82e5ba29dc602a55aba"
SRC_URI[signal-hook-registry-1.4.8.sha256sum] = "c4db69cba1110affc0e9f7bcd48bbf87b3f4fc7c61fc9155afd4c469eb3d6c1b"
SRC_URI[slab-0.4.12.sha256sum] = "0c790de23124f9ab44544d7ac05d60440adc586479ce501c1d6d7da3cd8c9cf5"
SRC_URI[smallvec-1.16.2.sha256sum] = "f9395f0f0eee849a9b707b2f06bb92a6a422090e2123bb2ef8e87a0e61892a8e"
SRC_URI[socket2-0.6.5.sha256sum] = "c3d1e2c7f27f8d4cb10542a02c49005dbd6e93095799d6f3be745fae9f8fedd4"
SRC_URI[subtle-2.6.1.sha256sum] = "13c2bddecc57b384dee18652358fb23172facb8a2c51ccc10d74c157bdea3292"
SRC_URI[syn-2.0.119.sha256sum] = "872831b642d1a07999a962a351ed35b955ea2cfc8f3862091e2a240a84f17297"
SRC_URI[syn-3.0.6.sha256sum] = "8593e8e72159ed2257d083c7a454a85cbf854f37a0966d8d483aff8c8a3ebcee"
SRC_URI[sync_wrapper-1.0.2.sha256sum] = "0bf256ce5efdfa370213c1dabab5935a12e49f2c58d15e9eac2870d3b4f27263"
SRC_URI[synstructure-0.13.2.sha256sum] = "728a70f3dbaf5bab7f0c4b1ac8d7ae5ea60a4b5549c8a5914361c99147a709d2"
SRC_URI[thiserror-2.0.21.sha256sum] = "09e52cb86a36cede5cb101bf8908837b3e4c6e5e59fe7fd85c23fb56200d189e"
SRC_URI[thiserror-impl-2.0.21.sha256sum] = "fe5197923287db20a58125f0bc85c062f7f2c892de97b18c356f9efb14b28524"
SRC_URI[time-0.3.55.sha256sum] = "cdb87b95ec50ddfa440816d227a17b2ccbdda963a316a727fda0fc4334f7d134"
SRC_URI[time-core-0.1.9.sha256sum] = "9e1c906769ad99c88eaa54e728060edef082f8e358ff32030cb7c7d315e81109"
SRC_URI[time-macros-0.2.32.sha256sum] = "7e689342a48d2ea927c87ea50cabf8594854bf940e9310208848d680d668ed85"
SRC_URI[tokio-1.53.1.sha256sum] = "202caea871b69668250d242070849eb495be178ed697a3e98aebce5bc81a0bed"
SRC_URI[tokio-macros-2.7.2.sha256sum] = "78773a2a397f451582ce068015985c33193cf6dea8b74d2a639fe457b2f07b0e"
SRC_URI[tokio-rustls-0.26.6.sha256sum] = "c9cc2678c2cdd569ef8215e2afd7954ada2ae20b4fdd2c5fe6139a3b02d105db"
SRC_URI[tokio-stream-0.1.19.sha256sum] = "a3d06f0b082ba57c26b79407372e57cf2a1e28124f78e9479fe80322cf53420b"
SRC_URI[tokio-util-0.7.19.sha256sum] = "494815d09bf52b5548659851081238f0ca39ff638363907596da739561c62c52"
SRC_URI[tonic-0.14.6.sha256sum] = "ac2a5518c70fa84342385732db33fb3f44bc4cc748936eb5833d2df34d6445ef"
SRC_URI[tonic-prost-0.14.6.sha256sum] = "50849f68853be452acf590cde0b146665b8d507b3b8af17261df47e02c209ea0"
SRC_URI[tower-0.5.3.sha256sum] = "ebe5ef63511595f1344e2d5cfa636d973292adc0eec1f0ad45fae9f0851ab1d4"
SRC_URI[tower-layer-0.3.3.sha256sum] = "121c2a6cda46980bb0fcd1647ffaf6cd3fc79a013de288782836f6df9c48780e"
SRC_URI[tower-service-0.3.3.sha256sum] = "8df9b6e13f2d32c91b9bd719c00d1958837bc7dec474d94952798cc8e69eeec3"
SRC_URI[tracing-0.1.44.sha256sum] = "63e71662fa4b2a2c3a26f570f037eb95bb1f85397f3cd8076caed2f026a6d100"
SRC_URI[tracing-attributes-0.1.31.sha256sum] = "7490cfa5ec963746568740651ac6781f701c9c5ea257c58e057f3ba8cf69e8da"
SRC_URI[tracing-core-0.1.36.sha256sum] = "db97caf9d906fbde555dd62fa95ddba9eecfd14cb388e4f491a66d74cd5fb79a"
SRC_URI[try-lock-0.2.5.sha256sum] = "e421abadd41a4225275504ea4d6566923418b7f05506fbc9c0fe86ba7396114b"
SRC_URI[unicode-ident-1.0.26.sha256sum] = "d245f478577f809a851594d02313b640fb437e0bb33866753cff937863096954"
SRC_URI[untrusted-0.9.0.sha256sum] = "8ecb6da28b8a351d773b68d5825ac39017e680750f980f3a1a85cd8dd28a47c1"
SRC_URI[want-0.3.1.sha256sum] = "bfa7760aed19e106de2c7c0b581b509f2f25d3dacaf737cb82ac61bc6d760b0e"
SRC_URI[wasi-0.11.1+wasi-snapshot-preview1.sha256sum] = "ccf3ec651a847eb01de73ccad15eb7d99f80485de043efb2f370cd654f4ea44b"
SRC_URI[windows-link-0.2.1.sha256sum] = "f0805222e57f7521d6a62e36fa9163bc891acd422f971defe97d64e70d0a4fe5"
SRC_URI[windows-sys-0.52.0.sha256sum] = "282be5f36a8ce781fad8c8ae18fa3f9beff57ec1b52cb3de0789201425d9a33d"
SRC_URI[windows-sys-0.61.2.sha256sum] = "ae137229bcbd6cdf0f7b80a31df61766145077ddf49416a728b02cb3921ff3fc"
SRC_URI[windows-targets-0.52.6.sha256sum] = "9b724f72796e036ab90c1021d4780d4d3d648aca59e491e6b98e725b84e99973"
SRC_URI[windows_aarch64_gnullvm-0.52.6.sha256sum] = "32a4622180e7a0ec044bb555404c800bc9fd9ec262ec147edd5989ccd0c02cd3"
SRC_URI[windows_aarch64_msvc-0.52.6.sha256sum] = "09ec2a7bb152e2252b53fa7803150007879548bc709c039df7627cabbd05d469"
SRC_URI[windows_i686_gnu-0.52.6.sha256sum] = "8e9b5ad5ab802e97eb8e295ac6720e509ee4c243f69d781394014ebfe8bbfa0b"
SRC_URI[windows_i686_gnullvm-0.52.6.sha256sum] = "0eee52d38c090b3caa76c563b86c3a4bd71ef1a819287c19d586d7334ae8ed66"
SRC_URI[windows_i686_msvc-0.52.6.sha256sum] = "240948bc05c5e7c6dabba28bf89d89ffce3e303022809e73deaefe4f6ec56c66"
SRC_URI[windows_x86_64_gnu-0.52.6.sha256sum] = "147a5c80aabfbf0c7d901cb5895d1de30ef2907eb21fbbab29ca94c5b08b1a78"
SRC_URI[windows_x86_64_gnullvm-0.52.6.sha256sum] = "24d5b23dc417412679681396f2b49f3de8c1473deb516bd34410872eff51ed0d"
SRC_URI[windows_x86_64_msvc-0.52.6.sha256sum] = "589f6da84c646204747d1270a2a5661ea66ed1cced2631d546fdfb155959f9ec"
SRC_URI[x509-parser-0.18.1.sha256sum] = "d43b0f71ce057da06bc0851b23ee24f3f86190b07203dd8f567d0b706a185202"
SRC_URI[yasna-0.6.0.sha256sum] = "b5f6765e852b9b4dc8e2a76843e4d64d1cea8e79bcde0b6901aea8e7c7f08282"
SRC_URI[yoke-proto-0.4.0.sha256sum] = "0b60fb6a1d6e8c9ff4c72e962f92f65295159c3a3ba4092a8dc8ae0c248d4be1"
SRC_URI[zeroize-1.9.1.sha256sum] = "e13084392c5e4bc371903e2935a5eaeed24905a7511356b883835e18a78f6879"
