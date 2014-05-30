#
# Install lemon from source
#

if (NOT lemon_NAME)

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

include (ExternalProject)
include (ExternalSource)
include (BuildSupport)
include (PatchSupport)

external_source (lemon
    1.2.4
	lemon-1.2.4.tar.gz
	fd89e8bf5035b02e2622a48ac7fe0641
    http://lemon.cs.elte.hu/pub/sources)
    
if((${CMAKE_SYSTEM_NAME} MATCHES "Darwin") AND ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang"))
	set(LEMON_OSX_CONFIG -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 
		-DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk)
else()
	set(LEMON_OSX_CONFIG "")
endif()

message ("Installing ${lemon_NAME} into FlyEM build area: ${BUILDEM_DIR} ...")
ExternalProject_Add(${lemon_NAME}
    PREFIX              ${BUILDEM_DIR}
    URL                 ${lemon_URL}
    URL_MD5             ${lemon_MD5}
    UPDATE_COMMAND      ""
    PATCH_COMMAND       ${BUILDEM_ENV_STRING} ${PATCH_EXE}
        # This patch fixes a build error that clang detects.
        # Already fixed in lemon trunk, patch here in Ticket #480 ( https://lemon.cs.elte.hu/trac/lemon/attachment/ticket/480/51deaff8728a.patch ), but not in the tarball release.
    	${lemon_SRC_DIR}/lemon/graph_to_eps.h ${PATCH_DIR}/lemon.patch
        ${lemon_SRC_DIR}/tools/lgf-gen.cc ${PATCH_DIR}/lemon-lgf-gen.patch
    	# Apparently one test file is missing from the release.
    	# This patch removes it from CMakeLists.txt
        ${lemon_SRC_DIR}/test/CMakeLists.txt ${PATCH_DIR}/lemon-test.patch

    CONFIGURE_COMMAND   ${BUILDEM_ENV_STRING} ${CMAKE_COMMAND} ${lemon_SRC_DIR} 
        -DBUILD_SHARED_LIBS=ON
        -DCMAKE_INSTALL_PREFIX=${BUILDEM_DIR}
        -DCMAKE_PREFIX_PATH=${BUILDEM_DIR}
        # Lemon can be optionally built with glpk to enable the LP solver.
        # We don't want to build with glpk because it isn't needed for cylemon.
        # Kill these cache variables to make sure we don't use it
        # (avoid potential linker errors if cmake finds a version of glpk on our system)
        -DGLPK_LIBRARY=
        -DGLPK_INCLUDE_DIR=
        -DGLPK_ROOT_DIR=
        -DCMAKE_CXX_FLAGS=${BUILDEM_ADDITIONAL_CXX_FLAGS}
        ${LEMON_OSX_CONFIG}

    BUILD_COMMAND       ${BUILDEM_ENV_STRING} $(MAKE)
    INSTALL_COMMAND     ${BUILDEM_ENV_STRING} $(MAKE) install
    TEST_COMMAND        ${BUILDEM_ENV_STRING} $(MAKE) check
)

set_target_properties(${lemon_NAME} PROPERTIES EXCLUDE_FROM_ALL ON)

endif (NOT lemon_NAME)

