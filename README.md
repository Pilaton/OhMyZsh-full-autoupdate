<div align="center">
    <a href="https://github.com/Pilaton/OhMyZsh-full-autoupdate">
        <img src="./doc/images/ohmyzsh-full-update.svg" alt="OhMyZsh Full-autoupdate" width="400">
    </a>
    <h1>🍃 OhMyZsh Full-autoupdate</h1>
    <h4>Automatic update of custom plugins and themes <a href="https://github.com/ohmyzsh/ohmyzsh">Oh My Zsh</a></h4>
</div>

<br>

## What is it

As you probably know, when you update Oh My Zsh, your plugins and themes installed in the `~/.oh-my-zsh/custom` folder are not updated.  

This plugin solves this problem and automatically updates your plugins and themes.

## Installing

1. Clone this repository into `$ZSH_CUSTOM/plugins` (`~/.oh-my-zsh/custom/plugins`)

    ```bash
    git clone https://github.com/Pilaton/OhMyZsh-full-autoupdate.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ohmyzsh-full-autoupdate
    ```

2. Add the plugin to the Oh My Zsh plugin list in the `~/.zshrc` file:

    ```bash
    plugins=(... ohmyzsh-full-autoupdate)
    ```

3. Start a new terminal session.

## Usage 🚀

The plugin **works completely automatically**.  
Runs the next time a new terminal session is opened, after an Oh My Zsh update.  
The update frequency depends on the Oh My Zsh settings, by default every 13 days.  

💡 Note: It can be changed with the parameter `export UPDATE_ZSH_DAYS=13` in `~/.zshrc`.

## Manual start

If you still need to start the update manually, just type `omz update` in the terminal, wait for the Oh My Zsh update to finish and restart the terminal. 😎

## License

MIT © [Pilaton](https://github.com/Pilaton)
