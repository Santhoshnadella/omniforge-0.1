// metrics.cpp - simple FPS/latency counters (stub)
#include <chrono>
#include <mutex>
#include "metrics.h"

using namespace std::chrono;

struct Metrics::Impl {
    std::mutex m;
    steady_clock::time_point last = steady_clock::now();
    int frames = 0;
    double fps = 0.0;
};

Metrics::Metrics() : p(new Impl) {}
Metrics::~Metrics() = default;

void Metrics::framePresented() {
    std::lock_guard<std::mutex> lk(p->m);
    ++p->frames;
    auto now = steady_clock::now();
    double dt = duration_cast<duration<double>>(now - p->last).count();
    if (dt >= 1.0) {
        p->fps = p->frames / dt;
        p->frames = 0;
        p->last = now;
    }
}

double Metrics::getFPS() const {
    std::lock_guard<std::mutex> lk(p->m);
    return p->fps;
}
