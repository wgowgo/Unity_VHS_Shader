# Unity VHS Shader

A Unity URP post-processing shader that recreates the look of old VHS tapes and CRT displays.

This shader adds analog video noise, screen distortion, scanlines, chromatic bleeding, glitches, and retro color degradation.
It is designed for horror games, retro-style projects, archive interfaces, analog monitor effects, and stylized screen transitions.

---

## Features

* VHS noise effect
* CRT-style screen distortion
* Scanline rendering
* Chromatic aberration
* Color bleeding
* Tracking glitch effect
* Pixelated screen look
* Retro color degradation
* URP post-processing workflow
* Adjustable shader parameters

---

## Preview

Add preview images or GIFs here.

```md
![Preview](.VHS-SHADER.gif)
```

---

## Requirements

* Unity 2021.3 or newer recommended
* Universal Render Pipeline
* Shader Graph or custom HLSL shader support depending on your project setup

---

## Installation

1. Download or clone this repository.

```bash
git clone https://github.com/wgowgo/Unity_VHS_Shader.git
```

2. Copy the shader files into your Unity project.

```text
Assets/Unity_VHS_Shader/
```

3. Make sure your project is using URP.

4. Add the VHS shader material or renderer feature to your post-processing setup.

---

## Basic Usage

1. Create a material using the VHS shader.
2. Assign the material to your fullscreen render pass, post-process system, or screen effect object.
3. Adjust the shader parameters in the Inspector.
4. Tune the effect strength depending on your game style.

---

## Main Parameters

| Parameter            | Description                                       |
| -------------------- | ------------------------------------------------- |
| Noise Strength       | Controls the intensity of VHS noise               |
| Distortion           | Controls screen warping and analog distortion     |
| Scanline Strength    | Controls CRT scanline visibility                  |
| Chromatic Aberration | Controls RGB color separation                     |
| Glitch Strength      | Controls tracking and horizontal glitch intensity |
| Pixel Size           | Controls pixelated screen resolution              |
| Color Degradation    | Controls faded retro color look                   |

---

## Recommended Use Cases

* Horror game camera effects
* Retro game screen filters
* CCTV monitor effects
* Archive UI screens
* VHS tape playback scenes
* Old television effects
* Analog glitch transitions

---

## Folder Structure

```text
Unity_VHS_Shader/
├── Assets/
│   └── Unity_VHS_Shader/
│       ├── Shaders/
│       ├── Materials/
│       ├── Scripts/
│       └── Examples/
├── Preview/
└── README.md
```

---

## Notes

This shader is intended as a stylized visual effect.
For best results, combine it with bloom, film grain, low-resolution rendering, or color grading.

Effect values should be adjusted carefully.
Strong VHS distortion can reduce readability, especially for UI text.

---

## License

This project is licensed under the MIT License.

You can use, modify, and distribute it freely in personal or commercial projects.

---

## Author

Created by **wgowgo**.
