#!/bin/bash

export BUILD_DIR=/tmp
export INSTALL_DIR=/opt/software/amdclang
export UCX_DIR=${INSTALL_DIR}/ucx
export UCC_DIR=${INSTALL_DIR}/ucc
export OMPI_DIR=${INSTALL_DIR}/aomp/ompi
export ROCM=/opt/rocm
export OSU_DIR=$INSTALL_DIR/osu


mkdir -p ${INSTALL_DIR}

git clone https://github.com/openucx/ucx.git ${BUILD_DIR}/ucx
cd ${BUILD_DIR}/ucx
git checkout v1.15.x
./autogen.sh
./configure --prefix=${UCX_DIR} --with-rocm=/opt/rocm --without-knem --without-cuda --enable-gtest --enable-examples
make -j
make install


git clone https://github.com/openucx/ucc.git ${BUILD_DIR}/ucc
cd ${BUILD_DIR}/ucc
./autogen.sh
./configure --with-rocm=/opt/rocm \
            --with-ucx=$UCX_DIR   \
            --prefix=$UCC_DIR
make -j && make install

git clone --recursive -b v5.0.x https://github.com/open-mpi/ompi.git ${BUILD_DIR}/ompi
cd ${BUILD_DIR}/ompi
./autogen.pl
mkdir build
cd build
FC=${ROCM}/bin/amdflang \
CC=${ROCM}/bin/amdclang \
CXX=${ROCM}/bin/amdclang++ \
../configure --prefix=$OMPI_DIR --with-ucx=$UCX_DIR --with-ucc=$UCC_DIR --with-rocm=${ROCM} --without-verbs
make -j
make install


cd $BUILD_DIR
wget http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-5.9.tar.gz
tar xfz osu-micro-benchmarks-5.9.tar.gz
cd osu-micro-benchmarks-5.9
./configure --prefix=$INSTALL_DIR/osu --enable-rocm \
    --with-rocm=/opt/rocm \
    CC=$OMPI_DIR/bin/mpicc CXX=$OMPI_DIR/bin/mpicxx \
    LDFLAGS="-L$OMPI_DIR/lib/ -lmpi -L/opt/rocm/lib/ $(hipconfig -C | tr -d '\n') -lamdhip64" CXXFLAGS="-std=c++11"
make -j $(nproc)
make install
