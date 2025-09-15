# Security & Privacy Settings
[![Translation status](https://l10n.elementaryos.org/widget/settings/security-privacy/svg-badge.svg)](https://l10n.elementaryos.org/engage/settings/)

![screenshot](data/screenshot-history.png?raw=true)

## Building, Testing, and Installation

You'll need the following dependencies:
* libgranite-7-dev
* libgtk-4-dev >= 4.10
* libpolkit-gobject-1-dev
* libswitchboard-3-dev
* libzeitgeist-2.0-dev
* meson >= 0.46.1
* policykit-1
* valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    ninja install
