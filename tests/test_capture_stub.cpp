#include <iostream>

extern "C" bool initializeCapture();

int main() {
    bool ok = initializeCapture();
    std::cout << "initializeCapture returned: " << ok << std::endl;
    return ok ? 0 : 1;
}
