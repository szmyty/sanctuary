#!/usr/bin/env perl

# ======================================================================================
# Perl `latexmk` configuration file
#
# This file is used to configure the `latexmk` command, which is a Perl script that
# automates the process of generating LaTeX documents. This file is used to set the
# default options for `latexmk` when it is run in the directory where this file is
# located. The options set in this file can be overridden by passing command-line
# arguments to `latexmk`.
#
# For more information on `latexmk`, see the documentation at:
# https://ctan.math.washington.edu/tex-archive/support/latexmk/latexmk.pdf
#
# For more information on the configuration options available in this file, see the
# documentation at:
#
# @Project: LaTeX Build Configuration
# @Author: Alan Szmyt
# @Description: This is a configuration file for `latexmk` to automate the LaTeX build process.
#               It includes environment variable setups, file paths, and compiler options.
#
# ======================================================================================
use strict;
use warnings;
use File::Basename;

# Set the timezone for any date/time operations if not already set (default timezone to UTC).
unless ($ENV{"TZ"}) {
    $ENV{"TZ"}="UTC";
}

# Set PROJECT_ROOT environment variable if not already set.
unless ($ENV{"PROJECT_ROOT"}) {
    $ENV{"PROJECT_ROOT"} = "$ENV{\"PWD\"}";
}

# Set TEX_PROJECT_ROOT environment variable if not already set.
unless ($ENV{"TEX_PROJECT_ROOT"}) {
    $ENV{"TEX_PROJECT_ROOT"} = "$ENV{\"PROJECT_ROOT\"}/docs";
}

# Set maximum print line length to avoid truncation in logs.
$ENV{"max_print_line"} = 9999;

# Set the resources location.
$ENV{"TEX_RESOURCES"} = "$ENV{\"TEX_PROJECT_ROOT\"}/resources";

# Set the TEX_STYLE environment variable to point to the style directory.
$ENV{"TEX_STYLE"} = "$ENV{\"TEX_RESOURCES\"}/style";

# Add TEX_STYLE to TEXINPUTS so LaTeX can find the style files.
ensure_path("TEXINPUTS", "$ENV{\"TEX_STYLE\"}//");

# Set LUA_SCRIPTS environment variable to point to the Lua scripts directory.
$ENV{"LUA_SCRIPTS"} = "$ENV{\"TEX_RESOURCES\"}/scripts";

# Add LUA_SCRIPTS to TEXINPUTS for Lua scripts access.
ensure_path("TEXINPUTS", "$ENV{\"LUA_SCRIPTS\"}//");

# Set the TEX_FONTS environment variable to point to the fonts directory.
$ENV{"TEX_FONTS"} = "$ENV{\"TEX_RESOURCES\"}/fonts";

# Add TEX_FONTS to TEXINPUTS so LaTeX can find the font files.
ensure_path("TEXINPUTS", "$ENV{\"TEX_FONTS\"}//");

# Set the TEX_IMAGES environment variable to point to the images directory.
$ENV{"TEX_IMAGES"} = "$ENV{\"TEX_RESOURCES\"}/images";

# Add TEX_IMAGES to TEXINPUTS so LaTeX can find the image files.
ensure_path("TEXINPUTS", "$ENV{\"TEX_IMAGES\"}//");

# Set the TEX_TABLES environment variable to point to the tables directory.
$ENV{"TEX_TABLES"} = "$ENV{\"TEX_RESOURCES\"}/tables";

# Set the TEX_BIB environment variable to point to the bibliography directory.
$ENV{"TEX_BIB"} = "$ENV{\"TEX_RESOURCES\"}/bib";

# Set the TEX_DATA environment variable to point to the data directory.
$ENV{"TEX_DATA"} = "$ENV{\"TEX_RESOURCES\"}/data";

# Ensure './texmf//' is in '$TEXINPUTS' for custom LaTeX packages.
ensure_path("TEXINPUTS",  "$ENV{\"TEX_PROJECT_ROOT\"}/texmf//");

# Ensure './classes//' is in '$TEXINPUTS' for custom LaTeX classes.
ensure_path("TEXINPUTS", "$ENV{\"TEX_PROJECT_ROOT\"}/classes//");

# Ensure './components//' is in '$TEXINPUTS' for custom LaTeX components
ensure_path("TEXINPUTS", "$ENV{\"TEX_PROJECT_ROOT\"}/components//");

# Set the PROJECT_OUT_DIR environment variable to point to the output directory.
$ENV{"PROJECT_OUT_DIR"} = "$ENV{\"PROJECT_CACHE_DIR\"}/out";

# Set the AUX_DIR environment variable to point to the auxiliary directory.
$ENV{"AUX_DIR"} = "$ENV{\"PROJECT_OUT_DIR\"}/aux";

# Set the TMPDIR environment variable to point to the temporary directory.
$ENV{"TMPDIR"} = "$ENV{\"PROJECT_CACHE_DIR\"}/tmp";

# Set the default file to process.
@default_files = ("$ENV{\"MAIN_TEX_FILE\"}");

# Set the LaTeX commands with shell-escape, synctex, and other options.
# set_tex_cmds("--shell-escape --synctex=1 -file-line-error -8bit -interaction=nonstopmode, %O %S");
set_tex_cmds("--shell-escape --synctex=1, %O %S");

# PDF-generating modes:
# 1: pdflatex (traditional method)
# 2: Postscript conversion (not commonly used)
# 3: DVI conversion (not commonly used)
# 4: lualatex (best)
# 5: xelatex (second best)
$pdf_mode = 5;

# Treat warnings as errors (0 = No, 1 = Yes).
$warnings_as_errors = 0;

# Show CPU time used in the logs (0 = No, 1 = Yes).
$show_time = 0;

# Set maximum number of times latexmk will run latex/pdflatex to resolve references.
$max_repeat = 20;

# Use temporary file for viewing (0 = No, 1 = Yes).
$always_view_file_via_temporary = 0;

# Configure BibTeX usage: 1 = default, 2 = custom.
$bibtex_use = 2;

# Customize Biber call to validate data models.
$biber = "biber --validate-datamodel %O %S";

# Set output directories for dependencies, output files, aux files, and temporary files.
# my $deps_out = "$ENV{\"PROJECT_CACHE_DIR\"}/dependencies.list";
$out_dir = "$ENV{\"PROJECT_OUT_DIR\"}";
$aux_dir = "$ENV{\"AUX_DIR\"}";
$tmpdir = "$ENV{\"TMPDIR\"}";

# Enable preview mode (1 = Yes, 0 = No).
$preview_mode = 1;

# Enable auxiliary emulation (1 = Yes, 0 = No).
$emulate_aux = 1;

# Silence output to log files and console.
$silent = 1;

# Silence warnings in the log files.
$silence_logfile_warnings = 1;

# Set the default file viewer for PDFs to MuPDF.
$view = "pdf";
$pdf_previewer = "xpdf %S";

# Custom dependency for .eps to .pdf conversion.
@cus_dep_list = (@cus_dep_list, "eps pdf 0 eps2pdf");

sub eps2pdf {
    system("epstopdf $_[0].eps");
}

# Custom dependency for running makeglossaries
add_cus_dep("glo", "gls", 0, "run_makeglossaries");
add_cus_dep("acn", "acr", 0, "run_makeglossaries");

sub run_makeglossaries {
  if ( $silent ) {
    system("makeglossaries -q '$_[0]'");
  }
  else {
    system("makeglossaries '$_[0]'");
  };
}

# List the generated extensions so latexmk knows what files are created.
push @generated_exts, "glo", "gls", "glg";
push @generated_exts, "acn", "acr", "alg";

# Clean up additional files generated by glossaries
$clean_ext .= "%R.ist %R.xdy";

$compiling_cmd = "echo COMPILING %P...";
$failure_cmd = "echo FAILURE %P...";
$success_cmd = "echo SUCCESS %P... && texqc && texsc && pandoc --resource-path=$ENV{\"TEX_IMAGES\"} --embed-resources --standalone $ENV{\"MAIN_TEX_FILE\"} -o $ENV{\"PROJECT_OUT_DIR\"}/$ENV{\"MAIN_TEX_FILE_NAME\"}.html && pandoc --resource-path=$ENV{\"TEX_IMAGES\"} --embed-resources --standalone $ENV{\"MAIN_TEX_FILE\"} -o $ENV{\"PROJECT_OUT_DIR\"}/$ENV{\"MAIN_TEX_FILE_NAME\"}.md && pandoc --resource-path=$ENV{\"TEX_IMAGES\"} --embed-resources --standalone $ENV{\"MAIN_TEX_FILE\"} -o $ENV{\"PROJECT_OUT_DIR\"}/$ENV{\"MAIN_TEX_FILE_NAME\"}.rtf && magick -density 300 $ENV{\"PROJECT_OUT_DIR\"}/$ENV{\"MAIN_TEX_FILE_NAME\"}.pdf $ENV{\"PROJECT_OUT_DIR\"}/$ENV{\"MAIN_TEX_FILE_NAME\"}.png";
