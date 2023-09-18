
#!/usr/bin/env bash
#
# svgtiny
# Libsvgtiny is an implementation of SVG Tiny, written in C
# http://www.netsurf-browser.org/projects/libsvgtiny/
#
# uses a makeifle build system

FORMULA_TYPES=( "linux64" "linuxarmv6l" "linuxarmv7l" "linuxaarch64" "osx" "vs" "ios" "tvos" "android" "emscripten" "msys2" )

#dependencies
FORMULA_DEPENDS=( "libxml2" )

# define the version by sha
VER=0.1.7

# tools for git use
GIT_URL=git://git.netsurf-browser.org/libsvgtiny.git
GIT_TAG=$VER

# download the source code and unpack it into LIB_NAME
function download() {
	git -c advice.detachedHead=false clone -b release/$VER --depth 1 git://git.netsurf-browser.org/libsvgtiny.git
    mv libsvgtiny svgtiny
    cd svgtiny

    git -c advice.detachedHead=false clone -b release/0.4.1 --depth 1 git://git.netsurf-browser.org/libdom.git
    git -c advice.detachedHead=false clone -b release/0.2.4 --depth 1 git://git.netsurf-browser.org/libparserutils.git
    git -c advice.detachedHead=false clone -b release/0.4.3 --depth 1 git://git.netsurf-browser.org/libwapcaplet.git

    if [ "$TYPE" == "vs" ]; then
		dos2unix $FORMULA_DIR/libdom.patch
		cd libdom
		if git apply $FORMULA_DIR/libdom.patch  --check; then
			git apply $FORMULA_DIR/libdom.patch
		fi
		cd ../
		sed -i -e 's/restrict//g' libwapcaplet/src/libwapcaplet.c
	else
		# Use custom Makefile
    	#cp $FORMULA_DIR/Makefile .
    	#gperf src/colors.gperf | sed -e 's/^\(const struct svgtiny_named_color\)/static \1/' > src/autogenerated_colors.c
		#dos2unix $FORMULA_DIR/libdom.patch
		cd libdom
		if git apply $FORMULA_DIR/libdom.patch  --check; then
			git apply $FORMULA_DIR/libdom.patch
		fi
		cd ../
		sed -i -e 's/restrict//g' libwapcaplet/src/libwapcaplet.c
	fi

	cd libparserutils
	patch -up1 < $FORMULA_DIR/libparseutils.patch
	cd ..
}

# prepare the build environment, executed inside the lib src dir
function prepare() {
	#if [ "$TYPE" == "vs" ]; then
		cp $FORMULA_DIR/CMakeLists.txt ./CMakeLists.txt
		cp -f $FORMULA_DIR/make-aliases.pl ./libparserutils/build/make-aliases.pl
		cp -f $FORMULA_DIR/autogenerated_colors.c ./src/autogenerated_colors.c
		cp $FORMULA_DIR/libwapcaplet.h libwapcaplet/include/libwapcaplet/
	#else
    #	cp $FORMULA_DIR/Makefile .
	#fi
	#Generate Aliases.inc file
	cd libparserutils
	perl build/make-aliases.pl
	cd ..
    cp -rf libdom/bindings libdom/include/dom/
}

# executed inside the lib src dir
function build() {
	LIBS_ROOT=$(realpath $LIBS_DIR)
    if [ "$TYPE" == "linux" ] || [ "$TYPE" == "linux64" ] || [ "$TYPE" == "linuxaarch64" ] || [ "$TYPE" == "linuxarmv6l" ] || [ "$TYPE" == "linuxarmv7l" ] ; then
        if [ $CROSSCOMPILING -eq 1 ]; then
            source ../../${TYPE}_configure.sh
            export LDFLAGS=-L$SYSROOT/usr/lib
            export CFLAGS=-I$SYSROOT/usr/include
        fi
        LIBXML2_ROOT="$LIBS_ROOT/libxml2/"
        LIBXML2_INCLUDE_DIR="$LIBS_ROOT/libxml2/include"
        LIBXML2_LIBRARY="$LIBS_ROOT/libxml2/lib/$TYPE/libxml2.a"
	    mkdir -p "build_${TYPE}_${ARCH}"
	    cd "build_${TYPE}_${ARCH}"
	    DEFS="-DLIBRARY_SUFFIX=${ARCH} \
	        -DCMAKE_BUILD_TYPE=Release \
	        -DCMAKE_C_STANDARD=17 \
	        -DCMAKE_CXX_STANDARD=17 \
	        -DCMAKE_CXX_STANDARD_REQUIRED=ON \
	        -DCMAKE_CXX_EXTENSIONS=OFF
	        -DBUILD_SHARED_LIBS=OFF \
	        -DCMAKE_INSTALL_PREFIX=Release \
	        -DCMAKE_INCLUDE_OUTPUT_DIRECTORY=include \
	        -DCMAKE_INSTALL_INCLUDEDIR=include"         
	    cmake .. ${DEFS} \
	        -DCMAKE_CXX_FLAGS="-DUSE_PTHREADS=1 -Iinclude" \
	        -DCMAKE_C_FLAGS="-DUSE_PTHREADS=1 -Iinclude" \
	        -DCMAKE_BUILD_TYPE=Release \
	        -DCMAKE_INSTALL_LIBDIR="lib" \
	        -DLIBXML2_ROOT=$LIBXML2_ROOT \
	        -DLIBXML2_INCLUDE_DIR=$LIBXML2_INCLUDE_DIR \
	        -DLIBXML2_LIBRARY=$LIBXML2_LIBRARY 
	    cmake --build . --config Release
	    cd ..
	elif [ "$TYPE" == "vs" ] ; then
        LIBXML2_ROOT="$LIBS_ROOT/libxml2/"
        LIBXML2_INCLUDE_DIR="$LIBS_ROOT/libxml2/include"
        LIBXML2_LIBRARY="$LIBS_ROOT/libxml2/lib/$TYPE/$PLATFORM/libxml2.lib"

		echo "building svgtiny $TYPE | $ARCH | $VS_VER | vs: $VS_VER_GEN"
	    echo "--------------------"
	    GENERATOR_NAME="Visual Studio ${VS_VER_GEN}"
	    mkdir -p "build_${TYPE}_${ARCH}"
	    cd "build_${TYPE}_${ARCH}"
	    DEFS="-DLIBRARY_SUFFIX=${ARCH} \
	        -DCMAKE_BUILD_TYPE=Release \
	        -DCMAKE_C_STANDARD=17 \
	        -DCMAKE_CXX_STANDARD=17 \
	        -DCMAKE_CXX_STANDARD_REQUIRED=ON \
	        -DCMAKE_CXX_EXTENSIONS=OFF
	        -DBUILD_SHARED_LIBS=OFF \
	        -DCMAKE_INSTALL_PREFIX=Release \
	        -DCMAKE_INCLUDE_OUTPUT_DIRECTORY=include \
	        -DCMAKE_INSTALL_INCLUDEDIR=include"         
	    cmake .. ${DEFS} \
	        -DCMAKE_CXX_FLAGS="-DUSE_PTHREADS=1" \
	        -DCMAKE_C_FLAGS="-DUSE_PTHREADS=1" \
	        -DCMAKE_BUILD_TYPE=Release \
	        -DCMAKE_INSTALL_LIBDIR="lib" \
	        ${CMAKE_WIN_SDK} \
	        -DLIBXML2_ROOT=$LIBXML2_ROOT \
	        -DLIBXML2_INCLUDE_DIR=$LIBXML2_INCLUDE_DIR \
	        -DLIBXML2_LIBRARY=$LIBXML2_LIBRARY \
	        -A "${PLATFORM}" \
	        -G "${GENERATOR_NAME}"
	    cmake --build . --config Release --target install
	    cd ..

	elif [ "$TYPE" == "msys2" ]; then

		if [ $CROSSCOMPILING -eq 1 ]; then
            source ../../${TYPE}_configure.sh
            export LDFLAGS=-L$SYSROOT/usr/lib
            export CFLAGS=-I$SYSROOT/usr/include
        fi
        LIBXML2_ROOT="$LIBS_ROOT/libxml2/"
        LIBXML2_INCLUDE_DIR="$LIBS_ROOT/libxml2/include"
        LIBXML2_LIBRARY="$LIBS_ROOT/libxml2/lib/$TYPE/$PLATFORM/libxml2.lib"

		echo "building svgtiny $TYPE | $ARCH | MSYS "
	            
        export CFLAGS="$(pkg-config libxml-2.0 --cflags)"
        
        if [ "$TYPE" == "linuxarmv6l" ] || [ "$TYPE" == "linuxarmv7l" ] || [ "$TYPE" == "linuxaarch64" ] ; then
            export CFLAGS="-I$LIBS_DIR/libxml2/include"
        fi
        
        make clean
        make -j${PARALLEL_MAKE}

	elif [ "$TYPE" == "android" ]; then
        source ../../android_configure.sh $ABI make
        export CFLAGS="$CFLAGS -I$LIBS_DIR/libxml2/include"
        make clean
	    make -j${PARALLEL_MAKE}

	elif [ "$TYPE" == "osx" ]; then
        export CFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=${OSX_MIN_SDK_VER}"
        export LDFLAGS="-arch arm64 -arch x86_64 -mmacosx-version-min=${OSX_MIN_SDK_VER}"
        export CFLAGS="$CFLAGS -I$LIBS_DIR/libxml2/include"
        make clean
	    make -j${PARALLEL_MAKE}

	elif [ "$TYPE" == "ios" ] || [ "$TYPE" == "tvos" ]; then
        if [ "${TYPE}" == "tvos" ]; then
            IOS_ARCHS="x86_64 arm64"
        elif [ "$TYPE" == "ios" ]; then
            IOS_ARCHS="x86_64 armv7 arm64" #armv7s
        fi
		for IOS_ARCH in ${IOS_ARCHS}; do
            echo
            echo
            echo "Compiling for $IOS_ARCH"
    	    source ../../ios_configure.sh $TYPE $IOS_ARCH
            export CFLAGS="$CFLAGS -I$LIBS_DIR/libxml2/include"
            export CPPFLAGS=" -I$LIBS_DIR/libxml2/include" #fix linking issues
            make clean
	        make -j${PARALLEL_MAKE}
            mv libsvgtiny.a libsvgtiny_$IOS_ARCH.a
        done

        if [ "$TYPE" == "ios" ]; then
            lipo -create libsvgtiny_x86_64.a \
                         libsvgtiny_armv7.a \
                         libsvgtiny_arm64.a \
                        -output libsvgtiny.a
        elif [ "$TYPE" == "tvos" ]; then
            lipo -create libsvgtiny_x86_64.a \
                         libsvgtiny_arm64.a \
                        -output libsvgtiny.a
        fi


	elif [ "$TYPE" == "emscripten" ]; then
        mkdir -p build_$TYPE
        LIBXML2_ROOT="$LIBS_ROOT/libxml2/"
        LIBXML2_INCLUDE_DIR="$LIBS_ROOT/libxml2/include"
        LIBXML2_LIBRARY="$LIBS_ROOT/libxml2/lib/$TYPE/$PLATFORM/libxml2.lib"
	    cd build_$TYPE
	    $EMSDK/upstream/emscripten/emcmake cmake .. \
	    	-B build \
	    	-DCMAKE_BUILD_TYPE=Release \
	    	-DCMAKE_INSTALL_LIBDIR="build_${TYPE}" \
	    	-DCMAKE_C_STANDARD=17 \
			-DCMAKE_CXX_STANDARD=17 \
			-DCMAKE_CXX_STANDARD_REQUIRED=ON \
			-DCMAKE_CXX_FLAGS="-DUSE_PTHREADS=1" \
			-DCMAKE_C_FLAGS="-DUSE_PTHREADS=1" \
			-DCMAKE_CXX_EXTENSIONS=OFF \
			-DBUILD_SHARED_LIBS=OFF \
			-DCMAKE_INSTALL_PREFIX=Release \
            -DCMAKE_INCLUDE_OUTPUT_DIRECTORY=include \
            -DCMAKE_INSTALL_INCLUDEDIR=include 
	  	cmake --build build --target install --config Release
	    cd ..
	fi
}

# executed inside the lib src dir, first arg $1 is the dest libs dir root
function copy() {
	# prepare headers directory if needed
	mkdir -p $1/include

	# prepare libs directory if needed
	mkdir -p $1/lib/$TYPE
	cp -Rv include/* $1/include

	if [ "$TYPE" == "vs" ] ; then
		mkdir -p $1/lib/$TYPE/$PLATFORM/
		cp -Rv "build_${TYPE}_${ARCH}/Release/include/" $1/ 
        cp -f "build_${TYPE}_${ARCH}/Release/lib/svgtiny.lib" $1/lib/$TYPE/$PLATFORM/svgtiny.lib
	elif [ "$TYPE" == "osx" ] || [ "$TYPE" == "ios" ] || [ "$TYPE" == "tvos" ]; then
		# copy lib
		cp -Rv libsvgtiny.a $1/lib/$TYPE/svgtiny.a
	elif [ "$TYPE" == "android" ] ; then
	    mkdir -p $1/lib/$TYPE/$ABI
		# copy lib
		cp -Rv libsvgtiny.a $1/lib/$TYPE/$ABI/libsvgtiny.a
	elif [ "$TYPE" == "linux" ] || [ "$TYPE" == "linux64" ] || [ "$TYPE" == "linuxaarch64" ] || [ "$TYPE" == "linuxarmv6l" ] || [ "$TYPE" == "linuxarmv7l" ] || [ "$TYPE" == "emscripten" ]; then
		mkdir -p $1/lib/$TYPE/$
		cp -Rv "include/" $1/ 
        cp -f "build_${TYPE}_${ARCH}/libsvgtiny.a" $1/lib/$TYPE/libsvgtiny.a
    elif [ "$TYPE" == "msys2" ] ; then
		cp -Rv libsvgtiny.a $1/lib/$TYPE/libsvgtiny.a
	fi


	# copy license file
	if [ -d "$1/license" ]; then
        rm -rf $1/license
    fi
	mkdir -p $1/license
	cp -v COPYING $1/license/
}

# executed inside the lib src dir
function clean() {
	if [ "$TYPE" == "vs" ] ; then
		make clean
		rm -f *.lib
		if [ -d "build_${TYPE}_${ARCH}" ]; then
		    # Delete the folder and its contents
		    rm -r build_${TYPE}_${ARCH}	    
		fi
	fi
}


function save() {
    . "$SAVE_SCRIPT" 
    savestatus ${TYPE} "svgtiny" ${ARCH} ${VER} true "${SAVE_FILE}"
}

function load() {
    . "$LOAD_SCRIPT"
    if loadsave ${TYPE} "svgtiny" ${ARCH} ${VER} "${SAVE_FILE}"; then
      return 0;
    else
      return 1;
    fi
}
