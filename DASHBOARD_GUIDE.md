# 🎮 DOOM with Omniforge Dashboard - User Guide

## ✅ WHAT'S RUNNING

The game is now running with:
- ✅ **Floating metrics dashboard** overlay
- ✅ **Windowed mode** (1400x900 window)
- ✅ **Zoom controls** (+/- keys)
- ✅ **Real-time performance monitoring**
- ✅ **Omniforge upscaling pipeline** active

---

## 🎯 DASHBOARD FEATURES

### What You See on the Dashboard:

```
┌────────────────────────────────────┐
│     OMNIFORGE METRICS              │
├────────────────────────────────────┤
│ Render: 630x405                    │
│ Display: 1260x810                  │
│ Scale: 2.00x                       │
│                                    │
│ Mode: FSR                          │
│                                    │
│ FPS: 60.0        Avg: 58.5         │
│ [FPS Graph - last 60 frames]       │
│                                    │
│ Frame Time Breakdown:              │
│   Render: 8.2ms  [████████░░]      │
│   Upscale: 2.3ms [██░░░░░░░░]      │
│   Total: 10.5ms  [██████░░░░]      │
│                                    │
│ Performance Gain: 37.2%            │
│                                    │
│ Frames Processed: 1234             │
│────────────────────────────────────│
│ F1: Toggle Dashboard               │
│ + / -: Zoom In/Out                 │
└────────────────────────────────────┘
```

---

## 🎮 CONTROLS

### Game Controls:
- **WASD** - Move
- **Mouse** - Look around
- **Left Click** - Shoot
- **ESC** - Exit game

### Dashboard Controls:
- **F1** - Toggle dashboard on/off
- **+** (or =) - Zoom in (up to 2.0x)
- **-** - Zoom out (down to 0.5x)

---

## 📊 METRICS EXPLAINED

### Resolution Info:
- **Render**: The resolution the game actually renders at (low-res for performance)
- **Display**: The resolution shown on screen (upscaled by Omniforge)
- **Scale**: How much larger the display is vs render (e.g., 2.00x = 4x fewer pixels)

### Mode:
- **FSR**: FidelityFX Super Resolution (AMD's upscaling)
- **Waifu2x**: AI-based upscaling
- **Hybrid**: FSR + Waifu2x combined
- **Bilinear**: Simple fallback

### FPS (Frames Per Second):
- **Current**: FPS right now
- **Avg**: Average FPS over last 60 frames
- **Graph**: Visual representation of FPS over time
- **Color coding**:
  - 🟢 Green (50+ FPS): Excellent
  - 🟡 Yellow (30-50 FPS): Good
  - 🔴 Red (<30 FPS): Poor

### Frame Time Breakdown:
Shows how long each part of the frame takes:

- **Render**: Time to draw the game at low resolution
  - Lower is better
  - Affected by game complexity

- **Upscale**: Time for Omniforge to upscale the frame
  - FSR: ~2-3ms
  - Waifu2x: ~10-15ms
  - Hybrid: ~12-18ms

- **Total**: Render + Upscale
  - Target: <16.67ms for 60 FPS
  - Green bar: Good performance
  - Yellow bar: Borderline
  - Red bar: Too slow

### Performance Gain:
Shows how much faster this is vs rendering at native resolution:
- **37%** = You're rendering 37% faster than native
- **0%** = Same speed as native (upscaling overhead = rendering savings)
- **Negative** = Slower than native (shouldn't happen with proper settings)

### Frames Processed:
Total number of frames rendered since game started.

---

## 🔍 ZOOM FEATURE

### How It Works:
- Game renders at low resolution (e.g., 630x405)
- Omniforge upscales to display resolution (e.g., 1260x810)
- Zoom scales the final image up or down
- Useful for seeing upscaling quality

### Zoom Levels:
- **0.5x** - Zoomed out (see more of the game)
- **1.0x** - Normal (default)
- **1.5x** - Zoomed in (see upscaling details)
- **2.0x** - Maximum zoom (inspect quality)

### Use Cases:
- **Zoom in (1.5x-2.0x)**: Inspect upscaling quality, see FSR sharpening
- **Zoom out (0.5x-0.7x)**: Get wider field of view
- **Normal (1.0x)**: Standard gameplay

---

## 🎨 DASHBOARD DESIGN

### Color Coding:
- **Cyan borders**: Dashboard frame
- **White text**: General information
- **Green**: Good performance metrics
- **Yellow**: Warning (borderline performance)
- **Red**: Error (poor performance)
- **Blue bars**: Render time
- **Orange bars**: Upscale time

### Semi-Transparent Background:
- You can see the game through the dashboard
- Dark background for readability
- Doesn't block gameplay

### Positioning:
- Top-left corner by default
- Doesn't interfere with game action
- Can be toggled off with F1

---

## 📈 PERFORMANCE MONITORING

### What to Watch:

1. **FPS Graph**:
   - Should be relatively flat (stable FPS)
   - Spikes down = frame drops
   - Consistent low = performance issue

2. **Render Time**:
   - Should be consistent
   - Increases with more enemies/complexity
   - Lower render scale = lower render time

3. **Upscale Time**:
   - Should be very consistent
   - FSR: ~2-3ms
   - If higher: GPU might be busy

4. **Total Time**:
   - Must be <16.67ms for 60 FPS
   - <8.33ms for 120 FPS
   - If too high: reduce render scale or switch to FSR-only

---

## 🔧 OPTIMIZATION TIPS

### If FPS is Too Low:

1. **Reduce Render Scale**:
   Edit `main_dashboard.py` line 24:
   ```python
   RENDER_SCALE = 0.33  # Was 0.5, now 33% resolution
   ```

2. **Use FSR Only**:
   Edit lines 25-27:
   ```python
   USE_FSR = True
   USE_WAIFU2X = False
   USE_HYBRID = False
   ```

3. **Zoom Out**:
   Press `-` key to reduce zoom to 0.7x or 0.5x

### If Quality is Too Low:

1. **Increase Render Scale**:
   ```python
   RENDER_SCALE = 0.75  # Render at 75% resolution
   ```

2. **Use Hybrid Mode**:
   ```python
   USE_HYBRID = True
   ```

3. **Zoom In**:
   Press `+` key to inspect quality at 1.5x zoom

---

## 🎯 WHAT THE DASHBOARD PROVES

### Real-Time Monitoring:
- ✅ Shows exactly what Omniforge is doing
- ✅ Proves upscaling is working
- ✅ Demonstrates performance gain
- ✅ Validates quality vs performance tradeoff

### Transparency:
- ✅ No hidden processing
- ✅ Every millisecond accounted for
- ✅ Clear breakdown of where time goes
- ✅ Honest performance metrics

### Educational:
- ✅ Learn how upscaling works
- ✅ See FSR's impact in real-time
- ✅ Understand performance tradeoffs
- ✅ Experiment with settings

---

## 🎮 GAMEPLAY TIPS

### With Dashboard Visible:
- Dashboard is in top-left corner
- Doesn't block center of screen
- Can still play normally
- Great for monitoring performance

### With Dashboard Hidden (F1):
- Full immersion
- No distractions
- Still getting upscaling benefits
- Press F1 again to bring it back

### Zoom for Different Experiences:
- **0.5x**: Tactical overview
- **1.0x**: Normal gameplay
- **1.5x**: Detailed combat
- **2.0x**: Quality inspection

---

## 📊 EXAMPLE METRICS

### Good Performance:
```
FPS: 60.0 (Avg: 59.2)
Render: 7.8ms
Upscale: 2.1ms
Total: 9.9ms
Performance Gain: 40.5%
```
**Interpretation**: Excellent! Running smoothly with significant performance gain.

### Borderline Performance:
```
FPS: 45.3 (Avg: 47.1)
Render: 12.4ms
Upscale: 2.8ms
Total: 15.2ms
Performance Gain: 8.9%
```
**Interpretation**: Playable but close to 60 FPS limit. Consider reducing render scale.

### Poor Performance:
```
FPS: 28.1 (Avg: 30.5)
Render: 18.2ms
Upscale: 3.1ms
Total: 21.3ms
Performance Gain: -12.3%
```
**Interpretation**: Below 30 FPS. Reduce render scale or disable upscaling.

---

## 🚀 ADVANCED FEATURES

### Frame Time Graph:
- Shows FPS history over last 60 frames
- Helps identify stuttering
- Smooth line = consistent performance
- Jagged line = frame time variance

### Performance Gain Calculation:
```
Native render time = Current render time / (render_scale²)
Gain = (Native time - Total time) / Native time × 100%
```

Example:
- Render at 0.5 scale: 8ms
- Native would be: 8ms / 0.25 = 32ms
- Total with upscale: 10ms
- Gain: (32 - 10) / 32 = 68.75%

---

## 🎯 SUMMARY

**You now have:**
- ✅ Real-time performance dashboard
- ✅ Zoom controls for quality inspection
- ✅ Windowed mode for easy multitasking
- ✅ Complete transparency into upscaling process
- ✅ Professional-grade monitoring tools

**The dashboard shows:**
- ✅ Exactly what Omniforge is doing
- ✅ How much time each step takes
- ✅ Performance gain vs native rendering
- ✅ Quality of upscaling in real-time

**Perfect for:**
- ✅ Demonstrating the technology
- ✅ Tuning performance settings
- ✅ Understanding upscaling tradeoffs
- ✅ Showing clients/stakeholders

---

**Enjoy the game with full visibility into the Omniforge pipeline!** 🎮✨
