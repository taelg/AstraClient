@echo off
setlocal enabledelayedexpansion
REM ============================================================
REM  build_windows.cmd - Compila o AstraClient (otclient 8.60)
REM  Visual Studio 2022 BuildTools + vcpkg (manifest) + MSBuild
REM
REM  Config escolhida por padrao: OpenGL|x64 (Release)
REM  -> gera: otclient_gl_x64.exe na raiz do projeto
REM  Para DirectX (ao inves de OpenGL), defina BACKEND=DirectX
REM    set BACKEND=DirectX
REM ============================================================

set "ROOT=%~dp0"
set "MSBUILD=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
if not defined VCPKG_ROOT set "VCPKG_ROOT=C:\vcpkg"
if not defined BACKEND set "BACKEND=OpenGL"

REM Plataforma x64 (Release). Ajuste aqui se precisar de outro.
set "PLATFORM=x64"

REM Garante que o script roda com o nome correto (evita processo antigo)
cd /d "%ROOT%"

echo [INFO] ROOT:    %ROOT%
echo [INFO] MSBuild: %MSBUILD%
echo [INFO] vcpkg:   %VCPKG_ROOT%
echo [INFO] Backend: %BACKEND%  /  Platform: %PLATFORM%

if not exist "%MSBUILD%" goto :nomsbuild
if not exist "%VCPKG_ROOT%\vcpkg.exe" goto :novcpkg

REM Carrega o ambiente MSVC 2022 (inclui caminhos do compilador/MSBuild)
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" >nul 2>&1
if errorlevel 1 goto :nomsvc

REM Integra o vcpkg (garante que o VS consiga usa-lo via manifest)
call "%VCPKG_ROOT%\vcpkg.exe" integrate install >nul 2>&1

echo.
echo [PASSO 1/2] Instalando/compilando dependencias via vcpkg manifest (primeira vez demora)...
call "%VCPKG_ROOT%\vcpkg.exe" install --triplet x64-windows-static --x-install-root="%ROOT%vcpkg_installed"
if errorlevel 1 goto :erro

echo.
echo [PASSO 2/2] Compilando o cliente (%BACKEND%/%PLATFORM%) com MSBuild...
"%MSBUILD%" "%ROOT%vc23\otclient.sln" /p:Configuration="%BACKEND%" /p:Platform=%PLATFORM% /p:VcpkgRoot="%VCPKG_ROOT%" /m
if errorlevel 1 goto :erro

echo.
echo [DONE] Build concluida.
echo Binario esperado: "%ROOT%otclient_gl_x64.exe"  (ou otclient_dx_x64.exe se BACKEND=DirectX)
if exist "%ROOT%otclient_gl_x64.exe" echo [OK] otclient_gl_x64.exe encontrado.
if exist "%ROOT%otclient_dx_x64.exe" echo [OK] otclient_dx_x64.exe encontrado.
goto :fim

:novcpkg
echo [ERRO] vcpkg nao encontrado: %VCPKG_ROOT%\vcpkg.exe
goto :fim

:nomsvc
echo [ERRO] Nao foi possivel carregar vcvars64.bat
goto :fim

:nomsbuild
echo [ERRO] MSBuild nao encontrado: %MSBUILD%
goto :fim

:erro
echo [ERRO] A build falhou. Veja as mensagens acima.
goto :fim

:fim
endlocal
