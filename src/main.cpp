#include <iostream>
#ifdef OMNIFORGE_HAVE_QT
#include <QApplication>
#include "gui/MainWindow.h"
#endif

int main(int argc, char** argv) {
#ifdef OMNIFORGE_HAVE_QT
    QApplication app(argc, argv);
    MainWindow w;
    w.show();
    return app.exec();
#else
    std::cout << "Omniforge scaffold - Qt not available. Build with Qt6 to run the GUI." << std::endl;
    return 0;
#endif
}
