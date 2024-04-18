
#include <chrono>
#include <iostream>
class Stopwatch
{
private:
    std::chrono::high_resolution_clock::time_point t1, t2;

public:
    explicit Stopwatch(bool run = true)
    {
        if (run)
        {
            Start();
        }
    }
    ~Stopwatch()
    {
        Finish();
    }

    void Start() { t2 = t1 = std::chrono::high_resolution_clock::now(); }

    int Finish()
    {
        t2 = std::chrono::high_resolution_clock::now();
        int ms = std::chrono::duration_cast<std::chrono::microseconds>(t2 - t1).count() / 1000.0;
        return ms;
    }

    // double ms() const { return std::chrono::duration_cast<std::chrono::microseconds>(t2 - t1).count() / 1000.0; }
};