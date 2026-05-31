# Codex Notice

Codex Notice 是一个 macOS 本地通知器：当 Codex 完成一次任务时，自动播放提示音，并可弹出系统通知。

它的目标是全局生效：当前 chat、新开的 chat、不同项目里的 Codex chat 都不需要单独提醒。你正常使用 Codex 即可，任务完成时电脑会响。

## 工作原理

Codex 会把会话事件写入 `~/.codex/sessions/**/*.jsonl`。

`codex-watcher` 后台监听这些文件，当发现新的完成事件时触发通知：

```text
payload.type == "task_complete"
```

然后它会调用 `notify-done`，由 `notify-done` 播放 macOS 系统声音并发送通知。

首次启动时会把已有历史记录设为基线，所以不会把过去已经完成的任务全部补响一遍。

## 日常怎么用

正常打开 Codex，正常发任务，不需要额外操作。

每次 Codex 任务完成后，后台服务会自动：

- 播放提示音
- 弹出一条 macOS 通知
- 记录已通知过的 `turn_id`，避免重复响

## 安装或重新安装

在这个项目目录下运行：

```sh
./install.sh
```

如果提示 `permission denied`，先修复脚本执行权限：

```sh
zsh ./fix-permissions.sh
./install.sh
```

安装脚本会复制这些文件：

- `bin/notify-done` -> `~/.local/bin/notify-done`
- `bin/codex-watcher` -> `~/.local/bin/codex-watcher`
- `launchagents/com.qy.codex-notifier.plist` -> `~/Library/LaunchAgents/com.qy.codex-notifier.plist`

然后启动 macOS LaunchAgent：

```text
com.qy.codex-notifier
```

以后它会在你登录 macOS 后自动运行。

## 确认是否正在运行

查看后台服务状态：

```sh
launchctl print gui/$(id -u)/com.qy.codex-notifier | head -80
```

看到 `state = running` 就说明正在运行。

也可以查看进程：

```sh
pgrep -fl codex-watcher
```

## 手动测试提示音

只测试声音和通知，不依赖 Codex：

```sh
~/.local/bin/notify-done "Codex task complete"
```

指定声音：

```sh
~/.local/bin/notify-done --sound Ping "Codex task complete"
```

可用的系统声音在这里：

```sh
ls /System/Library/Sounds
```

例如 `Glass`、`Ping`、`Pop`、`Tink`、`Submarine`。

## 测试 watcher 识别能力

只扫描事件，不真正播放声音：

```sh
~/.local/bin/codex-watcher --once --dry-run --no-baseline --state /tmp/codex-notifier-test-state.json
```

如果输出类似下面这样，说明 watcher 能识别 Codex 完成事件：

```text
dry-run: would notify turn_id=... message=Codex task complete (...)
```

## 日志和状态文件

运行日志：

```sh
tail -50 ~/.local/state/codex-notifier/watcher.out.log
tail -50 ~/.local/state/codex-notifier/watcher.err.log
```

状态文件：

```text
~/.local/state/codex-notifier/state.json
```

这个文件记录已经扫描到哪里、哪些 `turn_id` 已经提醒过。

## 重启后台服务

```sh
launchctl kickstart -k gui/$(id -u)/com.qy.codex-notifier
```

## 停止后台服务

```sh
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.qy.codex-notifier.plist
```

## 卸载

在这个项目目录下运行：

```sh
./uninstall.sh
```

它会停止并删除 LaunchAgent。`~/.local/bin/notify-done`、`~/.local/bin/codex-watcher` 和状态日志文件会保留，方便之后重新安装或排查。

## 常见问题

如果没有声音，先运行：

```sh
~/.local/bin/notify-done "test"
```

如果这条命令也没有声音，检查 macOS 音量、静音模式、勿扰模式，以及系统通知权限。

如果手动测试有声音，但 Codex 完成后没响，检查 watcher 是否运行：

```sh
launchctl print gui/$(id -u)/com.qy.codex-notifier | head -80
```

再看错误日志：

```sh
tail -50 ~/.local/state/codex-notifier/watcher.err.log
```
# Codex-watcher-for-MacOS
