\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{ruschidoc}
\LoadClass[11pt,a4paper,twoside]{article}
\RequirePackage[intlimits,sumlimits]{amsmath}
\RequirePackage{amssymb}
\RequirePackage{amsfonts}
\RequirePackage{fancyhdr}
\RequirePackage[T1]{fontenc}
\RequirePackage[latin1]{inputenc}
\RequirePackage{amsmath}
\RequirePackage{helvet}
\RequirePackage[amssymb]{SIunits}
\RequirePackage[helvet]{sfmath}
\RequirePackage{lastpage}
\RequirePackage{tabularx}
\RequirePackage{multirow}
\RequirePackage{listings}
\RequirePackage{textcomp}

%% Some packages need special options for PDFtex
\RequirePackage{ifpdf}
\ifpdf
	\RequirePackage[pdftex]{color}   
	\RequirePackage[pdftex]{graphics}
	\DeclareGraphicsExtensions{.pdf, .png, .jpg}
\else
	\RequirePackage{color}
	\RequirePackage{graphics}
	\DeclareGraphicsExtensions{.eps, .ps}
\fi
\graphicspath{{figs/}}
\RequirePackage{graphicx}
\RequirePackage{subfigure}
\RequirePackage{psfrag}
\RequirePackage{colortbl}

% ************************ Page layout ************************
\topmargin	    -20mm
\headheight		30mm
\headsep  	    	6mm
\footskip 			11mm
\oddsidemargin 	2mm
\evensidemargin 	2mm
\marginparsep   	145mm
\marginparwidth 	8mm
\textwidth 		162mm
\textheight		225mm
\parindent		0mm
\parskip			3mm

%Floats (tables, figures)
% http://www.eng.cam.ac.uk/help/tpl/textprocessing/squeeze.html
\floatsep			10mm
\intextsep			2ex
\textfloatsep		10pt
\abovecaptionskip 5pt
\belowcaptionskip 5pt
% Section and subsection are de-idented (text body is idented)
\def\@secindent{8mm}
% how wide is the header
\def\@htwidth{172mm}

%colors
\definecolor{lightgrey}{rgb}{0.95,0.95,0.95}

%% Change the font
\renewcommand{\familydefault}{\sfdefault}
%% Make Registered Trademark symbol raised
\newcommand{\tm}{\textsuperscript{\texttrademark}}
\newcommand{\rtm}{\textsuperscript{\textregistered}}
\renewcommand{\copyright}{\textcopyright}


\setcounter{secnumdepth}{4}
\setcounter{tocdepth}{3}
\newlength\captionwidth
\setlength\captionwidth{13cm}

\renewcommand{\paragraph}[1]{\newpar{#1}\ \vspace{0.3cm}\\}

\renewcommand{\section}{\@startsection
{section}%                   % the name
{1}%                         % the level
{-\@secindent}%              % the indent
{-18pt}%           
{6pt}%          % the after skip
{\Large\bf}} 	% the style

\renewcommand{\subsection}{\@startsection
{subsection}%                   % the name
{1}%                         % the level
{-\@secindent}%                       % the indent
{-6pt}%           
{6pt}%          % the after skip
{\large\bf}} % the style

\renewcommand{\subsubsection}{\@startsection
{subsubsection}%                   % the name
{1}%                         % the level
{-\@secindent}%                       % the indent
{-6pt}%           
{6pt}%          % the after skip
{\bf}} % the style




% ************************ Date format ************************
\def\shorttoday{\ifcase\month\or
 Jan\or Feb\or Mar\or Apr\or May\or Jun\or Jul\or Aug\or
 Sep\or Oct\or Nov\or Dec\fi~\number\day, \number\year}

\def\shorttoday{\number\day-\ifcase\month\or
 Jan\or Feb\or Mar\or Apr\or May\or Jun\or Jul\or Aug\or
 Sep\or Oct\or Nov\or Dec\fi-\number\year}

\newcommand{\paddedday}{\ifnum\number\day<10 0\number\day\else \number\day\fi}
\newcommand{\paddedmonth}{\ifnum\number\month<10 0\number\month\else \number\month\fi}

\def\shorttoday{\number\year/\paddedmonth/\paddedday}


% ************************ Document Variables ************************
% main author
\newcommand*{\authorName}[1]{\def\@authorName{#1}}
\authorName{}
% Additional Authors
\newcommand*{\authorAddress}[1]{\def\@authorAddress{#1}}
\authorAddress{} 
\newcommand*{\authorURL}[1]{\def\@authorURL{#1}}
\authorURL{} 
\newcommand*{\authorEmail}[1]{\def\@authorEmail{#1}}
\authorEmail{} 
% When was the document written/submitted (not compiled)
\newcommand*{\docDate}[1]{\def\@docDate{#1}}
\docDate{}
% unique identifier     
\newcommand*{\docID}[1]{\def\@docID{#1}}
\docID{}
% type of document
\newcommand*{\docType}[1]{\def\@docType{#1}}
\docType{Technical Note}
% Title of the document
\newcommand*{\docTitle}[1]{\def\@docTitle{#1}}
\docTitle{}
% Title of the document
\newcommand*{\docSubtitle}[1]{\def\@docSubtitle{#1}}
\docSubtitle{}
% current revision
\newcommand*{\docRevision}[1]{\def\@docRevision{#1}}
\docRevision{0.1}
% Status Draft/revision/ final
\newcommand*{\docStatus}[1]{\def\@docStatus{#1}}
\docStatus{Draft}
% Who will receive the doc -- differnece to customers???
\newcommand*{\recipientList}[1]{\def\@recipientList{#1}}
% list of keywords
\newcommand*{\keywords}[1]{\def\@keywords{#1}}
\keywords{}
% list of revisions
\newcommand*{\revisionList}[1]{\def\@revisionList{#1}}
\revisionList{}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\newenvironment{CompactList}
{\begin{list}{}{
  \setlength{\leftmargin}{0.5cm}
  \setlength{\itemsep}{0pt}
  \setlength{\parsep}{0pt}
  \setlength{\topsep}{0pt}
  \renewcommand{\makelabel}{\hfill}}}
{\end{list}}

\newenvironment{CompactItemize}
{
  \begin{itemize}
  \setlength{\itemsep}{-3pt}
  \setlength{\parsep}{0pt}
  \setlength{\topsep}{0pt}
  \setlength{\partopsep}{0pt}
}
{\end{itemize}}

\newcommand{\entrylabel}[1]{
   {\parbox[b]{\labelwidth}{\makebox[0pt][l]{\textbf{#1}}\vspace{1.5\baselineskip}}}}

\newcommand{\paragraphbreak}[1]{\paragraph{#1}\ \vspace{0.3cm}\\}
\newcommand{\subparagraphbreak}[1]{\subparagraph{#1}\ \vspace{0.3cm}\\}

\newenvironment{Desc}
{\begin{list}{}
  {
    \settowidth{\labelwidth}{40pt}
    \setlength{\leftmargin}{\labelwidth}
    \setlength{\parsep}{0pt}
    \setlength{\itemsep}{-4pt}
    \renewcommand{\makelabel}{\entrylabel}
  }
}
{\end{list}}
      \lstset{
            breaklines,
            tabsize=5,
            columns=flexible,
            extendedchars,
            xleftmargin=2em,
            basicstyle=\scriptsize\sffamily,
            showstringspaces=false,
            emptylines=*1,
            frame=single,
            literate={[]}{[{$\;$}]}3,
            captionpos=b
            backgroundcolor=\color{lightgrey}}
%\lstlistingname="Listing"


% ************************ Header/footer ************************
\pagestyle{fancy}
\renewcommand{\headrulewidth}{0.0pt}
\renewcommand{\footrulewidth}{0.0pt}

\fancyhead[O,E]{
 \leftskip-\@secindent
 \begin{tabularx}{185mm}{p{98mm}   p{45mm}  p{25mm}}
 \hskip2mm \sc{ \@docTitle } &    & \hskip2mm \thepage / \pageref{LastPage} 
 \end{tabularx}	
 \includegraphics[width=\@htwidth]{fancy_headsep_r}
}
 


 \fancyfoot{}
 \fancyfoot[ER,OL]{
   \tiny{All rights reserved - \copyright \number\year \ \@authorName}
 }
 \fancyfoot[EL,OR]{
   \tiny{\@docID \  (v. \@docRevision) - \@\shorttoday}
 }

 
\fancypagestyle{plain}{
   \renewcommand{\headrulewidth}{0.0pt}
   \renewcommand{\footrulewidth}{0.0pt}
   \fancyhead{}
   \fancyfoot[EL,OL]{}
   \renewcommand{\headrulewidth}{0pt}
 }




\renewenvironment{abstract}{
    \small
    \begin{center}
      {\bf\large \abstractname
          \vspace{-.5em}\vspace{\z@}}
    \end{center}
}

% ************************ Revision table *********************
\newcommand{ \revisionTable } {
    \section*{Change History}
	\begin{tabularx}{\textwidth} {| p{11mm} | p{14mm} | X | p{23mm} | p{32mm} |}
      	\hline
      	Rev. & Chapter & Description & Date & Reviewer \\
      	\hline
      	\@revisionList
	\hline
    \end{tabularx}
}

% ************************ Cover table ************************
\def\@maketitle{
 	 \vglue80mm
 %% Title
      \begin{minipage}{0.65\linewidth}
        \begin{flushleft}
           \Huge{\textbf{\sc{\@docTitle}}}
       \end{flushleft}
       \end{minipage}
%% fancy line
	\vskip4pt
	\leftskip-17mm
	\includegraphics[width=1.1\textwidth]{fancy_headsep_r}
	\vspace{3pt}
%% addess
	\vglue55mm   
	\begin{tabularx}{\textwidth}{p{55mm} X p{65mm}}
      \begin{minipage}{60mm}
		\includegraphics[width=20mm]{logo}
      \end{minipage} &  &
      \begin{minipage}{62mm}
        	\Large{\@authorName} \\ 
		\large{\@authorAddress}
      \end{minipage} \\
	& & \\
      \large{\@authorURL} & & \large{\@authorEmail}  \\
	\end{tabularx}
	\vspace{2ex}
}  %% End of maketitle
