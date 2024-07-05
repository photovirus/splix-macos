# A fork which works on modern macOS

This fork is basically @janrueth's [patch](https://github.com/janrueth/splix-2.0.0-macos) applied to latest Splix release.

Tested on: M1 Macbook Pro, macOS Sonoma 14.5, and a Samsung ML-2010.

## Installation

Install Xcode command line tools
```
xcode-select --install
```

In case your printer needs jbig:
```
brew install jbigkit
```

Then:
```
make
sudo make install
```

To compile without jbig:
```
make DISABLE_JBIG=1
sudo make install
```

# Driver for SPL2 and SPLc laser printers from Samsung, Xerox, Dell, Lexmark, and Toshiba

Support for printing to SPL2- and SPLc-based printers. These are most of the cheaper laser printers from Samsung, but also rebranded ones from Xerox, Dell, Lexmark, and Toshiba. This driver is especially for those models not understanding standard languages like PostScript or PCL.

Both monochrome (ML-15xx, ML-16xx, ML-17xx, ML-2xxx) and color (CLP-5xx, CLP-6xx) models are supported, and also their rebranded equivalents like the Xerox Phaser 6100 work with this driver.

Note that older SPL1-based models (ML-12xx, ML-14xx) do not work. Use these printers with the older "gdi" driver which is built into GhostScript.

See installation instructions in the INSTALL file.

The driver was created by Aurélien Croc (aurelien at ap2c dot org) and contains many contributions from Till Kamppeter (till dot kamppeter at gmail dot com). Development is discontinued as most modern printers do not need drivers any more.
