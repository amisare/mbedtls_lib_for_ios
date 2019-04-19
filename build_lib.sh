#!/bin/sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

VERSION_TAG="2.7.0"

create_directory() {
    rm -rf build/*
    rm -rf target/*
    mkdir -p build
    mkdir -p target/mbedtls/library/
    mkdir -p target/mbedtls/include/
    mkdir -p target/mbedtls_device/library/
    mkdir -p target/mbedtls_device/include/
    mkdir -p target/mbedtls_simulator/library/
    mkdir -p target/mbedtls_simulator/include/
}

fetch_mbedtls() {
    git clone https://github.com/ARMmbed/mbedtls.git mbedtls
    git -C mbedtls checkout mbedtls-${VERSION_TAG}
    status=$(git -C mbedtls status)
    echo "\nmbedtls git status:\n${status}\n"
}

run_cmake() {
    IOS_PLATFORM=$1
    # clean cmake cache
    find . -iname '*cmake*' -not -name CMakeLists.txt -exec rm -rf {} +
    cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain/ios.toolchain.cmake -DIOS_PLATFORM=${IOS_PLATFORM} -DENABLE_PROGRAMS=OFF -DENABLE_TESTING=OFF -DINSTALL_MBEDTLS_HEADERS=OFF ../mbedtls/
}

main_func() {
    create_directory
    fetch_mbedtls

    cd build

    run_cmake 'DEVICE'
    make
    cp -Rf ${DIR}/build/library/libmbed* ${DIR}/target/mbedtls_device/library/
    cp -Rf ${DIR}/mbedtls/include/mbedtls/* ${DIR}/target/mbedtls_device/include/
    make clean

    run_cmake 'SIMULATOR'
    make
    cp -Rf ${DIR}/build/library/libmbed* ${DIR}/target/mbedtls_simulator/library/
    cp -Rf ${DIR}/mbedtls/include/mbedtls/* ${DIR}/target/mbedtls_simulator/include/
    make clean

    lipo ${DIR}/target/mbedtls_device/library/libmbedcrypto.a ${DIR}/target/mbedtls_simulator/library/libmbedcrypto.a  -create -output ${DIR}/target/mbedtls/library/libmbedcrypto.a
    lipo ${DIR}/target/mbedtls_device/library/libmbedx509.a ${DIR}/target/mbedtls_simulator/library/libmbedx509.a  -create -output ${DIR}/target/mbedtls/library/libmbedx509.a
    lipo ${DIR}/target/mbedtls_device/library/libmbedtls.a ${DIR}/target/mbedtls_simulator/library/libmbedtls.a  -create -output ${DIR}/target/mbedtls/library/libmbedtls.a
    cp -rn ${DIR}/target/mbedtls_device/include/*.h ${DIR}/target/mbedtls/include/
}

main_func