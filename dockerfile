# 构建阶段 - 使用 Node 20 镜像
FROM node:20-alpine AS build-stage

# 设置工作目录并修复权限
WORKDIR /app
RUN chown -R node:node /app
USER node

# 1. 单独复制 package 文件（利用缓存层）
COPY --chown=node:node package*.json ./

# 2. 安装依赖（使用 ci 命令保持一致性）
RUN npm ci --prefer-offline

# 3. 复制其他文件
COPY --chown=node:node . .

# 4. 构建配置（调整内存限制）
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build

# 生产阶段 - 只提供静态文件（不再运行 Nginx）
FROM alpine:latest AS production-stage

# 安装 curl 用于健康检查（可选）
RUN apk add --no-cache curl

# 从构建阶段复制产物
COPY --from=build-stage --chown=1000:1000 /app/dist /app/dist

# 健康检查（检查静态文件是否存在）
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

# 声明数据卷（让外部 Nginx 挂载）
VOLUME /app/dist

# 启动命令（可选，可以只是 sleep 保持容器运行）
CMD ["sh", "-c", "while true; do sleep 86400; done"]