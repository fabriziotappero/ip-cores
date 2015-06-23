/*
 * @file     PathLib.cpp
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

/* System includes */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fstream>
#include <iostream>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/types.h>

#ifdef linux
#include <unistd.h>
#else
//#include <direct.h>
#include <stdarg.h>
#include <windef.h>
#include <WinBase.h>
#endif

#ifdef QT
#include <QRegExp>
#include <QFile>
#include <QDir>
#endif

/* Own includes */
#include "CPathLib.h"
#include "stddefs.h"

CPathLib::CPathLib()
{

}

char* CPathLib::CompletePath(char* pcPath)
{
	char aCurrentDir[FILENAME_MAX], *pResult;
#ifdef linux
    char szTmp[32];
#endif
    int bytes;

	pResult = (char*)malloc(sizeof(char) * FILENAME_MAX);

	if( (pcPath[0] == '.') && (pcPath[1] == '/') )
	{
#ifdef linux
        sprintf(szTmp, "/proc/%d/exe", getpid());
        aCurrentDir[0] = '\0';
        bytes = MIN(readlink(szTmp, aCurrentDir, FILENAME_MAX), FILENAME_MAX - 1);
        if(bytes >= 0)
            aCurrentDir[bytes] = '\0';
#else
        bytes = GetModuleFileNameA(NULL, aCurrentDir, FILENAME_MAX);
        if(bytes == 0)
            return NULL;
#endif

		strcpy(pResult, aCurrentDir);
		strcat(pResult, pcPath+1);
	}
	else
	{
		strcpy(pResult, pcPath);
	}

	return pResult;
}

std::string CPathLib::CompletePath(std::string sPath)
{
	char aCurrentDir[FILENAME_MAX];
	std::string sResult;
#ifdef linux
    char szTmp[32];
#endif
    int bytes;

	if( (sPath.at(0) == '.') && (sPath.at(1) == '/') )
	{
#ifdef linux
        sprintf(szTmp, "/proc/%d/exe", getpid());
        aCurrentDir[0] = '\0';
        bytes = MIN(readlink(szTmp, aCurrentDir, FILENAME_MAX), FILENAME_MAX - 1);
        if(bytes >= 0)
            aCurrentDir[bytes] = '\0';
#else
        bytes = GetModuleFileNameA(NULL, aCurrentDir, FILENAME_MAX);
        if(bytes == 0)
            return sResult;
#endif
		sResult.assign(aCurrentDir);
		sResult.append(sPath.substr(1, sPath.length()-1));
	}
	else
	{
		sResult = sPath;
	}

	return sResult;
}

#ifdef QT
QString CPathLib::CompletePath(QString sPath)
{
	char aCurrentDir[FILENAME_MAX];
	QString sResult;
#ifdef linux
    char szTmp[32];
#endif
    int bytes;

	if( (sPath.at(0) == '.') && (sPath.at(1) == '/') )
	{
#ifdef linux
        sprintf(szTmp, "/proc/%d/exe", getpid());
        aCurrentDir[0] = '\0';
        bytes = MIN(readlink(szTmp, aCurrentDir, FILENAME_MAX), FILENAME_MAX - 1);
        if(bytes >= 0)
            aCurrentDir[bytes] = '\0';
#else
        bytes = GetModuleFileNameA(NULL, aCurrentDir, FILENAME_MAX);
        if(bytes == 0)
            return sResult;
#endif
        sResult.fromAscii(aCurrentDir);
		sResult.append(sPath.right(sPath.length()-1));
	}
	else
	{
		sResult = sPath;
	}

	return sResult;
}
#endif

#ifdef QT
void CPathLib::DeleteFiles(QList<QString> *pFiles, QList<bool> *pResults)
#else
void CPathLib::DeleteFiles(std::list<std::string> *pFiles, std::list<bool> *pResults)
#endif
{
#ifdef QT
	QList<QString>::iterator itFiles;
	QString sFilename;
#else
	std::list<std::string>::iterator itFiles;
	std::string sFilename;
#endif

	if(pFiles == NULL)
		return;

	if(pResults == NULL)
		return;

	pResults->clear();

	for(itFiles = pFiles->begin(); itFiles != pFiles->end(); itFiles++)
	{
		sFilename = CompletePath(*itFiles);

#ifdef QT
		if(remove(sFilename.toStdString().c_str()) != 0)
#else
		if(remove(sFilename.c_str()) != 0)
#endif
		{
			pResults->push_back(false);
		}
		else
		{
			pResults->push_back(true);
		}
	}
}

#ifdef QT
QList<QString> CPathLib::ReadDir(QString sDir)
{
	QList<QString> aFiles;

	ReadDir(sDir, &aFiles);

	return aFiles;
}
#endif

#ifdef QT
bool CPathLib::ReadDir(QString sDir, QList<QString> *paFiles, QString sFilter)
{
	return ReadDir(sDir, paFiles, NULL, &sFilter);
}
#endif

#ifdef QT
bool CPathLib::ReadDir(QString sDir, QList<QString> *paFiles, QList<quint32> *paFileSizes, QString *sFilter)
{
	QString filepath;
	DIR *dp;
	struct dirent *dirp;
	struct stat filestat;

	if(paFiles == NULL)
		return false;

	paFiles->clear();

	if(paFileSizes != NULL)
		paFileSizes->clear();

    sDir = CPathLib::CompletePath(sDir);

	dp = opendir(sDir.toStdString().c_str());
	if(dp == NULL)
		return false;

	while( (dirp = readdir(dp)) )
	{
		filepath = sDir + QString("/") + QString("%1").arg(dirp->d_name);

		if(stat(filepath.toStdString().c_str(), &filestat)) continue;
		if( S_ISDIR(filestat.st_mode)) continue;

		/*
		 * Do the filter operation.
		 */
		if(sFilter != NULL)
		{
			if(sFilter->length() > 0)
			{
				QString sFileName(dirp->d_name);
				QRegExp oRegExp(sFilter->toStdString().c_str());
				if( oRegExp.indexIn(sFileName) == 0)
				{
					paFiles->push_back(QString(dirp->d_name));
				}
			}
			else
			{
				paFiles->push_back(QString(dirp->d_name));
			}
		}
		else
		{
			paFiles->push_back(QString(dirp->d_name));
		}

		if(paFileSizes != NULL)
			paFileSizes->push_back(filestat.st_size);
	}

	return true;
}
#endif
