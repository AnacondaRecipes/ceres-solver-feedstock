:: cmd
echo "Building %PKG_NAME%."

set "CUDA_CMAKE_ARGS=-DUSE_CUDA=OFF"
if defined cuda_compiler_version if not "%cuda_compiler_version%"=="None" (
    set "CUDA_CMAKE_ARGS=-DUSE_CUDA=ON"
    rem nvcc 13.x dropped Maxwell/Pascal/Volta. Rewrite Ceres 2.2.0's
    rem hardcoded "50;60;70;80" arch list for cuda 13.* only (mirrors build.sh).
    echo %cuda_compiler_version% | findstr /b "13." >nul && powershell -NoProfile -Command "(Get-Content CMakeLists.txt) -replace '\"50;60;70;80\"', '\"75;80;86;90\"' | Set-Content -NoNewline CMakeLists.txt"
)

mkdir build_ && cd build_
if errorlevel 1 exit /b 1

:: Generate the build files.
echo "Generating the build files..."
cmake .. %CMAKE_ARGS% ^
    -G"Ninja" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=ON ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_TESTING=OFF ^
    %CUDA_CMAKE_ARGS% ^
    ..
if errorlevel 1 exit /b 1


:: Build.
echo "Building..."
ninja -j%CPU_COUNT%
if errorlevel 1 exit /b 1


:: Install.
echo "Installing..."
ninja install
if errorlevel 1 exit /b 1


:: Error free exit.
echo "Error free exit!"
exit 0
