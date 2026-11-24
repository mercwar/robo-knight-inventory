#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <stdio.h>
#include <string.h>

typedef struct {
    wchar_t sourceZipPath[MAX_PATH];
    wchar_t targetTempDir[MAX_PATH];
} ZIP_DECOMP_CONTEXT;

typedef void(WINAPI* pfnZipInit)(ZIP_DECOMP_CONTEXT*, const wchar_t*);
typedef BOOL(WINAPI* pfnZipExtract)(ZIP_DECOMP_CONTEXT*);
typedef void(WINAPI* pfnZipCleanup)(ZIP_DECOMP_CONTEXT*);
typedef BOOL(WINAPI* pfnInstallCabPackage)(const wchar_t*, const wchar_t*);

// Comprehensive command line help documentation printout
void PrintUsage(const wchar_t* appName) {
    wprintf(L"============================================================\n");
    wprintf(L"                    MWAI TOOL USAGE GUIDE                   \n");
    wprintf(L"============================================================\n");
    wprintf(L"Syntax side-by-side layouts:\n\n");
    wprintf(L"1. Full Pipeline Execution Mode (-zip):\n");
    wprintf(L"    Unpacks a ZIP archive, discovers internal CABs, checks catalog\n");
    wprintf(L"    digital signatures, copies files, and imports registry profiles.\n");
    wprintf(L"    Format:  %s -zip <PathToArchive.zip>\n\n", appName);
    wprintf(L"2. Standalone Cabinet Extraction Mode (-cab):\n");
    wprintf(L"    Bypasses the ZIP phase to extract a standalone .cab package file\n");
    wprintf(L"    directly into a specified local file destination path folder.\n");
    wprintf(L"    Format:  %s -cab <PathToPackage.cab> <TargetOutputDir>\n\n", appName);
    wprintf(L"3. Loose Folder Deployment Mode (-folder):\n");
    wprintf(L"    Bypasses all archive extraction phases entirely to process raw\n");
    wprintf(L"    manifest .ini directives and .reg keys already sitting in a folder.\n");
    wprintf(L"    Format:  %s -folder <PathToExtractedFolder>\n", appName);
    wprintf(L"============================================================\n");
}

BOOL ProcessAllCabsInFolder(pfnInstallCabPackage fInstallCab, const wchar_t* folderPath) {
    wchar_t cabSearchPattern[MAX_PATH];
    swprintf_s(cabSearchPattern, MAX_PATH, L"%s\\*.cab", folderPath);

    WIN32_FIND_DATAW ffd;
    HANDLE hFind = FindFirstFileW(cabSearchPattern, &ffd);
    BOOL success = FALSE;

    if (hFind != INVALID_HANDLE_VALUE) {
        do {
            wchar_t fullCabPath[MAX_PATH];
            swprintf_s(fullCabPath, MAX_PATH, L"%s\\%s", folderPath, ffd.cFileName);
            wprintf(L"[*] Found internal cabinet package: %s\n", ffd.cFileName);
            wprintf(L"[*] Handing file off to mwreg.dll installation pass...\n");

            success = fInstallCab(fullCabPath, folderPath);
            if (!success) {
                printf("[ERROR] Pipeline terminated unexpectedly during cabinet processing.\n");
                break;
            }
        } while (FindNextFileW(hFind, &ffd) != 0);
        FindClose(hFind);
    } else {
        printf("[WARNING] No internal cabinet payloads were located inside the specified directory.\n");
        success = TRUE; 
    }
    return success;
}

// Helper function to safely load DLLs from the application's secure directory
HMODULE LoadSecureDll(const wchar_t* dllName) {
    wchar_t appDir[MAX_PATH];
    DWORD len = GetModuleFileNameW(NULL, appDir, MAX_PATH);
    if (len == 0 || len >= MAX_PATH) {
        return NULL;
    }

    wchar_t* lastSlash = wcsrchr(appDir, L'\\');
    if (!lastSlash) {
        return NULL;
    }
    *(lastSlash + 1) = L'\0';

    wchar_t dllPath[MAX_PATH];
    swprintf_s(dllPath, MAX_PATH, L"%s%s", appDir, dllName);

    return LoadLibraryW(dllPath);
}

int wmain(int argc, wchar_t* argv[]) {
    printf("============================================================\n");
    printf("      MWAI: MULTI-SWITCH WIN64 COMMAND LINE DISPATCHER        \n");
    printf("============================================================\n");
    printf("\n");

    if (argc < 3) {
        PrintUsage(argv[0]);
        return 1;
    }

    wchar_t* switchArg = argv[1];
    wchar_t* targetPath = argv[2];

    HMODULE hZipDll = LoadSecureDll(L"unzipcab.dll");
    HMODULE hCabDll = LoadSecureDll(L"mwreg.dll");
    
    if (!hCabDll) {
        printf("[ERROR] Failed to load layout engine dependency: mwreg.dll\n");
        if (hZipDll) FreeLibrary(hZipDll);
        return 1;
    }

    pfnInstallCabPackage fInstallCab = (pfnInstallCabPackage)GetProcAddress(hCabDll, "InstallCabPackage");
    if (!fInstallCab) {
        printf("[ERROR] Function exports missing inside mwreg.dll\n");
        FreeLibrary(hCabDll);
        if (hZipDll) FreeLibrary(hZipDll);
        return 1;
    }

    BOOL executionSuccess = FALSE;

    if (_wcsicmp(switchArg, L"-zip") == 0) {
        if (!hZipDll) {
            printf("[ERROR] Extraction mode requested but unzipcab.dll failed to load.\n");
            FreeLibrary(hCabDll);
            return 1;
        }

        pfnZipInit fZipInit = (pfnZipInit)GetProcAddress(hZipDll, "Zip_Init");
        pfnZipExtract fZipExtract = (pfnZipExtract)GetProcAddress(hZipDll, "Zip_Extract");
        pfnZipCleanup fZipCleanup = (pfnZipCleanup)GetProcAddress(hZipDll, "Zip_Cleanup");

        if (!fZipInit || !fZipExtract || !fZipCleanup) {
            printf("[ERROR] Function exports missing inside unzipcab.dll\n");
            FreeLibrary(hCabDll);
            FreeLibrary(hZipDll);
            return 1;
        }

        ZIP_DECOMP_CONTEXT zipCtx;
        fZipInit(&zipCtx, targetPath);

        printf("[*] Running archive decompression routines...\n");
        if (fZipExtract(&zipCtx)) {
            wprintf(L"[SUCCESS] Files unpacked safely to temp space: %s\n\n", zipCtx.targetTempDir);
            executionSuccess = ProcessAllCabsInFolder(fInstallCab, zipCtx.targetTempDir);
            
            printf("\n[*] Cleaning environment workspace states...\n");
            fZipCleanup(&zipCtx);
        } else {
            printf("[ERROR] File extraction process aborted.\n");
        }
    }
    else if (_wcsicmp(switchArg, L"-cab") == 0) {
        if (argc < 4) {
            wprintf(L"[ERROR] Cabinet mode requires an explicit destination path argument.\n\n");
            PrintUsage(argv[0]);
            FreeLibrary(hCabDll);
            if (hZipDll) FreeLibrary(hZipDll);
            return 1;
        }
        wchar_t* destinationFolder = argv[3];
        wprintf(L"[*] Directly executing single cabinet installation pass: %s\n", targetPath);
        
        executionSuccess = fInstallCab(targetPath, destinationFolder);
    }
    else if (_wcsicmp(switchArg, L"-folder") == 0) {
        wprintf(L"[*] Processing standalone installation folder path: %s\n", targetPath);
        wprintf(L"[*] Skipping archive decompression loops entirely...\n");
        
        executionSuccess = ProcessAllCabsInFolder(fInstallCab, targetPath);
    }
    else {
        wprintf(L"[ERROR] Unrecognized command switch parameter: %s\n\n", switchArg);
        PrintUsage(argv[0]);
    }

    FreeLibrary(hCabDll);
    if (hZipDll) FreeLibrary(hZipDll);

    printf("------------------------------------------------------------\n");
    if (executionSuccess) {
        printf("[SUCCESS] mwai operations completed successfully for requested mode.\n");
        return 0;
    } else {
        printf("[FAILURE] Operational switch pipeline ended with execution flags aborted.\n");
        return 1;
    }
}