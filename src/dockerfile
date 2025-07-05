# 1. 使用 Node 镜像构建阶段，编译打包 Vue 项目
FROM node:18-alpine AS build-stage

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 package-lock.json (如果有)
COPY package*.json ./

# 安装依赖
RUN npm install

# 复制所有源码
COPY . .

# 运行打包命令，生成生产环境代码
RUN npm run build

# 2. 使用 Nginx 镜像作为生产环境运行阶段，提供静态资源服务
FROM nginx:alpine AS production-stage

# 复制第一阶段构建好的静态资源到 nginx 默认目录
COPY --from=build-stage /app/dist /usr/share/nginx/html

# 复制自定义的 nginx 配置（可选）
# COPY nginx.conf /etc/nginx/nginx.conf

# 暴露 80 端口
EXPOSE 8083

# 启动 nginx 服务
CMD ["nginx", "-g", "daemon off;"]