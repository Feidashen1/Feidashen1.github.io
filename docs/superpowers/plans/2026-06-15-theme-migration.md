# 博客主题迁移实施计划：PaperMod → Stack

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将博客从 PaperMod 主题迁移到 Stack 主题，保留全部现有功能并优化布局

**Architecture:** 替换 git submodule 主题，重写 hugo.toml 配置，迁移自定义布局到 Stack 的扩展点（`layouts/partials/head/custom.html`），更新文章 front matter 适配 Stack 的分类树和卡片布局

**Tech Stack:** Hugo extended v0.157.0+, Stack 主题 (git submodule), Giscus, Google Analytics 4, KaTeX, Mermaid, PhotoSwipe

**设计文档:** `docs/superpowers/specs/2026-06-15-theme-migration-design.md`

---

## 前提条件

- 所有操作在 `Feidashen1.github.io/` 目录下执行
- 推送需用户手动执行（HTTPS + PAT 认证）
- 当前 Hugo 版本 v0.150.0 → 需升级到 v0.157.0（Stack 最低要求）

---

### Task 1: Git 快照 & 升级 Hugo

**Files:**
- Modify: `~/.local/bin/hugo`（替换二进制）
- Modify: `.github/workflows/hugo.yml:26`（更新版本号）

- [ ] **Step 1: 提交当前状态作为回退点**

```bash
cd Feidashen1.github.io
git add -A
git commit -m "chore: 迁移到 Stack 主题前的快照"
```

- [ ] **Step 2: 下载 Hugo v0.157.0 extended**

```bash
wget -O /tmp/hugo.deb https://github.com/gohugoio/hugo/releases/download/v0.157.0/hugo_extended_0.157.0_linux-amd64.deb
```

Expected: 下载成功，文件约 30-40MB

- [ ] **Step 3: 安装到 ~/.local/bin/**

```bash
dpkg -x /tmp/hugo.deb /tmp/hugo-extract
cp /tmp/hugo-extract/usr/bin/hugo ~/.local/bin/hugo
rm -rf /tmp/hugo.deb /tmp/hugo-extract
hugo version
```

Expected: `hugo v0.157.0-...+extended linux/amd64`

- [ ] **Step 4: 更新 CI workflow 的 Hugo 版本**

修改 `.github/workflows/hugo.yml` 第 26 行：

```yaml
# 旧
HUGO_VERSION: 0.150.0
# 新
HUGO_VERSION: 0.157.0
```

- [ ] **Step 5: 验证 Hugo 能正常工作**

```bash
hugo version
```

Expected: 显示 v0.157.0

- [ ] **Step 6: 提交**

```bash
git add .github/workflows/hugo.yml
git commit -m "chore: 升级 Hugo 到 v0.157.0（Stack 主题要求）"
```

---

### Task 2: 切换主题 submodule

**Files:**
- Remove: `themes/PaperMod`（子模块）
- Add: `themes/stack`（子模块）
- Modify: `.gitmodules`
- Modify: `hugo.toml:4`（theme 字段）

- [ ] **Step 1: 移除 PaperMod 子模块**

```bash
cd Feidashen1.github.io
git submodule deinit -f themes/PaperMod
git rm -f themes/PaperMod
rm -rf .git/modules/themes/PaperMod
```

- [ ] **Step 2: 添加 Stack 子模块**

```bash
git submodule add https://github.com/CaiJimmy/hugo-theme-stack.git themes/stack
```

Expected: `.gitmodules` 更新，`themes/stack/` 目录出现

- [ ] **Step 3: 修改 hugo.toml 的 theme 字段**

```toml
# 旧（第 4 行）
theme = "PaperMod"
# 新
theme = "stack"
```

- [ ] **Step 4: 清理旧主题残留**

```bash
rm -rf themes/PaperMod
```

- [ ] **Step 5: 提交**

```bash
git add .gitmodules themes/ hugo.toml
git commit -m "chore: 切换主题从 PaperMod 到 Stack"
```

---

### Task 3: 重写 hugo.toml 配置

**Files:**
- Rewrite: `hugo.toml`

- [ ] **Step 1: 备份旧配置**

```bash
cp hugo.toml hugo.toml.papermod.bak
```

- [ ] **Step 2: 写入新的 hugo.toml**

完整替换 `hugo.toml` 为以下内容：

```toml
baseURL       = "https://feidashen1.github.io/"
languageCode  = "zh-cn"
title         = "Feidashen 的博客"
theme         = "stack"
hasCJKLanguage = true
enableRobotsTXT = true
buildDrafts   = false
buildFuture   = false
buildExpired  = false

[pagination]
  pagerSize = 10

[permalinks]
  page = "/:slug/"
# post 不设自定义 permalinks，保持默认 /posts/slug/ 路径，避免破坏已有链接

# ─── 代码高亮 ───────────────────────────────
[markup.highlight]
  noClasses          = false
  codeFences         = true
  guessSyntax        = true
  lineNos            = false
  lineNumbersInTable = false

# ─── Goldmark 数学公式 passthrough ──────────
[markup.goldmark.extensions.passthrough]
  enable = true
  [markup.goldmark.extensions.passthrough.delimiters]
    block  = [["\\[", "\\]"], ["$$", "$$"]]
    inline = [["\\(", "\\)"], ["$", "$"]]

[markup.goldmark.renderer]
  unsafe = true

# ─── 目录 ───────────────────────────────────
[tableOfContents]
  endLevel   = 4
  ordered    = false
  startLevel = 2

# ─── 压缩 ───────────────────────────────────
[minify]
  disableXML = true
  minifyOutput = true

# ─── 输出格式 ───────────────────────────────
[outputs]
  home = ["HTML", "RSS", "JSON"]

# ─── Google Analytics（仅生产环境注入）──────
[services.googleAnalytics]
  ID = "G-0DHLKH8LTF"

# ─── 顶部导航菜单 ───────────────────────────
[menu]
  [[menu.main]]
    identifier = "posts"
    name       = "文章"
    url        = "/posts/"
    weight     = 10
  [[menu.main]]
    identifier = "about"
    name       = "关于"
    url        = "/about/"
    weight     = 50

# ═══════════════════════════════════════════
# Stack 主题参数
# ═══════════════════════════════════════════
[params]
  mainSections      = ["posts"]
  featuredImageField = "image"
  rssFullContent    = true
  favicon           = "/favicon.svg"

  [params.footer]
    since      = 2026
    customText = ""

  [params.dateFormat]
    published   = "2006-01-02"
    lastUpdated = "2006-01-02"

  [params.sidebar]
    emoji    = "📝"
    subtitle = "记录技术与生活"
    avatar   = ""
    compact  = false

  [params.article]
    headingAnchor = true
    math          = false
    toc           = true
    readingTime   = true

    [params.article.list]
      showTags = true

    [params.article.license]
      enabled = false

    [params.article.mermaid]
      look                  = "classic"
      lightTheme            = "default"
      darkTheme             = "dark"
      securityLevel         = "strict"
      htmlLabels            = true
      transparentBackground = false

  [params.widgets]
    homepage = [
      { type = "search" },
      { type = "archives", params = { limit = 5 } },
      { type = "categories", params = { limit = 10 } },
      { type = "tag-cloud", params = { limit = 10 } },
    ]
    page = [{ type = "toc" }]

  [params.opengraph.twitter]
    site = ""
    card = "summary_large_image"

  [params.colorScheme]
    toggle  = true
    default = "auto"

  [params.imageProcessing]
    autoOrient = false
    [params.imageProcessing.content]
      widths  = [800, 1600]
      enabled = true
    [params.imageProcessing.thumbnail]
      enabled = true

  # ─── Giscus 评论 ────────────────────────
  [params.comments]
    enabled  = true
    provider = "giscus"

    [params.comments.giscus]
      repo             = "Feidashen1/Feidashen1.github.io"
      repoID           = "R_kgDOSukKjg"
      category         = "Announcements"
      categoryID       = "DIC_kwDOSukKjs4C-WCA"
      mapping          = "pathname"
      strict           = 0
      reactionsEnabled = 1
      emitMetadata     = 0
      inputPosition    = "bottom"
      lightTheme       = "light"
      darkTheme        = "dark_dimmed"
      lang             = "zh-CN"
      loading          = "lazy"
```

- [ ] **Step 3: 验证配置语法**

```bash
hugo config 2>&1 | head -20
```

Expected: 无错误输出，显示解析后的配置

- [ ] **Step 4: 删除旧备份**

```bash
rm hugo.toml.papermod.bak
```

- [ ] **Step 5: 提交**

```bash
git add hugo.toml
git commit -m "feat: 重写 hugo.toml 适配 Stack 主题"
```

---

### Task 4: 迁移内容页面（search / archives / about）

**Files:**
- Delete: `content/search.md`
- Delete: `content/archives.md`
- Create: `content/page/search/index.md`
- Create: `content/page/archives/index.md`
- Modify: `content/about.md`

Stack 的搜索和归档页使用 `content/page/` 目录，不再用 `content/` 根目录。

- [ ] **Step 1: 创建 Stack 格式的搜索页**

创建 `content/page/search/index.md`：

```markdown
---
title: "搜索"
slug: "search"
layout: "search"
outputs:
    - html
    - json
menu:
    main:
        weight: 40
        params:
            icon: search
---
```

- [ ] **Step 2: 创建 Stack 格式的归档页**

创建 `content/page/archives/index.md`：

```markdown
---
title: "归档"
layout: "archives"
slug: "archives"
menu:
    main:
        weight: 20
        params:
            icon: archives
---
```

- [ ] **Step 3: 更新关于页面**

修改 `content/about.md` front matter：

```markdown
---
title: "关于"
layout: "page"
slug: "about"
menu:
    main:
        weight: 50
        params:
            icon: user
comments: false
---

## 关于我

你好，我是 **Feidashen** 👋

刚开始工作，一些知识还是比较匮乏，通过写博客的方式来利用"输出倒逼输入" 来强制自己做一些学习，夯实一下基础

记录学习：

- C++/C/python
- 计算机相关知识
- 一些工具或者技巧


## 联系我

- GitHub：[Feidashen1](https://github.com/Feidashen1)
- Email：fengshfei@163.com
- QQ: 925923758

> 感兴趣或者想要一起探讨的可以联系我
```

- [ ] **Step 4: 删除旧的特殊页面**

```bash
rm content/search.md content/archives.md
```

- [ ] **Step 5: 提交**

```bash
git add content/
git commit -m "feat: 迁移搜索/归档/关于页面到 Stack 格式"
```

---

### Task 5: 更新文章 front matter

**Files:**
- Modify: `content/posts/[C++] 构造与析构.md`
- Modify: `content/posts/[C++] 函数特性.md`
- Modify: `content/posts/[C++] 类和对象.md`
- Modify: `content/posts/gdb 命令.md`
- Modify: `content/posts/feature-test.md`
- Modify: `content/posts/first-post.md`

Stack 的文章 front matter 和 PaperMod 有以下差异：
- `categories` 字段：PaperMod 已有但需修正（当前全是 "随笔"）
- `image` 字段：Stack 用 `image:` 做封面图（PaperMod 用 `cover.image`）
- `description` 字段：Stack 优先用 `description`（PaperMod 用 `summary`）
- `ShowToc`/`TocOpen`：Stack 不认这些，改用 `toc: true/false`
- Stack 新增字段：`license`、`links`

- [ ] **Step 1: 更新 C++ 构造与析构**

修改 `content/posts/[C++] 构造与析构.md` front matter：

```yaml
---
title: "[C++] 构造与析构"
date: 2026-06-14T20:00:00+08:00
draft: false
tags: ["C++", "构造与析构"]
categories: ["C++"]
description: "构造、析构"
---
```

- [ ] **Step 2: 更新 C++ 函数特性**

修改 `content/posts/[C++] 函数特性.md` front matter：

```yaml
---
title: "[C++] 函数特性"
date: 2026-06-14T19:00:00+08:00
draft: false
tags: ["C++", "函数"]
categories: ["C++"]
description: "C++ 函数特性笔记"
---
```

（注：date 保留原文值，不要改。只改 categories/description）

- [ ] **Step 3: 更新 C++ 类和对象**

修改 `content/posts/[C++] 类和对象.md` front matter：

```yaml
---
title: "[C++] 类和对象"
date: 2026-06-14T18:00:00+08:00
draft: false
tags: ["C++", "类和对象"]
categories: ["C++"]
description: "C++ 类和对象笔记"
---
```

- [ ] **Step 4: 更新 gdb 命令**

修改 `content/posts/gdb 命令.md` front matter：

```yaml
---
title: "GDB 命令及技巧"
date: 2026-06-07T22:00:00+08:00
draft: false
tags: ["GDB", "系统"]
categories: ["工具"]
description: "学习一下 GDB 的东西和技巧，对自己比较模糊的地方做一下记录。"
---
```

- [ ] **Step 5: 更新 feature-test**

修改 `content/posts/feature-test.md` front matter：

```yaml
---
title: "功能测试：这篇文章用来检验博客的各项能力"
date: 2026-06-02T15:30:00+08:00
draft: false
tags: ["测试", "Hugo", "Stack", "Markdown"]
categories: ["测试"]
math: true
description: "一篇覆盖目录、代码高亮、表格、图片、标签、脚注、数学公式、Mermaid 图表、提示框等功能的测试文章。"
image: "/images/test-banner.svg"
---
```

注意：
- 删除 `ShowToc`、`TocOpen`（Stack 不认）
- 删除 `mermaid: true`（Stack 自动检测 mermaid 代码块）
- `cover:` 块改为顶层 `image:`
- `summary:` 改为 `description:`

- [ ] **Step 6: 更新 first-post**

修改 `content/posts/first-post.md` front matter：

```yaml
---
title: "我的第一篇博客"
date: 2026-06-02T14:00:00+08:00
draft: false
tags: ["开始", "Hugo"]
categories: ["随笔"]
description: "这是用 Hugo + Stack 搭建的博客的第一篇文章。"
---
```

同时修改文章正文中提到 PaperMod 的部分，改为 Stack：

```markdown
## 这个博客是怎么搭的

- **生成器**：[Hugo](https://gohugo.io/)（Go 写的静态站点生成器，构建极快）
- **主题**：[Stack](https://github.com/CaiJimmy/hugo-theme-stack)（卡片式技术博客主题）
- **托管**：GitHub Pages，通过 GitHub Actions 自动部署
```

- [ ] **Step 7: 提交**

```bash
git add content/posts/
git commit -m "feat: 更新文章 front matter 适配 Stack 主题"
```

---

### Task 6: 迁移自定义布局（notice shortcode + medium-zoom）

**Files:**
- Delete: `layouts/partials/extend_head.html`
- Delete: `layouts/partials/extend_footer.html`
- Delete: `layouts/partials/comments.html`
- Delete: `layouts/partials/google_analytics.html`
- Create: `layouts/partials/head/custom.html`（medium-zoom → PhotoSwipe 已由 Stack 内置）
- Keep: `layouts/shortcodes/notice.html`（保留，CSS 在 Task 7 处理）
- Delete: `layouts/_markup/render-codeblock-mermaid.html`（Stack 内置）

- [ ] **Step 1: 删除不再需要的 PaperMod 自定义 partials**

Stack 原生支持 Giscus 评论、GA 统计、KaTeX 数学、Mermaid 图表、PhotoSwipe 图片放大，不需要自定义 partial。

```bash
rm layouts/partials/extend_head.html
rm layouts/partials/extend_footer.html
rm layouts/partials/comments.html
rm layouts/partials/google_analytics.html
```

- [ ] **Step 2: 删除自定义 Mermaid 渲染钩子**

Stack 内置了 `render-codeblock-mermaid.html`，不需要自定义。

```bash
rm layouts/_markup/render-codeblock-mermaid.html
```

- [ ] **Step 3: 检查 layouts 目录是否还有残留**

```bash
find layouts/ -type f | sort
```

Expected 输出：
```
layouts/shortcodes/notice.html
```

`layouts/partials/` 和 `layouts/_markup/` 目录应为空（可删除空目录）。

- [ ] **Step 4: 提交**

```bash
git add layouts/
git commit -m "refactor: 删除 PaperMod 自定义布局（Stack 原生替代）"
```

---

### Task 7: 迁移自定义 CSS

**Files:**
- Delete: `assets/css/extended/custom.css`
- Create: `assets/css/custom.css`（Stack 的自定义 CSS 路径）

- [ ] **Step 1: 创建 Stack 格式的自定义 CSS**

创建 `assets/css/custom.css`：

```css
/* ── Callout / 提示框 ───────────────────────────── */
.notice {
  display: flex;
  gap: 0.6rem;
  padding: 0.8rem 1rem;
  margin: 1.2rem 0;
  border-radius: 8px;
  border: 1px solid var(--card-background);
  border-left-width: 4px;
  background: var(--card-background);
}
.notice-icon { font-size: 1.2rem; line-height: 1.7; flex-shrink: 0; }
.notice-body { flex: 1; }
.notice-body > :first-child { margin-top: 0; }
.notice-body > :last-child  { margin-bottom: 0; }
.notice-info    { border-left-color: #3b82f6; }
.notice-tip     { border-left-color: #22c55e; }
.notice-warning { border-left-color: #f59e0b; }
.notice-danger  { border-left-color: #ef4444; }
.notice-note    { border-left-color: #8b5cf6; }
```

注意：
- Stack 的 CSS 变量和 PaperMod 不同：`--entry` → `--card-background`，`--border` → `--card-background`
- 删除 `.post-content img { cursor: zoom-in; }` — Stack 用 PhotoSwipe，光标样式由主题处理
- 删除 `pre.mermaid` 样式 — Stack 内置处理

- [ ] **Step 2: 删除旧的 CSS 文件**

```bash
rm assets/css/extended/custom.css
rmdir assets/css/extended 2>/dev/null
```

- [ ] **Step 3: 提交**

```bash
git add assets/
git commit -m "feat: 迁移自定义 CSS 到 Stack 格式"
```

---

### Task 8: 更新 Makefile 和 CLAUDE.md

**Files:**
- Modify: `Makefile`
- Modify: `CLAUDE.md`（父目录）

- [ ] **Step 1: 更新 Makefile 的 upgrade 目标**

将 `Makefile` 中的 upgrade 目标改为 Stack：

```makefile
# 升级主题
upgrade:
	git submodule update --remote --merge themes/stack
	git add themes/stack
	git commit -m "升级 Stack 主题"
	@echo "已升级，运行 make publish 推送，或 git push"
```

同时更新 help 中的文字：

```makefile
	@echo "  make upgrade           升级 Stack 主题"
```

- [ ] **Step 2: 更新 CLAUDE.md**

更新以下内容：
- 主题名称 PaperMod → Stack
- 自定义实现章节：重写（大部分 Stack 原生支持，仅剩 notice shortcode + custom.css）
- 配置位置章节：更新 Giscus 配置路径
- 更新 `make upgrade` 描述
- 更新 front matter 约定（`image` 替代 `cover.image`，`description` 替代 `summary`）

- [ ] **Step 3: 提交**

```bash
git add Makefile ../CLAUDE.md
git commit -m "docs: 更新 Makefile 和 CLAUDE.md 适配 Stack 主题"
```

---

### Task 9: 本地验证

**Files:** 无新增修改，仅验证

- [ ] **Step 1: 清理并启动本地预览**

```bash
rm -rf public/ resources/ .hugo_build.lock
hugo server -D
```

Expected: 无错误，站点启动在 localhost

- [ ] **Step 2: 逐项验证功能**

在浏览器中打开 http://localhost:1313 并检查：

| 检查项 | 验证方式 |
|---|---|
| 分类树侧边栏 | 左侧显示 C++、工具、测试、随笔 等分类 |
| 卡片式文章列表 | 首页文章以卡片形式展示 |
| 暗/亮模式切换 | 点击切换按钮，两种模式都正常 |
| Giscus 评论 | 打开任意文章页，底部出现评论框 |
| KaTeX 数学 | 打开 feature-test 页面，公式正常渲染 |
| Mermaid 图表 | 打开 feature-test 页面，图表正常渲染 |
| PhotoSwipe 图片 | 打开文章页，点击图片可放大 |
| notice shortcode | 在 feature-test 中检查提示框样式 |
| 站内搜索 | 点击搜索，输入关键词有结果 |
| 归档页 | 打开 /archives/，按年份分组显示 |
| 关于页 | 打开 /about/，内容正常显示 |
| GA 不注入 | 查看页面源码，无 gtag 脚本（开发模式） |

- [ ] **Step 3: 构建生产版本验证**

```bash
hugo --gc --minify
```

Expected: 构建成功，无错误/警告

- [ ] **Step 4: 验证生产版本 GA 注入**

```bash
grep -c 'gtag\|google' public/index.html
```

Expected: 匹配数 > 0（生产环境应注入 GA）

- [ ] **Step 5: 提交最终状态**

```bash
git add -A
git commit -m "feat: PaperMod → Stack 主题迁移完成"
```

---

### Task 10: 推送发布（需用户手动执行）

- [ ] **Step 1: 用户手动推送**

用户在终端中执行：

```bash
! git push
```

输入 Feidashen1 的 PAT 凭证。

- [ ] **Step 2: 检查 GitHub Actions**

在浏览器打开 https://github.com/Feidashen1/Feidashen1.github.io/actions 确认部署成功。

- [ ] **Step 3: 验证线上站点**

打开 https://feidashen1.github.io/ 逐项检查：
- 分类树、卡片列表、暗/亮模式
- Giscus 评论、数学公式、Mermaid 图表
- 图片放大、搜索、归档

---

## 回退方案

如果迁移出现问题，可以回退到 PaperMod：

```bash
git log --oneline | head -10
# 找到 "chore: 迁移到 Stack 主题前的快照" 的 commit hash
git reset --hard <commit-hash>
git submodule update --init --recursive
```
