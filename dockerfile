# 构建阶段 - 使用 Node 20 镜像
FROM node:20-alpine AS build-stage

# 设置工作目录并修复权限
WORKDIR /app
RUN chown -R node:node /app
USER node

# 1. 单独复制package文件（利用缓存层）
COPY --chown=node:node package*.json ./

# 2. 安装依赖（使用ci命令保持一致性）
RUN npm ci --prefer-offline

# 3. 复制其他文件
COPY --chown=node:node . .

# 4. 构建配置（调整内存限制）
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build

# 生产阶段 - 保持轻量
FROM nginx:alpine AS production-stage

# 从构建阶段复制产物
COPY --from=build-stage --chown=nginx:nginx /app/dist /usr/share/nginx/html

# 使用自定义配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8083/ || exit 1

# 暴露端口（与nginx.conf一致）
EXPOSE 8083

CMD ["nginx", "-g", "daemon off;"]