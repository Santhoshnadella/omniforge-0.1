#include "injector_host.h"
#include <iostream>
#include <windows.h>


bool InjectorHost::inject(const std::string &exePath,
                          const std::string &dllPath) {
  STARTUPINFOA si = {sizeof(si)};
  PROCESS_INFORMATION pi = {0};

  // Create process suspended
  if (!CreateProcessA(exePath.c_str(), nullptr, nullptr, nullptr, FALSE,
                      CREATE_SUSPENDED, nullptr, nullptr, &si, &pi)) {
    std::cerr << "Failed to create process: " << exePath << std::endl;
    return false;
  }

  // Allocate memory for DLL path in target process
  void *pDllPath = VirtualAllocEx(pi.hProcess, nullptr, dllPath.length() + 1,
                                  MEM_COMMIT, PAGE_READWRITE);
  if (!pDllPath) {
    std::cerr << "Failed to allocate memory in target process." << std::endl;
    TerminateProcess(pi.hProcess, 1);
    return false;
  }

  // Write DLL path
  if (!WriteProcessMemory(pi.hProcess, pDllPath, dllPath.c_str(),
                          dllPath.length() + 1, nullptr)) {
    std::cerr << "Failed to write to target process memory." << std::endl;
    TerminateProcess(pi.hProcess, 1);
    return false;
  }

  // Create remote thread to load DLL
  HANDLE hThread =
      CreateRemoteThread(pi.hProcess, nullptr, 0,
                         (LPTHREAD_START_ROUTINE)GetProcAddress(
                             GetModuleHandleA("kernel32.dll"), "LoadLibraryA"),
                         pDllPath, 0, nullptr);
  if (!hThread) {
    std::cerr << "Failed to create remote thread." << std::endl;
    TerminateProcess(pi.hProcess, 1);
    return false;
  }

  // Wait for thread to finish
  WaitForSingleObject(hThread, INFINITE);
  CloseHandle(hThread);

  // Resume main thread
  ResumeThread(pi.hThread);

  CloseHandle(pi.hProcess);
  CloseHandle(pi.hThread);

  return true;
}
