#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>
#include <shellapi.h>

BOOL WINAPI DllMain(HINSTANCE hInst, DWORD reason, LPVOID reserved) {
    (void)hInst; (void)reserved;
    if (reason == DLL_PROCESS_ATTACH) DisableThreadLibraryCalls(hInst);
    return TRUE;
}

typedef BOOL (WINAPI *PFN_INSTALL_NODE)(const wchar_t*, const wchar_t*, const wchar_t*);

__declspec(dllexport) BOOL WINAPI UnzipCabinetPackage(const wchar_t* cabPath, const wchar_t* extractDir) {
    // Ensure destination directory exists
    CreateDirectoryW(extractDir, NULL);

    // 1. Unzip/Open CAB using Windows built-in expand.exe via ShellExecuteEx
    wchar_t cmdArgs[MAX_PATH * 3];
    swprintf_s(cmdArgs, sizeof(cmdArgs)/sizeof(wchar_t), L"-F:* \"%s\" \"%s\"", cabPath, extractDir);

    SHELLEXECUTEINFOW sei = { sizeof(sei) };
    sei.fMask = SEE_MASK_NOCLOSEPROCESS;
    sei.lpFile = L"expand.exe";
    sei.lpParameters = cmdArgs;
    sei.nShow = SW_HIDE;

    if (!ShellExecuteExW(&sei) || !sei.hProcess) {
        return FALSE;
    }
    WaitForSingleObject(sei.hProcess, INFINITE);
    CloseHandle(sei.hProcess);

    // 2. Load mwreg.dll to handle file copying and registry imports
    HMODULE hMwReg = LoadLibraryW(L"mwreg.dll");
    if (!hMwReg) return FALSE;
    PFN_INSTALL_NODE InstallNode = (PFN_INSTALL_NODE)GetProcAddress(hMwReg, "InstallCabPackageNode");
    if (!InstallNode) {
        FreeLibrary(hMwReg);
        return FALSE;
    }

    // 3. Open the parsed config JSON file from inside the extracted CAB folder
    wchar_t jsonPath[MAX_PATH];
    swprintf_s(jsonPath, MAX_PATH, L"%s\\config.json", extractDir);

    FILE* f = NULL;
    if (_wfopen_s(&f, jsonPath, L"rt") != 0 || !f) {
        FreeLibrary(hMwReg);
        return FALSE;
    }

    fseek(f, 0, SEEK_END);
    long len = ftell(f);
    fseek(f, 0, SEEK_SET);
    char* jsonBuf = (char*)malloc(len + 1);
    fread(jsonBuf, 1, len, f);
    jsonBuf[len] = '\0';
    fclose(f);

    wchar_t jsonWide[8192];
    MultiByteToWideChar(CP_UTF8, 0, jsonBuf, -1, jsonWide, 8192);
    free(jsonBuf);

    // 4. Locate associated .reg file inside extracted contents and send node + reg to mwreg.dll
    wchar_t regFilePath[MAX_PATH];
    swprintf_s(regFilePath, MAX_PATH, L"%s\\import.reg", extractDir);

    // Passes one JSON file-list node and one .reg file at a time
    InstallNode(jsonWide, regFilePath, extractDir);

    FreeLibrary(hMwReg);
    return TRUE;
}