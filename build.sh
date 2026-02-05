# submodule
git submodule init && git submodule update --remote

# Define toolchain variables
CLANG_DIR=$PWD/toolchain/neutron_18
PATH=$CLANG_DIR/bin:$PATH

# Check if toolchain exists
if [ ! -f "$CLANG_DIR/bin/clang-18" ]; then
    echo "-----------------------------------------------"
    echo "Toolchain not found! Downloading..."
    echo "-----------------------------------------------"
    rm -rf $CLANG_DIR
    mkdir -p $CLANG_DIR
    pushd toolchain/neutron_18 > /dev/null
    bash <(curl -s "https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman") -S=05012024
    echo "-----------------------------------------------"
    echo "Patching toolchain..."
    echo "-----------------------------------------------"
    bash <(curl -s "https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman") --patch=glibc
    echo "-----------------------------------------------"
    echo "Cleaning up..."
    popd > /dev/null
fi

# build
MAKE_ARGS="
LLVM=1 \
LLVM_IAS=1 \
ARCH=arm64 \
O=out
"

make ${MAKE_ARGS} -j16 beyond0lte_defconfig gorhanhee.config || exit 1
make ${MAKE_ARGS} -j16 || exit 1

# # make flashable file
export LOCATION=$(pwd)
# cp ${LOCATION}/out/arch/arm64/boot/Image ${LOCATION}/gorhanhee/boot_img/build/unzip_boot/kernel
# cd gorhanhee/boot_img
# ./gradlew pack || exit 1
# cp $(pwd)/boot.img.signed ${LOCATION}/gorhanhee/boot.img

cp ${LOCATION}/out/arch/arm64/boot/Image ${LOCATION}/gorhanhee/AnyKernel3/Image

cd gorhanhee/AnyKernel3
zip -r beyond0lte_kernelsu.zip . -x "beyond0te_kernelsu.zip" 
