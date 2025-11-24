#pragma once

#ifdef OMNIFORGE_HAVE_QT
#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow {
    Q_OBJECT
public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow() override;

public slots:
    void onInjectClicked();

signals:
    void injectionRequested(const QString &exePath, const QString &dllPath);

private:
    Ui::MainWindow *ui;
};
#endif
