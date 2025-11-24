#pragma once
#include <queue>
#include <mutex>
#include <condition_variable>

// Simple thread-safe queue for passing frame handles between threads.
template<typename T>
class LatencyQueue {
public:
    void push(T item) {
        {
            std::lock_guard<std::mutex> lk(m_);
            q_.push(std::move(item));
        }
        cv_.notify_one();
    }

    // Blocks until item available
    T pop() {
        std::unique_lock<std::mutex> lk(m_);
        cv_.wait(lk, [this]{ return !q_.empty(); });
        T v = std::move(q_.front());
        q_.pop();
        return v;
    }

    bool try_pop(T &out) {
        std::lock_guard<std::mutex> lk(m_);
        if (q_.empty()) return false;
        out = std::move(q_.front());
        q_.pop();
        return true;
    }

    size_t size() const {
        std::lock_guard<std::mutex> lk(m_);
        return q_.size();
    }

private:
    mutable std::mutex m_;
    std::condition_variable cv_;
    std::queue<T> q_;
};
#pragma once

#include <mutex>
#include <condition_variable>
#include <queue>

template<typename T>
class LatencyQueue {
public:
    void push(T item) {
        std::lock_guard<std::mutex> lk(m_);
        q_.push(std::move(item));
        cv_.notify_one();
    }

    T pop() {
        std::unique_lock<std::mutex> lk(m_);
        cv_.wait(lk, [&]{ return !q_.empty(); });
        T item = std::move(q_.front()); q_.pop();
        return item;
    }

    bool try_pop(T &out) {
        std::lock_guard<std::mutex> lk(m_);
        if (q_.empty()) return false;
        out = std::move(q_.front()); q_.pop();
        return true;
    }

private:
    std::mutex m_;
    std::condition_variable cv_;
    std::queue<T> q_;
};
