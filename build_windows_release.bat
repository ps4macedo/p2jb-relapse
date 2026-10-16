@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

REM ==========================================================
REM  ENTRYPOINTS DAS ETAPAS (rodar em janelas separadas)
REM ==========================================================
if /i "%~1"=="__STEP1__" goto STEP1
if /i "%~1"=="__STEP2__" goto STEP2
if /i "%~1"=="__STEP3__" goto STEP3
if /i "%~1"=="__STEP4__" goto STEP4

REM ==========================================================
REM  Mantem a janela principal aberta SEMPRE
REM ==========================================================
if /i "%~1"=="clean" (
  start "Y2JB THEME GENERATOR (EXE)" /max "%ComSpec%" /k ""%~f0" __RUN__ CLEAN"
  exit /b
)
if /i "%~1"=="noclean" (
  start "Y2JB THEME GENERATOR (EXE)" /max "%ComSpec%" /k ""%~f0" __RUN__ NOCLEAN"
  exit /b
)
if /i "%~1" NEQ "__RUN__" (
  start "Y2JB THEME GENERATOR (EXE)" /max "%ComSpec%" /k ""%~f0" __RUN__"
  exit /b
)

set "DO_CLEAN="
if /i "%~2"=="CLEAN" set "DO_CLEAN=1"
if /i "%~2"=="NOCLEAN" set "DO_CLEAN=0"

echo ==============================================================
echo  Y2JB THEME GENERATOR - GERA EXE / ENVIA P/ GITHUB RELEASE
echo ==============================================================
echo.

if not defined DO_CLEAN (
  choice /c SN /n /m "Deseja limpar build/dist/.venv_exe antes da compilacao? [S/N]: "
  if errorlevel 2 (
    set "DO_CLEAN=0"
  ) else (
    set "DO_CLEAN=1"
  )
  echo.
)

if "%DO_CLEAN%"=="1" (
  echo [INFO] Modo de compilacao: LIMPEZA COMPLETA ^(mais lento nesta execucao^)
) else (
  echo [INFO] Modo de compilacao: RAPIDO ^(sem limpeza completa nesta execucao^)
)
echo.

call :SETVARS
if errorlevel 1 (
  echo [ERRO] Falha ao detectar variaveis do projeto.
  echo [ERRO] Verifique se este .bat esta dentro da pasta do projeto e se existe buildozer.spec com:
  echo        version = ...
  echo        package.name = ...
  echo.
  pause
  exit /b 1
)

echo ----------------------------------------------------------
echo  O QUE ESTE SCRIPT FAZ (resumo rapido)
echo ----------------------------------------------------------
echo  - Etapa 1: Valida assets e prepara o ambiente Windows do EXE
echo  - Etapa 2: Gera um unico EXE via PyInstaller ^(onefile^)
echo  - Etapa 3: Copia o EXE para C:\GitHub\y2jb_theme_generator
echo  - Etapa 4: Atualiza Release no GitHub com o EXE
echo ----------------------------------------------------------
echo  Caminhos importantes:
echo   Projeto (Windows): %WIN_SRC%
echo   Venv EXE        : %VENV_DIR%
echo   Dist            : %DIST_DIR%
echo   EXE final       : %DIST_EXE%
echo   Repo (Windows)  : %WIN_REPO%
echo   EXE no Repo     : %WIN_REPO%\%REPO_EXE_NAME%
echo ----------------------------------------------------------
echo.

echo -----------------------------------------------
echo [1/4] Preparar ambiente Windows do EXE
echo -----------------------------------------------
echo.
echo [INFO] Vai validar e/ou preparar:
echo   %WIN_SRC%\main.py
echo   %WIN_SRC%\ui.kv
echo   %WIN_SRC%\i18n.py
echo   %WIN_SRC%\ps5_updater_core.py
echo   %WIN_SRC%\icon.png
echo   %WIN_SRC%\logo.png
echo   %WIN_SRC%\fonts\
echo   %WIN_SRC%\idiomas\
echo   %WIN_SRC%\theme_stub.elf
echo   %WIN_SRC%\y2jb_theme_generator_windows.spec
echo.
echo [INFO] Abrindo janela da etapa 1/4...
start "1- Preparar ambiente EXE" /wait "%ComSpec%" /c ""%~f0" __STEP1__"
if errorlevel 1 (
  echo.
  echo [ERRO] Falha ao preparar o ambiente do EXE.
  exit /b 1
)
echo [OK] Ambiente validado/preparado.
echo.

echo -----------------------------------------------
echo [2/4] Gerar um unico EXE -^> PyInstaller onefile
echo -----------------------------------------------
echo.
echo [INFO] Spec usado:
echo   %SPEC_FILE%
echo [INFO] Saida esperada:
echo   %DIST_EXE%
echo.
echo [INFO] Abrindo janela da etapa 2/4...
start "2- Gerar EXE (PyInstaller)" /wait "%ComSpec%" /c ""%~f0" __STEP2__"
if errorlevel 1 (
  echo.
  echo [ERRO] Falha ao gerar o EXE com PyInstaller.
  exit /b 1
)
echo.
echo [OK] EXE gerado.
echo [OK] EXE (Windows): %DIST_EXE%
echo.

echo -----------------------------------------------
echo [3/4] Copiar EXE -^> Repo (Windows)
echo -----------------------------------------------
echo.
echo [INFO] Copia do EXE:
echo   %DIST_EXE%
echo [INFO] Para o repo:
echo   %WIN_REPO%\%REPO_EXE_NAME%
echo.
echo [INFO] Abrindo janela da etapa 3/4...
start "3- Copiar EXE p/ Repo" /wait "%ComSpec%" /c ""%~f0" __STEP3__"
if errorlevel 1 (
  echo.
  echo [ERRO] Falha ao copiar o EXE para o repo.
  pause
  exit /b 1
)
echo [OK] EXE copiado para o repo.
echo.

echo -----------------------------------------------
echo [4/4] Atualizar Release (EXE)
echo -----------------------------------------------
echo.
echo [INFO] Repo: ps4macedo/y2jb_theme_generator
echo [INFO] Tag : v%APP_VERSION%
echo [INFO] Asset (Windows):
echo   %WIN_REPO%\%REPO_EXE_NAME%
echo.
echo [INFO] Abrindo janela da etapa 4/4...
start "4- Atualizar Release (EXE)" /wait "%ComSpec%" /c ""%~f0" __STEP4__"
if errorlevel 1 (
  echo.
  echo [ERRO] Falha ao atualizar a Release com o EXE.
  pause
  exit /b 1
)

echo.
echo ==========================================================
echo [OK] Concluido.
echo ==========================================================
echo.
pause
exit /b 0

:STEP1
call :SETVARS
if not exist "%WIN_SRC%\main.py" call :FAIL "main.py nao encontrado na raiz do projeto."
if not exist "%WIN_SRC%\ui.kv" call :FAIL "ui.kv nao encontrado na raiz do projeto."
if not exist "%WIN_SRC%\i18n.py" call :FAIL "i18n.py nao encontrado na raiz do projeto."
if not exist "%WIN_SRC%\ps5_updater_core.py" call :FAIL "ps5_updater_core.py nao encontrado na raiz do projeto."
if not exist "%WIN_SRC%\icon.png" call :FAIL "icon.png nao encontrado na raiz do projeto."
if not exist "%WIN_SRC%\logo.png" call :FAIL "logo.png nao encontrado na raiz do projeto."
if not exist "%WIN_SRC%\theme_stub.elf" call :FAIL "theme_stub.elf nao encontrado na raiz do projeto."
if not exist "%SPEC_FILE%" call :FAIL "y2jb_theme_generator_windows.spec nao encontrado na raiz do projeto."
if not exist "%WIN_SRC%\fonts" call :FAIL "Pasta fonts nao encontrada."
if not exist "%WIN_SRC%\idiomas" call :FAIL "Pasta idiomas nao encontrada."

where py >nul 2>&1 || where python >nul 2>&1 || call :FAIL "Python nao encontrado no PATH do Windows."

if "%DO_CLEAN%"=="1" (
  echo [INFO] Limpando build anterior...
  if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
  if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%"
  if exist "%VENV_DIR%" rmdir /s /q "%VENV_DIR%"
)

if not exist "%VENV_DIR%\Scripts\python.exe" (
  echo [INFO] Criando .venv_exe...
  if exist "%VENV_DIR%" rmdir /s /q "%VENV_DIR%"
  py -3 -m venv "%VENV_DIR%" 2>nul || python -m venv "%VENV_DIR%" || call :FAIL "Falha ao criar a .venv_exe."
)

echo [INFO] Ambiente validado com sucesso.
exit /b 0

:STEP2
call :SETVARS
call "%VENV_DIR%\Scripts\activate.bat" || call :FAIL "Falha ao ativar a .venv_exe."

echo [INFO] Atualizando pip/setuptools/wheel...
python -m pip install --upgrade pip setuptools wheel || call :FAIL "Falha ao atualizar pip/setuptools/wheel."

echo [INFO] Instalando dependencias do EXE...
python -m pip install --upgrade pyinstaller kivy kivymd pillow pyjnius || call :FAIL "Falha ao instalar PyInstaller/Kivy/KivyMD/Pillow/Pyjnius."

if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
if exist "%DIST_DIR%" rmdir /s /q "%DIST_DIR%"

echo [INFO] Gerando EXE via spec...
python -m PyInstaller --noconfirm --clean "%SPEC_FILE%" || call :FAIL "Falha no PyInstaller."

if not exist "%DIST_EXE%" call :FAIL "EXE final nao encontrado apos o PyInstaller."

echo [INFO] EXE final gerado:
echo        %DIST_EXE%
exit /b 0

:STEP3
call :SETVARS
if not exist "%DIST_EXE%" call :FAIL "EXE final nao encontrado: %DIST_EXE%"
if not exist "%WIN_REPO%" mkdir "%WIN_REPO%" || call :FAIL "Falha ao criar o repo local: %WIN_REPO%"
copy /y "%DIST_EXE%" "%WIN_REPO%\%REPO_EXE_NAME%" >nul || call :FAIL "Falha ao copiar o EXE para o repo local."
if not exist "%WIN_REPO%\%REPO_EXE_NAME%" call :FAIL "EXE nao encontrado no repo local apos a copia."
exit /b 0

:STEP4
call :SETVARS
title 4- Atualizar Release (WSL)
cls
echo ==========================================================
echo  [STEP4] ATUALIZAR RELEASE (GITHUB) - WSL
echo ==========================================================
echo.
echo [INFO] Repo        : ps4macedo/y2jb_theme_generator
echo [INFO] Tag         : v%APP_VERSION%
echo [INFO] EXE_WINDOWS : %WIN_REPO%\%REPO_EXE_NAME%
echo [INFO] EXE_WSL     : %WSL_REPO%/%REPO_EXE_NAME%
echo.

if not exist "%WIN_REPO%\%REPO_EXE_NAME%" call :FAIL "EXE nao encontrado: %WIN_REPO%\%REPO_EXE_NAME%"

wsl bash -lc "set -e; echo '[INFO] REPO esperado: ps4macedo/y2jb_theme_generator'; echo '[INFO] TAG esperada: v%APP_VERSION%'; echo '[INFO] EXE esperado: %WSL_REPO%/%REPO_EXE_NAME%'; command -v gh >/dev/null 2>&1 || { echo '[ERRO] gh nao encontrado no WSL'; exit 1; }; gh auth status -h github.com >/dev/null 2>&1 || { echo '[ERRO] gh nao autenticado no WSL. Rode: gh auth login'; exit 1; }; test -f '%WSL_REPO%/%REPO_EXE_NAME%' || { echo '[ERRO] EXE nao encontrado: %WSL_REPO%/%REPO_EXE_NAME%'; exit 1; }; if gh release view 'v%APP_VERSION%' -R 'ps4macedo/y2jb_theme_generator' >/dev/null 2>&1; then echo '[INFO] Release existe. Atualizando EXE com clobber...'; gh release upload 'v%APP_VERSION%' '%WSL_REPO%/%REPO_EXE_NAME%' -R 'ps4macedo/y2jb_theme_generator' --clobber; else echo '[INFO] Release nao existe. Criando com EXE...'; gh release create 'v%APP_VERSION%' '%WSL_REPO%/%REPO_EXE_NAME%' -R 'ps4macedo/y2jb_theme_generator' --title 'v%APP_VERSION%' --notes 'Arquivos desta versao' --latest; fi"

if errorlevel 1 (
  echo.
  echo [ERRO] Falha ao atualizar a Release.
  echo.
  pause
  exit /b 1
)

echo.
echo [OK] Release atualizada.
timeout /t 2 >nul
exit /b 0

:FAIL
echo.
echo [ERRO] %~1
echo.
pause
exit /b 1

:SETVARS
set "WIN_SRC=%~dp0"
if "%WIN_SRC:~-1%"=="\" set "WIN_SRC=%WIN_SRC:~0,-1%"

for %%I in ("%WIN_SRC%") do set "PROJ_NAME=%%~nxI"

if not exist "%WIN_SRC%\buildozer.spec" exit /b 1

setlocal EnableExtensions EnableDelayedExpansion
set "APP_VERSION="
set "PKG_NAME="

for /f "usebackq delims=" %%S in ("%WIN_SRC%\buildozer.spec") do (
  set "LINE=%%S"
  for /f "tokens=* delims= " %%T in ("!LINE!") do set "LINE=%%T"

  if not "!LINE!"=="" if not "!LINE:~0,1!"=="#" if not "!LINE:~0,1!"==";" (
    for /f "tokens=1,* delims==" %%K in ("!LINE!") do (
      set "KEY=%%K"
      set "VAL=%%L"

      set "KEY=!KEY: =!"
      set "KEY=!KEY:	=!"
      set "VAL=!VAL:~0,4096!"
      for /f "tokens=* delims= " %%A in ("!VAL!") do set "VAL=%%A"
      if defined VAL if "!VAL:~-1!"==" " set "VAL=!VAL:~0,-1!"
      set "VAL=!VAL:"=!"

      if /i "!KEY!"=="version"       if not defined APP_VERSION set "APP_VERSION=!VAL!"
      if /i "!KEY!"=="package.name"  if not defined PKG_NAME    set "PKG_NAME=!VAL!"
    )
  )

  if defined APP_VERSION if defined PKG_NAME goto _SETVARS_DONE
)

:_SETVARS_DONE
if not defined APP_VERSION ( endlocal & exit /b 1 )
if not defined PKG_NAME    ( endlocal & exit /b 1 )

set "APPV=!APP_VERSION!"
set "PKGN=!PKG_NAME!"
endlocal & (
  set "APP_VERSION=%APPV%"
  set "PKG_NAME=%PKGN%"
)

set "APP_TITLE=Y2JB Theme Generator"
set "SPEC_FILE=%WIN_SRC%\y2jb_theme_generator_windows.spec"
set "VENV_DIR=%WIN_SRC%\.venv_exe"
set "BUILD_DIR=%WIN_SRC%\build"
set "DIST_DIR=%WIN_SRC%\dist"
set "DIST_EXE=%DIST_DIR%\%APP_TITLE%.exe"
set "WIN_REPO=C:\GitHub\y2jb_theme_generator"
set "WSL_REPO=/mnt/c/GitHub/y2jb_theme_generator"
set "REPO_EXE_NAME=%PROJ_NAME%-%APP_VERSION%-windows.exe"

exit /b 0
