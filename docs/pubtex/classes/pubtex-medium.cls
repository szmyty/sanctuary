\ProvidesClass{pubtex-medium}[2024/09/22 LaTeX class for Medium-style articles]
\RequirePackage{graphicx}
\RequirePackage{fancyhdr}
\RequirePackage{geometry}
\RequirePackage{titlesec}
\RequirePackage{hyperref}

\geometry{margin=1in}

% Title and author formatting commands
\titleformat{\section}{\Large\bfseries}{\thesection}{1em}{}
\titleformat{\subsection}{\large\bfseries}{\thesubsection}{1em}{}

\newcommand{\articleTitle}[1]{\Huge\bfseries #1 \\[1em]}
\newcommand{\articleSubtitle}[1]{\large\itshape #1 \\[1em]}
\newcommand{\articleAuthor}[1]{\textsc{By #1} \\[1em]}
