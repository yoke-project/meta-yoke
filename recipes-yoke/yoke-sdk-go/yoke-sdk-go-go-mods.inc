
# Written as go-mod-update-modules.bbclass writes it, from the module cache `go list -deps` fills for the
# harnesses the recipe builds. Written again, never by hand, when the version changes.

SRC_URI += "\
    gomod://github.com/yoke-project/yoke/proto;version=v0.4.0;sha256sum=2c8ebc82eb168c5998318698a8ce8a47766d067d2e5212445408146db1c68aea \
    gomod://go.yaml.in/yaml/v3;version=v3.0.5;sha256sum=f2d70caa35f66283aec58b889af8c5f07c374c5934be27a738c1215263e19205 \
    gomod://golang.org/x/net;version=v0.57.0;sha256sum=f8d652c629374b43846ef4f2efd419e8d1c81779eb728306d09f0de1cc1bab80 \
    gomod://golang.org/x/sys;version=v0.47.0;sha256sum=cdac013ddced0262926ec29ffcda645da39670e61c7e5b761e572b6b1809bb1b \
    gomod://golang.org/x/text;version=v0.40.0;sha256sum=07757384728d0f52dd85c1f3f163405e6396b2b0fb7eb7d6b610f2a711d69ee3 \
    gomod://google.golang.org/genproto/googleapis/rpc;version=v0.0.0-20260706201446-f0a921348800;sha256sum=42a0902eda416f038ae29a247e12a8932a566d8b18682ca8cd2d333a40c0f407 \
    gomod://google.golang.org/grpc;version=v1.84.0;sha256sum=a14bebefbac1ec115d9e1f8042006c185d65adf43a91644f3e58df0688831b95 \
    gomod://google.golang.org/protobuf;version=v1.36.12;sha256sum=68f8a3174aff42950fd9bd02c11b45c6986eb8060508d124d1c3dd6bf86b9be6 \
"
