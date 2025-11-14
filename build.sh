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
# DTK 环境变量
# =====================
export HIP_PATH=/opt/dtk-24.04.1
export PATH=$HIP_PATH/bin:$PATH
export LD_LIBRARY_PATH=$HIP_PATH/lib:$LD_LIBRARY_PATH
export CMAKE_PREFIX_PATH=$HIP_PATH:$CMAKE_PREFIX_PATH

# 验证 hipcc
which hipcc

# =====================
# 解压 LAPACK
# =====================
mkdir -p "${LAPACK_DIR}"
tar -xzf "${LAPACK_TAR}" -C "${LAPACK_DIR}"

echo "解压后的 LAPACK 内容："
ls -lh "${LAPACK_DIR}"

# =====================
# MAGMA 配置文件 make.inc
# =====================
cat > make.inc <<EOF
BACKEND = hip
FORT = false
GPU_TARGET = gfx90a
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
  -DMAGMA_ENABLE_HIP=ON \
  -DGPU_TARGET=gfx90a \
  -DUSE_FORTRAN=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DHIP_ROOT_DIR="${HIP_PATH}" \
  -DCMAKE_CXX_COMPILER="${HIP_PATH}/bin/hipcc" \
  -DLAPACK_LIBRARIES="${LAPACK_DIR}/liblapack.so.3;${LAPACK_DIR}/libblas.so.3;${LAPACK_DIR}/libgfortran.so.3;${LAPACK_DIR}/libquadmath.so.0" \
  -DROCM_MATHLIBS_API_USE_HIP_COMPLEX=ON

make -j32
make install

echo ""
echo "✅ MAGMA build finished successfully (HIP/DTK + gfx90a)!"
echo "Installed to: ${INSTALL_DIR}"
echo ""
echo "Libraries available:"
ls -lh ${INSTALL_DIR}/lib
