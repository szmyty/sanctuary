#!/usr/bin/env bash

# ======================================================================================
# @Project: LaTeX Build Script
# @Author: Alan Szmyt
# @Description: This script sets up environment variables, triggers the `latexmk` build process,
#               and calls the conversion script to generate additional formats.
# ======================================================================================

# Set PROJECT_ROOT.
unless ($ENV{"PROJECT_ROOT"}) {
    $ENV{"PROJECT_ROOT"} = $ENV{"PWD"};
}

# Exit if TEX_PROJECT_ROOT is not set.
if (not exists $ENV{"TEX_PROJECT_ROOT"}) {
    die "TEX_PROJECT_ROOT environment variable is not set.\n";
}

# Exit if MAIN_TEX_FILE is not set.
if (not exists $ENV{"MAIN_TEX_FILE"}) {
    die "MAIN_TEX_FILE environment variable is not set.\n";
}

# # Set the main .tex file path.
# export MAIN_TEX_FILE="${TEX_PROJECT_ROOT}/main.tex"

# # Set the cache directory to be in the project root.
# export CACHE_DIR="${PROJECT_ROOT}/.cache/latex"

# # Set the output directory for converted formats in the article folder.
# export CONVERTED_DIR="${TEX_PROJECT_ROOT}/converted"

# # Set other directories
# export DEPS_OUT="${CACHE_DIR}/dependencies.list"
# export OUT_DIR="${CACHE_DIR}/out"
# export AUX_DIR="${CACHE_DIR}/out/aux"
# export TMPDIR="${CACHE_DIR}/tmp"

# Set timezone
# export TZ='America/New_York'

# Create necessary directories if they don't exist
mkdir -p "${OUT_DIR}"
mkdir -p "${AUX_DIR}"
mkdir -p "${TMPDIR}"
mkdir -p "${CONVERTED_DIR}"  # Directory for the converted files


# Define the main LaTeX file
my $tex_file = $ENV{"MAIN_TEX_FILE"};




# Define output formats
my @formats = ("html", "rtf", "markdown");

# Check if the LaTeX file exists.
unless (-e $tex_file) {
    die "LaTeX file not found: $tex_file\n";
}

# Base name for outputs.
my ($base_name) = fileparse($tex_file, qr/\.[^.]*/);

# Convert to each format using pandoc
foreach my $format (@formats) {
    my $output_file = $ENV{"TEX_PROJECT_ROOT"}/$base_name.$format;
    my $cmd = "pandoc $tex_file -s --resource-path=$ENV{'TEX_PROJECT_ROOT'} -o $output_file";
    print "Converting to $format...\n";
    system($cmd) == 0 or warn "Conversion to $format failed: $!\n";
}

print "Conversions completed.\n";





# Run latexmk with the specified configuration
latexmk -pdf -r "${PROJECT_ROOT}/latexmkrc" -outdir="${OUT_DIR}" -auxdir="${AUX_DIR}"


# Copy the generated PDF to the article directory
cp "${OUT_DIR}/main.pdf" "${TEX_PROJECT_ROOT}/main.pdf"

# Call the conversion script
echo "Converting to other formats..."
"${PROJECT_ROOT}/convert.pl"

# Move the converted files to the dedicated converted directory
mv "${TEX_PROJECT_ROOT}/main.html" "${CONVERTED_DIR}/"
mv "${TEX_PROJECT_ROOT}/main.markdown" "${CONVERTED_DIR}/"
mv "${TEX_PROJECT_ROOT}/main.rtf" "${CONVERTED_DIR}/"

echo "Build and conversion completed."
