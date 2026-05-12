# 12-beijing 阿里云静态部署说明

本项目当前不是 React/Vite/后端服务结构，而是纯静态三件套页面：

- `index.html`：入口页，自动跳转到 `gis-platform.html`
- `gis-platform.html`：主 GIS / Three.js 页面，内联 CSS 和 JS
- `data/*.json`：本地 GeoJSON 数据
- Three.js 等依赖通过 CDN importmap 加载

因此部署不需要 Python、Node、PM2、gunicorn，也不需要构建步骤。最合适的方式是用 Nginx 静态托管。

## 安全策略

为避免影响同一台服务器上的其他项目，本部署默认：

- 不停止已有前端/后端进程
- 不占用 80/443/5000/5173/3000/8080/18080
- 新建独立目录：`/opt/12_beijing_aliyun`
- 新建独立 Nginx site：`12-beijing-aliyun`
- 默认端口：`18081`

如果你已经有项目占用 `18081`，可以用 `PUBLIC_PORT=18082` 改端口。

## 推荐部署方式：Windows 下载 zip，再 scp 上传

服务器直连 GitHub 不稳定时，不要在 ECS 上 git clone。改为本地下载压缩包并上传。

### 1. Windows PowerShell 下载并上传

```powershell
cd C:\Users\yynnjj\Downloads

Invoke-WebRequest `
  -Uri "https://github.com/wanderingbackorforward/12-beijing/archive/refs/heads/deploy/aliyun-static.zip" `
  -OutFile "12-beijing-aliyun.zip"

scp .\12-beijing-aliyun.zip root@120.55.70.218:/tmp/
```

### 2. 服务器解压并部署

```bash
cd /tmp
rm -rf 12_beijing_upload
mkdir -p 12_beijing_upload
unzip 12-beijing-aliyun.zip -d 12_beijing_upload

cd 12_beijing_upload/12-beijing-deploy-aliyun-static
bash deploy/aliyun/deploy_static_from_current_dir.sh
```

如果目录名不确定，先看：

```bash
ls /tmp/12_beijing_upload
```

### 3. 验证

```bash
curl http://127.0.0.1:18081/
curl http://127.0.0.1:18081/gis-platform.html
nginx -t
systemctl status nginx --no-pager
```

浏览器访问：

```text
http://120.55.70.218:18081/
```

如果服务器本机 curl 成功，但浏览器打不开，去阿里云 ECS 安全组放行：

```text
TCP 18081 入方向
```

## 换端口部署

```bash
PUBLIC_PORT=18082 bash deploy/aliyun/deploy_static_from_current_dir.sh
```

浏览器访问：

```text
http://120.55.70.218:18082/
```

## 后续更新

重复 Windows 下载 zip、scp 上传、服务器解压和运行脚本即可。脚本会用 rsync 覆盖 `/opt/12_beijing_aliyun` 中的静态文件，但不会动其他项目。

## 注意事项

1. `gis-platform.html` 依赖 CDN 加载 Three.js：如果访问端浏览器无法连 jsdelivr，页面 3D 资源会失败。后续可把 Three.js vendoring 到本地，避免 CDN 风险。
2. 页面里存在外部报表、监控平台、地图瓦片等链接，这些外部站点是否可访问取决于用户浏览器网络与对方系统权限。
3. 本项目目前是单文件内联样式/脚本，短期部署没问题；如果后续要维护，应考虑拆分为 `css/`、`js/`、`config/`，不一定要强行改 React。
