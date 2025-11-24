#pragma once

class Metrics {
public:
    Metrics();
    ~Metrics();
    void framePresented();
    double getFPS() const;
private:
    struct Impl;
    Impl* p;
};
