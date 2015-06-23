%partly based on ruschidoc.cls file from Avalon AES ECB-Core project
\ProvidesClass{gajewski}
\LoadClass[11pt,a4paper,twoside]{article}
\RequirePackage[intlimits,sumlimits]{amsmath}
\RequirePackage{fancyhdr}
\RequirePackage[T1]{fontenc}
\RequirePackage[latin1]{inputenc}
\RequirePackage{amsmath}
\RequirePackage{helvet}
\RequirePackage{lastpage}
\RequirePackage{tabularx}
\RequirePackage{textcomp}
\RequirePackage{graphicx}
\RequirePackage{graphics}
\RequirePackage[bookmarks, plainpages={false}]{hyperref}
\RequirePackage{capt-of}
\graphicspath{{img/}}

% ************************ Page layout ************************
\topmargin	    	-20mm
\headheight			30mm
\headsep  	    	6mm
\footskip 			11mm
\oddsidemargin 	2mm
\evensidemargin 	2mm
\marginparsep   	145mm
\marginparwidth 	8mm
\textwidth 			162mm
\textheight			225mm
\parindent			0mm
\parskip				3mm

% Section and subsection are de-idented (text body is idented)
\def\@secindent{8mm}
% how wide is the header
\def\@htwidth{172mm}

%% Change the font
\renewcommand{\familydefault}{\sfdefault}
%% Make Registered Trademark symbol raised
\newcommand{\tm}{\textsuperscript{\texttrademark}}
\newcommand{\rtm}{\textsuperscript{\textregistered}}
\renewcommand{\copyright}{\textcopyright}

\renewcommand{\paragraph}[1]{\newpar{#1}\ \vspace{0.3cm}\\}

\renewcommand{\section}{\@startsection
{section}%                   % the name
{1}%                         % the level
{-\@secindent}%              % the indent
{-18pt}%           
{6pt}%          % the after skip
{\huge\bf}} 	% the style

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
\newcommand*{\docTitleShort}[1]{\def\@docTitleShort{#1}}
\docTitleShort{}
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

% ************************ Header/footer ************************
\def\@secindent{8mm}

\pagestyle{fancy}
\renewcommand{\headrulewidth}{0.4pt}
\renewcommand{\footrulewidth}{0.4pt}

\fancyhead[O,E]{
 \leftskip-\@secindent
 \begin{tabularx}{185mm}{p{98mm}   p{45mm}  p{25mm}}
 \hskip2mm \sc{ \@docTitleShort } &    & \hskip2mm \thepage / \pageref{LastPage} 
 \end{tabularx}	
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

% ************************ Revision table *********************
\newcommand{ \revisionTable } {
    \section*{Change History}
	\begin{tabularx}{\textwidth} {| p{11mm} | p{14mm} | p{23mm} | X | p{32mm} |}
      	\hline
      	Rev. & Chapter & Date & Description & Reviewer \\
      	\hline
      	\@revisionList
	\hline
    \end{tabularx}
}

% ************************ Cover table ************************
\def\@maketitle{
 	 \vglue40mm
 %% Title
      \begin{minipage}{0.65\linewidth}
        \begin{flushleft}
           \Huge{\textbf{\sc{\@docTitle}}} \\
           \LARGE{documentation}
       \end{flushleft}
       \end{minipage}
%% fancy line
	\vskip4pt
	\leftskip-17mm
	\vspace{3pt}
%% addes5mm
	\vglue95mm
	\begin{tabularx}{\textwidth}{p{55mm} X p{65mm}}
      \begin{minipage}{60mm}
		\includegraphics[width=0.3\textwidth]{logo.png}
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
