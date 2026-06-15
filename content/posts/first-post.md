---
title: "我的第一篇博客"
date: 2026-06-02T14:00:00+08:00
draft: false
tags: ["开始", "Hugo"]
categories: ["随笔"]
description: "这是用 Hugo + Stack 搭建的博客的第一篇文章。"
---

## 你好，世界 👋

欢迎来到我的博客！这是第一篇示例文章，用来验证站点能正常工作。

<!--more-->

## 这个博客是怎么搭的

- **生成器**：[Hugo](https://gohugo.io/)（Go 写的静态站点生成器，构建极快）
- **主题**：[Stack](https://github.com/CaiJimmy/hugo-theme-stack)（卡片式技术博客主题）
- **托管**：GitHub Pages，通过 GitHub Actions 自动部署

## 如何写新文章

在项目目录下运行：

```bash
hugo new posts/我的新文章.md
```

然后编辑生成的 Markdown 文件，把 `draft: true` 改成 `draft: false`（或删掉这一行），最后：

```bash
git add .
git commit -m "新文章"
git push
```

几分钟后，文章就会自动出现在线上。

## Markdown 速览

支持 **加粗**、*斜体*、`行内代码`、列表、引用：

> 这是一段引用。

1. 第一项
2. 第二项

```python
print("Hello, blog!")
```

祝写作愉快！
