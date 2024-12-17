cmake_minimum_required(VERSION 3.10)
project(CurVeResume)

# Variables
set(MAIN_FILE "main")
set(OUTPUT_DIR "${CMAKE_BINARY_DIR}/output")
set(DEPS_DIR "${CMAKE_BINARY_DIR}/deps")
set(FLAVORS "hw" "sw" "ic")
set(DEFAULT_COMPILER "latexmk")
set(COMPILER ${DEFAULT_COMPILER} CACHE STRING "Compiler to use (latexmk or lualatex)")
set(LATEXMK_FLAGS "-pdf -pdflua -interaction=nonstopmode -halt-on-error -use-make")
set(LUALATEX_FLAGS "-interaction=nonstopmode -halt-on-error")

# Ensure output and dependency directories exist
file(MAKE_DIRECTORY ${OUTPUT_DIR})
file(MAKE_DIRECTORY ${DEPS_DIR})

# Debugging function to print the commands
function(debug_message msg)
    message(STATUS "DEBUG: ${msg}")
endfunction()

# Debug the selected COMPILER
debug_message("Selected COMPILER: ${COMPILER}")

# Function to add a build command for a flavor
function(add_latex_flavor flavor)
    set(output_pdf "${OUTPUT_DIR}/cv-${flavor}.pdf")

    if(COMPILER STREQUAL "latexmk")
        # Define the latexmk command as a single shell string
        set(latex_command
            "TEXINPUTS=${CMAKE_SOURCE_DIR}:.: \
            BIBINPUTS=${CMAKE_SOURCE_DIR}:.: \
            ${COMPILER} ${LATEXMK_FLAGS} \
            -output-directory=${OUTPUT_DIR} \
            -jobname=cv-${flavor} \
            -deps-out=${DEPS_DIR}/cv-${flavor}.d \
            -usepretex=\\\"\\\\def\\\\Flavor{${flavor}}\\\" \
            ${CMAKE_SOURCE_DIR}/${MAIN_FILE}.tex"
        )
        # Add the custom command
        add_custom_command(
            OUTPUT ${output_pdf}
            COMMAND echo "Running: ${latex_command}"
            COMMAND /bin/sh -c "${latex_command}"
            DEPENDS ${CMAKE_SOURCE_DIR}/${MAIN_FILE}.tex
                    ${CMAKE_SOURCE_DIR}/${MAIN_FILE}.bib
                    ${CMAKE_SOURCE_DIR}/settings.sty
            COMMENT "Building flavor: ${flavor} with ${COMPILER}"
        )
    elseif(COMPILER STREQUAL "lualatex")
        # Define the lualatex command as a single shell string
        set(latex_command
            "${COMPILER} ${LUALATEX_FLAGS} \
            -output-directory=${OUTPUT_DIR} \
            --jobname=cv-${flavor} \
            \"\\def\\Flavor{${flavor}} \\input{${MAIN_FILE}.tex}\""
        )

        # Add the custom command
        add_custom_command(
            OUTPUT ${output_pdf}
            COMMAND echo "Running: ${latex_command}"
            COMMAND /bin/sh -c "${latex_command}"
            DEPENDS ${MAIN_FILE}.tex ${BIB_FILE}
            COMMENT "Building flavor: ${flavor} with ${COMPILER}"
        )
    else()
        message(FATAL_ERROR "Unknown COMPILER: ${COMPILER}. Supported values are 'latexmk' and 'lualatex'.")
    endif()

    # Create the full target name (cv-${flavor})
    add_custom_target(cv-${flavor} ALL DEPENDS ${output_pdf})

    # Create a short alias target (e.g., hw, sw, ic)
    add_custom_target(${flavor} DEPENDS cv-${flavor})
endfunction()

# Add targets for all flavors
foreach(flavor ${FLAVORS})
    debug_message("Adding flavor target for: ${flavor}")
    add_latex_flavor(${flavor})
endforeach()

# Clean auxiliary files
add_custom_target(clean_aux
    COMMAND ${CMAKE_COMMAND} -E remove ${OUTPUT_DIR}/*.log ${OUTPUT_DIR}/*.aux ${OUTPUT_DIR}/*.out
                              ${OUTPUT_DIR}/*.toc ${OUTPUT_DIR}/*.snm ${OUTPUT_DIR}/*.nav
                              ${OUTPUT_DIR}/*.xmpdata ${OUTPUT_DIR}/*.fls ${OUTPUT_DIR}/*.fdb_latexmk
                              ${OUTPUT_DIR}/*.xmpi ${DEPS_DIR}/*
    COMMENT "Cleaning auxiliary files"
)

# Clean biber files
add_custom_target(clean_biber
    COMMAND ${CMAKE_COMMAND} -E remove ${OUTPUT_DIR}/*.bcf ${OUTPUT_DIR}/*.bbl ${OUTPUT_DIR}/*.blg ${OUTPUT_DIR}/*.run.xml
    COMMENT "Cleaning biber files"
)

# Clean all files
add_custom_target(clean_all
    COMMAND ${CMAKE_COMMAND} -E remove ${OUTPUT_DIR}/*.pdf
    DEPENDS clean_aux clean_biber
    COMMENT "Cleaning all files"
)

# Full rebuild
add_custom_target(rebuild
    COMMAND ${CMAKE_COMMAND} --build . --target clean_all
    COMMAND ${CMAKE_COMMAND} --build . --target all
    COMMENT "Full rebuild"
)
