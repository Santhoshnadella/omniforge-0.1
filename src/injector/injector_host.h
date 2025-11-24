#pragma once
#include <string>

class InjectorHost {
public:
  static bool inject(const std::string &exePath, const std::string &dllPath);
};
