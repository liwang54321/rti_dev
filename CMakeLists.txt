cmake_minimum_required(VERSION 3.20.0)
project(rti_app VERSION 0.1.0 LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(BUILD_SHARED_LIBS ON)

# For RTI CONNEXT
set(CONNEXTDDS_DIR  "/opt/rti_connext_dds-6.0.1")
set(CONNEXTDDS_ARCH "x64Linux4gcc7.3.0")
# set(CONNEXTDDS_ARCH "armv8Linux4.4gcc5.4.0")

set(CMAKE_MODULE_PATH 
    ${CMAKE_MODULE_PATH} 
    ${CONNEXTDDS_DIR}/resource/cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake
)

find_package(RTIConnextDDS REQUIRED)

include(ConnextDdsCodegen)

connextdds_rtiddsgen_run(
    IDL_FILE
        ${CMAKE_CURRENT_SOURCE_DIR}/sources/IDL/hello_world.idl
    OUTPUT_DIRECTORY
        ${CMAKE_CURRENT_BINARY_DIR}
    LANG C++11
)

add_executable(${PROJECT_NAME} 
    sources/main.cpp 
    ${hello_world_CXX11_SOURCES} 
    ${hello_world_CXX11_HEADERS})

target_link_libraries(${PROJECT_NAME} PRIVATE RTIConnextDDS::cpp2_api)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
