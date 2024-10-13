# Linx (Link for Linux)

Linx is a simple and opinionated tool designed to synchronize your configurations on Linux systems, specifically for
Debian-based distributions. 
Its purpose is to create a link between Linux devices, allowing them to share and sync their configurations seamlessly.

## Features

Version 1.0.0 of Linx offers the following features:

- A comprehensive set of functions and aliases that reduce the time and effort required to navigate through directories, manage files, and execute common tasks
- Shortcuts for frequently accessed directories such as home, desktop, and programming, allowing users to jump to desired locations with minimal keystrokes
- A set of functions that make version control tasks more intuitive and faster, as well as improved log viewing capabilities
- For those who use Terminator as their terminal emulator, Linx provides preconfigured shortcuts, layouts, and multiple themes. List and switch Terminator themes at runtime directly from the command line without needing to install Python or additional plugins 

## Examples

- **(Navigation) Navigate to the home directory and pretty print its content**

Without Linx
```
cd ~
pwd
ls -AF --color --group-directories-first
```

With Linx
```
~
```

- **(git) Push all changes from staging to the remote**

Without Linx
```
git add .
git commit -m "feat: msg..."
git push
```

With Linx
```
gap "feat: msg..."
```

- **(git) Pretty print the releases history**

Without Linx
```
git log --no-walk --tags --pretty=format:"%h %ad %d% %an% %s" --date=format:"%Y-%m-%d %H:%M" --abbrev-commit
```

With Linx
```
glor
```

- **(Terminator) List themes and profiles**
```
profiles
```

- **(Terminator) Apply and persist the `material` theme to Terminator**
```
profiles material
```

- **(Linx) Synchronize your setup on this device**
```
synx
```

- **(System) There are many other features. But more importantly, you can now be polite with your terminal when shutting down your PC**
```
byebye
```

![Live Demo](./demo.gif)

## Installation instructions

#### 1. Clone this repository
```
git clone https://github.com/Julien-Fischer/bash_aliases
```

#### 2. Run the installation wizard
```
linx/install.sh
```

#### 3. Restart your terminal


## Upgrades

If you already installed this project and wish to upgrade, simply type: 
```
synx 
```

This function will: 
- clone this repository 
- backup your configuration
- install the latest version of Linx
- install third-party configuration files for Terminator
- remove the cloned directory
- reload `.bashrc`

Note that you may need to restart your terminal for all changes to be applied.

## Dependencies

#### Required
- Bash
- Git (for executing upgrade and synchronization commands)

#### Optional
- Terminator (and config files)
- Neofetch
- mkf (Make File)

## Requirements

This software was primarily tested on Kubuntu 24 and Debian 12.

Most of the functions and aliases defined in this project are designed to be compatible with Debian-based distributions.
However, some features may require additional work to achieve full compatibility with Debian.

Feel free to open an issue or a pull request if you need further adjustments.

## Acknowledgments

We would like to extend our gratitude to Eliver Lara and their contributors for their outstanding work 
on Terminator themes. 
Many of the third-party themes supported by Linx are credited to
[Eliver Lara's Terminator Themes](https://github.com/EliverLara/terminator-themes)

## Contributing

As Linx is a new project, we're still in the process of developing our contribution guidelines. 
We expect these to evolve over time as the scope and codebase of Linx grows. 

In the meantime, we welcome all contributions and feedback! 
Whether you're interested in submitting code, reporting bugs, or suggesting new features, your input helps us
improve Linx.

## License

Linx entire source code is released under the 
[MIT License](https://opensource.org/licenses/MIT).

During installation, Linx may download third-party Terminator themes. These themes are open-source and licensed under 
[GPL 3](https://www.gnu.org/licenses/gpl-3.0.fr.html#license-text)