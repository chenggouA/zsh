# zsh 插件安装脚本

该仓库包含一个用于安装 zsh 插件的脚本 `install_zsh_plugins.sh`。脚本会读取 `zsh_plugins.txt` 中列出的插件并自动将它们克隆到 Oh My Zsh 的 `custom/plugins` 目录下。

## 使用方法

1. 确保已安装 [Git](https://git-scm.com/) 并能够访问 GitHub。
2. 如已安装 [Oh My Zsh](https://ohmyz.sh/)，脚本会自动使用 `~/.oh-my-zsh` 作为安装路径；也可以通过设置 `ZSH` 环境变量自定义目录：
   ```bash
   ZSH=/path/to/oh-my-zsh ./install_zsh_plugins.sh
   ```
3. 直接运行脚本即可按照 `zsh_plugins.txt` 的列表安装插件：
   ```bash
   ./install_zsh_plugins.sh
   ```
   也可以传入自定义的插件列表文件：
   ```bash
   ./install_zsh_plugins.sh my_plugins.txt
   ```
4. 脚本会跳过内置或无需下载的插件，并在结束时输出需要写入 `~/.zshrc` 的插件名称列表。

## 插件列表

默认的 `zsh_plugins.txt` 列表包括常用的插件，例如：

- `git`
- `z`
- `sudo`
- `extract`
- `command-not-found`
- `zsh-autosuggestions`
- `zsh-completions`
- `fast-syntax-highlighting`
- `you-should-use`

根据需要可编辑该文件以增删插件。

## 注意事项

- 脚本使用 `bash` 并在出错时立即退出（`set -euo pipefail`）。
- 安装插件需要网络连接以从 GitHub 克隆仓库。
- 若脚本提示某插件未知，可在 `install_zsh_plugins.sh` 的 `REPO_MAP` 中添加映射或在列表中使用 `owner/repo` 或完整的 git URL。

