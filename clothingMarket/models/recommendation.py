# 导入所需的库和模块
from extensions import db
from sqlalchemy import func
import numpy as np
from datetime import datetime, timedelta

# 用户行为模型类，用于记录用户对商品的各种行为
class UserBehavior(db.Model):
    __tablename__ = 'user_behavior'
    
    id = db.Column(db.Integer, primary_key=True)  # 主键ID
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)  # 用户ID，外键关联到用户表
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)  # 商品ID，外键关联到商品表
    behavior_type = db.Column(db.String(20), nullable=False)  # 行为类型（例如：浏览、加入购物车、购买）
    behavior_time = db.Column(db.DateTime, default=datetime.utcnow)  # 行为发生时间，默认为当前时间

# 商品相似度模型类，用于存储商品之间的相似度关系
class ProductSimilarity(db.Model):
    __tablename__ = 'product_similarity'
    
    id = db.Column(db.Integer, primary_key=True)  # 主键ID
    product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)  # 商品ID，外键关联到商品表
    similar_product_id = db.Column(db.Integer, db.ForeignKey('product.id'), nullable=False)  # 相似商品ID，外键关联到商品表
    similarity_score = db.Column(db.Float, nullable=False)  # 相似度分数
    created_at = db.Column(db.DateTime, default=datetime.utcnow)  # 创建时间，默认为当前时间

# 推荐系统类，实现基于用户行为的商品推荐功能
class RecommendationSystem:
    
    @staticmethod
    def record_user_behavior(user_id, product_id, behavior_type):
        """记录用户行为
        
        Args:
            user_id (int): 用户ID
            product_id (int): 商品ID
            behavior_type (str): 行为类型（view/cart/purchase）
        """
        # 创建用户行为记录
        behavior = UserBehavior(
            user_id=user_id,
            product_id=product_id,
            behavior_type=behavior_type
        )
        # 添加到数据库会话并提交
        db.session.add(behavior)
        db.session.commit()

    @staticmethod
    def get_user_recommendations(user_id, limit=5):
        """获取用户推荐商品列表
        
        Args:
            user_id (int): 用户ID
            limit (int): 返回推荐商品的最大数量，默认为5
            
        Returns:
            list: 推荐商品ID列表
        """
        # 获取用户最近30天的行为记录
        recent_behaviors = UserBehavior.query.filter(
            UserBehavior.user_id == user_id,
            UserBehavior.behavior_time >= datetime.utcnow() - timedelta(days=30)
        ).all()

        # 如果没有行为记录，返回空列表
        if not recent_behaviors:
            return []

        # 计算用户对商品的兴趣分数
        product_scores = {}
        interacted_products = set()  # 记录用户交互过的所有商品
        for behavior in recent_behaviors:
            if behavior.product_id not in product_scores:
                product_scores[behavior.product_id] = 0
            
            # 根据行为类型分配权重：购买(3分) > 加入购物车(2分) > 浏览(1分)
            if behavior.behavior_type == 'purchase':
                product_scores[behavior.product_id] += 3
            elif behavior.behavior_type == 'cart':
                product_scores[behavior.product_id] += 2
            else:  # view
                product_scores[behavior.product_id] += 1
            
            # 记录交互过的商品
            interacted_products.add(behavior.product_id)

        # 获取相似商品
        recommended_products = set()
        # 选择用户最感兴趣的5个商品作为种子
        for product_id, score in sorted(product_scores.items(), key=lambda x: x[1], reverse=True)[:5]:
            # 获取每个种子商品的5个最相似商品
            similar_products = ProductSimilarity.query.filter(
                ProductSimilarity.product_id == product_id
            ).order_by(ProductSimilarity.similarity_score.desc()).limit(5).all()
            
            for similar in similar_products:
                # 只过滤掉用户购买过的商品，允许推荐用户浏览过的商品
                purchased_products = {b.product_id for b in recent_behaviors if b.behavior_type == 'purchase'}
                if similar.similar_product_id not in purchased_products:
                    recommended_products.add(similar.similar_product_id)

        # 转换为列表并限制数量
        recommended_products = list(recommended_products)[:limit]
        
        return recommended_products

    @staticmethod
    def calculate_product_similarity():
        """计算商品相似度矩阵
        
        使用基于用户行为的协同过滤算法计算商品之间的相似度：
        1. 构建用户-商品交互矩阵
        2. 应用时间衰减因子
        3. 计算商品之间的余弦相似度
        4. 保存超过阈值的相似度关系
        """
        try:
            # 清空旧的相似度数据
            ProductSimilarity.query.delete()
            db.session.commit()
            print("已清空旧的相似度数据")
            
            # 获取所有用户行为
            behaviors = UserBehavior.query.all()
            if not behaviors:
                print("没有用户行为数据，无法计算商品相似度")
                return
            
            # 获取所有用户和商品的ID列表
            user_ids = sorted(list(set(b.user_id for b in behaviors)))
            product_ids = sorted(list(set(b.product_id for b in behaviors)))
            
            # 创建用户-商品矩阵（使用numpy数组提高效率）
            n_users = len(user_ids)
            n_products = len(product_ids)
            
            # 创建ID到索引的映射
            user_to_idx = {uid: idx for idx, uid in enumerate(user_ids)}
            product_to_idx = {pid: idx for idx, pid in enumerate(product_ids)}
            
            # 初始化矩阵
            user_product_matrix = np.zeros((n_users, n_products))
            
            # 填充矩阵，对每个用户的行为进行时间衰减
            current_time = datetime.utcnow()
            max_days = 30  # 最大天数窗口
            
            for behavior in behaviors:
                user_idx = user_to_idx[behavior.user_id]
                product_idx = product_to_idx[behavior.product_id]
                
                # 计算时间衰减因子（距离现在越远，权重越小）
                days_diff = (current_time - behavior.behavior_time).days
                if days_diff > max_days:
                    continue
                time_decay = 1.0 - (days_diff / max_days)
                
                # 根据行为类型分配权重，并应用时间衰减
                if behavior.behavior_type == 'purchase':
                    user_product_matrix[user_idx, product_idx] += 3 * time_decay
                elif behavior.behavior_type == 'cart':
                    user_product_matrix[user_idx, product_idx] += 2 * time_decay
                else:  # view
                    user_product_matrix[user_idx, product_idx] += 1 * time_decay
            
            print(f"开始计算 {n_products} 个商品的相似度")
            
            # 设置相似度阈值
            SIMILARITY_THRESHOLD = 0.1  # 提高相似度阈值
            similarity_count = 0
            batch_size = 100  # 批处理大小
            
            # 分批计算相似度以减少内存使用
            for i in range(0, n_products, batch_size):
                batch_end = min(i + batch_size, n_products)
                batch_products = product_ids[i:batch_end]
                
                for j, product1 in enumerate(batch_products, i):
                    # 获取商品1的用户评分向量
                    vec1 = user_product_matrix[:, product_to_idx[product1]]
                    vec1_norm = np.linalg.norm(vec1)
                    
                    if vec1_norm == 0:
                        continue
                    
                    # 只计算与当前商品之后的商品的相似度
                    for k in range(j + 1, n_products):
                        product2 = product_ids[k]
                        vec2 = user_product_matrix[:, product_to_idx[product2]]
                        vec2_norm = np.linalg.norm(vec2)
                        
                        if vec2_norm == 0:
                            continue
                        
                        # 计算余弦相似度
                        similarity = np.dot(vec1, vec2) / (vec1_norm * vec2_norm)
                        
                        # 只保存超过阈值的相似度
                        if similarity >= SIMILARITY_THRESHOLD:
                            # 保存相似度
                            similarity_record = ProductSimilarity(
                                product_id=product1,
                                similar_product_id=product2,
                                similarity_score=float(similarity)
                            )
                            db.session.add(similarity_record)
                            
                            # 反向关系
                            reverse_similarity = ProductSimilarity(
                                product_id=product2,
                                similar_product_id=product1,
                                similarity_score=float(similarity)
                            )
                            db.session.add(reverse_similarity)
                            similarity_count += 2
                
                # 每批次提交一次
                db.session.commit()
                print(f"已处理 {batch_end}/{n_products} 个商品")
            
            print(f"商品相似度计算完成，共生成 {similarity_count} 条相似度记录")
            
        except Exception as e:
            db.session.rollback()
            print(f"计算商品相似度时出错: {str(e)}")
            raise

    @staticmethod
    def sync_historical_purchases():
        """同步历史订单的购买行为到用户行为表
        
        将历史订单中的购买记录同步到用户行为表中，用于后续的推荐计算
        """
        # 获取所有已支付的订单
        paid_orders = Order.query.filter_by(status='paid').all()
        
        for order in paid_orders:
            # 获取订单中的所有商品
            for item in order.items:
                # 检查是否已存在购买行为记录
                existing_behavior = UserBehavior.query.filter_by(
                    user_id=order.user_id,
                    product_id=item.product_id,
                    behavior_type='purchase'
                ).first()
                
                # 如果不存在，则添加记录
                if not existing_behavior:
                    behavior = UserBehavior(
                        user_id=order.user_id,
                        product_id=item.product_id,
                        behavior_type='purchase',
                        behavior_time=order.updated_at or order.created_at
                    )
                    db.session.add(behavior)
        
        try:
            db.session.commit()
            print("历史购买行为同步完成")
        except Exception as e:
            db.session.rollback()
            print(f"同步失败: {str(e)}")