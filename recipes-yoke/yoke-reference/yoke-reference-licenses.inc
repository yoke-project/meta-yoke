
# Written as go-mod-update-modules.bbclass writes it: a licence of every module the programs are built from.
# Written again, never by hand, when the commit moves.

LICENSE += "& Apache-2.0 & BSD-3-Clause & MIT"

LIC_FILES_CHKSUM += "\
    file://pkg/mod/github.com/yoke-project/yoke-sdk-go@v0.4.0/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327;spdx=Apache-2.0 \
    file://pkg/mod/github.com/yoke-project/yoke-sdk-go@v0.6.0/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327;spdx=Apache-2.0 \
    file://pkg/mod/github.com/yoke-project/yoke/proto@v0.3.0/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327;spdx=Apache-2.0 \
    file://pkg/mod/github.com/yoke-project/yoke/proto@v0.4.0/LICENSE;md5=86d3f3a95c324c9479bd8986968f4327;spdx=Apache-2.0 \
    file://pkg/mod/go.yaml.in/yaml/v3@v3.0.5/LICENSE;md5=3c91c17266710e16afdbb2b6d15c761c;spdx=MIT+%26+Apache-2.0 \
    file://pkg/mod/golang.org/x/net@v0.57.0/LICENSE;md5=7998cb338f82d15c0eff93b7004d272a;spdx=BSD-3-Clause \
    file://pkg/mod/golang.org/x/sys@v0.47.0/LICENSE;md5=7998cb338f82d15c0eff93b7004d272a;spdx=BSD-3-Clause \
    file://pkg/mod/golang.org/x/text@v0.40.0/LICENSE;md5=7998cb338f82d15c0eff93b7004d272a;spdx=BSD-3-Clause \
    file://pkg/mod/google.golang.org/genproto/googleapis/rpc@v0.0.0-20260706201446-f0a921348800/LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57;spdx=Apache-2.0 \
    file://pkg/mod/google.golang.org/grpc@v1.84.0/LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57;spdx=Apache-2.0 \
    file://pkg/mod/google.golang.org/protobuf@v1.36.12/LICENSE;md5=02d4002e9171d41a8fad93aa7faf3956;spdx=BSD-3-Clause \
"
