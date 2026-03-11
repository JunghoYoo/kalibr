# Camera Model Overview

| Model Group           | Components                       | Characteristics                                                                                                                             |
| --------------------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **Pinhole-Radtan**    | Pinhole + Radial-Tangential      | The standard model for *normal (non-wide-angle)* lenses. It corrects barrel/pincushion distortion using radial and tangential coefficients. |
| **Pinhole-Equi**      | Pinhole + Equidistant            | Designed for **fisheye lenses** using the Kannala-Brandt model to map ray angle to image radius.                                            |
| **Pinhole-FOV**       | Pinhole + Field-of-View          | A compact distortion model for wide-angle lenses where distortion is approximately proportional to the angle from the optical axis.         |
| **Omni (Scaramuzza)** | Unified Projection               | Generic model for omnidirectional cameras (catadioptric or ultra-wide fisheye) using a polynomial projection.                               |
| **EUCM / DS**         | Extended Unified / Double Sphere | Modern models for wide-angle sensors providing high accuracy with fewer parameters than polynomial omni models.                             |

---

# 1. Pinhole + Radial-Tangential (Radtan)

![Image](https://www.researchgate.net/publication/252588580/figure/fig1/AS%3A298186775252999%401448104675861/Pinhole-camera-model-with-radial-distortion.png)

![Image](https://www.researchgate.net/publication/363182033/figure/fig2/AS%3A11431281085580758%401663788657970/Radial-and-tangential-distortion-of-the-camera.jpg)

![Image](https://www.researchgate.net/publication/260728375/figure/fig1/AS%3A613986148036622%401523397113973/Radial-and-tangential-distortion.png)

### Concept

A standard **pinhole projection** with polynomial lens distortion correction.

The ideal pinhole projection maps a 3D point to the image plane as:

[
x = \frac{X}{Z}, \quad y = \frac{Y}{Z}
]

[
u = f_x x + c_x,\quad v = f_y y + c_y
]

Radial-tangential distortion is applied:

[
x_d = x(1 + k_1 r^2 + k_2 r^4 + k_3 r^6) + 2p_1xy + p_2(r^2 + 2x^2)
]

[
y_d = y(1 + k_1 r^2 + k_2 r^4 + k_3 r^6) + p_1(r^2 + 2y^2) + 2p_2xy
]

where

[
r^2 = x^2 + y^2
]

This model is widely used in **OpenCV calibration pipelines**. ([pantelis.github.io][1])

---

# 2. Pinhole + Equidistant (Kannala-Brandt)

![Image](https://www.researchgate.net/publication/299374422/figure/fig2/AS%3A1086766102642689%401636116638410/Equidistant-fisheye-projection-function-representation.jpg)

![Image](https://www.mdpi.com/remotesensing/remotesensing-14-04175/article_deploy/html/images/remotesensing-14-04175-g003.png)

### Concept

Used for **fisheye cameras** where projection depends on the **ray angle** rather than perspective distance.

Equidistant projection:

[
r = f\theta
]

Kannala-Brandt polynomial:

[
r = f(\theta + k_1\theta^3 + k_2\theta^5 + k_3\theta^7 + k_4\theta^9)
]

Mapping to image coordinates:

[
u = r\frac{x}{\sqrt{x^2+y^2}} + c_x
]

[
v = r\frac{y}{\sqrt{x^2+y^2}} + c_y
]

Commonly used for **fisheye SLAM systems** (e.g., ORB-SLAM fisheye).

---

# 3. Pinhole + Field-of-View (FOV)

### Concept

A compact **single-parameter distortion model** used for wide-angle lenses.

FOV distortion:

[
r_d = \frac{1}{\omega}\tan^{-1}(2r\tan(\omega/2))
]

where

* (r) = normalized radius
* (\omega) = field-of-view parameter

Advantages:

* Very **few parameters**
* Fast **inverse projection**
* Often used in **visual SLAM** and **real-time tracking**

---

# 4. Omni Model (Scaramuzza)

### Concept

A **polynomial projection model** for omnidirectional cameras.

Projection uses a polynomial mapping:

[
\rho = a_0 + a_1 z + a_2 z^2 + a_3 z^3 + \dots
]

where

* (z) = normalized ray direction
* (\rho) = image radius

Key idea:

Instead of modeling distortion explicitly, the projection itself is **approximated with a polynomial**.

Typical use cases:

* Catadioptric cameras
* 360° mirror-based sensors
* Omnidirectional robot vision

---

# 5. EUCM / Double Sphere (DS)

### Concept

Modern **analytical models** designed for wide-angle cameras with better numerical stability.

Double-Sphere projection:

[
d_1 = \sqrt{x^2 + y^2 + z^2}
]

[
d_2 = \sqrt{x^2 + y^2 + (\xi d_1 + z)^2}
]

[
u = f_x \frac{x}{\alpha d_2 + (1-\alpha)(\xi d_1 + z)} + c_x
]

[
v = f_y \frac{y}{\alpha d_2 + (1-\alpha)(\xi d_1 + z)} + c_y
]

Advantages:

* Accurate for **wide FOV (>160°)**
* No high-order polynomials
* Good numerical stability for **SLAM**

Often used in:

* **VINS-Fusion**
* **Basalt VIO**
* **Kalibr calibration**

---

✅ **Quick Practical Summary**

| Lens Type              | Best Model           |
| ---------------------- | -------------------- |
| Standard camera        | Pinhole-Radtan       |
| Fisheye (~180°)        | Pinhole-Equi         |
| Moderate wide-angle    | Pinhole-FOV          |
| Omnidirectional mirror | Omni (Scaramuzza)    |
| Modern SLAM wide-angle | EUCM / Double Sphere |

---

✅ If you want, I can also produce a **single comparison diagram of all 5 camera projection geometries (very useful for papers or slides)**.

[1]: https://pantelis.github.io/aiml-common/lectures/sensor-models/cameras/pinhole-model.html?utm_source=chatgpt.com "Pinhole Camera Model – Engineering AI Agents"
