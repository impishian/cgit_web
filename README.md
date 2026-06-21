# cgit_web

本地 git repos 浏览，页面风格类似 github。

局域网内自用，谨慎钫公网部署。

web server: `mini_httpd` 提供访问，

CGI for git: `cgit` 

入口: `http://localhost:18080/cgit.cgi/`

截图：

<img width="1170" height="330" alt="image" src="https://github.com/user-attachments/assets/3d3dad96-3759-4ee8-978f-15ccf53195b7" />

<img width="1298" height="705" alt="image" src="https://github.com/user-attachments/assets/c33ed268-cc06-4692-85d8-2ac1312fd1e0" />

<img width="1298" height="671" alt="image" src="https://github.com/user-attachments/assets/5775245d-8269-4c20-9df1-8dad5b7d3380" />

## 目录说明

- `cgit.cgi`：cgit 主入口
- `index.cgi`：站点首页入口
- `assets/`：样式、脚本和图片
- `config/`：`cgitrc`、`mini_httpd.conf`、`head-include.html`
- `scripts/`：启动、停止、生成配置脚本
- `filters/`：Markdown、About 页、源码高亮等过滤器
- `bin/`：本地使用的 `cgit.real` 和 `mini_httpd`

## 依赖

默认使用仓库里自带的可执行文件和脚本，正常浏览不需要额外编译。

运行时依赖：

- `bash`
- `perl`
- `git`
- `mini_httpd` 对应二进制 （示例中为 macos 26.5.2 的可执行文件）
- `cgit.real` 对应二进制 （示例中为 macos 26.5.2 的可执行文件，由编译得到 cgit 复制改名为 cgit.real）

过滤器相关依赖：

- Markdown about 页面：`markdown-it-py`
- 代码高亮：`highlight`

如果你要重新生成 about 页渲染结果、源码高亮结果，或者调试过滤器，
这些外部工具需要在系统里可用。

## 编译

这个仓库本身不包含 `cgit` 和 `mini_httpd` 的完整编译工程，因此日常使用
通常不需要在这里“编译”。

当前推荐方式是直接使用 `bin/` 目录下已经准备好的二进制文件：

- `bin/cgit.real`
- `bin/mini_httpd`

如果你要替换成自己编译的版本，原则上只要保持这两个文件可执行，
并且与当前配置文件兼容即可。

## 生成配置

`config/cgitrc` 可以由脚本自动生成，脚本会扫描指定根目录下的子仓库：

```bash
scripts/gen_cgitrc.sh /Users/ian/github > config/cgitrc
```

默认情况下，如果不传参数，脚本会使用 `$HOME/github` 作为仓库根目录。

生成规则：

- 自动设置站点样式、脚本和入口前缀
- 自动启用 Markdown about 页和源码高亮过滤器
- 自动列出扫描到的 Git 仓库
- 自动配置本地 cache 目录和 cache size

## 启动

直接启动：

```bash
scripts/start.sh
```

脚本会做这些事：

- 创建或更新 `cgit` cache 目录 `/tmp/cgit`
- 清理超出当前 `cache-size` 的旧 cache slot
- 停掉旧的 `mini_httpd`
- 生成临时 `mini_httpd` 配置
- 启动 `mini_httpd`

启动后访问：

```text
http://127.0.0.1:18080/cgit.cgi/
```

## 停止

```bash
scripts/stop.sh
```

脚本会优先使用 `/tmp/mini_httpd.pid` 停止服务，失败时再回退到进程名查找。

## 部署到本机局域网

1. 把这个仓库放到本机磁盘上的固定位置。
2. 确保你要展示的 Git 仓库也在本机磁盘上，并且 `config/cgitrc` 已经列出来。
3. 先执行 `scripts/gen_cgitrc.sh` 更新仓库列表，再检查 `config/cgitrc`。
4. 执行 `scripts/start.sh`。
5. 在浏览器里打开 `http://127.0.0.1:18080/cgit.cgi/`。

如果你想让局域网内其他机器访问，需要把 `config/mini_httpd.conf` 里的
`host=127.0.0.1` 改成可监听的地址，并配合防火墙放行端口 `18080`。

## Cache

当前 `cgit` cache 目录是 `/tmp/cgit`，`cache-size=128`。

这意味着：

- `start.sh` 会预创建 128 个 slot 目录
- 超出范围的旧 slot 会在启动时清理
- 缓存目录不是每次都重新生成一千多个文件，而是按 slot 目录组织

## 常见问题

### 为什么 about 页能渲染 Markdown

因为 `config/cgitrc` 里启用了 `about-filter`，并指向
`filters/about-formatting.sh`。这个脚本会把 `.md`、`.markdown`、
`.mkd` 等文件交给 Markdown 转换器处理。

### 为什么源码页有语法高亮

因为 `config/cgitrc` 里启用了 `source-filter`，并指向
`filters/syntax-highlighting.py`。

### 为什么这里是 `/cgit.cgi/`

这是 `virtual-root=/cgit.cgi/` 的配置结果。站点入口会保持这个前缀，
其余静态资源走 `/assets/`。

## 打包

如果你要重新打一个发布包，建议排除 `.git` 和 `.DS_Store`：

```bash
tar --exclude-vcs --exclude='.DS_Store' --exclude='*/.DS_Store'  --exclude='.git' -czf /tmp/cgit_web.tar.gz .
```

## 备注

这个项目定位是本机自用和局域网浏览，不追求公网部署、安全加固或多用户权限体系。

cgit 官网：https://git.zx2c4.com/cgit/
cgit github：https://github.com/zx2c4/cgit
cgit 源码下载：https://github.com/zx2c4/cgit/archive/refs/tags/v1.3.1.tar.gz

mini_httpd 官网：https://acme.com/software/mini_httpd/
mini_httpd 源码下载：http://www.acme.com/software/mini_httpd/mini_httpd-1.30.tar.gz

## Build cgit & mini_httpd

### 1. ubuntu 24.04.4, build cgit

```
tar xf cgit-1.3.1.tar.gz
cd cgit-1.3.1
make get-git
make NO_LUA=1 NEEDS_LIBICONV=YesPlease LDFLAGS="-L/usr/local/lib" -j4
```

### 2. macos 26.5.1, build cgit

```
tar xf cgit-1.3.1.tar.gz
cd cgit-1.3.1
make get-git
make NO_LUA=1 NO_GETTEXT=YesPlease -j10
```

报错，还需在 ui-shared.c 的 #include ‘cgit.h’ 后增加

```
#ifndef HAVE_MEMRCHR
static void *cgit_memrchr(const void *s, int c, size_t n)
{
  const unsigned char *p = (const unsigned char *)s + n;
  while (n--)
    if (*--p == (unsigned char)c)
      return (void *)p;
  return NULL;
}
#define memrchr cgit_memrchr
#endif
```

再编译就OK了


### 3. ubuntu 24.04.4, build mini_httpd


Makefile L27: CFLAGS 去掉 -ansi -pedantic

mini_httpd.c:  send_via_sendfile 函数体改为空 ( vim打开再执行 :2799,2823d )，再执行

```
make mini_httpd
```

### 4. macos 26.5.1 build mini_httpd


Makefile L10:  CRYPT_LIB =  

mini_httpd.c:  send_via_sendfile 函数体改为空 ( vim打开再执行 :2799,2823d )，再执行

```
make mini_httpd
```


## 感谢

- Codex: https://openai.com/codex/
- cgit: https://git.zx2c4.com/cgit/
- mini_httpd : https://acme.com/software/mini_httpd/
- CGit GitHub-Theme https://www.hackitu.de/cgithub/
