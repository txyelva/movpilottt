# MoviePilot (个人修改版)

![Based on](https://img.shields.io/badge/based%20on-MoviePilot%20v2.9.9-blue?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20Synology-blue?style=for-the-badge)

> 本项目基于 [jxxghp/MoviePilot](https://github.com/jxxghp/MoviePilot) `v2.9.9` 进行个人修改，仅供学习交流使用。

基于 [NAStool](https://github.com/NAStool/nas-tools) 部分代码重新设计，聚焦自动化核心需求，减少问题同时更易于扩展和维护。

## 修改内容

本修改版在原版基础上，**增强了推荐功能**，新增了按地区分类的剧集推荐接口，让推荐内容更加精准：

### 新增豆瓣推荐分类

| 接口 | 说明 |
|------|------|
| `/api/v1/recommend/douban_tv_domestic` | 豆瓣热门国产剧 |
| `/api/v1/recommend/douban_tv_american` | 豆瓣热门美剧 |
| `/api/v1/recommend/douban_tv_korean` | 豆瓣热门韩剧 |

### 新增 TMDB 推荐分类

| 接口 | 说明 |
|------|------|
| `/api/v1/recommend/tmdb_tv_chinese` | TMDB 热播国产剧（近3个月内有新集播出） |
| `/api/v1/recommend/tmdb_tv_american` | TMDB 热播美剧（近3个月内有新集播出） |
| `/api/v1/recommend/tmdb_tv_korean` | TMDB 热播韩剧（近3个月内有新集播出） |

### 其他增强

- **TMDB Discover 扩展**：新增 `air_date_gte` / `air_date_lte` 参数，支持按最新集播出日期筛选剧集
- **剧集季信息补充**：TMDB 电视剧推荐结果自动补充最新季信息，标题追加季标识（如 `S6`），年份更新为最新季年份
- **工作流集成**：新增推荐分类已同步注册到工作流的媒体获取动作中

### 修改文件清单

```
app/api/endpoints/recommend.py       # 新增6个推荐API端点
app/chain/recommend.py               # 推荐链核心逻辑，新增分类推荐和季信息补充
app/chain/douban.py                  # 豆瓣链新增国产剧/美剧/韩剧接口
app/chain/tmdb.py                    # TMDB链新增air_date筛选参数
app/modules/douban/__init__.py       # 豆瓣模块新增分类剧集获取
app/modules/douban/apiv2.py          # 豆瓣API新增分类URL调用
app/modules/themoviedb/__init__.py   # TMDB模块支持air_date参数
app/workflow/actions/fetch_medias.py  # 工作流媒体获取新增6个推荐源
```

## 安装使用

基础安装方式与原版一致，请参考官方文档：

- 官方 Wiki：https://wiki.movie-pilot.org
- API 文档：https://api.movie-pilot.org

### 下载

前往 [Releases](https://github.com/zqchris/MoviePilot/releases) 页面下载最新版本。

## 上游项目

- [MoviePilot](https://github.com/jxxghp/MoviePilot) - 原版项目
- [MoviePilot-Frontend](https://github.com/jxxghp/MoviePilot-Frontend) - 前端项目
- [MoviePilot-Resources](https://github.com/jxxghp/MoviePilot-Resources) - 资源项目
- [MoviePilot-Plugins](https://github.com/jxxghp/MoviePilot-Plugins) - 插件项目

## 免责声明

- 本软件仅供学习交流使用，请勿在任何国内平台宣传该项目。
- 本项目基于开源项目修改，所有修改仅为个人使用目的，不对任何第三方使用产生的后果负责。
