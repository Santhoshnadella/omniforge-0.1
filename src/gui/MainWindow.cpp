#ifdef OMNIFORGE_HAVE_QT
#include "MainWindow.h"
#include "../injector/injector_host.h"
#include "ui_MainWindow.h"
#include <QFileDialog>
#include <QMessageBox>


MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent), ui(new Ui::MainWindow) {
  ui->setupUi(this);
  // Create Batch and Real-Time tabs are already in the UI file
  // Wire up inject button placeholder if present
  if (ui->tabWidget) {
    // Assume real-time tab has a QPushButton named injectButton and a QLineEdit
    // exeLineEdit
    auto injectBtn =
        ui->centralWidget->findChild<QPushButton *>("injectButton");
    if (injectBtn)
      connect(injectBtn, &QPushButton::clicked, this,
              &MainWindow::onInjectClicked);
  }
}

MainWindow::~MainWindow() { delete ui; }

void MainWindow::onInjectClicked() {
  // Example slot: open file dialog to select executable
  QString exePath =
      QFileDialog::getOpenFileName(this, tr("Select Game Executable"));
  if (exePath.isEmpty())
    return;

  // In a real scenario, we might want to find where the DLL is relative to the
  // app. For now, we assume it's in the same directory.
  QString dllPath = "omniforge_inject.dll";

  // emit injectionRequested(exePath, dllPath); // Optional: keep if other
  // components need to know

  if (InjectorHost::inject(exePath.toStdString(), dllPath.toStdString())) {
    QMessageBox::information(this, tr("Inject"), tr("Injection successful!"));
  } else {
    QMessageBox::critical(this, tr("Inject"), tr("Injection failed."));
  }
}
#endif
