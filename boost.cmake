#
# Install boost libraries from source
#

if (NOT boost_NAME)

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

include (ExternalProject)
include (BuildSupport)
include (ExternalSource)

include (python)
include (zlib)

set (boost_INCLUDE_DIR  ${BUILDEM_INCLUDE_DIR}/boost)
include_directories (${boost_INCLUDE_DIR})

external_source (boost
    1_56_0
    boost_1_56_0.tar.bz2
    a744cf167b05d72335f27c88115f211d
    http://hivelocity.dl.sourceforge.net/project/boost/boost/1.56.0)

set (boost_LIBS ${BUILDEM_LIB_DIR}/libboost_container.${BUILDEM_PLATFORM_DYLIB_EXTENSION}
                ${BUILDEM_LIB_DIR}/libboost_thread.${BUILDEM_PLATFORM_DYLIB_EXTENSION}
                ${BUILDEM_LIB_DIR}/libboost_system.${BUILDEM_PLATFORM_DYLIB_EXTENSION}
                ${BUILDEM_LIB_DIR}/libboost_program_options.${BUILDEM_PLATFORM_DYLIB_EXTENSION}
                ${BUILDEM_LIB_DIR}/libboost_python.${BUILDEM_PLATFORM_DYLIB_EXTENSION}
                ${BUILDEM_LIB_DIR}/libboost_unit_test_framework.${BUILDEM_PLATFORM_DYLIB_EXTENSION}
                ${BUILDEM_LIB_DIR}/libboost_filesystem.${BUILDEM_PLATFORM_DYLIB_EXTENSION}
                ${BUILDEM_LIB_DIR}/libboost_chrono.${BUILDEM_PLATFORM_DYLIB_EXTENSION}
                ${BUILDEM_LIB_DIR}/libboost_random.${BUILDEM_PLATFORM_DYLIB_EXTENSION}
                ${BUILDEM_LIB_DIR}/libboost_atomic.${BUILDEM_PLATFORM_DYLIB_EXTENSION} )

# Add layout=tagged param to first boost install to explicitly create -mt libraries
# some libraries require.  TODO: Possibly shore up all library find paths to only
# allow use of built libs.
message ("Installing ${boost_NAME} into FlyEM build area: ${BUILDEM_DIR} ...")
ExternalProject_Add(${boost_NAME}
    DEPENDS             ${python_NAME} ${zlib_NAME}
    PREFIX              ${BUILDEM_DIR}
    URL                 ${boost_URL}
    URL_MD5             ${boost_MD5}
    UPDATE_COMMAND      ""
    PATCH_COMMAND       ""
    CONFIGURE_COMMAND   ${BUILDEM_ENV_STRING} ./bootstrap.sh 
        --with-libraries=container,date_time,filesystem,python,regex,serialization,system,test,thread,program_options,chrono,atomic,random
        --with-python=${PYTHON_EXE} 
        --prefix=${BUILDEM_DIR}
    BUILD_COMMAND       ${BUILDEM_ENV_STRING} ./b2
    	cxxflags="${BUILDEM_ADDITIONAL_CXX_FLAGS}" linkflags="${BUILDEM_ADDITIONAL_CXX_FLAGS}"
        --layout=tagged
        -sNO_BZIP2=1 
        -sZLIB_INCLUDE=${BUILDEM_DIR}/include 
        -sZLIB_SOURCE=${zlib_SRC_DIR} install
    BUILD_IN_SOURCE     1
    INSTALL_COMMAND     ${BUILDEM_ENV_STRING} ./b2
    	cxxflags="${BUILDEM_ADDITIONAL_CXX_FLAGS}" linkflags="${BUILDEM_ADDITIONAL_CXX_FLAGS}"
        -sNO_BZIP2=1 
        -sZLIB_INCLUDE=${BUILDEM_DIR}/include 
        -sZLIB_SOURCE=${zlib_SRC_DIR} install
)

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin" AND "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    ExternalProject_Add_Step(${boost_NAME} osx-gcc-fix-config
       COMMAND bash ${PATCH_DIR}/boost-osx-gcc-fix-config.sh ${boost_SRC_DIR} ${CMAKE_CXX_COMPILER}
       DEPENDERS configure
       DEPENDEES patch
    )
endif()

set_target_properties(${boost_NAME} PROPERTIES EXCLUDE_FROM_ALL ON)

endif (NOT boost_NAME)
