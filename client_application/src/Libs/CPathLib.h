/*
 * @file     PathLib.h
 * @date     May 14, 2012
 * @author   Aart Mulder
 */

#ifndef CPATHLIB_H
#define CPATHLIB_H

/* System includes */
#ifdef QT
#include <QDataStream>
#include <QList>
#include <QString>
#else
#include <list>
#include <string>
#endif

/* Own includes */

class CPathLib
{
public:
    CPathLib();

	static char* CompletePath(char* pcPath);
	static std::string CompletePath(std::string sPath);
#ifdef QT
	static QString CompletePath(QString sPath);
#endif

#ifdef QT
	static void DeleteFiles(QList<QString> *pFiles, QList<bool> *pResults);
#else
	static void DeleteFiles(std::list<std::string> *pFiles, std::list<bool> *pResults);
#endif

#ifdef QT
    static QList<QString> ReadDir(QString sDir);
	static bool ReadDir(QString sDir, QList<QString> *paFiles, QString sFilter);
	static bool ReadDir(QString sDir, QList<QString> *paFiles, QList<quint32> *paFileSizes = NULL, QString *sFilter = NULL);
#endif

};

#endif // CPATHLIB_H
