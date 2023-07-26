git clone https://github.com/fastlib/fCWT.git
cd fCWT
mkdir -p build
cd build
cmake ../ -DBUILD_MATLAB=ON
make 