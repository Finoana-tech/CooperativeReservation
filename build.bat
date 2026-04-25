@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Compilation du projet CooperativeReservation
echo ========================================

REM Définir le répertoire courant comme répertoire du projet
set PROJECT_DIR=%CD%
set SRC_DIR=%PROJECT_DIR%\src\main\java
set LIB_DIR=%PROJECT_DIR%\WEB-INF\lib
set CLASSES_DIR=%PROJECT_DIR%\WEB-INF\classes
set TOMCAT_LIB=D:\projetJSP\apache-tomcat-9.0.117-windows-x64\apache-tomcat-9.0.117\lib

echo Repertoire du projet: %PROJECT_DIR%
echo Dossier sources: %SRC_DIR%
echo Dossier lib: %LIB_DIR%
echo Dossier classes: %CLASSES_DIR%
echo.

REM Créer le dossier classes s'il n'existe pas
if not exist "%CLASSES_DIR%" mkdir "%CLASSES_DIR%"

REM Nettoyer les anciens fichiers .class
echo Nettoyage des anciens fichiers .class...
if exist "%CLASSES_DIR%\controller\*.class" del /Q "%CLASSES_DIR%\controller\*.class" 2>nul
if exist "%CLASSES_DIR%\dao\*.class" del /Q "%CLASSES_DIR%\dao\*.class" 2>nul
if exist "%CLASSES_DIR%\model\*.class" del /Q "%CLASSES_DIR%\model\*.class" 2>nul
if exist "%CLASSES_DIR%\util\*.class" del /Q "%CLASSES_DIR%\util\*.class" 2>nul

REM Construire le classpath avec tous les jars
set CLASSPATH=%CLASSES_DIR%

REM Ajouter les jars du projet (AVEC EXPANSION RETARDÉE)
if exist "%LIB_DIR%\*.jar" (
    for %%f in ("%LIB_DIR%\*.jar") do (
        set "CLASSPATH=!CLASSPATH!;%%f"
    )
)

REM Ajouter servlet-api.jar de Tomcat
if exist "%TOMCAT_LIB%\servlet-api.jar" (
    set "CLASSPATH=!CLASSPATH!;%TOMCAT_LIB%\servlet-api.jar"
    echo servlet-api.jar ajoute au classpath
)

REM Ajouter jsp-api.jar de Tomcat
if exist "%TOMCAT_LIB%\jsp-api.jar" (
    set "CLASSPATH=!CLASSPATH!;%TOMCAT_LIB%\jsp-api.jar"
    echo jsp-api.jar ajoute au classpath
)

echo Classpath: !CLASSPATH!
echo.

echo Compilation des sources Java...
echo.

REM AJOUT DE --release 21 POUR COMPATIBILITÉ AVEC TON RUNTIME
set JAVAC_OPTS=--release 21

echo [1/5] Compilation du package util...
javac %JAVAC_OPTS% -cp "!CLASSPATH!" -d "%CLASSES_DIR%" "%SRC_DIR%\util\DatabaseConnection.java"
if !errorlevel! neq 0 goto :error

echo [2/5] Compilation du package model...
javac %JAVAC_OPTS% -cp "!CLASSPATH!" -d "%CLASSES_DIR%" "%SRC_DIR%\model\Client.java" "%SRC_DIR%\model\Reservation.java" "%SRC_DIR%\model\Voiture.java" "%SRC_DIR%\model\Place.java"
if !errorlevel! neq 0 goto :error

echo [3/5] Compilation du package dao...
javac %JAVAC_OPTS% -cp "!CLASSPATH!" -d "%CLASSES_DIR%" "%SRC_DIR%\dao\ClientDAO.java" "%SRC_DIR%\dao\ReservationDAO.java" "%SRC_DIR%\dao\VoitureDAO.java" "%SRC_DIR%\dao\PlaceDAO.java"
if !errorlevel! neq 0 goto :error

echo [4/5] Compilation du package controller...
javac %JAVAC_OPTS% -cp "!CLASSPATH!" -d "%CLASSES_DIR%" "%SRC_DIR%\controller\ClientServlet.java"
if !errorlevel! neq 0 goto :error

javac %JAVAC_OPTS% -cp "!CLASSPATH!" -d "%CLASSES_DIR%" "%SRC_DIR%\controller\ReservationServlet.java"
if !errorlevel! neq 0 goto :error

javac %JAVAC_OPTS% -cp "!CLASSPATH!" -d "%CLASSES_DIR%" "%SRC_DIR%\controller\VoitureServlet.java"
if !errorlevel! neq 0 goto :error

javac %JAVAC_OPTS% -cp "!CLASSPATH!" -d "%CLASSES_DIR%" "%SRC_DIR%\controller\StatistiqueServlet.java"
if !errorlevel! neq 0 goto :error

javac %JAVAC_OPTS% -cp "!CLASSPATH!" -d "%CLASSES_DIR%" "%SRC_DIR%\controller\CheckPlacesServlet.java"
if !errorlevel! neq 0 goto :error

echo [5/5] Compilation de BilletPdfServlet avec iText...
javac %JAVAC_OPTS% -cp "!CLASSPATH!" -d "%CLASSES_DIR%" "%SRC_DIR%\controller\BilletPdfServlet.java"
if !errorlevel! neq 0 goto :error

echo.
echo ========================================
echo  Compilation reussie !
echo ========================================

REM Afficher les fichiers compilés
echo.
echo Fichiers compiles :
dir /s /b "%CLASSES_DIR%\*.class" 2>nul
echo.

goto :end

:error
echo.
echo ========================================
echo  Erreur de compilation !
echo ========================================

:end
endlocal
pause