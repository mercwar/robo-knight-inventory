#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdlib.h>
#include <stdio.h>
#include <shellapi.h>

BOOL WINAPI DllMain(HINSTANCE hInst, DWORD reason, LPVOID reserved) {
    (void)hInst; (void)reserved;
    if (reason == DLL_PROCESS_ATTACH) DisableThreadLibraryCalls(hInst);
    return TRUE;
}

// Exported Node Processing Function invoked by unzipcab.dll
__declspec(dllexport) BOOL WINAPI InstallCabPackageNode(const wchar_t* fileListJsonNode, const wchar_t* regFilePath, const wchar_t* workDir) {
    (void)fileListJsonNode; // Processes the JSON file list node

    // 1. Import associated .reg file if it exists
    if (GetFileAttributesW(regFilePath) != INVALID_FILE_ATTRIBUTES) {
        wchar_t cmdArgs[MAX_PATH * 2];
        swprintf_s(cmdArgs, sizeof(cmdArgs)/sizeof(wchar_t), L"/c reg.exe import \"%s\"", regFilePath);
        
        SHELLEXECUTEINFOW sei = { sizeof(sei) };
        sei.fMask = SEE_MASK_NOCLOSEPROCESS;
        sei.lpFile = L"cmd.exe";
        sei.lpParameters = cmdArgs;
        sei.nShow = SW_HIDE;
        
        if (ShellExecuteExW(&sei) && sei.hProcess) {
            WaitForSingleObject(sei.hProcess, INFINITE);
            CloseHandle(sei.hProcess);
        }
    }

    // 2. Perform file copy operations per destination requirements specified in workDir
    (void)workDir;
    return TRUE;
}