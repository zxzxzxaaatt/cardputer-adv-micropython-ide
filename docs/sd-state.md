# SD 卡状态与日志

所有文件都在一个带指纹的子目录里，**不占根目录**：

```
/sd/M5ADV_IDE_9F3C7A2B/
├── logs/
│   └── ide_YYYYMMDD.log
├── state.txt
└── imefreq.txt
```

目录名里的 `9F3C7A2B` 是固定指纹，用来和别的固件（LX Shell 等）的日志目录区分开。

## state.txt（key=value）

| key | 含义 | 取值范围 |
|---|---|---|
| `file` | 上一次打开的文件 | 绝对路径 |
| `theme` | 主题序号 | 0..7（蓝/白/绿/橙/青/紫/黄/红） |
| `bright` | 亮度档位 | 0..len(`dev._bld`)-1 |
| `side` | 侧栏 | 1=全分隔，0=禅模式 |
| `layout` | 布局名 | `full` / `zen` |
| `term` | 终端模式 | 0 关 / 1 半屏 / 2 全屏 |
| `err` | 问题面板 | 1 展开 / 0 收起 |
| `pos` | 光标位置 | `行,列` |

读写时机：打开 / 保存 / 切主题 / 调亮度 / 切侧栏 / 切终端 / 切面板 / Ctrl+Q 退出。

## ide_YYYYMMDD.log

一行一次事件：

```
2026-11-26 16:32:05 boot theme=2 bright=4
2026-11-26 16:33:11 restore /sd/demo.py
2026-11-26 16:35:02 open /sd/demo.py
2026-11-26 16:40:19 save /sd/demo.py
```

事件类型：`boot`、`restore`、`open`、`save`、`theme`、`bright`、`layout`、`term`。

## imefreq.txt

两列：`码位 次数`，例如：

```
26013 5
26012 1
```

同一字上屏满 3 次，候选就排到这个音节最前；每 4 次上屏落盘一次。删掉这个文件即可清空学习记录。
