# 服装商城推荐系统项目文档
## 1. 项目结构
clothingMarket/
├── models/                 # 数据模型目录
│   ├── __init__.py        # 模型初始化文件
│   ├── models.py          # 主要数据模型定义
│   ├── user.py            # 用户相关模型
│   └── recommendation.py  # 推荐系统相关模型
│
├── routes/                 # 路由目录
│   ├── main.py            # 主站路由
│   ├── auth.py            # 认证相关路由
│   ├── admin.py           # 管理后台路由
│   ├── cart.py            # 购物车相关路由
│   └── order.py           # 订单相关路由
│
├── templates/             # 模板目录
│   ├── base.html         # 基础模板
│   ├── index.html        # 首页模板
│   ├── profile.html      # 个人中心模板
│   ├── payment.html      # 支付页面模板
│   ├── admin/            # 管理后台模板
│   ├── main/             # 主站模板
│   ├── cart/             # 购物车模板
│   └── auth/             # 认证相关模板
│
├── static/               # 静态文件目录
│   ├── css/             # CSS文件
│   ├── js/              # JavaScript文件
│   └── images/          # 图片资源
│
├── app.py               # 应用主文件
├── extensions.py        # 扩展文件
├── middleware.py        # 中间件文件
├── init_db.sql         # 数据库初始化脚本
├── requirements.txt     # 依赖包列表
└── .env                # 环境变量文件

