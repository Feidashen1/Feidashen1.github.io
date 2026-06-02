# Feidashen 博客 · 常用命令
# 用法示例：
#   make new t=我的新文章      # 新建文章
#   make serve                 # 本地预览（含草稿）
#   make build                 # 本地构建检查
#   make publish m="更新说明"  # 提交并推送发布
#   make upgrade               # 升级 PaperMod 主题

HUGO ?= hugo

.PHONY: help new serve build publish upgrade clean

help:
	@echo "可用命令："
	@echo "  make new t=标题        新建一篇文章 (content/posts/标题.md)"
	@echo "  make serve             本地预览，含草稿 -> http://localhost:1313"
	@echo "  make build             本地构建到 public/ 做检查"
	@echo "  make publish m=说明     git add+commit+push 一键发布"
	@echo "  make upgrade           升级 PaperMod 主题"
	@echo "  make clean             清理构建产物"

# 新建文章：make new t=我的标题
new:
ifndef t
	@echo "用法: make new t=文章标题"; exit 1
endif
	$(HUGO) new posts/$(t).md
	@echo "已创建 content/posts/$(t).md —— 记得把 draft 改成 false 再发布"

# 本地预览（-D 显示草稿）
serve:
	$(HUGO) server -D

# 本地构建检查
build:
	$(HUGO) --gc --minify

# 一键发布：make publish m="提交说明"
publish:
	git add -A
	git commit -m "$(if $(m),$(m),更新内容)"
	git push

# 升级主题
upgrade:
	git submodule update --remote --merge themes/PaperMod
	git add themes/PaperMod
	git commit -m "升级 PaperMod 主题"
	@echo "已升级，运行 make publish 推送，或 git push"

# 清理构建产物
clean:
	rm -rf public resources/_gen .hugo_build.lock
