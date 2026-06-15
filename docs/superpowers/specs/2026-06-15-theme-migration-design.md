# 博客主题迁移设计：PaperMod → Stack

日期：2026-06-15

## 背景

当前博客使用 Hugo + PaperMod 主题，6 篇文章（C++ 技术笔记为主）。用户需要：
- 文章分类/目录树（侧边栏导航）
- 卡片式文章列表
- 保留现有全部功能并顺便优化

## 目标主题：Stack

- GitHub: https://github.com/CaiJimmy/hugo-theme-stack
- 特点：左侧分类树 + 卡片列表 + 文章页目录侧边栏
- 专为技术博客设计，中文社区活跃

## 迁移步骤

### 1. 主题切换

- 移除 `themes/PaperMod` git submodule
- 添加 `themes/stack` 作为 git submodule
- 修改 `hugo.toml`：`theme = "stack"`

### 2. 配置重写

PaperMod 和 Stack 的 `[params]` 结构完全不同，需要全部重写。

#### 2.1 保留不变的配置

```toml
baseURL = "https://feidashen1.github.io/"
languageCode = "zh-cn"
title = "Feidashen 的博客"
enableRobotsTXT = true
buildDrafts = false

[markup.highlight]
  noClasses = false

[minify]
  disableXML = true
  minifyOutput = true

[outputs]
  home = ["HTML", "RSS", "JSON"]

[services.googleAnalytics]
  ID = "G-0DHLKH8LTF"
```

#### 2.2 需要重写的配置

**导航菜单**（`[menu]`）：
- Stack 用 `main` 菜单做顶部导航
- 侧边栏分类树是自动生成的，不需要菜单配置
- 保留：文章、归档、标签、搜索、关于

**主题参数**（`[params]`）：
- PaperMod 的 `params` 全部删除
- 替换为 Stack 的配置结构：
  - `[params.sidebar]`：侧边栏行为
  - `[params.footer]`：页脚
  - `[params.article]`：文章页设置（数学、mermaid、目录等）
  - `[params.comments]`：评论系统
  - `[params.widgets]`：首页小部件（搜索、分类、标签、归档、最近文章）
  - `[params.search]`：搜索设置

#### 2.3 Stack 配置参考

```toml
[params]
  mainSections = ["posts"]
  featuredImageField = "image"
  favicon = "/favicon.svg"

  [params.sidebar]
    emoji = ""
    subtitle = "记录技术与生活"
    compact = false

  [params.article]
    headingAnchor = true
    math = false          # 默认关闭，文章 front matter 按需开启
    toc = true
    readingTime = true
    license = ""          # 可选：文章许可证

  [params.comments]
    enabled = true
    provider = "giscus"
    [params.comments.giscus]
      repo = "Feidashen1/Feidashen1.github.io"
      repoID = "R_kgDOSukKjg"
      category = "Announcements"
      categoryID = "DIC_kwDOSukKjs4C-WCA"
      mapping = "pathname"
      strict = false
      reactionsEnabled = true
      inputPosition = "bottom"
      lightTheme = "light"
      darkTheme = "dark_dimmed"
      lang = "zh-CN"

  [params.widgets]
    enabled = ["search", "archives", "categories", "tag-cloud"]
    [params.widgets.archives]
      count = 5
    [params.widgets.tagCloud]
      limit = 10

  [params.search]
    enabled = true
    provider = ""         # 空 = 内置 Fuse.js
```

### 3. 自定义布局迁移

| PaperMod 文件 | Stack 对应位置 | 迁移方式 |
|---|---|---|
| `layouts/partials/extend_head.html` | `layouts/partials/head/custom.html` | 复制 medium-zoom 代码，KaTeX/Mermaid 改用 Stack 原生 |
| `layouts/partials/extend_footer.html` | `layouts/partials/footer/custom.html` | 保持为空 |
| `layouts/partials/comments.html` | 删除 | Stack 原生 Giscus，配置在 hugo.toml |
| `layouts/partials/google_analytics.html` | 删除 | Stack 用 Hugo 内置 GA |
| `layouts/shortcodes/notice.html` | `layouts/shortcodes/notice.html` | 重建，适配 Stack 样式 |
| `layouts/_markup/render-codeblock-mermaid.html` | `layouts/_markup/render-codeblock-mermaid.html` | 保留或改用 Stack 原生 |

### 4. 自定义 CSS

- `assets/css/extended/custom.css` → Stack 使用 `assets/css/custom.scss` 或 `assets/css/custom.css`
- 检查并迁移自定义样式

### 5. 文章内容更新

每篇文章需要：
- 添加 `categories` 字段（Stack 分类树依赖）
- 可选添加 `image` 字段（卡片封面图）
- 可选添加 `description` 字段（卡片摘要）

现有文章分类计划：
- `[C++] 构造与析构.md` → categories: ["C++"]
- `[C++] 函数特性.md` → categories: ["C++"]
- `[C++] 类和对象.md` → categories: ["C++"]
- `gdb 命令.md` → categories: ["Linux"] 或 ["工具"]
- `feature-test.md` → categories: ["测试"]
- `first-post.md` → categories: ["随笔"]

### 6. 优化项

- 为 C++ 文章添加系列标签或分类
- 添加文章封面图（可用 placeholder 或纯色背景）
- 配置 Stack 的 widget 系统，优化首页布局
- 利用 Stack 的 built-in features：最后修改时间、编辑按钮链接

### 7. 验证清单

- [ ] 本地 `hugo server -D` 正常启动
- [ ] 分类树侧边栏显示正确
- [ ] 卡片式文章列表正常
- [ ] 暗/亮模式切换正常
- [ ] Giscus 评论正常加载
- [ ] KaTeX 数学公式正常渲染（feature-test）
- [ ] Mermaid 图表正常渲染（feature-test）
- [ ] 图片点击放大正常
- [ ] notice shortcode 正常
- [ ] 站内搜索正常
- [ ] Google Analytics 仅生产环境注入
- [ ] 构建后 `public/` 无错误
- [ ] 推送到 GitHub，Actions 部署成功
- [ ] 线上站 https://feidashen1.github.io 验证

## 风险与回退

- 主题切换前 git commit 当前状态，方便回退
- Stack 和 PaperMod 的 front matter 不完全兼容，需要逐篇文章检查
- Stack 的搜索方案可能需要额外配置（Pagefind 需安装）
