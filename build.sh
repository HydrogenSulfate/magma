#!/usr/bin/env bash
set -ex

# =====================
# 基本路径设置
# =====================
MAGMA_ROOT=$(pwd)
BUILD_DIR=${MAGMA_ROOT}/build
INSTALL_DIR=${MAGMA_ROOT}/magma_install
LAPACK_TAR=/work/Paddle/third_party/lapack/Linux/lapack_lnx_v3.10.0.20210628.tar.gz
LAPACK_DIR=${MAGMA_ROOT}/lapack_temp

# =====================
# 解压 Paddle 的 LAPACK
# =====================
mkdir -p "${LAPACK_DIR}"
tar -xzf "${LAPACK_TAR}" -C "${LAPACK_DIR}"

echo "解压后的 LAPACK 内容："
ls -lh "${LAPACK_DIR}"

# =====================
# 生成 MAGMA 构建配置
# =====================
cat > make.inc <<EOF
BACKEND = cuda
FORT = false
GPU_TARGET = sm_80
EOF

make generate

# =====================
# CMake 构建
# =====================
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}"

cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${INSTALL_DIR}" \
  -DMAGMA_ENABLE_CUDA=ON \
  -DGPU_TARGET=sm_80 \
  -DUSE_FORTRAN=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DLAPACK_LIBRARIES="${LAPACK_DIR}/liblapack.so.3;${LAPACK_DIR}/libblas.so.3;${LAPACK_DIR}/libgfortran.so.3;${LAPACK_DIR}/libquadmath.so.0" \
  -DCMAKE_INSTALL_RPATH="\$ORIGIN" \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON

make -j"$(nproc)"
make install

pushd ../magma_install/lib
tar -cvf magma_lnx_xpu_aarch64_v2.9.0.20250728.tar.gz ./*.so
popd

echo ""
echo "✅ MAGMA build finished successfully(xpu+aarch64)!"
echo "Installed to: ${INSTALL_DIR}"
echo ""
echo "Libraries available:"
ls -lh ${INSTALL_DIR}/lib
